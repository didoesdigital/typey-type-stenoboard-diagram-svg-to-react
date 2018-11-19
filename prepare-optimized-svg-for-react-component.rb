#!/usr/bin/env ruby

require 'fileutils'
require 'nokogiri'
if ARGV.size < 2
  $stderr.puts "Usage: ruby ./prepare-optimized-svg-for-react-component.rb STENO_LAYOUT.svg STENOLAYOUTStenoDiagram.js"
  exit 1
end

SOURCE_SVG = ARGV[0]
TARGET_JS = ARGV[1]

ITALIAN_BLACK_KEYS = [
  'leftCapitalF',
  'leftCapitalZ',
  'leftCapitalN',
  'leftCapitalX',
  'eRightLowercase',
  'nRightLowercase',
  'zRightLowercase',
  'fRightLowercase',
]

ITALIAN_WHITE_KEYS = [
  'leftCapitalS',
  'leftCapitalC',
  'leftCapitalP',
  'leftCapitalR',
  'leftCapitalI',
  'leftCapitalU',
  'uRightLowercase',
  'iRightLowercase',
  'aRightLowercase',
  'pRightLowercase',
  'cRightLowercase',
  'sRightLowercase',
]

ITALIAN_BLACK_KEYS_LETTERS = [
  'leftCapitalFLetter',
  'leftCapitalZLetter',
  'leftCapitalNLetter',
  'leftCapitalXLetter',
  'eRightLowercaseLetter',
  'nRightLowercaseLetter',
  'zRightLowercaseLetter',
  'fRightLowercaseLetter',
]

ITALIAN_WHITE_KEYS_LETTERS = [
  'leftCapitalSLetter',
  'leftCapitalCLetter',
  'leftCapitalPLetter',
  'leftCapitalRLetter',
  'leftCapitalILetter',
  'leftCapitalULetter',
  'uRightLowercaseLetter',
  'iRightLowercaseLetter',
  'aRightLowercaseLetter',
  'pRightLowercaseLetter',
  'cRightLowercaseLetter',
  'sRightLowercaseLetter',
]

italian_color_config = {}

ITALIAN_WHITE_KEYS.each do | key |
  italian_color_config["#{key}OnColor"] = "#FFFFFF"
  italian_color_config["#{key}OffColor"] = "#E9D9F2"
end

ITALIAN_BLACK_KEYS.each do | key |
  italian_color_config["#{key}OnColor"] = "#7109AA"
  italian_color_config["#{key}OffColor"] = "#E9D9F2"
end

ITALIAN_WHITE_KEYS_LETTERS.each do | key |
  italian_color_config["#{key}OnColor"] = "#7109AA"
  italian_color_config["#{key}OffColor"] = "#E9D9F2"
end

ITALIAN_BLACK_KEYS_LETTERS.each do | key |
  italian_color_config["#{key}OnColor"] = "#FFFFFF"
  italian_color_config["#{key}OffColor"] = "#E9D9F2"
end

@doc = File.open(SOURCE_SVG) { |f| Nokogiri::XML(f) }

svg = @doc.at_css "svg"
# svg["aria-hidden"] = "xxxhiddenxxx"
svg["width"] = 140

title = @doc.at_css "title"
title_content = title.content
title.remove

# if title.contents == "italian-steno" then
g = @doc.at_css "g"
g_id = g["id"]
# Use this to offset Danish diagram and others by 1 pixel
# g["transform"] = "translate(1 1)"
g["id"] = "xxxstenoboard-xxx + this.props.brief xxx}"
# end

vars = {}

