{
  description = "A basic package";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
        "riscv64-linux"
      ];
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      inherit (nixpkgs) lib;
    in
    {
      overlays.default = final: prev: {
        veraison-services = final.callPackage ./src/veraison-services.nix { };
        veraison = final.callPackage ./src/veraison.nix { };
        pocli = final.callPackage ./src/pocli.nix { };
        cocli = final.callPackage ./src/cocli.nix { };
        evcli = final.callPackage ./src/evcli.nix { };
        mockgen_1_6 = final.callPackage ./src/oldmockgen.nix { };
      };

      nixosModules = {
        cocli =
          {
            pkgs,
            lib,
            config,
            ...
          }:
          let
            cfg = config.services.veraison.cocli;
          in
          {
            options.services.veraison = {
              enable = lib.mkEnableOption "cocli service";
              package = lib.mkPackageOption "veraison-services" { };
              provisioning-port = lib.mkOption { type = "int"; };
              keycloak-port = lib.mkOption { type = "int"; };
            };
            config = lib.mkIf cfg.enable (
              lib.mkMerge [
                {
                  systemd.services.veraison-vst =
                    let
                      config-nix = {
                        logging = {
                          level = "info";
                          output-paths = [ "stdout" ];
                        };
                      };
                      config-file = pkgs.runCommand "config.yaml" { } ''
                        ${lib.getExe pkgs.json2yaml} < ${config-nix} > $out
                      '';
                    in
                    {
                      description = "Veraison Trusted Services server";
                      wantedBy = [ "multi-user.target" ];
                      after = [ "network.target" ];
                      serviceConfig = {
                        ExecStart = "${cfg.package}/bin/vts-service --config ${config-file}";
                      };
                    };
                }
              ]
            );
          };
      };

      nixosConfigurations.default = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ];
      };

      legacyPackages = eachSystem pkgsFor;

      packages = eachSystem (
        system:
        let
          pkgs = (pkgsFor system);
        in
        {
          default = pkgs.veraison-services;
          inherit (pkgs)
            pocli
            cocli
            evcli
            veraison-services
            ;
          all = pkgs.linkFarm "veraison-all" [
            {
              name = "pocli";
              path = pkgs.pocli;
            }
            {
              name = "cocli";
              path = pkgs.cocli;
            }
            {
              name = "evcli";
              path = pkgs.evcli;
            }
          ];
        }
      );
      formatter = eachSystem (
        system:
        (treefmt-nix.lib.evalModule (pkgsFor system) {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        }).config.build.wrapper
      );
    };
}
