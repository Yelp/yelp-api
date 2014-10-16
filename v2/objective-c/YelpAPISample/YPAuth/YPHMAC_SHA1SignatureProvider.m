//
//  YPHMAC_SHA1SignatureProvider.m
//  YelpAPISample
//
//  Created by Thibaud Robelain on 16/10/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import "YPHMAC_SHA1SignatureProvider.h"
#import "hmac.h"
#import "Base64Transcoder.h"

@implementation YPHMAC_SHA1SignatureProvider

- (NSString *)name {
    return @"HMAC-SHA1";
}

- (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret {
  NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
  NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
  unsigned char result[20];
  hmac_sha1((unsigned char *)[clearTextData bytes], [clearTextData length], (unsigned char *)[secretData bytes], [secretData length], result);

  //Base64 Encoding
  char base64Result[32];
  size_t resultLength = 32;
  Base64EncodeData(result, 20, base64Result, &resultLength);
  NSData *data = [NSData dataWithBytes:base64Result length:resultLength];

  NSString *base64EncodedResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return base64EncodedResult;
}

@end
