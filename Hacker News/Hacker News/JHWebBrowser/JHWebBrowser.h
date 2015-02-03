//
//  MAWebBrowser.h
//
//  Copyright 2012 Josh Hudnall.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <UIKit/UIKit.h>

@protocol JHWebBrowserDelegate

- (NSString *)titleToShare;
- (NSString *)textOnlyHtml;

@end

@interface JHWebBrowser : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate>

@property (nonatomic, readonly) IBOutlet UIWebView *webView;

@property (nonatomic, strong) IBOutlet UIView *titleToolbar;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) IBOutlet UIToolbar *addressToolbar;
@property (nonatomic, strong) IBOutlet UITextField *urlField;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;

@property (nonatomic, getter = isTitleBarVisible) BOOL showTitleBar;
@property (nonatomic, getter = isAddressBarVisible) BOOL showAddressBar;
@property (nonatomic, getter = isToolbarVisible) BOOL showToolbar;
@property (nonatomic) BOOL showDoneButton;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *html;
@property (nonatomic, strong) NSData *data;

@property BOOL textOnlyView;
@property (nonatomic) BOOL canDoTextOnly;
@property (nonatomic) BOOL canShowCommentButton;
@property NSURL *baseUrl;

@property (nonatomic, weak)   NSObject <JHWebBrowserDelegate> *delegate;

@end


#pragma mark - UIToolbar (TTCategory)
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface UIToolbar (JHWebBrowser)

- (void)replaceItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem *)item;

@end


