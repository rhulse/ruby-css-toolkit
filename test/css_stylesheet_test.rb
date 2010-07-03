require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssStyleSheetTest < Test::Unit::TestCase

	def test_add_node_to_stylesheet
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		sheet << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		expected = 'body{margin:20px;padding:10px 5px 3px 8px}p{font-size:20px;margin:5px;border:1px solid #334123}'
		assert_equal(expected, sheet.to_s)
	end

	def test_add_node_to_stylesheet_multiline
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		sheet << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		expected = "body{\n  margin:20px;\n  padding:10px 5px 3px 8px\n}\np{\n  font-size:20px;\n  margin:5px;\n  border:1px solid #334123\n}\n"
		assert_equal(expected, sheet.to_s(:multi_line))
	end

	def test_add_charset_comments_and_nodes
		sheet = CssTidy::StyleSheet.new
		comment = CssTidy::Comment.new

		sheet.charset = "'UTF-16'"

		comment.text = " This is a comment "

		sheet << comment

		sheet << CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		sheet << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		expected = "@charset 'UTF-16';\n/* This is a comment */\nbody{\n  margin:20px;\n  padding:10px 5px 3px 8px\n}\np{\n  font-size:20px;\n  margin:5px;\n  border:1px solid #334123\n}\n"
		assert_equal(expected, sheet.to_s(:multi_line))
	end

	def test_charset
		sheet = CssTidy::StyleSheet.new
		sheet.charset = '"UTF-8"'

		assert_equal('"UTF-8"', sheet.charset)
	end

	def test_charset_removes_quotes
		sheet = CssTidy::StyleSheet.new
		sheet.charset = 'UTF-8'

		assert_equal('UTF-8', sheet.charset)
	end

	def test_import
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::Import.new("'test.css'")

		assert_equal("@import 'test.css';", sheet.to_s)
	end

	def test_two_imports
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::Import.new("'test.css'")
		sheet << CssTidy::Import.new("'another.css'")

		assert_equal("@import 'test.css';@import 'another.css';", sheet.to_s)
	end

	def test_two_imports_with_comment
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::Comment.new(" This is a comment ")
		sheet << CssTidy::Import.new("'test.css'")
		sheet << CssTidy::Import.new("'another.css'")

		assert_equal("/* This is a comment */@import 'test.css';@import 'another.css';", sheet.to_s)
	end

	def test_optimise
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		sheet << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})
		sheet << CssTidy::RuleSet.new({:selector => 'dl', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		sheet.optimize({:optimize_selectors => true})
		expected = 'body{margin:20px;padding:10px 5px 3px 8px}p,dl{font-size:20px;margin:5px;border:1px solid #334123}'
		assert_equal(expected, sheet.to_s)
	end
end
