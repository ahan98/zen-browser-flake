{ lib }:

let
  inherit (lib) mkOption;
  inherit (lib.types)
    bool
    either
    listOf
    nullOr
    str
    submodule
    ;
in
rec {
  # Recursive types for pins
  pinnedTab = submodule {
    options = {
      title = mkOption {
        type = str;
        description = "Title of the pinned tab.";
      };
      url = mkOption {
        type = str;
        description = "URL of the pinned tab.";
      };
      isEssential = mkOption {
        type = bool;
        default = false;
        description = "Whether this is an essential tab.";
      };
    };
  };

  pinnedFolder = submodule {
    options = {
      title = mkOption {
        type = str;
        description = "Title of the folder.";
      };
      icon = mkOption {
        type = nullOr str;
        default = null;
        description = "Icon for the folder.";
      };
      collapsed = mkOption {
        type = bool;
        default = false;
        description = "Whether the folder is collapsed.";
      };
      items = mkOption {
        type = listOf (either pinnedFolder pinnedTab);
        default = [ ];
        description = "Child items in this folder.";
      };
    };
  };

  pins = mkOption {
    type = listOf (either pinnedFolder pinnedTab);
    default = [ ];
    description = "Pinned workspace tabs and/or folders.";
  };
}
