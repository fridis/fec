--------------------------------------------------------------------------------
-- FEC -- Native Eiffel Compiler for SUN/SPARC
--
--  Copyright (C) 1997 Fridtjof Siebert
--    EMail: fridi@gr.opengroup.org
--    SMail: Fridtjof Siebert 
--           5b rue du 26 mai 1944
--           38940 St. Martin le Vinoux
--           Grenoble
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; Version 2.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--
--------------------------------------------------------------------------------

class SCANNER

-- Der Eiffel Scanner
	
inherit
	SCANNER_SYMBOLS;
	SORTABLE[INTEGER];
	CLASSES;
	FRIDISYS;
	
creation 
	make

--------------------------------------------------------------------------------

feature { ANY }

--	key: INTEGER;  -- (geerbt) Id des Namens den diese Klasse haben sollte

--------------------------------------------------------------------------------

feature {NONE}

	keywords : ARRAY [STRING] is
	-- die Schlüsselwörter alphabetisch sortiert. Index hier entspricht dem Index in keyword_types
		once
			Result := <<"alias",
							"all",
							"and",
							"as",
							"bit",
							"check",
							"class",
							"creation",
							"debug",
							"deferred",
							"do",			
							"else",		
							"elseif",	
							"end",		
							"ensure",	
							"expanded",
							"export",	
							"external",	
							"false",		
							"feature",	
							"from",		
							"frozen",	
							"if",			
							"implies", 	
							"indexing",	
							"infix",		
							"inherit",	
							"inspect",	
							"invariant",
							"is",			
							"like",		
							"local",		
							"loop",		
							"not", 		
							"obsolete",	
							"old",		
							"once",		
							"or", 		
							"prefix",	
							"redefine",	
							"rename",	
							"require",	
							"rescue",	
							"retry",		
							"select",	
							"separate",	
							"strip",		
							"then",		
							"true",		
							"undefine",	
							"unique",	
							"until",		
							"variant",	
							"when",		
							"xor">>
		end; -- keywords

	keyword_types : ARRAY [INTEGER] is
	-- die Scannersymbol-typen der Schlüsselwörter. Index in diesem Feld entspricht dem in keywords
		once
			Result := <<s_alias,		
							s_all,		
							s_and, 		
							s_as,			
							s_bit,		
							s_check,		
							s_class,		
							s_creation,	
							s_debug,		
							s_deferred,	
							s_do,			
							s_else,		
							s_elseif,	
							s_end,		
							s_ensure,	
							s_expanded,	
							s_export,	
							s_external,	
							s_false,		
							s_feature,	
							s_from,		
							s_frozen,	
							s_if,			
							s_implies,	
							s_indexing,	
							s_infix,		
							s_inherit,	
							s_inspect,	
							s_invariant,
							s_is,			
							s_like,	
							s_local,		
							s_loop,		
							s_not,  		
							s_obsolete,	
							s_old,		
							s_once,		
							s_or,  		
							s_prefix,	
							s_redefine,	
							s_rename,	
							s_require,	
							s_rescue,	
							s_retry,		
							s_select,	
							s_separate,	
							s_strip,		
							s_then,		
							s_true,		
							s_undefine,	
							s_unique,	
							s_until,		
							s_variant,	
							s_when,		
							s_xor>>
		end; -- keyword_types
	
	which_keyword_tmp : STRING is -- von which_keyword benutzt für lower-case String
		once
			!!Result.make(16);
		end; -- which_keyword_tmp
		
	which_keyword (str: STRING) : INTEGER is -- ergibt type dieses keywords oder -1
		require
			str /= Void
		local
			min,max,mid,cmp: INTEGER 
		do
			if str.count>16 then  
				Result := -1
			else 
				which_keyword_tmp.copy(str); 
				which_keyword_tmp.to_lower; 
				from 
					min := 1 
					max := keywords.upper 
				invariant  
					min > 1              implies which_keyword_tmp >= keywords @ (min - 1) 
					max < keywords.upper implies which_keyword_tmp <= keywords @ (max + 1)				 
				variant 
					max-min	 
				until  
					min>max 
				loop 
					mid := (min+max) // 2; 
					cmp := which_keyword_tmp.three_way_comparison(keywords @ mid); 
					if cmp <= 0 then max := mid-1 end 
					if cmp >= 0 then min := mid+1 end 
				end 
				if cmp=0 then 
					Result := keyword_types @ mid 
				else 
					Result := -1 
				end
			end
		ensure
			-- Result>=0  implies exists x : keywords @ x = str and keyword_types @ x = Result
			-- Result<0   implies for all x : keywords @ x /= str
		end; -- which_keyword
		
	keyword_string (keyword: INTEGER): STRING is -- ergibt das Schlüsselwort keyword als String
		require
			is_keyword(keyword)
		local
			index: INTEGER
		do
			from
				index := keywords.lower
			until
				keyword_types @ index = keyword
			loop
				index := index + 1
			end
			Result := 	keywords @ index
		end; -- keyword_string

