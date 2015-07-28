# -*- coding: utf-8 -*-
"""
Yelp API v2.0 code sample.

This program demonstrates the capability of the Yelp API version 2.0
by using the Search API to query for businesses by a search term and location,
and the Business API to query additional information about the top result
from the search query.

Please refer to http://www.yelp.com/developers/documentation for the API documentation.

This program requires the Python oauth2 library, which you can install via:
`pip install -r requirements.txt`.

Sample usage of the program:
`python sample.py --term="bars" --location="San Francisco, CA"`
"""
import gevent.monkey
gevent.monkey.patch_all()

import argparse
import codecs
import cStringIO
import csv
import os
import sys
import urllib
import urllib2

from bs4 import BeautifulSoup
import gevent
import oauth2
import requests


API_HOST = 'api.yelp.com'
DEFAULT_TERM = 'dinner'
DEFAULT_LOCATION = 'New York, NY'
SEARCH_LIMIT = 20
SEARCH_PATH = '/v2/search/'
BUSINESS_PATH = '/v2/business/'

# Yelp OAuth1 credentials
CONSUMER_KEY = os.environ.get('YELP_CONSUMER_KEY')
CONSUMER_SECRET = os.environ.get('YELP_CONSUMER_SECRET')
TOKEN = os.environ.get('YELP_API_TOKEN')
TOKEN_SECRET = os.environ.get('YELP_API_SECRET')


class UnicodeWriter:
    """
    A CSV writer which will write rows to CSV file "f",
    which is encoded in the given encoding.
    """

    def __init__(self, f, dialect=csv.excel, encoding="utf-8", **kwds):
        # Redirect output to a queue
        self.queue = cStringIO.StringIO()
        self.writer = csv.writer(self.queue, dialect=dialect, **kwds)
        self.stream = f
        self.encoder = codecs.getincrementalencoder(encoding)()

    def writerow(self, row):
        self.writer.writerow([s.encode("utf-8") if s else u'' for s in row])
        # Fetch UTF-8 output from the queue ...
        data = self.queue.getvalue()
        data = data.decode("utf-8")
        # ... and reencode it into the target encoding
        data = self.encoder.encode(data)
        # write to the target stream
        self.stream.write(data)
        # empty queue
        self.queue.truncate(0)

    def writerows(self, rows):
        for row in rows:
            self.writerow(row)


def request(host, path, url_params=None):
    """Prepares OAuth authentication and sends the request to the API.

    Args:
        host (str): The domain host of the API.
        path (str): The path of the API after the domain.
        url_params (dict): An optional set of query parameters in the request.

    Returns:
        dict: The JSON response from the request.

    Raises:
        urllib2.HTTPError: An error occurs from the HTTP request.
    """
    url_params = url_params or {}
    url = 'http://{0}{1}?'.format(host, urllib.quote(path.encode('utf8')))

    consumer = oauth2.Consumer(CONSUMER_KEY, CONSUMER_SECRET)
    oauth_request = oauth2.Request(method="GET", url=url, parameters=url_params)

    oauth_request.update(
        {
            'oauth_nonce': oauth2.generate_nonce(),
            'oauth_timestamp': oauth2.generate_timestamp(),
            'oauth_token': TOKEN,
            'oauth_consumer_key': CONSUMER_KEY
        }
    )
    token = oauth2.Token(TOKEN, TOKEN_SECRET)
    oauth_request.sign_request(oauth2.SignatureMethod_HMAC_SHA1(), consumer, token)
    signed_url = oauth_request.to_url()

    print u'Querying {0} ...'.format(url)

    r = requests.get(signed_url)
    return r.json()


def search(term, location, offset=None):
    """Query the Search API by a search term and location.

    Args:
        term (str): The search term passed to the API.
        location (str): The search location passed to the API.
        offset (int): The number of entries to skip ahead by.

    Returns:
        dict: The JSON response from the request.
    """
    if offset is None:
        offset = 0

    url_params = {
        'term': term.replace(' ', '+'),
        'location': location.replace(' ', '+'),
        'limit': SEARCH_LIMIT,
        'offset': offset,
    }

    return request(API_HOST, SEARCH_PATH, url_params=url_params)


def get_business(business_id):
    """Query the Business API by a business ID.

    Args:
        business_id (str): The ID of the business to query.

    Returns:
        dict: The JSON response from the request.
    """
    business_path = BUSINESS_PATH + business_id

    return request(API_HOST, business_path)


def query_api(term, location, output_file=None):
    """Queries the API by the input values from the user.

    Args:
        term (str): The search term to query.
        location (str): The location of the business to query.
        output_file (str): File handle to write scraped CSV output to. (default: stdout)
    """
    offset = 0
    response = search(term, location, offset=offset)

    businesses = response.get('businesses')
    total_businesses = response.get('total')

    with open(output_file, 'w') if output_file else sys.stdout as csv_file:
        csv_writer = UnicodeWriter(csv_file, delimiter=',')
        # TODO write header

        while businesses and offset < total_businesses:
            print 'Handling results {} to {}...'.format(offset + 1, offset + len(businesses))

            business_url_results = [
                gevent.spawn(parse_business_url, business.get('url')) for business in businesses
            ]
            gevent.joinall(business_url_results)

            for index, business in enumerate(businesses):
                business_url = business_url_results[index].value

                csv_writer.writerow([
                    business.get('name', u''),
                    business.get('phone', u''),
                    business.get('url', u''),
                    business_url,
                ])

            offset += SEARCH_LIMIT
            response = search(term, location, offset=offset)
            businesses = response.get('businesses')

    print u'No more businesses for {0} in {1} found.'.format(term, location)
    return


def parse_business_url(yelp_url):
    """ Extract the business url from a yelp profile page. """
    if not yelp_url:
        return u''

    r = requests.get(yelp_url)
    html_doc = r.text
    soup = BeautifulSoup(html_doc, 'html.parser')
    # print soup.prettify(encoding='utf-8')

    business_info = soup.find(class_='biz-website')
    if business_info:
        anchor_tag = business_info.a
        if anchor_tag:
            raw_url = anchor_tag.string
            return u'http://www.{}'.format(raw_url)  # .encode('utf-8'))


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-q', '--term', dest='term', default=DEFAULT_TERM,
        type=str, help='Search term (default: %(default)s)')
    parser.add_argument(
        '-l', '--location', dest='location', default=DEFAULT_LOCATION,
        type=str, help='Search location (default: %(default)s)')
    parser.add_argument(
        '-f', '--file', dest='file', default=None,
        type=str, help='A file to dump results to')

    input_values = parser.parse_args()

    try:
        query_api(input_values.term, input_values.location, output_file=input_values.file)
    except urllib2.HTTPError as error:
        sys.exit('Encountered HTTP error {0}. Abort program.'.format(error.code))


if __name__ == '__main__':
    main()
