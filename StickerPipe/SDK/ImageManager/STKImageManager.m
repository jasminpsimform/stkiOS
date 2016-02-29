//
//  STKImageManager.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 2/26/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKImageManager.h"
#import "STKUtility.h"
#import <objc/runtime.h>

//__strong static DFImageTask* imageTask = nil;

@implementation STKImageManager

- (void)getImageForStickerMessage:(NSString *)stickerMessage andDensity:(NSString *)density withProgress:(STKDownloadingProgressBlock)progressBlock andCompletion:(STKCompletionBlock)completion {
   
    NSURL *stickerUrl = [STKUtility imageUrlForStikerMessage:stickerMessage andDensity:density];
    
    DFImageRequestOptions *options = [DFImageRequestOptions new];
    options.allowsClipping = YES;
    options.progressHandler = ^(double progress){
        // Observe progress
        if (progressBlock) {
            progressBlock(progress);
        }
    };
    
    DFImageRequest *request = [DFImageRequest requestWithResource:stickerUrl targetSize:CGSizeZero contentMode:DFImageContentModeAspectFit options:options];
    
    self.imageTask = [[DFImageManager sharedManager] imageTaskForRequest:request completion:^(UIImage *image, NSDictionary *info) {
        NSError *error = info[DFImageInfoErrorKey];
        
        if (completion) {
            completion(error, image);
        }
    }];
    [self.imageTask resume];

}

- (DFImageTask *)imageTask {
    return objc_getAssociatedObject(self, @selector(imageTask));
}

- (void)setImageTask:(DFImageTask *)imageTask {
    objc_setAssociatedObject(self, @selector(imageTask), imageTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelLoading {
    [self.imageTask cancel];
}

@end
