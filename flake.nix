{
  inputs = {
    dataframe.url = "github:jisantuc/dataframe/nix/js/update-flake";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      dataframe,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem =
        {
          self',
          config,
          pkgs,
          system,
          ...
        }:
        {

          # Typically, you just want a single project named "default". But
          # multiple projects are also possible, each using different GHC version.
          haskellProjects.default = {
            # The base package set representing a specific GHC version.
            # By default, this is pkgs.haskellPackages.
            # You may also create your own. See https://haskell.nixos.asia/package-set
            # TODO: set this up per compiler
            basePackages = pkgs.haskell.packages.ghc910.extend (
              self: super: {
                dataframe-core = dataframe.packages.${system}.dataframe-core;
                dataframe-operations = dataframe.packages.${system}.dataframe-operations;
              }
            );

            # Extra package information. See https://haskell.nixos.asia/dependency
            #
            # Note that local packages are automatically included in `packages`
            # (defined by `defaults.packages` option).
            #
            packages = {
              # hvega = "0.12.0.7";
            };

            settings = {
              #  aeson = {
              #    check = false;
              #  };
              #  relude = {
              #    haddock = false;
              #    broken = false;
              #  };
            };

            devShell = {
              # Enabled by default
              # enable = true;

              # Programs you want to make available in the shell.
              # Default programs can be disabled by setting to 'null'
              tools = hp: {
                cabal-fmt = hp.cabal-fmt;
                cabal-gild = hp.cabal-gild;
                shellcheck = pkgs.shellcheck;
                nixfmt = pkgs.nixfmt;
              };

              # Check that haskell-language-server works
              # hlsCheck.enable = true; # Requires sandbox to be disabled
            };
          };

          # haskell-flake doesn't set the default package, but you can do it here.
          packages.default = self'.packages.dataframe-plot;
        };
    };
}
