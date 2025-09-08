# title
# url
# isEssential
# isGroup
# editedTitle
# isFolderCollapsed
# folderIcon
# parentUuid
# ##############
# uuid
# position
# workspace
# container
# ##############
# id
# created_at
# updated_at

{ lib }:

let
  generateUUID =
    seed:
    let
      hash = builtins.hashString "sha256" seed;
      hex = builtins.substring 0 32 hash;
      formatted = builtins.concatStringsSep "-" [
        (builtins.substring 0 8 hex)
        (builtins.substring 8 4 hex)
        "4${builtins.substring 13 3 hex}" # Version 4
        "8${builtins.substring 16 3 hex}" # Variant
        (builtins.substring 20 12 hex)
      ];
    in
    formatted;

  generatePinUUID = workspaceUuid: position: generateUUID "${workspaceUuid}:${toString position}";

  # Helper to create a tab pin
  mkTab =
    {
      title,
      url,
      isEssential ? false,
    }@inputs:
    inputs
    // {
      isGroup = false;
      editedTitle = true; # In declarative approach, title is always edited
      isFolderCollapsed = null;
      folderIcon = null;
    };

  # Helper to create a folder pin
  mkFolder =
    {
      title,
      icon ? null,
      collapsed ? false,
      items ? [ ],
    }:
    {
      inherit title;
      url = null;
      isEssential = false;
      isGroup = true;
      editedTitle = true;
      isFolderCollapsed = collapsed;
      folderIcon = icon;
      parentUuid = null;
      _items = items; # Internal use for flattening
    };

  isTab = attrs: (attrs ? url) && attrs.url != null;

  flatten =
    {
      workspaceUuid,
      containerId ? null,
      parentUuid ? null,
    }@context:

    acc: pin:
    let
      count = acc.count + 1;
      uuid = generatePinUUID workspaceUuid count;

      processChild = flatten (context // { parentUuid = uuid; });

      wrapped = if isTab pin then (mkTab pin) // { container = containerId; } else mkFolder pin;

      initialState = {
        pins = acc.pins ++ [
          (
            wrapped
            // {
              inherit workspaceUuid parentUuid uuid;
              position = count;
            }
          )
        ];
        inherit count;
      };

      children = if (wrapped ? _items) then wrapped._items else [ ];
    in
    lib.foldl' processChild initialState children;

  mkPins =
    {
      pins,
      workspaceUuid,
      containerId ? null,
    }:
    let
      accumulator = flatten { inherit workspaceUuid containerId; };
      result = lib.foldl' accumulator {
        pins = [ ];
        count = 0;
      } pins;
    in
    map (attrs: removeAttrs attrs [ "_items" ]) result.pins;
in
{
  inherit mkPins;
  options = import ./types.nix { inherit lib; };
}
