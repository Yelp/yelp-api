import json
import oauth2
import optparse
import urllib
import urllib2

import api

parser = api.option_parser()
parser.add_option('-i', '--id', dest='id', help='Business')

options, args = api.validate_parse_args(parser)

if not options.id:
  parser.error('--id required')

path = '/v2/business/%s' % (options.id,)
response = api.request(options.host, path, None, options.consumer_key, options.consumer_secret, options.token, options.token_secret)
print json.dumps(response, sort_keys=True, indent=2)
