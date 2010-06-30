module CssToolkit

	class Comment < CssBase
		attr_accessor :text, :printable

		def initialize(text='')
			@text = text
			@printable = true
			self
		end

		def << (text)
			@text << text
		end

		def to_s(format=nil)
			if @printable
				"/*#{@text}*/"
			else
				''
			end
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

		def clear
			@text = ''
			@printable = false
		end
	end
end

