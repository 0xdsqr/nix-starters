{
  description = "🟪 Go 1.24 Project with Nix";
  
  # Define the sources we'll use in our flake
  inputs = {
    # Unstable channel for latest package versions
    # This provides access to the newest available Go and tools
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Stable channel for production-ready packages
    # Useful for dependencies that require more stability
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-24.11";
    
    # Provides utility functions for working with flakes
    # Simplifies handling multiple systems (x86_64-linux, aarch64-darwin, etc.)
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs-unstable, nixpkgs-stable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import both package sets for the current system
        pkgs-unstable = import nixpkgs-unstable { inherit system; };
        pkgs-stable = import nixpkgs-stable { inherit system; };

        # Define the applicaiotn name
        appName = "dsqr";
      in {
        # Default development shell with necessary tools
        devShells.default = pkgs-unstable.mkShell {
          buildInputs = with pkgs-unstable; [
            # Core Go development tools
            go_1_24        # Go compiler and runtime (version 1.24)
            gopls          # Official Go language server protocol implementation
            gotools        # Essential Go development utilities
            golangci-lint  # Meta-linter combining 50+ linters in one tool
            delve          # Powerful debugger for Go applications
            git            # Distributed version control system
          ];
          
          # Executed when entering the development shell
          shellHook = ''
            # Set up project-local configuration
            export GOPATH="$PWD/.go"              # Project-local GOPATH
            export PATH="$GOPATH/bin:$PATH"       # Make go install binaries available
            export GO111MODULE=on                 # Ensure modules mode is enabled
            
            # Create directories if needed
            mkdir -p .go/bin
            
            echo "🟪 Go 1.24 development environment activated!"
          '';
        };
        
        packages.default = pkgs-unstable.stdenv.mkDerivation {
          name = ${appName};
          src = ./.;

          nativeBuildInputs = with pkgs-unstable; [
            go
          ];

          buildPhase = ''
            export GOCACHE=$TMPDIR/go-cache
            export GOPATH=$TMPDIR/go
            
            go build -o ${appName}
          '';
        };
        
        # Define a formatter for the flake itself
        # This helps maintain consistent formatting with 'nix fmt'
        # Run with: nix fmt
        formatter = pkgs-unstable.nixpkgs-fmt;
      }
    );
}
