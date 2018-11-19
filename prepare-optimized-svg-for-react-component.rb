#!/usr/bin/env ruby

require 'fileutils'
if ARGV.size < 2
  $stderr.puts "Usage: ruby ./prepare-optimized-svg-for-react-component.rb STENO_LAYOUT.svg STENOLAYOUTStenoDiagram.js"
  exit 1
end

SOURCE_SVG = ARGV[0]
TARGET_JS = ARGV[1]

File.open(TARGET_JS, 'w:utf-8') do |target|
  File.open(SOURCE_SVG, 'r:utf-8') do |source|

    source.each_line do |raw_line|
      line = raw_line.rstrip
      if line =~ /<svg (.+)>/i
        target.puts "<svg " + $1 + " aria-hidden={hidden}>"
      else
        target.puts line
      end
    end

  end

end
