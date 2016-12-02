## About
[![Version](https://cocoapod-badges.herokuapp.com/v/StickerPipe/badge.png)](http://stickerpipe.com)
[![Platform](https://cocoapod-badges.herokuapp.com/p/StickerPipe/badge.png)](http://stickerpipe.com)
[![License](https://cocoapod-badges.herokuapp.com/l/StickerPipe/badge.(png|svg))](http://stickerpipe.com)

**Stickerpipe** is a stickers SDK for iOS

![ios](ios.gif)

## Installation

Get the API key on the [Stickerpipe](http://stickerpipe.com/)

#### Using CocoaPods (iOS 8 and later)

```ruby
use_frameworks!
pod "StickerPipe", "~> 0.3.30"
```

#### or manualy (iOS 7 and later)

Add content of Framework folder to your project. You can also get sources from [here](https://github.com/908Inc/stickerpipe-ios-sdk) for low-level customization


## Usage

Import framework with:

swift:
```swift
@import Stickerpipe
```

objC:
```ojbc
#import <Stickerpipe/Stickerpipe.h>
```


### Initializing 

Set API key in your AppDelegate.m 

```objc
[STKStickersManager initWithApiKey:@"API_KEY"];
```

You can get your own API Key on http://stickerpipe.com to have customized packs set.


### Users

User id required, and need for retrieving stickers packs. Set it to sdk, when you receive user id.

```objc
[STKStickersManager setUserKey:@"USER_ID"];
```


### Presenting

Init STKStickerController and add stickersView as inputView for your UITextView/UITextField. Storing stickerController instance is up to you

```objc
@property (strong, nonatomic) STKStickerController *stickerController;

self.stickerController.textInputView = self.inputTextView;
```


### Stickers

Use delegate method for recieving sticker messages from sticker view controller

```objc
- (void)  stickerController:(STKStickerController *)stickerController 
didSelectStickerWithMessage:(NSString *)message;
```

and display it with UIImageView:

```objc
- (void)stk_setStickerWithMessage: (NSString*)stickerMessage
					   completion: (STKCompletionBlock)completion;
```

or just retrieve an image for custom processing with imageManager property:

```objc
- (void)getImageForStickerMessage: (NSString*)stickerMessage 
                     withProgress: (STKDownloadingProgressBlock)progressBlock 
                    andCompletion: (STKCompletionBlock)completion;
```


### Modals

Return your controller from delegate method for presenting modal controllers:

```objc
- (UIViewController*)stickerControllerViewControllerForPresentingModalView;
```


### Push notifications
Register to push notifications in AppDelegate. 

Add 
```objc
[STKStickersManager sendDeviceToken:deviceToken failure:nil];
```
method call to delegate method:
```objc
- (void)application:(UIApplication )application didRegisterForRemoteNotificationsWithDeviceToken:(NSData )deviceToken  
```

Add
```objc
STKStickerController *stickerController = ...
[STKStickersManager getUserInfo:userInfo stickerController:stickerController];
```
method call to delegate method:
```objc
- (void) application:(UIApplication )application didReceiveRemoteNotification:(NSDictionary )userInfo
```


### Suggests

To add suggestions about stickers you should add UICollectionView to appropriate place on you screen, for example above UITextView. Then attach your collection view to STKStickerController

```objc
self.stickerController.suggestCollectionView = self.yourCollectionView;
```
Enable your suggests with showSuggests property

```objc
self.stickerController.showSuggests = YES;
```


### Statistics

To receive correct statistic about number of sent stickers and messages you should call pair of methods textMessageSendStatistic and stickerMessageSendStatistic.

Call textMessageSendStatistic after user send each text message

```objc
- (void)yourTextMessageDidSend {
    [self.stickerController textMessageSendStatistic];
}
```

Call stickerMessageSendStatistic after user send each sticker in delegate method to STKStickerController

```objc
- (void)stickerController:(STKStickerController *)stickerController didSelectStickerWithMessage:(NSString *)message {
    [self.stickerController stickerMessageSendStatistic];
}
```


### Сustomizations

**You can change default placeholders color and shop content color:**


Placeholder in stickers view

```objc
[self.stickerController setColorForStickersPlaceholder:[UIColor redColor]];
```

Placeholder in stickers view header

```objc
[self.stickerController setColorForStickersHeaderPlaceholderColor:[UIColor blueColor]];
```

Shop content color

```objc
[STKStickersManager setShopContentColor:[UIColor greenColor]];
```

## Credits

Add custom Stickers to iMessage with Stickerpipe - http://stickerpipe.com/add-stickers-to-imessage

## Contact

i@stickerpipe.com

## License

Stickerpipe is available under the Apache 2 license. See the [LICENSE](LICENSE) file for more information.
