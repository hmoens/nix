{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "hmoens";
  home.homeDirectory = "/home/hmoens";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.kubectl
    pkgs.kubectx
    pkgs.minikube
    pkgs.nerd-fonts.adwaita-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.nixfmt-rfc-style
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
  #  /etc/profiles/per-user/hmoens/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
  };

  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };

  programs.git = {
    enable = true;
    userName = "Hendrik Moens";
    userEmail = "hendrik@moens.io";
  };

  programs.starship = {
    enable = true;
    settings = {
      # General
      add_newline = false;
      format = lib.concatStrings [
        "$character"
        "$directory"
        ""
        "$git_branch"
        "$git_status"
        ""
        "$kubernetes"
        "[ ](fg:prev_bg)"
        "$line_break"
      ];

      palette = "catppuccin_mocha";

      palettes = {
        standard = {
          git = "yellow";
          directory = "blue";
          base = "black";
          error = "red";
          context = "green";
        };

        catppuccin_mocha = {
          git = "#f9e2af";
          directory = "#74c7ec";
          base = "#11111b";
          error = "#f38ba8";
          success = "#a6e3a1";
          context = "#cdd6f4";
        };
      };

      os = {
        disabled = true;
      };

      username = {
        disabled = true;
      };

      # Simply outptut " ", but use the background to
      # indicate success.
      character = {
        disabled = false;
        success_symbol = "[ ](bg:success fg:base)";
        error_symbol = "[ ](bg:error fg:base)";
        format = "$symbol";
      };

      # Inherit background color from character module.
      directory = {
        style = "bg:prev_bg fg:base";
        format = "[$path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:git fg:base";
        format = "[](bg:git fg:prev_bg)[[ $symbol $branch ](fg:base bg:git)]($style)";
      };

      git_status = {
        style = "bg:git fg:base";
        format = "[[ ($all_status$ahead_behind )](fg:base bg:git)]($style)";
      };

      kubernetes = {
        disabled = false;
        style = "bg:context fg:base";
        # Use symbol for the powerline as its fg and bg are reversed
        # this way we can style it in custom contexts.
        symbol = "[](bg:context fg:prev_bg)";
        format = "$symbol[ $context(/($namespace)) ]($style)";

        contexts = [
          {
            # context_pattern = "minikube";
            context_pattern = "prod|production";
            symbol = "[](bg:red fg:prev_bg)[  ]($style)";
            style = "fg:base bg:red";
          }
        ];
      };

      c = {
        disabled = true;
      };
      rust = {
        disabled = true;
      };
      golang = {
        disabled = true;
      };
      nodejs = {
        disabled = true;
      };
      php = {
        disabled = true;
      };
      java = {
        disabled = true;
      };
      kotlin = {
        disabled = true;
      };
      haskell = {
        disabled = true;
      };
      python = {
        disabled = true;
      };
      conda = {
        disabled = true;
      };
      docker_context = {
        disabled = true;
      };
      time = {
        disabled = true;
      };
      line_break = {
        disabled = true;
      };

      cmd_duration = {
        disabled = true;
      };
    };
  };

}
