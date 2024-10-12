{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  my_vars = import ./my_vars.nix;
in
{
  imports = [
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ./disko.nix
    ./hardware-configuration.nix
  ];

  time.timeZone = "Europe/Moscow";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "ru_RU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" ];

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhxTIqodDYFpXbl12Qe/Sc1PIhsjBrOja+5z3FB/VgF root@yuyus"
        ];
      };
      yuyus = {
        isNormalUser = true;
        description = "YuYuS";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpMaD143EZqhRlpAgNINLrH/qXkN3zXmKgFJlhbhGwg yuyus@yuyus"
        ];
        initialPassword = "4343";
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        packages = with pkgs; [ ];
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      #bash-completion
      #nix-bash-completions
      neofetch
      acl
      pciutils # Info
      mc # tty
      btop # tty
      lf # tty
      parted # Disks
      smartmontools # tty
      nixfmt-rfc-style # Fronmatter
      sing-box
      yazi
      iptables
      efibootmgr # Info
      eza
      inxi
    ];
  };

  fileSystems = {
    "${my_vars.dirs.nixos}" = {
      device = "/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
    };
    "${my_vars.dirs.sync}/Symlinks/VY" = {
      device = "${my_vars.dirs.user}/Vaults/My/Хранилище/Базы данных/VY";
      fsType = "none";
      options = [ "bind" ];
    };
    "${my_vars.dirs.home}/Pictures/Camera" = {
      device = "${my_vars.dirs.sync}/YuYuM/Camera";
      fsType = "none";
      options = [ "bind" ];
    };
  };

  services = {
    earlyoom.enable = true;
    preload.enable = true;
    auto-cpufreq.enable = true;
    throttled.enable = true;
    watchdogd.enable = false;
    journald = {
      extraConfig = ''
        SystemMaxUse=128M
      '';
    };
    samba = {
      enable = true;
      settings = {
        global = {
          "invalid users" = [ ];
          "passwd program" = "/run/wrappers/bin/passwd %u";
          security = "user";
        };
        nixos = {
          "path" = "/etc/nixos";
          "browseable" = "yes";
          "read only" = "no";
          "valid users" = "root yuyus";
          "guest ok" = "no";
          "writable" = "yes";
          "create mask" = 644;
          "directory mask" = 644;
          "force user" = "root";
          "force group" = "root";
        };
        root = {
          "path" = "/";
          "browseable" = "yes";
          "read only" = "no";
          "valid users" = "root yuyus";
          "guest ok" = "no";
          "writable" = "yes";
          #"create mask" = 0644;
          #"directory mask" = 0644;
          "force user" = "root";
          "force group" = "root";
        };
        server = {
          "path" = "/mnt/server";
          "browseable" = "yes";
          "read only" = "no";
          "valid users" = "root yuyus";
          "guest ok" = "no";
          "writable" = "yes";
          "create mask" = 775;
          "directory mask" = 775;
          "force user" = "yuyus";
          "force group" = "users";
        };
      };
    };
    calibre-web = {
      enable = true;
      group = "users";
      user = "yuyus";
      #dataDir = "${my_vars.dirs.home}";
      options = {
        calibreLibrary = "${my_vars.dirs.user}/Library";
        enableBookUploading = true;
        enableKepubify = false;
      };
      listen.ip = "0.0.0.0";
      listen.port = 8083;
      openFirewall = true;
    };
    openssh = {
      enable = true;
      allowSFTP = true;
      hostKeys = [
        {
          path = "/etc/ssh/keys/root";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/keys/yuyus";
          type = "ed25519";
        }
      ];
      settings = {
        UsePAM = true;
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
      };
    };
    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      openRPCPort = true;
      settings = {
        incomplete-dir-enabled = true;
        incomplete-dir = "${my_vars.dirs.home}/Downloads/Temp";
        download-dir = "${my_vars.dirs.home}/Downloads";
        rpc-bind-address = "0.0.0.0";
        rpc-port = 9091;
        rpc-whitelist-enabled = false;
      };
    };
    cockpit = {
      enable = true;
      openFirewall = true;
      port = 9090;
      settings = {
        WebService = {
          AllowUnencrypted = true;
        };
      };
    };
    syncthing = {
      enable = true;
      systemService = true;
      guiAddress = "0.0.0.0:8384";
      configDir = "${my_vars.dirs.programs}/Syncthing/YuYuS";
      dataDir = "${my_vars.dirs.home}";
      group = "users";
      user = "yuyus";
    };
    tailscale.enable = true;
    #httpd.enable = true;
    sing-box = {
      enable = true;
      settings = {
        log = {
          level = "error";
        };
        dns = {
          servers = [
            {
              tag = "dns-remote";
              address = "https://1.1.1.1/dns-query";
              address_resolver = "dns-local";
              strategy = "prefer_ipv4";
              detour = "proxy";
            }
            {
              tag = "dns-direct";
              address = "0.0.0.0";
              address_resolver = "dns-local";
              strategy = "prefer_ipv4";
              detour = "direct";
            }
            {
              tag = "dns-block";
              address = "rcode://success";
            }
            {
              tag = "dns-local";
              address = "0.0.0.0";
              detour = "direct";
            }
          ];
          rules = [
            {
              domain = [
                "tendawifi.com"
                "sync-v2.brave.com"
              ];
              server = "dns-direct";
            }
            {
              query_type = [
                "NIMLOC"
                "SRV"
              ];
              server = "dns-block";
            }
            {
              domain_suffix = ".lan";
              server = "dns-block";
            }
          ];

          independent_cache = true;
        };
        inbounds = [
          {
            type = "mixed";
            tag = "mixed-in";
            listen = "127.0.0.1";
            listen_port = 2080;
            sniff = true;
            domain_strategy = "prefer_ipv4";
          }
          {
            type = "tun";
            tag = "tun-in";
            interface_name = "nekoray-tun";
            mtu = 9000;
            inet4_address = "172.19.0.1/28";
            auto_route = true;
            endpoint_independent_nat = true;
            stack = "system";
            sniff = true;
            domain_strategy = "prefer_ipv4";
          }
        ];
        outbounds = [
          {
            type = "vless";
            tag = "proxy";
            domain_strategy = "prefer_ipv4";
            server = "185.31.200.24";
            server_port = 443;
            uuid = "a085c589-e7d9-43f7-81ad-dff4096c4aa6";
            flow = "xtls-rprx-vision";
            tls = {
              enabled = true;
              server_name = "www.samsung.com";
              utls = {
                enabled = true;
                fingerprint = "chrome";
              };
              reality = {
                enabled = true;
                public_key = "Qnt-WTl02JRNw2ev--JInZ-egrCrK1RDjc927kIPUxk";
                short_id = "8f2a76376de91be1";
              };
            };
            packet_encoding = "";
          }
          {
            type = "direct";
            tag = "direct";
          }
          {
            type = "direct";
            tag = "bypass";
          }
          {
            type = "block";
            tag = "block";
          }
          {
            type = "dns";
            tag = "dns-out";
          }
        ];
        route = {
          rules = [
            {
              protocol = "dns";
              outbound = "dns-out";
            }
            {
              domain = [
                "tendawifi.com"
                "sync-v2.brave.com"
              ];
              outbound = "bypass";
            }
            {
              geoip = "private";
              ip_cidr = [
                "100.64.0.0/10"
                "fd7a:115c:a1e0::/96"
                "192.168.0.0/24"
                "192.168.1.0/24"
              ];
              outbound = "bypass";
            }
            {
              network = "udp";
              port = [
                135
                137
                138
                139
                5353
              ];
              outbound = "block";
            }
            {
              ip_cidr = [
                "224.0.0.0/3"
                "ff00::/8"
              ];
              outbound = "block";
            }
            {
              source_ip_cidr = [
                "224.0.0.0/3"
                "ff00::/8"
              ];
              outbound = "block";
            }
            {
              process_name = [
                ""
              ];
              outbound = "bypass";
            }
          ];
          final = "proxy";
          auto_detect_interface = true;
        };
      };
    };
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

  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 1d --keep 2";
    };
    git.enable = true;
    lazygit.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      syntaxHighlighting.enable = true;
      zsh-autoenv.enable = true;
      loginShellInit = "clear && neofetch";
      ohMyZsh = {
        enable = true;
        theme = "robbyrussell";
      };
    };
    nix-ld = {
      # For binary files execution
      enable = false;
      libraries =
        with pkgs;
        [
        ];
    };
  };

  systemd.services = {
    base-start = {
      path = [ "/run/current-system/sw" ]; # Запуск в текущей системе
      #setfacl -R -m u:yuyus:rwx /etc/nixos
      script = ''
        nixfmt /etc/nixos
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  networking = {
    hostName = "yuyus";
    networkmanager.enable = true;
    firewall.enable = false;
    useDHCP = lib.mkDefault true;
  };

  system = {
    stateVersion = "24.05";
    autoUpgrade = {
      enable = true;
      #flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L" # print build logs
      ];
      dates = "04:00";
      randomizedDelaySec = "45min";
    };
  };
}
