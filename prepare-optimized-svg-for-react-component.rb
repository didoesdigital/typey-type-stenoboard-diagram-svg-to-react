#!/usr/bin/env ruby

require 'fileutils'
require 'nokogiri'
if ARGV.size < 2
  $stderr.puts "Usage: ruby ./prepare-optimized-svg-for-react-component.rb STENO_LAYOUT.svg STENOLAYOUTStenoDiagram.js"
  exit 1
end

SOURCE_SVG = ARGV[0]
TARGET_JS = ARGV[1]

@doc = File.open(SOURCE_SVG) { |f| Nokogiri::XML(f) }

svg = @doc.at_css "svg"
svg["aria-hidden"] = "hidden"
svg["width"] = 140

title = @doc.at_css "title"
title_content = title.content
title.remove

# if title.contents == "italian-steno" then
g = @doc.at_css "g"
g["transform"] = "translate(1 1)"
# end

vars = {}
rects = @doc.css "rect"
rects.each do | rect |
  id = rect["id"]
  stroke = rect["stroke"]
  stroke_var_name = id + "StrokeColor"
  stroke_var_value = stroke
  rect["stroke"] = stroke_var_name
  vars.store(stroke_var_name, stroke_var_value)
end
File.open(TARGET_JS, 'w:utf-8') do |target|
  target.puts @doc.to_html
end
