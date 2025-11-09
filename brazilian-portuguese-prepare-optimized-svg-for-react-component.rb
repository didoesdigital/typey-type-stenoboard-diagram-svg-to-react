#!/usr/bin/env ruby

# require 'pry'
require 'fileutils'
require 'nokogiri'

if ARGV.size < 2
  $stderr.puts "Usage: ruby ./brazilian-portuguese-prepare-optimized-svg-for-react-component.rb STENO_LAYOUT.svg STENOLAYOUTStenoDiagram.jsx"
  exit 1
end

SOURCE_SVG = ARGV[0]
TARGET_JS = ARGV[1]

# SKTFPLRAO*-EURWBPGHTSDZ
BRAZILIAN_PORTUGUESE_KEYS = [
"leftSKey", "leftKKey", "leftTKey", "leftFKey", "leftPKey", "leftLKey", "leftRKey", "leftAKey", "leftOKey", "starKey",
# "dashKey",
"rightEKey", "rightUKey", "rightRKey", "rightWKey", "rightBKey", "rightPKey", "rightGKey", "rightHKey", "rightTKey", "rightSKey", "rightDKey", "rightZKey"]

BRAZILIAN_PORTUGUESE_SYMBOLS = [
  "leftS", "leftK", "leftT", "leftF", "leftP", "leftL", "leftR", "leftA", "leftO", "star",
  # "dash",
  "rightE", "rightU", "rightR", "rightW", "rightB", "rightP", "rightG", "rightH", "rightT", "rightS", "rightD", "rightZ"]

brazilian_portuguese_color_config = {}

BRAZILIAN_PORTUGUESE_KEYS.each do | key |
  brazilian_portuguese_color_config["#{key}OnColor"] = "#7109AA"
  brazilian_portuguese_color_config["#{key}OffColor"] = "#E9D9F2"
end

BRAZILIAN_PORTUGUESE_SYMBOLS.each do | key |
  brazilian_portuguese_color_config["#{key}OnColor"] = "#FFFFFF"
  brazilian_portuguese_color_config["#{key}OffColor"] = "#FFFFFF"
end

# SVG_WIDTH = 160
SVG_WIDTH = 140
# SVG_WIDTH = 202


source_svg_basename = File.basename(SOURCE_SVG)
OPTIMIZED_SVG = "./optimized-svgs/#{source_svg_basename}"

if !system "node_modules/.bin/svgo --pretty --config=svgo.config.mjs -i #{SOURCE_SVG} -o #{OPTIMIZED_SVG} > /dev/null"
  exit 1
end

@doc = File.open(OPTIMIZED_SVG) { |f| Nokogiri::XML(f) }

svg = @doc.at_css "svg"
svg["width"] = SVG_WIDTH
svg["viewBox"] = "0 0 215 101"

title = @doc.at_css "title"
# title_content = title.content
title.remove unless title == nil

# if title.content == "brazilian-portuguese-steno" then
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
  rect["stroke"] = "xxx{strokeColorxxx}"

  # steno key fills
  # key_fill = rect["fill"]
  key_fill_var_name_on = rect_id + "OnColor"
  key_fill_var_name_off = rect_id + "OffColor"
  # key_fill_var_value = key_fill
  rect["fill"] = "xxx{this.props." + rect_id + " ? " + key_fill_var_name_on + " : " + key_fill_var_name_off + "xxx}"
  vars.store(key_fill_var_name_on, brazilian_portuguese_color_config[key_fill_var_name_on])
  vars.store(key_fill_var_name_off, brazilian_portuguese_color_config[key_fill_var_name_off])
end



# STENO LETTERS
paths = @doc.css "path"
paths.each do | path |
  path_id = path["id"]

  # steno letter fills
  path["fill"] = "xxx{this.props." + path_id.gsub('Letter','') + " ? onTextColor : offTextColorxxx}"
end

File.open(TARGET_JS, 'w') do |target|
  target.puts @doc.to_html
end

jsx = `node_modules/.bin/svg-to-jsx #{TARGET_JS}`

svgjs = ""

jsx.each_line do |raw_line|
  line = raw_line.rstrip
  if line =~ /<svg (.+)>/i
    line = "<svg " + $1 + " aria-hidden={true}>"
  end
  line = line.gsub(/"xxx{/,"{")
  line = line.gsub(/xxx}"/,"}")
  line = line.gsub(/"xxxstenoboard-xxx/,'{"stenoboard-"')
  line = line.gsub(/	/,"  ")
  line = "      " + line
  svgjs += line + "\n"
end

stroke_color_value = "#7109AA"
stroke_color = "const strokeColor = \"#{stroke_color_value}\";"

File.open(TARGET_JS, 'w') do |target|

  target.puts "import React, { Component } from 'react';"
  target.puts
  target.puts 'const strokeColor = "#7109AA";'
  target.puts 'const onTextColor = "#fff";'
  target.puts 'const offTextColor = "#fff";'

  target.puts

  vars.each do |key, value|
    target.puts "const " + key + " = '" + value + "';"
  end

  target.puts

  target.puts "class " + File.basename(TARGET_JS, ".jsx") + " extends Component {"
  target.puts "  render() {"

  target.puts "    return ("

  target.puts svgjs

  target.puts "    );"
  target.puts "  }"
  target.puts "}"
  target.puts
  target.puts "export default " + File.basename(TARGET_JS, ".jsx") + ";"

end

