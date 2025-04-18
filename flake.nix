{
  description = "Bitcoin development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        isLinux = pkgs.stdenv.isLinux;
        binDirs = [ "./build/bin" "./build/bin/qt" ];

        # Common dependencies for both platforms
        commonNativeBuildInputs = with pkgs; [
          byacc
          ccache
          clang-tools_19
          clang_19
          cmake
          mold-wrapped
          ninja
          pkg-config
          python311
        ];

        # Linux-specific dependencies
        linuxNativeBuildInputs = with pkgs; [
          libsystemtap
          linuxPackages.bcc
          linuxPackages.bpftrace
        ];

        # Combine dependencies based on platform
        nativeBuildInputs = commonNativeBuildInputs ++ (if isLinux then linuxNativeBuildInputs else []);

        # Common runtime dependencies
        buildInputs = with pkgs; [
          boost
          capnproto
          db4
          gdb
          hexdump
          libevent
          qrencode
          qt6.qtbase
          qt6.qttools
          sqlite
          uv
          zeromq
        ];

        # Platform-specific shell hook
        shellHook = ''
          # Set up python venv and deps
          uv venv --python 3.11 $PWD/.venv
          source $PWD/.venv/bin/activate
          uv pip install codespell==2.2.6 flake8==6.1.0 lief==0.13.2 mypy==1.4.1 mypy-extensions==1.0.0 pycodestyle==2.11.1 pyflakes==3.1.0 pyzmq==25.1.0 typing-extensions==4.13.2 vulture==2.14

          # Use clang as default
          export CC=clang
          export CXX=clang++

          # Use Ninja generator 🥷
          export CMAKE_GENERATOR="Ninja"

          # Use mold linker 🦠
          export LDFLAGS="-fuse-ld=mold"

          # Add build dirs to PATH
          export PATH=$PATH:${builtins.concatStringsSep ":" binDirs}

          ${if isLinux then ''
            # Linux-specific settings
            BCC_EGG=${pkgs.linuxPackages.bcc}/${pkgs.python3.sitePackages}/bcc-${pkgs.linuxPackages.bcc.version}-py3.${pkgs.python3.sourceVersion.minor}.egg
            if [ -f $BCC_EGG ]; then
              export PYTHONPATH="$PYTHONPATH:$BCC_EGG"
            else
              echo "Warning: The bcc egg $BCC_EGG does not exist. Skipping bcc PYTHONPATH setup."
            fi
          '' else ''
          ''}
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs shellHook;
        };
      }
    );
}