feature { ANY }
		
	is_keyword (keyword: INTEGER): BOOLEAN is -- Prüfe, ob keyword = s_alias..s_xor
		do
			inspect keyword
			when
				s_alias,		s_all,		s_and, 		s_as,			s_bit,		s_check,		s_class,
				s_creation,	s_debug,		s_deferred,	s_do,			s_else,		s_elseif,	s_end,
				s_ensure,	s_expanded,	s_export,	s_external,	s_false,		s_feature,	s_from,
				s_frozen,	s_if,			s_implies,	s_indexing,	s_infix,		s_inherit,	s_inspect,	
				s_invariant,s_is,			s_like,		s_local,		s_loop,		s_not,  		s_obsolete,
				s_old,		s_once,		s_or,  		s_prefix,	s_redefine,	s_rename,	s_require,	
				s_rescue,	s_retry,		s_select,	s_separate,	s_strip,		s_then,		s_true,
				s_undefine,	s_unique,	s_until,		s_variant,	s_when,		s_xor
			then
				Result := true
			else
				Result := false
			end
		end; -- is_keyword

--------------------------------------------------------------------------------

feature { POSITION, SYSTEM }

	source_file_name: STRING;        -- Name der Quelltextdatei
	scanner_number: INTEGER;         -- Nummer in CLASSES.scanners

feature { NONE }

	source_file:  STD_FILE_READ;     -- Die Quelltextdatei 

	
	symbols: ARRAY[SCANNER_SYMBOL];  -- die Symbole
	num_symbols: INTEGER;            -- Index des letzten gültigen Eintrags im symbols-Feld

	reals: ARRAY[DOUBLE];            -- s_real: SCANNER_SYMBOL.special gibt den Index an
	num_reals: INTEGER;              -- Anzahl der Einträge in reals				
		
	current_char: CHARACTER;         -- Aktuelles Eingabezeichen
	current_char_is_escaped: BOOLEAN;-- Ist aktuelles Zeichen mit Prozent erzeugtes Zeichen?
	current_raw_char: CHARACTER;     -- Zeichen aus Eingabedatei bevor next_char Prozent-Codes erkennt
	
	current_line, 
	current_column: INTEGER;         -- Position von current_char im Quelltext
	symbol_start_position: POSITION; -- Position des ersten Zeichens des gerade untersuchten Symbols

	current_position: POSITION is
		do
			Result.init(current_line,current_column,scanner_number);
		end -- current_position;

	error(msg_num: INTEGER) is 
	-- sebug: nur wg Bug in SE (current_position.error() funkt nicht)
		local
			p: POSITION;
		do
			p := current_position;
			p.error(msg_num);
		end; -- error;

--------------------------------------------------------------------------------
	
	add_real (num: DOUBLE) is 
	-- fügt num in reals-Feld ein, erhöht num_reals. 
	-- danach enthält num_reals den index der eingefügten Zahl.  
		do
			num_reals := num_reals + 1;
			if reals=Void then 
memstats(229);
				!!reals.make(1,16)
			elseif reals.upper<num_reals then 
memstats(230);
				reals.resize(1,reals.upper*2)
			end;
			reals.put(num,num_reals)	
		end; -- add_real

--------------------------------------------------------------------------------
	
	add_symbol(type: INTEGER; special: INTEGER) is
	-- fügt neues Symbol in symbols-Feld ein und erhöht num_symbols
		local
			new_symbol: SCANNER_SYMBOL; 
		do 
memstats(231);
			!!new_symbol;
			new_symbol.set(type,special,symbol_start_position)
			num_symbols := num_symbols + 1
			if num_symbols > symbols.upper then  
memstats(232);
				symbols.resize(1,symbols.upper * 2)
			end
			symbols.put(new_symbol,num_symbols)
		end;  -- add_symbol

--------------------------------------------------------------------------------
	
	next_raw_char is -- Zeichen aus source_file lesen und in current_raw_char speichern
		do
			if current_raw_char='%N' or current_raw_char='%R' then  
				current_line := current_line + 1;
				current_column := 1;
			else 
				current_column := current_column + 1; 
			end; 
			if not source_file.end_of_input then  
				source_file.read_character 
			end
			if source_file.end_of_input then  
				current_raw_char := '%U' 
			else 
				current_raw_char := source_file.last_character 
--print("CHAR: %"" | current_raw_char.out | "%"%N");
			end 
		ensure
			source_file.end_of_input implies current_raw_char='%U'
		end;  -- next_raw_char; 

