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

class ROUTINE_CODE

-- Code generation for one routine.
--
-- Backend class specific for SUN/SPARC 

inherit
	MIDDLE_ROUTINE_CODE
		rename
			make as middle_make,
			init as middle_init
		end;
	SPARC_CONSTANTS;
	DATATYPE_SIZES;
	FRIDISYS;

--------------------------------------------------------------------------------

creation { FEATURE_INTERFACE }
	make

--------------------------------------------------------------------------------

feature { NONE }
	
	make is 
		local
			i: INTEGER;
			new_reg: LOCAL_VAR;
		do
			middle_make;
memstats(414);
			!!registers.make(r0,r0+31);
			from 
				i := r0
			until
				i > r0+31
			loop
memstats(415);
				!!new_reg.make_gpr(i);
				registers.put(new_reg,i);
				i := i + 1;
			end;
memstats(496);
			!!fp_registers.make(f0,f0+31);
			!!dfp_registers.make(f0,f0+31);
			from 
				i := f0
			until
				i > f0+31
			loop
memstats(497);
				!!new_reg.make_fpr(i);
				fp_registers.put(new_reg,i);
				if i \\ 2 = 0 then
memstats(495);
					!!new_reg.make_dfpr(i);
					dfp_registers.put(new_reg,i);
				end;
				i := i + 1;
			end;
			!!c_temp1_register.make_gpr_character(temp1);
			!!c_temp2_register.make_gpr_character(temp2);

		end;	-- make	

--------------------------------------------------------------------------------

	symbol_name: INTEGER;         -- Symbol of this routine.
				
--------------------------------------------------------------------------------
	
feature { FEATURE_INTERFACE }

	init (is_precondition: BOOLEAN;
	      new_class_code: CLASS_CODE; 
			new_fi: FEATURE_INTERFACE;
	      current_type: LOCAL_TYPE;
	      result_type: TYPE) is 
	-- result_type ist der Typ fŸr result_local oder Void.
		require
			current_type.is_reference or current_type.is_pointer
		local
			cur: ROUTINE_CODE;
		do
			stack_arguments_size := minimum_arguments_size; 
			stack_frame_size := -1;    -- this is set by allocate_stack
			last_fp_register_used := -1; 
			middle_init(new_class_code,new_fi,current_type,result_type);
			if is_precondition then
				symbol_name := get_precondition_name(new_class_code.actual_class.key.code_name,new_fi.key);
			else
				symbol_name := get_symbol_name      (new_class_code.actual_class.key.code_name,new_fi.key);
			end;
			(registers @ (o0+0)).add_to_locals(locals); 
			(registers @ (o0+1)).add_to_locals(locals); 
			(registers @ (o0+2)).add_to_locals(locals); 
			(registers @ (o0+3)).add_to_locals(locals); 
			(registers @ (o0+4)).add_to_locals(locals); 
			(registers @ (o0+5)).add_to_locals(locals);
			(registers @ fp    ).add_to_locals(locals);
			(registers @ sp    ).add_to_locals(locals);
			(registers @ (i0+0)).add_to_locals(locals);
			(registers @ (i0+1)).add_to_locals(locals);
			(registers @ (i0+2)).add_to_locals(locals);
			(registers @ (i0+3)).add_to_locals(locals);
			(registers @ (i0+4)).add_to_locals(locals);
			(registers @ (i0+5)).add_to_locals(locals);
			(registers @ (i0+7)).add_to_locals(locals);

			-- g0 is read by ari-cmd and so gets involved into live-time determination...
			(registers @ g0    ).add_to_locals(locals); 
						
			( fp_registers @ f0).add_to_locals(locals); -- we need %f0 for return real/double results
			(dfp_registers @ f0).add_to_locals(locals);
		end; -- init
		
--------------------------------------------------------------------------------
	
feature { ANY }

	create_code is
		do
--write_string("%N%Ncreate code:%Noriginal:%N");
--print_blocks;
			expand_commands;
--write_string("%Nexpanded:%N");
--print_blocks;
			-- copy_propagation;
			allocate_registers;
			allocate_stack;
