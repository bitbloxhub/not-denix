{
  inputs,
  ...
}:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem.treefmt =
    {
      pkgs,
      ...
    }:
    {
      projectRootFile = "flake.lock";
      programs.nixfmt = {
        enable = true;
        package = pkgs.nixfmt;
      };
      programs.deadnix.enable = true;
      programs.statix.enable = true;
    };
}
