//
//  STKChatTextTableViewCell.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/14/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKChatTextCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* textMessage;
- (void)fillWithTextMessage: (NSString*)message;

@end
