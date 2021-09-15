local Uint32 = require("Uint32")
local function Split(s)
    local Splited = {}
    for c in s:gmatch("([^%s]+)") do
        table.insert(Splited,c)
    end
    return Splited
end
local function GetNumber(s)
    local Hex = s:match("^x(.+)")
    return Hex and tonumber(Hex,16) or tonumber(s)
end
return function(Input,Output)
    local File = io.open(Input or "program.racc","r")
    local Bytecode = ""
    local LastLine = true
    while true do
        local Line = File:read("*line")
        if not Line then break end
        local InstructionRaw = Line:match("^%w+")
        local InstructionName = InstructionRaw and InstructionRaw:upper()
        local InstructionHeaderSize = InstructionName and #(Line:match("^%w+%s+") or InstructionName)
        if InstructionHeaderSize then
            local RawArguments = Line:sub(InstructionHeaderSize+1)
            local Arguments = Split(Line:sub(InstructionHeaderSize+1))
            if InstructionName == "CALL" then
                local FunctionCell = string.char(GetNumber(table.remove(Arguments,1)))
                for Index,Value in next,Arguments do
                    Arguments[Index] = string.char(GetNumber(Value))
                end
                Bytecode = Bytecode .. ("\255"..FunctionCell..string.char(#Arguments)..table.concat(Arguments))
            elseif InstructionName == "ENVSET" then
                Bytecode = Bytecode .. ("\254"..Uint32.encode({#Arguments[1]})..Arguments[1]..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "ENV" then
                Bytecode = Bytecode .. ("\253"..Uint32.encode({#Arguments[1]})..Arguments[1])
            elseif InstructionName == "TRUE" then
                Bytecode = Bytecode .. "\18"
            elseif InstructionName == "FALSE" then
                Bytecode = Bytecode .. "\17"
            elseif InstructionName == "MOD" then
                Bytecode = Bytecode .. ("\16"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "POW" then
                Bytecode = Bytecode .. ("\15"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "DIV" then
                Bytecode = Bytecode .. ("\14"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "MUL" then
                Bytecode = Bytecode .. ("\13"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "SUB" then
                Bytecode = Bytecode .. ("\12"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "ADD" then
                Bytecode = Bytecode .. ("\11"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "CON" then
                Bytecode = Bytecode .. ("\10"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "NEG" then
                Bytecode = Bytecode .. ("\9"..string.char(GetNumber(Arguments[1])))
            elseif InstructionName == "FLO" then
                Bytecode = Bytecode .. ("\8"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "INT" then
                Bytecode = Bytecode .. ("\7"..Uint32.encode({GetNumber(Arguments[1])}))
            elseif InstructionName == "STR" then
                Bytecode = Bytecode .. ("\6"..Uint32.encode({#RawArguments})..RawArguments)
            elseif InstructionName == "SETTABLE" then
                Bytecode = Bytecode .. ("\5"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2]))..string.char(GetNumber(Arguments[3])))
            elseif InstructionName == "GETTABLE" then
                Bytecode = Bytecode .. ("\4"..string.char(GetNumber(Arguments[1]))..string.char(GetNumber(Arguments[2])))
            elseif InstructionName == "NEWTABLE" then
                Bytecode = Bytecode .. "\3"
            elseif InstructionName == "CLR" then
                Bytecode = Bytecode .. ("\2"..Uint32.encode({GetNumber(Arguments[1])}))
            elseif InstructionName == "MOVE" then
                Bytecode = Bytecode .. ("\1"..string.char(GetNumber(Arguments[1]))..Uint32.encode({GetNumber(Arguments[2])}))
            elseif InstructionName == "READ" then
                Bytecode = Bytecode .. ("\0"..Uint32.encode({GetNumber(Arguments[1])}))
            end
        end
    end
    File:close()
    local BinFile = io.open(Output or "program.bin","w")
    BinFile:write(Bytecode)
    BinFile:close()
end
