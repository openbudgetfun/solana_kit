Pod::Spec.new do |s|
  s.name             = 'solana_kit_mobile_wallet_adapter'
  s.version          = '0.0.1'
  s.summary          = 'Solana Mobile Wallet Adapter Flutter plugin (iOS no-op).'
  s.description      = <<-DESC
MWA is Android-only. This iOS plugin compiles but is a no-op.
                       DESC
  s.homepage         = 'https://github.com/anza-xyz/kit'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Solana Kit' => 'kit@solana.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.swift_version = '5.0'
end
