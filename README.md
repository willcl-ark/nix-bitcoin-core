# nix-bitcoin-core

A Nix flake for Bitcoin Core development. Helps install necessary and optional dependencies.

## Installation

One way is to have the **nix-bitcoin-core/** directory alongside your **bitcoin/** directory, then symlink the flake.nix across. (Here it's done from **bitcoin/** assuming a common parent directory).

```console
ln -s ../nix-bitcoin-core/flake.nix .
```

An even more seamless experience can be attained by using [`direnv`](https://direnv.net/) (or if on NixOS [`nix-direnv`](https://github.com/nix-community/nix-direnv)).
With this you can clone this repo wherever you like, and simply reference the flake in your `.envrc` file, which can be located in your Bitcoin Core source directory or a parent.

e.g.:

```bash
# Clone this flake
git clone https://github.com/0xb10c/nix-bitcoin-core ~/nix-bitcoin-core

# Ignore .envrc files in the bitcoin repo
echo ".envrc" >> /path/to/bitcoin/source .git/info/exclude

# Add the flake directive to .envrc config file
echo "use flake $HOME/nix-bitcoin-core" > /path/to/bitcoin/source/.envrc

# "Allow" the direnv configuration
cd /path/to/bitcoin/source
direnv allow
```

If using `direnv` to manage the environment like this, the devShell will be automatically activated (and deactivated) when you enter/leave the bitcoin core source directory.

## Usage

Get your terminal into the **bitcoin/** directory and do some variant of this:
```console
nix develop
```

### Supported arguments

| Name         | Description                                   | Valid values  |
|--------------|-----------------------------------------------|---------------|
| `bdbVersion` | Which version of Berkeley DB to use, if any.<br/>Use `--argstr` instead of `--arg` with this one. | `""` = off<br/>`"db48"` = Compatible v4.8<br/>`"db5"` = Incompatible v5.x |
| `spareCores` | How many cores to exclude when running `make` | `<integer>` = less than the number of logical cores |
| `withClang`  | Whether to switch from GCC to Clang for compilation | `<boolean>` |
| `withDebug`  | Whether to pass `--enable-debug` to `./configure` | `<boolean>` |
| `withGui`    | Whether to enable bitcoin-qt                  | `<boolean>` |
