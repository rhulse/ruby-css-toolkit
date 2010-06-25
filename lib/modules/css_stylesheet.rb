module CssToolkit

	class StyleSheet

		def initialize
			# nodes can contain any kind of object:
			# * charset
			# * media (which can contain media or rulesets)
			# * rulesets
			@nodes = []
		end

		def <<(ruleset)
			@nodes << ruleset
		end

		def to_s(format=:one_line)
			css = ''
			@nodes.each do |node|
				css << node.to_s(format) + ((format == :multi_line) ? "\n" : '')
			end
			css
		end

		def optimize
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