//
//  STKChatTextTableViewCell.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/14/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKChatTextCell.h"

@implementation STKChatTextCell

- (void)awakeFromNib {
	// Initialization code
}

- (void)setSelected: (BOOL)selected animated: (BOOL)animated {
	[super setSelected: selected animated: animated];

	// Configure the view for the selected state
}

- (void)fillWithTextMessage: (NSString*)message {
	self.textMessage.text = message;
}

@end
