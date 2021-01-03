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

class LINKED_LIST [ELEMENT -> LINKABLE]

-- Basic list type, reference implementation

creation
	make

--------------------------------------------------------------------------------
	
feature { ANY }

	head, tail: ELEMENT;

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
			head := no_element;
			tail := no_element;
		ensure
			count = 0;
			consistent;
		end; -- make	

	no_element: ELEMENT is 
	-- nyi: Klären, ob "x:=Void" für x: Formal_generic erlaubt ist!
		do
		end; -- no_element;

--------------------------------------------------------------------------------

	add_head (element: ELEMENT) is -- add element at beginning of list
		require
			element.is_next_prev_void;
		do
			if count = 0 then
				tail := element; 
			else
				head.set_next_prev(head.next,element);
			end;
			element.set_next_prev(head,no_element);
			head := element;
			count := count + 1;
		ensure
			head = element
			count = old count + 1
			consistent;
		end;  -- add_head

--------------------------------------------------------------------------------
		
	add_tail (element: ELEMENT) is -- add element at end of list
		require
			element.is_next_prev_void;
		do
			if count=0 then
				head := element;
			else
				tail.set_next_prev(element,tail.prev);
			end;
			element.set_next_prev(no_element,tail);
			tail := element;
			count := count + 1;
		ensure
			tail = element;
			count = old count + 1;
			consistent;
		end;

--------------------------------------------------------------------------------
		
	insert (element, next: ELEMENT) is 
	-- add element before next, next must already be in this list.	 
	-- next may be Void, then the effect is that of add_tail.
		require
			element.is_next_prev_void;
			next/=Void implies has(next);
		local
			prev: ELEMENT;
		do
			if next = head then 
				add_head(element);
			elseif next = Void then
				add_tail(element);
			else
				prev := next.prev;
				element.set_next_prev(next,prev); 
				next.set_next_prev(next.next,element);
				prev.set_next_prev(element,prev.prev);
				count := count + 1
			end;
		ensure
			count = old count + 1;
			next /= Void implies next.prev = element;
			next  = Void implies tail      = element;
			consistent;
		end; -- insert

--------------------------------------------------------------------------------

	remove (element: ELEMENT) is
	-- remove element from list
		require
			has(element);
		local
			n,p: ELEMENT;
		do
			if count=1 then
				head := no_element;
				tail := no_element
			elseif element=head then
				head := head.next;
				head.set_next_prev(head.next,no_element);
			elseif element=tail then
				tail := tail.prev;
				tail.set_next_prev(no_element,tail.prev);
			else
				n := element.next; 
				p := element.prev;
				n.set_next_prev(n.next,p);
				p.set_next_prev(n,p.prev);
			end;
			element.set_next_prev(no_element,no_element);
			count := count - 1;	
		ensure
			count = old count - 1;
			not has(element);
		end; -- remove

--------------------------------------------------------------------------------

	has(element: ELEMENT): BOOLEAN is
		local
			e: ELEMENT;
		do
			from
				e := head
			until	
				e = Void or e = element
			loop
				e := e.next
			end; 
			Result := e=element
		end; -- has

--------------------------------------------------------------------------------

	consistent: BOOLEAN is
		local
			e,p: ELEMENT;
			c: INTEGER;
		do
			if count=0 then
				Result := head=Void and tail=Void
			else
				from
					c := count;
					e := head;
					p := head.prev;
					Result := true;
				until
					c=0 or e=Void
				loop
					if e.prev /= p then
						Result := false;
					end;
					c := c - 1;
					p := e;
					e := e.next;
				end; 
				if c/=0 or e/=Void or p/=tail then
					Result := false;
				end; 
			end;
		end; -- consistent;

--------------------------------------------------------------------------------
				
end -- LINKED_LIST
