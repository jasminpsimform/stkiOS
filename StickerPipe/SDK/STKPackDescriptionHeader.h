//
//  STKStickerPackDescriptionHeader.h
//  StickerPipe
//
//  Created by Vadim Degterev on 29.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKPackDescriptionHeader;

@protocol STKPackDescriptionHeaderDelegate <NSObject>

- (void)packDescriptionHeader:(STKPackDescriptionHeader*)header didTapDownloadButton:(UIButton*)button;

@end

@interface STKPackDescriptionHeader : UICollectionReusableView

@property (weak, nonatomic) id<STKPackDescriptionHeaderDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *packImageView;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *packNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *priceLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end
