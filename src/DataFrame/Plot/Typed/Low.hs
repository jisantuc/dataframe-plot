{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

module DataFrame.Plot.Typed.Low
  ( colName,
    constantColorEncoding,
    nominalColorEncoding,
    pointEncoding,
    pointMark,
    title,
    VLColumn,
    KnownNumericColumn,
    KnownTextColumn,
    NumericVLColumn (..),
    Scatter,
    TextVLColumn (..),
  )
where

import Data.String (IsString)
import Data.Text (Text, pack)
import Data.Typeable (Proxy (Proxy))
import DataFrame.Internal.Column (Columnable)
import DataFrame.Typed.Access (columnAsList)
import DataFrame.Typed.Schema (AssertPresent, SafeLookup)
import DataFrame.Typed.Types (TypedDataFrame)
import GHC.TypeLits (KnownSymbol, symbolVal)
import qualified Graphics.Vega.VegaLite as V

type KnownNumericColumn col columnType schema =
  ( KnownSymbol col,
    Real columnType,
    columnType ~ SafeLookup col schema,
    AssertPresent col schema,
    Columnable columnType
  )

type KnownTextColumn col columnType schema =
  ( KnownSymbol col,
    columnType ~ SafeLookup col schema,
    AssertPresent col schema,
    Columnable columnType,
    IsString columnType
  )

type Scatter x y schema xColumnType yColumnType =
  ( KnownNumericColumn x xColumnType schema,
    KnownNumericColumn y yColumnType schema
  )

type VLColumn = [V.DataColumn] -> [V.DataColumn]

colName ::
  forall col schema.
  (KnownSymbol col, AssertPresent col schema) =>
  TypedDataFrame schema -> Text
colName _ = pack . symbolVal $ Proxy @col

class (KnownSymbol col) => TextVLColumn col columnType schema where
  textVLColumn :: TypedDataFrame schema -> VLColumn

instance (KnownTextColumn col String schema) => TextVLColumn col String schema where
  textVLColumn df = V.dataColumn (colName @col df) (V.Strings (pack <$> columnAsList @col df))

instance (KnownTextColumn col Text schema) => TextVLColumn col Text schema where
  textVLColumn df = V.dataColumn (colName @col df) (V.Strings (columnAsList @col df))

class (KnownSymbol col) => NumericVLColumn col columnType schema where
  numericVLColumn :: TypedDataFrame schema -> VLColumn

instance
  (Real columnType, KnownNumericColumn col columnType schema) =>
  NumericVLColumn col columnType schema
  where
  numericVLColumn df = V.dataColumn (colName @col df) (V.Numbers (realToFrac <$> columnAsList @col df))

---
-- Encoding
---

pointEncoding ::
  forall x xColumnType y yColumnType schema.
  (KnownNumericColumn x xColumnType schema, KnownNumericColumn y yColumnType schema) =>
  TypedDataFrame schema -> V.BuildEncodingSpecs
pointEncoding df =
  V.position V.X [V.PName (colName @x df), V.PmType V.Quantitative]
    . V.position V.Y [V.PName (colName @y df), V.PmType V.Quantitative]

nominalColorEncoding ::
  forall col columnType schema.
  (KnownTextColumn col columnType schema) =>
  TypedDataFrame schema -> V.BuildEncodingSpecs
nominalColorEncoding df = V.color [V.MName (colName @col df), V.MmType V.Nominal]

constantColorEncoding :: Text -> V.BuildEncodingSpecs
constantColorEncoding colorName = V.color [V.MString colorName]

---
-- Marks
---

pointMark :: V.PropertySpec
pointMark = V.mark V.Point [V.MFilled True]

---
-- Title and labels
---

title :: Text -> V.PropertySpec
title text = V.title text []
