HOW TO COMPILE

The requirements: bison, make, c++, lex or flex.  The optimizer part of the compiler requires the presence of pcrecpp library.  Just type `make'.


HOW TO USE

Just run `rbkbasic <INPUT.bas >OUTPUT.asm'.  This produces OUTPUT.asm in MACRO-11 format.  This file has a slight dependency on AnDOS.  The files `gc.s', `rbkbasic.mac', `rbkbasic.inc' have to be at the same directory as `INPUT.asm' at the assemble stage.  The script `build-notepad-bk' provides an example of linking, etc.  Place COM-file to the disk and run it.  BIN-file theoretically maybe also used, it doesn't require the proper timestamp.


Supported operators: ^ \ * + - ( ) = < > <= >= =< => <> ><


Unsupported operators: /


Supported keywords:
? ABS AND ASC AT BIN$ BLOAD BSAVE CHR$ CLEAR CLS CSRLIN DATA DEC DEF DIM ELSE END EOF EQV FILES FIND FN FOR GET# GOSUB GOTO HEX$ IF IMP INKEY$ INP INPUT INSTR LEN LET LOCATE MID$ MOD MONIT NEXT NOT OCT$ ON OR OUT PEEK POKE POS PRINT READ REM RESTORE RETURN SGN SPC STEP STR$ STRING$ SYSTEM TAB THEN TO UINT$ UPPER$ USR VAL VARPTR XOR


Unsupported keywords:
BEEP CINT COLOR KEY
CIRCLE DRAW PAINT POINT PRESET PSET
ATN CDBL COS EXP INT FIX LOG PI RND SIN SQR TAN CSNG
. AUTO CALL CLOAD CONT CSAVE DELETE LIST LLIST LOAD LPOS MERGE NEW RENUM RUN SAVE STOP TROFF TRON
SCREEN


The new features:

+ Variable names may have any length.

+ It is possible to use the several statements at one BASIC's line using ':' separator between statements.  The line length is unlimited.

+ New statement GET# allows to use char-by-char data transmission, e.g., GET#a$ inputs one character or the empty string to a$ from a file opened to read.  It is the file equivalent of INKEY$.

+ New function DEC converts hexadecimal string to the integer, e.g., dec("a0A")=2570.

+ INSTR maybe used with 2 arguments, e.g., instr("abcdef", "cd") = instr(1, "abcdef", "cd").

+ New function UPPER$ converts lowercase letter in the string to the uppercase.

+ New function UINT$ provides the conversion to unsigned integer.  For example, UINT$(-1) gives "65535".


The unsupported or supported with the limits features of BK0011 Basic:

- Supported only integer (at the range -32768..32767) and string (up to 255 chars length) types.

- DIM should be used for any array (even with less than 10 elements) and its number argument has to be a constant.  Only one dimensional arrays are supported.  The virtual arrays are not supported (so as for VARPTR).

- Only some syntax errors are detected.


Special notes:

* The compiler supports several keywords of BK0011 Basic.

* Executable file size is up to 32256 bytes. 16384 additional bytes maybe used for strings and machine code.  The executable starts from address 512.  The generated code uses AnDOS calls which emulates BK0010 ROM functions.  It doesn't use BK0011 ROM calls.

* Memory area at 532-565 are free for a user (ML, data). The memory above 16384 is switchable so it has limitations for the direct usage for ML or data.

* Keyboard interrupts are used to provide the key autorepeat. This changes the standard way to use Cyrillic signs - use AP2.

* It is necessary to use space(s) between tokens, e.g. 'if a<3 goto 10' requires space between 'if' and 'a' so as between 'goto' and '10'.

* The pages 2, 3, and 6 are used to keep the program and data. Page 0 is used as io-buffer. Page 4 contains AnDOS.  Other pages of memory are free for any usage.

* CLEAR requires exactly two arguments but the first argument is ignored because all free memory is available for the strings. CLEAR calls the garbage collector at first.  The second argument sets the upper border of memory for BASIC.  The default value for this border is 49152.  It may be set to 16384 for compatibility with BK0010.

* INPUT may have a bit different interface. For example, INPUT A,B requires to enter the value for A then press Enter-key and then the value for B terminated by Enter-key.

* CSRLIN and POS completely ignore their arguments.

* FRE shows total amount of free memory. The garbage collector is only invoked if the argument type is string. So in the case of the integer or absent argument the shown amount of memory maybe less than the actual.

* FIND has to use any MS-DOS wildcard pattern.  So FIND "*.TXT" will show all files with TXT-extension, FIND "?." will show files which names consist of one sign and have no extension.  The patterns are case sensitive.

* BLOAD always requires three arguments, e.g. BLOAD "MC",,32768 or BLOAD "MC.BIN",R,47*1024.

* BLOAD and BSAVE can't work with the file bigger than 16 KB.

* USRn(X) call puts X at R5 and then use CALL.  So the return from this ML subroutine may be achieved by RETURN instruction.  The result should be placed at R5.

* SYSTEM and MONIT commands do the same as END.

* FILES command is identical to FIND.

* \-operator can correctly divide -32768 but it ignores any errors.

* %-suffix for the integer variables is optional.

* Keywords should be spelled fully, the shortcuts are not allowed.


Common information:

@ use PEEK(208) and -256 to check the error status after file open. It should be equal to 0 if operation was successful.

@ Be careful with PEEK and POKE -- they ignore the lowest (the oddness) bit.

@ This program is distributed under the GNU General Public License, Version 2, or, at your discretion, any later version. The GNU General Public License is available via the Web at <http://www.gnu.org/copyleft/gpl.html>. The GPL is designed to allow you to alter and redistribute the package, as long as you do not remove that freedom from others.

@ This is free, fast and dirty compiler designed to compile Notepad-BK.  It is not a Visual Studio.
