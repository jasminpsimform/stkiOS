//
//  IosJsInterface.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/29/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKStickersShopJsInterface.h"
#import "STKStickersConstants.h"

@implementation STKStickersShopJsInterface

- (void)showCollections {
//    [[NSNotificationCenter defaultCenter] postNotificationName:STKShowStickersCollectionsNotification object:self];
    NSLog(@"showCollections!!!!!!!!!!");
}

- (void)purchasePack:(NSString *)packTitle :(NSString *)packName :(NSString *)packPrice {
    NSLog(@"purchasePack");
    
}

- (void)setInProgress:(BOOL)show {
    NSLog(@"setInProgress %d", show);
}

@end
