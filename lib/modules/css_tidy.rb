

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
				:fix_invalid_colors					=> false,
				:optimize_decimals					=> true,
				:optimize_zeros							=> true,
				:optimize_font_weight				=> true,
				:optimize_margin_padding		=> true,
				:optimize_filters						=> true,
				:optimize_urls							=> true,
				:optimize_selectors					=> false,
				:format											=> 0,
				:line_length								=> 0,
			}.merge(opts)

			@stylesheet = @parser.parse(css)
			optimize(options)

			case options[:format]
			when 1
				format = :multi_line
			else
				format = :one_line
			end

			compressed_css = @stylesheet.to_s(format)

	    if (options[:line_length] > 0 && format == :one_line)
				compressed_css = split_lines(compressed_css, options[:line_length])
			end

			@output_size = compressed_css.length

			compressed_css
		end

		def optimize(options)
			@stylesheet.optimize(options)
		end

		def split_lines(compressed_css, line_length)
			css = compressed_css.clone
      # Some source control tools don't like it when files containing lines longer
      # than, say 8000 characters, are checked in. The linebreak option is used in
      # that case to split long lines after a specific column.
      startIndex = 0
      index = 0
			length = css.length
      while (index < length)
        index += 1
        if (css[index - 1,1] === '}' && index - startIndex > line_length)
          css = css.slice(0, index) + "\n" + css.slice(index, length)
          startIndex = index
        end
      end
			css
		end

	end
end