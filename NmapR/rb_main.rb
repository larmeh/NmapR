#
#  rb_main.rb
#  NmapR
#
#  Created by Lars Mehrtens on 06.02.13.
#  Copyright (c) 2013 AWE13. All rights reserved.
#

require 'osx/cocoa'

def rb_main_init
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
end

rb_main_init
