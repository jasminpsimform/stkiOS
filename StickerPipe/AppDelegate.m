//
//  AppDelegate.m
//  StickerFactory
//
//  Created by Vadim Degterev on 25.06.15.
//  Copyright (c) 2015 908. All rights reserved.
//

#import "AppDelegate.h"
#import "STKStickersManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "NSString+MD5.h"
#import <SSKeychain/SSKeychain.h>

//demo
NSString *const apiKey = @"72921666b5ff8651f374747bfefaf7b2";

//test
//NSString *const testIOSKey = @"f06190d9d63cd2f4e7b124612f63c56c";

//for push
NSString *const testIOSKey = @"dced537bd6796e0e6dc31b8e79485c6a";

@interface AppDelegate ()

@end

@implementation AppDelegate

-(NSString *)getUniqueDeviceIdentifierAsString
{
    
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    
    return strApplicationUUID;
}

- (NSString *)userId {
    
    NSString  *currentDeviceId = [self getUniqueDeviceIdentifierAsString];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [[currentDeviceId stringByAppendingString:appVersionString] MD5Digest];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    [Fabric with:@[[Crashlytics class]]];
    [Crashlytics startWithAPIKey:@"0c5dc9cc90ca8deb6e4e375e9d1fbcc76d193c10"];
    [CrashlyticsKit setUserIdentifier:[self userId]];
    
    [STKStickersManager initWitApiKey: apiKey];
    [STKStickersManager setStartTimeInterval];
    [STKStickersManager setUserKey:[self userId]];
    
//    [STKStickersManager setPriceBProductId:@"com.priceB.stickerPipe" andPriceCProductId:@"com.priceC.stickerPipe"];
    [STKStickersManager setPriceBWithLabel:@"0.99 USD" andValue:0.99f];
    [STKStickersManager setPriceCwithLabel:@"1.99 USD" andValue:1.99f];
    
    [STKStickersManager setUserIsSubscriber:NO];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken  {
    [STKStickersManager sendDeviceToken:deviceToken failure:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [STKStickersManager getUserInfo:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
