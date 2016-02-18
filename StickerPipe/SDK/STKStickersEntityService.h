//
//  STKStickersEntityService.h
//  StickerPipe
//
//  Created by Vadim Degterev on 27.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKStickerPackObject;

@interface STKStickersEntityService : NSObject

@property (nonatomic, strong) NSArray *stickersArray;

- (void)getStickerPacksWithType:(NSString*)type
                 completion:(void(^)(NSArray *stickerPacks))completion
                    failure:(void(^)(NSError *error))failure;

- (void)incrementStickerUsedCountWithID:(NSNumber*)stickerID;

- (void)getStickerPacksIgnoringRecentWithType:(NSString*)type
                                   completion:(void(^)(NSArray *stickerPacks))completion
                                      failure:(void(^)(NSError *error))failre;

- (void) getPackWithMessage:(NSString*)message completion:(void(^)(STKStickerPackObject* stickerPack, BOOL isDownloaded))completion;

- (STKStickerPackObject *)getStickerPackWithName:(NSString *)packName;
- (BOOL)isPackDownloaded:(NSString*)packName;

- (void) saveStickerPack:(STKStickerPackObject*)stickerPack;

- (void) saveStickerPacks:(NSArray*)stickerPacks;

- (void)updateStickerPackInCache:(STKStickerPackObject *)stickerPackObject;

- (void) deleteStickerPack:(STKStickerPackObject*) stickerPack;

- (void) togglePackDisabling:(STKStickerPackObject*)pack;

- (BOOL)hasRecentStickers;
- (BOOL)hasNewPacks;

@end
