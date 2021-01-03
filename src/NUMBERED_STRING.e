class NUMBERED_STRING

inherit
	SORTABLE[STRING]
		redefine
			out
		end;

creation
	make

feature

--	key: STRING;  -- inherited

	number: INTEGER;

	make (new_key: STRING; new_number: INTEGER) is
		do
			key := new_key;
			number := new_number;
		end;

	out: STRING is
		do
			Result := key | " = " | number.out;
		end; -- out

end -- NUMBERED_STRING