--write_string("%Nregs allocated:%N");
--print_blocks;
			expand2_commands;
			-- insn_scheduling;
--write_string("%Nexpanded2:%N");
--print_blocks;
--write_string("%Nmachine_code:%N");
--print_machine_code;
			create_machine_code;
		end; -- create_code
	
--------------------------------------------------------------------------------

feature { COMMAND, BLOCK_SUCCESSORS }

	registers: ARRAY[LOCAL_VAR];  -- %r0, %r1, ... , %r31

	fp_registers: ARRAY[LOCAL_VAR];   -- %f0..%f31

	dfp_registers: ARRAY[LOCAL_VAR];   -- %f0..%f30, for doubles

-- temporary registers for integers:

	temp1_register: LOCAL_VAR is 
		do
			Result := registers @ temp1
		end;  -- temp1_register
		
	temp2_register: LOCAL_VAR is
		do
			Result := registers @ temp2
		end; -- temp2_register

-- temporary registers for characters:

	c_temp1_register: LOCAL_VAR;
	c_temp2_register: LOCAL_VAR;

-- temporary registers for reals:

	f_temp1_register: LOCAL_VAR is
	-- temporary fp reg
		do
			Result := fp_registers @ f_temp1
		end; -- f_temp1_register

	f_temp2_register: LOCAL_VAR is
		do
			Result := fp_registers @ f_temp2
		end; -- f_temp2_register

-- temporary registers for doubles:

	df_temp1_register: LOCAL_VAR is
		do
			Result := dfp_registers @ f_temp1
		end; -- df_temp1_register

	df_temp2_register: LOCAL_VAR is
		do
			Result := dfp_registers @ f_temp2
		end; -- df_temp2_register

feature { NONE }

	nonvolatile_registers: SET is
	-- used by allocate_register_for for values that have to survive calls
		local
			i: INTEGER;
		once
			!!Result.make(63);

			Result.include(i0);    -- %i0-%i6 are free and nonvolatile
			Result.include(i0+1); 
			Result.include(i0+2); 
			Result.include(i0+3); 
			Result.include(i0+4); 
			Result.include(i0+5);  
			-- %i6 is %sp, %i7 return address
			
			Result.include(l0);    -- all %l0-%l7 are free and nonvolatile
			Result.include(l0+1); 
			Result.include(l0+2); 
			Result.include(l0+3); 
			Result.include(l0+4); 
			Result.include(l0+5); 
			Result.include(l0+6); 
			Result.include(l0+7);
			
			from   -- %f16..%f31 are nonvolatile
				i := 16
			until
				i > 31
			loop
				Result.include(f0+i);
				i := i + 1;
			end;
			 
		end; -- nonvolatile_registers

	volatile_registers: SET is
	-- used by allocate_register_for for values that do not have to survive calls
		local
			i: INTEGER;
		once
			!!Result.make(63);

			Result.include(i0);   -- %in and %ln like nonvolatile_registers
			Result.include(i0+1); 
			Result.include(i0+2); 
			Result.include(i0+3); 
			Result.include(i0+4); 
			Result.include(i0+5);

			Result.include(l0); 
			Result.include(l0+1); 
			Result.include(l0+2); 
			Result.include(l0+3); 
			Result.include(l0+4); 
			Result.include(l0+5); 
			Result.include(l0+6); 
			Result.include(l0+7); 

			Result.include(o0);    -- %o0-%o5 are free but volatile
			Result.include(o0+1); 
			Result.include(o0+2); 
			Result.include(o0+3); 
			Result.include(o0+4); 
			Result.include(o0+5);  
			-- %o6 is %fp
			-- %o7 used as temp2 (see SPARC_CONSTANTS)

			-- %g0 is not usable
			-- %g1 used as temp1 (see SPARC_CONSTANTS)
			Result.include(g0+2);  -- %g2-%g4 seam to be free for application temporaries
			Result.include(g0+3);  
			Result.include(g0+4);  
			-- %g5-%g7 are reserved for operating system, we won't use them 

			from  -- all fp registers may be used, apart from those this compilers
			      -- uses as temporaries
				i := 0
			until
				i > 31
			loop
				if i/=f_temp1 and i/=f_temp2 then
					Result.include(f0+i)
					Result.include(f0+i+1)
				end;
				i := i + 2;
			end;
		end; -- volatile_registers

