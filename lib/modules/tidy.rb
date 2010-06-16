
def tidy_css(clean_css)
	css = clean_css.clone

	# color swaps
	swaps = {
		'white' 	=> '#fff',
		'black' 	=> '#000',
    'fuchsia'	=> '#f0f',
    'yellow'	=> '#ff0',
    '#f00'		=> 'red',
		'#800000'	=> 'maroon',
		'#ffa500' => 'orange',
		'#808000'	=> 'olive',
		'#800080'	=> 'purple',
		'#008000' => 'green',
		'#000080'	=> 'navy',
		'#008080' => 'teal',
		'#c0c0c0' => 'silver',
		'#808080' => 'gray',
	}

	swaps.each do |from, to|
		css.gsub!(/:#{from}(;|\})/, ":#{to}\\1")
	end
	
	css.gsub!(/url\(['\"](.*?)['\"]\)/, 'url(\1)')

	css = split_lines(css)
	puts "\n\n========="
	puts css
	puts "+++++++++"
	in_at = 0;
	in_ruleset = 0;
	in_declarations = 0;
	css.each_line do |line|
		if line[0,1] == '@' && line[-2,1] == ';'
			puts 'in at_charset: ' + line
		elsif line[0,1] == '@'
			puts 'in at: ' + line
		elsif line == "{\n"
			puts 'in at_{: ' + line
		elsif line =~ /\/\*/
			puts 'in comment: ' + line
		elsif line[0,1] == '{' && ( line[-2,1] == '}' || line[-1,1] == '}')
			puts 'in decl: ' + line
		elsif line[0,1] == "}"
			puts 'end at: ' + line
		else
			puts 'in ruleset: ' + line
		end
		
	end
	
	css = restore_lines(css)

	css
end

def split_lines(clean_css)
	css = clean_css.clone

  startIndex = 0
  endIndex = 0
	totallen = css.length

	css.gsub!("@", "\n@")

	# split @ declarations like @import onto their own lines
  while (startIndex = css.index("@", startIndex))
    endIndex = css.index(/;|\{/, startIndex)

    unless endIndex
      endIndex = totallen
    end
    css = css.slice(0..endIndex).to_s + "\n" + css.slice(endIndex+1, totallen).to_s
		startIndex = endIndex
		totallen += 1 # to allow for the extra \n
  end
	css.gsub!("}", "}\n")
	css.gsub!("{", "\n{")
	css.gsub!(/\n+/, "\n")
	css.gsub!("*/", "*/\n")
	css.strip!

	css
end

def restore_lines(clean_css)
	css = clean_css.clone
	css.gsub!("\n", '')

	css
end
