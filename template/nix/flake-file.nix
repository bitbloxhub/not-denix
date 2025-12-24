{
  inputs,
  ...
}:
{
  flake-file = {
    outputs =
      # nix
      ''
        inputs:
        inputs.flake-parts.lib.mkFlake {
          inherit inputs;
          specialArgs.not-denix = inputs.not-denix.lib.factory { };
        } ((inputs.import-tree.filterNot (inputs.nixpkgs.lib.hasSuffix "npins/default.nix")) ./nix)
      '';
    inputs = {
      flake-file.url = "github:vic/flake-file";
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      flint = {
        url = "github:NotAShelf/flint";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      not-denix = {
        url = "github:bitbloxhub/not-denix";
        inputs.flake-file.follows = "flake-file";
        inputs.flake-parts.follows = "flake-parts";
        inputs.import-tree.follows = "import-tree";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.flint.follows = "nixpkgs";
        inputs.treefmt-nix.follows = "treefmt-nix";
        inputs.make-shell.follows = "make-shell";
      };
    };
  };

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  imports = [
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.import-tree
  ];
}
