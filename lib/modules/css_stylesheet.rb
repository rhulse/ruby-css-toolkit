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

	end

end