//
//  SEGMappingProvider.m
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import "SEGMappingProvider.h"
#import "SEGHNItem.h"
#import "SEGHNComment.h"

@implementation SEGMappingProvider

+ (RKMapping *)newsItemMapping
{
    static RKObjectMapping *mapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = [RKObjectMapping mappingForClass:[SEGHNItem class]];
        [mapping addAttributeMappingsFromDictionary:@{
            @"id": @"itemID",
            @"_id": @"sigid"
         }];
        [mapping addAttributeMappingsFromArray:@[
            @"points",
            @"username",
            @"url",
            @"domain",
            @"create_ts",
            @"type",
            @"title"]];
    });
    return mapping;
}

+ (RKMapping *)commentMapping
{
    static RKObjectMapping *mapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = [RKObjectMapping mappingForClass:[SEGHNComment class]];
        [mapping addAttributeMappingsFromDictionary:@{
            @"text":@"commentText",
            @"parent_sigid":@"parentSigid",
            @"_id":@"sigid"
         }];
        [mapping addAttributeMappingsFromArray:@[
            @"username",
            @"create_ts"
        ]];
    });
    return mapping;
}

@end
