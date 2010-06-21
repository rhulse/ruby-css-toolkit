module CssTidy

	class Parser
		# All whitespace allowed in CSS
		WHITESPACE = [' ',"\n","\t","\r","\x0B"]

		# All CSS tokens used by tidy
		TOKENS = %w[/ @ } { , : = ' " ( , \\ ! $ % & ) * + . < > ? [ ] ^ ` | ~]

		# All CSS units (CSS 3 units included)
		units = ['in','cm','mm','pt','pc','px','rem','em','%','ex','gd','vw','vh','vm','deg','grad','rad','ms','s','khz','hz']

		# Available at-rules
		AT_RULES = {
			'page' => 'IN_SELECTOR',
			'font-face' => 'IN_SELECTOR',
			'charset' => 'IN_VALUE',
			'import' => 'IN_VALUE',
			'namespace' => 'IN_VALUE',
			'media' => 'IN_AT_BLOCK'
		}

		# Properties that need a value with unit
		unit_values = [
			'background', 'background-position',
			'border', 'border-top', 'border-right', 'border-bottom', 'border-left', 'border-width',
			'border-top-width', 'border-right-width', 'border-left-width', 'border-bottom-width',
			'bottom', 'border-spacing', 'font-size', 'height', 'left',
			'margin', 'margin-top', 'margin-right', 'margin-bottom', 'margin-left',
			'max-height', 'max-width', 'min-height', 'min-width', 'outline-width',
			'padding', 'padding-top', 'padding-right', 'padding-bottom', 'padding-left',
	    'position', 'right', 'top', 'text-indent', 'letter-spacing', 'word-spacing', 'width'
		]

		# Properties that allow <color> as value
		color_values = [
			'background-color', 'border-color', 'border-top-color', 'border-right-color',
			'border-bottom-color', 'border-left-color', 'color', 'outline-color'
		]

		# Default values for the background properties
		background_prop_default = {
			'background-image' 			=> 'none',
			'background-size'				=> 'auto',
			'background-repeat' 		=> 'repeat',
			'background-position'		=> '0 0',
			'background-attachment'	=> 'scroll',
			'background-clip'				=> 'border',
			'background-origin'			=> 'padding',
			'background-color'			=> 'transparent',
		}

		# A list of all shorthand properties that are devided into four properties and/or have four subvalues
		shorthands = {
			'border-color'	=> ['border-top-color','border-right-color','border-bottom-color','border-left-color'],
			'border-style'	=> ['border-top-style','border-right-style','border-bottom-style','border-left-style'],
			'border-width'	=> ['border-top-width','border-right-width','border-bottom-width','border-left-width'],
			'margin'				=> ['margin-top','margin-right','margin-bottom','margin-left'],
			'padding'				=> ['padding-top','padding-right','padding-bottom','padding-left'],
		}

		# All CSS Properties
		PROPERTIES = {
			'background' 						=> '1.0,2.0,2.1',
			'background-color' 			=> '1.0,2.0,2.1',
			'background-image' 			=> '1.0,2.0,2.1',
			'background-repeat' 		=> '1.0,2.0,2.1',
			'background-attachment' => '1.0,2.0,2.1',
			'background-position' 	=> '1.0,2.0,2.1',
			'border' 								=> '1.0,2.0,2.1',
			'border-top' 						=> '1.0,2.0,2.1',
			'border-right' 					=> '1.0,2.0,2.1',
			'border-bottom' 				=> '1.0,2.0,2.1',
			'border-left' 					=> '1.0,2.0,2.1',
			'border-color' 					=> '1.0,2.0,2.1',
			'border-top-color' 			=> '2.0,2.1',
			'border-bottom-color' 	=> '2.0,2.1',
			'border-left-color' 		=> '2.0,2.1',
			'border-right-color'	 	=> '2.0,2.1',
			'border-style' 					=> '1.0,2.0,2.1',
			'border-top-style' 			=> '2.0,2.1',
			'border-right-style' 		=> '2.0,2.1',
			'border-left-style' 		=> '2.0,2.1',
			'border-bottom-style' 	=> '2.0,2.1',
			'border-width' 					=> '1.0,2.0,2.1',
			'border-top-width' 			=> '1.0,2.0,2.1',
			'border-right-width' 		=> '1.0,2.0,2.1',
			'border-left-width' 		=> '1.0,2.0,2.1',
			'border-bottom-width' 	=> '1.0,2.0,2.1',
			'border-collapse' 			=> '2.0,2.1',
			'border-spacing' 				=> '2.0,2.1',
			'bottom' 								=> '2.0,2.1',
			'caption-side' 					=> '2.0,2.1',
			'content' 							=> '2.0,2.1',
			'clear' 								=> '1.0,2.0,2.1',
			'clip' 									=> '1.0,2.0,2.1',
			'color' 								=> '1.0,2.0,2.1',
			'counter-reset' 				=> '2.0,2.1',
			'counter-increment' 		=> '2.0,2.1',
			'cursor'			 					=> '2.0,2.1',
			'empty-cells' 					=> '2.0,2.1',
			'display' 							=> '1.0,2.0,2.1',
			'direction' 						=> '2.0,2.1',
			'float' 								=> '1.0,2.0,2.1',
			'font' 									=> '1.0,2.0,2.1',
			'font-family' 					=> '1.0,2.0,2.1',
			'font-style' 						=> '1.0,2.0,2.1',
			'font-variant' 					=> '1.0,2.0,2.1',
			'font-weight' 					=> '1.0,2.0,2.1',
			'font-stretch' 					=> '2.0',
			'font-size-adjust' 			=> '2.0',
			'font-size' 						=> '1.0,2.0,2.1',
			'height' 								=> '1.0,2.0,2.1',
			'left' 									=> '1.0,2.0,2.1',
			'line-height' 					=> '1.0,2.0,2.1',
			'list-style' 						=> '1.0,2.0,2.1',
			'list-style-type' 			=> '1.0,2.0,2.1',
			'list-style-image' 			=> '1.0,2.0,2.1',
			'list-style-position' 	=> '1.0,2.0,2.1',
			'margin' 								=> '1.0,2.0,2.1',
			'margin-top' 						=> '1.0,2.0,2.1',
			'margin-right' 					=> '1.0,2.0,2.1',
			'margin-bottom' 				=> '1.0,2.0,2.1',
			'margin-left' 					=> '1.0,2.0,2.1',
			'marks' 								=> '1.0,2.0',
			'marker-offset' 				=> '2.0',
			'max-height'			 			=> '2.0,2.1',
			'max-width' 						=> '2.0,2.1',
			'min-height' 						=> '2.0,2.1',
			'min-width' 						=> '2.0,2.1',
			'overflow' 							=> '1.0,2.0,2.1',
			'orphans' 							=> '2.0,2.1',
			'outline' 							=> '2.0,2.1',
			'outline-width' 				=> '2.0,2.1',
			'outline-style' 				=> '2.0,2.1',
			'outline-color' 				=> '2.0,2.1',
			'padding' 							=> '1.0,2.0,2.1',
			'padding-top' 					=> '1.0,2.0,2.1',
			'padding-right' 				=> '1.0,2.0,2.1',
			'padding-bottom' 				=> '1.0,2.0,2.1',
			'padding-left' 					=> '1.0,2.0,2.1',
			'page-break-before' 		=> '1.0,2.0,2.1',
			'page-break-after' 			=> '1.0,2.0,2.1',
			'page-break-inside' 		=> '2.0,2.1',
			'page' 									=> '2.0',
			'position' 							=> '1.0,2.0,2.1',
			'quotes' 								=> '2.0,2.1',
			'right' 								=> '2.0,2.1',
			'size' 									=> '1.0,2.0',
			'speak-header' 					=> '2.0,2.1',
			'table-layout' 					=> '2.0,2.1',
			'top' 									=> '1.0,2.0,2.1',
			'text-indent' 					=> '1.0,2.0,2.1',
			'text-align' 						=> '1.0,2.0,2.1',
			'text-decoration' 			=> '1.0,2.0,2.1',
			'text-shadow' 					=> '2.0',
			'letter-spacing' 				=> '1.0,2.0,2.1',
			'word-spacing' 					=> '1.0,2.0,2.1',
			'text-transform' 				=> '1.0,2.0,2.1',
			'white-space' 					=> '1.0,2.0,2.1',
			'unicode-bidi' 					=> '2.0,2.1',
			'vertical-align' 				=> '1.0,2.0,2.1',
			'visibility' 						=> '1.0,2.0,2.1',
			'width' 								=> '1.0,2.0,2.1',
			'widows' 								=> '2.0,2.1',
			'z-index' 							=> '1.0,2.0,2.1',
			# Speech
			'volume' 								=> '2.0,2.1',
			'speak' 								=> '2.0,2.1',
			'pause' 								=> '2.0,2.1',
			'pause-before' 					=> '2.0,2.1',
			'pause-after'	 					=> '2.0,2.1',
			'cue' 									=> '2.0,2.1',
			'cue-before' 						=> '2.0,2.1',
			'cue-after' 						=> '2.0,2.1',
			'play-during' 					=> '2.0,2.1',
			'azimuth' 							=> '2.0,2.1',
			'elevation' 						=> '2.0,2.1',
			'speech-rate' 					=> '2.0,2.1',
			'voice-family'	 				=> '2.0,2.1',
			'pitch' 								=> '2.0,2.1',
			'pitch-range' 					=> '2.0,2.1',
			'stress' 								=> '2.0,2.1',
			'richness' 							=> '2.0,2.1',
			'speak-punctuation' 		=> '2.0,2.1',
			'speak-numeral' 				=> '2.0,2.1',
		}
	end
end