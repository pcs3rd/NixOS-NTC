
{ config, pkgs, inputs, output, ... }:
{
  home-manager.users.tower = { pkgs, ... }: {
    imports = [ ../extra-config/gnome-setting.nix ];
    # ...
  };   
    home.stateVersion = 24.11;
}