# TODO: This has a bunch of duplication with matrix-appservice-slack

{ pkgs, nodePackages, nodejs, stdenv, lib, ... }:

let

  packageName = with lib; concatStrings (map (entry: (concatStrings (mapAttrsToList (key: value: "${key}-${value}") entry))) (importJSON ./package.json));

  ourNodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
ourNodePackages."${packageName}".override (oldAttrs: {
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = oldAttrs.buildInputs ++ [ nodePackages.node-gyp-build ];

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/matrix-appservice-irc" \
    --add-flags "$out/lib/node_modules/matrix-appservice-irc/app.js"
  '';

  meta = with lib; {
    description = "A Matrix <--> IRC bridge";
    maintainers = with maintainers; [ puffnfresh ];
    license = licenses.asl20;
  };
})
