Pod::Spec.new do |s|
  s.name             = 'BeamsChatkit'
  s.version          = '1.2.0'
  s.summary          = 'BeamsChatkit SDK'
  s.homepage         = 'https://github.com/pusher/beams-chatkit-swift'
  s.license          = 'MIT'
  s.author           = { "Luka Bratos" => "luka@pusher.com" }
  s.source           = { git: "https://github.com/pusher/beams-chakit-swift.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/pusher'
  s.documentation_url = 'https://pusher.github.io/push-notifications-swift/Classes/PushNotifications.html'

  s.requires_arc = true
  s.source_files = 'Sources/*.swift'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'
end
