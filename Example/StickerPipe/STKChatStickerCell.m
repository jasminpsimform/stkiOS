//
//  STKChatCell.m
//  StickerFactory
//
//  Created by Vadim Degterev on 03.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKChatStickerCell.h"

@import Stickerpipe;

@implementation STKChatStickerCell

- (void)prepareForReuse {
    [self.stickerImageView stk_cancelStickerLoading];
    self.stickerImageView.image = nil;
    [self.stickerImageView stk_cancelStickerImageLoading:self.stickerImageView];
    
}

- (void) fillWithStickerMessage:(NSString*) message downloaded:(BOOL) downloaded {
    if ([STKStickersManager isStickerMessage:message]) {
        [self.stickerImageView stk_setStickerWithMessage:message placeholder:nil placeholderColor:nil progress:nil completion:nil];
        
    }
    
    UIImage *downloadImage = [UIImage imageNamed:@"STKDownloadIcon"];
    
    UIColor *imageColor = [UIColor colorWithRed:255.0/255.0 green:87.0/255.0 blue:34.0/255.0 alpha:1];
    
    [self.downloadButton setImage:[downloadImage imageWithImageTintColor:imageColor] forState:UIControlStateNormal];
    [self.downloadButton setImage:[downloadImage imageWithImageTintColor:imageColor] forState:UIControlStateHighlighted];
    
    self.downloadButton.hidden = downloaded;
    
}

@end
