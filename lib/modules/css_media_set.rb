module CssToolkit

	# media sets live as nodes in a stylesheet
	# when a set is added to a style sheet, the sheet
	# adds all new nodes to the last mediaset
	#
	class MediaSet
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

		def optimize
			keep_next_comment = false

			@nodes.each_with_index do |node, idx|
				if node.class == CssToolkit::Comment
					if node.is_special?
						next # do nothing
					elsif node.is_ie5_hack?
						node.text = '\\'  # replace it
						keep_next_comment = true
					elsif keep_next_comment
						node.text = ''  # replace it
						keep_next_comment = false
					else
						node.printable = false # don't print this one
					end
				end
				node.optimize
			end
		end

	end

end