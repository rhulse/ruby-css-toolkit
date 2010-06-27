

module CssTidy
	class Tidy
		attr_reader :input_size, :output_size

		def initialize
			@parser = Parser.new
		end

		def tidy(css, opts={})
			@input_size = css.length
			options = {
				:downcase_selectors 				=> true,
				:downcase_properties 				=> true,
				:keep_special_comments 			=> true, # comments that start with a !
				:keep_ie5_comment_hack			=> true, # ie5 comment hack => /*\*/ stuff /**/
				:keep_ie7_selector_comments	=> true, # empty comments in selectors => /**/ used for IE7 hack
				:keep_selector_comments			=> false, # other comments in selectors
				:keep_comments							=> false, # any other comments
				:optimize_colors						=> true,
				:optimize_decimals					=> true,
				:optimize_zeros							=> true,
				:optimize_margin_padding		=> true,
				:optimize_filters						=> true,
				:format											=> 0,
			}.merge(opts)

			case options[:format]
			when 1
				format = :multi_line
			else
				format = :one_line
			end

			@stylesheet = @parser.parse(css)
			optimize(options)
			compressed_css = @stylesheet.to_s(format)
			@output_size = compressed_css.length

			compressed_css
		end

		def optimize(options)
			@stylesheet.optimize(options)
		end

	end
end