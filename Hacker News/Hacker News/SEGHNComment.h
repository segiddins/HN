//
//  SEGHNComment.h
//  Hacker News
//
//  Created by Samuel E. Giddins on 3/3/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SEGHNComment : NSObject

@property NSString *commentText;
@property NSString *username;
@property NSString *parentSigid;
@property NSString *sigid;
@property NSDate   *create_ts;
@property SEGHNComment *parent;

- (NSInteger)nestedLevel;

@end
