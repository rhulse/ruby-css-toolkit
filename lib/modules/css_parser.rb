$:.unshift File.dirname(__FILE__)
require 'css_properties'

module CssTidy

	class Parser
		# these are used to poke values in for testing instance methods
		attr_accessor :css, :index

		# parser current context
		NONE				= 0
		IN_SELECTOR = 1
		IN_PROPERTY = 2
		IN_VALUE		= 3
		IN_STRING		= 4
		IN_COMMENT	= 5
		IN_AT_BLOCK	= 6

		# setup the class vars used by Tidy
		def initialize

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

			current_at_block = ''
			invalid_at = false
			current_selector = ''
			current_property = ''
			current_value = ''
			sub_value = ''
			sub_value_array = []
			current_comment = ''

			while @index < css_length
				# puts context_name
				# puts @css[@index,1]

				if is_newline?
					@line_number += 1
				end

				case @context.last
				when IN_AT_BLOCK
					if is_token
						if is_comment
							@context << IN_COMMENT
							@index += 1 # move past '*'
						elsif is_char '{'
							@context << IN_SELECTOR
							# $this->_add_token(AT_START, $this->at);
							@context << IN_SELECTOR
						elsif is_char ','
							current_at_block = current_at_block.strip + ','
						elsif is_char '\\'
							# $this->at .= $this->_unicode($string,$i);
						end # of is_comment
					else # not token
	          lastpos = current_at_block.length - 1
	          # if(!( (ctype_space($this->at{$lastpos}) || csstidy::is_token($this->at,$lastpos) && $this->at{$lastpos} == ',') && ctype_space($string{$i})))
	          #if !( (ctype_space($this->at{$lastpos}) || csstidy::is_token($this->at,$lastpos) && $this->at{$lastpos} == ',') && ctype_space($string{$i}))
	          	current_at_block << current_char
	          #end
					end

				when IN_SELECTOR
          if is_token?
	       		if is_comment? && current_selector.empty?
							@context << IN_COMMENT
							@index += 1
	       		elsif is_char?('@') && current_selector.empty?
	            # # Check for at-rule
	            # $this->invalid_at = true;
	            # foreach($at_rules as $name => $type)
	            # {
	            #     if(!strcasecmp(substr($string,$i+1,strlen($name)),$name))
	            #     {
	            #         ($type == 'at') ? $this->at = '@'.$name : $this->selector = '@'.$name;
	            #         $this->status = $type;
	            #         $i += strlen($name);
	            #         $this->invalid_at = false;
	            #     }
	            # }
	            #
	            # if($this->invalid_at)
	            # {
	            #     $this->selector = '@';
	            #     $invalid_at_name = '';
	            #     for($j = $i+1; $j < $size; ++$j)
	            #     {
	            #         if(!ctype_alpha($string{$j}))
	            #         {
	            #             break;
	            #         }
	            #         $invalid_at_name .= $string{$j};
	            #     }
	            #     $this->log('Invalid @-rule: '.$invalid_at_name.' (removed)','Warning');
	            # }
	          elsif is_char?('"') || is_char?("'")
							@context << IN_STRING
	             # $this->cur_string = $string{$i};
	             # $this->str_char = $string{$i};
	          elsif invalid_at && is_char?(';')
							invalid_at = false
							@context << IN_SELECTOR
	          elsif is_char?('{')
							@context << IN_PROPERTY
              # $this->_add_token(SEL_START, $this->selector);
              # $this->added = false;
	          elsif is_char?('}')
	            # $this->_add_token(AT_END, $this->at);
							current_at_block = ''
							current_selector = ''
	            # $this->sel_separate = array();
	          elsif is_char?(',')
							current_selector = current_selector.strip + ','
	            #$this->sel_separate[] = strlen($this->selector);
	          elsif is_char?('\\')
	            #$this->selector .= $this->_unicode($string,$i);
	          end
	          #remove unnecessary universal selector,  FS#147
	          # else if(!($string{$i} == '*' && @in_array($string{$i+1}, array('.', '#', '[', ':')))) {
	          #     $this->selector .= $string{$i};
	          # }
          else # not is_token
	          # $lastpos = strlen($this->selector)-1;
						last_position = current_selector.length - 1
								# 	          if( $lastpos == -1 
								# || ! ( (ctype_space($this->selector{$lastpos}) || csstidy::is_token($this->selector,$lastpos) && $this->selector{$lastpos} == ',') 
								# && ctype_space($string{$i}) ))
						if( lastpos == -1 || ! ( (is_char_ctype?(:space, current_selector[last_position,1]) || is_char_token?(current_selector[last_position,1]) && current_selector[last_position,1] == ',') && is_ctype?(:space) ))
	          	#$this->selector .= $string{$i};
	          	current_selector << current_char
	          end
          end

				when IN_PROPERTY
					if is_token?
						if (is_char?(':') || is_char('=')) && ! current_property.empty?
							@context << IN_VALUE
	            #if(! $this->get_cfg('discard_invalid_properties') || csstidy::property_is_valid($this->property)) {
	            if is_property_valid?(current_property)
	            	#$this->_add_token(PROPERTY, $this->property);
	            end
	          elsif is_comment? && current_property.empty?
							@context << IN_COMMENT
							@index += 1 # move past '*'
	          elsif is_char?('}')
	            # $this->explode_selectors();
							@context << IN_SELECTOR
							invalid_at = false
	            # $this->_add_token(SEL_END, $this->selector);
							current_selector = ''
							current_property = ''
	          elsif is_char?(';')
							current_property = ''
	          elsif is_char('\\')
	            #  $this->property .= $this->_unicode($string,$i);
	          end
          elsif ! is_ctype?(:space)
						current_property << current_char
          end

				when IN_VALUE
          property_next = ( is_newline? && (property_is_next? || @index == css_length-1))
          if is_token? || property_next
	          if is_comment?
							@context = IN_COMMENT
							@index += 1
	          elsif is_char?('"') || is_char?("'") || is_char?('(')
	            # $this->cur_string = $string{$i};
	            # $this->str_char = ($string{$i} == '(') ? ')' : $string{$i};
	            @context << IN_STRING
	          elsif is_char?(',')
	          	sub_value = sub_value.strip + ','
	          elsif is_char?('\\')
	             # $this->sub_value .= $this->_unicode($string,$i);
	          elsif is_char?(';') || property_next
							if current_selector[0,1] == '@'
	            # if($this->selector{0} == '@' && isset($at_rules[substr($this->selector,1)]) && $at_rules[substr($this->selector,1)] == 'iv')
	            # {
	            #     $this->sub_value_arr[] = trim($this->sub_value);
	            #
	            #     $this->status = 'is';
	            #
	            #     switch($this->selector)
	            #     {
	            #         case '@charset': $this->charset = $this->sub_value_arr[0]; break;
	            #         case '@namespace': $this->namespace = implode(' ',$this->sub_value_arr); break;
	            #         case '@import': $this->import[] = implode(' ',$this->sub_value_arr); break;
	            #     }
	            #
	            #     $this->sub_value_arr = array();
	            #     $this->sub_value = '';
	            #     $this->selector = '';
	            #     $this->sel_separate = array();
	            # }
	            else
	            	@context << IN_PROPERTY
            	end
	          elsif is_char?('}')
	            sub_value << current_char
	          end

	          if (is_char?('}') || is_char?(';') || property_next) && ! current_selector.empty?
	            if current_at_block.empty?
		          	current_at_block = '41';
	            end

	            # case settings
							#	if($this->get_cfg('lowercase_s'))
	            	current_selector.downcase
	            #end
							current_property.strip.downcase!

	            #$this->optimise->subvalue();
	            if ! sub_value.empty?
	              # $this->sub_value_arr[] = $this->sub_value;
	              # $this->sub_value = '';
	              sub_value_array << sub_value
	              sub_value = ''
	            end

	            current_value = sub_value_array.join(' ')
	            # $this->optimise->value();

	            valid = is_property_valid?(current_property)

	            #if((!$this->invalid_at || $this->get_cfg('preserve_css')) && (!$this->get_cfg('discard_invalid_properties') || $valid))
	            if (! invalid_at || valid)
                #$this->css_add_property($this->at,$this->selector,$this->property,$this->value);
								puts "ADDED: #{current_at_block}, #{current_selector}, #{current_property}, #{current_value}"
	                # $this->_add_token(VALUE, $this->value);
	                # $this->optimise->shorthands();
	            end

	            if ! valid
	                # if($this->get_cfg('discard_invalid_properties'))
	                # {
	                #     $this->log('Removed invalid property: '.$this->property,'Warning');
	                # }
	                # else
	                # {
	                #     $this->log('Invalid property in '.strtoupper($this->get_cfg('css_level')).': '.$this->property,'Warning');
	                # }
	            end

	            current_property = ''
							sub_value_array = []
	            current_value = ''
	          end

	          if is_char?('}')
              # $this->explode_selectors();
              # $this->_add_token(SEL_END, $this->selector);
							@context << IN_SELECTOR
							invalid_at = false
							current_selector = ''
	          end
          elsif ! property_next
	          sub_value << current_char

	          if is_ctype?(:space)
	            # $this->optimise->subvalue();
	            # if($this->sub_value != '')
							if ! sub_value.empty?
	            #    $this->sub_value_arr[] = $this->sub_value;
	            #     $this->sub_value = '';
	              sub_value_array << sub_value
	              sub_value = ''
	            end
	          end
          end

				when IN_STRING


				when IN_COMMENT
					if is_comment_end?
            #$this->status = $this->from;
						@context.pop # go back to previous context
            #$i++;
						@index += 1 # skip the '/'
            #$this->_add_token(COMMENT, $cur_comment);
						current_comment = ''
          else
            #$cur_comment .= $string{$i};
						current_comment = current_char
          end

				end
				@index += 1
			end

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


		# These functions all test the character at the current index location

		def is_token?(offset=0)
			is_char_token?(@css[@index+offset,1])
		end
		
		def is_char_token?(char)
			TOKENS.include?(char)
		end

		# Checks if a character is escaped (and returns true if it is)
		def is_escaped?
			# cannot backtrack before index '1' (would be -1, or the end of the string)
			if @index > 0
				if @css[@index-1,1] == '\\'
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
		def is_char?(char,offset=0)
			case char.class.to_s
			when 'String'
				@css[@index+offset,1] == char
			when 'Array'
				char.include?(@css[@index+offset,1])
			end
		end

		def convert_unicode
			@index += 1
			add = '';
			replaced = false;
			length = @css.length
			# collect the unicode numbers
			while (@index < length && (is_ctype?(:xdigit)) || (is_ctype?(:space)) && add.length < 6)
				add << current_char
				if is_ctype?(:space)
					break;
				end
				@index += 1
			end
			code = add.to_i(10)
			if (code > 47 && code < 58) || (code > 64 && code < 91) || (code > 96 && code < 123)
				add = code.chr
				replaced = true
			else
				add = '\\' + add.strip
			end

			if is_ctype?(:xdigit, 1) && is_ctype?(:space) && ( !replaced || !is_ctype?(:space))
				@index -= 1;
			end

			if(add != '\\' || ! is_token?(1))
				return add;
			end

			if(add == '\\')
				puts('Removed unnecessary backslash','Information');
			end
			return ''
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