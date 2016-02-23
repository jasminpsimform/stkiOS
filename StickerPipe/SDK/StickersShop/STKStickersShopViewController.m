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
#import "STKInAppProductsManager.h"
#import "STKUUIDManager.h"
#import "STKStickersConstants.h"
#import "STKStickersApiService.h"
#import "STKPurchaseService.h"
#import "STKStickersPurchaseService.h"
#import "STKStickersEntityService.h"
#import "SKProduct+STKStickerSKProduct.h"
#import "STKStickerPackObject.h"

#import "STKStickersShopJsInterface.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import <StoreKit/StoreKit.h>

static NSString * const mainUrl = @"http://work.stk.908.vc/api/v2/web?";

static NSString * const uri = @"http://demo.stickerpipe.com/work/libs/store/js/stickerPipeStore.js";

@interface STKStickersShopViewController () <UIWebViewDelegate, STKStickersShopJsInterfaceDelegate>

@property(nonatomic, strong) STKStickersShopJsInterface *jsInterface;
@property(nonatomic, strong) STKStickersApiService *apiService;
@property(nonatomic, strong) STKStickersPurchaseService *stickersPurchaseService;
@property(nonatomic, strong) STKStickersEntityService *entityService;

@property(nonatomic, strong) NSMutableArray *prices;

@property(nonatomic, strong) UIAlertController *alertController;

@end

@implementation STKStickersShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.prices = [NSMutableArray new];
    [self loadShopPrices];
    
    [self setUpButtons];
    self.navigationController.navigationBar.tintColor = [STKUtility defaultOrangeColor];
    
    self.jsInterface.delegate = self;
    self.apiService = [STKStickersApiService new];
    
    [self initErrorAlert];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFailed) name:STKPurchaseFailedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseSucceeded:) name:STKPurchaseSucceededNotification object:nil];
}

- (void)packDownloaded {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.reload()"];
    });
}

- (void)loadShopPrices {
    if ([STKInAppProductsManager hasProductIds]) {
        [self.stickersPurchaseService requestProductsWithIdentifier:[STKInAppProductsManager productIds] completion:^(NSArray *stickerPacks) {
            for (SKProduct *product in stickerPacks) {
                [self.prices addObject:[product currencyString]];
            }
            [self loadStickersShop];
        }];
        
    }
    else {
        self.prices =  [[NSMutableArray alloc] initWithArray: @[[STKStickersManager priceBLabel], [STKStickersManager priceCLabel]]];
        [self loadStickersShop];
    }
}

- (NSString *)shopUrlString {
    NSMutableString *urlstr = [NSMutableString stringWithFormat:@"%@&apiKey=%@&platform=IOS&userId=%@&density=%@&priceB=%@&priceC=%@#", mainUrl, [STKApiKeyManager apiKey], [STKStickersManager userKey], [STKUtility scaleString], [self.prices firstObject],
                               [self.prices lastObject]];
    
    if (self.packName) {
        [urlstr appendString:[NSString stringWithFormat:@"/packs/%@", self.packName]];
    } else {
        [urlstr appendString:@"/store"];
    }
    return urlstr;
}
- (NSURLRequest *)shopRequest {
    NSURL *url =[NSURL URLWithString:[self shopUrlString]];
    return [NSURLRequest requestWithURL:url];
}

- (void)loadStickersShop {
    [self setJSContext];
    [self.stickersShopWebView loadRequest:[self shopRequest] progress:nil success:^NSString * _Nonnull(NSHTTPURLResponse * _Nonnull response, NSString * _Nonnull HTML) {
        return HTML;
    } failure:^(NSError * error) {
        [self showError];
    }];
}

- (STKStickersShopJsInterface *)jsInterface {
    if (!_jsInterface) {
        _jsInterface = [STKStickersShopJsInterface new];
    }
    return _jsInterface;
}

