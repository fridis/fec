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

class LIST [ELEMENT]

-- Basic LIST type, array implementation

creation
	make

--------------------------------------------------------------------------------
	
feature { NONE }

	data: ARRAY [ELEMENT];

--------------------------------------------------------------------------------

feature { ANY }

	head: ELEMENT is  -- first element of this list
		require
			count > 0
		do
			Result := data.item(1);
		end; -- first
		
	tail: ELEMENT is -- last element of this list
		require
			count > 0
		do
			Result := data.item(count)
		end; -- last

--------------------------------------------------------------------------------
		
	count: INTEGER;    -- number of elements in this list
	
	is_empty: BOOLEAN is 
		do
			Result := count=0
		ensure
			Result = (count=0)
		end;  -- is_empty

--------------------------------------------------------------------------------

	make is -- create an empty list
		do
			count := 0;
		ensure
			count = 0
		end; -- make	

--------------------------------------------------------------------------------

	add_head (element: ELEMENT) is -- add element at beginning of list
		local
			index: INTEGER;
		do
			if data=Void then
memstats(120);
				!!data.make(1,4);
			end;
			if count=data.upper then
memstats(121);
				data.resize(1,data.upper*2)
			end;
			from
				index := count
			until
				index = 0
			loop
				data.put(data.item(index),index+1);
				index := index - 1;
			end;
			data.put(element,1);
			count := count + 1
		ensure
			head = element
			count = old count + 1
		end;  -- add_head

--------------------------------------------------------------------------------
		
	add, add_tail (element: ELEMENT) is -- add element at end of list
		do
			if data=Void then
memstats(122);
				!!data.make(1,4);
			end;
			if count=data.upper then
memstats(123);
				data.resize(1,data.upper*2)
			end;
			count := count + 1
			data.put(element,count);
		ensure
			tail = element
			count = old count + 1
		end;  -- add, add_tail
		
--------------------------------------------------------------------------------

	remove (element: ELEMENT) is -- remove element from list
		require
			has(element)
		local
			index: INTEGER;
		do
			from 
				index := 1
			until
				element = data.item(index)
			loop
				index := index + 1;	
			end;
			from
			until
				index = count
			loop
				data.put(data.item(index),index-1)
				index := index + 1;
			end;
			count := count - 1
		ensure
			count = old count - 1
		end; -- remove

--------------------------------------------------------------------------------
		
	has (element: ELEMENT) : BOOLEAN is -- has element been added to list?
		local
			index: INTEGER;
		do
			if count>0 then
				from 
					index := 1
				until
					index = count or else
					element = data.item(index)
				loop
					index := index + 1;	
				end;
				Result := element= data.item(index)
			end;
		end; -- has

--------------------------------------------------------------------------------
	
	item , infix "@" (pos: INTEGER): ELEMENT is
		require
			1 <= pos;
			pos <= count;
		do
			Result := data @ pos;
		end; -- item

--------------------------------------------------------------------------------

	replace (with: ELEMENT; pos: INTEGER) is
		require
			1 <= pos;
			pos <= count;
		do
			data.put(with,pos);
		end; -- replace
	
--------------------------------------------------------------------------------
				
end -- LIST
