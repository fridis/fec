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

class MESSAGES

-- All text messages are created through this class to allow the support for 
-- several languages. Currently German and English are supported. The language
-- is chosen by a call to the desired make_* feature.
--
-- ANY has a once field "msg" pointing to an object of this class. This allows 
-- easy access to all the messages declared here using "msg @ msg.*" and
-- "msg.write(msg.*)".

creation
	make_english,
	make_deutsch

--------------------------------------------------------------------------------
	
feature { ANY }

	title : STRING is "FEC -- Fridi's Eiffel Compiler V0.03 (29-Aug-97)%N"

--------------------------------------------------------------------------------

	messages: ARRAY[STRING];

--------------------------------------------------------------------------------
	
	make_english is
		do
			messages := english_messages;
		end; -- make_english

	make_deutsch is
		do
			messages := deutsche_meldungen;
		end; -- make_deutsch

--------------------------------------------------------------------------------

	infix "@" (msg_num: INTEGER): STRING is
		do
			Result := messages @ msg_num;
		end; -- infix "@"

--------------------------------------------------------------------------------

	write (msg_num: INTEGER) is
		do
			print(messages @ msg_num);
		end;
		
--------------------------------------------------------------------------------

	vaol1 : INTEGER is   1;   -- "VAOL: OLD nur in Postcondition erlaubt."
	vape1 : INTEGER is   2;   -- "VAPE: Lokaler Bezeichner in Precondition nicht erlaubt."
	vape2 : INTEGER is   3;   -- "VAPE: Aufgerufenes Feature in Precondition muﬂ allen Klassen zur Verf¸gung stehen, denen auch dieses Feature zur Verf¸gung steht (availability)."
	vbar1 : INTEGER is   4;   -- "VBAR: Der rechte Ausdrucks einer Zuweisung muß der Zielentität entsprechen (conformance)."
	vcch1 : INTEGER is   5;   -- "VCCH: Deferred-Markierung darf nicht vorhanden sein, wenn es keine deferred Features gibt."
	vcfg1 : INTEGER is   6;   -- "VCFG: Formale generische Parameter müssen alle unterschiedliche Namen haben."
	vcrn1 : INTEGER is   7;   -- "VCRN: Finaler Kommentar einer Klasse muss die Form %"-- <Class_name>%" haben."
	vdjr1 : INTEGER is   8;   -- "VDJR: Join rule: Unterschiedliche unter demselben Namen geerbte Features m¸ssen dieselbe Signatur haben."
	vdrd1 : INTEGER is   9;   -- "VDRD: Illegale Redeklaration: Signature der Redeklaration muss der urspr¸nglichen entsprechen (conformance)."
	vdrd2 : INTEGER is  10;   -- "VDRD: Attribut muﬂ als Attribut redeklariert werden."
	vdrd3 : INTEGER is  11;   -- "VDRD: Bei redeklarierter Routine muﬂ Precondition mit require else und Postcondition mit ensure then beginnen."
	vdrd4 : INTEGER is  12;   -- "VDRD: Redeklaration zwischen externer und interner Routine nicht mˆglich."
	vdrd5 : INTEGER is  13;   -- "VDRD: Geerbtes effektives Feature darf nicht als deferred redefiniert werden."
	vdrd6 : INTEGER is  14;   -- "VDRD: Feature wird redefiniert, der Name wird jedoch nicht in der Redefine-Liste im Parent_clause aufgelistet."
	vdrs1 : INTEGER is  15;   -- "VDRS: Featurename muß finaler Name von geerbtem Feature sein und darf nicht mehrfach in der redefine-Liste vorkommen."
	vdrs2 : INTEGER is  16;   -- "VDRS: Frozen Feature oder konstantes Attribut darf nicht redefiniert werden."
	vdrs3 : INTEGER is  17;   -- "VDRS: Feature_declaration für redefiniertes Feature fehlt in dieser Klasse."
	vdrs4 : INTEGER is  18;   -- "VDRS: Eine frozen Feature kann nicht redefiniert werden."
	vdrs5 : INTEGER is  19;   -- "VDRS: Redefinition darf nicht aus einem deferred Feature ein effektives Feature machen (redefine unnötig)."
	vdus1 : INTEGER is  20;   -- "VDUS: Featurename muß finaler Name von geerbtem Feature sein und darf nicht mehrfach in der undefine-Liste vorkommen."
	vdus2 : INTEGER is  21;   -- "VDUS: Undefine darf nicht auf frozen Feature oder Attribut angewendet werden."
	vdus3 : INTEGER is  22;   -- "VDUS: Undefine darf nur auf effektives Feature angewendet werden."
	veen1 : INTEGER is  23;   -- "VEEN: Result darf in Precondition nicht verwendet werden."
	veen2 : INTEGER is  24;   -- "VEEN: Result darf nur innerhalb einer Funktion verwendet werden."
	veen3 : INTEGER is  25;   -- "VEEN: Illegales Writeable: Dies ist kein variables Attribut."
	veen4 : INTEGER is  26;   -- "VEEN: Writeable muß finaler Name eines Attributs dieser Klasse oder einer lokalen Variablen sein."
	veen5 : INTEGER is  27;   -- "VEEN: Formale Argumente sind nicht Writeable."
	vffd1 : INTEGER is  28;   -- "VFFD: Feature muß nach den Regeln von 5.11 Attribut, Konstante, Prozedur oder Funktion sein."
	vffd2 : INTEGER is  29;   -- "VFFD: Once-Funktion darf als Ergebnis weder einen Formal_generic noch einen Anchored Type liefern."
	vffd3 : INTEGER is  30;   -- "VFFD: Frozen Feature darf nicht deferred sein."
	vffd4 : INTEGER is  31;   -- "VFFD: Präfixoperator muß Funktion oder Attribut ohne Argumente sein."
	vffd5 : INTEGER is  32;   -- "VFFD: Infixoperator muß Funktion mit genau einem Argument sein."
	vgcc1 : INTEGER is  33;   -- "VGCC: Erzeugtes Objekt darf keinen Formal_generic_name als Typ haben."
	vgcc2 : INTEGER is  34;   -- "VGCC: Ein Objekt eines abstrakten (deferred) Typs kann nicht erzeugt werden."
	vgcc3 : INTEGER is  35;   -- "VGCC: Expliziter Creation-Typ muß dem Typ des writeables entsprechen (conformance)."
	vgcc4 : INTEGER is  36;   -- "VGCC: Expliziter Creation-Typ muß Referenztyp sein."
	vgcc5 : INTEGER is  37;   -- "VGCC: Die Klasse des Creation-Typs hat keinen Creators Teil, es darf bei der Erzeugung eines Objekts also keine Creation-Routine aufgerufen werden."
	vgcc6 : INTEGER is  38;   -- "VGCC: Die Klasse des Creation-Typs hat einen Creators Teil, es muss bei der Erzeugung eines Objekts also eine Creation-Routine aufgerufen werden."
	vgcc7 : INTEGER is  39;   -- "VGCC: Creation-Routine muß dieser Klasse zum Erzeugen zur Verfügung stehen (available for creation)."
	vgcc8 : INTEGER is  40;   -- "VGCC: Creation-Routine darf weder Funktion noch ONCE-Routine sein."
	vgcp1 : INTEGER is  41;   -- "VGCP: Creator muß Prozedur dieser Klasse sein."
	vgcp2 : INTEGER is  42;   -- "VGCP: Creator darf keine Funktion sein."
	vgcp3 : INTEGER is  43;   -- "VGCP: Creator von Expanded Class darf keine Argumente haben."
	vgcp4 : INTEGER is  44;   -- "VGCP: Creation_clause darf nur in effektiver (nicht deferred) Klasse vorhanden sein."
	vgcp5 : INTEGER is  45;   -- "VGCP: Expanded Class darf nur einen Creator besitzen."
	vgcp6 : INTEGER is  46;   -- "VGCP: Creator darf nicht mehrmals genannt werden."
	vhay1 : INTEGER is  47;   -- "VHAY: Jedes Universum braucht eine Klasse ANY."
	vhpr1 : INTEGER is  48;   -- "VHPR: Zyklische Vererbung ist nicht erlaubt."
	vhrc1 : INTEGER is  49;   -- "VHRC: old_name ist nicht final_name eines Features der Vaterklasse oder old_name kommt doppelt in Rename-clause vor."
	vjrv1 : INTEGER is  50;   -- "VJRV: Zieltyp eines Assignment_attempt muß ein Zeigertyp sein."
	vkcn1 : INTEGER is  51;   -- "VKCN: Prozedur darf nicht als Funktion aufgerufen werden."
	vkcn2 : INTEGER is  52;   -- "VKCN: Prozeduraufruf darf keine Funktion und kein Attribut aufrufen."
	vlec1 : INTEGER is  53;   -- "VLEC: Ein Klasse C darf nicht expandierter Klient einer Klasse D sein, wenn D auch expandierter Klient von C ist."
	vlel1 : INTEGER is  54;   -- "VLEL: Höchstens eine der Feature_lists in New_exports darf %"all%" sein."
	vlel2 : INTEGER is  55;   -- "VLEL: Feature_name in New_exports muß finaler Name eines Features der Vaterklasse in der neuen Klasse sein und darf nicht mehrfach in den Feature_listen auftreten."
	vmfn1 : INTEGER is  56;   -- "VMFN / VMCN: Gleichnamiges Feature wird mehrmals in derselben Klasse eingeführt."
	vmfn2 : INTEGER is  57;   -- "VMFN / VMCN: Mehrere effektive Features d¸rfen nicht unter demselben Namen geerbt werden: "
	vmrc1 : INTEGER is  58;   -- "VMRC: Mehrdeutiges Feature kommt in mehreren Selects vor."
	vmrc2a: INTEGER is  59;   -- "VMRC 2: Fehlendes select für mehrdeutiges Feature <<"
	vmrc2b: INTEGER is  60;   -- ">> in Ancestor <<"
	vmrc2c: INTEGER is  61;   -- ">>."
	vmss1 : INTEGER is  62;   -- "VMSS: Featurename muß finaler Name von geerbtem Feature sein und darf nicht mehrfach in der select-Liste vorkommen."
	vmss2 : INTEGER is  63;   -- "VMSS: Feature in select_clause muß mehrere potentielle Versionen besitzen."
	vomb1 : INTEGER is  64;   -- "VOMB: Die inspect-Konstanten müssen vom selben Typ sein wie der Inspect-Ausdruck."
	vomb2 : INTEGER is  65;   -- "VOMB: Ausdruck in Multi_branch muß vom Typ INTEGER oder CHARACTER sein."
	vomb3 : INTEGER is  66;   -- "VOMB: Wenn eine Inspect-Konstante Unique ist, müssen alle anderen Konstanten, die nicht Unique sind, null oder negativ sein."
	vomb4 : INTEGER is  67;   -- "VOMB: Inspekt-Konstanten müssen unterschiedliche Werte haben."
	vomb5 : INTEGER is  68;   -- "VOMB: Die selbe Unique-Konstante darf nicht mehrfach in einer Multi_branch-Anweisung vorkommen."
	vomb6 : INTEGER is  69;   -- "VOMB: Alle UNIQUE-Konstanten eines Multi_branch müssen dieselbe Ursprungsklasse haben."
	vqmc1 : INTEGER is  70;   -- "VQMC: Typ einer Boolean-Konstante muß BOOLEAN sein."
	vqmc2 : INTEGER is  71;   -- "VQMC: Typ einer Zeichen-Konstante muß CHARACTER sein."
	vqmc3 : INTEGER is  72;   -- "VQMC: Typ einer Integer-Konstante muß INTEGER sein."
	vqmc4 : INTEGER is  73;   -- "VQMC: Typ einer Reellen-Konstante muß REAL oder DOUBLE sein."
	vqmc5 : INTEGER is  74;   -- "VQMC: Typ einer Zeichenketten-Konstante muß STRING sein."
	vqmc6 : INTEGER is  75;   -- "VQMC: Typ einer Bit-Konstante muß BIT N sein."
	vqui1 : INTEGER is  76;   -- "VQUI: Der Typ einer UNIQUE-Konstanten muß INTEGER sein."
	vreg1 : INTEGER is  77;   -- "VREG: Der gleiche Bezeichner darf nicht doppelt in einer Entity_declaration_list vorkommen."
	vrfa1 : INTEGER is  78;   -- "VRFA: Formales Argument darf nicht denselben Namen haben wie ein Feature der Klasse."
	vrle1 : INTEGER is  79;   -- "VRLE: Lokaler Bezeichenr darf nicht denselben Namen haben wie ein Feature der Klasse."
	vrle2 : INTEGER is  80;   -- "VRLE: Lokaler Bezeichenr darf nicht denselben Namen haben wie ein formales Argument des Features."
	vsrc1 : INTEGER is  81;   -- "VSRC: Root Class darf nicht generisch sein."
	vsrc2 : INTEGER is  82;   -- "VSRC: Root Creation Prozedur darf keine Argumente haben und darf keine Funktion sein."
	vsrc3 : INTEGER is  83;   -- "VSRC: Root Creation Prozedur muß in Root Class vorhanden sein."
	vrrr1 : INTEGER is  84;   -- "VRRR: Deferred und External Routinen dürfen weder Local_declaration noch Rescue Anweisung besitzen."
	vtat1 : INTEGER is  85;   -- "VTAT: Anchored Typ darf nicht rekursiv definiert sein."
	vtat2 : INTEGER is  86;   -- "VTAT: Anchor muß Name eines Features, eines formalen Arguements oder Current sein."
	vtat3 : INTEGER is  87;   -- "VTAT: Anchor darf nicht selbst Anchored sein."
	vtat4 : INTEGER is  88;   -- "VTAT: Anchor muß Referenztyp sein."
	vtbt1 : INTEGER is  89;   -- "VTBT: Ein Bit_type benötigt eine positive Integer-Konstante als Größe."
	vtcg1 : INTEGER is  90;   -- "VTCG: Aktueller generischer Parameter muﬂ dem generischen Constraint entsprechen."
	vtct1 : INTEGER is  91;   -- "VTCT: Der Class_name eines Class_type muß der Name einer Klasse des umgebenden Universums sein."
	vtec1 : INTEGER is  92;   -- "VTEC: Expanded darf als Basisklasse keine abstrakte (deferred) Klasse haben."
	vtec2 : INTEGER is  93;   -- "VTEC: Basisklasse eines expanded-Typs darf höchstens eine Creation-routine besitzen."
	vtec3 : INTEGER is  94;   -- "VTEC: Creation-Prozedur eines expanded-Typs muß für diese Klasse verfügbar sein."
	vtec4 : INTEGER is  95;   -- "VTEC: Creation-Prozedur eines expanded-Typs darf keine Argumente haben."
	vtug1 : INTEGER is  96;   -- "VTUG: Aktuelle generische Parameter d¸rfen nur bei generischer Klasse angegeben werden."
	vtug2 : INTEGER is  97;   -- "VTUG: Aktuelle generische Parameter f¸r generischen Klasse nötig."
	vtug3 : INTEGER is  98;   -- "VTUG: Anzahl der aktuellen generischen Parameter muss gleich der Anzahl der formalen generischen Parameter sein."
	vuar1 : INTEGER is  99;   -- "VUAR: Adreßoperator $ nur beim Aufruf von externer Routine erlaubt."
	vuar2 : INTEGER is 100;   -- "VUAR: Nach dem Adressoperator muss der finale Name eines Features dieser Klasse stehen."
	vuar3 : INTEGER is 101;   -- "VUAR: Adressoperator darf nicht auf ein konstantes Attribut angewendet werden."
	vuar4 : INTEGER is 102;   -- "VUAR: Das aktuelle Argument eines Aufrufs muss dem formalen Argument entsprechen (conformance)."
	vuar5 : INTEGER is 103;   -- "VUAR: Adressoperator darf nicht auf ein konstantes Attribut angewendet werden."
	vuar6 : INTEGER is 104;   -- "VUAR: Aktuelle Argumente dieses Aufrufs fehlen."
	vuar7 : INTEGER is 105;   -- "VUAR: Für diesen Aufruf werden keine aktuellen Argumente erwartet."
	vuar8 : INTEGER is 106;   -- "VUAR: Falsche Anzahl an aktuellen Argumenten für diesen Aufruf."
	vuex1 : INTEGER is 107;   -- "VUEX: Aufgerufenes Feature muß in aufgerufener Klasse existieren."
	vuex2 : INTEGER is 108;   -- "VUEX: Aufgerufenes Feature muﬂ dieser Klasse zur Verf¸gung stehen (available)."
	vwbe1 : INTEGER is 109;   -- "VWBE: Eine Boolean_expression muß vom Typ BOOLEAN sein."
	vwca1 : INTEGER is 110;   -- "VWCA: Ein Constant_attribute muß der finale Name eines konstanten Attributes dieser Klasse sein."
	vweq1 : INTEGER is 111;   -- "VWEQ: In Gleichheitsausdruck muß einer Ausdr¸cke dem anderen entsprechen (conformance)."
	vwid1 : INTEGER is 112;   -- "VWID: Ein unqualifizierter Bezeichner in einem Ausdruck muﬂ der Name eines Features dieser Klasse sein."
	vwid2 : INTEGER is 113;   -- "VWID: Ein unqualifizierter Bezeichner in einem Ausdruck muﬂ der Name eines Features dieser Klasse, eine lokale Entit‰t dieser Routine oder ein formales Argument sein."
	vwst1 : INTEGER is 114;   -- "VWST: Alle Bezeichner in einem STRIP-Ausdrück müssen finale Namen von Attributen dieser Klasse sein."
	vwst2 : INTEGER is 115;   -- "VWST: Kein Bezeicher darf doppelt in der Attributlist eines STRIP-Ausdrucks auftreten."
	vxrc1 : INTEGER is 116;   -- "VXRC: Eine Rescue-Clause darf nur bei einer internen Routine angegeben werden."
	vxrt1 : INTEGER is 117;   -- "VXRT: Eine Retry-Anweisung darf nur im Rescue-clause stehen."

	percent_err    : INTEGER is 130;   -- "Scanner: Fehler in %%/code/-Sequenz."
	percent_illasc : INTEGER is 131;   -- "Scanner: Illegaler ASCII-Code in %%/code/ Sequenz."
	percent_slash  : INTEGER is 132;   -- "Scanner: %"/%" in %%/code/-Sequenz erwartet."
	percent_at_line: INTEGER is 133;   -- "Scanner: Umgebrochene Zeile: %"%%%" an Zeilenanfang erwartet."
	ill_char       : INTEGER is 134;   -- "Scanner: Illegales Zeichen im Quelltext."
	const_ovfl     : INTEGER is 135;   -- "Scanner: Konstante Zahl zu groß."
	dquot_expected : INTEGER is 136;   -- "Scanner: Zweites Anführungszeichen in String fehlt."
	squot_expected : INTEGER is 137;   -- "Scanner: Zweites %"%'%" in Character-Konstant fehlt."
	intreal_err    : INTEGER is 138;   -- "Scanner: Fehler in Integer- oder Real-Konstante."
	real_err       : INTEGER is 139;   -- "Scanner: Fehler in Real-Konstante."
	exp_expected   : INTEGER is 140;   -- "Scanner: Exponent in Real-Konstante erwartet."
	ill_symbol     : INTEGER is 141;   -- "Scanner: Illegales Scannersymbol."
	expected_a     : INTEGER is 142;   -- "Scanner: %""
	expected_b     : INTEGER is 143;   -- "%" erwartet."

	char_expected  : INTEGER is 150;   -- "Parser: Character-Konstante erwartet."
	int_expected   : INTEGER is 151;   -- "Parser: Integer-Konstante erwartet."
	const_expected : INTEGER is 152;   -- "Parser: Konstante erwartet."
	lbrace_expected: INTEGER is 153;   -- "Parser: %"{%" in Clients erwartet."
	rbrace_expected: INTEGER is 154;   -- "Parser: %"}%" am Schluß von Clients erwartet."
	rangle_expected: INTEGER is 155;   -- "Parser: %">>%" am Ende von Manifest_array erwartet."
	lp_str_expected: INTEGER is 156;   -- "Parser: %"(%" in Strip-Ausdruck erwartet."
	excl_expected  : INTEGER is 157;   -- "Parser: Zweites %"!%" in Creation erwartet."
	end_expected   : INTEGER is 158;   -- "Parser: %"end%" erwartet."
	eof_expected   : INTEGER is 159;   -- "Parser: Dateiende erwartet."
	crlist_no_semi : INTEGER is 160;   -- "Parser: Nach Creation_list darf kein Strichpunkt stehen."
	ill_prefix     : INTEGER is 161;   -- "Parser: Illegaler Präfix-Operator."
	ill_infix      : INTEGER is 162;   -- "Parser: Illegaler Infix-Operator."
	id_adr_expected: INTEGER is 163;   -- "Parser: Bezeichner nach Adressoperator %"$%" erwartet."
	id_anc_expected: INTEGER is 164;   -- "Parser: Anchor-Bezeichner hinter like erwartet."
	id_cll_expected: INTEGER is 165;   -- "Parser: Featurebezeichner in Call erwartet."
	id_cls_expected: INTEGER is 166;   -- "Parser: Class_name-Bezeichner erwartet."
	id_cnc_expected: INTEGER is 167;   -- "Parser: Class_name-Bezeichner in CLIENTS erwartet."
	id_ftr_expected: INTEGER is 168;   -- "Parser: Featurebezeichner erwartet."
	id_fgn_expected: INTEGER is 169;   -- "Parser: Formal_generic_name-Bezeichner erwartet."
	id_far_expected: INTEGER is 170;   -- "Parser: Formal_argument-Bezeichner erwartet."
	id_wrt_expected: INTEGER is 171;   -- "Parser: Writeable-Bezeichner erwartet."
	dbg_ky_expected: INTEGER is 172;   -- "Parser: Debug_key in Anführungszeichen erwartet."
	lang_expected  : INTEGER is 173;   -- "Parser: Language_name in Anführungszeichen erwartet."
	ext_expected   : INTEGER is 174;   -- "Parser: External_name in Anführungszeichen erwartet."
	prefix_expected: INTEGER is 175;   -- "Parser: Präfix-Operator in Anführungszeichen erwartet."
	infix_expected : INTEGER is 176;   -- "Parser: Infix-Operator in Anführungszeichen erwartet."
	obs_expected   : INTEGER is 177;   -- "Parser: Obsolete-Meldung in Anführungszeichen erwartet."
	dot_pe_expected: INTEGER is 178;   -- "Parser: %".%" nach Parenthesized_qualifier erwartet."
	cln_fa_expected: INTEGER is 179;   -- "Parser: %":%" in Formal_arguments erwartet."
	rpr_pq_expected: INTEGER is 180;   -- "Parser: %")%" in Parenthesized_qualifier erwartet."
	rpr_pr_expected: INTEGER is 181;   -- "Parser: %")%" nach den Parametern in Call erwartet."
	rpr_db_expected: INTEGER is 182;   -- "Parser: %")%" am Ende der Debug_keys erwartet."
	rpr_fa_expected: INTEGER is 183;   -- "Parser: %")%" am Ende der Formal_arguments erwartet."
	rpr_ex_expected: INTEGER is 184;   -- "Parser: %")%" in Ausdruck erwartet."
	rpr_st_expected: INTEGER is 185;   -- "Parser: %")%" am Ende des Strip-Ausdrucks erwartet."
	rbk_ag_expected: INTEGER is 186;   -- "Parser: %"]%" in Actual_generics erwartet."
	rbk_fg_expected: INTEGER is 187;   -- "Parser: %"]%" am Ende der Formal_generics erwartet."	
	
	overflow       : INTEGER is 200;   -- "Compilation: Überlauf in konstantem Ausdruck."
	name_wrong     : INTEGER is 201;   -- "Compilation: Klassenname und Dateiname stimmen nicht überein."
	anchor_parent  : INTEGER is 202;   -- "Compilation: Anchored Typ in Parent nicht erlaubt."
	rec_generic    : INTEGER is 203;   -- "Compilation: V***: Illegale rekursive Verwendung eines formalen generischen Parameters."
	loop_variant   : INTEGER is 204;   -- "Compilation: V***: Schleifenvariante muß vom Typ INTEGER sein."); 

	name_and_version   : INTEGER is 210;   -- "FEC -- Fridi´s Eiffel Compiler V0.01 (06-Jul-97)%N"
	usage              : INTEGER is 211;   -- "Aufruf: FEC <Projektname>%N"
	ok                 : INTEGER is 212;   -- "ok.%N"
	created_file_prefix: INTEGER is 213;   -- " + "
	save_main          : INTEGER is 214;   -- " + obj/main.o"
	save_elink         : INTEGER is 215;   -- " + elink"
	read_file_prefix   : INTEGER is 216;   -- " - "
	lf                 : INTEGER is 217;   -- "%N"
	lflf               : INTEGER is 218;   -- "%N%N"
	couldnt_save       : INTEGER is 219;   -- " *** konnte Datei nicht erzeugen!%N"
	errors_found       : INTEGER is 220;   -- " Fehler gefunden.%N%N"
	bytes_mc_created   : INTEGER is 221;   -- " Bytes Machinencode erzeugt.%N"
	error_in_system    : INTEGER is 222;   -- "%NFehler bei Systemerzeugung: "
	error              : INTEGER is 223;   -- "%NFehler: "
	error_in_file_a    : INTEGER is 224;   -- "%NFehler in Datei <<"
	error_in_file_b    : INTEGER is 225;   -- ">> Zeile: "
	error_in_file_c    : INTEGER is 226;   -- " Spalte: "
	error_in_file_d    : INTEGER is 227;   -- "%N"
	warning_in_file_a  : INTEGER is 228;   -- "%NWarnung in Datei <<"
	warning_in_file_b  : INTEGER is 229;   -- ">> Zeile: "
	warning_in_file_c  : INTEGER is 230;   -- " Spalte: "
	warning_in_file_d  : INTEGER is 231;   -- "%N"
	unknown_file       : INTEGER is 232;   -- "Unbekannte Datei"
	compiling          : INTEGER is 233;   -- "compiliere:%N"
	missing_source_a   : INTEGER is 234;   -- "Quelltext zu Klasse <<"
	missing_source_b   : INTEGER is 235;   -- ">> nicht gefunden."
	error_in_enviro_a  : INTEGER is 236;   -- " *** Fehler in Environment: <<" 
	error_in_enviro_b  : INTEGER is 237;   -- ">> nicht interpretierbar.%N"
	env_created        : INTEGER is 238;   -- "Environment Datei erzeugt. Bitte FEC nochmals starten um Eiffel System zu compilieren.%N"

