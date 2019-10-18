Pod::Spec.new do |spec|
  spec.name         = "MessageRouter"
  spec.version      = "1.0.0"
  spec.summary      = "Lightweight, type-safe message and notification passing broker."
  spec.description  = <<-DESC
  A lightweight, type-safe message and notification passing broker in Swift.
                   DESC
  spec.homepage     = "https://github.com/rob-brown/MessageRouter"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Robert Brown" => "ammoknight@gmail.com" }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/rob-brown/MessageRouter.git", :tag => "#{spec.version}" }
  spec.source_files  = "MessageRouter", "MessageRouter/**/*.{h,m,swift}"
  spec.swift_version = '5.0'
end
