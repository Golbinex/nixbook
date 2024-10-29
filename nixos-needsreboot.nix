#with import {
#  lib,
#  fetchFromGitHub,
#  rustPlatform,
#}:
with import <nixpkgs> {}; # bring all of Nixpkgs into scope

rustPlatform.buildRustPackage rec {
  pname = "nixos-needsreboot";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "thefossguy";
    repo = "nixos-needsreboot";
    rev = "8a3f64cc3c246cc6311485ad96ee9db0989c1377";
    hash = "sha256-zOMZDSAd3w1Dd5Jcs3nYae7aNomb3qfMJmCQl2ucZok=";
  };

  cargoHash = "sha256-LzO1kkrpWTjLnqs0HH5AIFLOZxtg0kUDIqXCVKSqsAc=";

  meta = {
    description = "Checks if you should reboot your NixOS machine in case an upgrade brought in some new goodies. :)";
    homepage = "https://https://github.com/thefossguy/nixos-needsreboot";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ baksa ];
  };
}
