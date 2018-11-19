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
g_id = g["id"]
g["transform"] = "translate(1 1)"
g["id"] = "xxxstenoboard-xxx + this.props.brief xxx}"
# end

vars = {}
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
  fill = rect["fill"]
  fill_var_name_on = rect_id + "OnColor"
  fill_var_name_off = rect_id + "OffColor"
  fill_var_value = fill
  rect["fill"] = "xxx{this.props." + rect_id + " ? " + fill_var_name_on + " : " + fill_var_name_off + "xxx}"
  vars.store(fill_var_name_on, fill_var_value)
  vars.store(fill_var_name_off, fill_var_value)
end
paths = @doc.css "path"
paths.each do | path |
  path_id = path["id"]

  # fills
  fill = path["fill"]
  fill_var_name_on = path_id + "OnTextColor"
  fill_var_name_off = path_id + "OffTextColor"
  fill_var_value = fill
  path["fill"] = "xxx{this.props." + path_id + " ? " + fill_var_name_on + " : " + fill_var_name_off + "xxx}"
  vars.store(fill_var_name_on, fill_var_value)
  vars.store(fill_var_name_off, fill_var_value)
end

File.open(TARGET_JS, 'w:utf-8') do |target|
  target.puts @doc.to_html
end
jsx = `yarn run svg-to-jsx #{TARGET_JS}`

File.open(TARGET_JS, 'w:utf-8') do |target|

  jsx.each_line do |raw_line|
    line = raw_line.rstrip
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

