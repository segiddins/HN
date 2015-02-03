//
//  SEGCommentCell.h
//  Hacker News
//
//  Created by Samuel E. Giddins on 3/23/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SEGCommentCell : UITableViewCell

@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic) NSInteger indentationLevel;

@property (nonatomic, readonly) CGFloat realHeight;

- (void)setCommentText:(NSString *)text;

@end
