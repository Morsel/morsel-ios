//
//  MRSLWebBrowserViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityIndicatorView.h"
#import "MRSLWebBrowserViewController.h"

@interface MRSLWebBrowserViewController ()
<UIWebViewDelegate>

@property (nonatomic) CGFloat webViewHeight;

@property (weak, nonatomic) IBOutlet MRSLActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UIButton *goForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSURL *url;

@end

@implementation MRSLWebBrowserViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.navigationController.title = self.title ?: @"Web Browser";
    [self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(0.f, 0.f, 60.f, 0.f)];
    self.webViewHeight = [self.webView getHeight];
    self.goBackButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)setTitle:(NSString *)title andURL:(NSURL *)url {
    self.title = title;
    self.url = url;
}

#pragma mark - Private Methods

- (void)displayActivity:(BOOL)shouldDisplay {
    self.refreshButton.enabled = !shouldDisplay;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:shouldDisplay];
    (shouldDisplay) ? [_activityIndicatorView startAnimating] : [_activityIndicatorView stopAnimating];
    self.goBackButton.enabled = [self.webView canGoBack];
    self.goForwardButton.enabled = [self.webView canGoForward];
}

#pragma mark - Action Methods

- (IBAction)goBackInBrowser {
    [self.webView goBack];
}

- (IBAction)goForwardInBrowser {
    [self.webView goForward];
}

- (IBAction)refreshBrowser {
    [self.webView reload];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self displayActivity:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self displayActivity:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self displayActivity:NO];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.webView setHeight:[self.webView getHeight] - keyboardSize.height];
                     }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.webView setHeight:_webViewHeight];
                     }];
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    [_webView setDelegate:nil];
    [_webView stopLoading];
}

@end
