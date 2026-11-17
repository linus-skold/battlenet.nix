# NixOS-only addendum to module.nix. Kept separate (instead of a runtime
# platform check in module.nix) because module.nix is shared with
# darwinModules.default, which has no `boot.kernel.sysctl` option at all;
# statically omitting this file from darwinModules.default avoids both the
# missing-option error and the need for any pkgs/config-forcing condition.
{ config, lib, ... }: {
  config = lib.mkIf config.programs.battlenet.enable {
    # Per-object inputs can exceed Linux's default sandbox mount limit.
    boot.kernel.sysctl."fs.mount-max" = lib.mkDefault 2000000;
  };
}