--------------------------------------------------------------------------------

feature { NONE }

	expand_commands is 
	-- fŸgt, wo nštig, zusŠtzliche Maschinenbefehle ein, z.B. wird
	-- "l1 := l2 + c" zu "l3 := c; l1 := l2 + l3" wenn c zu gross ist um
	-- im Additionsbefehl gespeichert zu werden.
	-- Au§erdem wird am Anfang und Ende der Routine der nštige Code zum holen
	-- der Parameter oder zurŸckgeben des Ergebnisses erzeugt.
		local 
			b: BASIC_BLOCK;
		do
			get_register_arguments;
			from 
				b := blocks.head;
			until
				b = Void
			loop
				b.expand_commands(Current);
				b := b.next;
			end; 
		end; -- expand_commands;

--------------------------------------------------------------------------------

	get_register_arguments is
	-- erzeugt Code der die in Registern Ÿbergebenen Argumente in ihre locals
	-- kopiert
		local 
			i: INTEGER;
			arg_word: INTEGER;  -- this is the word number of the current arg, starting with 0 and
			                    -- increased by one for each arg, by two for doubles.
			cmd: COMMAND;
			arg_type: LOCAL_TYPE;
			result_reg: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
		do
			from
				i := 1
				arg_word := 0;
			until
				i > arguments.count
			loop
				arg_type := (arguments @ i).type;
				if arg_type.is_real_or_double then
					-- NOTE: since these commands are all added to the head of first_block, they are
					-- added in reverse order!
					read_arg_from_stack_frame(arg_word,arguments @ i);
					copy_arg_to_memory(arg_word);
					if arg_type.is_double then
						arg_word := arg_word + 1;
						copy_arg_to_memory(arg_word);
					end;
				elseif arg_type.is_expanded then
					write_string("Compilerfehler ROUTINE_CODE.get_register_arguments #1%N");
				else
					copy_arg_to_local(arg_word,arguments @ i);
				end;
				arg_word := arg_word + 1;
				i := i + 1;
			end;
			if result_local /= Void then
				if expanded_result then
					copy_arg_to_local(arg_word,result_local);
				else
					if     result_local.type.is_real   then result_reg :=  fp_registers @ f0
					elseif result_local.type.is_double then result_reg := dfp_registers @ f0
					                                   else result_reg :=     registers @ i0
					end;
					cmd := recycle.new_ass_cmd(result_reg,result_local);
					blocks.tail.add_tail(cmd);
				end;
			end;
		end; -- get_arguments

-- Routines used by get_arguments:
	
	arg_offset(arg_word: INTEGER): INTEGER is
	-- returns the offset from %fp to the stack position of the argument arg_word, where
	-- arg_word is 0 for the first argument and incremented by one for each argument except
	-- doubles, which increment it by two.
		do
			Result := 68+4*arg_word;
		end; -- arg_offset

	copy_arg_to_memory(arg_word: INTEGER) is
	-- if argument at arg_word is in a register, copy it to %fp+arg_offset(arg_word) and add
	-- the command to the head for first_block.
		local
			write_mem_cmd: WRITE_MEM_COMMAND;
		do
			if arg_word < 6 then -- only the first 6 words are in registers
				write_mem_cmd := recycle.new_write_mem_cmd;
				write_mem_cmd.make_write_offset(arg_offset(arg_word),0,registers @ fp,registers @ (i0+arg_word));
				first_block.add_head(write_mem_cmd);
			end;
		end; -- copy_arg_to_memory

	copy_arg_to_local(arg_word: INTEGER; locl: LOCAL_VAR) is
	-- copy argument at arg_word to locl. This takes care of arguments that are
	-- in a register or in the stack frame.
		local
			write_mem_cmd: WRITE_MEM_COMMAND;
		do
			if arg_word < 6 then
				first_block.add_head(recycle.new_ass_cmd(locl, registers @ (i0+arg_word)));
			else
				read_arg_from_stack_frame(arg_word,locl);
			end;
		end; -- copy_arg_to_local
		
	read_arg_from_stack_frame(arg_word: INTEGER; locl: LOCAL_VAR) is
	-- copy argument at arg_word in stack frame to locl. This does not take care
	-- of arguments that are passed in registers
		local
			read_mem_cmd: READ_MEM_COMMAND;
		do
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_offset(locl,arg_offset(arg_word),0,registers @ fp);
			first_block.add_head(read_mem_cmd);
		end; -- read_arg_from_stack_frame
		
