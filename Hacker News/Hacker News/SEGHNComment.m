//
//  SEGHNComment.m
//  Hacker News
//
//  Created by Samuel E. Giddins on 3/3/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import "SEGHNComment.h"

@implementation SEGHNComment

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSInteger)nestedLevel {
    NSInteger level = 0;
    SEGHNComment *parent = self.parent;
    while (parent) {
        level++;
        parent = parent.parent;
    }
    return level;
}

@end
