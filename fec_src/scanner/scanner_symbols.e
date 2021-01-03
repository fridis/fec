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

class SCANNER_SYMBOLS

--	Diese Klasse definiert nur unique-Konstanten für die Scannersymbole.

feature { ANY }
	
-- Konstanten für Scannersymbole, für SCANNER_SYMBOL.type

  -- Schlüsselwörter: 

  s_alias      : INTEGER is unique;
  s_all        : INTEGER is unique;
  s_and        : INTEGER is unique; 
  s_as         : INTEGER is unique;
  s_bit        : INTEGER is unique;
  s_check      : INTEGER is unique;
  s_class      : INTEGER is unique;
  s_creation   : INTEGER is unique;
  s_debug      : INTEGER is unique;
  s_deferred   : INTEGER is unique;
  s_do         : INTEGER is unique;
  s_else       : INTEGER is unique;
  s_elseif     : INTEGER is unique;
  s_end        : INTEGER is unique;
  s_ensure     : INTEGER is unique;
  s_expanded   : INTEGER is unique;
  s_export     : INTEGER is unique;
  s_external   : INTEGER is unique;
  s_false      : INTEGER is unique;
  s_feature    : INTEGER is unique;
  s_from       : INTEGER is unique;
  s_frozen     : INTEGER is unique;
  s_if         : INTEGER is unique;
  s_implies    : INTEGER is unique; 
  s_indexing   : INTEGER is unique;
  s_infix      : INTEGER is unique;
  s_inherit    : INTEGER is unique;
  s_inspect    : INTEGER is unique;
  s_invariant  : INTEGER is unique;
  s_is         : INTEGER is unique;
  s_like       : INTEGER is unique;
  s_local      : INTEGER is unique;
  s_loop       : INTEGER is unique;
  s_not        : INTEGER is unique; 
  s_obsolete   : INTEGER is unique;
  s_old        : INTEGER is unique;
  s_once       : INTEGER is unique;
  s_or         : INTEGER is unique; 
  s_prefix     : INTEGER is unique;
  s_redefine   : INTEGER is unique;
  s_rename     : INTEGER is unique;
  s_require    : INTEGER is unique;
  s_rescue     : INTEGER is unique;
  s_retry      : INTEGER is unique;
  s_select     : INTEGER is unique;
  s_separate   : INTEGER is unique;
  s_strip      : INTEGER is unique;
  s_then       : INTEGER is unique;
  s_true       : INTEGER is unique;
  s_undefine   : INTEGER is unique;
  s_unique     : INTEGER is unique;
  s_until      : INTEGER is unique;
  s_variant    : INTEGER is unique;
  s_when       : INTEGER is unique;
  s_xor        : INTEGER is unique;
  
  -- BOOLEAN, CHARACTER, Current, DOUBLE, INTEGER, NONE, POINTER, REAL, Result und STRING werden
  -- nicht als Schlüsselwörter betrachtet.

  -- Spezialsymbole: 

  s_semicolon          : INTEGER is unique;  -- ";"  
  s_comma              : INTEGER is unique;  -- ","  
  s_colon              : INTEGER is unique;  -- ":"  
  s_dot                : INTEGER is unique;  -- "."  
  s_exclamation_mark   : INTEGER is unique;  -- "!"
  s_arrow              : INTEGER is unique;  -- "->" 
  s_double_dot         : INTEGER is unique;  -- ".." 
  s_left_parenthesis   : INTEGER is unique;  -- "("  
  s_right_parenthesis  : INTEGER is unique;  -- ")"  
  s_left_bracket       : INTEGER is unique;  -- "["  
  s_right_bracket      : INTEGER is unique;  -- "]"  
  s_left_brace         : INTEGER is unique;  -- "{"  
  s_right_brace        : INTEGER is unique;  -- "}"  
  s_left_angle_bracket : INTEGER is unique;  -- "<<" 
  s_right_angle_bracket: INTEGER is unique;  -- ">>" 
  s_receives           : INTEGER is unique;  -- ":=" 
  s_may_receive        : INTEGER is unique;  -- "?=" 
  s_dollar_sign        : INTEGER is unique;  -- "$"
  s_percent            : INTEGER is unique;  -- "%"
  s_plus               : INTEGER is unique;  -- "+"
  s_minus              : INTEGER is unique;  -- "-"
  s_times              : INTEGER is unique;  -- "*"
  s_divide             : INTEGER is unique;  -- "/"
  s_equal              : INTEGER is unique;  -- "="  
  s_not_equal          : INTEGER is unique;  -- "/="
  s_less               : INTEGER is unique;  -- "<"
  s_higher             : INTEGER is unique;  -- ">"
  s_less_or_equal      : INTEGER is unique;  -- "<="
  s_higher_or_equal    : INTEGER is unique;  -- ">="
  s_div                : INTEGER is unique;  -- "//" 
  s_mod                : INTEGER is unique;  -- "\\" 
  s_power              : INTEGER is unique;  -- "^"  
  s_and_then           : INTEGER is unique;  -- and then
  s_or_else            : INTEGER is unique;  -- or else
  s_free               : INTEGER is unique;  -- "&-)" "|o**" "###" 

  -- Zusammengesetzte Symbole: 

  s_identifier         : INTEGER is unique;  -- Bezeichner                                    
  s_integer            : INTEGER is unique;  -- Integer-Konstanten wie "42" oder "12_345_678"
  s_string             : INTEGER is unique;  -- String-Konstanten wie '"ha%/108/lo"'          
  s_character          : INTEGER is unique;  -- Character-Konstanten wie "'c'" oder "'%B'"    
  s_real               : INTEGER is unique;  -- Real-Konstante wie "1234.5678e-90"            
  s_bit_sequence       : INTEGER is unique;  -- 010101B          
  s_comment            : INTEGER is unique;  -- strings @ special enthält den Kommentar ohne die "--"                            
  s_eof                : INTEGER is unique;  -- unechtes Symbol: Dateiende                    

end -- SCANNER_SYMBOLS
