{
  lib,
  not-denix,
  ...
}:
not-denix.module {
  # The name of the module, used for finding enable options.
  name = "example-module";

  # You can use flake-part attributes here!
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.example = pkgs.hello;
    };

  # Define your modules options here, remember it does NOT automaticaly prefix them with genericConfigName!
  generic.always = {
    options.my.example-module = {
      enable = lib.mkEnableOption "example-module";
    };
  };

  # Declare options for specific classes that only exist when options.my.example-module is true.
  nixos.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [
        pkgs.hello
      ];
    };
}
