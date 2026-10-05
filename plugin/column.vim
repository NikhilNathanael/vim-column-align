vim9script
# Column aligns text in selected lines according to an input regex
#
# Written by Nikhil Nathanael Ilango
# Started on Saturday, October 3, 2026 at 5:59:48 PM
#
# state.register_host_fn("nothing"                    , game_fn_nothing                 	)?;
# state.register_host_fn("magic"                      , game_fn_magic                   	)?;
# state.register_host_fn("initialize"                 , game_fn_initialize              	)?;
# state.register_host_fn("initialize_bool"            , game_fn_initialize_bool         	)?;
# state.register_host_fn("identity"                   , game_fn_identity                	)?;
# state.register_host_fn("max"                        , game_fn_max                     	)?;
# state.register_host_fn("say"                        , game_fn_say                     	)?;
# state.register_host_fn("sin"                        , game_fn_sin                     	)?;
# state.register_host_fn("cos"                        , game_fn_cos                     	)?;
# state.register_host_fn("mega"                       , game_fn_mega                    	)?;
# state.register_host_fn("eval_order_1"               , game_fn_eval_order_1            	)?;
# state.register_host_fn("eval_order_2"               , game_fn_eval_order_2            	)?;
# state.register_host_fn("get_false"                  , game_fn_get_false               	)?;
# state.register_host_fn("set_is_happy"               , game_fn_set_is_happy            	)?;
# state.register_host_fn("draw"                       , game_fn_draw                    	)?;
# state.register_host_fn("assert_state_is_not_null"   , game_fn_assert_state_is_not_null	)?;
# state.register_host_fn("blocked_alrm"               , game_fn_blocked_alrm            	)?;
# state.register_host_fn("spawn"                      , game_fn_spawn                   	)?;
# state.register_host_fn("spawn_d"                    , game_fn_spawn_d                 	)?;
# state.register_host_fn("has_resource"               , game_fn_has_resource            	)?;
# state.register_host_fn("has_optional_resource"      , game_fn_has_optional_resource   	)?;
# state.register_host_fn("has_entity"                 , game_fn_has_entity              	)?;
# state.register_host_fn("has_string"                 , game_fn_has_string              	)?;
# state.register_host_fn("get_opponent"               , game_fn_get_opponent            	)?;
# state.register_host_fn("set_d"                      , game_fn_set_d                   	)?;
# state.register_host_fn("get_os"                     , game_fn_get_os                  	)?;
# state.register_host_fn("set_opponent"               , game_fn_set_opponent            	)?;
# state.register_host_fn("motherload"                 , game_fn_motherload              	)?;
# state.register_host_fn("motherload_subless"         , game_fn_motherload_subless      	)?;
# state.register_host_fn("offset_32_bit_f32"          , game_fn_offset_32_bit_f32       	)?;
# state.register_host_fn("offset_32_bit_i32"          , game_fn_offset_32_bit_i32       	)?;
# state.register_host_fn("offset_32_bit_string"       , game_fn_offset_32_bit_string    	)?;
# state.register_host_fn("talk"                       , game_fn_talk                    	)?;
# state.register_host_fn("get_position"               , game_fn_get_position            	)?;
# state.register_host_fn("set_position"               , game_fn_set_position            	)?;
# state.register_host_fn("cause_game_fn_error"        , game_fn_cause_game_fn_error     	)?;
# state.register_host_fn("call_on_b_fn"               , game_fn_call_on_b_fn            	)?;
# state.register_host_fn("call_on_b_fn_number"        , game_fn_call_on_b_fn_number     	)?;
# state.register_host_fn("box_number"                 , game_fn_box_number              	)?;
# state.register_host_fn("print_csv"                  , game_fn_print_csv               	)?;
# state.register_host_fn("vec_number_new"             , game_fn_vec_number_new          	)?;
# state.register_host_fn("utils"                      , game_fn_utils                   	)?;

def IsWhitespace(x: string): bool
	# regex match
	return x =~# '\s'
enddef

# Last command info
var needle = ""

def OpFunc(type: string)
	# get the line numbers of the start and stop of the text selection
	var start = getpos("'[")[1]
	var end = getpos("']")[1]

	# if it is a block, we only want to search within the block, so we define
	# a start col and end col. 
	# For line selection or charwise selection, start_col is 1 and end_col is
	# v:colmax
	# for block selection it is the corners of the block
	var start_col: number
	var end_col: number
	if type ==# "block"
		start_col = getpos("'[")[2] - 1
		end_col = getpos("']")[2]
	else 
		start_col = 0
		end_col = v:maxcol
	endif
	
	if needle->len() == 0
		needle = input("/")
	endif

	if needle ==# ''
		return
	endif
	
	var final_col = start_col
	
	for i in range(start, end)
		var line = getline(i)
		var needle_loc = line->stridx(needle, start_col)
		if needle_loc < 0 || needle_loc + needle->len() >= end_col
			continue
		endif

		var last_valid = needle_loc
		needle_loc -= 1

		# Search backwards until the first non whitespace character is found
		while needle_loc >= start_col
			var char = line[needle_loc]
			if !IsWhitespace(char)
				break
			endif
			last_valid = needle_loc
			needle_loc -= 1
		endwhile
		final_col = max([final_col, last_valid])
	endfor

	for i in range(start, end) 
		var line = getline(i)
		var needle_loc = stridx(line, needle, start_col)
		if needle_loc < 0 || needle_loc + needle->len() > end_col
			continue
		endif
		if needle_loc <= final_col 
			line = line[ : needle_loc - 1] .. repeat(" ", final_col - needle_loc) .. line[needle_loc : ]
		else
			line = line[ : final_col - 1] .. line[needle_loc : ]
		endif
		setline(i, line)
	endfor
enddef

def Go(): string
	needle = ""
	set operatorfunc=OpFunc

	return 'g@'
enddef

defc

xnoremap <expr>   	<Plug>ColumnAlign    		<SID>Go()
nnoremap <expr>   	<Plug>ColumnAlign    		<SID>Go()
nnoremap <expr>   	<Plug>ColumnAlignLine		<SID>Go() .. '_'

if hasmapto('<Plug>ColumnAlign') || maparg('ga', 'n') ==# ''
  xmap ga  <Plug>ColumnAlign
  nmap ga  <Plug>ColumnAlign
  nmap gaa <Plug>ColumnAlignLine
endif
