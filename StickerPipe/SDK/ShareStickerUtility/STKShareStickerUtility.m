//
//  STKShareStickerUtility.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 2/26/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKShareStickerUtility.h"

__strong static STKShareStickerUtility* instanceOf = nil;

@interface STKShareStickerUtility () <UIDocumentInteractionControllerDelegate>

@property (retain) UIDocumentInteractionController *documentInteractionController;

@end

@implementation STKShareStickerUtility


+ (STKShareStickerUtility *)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceOf = [[STKShareStickerUtility alloc] init];
    });
    
    return instanceOf;
}
- (BOOL)isWhatsAppInstalled {
    
    return [[UIApplication sharedApplication] canOpenURL:
            [NSURL URLWithString:@"whatsapp://app"]];
}

- (void)sendImage:(UIImage*)image inView:(UIView*)view
{
    if ( [self isWhatsAppInstalled] )
    {
        NSError *error = nil;
        NSURL	*documentURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
        if (!documentURL){
            [self alertError:[NSString stringWithFormat:@"Error getting document directory: %@", error]];
            return;
        }
        
        NSURL	*tempFile	= [documentURL URLByAppendingPathComponent:@"whatsAppTmp.wai"];
        NSData	*imageData	= UIImageJPEGRepresentation(image, 1.0);
        
        if (![imageData writeToURL:tempFile options:NSDataWritingAtomic error:&error]){
            [self alertError:[NSString stringWithFormat:@"Error writing File: %@", error]];
            return;
        }
        
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:tempFile];
        self.documentInteractionController.UTI		= @"net.whatsapp.image";
        self.documentInteractionController.delegate	= self;
        
        [self.documentInteractionController presentOpenInMenuFromRect:view.frame inView:view animated:YES];
        
    } else {
        [self alertWhatsappNotInstalled];
    }
}

#pragma mark - Alert helper

- (void)alertWhatsappNotInstalled {
    [[[UIAlertView alloc] initWithTitle:@"Error." message:@"Your device has no WhatsApp installed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)alertError:(NSString*)message {
    [[[UIAlertView alloc] initWithTitle:@"Error." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}



@end
