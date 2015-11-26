extern crate hyper;
extern crate oauthcli;
extern crate serde_json;

use std::io::Read;

use hyper::Url;
use hyper::client::Client;
use hyper::header::Authorization;
use oauthcli::{SignatureMethod, authorization_header, nonce, timestamp};
use serde_json::Value;

// Update OAuth credentials below from the Yelp Developers API site:
// http://www.yelp.com/developers/getting_started/api_access
const CONSUMER_KEY:    &'static str = "";
const CONSUMER_SECRET: &'static str = "";
const TOKEN:           &'static str = "";
const TOKEN_SECRET:    &'static str = "";

fn main() {
    let term = "dinner";
    let location = "San Francisco, CA";
    let limit = 3;

    let base = Url::parse("https://api.yelp.com/v2/search/").unwrap();
    let params = vec![
        ("term".to_owned(), term.to_owned()),
        ("location".to_owned(), location.to_owned()),
        ("limit".to_owned(), limit.to_string()),
    ];

    // Construct the full URL including query params
    let mut url = base.clone();
    url.set_query_from_pairs(params.iter().map(|&(ref k, ref v)| {
        (&k[..], &v[..])
    }));

    // Generate the authorization header for this request
    let auth = authorization_header(
        "GET", base, None,
        CONSUMER_KEY, CONSUMER_SECRET,
        Some(TOKEN), Some(TOKEN_SECRET),
        SignatureMethod::HmacSha1,
        &timestamp(), &nonce(),
        None, None, params.into_iter(),
    );

    // Send the request
    let client = Client::new();
    let request = client.get(url).header(Authorization(auth));
    let mut response = request.send().unwrap();

    // Read and parse the response
    let mut result = String::new();
    response.read_to_string(&mut result).unwrap();
    let data: Value = serde_json::from_str(&result).unwrap();

    println!("{}", serde_json::to_string_pretty(&data).unwrap());
}
