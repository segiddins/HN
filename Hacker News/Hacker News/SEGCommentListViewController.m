//
//  SEGCommentListViewController.m
//  Hacker News
//
//  Created by Samuel E. Giddins on 3/23/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import "SEGCommentListViewController.h"
#import "SEGHNComment.h"
#import "SEGCommentCell.h"
#import "SEGDetailViewController.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "NSString+HTML.h"

@interface SEGCommentListViewController ()

@property NSMutableArray *rowHeight;

@end

@implementation SEGCommentListViewController {
    BOOL allHeightsSet;

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setHnItem:(SEGHNItem *)hnItem {
    _hnItem = hnItem;
    _rowHeight = [NSMutableArray array];
    for (int i = 0; i < hnItem.comments.count; i++) {
        _rowHeight[i] = @(60.3f);
    }
    allHeightsSet = NO;
    [self.tableView reloadData];
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.rightBarButtonItem.action = @selector(removeSelf:);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"adding observer");
    [[NSNotificationCenter defaultCenter] addObserverForName:@"Comments Loaded" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"revieced note: %@", note);
        if (note.object == self.hnItem) {
            self.hnItem = note.object;
        }
    }];
    
    [self.tableView registerClass:SEGCommentCell.class forCellReuseIdentifier:@"HN Comment Cell"];
    __weak SEGCommentListViewController *weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf.hnItem loadComments];
    }];
    [self.tableView.pullToRefreshView setTitle:@"Pull to reload..." forState:SVPullToRefreshStateAll];
    [self.tableView.pullToRefreshView setTitle:@"Release to reload..." forState:SVPullToRefreshStateTriggered];
    
    [self.tableView setAllowsSelection:NO];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)removeSelf:(id)sender {
    UINavigationController *nc = self.navigationController;
    [self.navigationController popViewControllerAnimated:YES];
    [(SEGDetailViewController *)nc.topViewController setViewComments:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.hnItem.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HN Comment Cell";
    SEGCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SEGHNComment *comment = [self.hnItem commentForIndexPath:indexPath];
    
    
    // Configure the cell...
    cell.usernameLabel.text = comment.username;
    [cell setCommentText:comment.commentText];
    
    self.rowHeight[indexPath.row] = @(cell.realHeight);
    if (!allHeightsSet && ![self.rowHeight[indexPath.row] isEqualToNumber:@(60.3f)]) {
//        [tableView beginUpdates];
//        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        [tableView endUpdates];
    }
    allHeightsSet = (indexPath.row == [tableView numberOfRowsInSection:0]) ? YES : NO;
    
    cell.indentationLevel = [comment nestedLevel];
    NSLog(@"indentation level at row %d is %d", indexPath.row, cell.indentationLevel);
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row < self.rowHeight.count) {
//        height = [self.rowHeight[indexPath.row] floatValue];
//    }
//    height = (height == 60.3f) ? 60.0f : height;
//    NSLog(@"username: %@\nrow: %d\theight: %f",[self.hnItem.comments[indexPath.row] username], indexPath.row, height);
    const CGFloat VerticalMargin = 4;
    SEGHNComment *comment = [self.hnItem commentForIndexPath:indexPath];
    
    CGFloat y = VerticalMargin;
    CGSize textSize = [comment.username sizeWithFont:[UIFont boldSystemFontOfSize:16]];
    CGFloat height = textSize.height;
    
    y += height + VerticalMargin;
    textSize = [[comment.commentText stringByConvertingHTMLToPlainText] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.view.frame.size.width - (60 + 25 * [comment nestedLevel]), 2000) lineBreakMode:NSLineBreakByWordWrapping];
    height = textSize.height;
    
    NSLog(@"row %d commentText: %@", indexPath.row, [comment.commentText stringByConvertingHTMLToPlainText]);
    
    height += y + 2*VerticalMargin;
    
    NSLog(@"row %d height %f", indexPath.row, height);
    return height;
}

@end
