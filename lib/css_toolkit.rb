$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'modules/yui_compressor'

module CssToolkit
	include YuiCompressor

	def yui_compressor(css, line_length)
		yui = Yui.new()
		yui.compress(css, line_length)
	end

end