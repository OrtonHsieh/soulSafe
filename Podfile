# Uncomment the next line to define a global platform for your project

platform :ios, '13.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end

# Override Firebase SDK Version
$FirebaseSDKVersion = '10.22.0'

target 'SoulSafe' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SoulSafe
  pod 'GTMSessionFetcher', :modular_headers => true
  pod 'IQKeyboardManagerSwift', '>= 7.0.0'
  pod 'GrowingTextView', '0.7.2'
  pod 'FirebaseCore', '10.0'
  # pod 'FirebaseAuth', '>= 9.6.0'
  # pod 'FirebaseFirestore', '10.0'
  # pod 'FirebaseStorage', '10.15.0'
  pod 'FirebaseAuth', $FirebaseSDKVersion
  pod 'FirebaseStorage', $FirebaseSDKVersion
  pod 'FirebaseFirestore', $FirebaseSDKVersion

  pod 'Kingfisher', '~> 7.0'
  # pod 'FirebaseFirestoreSwift', '> 7.0-beta'
  pod 'FirebaseFirestoreSwift', '10.18.0'
  pod 'CropViewController'

end

