//
//  SEGDetailViewController.h
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SEGDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