# STENO KEYS
# `<rect id="rightDLower" stroke={strokeColor} fill={this.props.rightDLower ? rightDLowerOnColor : rightDLowerOffColor} x="195" y="48" width="18" height="23" rx="4"/>`
rects = @doc.css "rect"
rects.each do | rect |
  rect_id = rect["id"]

  # strokes
  stroke = rect["stroke"]
  stroke_var_name = rect_id + "StrokeColor"
  stroke_var_value = stroke
  rect["stroke"] = "xxx{" + stroke_var_name + "xxx}"
  vars.store(stroke_var_name, stroke_var_value)

  # fills
  key_fill = rect["fill"]
  key_fill_var_name_on = rect_id + "OnColor"
  key_fill_var_name_off = rect_id + "OffColor"
  key_fill_var_value = key_fill
  rect["fill"] = "xxx{this.props." + rect_id + " ? " + key_fill_var_name_on + " : " + key_fill_var_name_off + "xxx}"
  # if rect_id.include?('CapitalP') then binding.pry end
  vars.store(key_fill_var_name_on, italian_color_config[key_fill_var_name_on])
  vars.store(key_fill_var_name_off, italian_color_config[key_fill_var_name_off])
end

# STENO LETTERS
# <path d="M195 34.2V23h2.816c3.744 0 5.152 2.816 5.152 5.6 0 2.56-1.28 5.6-5.216 5.6H195zm1.904-1.792h1.04c2.288 0 3.04-2.032 3.04-3.808 0-1.888-.832-3.808-2.864-3.808h-1.216v7.616z" id="DUpper" fill={this.props.leftDUpper ? onTextColor : offTextColor}/>
paths = @doc.css "path"
paths.each do | path |
  path_id = path["id"]

  # fills
  letter_fill = path["fill"]
  letter_fill_var_name_on = path_id + "OnColor"
  letter_fill_var_name_off = path_id + "OffColor"
  letter_fill_var_value = letter_fill
  # if path_id.include?('CapitalP') then binding.pry end
  path["fill"] = "xxx{this.props." + path_id.gsub('Letter','') + " ? " + letter_fill_var_name_on + " : " + letter_fill_var_name_off + "xxx}"
  vars.store(letter_fill_var_name_on, italian_color_config[letter_fill_var_name_on])
  vars.store(letter_fill_var_name_off, italian_color_config[letter_fill_var_name_off])
end


# puts @doc.to_html
File.open(TARGET_JS, 'w:utf-8') do |target|
  target.puts @doc.to_html
end

# system './svg-to-jsx'
# system 'svg-to-jsx', 'TARGET_JS'
# system 'yarn', 'run', 'svg-to-jsx', 'TARGET_JS'
jsx = `yarn run svg-to-jsx #{TARGET_JS}`

puts jsx
File.open(TARGET_JS, 'w:utf-8') do |target|

  jsx.each_line do |raw_line|
    line = raw_line.rstrip
    if line =~ /<svg (.+)>/i
      line = "<svg " + $1 + " aria-hidden={hidden}>"
    end
    line = line.gsub(/"xxx{/,"{")
    line = line.gsub(/xxx}"/,"}")
    line = line.gsub(/"xxxstenoboard-xxx/,'{"stenoboard-"')
    line = line.gsub(/	/,"  ")
    line = "      " + line
    target.puts line
  end

end

remove_first_line = `sed -i '' '1d' #{TARGET_JS}`
# yarn run v1.9.4

remove_second_line = `sed -i '' '1d' #{TARGET_JS}`
# $ svg-to-jsx target-js/ItalianMichelaStenoDiagram.js

remove_last_line = `sed -i '' -e '$ d' #{TARGET_JS}`
# Done in 0.31s.

File.open('teft.js', 'w:utf-8') do |target|
  File.open(TARGET_JS, 'r:utf-8') do |reeead|

    target.puts "import React, { Component } from 'react';"
    target.puts ""
    target.puts "class " + File.basename(TARGET_JS, ".js") + " extends Component {"
    target.puts "  render() {"
    target.puts ""
    target.puts "    let hidden = true;"

    vars.each do |key, value|
      target.puts "    let " + key + " = '" + value + "';"
    end

    target.puts ""

    target.puts "    return ("

    reeead.each_line do |raw_line|
      line = raw_line.rstrip
      target.puts raw_line
    end

    target.puts "    );"
    target.puts "  }"
    target.puts "}"
    target.puts ""
    target.puts "export default " + File.basename(TARGET_JS, ".js") + ";"

  end
end
