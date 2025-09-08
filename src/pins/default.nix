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

  flatten =
    {
      workspaceUuid,
      containerId ? null,
      parentUuid ? null,
    }@context:

    acc: pin:
    let
      uuid = generatePinUUID workspaceUuid acc.count;

      processChild = flatten (context // { parentUuid = uuid; });

      wrapped =
        if (pin ? url && pin.url != null) then
          pin
          // {
            isGroup = false;
            editedTitle = true;
            isFolderCollapsed = null;
            folderIcon = null;
            container = containerId;
          }
        else
          pin
          // {
            url = null;
            isEssential = false;
            isGroup = true;
            editedTitle = true;
            isFolderCollapsed = true;
            folderIcon = pin.icon or null;
            container = null;
            items = pin.items or [ ];
          };

      initialState = {
        pins = acc.pins ++ [
          (
            wrapped
            // {
              inherit workspaceUuid parentUuid uuid;
              position = acc.count;
            }
          )
        ];
        count = acc.count + 1;
      };

      children = wrapped.items or [ ];
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
    map (attrs: removeAttrs attrs [ "items" ]) result.pins;
in
{
  inherit mkPins;
  types = import ./types.nix { inherit lib; };
}
