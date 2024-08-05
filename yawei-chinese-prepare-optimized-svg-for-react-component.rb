#!/usr/bin/env ruby

# require 'pry'
require 'fileutils'
require 'nokogiri'

if ARGV.size < 2
  $stderr.puts "Usage: ruby ./yawei-chinese-prepare-optimized-svg-for-react-component.rb STENO_LAYOUT.svg STENOLAYOUTStenoDiagram.js"
  exit 1
end

SOURCE_SVG = ARGV[0]
TARGET_JS = ARGV[1]

# #XBDZGWIUNEAO-#XBDZGWIUNEAO
KEYS = ["LeftHashKey", "LeftXKey", "LeftBKey", "LeftDKey", "LeftZKey", "LeftGKey", "LeftWKey", "LeftIKey", "LeftUKey", "LeftNKey", "LeftEKey", "LeftAKey", "LeftOKey", "RightHashKey", "RightXKey", "RightBKey", "RightDKey", "RightZKey", "RightGKey", "RightWKey", "RightIKey", "RightUKey", "RightNKey", "RightEKey", "RightAKey", "RightOKey"]

SYMBOLS = ["LeftHash", "LeftX", "LeftB", "LeftD", "LeftZ", "LeftG", "LeftW", "LeftI", "LeftU", "LeftN", "LeftE", "LeftA", "LeftO", "RightHash", "RightX", "RightB", "RightD", "RightZ", "RightG", "RightW", "RightI", "RightU", "RightN", "RightE", "RightA", "RightO"]

color_config = {}

KEYS.each do | key |
  color_config["#{key}OnColor"] = "#7109AA"
  color_config["#{key}OffColor"] = "#E9D9F2"
end

SYMBOLS.each do | key |
  color_config["#{key}OnColor"] = "#FFFFFF"
  color_config["#{key}OffColor"] = "#FFFFFF"
end

# This is mostly irrelevant in the front end now
SVG_WIDTH = 140

source_svg_basename = File.basename(SOURCE_SVG)
OPTIMIZED_SVG = "./optimized-svgs/#{source_svg_basename}"

if !system "node_modules/.bin/svgo --pretty --config=.svgo.yml -o #{OPTIMIZED_SVG} #{SOURCE_SVG} > /dev/null"
  exit 1
end

@doc = File.open(OPTIMIZED_SVG) { |f| Nokogiri::XML(f) }

svg = @doc.at_css "svg"
svg["width"] = SVG_WIDTH

title = @doc.at_css "title"
# title_content = title.content
title.remove unless title == nil

g = @doc.at_css "g"
# g_id = g["id"]
# Use this to offset Danish diagram and others by 1 pixel
# g["transform"] = "translate(1 1)"
g["id"] = "xxxstenoboard-xxx + this.props.brief xxx}"
# end

vars = {}

# STENO KEYS
rects = @doc.css "rect"
rects.each do | rect |
  rect_id = rect["id"]

  # steno key strokes
  stroke = rect["stroke"]
  stroke_var_name = rect_id + "StrokeColor"
  stroke_var_value = stroke
  rect["stroke"] = "xxx{" + stroke_var_name + "xxx}"
  vars.store(stroke_var_name, stroke_var_value)

  # steno key fills
  # key_fill = rect["fill"]
  key_fill_var_name_on = rect_id + "OnColor"
  key_fill_var_name_off = rect_id + "OffColor"
  # key_fill_var_value = key_fill
  rect["fill"] = "xxx{this.props." + rect_id + " ? " + key_fill_var_name_on + " : " + key_fill_var_name_off + "xxx}"
  vars.store(key_fill_var_name_on, color_config[key_fill_var_name_on])
  vars.store(key_fill_var_name_off, color_config[key_fill_var_name_off])
end



# STENO LETTERS
paths = @doc.css "path"
paths.each do | path |
  path_id = path["id"]

  # steno letter fills
  # letter_fill = path["fill"]
  letter_fill_var_name_on = path_id + "OnColor"
  letter_fill_var_name_off = path_id + "OffColor"
  # letter_fill_var_value = letter_fill
  path["fill"] = "xxx{this.props." + path_id.gsub('Letter','') + " ? " + letter_fill_var_name_on + " : " + letter_fill_var_name_off + "xxx}"
  vars.store(letter_fill_var_name_on, color_config[letter_fill_var_name_on])
  vars.store(letter_fill_var_name_off, color_config[letter_fill_var_name_off])
end

File.open(TARGET_JS, 'w') do |target|
  target.puts @doc.to_html
end

jsx = `node_modules/.bin/svg-to-jsx #{TARGET_JS}`

svgjs = ""

jsx.each_line do |raw_line|
  line = raw_line.rstrip
  if line =~ /<svg (.+)>/i
    line = "<svg id={svgDiagramID} " + $1 + " aria-hidden={true}>"
  end
  line = line.gsub(/"xxx{/,"{")
  line = line.gsub(/xxx}"/,"}")
  line = line.gsub(/"xxxstenoboard-xxx/,'{"stenoboard-"')
  line = line.gsub(/	/,"  ")
  line = "      " + line
  svgjs += line + "\n"
end


File.open(TARGET_JS, 'w') do |target|

  target.puts "import React, { Component } from 'react';"
  target.puts

  vars.each do |key, value|
    target.puts "const " + key + " = '" + value + "';"
  end

  target.puts
  target.puts "class " + File.basename(TARGET_JS, ".js") + " extends Component {"
  target.puts "  render() {"
  target.puts "    const diagramWidth = this.props.diagramWidth || 140;"
  target.puts "    const svgDiagramID = this.props.id || 'stenoDiagram';"
  target.puts
  target.puts "    return ("
  target.puts svgjs

  target.puts "    );"
  target.puts "  }"
  target.puts "}"
  target.puts
  target.puts "export default " + File.basename(TARGET_JS, ".js") + ";"

end

