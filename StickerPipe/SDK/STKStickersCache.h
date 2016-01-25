//
//  STKStickersDataModel.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKStickerObject, STKStickerPackObject;


@interface STKStickersCache : NSObject

- (void)saveStickerPacks:(NSArray*) stickerPacks;

- (void)saveDisabledStickerPack:(STKStickerPackObject*)stickerPack;

- (void)updateStickerPack:(STKStickerPackObject *)stickerPackObject;

- (void)deleteStickerPacks:(NSArray*) stickerPacks;

- (STKStickerPackObject*)getStickerPackWithPackName:(NSString*)packName;

- (void)getStickerPacksIgnoringRecent:(void(^)(NSArray *stickerPacks))response;

- (void)getStickerPacks:(void(^)(NSArray *stickerPacks))response;

- (STKStickerPackObject*)recentStickerPack;

- (BOOL)isStickerPackDownloaded:(NSString*)packName;

- (BOOL)hasNewStickerPacks;

- (void)incrementUsedCountWithStickerID:(NSNumber*)stickerID;

- (void)markStickerPack:(STKStickerPackObject*)pack disabled:(BOOL)disabled;

@end
