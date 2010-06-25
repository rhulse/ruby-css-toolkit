

module CssTidy
	class Tidy

		def initialize
			@parser = Parser.new
		end

		def tidy(css)
			stylesheet = @parser.parse(css)
			stylesheet.to_s
		end

	end
end