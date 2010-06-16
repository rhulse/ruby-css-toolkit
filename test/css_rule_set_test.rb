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

end