//
//  STKStickersPurchaseService.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 2/16/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKStickersPurchaseService.h"
#import "STKStickersManager.h"
#import "STKInAppProductsManager.h"

#import <RMStore/RMStore.h>
#import "RMStoreKeychainPersistence.h"

#import "STKStickersConstants.h"

@interface STKStickersPurchaseService() <RMStoreObserver>

@property(nonatomic, strong) RMStoreKeychainPersistence *persistence;

@end


@implementation STKStickersPurchaseService
- (void)configureStore {
    
    _persistence = [[RMStoreKeychainPersistence alloc] init];
    [RMStore defaultStore].transactionPersistor = _persistence;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self configureStore];
    RMStore *store = [RMStore defaultStore];
    [store addStoreObserver:self];
    
    self.persistence = store.transactionPersistor;
    
    return self;
}

- (void)requestProductsWithIdentifier:(NSArray *)productIds
                           completion:(void(^) (NSArray *))completion{
    NSSet *product = [NSSet setWithArray:productIds];
    [[RMStore defaultStore] requestProducts:product success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        completion(products);
        NSLog(@"Products loaded");
    } failure:^(NSError *error) {
        NSLog(@"Something went wrong");
    }];
}

- (void)purchaseProductWithPackName:(NSString *)packName
                       andPackPrice:(NSString *)packPrice {
    
    __weak typeof(self) wself = self;
    
    [[RMStore defaultStore] addPayment:[STKInAppProductsManager productIdWithPackPrice:packPrice] success:^(SKPaymentTransaction *transaction) {
        NSLog(@"purchase complete");
        BOOL consumed = [wself.persistence consumeProductOfIdentifier:
                         [STKInAppProductsManager productIdWithPackPrice:packPrice]];
        
        [wself purchaseSucceedForPack:packName withPrice:packPrice];
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"purchase failed");
        [wself purchaseFailed];
    }];
    
}

#pragma mark - purchases

- (void)purchaseSucceedForPack:(NSString *)packName withPrice:(NSString *)packPrice {
    [[NSNotificationCenter defaultCenter] postNotificationName:STKPurchaseSucceededNotification object:self userInfo:@{@"packName": packName, @"packPrice": packPrice}];
}

- (void)purchaseFailed {
    [[NSNotificationCenter defaultCenter] postNotificationName:STKPurchaseFailedNotification object:self];
}

@end
