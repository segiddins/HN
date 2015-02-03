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

@interface SEGMasterViewController () <UISearchDisplayDelegate> {
    NSArray *_objects;
    NSMutableArray *_searchObjects;
}
@property UISearchBar *searchBar;
@property UISearchDisplayController *searchController;
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
    [self setupSearchBar];
    [self loadItems];
}

- (void)setupSearchBar {
    _searchObjects = [NSMutableArray array];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.tableView.tableHeaderView = self.searchBar;
    
    // scroll just past the search bar initially
    CGPoint offset = CGPointMake(0, self.searchBar.frame.size.height);
    self.tableView.contentOffset = offset;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                              contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    __weak SEGMasterViewController *weakSelf = self;
    [self.searchController.searchResultsTableView addPullToRefreshWithActionHandler:^{
        NSString *term = self.searchController.searchBar.text;
        [weakSelf filterItemsForTerm:term];
    }];
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
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NULL), ^{
//                for (SEGHNItem *item in _objects) {
//                    if (item.url != nil) {
//                        NSURL *toURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.readability.com/api/content/v1/parser?token=c7a7ca94e7e3d9b9da49f8002ab08e6ec14ffea2&url=%@", [item.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//                        NSURLRequest *toRequest = [NSURLRequest requestWithURL:toURL];
//                        AFJSONRequestOperation *textOnlyOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:toRequest
//                                                                                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                                                                                                                        item.textView = [JSON objectForKey:@"content"];
//                                                                                                                    }
//                                                                                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                                                                                                                        CLSNSLog(@"%@", error.debugDescription);
//                                                                                                                    }];
//                        [textOnlyOperation start];
//                    }
//                }
//            });
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            CLSNSLog(@"ERROR: %@", error);
            CLSNSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
            [self.tableView.pullToRefreshView stopAnimating];
            [SVProgressHUD showErrorWithStatus:@"Download Failed :("];
        }];

        [operation start];
    });
}

- (void)loadSearchItems:(NSString *)searchTerm {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
        RKMapping *mapping = [SEGMappingProvider newsItemMapping];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                           pathPattern:@"/api.hnsearch.com/items/_search"
                                                                                               keyPath:@"results.item"
                                                                                           statusCodes:statusCodeSet];
        NSString *q = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][type][]=submission&&weights[title]=1.1&weights[text]=0.7&weights[domain]=2.0&weights[username]=0.1&weights[type]=0.0&boosts[fields][points]=0.15&boosts[fields][num_comments]=0.15&boosts[functions][pow(2,div(div(ms(create_ts,NOW),3600000),72))]=500.0&filter[fields][points]=[10%%20TO%%20*]&limit=100&sortby=create_ts%%20desc&q=%@", q]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                            responseDescriptors:@[responseDescriptor]];
        [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            _searchObjects = [NSMutableArray arrayWithArray:mappingResult.array];
            [self.searchDisplayController.searchResultsTableView reloadData];
            [self.searchDisplayController.searchResultsTableView.pullToRefreshView stopAnimating];
            [SVProgressHUD dismiss];
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NULL), ^{
//                for (SEGHNItem *item in _searchObjects) {
//                    if (item.url != nil) {
//                        NSURL *toURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.readability.com/api/content/v1/parser?token=c7a7ca94e7e3d9b9da49f8002ab08e6ec14ffea2&url=%@", [item.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//                        NSURLRequest *toRequest = [NSURLRequest requestWithURL:toURL];
//                        AFJSONRequestOperation *textOnlyOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:toRequest
//                                                                                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                                                                                                                        item.textView = [JSON objectForKey:@"content"];
//                                                                                                                    }
//                                                                                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                                                                                                                        CLSNSLog(@"%@", error.debugDescription);
//                                                                                                                    }];
//                        [textOnlyOperation start];
//                    }
//                }
//            });
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            CLSNSLog(@"ERROR: %@", error);
            CLSNSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
            [self.searchDisplayController.searchResultsTableView.pullToRefreshView stopAnimating];
            [SVProgressHUD showErrorWithStatus:@"Search Failed :("];
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
    if (tableView == self.tableView) {
        return _objects.count;
    } else {
        return _searchObjects.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HN Item" forIndexPath:indexPath];

    SEGHNItem *object = (tableView == self.tableView) ? _objects[indexPath.row] : _searchObjects[indexPath.row];
    cell.textLabel.text = [object title];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", object.points, object.domain ? ([@": " stringByAppendingString: object.domain]): @""];
    [cell setAccessoryType:object.url ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithWhite:0.510 alpha:.2];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

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
    if (!self.dvc) {
        self.dvc = [[SEGDetailViewController alloc] init];
    }

    [self clearAllSelectionsInTableView:tableView exceptFor:indexPath];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.dvc setDetailItem:(tableView == self.tableView) ? _objects[indexPath.row] : _searchObjects[indexPath.row]];
    [self.dvc setViewComments:NO];
    [self.dvc.detailItem loadTextView];
    if (IS_IPAD) {
        [(UISplitViewController *)self.parentViewController.parentViewController setViewControllers:@[self.parentViewController, self.dvc]];
    } else {
        [self.navigationController pushViewController:self.dvc animated:YES];
    }
    [self hideKeyboard];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.dvc) {
        self.dvc = [[SEGDetailViewController alloc] init];
    }
    
    [self clearAllSelectionsInTableView:tableView exceptFor:indexPath];
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.dvc setDetailItem:(tableView == self.tableView) ? _objects[indexPath.row] : _searchObjects[indexPath.row]];
    [self.dvc setViewComments:YES];
    [self.dvc.detailItem loadTextView];
    [self.dvc.detailItem loadComments];
    if (IS_IPAD) {
        [(UISplitViewController *)self.parentViewController.parentViewController setViewControllers:@[self.parentViewController, self.dvc]];
    } else {
        [self.navigationController pushViewController:self.dvc animated:YES];
    }
    [self hideKeyboard];
}

- (void)clearAllSelectionsInTableView:(UITableView *)tableView exceptFor:(NSIndexPath *)indexPath
{
//    for (NSIndexPath *path in tableView.indexPathsForSelectedRows) {
//        if (![path isEqual:indexPath]) {
//            [tableView deselectRowAtIndexPath:path animated:NO];
//        }
//    }
}

#pragma mark - Search

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterItemsForTerm:searchString];
    return YES;
}

- (void)filterItemsForTerm:(NSString *)term {
    [self loadSearchItems:term];
}

- (void)hideKeyboard {
    [self.searchController.searchBar resignFirstResponder];
}

@end
