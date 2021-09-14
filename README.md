# Raccoon
<a href="https://www.lua.org/"><img src="https://img.shields.io/badge/Lua-5.4-blue"></a>
<a href="https://github.com/TheOfficialSeb/Raccoon"><img src="https://img.shields.io/badge/Raccoon-BETA-blue"></a>
## What is a cell in Raccoon?
	1. All instruction return a value which then relative to the current one will be it's cell
	2. Cells are Uint8 no matter what so your limited at 255
## Opt Codes
- 00
	> NAME READ
	> 
	> ARGS {Uint32(Read location)}
- 01
	> NAME MOVE
	> 
	> ARGS {Cell(ANY)}{Uint32(Read location)}
- 02
	> NAME CLR
	> 
	> ARGS {Uint32(Read location)}
- 03
	> NAME NEWTABLE
	> 
	> ARGS NONE
- 04
	> NAME GETTABLE
	> 
	> ARGS {Cell(TABLE)}{Cell(ANY)}
- 05
	> NAME SETTABLE
	> 
	> ARGS {Cell(TABLE)}{Cell(ANY)}{Cell(ANY)}
- 06
	> NAME STR
	> 
	> ARGS {Uint32(Length)}{Any(Must be size of length told)}
- 07
	> NAME INT
	> 
	> ARGS {Uint32}
- 08
	> NAME FLO
	> 
	> ARGS {Cell(INT)}
- 09
	> NAME NEG
	> 
	> ARGS {Cell(INT)}
- 0A
	> NAME CON
	> 
	> ARGS {Cell(STR)}{Cell(STR)}
- 0B
	> NAME ADD
	> 
	> ARGS {Cell(INT or FLO)}{Cell(INT or FLO)}
- 0C
	> NAME SUB
	> 
	> ARGS {Cell(INT or FLO)}{Cell(INT or FLO)}
- 0D
	> NAME MUL
	> 
	> ARGS {Cell(INT or FLO)}{Cell(INT or FLO)}
- 0E
	> NAME DIV
	> 
	> ARGS {Cell(INT or FLO)}{Cell(INT or FLO)}
- 0F
	> NAME POW
	> 
	> ARGS {Cell(INT or FLO)}{Cell(INT or FLO)}
- 10
	> NAME MOD
	> 
	> ARGS {Cell(INT or FLO)}{Cell(INT or FLO)}
- 11
	> NAME FALSE
	> 
	> ARGS NONE
- 12
	> NAME TRUE
	> 
	> ARGS NONE