--------------------------------------------------------------------------------

	allocate_registers is
	-- This tries to allocate gp and fp registers for all local_vars
	-- that can be placed in a register
		local
			i: INTEGER;
			sorted_locals: ARRAY[LOCAL_VAR];
		do
			get_live_spans;

--write_string("before remove_assigns_to_dead:%N");
--print_blocks;

			-- now that we know the live-spans, we can remove initialisations of dead
			-- variables:
			first_block.remove_assigns_to_dead;

--write_string("after remove_assigns_to_dead:%N");
--print_blocks;

			get_conflict_matrix;

			-- sort locals by number of uses (weighted).
			sorted_locals := locals.get_sorted;
			
			-- register allocation, most often used locals first:
			from 
				i := sorted_locals.upper
			until
				i < sorted_locals.lower
			loop
				allocate_register_for(sorted_locals @ i);
				i := i - 1;
			end; 

		end; -- allocate_registers

--------------------------------------------------------------------------------

	get_live_spans is
		local
			changed: BOOLEAN
			b: BASIC_BLOCK;
		do
			from
				b := blocks.head;
			until
				b = Void
			loop
				b.clear_live_spans(Current);
				b := b.next;
			end;
			from
				changed := true;
			until
				not changed
			loop
				changed := false;
				from
					b := blocks.tail
				until
					b = Void
				loop
					b.get_live_spans(Current);
					if b.live_span_changed then
						changed := true
					end;
					b := b.prev;
				end;
			end;
		end;  -- get_live_spans

feature { COMMAND, BLOCK_SUCCESSORS }

	add_conflict (var: LOCAL_VAR; with: SET) is
		local
			n,i: INTEGER;
		do
			n := var.number;
			if n >= 0 then
				(conflict_matrix @ n).union(with);
			end;
		end; -- add_conflict

feature { NONE }

	conflict_matrix: ARRAY[SET];  -- conflicting local_vars

feature { CALL_COMMAND }
	
	must_not_be_volatile: SET;  -- local_vars that have to survive calls

feature { NONE }

	get_conflict_matrix is
		local
			i: INTEGER; 
			b: BASIC_BLOCK;
			set: SET;
		do
			if conflict_matrix=Void or else conflict_matrix.upper<locals.count then
memstats(412);
				!!conflict_matrix.make(1,locals.count);
				from 
					i := 1 
				until
					i>locals.count
				loop
memstats(413);
					!!set.make(locals.count);
					conflict_matrix.put(set,i);
					i := i + 1;
				end;
			else
				from 
					i := 1 
				until
					i>locals.count
				loop
					(conflict_matrix @ i).make(locals.count);
					i := i + 1;
				end;
			end;
			if must_not_be_volatile=Void then
				!!must_not_be_volatile.make(locals.count);
			else
				must_not_be_volatile.make(locals.count);
			end;
			from
				b := blocks.head;
			until
				b = Void
			loop
				b.get_conflict_matrix(Current);
				b := b.next;
			end;
			bijektive_huelle;
-- print_conflict_matrix;
		end; -- get_conflict_matrix

	bijektive_huelle is
	-- ensure conflict_matrix(i,j) = conflict_matrix(j,i)
		local
			row: SET;
			i,j: INTEGER;
		do
			from
				i := 1
			until
				i > locals.count
			loop
				row := conflict_matrix @ i;
				from 
					j := 1
				until
					j > locals.count
				loop
					if row.has(j) then
						(conflict_matrix @ j).include(i);
					end;
					j := j + 1;
				end;
				i := i + 1
			end;
		end; -- bijektive_hŸlle

	print_conflict_matrix is
	-- debugging only
		local
			i,j: INTEGER;
		do
			write_string("conflict matrix:%N");
			from
				i := 1
			until
				i > locals.count
			loop
				from 
					j := 1
				until
					j > locals.count
				loop
					if (conflict_matrix @ i).has(j) then
						write_string("*");
					else
						write_string("-");
					end;
					j := j + 1;
				end;
				write_string("%N");
				i := i + 1
			end;
		end; -- print_conflict_matrix

