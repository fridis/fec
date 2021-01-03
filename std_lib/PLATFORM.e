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

indexing

	description: "Platform-dependent properties. This class may be %
	             %used as ancestor by classes needing its facilities"

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";

class PLATFORM

inherit GENERAL; 
	-- Inheriting GENERAL allows ANY to inherit PLATFORM without
	-- causing an inheritance-loop.

feature -- Access

	Boolean_bits: INTEGER is
	-- Number of bits in a value of type BOOLEAN
		do
			Result := 8
		ensure
			meaningful: Result >= 1;
		end; -- Boolean_bits
		
	Character_bits: INTEGER is
	-- Number of bits in a value of type CHARACTER
		do
			Result := 8
		ensure
			meaningful: Result >= 1;
			large_enough: 2^Result >= Maximum_character_code;
		end; -- Character_bits

	Double_bits: INTEGER is
	-- Number of bits in a value of type DOUBLE
		do
			Result := 64
		ensure
			meaningful: Result >= 1;
			meaningful: Result >= Real_bits;
		end; -- Double_bits

	Integer_bits: INTEGER is
	-- Number of bits in a value of type INTEGER
		do
			Result := 32
		ensure
			meaningful: Result >= 1;
			large_enough: 2^Result >= Maximum_integer;
			larg_enough_for_negative: 2^Result >= -Minimum_integer;
		end; -- Integer_bits

	Maximum_character_code: INTEGER is
	-- Largest supported code for CHARACTER values
		do
			Result := 255;
		ensure
			meaningful: Result >= 127;
		end; -- Maximum_character_code
	
	Maximum_integer: INTEGER is 
	-- Largest supported value of type INTEGER
		do
			Result := 2147483647;
		ensure 
			meaningful: Result >= 0;
		end; -- Maximum_integer

	Minimum_character_code: INTEGER is
	-- Smallest supported code for CHARACTER values
		do
			Result := 0;
		ensure
			meaningful: Result <= 0;
		end; -- Minimum_character_code
	
	Minimum_integer: INTEGER is 
	-- Smallest supported value of type INTEGER
		do
			Result := (-2147483647)-1;
		ensure 
			meaningful: Result <= 0;
		end; -- Minimum_integer

	Pointer_bits: INTEGER is
	-- Number of bits in a value of type POINTER
		do
			Result := 32;
		ensure
			meaningful: Result >= 1;
		end; -- Pointer_bits

	Real_bits: INTEGER is
	-- Number of bits in a value of type REAL
		do
			Result := 32
		ensure
			meaningful: Result >= 1;
		end; -- Real_bits

end -- PLATFORM
