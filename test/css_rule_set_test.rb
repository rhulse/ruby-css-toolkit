require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssRuleSetTest < Test::Unit::TestCase

	def test_rule_set_basic
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin:20px'})
		expected = {['body']=>['margin:20px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_basic_with_spaces
		rs = CssTidy::RuleSet.new({:selector => ' body ', :declarations => ' margin:20px '})
		expected = {['body']=>['margin:20px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_longer
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin:20px;padding:10px 5px 3px 8px;'})
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_longer_with_spaces
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin:20px ; padding: 10px 5px 3px 8px; '})
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_longer
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin:20px;padding:10px 5px 3px 8px;'})
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_merge_margin_longhand
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin-top:20px ; margin-bottom:3px; margin-left: 12px; margin-right:11px;'})
		expected = {['body']=>['margin:20px 11px 3px 12px']}
		rs.merge_4_part_longhands
		assert_equal(expected, rs.to_hash)
	end

	def test_merge_margin_longhand_optimise
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin-top:20px ; margin-bottom:20px; margin-left: 20px; margin-right:20px;'})
		expected = {['body']=>['margin:20px']}
		rs.optimize({:optimize_margin_padding => true})
		assert_equal(expected, rs.to_hash)
	end

	def test_not_merge_partial_margin_longhand
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin-bottom:3px; margin-left: 12px; margin-right:11px;'})
		expected = {['body']=>['margin-bottom:3px', 'margin-left:12px', 'margin-right:11px']}
		rs.merge_4_part_longhands
		assert_equal(expected, rs.to_hash)
	end

	def test_merge_margin_longhand_important
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin-top:20px ; margin-bottom:3px !important; margin-left: 12px; margin-right:11px;'})
		expected = {['body']=>['margin:20px 11px 3px 12px!important']}
		rs.merge_4_part_longhands
		assert_equal(expected, rs.to_hash)
	end

	def test_merge_padding_longhand
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'padding-top:21px ; padding-bottom:9px; padding-left: 45px; padding-right:7px;'})
		expected = {['body']=>['padding:21px 7px 9px 45px']}
		rs.merge_4_part_longhands
		assert_equal(expected, rs.to_hash)
	end

	def test_merge_padding_longhand_important
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'padding-top:21px ; padding-bottom:9px; padding-left: 45px !important; padding-right:7px;'})
		expected = {['body']=>['padding:21px 7px 9px 45px!important']}
		rs.merge_4_part_longhands
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_really_long_with_spaces
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
		CSS
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => css})

		expected = {['body']=>['background-color:#123abc','margin:20px', 'padding:10px 5px 3px 8px','width:100px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_really_long_with_spaces_and_box_model_hack
		# NB hack is actually:
		# voice-family: "\"}\"";
		# extra escaped are for Ruby
		css = <<-CSS
			background-color: #123abc;
			margin : 20px;
			padding: 10px 5px 3px 8px ;
			width: 100px;
			voice-family: "\\"}\\"";
			voice-family:inherit;
			width: 200px;
		CSS
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => css})

		expected = {['body']=>['background-color:#123abc','margin:20px', 'padding:10px 5px 3px 8px','width:100px','voice-family:"\\"}\\""','voice-family:inherit','width:200px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_add_a_declaration
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px']}
		assert_equal(expected, rs.to_hash)

		rs << 'width: 100px'
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px','width:100px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_to_s_one_line_format
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		expected = 'body{margin:20px;padding:10px 5px 3px 8px}'
		assert_equal(expected, rs.to_s)
	end

	def test_to_s_one_line_format_larger
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
		CSS
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => css})

		expected = 'body{background-color:#123abc;margin:20px;padding:10px 5px 3px 8px;width:100px}'
		assert_equal(expected, rs.to_s)
	end

	def test_to_s_multi_line_format_larger
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
		CSS
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => css})

		expected = "body{\n  background-color:#123abc;\n  margin:20px;\n  padding:10px 5px 3px 8px;\n  width:100px\n}"
		assert_equal(expected, rs.to_s(:multi_line))
	end

	def test_optimse_colors
		css = <<-CSS
			  me: rgb(123, 123, 123);
			  impressed: #ffeedd;
			  filter: chroma(color="#FFFFFF");
			  background: none repeat scroll 0 0 rgb(255, 255,0);
			  alpha: rgba(1, 2, 3, 4);
		CSS
		rs = CssTidy::RuleSet.new({:selector => '.color', :declarations => css})

		rs.optimize_colors
		expected = '.color{me:#7b7b7b;impressed:#fed;filter:chroma(color="#FFFFFF");background:none repeat scroll 0 0 #ff0;alpha:rgba(1, 2, 3, 4)}'

		assert_equal(expected, rs.to_s)
	end

	def test_empty
		rs = CssTidy::RuleSet.new()
		assert rs.empty?
	end

	def test_equality
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
			border 1px solid #000
		CSS
		rs1 = CssTidy::RuleSet.new({:selector => '.color', :declarations => css})
		rs2 = CssTidy::RuleSet.new({:selector => 'p', :declarations => css})

		assert rs1 == rs2
	end

	def test_inequality
		css1 = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
			border: 1px solid #000;
		CSS
		css2 = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
			border: 1px solid #001;
		CSS
		rs1 = CssTidy::RuleSet.new({:selector => '.color', :declarations => css1})
		rs2 = CssTidy::RuleSet.new({:selector => 'p', :declarations => css2})

		assert rs1 != rs2
	end

	def test_inequality_shorter
		css1 = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
			border: 1px solid #000;
		CSS
		css2 = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
		CSS
		rs1 = CssTidy::RuleSet.new({:selector => '.color', :declarations => css1})
		rs2 = CssTidy::RuleSet.new({:selector => 'p', :declarations => css2})

		assert rs1 != rs2
	end

	def test_inequality_longer
		css1 = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
		CSS
		css2 = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
			border: 1px solid #000;
		CSS
		rs1 = CssTidy::RuleSet.new({:selector => '.color', :declarations => css1})
		rs2 = CssTidy::RuleSet.new({:selector => 'p', :declarations => css2})

		assert rs1 != rs2
	end

	def test_equality_different_order
		css1 = <<-CSS
			border: 1px solid #000;
			margin : 20px ;
			background-color: #123abc;
		 	width: 100px;
			font-weight:700;
			padding: 10px 5px 3px 8px ;
		CSS
		css2 = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
			border: 1px solid #000;
		CSS
		rs1 = CssTidy::RuleSet.new({:selector => '.color', :declarations => css1})
		rs2 = CssTidy::RuleSet.new({:selector => 'p', :declarations => css2})

		assert rs1 == rs2
	end

	def test_inequality_different_order
		css1 = <<-CSS
			border: 1px solid #001;
			margin : 20px ;
			background-color: #123abc;
		 	width: 100px;
			font-weight:700;
			padding: 10px 5px 3px 8px ;
		CSS
		css2 = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
			border: 1px solid #000;
		CSS
		rs1 = CssTidy::RuleSet.new({:selector => '.color', :declarations => css1})
		rs2 = CssTidy::RuleSet.new({:selector => 'p', :declarations => css2})

		assert rs1 != rs2
	end

	def test_merge_two_sets
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
			border 1px solid #000
		CSS
		expected = '.color,p{background-color:#123abc;margin:20px;padding:10px 5px 3px 8px;width:100px;font-weight:700}'
		rs1 = CssTidy::RuleSet.new({:selector => '.color', :declarations => css})
		rs2 = CssTidy::RuleSet.new({:selector => 'p', :declarations => css})

		rs1 += rs2
		assert_equal(expected, rs1.to_s)
	end

	def test_merge_two_sets
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px 5px 3px 8px ;
		 	width: 100px;
			font-weight:700;
			border 1px solid #000
		CSS
		expected = '.color,p,dl{background-color:#123abc;margin:20px;padding:10px 5px 3px 8px;width:100px;font-weight:700}'
		rs1 = CssTidy::RuleSet.new({:selector => '.color', :declarations => css})
		rs2 = CssTidy::RuleSet.new({:selector => 'p', :declarations => css})
		rs3 = CssTidy::RuleSet.new({:selector => 'dl', :declarations => css})

		rs1 += rs2
		rs1 += rs3
		assert_equal(expected, rs1.to_s)
	end

	def test_clear
		rs = CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin:20px'})
		expected = {['body']=>['margin:20px']}
		assert_equal(expected, rs.to_hash)

		rs.clear
		assert_equal('', rs.to_s)
	end

end