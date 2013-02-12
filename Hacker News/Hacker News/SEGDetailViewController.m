//
//  SEGDetailViewController.m
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import "SEGDetailViewController.h"
#import "SEGHNItem.h"

@interface SEGDetailViewController ()
- (void)configureView;
@end

@implementation SEGDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(SEGHNItem *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(toggleComment)];
    if (self.detailItem) {
        if (self.detailItem.url && !self.viewComments) {
            self.browser.url = [NSURL URLWithString: self.detailItem.url];
            self.navigationItem.title = nil;
            self.navigationItem.rightBarButtonItem.title = @"Comments";
            [self.browser setCanShowCommentButton:YES];
            self.browser.canDoTextOnly = YES;
        } else {
            [self.browser setUrl:[NSURL URLWithString: [NSString stringWithFormat: @"http://news.ycombinator.com/item?id=%@", self.detailItem.itemID]]];
            if (self.detailItem.url) {
                self.navigationItem.rightBarButtonItem.title = @"Linked Page";
                self.navigationItem.title = @"Comments";
                [self.browser setCanShowCommentButton:YES];
            } else {
                self.navigationItem.title = @"Post";
                self.navigationItem.rightBarButtonItem = nil;
                [self.browser setCanShowCommentButton:NO];
            }
            self.browser.canDoTextOnly = NO;
        }
        self.browser.textOnlyView = NO;
    }
}

- (void)toggleComment
{
    self.viewComments = !self.viewComments;
}

- (void)setViewComments:(bool)viewComments
{
    self->_viewComments = viewComments;
    [self configureView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _browser = [JHWebBrowser new];
    _browser.delegate = self;
    [self configureView];
    CGRect frame = self.view.bounds;
//    frame.size.height -= 50;
    self.browser.view.frame = frame;
    self.browser.showAddressBar = NO;
    self.browser.showTitleBar = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? YES : NO;
    [self.view addSubview:self.browser.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Browser Delegate Methods

- (NSString *)titleToShare
{
    return self.detailItem.title;
}

@end
