$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'modules/yui_compressor'
require 'modules/css_parser'
require 'modules/css_tidy'

module CssToolkit
	include YuiCompressor
  VERSION = "1.3"

	def yui_compressor(css, line_length=0)
		yui = Yui.new()
		yui.compress(css, line_length)
	end

	def css_tidy(css, opts={})
		tidy = Tidy.new()
		tidy.tidy(css, line_length)
	end

end