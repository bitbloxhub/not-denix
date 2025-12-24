{
  self,
  ...
}:
{
  # Factory function for the library, based on https://github.com/yunfachi/denix/blob/d90f816/lib/configurations/default.nix#L10
  flake.lib.factory =
    {
      genericConfigName ? "my",
    }:
    {
      module = self.lib.internal.module {
        inherit genericConfigName;
      };
    };
}
