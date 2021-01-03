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

class CREATION_ITEM

inherit
	SCANNER_SYMBOLS;

creation
	parse
	
feature { ANY }

--------------------------------------------------------------------------------

	clients: CLIENTS;
	
	name: INTEGER;
	
	position: POSITION;

--------------------------------------------------------------------------------
	
	parse (s: SCANNER; new_clients: CLIENTS) is
	-- Creation_Item = Identifier
		do	
			position := s.current_symbol.position;
			clients := new_clients; 
			s.check_and_get_identifier(msg.id_ftr_expected);
			name := s.last_identifier;
		end; -- parse

--------------------------------------------------------------------------------
	
	validity (interface: CLASS_INTERFACE) is
		local
			f: FEATURE_INTERFACE; 
		do
			f := interface.feature_list.find(name);
			if f = Void then
				position.error(msg.vgcp1);
			else
				if f.type /= Void then
					position.error(msg.vgcp2);
				end;
				if f.formal_arguments.count > 0 and interface.parse_class.is_expanded then
					position.error(msg.vgcp3);
				end;
			end;
		end; -- validity

--------------------------------------------------------------------------------

end -- CREATION_ITEM