--------------------------------------------------------------------------------

	deutsche_meldungen : ARRAY[STRING] is
		once
			Result := <<
				"VAOL: OLD nur in Postcondition erlaubt.",
				"VAPE: Lokaler Bezeichner in Precondition nicht erlaubt.",
				"VAPE: Aufgerufenes Feature in Precondition muﬂ allen Klassen zur Verf¸gung stehen, denen auch dieses Feature zur Verf¸gung steht (availability).",
				"VBAR: Der rechte Ausdrucks einer Zuweisung muß der Zielentität entsprechen (conformance).",
				"VCCH: Deferred-Markierung darf nicht vorhanden sein, wenn es keine deferred Features gibt.",
				"VCFG: Formale generische Parameter müssen alle unterschiedliche Namen haben.",
				"VCRN: Finaler Kommentar einer Klasse muss die Form %"-- <Class_name>%" haben.",
				"VDJR: Join rule: Unterschiedliche unter demselben Namen geerbte Features m¸ssen dieselbe Signatur haben.",
				"VDRD: Illegale Redeklaration: Signature der Redeklaration muss der urspr¸nglichen entsprechen (conformance).",
				"VDRD: Attribut muﬂ als Attribut redeklariert werden.",
				"VDRD: Bei redeklarierter Routine muﬂ Precondition mit require else und Postcondition mit ensure then beginnen.",
				"VDRD: Redeklaration zwischen externer und interner Routine nicht mˆglich.",
				"VDRD: Geerbtes effektives Feature darf nicht als deferred redefiniert werden.",
				"VDRD: Feature wird redefiniert, der Name wird jedoch nicht in der Redefine-Liste im Parent_clause aufgelistet.",
				"VDRS: Featurename muß finaler Name von geerbtem Feature sein und darf nicht mehrfach in der redefine-Liste vorkommen.",
				"VDRS: Frozen Feature oder konstantes Attribut darf nicht redefiniert werden.",
				"VDRS: Feature_declaration für redefiniertes Feature fehlt in dieser Klasse.",
				"VDRS: Eine frozen Feature kann nicht redefiniert werden.",
				"VDRS: Redefinition darf nicht aus einem deferred Feature ein effektives Feature machen (redefine unnötig).",
				"VDUS: Featurename muß finaler Name von geerbtem Feature sein und darf nicht mehrfach in der undefine-Liste vorkommen.",
				"VDUS: Undefine darf nicht auf frozen Feature oder Attribut angewendet werden.",
				"VDUS: Undefine darf nur auf effektives Feature angewendet werden.",
				"VEEN: Result darf in Precondition nicht verwendet werden." ,
				"VEEN: Result darf nur innerhalb einer Funktion verwendet werden.",
				"VEEN: Illegales Writeable: Dies ist kein variables Attribut.",
				"VEEN: Writeable muß finaler Name eines Attributs dieser Klasse oder einer lokalen Variablen sein.",
				"VEEN: Formale Argumente sind nicht Writeable.",
				"VFFD: Feature muß nach den Regeln von 5.11 Attribut, Konstante, Prozedur oder Funktion sein.",
				"VFFD: Once-Funktion darf als Ergebnis weder einen Formal_generic noch einen Anchored Type liefern.",
				"VFFD: Frozen Feature darf nicht deferred sein.",
				"VFFD: Präfixoperator muß Funktion oder Attribut ohne Argumente sein.",
				"VFFD: Infixoperator muß Funktion mit genau einem Argument sein.",
				"VGCC: Erzeugtes Objekt darf keinen Formal_generic_name als Typ haben.",
				"VGCC: Ein Objekt eines abstrakten (deferred) Typs kann nicht erzeugt werden.",
				"VGCC: Expliziter Creation-Typ muß dem Typ des writeables entsprechen (conformance).",
				"VGCC: Expliziter Creation-Typ muß Referenztyp sein.",
				"VGCC: Die Klasse des Creation-Typs hat keinen Creators Teil, es darf bei der Erzeugung eines Objekts also keine Creation-Routine aufgerufen werden.",
				"VGCC: Die Klasse des Creation-Typs hat einen Creators Teil, es muss bei der Erzeugung eines Objekts also eine Creation-Routine aufgerufen werden.",
				"VGCC: Creation-Routine muß dieser Klasse zum Erzeugen zur Verfügung stehen (available for creation).",
				"VGCC: Creation-Routine darf weder Funktion noch ONCE-Routine sein.",
				"VGCP: Creator muß Prozedur dieser Klasse sein.",
				"VGCP: Creator darf keine Funktion sein.",
				"VGCP: Creator von Expanded Class darf keine Argumente haben.",
				"VGCP: Creation_clause darf nur in effektiver (nicht deferred) Klasse vorhanden sein.",
				"VGCP: Expanded Class darf nur einen Creator besitzen.",
				"VGCP: Creator darf nicht mehrmals genannt werden.",
				"VHAY: Jedes Universum braucht eine Klasse ANY.",
				"VHPR: Zyklische Vererbung ist nicht erlaubt.",
				"VHRC: old_name ist nicht final_name eines Features der Vaterklasse oder old_name kommt doppelt in Rename-clause vor.",
				"VJRV: Zieltyp eines Assignment_attempt muß ein Zeigertyp sein.",
				"VKCN: Prozedur darf nicht als Funktion aufgerufen werden.",
				"VKCN: Prozeduraufruf darf keine Funktion und kein Attribut aufrufen.",
				"VLEC: Ein Klasse C darf nicht expandierter Klient einer Klasse D sein, wenn D auch expandierter Klient von C ist.",
				"VLEL: Höchstens eine der Feature_lists in New_exports darf %"all%" sein.",
				"VLEL: Feature_name in New_exports muß finaler Name eines Features der Vaterklasse in der neuen Klasse sein und darf nicht mehrfach in den Feature_listen auftreten.",
				"VMFN / VMCN: Gleichnamiges Feature wird mehrmals in derselben Klasse eingeführt.",
				"VMFN / VMCN: Mehrere effektive Features d¸rfen nicht unter demselben Namen geerbt werden: ",
				"VMRC: Mehrdeutiges Feature kommt in mehreren Selects vor.",
				"VMRC 2: Fehlendes select für mehrdeutiges Feature <<",
				">> in Ancestor <<",
				">>.",
				"VMSS: Featurename muß finaler Name von geerbtem Feature sein und darf nicht mehrfach in der select-Liste vorkommen.",
				"VMSS: Feature in select_clause muß mehrere potentielle Versionen besitzen.",
				"VOMB: Die inspect-Konstanten müssen vom selben Typ sein wie der Inspect-Ausdruck.",
				"VOMB: Ausdruck in Multi_branch muß vom Typ INTEGER oder CHARACTER sein.",
				"VOMB: Wenn eine Inspect-Konstante Unique ist, müssen alle anderen Konstanten, die nicht Unique sind, null oder negativ sein.",
				"VOMB: Inspekt-Konstanten müssen unterschiedliche Werte haben.",
				"VOMB: Die selbe Unique-Konstante darf nicht mehrfach in einer Multi_branch-Anweisung vorkommen.",
				"VOMB: Alle UNIQUE-Konstanten eines Multi_branch müssen dieselbe Ursprungsklasse haben.",
				"VQMC: Typ einer Boolean-Konstante muß BOOLEAN sein.",
				"VQMC: Typ einer Zeichen-Konstante muß CHARACTER sein.",
				"VQMC: Typ einer Integer-Konstante muß INTEGER sein.",
				"VQMC: Typ einer Reellen-Konstante muß REAL oder DOUBLE sein.",
				"VQMC: Typ einer Zeichenketten-Konstante muß STRING sein.",
				"VQMC: Typ einer Bit-Konstante muß BIT N sein.",
				"VQUI: Der Typ einer UNIQUE-Konstanten muß INTEGER sein.",
				"VREG: Der gleiche Bezeichner darf nicht doppelt in einer Entity_declaration_list vorkommen.",
				"VRFA: Formales Argument darf nicht denselben Namen haben wie ein Feature der Klasse.",
				"VRLE: Lokaler Bezeichenr darf nicht denselben Namen haben wie ein Feature der Klasse.",
				"VRLE: Lokaler Bezeichenr darf nicht denselben Namen haben wie ein formales Argument des Features.",
				"VSRC: Root Class darf nicht generisch sein.",
				"VSRC: Root Creation Prozedur darf keine Argumente haben und darf keine Funktion sein.",
				"VSRC: Root Creation Prozedur muß in Root Class vorhanden sein.",
				"VRRR: Deferred und External Routinen dürfen weder Local_declaration noch Rescue Anweisung besitzen.",
				"VTAT: Anchored Typ darf nicht rekursiv definiert sein.",
				"VTAT: Anchor muß Name eines Features, eines formalen Arguements oder Current sein.",
				"VTAT: Anchor darf nicht selbst Anchored sein.",
				"VTAT: Anchor muß Referenztyp sein.",
				"VTBT: Ein Bit_type benötigt eine positive Integer-Konstante als Größe.",
				"VTCG: Aktueller generischer Parameter muﬂ dem generischen Constraint entsprechen.",
				"VTCT: Der Class_name eines Class_type muß der Name einer Klasse des umgebenden Universums sein.",
				"VTEC: Expanded darf als Basisklasse keine abstrakte (deferred) Klasse haben.",
				"VTEC: Basisklasse eines expanded-Typs darf höchstens eine Creation-routine besitzen.",
				"VTEC: Creation-Prozedur eines expanded-Typs muß für diese Klasse verfügbar sein.",
				"VTEC: Creation-Prozedur eines expanded-Typs darf keine Argumente haben.",
				"VTUG: Aktuelle generische Parameter d¸rfen nur bei generischer Klasse angegeben werden.",
				"VTUG: Aktuelle generische Parameter f¸r generischen Klasse nötig.",
				"VTUG: Anzahl der aktuellen generischen Parameter muss gleich der Anzahl der formalen generischen Parameter sein.",
				"VUAR: Adreßoperator $ nur beim Aufruf von externer Routine erlaubt.",
				"VUAR: Nach dem Adressoperator muss der finale Name eines Features dieser Klasse stehen.",
				"VUAR: Adressoperator darf nicht auf ein konstantes Attribut angewendet werden.",
				"VUAR: Das aktuelle Argument eines Aufrufs muss dem formalen Argument entsprechen (conformance).",
				"VUAR: Adressoperator darf nicht auf ein konstantes Attribut angewendet werden.",
				"VUAR: Aktuelle Argumente dieses Aufrufs fehlen.",
				"VUAR: Für diesen Aufruf werden keine aktuellen Argumente erwartet.",
				"VUAR: Falsche Anzahl an aktuellen Argumenten für diesen Aufruf.",
				"VUEX: Aufgerufenes Feature muß in aufgerufener Klasse existieren.",
				"VUEX: Aufgerufenes Feature muﬂ dieser Klasse zur Verf¸gung stehen (available).",
				"VWBE: Eine Boolean_expression muß vom Typ BOOLEAN sein.",
				"VWCA: Ein Constant_attribute muß der finale Name eines konstanten Attributes dieser Klasse sein.",
				"VWEQ: In Gleichheitsausdruck muß einer Ausdr¸cke dem anderen entsprechen (conformance).",
				"VWID: Ein unqualifizierter Bezeichner in einem Ausdruck muﬂ der Name eines Features dieser Klasse sein.",
				"VWID: Ein unqualifizierter Bezeichner in einem Ausdruck muﬂ der Name eines Features dieser Klasse, eine lokale Entit‰t dieser Routine oder ein formales Argument sein.",
				"VWST: Alle Bezeichner in einem STRIP-Ausdrück müssen finale Namen von Attributen dieser Klasse sein.",
				"VWST: Kein Bezeicher darf doppelt in der Attributlist eines STRIP-Ausdrucks auftreten.",
				"VXRC: Eine Rescue-Clause darf nur bei einer internen Routine angegeben werden.",
				"VXRT: Eine Retry-Anweisung darf nur im Rescue-clause stehen.",
				Void,    -- 118 
				Void,    -- 119
				Void,    -- 120
				Void,    -- 121
				Void,    -- 122
				Void,    -- 123
				Void,    -- 124
				Void,    -- 125
				Void,    -- 126
				Void,    -- 127
				Void,    -- 128
				Void,    -- 129
				"Scanner: Fehler in %%/code/-Sequenz.",
				"Scanner: Illegaler ASCII-Code in %%/code/ Sequenz.",
				"Scanner: %"/%" in %%/code/-Sequenz erwartet.",
				"Scanner: Umgebrochene Zeile: %"%%%" an Zeilenanfang erwartet.",
				"Scanner: Illegales Zeichen im Quelltext.",
				"Scanner: Konstante Zahl zu groß.",
				"Scanner: Zweites Anführungszeichen in String fehlt.",
				"Scanner: Zweites %"%'%" in Character-Konstant fehlt.",
				"Scanner: Fehler in Integer- oder Real-Konstante.",
				"Scanner: Fehler in Real-Konstante.",
				"Scanner: Exponent in Real-Konstante erwartet.",
				"Scanner: Illegales Scannersymbol.",
				"Scanner: %"",
				"%" erwartet.",
				Void,    -- 144
				Void,    -- 145
				Void,    -- 146
				Void,    -- 147
				Void,    -- 148
				Void,    -- 149
				"Parser: Character-Konstante erwartet.",
				"Parser: Integer-Konstante erwartet.",
				"Parser: Konstante erwartet.",
				"Parser: %"{%" in Clients erwartet.",
				"Parser: %"}%" am Schluß von Clients erwartet.",
				"Parser: %">>%" am Ende von Manifest_array erwartet.",
				"Parser: %"(%" in Strip-Ausdruck erwartet.",
				"Parser: Zweites %"!%" in Creation erwartet.",
				"Parser: %"end%" erwartet.",
				"Parser: Dateiende erwartet.",
				"Parser: Nach Creation_list darf kein Strichpunkt stehen.",
				"Parser: Illegaler Präfix-Operator.",
				"Parser: Illegaler Infix-Operator.",
				"Parser: Bezeichner nach Adressoperator %"$%" erwartet.",
				"Parser: Anchor-Bezeichner hinter %"like%" erwartet.",
				"Parser: Featurebezeichner in Call erwartet.",
				"Parser: Class_name-Bezeichner erwartet.",
				"Parser: Class_name-Bezeichner in Clients erwartet.",
				"Parser: Featurebezeichner erwartet.",
				"Parser: Formal_generic_name-Bezeichner erwartet.",
				"Parser: Formal_argument-Bezeichner erwartet.",
				"Parser: Writeable-Bezeichner erwartet.",
				"Parser: Debug_key in Anführungszeichen erwartet.",
				"Parser: Language_name in Anführungszeichen erwartet.",
				"Parser: External_name in Anführungszeichen erwartet.",
				"Parser: Präfix-Operator in Anführungszeichen erwartet.",
				"Parser: Infix-Operator in Anführungszeichen erwartet.",
				"Parser: Obsolete-Meldung in Anführungszeichen erwartet.",
				"Parser: %".%" nach Parenthesized_qualifier erwartet.",
				"Parser: %":%" in Formal_arguments erwartet.",
				"Parser: %")%" in Parenthesized_qualifier erwartet.",
				"Parser: %")%" nach den Parametern in Call erwartet.",
				"Parser: %")%" am Ende der Debug_keys erwartet.",
				"Parser: %")%" am Ende der Formal_arguments erwartet.",
				"Parser: %")%" in Ausdruck erwartet.",
				"Parser: %")%" am Ende des Strip-Ausdrucks erwartet.",
				"Parser: %"]%" in Actual_generics erwartet.",
				"Parser: %"]%" am Ende der Formal_generics erwartet.",
				Void,    -- 188
				Void,    -- 189
				Void,    -- 190
				Void,    -- 191
				Void,    -- 192
				Void,    -- 193
				Void,    -- 194
				Void,    -- 195
				Void,    -- 196
				Void,    -- 197
				Void,    -- 198
				Void,    -- 199
				"Compilation: Überlauf in konstantem Ausdruck.",
				"Compilation: Klassenname und Dateiname stimmen nicht überein.",
				"Compilation: Anchored Typ in Parent nicht erlaubt.",
				"V***: Illegale rekursive Verwendung eines formalen generischen Parameters.",
				"V***: Schleifenvariante muß vom Typ INTEGER sein.", 
				Void,    -- 205
				Void,    -- 206
				Void,    -- 207
				Void,    -- 208
				Void,    -- 209
				title,
				"Aufruf: FEC <Projektname>%N",
				"ok.%N",
				" + ",
				" + obj/main.o",
				" + elink",
				" - ",
				"%N",
				"%N%N",
				" *** konnte Datei nicht erzeugen!%N",
				" Fehler gefunden.%N%N",
				" Bytes Machinencode erzeugt.%N",
				"%NFehler bei Systemerzeugung: ",
				"%NFehler: ",
				"%NFehler in Datei <<",
				">> Zeile: ",
				" Spalte: ",
				"%N",
				"%NWarnung in Datei <<",
				">> Zeile: ",
				" Spalte: ",
				"%N",
				"Unbekannte Datei",
				"compiliere:%N",
				"Quelltext zu Klasse <<",
				">> nicht gefunden.",
				" *** Fehler in Environment: <<",
				">> nicht verstanden.%N",
				"Environment Datei erzeugt. Bitte FEC nochmals starten um Eiffel System zu compilieren.%N"
			>>
		end; -- deutsche_meldungen

