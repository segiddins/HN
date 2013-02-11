//
//  SEGRootViewController.h
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/10/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SEGMasterViewController.h"
#import "SEGDetailViewController.h"

@interface SEGRootViewController : UISplitViewController

@property SEGMasterViewController *mvc;
@property SEGDetailViewController *dvc;

@end
