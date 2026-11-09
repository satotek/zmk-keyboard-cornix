{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # This pins requirements.txt provided by zephyr-nix.pythonEnv.
    zephyr.url = "github:zephyrproject-rtos/zephyr/v3.7.0";

    zephyr.flake = false;

    # Zephyr sdk and toolchain.
    zephyr-nix.url = "github:urob/zephyr-nix";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";

    keymap_drawer-nix = {
      url = "github:hitsmaxft/keymap-drawer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, zephyr-nix, keymap_drawer-nix, ... }:
    let
      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {

      devShells = forAllSystems (system:
        let

          pkgs = nixpkgs.legacyPackages.${system};
          zephyr = zephyr-nix.packages.${system};
          zephyrPyEnv = zephyr-nix.packages.${system}.pythonEnv;
          keymap_drawer = keymap_drawer-nix.packages.${system}.default;
        in {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              gcovr
              gcc-arm-embedded
              zephyrPyEnv
              (zephyr.sdk-0_16.override { targets = [ "arm-zephyr-eabi" ]; })

              cmake
              dtc
              ninja

              just
              yq # Make sure yq resolves to python-yq.
              tio

              # poetry build error
              keymap_drawer
            ];
            #export env variables and print

            #never export ZEPHYR_BASE, it is set by west
            shellHook = ''
if west topdir >/dev/null 2>&1; then
  ZEPHYR_BASE=$(west config zephyr.base)
  Zephyr_DIR=$ZEPHYR_BASE/share/zephyr-package/cmake/
  export Zephyr_DIR
else
  echo "West workspace is not initialized. Run: just init"
fi
            '';
          };
        });
    };
}
