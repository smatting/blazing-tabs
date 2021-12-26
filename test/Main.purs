module Test.Main where

import Prelude
import Data.Maybe
import Effect (Effect)
import Effect.Class.Console (log)
import Effect (Effect)
import Effect.Aff (launchAff_, delay)
import Test.Spec (pending, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import Data.String.Pattern (Pattern(..))

import Main (mergeRange, findRanges, joinRanges, Range(..))

main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
  describe "findRanges" do
    it "finds pattern that is a strict substring" $
      findRanges (Pattern "tab") "Stabber" `shouldEqual` [Range 1 4]
    it "finds pattern that equal the string" $
      findRanges (Pattern "tab") "tab" `shouldEqual` [Range 0 3]
    it "finds pattern that equal the string with prefix" $
      findRanges (Pattern "tab") "astab" `shouldEqual` [Range 2 5]
    it "finds pattern that equal the string with suffix" $
      findRanges (Pattern "tab") "tabxx" `shouldEqual` [Range 0 3]
    it "finds only non-verlapping patterns" $
      findRanges (Pattern "aba") "ababa" `shouldEqual` [Range 0 3]
    it "finds multiple occurences" $
      findRanges (Pattern "aba") "abababa" `shouldEqual` [Range 0 3, Range 4 7]
    it "returns empty result for an empty pattern" $
      findRanges (Pattern "") "Stabber" `shouldEqual` []

  describe "mergeRange" do
    it "merges ranges that meet" $
      mergeRange (Range 1 4) (Range 4 7) `shouldEqual` Just (Range 1 7)
    it "returns the same for arguments flipped" $
      mergeRange (Range 4 7) (Range 1 4)  `shouldEqual` Just (Range 1 7)
    it "merges ranges that overlap" $
      mergeRange (Range 1 4) (Range 3 5) `shouldEqual` Just (Range 1 5)
    it "merges ranges that are contained in each other" $
      mergeRange (Range 1 6) (Range 2 3) `shouldEqual` Just (Range 1 6)
    it "detects disjoints" $
      mergeRange (Range 6 7) (Range 1 5) `shouldEqual` Nothing

  describe "joinRanges" do
    it "joins 3 overlapping ranges" $
      joinRanges [Range 1 3, Range 2 4, Range 4 8] `shouldEqual` [Range 1 8]
    it "joins some ranges" $
      joinRanges [Range 1 3, Range 3 4, Range 5 6] `shouldEqual` [Range 1 4, Range 5 6]
    it "joins some ranges irrespective of order" $
      joinRanges [Range 1 3, Range 5 6, Range 3 4] `shouldEqual` [Range 1 4, Range 5 6]
