{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module Main where

import Data.Aeson
import GHC.Generics
import Network.HTTP.Conduit
import Web.Authenticate.OAuth

import Credentials

data Business =
  Business { name          :: String
           , url           :: String
           , rating        :: Double
           , display_phone :: Maybe String
             } deriving (Show, Generic)

instance FromJSON Business
instance ToJSON Business

data YelpResponse =
  YelpResponse { total       :: Int
               , businesses  :: [Business]
                 } deriving (Show, Generic)

instance FromJSON YelpResponse
instance ToJSON YelpResponse

main :: IO ()
main = do
  putStrLn "Welcome to Yelp, what are you looking for?"
  searchTerm <- getLine
  putStrLn $ "\nCool, here are some businesses that have " ++ searchTerm
  contents <- search searchTerm
  case contents of
    Left err -> putStrLn err
    Right rs -> do
      let bizs    = businesses rs
      let names   = map name   $ bizs
      let ratings = map rating $ bizs
      mapM_ putStrLn $
        [ n ++ ": " ++ (show r) ++ " stars"
          | (n,r) <- zip names ratings]

search :: String -> IO (Either String YelpResponse)
search term = do
  request  <- (parseUrl $ "https://api.yelp.com/v2/search/?location=San Francisco, CA&term=" ++ term) :: (IO Request)
  signed   <- signOAuth myoauth mycred request
  manager  <- newManager tlsManagerSettings
  response <- httpLbs signed manager
  return $ eitherDecode $ responseBody response
