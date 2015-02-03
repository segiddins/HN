//
//  SEGCommentCell.m
//  Hacker News
//
//  Created by Samuel E. Giddins on 3/23/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import "SEGCommentCell.h"
#import "NSString+HTML.h"

@interface SEGCommentCell ()

@property (nonatomic, strong) UILabel *commentTextView;

@end

@implementation SEGCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addUsernameLabel];
        [self addCommentTextLabel];
        [self setupBackground];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    CGSize shadowOffset = highlighted ? CGSizeZero : CGSizeMake(0, 1);
    self.usernameLabel.shadowOffset = shadowOffset;
    self.commentTextView.shadowOffset = shadowOffset;
}

- (void)addUsernameLabel {
    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:16];
    self.usernameLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1.0];
    self.usernameLabel.shadowColor = [UIColor whiteColor];
    self.usernameLabel.shadowOffset = CGSizeMake(0, 1);
    self.usernameLabel.backgroundColor = [UIColor clearColor];
    self.usernameLabel.highlightedTextColor = [UIColor whiteColor];
    self.usernameLabel.numberOfLines = 0;
    
    [self.contentView addSubview:self.usernameLabel];
    
}

- (void)addCommentTextLabel {
    self.commentTextView = [[UILabel alloc] init];
    self.commentTextView.font = [UIFont systemFontOfSize:14];
    self.commentTextView.textColor = [UIColor colorWithWhite:.25 alpha:1.0];
    self.commentTextView.shadowColor = [UIColor whiteColor];
    self.commentTextView.shadowOffset = CGSizeMake(0, 1);
    self.commentTextView.backgroundColor = [UIColor clearColor];
    self.commentTextView.highlightedTextColor = [UIColor whiteColor];
    self.commentTextView.numberOfLines = 0;
    self.commentTextView.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.contentView addSubview:self.commentTextView];
}

- (void)setCommentText:(NSString *)text {
    self.commentTextView.text = [text stringByConvertingHTMLToPlainText];
}

- (void)setupBackground {
    self.backgroundColor = [UIColor colorWithWhite:.51 alpha:.15];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat HorizontalMargin = 10;
    const CGFloat VerticalMargin = 4;
    
    CGFloat x = HorizontalMargin + self.indentationLevel * 25;
    CGFloat y = VerticalMargin;
    CGSize textSize = [self.usernameLabel.text sizeWithFont:self.usernameLabel.font];
    CGFloat width = self.contentView.frame.size.width - (2 * HorizontalMargin + self.indentationLevel * 25);
    CGFloat height = textSize.height;
    self.usernameLabel.frame = CGRectMake(x, y, width, height);
    
    y += height + VerticalMargin;
    textSize = [self.commentTextView.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(width, 2000) lineBreakMode:NSLineBreakByWordWrapping];
    height = textSize.height;
    self.commentTextView.frame = CGRectMake(x, y, width, height);
}

- (CGFloat)realHeight {
    const CGFloat VerticalMargin = 4;
    return self.commentTextView.frame.origin.y + self.commentTextView.frame.size.height + VerticalMargin;
}

@end
