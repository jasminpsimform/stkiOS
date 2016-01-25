//
//  STKStickerPackDescriptionHeader.m
//  StickerPipe
//
//  Created by Vadim Degterev on 29.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKPackDescriptionHeader.h"

static NSString* const kDownloadedTitle = @"Downloaded";
static NSString* const kRemoveTitle = @"Remove";

@implementation STKPackDescriptionHeader

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (IBAction)downloadButtonAction:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(packDescriptionHeader:didTapDownloadButton:)]) {
        [self.delegate packDescriptionHeader:self didTapDownloadButton:sender];
    }
}

@end
