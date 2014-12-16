using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using CommandLine;
using Newtonsoft.Json.Linq;
using SimpleOAuth;

/// <summary>
/// Yelp API v2.0 code sample.
/// This program demonstrates the capability of the Yelp API version 2.0
/// by using the Search API to query for businesses by a search term and location,
/// and the Business API to query additional information about the top result
/// from the search query.
///
/// Please refer to http://www.yelp.com/developers/documentation for the API documentation.
///
/// Sample usage of the program:
/// `YelpAPI.exe --term="bars" --location="San Francisco, CA"`
/// </summary>
namespace YelpAPI
{
    /// <summary>
    /// Class that encapsulates the logic for querying the API.
    ///
    /// Users have to set the OAuth credentials properties
    /// in order to use this class.
    /// </summary>
    class YelpAPIClient
    {
        /// <summary>
        /// Consumer key used for OAuth authentication.
        /// This must be set by the user.
        /// </summary>
        private const string CONSUMER_KEY = null;

        /// <summary>
        /// Consumer secret used for OAuth authentication.
        /// This must be set by the user.
        /// </summary>
        private const string CONSUMER_SECRET = null;

        /// <summary>
        /// Token used for OAuth authentication.
        /// This must be set by the user.
        /// </summary>
        private const string TOKEN = null;

        /// <summary>
        /// Token secret used for OAuth authentication.
        /// This must be set by the user.
        /// </summary>
        private const string TOKEN_SECRET = null;

        /// <summary>
        /// Host of the API.
        /// </summary>
        private const string API_HOST = "http://api.yelp.com";

        /// <summary>
        /// Relative path for the Search API.
        /// </summary>
        private const string SEARCH_PATH = "/v2/search/";

        /// <summary>
        /// Relative path for the Business API.
        /// </summary>
        private const string BUSINESS_PATH = "/v2/business/";

        /// <summary>
        /// Search limit that dictates the number of businesses returned.
        /// </summary>
        private const int SEARCH_LIMIT = 3;

        /// <summary>
        /// Prepares OAuth authentication and sends the request to the API.
        /// </summary>
        /// <param name="baseURL">The base URL of the API.</param>
        /// <param name="queryParams">The set of query parameters.</param>
        /// <returns>The JSON response from the API.</returns>
        /// <exception>Throws WebException if there is an error from the HTTP request.</exception>
        private JObject PerformRequest(string baseURL, Dictionary<string, string> queryParams=null)
        {
            var query = System.Web.HttpUtility.ParseQueryString(String.Empty);

            if (queryParams == null)
            {
                queryParams = new Dictionary<string, string>();
            }

            foreach (var queryParam in queryParams)
            {
                query[queryParam.Key] = queryParam.Value;
            }

            var uriBuilder = new UriBuilder(baseURL);
            uriBuilder.Query = query.ToString();

            var request = WebRequest.Create(uriBuilder.ToString());
            request.Method = "GET";

            request.SignRequest(
                new Tokens {
                    ConsumerKey = CONSUMER_KEY,
                    ConsumerSecret = CONSUMER_SECRET,
                    AccessToken = TOKEN,
                    AccessTokenSecret = TOKEN_SECRET
                }
            ).WithEncryption(EncryptionMethod.HMACSHA1).InHeader();

            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            var stream = new StreamReader(response.GetResponseStream(), Encoding.UTF8);
            return JObject.Parse(stream.ReadToEnd());
        }

        /// <summary>
        /// Query the Search API by a search term and location.
        /// </summary>
        /// <param name="term">The search term passed to the API.</param>
        /// <param name="location">The search location passed to the API.</param>
        /// <returns>The JSON response from the API.</returns>
        public JObject Search(string term, string location)
        {
            string baseURL = API_HOST + SEARCH_PATH;
            var queryParams = new Dictionary<string, string>()
            {
                { "term", term },
                { "location", location },
                { "limit", SEARCH_LIMIT.ToString() }
            };
            return PerformRequest(baseURL, queryParams);
        }

        /// <summary>
        /// Query the Business API by a business ID.
        /// </summary>
        /// <param name="business_id">The ID of the business to query.</param>
        /// <returns>The JSON response from the API.</returns>
        public JObject GetBusiness(string business_id)
        {
            string baseURL = API_HOST + BUSINESS_PATH + business_id;
            return PerformRequest(baseURL);
        }
    }

    /// <summary>
    /// Command-line options abstraction.
    /// </summary>
    class Options
    {
        /// <summary>
        /// Gets and sets the Term property.
        /// </summary>
        /// <value>The search term specified by the user.</value>
        [Option('t', "term", DefaultValue="dinner", HelpText = "Search term")]
        public string Term { get; set; }

        /// <summary>
        /// Gets and sets the Location property.
        /// </summary>
        /// <value>The location term specified by the user.</value>
        [Option('l', "location", DefaultValue="San Francisco, CA", HelpText = "Search Location")]
        public string Location { get; set; }
    }

    /// <summary>
    /// Class that encapsulates the program entry point.
    /// </summary>
    class Program
    {
        /// <summary>
        /// Queries the API by the input values from the user, and prints
        /// the result on the console.
        /// </summary>
        /// <param name="term">The search term to query.</param>
        /// <param name="location">The location of the business to query.</param>
        public static void QueryAPIAndPrintResult(string term, string location)
        {
            var client = new YelpAPIClient();

            Console.WriteLine("Querying for {0} in {1}...", term, location);

            JObject response = client.Search(term, location);

            JArray businesses = (JArray)response.GetValue("businesses");

            if (businesses.Count == 0)
            {
                Console.WriteLine("No businesses for {0} in {1} found.", term, location);
                return;
            }

            string business_id = (string)businesses[0]["id"];

            Console.WriteLine(
                "{0} businesses found, querying business info for the top result \"{1}\"...",
                businesses.Count,
                business_id
            );

            response = client.GetBusiness(business_id);

            Console.WriteLine(String.Format("Result for business {0} found:", business_id));        
            Console.WriteLine(response.ToString());
        }

        /// <summary>
        /// Program entry point.
        /// </summary>
        /// <param name="args">The command-line arguments.</param>
        static void Main(string[] args)
        {
            var options = new Options();

            try
            {
                CommandLine.Parser.Default.ParseArguments(args, options);
            }
            catch (CommandLine.ParserException)
            {
                Console.Error.WriteLine("Failed to parse command line options.");
                Environment.Exit(-1);
            }

            try
            {
                Program.QueryAPIAndPrintResult(options.Term, options.Location);
            }
            catch (WebException error)
            {
                if (error.Response != null)
                    using (var reader = new StreamReader(error.Response.GetResponseStream()))
                    {
                        Console.Error.WriteLine("Response returned: {0}", reader.ReadToEnd());
                    }

                Console.Error.WriteLine("HTTP request failed, got {0}, abort program.", error.Message);

                Environment.Exit(-1);
            }
        }
    }
}