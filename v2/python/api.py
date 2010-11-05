
import json
import oauth2
import optparse
import urllib
import urllib2


def option_parser():
  parser = optparse.OptionParser()
  parser.add_option('-c', '--consumer_key', dest='consumer_key', help='OAuth consumer key (REQUIRED)')
  parser.add_option('-s', '--consumer_secret', dest='consumer_secret', help='OAuth consumer secret (REQUIRED)')
  parser.add_option('-t', '--token', dest='token', help='OAuth token (REQUIRED)')
  parser.add_option('-e', '--token_secret', dest='token_secret', help='OAuth token secret (REQUIRED)')
  parser.add_option('-a', '--host', dest='host', help='Host', default='api.yelp.com')
  return parser

def validate_parse_args(parser):
  """Return parse args from options parser."""
  options, args = parser.parse_args()

  # Required options
  if not options.consumer_key:
    parser.error('--consumer_key required')
  if not options.consumer_secret:
    parser.error('--consumer_secret required')
  if not options.token:
    parser.error('--token required')
  if not options.token_secret:
    parser.error('--token_secret required')

  return options, args

def request(host, path, url_params, consumer_key, consumer_secret, token, token_secret):
  """Returns response for API request."""
  # Unsigned URL
  encoded_params = None
  if url_params:
    encoded_params = urllib.urlencode(url_params)
  url = 'http://%s%s?%s' % (host, path, encoded_params)
  print 'URL: %s' % (url,)

  # Sign the URL
  consumer = oauth2.Consumer(consumer_key, consumer_secret)
  oauth_request = oauth2.Request('GET', url, {})
  oauth_request.update({'oauth_nonce': oauth2.generate_nonce(),
                        'oauth_timestamp': oauth2.generate_timestamp(),
                        'oauth_token': token,
                        'oauth_consumer_key': consumer_key})

  token = oauth2.Token(token, token_secret)
  oauth_request.sign_request(oauth2.SignatureMethod_HMAC_SHA1(), consumer, token)
  signed_url = oauth_request.to_url()
  print 'Signed URL: %s\n' % (signed_url,)

  # Connect
  try:
    conn = urllib2.urlopen(signed_url, None)
    try:
      response = json.loads(conn.read())
    finally:
      conn.close()
  except urllib2.HTTPError, error:
    response = json.loads(error.read())

  return response
