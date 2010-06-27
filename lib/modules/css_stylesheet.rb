module CssToolkit

	class StyleSheet
		attr_accessor :in_media

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