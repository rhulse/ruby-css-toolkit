module CssToolkit

	class Comment
		attr_accessor :text

		def initialize(text='')
			@text = text
			self
		end

		def <<(text)
			@text << text
		end

		def to_s(format=nil)
			"/*#{@text}*/"
		end

		def optimize
		end
	end
end