--------------------------------------------------------------------------------

	allocate_register_for(l: LOCAL_VAR) is
	-- Versucht, l ein Register zuzuordnen. 
		require
			l.number >= 0; 
		local
			i: INTEGER;
			row: SET;
			conflicting_reg,synonym_reg: INTEGER;
			is_real_or_double: BOOLEAN;
			is_double: BOOLEAN;
			new_last_fp: INTEGER;
		do
			if not l.must_not_be_register then
				if l.gp_register < 0 and l.fp_register < 0 then
					if must_not_be_volatile.has(l.number) then
						register_set.copy(nonvolatile_registers);
					else
						register_set.copy(volatile_registers);
					end;
					is_double := l.type.is_double
					is_real_or_double := l.type.is_real_or_double;
					row := conflict_matrix @ l.number;
					from 
						i := 1;
					until
						i > locals.count
					loop
						if row.has(i) then
							if is_real_or_double then
								conflicting_reg := (locals @ i).fp_register;
							else
								conflicting_reg := (locals @ i).gp_register;
							end;
							if conflicting_reg > 0 then
								register_set.exclude(conflicting_reg);
								if (locals @ i).type.is_double then
									register_set.exclude(conflicting_reg+1);
								end;
							end;
						end;
						i := i + 1;
					end;
					if is_real_or_double then
						from
							i := 1
						until
							i > l.preferred_synonyms.count or l.fp_register >= 0 
						loop
						-- nyi: besser wÉre, mûgliche Synonyme zu zÉhlen und dann den besten wŠhlen
							synonym_reg := (l.preferred_synonyms @ i).fp_register;
							if synonym_reg >= 0 and then 
							   register_set.has(synonym_reg) and then 
							   (is_double implies (synonym_reg \\ 2 = 0) and register_set.has(synonym_reg+1))
							then
								l.set_fpr(synonym_reg);
							end;
							i := i + 1;
						end;
						if l.fp_register < 0 then
						-- nyi: falls register_set.first volatile dann dasjenige volatile reg benutzten,
						--      das bisher am wenigsten bentutzt wurde, damit Instruction-scheduling
						--      erleichtert wird.
							from 
								i := f0;
							until
								i > f0+31 or else
								register_set.has(i) and then
								(is_double implies (i \\ 2 = 0) and register_set.has(i+1))
							loop
								i := i + 1
							end;
							if i <= f0+31 then
								l.set_fpr(i);
							end;
						end;
						if l.fp_register > 0 then
							new_last_fp := l.fp_register;
							if is_double then 
								new_last_fp := new_last_fp + 1;
							end;
							if new_last_fp > last_fp_register_used then
								last_fp_register_used := new_last_fp
							end;
						end;
					else
--l.print_local; write_string("("); write_integer(l.key); write_string("):");
						from
							i := 1
						until
							i > l.preferred_synonyms.count or l.gp_register >= 0 
						loop
						-- nyi: besser wÉre, mûgliche Synonyme zu zÉhlen und dann den besten wŠhlen
							synonym_reg := (l.preferred_synonyms @ i).gp_register;
--write_string("syn="); write_integer((l.preferred_synonyms @ i).number); write_string(" r "); write_integer(synonym_reg); write_string(", ");
							if synonym_reg >= 0 and then register_set.has(synonym_reg) then
								l.set_gpr(synonym_reg);
							end;
							i := i + 1;
						end;
--write_string("%N");
						if l.gp_register < 0 then
						-- nyi: falls register_set.first volatile dann dasjenige volatile reg benutzten,
						--      das bisher am wenigsten bentutzt wurde, damit Instruction-scheduling
						--      erleichtert wird.
							l.set_gpr(register_set.first); -- starting with first prefers volatile regs
						end;
