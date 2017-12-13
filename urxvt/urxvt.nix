{ pkgs }:
let
  urxvt-config = import ./config.nix {};
  urxvt-config-file = pkgs.writeTextFile {
    name = "urxvt.conf";
    text = urxvt-config;
  };
in
  pkgs.writeScript
    "sean-urxvt"
    ''${pkgs.coreutils}/bin/env XENVIRONMENT=${urxvt-config-file} ${pkgs.rxvt_unicode-with-plugins}/bin/urxvt $@''

