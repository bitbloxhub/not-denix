{
  lib,
  self,
  ...
}:
{
  flake.lib = rec {
    moduleSystems = [
      "generic"
      "nixos"
      "darwin"
      "systemManager"
      "homeManager"
    ];

    notDenixAttrs = moduleSystems ++ [
      "name"
      "options"
    ];

    # From https://github.com/yunfachi/denix/blob/d90f816/lib/attrset.nix#L4
    splitStrPath = lib.splitString ".";

    getAttrByStrPath =
      strPath: attrset: default:
      lib.attrByPath (splitStrPath strPath) default attrset;

    setAttrByStrPath = strPath: value: lib.setAttrByPath (splitStrPath strPath) value;

    hasAttrs =
      attrs: attrset:
      if attrs != [ ] then builtins.any (attr: builtins.hasAttr attr attrset) attrs else true;

    # Temporary until https://github.com/NixOS/nixpkgs/pull/399527 is merged
    conditionalImport =
      module_: cond:
      let
        module = wrap module_;
      in
      lib.setFunctionArgs (
        args:
        let
          applied_ = module args;
          applied =
            if (self.lib.hasAttrs [ "config" "options" ] applied_) then
              applied_
            else
              {
                imports = self.lib.getAttrByStrPath "imports" applied_ [ ];
                config = builtins.removeAttrs applied_ [ "imports" ];
              };
        in
        {
          imports = self.lib.getAttrByStrPath "imports" applied [ ];
          options = self.lib.getAttrByStrPath "options" applied { };
          config = lib.mkIf cond applied.config;
        }
      ) (lib.functionArgs module);

    wrap = arg: if builtins.typeOf arg == "lambda" then arg else (_: arg);
  };
}
