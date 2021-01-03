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

class ANCESTOR_NAME

-- Name of Ancestor of a CLASS_INTERFACE. This is a Class_name followed by a list
-- of ANCESTOR_NAMEs and formal generic names. The formal generics are those of the
-- CLASS_INTERFACE this is an ancestor of. 

inherit
	COMPARABLE
		redefine
			three_way_comparison
		end;
	CLASSES
		undefine
			is_equal
		end;
	FRIDISYS
		undefine
			is_equal
		end;
	
--------------------------------------------------------------------------------

creation	{ ANY } 
	make
	
creation { ANCESTOR_NAME, TYPE, GLOBAL_OBJECTS }
	make_class_type,
	make_formal_generic

--------------------------------------------------------------------------------
	
feature { ANY }

	name: INTEGER;            -- id of this class' name or 0 for formal_generic
	
feature { ANCESTOR_NAME }
	
	formal_generic: INTEGER;  -- number of formal generic of -1
	
feature { ANCESTOR_NAME, CLASS_INTERFACE }
	
	generics: LIST[ANCESTOR_NAME];  -- this class' actual generics
	
--------------------------------------------------------------------------------

feature { NONE }

	make (ci: CLASS_INTERFACE) is
		local
			i: INTEGER;
			g: ANCESTOR_NAME;
		do
			name := ci.key;
			formal_generic := -1;
			if ci.parse_class.formal_generics.is_empty then
				generics := empty_generics;
			else
memstats(250); 
				!!generics.make;
				from 
					i := 1
				until
					i > ci.parse_class.formal_generics.count
				loop
memstats(251); 
					!!g.make_formal_generic(i);
					generics.add(g);
					i := i + 1;
				end;
			end;
		end; -- make
		
	make_formal_generic(num: INTEGER) is
		do 
			name := 0;
			formal_generic := num;
		end; -- make_formal_generic
	
	make_class_type(new_name: INTEGER; new_generics: LIST[ANCESTOR_NAME]) is
		do 
			name := new_name;
			formal_generic := -1;
			if new_generics=Void then
				generics := empty_generics;
			else
				generics := new_generics;
			end;
		end; -- make_class_type

--------------------------------------------------------------------------------

feature { PARENT, FEATURE_INTERFACE, ANCESTOR_NAME }

	get_heirs_view (ci: CLASS_INTERFACE; type: CLASS_TYPE): ANCESTOR_NAME is
	-- Sicht dieses ANCESTOR_NAME, wenn er in ci mit Parent_clause.class_type=type
	-- geerbt wird.
		local
			i,j: INTEGER;
			gen_view: ANCESTOR_NAME;
			new_generics: LIST[ANCESTOR_NAME];
		do
			if name /= 0 then
				from 
					i := 1
				until
					i > generics.count
				loop
					gen_view := (generics @ i).get_heirs_view(ci,type);
					if gen_view /= generics @ i and then new_generics=Void then
						from
memstats(252); 
							!!new_generics.make;
							j := 1
						until
							j >= i
						loop
							new_generics.add(generics @ j)
							j := j + 1
						end;
					end;
					if new_generics /= Void then
						new_generics.add(gen_view)
					end;
					i := i + 1;
				end;
				if new_generics = Void then
					Result := Current
				else
memstats(253); 
					!!Result.make_class_type(name,new_generics);
				end;
			else
				Result := (type.actual_generics @ formal_generic).ancestor_name(ci);
			end;
		end; -- get_heirs_view

--------------------------------------------------------------------------------

feature { NONE }

	empty_generics: LIST[ANCESTOR_NAME] is
		once
			!!Result.make;
		end; -- empty_formal_generics

--------------------------------------------------------------------------------

feature { ANY }

	three_way_comparison (other: like Current): INTEGER is
		local
			i: INTEGER;
		do
			Result := name - other.name;
			if Result = 0 then
				if name /= 0 then
					from
						i := 1
					until
						i > generics.count or
						i > other.generics.count or
						Result /= 0
					loop
						Result := (generics @ i).three_way_comparison(other.generics @ i);
						i := i + 1
					end;
				else
					Result := other.formal_generic - formal_generic;
				end;
			end;
			if Result < 0 then
				Result := -1
			elseif Result > 0 then
				Result := 1
			end;
		end; -- three_way_comparison

	infix "<" (other: like Current): BOOLEAN is
		do
			Result := three_way_comparison(other) < 0;
		end; -- infix "<"

