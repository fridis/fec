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

class RECYCLE_OBJECTS

-- This class helps to overcome the current lack of a garbage collector. It
-- reuse the objects created during the code generation for a routine.

creation
	make

--------------------------------------------------------------------------------
	
feature

	make is
		do 
			feature_interfaces := Void;

			!!ass_cmds.make;
			!!ass_const_cmds.make;
			!!read_mem_cmds.make;
			!!write_mem_cmds.make;
			!!load_adr_cmds.make;
			!!call_cmds.make;
			!!ari_cmds.make;
			!!nop_cmds.make;
			!!bra_cmds.make;
			!!save_cmds.make;
			!!restore_cmds.make;
			!!return_cmds.make;
			!!fcmpe_cmds.make;
			!!sethi_cmds.make;
			!!setlo_cmds.make;

			!!args_lists.make;
			
			!!locals.make;
			!!blocks.make;
			!!off_inds.make;
			!!indexeds.make;
			!!boolvals.make;
			!!two_succs.make;
			!!one_succs.make;
			
			!!symbols.make;
			!!relocs.make;
			
		end; -- allocate

--------------------------------------------------------------------------------

	new_feature_interface : FEATURE_INTERFACE is
		do
			if feature_interfaces = Void then
memstats(399); 
				!!Result.clear;
			else
				Result := feature_interfaces;
				feature_interfaces := Result.joined;
				Result.clear;
			end;
		end; -- new_feature_interface

	forget_features(fi: FEATURE_INTERFACE) is
		do
			if fi.joined /= Void then
				forget_features(fi.joined);
			end;
			if fi.shared /= Void then
				forget_features(fi.shared);
			end;
			fi.set_joined(feature_interfaces); 
			feature_interfaces := fi;
		end; -- forget_joined_and_shared	

feature { NONE }

	feature_interfaces: FEATURE_INTERFACE;

--------------------------------------------------------------------------------

feature { ANY }

	new_ass_cmd (dst,src: LOCAL_VAR): ASSIGN_COMMAND is
		do
			ass_cmds_used := ass_cmds_used + 1
			if ass_cmds_used <= ass_cmds.count then
				Result := ass_cmds @ ass_cmds_used;
				Result.clear;
			else
memstats(400); 
				!!Result.clear;
				ass_cmds.add(Result);
			end;
			Result.make_assignment(dst,src);
		end; -- new_ass_cmd

	new_ass_const_cmd : ASSIGN_CONST_COMMAND is
		do
			ass_const_cmds_used := ass_const_cmds_used + 1
			if ass_const_cmds_used <= ass_const_cmds.count then
				Result := ass_const_cmds @ ass_const_cmds_used;
				Result.clear;
			else
memstats(428); 
				!!Result.clear;
				ass_const_cmds.add(Result);
			end;
		end; -- new_ass_const_cmd

	new_read_mem_cmd : READ_MEM_COMMAND is
		do
			read_mem_cmds_used := read_mem_cmds_used + 1
			if read_mem_cmds_used <= read_mem_cmds.count then
				Result := read_mem_cmds @ read_mem_cmds_used;
				Result.clear;
			else
memstats(429); 
				!!Result.clear;
				read_mem_cmds.add(Result);
			end;
		end; -- new_read_mem_cmd

	new_write_mem_cmd : WRITE_MEM_COMMAND is
		do
			write_mem_cmds_used := write_mem_cmds_used + 1
			if write_mem_cmds_used <= write_mem_cmds.count then
				Result := write_mem_cmds @ write_mem_cmds_used;
				Result.clear;
			else
memstats(430); 
				!!Result.clear;
				write_mem_cmds.add(Result);
			end;
		end; -- new_write_mem_cmd

	new_load_adr_cmd (dst,src: LOCAL_VAR): LOAD_ADR_COMMAND is
		do
			load_adr_cmds_used := load_adr_cmds_used + 1
			if load_adr_cmds_used <= load_adr_cmds.count then
				Result := load_adr_cmds @ load_adr_cmds_used;
				Result.clear;
			else
memstats(431); 
				!!Result.clear;
				load_adr_cmds.add(Result);
			end;
			Result.make_load_address(dst,src);
		end; -- new_load_adr_cmd

	new_call_cmd : CALL_COMMAND is
		do
			call_cmds_used := call_cmds_used + 1
			if call_cmds_used <= call_cmds.count then
				Result := call_cmds @ call_cmds_used;
				Result.clear;
			else
memstats(401); 
				!!Result.clear;
				call_cmds.add(Result);
			end;
		end; -- new_call_cmd

	new_ari_cmd : ARITHMETIC_COMMAND is
		do
			ari_cmds_used := ari_cmds_used + 1
			if ari_cmds_used <= ari_cmds.count then
				Result := ari_cmds @ ari_cmds_used;
				Result.clear;
			else
memstats(402); 
				!!Result.clear;
				ari_cmds.add(Result);
			end;
		end; -- new_ari_cmd

	new_nop_cmd : NOP_COMMAND is
		do
			nop_cmds_used := nop_cmds_used + 1
			if nop_cmds_used <= nop_cmds.count then
				Result := nop_cmds @ nop_cmds_used;
				Result.clear;
			else
