{
  lib,
  self,
  ...
}:
{
  flake.nixosConfigurations.example = lib.nixosSystem {
    modules = [
      self.modules.generic.default
      self.modules.nixos.default

      {
        system.stateVersion = "26.05";
        nixpkgs.hostPlatform = "x86_64-linux";
        my.example-module.enable = true;
      }
    ];
  };
}
