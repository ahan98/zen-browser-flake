let
  pkgs = import <nixpkgs> { };
  pins = import ./default.nix { inherit (pkgs) lib; };
  inherit (pins) mkPins;
  inherit (pkgs) lib;

  example =
    let
      workspaceUuid = "65f1509d-fe24-45f2-90b7-2129b3ee52f2";
      containerId = 1;

      pins = [
        {
          title = "GitHub";
          url = "https://github.com";
          isEssential = true;
        }
        {
          title = "Work";
          icon = "💼";
          collapsed = false;
          items = [
            {
              title = "Jira";
              url = "https://company.atlassian.net";
            }
            {
              title = "Confluence";
              url = "https://company.confluence.com";
            }
            {
              title = "Projects";
              items = [
                {
                  title = "Project A";
                  url = "https://github.com/company/project-a";
                }
              ];
            }
          ];
        }
        {
          title = "Mail";
          url = "https://mail.google.com";
          isEssential = true;
        }
      ];
    in
    mkPins {
      inherit workspaceUuid containerId pins;
    };

  result = pins.mkPins {
    workspaceUuid = "test-workspace";
    pins = [
      {
        title = "Test";
        items = [
          {
            title = "GitHub";
            url = "https://github.com";
          }
        ];
      }
    ];
  };

in
lib.debug.traceSeqN 2 (map (p: { inherit (p) uuid position title; }) result) result
