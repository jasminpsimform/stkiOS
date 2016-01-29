//
//  IosJsInterface.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/29/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol IosJs <JSExport>

- (void)showCollections;
- (void)purchasePack:(NSString *)packTitle :(NSString *)packName :(NSString *)packPrice;
- (void)setInProgress:(BOOL)show;

@end

@interface IosJsInterface : NSObject <IosJs>

@end
