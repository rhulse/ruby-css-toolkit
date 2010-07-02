module CssToolkit

	class StyleSheet
		attr_accessor :in_media
		alias :end_at_block :in_media

		def initialize
			# nodes can contain any kind of object:
			# * charset
			# * media (which can contain media or rulesets)
			# * rulesets
			@nodes = []
			@charset = ''
			@in_media = false
		end

		def << (object)
			# if we are in media block, then add object to the last node
			if @in_media
				if object.class == CssToolkit::MediaSet
					@nodes << object
				else
					@nodes.last << object
				end
			else
				@nodes << object
				if object.class == CssToolkit::MediaSet
					@in_media = true
				end
			end
		end

		def to_s(format=:one_line)
			css = ''
			if ! @charset.empty?
				css << "@charset #{@charset};" + ((format == :multi_line) ? "\n" : '')
			end

			@nodes.each do |node|
				css << node.to_s(format) + ((format == :multi_line) ? "\n" : '')
			end
			css
		end

		def charset=(charset)
			if @charset.empty?
				@charset = charset.strip
				return true
			else
				return false
			end
		end

		def charset
			@charset
		end

		def optimize(options={})
			keep_next_comment = false

			@nodes.each_with_index do |node, idx|
				if node.class == CssToolkit::Comment
					if node.is_special? && options[:keep_special_comments]
						next # do nothing
					elsif node.is_ie5_hack? && options[:keep_ie5_comment_hack] && ! options[:optimize_selectors]
						node.text = '\\'  # replace it
						keep_next_comment = true
					elsif keep_next_comment
						node.text = ''  # replace it
						keep_next_comment = false
					elsif ! options[:keep_comments]
						node.printable = false # don't print this one
					end
				end
				node.optimize(options)
			end

			if options[:optimize_selectors]
				nodes_to_remove = []
				length = @nodes.length
				@nodes.each_with_index do |node, index|
					if node.class == CssToolkit::RuleSet
						idx = index
						# Check if properties also exist in another RuleSet
						while idx < length -1
							idx += 1 # start at the next one
							# just Rulsets
							if @nodes[idx].class == CssToolkit::RuleSet
								if ! node.empty? && node == @nodes[idx]
									node += @nodes[idx]
									nodes_to_remove << idx
									@nodes[idx].clear
								end
					 		end
 			      end
					end
				end
			end

		end

		def inspect
			indent = '  '
			puts "Stylesheet"
			@nodes.each_with_index do |node, idx|
				case node.class.to_s
				when 'CssToolkit::RuleSet'
					puts " + RuleSet"
				when 'CssToolkit::Comment'
					puts " + Comment"
				end
				node.inspect(indent)
#				puts node.class
			end
		end

	end

end