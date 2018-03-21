platform :ios, ’10.0’

target 'Flash Chat' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Flash Chat
    pod 'Firebase'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'SwiftyTimer', '~> 2.0'
    pod 'SVProgressHUD'
    pod 'ChameleonFramework'
    pod ‘BluetoothKit’, ‘~> 0.4’
    pod ‘SwiftCharts’, ‘~> 0.6.1’
    pod 'BlueCapKit', '~> 0.6'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end
