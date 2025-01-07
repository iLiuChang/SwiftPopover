Pod::Spec.new do |s|
  s.name         = "SwiftPopover"
  s.version      = "1.0.0"
  s.summary      = "A simple Popover control in Swift."
  s.homepage     = "https://github.com/iLiuChang/SwiftPopover"
  s.license      = "MIT"
  s.authors      = { "iLiuChang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/iLiuChang/SwiftPopover.git", :tag => s.version }
  s.requires_arc = true
  s.swift_version = "5.0"
  s.source_files = "Source/*.{swift}"
end
