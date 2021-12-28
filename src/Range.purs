module Range where

import Prelude
import Data.Array as Array
import Data.List ((:))
import Data.List as List
import Data.List.Types (List(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.CodePoints (contains, indexOf, indexOf', length, splitAt, take) as String
import Data.String.Common (toLower, split) as String
import Data.String.Pattern (Pattern) as String
import Data.Newtype (unwrap)
import Data.Unfoldable (unfoldr)
import Data.Tuple (Tuple(..))

-- range in a string, indexes are 0-based
-- second index is exlcusive
data Range = Range Int Int

derive instance eqRange :: Eq Range

instance rangeShow :: Show Range
  where
    show (Range a b) = "Range " <> show a <> " " <> show b

findRanges :: String.Pattern -> String -> Array Range
findRanges pat s =
  let k = String.length (unwrap pat)
  in
   if k == 0
      then []
      else
        unfoldr
            (\pos ->
                case String.indexOf' pat pos s of
                  Nothing -> Nothing
                  Just i -> Just (Tuple (Range i (i + k)) (i + k))
            ) 0

mergeRange :: Range -> Range -> Maybe Range
mergeRange range1@(Range l1 r1) range2@(Range l2 r2)
  | l1 > l2 = mergeRange range2 range1
  | l2 <= r1 = Just (Range l1 (max r1 r2))
  | otherwise = Nothing

joinSortedRanges :: List Range -> List Range
joinSortedRanges Nil = Nil
joinSortedRanges (Cons r1 rs) =
  case rs of
    Nil -> r1 : Nil
    r2 : rest ->
      case mergeRange r1 r2 of
        Nothing -> r1 : joinSortedRanges (r2 : rest)
        Just rMerged -> joinSortedRanges (rMerged : rest)

joinRanges :: Array Range -> Array Range
joinRanges =
  Array.sortWith f >>> List.fromFoldable >>> joinSortedRanges >>> Array.fromFoldable
  where
    f :: Range -> Int
    f (Range l r) = l
