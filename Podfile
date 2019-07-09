# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def all_pods
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Alamofire', '4.8.0'
  pod 'Blockstack'
  pod 'Charts'
  pod 'Groot', '3.0.1'
  pod 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord.git', :tag => 'v2.3.3'
  pod 'BiometricAuthentication'
  pod 'SVProgressHUD'
  pod 'QRCodeReader.swift', '~> 10.0.0'
end

target 'Lannister' do
  all_pods
end

target 'Lannister Beta' do
  all_pods
end

target 'LannisterTests' do
    inherit! :search_paths
    # Pods for testing
  end

target 'LannisterUITests' do
  inherit! :search_paths
  # Pods for testing
end