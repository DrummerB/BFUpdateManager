
Pod::Spec.new do |s|


  s.name         = "BFUpdateManager"
  s.version      = "0.1.0"
  s.summary      = "A library to easily manage app updates."
  s.homepage     = "https://github.com/DrummerB/BFUpdateManager"
 
  s.author       = { "Balazs Faludi" => "balazsfaludi@gmail.com" }

  s.source       = { 
    :git => "https://github.com/DrummerB/BFUpdateManager",
    :tag =>  s.version.to_s
  }

  s.source_files  = 'BFUpdateManager/*.{h,m}'
  s.public_header_files = 'BFUpdateManager/BFUpdateManager.h'
  
  s.requires_arc = true


end