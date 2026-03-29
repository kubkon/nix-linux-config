{ config, pkgs, lib, ... }:

let
  userName = "Jakub Konka";
  userEmail = "kubkon@jakubkonka.com";
  signingKey = "~/.ssh/id_ecdsa_sk.pub";
  allowedSigners = "~/.ssh/allowed_signers";
  gpgFormat = "ssh";
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kubkon";
  home.homeDirectory = "/home/kubkon";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    _1password-cli
    _1password-gui
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.forgit
    fishPlugins.hydro
    fzf
    fishPlugins.grc
    grc
    networkmanagerapplet
    wl-clipboard
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kubkon/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.niri.settings = {
    spawn-at-startup = [
      { command = ["mako"]; }
      { command = [ "${lib.getExe pkgs.networkmanagerapplet}" ]; }
    ];
    binds = {
      "Mod+D".action.spawn = "fuzzel";
      "Mod+Return".action.spawn = "ghostty";
      "Mod+Q".action.close-window = [];
      "Mod+Shift+E".action.quit = [];
      "Mod+L".action.spawn = "swaylock";
    };
    input = {
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
      keyboard.xkb = {
        layout = "us,us";
        variant = "colemak,";
        options = "grp:win_space_toggle";
      };
      touchpad = {
        tap = true;
        natural-scroll = true;
      };
    };
    layout = {
      shadow.enable = true;
      gaps = 8;
      focus-ring.enable = true;
    };
    outputs = {
      "eDP-1".scale = 2.0;
      "DP-2".scale = 1.5;
    };
    prefer-no-csd = true;
  };

  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    fonts = {
      serif = {
        package = pkgs.nerd-fonts.monaspace;
        name = "MonaspiceXe Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.monaspace;
        name = "MonaspiceNe Nerd Font";
      };
      monospace = {
        package = pkgs.nerd-fonts.monaspace;
        name = "MonaspiceKr Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 11;
        terminal = 11;
        popups = 11;
        desktop = 11;
      };
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.main = {
      modules-left = [
        "niri/workspaces"
      ];
      modules-center = [
        "niri/window"
      ];
      modules-right = [
        "idle_inhibitor"
        "pulseaudio"
        "battery"
        "tray"
        "clock"
      ];
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
      "niri/workspaces" = {
        format = "{icon} {value}";
        format-icons = {
          active = "";
          default = "";
        };
      };
      "niri/window" = {
        icon = true;
      };
      clock = {
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format-alt =  "{:%Y-%m-%d}";
      };
      pulseaudio = {
        format = "{icon}";
        format-bluetooth = "{icon} ";
        format-muted = "󰝟";
        format-icons = {
          headphone = "";
          default = [
            ""
            ""
          ];
        };
        scroll-step = 1;
        on-click = "pavucontrol";
      };
      tray = {
        icon-size = 21;
        spacing = 10;
      };
      battery = {
        format = "{icon}";

        format-icons = [
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂀"
          "󰂁"
          "󰂂"
          "󰁹"
        ];
        states = {
          battery-10 = 10;
          battery-20 = 20;
          battery-30 = 30;
          battery-40 = 40;
          battery-50 = 50;
          battery-60 = 60;
          battery-70 = 70;
          battery-80 = 80;
          battery-90 = 90;
          battery-100 = 100;
        };

        format-plugged = "󰚥";
        format-charging-battery-10 = "󰢜";
        format-charging-battery-20 = "󰂆";
        format-charging-battery-30 = "󰂇";
        format-charging-battery-40 = "󰂈";
        format-charging-battery-50 = "󰢝";
        format-charging-battery-60 = "󰂉";
        format-charging-battery-70 = "󰢞";
        format-charging-battery-80 = "󰂊";
        format-charging-battery-90 = "󰂋";
        format-charging-battery-100 = "󰂅";
        tooltip-format = "{capacity}% {timeTo}";
      };
    };
  };
  programs.fuzzel.enable = true;
  programs.swaylock.enable = true;

  programs.ssh = {
    enable = true;
    extraConfig = pkgs.lib.mkBefore ''
    PKCS11Provider=${pkgs.yubico-piv-tool}/lib/libykcs11.so
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      font-size = 10;
      background = "282828";
      foreground = "dedede";
      keybind = [
        "ctrl+d=new_split:right"
        "ctrl+left_bracket=goto_split:left"
        "ctrl+right_bracket=goto_split:right"
        "ctrl+shift+left_bracket=previous_tab"
        "ctrl+shift+right_bracket=next_tab"
      ];
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = userName;
        email = userEmail;
      };
      gpg.ssh.allowedSignersFile = allowedSigners;
    };
    signing = {
      format = "ssh";
      key = signingKey;
      signByDefault = true;
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = userName;
        email = userEmail;
      };
      signing = {
        backend = "ssh";
        key = signingKey;
        backends.ssh.allowed-signers = allowedSigners;
        behavior = "drop";
      };
      git.sign-on-push = true;
      ui = {
        editor = "hx";
      };
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      editor = {
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        bufferline = "multiple";
        statusline = {
          left = [
            "mode"
            "spinner"
            "spacer"
            "diagnostics"
            "file-name"
            "separator"
            "spacer"
            "version-control"
          ];
          right = [
            "file-type"
            "file-encoding"
            "file-line-ending"
            "position"
            "position-percentage"
            "total-line-numbers"
          ];
          separator = "⌥";
        };
        lsp = {
          display-inlay-hints = true;
        };
        end-of-line-diagnostics = "disable";
        inline-diagnostics = {
          cursor-line = "hint";
        };
      };

      keys = {
        normal = {
          C = [
            "extend_to_line_end"
            "yank_main_selection_to_clipboard"
            "delete_selection"
            "insert_mode"
          ];
          D = [
            "extend_to_line_end"
            "yank_main_selection_to_clipboard"
            "delete_selection"
          ];
          V = [
            "select_mode"
            "extend_to_line_bounds"
          ];
          "{" = [
            "extend_to_line_bounds"
            "goto_prev_paragraph"
          ];
          "}" = [
            "extend_to_line_bounds"
            "goto_next_paragraph"
          ];
          "*" = [
            "move_char_right"
            "move_prev_word_start"
            "move_next_word_end"
            "search_selection"
            "search_next"
          ];
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
        };

        insert = {
          esc = [
            "collapse_selection"
            "normal_mode"
          ];
        };

        select = {
          esc = [
            "collapse_selection"
            "keep_primary_selection"
            "normal_mode"
          ];
          "{" = [
            "extend_to_line_bounds"
            "goto_prev_paragraph"
          ];
          "}" = [
            "extend_to_line_bounds"
            "goto_next_paragraph"
          ];
        };
      };
    };
  };

  services.mako.enable = true;
  services.polkit-gnome.enable = true;
  services.network-manager-applet.enable = true;

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "swaylock";
      }
      {
        timeout = 360;
        command = "niri msg action power-off-monitors";
        resumeCommand = "niri msg action power-on-monitors";
      }
    ];
    events = {
      before-sleep = "swaylock";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
