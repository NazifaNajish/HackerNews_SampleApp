//
//  ArticleController.m
//  SampleApp
//
//  Created by Nazifa Najish on 3/15/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import "ArticleController.h"
#import <SVProgressHUD.h>
#import "Helper.h"

@interface ArticleController ()<UIWebViewDelegate> {
    Helper *helperObj;
}
@end

@implementation ArticleController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    helperObj = [[Helper alloc]init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ArticleUrl"] != nil) {
        NSLog(@"Loading URL :%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"ArticleUrl"]);
        self.WebView.delegate = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"ArticleUrl"]]];
        [self.WebView loadRequest:request];
        [SVProgressHUD showWithStatus:@"Loading..."];
    } else {
        [SVProgressHUD showInfoWithStatus:@"No Article"];
        [SVProgressHUD dismissWithDelay:1.0];
    }

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![helperObj NetworkConnection]) {
        [SVProgressHUD showInfoWithStatus:NO_INTERNET];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma - mark UIWebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    return;
}

@end
