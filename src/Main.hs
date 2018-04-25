module Main where

import "rio" RIO hiding (withSystemTempFile)

import "prettyprinter" Data.Text.Prettyprint.Doc
    ( defaultLayoutOptions
    )
import "prettyprinter" Data.Text.Prettyprint.Doc.Render.Text (renderIO)
import "optparse-applicative" Options.Applicative            (execParser)
import "path-io" Path.IO
    ( copyFile
    , copyPermissions
    , makeAbsolute
    , withSystemTempFile
    )
import "base" System.Exit                                    (exitFailure)

import "purty" Purty
    ( Args(Args, filePath, output, verbosity)
    , Env(Env)
    , Output(InPlace, StdOut)
    , PrettyPrintConfig(PrettyPrintConfig)
    , Verbosity(Verbose)
    , argsInfo
    , envArgs
    , envLogFunc
    , envPrettyPrintConfig
    , layoutOptions
    , purty
    )

main :: IO ()
main = do
  envArgs@Args{ verbosity, filePath, output } <- execParser argsInfo
  let envPrettyPrintConfig =
        PrettyPrintConfig { layoutOptions = defaultLayoutOptions }
  logOptions <- logOptionsHandle stderr (verbosity == Verbose)
  withLogFunc logOptions $ \envLogFunc -> do
    let env = Env { envArgs, envLogFunc, envPrettyPrintConfig }
    runRIO env $ do
      logDebug ("Env: " <> display env)
      logDebug "Running main `purty` program"
      stream' <- purty
      case stream' of
        Left err -> do
          logError "Problem parsing module"
          logError (displayShow err)
          liftIO exitFailure
        Right stream -> do
          logDebug "Successfully created stream for rendering"
          logDebug (displayShow $ void stream)
          case output of
            InPlace -> liftIO $ withSystemTempFile "purty.purs" $ \fp h -> do
              absPath <- either pure makeAbsolute filePath
              renderIO h stream
              hClose h
              copyPermissions absPath fp
              copyFile fp absPath
            StdOut -> do
              logDebug "Printing to stdout"
              liftIO $ renderIO stdout stream
