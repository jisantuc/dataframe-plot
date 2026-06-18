{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}

module Artifact.SnapshotSpec (spec) where

import Control.Monad.Trans.State (evalState)
import qualified Data.Text.Lazy as Text
import qualified Data.Text.Lazy.IO as Text
import DataFrame.Plot.Typed.High (textScatter)
import Gen (labeledPointsDf)
import System.FilePath ((</>))
import System.Random (mkStdGen)
import Test.Hspec (Spec, describe, it)

snapshot :: FilePath -> Text.Text -> IO ()
snapshot fname html =
  let pathFor = ("snapshots" </>)
   in Text.writeFile (pathFor fname) html

spec :: Spec
spec =
  let sampleData = evalState (labeledPointsDf 100) (mkStdGen 1234)
   in describe "plot snapshots" $ do
        it "simple scatter" $
          snapshot "simple-scatter.html" (textScatter @"x" @"y" sampleData)
