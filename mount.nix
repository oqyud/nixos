{
  config,
  pkgs,
  ...
}:

let
  homeDir = "/home/yuyul";
  structureDir = "${homeDir}/Structure";
  sharedDir = "${structureDir}/Shared";
  storageDir = "${sharedDir}/Storage";
  programsDir = "${storageDir}/Programs";
  #
  nixosDir = "${sharedDir}/Configs/NixOS";
in
{
  # NixOS резерв
  fileSystems = {
  "${nixosDir}" = {
    device = "/etc/nixos";
    fsType = "none";
    options = [ "bind" ];
    };
  };

  # Nekoray
  fileSystems = {
    "${homeDir}/.config/nekoray" = {
      device = "${programsDir}/Nekoray";
      fsType = "none";
      options = [ "bind" ];
    };
  };
  # Syncthing
  fileSystems = {
    "${homeDir}/.config/syncthing" = {
      device = "${programsDir}/syncthing/YuYuL";
      fsType = "none";
      options = [ "bind" ];
    };
  };
}