--------------------------------------------------------------------------------

	english_messages : ARRAY[STRING] is
		once
			Result := <<
				"VAOL: %"old%" may only be used within a postcondition.",
				"VAPE: A local identifier may not be used within a precondition.",
				"VAPE: Every feature used in a precondition of a routine r must be available to every class to which r is available.",
				"VBAR: An Assignment is valid if and only if the source expression conforms to its target entity.",
				"VCCH: A deferred class must have deferred features.",
				"VCFG: All formal generic names must be different.",
				"VCRN: Ending comment must repeat the Class_name given at the head of the class, it must look like %"-- <Class_name>%".",
				"VDJR: Join rule: Different features inherited under the same final name must have identical signatures.",
				"VDRD: Illegal redeclaration: Signature of redeclared feature must conform to the original one.",
				"VDRD: An attribute must be redeclared as an attribute.",
				"VDRD: The Precondition of redeclared routine must begin with %"require else%" and the postcondition must begin with %"ensure then%".",
				"VDRD: Redeclaration between external and non-external routines is not possible.",
				"VDRD: A inherited effective feature may not be redefined as deferred.",
				"VDRD: This feature is being redefined, but its name ist not given in the redefine list of the parent clause.",
				"VDRS: A feature name listed in a redefine clause must be the final name of an inherited feature and it may not be listed more than once.",
				"VDRS: A frozen feature or a constant attribute may not be redefined.",
				"VDRS: Feature_declaration for this redefined feature is missing in this class.",
				"VDRS: A frozen feature cannot be redefined.",
				"VDRS: Redefinition may not turn an deferred into an effective feature (redefine unnecessary).",
				"VDUS: Feature name must be final name of inherited feature and may not appear more than once within the undefine list.",
				"VDUS: Frozen feature or attribute may not be undefined.",
				"VDUS: Only effective features may be undefined.",
				"VEEN: Result may not be used within a routine's precondition." ,
				"VEEN: Result may only be used within a function.",
				"VEEN: Illegal writeable: This is not a writeable attribute.",
				"VEEN: Writeable must be final name of an attribute of this class or a local variable.",
				"VEEN: Formal arguments are not writeable.",
				"VFFD: A feature must a an attribute, constant, procedure or function according to the rules given in 5.11 of %"Eiffel: The Language%".",
				"VFFD: The Result of a Once-Function must not be of a Formal_generic nor an anchored type.",
				"VFFD: A frozen feature may not be deferred.",
				"VFFD: A prefix-operator must be a function or attribute without arguments.",
				"VFFD: An infix-operator must be a function with exactly one argument.",
				"VGCC: Creation type must not be a Formal_generic_name.",
				"VGCC: Base class of creation type must not be deferred.",
				"VGCC: Explicit creation type must conform to the type of the writable given in the Creation instruction.",
				"VGCC: Explicit creation type must be reference type.",
				"VGCC: The base class of the creation type has no creators part, so there must not be a Creation_call part within this Creation instruction.",
				"VGCC: The base calls of the creation type has a creators part, so there must be a Creation_call part within this Creation instruction.",
				"VGCC: Routine given in Creation_call must be available for creation to this class.",
				"VGCC: Creation routine may not be a function or a once-routine.",
				"VGCP: Feature name in Creation_clause must be final name of a procedure of this class.",
				"VGCP: Creation procedure must not be a function.",
				"VGCP: Creation proceudre of expanded class must not have arguments.",
				"VGCP: A deferred class may not include a Creation_clause.",
				"VGCP: Expanded class may not have more than one creation procuedure.",
				"VGCP: A feature name must not appear more than once within one Creation_clause.",
				"VHAY: Any system needs a class of name ANY.",
				"VHPR: Inheritance may not be cyclic.",
				"VHRC: old_name must be a final_name of a feature of the parent class and it must not appear twice withine the Rename_clause.",
				"VJRV: An Assignment_attempt is valid if and only if the type of the target entitiy is a reference type.",
				"VKCN: If the feature in a call is a procedure, the call must be an instruction.",
				"VKCN: If the feature of a call is an attribute or a function, the call must be an expression.",
				"VLEC: It is valid for a class C to be an expanded client of a class SC if and only if SC is not a direct or indirect expanded client of C.",
				"VLEL: At most one of the feature_lists in an Export List may be %"all%".",
				"VLEL: A New_exports parent appearing in class C in a Parent clause for a parent B is valid if and only if all the identifiers given in its feature_lists are the final names of features of C obtained from B and no feature name appears twice in any such list, or appears in more than one list.",
				"VMFN / VMCN: A class may not introduce two different features, both deferred or both effective, with the same name.",
				"VMFN / VMCN: A class may not inherit several effective features under the same final name: ",
				"VMRC: A potentially ambigous feature must not be present in several select clauses.",
				"VMRC 2: Missing select for ambiguos feature <<",
				">> in Ancestor <<",
				">>.",
				"VMSS: A Feature_name appearing in a Select subclause in the parent part for a class B in a class D must be the final name in D of a feature inherited from B and must appear only once in the Feature_list.",
				"VMSS: A Feature_name appearing in a Select subclause in the parent part for a class B in a class D must be the final name in D of a feature inherited from B that has two or more potential versions in D.",
				"VOMB: Any inspect constant must be a constant of the same type as the inspect expression.",
				"VOMB: The inspect expression must be of type INTEGER or CHARACTER.",
				"VOMB: If any inspect constant is Unique, then every other inspect constant in the instruction is either Unique or has a negative or zero value.",
				"VOMB: Any two non-Unique inspect constant must have different values.",
				"VOMB: Any two Unique inspect constants must have different names.",
				"VOMB: All Unique inspect constants must have the same class of origin (the enclosing class or a proper ancestor).",
				"VQMC: A Boolean_constant must be of type BOOLEAN.",
				"VQMC: A Character_constant must be of type CHARACTER.",
				"VQMC: A Integer_constant must be of type INTEGER.",
				"VQMC: A Real_constant must be of type REAL or DOUBLE.",
				"VQMC: A Manifest_string_constant must be of type STRING.",
				"VQMC: A Bit_constant consisting of M bits must be of type BIT M.",
				"VQUI: A declaration of a feature introducing a Unique constant is valid if and only if the type declared for it is INTEGER.",
				"VREG: An identifier must not appear twice within one Entity_declaration_list.",
				"VRFA: A formal argument may not have the same name as a feature of the class.",
				"VRLE: A local identifier may not have the same name as the final name of a feature of the class.",
				"VRLE: A local identifier may not have the same name as a formal argument of the feature.",
				"VSRC: Root class must not be generic",
				"VSRC: Root creation procedure must not have any arguments and must not be a function.",
				"VSRC: Root creation procedure must exist in root class.",
				"VRRR: The Routine_body of deferred or external routines may neither have a Local_declarations nor a Rescue part.",
				"VTAT: Declared type of anchored must be a non-anchored reference type.",
				"VTAT: Anchor must be name of a feature, a forma argument or Current.",
				"VTAT: Anchor may not itselv a of an anchored type.",
				"VTAT: Anchor must be of a reference type.",
				"VTBT: The constant of a Bit_type declaration must be of type INTEGER and must have a positive value.",
				"VTCG: Actual generic parameter must conform to the formal generic parameter's constraint.",
				"VTCT: The Class_name of a Class_type must be the name of a class of the surrounding universe.",
				"VTEC: Base class of an expanded type may not be deferred.",
				"VTEC: Base class of an expanded type may either have no creators pars or a creators part that lists exactly one creation routine.",
				"VTEC: Creation routine of an expanded type must be available for this class.",
				"VTEC: Creation routine of an expanded type must not have arguments.",
				"VTUG: Actual generic parameters may be given only for generic classes.",
				"VTUG: Actual generic parameters for generic class are missing.",
				"VTUG: Number of actual generic parameters must the same as the number of formal generic parameters of the generic class.",
				"VUAR: The Adress form %"$ fn%" may only be used for a call to an external routine.",
				"VUAR: If an actual argument is of the Address form %"$ fn%", fn must be the final name of a feature of the this class which is not a constant attribute.",
				"VUAR: The Adress form %"$ fn%" may not be used on a constant attribute.",
				"VUAR: Every actual argument in a call must conform to the corresponding formal argument.",
				"VUAR: The Adress form %"$ fn%" may not be used on a constant attribute.",
				"VUAR: Actual arguments of this call are missing.",
				"VUAR: For this call does not need any actual arguments.",
				"VUAR: The number of actual arguments in a call must be the same as the number of formal arguments declared for the called feature.",
				"VUEX: Called feature must exist in the base class of the target type.",
				"VUEX: Called feature must be available to this class.",
				"VWBE: A Boolean_expression is valid if and only if it is an Expression of type BOOLEAN.",
				"VWCA: A Constant_attribute appearing in a class C is valid if and only if its Entity is the final name of a constant attribute of this class.",
				"VWEQ: An Equality expression is valid if and only if either of its operands conforms to the other.",
				"VWID: An unqualified identifier in an expression must be the final name of a features of this class.",
				"VWID: An unqualified identifier in an expression must be the final name of a feature of this class, a local entity or a formal argument.",
				"VWST: Every identifiers appearing in a Strip expression must be the final name of an attribute of this class.",
				"VWST: No identifier may appear twice in a Strip expression.",
				"VXRC: A routine may include a Rescue clause if and only if its Routine_body is of the Internal form.",
				"VXRT: A Retry instruction is valid if and only if it appears in a Rescue clause.",
				Void,    -- 118
				Void,    -- 119
				Void,    -- 120
				Void,    -- 121
				Void,    -- 122
				Void,    -- 123
				Void,    -- 124
				Void,    -- 125
				Void,    -- 126
				Void,    -- 127
				Void,    -- 128
				Void,    -- 129
				"Scanner: Error in %%/code/-sequence.",
				"Scanner: Illegal ASCII-Code in %%/code/-sequence.",
				"Scanner: %"/%" in %%/code/-sequence expected.",
				"Scanner: %"%%%" at beginning of line expected after split string.",
				"Scanner: Illegal Character.",
				"Scanner: Constant number is too big.",
				"Scanner: Second quotation mark in constant String expected.",
				"Scanner: Second %"%'%" in Character-constant is missing.",
				"Scanner: Error in Integer- or Real-constant.",
				"Scanner: Error in Real-constant.",
				"Scanner: Exponent in Real-constant exepected.",
				"Scanner: Illegal scanner symbol.",
				"Scanner: %"",
				"%" expected.",
				Void,    -- 144
				Void,    -- 145
				Void,    -- 146
				Void,    -- 147
				Void,    -- 148
				Void,    -- 149
				"Parser: Character-constant expectd.",
				"Parser: Integer-constant expected.",
				"Parser: Constant expected.",
				"Parser: %"{%" in Clients expected.",
				"Parser: %"}%" after Clients expected.",
				"Parser: %">>%" after Manifest_array expected.",
				"Parser: %"(%" in Strip-expression expected.",
				"Parser: Second %"!%" in Creation expected.",
				"Parser: %"end%" expected.",
				"Parser: End of file expected.",
				"Parser: No semicolon may be present at the end of a Creation_list.",
				"Parser: Illegal Prefix-operator.",
				"Parser: Illegal Infix-operator.",
				"Parser: Identifier after Address-operator %"$%" expected.",
				"Parser: Anchor-identifier after %"like%" expected.",
				"Parser: Feature identifier in Call expected.",
				"Parser: Class_name expected.",
				"Parser: Class_name in Clients expected.",
				"Parser: Feature identifier expected.",
				"Parser: Formal_generic_name expected.",
				"Parser: Formal_argument identifier expected.",
				"Parser: Writeable identifier expected.",
				"Parser: Debug_key in quotation marks expected.",
				"Parser: Language_name in quotation marks expected.",
				"Parser: External_name in quotation marks expected.",
				"Parser: Prefix-operator in quotation marks expected.",
				"Parser: Infix-operator in quotation marks expected.",
				"Parser: Obsolete-message in quotation marks expected.",
				"Parser: %".%" after Parenthesized_qualifier expected.",
				"Parser: %":%" in Formal_arguments expected.",
				"Parser: %")%" in Parenthesized_qualifier expected.",
				"Parser: %")%" after parameters in Call expected.",
				"Parser: %")%" after Debug_keys expected.",
				"Parser: %")%" after Formal_arguments expected.",
				"Parser: %")%" in Expression expected.",
				"Parser: %")%" after Strip expression expected.",
				"Parser: %"]%" in Actual_generics expected.",
				"Parser: %"]%" after Formal_generics expected.",
				Void,    -- 188
				Void,    -- 189
				Void,    -- 190
				Void,    -- 191
				Void,    -- 192
				Void,    -- 193
				Void,    -- 194
				Void,    -- 195
				Void,    -- 196
				Void,    -- 197
				Void,    -- 198
				Void,    -- 199
				"Compilation: Overflow in constant expression.",
				"Compilation: Class name und File name don't match.",
				"Compilation: Anchored type in parent not allowed.",
				"V***: Illegal recursive usage of a formal generic parameter.",
				"V***: Loop variant must be of type INTEGER.", 
				Void,    -- 205
				Void,    -- 206
				Void,    -- 207
				Void,    -- 208
				Void,    -- 209
				title,
				"Usage: FEC <Project name>%N",
				"ok.%N",
				" + ",
				" + obj/main.o",
				" + elink",
				" - ",
				"%N",
				"%N%N",
				" *** could not create file!%N",
				" Errors found.%N%N",
				" Bytes machinencode created.%N",
				"%NError creation system: ",
				"%NError: ",
				"%NError in file <<",
				">> line: ",
				" column: ",
				"%N",
				"%NWarning in file <<",
				">> line: ",
				" column: ",
				"%N",
				"Unknown file",
				"compiling:%N",
				"Unable to find source code of class <<",
				">>.",
				" *** Error in environment file: <<",
				">> not understood.%N",
				"Environment file created. Start FEC again to compile Eiffel System.%N"
			>>
		end; -- english_messages
		
--------------------------------------------------------------------------------

end -- MESSAGES
