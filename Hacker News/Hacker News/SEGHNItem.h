//
//  SEGHNItem.h
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEGHNComment.h"

@interface SEGHNItem : NSObject

@property NSString *itemID;
@property NSString *sigid;
@property NSNumber *points;
@property NSString *username;
@property NSString *url;
@property NSString *domain;
@property NSDate   *create_ts;
@property NSString *type;
@property NSString *title;
@property (nonatomic) NSMutableArray  *comments;
@property NSString *textView;
@property UIImage  *leadImage;
@property NSInteger commentCount;

- (void)loadTextView;
- (void)loadComments;

- (SEGHNComment *)commentForIndexPath:(NSIndexPath *)indexPath;

@end
