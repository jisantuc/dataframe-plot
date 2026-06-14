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
  ( constantColorEncoding,
    nominalColorEncoding,
    pointEncoding,
    VLColumn,
    KnownNumericColumn,
    KnownTextColumn,
    NumericVLColumn (..),
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
    Num columnType,
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
  (Integral columnType, KnownNumericColumn col columnType schema) =>
  NumericVLColumn col columnType schema
  where
  numericVLColumn df = V.dataColumn (colName @col df) (V.Numbers (fromIntegral <$> columnAsList @col df))

instance
  (KnownNumericColumn col Double schema) =>
  NumericVLColumn col Double schema
  where
  numericVLColumn df = V.dataColumn (colName @col df) (V.Numbers (columnAsList @col df))

-- TODO: I don't actually know how to fold over a list of columns and types, but I think something like that is
-- in thinking with types

-- |
-- Build `hvega`'s `Data` from a typed dataframe by indicating which columns contribute to the visualization.
--
-- `hvega`'s column types will be inferred from the types of data in the dataframe's schema.
vegaData :: TypedDataFrame schema -> V.Data
vegaData df = V.dataFromColumns [] []

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
