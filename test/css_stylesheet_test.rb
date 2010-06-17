require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssStyleSheetTest < Test::Unit::TestCase

	def test_add_node_to_stylesheet
		sheet = CssToolkit::StyleSheet.new
		sheet << CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px  5px  3px 8px ; '})
		sheet << CssToolkit::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		expected = 'body{margin:20px;padding:10px 5px 3px 8px}p{font-size:20px;margin:5px;border:1px solid #334123}'
		assert_equal(expected, sheet.to_s)
	end

	def test_add_node_to_stylesheet_multiline
		sheet = CssToolkit::StyleSheet.new
		sheet << CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px  5px  3px 8px ; '})
		sheet << CssToolkit::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		expected = "body{\n  margin:20px;\n  padding:10px 5px 3px 8px\n}\np{\n  font-size:20px;\n  margin:5px;\n  border:1px solid #334123\n}\n"
		assert_equal(expected, sheet.to_s(:multi_line))
	end

	def test_add_charset_comments_and_nodes
		sheet = CssToolkit::StyleSheet.new
		comment = CssToolkit::Comment.new

		charset = CssToolkit::Charset.new
		charset << 'UTF-16'

		comment.text = " This is a comment "

		sheet << charset
		sheet << comment

		sheet << CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px  5px  3px 8px ; '})
		sheet << CssToolkit::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		expected = "@charset \"UTF-16\";\n\n/* This is a comment */\nbody{\n  margin:20px;\n  padding:10px 5px 3px 8px\n}\np{\n  font-size:20px;\n  margin:5px;\n  border:1px solid #334123\n}\n"
		assert_equal(expected, sheet.to_s(:multi_line))
	end

end