--------------------------------------------------------------------------------

	actual_class_name (actual: ACTUAL_CLASS_NAME): ACTUAL_CLASS_NAME is
	-- Der aktuelle Name des VorgŠngers in der aktuellen Klasse actual
		local
			actual_class_expanded: BOOLEAN;
			xx,xr: BOOLEAN;
		do
-- nyi: use actual_class.is_expanded
			actual_class_expanded := get_class(actual.name).parse_class.is_expanded;
			xx := actual.is_expanded  or else not actual.is_reference and then     actual_class_expanded;
			xr := actual.is_reference or else not actual.is_expanded  and then not actual_class_expanded;
			Result := internal_actual_class_name(actual,xx,xr);
		end; -- actual_class_name

	actual_class_name_of_generic (index: INTEGER; actual: ACTUAL_CLASS_NAME): ACTUAL_CLASS_NAME is
		do
			Result := (generics @ index).actual_class_name(actual);
		end; -- actual_class_name_of_generic

feature { ANCESTOR_NAME }

	internal_actual_class_name (actual: ACTUAL_CLASS_NAME; xx,xr: BOOLEAN): ACTUAL_CLASS_NAME is
		local
			list: LIST[ACTUAL_CLASS_NAME];
			i: INTEGER; 
		do
			if name/=0 then
				if not generics.is_empty then
memstats(7);
					!!list.make;
					from
						i := 1
					until
						i > generics.count
					loop
						list.add_tail((generics @ i).internal_actual_class_name(actual,false,false));
						i := i + 1;
					end;
				end;
memstats(8);
				if xx and then not get_class(name).parse_class.is_expanded then
					!!Result.make(name,true,false,list);
				elseif xr and then get_class(name).parse_class.is_expanded then					
					!!Result.make(name,false,true,list)
				else
					!!Result.make(name,false,false,list);
				end;
			else
				Result := actual.actual_generics @ formal_generic;
			end;
		end; -- internal_actual_class_name

--------------------------------------------------------------------------------

feature { ANY }

	true_class_name (tcn: TRUE_CLASS_NAME): TRUE_CLASS_NAME is
	-- Der wirkliche Name des VorgŠngers in der wirklichen Klasse tcn
		local
			actual_class_expanded: BOOLEAN;
			xx,xr: BOOLEAN;
		do
-- nyi: use tcn.is_expanded
			actual_class_expanded := get_class(tcn.name).parse_class.is_expanded;
			xx := tcn.is_expanded  or else not tcn.is_reference and then     actual_class_expanded;
			xr := tcn.is_reference or else not tcn.is_expanded  and then not actual_class_expanded;
			Result := internal_true_class_name(tcn,xx,xr);
		end; -- true_class_name

feature { ANCESTOR_NAME }

	internal_true_class_name (tcn: TRUE_CLASS_NAME; xx,xr: BOOLEAN): TRUE_CLASS_NAME is
		local
			list: LIST[TRUE_CLASS_NAME];
			i: INTEGER; 
		do
			if name/=0 then
				if not generics.is_empty then
memstats(7);
					!!list.make;
					from
						i := 1
					until
						i > generics.count
					loop
						list.add_tail((generics @ i).internal_true_class_name(tcn,false,false));
						i := i + 1;
					end;
				end;
memstats(8);
				if xx and then not get_class(name).parse_class.is_expanded then
					!!Result.make(name,true,false,list);
				elseif xr and then get_class(name).parse_class.is_expanded then					
					!!Result.make(name,false,true,list)
				else
					!!Result.make(name,false,false,list);
				end;
			else
				Result := tcn.actual_generics @ formal_generic;
			end;
		end; -- internal_true_class_name

--------------------------------------------------------------------------------

feature { ANY }

	print_name(ci: CLASS_INTERFACE) is
		local
			i: INTEGER;
		do
			if name/=0 then 
				write_string(strings @ name);
				if not generics.is_empty then
					write_string("[");
					from
						(generics @ 1).print_name(ci);
						i := 2;
					until
						i > generics.count
					loop
						write_string(",");
						(generics @ i).print_name(ci);
						i := i + 1;
					end;
					write_string("]");
				end;
			else
				write_string(strings @ (ci.parse_class.formal_generics @ formal_generic).name);
			end;
		end; -- print_name

--------------------------------------------------------------------------------

invariant
	name = 0 xor formal_generic <= 0;
	name /= 0 xor generics = Void;
end -- ANCESTOR_NAME
