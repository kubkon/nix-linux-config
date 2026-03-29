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

    binds =
      with config.lib.niri.actions;
      let
        mod = "Mod";
        set-volume = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@";
        brillo = spawn "${pkgs.brillo}/bin/brillo" "-q" "-u" "300000";
        playerctl = spawn "${pkgs.playerctl}/bin/playerctl";
      in
      {
        "${mod}+D".action = spawn "fuzzel";
        "${mod}+Return".action = spawn "ghostty";
        "${mod}+Q".action = close-window;
        "${mod}+Shift+E".action = quit;
        "${mod}+Shift+L".action = spawn "swaylock";
        "${mod}+Shift+Slash".action = show-hotkey-overlay;

        XF86AudioRaiseVolume.action = set-volume "5%+";
        XF86AudioLowerVolume.action = set-volume "5%-";
        XF86AudioMute.action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
        XF86AudioMicMute.action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";

        XF86AudioPlay.action = playerctl "play-pause";
        XF86AudioStop.action = playerctl "pause";
        XF86AudioPrev.action = playerctl "previous";
        XF86AudioNext.action = playerctl "next";

        XF86MonBrightnessUp.action = brillo "-A" "5";
        XF86MonBrightnessDown.action = brillo "-U" "5";

        # // Open/close the Overview: a zoomed-out view of workspaces and windows.
        # // You can also move the mouse into the top-left hot corner,
        # // or do a four-finger swipe up on a touchpad.
        "${mod}+O" = {
          action = toggle-overview;
          repeat = false;
        };

        "${mod}+P".action.screenshot = { show-pointer = false; };
        "${mod}+Shift+P".action.screenshot-screen = { show-pointer = false; };
        "${mod}+Ctrl+P".action.screenshot-window = { show-pointer = false; };

        "${mod}+R".action = switch-preset-column-width;
        "${mod}+Shift+R".action = reset-window-height;
        "${mod}+F".action = maximize-column;
        "${mod}+Shift+F".action = fullscreen-window;
        "${mod}+C".action = center-column;

        "${mod}+Shift+Q".action = close-window;
        "${mod}+Left".action = focus-column-left;
        "${mod}+Down".action = focus-workspace-down;
        "${mod}+Up".action = focus-workspace-up;
        "${mod}+Right".action = focus-column-right;

        "${mod}+Shift+Left".action = move-column-left;
        "${mod}+Shift+Right".action = move-column-right;
        "${mod}+Shift+Down".action = move-column-to-workspace-down;
        "${mod}+Shift+Up".action = move-column-to-workspace-up;

        # There are also commands that consume or expel a single window to the side.
        "${mod}+BracketLeft".action = consume-or-expel-window-left;
        "${mod}+BracketRight".action = consume-or-expel-window-right;

        # // Move the focused window between the floating and the tiling layout.
        "${mod}+V".action = toggle-window-floating;
        "${mod}+Shift+V".action = switch-focus-between-floating-and-tiling;

        # // Finer width adjustments.
        # // This command can also:
        # // * set width in pixels: "1000"
        # // * adjust width in pixels: "-5" or "+5"
        # // * set width as a percentage of screen width: "25%"
        # // * adjust width as a percentage of screen width: "-10%" or "+10%"
        # // Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
        # // set-column-width "100" will make the column occupy 200 physical screen pixels.
        "${mod}+Minus".action = set-column-width "-10%";
        "${mod}+Equal".action = set-column-width "+10%";

        # // Finer height adjustments when in column with other windows.
        "${mod}+Shift+Minus".action = set-window-height "-10%";
        "${mod}+Shift+Equal".action = set-window-height "+10%";

        # // You can refer to workspaces by index. However, keep in mind that
        # // niri is a dynamic workspace system, so these commands are kind of
        # // "best effort". Trying to refer to a workspace index bigger than
        # // the current workspace count will instead refer to the bottommost
        # // (empty) workspace.
        # //
        # // For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
        # // will all refer to the 3rd workspace.
        "${mod}+1".action = focus-workspace 1;
        "${mod}+2".action = focus-workspace 2;
        "${mod}+3".action = focus-workspace 3;
        "${mod}+4".action = focus-workspace 4;
        "${mod}+5".action = focus-workspace 5;
        "${mod}+6".action = focus-workspace 6;
        "${mod}+7".action = focus-workspace 7;
        "${mod}+8".action = focus-workspace 8;
        "${mod}+9".action = focus-workspace 9;

        # The wonky format used here is to work-around https://github.com/sodiboo/niri-flake/issues/944
        "${mod}+Shift+1".action.move-column-to-workspace = [ 1 ];
        "${mod}+Shift+2".action.move-column-to-workspace = [ 2 ];
        "${mod}+Shift+3".action.move-column-to-workspace = [ 3 ];
        "${mod}+Shift+4".action.move-column-to-workspace = [ 4 ];
        "${mod}+Shift+5".action.move-column-to-workspace = [ 5 ];
        "${mod}+Shift+6".action.move-column-to-workspace = [ 6 ];
        "${mod}+Shift+7".action.move-column-to-workspace = [ 7 ];
        "${mod}+Shift+8".action.move-column-to-workspace = [ 8 ];
        "${mod}+Shift+9".action.move-column-to-workspace = [ 9 ];
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
      focus-ring = {
        enable = true;
        width = 2;
      };
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
    style = ''
    @define-color module-bg @base01;

    #pulseaudio,
    #pulseaudio.muted {
      background: @module-bg;
      border-radius: 4px;
      padding: 0 18px 0 8px;
      margin: 4px 0;
    }

    #upower.charging,
    #battery.charging {
      background: @module-bg;
      border-radius: 4px;
      padding: 0 10px 0 8px;
      margin: 4px 0;
    }

    #upower,
    #battery,
    #clock,
    #tray {
      background: @module-bg;
      border-radius: 4px;
      padding: 0 8px 0 8px;
      margin: 4px 0;
    }

    #pulseaudio,
    #pulseaudio.muted,
    #upower,
    #battery,
    #upower.charging,
    #battery.charging,
    #idle_inhibitor {
      font-family: "Noto Color Emoji";
      font-size: 13pt;
    }

    #idle_inhibitor {
      background: @module-bg;
      border-radius: 20px 4px 4px 20px;
      padding: 8px 16px 8px 20px; /* 20px padding-left is necessary to create uniform left/right edges */
      margin: 4px 0;
    }

    #custom-blank {
      background: @module-bg;
      border-radius: 0 20px 20px 0;
      padding-right: 12px; /* 12px padding-right = minimum necessary to create uniform left/right edges */
      margin: 4px 4px 4px -12px; /* set a negative margin-left to: 1. cover the config-defined spacing between modules, 2. cover the 4px border-radius of the nearest module for a clean top/bottom, 3. cover the additional space left by an empty tray */
    }
    '';
    settings.main = {
      spacing = 4;
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
        "custom/blank"
      ];
      "custom/blank" = {
        format = " ";
        tooltip = false;
      };
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
      # font-size = 10;
      # background = "282828";
      # foreground = "dedede";
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
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 360;
        command = "${pkgs.niri-unstable}/bin/niri msg action power-off-monitors";
        resumeCommand = "${pkgs.niri-unstable}/bin/niri msg action power-on-monitors";
      }
    ];
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
