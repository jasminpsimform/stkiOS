## About
[![Version](https://cocoapod-badges.herokuapp.com/v/StickerPipe/badge.png)](http://stickerpipe.com)
[![Platform](https://cocoapod-badges.herokuapp.com/p/StickerPipe/badge.png)](http://stickerpipe.com)
[![License](https://cocoapod-badges.herokuapp.com/l/StickerPipe/badge.(png|svg))](http://stickerpipe.com)

**Stickerpipe** is a stickers SDK for iOS

![ios](ios.gif)

## Installation

Get the API key on the [Stickerpipe](http://stickerpipe.com/)

#### Using CocoaPods:
```ruby
use_frameworks!
pod "StickerPipe", "~> 0.3.17"
```
#### or manualy

Add content of Framework folder to your project

## Usage

For import framework to project use:
```objc
@import Stickerpipe
```

### Initializing 

Set API key in your AppDelegate.m 

```objc
[STKStickersManager initWithApiKey:@"API_KEY"];
[STKStickersManager setStartTimeInterval];
```

You can get your own API Key on http://stickerpipe.com to have customized packs set.

### Users

User id required, and need for retrieving stickers packs. Set it to sdk, when you receive user id.

```objc
[STKStickersManager setUserKey:@"USER_ID"];
```

### Presenting

Init STKStickerController and add stickersView like inputView for your UITextView/UITextField. Storing stickerController instance is up to you

```objc
@property (strong, nonatomic) STKStickerController *stickerController;

self.stickerController.textInputView = self.inputTextView;
```

Use delegate method for reciving sticker messages from sticker view controller


```objc
- (void)stickerController:(STKStickerController *)stickerController didSelectStickerWithMessage:(NSString *)message {
    
    //Send sticker message
    
}
```

Sticker image can be displayed in UIImageView by message:
```objc
stk_setStickerWithMessage: placeholder: placeholderColor: progress: completion:
```

Image for sticker can be get by sticker message:
```objc
[self.stickerController.imageManager getImageForStickerMessage:message withProgress:^(NSTimeInterval progress) {
} andCompletion:^(NSError error, UIImage stickerImage) {
    yourImageView.image = stickerImage;
}];
```

Use delegate method to set base controller for presenting modal controllers 

```objc
- (UIViewController *)stickerControllerViewControllerForPresentingModalView {
    return self;
}
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
