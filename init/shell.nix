let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  rust-overlay = builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
  pkgs = import nixpkgs { config = {}; overlays = [(import rust-overlay)]; };
  cross = import nixpkgs {
    crossSystem = { config = "aarch64-unknown-linux-gnu"; };
  };
  toolchain = pkgs.rust-bin.fromRustupToolchainFile ./toolchain.toml;
in

pkgs.mkShell {
  buildInputs = [
    cross.buildPackages.gcc
  ];
  packages = with pkgs; [
    android-tools
    toolchain
  ];
}