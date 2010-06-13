require 'modules/yui_compressor'

module CssToolkit
	include YuiCompressor

	def yui_compressor(css, line_length)
		yui = Yui.new()
		yui.compress(css, line_length)
	end

end