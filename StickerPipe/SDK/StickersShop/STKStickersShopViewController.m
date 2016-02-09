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
#import "STKStickersConstants.h"
#import "STKStickersApiService.h"


#import "STKStickersShopJsInterface.h"

#import <JavaScriptCore/JavaScriptCore.h>

static NSString * const mainUrl = @"http://work.stk.908.vc/api/v1/web?";

static NSString * const uri = @"http://demo.stickerpipe.com/work/libs/store/js/stickerPipeStore.js";

@interface STKStickersShopViewController () <UIWebViewDelegate, STKStickersShopJsInterfaceDelegate>

@property (nonatomic, strong) STKStickersShopJsInterface *jsInterface;
@property(nonatomic, strong) STKStickersApiService *apiService;

@end

@implementation STKStickersShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadStickersShop];
    [self setUpButtons];
    self.navigationController.navigationBar.tintColor = [STKUtility defaultOrangeColor];
    
    self.jsInterface.delegate = self;
    self.apiService = [STKStickersApiService new];
}

- (void)packDownloaded {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.onPackDownloaded()"];
        [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.reload()"];
    });
}

- (NSURLRequest *)shopRequest {
    
    NSString *urlstr = [NSString stringWithFormat:@"%@uri=%@&apiKey=%@&platform=IOS&userId=%@&density=%@&priceB=0.99&priceC=1.99", mainUrl, uri, [STKApiKeyManager apiKey], [STKStickersManager userKey], [STKUtility scaleString]];
    
    NSURL *url =[NSURL URLWithString:urlstr];
    return [NSURLRequest requestWithURL:url];
}

- (void)loadStickersShop {
    [self setJSContext];
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

- (void)setUpButtons {
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
    
    self.navigationItem.leftBarButtonItem = closeBarButton;
}

- (void)setJSContext {
    
    JSContext *context = [self.stickersShopWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"WEB JS: %@", value);
    }];
    
    context[@"IosJsInterface"] = self.jsInterface;
}

#pragma mark - Actions

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebviewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"webview load fail!!!!");
}

#pragma mark - STKStickersShopJsInterfaceDelegate

- (void)showCollectionsView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:STKShowStickersCollectionsNotification object:self];
        }];
    });
}

- (void)purchasePack:(NSString *)packTitle withName:(NSString *)packName andPrice:(NSString *)packPrice {
    __weak typeof(self) wself = self;
    
    [self.apiService loadStickerPackWithName:packName success:^(id response) {
        [[NSNotificationCenter defaultCenter] postNotificationName:STKStickerPackDownloadedNotification object:self userInfo:@{@"packDict": response[@"data"]}];
        [wself packDownloaded];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)setInProgress:(BOOL)show {
    self.activity.hidden = !show;
}
@end
