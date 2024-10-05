{ config, lib, pkgs, inputs, ... }:

let
  homeDir = "/home/yuyus";
  serverDir = "/mnt/server";
  structureDir = "${serverDir}/Structure";
  syncDir = "${serverDir}/Sync";
  sharedDir = "${structureDir}/Shared";
  storageDir = "${sharedDir}/Storage";
  deployDir = "${sharedDir}/Deploy";
  userDir = "${structureDir}/User";
  programsDir = "${storageDir}/Programs";
  settingsDir = "${storageDir}/Settings";
  nixosDir = "${deployDir}/NixOS/yuyus";
in
{
  # NixOS
  fileSystems =  {
    "${nixosDir}" = {
      device = "/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
    };
    "${syncDir}/Symlinks/VY" = {
      device = "${userDir}/Vaults/My/Хранилище/Базы данных/VY";
      fsType = "none";
      options = [ "bind" ];
    };
    "${serverDir}/Pictures/Camera" = {
      device = "${syncDir}/YuYuM/Camera";
      fsType = "none";
      options = [ "bind" ];
    };
  };
  services.syncthing.configDir = "${programsDir}/Syncthing/YuYuS";
}
