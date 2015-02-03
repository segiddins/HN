//
//  SEGDetailViewController.m
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import "SEGDetailViewController.h"
#import "SEGHNItem.h"
#import "SEGCommentListViewController.h"

@interface SEGDetailViewController ()
- (void)configureView;
@property SEGCommentListViewController *commentList;
@end

@implementation SEGDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(SEGHNItem *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        [_detailItem loadComments];
        
        NSLog(@"detail item's sigid: %@", _detailItem.itemID);

        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    NSLog(@"configuring view");
    NSLog(@"has url: %d\nview comments: %d", self.detailItem.url, self.viewComments);
    // Update the user interface for the detail item.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(toggleComment)];
    if (self.detailItem) {
        _commentList.hnItem = self.detailItem;
        if (self.detailItem.url && !self.viewComments) {
            self.browser.url = [NSURL URLWithString: self.detailItem.url];
            self.navigationItem.title = nil;
            self.navigationItem.rightBarButtonItem.title = @"Comments";
            [self.browser setCanShowCommentButton:YES];
            self.browser.canDoTextOnly = YES;
            [self.commentList.view removeFromSuperview];
        } else {
            self.commentList.view.frame = self.view.bounds;
            [self.view addSubview:self.commentList.view];
//            [self.browser setUrl:[NSURL URLWithString: [NSString stringWithFormat: @"http://news.ycombinator.com/item?id=%@", self.detailItem.itemID]]];
            if (self.detailItem.url) {
                self.navigationItem.rightBarButtonItem.title = @"Linked Page";
                self.navigationItem.title = @"Comments";
//                [self.browser setCanShowCommentButton:YES];
            } else {
                self.navigationItem.title = @"Post";
                self.navigationItem.rightBarButtonItem = nil;
//                [self.browser setCanShowCommentButton:NO];
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
    _commentList = [SEGCommentListViewController new];
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
    [self configureView];
}

#pragma mark - Browser Delegate Methods

- (NSString *)titleToShare
{
    return self.detailItem.title;
}

- (NSString *)textOnlyHtml {
    NSLog(@"%@", self.detailItem.textView);
    return [self.detailItem.textView copy];
}

@end
