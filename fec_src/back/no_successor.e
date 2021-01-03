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

class NO_SUCCESSOR

inherit
	MIDDLE_NO_SUCCESSOR;
	SPARC_CONSTANTS;
	
creation
	make
	
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt für die Zielarchitektur nötige zusätzliche Befehle vor der Registervergabe
	-- ein
		do
		end; -- expand

--------------------------------------------------------------------------------

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt nötige Befehle nach der Registervergabe ein und entfernt unnötige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
	-- expand2 darf keine neuen Register allozieren, da die Registervergabe bereits
	-- vorbei ist.
	-- BLOCK_SUCCESSORS.expand2 wird für alle BASIC_BLOCKs, die diesen Successor haben,
	-- aufgerufen. Es kann also mehrfach aufgerufen werden. Dann muss sichergestellt
	-- werden, dass die evtl. am Blockende eingefügten Befehle bei jedem Block dieselben
	-- sind!
		do
		end; -- expand2

--------------------------------------------------------------------------------

end -- NO_SUCCESSOR
