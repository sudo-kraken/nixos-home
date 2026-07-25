{ pkgs-unstable, ... }:
{
  programs = {
    git = {
      enable = true;
      package = pkgs-unstable.git;
      settings = {
        user = {
          name = "Joe Harrison";
          email = "joe@j-harrison.co.uk";
        };
        core.editor = "vi";
        color.ui = true;
        merge.conflictStyle = "zdiff3";
        push.autoSetupRemote = true;
        pull.ff = "only";
      };
    };

    delta = {
      enable = true;
      package = pkgs-unstable.delta;
      enableGitIntegration = true;
      options = {
        line-color = true;
        navigate = true;
        hyperlinks = true;
      };
    };
  };
}
