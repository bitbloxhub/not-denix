{
  lib,
  self,
  ...
}:
{
  flake.lib.module = module: {
    imports = [
      # Partially based on https://github.com/yunfachi/denix/blob/d90f816/lib/configurations/module.nix
      (
        {
          config,
          ...
        }:
        let
          flakeConfig = config.not-denix;
        in
        {
          flake.modules = builtins.listToAttrs (
            builtins.map
              (moduleSystem: {
                name = moduleSystem;
                value.${flakeConfig.defaultFlakeModule} =
                  {
                    lib,
                    config,
                    ...
                  }:
                  let
                    args = rec {
                      # instance of the user's config attrset
                      genericConfig = config.${flakeConfig.genericConfigName};

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

                    options = self.lib.wrap (self.lib.getAttrByStrPath "options" module { });
                  in
                  {
                    imports = [
                      (self.lib.getAttrByStrPath "${moduleSystem}.always" module { })
                      (self.lib.conditionalImport ifEnabled enabled)
                      (self.lib.conditionalImport ifDisabled disabled)
                      (
                        if moduleSystem == "generic" then
                          lib.setFunctionArgs (args: {
                            options.${flakeConfig.genericConfigName} = options args;
                          }) (lib.functionArgs options)
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
        }
        // (lib.filterAttrs (n: _v: !(builtins.elem n self.lib.notDenixAttrs)) module)
      )
    ];
  };
}
