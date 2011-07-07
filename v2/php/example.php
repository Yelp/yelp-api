<?php

//
// From http://non-diligent.com/articles/yelp-apiv2-php-example/
//


// Enter the path that the oauth library is in relation to the php file
require_once ('lib/OAuth.php');

// For example, request business with id 'the-waterboy-sacramento'
$unsigned_url = "http://api.yelp.com/v2/business/the-waterboy-sacramento";

// For examaple, search for 'tacos' in 'sf'
//$unsigned_url = "http://api.yelp.com/v2/search?term=tacos&location=sf";


// Set your keys here
$consumer_key = "";
$consumer_secret = "";
$token = "";
$token_secret = "";

// Token object built using the OAuth library
$token = new OAuthToken($token, $token_secret);

// Consumer object built using the OAuth library
$consumer = new OAuthConsumer($consumer_key, $consumer_secret);

// Yelp uses HMAC SHA1 encoding
$signature_method = new OAuthSignatureMethod_HMAC_SHA1();

// Build OAuth Request using the OAuth PHP library. Uses the consumer and token object created above.
$oauthrequest = OAuthRequest::from_consumer_and_token($consumer, $token, 'GET', $unsigned_url);

// Sign the request
$oauthrequest->sign_request($signature_method, $consumer, $token);

// Get the signed URL
$signed_url = $oauthrequest->to_url();

// Send Yelp API Call
$ch = curl_init($signed_url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, 0);
$data = curl_exec($ch); // Yelp response
curl_close($ch);

// Handle Yelp response data
$response = json_decode($data);

// Print it for debugging
print_r($response);

?>
