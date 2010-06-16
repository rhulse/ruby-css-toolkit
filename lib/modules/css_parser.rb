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
		def intitialize

			# the raw, unprocessed css
			@raw_css = ''

			# the string that is being processed
			@css = ''

			# the current position in the string
			@index = 0

			# the current parser context. i.e where we are in the CSS
			@current_context = [NONE, IN_SELECTOR]

			# the current line number
			@line_number = 1

		end


#		Parses CSS in $string. The code is saved as array in $this->css
	# 	def parse(css)
	# 		@css = css.clone
	# 
	# 		css_rules = []
	# 		current_selector = ''
	# 		invalid_at = false;
	# 		current_at	= ''
	# 
	#     @css.gsub!("\r\n","\n")
	#     cur_comment = ''
	# 		length = css.length
	# 
	# 		while @index < length
	# 
	# 			# bump the line count for logging
	# 			if @css[@index,1] =~ /\n|\r/
	# 				@line_number += 1
	# 			end
	# 
	# 			case status
	#         # Case in at-block
	#         when IN_AT_BLOCK:
	#           # if(csstidy::is_token($string,$i))
	# 				if is_token
	#           	# if($string{$i} == '/' && @$string{$i+1} th== '*')
	# 					if is_comment
	# 	          # $this->context = 'ic'; ++$i;
	# 	          # $this->from = 'at';
	# 						@current_context << IN_COMMENT
	# 						@index += 1
	#           	# }
	#           	# elseif($string{$i} == '{')
	# 					elsif is_char '{'
	# 						#         $this->context = 'is';
	#           		#         $this->_add_token(AT_START, $this->at);
	# 						@current_context << IN_SELECTOR
	#           	# elseif($string{$i} == ',')
	# 					elsif is_char ','
	#           		#         $this->at = trim($this->at).',';
	#           	# elseif($string{$i} == '\\')
	# 					elsif is_char '\\'
	#           		# $this->at .= $this->_unicode($string,$i);
	#           #     }
	# 					end # of is_comment
	#           # }
	#           # else
	# 				else # not token
	#           #     $lastpos = strlen($this->at)-1;
	#           #     if(!( (ctype_space($this->at{$lastpos}) || csstidy::is_token($this->at,$lastpos) && $this->at{$lastpos} == ',') && ctype_space($string{$i})))
	#           #     {
	#           #         $this->at .= $string{$i};
	#           #     }
	#           # }
	# 				end
	# 
	#         when IN_SELECTOR:
	#           #if(csstidy::is_token($string,$i))
	#           if is_token
	#               #if($string{$i} == '/' && @$string{$i+1} == '*' && trim($this->selector) == '')
	# 						if is_comment && current_selector.empty?
	# 							#$this->status = 'ic'; ++$i;
	# 							@current_context << IN_COMMENT
	#                 #$this->from = 'is';
	#               #elseif($string{$i} == '@' && trim($this->selector) == '')
	#               elsif is_char('@') && current_selector.empty?
	#                 #Check for at-rule
	#                 invalid_at = true;
	# 
	# 							# look ahead to see if there is a match
	# 							#foreach($at_rules as $name => $type)
	# 							AT_RULES.each do |name, type|
	#                   #if(!strcasecmp(substr($string,$i+1,strlen($name)),$name)){
	# 								if @css.slice(@index+1, name.length) == name
	#                     #($type == 'at') ? $this->at = '@'.$name : $this->selector = '@'.$name;
	# 									(type == 'at') ? current_at = '@' + name : current_selector = '@' + name
	#                     #$this->status = $type;
	# 									@current_context << type
	# 									#$i += strlen($name);
	#                     index += name.length
	# 									#$this->invalid_at = false;
	# 									invalid_at = false;
	# 								#}
	# 								end
	# 							end
	# 
	#                 #if($this->invalid_at)
	#                 if invalid_at
	# 								#$this->selector = '@';
	# 								current_selector = '@'
	#                   #$invalid_at_name = '';
	#                   invalid_at_name = '';
	#                   #for($j = $i+1; $j < $size; ++$j)
	# 								while j < length
	#                    {
	#                        if(!ctype_alpha($string{$j}))
	#                        {
	#                            break;
	#                        }
	#                        $invalid_at_name .= $string{$j};
	# 											$j ++;
	#                    }
	#                    $this->log('Invalid @-rule: '.$invalid_at_name.' (removed)','Warning');
	#                 }
	#               }
	#               elseif(($string{$i} == '"' || $string{$i} == "'"))
	#               {
	#                   $this->cur_string = $string{$i};
	#                   $this->status = 'instr';
	#                   $this->str_char = $string{$i};
	#                   $this->from = 'is';
	#               }
	#               elseif($this->invalid_at && $string{$i} == ';')
	#               {
	#                   $this->invalid_at = false;
	#                   $this->status = 'is';
	#               }
	#               elseif($string{$i} == '{')
	#               {
	#                   $this->status = 'ip';
	#                   $this->_add_token(SEL_START, $this->selector);
	#                   $this->added = false;
	#               }
	#               elseif($string{$i} == '}')
	#               {
	#                   $this->_add_token(AT_END, $this->at);
	#                   $this->at = '';
	#                   $this->selector = '';
	#                   $this->sel_separate = array();
	#               }
	#               elseif($string{$i} == ',')
	#               {
	#                   $this->selector = trim($this->selector).',';
	#                   $this->sel_separate[] = strlen($this->selector);
	#               }
	#               elseif($string{$i} == '\\')
	#               {
	#                   $this->selector .= $this->_unicode($string,$i);
	#               }
	#               // remove unnecessary universal selector,  FS#147
	#               else if(!($string{$i} == '*' && @in_array($string{$i+1}, array('.', '#', '[', ':')))) {
	#                   $this->selector .= $string{$i};
	#               }
	#           }
	#           else # not is_token
	#           {
	#               $lastpos = strlen($this->selector)-1;
	#               if($lastpos == -1 || !( (ctype_space($this->selector{$lastpos}) || csstidy::is_token($this->selector,$lastpos) && $this->selector{$lastpos} == ',') && ctype_space($string{$i})))
	#               {
	#                   $this->selector .= $string{$i};
	#               }
	#           }
	# 
	# 
	#         when IN_PROPERTY:
	#         #if(csstidy::is_token($string,$i))
	# 				if is_token
	# 					#if(($string{$i} == ':' || $string{$i} == '=') && $this->property != '')
	# 					if (is_char(':') || is_char('=')) && ! current_property.empty?
	# 							@current_context << IN_VALUE
	# 
	#                if(!$this->get_cfg('discard_invalid_properties') || csstidy::property_is_valid($this->property)) {
	#                    $this->_add_token(PROPERTY, $this->property);
	#                }
	#            #elseif($string{$i} == '/' && @$string{$i+1} == '*' && $this->property == '')
	# 					elsif is_comment && current_property.empty?
	# 						#@current_context = 'ic'; ++$i;
	# 						@current_context << IN_COMMENT
	# 						@index += 1
	#              #@previous_context = 'ip';
	#            #elseif($string{$i} == '}')
	# 					elsif is_char('}')
	#             #$this->explode_selectors();
	#             @current_context << IN_SELECTOR
	#             #$this->invalid_at = false;
	# 						invalid_at = false
	#             #$this->_add_token(SEL_END, $this->selector);
	#             #$this->selector = '';
	#             #$this->property = '';
	# 						current_selector = ''
	# 						current_property = ''
	#            #elseif($string{$i} == ';')
	# 					elsif is_char(';')
	#           	#$this->property = '';
	# 						current_property = ''
	#           #elseif($string{$i} == '\\')
	# 					elsif is_char('\\')
	#                $this->property .= $this->_unicode($string,$i);
	#            end
	#         elseif(!ctype_space($string{$i}))
	#         {
	#             $this->property .= $string{$i};
	#         }
	#         break;
	# 
	#         when IN_VALUE:
	# 				# is there another property ??
	#         $pn = (($string{$i} == "\n" || $string{$i} == "\r") && $this->property_is_next($string,$i+1) || $i == strlen($string)-1);
	#         if(csstidy::is_token($string,$i) || $pn)
	#         {
	#             if($string{$i} == '/' && @$string{$i+1} == '*')
	#             {
	#                 @current_context = 'ic'; ++$i;
	#                 @previous_context = 'iv';
	#             }
	#             elseif(($string{$i} == '"' || $string{$i} == "'" || $string{$i} == '('))
	#             {
	#                 $this->cur_string = $string{$i};
	#                 $this->str_char = ($string{$i} == '(') ? ')' : $string{$i};
	#                 @current_context = 'instr';
	#                 @previous_context = 'iv';
	#             }
	#             elseif($string{$i} == ',')
	#             {
	#                 $this->sub_value = trim($this->sub_value).',';
	#             }
	#             elseif($string{$i} == '\\')
	#             {
	#                 $this->sub_value .= $this->_unicode($string,$i);
	#             }
	#             elseif($string{$i} == ';' || $pn)
	#             {
	#                 if($this->selector{0} == '@' && isset($at_rules[substr($this->selector,1)]) && $at_rules[substr($this->selector,1)] == 'iv')
	#                 {
	#                     $this->sub_value_arr[] = trim($this->sub_value);
	# 
	#                     @current_context = 'is';
	# 
	#                     switch($this->selector)
	#                     {
	#                         case '@charset': $this->charset = $this->sub_value_arr[0]; break;
	#                         case '@namespace': $this->namespace = implode(' ',$this->sub_value_arr); break;
	#                         case '@import': $this->import[] = implode(' ',$this->sub_value_arr); break;
	#                     }
	# 
	#                     $this->sub_value_arr = array();
	#                     $this->sub_value = '';
	#                     $this->selector = '';
	#                     $this->sel_separate = array();
	#                 }
	#                 else
	#                 {
	#                     @current_context = 'ip';
	#                 }
	#             }
	#             elseif($string{$i} != '}')
	#             {
	#                 $this->sub_value .= $string{$i};
	#             }
	#             if(($string{$i} == '}' || $string{$i} == ';' || $pn) && !empty($this->selector))
	#             {
	#                 if($this->at == '')
	#                 {
	#                     $this->at = DEFAULT_AT;
	#                 }
	# 
	#                 // case settings
	#                 if($this->get_cfg('lowercase_s'))
	#                 {
	#                     $this->selector = strtolower($this->selector);
	#                 }
	#                 $this->property = strtolower($this->property);
	# 
	#                 $this->optimise->subvalue();
	#                 if($this->sub_value != '') {
	#                     $this->sub_value_arr[] = $this->sub_value;
	#                     $this->sub_value = '';
	#                 }
	# 
	#                 $this->value = implode(' ',$this->sub_value_arr);
	# 
	#                 $this->selector = trim($this->selector);
	# 
	#                 $this->optimise->value();
	# 
	#                 $valid = csstidy::property_is_valid($this->property);
	#                 if((!$this->invalid_at || $this->get_cfg('preserve_css')) && (!$this->get_cfg('discard_invalid_properties') || $valid))
	#                 {
	#                     $this->css_add_property($this->at,$this->selector,$this->property,$this->value);
	#                     $this->_add_token(VALUE, $this->value);
	#                     $this->optimise->shorthands();
	#                 }
	#                 if(!$valid)
	#                 {
	#                     if($this->get_cfg('discard_invalid_properties'))
	#                     {
	#                         $this->log('Removed invalid property: '.$this->property,'Warning');
	#                     }
	#                     else
	#                     {
	#                         $this->log('Invalid property in '.strtoupper($this->get_cfg('css_level')).': '.$this->property,'Warning');
	#                     }
	#                 }
	# 
	#                 $this->property = '';
	#                 $this->sub_value_arr = array();
	#                 $this->value = '';
	#             }
	#             if($string{$i} == '}')
	#             {
	#                 $this->explode_selectors();
	#                 $this->_add_token(SEL_END, $this->selector);
	#                 @current_context = 'is';
	#                 $this->invalid_at = false;
	#                 $this->selector = '';
	#             }
	#         }
	#         elseif(!$pn)
	#         {
	#             $this->sub_value .= $string{$i};
	# 
	#             if(ctype_space($string{$i}))
	#             {
	#                 $this->optimise->subvalue();
	#                 if($this->sub_value != '') {
	#                     $this->sub_value_arr[] = $this->sub_value;
	#                     $this->sub_value = '';
	#                 }
	#             }
	#         }
	#         break;
	# 
	#         when IN_STRING:
	#         if($this->str_char == ')' && ($string{$i} == '"' || $string{$i} == '\'') && !$this->str_in_str && !csstidy::escaped($string,$i))
	#         {
	#             $this->str_in_str = true;
	#         }
	#         elseif($this->str_char == ')' && ($string{$i} == '"' || $string{$i} == '\'') && $this->str_in_str && !csstidy::escaped($string,$i))
	#         {
	#             $this->str_in_str = false;
	#         }
	#         $temp_add = $string{$i};           // ...and no not-escaped backslash at the previous position
	#         if( ($string{$i} == "\n" || $string{$i} == "\r") && !($string{$i-1} == '\\' && !csstidy::escaped($string,$i-1)) )
	#         {
	#             $temp_add = "\\A ";
	#             $this->log('Fixed incorrect newline in string','Warning');
	#         }
	#         if (!($this->str_char == ')' && in_array($string{$i}, $GLOBALS['csstidy']['whitespace']) && !$this->str_in_str)) {
	#             $this->cur_string .= $temp_add;
	#         }
	#         if($string{$i} == $this->str_char && !csstidy::escaped($string,$i) && !$this->str_in_str)
	#         {
	#             @current_context = @previous_context;
	#             if (!preg_match('|[' . implode('', $GLOBALS['csstidy']['whitespace']) . ']|uis', $this->cur_string) && $this->property != 'content') {
	#                 if ($this->str_char == '"' || $this->str_char == '\'') {
	# 	$this->cur_string = substr($this->cur_string, 1, -1);
	# } else if (strlen($this->cur_string) > 3 && ($this->cur_string[1] == '"' || $this->cur_string[1] == '\'')) /* () */ {
	# 	$this->cur_string = $this->cur_string[0] . substr($this->cur_string, 2, -2) . substr($this->cur_string, -1);
	# }
	#             }
	#             if(@previous_context == 'iv')
	#             {
	#                 $this->sub_value .= $this->cur_string;
	#             }
	#             elseif(@previous_context == 'is')
	#             {
	#                 $this->selector .= $this->cur_string;
	#             }
	#         }
	# 
	#       when IN_COMMENT:
	# 				#if($string{$i} == '*' && $string{$i+1} == '/')
	# 				if is_comment_end?
	# 					# revert context
	#             #@current_context = @previous_context;
	# 					@current_context.pop
	#           #$i++;
	# 					@index += 1
	#           #$this->_add_token(COMMENT, $cur_comment);
	#           #$cur_comment = '';
	# 					current_comment = ''
	#         else
	#           #$cur_comment .= $string{$i};
	# 					current_comment += @css[@index,1]
	#         end
	# 			end # case
	# 
	# 		end
	# 
	#     $this->optimise->postparse();
	# 
	#     $this->print->_reset();
	# 
	#     return !(empty($this->css) && empty($this->import) && empty($this->charset) && empty($this->tokens) && empty($this->namespace));
	# 	end


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



		# These functions all test the character at the current index location

		# any sort of character - use for readability
		def is(char)
			@css[@index,1] == char
		end

		def is_token?
			TOKENS.include?(@css[@index,1])
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
			@css[@index-1,1] =~ /\n|\r/
		end

		def is_ctype?(ctype)
			char = @css[@index-1,1]
			case ctype
			when :space
				char =~ / |\t|\f|\v|\n|\r/
			when :xdigit # hexidecimal
				char =~ /[0-9a-f]/i
			when :alpha
				char =~ /[A-Za-z]/
			end
		end

		def is_char?(char)
			@css[@index-1,1] == char
		end

		def convert_unicode
			# #++$i;
			# @index += 1
			# #$add = '';
			# add = '';
			# #$tokens =& $GLOBALS['csstidy']['tokens'];
			# #$replaced = false;
			# replaced = false;
			# length = @css.length
			# 
			# # collect the unicode numbers
			# #while($i < strlen($string) && (ctype_xdigit($string{$i}) || ctype_space($string{$i})) && strlen($add) < 6)
			# while @index < length && (is_ctype(:xdigit) || is_ctype(:space) && add.length < 6
			# 	#$add .= $string{$i};
			# 	add << @css[@index,1]
			# 	#if(ctype_space($string{$i})) {
			# 	if is_ctype(:space)
			# 		break;
			# 	end
			# 	#$i++;
			# 	@index += 1
			# end
			# # hex to decimal
			# if(hexdec($add) > 47 && hexdec($add) < 58 || hexdec($add) > 64 && hexdec($add) < 91 || hexdec($add) > 96 && hexdec($add) < 123)
			# {
			# 	$this->log('Replaced unicode notation: Changed \\'. $add .' to ' . chr(hexdec($add)),'Information');
			# 	# string chr ( int $ascii )
			# 	$add = chr(hexdec($add));
			# 	$replaced = true;
			# }
			# else {
			# 	$add = trim('\\'.$add);
			# }
			# 		
			# if(@ctype_xdigit($string{$i+1}) && ctype_space($string{$i})
			# 		       && !$replaced || !ctype_space($string{$i})) {
			# 	$i--;
			# }
			# 		
			# if($add != '\\' || !$this->get_cfg('remove_bslash') || strpos($tokens, $string{$i+1}) !== false) {
			# 	return $add;
			# }
			# 		
			# if($add == '\\') {
			# 	$this->log('Removed unnecessary backslash','Information');
			# }
			# return ''
		end

	end
end