- (STKStickersPurchaseService *)stickersPurchaseService {
    if (!_stickersPurchaseService) {
        _stickersPurchaseService = [STKStickersPurchaseService new];
    }
    return _stickersPurchaseService;
}

- (STKStickersEntityService *)entityService {
    if (!_entityService) {
        _entityService = [STKStickersEntityService new];
    }
    return _entityService;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpButtons {
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
    
    self.navigationItem.leftBarButtonItem = closeBarButton;
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"STKSettingsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(showCollections:)];
    self.navigationItem.rightBarButtonItem = settingsButton;
}

- (void)setJSContext {
    
    JSContext *context = [self.stickersShopWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"WEB JS: %@", value);
    }];
    
    context[@"IosJsInterface"] = self.jsInterface;
}

- (void)loadPackWithName:(NSString *)packName andPrice:(NSString *)packPrice {
    __weak typeof(self) wself = self;
    
    [self.apiService loadStickerPackWithName:packName andPricePoint:packPrice success:^(id response) {
        [wself.entityService downloadNewPack:response[@"data"]
                                   onSuccess:^(NSArray *stickerPacks) {
            [wself dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:STKNewPackDownloadedNotification object:self userInfo:@{@"packName": packName, @"stickerPacks": stickerPacks}];
             }];
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Actions

- (IBAction)closeAction:(id)sender {
    
    NSString *currentURL = [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    if ([currentURL isEqualToString:[self shopUrlString]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.goBack()"];
        });
    }
    
}

- (IBAction)showCollections:(id)sender {
    
    [self showCollections];
    
}

#pragma mark - UIWebviewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showError];
}

#pragma mark - STKStickersShopJsInterfaceDelegate

- (void)showCollectionsView {
    
    [self showCollections];
}

- (void)purchasePack:(NSString *)packTitle withName:(NSString *)packName
            andPrice:(NSString *)packPrice {
    
    if ([packPrice isEqualToString:@"A"] || ([packPrice isEqualToString:@"B"] && [STKStickersManager isSubscriber]) || [self.entityService hasPackWithName:packName]) {
        
        [self loadPackWithName:packName andPrice:packPrice];
        
    } else {
        
        if ([STKInAppProductsManager hasProductIds]) {
            [self.stickersPurchaseService purchaseProductWithPackName:packName andPackPrice:packPrice];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:STKPurchasePackNotification object:self userInfo:@{@"packName":packName, @"packPrice":packPrice}];
        }
    }
    
}

- (void)setInProgress:(BOOL)show {
    self.activity.hidden = !show;
}

- (void)removePack:(NSString *)packName {
    
    __weak typeof(self) wself = self;
    
    [self.apiService deleteStickerPackWithName:packName success:^(id response) {
        STKStickerPackObject *stickerPack = [wself.entityService getStickerPackWithName:packName];
        [wself.entityService togglePackDisabling:stickerPack];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:STKStickersReorderStickersNotification object:self];
            [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.reload()"];
        });
    } failure:^(NSError *error) {
        
    }];
}

- (void)showPack:(NSString *)packName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:STKShowPackNotification object:self userInfo:@{@"packName": packName}];
        }];
    });
}

#pragma mark - AlertController

- (void)initErrorAlert {
    self.alertController = [UIAlertController alertControllerWithTitle:@"No internet connection" message:@"Reload?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadStickersShop];
    }];
    [self.alertController addAction:okAction];
}

#pragma mark - Show views

- (void)showError {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        [self presentViewController:self.alertController animated:YES completion:nil];
    }
}

- (void)showCollections {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:STKShowStickersCollectionsNotification object:self];
        }];
    });
}

#pragma mark - purchses

- (void)purchaseSucceeded:(NSNotification *)notification {
    
    NSString *packName = notification.userInfo[@"packName"];
    NSString *packPrice = notification.userInfo[@"packPrice"];
    
    [self loadPackWithName:packName andPrice:packPrice];
}

- (void)purchaseFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.hideActionProgress()"];
    });
}

@end
