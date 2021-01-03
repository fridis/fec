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

class MIDDLE_ANCESTOR

-- An entry in the ANCESTOR-List of a class

inherit
	SORTABLE[ANCESTOR_NAME];
	FRIDISYS;

creation -- don't create objects of this class
	
--------------------------------------------------------------------------------
	
feature { ANY }

--	key: ANCESTOR_NAME;       -- Name des VorgŠngers

	position: POSITION;       -- Position des ersten Parents, das diesen Ancestor
	                          -- in die neue Klasse einfŸgt

	features: ARRAY[FEATURE_INTERFACE];

feature { NONE }

	ambiguous: ARRAY[BOOLEAN];     -- true fŸr mehrdeutige EintrŠge
	
	selects: ARRAY[FEATURE_LIST];  -- die Select-Listen der Parent-Clauses,
	                               -- durch das die Features geerbt wurden

--------------------------------------------------------------------------------

feature { ANY }

	make_this_class (ci: CLASS_INTERFACE) is
		local
			an: ANCESTOR_NAME; -- sebug: !!key liefert "creation on formal generic..."
		do
memstats(248); 
			!!an.make(ci);
			key := an;
			position := ci.parse_class.name_position;
		end; -- make
		
	make_parent (new_key: ANCESTOR_NAME; 
	             new_pos: POSITION) is
		do
			key := new_key;
			position := new_pos;
		end; -- make_parent

--------------------------------------------------------------------------------

	set_features (feat: ARRAY[FEATURE_INTERFACE]; num_dynamic: INTEGER) is
	-- dies wird fŸr die neue Klasse verwendet, die ihr eigener ancestor ist.
	-- features bekommt fŸr jedes dynamische Feature einen eintrag an dessen nummer
		local
			i: INTEGER; 
			fi: FEATURE_INTERFACE;
		do
memstats(249); 
			!!features.make(1,num_dynamic);
			from
				i := 1
			until
				i > feat.upper
			loop
				fi := feat @ i;
				if fi.number > 0 then
					features.put(fi,fi.number)
				end;
				i := i + 1
			end; 
			ambiguous := Void;
			selects := Void;
		end; -- set_features

	allocate_features (num: INTEGER) is
	-- alloziert Platz fŸr die Features eines echten VorgŠngers
		do
memstats(4);
			!!features.make(1,num);
memstats(5);
			!!ambiguous.make(1,num);
memstats(6);
			!!selects.make(1,num);
		end; -- allocate_features

--------------------------------------------------------------------------------

	set (index: INTEGER; value: FEATURE_INTERFACE; select_list: FEATURE_LIST) is
	-- setzt Feature mit angegebenem index auf value. is_selected gibt an, ob
	-- dieses feature selectiert wurde und beeinflu§t so ersetzen des features.
		local
			old_set: FEATURE_INTERFACE;
		do
			old_set := features @ index;
			if select_list.has_feat(value.key) then
				if old_set /= Void and
				   old_set /= value 
				then
					ambiguous.put(true,index);
					if (selects @ index).has_feat(old_set.key) then 
						select_list.error_at(value.key,msg.vmrc1);
					else
					end;
				end;
				features.put(value,index);
				selects.put(select_list,index);
			else
				if old_set /= value then
					if old_set = Void then
						features.put(value,index);
						selects.put(select_list,index);
					else
						ambiguous.put(true,index);
					end;
				end;
			end;
		end; -- set

--------------------------------------------------------------------------------

	check_selects is
		-- ŸberprŸft, ob alle mehrdeutigen Features mit select ausgewŠhlt wurden und
		-- setzt used in diesen Selects.
		local
			i: INTEGER; 
		do
			if ambiguous /= Void then
				from 
					i := ambiguous.lower
				until
					i > ambiguous.upper
				loop
					if ambiguous @ i then
						if not (selects @ i).has_and_used((features @ i).key) then
							position.error_m(<<msg @ msg.vmrc2a,strings @ (features @ i).key,
							                   msg @ msg.vmrc2b,strings @ key.name,
							                   msg @ msg.vmrc2c>>);
						end; 
					end; 
					i := i + 1;
				end; 
			end;
		end; -- check_selects
		
--------------------------------------------------------------------------------

end -- MIDDLE_ANCESTOR