--write_string("local"); write_integer(l.number); write_string(" => "); l.print_local; write_string("%N");
					end;
				end;
			end;
		end; -- allocate_register_for

	register_set: SET is
	-- von allocate_register_for verwendet
		once
			!!Result.make(63);
		end; -- register_set

--------------------------------------------------------------------------------

-- Stack frame:

-- So far I didn't have access to the Sparc ABI (System V Application Binary 
-- Interface, SPARC Processor Supplement, 3rd Edition, Unix Press, Prentice
-- Hall 1993, ISBN 0-13-104696-9), so I had to work out all the information
-- on the format of the stack frame by hand. So if in doubt, do not trust this
-- information!
-- 
-- The main sources for information was disassembling cc- and gcc- object
-- files and the SPARC.h and SPARC.c source texts of the GNU compiler (which 
-- often allocates a lot more stack space than necessary).
-- 
-- The stack grows downward and %sp points to top of the stack, ie. the lowest
-- used stack address. %fp has the value of %sp in the context of the caller.
--
-- At [%sp+0] there are 64 Bytes reserved for the register window, 16 Register
--             that occupy 4 bytes each.
-- At [%sp+64] In the SPARC ABI, this should be used for a pointer to a memory
--             area to store a complex result. This is not done by this compiler. 
--             In trace mode, this holds a pointer to a descriptor for the next stack
--             frame and is 0 if no next frame exists.
-- At [%sp+68] 6 words are reserved for called routines to save %i0..%i5. A
--             Routine can use [%fp+68..%fp+88] to save the register arguments.
-- At [%sp+92] and the following addresses additional arguments (more than 6) can
--             be passed on the stack. This area has stack_arguments_size-6*4 bytes.
--             A routine accesses its 7th argument as [%fp+92], 8th as [%sp+96] etc.
-- At [%sp+68+stack_arguments_size] local variables can be stored.
-- At [%sp+68+stack_arguments_size+stack_locals_size] there might be some padding
--             bytes. The size of the stack frame must be a multiple of 8.
--  
-- The complete frame has (68+stack_arguments_size+stack_locals_size + 7) // 8 * 8
-- bytes.

feature { NONE }

	stack_arguments_size: INTEGER; -- the size of the arguments area in the stack frame,
	                               -- at least 24 bytes

	minimum_arguments_size: INTEGER is 24; -- stack_arguments_size >= this value

	offset_to_save_fp_regs: INTEGER; -- save non-volatile fp-regs at %sp+offset_to_save_fp_regs.
	                                 -- this is set by allocate_stack;

	last_fp_register_used: INTEGER;  -- highest number of a used fp-register. %f16..%f31
	                                 -- are non-volatile and have to be saved by this
	                                 -- routine. This is <0 if no fp register is used

feature { ANY }

	stack_frame_size: INTEGER;     -- Number of bytes to be allocated on the stack

feature { CALL_COMMAND }

	set_stack_arguments_size (arg_words: INTEGER) is 
	-- set the stack_arguments_size to provide space for at least arg_words
	-- argument words.
	-- This is called by expand() of all commands that pass stack arguments
	-- to called routines (call_command).
		do
			if stack_arguments_size < 4*arg_words then
				stack_arguments_size := 4*arg_words
			end;
		end; -- set_stack_arguments_size

feature { NONE }

	allocate_stack is
	-- Allocate memory in the stack frame for all locals that didn't get
	-- their own register during register allocation
		local
			i,byte_size: INTEGER;
			l: LOCAL_VAR;
		do
			stack_frame_size := 68+stack_arguments_size;
			from
				i := 1
			until
				i > locals.count
			loop
				l := locals @ i;
				if l.gp_register < 0 and l.fp_register < 0 then
					byte_size := l.type.byte_size; 
					stack_frame_size := align(stack_frame_size,byte_size);
					l.set_stack_pos(stack_frame_size,sp);
					stack_frame_size := stack_frame_size + byte_size;
				end;
				i := i + 1;
			end;
			if last_fp_register_used >= f0+16 then
				stack_frame_size := align(stack_frame_size,4);
				offset_to_save_fp_regs := stack_frame_size;
				stack_frame_size := stack_frame_size + real_size * (last_fp_register_used - (f0+15));
			end;
			stack_frame_size := align(stack_frame_size,8);
		end; -- allocate_stack

