{
  description = "Elixir development environment";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05"; # Or a specific stable channel like "nixos-24.05"
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      with pkgs; {
        devShell = mkShell {
          buildInputs = [
            beam.packages.erlang.elixir_1_18
            elixir_ls
            glibcLocales # For locale support
          ]
          ++ lib.optional stdenv.isDarwin terminal-notifier # For macOS notifications
          ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
            CoreFoundation
            CoreServices
          ]);
        };
      });
}
