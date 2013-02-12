//
//  SEGMasterViewController.m
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import "SEGMasterViewController.h"

#import "SEGDetailViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <SVPullToRefresh/SVPullToRefresh.h>

#import "SEGMappingProvider.h"

#import "SEGHNItem.h"

@interface SEGMasterViewController () {
    NSArray *_objects;
}
@end

@implementation SEGMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadItems)];
    __weak SEGMasterViewController *weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf loadItems];
    }];
    [self.tableView.pullToRefreshView setTitle:@"Pull to reload..." forState:SVPullToRefreshStateAll];
    [self.tableView.pullToRefreshView setTitle:@"Release to reload..." forState:SVPullToRefreshStateTriggered];

    [self loadItems];
}

- (void)loadItems
{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
        RKMapping *mapping = [SEGMappingProvider newsItemMapping];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                           pathPattern:@"/api.hnsearch.com/items/_search"
                                                                                               keyPath:@"results.item"
                                                                                           statusCodes:statusCodeSet];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][type][]=submission&&weights[title]=1.1&weights[text]=0.7&weights[domain]=2.0&weights[username]=0.1&weights[type]=0.0&boosts[fields][points]=0.15&boosts[fields][num_comments]=0.15&boosts[functions][pow(2,div(div(ms(create_ts,NOW),3600000),72))]=200.0&filter[fields][points]=[10%%20TO%%20*]&limit=100&sortby=create_ts%%20desc"]];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                            responseDescriptors:@[responseDescriptor]];
        [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            _objects = mappingResult.array;
            [self.tableView reloadData];
            [self.tableView.pullToRefreshView stopAnimating];
            [SVProgressHUD showSuccessWithStatus:@"Reloaded!"];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            CLSNSLog(@"ERROR: %@", error);
            CLSNSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
            [self.tableView.pullToRefreshView stopAnimating];
            [SVProgressHUD showErrorWithStatus:@"Download Failed :("];
        }];

        [operation start];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HN Item" forIndexPath:indexPath];

    SEGHNItem *object = _objects[indexPath.row];
    cell.textLabel.text = [object title];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", object.points, object.domain ? ([@": " stringByAppendingString: object.domain]): @""];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [_objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        if ([[segue identifier] isEqualToString:@"Main Detail"]) {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            SEGHNItem *object = _objects[indexPath.row];
            [[segue destinationViewController] setDetailItem:object];
            [[segue destinationViewController] setViewComments:NO];
        } else if ([[segue identifier] isEqualToString:@"Accessory Detail"]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            SEGHNItem *object = _objects[indexPath.row];
            [[segue destinationViewController] setDetailItem:object];
            [[segue destinationViewController] setViewComments:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (!self.dvc) {
            self.dvc = [[SEGDetailViewController alloc] init];
        }
        [(UISplitViewController *)self.parentViewController.parentViewController setViewControllers:@[self.parentViewController, self.dvc]];
        [self clearAllSelectionsInTableView:tableView exceptFor:indexPath];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.dvc setDetailItem:[_objects objectAtIndex:indexPath.row]];
        [self.dvc setViewComments:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (!self.dvc) {
            self.dvc = [[SEGDetailViewController alloc] init];
        }
        [(UISplitViewController *)self.parentViewController.parentViewController setViewControllers:@[self.parentViewController, self.dvc]];
        [self clearAllSelectionsInTableView:tableView exceptFor:indexPath];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.dvc setDetailItem:[_objects objectAtIndex:indexPath.row]];
        [self.dvc setViewComments:NO];
    }
}

- (void)clearAllSelectionsInTableView:(UITableView *)tableView exceptFor:(NSIndexPath *)indexPath
{
    for (NSIndexPath *path in tableView.indexPathsForSelectedRows) {
        if (![path isEqual:indexPath]) {
            [tableView deselectRowAtIndexPath:path animated:NO];
        }
    }
}

@end
