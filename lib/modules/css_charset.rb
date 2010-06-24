module CssToolkit

	class Charset
		attr_accessor :encoding

		# sets the charset to UTF-8 by default
		def initialize
			@encoding = 'UTF-8'
		end

		def <<(charset)
			@encoding = charset
		end

		def to_s(format=:one_line)
			case format
			when :one_line
				%Q{@charset "#{@encoding}";}
			when :multi_line
				%Q{@charset "#{@encoding}";\n}
			end
		end
	end
end

