require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssMediaSetTest < Test::Unit::TestCase

	def test_add_nodes_to_media_set
		media_set = CssTidy::MediaSet.new('@media screen')
		media_set << CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		media_set << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		expected = '@media screen{body{margin:20px;padding:10px 5px 3px 8px}p{font-size:20px;margin:5px;border:1px solid #334123}}'
		assert_equal(expected, media_set.to_s)
	end

	def test_add_media_set_to_stylesheet
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::MediaSet.new('@media screen')
		sheet << CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		sheet << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})
		sheet.in_media = false

		expected = '@media screen{body{margin:20px;padding:10px 5px 3px 8px}p{font-size:20px;margin:5px;border:1px solid #334123}}'
		assert_equal(expected, sheet.to_s)
	end

	def test_add_two_media_sets_to_stylesheet
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::MediaSet.new('@media screen')
		sheet << CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		sheet << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})
		sheet.in_media = false

		sheet << CssTidy::MediaSet.new('@media print')
		sheet << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 12pt ; margin: 3pt;'})
		sheet.in_media = false

		expected = '@media screen{body{margin:20px;padding:10px 5px 3px 8px}p{font-size:20px;margin:5px;border:1px solid #334123}}@media print{p{font-size:12pt;margin:3pt}}'
		assert_equal(expected, sheet.to_s)
	end

	def test_add_media_set_and_some_rules_to_stylesheet
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::MediaSet.new('@media screen')
		sheet << CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		sheet << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})
		sheet.in_media = false

		sheet << CssTidy::RuleSet.new({:selector => 'dl', :declarations => 'font-size : 12px ; margin: 3pt;'})

		expected = '@media screen{body{margin:20px;padding:10px 5px 3px 8px}p{font-size:20px;margin:5px;border:1px solid #334123}}dl{font-size:12px;margin:3pt}'
		assert_equal(expected, sheet.to_s)
	end

	def test_add_complex_media_set_and_rule_after
		sheet = CssTidy::StyleSheet.new
		sheet << CssTidy::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px 5px 3px 8px ; '})
		sheet << CssTidy::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		sheet << CssTidy::MediaSet.new('@media all and (max-width: 750px), all and (max-device-width: 750px)')

		sheet << CssTidy::RuleSet.new({:selector => 'dl', :declarations => 'font-size : 12px ; margin: 3pt;'})
		sheet.in_media = false

		sheet << CssTidy::RuleSet.new({:selector => 'table', :declarations => 'font-size : 20px ; margin: 3pt;'})

		expected = 'body{margin:20px;padding:10px 5px 3px 8px}p{font-size:20px;margin:5px;border:1px solid #334123}@media all and (max-width: 750px), all and (max-device-width: 750px){dl{font-size:12px;margin:3pt}}table{font-size:20px;margin:3pt}'
		assert_equal(expected, sheet.to_s)
	end

end
