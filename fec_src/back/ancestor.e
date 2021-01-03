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

class ANCESTOR

-- Entry in the Ancestor list of a Class_interface.
--
-- This is used to create the feature_descriptor entry the represents this
-- ancestor in the type-descript.

inherit
	MIDDLE_ANCESTOR;
	DATATYPE_SIZES;
	CLASSES;

creation
	make_this_class,
	make_parent

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	create_feature_descriptor(ac: ACTUAL_CLASS) is
	-- nyi: should be part of the back-end
		local
			i,offset: INTEGER;
			mc: MACHINE_CODE;
			fdn: INTEGER;
			ancestors_features: ARRAY[FEATURE_INTERFACE]; -- dynamic feature array of ancestor's class
		do
			ancestors_features := get_class(key.name).this_class.features;
			mc := ac.class_code.machine_code;
			fdn := feature_descriptor_name(ac.key,key.actual_class_name(ac.key));
			mc.define_data_symbol(fdn,mc.data_index);
			from
				i := 1
			until
				i > features.count
			loop
				if (ancestors_features @ i).feature_value.is_variable_attribute then
					offset := ac.attribute_offsets @ (features @ i).number;
					mc.add_data_word(offset);
				else
					mc.add_data_reloc(mc.data_index,(features @ i).get_static_name(ac));
					mc.add_data_word(0);
				end;
				i := i + 1;
			end; 
		end; -- create_feature_descriptor

--------------------------------------------------------------------------------

end -- ANCESTOR
