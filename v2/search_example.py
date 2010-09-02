import json
import oauth2
import optparse
import urllib
import urllib2

parser = optparse.OptionParser()
parser.add_option('-c', '--consumer_key', dest='consumer_key', help='OAuth consumer key (REQUIRED)')
parser.add_option('-s', '--consumer_secret', dest='consumer_secret', help='OAuth consumer secret (REQUIRED)')
parser.add_option('-t', '--token', dest='token', help='OAuth token (REQUIRED)')
parser.add_option('-e', '--token_secret', dest='token_secret', help='OAuth token secret (REQUIRED)')
parser.add_option('-a', '--api_host', dest='api_host', help='API Host', default='api.yelp.com')
parser.add_option('-q', '--term', dest='term', help='Search term')

parser.add_option('-l', '--location', dest='location', help='Location (address)')
parser.add_option('-b', '--bounds', dest='bounds', help='Bounds (sw_latitude,sw_longitude|ne_latitude,ne_longitude)')
parser.add_option('-p', '--point', dest='point', help='Latitude,longitude')
# Not sure if current location hints are currently working
#parser.add_option('-i', '--current_location', dest='current_location', help='Current location latitude,longitude for location disambiguation')

parser.add_option('-o', '--offset', dest='offset', help='Offset (starting position)')
parser.add_option('-r', '--limit', dest='limit', help='Limit (number of results to return)')
parser.add_option('-u', '--cc', dest='cc', help='Country code')
parser.add_option('-n', '--lang', dest='lang', help='Language code')


(options, args) = parser.parse_args()

# Required options
if not options.consumer_key:
	parser.error('--consumer_key required')
if not options.consumer_secret:
	parser.error('--consumer_secret required')
if not options.token:
	parser.error('--token required')
if not options.token_secret:
	parser.error('--token_secret required')

if not options.location and not options.bounds and not options.point:
	parser.error('--location, --bounds, or --point required')

# Setup URL params from options
url_params = {}
if options.term:
	url_params['term'] = options.term
if options.location:
	url_params['location'] = options.location
if options.bounds:
	url_params['bounds'] = options.bounds
if options.point:
	url_params['ll'] = options.point
if options.offset:
	url_params['offset'] = options.offset
if options.limit:
	url_params['limit'] = options.limit
if options.cc:
	url_params['cc'] = options.cc
if options.lang:
	url_params['lang'] = options.lang
if options.current_location:
	url_params['cll'] = options.current_location

# Unsigned URL
url = 'http://%s%s?%s' % (options.api_host, '/v2/search', urllib.urlencode(url_params))
print 'URL: %s' % (url,)

# Sign the URL
consumer = oauth2.Consumer(options.consumer_key, options.consumer_secret)
oauth_request = oauth2.Request('GET', url, {})
oauth_request.update({'oauth_nonce': oauth2.generate_nonce(),
                      'oauth_timestamp': oauth2.generate_timestamp(),
                      'oauth_token': options.token,
                      'oauth_consumer_key': options.consumer_key})

token = oauth2.Token(options.token, options.token_secret)
oauth_request.sign_request(oauth2.SignatureMethod_HMAC_SHA1(), consumer, token)
signed_url = oauth_request.to_url()
print 'Signed URL: %s\n' % (signed_url,)

# Connect
conn = urllib2.urlopen(signed_url, None)
try:
  response = json.loads(conn.read())
finally:
  conn.close()

print json.dumps(response, sort_keys=True, indent=2)

