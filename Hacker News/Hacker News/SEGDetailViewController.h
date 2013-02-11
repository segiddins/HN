//
//  SEGDetailViewController.h
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEGHNItem.h"
#import "JHWebBrowser.h"

@interface SEGDetailViewController : UIViewController <JHWebBrowserDelegate>

@property (strong, nonatomic) SEGHNItem *detailItem;

@property JHWebBrowser *browser;

@property (nonatomic) bool viewComments;

@end
