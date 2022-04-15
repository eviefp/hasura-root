# Configure your own Haskell nix shell!
let
  # Do not touch this part.
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  # This is supposed to be my dotfiles repository.
  common = import ../dotfiles/dev-shell/haskell;

  # TODO: Test dev.sh and add deps as needed.
  # You can remove anything from here if you'd rather manage it.
  consoleDeps =
    [
      pkgs.nodejs-12_x
      pkgs.google-cloud-sdk
    ];

  serverDeps =
    [
      pkgs.zlib.dev
      pkgs.postgresql
      pkgs.libkrb5
      pkgs.openssl
      pkgs.freetds
      pkgs.unixODBC
      pkgs.unixODBCDrivers.msodbcsql17
      pkgs.pcre.dev
      pkgs.zstd.dev
      pkgs.libmysqlclient
      pkgs.docker-compose
    ];

  testDeps =
    [
      pkgs.python39Full
      pkgs.libffi
    ];

  projectDeps = consoleDeps ++ serverDeps ++ testDeps;
in
pkgs.mkShell {
  buildInputs = projectDeps ++ common.buildInputs;

  # This is required for the database scripts to work.
  # Remove if not wanted.
  inherit
    (import ./exports.nix)
    PGHOST PGPORT PGDATABASE PGUSER PGPASSWORD DATABASE_URL;
  LD_LIBRARY_PATH="${pkgs.unixODBC}/lib:${pkgs.zlib}/lib:${pkgs.pcre.out}/lib:${pkgs.zstd.out}/lib:${pkgs.openssl}/lib;";
}
