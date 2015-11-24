{-# LANGUAGE OverloadedStrings #-}
module Credentials where

import Web.Authenticate.OAuth

-- NOTE:
--   This is only a template file!
--   To use this yourself, you need to fill in the specified fields below
--   (hint, you can get these creds at: https://www.yelp.com/developers/manage_api_keys )

myoauth :: OAuth
myoauth = 
  newOAuth { oauthServerName     = "api.yelp.com"
           , oauthConsumerKey    = "CONSUMER KEY"
           , oauthConsumerSecret = "COMSUMER SECRET"
             }

mycred :: Credential
mycred = newCredential "ACCESS TOKEN"
                       "ACCESS TOKEN SECRET"

