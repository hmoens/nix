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
    pkgs.helm
    pkgs.nerd-fonts.adwaita-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.nixfmt-rfc-style
    pkgs.pastel
    pkgs.rustup
    pkgs.ruff
    pkgs.uv
    pkgs.go
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

  programs.fzf = {
    tmux.enableShellIntegration = true;
    enable = true;
  };

  programs.lazygit.enable = true;
  programs.k9s.enable = true;
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible

      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim "session"
        '';
      }

      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }

      cpu
    ];

    extraConfig = ''
      # place status line at top
      set -g status-position top
      set -g status on

      set -g default-terminal "screen-256color"
      setw -g mode-keys vi
      set -g mouse on
      set -g history-limit 10000

      set -g status-bg black
      set -g status-fg white
      setw -g window-status-separator ""

      set -g status-left-length 100
      set -g status-left " #{@context} "
      set -g status-right "  #S "
      set -g status-justify right

      # set -g pane-border-status top
      # set -g pane-border-format "#{@context}"

      set-hook -g after-new-session "run-shell '~/.config/tmux/theme.sh #{session_name}'"
      set-hook -g after-new-window "run-shell '~/.config/tmux/theme.sh #{session_name}'"
      set-hook -g client-session-changed "run-shell '~/.config/tmux/theme.sh #{session_name}'"

      run-shell '~/.config/tmux/theme.sh #{session_name}'
    '';
  };

  home.file.".config/tmux/theme.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -e
      set -u

      SESSION_NAME="$1"

      HASH=$(echo -n "$SESSION_NAME" | md5sum | cut -c1-6)
      HUE=$((0x''${HASH} % 360))

      COLOR_LIGHT=$(${pkgs.pastel}/bin/pastel format hex "hsl($HUE,50%,75%)")
      COLOR_GREY=$(${pkgs.pastel}/bin/pastel format hex "hsl($HUE,25%,40%)")
      COLOR_DARK=$(${pkgs.pastel}/bin/pastel format hex "hsl($HUE,50%,20%)")

      tmux set-option -t "$SESSION_NAME" status-bg "$COLOR_DARK"
      tmux set-option -t "$SESSION_NAME" status-left "#[fg=$COLOR_LIGHT, bold] #{@context} "
      tmux set-option -t "$SESSION_NAME" status-right "#[fg=$COLOR_LIGHT, bold] #S  "
      tmux set-option -t "$SESSION_NAME" pane-border-style "fg=$COLOR_DARK"
      tmux set-option -t "$SESSION_NAME" pane-active-border-style "fg=$COLOR_LIGHT"
      tmux setw -t "$SESSION_NAME" window-status-current-format "#[fg=$COLOR_LIGHT,bg=$COLOR_DARK]#[fg=$COLOR_DARK,bg=$COLOR_LIGHT,bold] #I:#W #[fg=$COLOR_DARK,bg=$COLOR_LIGHT]#[default]"
      tmux setw -t "$SESSION_NAME" window-status-format "#[fg=$COLOR_GREY,bg=$COLOR_DARK]#[fg=$COLOR_LIGHT,bg=$COLOR_GREY,bold] #I:#W #[fg=$COLOR_DARK,bg=$COLOR_GREY]#[default]"
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    # Kubectl aliases based on joke/zim-kubectl
    shellAliases =
      let
        # helper to flatten attrsets
        merge = attrs: builtins.foldl' (a: b: a // b) { } (builtins.attrValues attrs);

        other = {
          "lg" = "lazygit";
        };

        kubernetes_basic = {
          "k" = "kubectl";
          "kg" = "kubectl get";
          "kgf" = "kubectl get -f";
          "kgk" = "kubectl get -k";
          "kgl" = "kubectl get -l";
          "kgw" = "kubectl get -o wide";
          "kgwa" = "kubectl get --watch";
          "kgy" = "kubectl get -o yaml";
          "ke" = "kubectl edit";
          "kef" = "kubectl edit -f";
          "kek" = "kubectl edit -k";
          "kel" = "kubectl edit -l";
          "kdel" = "kubectl delete";
          "kdelf" = "kubectl delete -f";
          "kdelk" = "kubectl delete -k";
          "kdell" = "kubectl delete -l";
          "kd" = "kubectl describe";
          "kdl" = "kubectl describe -l";
          "kccc" = "kubectl config current-context";
          "kcdc" = "kubectl config delete-context";
          "kcgc" = "kubectl config get-contexts";
          "kcsc" = "kubectl config set-context";
          "kcscn" = "kubectl config set-context --current --namespace";
          "kcuc" = "kubectl config use-context";
          "kla" = "kubectl label";
          "klal" = "kubectl label -l";
          "kan" = "kubectl annotate";
          "kanl" = "kubectl annotate -l";
          "kaf" = "kubectl apply -f";
          "kak" = "kubectl apply -k";
          "kl" = "kubectl logs";
          "klf" = "kubectl logs -f";
          "keti" = "kubectl exec -t -i";
          "kpf" = "kubectl port-forward";
          "ktno" = "kubectl top node";
          "ktpo" = "kubectl top pod";
        };

        kubernetes_resource =
          builtins.mapAttrs
            (abbr: res: {
              "kd${abbr}" = "kubectl describe ${res}";
              "kg${abbr}" = "kubectl get ${res}";
              "kg${abbr}l" = "kubectl get ${res} -l";
              "kg${abbr}w" = "kubectl get ${res} -o wide";
              "kg${abbr}wa" = "kubectl get ${res} --watch";
              "kg${abbr}y" = "kubectl get ${res} -o yaml";
              "ke${abbr}" = "kubectl edit ${res}";
              "kdel${abbr}" = "kubectl delete ${res}";
            })
            {
              a = "all";
              cj = "cronjob";
              cm = "configmap";
              cr = "clusterrole";
              crb = "clusterrolebinding";
              ds = "daemonset";
              dep = "deployment";
              deploy = "deployment";
              hpa = "horizontalpodautoscaler";
              ing = "ingress";
              j = "job";
              no = "node";
              ns = "namespace";
              pc = "priorityclass";
              pdb = "poddisruptionbudget";
              po = "pod";
              pv = "persistentvolume";
              pvc = "persistentvolumeclaim";
              rc = "replicationcontroller";
              rs = "replicaset";
              sa = "serviceaccount";
              sec = "secret";
              sts = "statefulset";
              svc = "service";
            };
      in
      other // kubernetes_basic // merge kubernetes_resource;

    initExtra = ''
      if [[ -n "$TMUX" ]]; then
        export STARSHIP_CONFIG=/home/hmoens/.config/starship_tmux.toml

        # Use starship to generate tmux pane titles
        starship_tmux_pane_title() {
            tmux set-option -p @context "$(STARSHIP_CONFIG=/home/hmoens/.config/starship_title.toml starship prompt)"
        }

        precmd_functions+=(starship_tmux_pane_title)
      fi
    '';
  };

  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";

    # Plugins
    plugins = {
      lualine.enable = true;

      bufferline.enable = true;

      nvim-tree = {
        enable = true;
        view.width = 30;
        openOnSetup = true;
      };

      cmp.enable = true;

      telescope.enable = true;

      luasnip.enable = true;

      lspconfig.enable = true;

      web-devicons.enable = true;

      persistence.enable = true;

      scrollview = {
        enable = true;
      };
    };

    keymaps = [
      {
        action = ":NvimTreeToggle<CR>";
        key = "<leader>e";
      }

      {
        key = "<leader>1";
        action = ":BufferLineGoToBuffer 1<CR>";
      }
      {
        key = "<leader>2";
        action = ":BufferLineGoToBuffer 2<CR>";
      }
      {
        key = "<leader>3";
        action = ":BufferLineGoToBuffer 3<CR>";
      }
      {
        key = "<leader>q";
        action = ":bd<CR>";
      }
      {
        key = "<leader>q";
        action = "<cmd>quitall<CR>";
        options.silent = true;
      }
    ];
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
          git = "blue";
          base = "black";
          error = "red";
          context = "cyan";
          success = "green";
        };

        catppuccin_mocha = {
          git = "#f9e2af";
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
    };
  };

  # Secondary starhip config, used when inside tmux.
  home.file.".config/starship_tmux.toml".source = (pkgs.formats.toml { }).generate "starship_tmux" {
    # General
    add_newline = false;
    format = " $character $line_break";

    character = {
      disabled = false;
      format = "$symbol";
    };
  };

  # Secondary starhip config, used to generate tmux pane titles.
  home.file.".config/starship_title.toml".source = (pkgs.formats.toml { }).generate "starship_title" {
    add_newline = false;
    format = "$directory(  $git_branch$git_status)(  $kubernetes) ";

    directory = {
      format = "$path";
      truncation_length = 5;
      truncation_symbol = "…/";
      truncate_to_repo = false;
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
      format = " $symbol $branch ";
    };

    git_status = {
      format = " ($all_status$ahead_behind )";
    };

    kubernetes = {
      disabled = false;
      format = "$symbol$context(/($namespace))";
    };
  };

  programs.zoxide.enable = true;

  programs.sesh = {
    enable = true;
    settings = {
      dir_length = 2;
    };
  };
}
