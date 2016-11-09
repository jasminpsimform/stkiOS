//
//  AppDelegate.m
//  StickerFactory
//
//  Created by Vadim Degterev on 25.06.15.
//  Copyright (c) 2015 908. All rights reserved.
//

#import <SSKeychain/SSKeychain.h>
#import "AppDelegate.h"
#import "NSString+MD5.h"
#import "STKChatViewController.h"

@import Stickerpipe;

//demo
NSString* const apiKey = @"72921666b5ff8651f374747bfefaf7b2";

@interface AppDelegate ()

@property (nonatomic, strong) NSDictionary* remoteNotifiInfo;

@end

@implementation AppDelegate

- (NSString*)getUniqueDeviceIdentifierAsString {
	NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey: (NSString*) kCFBundleNameKey];

	NSString* strApplicationUUID = [SSKeychain passwordForService: appName account: @"incoding"];
	if (strApplicationUUID == nil) {
		strApplicationUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
		[SSKeychain setPassword: strApplicationUUID forService: appName account: @"incoding"];
	}

	return strApplicationUUID;
}

- (NSString*)userId {
	NSString* currentDeviceId = [self getUniqueDeviceIdentifierAsString];
	NSString* appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
	return [[currentDeviceId stringByAppendingString: appVersionString] MD5Digest];
}

- (BOOL)application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions {
	// Override point for customization after application launch.
	[STKStickersManager initWithApiKey: apiKey];
	[STKStickersManager setStartTimeInterval];
	[STKStickersManager setUserKey: [self userId]];

	[STKStickersManager setPriceBWithLabel: @"0.99 USD" andValue: 0.99f];
	[STKStickersManager setPriceCwithLabel: @"1.99 USD" andValue: 1.99f];

	[STKStickersManager setUserAsSubscriber: NO];

	[[UIApplication sharedApplication] registerUserNotificationSettings: [UIUserNotificationSettings settingsForTypes: (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories: nil]];
	[[UIApplication sharedApplication] registerForRemoteNotifications];

	self.remoteNotifiInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];

	return YES;
}

- (void)application: (UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken: (NSData*)deviceToken {
	[STKStickersManager sendDeviceToken: deviceToken failure: nil];
}

- (void)application: (UIApplication*)application didFailToRegisterForRemoteNotificationsWithError: (NSError*)error {
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application: (UIApplication*)application didReceiveRemoteNotification: (NSDictionary*)userInfo {
	UINavigationController* nvc = (UINavigationController*) self.window.rootViewController;
	STKChatViewController* vc = (STKChatViewController*) nvc.topViewController;
	[STKStickersManager getUserInfo: userInfo stickerController: vc.stickerController];
}

- (void)checkForNotifications {
	if (self.remoteNotifiInfo) {
		[self application: [UIApplication sharedApplication] didReceiveRemoteNotification: self.remoteNotifiInfo];
	}
}

@end
