//
// Created by Vadim Degterev on 12.08.15.
// Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKShowStickerButton.h"

static const CGFloat kBadgeViewPadding = 4.0;

@interface STKShowStickerButton()

@end

@implementation STKShowStickerButton

- (void)awakeFromNib {
    [self initBadgeView];
}

- (instancetype)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
    if (self) {
        [self initBadgeView];
    }

    return self;
}

- (void)initBadgeView {

    self.imageView.contentMode = UIViewContentModeCenter;
    self.badgeView = [[STKBadgeView alloc] initWithFrame:CGRectMake(0, 0, 20.0, 20.0) lineWidth:2.5 dotSize:CGSizeMake(4.0, 4.0)];
    self.badgeView.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) - kBadgeViewPadding, CGRectGetMinY(self.imageView.frame) + kBadgeViewPadding);
    [self addSubview:self.badgeView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.badgeView.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) - 2.0, CGRectGetMinY(self.imageView.frame) + kBadgeViewPadding);;
}


@end