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
      };
    };
}