--------------------------------------------------------------------------------
	
	next_char is 
	-- nächstes Zeichen aus Eingabedatei holen, dabei Prozent-Syntax in entsprechendes Zeichen
	-- umwandeln. Ergebnis in current_char und current_char_is_escaped speichern.
		do
			next_raw_char
			if current_raw_char='%%' then 
				current_char_is_escaped := true; 
				next_raw_char;  
				inspect current_raw_char 
				when 'A'  then current_char := '@' 
				when 'B'  then current_char := '%B'  -- backspace 
				when 'C'  then current_char := '^' 
				when 'D'  then current_char := '$' 
				when 'F'  then current_char := '%F'  -- formfeed 
				when 'H'  then current_char := '\' 
				when 'L'  then current_char := '~' 
				when 'N'  then current_char := '%N'  -- newline 
				when 'Q'  then current_char := '%Q'  -- back quote 
				when 'R'  then current_char := '%R'  -- carriage return 
				when 'S'  then current_char := '#' 
				when 'T'  then current_char := '%T'  -- horizontal tab 
				when 'U'  then current_char := '%U'  -- null 
				when 'V'  then current_char := '|' 
				when '%%' then current_char := '%%' 
				when '%'' then current_char := '%'' 
				when '"'  then current_char := '"' 
				when '('  then current_char := '[' 
				when ')'  then current_char := ']' 
				when '<'  then current_char := '{' 
				when '>'  then current_char := '}' 
				when '/'  then escaped_code 
				when '%N','%R',' ','%T' then escape_at_eol 
				else 
					current_char := current_raw_char 
				end
			else 
				current_char_is_escaped := false;
				current_char := current_raw_char 
			end 
		end; -- next_char
	
	escaped_code is -- von next_char aufgerufen, wenn %%/code/ gefunden wurde
		local
			code: INTEGER; -- code z.B. 65 in %/65/
			is_error_reported: BOOLEAN;  -- Fehler bereits berichtet?
		do
			next_raw_char;
			if current_raw_char<'0' or current_raw_char>'9' then 
				error(msg.percent_err); 
				is_error_reported := true; 
			end; 	
			from 
				code := 0; 
			until 
				current_raw_char<'0' or current_raw_char>'9'
			loop 
				if code * 10 + (current_raw_char.code - 48) > 255 then 
					if not is_error_reported then 
						error(msg.percent_illasc); 
						is_error_reported := true; 
					end; 
				else 
					code := code * 10 + (current_raw_char.code - 48); 
				end; 
				next_raw_char;					
			end;	
			if current_raw_char /= '/' then 
				if not is_error_reported then 
					error(msg.percent_slash) 
				end
			end
			current_char := code.to_character;
		end; -- escaped_code

	escape_at_eol is 
	-- von next_char aufgerufen, wenn %% an Zeilenende oder vor ' ' oder '%T' gefunden wurde
		do
			from
			until 
				current_raw_char/=' ' and  
				current_raw_char/='%T'
			loop 
				next_raw_char
			end
			if current_raw_char/='%N' and current_raw_char/='%R' then 
				current_char := ' ';
			else 
				from 
					next_raw_char; 
				until 
					current_raw_char/=' ' and 
					current_raw_char/='%T'  
				loop 
					next_raw_char 
				end; 
				if current_raw_char='%%' then 
					next_char; 
				else
					error(msg.percent_at_line);
					current_char := ' ';
				end;
			end;
		end; -- escape_at_eol
			
