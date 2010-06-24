module CssToolkit

	class Declaration
		attr_accessor :property, :value

		# sets the values
		# we assume that any extraneous whitespace has been striped
		def initialize(property, value)
			@property = property
			@value = value
		end

		def to_s(format=:one_line)
			unless @property.empty? &&  @value.empty?
				"#{@property}:#{@value};"
			end
		end
	end
end

