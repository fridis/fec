/*------------------------------------------------------------------------------
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
------------------------------------------------------------------------------*/

#include <stdio.h>
#include <signal.h>

void writestr (char *s) { printf("%s",s); }

void *eiffel_reference_to_pointer(void* ref)
{
	return ref;
};


/*------  Standard IO  ------*/

void *eiffel_standard_input()
{
	return stdin;
};

void *eiffel_standard_output()
{
	return stdout;
};

void * eiffel_standard_error()
{
	return stderr;
};


/*------  Type Descriptor format ------*/

struct type_descriptor{
   int     td_type_id;
   int     td_size;
   void    *td_generics;
   char    *td_name;
   void    *td_attributes;
   int     td_object_size;
   int     td_color;
   int     td_number;
   void    *td_true_types;
   void    *td_ancestors;
   };


/*------  Memory allocation  ------*/

void *eiffel_new(struct type_descriptor *type)
{ int *result;
  int *obj;
  /* printf("type = %ld  type.object_size = %ld \n",type, type->td_object_size); */
  obj = (int *) malloc(type->td_object_size + 8); /* alloc 8 bytes extra to ensure 8-Byte alignment */
  memset(obj,0,type->td_object_size + 8);
  obj = (void *) (((int) obj)+4);
  *obj = (int) type;
  result = (void *) (((int) obj)+4); 
  /* printf("result = %ld \n",result); */
  return result;
};


/*------  Stack frame format  ------*/

struct stack_descriptor{
	int     sd_size;
	char    *sd_name;
	};

typedef struct stack_descriptor stack_descriptor; /* who invented this idiotic syntax? */

struct stack_frame{
   int               reg[16];
   stack_descriptor  *sf_stack_descriptor;
   };

typedef struct stack_frame stack_frame;

stack_frame *first_stack_frame;

/*------  Runtime Messages  ------*/

struct pos_and_tag {
	char  **src_file;
	int   line;
	int   col;
	char  *tag;
	};

typedef struct pos_and_tag pos_and_tag;

void eiffel_show_call_sequence()
{	stack_frame *sf;
	sf = first_stack_frame;
	if (sf)
	{
		printf("\n\nCall sequence:\n");
		while(sf->sf_stack_descriptor)
		{
			printf("Routine called: %s\n",sf->sf_stack_descriptor->sd_name); 
			sf = (stack_frame *) (((int) sf) - sf->sf_stack_descriptor->sd_size);
		};
	};
};

void eiffel_show_pos_and_tag(pos_and_tag *pat)
{
	if (pat->src_file)
	{
		printf("In file <<%s>> line %ld column %ld\n",*(pat->src_file),pat->line,pat->col);
	};
	if (pat->tag)
	{
		printf("Tag = <<%s>>\n",pat->tag);
	};
	printf("\n");
};

void eiffel_check_failed(pos_and_tag *pat)
{
	eiffel_show_call_sequence();
	printf("\n**** Eiffel Runtime Failure: CHECK instruction failed ****\n");
	eiffel_show_pos_and_tag(pat);
	exit(1);
};

void eiffel_void_reference(pos_and_tag *pat)
{
	eiffel_show_call_sequence();
	printf("\n**** Eiffel Runtime Failure: Void reference used ****\n");
	eiffel_show_pos_and_tag(pat);
	exit(1);
};

void eiffel_precondition_failed(pos_and_tag *pat,
                                pos_and_tag *condition)
{
	eiffel_show_call_sequence();
	printf("\n**** Eiffel Runtime Failure: Precondition failed ****\n");
	eiffel_show_pos_and_tag(pat);
	printf("Failed condition is:\n");
	eiffel_show_pos_and_tag(condition);
	exit(1);
};

/*------  User break by signal:  ------*/

void eiffel_quit_on_signal (int signal)
{
	eiffel_show_call_sequence();
	printf("\n**** Eiffel Runtime Failure: Received signal number %d.\n",signal);
	exit(1);
};

void eiffel_init_trace(stack_frame *new_first_stack_frame)
{
	first_stack_frame = new_first_stack_frame;
	signal(SIGINT  ,eiffel_quit_on_signal);
	signal(SIGQUIT ,eiffel_quit_on_signal);
	signal(SIGTERM ,eiffel_quit_on_signal);
	signal(SIGKILL ,eiffel_quit_on_signal);
	signal(SIGSEGV ,eiffel_quit_on_signal);
	signal(SIGBUS  ,eiffel_quit_on_signal);
};

/*------  Single byte memory modification  ------*/

char get_byte (char *s, int off) 
{ 
	return *((char *) (((int) s) + off)); 
}

void put_byte (char *s, int off, char c) 
{ 
	*((char *) (((int) s) + off)) = c; 
}


/*------  Type conformance  ------*/

struct type_descriptor *get_type(void *object)
{
	return *(struct type_descriptor **) (((int) object)-4);
}

void *eiffel_conforms_to_number(int num, void *src);

void *eiffel_conforms_to(void *dst, void *src)
/* does src object conform to dst object? returns src if true, null else */
{ void *result;
  int num;
  num = get_type(dst)->td_number;
  result = eiffel_conforms_to_number(num,src);
  return result;
}

void *eiffel_conforms_to_number(int num, void *src)
/* does src object conform to true_class with number = num? returns src
if true, null else */
{ int *anc;
  anc = get_type(src)->td_ancestors;
  while (((*anc) >= 0) && ((*anc) != num))
  { 
    anc = (int *) (((int) anc) + 4);  
  }
  if (*anc >= 0) 
  { 
    return src; 
  } 
  else
  {
    return 0; 
  }
}

struct type_descriptor *get_actual_generic(void *object, int n)
{  struct type_descriptor *type;
   type = get_type(object);
   return *(struct type_descriptor **) (((int) type->td_generics)+4*n);
}

int get_type_id(struct type_descriptor *type) 
{
	return type->td_type_id;
}

int get_type_size(struct type_descriptor *type)
{
	return type->td_size;
}

int get_object_size(struct type_descriptor *type)
{
	return type->td_object_size;
}


/*------  Command line Arguments  ------*/

char **eiffel_argv;
int eiffel_argc;

void * eiffel_get_arg (int num)
{
	return eiffel_argv[num];
}

int eiffel_get_argc()
{
	return eiffel_argc;
}


