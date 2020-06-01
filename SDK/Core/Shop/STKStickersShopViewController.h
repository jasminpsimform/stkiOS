//
//  STKStickersShopViewController.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/28/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//
#import <WebKit/WebKit.h>

@interface WKWebView(SynchronousEvaluateJavaScript)
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
@end

@implementation WKWebView(SynchronousEvaluateJavaScript)

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    __block NSString *resultString = nil;
    __block BOOL finished = NO;

    [self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];

    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    return resultString;
}
@end


@import UIKit;

@class STKStickersShopViewController;
@class STKStickerPack;

@protocol STKStickersShopViewControllerDelegate <NSObject>
- (void)hideSuggestCollectionViewIfNeeded;

- (void)showKeyboard;

- (void)showStickersCollection;

- (void)packRemoved: (STKStickerPack*)packObject fromController: (STKStickersShopViewController*)shopController;

- (void)showPackWithName: (NSString*)name fromController: (STKStickersShopViewController*)shopController;

- (void)packWithName: (NSString*)packName downloadedFromController: (STKStickersShopViewController*)shopController;

- (void)packPurchasedWithName:(NSString*)packName price:(NSString* )packPrice fromController:(STKStickersShopViewController*)shopController;

@end

@interface STKStickersShopViewController : UIViewController
@property (nonatomic, weak) id <STKStickersShopViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet WKWebView* stickersShopWebView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activity;

@property (nonatomic) NSString* packName;

@end
