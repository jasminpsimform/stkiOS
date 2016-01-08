//
//  STKStickerController.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STKStickersNotificationConstants.h"

@class STKStickerController;

@protocol STKStickerControllerDelegate <NSObject>

@required
- (void)stickerController:(STKStickerController*)stickerController didSelectStickerWithMessage:(NSString*)message;

//View controller for presenting modal controllers
- (UIViewController*)stickerControllerViewControllerForPresentingModalView;

@optional

- (void)stickerControllerDidChangePackStatus:(STKStickerController*)stickerController;

@end

@interface STKStickerController : NSObject

@property (weak, nonatomic) id<STKStickerControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *stickersView;

@property (nonatomic, assign, readonly) BOOL isStickerViewShowed;

@property (nonatomic, strong) UIColor *headerBackgroundColor;

@property (nonatomic, strong) UITextView *textInputView;


//@property (nonatomic, strong) UIColor *stickersShopTintColor;


- (void)reloadStickersView;

- (BOOL)isStickerPackDownloaded:(NSString*)packMessage;

- (void)showPackInfoControllerWithStickerMessage:(NSString*)message;

//Color settings. Default is light gray

- (void)setColorForStickersPlaceholder:(UIColor*) color;

- (void)setColorForStickersHeaderPlaceholderColor:(UIColor*) color;



@end
