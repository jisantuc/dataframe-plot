{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module DataFrame.Plot.Typed.Mid.Text
  ( defaultScatterTitle,
  )
where

import qualified Data.Text as Text
import DataFrame.Plot.Typed.Low (Scatter, colName, title)
import DataFrame.Typed.Types (TypedDataFrame)
import qualified Graphics.Vega.VegaLite as V

defaultScatterTitle ::
  forall x xColumnType y yColumnType schema.
  (Scatter x y schema xColumnType yColumnType) =>
  TypedDataFrame schema -> V.PropertySpec
defaultScatterTitle df = title $ Text.unwords [colName @x @schema df, "vs.", colName @y @schema df]
