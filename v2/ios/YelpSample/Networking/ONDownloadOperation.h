//
//  ONDownloadOperation.h
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "ONNetworkOperation.h"

#import "ONDownloadItem.h"

@interface ONDownloadOperation : ONNetworkOperation

@property (strong, nonatomic) ONDownloadItem *downloadItem;

- (id)initWithDownloadItem:(ONDownloadItem *)downloadItem;

- (id)initWithDownloadItem:(ONDownloadItem *)downloadItem andCategory:(NSString *)category;

@end
