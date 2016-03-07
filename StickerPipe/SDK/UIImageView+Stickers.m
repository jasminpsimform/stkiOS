//
//  UIImageView+Stickers.m
//  StickerFactory
//
//  Created by Vadim Degterev on 24.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "UIImageView+Stickers.h"
#import "STKUtility.h"
#import <objc/runtime.h>
#import "UIImage+Tint.h"
#import "STKStickersManager.h"
#import "DFImageManagerKit.h"

@interface UIImageView()

@property (strong, nonatomic) DFImageTask *imageTask;

@end

@implementation UIImageView (Stickers)

#pragma mark - Builder

- (void) stk_setStickerWithMessage:(NSString *)stickerMessage completion:(STKCompletionBlock)completion {
    
    [self stk_setStickerWithMessage:stickerMessage placeholder:nil placeholderColor:nil progress:nil completion:completion];
    
}


- (void) stk_setStickerWithMessage:(NSString *)stickerMessage placeholder:(UIImage *)placeholder {
    
    [self stk_setStickerWithMessage:stickerMessage placeholder:placeholder placeholderColor:nil progress:nil completion:nil];
}

- (void) stk_setStickerWithMessage:(NSString *)stickerMessage
                   placeholder:(UIImage *)placeholder
                    completion:(STKCompletionBlock)completion
{
    
    [self stk_setStickerWithMessage:stickerMessage placeholder:placeholder placeholderColor:nil progress:nil completion:completion];
}

#pragma mark - Sticker Download

- (void) stk_setStickerWithMessage:(NSString *)stickerMessage
                       placeholder:(UIImage *)placeholder
                  placeholderColor:(UIColor*)placeholderColor
                          progress:(STKDownloadingProgressBlock)progressBlock
                        completion:(STKCompletionBlock)completion {
    
    
    NSURL *stickerUrl = [STKUtility imageUrlForStikerMessage:stickerMessage];
    UIImage *placeholderImage = nil;
    if (!placeholder) {
        UIImage *defaultPlaceholder = [UIImage imageNamed:@"STKStickerPlaceholder"];
        if (placeholderColor) {
            defaultPlaceholder = [defaultPlaceholder imageWithImageTintColor:placeholderColor];
        } else {
            defaultPlaceholder = [defaultPlaceholder imageWithImageTintColor:[STKUtility defaultPlaceholderGrayColor]];
        }
        placeholderImage = defaultPlaceholder;

    } else {
        placeholderImage = placeholder;
    }
    
    self.image = placeholderImage;
    [self setNeedsLayout];
    
    DFImageRequestOptions *options = [DFImageRequestOptions new];
    options.allowsClipping = YES;
    options.progressHandler = ^(double progress){
        // Observe progress
        if (progressBlock) {
            progressBlock(progress);
        }
    };
    
    DFImageRequest *request = [DFImageRequest requestWithResource:stickerUrl targetSize:CGSizeZero contentMode:DFImageContentModeAspectFit options:options];
    
    __weak typeof(self) weakSelf = self;
    
    self.imageTask = [[DFImageManager sharedManager] imageTaskForRequest:request completion:^(UIImage *image, NSDictionary *info) {
        NSError *error = info[DFImageInfoErrorKey];
        
        if (image) {
            weakSelf.image = image;
            [weakSelf setNeedsLayout];
        } else {
            if (error.code != -1) {
                STKLog(@"Failed loading from category: %@", error.localizedDescription);
            }
        }
        
        if (completion) {
            completion(error, image);
        }
    }];
    
    [self.imageTask resume];
    
}

#pragma mark - Properties

- (DFImageTask *)imageTask {
    return objc_getAssociatedObject(self, @selector(imageTask));
}

- (void)setImageTask:(DFImageTask *)imageTask {
     objc_setAssociatedObject(self, @selector(imageTask), imageTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Stop loading

- (void)stk_cancelStickerLoading {
    
    [self.imageTask cancel];
}

@end
