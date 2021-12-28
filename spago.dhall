{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "blazing-tabs"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
  , "dom-indexed"
  , "effect"
  , "foldable-traversable"
  , "halogen"
  , "halogen-subscriptions"
  , "lists"
  , "maybe"
  , "newtype"
  , "prelude"
  , "psci-support"
  , "spec"
  , "strings"
  , "tuples"
  , "unfoldable"
  , "web-events"
  , "web-html"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
