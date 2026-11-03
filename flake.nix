{
  description = "GigaMate — Gigabyte laptop management for Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      gigamate = pkgs.callPackage ./package.nix { };
    in
    {
      packages.${system} = {
        inherit gigamate;
        default = gigamate;
      };

      apps.${system} = {
        default = {
          type = "app";
          program = "${gigamate}/bin/gigamate";
          meta.description = "GigaMate laptop management CLI";
        };
        gigamate = {
          type = "app";
          program = "${gigamate}/bin/gigamate";
          meta.description = "GigaMate laptop management CLI";
        };
      };

      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.hardware.gigamate;
        in
        {
          options.hardware.gigamate = {
            enable = lib.mkEnableOption "GigaMate laptop management utility and udev rules";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default or (pkgs.callPackage ./package.nix { });
              defaultText = lib.literalExpression "pkgs.gigamate";
              description = "The GigaMate package to install.";
            };

            enableAcpi = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to build and load the GigaMate ACPI WMI kernel module.";
            };
          };

          config = lib.mkMerge [
            (lib.mkIf cfg.enable {
              environment.systemPackages = [ cfg.package ];
              services.udev.packages = [ cfg.package ];
            })
            (lib.mkIf cfg.enableAcpi {
              boot.extraModulePackages = [
                (config.boot.kernelPackages.callPackage ./gigamate-acpi.nix { })
              ];
              boot.kernelModules = [ "gigamate_acpi" ];
            })
          ];
        };
    };
}
