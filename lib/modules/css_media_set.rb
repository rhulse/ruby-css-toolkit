module CssToolkit

	# media sets live as nodes in a stylesheet
	# when a set is added to a style sheet, the sheet
	# adds all new nodes to the last mediaset
	#
	class MediaSet < CssBase
		attr_accessor :at_media

		def initialize(at_media)
			# nodes can contain:
			# * ruleset
			# * comment
			@nodes = []
			@at_media = at_media
			self
		end

		def << (object)
			@nodes << object
		end

		def to_s(format=:one_line, indent='')
			css = "#{@at_media}{" + ((format == :multi_line) ? "\n" : '')
			@nodes.each do |node|
				css << indent + node.to_s(format) + ((format == :multi_line) ? "\n" : '')
			end
			css << '}' + ((format == :multi_line) ? "\n" : '')
			css
		end

		def optimize(options)
			return nil if @nodes.empty? || @at_media.empty?
			# clean up self first
      @at_media.gsub!(/\*\/\s+\/\*/, '*//*')

			# then do kids
			keep_next_comment = false

			@nodes.each_with_index do |node, idx|
				if node.class == CssToolkit::Comment
					if node.is_special? && options[:keep_special_comments]
						next # do nothing
					elsif node.is_ie5_hack? && options[:keep_ie5_comment_hack]
						node.text = '\\'  # replace it
						keep_next_comment = true
					elsif keep_next_comment
						node.text = ''  # replace it
						keep_next_comment = false
					else
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

		def clear
			@nodes = []
			@at_media = ''
		end

	end

end