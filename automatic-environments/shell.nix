{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs.buildPackages; [
    colima
    kubectl
  ];
  shellHook = ''
    alias docker='colima nerdctl'
  '';
}
