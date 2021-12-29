<h1>
<img src="https://github.com/smatting/blazing-tabs/raw/main/src/logo.svg">
Blazing Tabs - blazing fast tab search
</h1>

Blazing Tabs is available as a:

- [Firefox extension](https://todo)
- [Google chrome add-on](https://todo)

![demo video](https://github.com/smatting/blazing-tabs/raw/main/assets/workflow-demo.gif)

Features:

- Incremental multi-keyword search. Both the tab's title and domain of url are searched.
- Allows for keyboard-only workflow:
    1. Ctrl+E to open the search
    2. Type to search and use arrow keys to select tab
    3. Hit ENTER to switch to tab, or Ctrl+Left to close the tab
    
Blazing Tabs is especially useful if you've got so many tabs open that you can't barely read their titles anymore.

## How to build

Prerequisites: Install [nix](https://nixos.org/). The `shell.nix` pins all the build tools needed to build.

1. Start a nix-shell `nix-shell`. In this shell [spago](https://github.com/purescript/spago) etc are available that can build the app.
2. Run `./scripts/make.sh` to compile to `src/index.js`
3. Run `./scripts/package.sh` to create a browser extension zip file in `dist/`.

## How to develop

1. Start a nix-shell `nix-shell`
2. `./scripts/dev.sh`
3. (Re)load the browser extension `src/`. Alternatively open `debug-ui/index.html` to test the app with dummy tabs.

