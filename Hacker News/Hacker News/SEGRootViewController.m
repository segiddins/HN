//
//  SEGRootViewController.m
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/10/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import "SEGRootViewController.h"

@interface SEGRootViewController ()

@end

@implementation SEGRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"%@", self.viewControllers);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
