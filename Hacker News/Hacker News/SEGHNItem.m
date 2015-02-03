//
//  SEGHNItem.m
//  Hacker News
//
//  Created by Samuel E. Giddins on 2/9/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import "SEGHNItem.h"
#import <RestKit/RestKit.h>
#import "SEGMappingProvider.h"
#import "NSString+GTMNSString_HTML_h.h"

#define READABILITY_TOKEN @"c7a7ca94e7e3d9b9da49f8002ab08e6ec14ffea2"

@implementation SEGHNItem

- (void) loadTextView {
    if (self.url != nil && _textView == nil) {
//        NSURL *toURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.thequeue.org/v1/clear?url=%@&format=json", [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NSURL *toURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://readability.com/api/content/v1/parser?url=%@&token=%@", [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], READABILITY_TOKEN]];
        NSURLRequest *toRequest = [NSURLRequest requestWithURL:toURL];
        AFJSONRequestOperation *textOnlyOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:toRequest
                                                                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                                                                                                        NSDictionary *itemDict = [JSON objectForKey:@"item"];
//                                                                                                        NSString *path = [[NSBundle mainBundle] bundlePath];
//                                                                                                        NSString *css = [NSString stringWithFormat:@"<link rel=\"stylesheet\" href=\"%@/reset.css\" type=\"text/css\"><link rel=\"stylesheet\" href=\"%@/typography.css\" type=\"text/css\">", path, path];
//                                                                                                        self.textView = [[NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>",css, itemDict[@"description"]] gtm_stringByUnescapingFromHTML];
//                                                                                                        NSLog(@"JSON: %@", JSON);
//                                                                                                        NSLog(@"textView: %@", self.textView);
                                                                                                        self.textView = [JSON objectForKey:@"content"];
                                                                                                    }
                                                                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                        CLSNSLog(@"%@", error.debugDescription);
                                                                                                    }];
        [textOnlyOperation start];
    }
}

- (void) loadComments {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
        RKMapping *mapping = [SEGMappingProvider commentMapping];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                           pathPattern:@"/api.hnsearch.com/items/_search"
                                                                                               keyPath:@"results.item"
                                                                                           statusCodes:statusCodeSet];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][type][]=comment&filter[fields][discussion.sigid][]=%@&sortby=create_ts%%20asc&limit=100", _sigid]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                            responseDescriptors:@[responseDescriptor]];
        [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            self.comments = [NSMutableArray arrayWithArray:[mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSDate *c1date = [(SEGHNComment *)obj1 create_ts];
                NSDate *c2date = [(SEGHNComment *)obj2 create_ts];
                return [c1date compare:c2date];
            }]];
            NSNotification *notification = [NSNotification notificationWithName:@"Comments Loaded" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            NSLog(@"posted notification: %@", notification);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            CLSNSLog(@"ERROR: %@", error);
            CLSNSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        }];
        [operation start];
    });
}

- (void)setComments:(NSArray *)comments {
    _comments = [NSMutableArray arrayWithArray:comments];
    _commentCount = _comments.count;
    for (SEGHNComment *comment in _comments) {
        for (SEGHNComment *nestedComment in _comments) {
            if ([comment.parentSigid isEqualToString:nestedComment.sigid]) {
                comment.parent = nestedComment;
            }
        }
    }
}

- (SEGHNComment *)commentForIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (index >= _commentCount) {
        return nil;
    } else if (index >= self.comments.count) {
        return nil;
    } else {
        return self.comments[index];
    }
}

@end
