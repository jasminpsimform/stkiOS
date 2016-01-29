//
//  STKStickersShopViewController.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/28/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKStickersShopViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "UIWebView+AFNetworking.h"
#import "STKUtility.h"
#import "STKStickersManager.h"
#import "STKApiKeyManager.h"
#import "STKUUIDManager.h"

#import "STKStickersShopApiService.h"

@interface STKStickersShopViewController () <UIWebViewDelegate>

@end

@implementation STKStickersShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://api.stickerpipe.com/api/v1/web?"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"v1" forHTTPHeaderField:@"ApiVersion"];
    [request addValue:@"JS" forHTTPHeaderField:@"Platform"];
    [request addValue:[STKApiKeyManager apiKey] forHTTPHeaderField:@"ApiKey"];
    [request addValue:[STKStickersManager userKey] forHTTPHeaderField:@"userId"];
    [request addValue:[STKUtility scaleString] forHTTPHeaderField:@"density"];
    [request addValue:@"UAH9.99" forHTTPHeaderField:@"priceB"];
    [request addValue:@"UAH19.99" forHTTPHeaderField:@"priceC"];


    [self.stickersShopWebView loadRequest:request progress:nil success:^NSString * _Nonnull(NSHTTPURLResponse * _Nonnull response, NSString * _Nonnull HTML) {
        return HTML;
    } failure:^(NSError * error) {
        NSLog(@"%@", error.localizedDescription);

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebviewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}
@end
