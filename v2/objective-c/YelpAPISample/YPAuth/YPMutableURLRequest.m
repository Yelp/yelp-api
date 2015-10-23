//
//  YPMutableURLRequest.m
//  YelpAPISample
//
//  Created by Thibaud Robelain on 16/10/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import "YPMutableURLRequest.h"
#import "YPRequestParameter.h"
#import "NSString+URLEncoding.h"
#import "NSURL+Base.h"

static NSString * const kOAuthVersion = @"1.0";

@interface YPMutableURLRequest()

@property (strong, nonatomic) YPToken *token;
@property (strong, nonatomic) YPConsumer *consumer;
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *nonce;
@property (strong, nonatomic) NSString *signature;
@property (strong, nonatomic) NSString *realm;
@property (strong, nonatomic) id<YPSignatureProvider> signatureProvider;

@end

@implementation YPMutableURLRequest

- (instancetype)initWithURL:(NSURL *)URL token:(YPToken *)token consumer:(YPConsumer *)consumer realm:(NSString *)realm signatureProvider:(id<YPSignatureProvider>)signatureProvider {
  if (self = [super initWithURL:URL]) {

    self.token = token;
    self.consumer = consumer;
    self.realm = (realm)? realm : @"";
    self.timestamp = [self _generateTimestamp];
    self.nonce = [self _generateNonce];
    if (signatureProvider) {
      self.signatureProvider = signatureProvider;
    } else {
      self.signatureProvider = [[YPHMAC_SHA1SignatureProvider alloc] init];
    }

    self.HTTPMethod = @"GET"; // This needs to happen before the OAuth is setup because it is used by it.
    [self _setupOAuth];
  }

  return self;
}

#pragma mark - Setting up the OAuth fields

- (void)_setupOAuth {

  self.signature = [self.signatureProvider signClearText:[self _signatureBaseString]
                                    withSecret:[NSString stringWithFormat:@"%@&%@",
                                                [self.consumer.secret encodedURLParameterString],
                                                [self.token.secret encodedURLParameterString]]];

  NSMutableArray *fields = [[NSMutableArray alloc] init];
  [fields addObject:[NSString stringWithFormat:@"realm=\"%@\"", [self.realm encodedURLParameterString]]];
  [fields addObject:[NSString stringWithFormat:@"oauth_consumer_key=\"%@\"", [self.consumer.key encodedURLParameterString]]];

  NSDictionary *tokenParameters = [self.token OAuthHeaderParameters];
  for (NSString *key in tokenParameters) {
    [fields addObject:[self _OAuthFieldWithKey:key value:[tokenParameters objectForKey:key]]];
  }

  [fields addObject:[self _OAuthFieldWithKey:@"oauth_signature_method" value:[self.signatureProvider name]]];
  [fields addObject:[self _OAuthFieldWithKey:@"oauth_signature" value:self.signature]];
  [fields addObject:[self _OAuthFieldWithKey:@"oauth_timestamp" value:self.timestamp]];
  [fields addObject:[self _OAuthFieldWithKey:@"oauth_nonce" value:self.nonce]];
  [fields addObject:[self _OAuthFieldWithKey:@"oauth_version" value:kOAuthVersion]];

  NSString *OAuthHeader = [NSString stringWithFormat:@"OAuth %@", [fields componentsJoinedByString:@", "]];

  [self setValue:OAuthHeader forHTTPHeaderField:@"Authorization"];
}

#pragma mark - Helpers

- (NSString *)_OAuthFieldWithKey:(NSString *)key value:(NSString *)value {
  return [NSString stringWithFormat:@"%@=\"%@\"", key, [value encodedURLParameterString]];
}

- (NSString *)_generateTimestamp {
  return [[NSString alloc]initWithFormat:@"%ld", time(NULL)];
}

- (NSString *)_generateNonce {
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);

  return (__bridge NSString *)string;
}

- (NSString *)_signatureBaseString {
  // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"

  NSDictionary *tokenParameters = [self.token OAuthHeaderParameters];
  NSArray *parameters = [self _queryParameters];
  NSMutableArray *parameterPairs = [[NSMutableArray alloc] init];

  [parameterPairs addObject:[[[YPRequestParameter alloc] initWithKey:@"oauth_consumer_key" value:self.consumer.key] URLEncodedKeyValuePair]];
  [parameterPairs addObject:[[[YPRequestParameter alloc] initWithKey:@"oauth_signature_method" value:[self.signatureProvider name]] URLEncodedKeyValuePair]];
  [parameterPairs addObject:[[[YPRequestParameter alloc] initWithKey:@"oauth_timestamp" value:self.timestamp] URLEncodedKeyValuePair]];
  [parameterPairs addObject:[[[YPRequestParameter alloc] initWithKey:@"oauth_nonce" value:self.nonce] URLEncodedKeyValuePair]];
  [parameterPairs addObject:[[[YPRequestParameter alloc] initWithKey:@"oauth_version" value:kOAuthVersion] URLEncodedKeyValuePair]];

  for(NSString *key in tokenParameters) {
    YPRequestParameter *parameter = [[YPRequestParameter alloc] initWithKey:key value:[tokenParameters objectForKey:key]];
    [parameterPairs addObject:[parameter URLEncodedKeyValuePair]];
  }

  if (![[self valueForHTTPHeaderField:@"Content-Type"] hasPrefix:@"multipart/form-data"]) {
    for (YPRequestParameter *parameter in parameters) {
      [parameterPairs addObject:[parameter URLEncodedKeyValuePair]];
    }
  }

  NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
  NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];

  return [NSString stringWithFormat:@"%@&%@&%@",
          [self HTTPMethod],
          [[[self URL] URLStringWithoutQuery] encodedURLParameterString],
          [normalizedRequestParameters encodedURLString]];
}

- (NSArray *)_queryParameters {
  NSString *encodedParameters = nil;

  if ([[self HTTPMethod] isEqualToString:@"GET"] || [[self HTTPMethod] isEqualToString:@"DELETE"]) {
    encodedParameters = [[self URL] query];
  } else {
    encodedParameters = [[NSString alloc] initWithData:[self HTTPBody] encoding:NSASCIIStringEncoding];
  }

  NSArray *encodedParameterPairs = [encodedParameters componentsSeparatedByString:@"&"];
  NSMutableArray *requestParameters = [NSMutableArray arrayWithCapacity:[encodedParameterPairs count]];

  for (NSString *encodedPair in encodedParameterPairs) {
    NSArray *encodedPairElements = [encodedPair componentsSeparatedByString:@"="];
    if ([encodedPairElements count] == 2) {
      YPRequestParameter *parameter = [[YPRequestParameter alloc] initWithKey:[[encodedPairElements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                        value:[[encodedPairElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
      [requestParameters addObject:parameter];
    }
  }

  return requestParameters;
}


@end
