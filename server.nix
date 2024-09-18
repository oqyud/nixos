{
  config,
  pkgs,
  libs,
  inputs,
  ...
}:

{

  imports = [
    ./hardware-configuration.nix # Аппаратная часть
  ];

  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Локализация
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "ru_RU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    #extraLocaleSettings = {
    #  LC_ALL = "en_US.UTF-8";
    #  LC_LANGUAGE = "en_US.UTF-8";
    #  LC_ADDRESS = "en_US.UTF-8";
    #  LC_IDENTIFICATION = "en_US.UTF-8";
    #  LC_MEASUREMENT = "en_US.UTF-8";
    #  LC_MONETARY = "en_US.UTF-8";
    #  LC_NAME = "en_US.UTF-8";
    #  LC_NUMERIC = "en_US.UTF-8";
    #  LC_PAPER = "en_US.UTF-8";
    #  LC_TELEPHONE = "en_US.UTF-8";
    #  LC_TIME = "en_US.UTF-8";
    #};
    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
    # };
  };

  time.timeZone = "Europe/Moscow";

  # Конфигурация NixOS
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
  ];

  #  home-manager = {
  #    extraSpecialArgs = { inherit inputs; };
  #    users = {
  #      "yuyus" = import ./home.nix;
  #    };
  #  };

  # Пользователи
  users.users.yuyus = {
    isNormalUser = true;
    description = "YuYuS";
    extraGroups = [
      "networkmanager"
      "wheel"
      "yuyus"
    ];
    packages = with pkgs; [ ];
  };

  services = {
    calibre-web = {
      enable = true;
      group = "users";
      user = "yuyus";
      dataDir = "/home/yuyus";
      calibreLibrary = "/home/yuyus/Library";
      #listen.port = 8083;
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
      };
    };
    transmission.enable = true;
    cockpit.enable = true; # Обычный порт 9090
    syncthing = {
      enable = true;
      systemService = true;
      dataDir = "/home/yuyus";
      group = "users";
      user = "yuyus";
    };
    tailscale.enable = true;
    #httpd.enable = true;
  };
  security = {
    sudo.wheelNeedsPassword = false;
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
            if ((action.id == "org.gnome.gparted" || // Для гнома
                action.id == "org.freedesktop.policykit.exec") && // Для запуска Nekoray
                subject.isInGroup("wheel")){ // Операции sudo
                return polkit.Result.YES;
            }
        });
      '';
    };
  };

  environment = {
    systemPackages = with pkgs; [
      bash-completion
      nix-bash-completions
      acl
      pciutils # Info
      mc # tty
      btop # tty
      lf # tty
      parted # Disks
      smartmontools # tty
      nixfmt-rfc-style # Fronmatter

      # Something
      #
      #iptables
      #efibootmgr # Info
    ];
  };

  systemd.services = {
    base-start = {
      path = [ "/run/current-system/sw" ]; # Запуск в текущей системе
      description = "YuYuL";
      script = ''
        setfacl -R -m u:yuyul:rwx /etc/nixos
        nixfmt /etc/nixos
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  # use the example session manager (no others are packaged yet so this is enabled by default,
  # no need to redefine it in your config for now)
  #media-session.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";

}