memstats(440); 
				!!Result.clear;
				nop_cmds.add(Result);
			end;
		end; -- new_nop_cmd

	new_bra_cmd(fb: BOOLEAN; cnd: INTEGER; to: BASIC_BLOCK) : BRANCH_COMMAND is
		do
			bra_cmds_used := bra_cmds_used + 1
			if bra_cmds_used <= bra_cmds.count then
				Result := bra_cmds @ bra_cmds_used;
				Result.clear;
			else
memstats(441); 
				!!Result.clear;
				bra_cmds.add(Result);
			end;
			Result.make(fb,cnd,to);
		end; -- new_bra_cmd

	new_save_cmd : SAVE_COMMAND is
		do
			save_cmds_used := save_cmds_used + 1
			if save_cmds_used <= save_cmds.count then
				Result := save_cmds @ save_cmds_used;
				Result.clear;
			else
memstats(442); 
				!!Result.clear;
				save_cmds.add(Result);
			end;
		end; -- new_save_cmd

	new_restore_cmd : RESTORE_COMMAND is
		do
			restore_cmds_used := restore_cmds_used + 1
			if restore_cmds_used <= restore_cmds.count then
				Result := restore_cmds @ restore_cmds_used;
				Result.clear;
			else
memstats(443); 
				!!Result.clear;
				restore_cmds.add(Result);
			end;
		end; -- new_restore_cmd

	new_return_cmd : RETURN_COMMAND is
		do
			return_cmds_used := return_cmds_used + 1
			if return_cmds_used <= return_cmds.count then
				Result := return_cmds @ return_cmds_used;
				Result.clear;
			else
memstats(444); 
				!!Result.clear;
				return_cmds.add(Result);
			end;
		end; -- new_return_cmd

	new_fcmpe_cmd : FCMPE_COMMAND is
		do
			fcmpe_cmds_used := fcmpe_cmds_used + 1
			if fcmpe_cmds_used <= fcmpe_cmds.count then
				Result := fcmpe_cmds @ fcmpe_cmds_used;
				Result.clear;
			else
memstats(490); 
				!!Result.clear;
				fcmpe_cmds.add(Result);
			end;
		end; -- new_fcmpe_cmd

	new_sethi_cmd : SETHI_COMMAND is
		do
			sethi_cmds_used := sethi_cmds_used + 1
			if sethi_cmds_used <= sethi_cmds.count then
				Result := sethi_cmds @ sethi_cmds_used;
				Result.clear;
			else
memstats(445); 
				!!Result.clear;
				sethi_cmds.add(Result);
			end;
		end; -- new_sethi_cmd

	new_setlo_cmd : SETLO_COMMAND is
		do
			setlo_cmds_used := setlo_cmds_used + 1
			if setlo_cmds_used <= setlo_cmds.count then
				Result := setlo_cmds @ setlo_cmds_used;
				Result.clear;
			else
memstats(480); 
				!!Result.clear;
				setlo_cmds.add(Result);
			end;
		end; -- new_setlo_cmd

----

	new_args_list : LIST[LOCAL_VAR] is
		do
			args_lists_used := args_lists_used + 1
			if args_lists_used <= args_lists.count then
				Result := args_lists @ args_lists_used;
				Result.make;
			else
memstats(312); 
				!!Result.make;
				args_lists.add(Result);
			end;
		end; -- new_args_list

	new_local(code: ROUTINE_CODE; type: LOCAL_TYPE) : LOCAL_VAR is
		do
			locals_used := locals_used + 1
			if locals_used <= locals.count then
				Result := locals @ locals_used;
				Result.clear;
			else
memstats(403); 
				!!Result.clear;
				locals.add(Result);
			end;
			Result.make_local(code,type);
		end; -- new_local

	new_block (weight: INTEGER) : BASIC_BLOCK is
		do
			blocks_used := blocks_used + 1
			if blocks_used <= blocks.count then
				Result := blocks @ blocks_used;
				Result.clear;
			else
memstats(404); 
				!!Result.clear;
				blocks.add(Result);
			end;
			Result.make(weight);
		end; -- new_block

	new_off_ind : OFFSET_INDIRECT_VALUE is
		do
			off_inds_used := off_inds_used + 1
			if off_inds_used <= off_inds.count then
				Result := off_inds @ off_inds_used;
				Result.clear;
			else
memstats(405); 
				!!Result.clear;
				off_inds.add(Result);
			end;
		end; -- new_off_ind

	new_indexed : INDEXED_VALUE is
		do
			indexeds_used := indexeds_used + 1
			if indexeds_used <= indexeds.count then
				Result := indexeds @ indexeds_used;
				Result.clear;
			else
memstats(406); 
				!!Result.clear;
				indexeds.add(Result);
			end;
		end; -- new_indexed

	new_boolval : BOOLEAN_VALUE is
		do
			boolvals_used := boolvals_used + 1
			if boolvals_used <= boolvals.count then
				Result := boolvals @ boolvals_used;
				Result.clear;
			else
