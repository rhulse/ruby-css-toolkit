

module CssTidy
	class Tidy
		attr_reader :input_size, :output_size

		def initialize
			@parser = Parser.new
		end

		def tidy(css, format=:one_line)
			@input_size = css.length
			options = {
				:downcase_selectors => true,
				:downcase_properties => true
			}
			@stylesheet = @parser.parse(css)
			optimize(options)
			compressed_css = @stylesheet.to_s(format)
			@output_size = compressed_css.length
			compressed_css
		end

		def optimize(options)
			@stylesheet.optimize
		end

	end
end