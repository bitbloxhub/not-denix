{
  flake.flakeModules.default =
    {
      lib,
      ...
    }:
    {
      options.not-denix = {
        genericConfigName = lib.mkOption {
          type = lib.types.str;
          default = "my";
          description = "The name of the root option the other options are prefixed with.";
        };
        defaultFlakeModule = lib.mkOption {
          type = lib.types.str;
          default = "default";
          description = ''
            The name of the module in `flake.modules` that the modules will go.
            e.g. a value of "my" will cause the nixos module to be in `flake.modules.nixos.my`.
          '';
        };
      };
    };
}
