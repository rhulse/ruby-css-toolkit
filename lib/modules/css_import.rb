module CssToolkit

	class Import < CssBase
		attr_accessor :import

		def initialize(text='')
			@import = text
			self
		end

		def to_s(format=nil)
			"@import #{@import};"
		end
	end
end

