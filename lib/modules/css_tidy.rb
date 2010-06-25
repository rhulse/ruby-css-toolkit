

module CssTidy
	class Tidy

		def initialize
			@parser = Parser.new
		end

		def tidy(css, format=:one_line)
			options = {
				:downcase_selectors => true,
				:downcase_properties => true
			}
			@stylesheet = @parser.parse(css)
			optimize(options)
			@stylesheet.to_s(format)
		end

		def optimize(options)
			@stylesheet.optimize
		end

	end
end