memstats(407); 
				!!Result.clear;
				boolvals.add(Result);
			end;
		end; -- new_boolval

	new_two_succ : TWO_SUCCESSORS is
		do
			two_succs_used := two_succs_used + 1
			if two_succs_used <= two_succs.count then
				Result := two_succs @ two_succs_used;
				Result.clear;
			else
memstats(408); 
				!!Result.clear;
				two_succs.add(Result);
			end;
		end; -- new_two_succ

	new_one_succ (new_next: BASIC_BLOCK) : ONE_SUCCESSOR is
		do
			one_succs_used := one_succs_used + 1
			if one_succs_used <= one_succs.count then
				Result := one_succs @ one_succs_used;
				Result.clear;
			else
memstats(409); 
				!!Result.clear;
				one_succs.add(Result);
			end;
			Result.make(new_next);
		end; -- new_one_succ

	forget_commands is
		do
			ass_cmds_used := 0;
			ass_const_cmds_used := 0;
			read_mem_cmds_used := 0;
			write_mem_cmds_used := 0;
			load_adr_cmds_used := 0;
			call_cmds_used := 0;
			ari_cmds_used := 0;
			nop_cmds_used := 0;
			bra_cmds_used := 0;
			save_cmds_used := 0;
			restore_cmds_used := 0;
			return_cmds_used := 0;
			fcmpe_cmds_used := 0;
			sethi_cmds_used := 0;
			setlo_cmds_used := 0;
			args_lists_used := 0;
			locals_used := 0;
			blocks_used := 0;
			off_inds_used := 0;
			indexeds_used := 0;
			boolvals_used := 0;
			two_succs_used := 0;
			one_succs_used := 0;
		end; -- forget_commands
		
--------------------------------------------------------------------------------

	new_symbol : SYMBOL is
		do
			symbols_used := symbols_used + 1
			if symbols_used <= symbols.count then
				Result := symbols @ symbols_used;
				Result.clear;
			else
memstats(448); 
				!!Result.clear;
				symbols.add(Result);
			end;
		end; -- new_symbol

	new_reloc : RELOC is
		do
			relocs_used := relocs_used + 1
			if relocs_used <= relocs.count then
				Result := relocs @ relocs_used;
				Result.clear;
			else
memstats(451); 
				!!Result.clear;
				relocs.add(Result);
			end;
		end; -- new_reloc

	forget_machine_code is
		do
			symbols_used := 0;
			relocs_used := 0;
		end; -- forget_machine_code

--------------------------------------------------------------------------------

feature { NONE }

	ass_cmds : LIST[ASSIGN_COMMAND];
	ass_cmds_used : INTEGER;
	ass_const_cmds : LIST[ASSIGN_CONST_COMMAND];
	ass_const_cmds_used : INTEGER;
	read_mem_cmds : LIST[READ_MEM_COMMAND];
	read_mem_cmds_used : INTEGER;
	write_mem_cmds : LIST[WRITE_MEM_COMMAND];
	write_mem_cmds_used : INTEGER;
	load_adr_cmds : LIST[LOAD_ADR_COMMAND];
	load_adr_cmds_used : INTEGER;
	call_cmds: LIST[CALL_COMMAND];
	call_cmds_used: INTEGER;
	ari_cmds: LIST[ARITHMETIC_COMMAND];
	ari_cmds_used: INTEGER;
	nop_cmds: LIST[NOP_COMMAND];
	nop_cmds_used: INTEGER;
	bra_cmds: LIST[BRANCH_COMMAND];
	bra_cmds_used: INTEGER;
	save_cmds: LIST[SAVE_COMMAND];
	save_cmds_used: INTEGER;
	restore_cmds: LIST[RESTORE_COMMAND];
	restore_cmds_used: INTEGER;
	return_cmds: LIST[RETURN_COMMAND];
	return_cmds_used: INTEGER;
	fcmpe_cmds: LIST[FCMPE_COMMAND];
	fcmpe_cmds_used: INTEGER;
	sethi_cmds: LIST[SETHI_COMMAND];
	sethi_cmds_used: INTEGER;
	setlo_cmds: LIST[SETLO_COMMAND];
	setlo_cmds_used: INTEGER;
	args_lists: LIST[LIST[LOCAL_VAR]];
	args_lists_used: INTEGER;
	locals: LIST[LOCAL_VAR];
	locals_used: INTEGER;
	blocks: LIST[BASIC_BLOCK];
	blocks_used: INTEGER;
	off_inds: LIST[OFFSET_INDIRECT_VALUE];
	off_inds_used: INTEGER;
	indexeds: LIST[INDEXED_VALUE];
	indexeds_used: INTEGER;
	boolvals: LIST[BOOLEAN_VALUE];
	boolvals_used: INTEGER;
	two_succs: LIST[TWO_SUCCESSORS];
	two_succs_used: INTEGER;
	one_succs: LIST[ONE_SUCCESSOR];
	one_succs_used: INTEGER;
	symbols: LIST[SYMBOL]
	symbols_used: INTEGER;
	relocs: LIST[RELOC];
	relocs_used: INTEGER;

--------------------------------------------------------------------------------
		
end -- RECYCLE_OBJECTS
