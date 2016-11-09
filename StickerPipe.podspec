Pod::Spec.new do |s|

  s.name            = 'StickerPipe'
  s.version         = '0.3.19'
  s.platform        = :ios, '8.0'
  s.summary         = 'Easy stickers SDK for integration in messangers.'
  s.homepage        = "https://github.com/908Inc/stkiOS"
  s.license         = "Apache License, Version 2.0"
  s.author          = "908 Inc."
  s.source          = { :git => 'https://github.com/908Inc/stkiOS.git', :tag => s.version }

  s.vendored_frameworks = 'Stickerpipe/Framework/Stickerpipe.framework'

  s.framework       = 'CoreData'
  s.requires_arc    = true
  s.dependency       'AFNetworking', '~> 3.1.0'
  s.dependency       'DFImageManager', '~> 0.8.0'
  s.dependency       'RMStore', '~> 0.7.1'
  s.dependency       'RMStore/KeychainPersistence'
  s.dependency       'RMStore/NSUserDefaultsPersistence'
  s.dependency       'SDWebImage', '~> 3.8.2'

  s.resource = 'Stickerpipe/Framework/ResBundle.bundle'

  s.module_name = 'Stickerpipe'

end
