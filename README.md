# nix

NixOS flake with home-manager for two machines:

- `messmer`: desktop, KDE Plasma, NVIDIA
- `framework`: Framework Laptop 13, GNOME, AMD

```bash
sudo nixos-rebuild switch --flake .#messmer
```
