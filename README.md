# Blazing Tabs

# How to build

1. Start a nix-shell `nix-shell`
2. Run `./scripts/make.sh` to compile `src/index.js`
2. Run `./scripts/package.sh` to create extension zip in `dist/`.

# How to develop

1. Start a nix-shell `nix-shell`
2. `./scripts/dev.sh`
3. (Re)load the browser extension `src/` or open `debug-ui/index.html` to run the app with dummy tabs
