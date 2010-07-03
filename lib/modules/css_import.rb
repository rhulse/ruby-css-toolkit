module CssTidy

	class Import < CssBase
		attr_accessor :import

		def initialize(text='')
			@import = text
			self
		end

		def to_s(format=nil)
			unless @import.empty?
				"@import #{@import};"
			else
				''
			end
		end

		def clear
			@import = ''
		end
	end
end

