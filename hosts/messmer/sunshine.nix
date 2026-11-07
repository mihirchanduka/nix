{ lib, pkgs, ... }:
let
  monitorName = "sunshine";
  output = "Virtual-${monitorName}";
  disablePhysical = true;

  runtimeInputs = [
    pkgs.kdePackages.kscreen
    pkgs.kdePackages.krfb
    pkgs.procps
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.util-linux
  ];

  krfbPattern = "krfb-virtualmonitor.*--name ${monitorName}";

  stateSetup = ''
    state="$XDG_RUNTIME_DIR/sunshine-virtual-display"
    mkdir -p "$state"
    exec >>"$state/log" 2>&1
    log() { echo "[$(date '+%F %T')] $*"; }
  '';

  spawnVirtual = resolution: ''
    setsid krfb-virtualmonitor \
      --name ${monitorName} \
      --resolution "${resolution}" \
      --password "$(head -c 24 /dev/urandom | base64)" \
      --port 5905 \
      </dev/null 9>&- &
  '';

  killVirtual = ''
    pkill -f "${krfbPattern}" || true
    for _ in $(seq 40); do
      pgrep -f "${krfbPattern}" >/dev/null || break
      sleep 0.1
    done
  '';

  stop = pkgs.writeShellApplication {
    name = "sunshine-virtual-display-stop";
    inherit runtimeInputs;
    text = ''
      ${stateSetup}
      [ -f "$state/enabled" ] || exit 0
      log "stop"

      while read -r o; do
        [ -n "$o" ] && { kscreenctl "$o" set-enabled true || log "could not enable $o"; }
      done <"$state/enabled"
      if [ -s "$state/primary" ]; then
        kscreenctl "$(cat "$state/primary")" set-primary || true
      fi

      if [ -f "$state/pid" ]; then
        kill "$(cat "$state/pid")" 2>/dev/null || true
      fi
      pkill -f "${krfbPattern}" || true

      rm -f "$state/enabled" "$state/primary" "$state/pid"
    '';
  };

  start = pkgs.writeShellApplication {
    name = "sunshine-virtual-display-start";
    inherit runtimeInputs;
    text = ''
      ${stateSetup}
      exec 9>"$state/lock"
      flock -w 10 9 || log "lock timed out"
      ${lib.getExe stop}

      w="''${SUNSHINE_CLIENT_WIDTH:-1920}"
      h="''${SUNSHINE_CLIENT_HEIGHT:-1080}"
      fps="''${SUNSHINE_CLIENT_FPS:-60}"
      log "start ''${w}x''${h}@''${fps}"

      ${killVirtual}
      kscreenctl list-outputs --enabled --names | grep -vx "${output}" >"$state/enabled" || true
      kscreenctl primary-output get-name >"$state/primary" || true

      ${spawnVirtual "\${w}x\${h}"}
      echo $! >"$state/pid"

      for _ in $(seq 40); do
        kscreenctl list-outputs --names | grep -qx "${output}" && break
        sleep 0.25
      done
      if ! kscreenctl list-outputs --names | grep -qx "${output}"; then
        log "virtual output never appeared, leaving the monitors alone"
        ${lib.getExe stop}
        exit 0
      fi

      kscreenctl ${output} add-custom-mode "''${w}x''${h}@''${fps}" || true
      kscreenctl ${output} set-mode "''${w}x''${h}@''${fps}" \
        || kscreenctl ${output} set-mode "''${w}x''${h}" \
        || log "could not set ''${w}x''${h}@''${fps}"
      kscreenctl ${output} set-primary || true

      ${lib.optionalString disablePhysical ''
        while read -r o; do
          [ -n "$o" ] && { kscreenctl "$o" set-enabled false || log "could not disable $o"; }
        done <"$state/enabled"
      ''}
      log "streaming ${output}"
    '';
  };

  keepalive = pkgs.writeShellApplication {
    name = "sunshine-virtual-display-keepalive";
    inherit runtimeInputs;
    text = ''
      ${stateSetup}
      exec 9>"$state/lock"
      while true; do
        flock 9
        if [ ! -f "$state/enabled" ]; then
          if grep -qx connected /sys/class/drm/card*-*/status 2>/dev/null; then
            if pgrep -f "${krfbPattern}" >/dev/null; then
              log "monitor connected, removing ${output}"
              ${killVirtual}
            fi
          elif ! pgrep -f "${krfbPattern}" >/dev/null; then
            log "no monitor connected, adding ${output}"
            ${spawnVirtual "1920x1080"}
          fi
        fi
        flock -u 9
        sleep 2
      done
    '';
  };
in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    settings = {
      capture = "kwin";
      output_name = output;
      global_prep_cmd = builtins.toJSON [
        {
          do = lib.getExe start;
          undo = lib.getExe stop;
        }
      ];
    };
  };

  systemd.user.services.sunshine.serviceConfig.ExecStopPost = lib.getExe stop;

  systemd.user.services.sunshine-virtual-display-keepalive = {
    description = "Virtual output for Sunshine while no monitor is connected";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = lib.getExe keepalive;
      Restart = "on-failure";
    };
  };

  environment.systemPackages = [
    start
    stop
  ];
}
