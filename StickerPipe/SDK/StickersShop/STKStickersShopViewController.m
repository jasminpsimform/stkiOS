//
//  STKStickersShopViewController.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/28/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKStickersShopViewController.h"
#import "UIWebView+AFNetworking.h"
#import "STKUtility.h"
#import "STKStickersManager.h"
#import "STKApiKeyManager.h"
#import "STKUUIDManager.h"

#import "STKStickersShopJsInterface.h"

#import <JavaScriptCore/JavaScriptCore.h>

static NSString * const mainUrl = @"http://work.stk.908.vc/api/v1/web?";

@interface STKStickersShopViewController () <UIWebViewDelegate>

@property (nonatomic, strong) STKStickersShopJsInterface *jsInterface;
@end

@implementation STKStickersShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadStickersShop];
}

- (NSURLRequest *)shopRequest {
    NSString *uri = @"http://demo.stickerpipe.com/work/demo/libs/store/js/stickerPipeStore.js";
    
    NSString *urlstr = [NSString stringWithFormat:@"%@uri=%@&apiKey=%@&platform=IOS&userId=%@&density=%@&priceB=0.99%20%24&priceC=1.99%20%24", mainUrl, uri, [STKApiKeyManager apiKey], [STKStickersManager userKey], [STKUtility scaleString]];
    
    NSURL *url =[NSURL URLWithString:urlstr];
   return [NSURLRequest requestWithURL:url];
}

- (void)loadStickersShop {
     [self.stickersShopWebView loadRequest:[self shopRequest] progress:nil success:^NSString * _Nonnull(NSHTTPURLResponse * _Nonnull response, NSString * _Nonnull HTML) {
        return HTML;
    } failure:^(NSError * error) {
        NSLog(@"%@", error.localizedDescription);
        
    }];
}

- (STKStickersShopJsInterface *)jsInterface {
    if (!_jsInterface) {
        _jsInterface = [STKStickersShopJsInterface new];
    }
    return _jsInterface;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebviewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"WEB JS: %@", value);
    }];

    context[@"IosJsInterface"] = self.jsInterface;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}
@end
