$:.unshift File.dirname(__FILE__)
require 'css_properties'
require 'css_misc'
require 'css_base'
require 'css_stylesheet'
require 'css_rule_set'
require 'css_media_set'
require 'css_declaration'
require 'css_comment'
require 'css_import'

module CssTidy

	class Parser
		# these are used to poke values in for testing instance methods
		attr_accessor :css, :index, :sheet

		# setup the class vars used by Tidy
		def initialize

			# temporary array to hold data during development
			@stylesheet = CssToolkit::StyleSheet.new

			# the raw, unprocessed css
			@raw_css = ''

			# the string that is being processed
			@css = ''

			# the current position in the string
			@index = 0

			# the current parser context. i.e where we are in the CSS
			@context = [NONE, IN_SELECTOR]

			# the current line number
			@line_number = 1
		end

		def parse(css)
			css_length = css.length
			@css = css.clone

			# vars used in processing of sheets
			current_at_block = ''
			invalid_at = false
			invalid_at_name = ''

			current_selector = ''
			current_property = ''
			current_ruleset = CssToolkit::RuleSet.new

			current_value = ''
			sub_value = ''
			sub_value_array = []

			current_string = ''
			string_char = ''
			str_in_str = false

			current_comment = ''

			while @index < css_length

				if is_newline?
					@line_number += 1
				end
				case @context.last
				when IN_AT_BLOCK
					if is_token?
						# current_at_block empty? allows comment inside of selectors to pass
						if is_comment? && current_at_block.strip.empty?
							@context << IN_COMMENT
							@index += 1 # move past '*'
						elsif is_current_char? '{'
							@context << IN_SELECTOR
						elsif is_current_char? ','
							current_at_block = current_at_block.strip + ','
						elsif is_current_char? ['(',')',':','/','*','!','\\']
							# catch media queries and escapes
	          	current_at_block << current_char
						end # of is_comment
					else # not token
						if(! ( (is_char_ctype?(:space, current_at_block[-1,1]) || is_char_token?(current_at_block[-1,1]) && current_at_block[-1,1] == ',') && is_ctype?(:space) ))
	          	current_at_block << current_char
	          end
					end

				when IN_SELECTOR
          if is_token?
						# current_selector empty? allows comment inside of selectors to pass
						if is_comment? && current_selector.strip.empty?
							@context << IN_COMMENT
							@index += 1
	       		elsif is_current_char?('@') && current_selector.strip.empty?
	            # Check for at-rule
	            invalid_at = true
							AT_RULES.each do |name, type|
								size_of_property = name.length
								# look ahead for the name
								property_to_find = (@css[@index+1,size_of_property]).strip.downcase
								if name == property_to_find
									if type == IN_AT_BLOCK
										current_at_block = '@' + name
									else
										current_selector = '@' + name
									end
									@context << type
									@index += size_of_property
									invalid_at = false
								end
	            end

							if invalid_at
	              current_selector = '@'
	              invalid_at_name = ''
								puts "invalid At rule"
	              # for($j = $i+1; $j < $size; ++$j)
	              # {
	              #     if(!ctype_alpha($string{$j}))
	              #     {
	              #         break;
	              #     }
	              #     $invalid_at_name .= $string{$j};
	              # }
	              # $this->log('Invalid @-rule: '.$invalid_at_name.' (removed)','Warning');
	            end
	          elsif is_current_char?('"') || is_current_char?("'")
							@context << IN_STRING
							current_string = current_char
							string_char = current_char
	          elsif invalid_at && is_current_char?(';')
							invalid_at = false
							@context << IN_SELECTOR
	          elsif is_current_char?('{')
							@context << IN_PROPERTY
	          elsif is_current_char?('}')
							current_at_block = ''
							@stylesheet.end_at_block
							current_selector = ''
							# when there is a new selector we save the last set
							@stylesheet << current_ruleset unless current_ruleset.empty?
							# and start a new one
							current_ruleset = CssToolkit::RuleSet.new
	          elsif is_current_char?([',','\\'])
							current_selector = current_selector.strip + current_char
	          #remove unnecessary universal selector,  FS#147
						#elseif ! (is_current_char?('*') && @in_array($string{$i+1}, array('.', '#', '[', ':'))))
						else
							current_selector << current_char
						end
          else # not is_token
						last_position = current_selector.length - 1
						if( last_position == -1 || ! ( (is_char_ctype?(:space, current_selector[last_position,1]) || is_char_token?(current_selector[last_position,1]) && current_selector[last_position,1] == ',') && is_ctype?(:space) ))
	          	current_selector << current_char
	          end
          end

				when IN_PROPERTY
					if is_token?
						if (is_current_char?(':') || is_current_char?('=')) && ! current_property.empty?
							@context << IN_VALUE
	          elsif is_comment? && current_property.empty?
							@context << IN_COMMENT
							@index += 1 # move past '*'
	          elsif is_current_char?('}')
							@context << IN_SELECTOR
							invalid_at = false
							current_property = ''
							current_selector = ''
							# when there is a new selector we save the last set
							@stylesheet << current_ruleset unless current_ruleset.empty?
							# and start a new one
							current_ruleset = CssToolkit::RuleSet.new
	          elsif is_current_char?(';')
							current_property = ''
	          elsif is_current_char?(['*','\\']) # allow star hack and \ hack for properties
							current_property << current_char
	          end
          elsif ! is_ctype?(:space)
						current_property << current_char
          end

				when IN_VALUE
          property_next = is_newline? && property_is_next? || @index == css_length-1
          if is_token? || property_next
	          if is_comment?
							@context << IN_COMMENT
							@index += 1
	          elsif is_current_char?('"') || is_current_char?("'") || is_current_char?('(')
							current_string = current_char
							string_char = is_current_char?('(') ? ')' : current_char
	            @context << IN_STRING
	          elsif is_current_char?([',','\\'])
							sub_value = sub_value.strip + current_char
	          elsif is_current_char?(';') || property_next
							if current_selector[0,1] == '@' && AT_RULES.has_key?(current_selector[1..-1]) && AT_RULES[current_selector[1..-1]] == IN_VALUE
								sub_value_array << sub_value.strip

								@context << IN_SELECTOR
								case current_selector
	                  when '@charset'
											unless (@stylesheet.charset = sub_value_array[0])
												puts "extra charset"
											end
	                  when '@namespace'
											#$this->namespace = implode(' ',$this->sub_value_arr);
	                  when '@import'
											@stylesheet << CssToolkit::Import.new(sub_value_array.join(' '))
								end

	              sub_value_array = []
	              sub_value = ''
	              current_selector = ''
	            else
	            	@context << IN_PROPERTY
            	end
	          elsif ! is_current_char?('}')
	            sub_value << current_char
	          end

	          if (is_current_char?('}') || is_current_char?(';') || property_next) && ! current_selector.empty?
	            unless current_at_block.empty?
								@stylesheet << CssToolkit::MediaSet.new(current_at_block.strip)
								current_at_block = ''
	            end

	            if ! sub_value.strip.empty?
	              sub_value_array << sub_value.strip
	              sub_value = ''
	            end

	            current_value = sub_value_array.join(' ')

	            valid = is_property_valid?(current_property)
	            if (! invalid_at || valid)
								current_ruleset.add_rule({:selector => current_selector.strip, :declarations => "#{current_property}:#{current_value}" })
	            end

	            current_property = ''
							sub_value_array = []
	            current_value = ''
	          end

	          if is_current_char?('}')
							@context << IN_SELECTOR
							invalid_at = false
							current_selector = ''
							# when there is a new selector we save the last set
							@stylesheet << current_ruleset unless current_ruleset.empty?
							# and start a new one
							current_ruleset = CssToolkit::RuleSet.new
	          end
          elsif ! property_next
	          sub_value << current_char

	          if is_ctype?(:space)
							if ! sub_value.strip.empty?
	              sub_value_array << sub_value.strip
	              sub_value = ''
	            end
	          end
          end

				when IN_STRING
					if string_char === ')' && (is_current_char?('"') || is_current_char?("'")) && ! str_in_str && ! is_escaped?
						str_in_str = true
					elsif string_char === ')' && (is_current_char?('"') || is_current_char?("'")) && str_in_str && ! is_escaped?
						str_in_str = false
					end
					temp_add = current_char	# // ...and no not-escaped backslash at the previous position

					if is_newline? && !is_current_char?('\\',-1) && ! is_escaped?(-1)
						temp_add = "\\A "
           	#$this->log('Fixed incorrect newline in string','Warning');
					end

	        if !(string_char === ')' && is_css_whitespace?(current_char) && !str_in_str)
						current_string << temp_add
	        end

          if is_current_char?(string_char) && !is_escaped? && !str_in_str
						@context.pop

						if is_css_whitespace?(current_string) && current_property != 'content'
							if (!quoted_string)
								if (string_char === '"' || string_char === '\'')
									# Temporarily disable this optimization to avoid problems with @charset rule, quote properties, and some attribute selectors...
									# Attribute selectors fixed, added quotes to @chartset, no problems with properties detected. Enabled
									#current_string = current_string.slice($this->cur_string, 1, -1);
								elsif (current_string > 3) && (current_string[1,1] === '"' || current_string[1,1] === '\'')
									#current_string = current_string + substr($this->cur_string, 2, -2) . substr($this->cur_string, -1);
								end
							else
								quoted_string = false
							end
						end

						if @context[-1] === IN_VALUE # from in value?
               sub_value << current_string
            elsif @context[-1] === IN_SELECTOR
	            current_selector << current_string;
            end
					end

				when IN_COMMENT
					if is_comment_end?
						@context.pop # go back to previous context
						@index += 1 # skip the '/'
						@stylesheet << CssToolkit::Comment.new(current_comment)
						current_comment = ''
          else
						current_comment << current_char
          end

				end
				@index += 1
			end

			@stylesheet
		end

		def current_char
			@css[@index,1]
		end

		 # Checks if the next word in a string from after current index is a CSS property
		def property_is_next?
			pos = @css.index(':', @index+1)

			if ! pos
				return false
			end

			# get the length until just before the ':'
			size_of_property = pos - @index - 1

			# extract the name of the property
			property_to_find = (@css[@index+1,size_of_property]).strip.downcase

			if PROPERTIES.has_key?(property_to_find)
				#$this->log('Added semicolon to the end of declaration','Warning');
				return true
			else
				return false
			end
		end

		def is_property_valid?(property)
			PROPERTIES.has_key?(property)
		end

		def is_css_whitespace?(char)
			WHITESPACE.include?(char)
		end


		# These functions all test the character at the current index location

		def is_token?(offset=0)
			is_char_token?(@css[@index+offset,1])
		end

		def is_char_token?(char)
			TOKENS.include?(char)
		end

		# Checks if a character is escaped (and returns true if it is)
		def is_escaped?(offset=0)
			is_char_escaped?(@css[@index+offset-1,1])
		end

		def is_char_escaped?(char)
			# cannot backtrack before index '1' (would be -1, or the end of the string)
			if @index > 0
				if char === '\\'
					return true
				end
			end
			false
		end


		def is_comment?
			# cannot look beyond the end of the string
			if @index < @css.length
				if @css[@index, 2] == '/*'
					return true
				end
			end
			false
		end

		def is_comment_end?
			# cannot look beyond the end of the string
			if @index < @css.length
				if @css[@index, 2] == '*/'
					return true
				end
			end
			false
		end

		def is_newline?
			@css[@index,1] =~ /\n|\r/
		end

		def is_ctype?(ctype, offset=0)
			if @index < @css.length
				is_char_ctype?(ctype, @css[@index+offset,1])
			end
		end

		def is_char_ctype?(ctype, char)
			case ctype
			when :space
				char =~ / |\t|\f|\v|\n|\r/
			when :xdigit # hexidecimal
				char =~ /[0-9a-f]/i
			when :alpha
				char =~ /[A-Za-z]/
			end
		end

		# any sort of character - use for readability
		def is_current_char?(char,offset=0)
			case char.class.to_s
			when 'String'
				@css[@index+offset,1] == char
			when 'Array'
				char.include?(@css[@index+offset,1])
			end
		end

		def is_at_rule?(text)
      #if($this->selector{0} == '@' && isset($at_rules[substr($this->selector,1)]) && $at_rules[substr($this->selector,1)] == 'iv')
		end

		private

		# debugging help
		def context_name
			# parser current context
			case @context.last
			when NONE
				'None'
			when IN_SELECTOR
				'in selector'
			when IN_PROPERTY
				'in property'
			when IN_VALUE
				'in value'
			when IN_STRING
				'in string'
			when IN_COMMENT
				'in comment'
			when IN_AT_BLOCK
				'in at block'
			end
		end

	end
end