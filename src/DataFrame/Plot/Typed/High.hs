{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}

-- |
-- High level typed plotting API for @TypedDataFrame@s.
--
-- Functions exported by this module aren't conducive to additional
-- modification of the plot output. If you need a quick scatter/histogram/bar chart/etc. and aren't too concerned about
-- configuration, this module is the right module for you.
--
-- Use of this module requires a bundle of language extensions because of its reliance on @dataframe@'s typed API.
-- If you'd rather provide column names as strings and skip the language extensions, see @DataFrame.Plot.High@ instead.
module DataFrame.Plot.Typed.High (showScatter, textScatter) where

import Data.Text.Lazy (Text)
import DataFrame.Plot.Typed.Low (KnownNumericColumn)
import DataFrame.Plot.Typed.Mid (scatter)
import DataFrame.Typed.Types (TypedDataFrame)
import qualified Graphics.Vega.VegaLite as V

-- |
-- Create a scatter plot using columns x and y and display it.
showScatter ::
  forall x y schema xColumnType yColumnType.
  ( KnownNumericColumn x xColumnType schema,
    KnownNumericColumn y yColumnType schema
  ) =>
  TypedDataFrame schema -> IO ()
showScatter df = plotShow (scatter @x @xColumnType @y @yColumnType @schema df)

-- |
-- Create a scatter plot using columns x and y and convert it to `Text` of its HTML representation.
-- Use this function (and related functions like textBar, textHistogram, etc.)
-- in notebook settings to see plots inline.
textScatter ::
  forall x y schema xColumnType yColumnType.
  ( KnownNumericColumn x xColumnType schema,
    KnownNumericColumn y yColumnType schema
  ) =>
  TypedDataFrame schema -> Text
textScatter df = plotText (scatter @x @xColumnType @y @yColumnType @schema df)

plotShow :: V.VegaLite -> IO ()
plotShow = undefined

plotText :: V.VegaLite -> Text
plotText = V.toHtml