--------------------------------------------------------------------------------

	expand2_commands is 
		local 
			b: BASIC_BLOCK;
			save_cmd: SAVE_COMMAND;
			write_mem_cmd,write_mem_cmd2: WRITE_MEM_COMMAND;
			read_mem_cmd: READ_MEM_COMMAND;
			f,off: INTEGER;
			sethi_cmd: SETHI_COMMAND;
			setlo_cmd: SETLO_COMMAND;
		do
			from 
				b := blocks.head;
			until
				b = Void
			loop
				b.expand2_commands(Current);
				b := b.next;
			end;
         -- save and restore %f16..%f31 if required
			from 
				f := last_fp_register_used
				off := offset_to_save_fp_regs;
			until
				f < f0+16
			loop
				write_mem_cmd := recycle.new_write_mem_cmd;
				read_mem_cmd  := recycle.new_read_mem_cmd;
				write_mem_cmd.make_write_offset(                 off,0,registers @ sp,fp_registers @ f);
				read_mem_cmd .make_read_offset (fp_registers @ f,off,0,registers @ sp                 );
				first_block.add_head(write_mem_cmd);
				blocks.tail.add_tail(read_mem_cmd  );
				off := off + real_size;
				f := f - 1;
			end;
			-- mark new stack frame for trace:
			if globals.create_trace_code or globals.create_gc_code then
				trace_sym := stack_trace_name(symbol_name);
				sethi_cmd := recycle.new_sethi_cmd; sethi_cmd.make_reloc(trace_sym,temp1,0);
				setlo_cmd := recycle.new_setlo_cmd; setlo_cmd.make_reloc(trace_sym,temp1,0);
				write_mem_cmd := recycle.new_write_mem_cmd;
				write_mem_cmd.make_write_offset(stack_trace_offset,0,registers @ fp,registers @ temp1);
				write_mem_cmd2 := recycle.new_write_mem_cmd;
				write_mem_cmd2.make_write_offset(stack_trace_offset,0,registers @ sp,registers @ g0);
				first_block.add_head(write_mem_cmd2);
				first_block.add_head(write_mem_cmd);
				first_block.add_head(setlo_cmd);
				first_block.add_head(sethi_cmd);
			else
				trace_sym := 0;
			end;
			-- create new register window:
			save_cmd := recycle.new_save_cmd;
			save_cmd.make(-stack_frame_size); 
			first_block.add_head(save_cmd);
			-- return from routine:
			write_mem_cmd := recycle.new_write_mem_cmd;
			write_mem_cmd.make_write_offset(stack_trace_offset,0,registers @ fp,registers @ g0);
			blocks.tail.add_tail(write_mem_cmd);
			blocks.tail.add_tail(recycle.new_return_cmd);
			blocks.tail.add_tail(recycle.new_restore_cmd);
		end; -- expand2_commands;

	trace_sym: INTEGER; -- Name of stack descriptor or 0 if none

--------------------------------------------------------------------------------

	create_machine_code is
		local 
			b: BASIC_BLOCK;
			mc: MACHINE_CODE;
		do
			mc := class_code.machine_code;
			mc.define_func_symbol(symbol_name,mc.pc);
			from
				b := blocks.head;
			until
				b = Void
			loop
				b.create_machine_code(Current,class_code.machine_code);
				b := b.next;
			end;
			class_code.machine_code.fixup_branches;
			if trace_sym /= 0 then
				mc.define_data_symbol(trace_sym,mc.data_index);
				mc.add_data_word(stack_frame_size);
				class_code.add_c_string(symbol_name);
				mc.add_data_reloc_addend(mc.data_index,
				                         class_code.c_string_label,
				                         class_code.c_string_offset);
				mc.add_data_word(0);
			end;
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
		local 
			b: BASIC_BLOCK;
		do
			from 
				b := blocks.head;
			until
				b = Void
			loop
				b.print_machine_code;
				b := b.next;
			end;
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- ROUTINE_CODE
