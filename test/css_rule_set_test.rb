require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssRuleSetTest < Test::Unit::TestCase

	def test_rule_set_basic
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin:20px'})
		expected = {['body']=>['margin:20px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_basic_with_spaces
		rs = CssToolkit::RuleSet.new({:selector => ' body ', :declarations => ' margin   :  20px '})
		expected = {['body']=>['margin:20px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_longer
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin:20px;padding:10px 5px 3px 8px;'})
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_longer_with_spaces
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px  5px  3px 8px ; '})
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_really_long_with_spaces
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px  5px  3px 8px ;
		 	width: 100px;
		CSS
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => css})

		expected = {['body']=>['background-color:#123abc','margin:20px', 'padding:10px 5px 3px 8px','width:100px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_really_long_with_spaces_and_box_model_hack
		# NB hack is actually:
		# voice-family: "\"}\"";
		# extra escaped are for Ruby
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px  5px  3px 8px ;
			width: 100px;
			voice-family: "\\"}\\"";
			voice-family:inherit;
			width: 200px;
		CSS
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => css})

		expected = {['body']=>['background-color:#123abc','margin:20px', 'padding:10px 5px 3px 8px','width:100px','voice-family:"\\"}\\""','voice-family:inherit','width:200px']}
		assert_equal(expected, rs.to_hash)
	end

end