--------------------------------------------------------------------------------
			
	white_space is  -- von scan_symbol aufgerufen zum überspringen von blanks, newlines und tabs 
		local
			done: BOOLEAN
		do
			from  
				done := false
			until 
				done
			loop 
				inspect current_char 
				when ' ','%N','%R','%T','%F','%B' then next_char 
				else 
					done := true  
				end
			end	
		end; -- white_space
		
	scan_symbol is 
	-- nächstes Symbol scannen und mit add_symbol in Symbolliste eintragen
		do
			white_space
			symbol_start_position := current_position 
			inspect current_char
			when '!'                             then next_char; add_symbol(s_exclamation_mark,0) 
			when '='                             then next_char; add_symbol(s_equal,0)
			when '+'                             then next_char; add_symbol(s_plus,0)
			when '*'                             then next_char; add_symbol(s_times,0)
			when '^'                             then next_char; add_symbol(s_power,0)
			when ';'                             then next_char; add_symbol(s_semicolon,0)
			when ','                             then next_char; add_symbol(s_comma,0)
			when '('                             then next_char; add_symbol(s_left_parenthesis,0)
			when ')'                             then next_char; add_symbol(s_right_parenthesis,0)
			when '['                             then next_char; add_symbol(s_left_bracket,0)
			when ']'                             then next_char; add_symbol(s_right_bracket,0)
			when '{'                             then next_char; add_symbol(s_left_brace,0)
			when '}'                             then next_char; add_symbol(s_right_brace,0)
			when '$'                             then next_char; add_symbol(s_dollar_sign,0); 
			when '"'                             then scan_string
			when '%''                            then scan_character
			when '0'..'9'                        then scan_number
			when '/','<','>','-','\',':','.','?' then scan_two_character_symbol
			when '@','#','|','&'                 then scan_free_operator
			when '%U'                            then add_symbol(s_eof,0)
			when 'a'..'z','A'..'Z'               then scan_identifier
			else 
				error(msg.ill_char)  
				next_char
			end; 					
		end;  -- scan_symbol 	

	tmp_string : STRING is 
	-- von scan_string und scan_identifier verwendet
		once
			!!Result.make(256);
		end; -- tmp_string;	
	
	tmp_string_to_integer : INTEGER is -- Berechne den Wert von tmp_string, Überlauf abfangen
		require
			-- for all x: 1<=x<=tmp_string.count implies (tmp_string @ x).is_digit	
		local
			index: INTEGER; 
			value: INTEGER;
			overflow: BOOLEAN;
		do
			from 
				index := 1
				overflow := false; 
			until
				index	> tmp_string.count
			loop
				value := (tmp_string @ index).code - 48;
				if Result > (Maximum_integer - value) // 10 then
					-- ist die Bedingung erfüllt, gäge es einen Überlauf, denn
					--  Result * 10 + value > Max implies
					--  Result * 10 > (Max - value) implies
					--  Result * 10> (Max - value) - (Max - value) \\ 10 implies
					--  Result > ((Max - value) - (Max - value \\ 10) // 10 implies
					--  Result > (Max - value) // 10
					-- Mit Kontraposition folgt aus der Bedingung also der Überlauf.  
					if not overflow then 
						error(msg.const_ovfl)
						overflow := true;
					end	
				else
					-- ein Überlauf wird verhindert, weil folgendes gilt:
					--  Result <= (Max - value) // 10 implies
					--  Result * 10 + value <= Max 				
					Result := Result * 10 + value 
				end;
				index := index + 1
			end
			if overflow then 
				Result := 0
			end
		end; -- tmp_string_to_integer
							
	scan_string is -- von scan_symbol aufgerufen, wenn '"' gefunden wurde
		do
			from 
				tmp_string.wipe_out;
				next_char
			until 
				(current_char='%N' or  
				 current_char='%R' or  
				 current_char='%U' or 
				 current_char='"'     ) and not current_char_is_escaped
			loop 
				tmp_string.append_character(current_char) 
				next_char 
			end
			if current_char='"' then 
				next_char
			else 
				error(msg.dquot_expected)
			end
			add_symbol(s_string,strings # tmp_string)
		end; -- scan_string
		
	scan_character is -- von scan_symbol aufgerufen, wenn '%'' gefunden wurde
		local
			special : INTEGER; 
		do
			next_char;
			special := current_char.code;
			next_char;
			if current_char='%'' then 
				next_char;
				add_symbol(s_character,special);
			else 
				error(msg.squot_expected);
			end 
		end; -- scan_character

	scan_number is -- von scan_symbol aufgerufen, wenn '0'..'9' gefunden wurde
		local
			underscore_present: BOOLEAN; -- Unterstrich in Zahl?
			consecutive_digits: INTEGER; -- Anzahl aufeinanderfolgernder Ziffern ohne Unterstrich
			loop_done: BOOLEAN;
			error_reported: BOOLEAN; 
			has_only_zeroes_and_ones: BOOLEAN;
		do
			from 
				tmp_string.wipe_out
				underscore_present := false
				consecutive_digits := 0 
				loop_done := false
				error_reported := false
				has_only_zeroes_and_ones := true;
			until 
				loop_done
			loop 
				inspect current_char
				when '0'..'9' then 
					if current_char>'1' then
						has_only_zeroes_and_ones := false
					end
					tmp_string.append_character(current_char); 
					next_char
					consecutive_digits := consecutive_digits + 1
				when '_' then
					if not error_reported and
					   (underscore_present and consecutive_digits/=3 or consecutive_digits>3) then
						error(msg.intreal_err)
						error_reported := true
					end;
					underscore_present := true 
					consecutive_digits := 0
					has_only_zeroes_and_ones := false;
					next_char
				else
					loop_done := true
				end; 
			end; 
			if not error_reported and underscore_present and consecutive_digits/=3 then
				error(msg.intreal_err)
				error_reported := true
			end
			if has_only_zeroes_and_ones and (current_char='b' or current_char='B') then		
				next_char
				error_on_letter_or_digit(error_reported)
				add_symbol(s_bit_sequence,strings # tmp_string)
			else
				if current_char='.' then
					next_char;
					if current_char='.' then  -- integer gefolgt von ".."
						add_symbol(s_integer,tmp_string_to_integer)
						next_char
						add_symbol(s_double_dot,0)
					else                      -- real
						scan_real(tmp_string,
						          underscore_present,
						          tmp_string.count>3 and not underscore_present,
						          error_reported)
					end
				else                          -- integer
					error_on_letter_or_digit(error_reported)
					add_symbol(s_integer,tmp_string_to_integer)
				end
			end;
		end; -- scan_number
		
	error_on_letter_or_digit(error_reported: BOOLEAN) is 
	-- von scan_real und scan_number aufgerufen: Ergibt Fehlermeldung wenn Buchstabe oder Ziffer
	-- einer Konstanten folgt.
		do
			inspect current_char
			when '0'..'9','a'..'z','A'..'Z' then 
				if not error_reported then
					error(msg.intreal_err)
				end
			else
			end
		end; -- error_on_letter_or_digit
					
	scan_real (integral: STRING; 
	           old_underscore_present, 
	           old_underscore_not_present, 
	           old_error_reported: BOOLEAN) is 
	-- von scan_number und scan_two_character_symbol aufgerufen, wenn eine Real-Konstante erkannt
	-- wurde. integral enthält die Ziffern des bereits einegelesenen Vorkommateils, falls dieser vorhanden
	-- ist, sonst ist integral=Void
	-- current_char ist das erste Zeichen hinter dem Dezimalpunkt.
	-- old_underscore_present = true, wenn Vorkommastellen '_' enthalten
	-- old_underscore_not_present = true, wenn mehr als 3 Vorkommastellen ohne '_'
	
		require 
			integral = Void implies not old_underscore_present and not old_error_reported
		local
			number,fraction: DOUBLE;
			index: INTEGER;
			consecutive_digits: INTEGER;
			underscore_present, error_reported, neg_exponent : BOOLEAN;
			loop_done: BOOLEAN;
		do
			error_reported := old_error_reported; 
			underscore_present := old_underscore_present;
			number := 0; 
			if integral/=Void then
				from
					index := 1; 
				until
					index>integral.count	
				loop
					number := number * 10.0 + ((integral @ index).code - 48)
					index := index + 1
				end
			end
			if current_char>='0' and current_char<='9' then  -- scan fractional part	
				from 
					fraction := 0.1
					consecutive_digits := 0 
					loop_done := false
				until 
					loop_done
				loop 
					inspect current_char
					when '0'..'9' then 
						number := number + fraction * (current_char.code - 48); 
						fraction := fraction / 10.0;
						next_char
						consecutive_digits := consecutive_digits + 1
					when '_' then
						if not error_reported and
						   (underscore_present and consecutive_digits/=3 or consecutive_digits>3 or
						    old_underscore_not_present) then
							error(msg.real_err)
							error_reported := true
						end;
						underscore_present := true 
						consecutive_digits := 0
						next_char
					else
						loop_done := true
					end; 
				end; 
			end
			if current_char='e' or current_char='E' then
				next_char;
				if current_char='+' then
					next_char;
				elseif current_char='-' then
					neg_exponent := true
					next_char
				end;
				if not error_reported and (current_char<'0' or current_char>'9') then
					error(msg.exp_expected);
					error_reported := true
				end;
				from
					tmp_string.wipe_out;
				until
					current_char<'0' or current_char>'9'
				loop
					tmp_string.append_character(current_char)
					next_char
				end;
				if neg_exponent then 
					number := number / 10.0 ^ tmp_string_to_integer
				else
					number := number * 10.0 ^ tmp_string_to_integer
				end					
			end;
			error_on_letter_or_digit(error_reported);
			add_real(number)
			add_symbol(s_real,num_reals)			
		end;  -- scan_real
		
	scan_two_character_symbol is 
	-- von scan_symbol aufgerufen, wenn '/','<','>','-','\',':','.','?' gefunden wurde
		local
			char1,char2: CHARACTER;
		do
			char1 := current_char
			next_char
			char2 := current_char
			inspect char1 
			when '/' then inspect char2 
							when '/' then next_char; add_symbol(s_div,0) 
							when '=' then next_char; add_symbol(s_not_equal,0) 
							         else            add_symbol(s_divide,0)  
							end
			when '<' then	inspect char2 
							when '=' then next_char; add_symbol(s_less_or_equal,0) 
							when '<' then next_char; add_symbol(s_left_angle_bracket,0)
			       				  else            add_symbol(s_less,0)  
							end
			when '>' then inspect char2 
							when '=' then next_char; add_symbol(s_higher_or_equal,0) 
							when '>' then next_char; add_symbol(s_right_angle_bracket,0)
			       				  else            add_symbol(s_higher,0)  
							end
			when '-' then inspect char2 
							when '-' then next_char; scan_comment 
							when '>' then next_char; add_symbol(s_arrow,0) 
									  else            add_symbol(s_minus,0)  
							end
			when '\' then inspect char2 
							when '\' then next_char; add_symbol(s_mod,0)
			     					  else error(msg.ill_symbol); 
							end
			when ':' then inspect char2 
							when '=' then next_char; add_symbol(s_receives,0) 
							         else            add_symbol(s_colon,0) 
							end
			when '.' then inspect char2
							when '0'..'9' then scan_real(Void,false,false,false)
							when '.' then next_char; add_symbol(s_double_dot,0) 
							         else            add_symbol(s_dot,0) 
							end
			when '?' then inspect char2 
							when '=' then next_char; add_symbol(s_may_receive,0) 
							         else error(msg.ill_symbol) 
							end 
			end
		end; -- scan_two_character_symbol
	
	scan_comment is -- von scan_two_character_symbol aufgerufen, wenn "--" gefunden
		do
			from
			until
				current_char /= ' ' and
				current_char /= '%T'
			loop
				next_char;
			end;
			from 
				tmp_string.wipe_out;
			until 
				(current_char='%N' or  
				 current_char='%R' or  
				 current_char='%U'    ) and not current_char_is_escaped
			loop 
				tmp_string.append_character(current_char) 
				next_char 
			end
			-- Diese Bedingung nur, um Speicher zu sparen
			if num_symbols > 0 and then (symbols @ num_symbols).type = s_end then
				add_symbol(s_comment,strings # tmp_string)
			end; 
		end; -- scan_comment
	
	scan_free_operator is -- von scan_symbol aufgerufen, wenn '@','#','|','&' gefunden
		do
			from
				tmp_string.wipe_out;
			until
				current_char='%U' or
				current_char='%R' or
				current_char='%N' or
				current_char='%T' or
				current_char=' '
			loop
				tmp_string.append_character(current_char)
				next_char
			end;
			tmp_string.to_lower; 
			add_symbol(s_free,strings # tmp_string)	
		end; -- scan_free_operator
	
	scan_identifier is -- von scan_symbol aufgerufen, wenn 'a'..'z','A'..'Z' gefunden
		local
			keyword : INTEGER;
		do
			tmp_string.wipe_out;
			from 
				tmp_string.append_character(current_char) 
				next_char
			until 
				(current_char<'a' or current_char>'z') and  
				(current_char<'A' or current_char>'Z') and  
				(current_char<'0' or current_char>'9') and  
				current_char/='_'
			loop 
				tmp_string.append_character(current_char) 
				next_char
			end
			keyword := which_keyword(tmp_string)
			if keyword	<0 then
				tmp_string.to_lower; 
				add_symbol(s_identifier,strings # tmp_string);
			else 
				if keyword = s_then then  -- and then? 
					if num_symbols>0 and then (symbols @ num_symbols).type = s_and then 
						(symbols @ num_symbols).set(s_and_then,0,symbols.item(num_symbols).position); 
					else 
						add_symbol(s_then,0) 
					end 
				elseif keyword = s_else then  -- or else? 
					if num_symbols>0 and then (symbols @ num_symbols).type = s_or then 
						(symbols @ num_symbols).set(s_or_else,0,(symbols @ num_symbols).position); 
					else 
						add_symbol(s_else,0) 
					end 
				else 
					add_symbol(keyword,0) 
				end;
			end;
		end; -- scan_identifier

--------------------------------------------------------------------------------
		
feature {ANY}

  	make(name: INTEGER; src_file: STD_FILE_READ; src_file_name: STRING; scanner_num: INTEGER) is 
	require
		src_file.is_connected;
		src_file_name /= Void
	do
		key := name;
		source_file_name := src_file_name;
		source_file := src_file;
		scanner_number := scanner_num;
		scanners.add(Current);
memstats(235);
  		!!symbols.make(1,512)
		num_symbols := 0 

		from  		
			current_raw_char := ' '
			current_line := 1; 
			current_column := 0;
  			next_char 
  		until
  			num_symbols>0 and then (symbols @ num_symbols).type = s_eof
  		loop
			scan_symbol 
  		end;
		current_symbol_index := 0;
	end; -- make 
	
	reset is
	-- Setze current_symbol_index vor erstes Symbol
		do
			current_symbol_index := 0
		end; -- reset
	
--------------------------------------------------------------------------------

	current_symbol : SCANNER_SYMBOL;  -- aktuelles scannersymbol

	current_symbol_index : INTEGER;   -- Index von current_symbol in symbols oder 0
	
	next_symbol is 
	-- hole das nächste Symbol, überlese Kommentare
		require
			current_symbol_index >= 0
		do
			if current_symbol_index < num_symbols then 
				current_symbol_index := current_symbol_index + 1;
			end
			from
				current_symbol := symbols @ current_symbol_index
			until
				current_symbol.type /= s_comment
			loop
				current_symbol_index := current_symbol_index + 1
				current_symbol := symbols @ current_symbol_index
			end
		ensure
			current_symbol_index = num_symbols or current_symbol_index > old current_symbol_index;
			current_symbol.type /= s_comment
		end; -- next_symbol

	next_symbol_or_comment is 
	-- hole das nächste Symbol oder den nächsten Kommentar
		require
			current_symbol_index >= 0
		do
			if current_symbol_index < num_symbols then 
				current_symbol_index := current_symbol_index + 1;
			end
			current_symbol := symbols @ current_symbol_index
		ensure
			current_symbol_index = old current_symbol_index + 1
		end; -- next_symbol_or_comment

--------------------------------------------------------------------------------
		
	reset_current_symbol (index: INTEGER) is
	-- mit next_symbol oder next_symbol_or_comment geholte Symbole werden wieder zurückgeschrieben und
	-- symbols @ index wird wieder zum aktuellen Symbol
		require
			index > 0;
			index <= current_symbol_index
		do
			current_symbol_index := index
			current_symbol := symbols @ index
		end; -- reset_current_symbol

--------------------------------------------------------------------------------
	
	check_keyword (keyword: INTEGER) is
	-- Überprüft, ob current_symbol.type=keyword. Falls dies nicht der Fall ist, wird eine Fehlermeldung
	-- ausgegeben
	-- Das Schlüsselwort wird überlesen. Im Fehlerfall wird ein falsches Schlüsselwort oder ein Bezeichner
	-- überlesen, bei anderen Symbolen geschieht nichts.
		require
			is_keyword(keyword)
		do
			if current_symbol.type /= keyword then
				current_symbol.position.error_m(<<msg @ msg.expected_a,keyword_string(keyword),
				                                  msg @ msg.expected_b>>)
				if is_keyword(current_symbol.type) or current_symbol.type = s_identifier then
					next_symbol
				end
			else
				next_symbol
			end
		end

--------------------------------------------------------------------------------

	check_final_comment (name: STRING) is
	-- überprüft "end -- <class-name>" am Ende einer Klasse
		local
			comment: STRING;
		do
			if current_symbol.type = s_comment then
memstats(237);
				!!comment.make_from_string(strings @ current_symbol.special);
				comment.to_lower;
				from
				until
					comment.count = 0 or else
					(comment @ 1) /= ' ' and
					(comment @ 1) /= '%T'
				loop
					comment.remove(1);
				end;
				if not(comment.substring_index(name,1)=1 and then
					    (comment.count              = name.count or else
					     comment @ (name.count + 1) = ' '        or else
					     comment @ (name.count + 1) = '%T'       or else
					     comment @ (name.count + 1) = '[' 
					    )
					   )
				then
					current_symbol.position.warning(msg.vcrn1);
				end;
				next_symbol;
			end;
		end; -- check_end_final_comment

--------------------------------------------------------------------------------

	check_and_get_identifier (msg_num: INTEGER) is
	-- prüft, ob current_symbol.type = s_identifier 
	-- ist dies der Fall, so wird der Bezeichner nach last_identifier kopiert und das nächste Symbol geholt
	-- sonst wird die Fehlermeldung msg ausgegeben, das aktuelle Symbol überlesen, falls es ein Schlüsselwort ist, 
	-- und last_identifier auf unkown_identifier gesetzt
		require
			msg = Void implies current_symbol.type = s_identifier
		do
			if current_symbol.type /= s_identifier then
				current_symbol.position.error(msg_num)
				if is_keyword(current_symbol.type) then
					next_symbol
				end;
				last_identifier := strings # unknown_identifier
			else
				last_identifier := current_symbol.special
				next_symbol
			end
		ensure
			last_identifier /= 0
		end; -- check_and_get_identifier

	last_identifier: INTEGER;  -- id dest letzten Bezeichners von check_and_get_identifier gesetzt

	unknown_identifier: STRING is "__unknown";

	get_identifier : INTEGER is
	-- ergibt id des aktuellen Bezeichners
		require
			current_symbol.type = s_identifier
		do
			Result := current_symbol.special
		ensure
			Result /= 0
		end; -- get_identifier
		
--------------------------------------------------------------------------------
	
	check_and_get_string (msg_num: INTEGER) is
	-- prüft, ob current_symbol.type = s_string 
	-- ist dies der Fall, so wird der Bezeichner nach last_string kopiert und das nächste Symbol geholt
	-- sonst wird die Fehlermeldung msg ausgegeben, das aktuelle Symbol überlesen, falls es s_identifier, 
	-- s_integer, s_character, s_real oder s_bit_sequence ist, und last_string wird auf unknown_string 
	-- gesetzt
		require
			msg = Void implies current_symbol.type = s_string
		do
			if current_symbol.type /= s_string then
				current_symbol.position.error(msg_num)
				inspect current_symbol.type 
				when s_identifier, s_integer, s_character, s_real, s_bit_sequence then
					next_symbol
				else
				end;
				last_string := strings # unknown_string
			else
				last_string := current_symbol.special
				next_symbol
			end
		ensure
			last_string /= 0
		end; -- check_and_get_string
		
	last_string: INTEGER;  -- id des letzten strings, von check_and_get_identifier gesetzt

	unknown_string: STRING is "### unknown string ###";

--------------------------------------------------------------------------------
	
	get_character: CHARACTER is
	-- Ist das current_symbol eine Character-Konstante ergibt dies den Wert. 
		require
			current_symbol.type = s_character
		do
			Result := current_symbol.special.to_character;
		end; -- get_character

	get_real : DOUBLE is
	-- Ist das current_symbol eine Real-Konstante ergibt dies den Wert. 
		require
			current_symbol.type = s_real
		do
			Result := reals @ current_symbol.special;
		end; -- get_real

	get_integer : INTEGER is
	-- Ist das current_symbol eine Integer-Konstante ergibt dies den Wert. 
		require
			current_symbol.type = s_integer
		do
			Result := current_symbol.special;
		end; -- get_integer

	get_bit_sequence : INTEGER is
	-- Ist das current_symbol eine Bit-Sequenz ergibt dies id des Wertes
		require
			current_symbol.type = s_bit_sequence
		do
			Result := current_symbol.special;
		end; -- get_bit_sequence

	get_free : INTEGER is
	-- Ist das current_symbol eine freier Operator ergibt dies id des Operators. 
		require
			current_symbol.type = s_free
		do
			Result := current_symbol.special;
		end; -- get_free

--------------------------------------------------------------------------------

	check_dot(msg_num: INTEGER) is
	-- Prüft, ob current_symbol	"." ist und überliest es oder gibt 
	-- ansonsten msg als Fehlermeldung.
		do
			if current_symbol.type /= s_dot then 
				current_symbol.position.error(msg_num); 
				inspect current_symbol.type
				when 
					s_semicolon, 
					s_colon, 
					s_exclamation_mark,
					s_comma
				then
					next_symbol;
				else
				end;
			else
				next_symbol;
			end;
		end; -- check_dot
		
--------------------------------------------------------------------------------

	check_colon(msg_num: INTEGER) is
	-- Prüft, ob current_symbol	Doppelpunkt und überliest ihn oder gibt 
	-- ansonsten eine Fehlermeldung.
		do
			if current_symbol.type /= s_colon then 
				current_symbol.position.error(msg_num); 
				inspect current_symbol.type
				when 
					s_semicolon, 
					s_comma, 
					s_exclamation_mark,
					s_dot
				then
					next_symbol;
				else
				end;
			else
				next_symbol;
			end;
		end; -- check_colon

--------------------------------------------------------------------------------

	check_right_parenthesis(msg_num: INTEGER) is
	-- Prüft, ob current_symbol	")" ist und überliest es oder gibt 
	-- ansonsten eine Fehlermeldung aus.
		do
			if current_symbol.type /= s_right_parenthesis then 
				current_symbol.position.error(msg_num); 
				inspect current_symbol.type
				when 
					s_right_bracket,
					s_right_brace
				then
					next_symbol;
				else
				end;
			else
				next_symbol;
			end;
		end; -- check_right_parenthesis

--------------------------------------------------------------------------------

	check_right_bracket(msg_num: INTEGER) is
	-- Prüft, ob current_symbol	"]" ist und überliest es oder gibt 
	-- ansonsten eine Fehlermeldung aus.
		do
			if current_symbol.type /= s_right_bracket then 
				current_symbol.position.error(msg_num); 
				inspect current_symbol.type
				when 
					s_right_parenthesis,
					s_right_brace
				then
					next_symbol;
				else
				end;
			else
				next_symbol;
			end;
		end; -- check_right_bracket

--------------------------------------------------------------------------------

	remove_redundant_semicolon is
		do
			from
			until
				current_symbol.type /= s_semicolon
			loop
				next_symbol
			end;
		end; -- remove_redundant_semicolon

--------------------------------------------------------------------------------

	first_of_assertion_clause : BOOLEAN is 
	-- ist current_symbol in FIRST(Assertion_clause)?
		do
			inspect current_symbol.type
			when 
				s_identifier,
				s_left_parenthesis,
				s_not,
				s_plus,
				s_minus,
				s_free,
				s_true,
				s_false,
				s_integer,
				s_real,
				s_string,
				s_bit_sequence,
				s_left_angle_bracket,
				s_old,
				s_strip
			then
				Result := true
			else
				Result := false
			end;
		end; -- first_of_assertion_clause

	first_of_expression : BOOLEAN is
	-- ist current_symbol in FIRST(Expression)?
		do
			inspect current_symbol.type
			when s_true,
			     s_false,
			     s_integer,
			     s_real,
			     s_string,
			     s_character,
			     s_bit_sequence,
			     s_left_angle_bracket,
			     s_old,
			     s_strip,
			     s_not,
			     s_plus,
			     s_minus,
			     s_free,
			     s_left_parenthesis,
			     s_identifier
		then
			Result := true
		else
			Result := false
		end;
	end; -- first_of_expression

	first_of_actual : BOOLEAN is 
	-- ist current_symbol in FIRST(Actual)?
		do
			inspect current_symbol.type
			when 
				s_dollar_sign,
				s_identifier,
				s_left_parenthesis,
				s_not,
				s_plus,
				s_minus,
				s_free,
				s_true,
				s_false,
				s_integer,
				s_real,
				s_string,
				s_character,
				s_bit_sequence,
				s_left_angle_bracket,
				s_old,
				s_strip
			then
				Result := true
			else
				Result := false
			end;
		end; -- first_of_Actual
		
	first_of_instruction : BOOLEAN is 
	-- ist current_symbol in FIRST(Instruction)?
		do
			inspect current_symbol.type
			when 
				s_exclamation_mark,
				s_left_parenthesis,
				s_identifier,
				s_if,
				s_inspect,
				s_from,
				s_debug,
				s_check,
				s_retry
			then
				Result := true
			else
				Result := false
			end;
		end; -- first_of_instruction
		
	first_of_feature_declaration : BOOLEAN is
	-- ist current_symbol in FIRST(Feature_declaraion)?
		do 
			inspect current_symbol.type
			when 
				s_frozen,
				s_identifier,
				s_prefix,
				s_infix 
			then
				Result := true;
			else
				Result := false;
			end;
		end; -- first_of_feature_declaration

	first_of_feature_name : BOOLEAN is 
	-- ist current_symbol in FIRST(Feature_name)?
		do
			inspect current_symbol.type
			when 
				s_identifier,
				s_prefix,
				s_infix
			then
				Result := true
			else
				Result := false
			end;
		end; -- first_of_Feature_name
				
	first_of_index_clause : BOOLEAN is 
	-- ist current_symbol in FIRST(Indexing)?
		do
			inspect current_symbol.type
			when 
				s_identifier,
				s_true,
				s_false,
				s_character,
				s_plus,
				s_minus,
				s_integer,
				s_real,
				s_string,
				s_bit
			then
				Result := true
			else
				Result := false
			end;
		end; -- first_of_index_clause

	first_of_type : BOOLEAN is 
	-- ist current_symbol in FIRST(Type)?
		do
			inspect current_symbol.type
			when 
				s_identifier,
				s_expanded,
				s_bit,
				s_like
			then
				Result := true
			else
				Result := false
			end;
		end; -- first_of_type
			
	first_of_choice : BOOLEAN is 
	-- ist current_symbol in FIRST(Type)?
		do
			inspect current_symbol.type
			when 
				s_identifier,
				s_character,
				s_plus,
				s_minus,
				s_integer
			then
				Result := true
			else
				Result := false
			end;
		end; -- first_of_choice
		
--------------------------------------------------------------------------------

	parse_class: PARSE_CLASS;
	
feature { PARSE_CLASS }

	set_parse_class(to: PARSE_CLASS) is
		do
			parse_class := to;
		end; -- set_parse_class

--------------------------------------------------------------------------------

invariant
	symbols /= Void;
	num_symbols <= symbols.upper;
	symbols.lower = 1;
	source_file /= Void;
	which_keyword_tmp /= Void;
	keywords.upper = keyword_types.upper;
	tmp_string /= Void;
	(symbols @ num_symbols).type = s_eof
	-- for all x: 1<=x<num_symbols imples (symbols @ x).type /= s_eof
end -- SCANNER
