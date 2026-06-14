{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module DataFrame.Plot.Typed.Mid where

import DataFrame.Plot.Typed.Low
  ( KnownNumericColumn,
    KnownTextColumn,
    constantColorEncoding,
    nominalColorEncoding,
    pointEncoding,
  )
import DataFrame.Typed.Types (TypedDataFrame)
import qualified Graphics.Vega.VegaLite as V

scatterCategorical ::
  forall x xColumnType y yColumnType tag tagColumnType schema.
  ( KnownNumericColumn x xColumnType schema,
    KnownNumericColumn y yColumnType schema,
    KnownTextColumn tag tagColumnType schema
  ) =>
  TypedDataFrame schema -> V.VegaLite
scatterCategorical df =
  V.toVegaLite
    [ V.encoding
        . pointEncoding @x @xColumnType @y @yColumnType @schema df
        . nominalColorEncoding @tag @tagColumnType df
        $ []
    ]

scatter ::
  forall x xColumnType y yColumnType schema.
  ( KnownNumericColumn x xColumnType schema,
    KnownNumericColumn y yColumnType schema
  ) =>
  TypedDataFrame schema -> V.VegaLite
scatter df =
  V.toVegaLite
    [ V.encoding
        . pointEncoding @x @xColumnType @y @yColumnType @schema df
        . constantColorEncoding "firebrick"
        $ []
    ]
