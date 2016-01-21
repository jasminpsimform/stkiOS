//
//  STKStickersClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 25.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersManager.h"
#import <DFImageManagerKit.h>
#import "STKUtility.h"
#import "STKAnalyticService.h"
#import "STKApiKeyManager.h"
#import "STKCoreDataService.h"
#import "STKStickersConstants.h"


@interface STKStickersManager()


@end

@implementation STKStickersManager

- (void)getStickerForMessage:(NSString *)message progress:(void (^)(double))progressBlock success:(void (^)(UIImage *))success failure:(void (^)(NSError *, NSString *))failure {
    
    if ([self.class isStickerMessage:message]) {
        NSURL *stickerUrl = [STKUtility imageUrlForStikerMessage:message];
        
        DFImageRequestOptions *options = [DFImageRequestOptions new];
        options.allowsClipping = YES;
        options.progressHandler = ^(double progress){
            // Observe progress
            if (progressBlock) {
                progressBlock(progress);
            }
        };
        
        DFImageRequest *request = [DFImageRequest requestWithResource:stickerUrl targetSize:CGSizeMake(160.f, 160.f) contentMode:DFImageContentModeAspectFit options:options];
                
        DFImageTask *task =[[DFImageManager sharedManager] imageTaskForRequest:request completion:^(UIImage *image, NSDictionary *info) {
            NSError *error = info[DFImageInfoErrorKey];
            if (error) {
                if (failure) {
                    failure(error, error.localizedDescription);
                }
            } else {
                if (success) {
                    success(image);
                }
            }
            
            if (error.code != -1) {
                STKLog(@"Failed loading from category: %@ %@", error.localizedDescription, @"ddd");
            }

        }];
        
        [task resume];
        
    } else {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"It's not a sticker" code:999 userInfo:nil];
            failure(error, @"It's not a sticker");
        }
    }

}

#pragma mark - Validation

+ (BOOL)isStickerMessage:(NSString *)message {
    NSString *regexPattern = @"^\\[\\[[a-zA-Z0-9]+_[a-zA-Z0-9]+\\]\\]$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexPattern];
    
    BOOL isStickerMessage = [predicate evaluateWithObject:message];
    
    return isStickerMessage;
}


#pragma mark - ApiKey

+ (void)initWitApiKey:(NSString *)apiKey {
    [STKApiKeyManager setApiKey:apiKey];
    [STKCoreDataService setupCoreData];
}

#pragma mark - User key

+ (void)setUserKey:(NSString *)userKey {
    [[NSUserDefaults standardUserDefaults] setObject:userKey forKey:kUserKeyDefaultsKey];
}

+ (NSString *)userKey {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserKeyDefaultsKey];
}

#pragma mark - Localization 

+ (void)setLocalization:(NSString *)localization {
    [[NSUserDefaults standardUserDefaults] setObject:localization forKey:kLocalizationDefaultsKey];
}

+ (NSString *)localization {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLocalizationDefaultsKey];
}

#pragma mark - Srart time interval

+ (void)setStartTimeInterval {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:0 forKey:kLastUpdateIntervalKey];
    [defaults synchronize];
}

@end
