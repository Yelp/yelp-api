# Examples

 - `search.py`: Command line interface to the Yelp Search API. `python search.py --help`
 - `business.py`: Command line interface to the Yelp Business API. `python business.py --help`
 - `sign_request.py`: Example for signing a search request using the oauth2 library.

These scripts require the oauth2 library which you can install via:

	sudo easy_install oauth2

Search for `bars` in `sf`:

	python search.py --consumer_key="CONSUMER_KEY" --consumer_secret="CONSUMER_SECRET" \
	--token="TOKEN" --token_secret="TOKEN_SECRET" --location="sf" --term="bars"

Lookup business information for `yelp-san-francisco` (Yelp):

	python business.py --consumer_key="CONSUMER_KEY" --consumer_secret="CONSUMER_SECRET" \
	--token="TOKEN" --token_secret="TOKEN_SECRET" --id="yelp-san-francisco"

# Clients

If you prefer to interact with the Yelp v2.0 API through a re-usable python module:

* [yelp-python-v2](https://github.com/mathisonian/python-yelp-v2)
