{ config, pkgs, ... }:

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
      font-size = 12; 
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
        signingKey = signingKey;
      };
      gpg = {
        format = gpgFormat;
        ssh.allowedSignersFile = allowedSigners;
      };
      commit.gpgsign = true;
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
        paginate = "never";
      };
    };
  };
  
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "tokyonight";
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
