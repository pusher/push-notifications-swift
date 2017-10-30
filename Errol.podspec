Pod::Spec.new do |s|
  s.name             = 'Errol'
  s.version          = '0.0.6'
  s.summary          = 'Errol SDK'
  s.homepage         = 'https://github.com/pusher/errol-ios'
  s.license          = 'MIT'
  s.author           = { "Luka Bratos" => "luka@pusher.com" }
  s.source           = { git: "https://github.com/pusher/errol-ios.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/pusher'

  s.requires_arc = true
  s.source_files = 'Sources/*.swift'

  s.ios.deployment_target = '10.0'
end