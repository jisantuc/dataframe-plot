{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module DataFrame.Plot.Typed.Mid
  ( scatter,
    scatterCategorical,
    Scatter,
  )
where

import DataFrame.Plot.Typed.Low
  ( KnownNumericColumn,
    KnownTextColumn,
    Scatter,
    constantColorEncoding,
    nominalColorEncoding,
    numericVLColumn,
    pointEncoding,
    pointMark,
  )
import DataFrame.Plot.Typed.Mid.Text (defaultScatterTitle)
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
  (Scatter x y schema xColumnType yColumnType) =>
  TypedDataFrame schema -> V.VegaLite
scatter df =
  V.toVegaLite
    [ V.dataFromColumns [] $
        (numericVLColumn @x @xColumnType @schema df . numericVLColumn @y @yColumnType @schema df $ []),
      V.encoding
        . pointEncoding @x @xColumnType @y @yColumnType @schema df
        . constantColorEncoding "firebrick"
        $ [],
      pointMark,
      defaultScatterTitle @x @xColumnType @y @yColumnType @schema df
    ]
