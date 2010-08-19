import oauth2

# Fill in these values
consumer_key = ''
consumer_secret = ''
token = ''
token_secret = ''
api_host = 'api.yelp.com'

api_path_search = '/v2/search?term=food&location=San+Francisco'
api_path_check_ins = '/v2/check_ins'

consumer = oauth2.Consumer(consumer_key, consumer_secret)
url = 'http://%s%s' % (api_host, api_path_check_ins)
oauth_request = oauth2.Request('GET', url, {})
oauth_request.update({'oauth_nonce': oauth2.generate_nonce(),
                      'oauth_timestamp': oauth2.generate_timestamp(),
                      'oauth_token': token,
                      'oauth_consumer_key': consumer_key})

token = oauth2.Token(token, token_secret)

oauth_request.sign_request(oauth2.SignatureMethod_HMAC_SHA1(), consumer, token)

url = oauth_request.to_url()

print url