import oauth2
import urllib
import urllib2
import json

# Fill in these values
consumer_key = ''
consumer_secret = ''
token = ''
token_secret = ''
api_host = 'api.yelp.com'
# Email and password for a user
email = ''
password = ''

consumer = oauth2.Consumer(consumer_key, consumer_secret)
url = 'https://%s%s' % (api_host, '/v2/oauth/access_token')
post_data = {'email': email, 'password': password}
oauth_request = oauth2.Request('POST', url, post_data)
oauth_request.update({'oauth_nonce': oauth2.generate_nonce(),
                      'oauth_timestamp': oauth2.generate_timestamp(),
                      'oauth_token': token,
                      'oauth_consumer_key': consumer_key})

token = oauth2.Token(token, token_secret)

oauth_request.sign_request(oauth2.SignatureMethod_HMAC_SHA1(), consumer, token)

# Remove post params; TODO(gabe): Submit patch for oauth2 for generating post url
for key in post_data:
  del oauth_request[key]

url = oauth_request.to_url()

print 'Requesting with URL: %s' % (url,)

conn = urllib2.urlopen(url, urllib.urlencode(post_data))
try:
  response = json.loads(conn.read())
finally:
  conn.close()

print response
