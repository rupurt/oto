{
  description = "Nix flake for oto. Bulk SQL extraction over ODBC.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    odbc-drivers.url = "github:rupurt/odbc-drivers-nix";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    odbc-drivers,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          odbc-drivers.overlay
          self.overlays
        ];
      };
    in rec {
      # packages exported by the flake
      packages = {
        db2-odbc-driver = pkgs.db2-odbc-driver {};
        postgres-odbc-driver = pkgs.postgres-odbc-driver {};
        oto = pkgs.oto {};
        default = packages.oto {};
      };

      # nix run
      apps = {};

      # nix fmt
      formatter = pkgs.alejandra;

      # nix develop -c $SHELL
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.python310
          pkgs.python310Packages.pip
          pkgs.python310Packages.virtualenv
          pkgs.python310Packages.ipython
        ];
        packages = [
          packages.db2-odbc-driver
          packages.postgres-odbc-driver
          pkgs.bats
          pkgs.kafkactl
          pkgs.k9s
          pkgs.k3d
          pkgs.krew
          pkgs.kubectl
          pkgs.kubectx
          pkgs.kubetail
          pkgs.kcat
          pkgs.kubernetes-helm
          pkgs.modd
        ];
        shellHook = ''
          # k8s
          export PATH="$HOME/.krew/bin:$PATH"
          export KUBECONFIG="$PWD/.local/kubeconfig"

          # python
          [ ! -d ".venv" ] && python -m venv .venv
          source .venv/bin/activate
          [ ! -x "$(command -v pdm)" ] && pip install -r requirements.txt
        '';
      };
    });
  in
    outputs
    // {
      # Overlay that can be imported so you can access the packages
      # using oto.overlays
      overlays = final: prev: {
        oto = prev.pkgs.callPackage ./oto.nix {};
      };
    };
}
