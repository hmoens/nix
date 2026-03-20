{
  config,
  pkgs,
  lib,
  username,
  homeDirectory,
  userEmail,
  ...
}:

{
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "25.05";

  home.packages = [
    pkgs.kubectl
    pkgs.kubectx
    pkgs.minikube
    pkgs.kubernetes-helm
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
    pkgs.lazyjournal
    pkgs.fluxcd
    pkgs.tenv
    pkgs.azure-cli
    pkgs.vcluster
    pkgs.glab
    pkgs.k9s
  ];

  home.file = { };

  home.sessionVariables = {
    PASSWORD_STORE_DIR = "${config.home.homeDirectory}/src/devtoolspass";
    EDITOR = "nvim";
    KUBECACHEDIR = "${config.home.homeDirectory}/.kube/cache";
  };

  programs.fzf = {
    tmux.enableShellIntegration = true;
    enable = true;
  };

  programs.nushell.enable = true;

  programs.lazygit.enable = true;
  programs.k9s.enable = true;
  programs.kubecolor = {
    enable = true;
    enableZshIntegration = true;
  };

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
      tmux set-option -t "$SESSION_NAME" status-left "#[fg=$COLOR_DARK,bg=$COLOR_LIGHT] #{@context} #[fg=$COLOR_LIGHT,bg=$COLOR_DARK]"
      tmux set-option -t "$SESSION_NAME" status-right "#[fg=$COLOR_LIGHT,bold] #S  "
      tmux set-option -t "$SESSION_NAME" pane-border-style "fg=$COLOR_DARK"
      tmux set-option -t "$SESSION_NAME" pane-active-border-style "fg=$COLOR_LIGHT"
      tmux setw -t "$SESSION_NAME" window-status-current-format "#[fg=$COLOR_LIGHT,bg=$COLOR_DARK]#[fg=$COLOR_DARK,bg=$COLOR_LIGHT,bold] #I:#W #[fg=$COLOR_DARK,bg=$COLOR_LIGHT]#[default]"
      tmux setw -t "$SESSION_NAME" window-status-format "#[fg=$COLOR_GREY,bg=$COLOR_DARK]#[fg=$COLOR_LIGHT,bg=$COLOR_GREY,bold] #I:#W #[fg=$COLOR_DARK,bg=$COLOR_GREY]#[default]"
    '';
  };

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    completionInit = "autoload -U compinit && compinit -u";

    shellAliases =
      let
        merge = attrs: builtins.foldl' (a: b: a // b) { } (builtins.attrValues attrs);

        other = {
          "lg" = "lazygit";
        };

        kubernetes_basic = {
          "k" = "kubecolor";
          "kg" = "kubecolor get";
          "kgf" = "kubecolor get -f";
          "kgk" = "kubecolor get -k";
          "kgl" = "kubecolor get -l";
          "kgw" = "kubecolor get -o wide";
          "kgwa" = "kubecolor get --watch";
          "kgy" = "kubecolor get -o yaml";
          "ke" = "kubecolor edit";
          "kef" = "kubecolor edit -f";
          "kek" = "kubecolor edit -k";
          "kel" = "kubecolor edit -l";
          "kdel" = "kubecolor delete";
          "kdelf" = "kubecolor delete -f";
          "kdelk" = "kubecolor delete -k";
          "kdell" = "kubecolor delete -l";
          "kd" = "kubecolor describe";
          "kdl" = "kubecolor describe -l";
          "kccc" = "kubecolor config current-context";
          "kcdc" = "kubecolor config delete-context";
          "kcgc" = "kubecolor config get-contexts";
          "kcsc" = "kubecolor config set-context";
          "kcscn" = "kubecolor config set-context --current --namespace";
          "kcuc" = "kubecolor config use-context";
          "kla" = "kubecolor label";
          "klal" = "kubecolor label -l";
          "kan" = "kubecolor annotate";
          "kanl" = "kubecolor annotate -l";
          "kaf" = "kubecolor apply -f";
          "kak" = "kubecolor apply -k";
          "kl" = "kubecolor logs";
          "klf" = "kubecolor logs -f";
          "keti" = "kubecolor exec -t -i";
          "kpf" = "kubecolor port-forward";
          "ktno" = "kubecolor top node";
          "ktpo" = "kubecolor top pod";
        };

        kubernetes_resource =
          builtins.mapAttrs
            (abbr: res: {
              "kd${abbr}" = "kubecolor describe ${res}";
              "kg${abbr}" = "kubecolor get ${res} -o wide";
              "kg${abbr}l" = "kubecolor get ${res} -l";
              "kg${abbr}w" = "kubecolor get ${res} --watch";
              "kg${abbr}y" = "kubecolor get ${res} -o yaml";
              "ke${abbr}" = "kubecolor edit ${res}";
              "kdel${abbr}" = "kubecolor delete ${res}";
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

    initContent =
      let
        zshKubec = lib.mkOrder 600 ''
          . ${./kubec.sh}
        '';
      in
      lib.mkMerge [
        zshKubec
      ];
  };

  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";

    plugins = {
      lualine.enable = true;

      bufferline.enable = true;

      nvim-tree = {
        enable = true;
        settings.view.width = 30;
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
    settings.user = {
      name = "Hendrik Moens";
      email = userEmail;
    };
    ignores = [
      "*donotcommit*"
      ".envrc"
    ];
  };

  programs.direnv = {
    enable = true;

    nix-direnv = {
      enable = true;
    };

    enableZshIntegration = true;

    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  programs.zoxide.enable = true;

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = lib.concatStrings [
        "$character"
        "$directory"
        ""
        "$git_branch"
        "$git_status"
        ""
        "$kubernetes"
        ""
        "$direnv"
        ""
        "[](fg:prev_bg)"
        "$line_break"
        "[╰─󰍟 ](fg:gray)"
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
          gray = "#55555b";
          error = "#f38ba8";
          success = "#a6e3a1";
          context = "#cdd6f4";
          ai-os-dev = "#9fd3df";
          ai-dev = "#de9fdf";
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
        repo_root_format = "[ $repo_root]($repo_root_style)[$path ]($style)";
        repo_root_style = "bg:prev_bg fg:base";
        truncation_length = 7;
        truncate_to_repo = true;
        truncation_symbol = "…/";
      };

      git_branch = {
        symbol = "";
        style = "bg:git fg:base";
        format = "[](bg:git fg:prev_bg)[[ $symbol $branch ](fg:base bg:git)]($style)";
      };

      git_status = {
        style = "bg:git fg:base";
        format = "[[ ($all_status$ahead_behind )](fg:base bg:git)]($style)";
      };

      direnv = {
        disabled = false;
        format = "[](bg:gray fg:prev_bg)[ $symbol$loaded$allowed ]($style)";
        style = "bg:gray";
        symbol = "";
        allowed_msg = "";
        not_allowed_msg = " not allowed";
        denied_msg = " denied";
        loaded_msg = "";
        unloaded_msg = " not loaded";
      };

      kubernetes = {
        disabled = false;
        style = "bg:context fg:base";
        symbol = "[](bg:context fg:prev_bg)";
        format = "$symbol[ $context(/($namespace)) ]($style)";

        contexts = [
          {
            context_pattern = "ai-os-dev";
            symbol = "[](bg:ai-os-dev fg:prev_bg)";
            style = "fg:base bg:ai-os-dev";
          }
          {
            context_pattern = "ai-dev";
            symbol = "[](bg:ai-dev fg:prev_bg)";
            style = "fg:base bg:ai-dev";
          }
        ];
      };
    };
  };

  services.ollama.enable = true;
  programs.aider-chat.enable = true;
  programs.opencode.enable = true;
}
