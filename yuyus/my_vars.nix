rec {
  this-host = "yuyus";
  dirs = rec {
    user-home = "/home/${this-host}";
    home = "/mnt/server";
    structure = "${home}/Structure";
    sync = "${home}/Sync";
    shared = "${structure}/Shared";
    storage = "${shared}/Storage";
    deploy = "${shared}/Deploy";
    user = "${structure}/User";
    programs = "${storage}/Programs";
    settings = "${storage}/Settings";
    nixos = "${deploy}/NixOS";
    nextcloud-home = "${home}/Nextcloud";
  };
}
