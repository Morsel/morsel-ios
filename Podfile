platform :ios,'6.0'

inhibit_all_warnings!

xcodeproj 'Morsel/Morsel.xcodeproj'

pod 'AFNetworking', '~> 2.0'
pod 'MagicalRecord', '~> 2.2'
pod 'CocoaLumberjack', '~> 1.6.5.1'
pod 'GCPlaceholderTextView', '1.0.1'
pod 'NullSafe', '~>1.2'
pod 'NSDate+TimeAgo', '~> 1.0.2'
pod 'OAuthCore', '~> 0.0.1'
pod 'Mixpanel', '~> 2.3.1'
pod 'ALAssetsLibrary-CustomPhotoAlbum', '~> 1.1'
pod 'ELCImagePickerController', '~> 0.2'
pod 'SDWebImage', '~> 3.6'
pod 'JLRoutes', '~> 1.5'
pod 'Facebook-iOS-SDK', '~> 3.14'
pod 'AFOAuth1Client', :git => 'https://github.com/Morsel/AFOAuth1Client'
pod 'AFOAuth2Client', :git => 'https://github.com/Morsel/AFOAuth2Client'
pod 'NXOAuth2Client', '~> 1.2'
pod 'XMLDictionary', '~> 1.4'

# Note: 0.1.5 contains a fix for a common crash but has not been released as a cocoapod yet, so point to GitHub instead.
pod 'GPUImage', :git => 'git@github.com:BradLarson/GPUImage.git', :tag => '0.1.5'

# M13Checkbox's podspec on cocoapods incorrectly says iOS7 as the minimum
pod 'M13Checkbox', :git => 'git@github.com:Marxon13/M13Checkbox.git', :commit => '8c3a6f167e0f602dd47928492ef3777e604be66b'

target 'Morsel-Integration' do
	pod 'VCRURLConnection', :git => 'git@github.com:dstnbrkr/VCRURLConnection.git', :commit => 'aa0b0fcf0e112da363e9c63d6215b216ff604614'
	pod 'OHHTTPStubs', '~> 3.1.4'
	pod 'Kiwi-KIF/XCTest', '~>1.0.1'
end

target 'Morsel-Specs' do
	pod 'OHHTTPStubs', '~> 3.1.4'
	pod 'Kiwi/XCTest', :head
end
