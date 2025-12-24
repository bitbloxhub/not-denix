{
  lib,
  self,
  ...
}:
{
  flake.lib.internal.module =
    # Partially based on https://github.com/yunfachi/denix/blob/d90f816/lib/configurations/module.nix
    { genericConfigName, ... }:
    module: {
      flake.modules = builtins.listToAttrs (
        builtins.map
          (moduleSystem: {
            name = moduleSystem;
            value.default =
              {
                lib,
                config,
                ...
              }:
              let
                args = rec {
                  # instance of the user's config attrset
                  genericConfig = config.${genericConfigName};

                  cfgPath = self.lib.splitStrPath module.name;

                  fromPath =
                    with lib;
                    path: if (length path) > 0 then lib.attrByPath path { } genericConfig else genericConfig;

                  cfg = fromPath cfgPath;
                  parent = fromPath (lib.dropEnd 1 cfgPath);
                };

                inherit (args) cfg;

                # If the `cfg.enable` option is missing, do not import ifEnabled or ifDisabled.
                enabled = self.lib.getAttrByStrPath "enable" cfg false;
                # Not `disabled = !enabled`, because it behaves differently when the 'enable' option is missing.
                disabled = !(self.lib.getAttrByStrPath "enable" cfg true);

                ifEnabled = self.lib.getAttrByStrPath "${moduleSystem}.ifEnabled" module { };
                ifDisabled = self.lib.getAttrByStrPath "${moduleSystem}.ifDisabled" module { };
              in
              {
                imports = [
                  (self.lib.getAttrByStrPath "${moduleSystem}.always" module { })
                  (self.lib.conditionalImport ifEnabled enabled)
                  (self.lib.conditionalImport ifDisabled disabled)
                  (
                    if moduleSystem == "generic" then
                      {
                        options.${genericConfigName} = self.lib.getAttrByStrPath "options" module { };
                      }
                    else
                      { }
                  )
                ];
              };
          })
          (
            lib.lists.uniqueStrings (
              (builtins.attrNames (lib.filterAttrs (n: _v: builtins.elem n self.lib.moduleSystems) module))
              # Always evaluate the generic value for options.
              ++ [ "generic" ]
            )
          )
      );
    };
}
