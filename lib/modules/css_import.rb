module CssToolkit

	class Import
		attr_accessor :import

		def initialize(text='')
			@import = text
			self
		end

		def to_s(format=nil)
			"@import #{@import};"
		end

		def optimize(options)
		end
	end
end

