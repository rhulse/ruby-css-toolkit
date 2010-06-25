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

		# special comments start with a ! and should not be deleted
		def is_special?
			text[0,1] == '!'
		end

		# looks for a \ at the end of the comment, indicating
		# that it is a the start of an IE5 hack
		# why anyone is still doing this, is beyond me! :-)
		def is_ie5_hack?
			text[-1,1] == '\\'
		end

		def optimize
		end
	end
end

