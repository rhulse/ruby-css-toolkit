require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssRuleSetTest < Test::Unit::TestCase

	def test_rule_set_basic
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declaration => 'margin:20px'})
		expected = {['body']=>['margin:20px']}
		assert_equal(expected, rs.to_hash)
	end

end