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

class CLASSES

-- Global list of classes in this system.

inherit
	FRIDISYS;
	ERRORS;

--------------------------------------------------------------------------------
	
feature { NONE }

	scanners: LIST[SCANNER] is 
		once
memstats(27);
			!!Result.make
		end; -- scanners

	class_list : PS_ARRAY[INTEGER,CLASS_INTERFACE] is
		once
memstats(28);
			!!Result.make;
		end; -- class_list

--------------------------------------------------------------------------------

feature { ANY }

	get_parse_class (name: INTEGER): PARSE_CLASS is
	-- parst die Klasse mit dem angegebenem Namen. 
	-- Ist need_new_copy=true, so wird ein neuer abstrakter Syntaxbaum erzeugt, in
	-- den dann auch Informationen gespeichert werden kûnnen.
		local
			source_file: STD_FILE_READ;
			source_file_name: STRING;
			name_str, upper_name_str: STRING;
			scanner: SCANNER;
			i: INTEGER;
		do
			name_str := strings @ name;
memstats(449);
			!!upper_name_str.make_from_string(name_str);
			upper_name_str.to_upper;
memstats(30);
			!!source_file_name.make(128);
			from
				i := 1;
				memstats(29);
				!!source_file.make;
			until
				i > globals.num_loadpaths or
				source_file.is_connected
			loop
				source_file_name.copy(globals.loadpath @ i); 
				source_file_name.append(name_str);
				source_file_name.append(".e");
				source_file.connect_to(source_file_name);
				if not source_file.is_connected then
					source_file_name.copy(globals.loadpath @ i); 
					source_file_name.append(upper_name_str);
					source_file_name.append(".e");
					source_file.connect_to(source_file_name);
				end;
				i := i + 1;
			end;
	  		if source_file.is_connected then	  			
				msg.write(msg.read_file_prefix); 
  				write_string(source_file_name); 
				msg.write(msg.lf); 
memstats(31);
				!!scanner.make(name,source_file,source_file_name,scanners.count+1);
				source_file.disconnect;
			end
			if scanner /= Void then
				scanner.reset;
memstats(32);
				!!Result.parse(scanner,name);
			else
				msg.write(msg.error);
				if name = globals.string_any then
					msg.write(msg.vhay1);
				else 
					msg.write(msg.missing_source_a);
					write_string(strings @ name);
					msg.write(msg.missing_source_b);
				end;
				msg.write(msg.lf);
				error_status.inc_error_count;
memstats(33);
				!!Result.make_dummy(name);
			end; 
		ensure
			Result /= Void
		end; -- get_parse_class	

--------------------------------------------------------------------------------

	get_class (name: INTEGER): CLASS_INTERFACE is
	-- holt das Interface der Klasse mit dem angegebenem Typ. 
	-- Dazu werden auch die Interfaces aller VorgÉngerklassen mittels get_class bestimmt, jedoch noch 
	-- nicht die verwendeten Klassen bestimmt, dies geschieht bei der Validity-PrÄfung.
		require
			name /= globals.string_ref
		local
			pc: PARSE_CLASS;
		do
--print("get_class:%N");
			if name = globals.string_none then
				Result := none
			else
--print("find:%N");
				Result := class_list.find(name);
--print("find done.%N");
				if Result /= Void then
					if Result.getting_inherited then
						Result.parse_class.name_position.error(msg.vhpr1);
memstats(34);
						!!Result.make_dummy(name); 
					end;
				else	
memstats(35);
					!!Result.make(get_parse_class(name),class_list);
					if error_status.error_count = 0 then
						unvalidated.add_tail(Result);
					end;
				end;
			end;
--print("get_class done.%N");
		end; -- get_class

feature { NONE }

	none: CLASS_INTERFACE is
		once
memstats(36);
			!!Result.make_none
		end; -- none;

--------------------------------------------------------------------------------

	unvalidated: LIST[CLASS_INTERFACE] is
		once
memstats(37);
			!!Result.make
		end; -- unvalidated;

feature { ANY }

	check_validity is
		local
			validated: INTEGER;
		do
			from
				validated := 1;
			until
				validated > unvalidated.count or else
				error_status.error_count > 0
			loop
				(unvalidated @ validated).validity;
				validated := validated + 1
			end;
		end;

--------------------------------------------------------------------------------
		
end -- CLASSES
