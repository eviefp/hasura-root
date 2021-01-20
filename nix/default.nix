# This uses `niv` https://github.com/nmattia/niv to manage git
# dependencies/updates.

# The niv sources include `nix-tooling` which is a thin wrapper around
# `nixpkgs` to allow simplified creation of language-specific shells.
let
  sources = import ./sources.nix;
  tooling = import sources.nix-tooling;
in
  tooling
