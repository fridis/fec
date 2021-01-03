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

class FEC

-- Fridi«s Eiffel Compiler 
--
-- The root class. Root feature is FEC.make.

inherit
	FRIDISYS; 
	ACTUAL_CLASSES;
	ERRORS;
	ARGUMENTS;

creation 
	make

--------------------------------------------------------------------------------
   
feature { NONE }

	project_name: STRING; 
	
	root_name, root_creation: STRING;

	root: CLASS_INTERFACE;

--------------------------------------------------------------------------------

  	make is
  		do 
  			globals.allocate;
			msg.write(msg.name_and_version); 
  			check_arguments;
  			if project_name /= Void then
  				read_environment;
  				if root_name /= Void then
					unvalidated.make;
					root := get_class(strings # root_name);
					check_validity;
					if error_status.error_count = 0 then
						check_root_creation;
					end;
					if error_status.error_count > 0 then
						msg.write(msg.lf); write_integer(error_status.error_count); msg.write(msg.errors_found); 
					else
						-- write_integer(globals.num_routines-globals.num_inherited); write_string(" internal routines%N"); 
						-- write_integer(globals.num_inherited); write_string(" inherited routines%N");
						-- write_integer(globals.max_locals); write_string(" locals used (max)%N");
						-- write_integer(globals.total_locals // globals.num_routines); write_string(" locals used (average)%N");
						write_integer(globals.total_insns * 4); msg.write(msg.bytes_mc_created);
					end;
				end;
			end; 	
-- show_memory_statistics
		end;  -- make 

--------------------------------------------------------------------------------

	check_arguments is
		local
			dot: INTEGER;
		do
  			if argument_count/=1 then 
  				msg.write(msg.usage); 
  			else
memstats(346);
				!!project_name.make_from_string(argument(1));
				project_name.to_lower;
				dot := project_name.index_of('.',1);
				if dot > 0 then -- remove suffix
					project_name.head(dot-1);
				end;
			end;
		end; -- check_arguments

--------------------------------------------------------------------------------

	read_environment is
		local
			env_file: STD_FILE_READ;
			new_env_file: STD_FILE_WRITE;
			env_file_name, key, arg: STRING;
			blank: INTEGER;
			error: BOOLEAN;
		do
			!!env_file.make;
			!!env_file_name.make(128);
			env_file_name.copy(project_name);
			env_file_name.append(".env");
			env_file.connect_to(env_file_name);
			if not env_file.is_connected then
				env_file_name.copy(project_name);
				env_file_name.to_upper;
				env_file_name.append(".env");
				env_file.connect_to(env_file_name);
			end;
			if not env_file.is_connected then
				env_file_name.copy(project_name);
				env_file_name.append(".env");
				msg.write(msg.created_file_prefix); write_string(env_file_name);
				!!new_env_file.connect_to(env_file_name);
				if new_env_file.is_connected then
					msg.write(msg.lf);
					new_env_file.put_string("-- Eiffel project environment:%N%
					                        %%N%
					                        %-- Root class for this system:%N%
					                        %ROOT_CLASS ");
					new_env_file.put_string(project_name);
					new_env_file.put_string("%N-- Root creation procedure:%N%
					                        %ROOT_CREATION make%N%
					                        %%N%
					                        %-- Checking Mode:%N%
					                        %-- Set this to one of NONE, REFERENCE, REQUIRE, ENSURE, INVARIANT, LOOP, ALL or DEBUG%N%
					                        %CHECK ALL%N%
					                        %%N%
					                        %-- Name of executable program to create:%N%
					                        %EXECUTABLE ");
					new_env_file.put_string(project_name);
					new_env_file.put_string("%N%
					                        %%N%
					                        %-- Load path to look for source texts:%N%
					                        %LOADPATH%N%
					                        %LOADPATH src/%N%
					                        %LOADPATH std_lib/%N%
					                        %%N%
					                        %-- Either %"gcc%" or %"cc%" may be used to link the system:%N%
					                        %LINKER gcc%N");
					new_env_file.disconnect;
					msg.write(msg.env_created);
				else
					msg.write(msg.couldnt_save);
				end;
			else
				msg.write(msg.read_file_prefix); 
  				write_string(env_file_name); 
				msg.write(msg.lf); 
				!!key.make(128);
				!!arg.make(128);
				from		
					error := false;
					root_name := project_name;
					root_creation := "make";
					globals.set_linker("gcc");
					globals.set_executable(project_name);
				until
					env_file.end_of_input or
					error 
				loop
					env_file.read_line;
					key.copy(env_file.last_string);
					arg.copy(key);
					if key.count > 0 and then key @ 1 /= '-' then
						blank := key.index_of(' ',1);
						if blank = 0 then 
							blank := key.count + 1;
						end;
						key.head(blank-1);
						key.to_upper;
						arg.tail(arg.count - (blank - 1));
						arg.left_adjust;
						arg.right_adjust;
						if     key.is_equal("ROOT_CLASS") then
							!!root_name.make_from_string(arg);
							root_name.to_lower;
						elseif key.is_equal("ROOT_CREATION") then
							!!root_creation.make_from_string(arg);
							root_creation.to_lower;
						elseif key.is_equal("CHECK") then
							arg.to_upper;
							if     arg.is_equal("NONE"     ) then globals.set_no_check
							elseif arg.is_equal("REFERENCE") then globals.set_reference_check
							elseif arg.is_equal("REQUIRE"  ) then globals.set_require_check
							elseif arg.is_equal("ENSURE"   ) then globals.set_ensure_check
							elseif arg.is_equal("INVARIANT") then globals.set_invariant_check
							elseif arg.is_equal("LOOP"     ) then globals.set_loop_check
							elseif arg.is_equal("ALL"      ) then globals.set_all_check
							elseif arg.is_equal("DEBUG"    ) then globals.set_debug_check
							else 
								error := true;
							end;
						elseif key.is_equal("LOADPATH"  ) then globals.add_loadpath  (clone(arg));
						elseif key.is_equal("LINKER"    ) then globals.set_linker    (clone(arg));
						elseif key.is_equal("EXECUTABLE") then globals.set_executable(clone(arg));
						else
							error := true;
						end;
					end;
				end;   -- loop
				if error then
					msg.write(msg.error_in_enviro_a); 
					write_string(env_file.last_string);
					msg.write(msg.error_in_enviro_b);
					root_name := Void
				end; 
				env_file.disconnect;				
			end;
		end; -- read_environment

--------------------------------------------------------------------------------

	check_root_creation is
  		local
  			f: FEATURE_INTERFACE;
		do
			if not root.parse_class.formal_generics.is_empty then
				root.parse_class.name_position.error(msg.vsrc1);
			else
				f := root.feature_list.find(strings # root_creation);
				if f=Void or else 
				   root.parse_class.creators=Void or else
				   root.parse_class.creators.find(strings # root_creation) = Void 
				then
					msg.write(msg.error_in_system);
					msg.write(msg.vsrc3);
					error_status.inc_error_count;
				elseif not f.formal_arguments.is_empty or else f.type /= Void then
					f.position.error(msg.vsrc2);
				else
					compile_classes(root,strings # root_creation);
					msg.write(msg.ok);
				end;
			end;
		end; -- check_root_creation

--------------------------------------------------------------------------------

end -- FEC
