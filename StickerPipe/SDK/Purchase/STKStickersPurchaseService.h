//
//  STKStickersPurchaseService.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 2/16/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKStickersPurchaseService : NSObject

- (BOOL) hasInAppProductIds;

- (void)requestProductsWithIdentifier:(NSArray *)productIds
                           completion:(void(^) (NSArray *))completion;

- (void)purchaseProductWithIdentifier:(NSString *)productId packName:(NSString *)packName
                         andPackPrice:(NSString *)packPrice;
@end
