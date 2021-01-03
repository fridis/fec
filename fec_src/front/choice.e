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

class CHOICE

inherit
	SCANNER_SYMBOLS
		undefine
			is_equal
		end;
	PARSE_MANIFEST_CONSTANT
		rename
			constant as manifest_constant
		export
			{ NONE } manifest_constant
		undefine
			is_equal
		end;
	SORTABLE[INTEGER];
	FRIDISYS
		undefine
			is_equal
		end;

creation
	parse
	
--------------------------------------------------------------------------------

feature { ANY }

	constant_attribute : INTEGER;      -- id von Constant attribute, sonst 0

	lower, upper : MANIFEST_CONSTANT;  -- Bei Interval, sonst Void

	is_integer: BOOLEAN;               -- Integer oder Character
	
-- key: INTEGER;                      -- (geerbt): Synonym für lower_value, 
                                      -- sollte eigentlich umbenannt werden, 
                                      -- sebug: wg. Fehler in SE
	
	lower_value, upper_value: INTEGER; 	

	unique_feature: FEATURE_INTERFACE;

	position: POSITION;
	
--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Choice = Constant | Interval.
	-- Interval = Integer_interval | Character_interval.
	-- Interger_interval = Integer_constant ".." Integer_constant.
	-- Character_interval = Character_constant ".." Character_constant.
		do
			position := s.current_symbol.position;
			if s.current_symbol.type = s_identifier then
				s.check_and_get_identifier(0);
				constant_attribute := s.last_identifier;
			else
				parse_manifest_constant(s);
				lower := manifest_constant; 
				if s.current_symbol.type = s_double_dot then
					s.next_symbol;
					parse_manifest_constant(s);
					upper := manifest_constant;
				end;
			end;
		end; -- parse
				 
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE; int: BOOLEAN) is
	-- int is true for integer inspect instruction, false for character.
		local
			ic: INTEGER_CONSTANT;
			cc: CHARACTER_CONSTANT;
			f: FEATURE_INTERFACE;
			typ_bug: BOOLEAN;
			mcv: MANIFEST_CONSTANT_VALUE;
			unique_value: UNIQUE_VALUE;
		do
			if constant_attribute /= 0 then
				f := fi.interface.feature_list.find(constant_attribute);
				if f = Void or else not f.feature_value.is_constant_attribute then
					position.error(msg.vwca1);
				else
					if f.type = Void or else
						int and then not f.type.is_integer or else
						not int and then not f.type.is_character 
					then
						typ_bug := true;
					else
						unique_value ?= f.feature_value;
						if unique_value /= Void then
							unique_feature := f;
							lower_value := unique_value.value;
						else
							mcv ?= f.feature_value;
							if int then
								ic ?= mcv.constant;
								lower_value := ic.value;
							else
								cc ?= mcv.constant;
								lower_value := cc.value.code;
							end;
						end;		
						upper_value := lower_value;				
					end;
				end; 
			else
				if int then
					ic ?= lower;
					if ic /= Void then
						lower_value := ic.value;
						upper_value := lower_value;
						if upper /= Void then
							ic ?= upper;
							if ic /= Void then 
								upper_value := ic.value
							else
								typ_bug := true;
							end;
						end;
					else
						typ_bug := true
					end;
				else	   
					cc ?= lower;
					if cc /= Void then
						lower_value := cc.value.code;
						upper_value := lower_value;
						if upper /= Void then
							cc ?= upper;
							if cc /= Void then 
								upper_value := cc.value.code
							else
								typ_bug := true;
							end;
						end;
					else
						typ_bug := true
					end;
				end;
			end;
			if typ_bug then
				position.error(msg.vomb1);
			end;
			key := lower_value; -- sebug: nur wg. SE nötig!
		end; -- validity

--------------------------------------------------------------------------------

end -- CHOICE			
			
