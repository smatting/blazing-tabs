{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name =
    "my-project"
, dependencies =
    [ "maybe", "prelude", "effect", "psci-support", "halogen" ]
, packages =
    ./packages.dhall
, sources =
    -- [ "src/**/*.purs", "test/**/*.purs" ]
    [ "ui/**/*.purs" ]
}
