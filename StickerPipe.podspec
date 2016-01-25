
Pod::Spec.new do |s|

  s.name            = 'StickerPipe'
  s.version         = '2.0-beta1'
  s.platform        = :ios, '7.0'
  s.summary         = 'Easy stickers SDK for integration in messangers.'
  s.homepage        = "https://github.com/908Inc/stkiOS"
  s.license         = "Apache License, Version 2.0"
  s.author          = "908 Inc."
  s.source          = { :git => 'https://github.com/908Inc/stkiOS.git', :tag => s.version }
  s.source_files    = "StickerPipe/SDK/*.{h,m}"
  s.framework       = 'CoreData'
  s.requires_arc    = true
  s.dependency       'AFNetworking', '~> 2.0'
  s.dependency       'GoogleAnalytics', '~> 3.0'
  s.dependency       'DFImageManager', '~> 0.5.0'
  s.dependency       'Fabric'
  s.dependency       'Crashlytics'
  s.dependency       'MD5Digest', '~> 1.1'
  s.resources       = ['StickerPipe/SDK/Media.xcassets', 'StickerPipe/SDK/*.{xcdatamodeld}','StickerPipe/SDK/StickerPipe.xcassets']

end
