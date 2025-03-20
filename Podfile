# Uncomment the next line to define a global platform for your project
platform :ios, '14.3'

target 'My Demo App' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for My Demo App

  pod 'TestFairy', '1.30.1'
  pod 'FormTextField', '3.1.0'
  pod 'EasyTipView', '2.1.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
            config.build_settings['GCC_GENERATE_DEBUGGING_SYMBOLS'] = 'YES'
            config.build_settings['STRIP_SWIFT_SYMBOLS'] = 'NO'
        end
    end

    installer.aggregate_targets.each do |target|
        target.xcconfigs.each do |config_name, config_file|
            config_file.attributes['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
            config_file.attributes['STRIP_SWIFT_SYMBOLS'] = 'NO'
        end
    end

    installer.pods_project.build_configurations.each do |config|
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
        config.build_settings['STRIP_SWIFT_SYMBOLS'] = 'NO'
    end
end



