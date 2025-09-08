{ lib }:

let
  inherit (lib) mkOption;
  inherit (lib.types)
    bool
    listOf
    nullOr
    str
    submodule
    ;
in
{
  pins = mkOption {
    type = listOf (submodule {
      options = rec {
        title = mkOption { type = str; };
        url = mkOption {
          type = nullOr str;
          default = null;
        };
        isEssential = mkOption {
          type = bool;
          default = false;
        };
        icon = mkOption {
          type = nullOr str;
          default = null;
        };
        collapsed = mkOption {
          type = bool;
          default = false;
        };
        items = mkOption {
          type = listOf (submodule {
            options = {
              inherit
                title
                url
                isEssential
                icon
                collapsed
                items
                ;
            };
          });
          default = [ ];
        };
      };
    });
    default = [ ];
  };
}
