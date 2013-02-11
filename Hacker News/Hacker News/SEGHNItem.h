//
//  SEGHNItem.h
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SEGHNItem : NSObject

@property NSNumber *itemID;
@property NSNumber *points;
@property NSString *username;
@property NSString *url;
@property NSString *domain;
@property NSDate   *create_ts;
@property NSString *type;
@property NSString *title;

@end
