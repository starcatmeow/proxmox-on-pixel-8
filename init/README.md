# Compile init

1. Use nix-shell to get the compile environment; Or manually install rustup, and run `rustup target add aarch64-unknown-linux-musl`, then install `gcc-12-aarch64-linux-gnu` and change the linker in `.cargo/config.toml` to `aarch64-linux-gnu-ld`.
2. Run `01-unpack.sh` to unpack the original vendor_boot.img.
3. Run `02-compile-and-pack.sh` to compile the init, then pack into ../out/vendor_boot.img.
