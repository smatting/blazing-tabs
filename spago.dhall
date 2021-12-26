{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
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
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "ui/**/*.purs", "test/**/*.purs" ]
}
