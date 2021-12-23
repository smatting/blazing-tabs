# How to build

1. Use `nix run` to start a development shell that has the correct version of `elm` and `elm-live` in PATH.
2. Run `elm make src/Main.elm --output=src/elm.js` to update `src/elm.js`

# How to develop

1. Use `nix run` to start a development shell that has the correct version of `elm` and `elm-live` in PATH.
2. Run `elm-live src/Main.elm --dir=src -- --output=src/elm.js`
3. Load the extension into Firefox by navigating to `about:debugging` and  by selecting `src/manifest.json`
4. Click on the extension icon to open the main tab
5. Save changes to `src/Main.elm`. `elm-live` should automatically compile `src/elm.js`
6. Refresh the main tab to see the updated view.

# Develop notes
- https://github.com/purescript-halogen/purescript-halogen/blob/master/docs/guide/04-Lifecycles-Subscriptions.md
- https://blog.logrocket.com/custom-events-in-javascript-a-complete-guide/#how-to-create-a-custom-event-in-javascript
