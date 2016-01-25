//
//  STKPacksDescriptionController.h
//  StickerPipe
//
//  Created by Vadim Degterev on 29.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKPackDescriptionController;

@protocol STKPackDescriptionControllerDelegate <NSObject>

- (void) packDescriptionControllerDidChangePakcStatus:(STKPackDescriptionController*)controller;

@end

@interface STKPackDescriptionController : UIViewController

@property (strong, nonatomic) NSString *stickerMessage;

@property (weak, nonatomic) id<STKPackDescriptionControllerDelegate> delegate;

@end
