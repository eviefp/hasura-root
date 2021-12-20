# Configure your own Haskell nix shell!
let
  # Do not touch this part.
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};

  # TODO: Test dev.sh and add deps as needed.
  # You can remove anything from here if you'd rather manage it.
  consoleDeps =
    [ pkgs.nodejs
      pkgs.google-cloud-sdk
    ];

  serverDeps =
    [ pkgs.zlib
      pkgs.postgresql
      pkgs.libkrb5
      pkgs.openssl
      pkgs.freetds
      pkgs.unixODBC
      pkgs.unixODBCDrivers.msodbcsql17
      pkgs.pcre
      pkgs.pcre.dev
      pkgs.zstd
      pkgs.zstd.dev
      pkgs.libmysqlclient
    ];

  testDeps =
    [ pkgs.python3
    ];

  projectDeps = consoleDeps ++ serverDeps ++ testDeps;

  # Common tooling used by the whole team/CI. Remove if you'd rather
  # use the system-wide version you might already have.
  commonTooling =
    [ pkgs.haskell.compiler.ghc8107 # GHC version as defined above at 'self'
      pkgs.haskell.packages.ghc8107.cabal-install
    ];

  # Personal tooling: change/update as needed, e.g. `inputs.ghcide`.
  personalTooling =
    [ pkgs.haskell.packages.ghc8107.haskell-language-server
      pkgs.haskell.packages.ghc8107.cabal2nix
      pkgs.haskell.packages.ghc8107.implicit-hie
    ];
in
  pkgs.mkShell {
    buildInputs = projectDeps ++ commonTooling ++ personalTooling;

    # This is required for the database scripts to work.
    # Remove if not wanted.
    inherit
      (import ./exports.nix)
      PGHOST PGPORT PGDATABASE PGUSER PGPASSWORD DATABASE_URL;
    LD_LIBRARY_PATH="${pkgs.unixODBC}/lib:${pkgs.zlib}/lib:${pkgs.pcre.out}/lib:${pkgs.zstd.out}/lib";
  }
