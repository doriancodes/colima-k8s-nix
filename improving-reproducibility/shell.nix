let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in
with pkgs;

pkgs.mkShell {
  buildInputs = with pkgs.buildPackages; [
    colima
    kubectl
  ];
  shellHook = ''
    alias docker='colima nerdctl'
  '';
}
