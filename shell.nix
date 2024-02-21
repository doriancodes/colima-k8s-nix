{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  buildInputs = with pkgs.buildPackages; [
    colima
    kubectl
  ];
  shellHook = ''
    alias docker='colima nerdctl'
  '';
}
