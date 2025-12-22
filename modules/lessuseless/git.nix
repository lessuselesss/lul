{
  flake.modules.homeManager.lessuseless =
    { pkgs, ... }:
    {

      home.packages = [ pkgs.difftastic ];

      programs.git = {
        enable = true;
        signing.format = "ssh";

        settings = {
          user.name = "lessuseless";
          user.email = "lessuseless@duck.com";

          init.defaultBranch = "main";
          pull.rebase = true;
          pager.difftool = true;
          diff.tool = "difftastic";
          difftool.prompt = false;
          difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";

          github.user = "lessuselesss"; # three 's'
          gitlab.user = "lessuseless";

          core.editor = "vim";

          alias = {
            dff = "difftool";
            fap = "fetch --all -p";
            rm-merged = "for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D";
            recents = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
          };
        };

        ignores = [
          ".DS_Store"
          "*.swp"
          ".direnv"
          ".envrc"
          ".envrc.local"
          ".env"
          ".env.local"
          ".jj"
          "devshell.toml"
          ".tool-versions"
          "/.github/chatmodes"
          "/.github/instructions"
          "/lessuseless"
          "*.key"
          "target"
          "result"
          "out"
          "old"
          "*~"
          ".aider*"
          ".crush*"
          "CRUSH.md"
          "GEMINI.md"
          "CLAUDE.md"
        ];
        includes = [ ];
        # { path = "${DOTS}/git/something"; }

        lfs.enable = true;
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          line-numbers = true;
          side-by-side = false;
        };
      };

    };

}
