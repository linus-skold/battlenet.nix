# Regression test for https://github.com/linus-skold/battlenet.nix/issues/4:
# importing nixosModules.default must never force `pkgs`/`config` while NixOS
# is still declaring options, or evaluation deadlocks in infinite recursion.
# Covers both the default (disabled) case and an enabled game.
let
  flake = builtins.getFlake (toString ../.);
  nixpkgs = flake.inputs.nixpkgs;
  mkSystem = extraConfig: (nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      flake.nixosModules.default
      ({
        nixpkgs.config.allowUnfree = true;
        boot.isContainer = true;
        boot.loader.grub.enable = false;
        fileSystems."/".device = "/dev/null";
        system.stateVersion = "25.05";
      } // extraConfig)
    ];
  }).config;
  disabled = mkSystem { };
  enabled = mkSystem { programs.battlenet = { enable = true; games.w3.enable = true; }; };
in
assert disabled.system.stateVersion == "25.05";
assert enabled.boot.kernel.sysctl."fs.mount-max" == 2000000;
"ok"
