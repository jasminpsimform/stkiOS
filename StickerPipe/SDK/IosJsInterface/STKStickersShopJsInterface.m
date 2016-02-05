//
//  IosJsInterface.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/29/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKStickersShopJsInterface.h"
#import "STKStickersConstants.h"
#import "STKStickersApiService.h"
#import "STKStickersConstants.h"

@interface STKStickersShopJsInterface()

@property(nonatomic, strong) STKStickersApiService *apiService;

@end

@implementation STKStickersShopJsInterface

- (id)init {
    self = [super init];
    if (self) {
        self.apiService = [STKStickersApiService new];
    }
    return self;
}

- (void)showCollections {
//    [[NSNotificationCenter defaultCenter] postNotificationName:STKShowStickersCollectionsNotification object:self];
    NSLog(@"showCollections!!!!!!!!!!");
}

- (void)purchasePack:(NSString *)packTitle :(NSString *)packName :(NSString *)packPrice {
    NSLog(@"purchasePack");
    [self.apiService loadStickerPackWithName:packName success:^(id response) {
        [[NSNotificationCenter defaultCenter] postNotificationName:STKStickerPackDownloadedNotification object:self userInfo:@{@"packDict": response[@"data"]}];
        
    } failure:^(NSError *error) {
        
    }];
    
    
}

- (void)setInProgress:(BOOL)show {
    NSLog(@"setInProgress %d", show);
}

@end