//
//  STKShareStickerUtility.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 2/26/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface STKShareStickerUtility : NSObject

+ (STKShareStickerUtility *)sharesInstance;

- (void)sendImage:(UIImage*)image inView:(UIView*)view;

@end
