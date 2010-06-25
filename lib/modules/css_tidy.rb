

module CssTidy
	class Tidy

		def initialize
			@parser = Parser.new
		end

		def tidy(css, format=:one_line)
			stylesheet = @parser.parse(css)
			stylesheet.to_s(format)
		end

	end
end