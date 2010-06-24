module CssToolkit

	class Comment
		attr_accessor :text

		def initialize
			@text = ''
		end

		def <<(text)
			@text << text
		end

		def to_s(format=nil)
			"/*#{@text}*/"
		end
	end
end

