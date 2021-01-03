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

class NEW_EXPORT_ITEM

inherit
	SCANNER_SYMBOLS;

creation
	parse
	
feature { ANY }

	clients: CLIENTS; 
	all_features: BOOLEAN;     -- all features to the new clients
	features: FEATURE_LIST;    -- newly exported features
	
	position: POSITION; 

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- New_export_item = Clients Feature_set.
	-- Feature_set = Feature_list | "all".
		local
			feature_name: FEATURE_NAME;
		do
			position := s.current_symbol.position;
memstats(138);
			!!clients.parse(s)
			if s.current_symbol.type = s_all then 
				s.next_symbol; 
				all_features := true; 
			else
				all_features := false; 
memstats(139);
				!!features.parse(s); 
			end;
		end; -- parse
		
--------------------------------------------------------------------------------	

invariant
	clients /= Void;
	all_features implies features = Void;
	features /= Void implies not all_features
end -- NEW_EXPORT_ITEM
