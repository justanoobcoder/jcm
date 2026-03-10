{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.jcm;
in {
  options.programs.jcm = {
    enable = mkEnableOption "JCM (Just a Clipboard Manager)";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./default.nix {};
      description = "The JCM package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services.jcm = {
      Unit = {
        Description = "JCM Clipboard Manager Daemon";
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/jcm-daemon watch";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
