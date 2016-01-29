//
//  STKApiClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 30.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKApiAbstractService.h"
#import <AFNetworking.h>
#import "STKApiKeyManager.h"
#import "STKUUIDManager.h"
#import "STKStickersManager.h"
#import "STKStickersConstants.h"
#import "NSString+MD5.h"


NSString *const STKApiVersion = @"v1";
//NSString *const STKBaseApiUrl = @"https://api.stickerpipe.com/api";
NSString *const STKBaseApiUrl = @"http://work.stk.908.vc/api";

@implementation STKApiAbstractService

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *baseUrl = [NSString stringWithFormat:@"%@/%@", STKBaseApiUrl, STKApiVersion];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        
        
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        
        [serializer setValue:[self userId] forHTTPHeaderField:@"UserID"];
        [serializer setValue:STKApiVersion forHTTPHeaderField:@"ApiVersion"];
        [serializer setValue:@"iOS" forHTTPHeaderField:@"Platform"];
        [serializer setValue:[STKUUIDManager generatedDeviceToken] forHTTPHeaderField:@"DeviceId"];
        [serializer setValue:[STKApiKeyManager apiKey] forHTTPHeaderField:@"ApiKey"];
        [serializer setValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"Package"];
        [serializer setValue:[self localization] forHTTPHeaderField:@"Localization"];
        
        self.sessionManager.requestSerializer = serializer;
    }
    return self;
}

- (NSString *)localization {
    NSString *locale = [[NSUserDefaults standardUserDefaults]
                        stringForKey:kLocalizationDefaultsKey];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    return (locale) ? locale : language;
}

- (NSString *)userId {
    
    NSString *userKey = [STKStickersManager userKey];
    NSString *hashUserKey = [[userKey stringByAppendingString:[STKApiKeyManager apiKey]] MD5Digest];
    
    return hashUserKey;
}


@end
