//
// Created by Vadim Degterev on 12.08.15.
// Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKShowStickerButton.h"
#import "STKStickersCache.h"
#import "STKStickersNotificationConstants.h"
#import "STKBadgeView.h"

static const CGFloat kBadgeViewPadding = 4.0;

@interface STKShowStickerButton()

@property (nonatomic, strong) STKBadgeView *badgeView;

@end

@implementation STKShowStickerButton

- (void)awakeFromNib {
    
    [self initDotView];
    [self subscribe];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        [self initDotView];
        [self subscribe];
    }

    return self;
}

- (void)subscribe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storageUpdated:) name:STKStickersCacheDidUpdateStickersNotification object:nil];
}

- (void)storageUpdated:(NSNotification*)notification {
    if ([STKStickersCache hasNewStickerPacks]) {
        self.badgeView.hidden = NO;
    } else {
        self.badgeView.hidden = YES;
    }
}


- (void)initDotView {

    self.imageView.contentMode = UIViewContentModeCenter;
    
    self.badgeView = [[STKBadgeView alloc] initWithFrame:CGRectMake(0, 0, 20.0, 20.0) lineWidth:2.5 dotSize:CGSizeMake(4.0, 4.0)];
    self.badgeView.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) - kBadgeViewPadding, CGRectGetMinY(self.imageView.frame) + kBadgeViewPadding);
    [self addSubview:self.badgeView];
    if ([STKStickersCache hasNewStickerPacks]) {
        self.badgeView.hidden = NO;
    } else {
        self.badgeView.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.badgeView.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) - 2.0, CGRectGetMinY(self.imageView.frame) + kBadgeViewPadding);;
}


@end