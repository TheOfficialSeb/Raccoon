local Uint32_decode = require("Uint32").decode
local function sleep(s)
    return (wait and wait(s) or os.execute("sleep "..tonumber(s))) or true
end
local function Interpreter(Instructions,Debug)
    local InstructionIndex = 0
    local Cells = {}
    local unpack = unpack or table.unpack
    local RAM = {[0]=(getfenv and getfenv() or _G)}
    local function ReadCell(CellIndex,CellArray)
        local CellArray = CellArray or Cells
        return CellArray[#CellArray-(CellIndex-1)]
    end
    local function ReadInstructionIndex(InstructionIndex)
        return Instructions:sub(InstructionIndex+1,InstructionIndex+1):byte()
    end
    local function ReadInstructionIndexRaw(InstructionIndex,Length)
        return Instructions:sub(InstructionIndex+1,InstructionIndex+Length)
    end
    local function ReadInstruction(Opcode,InstructionIndex,Cells)
        if Opcode == 0 then
            local RamIndex = Uint32_decode(ReadInstructionIndexRaw(InstructionIndex+1,4),true)
            --for Index=InstructionIndex+2,(InstructionIndex+1)+Len do
            --    RamIndex = RamIndex .. ReadInstructionIndex(Index)
            --end
            return RAM[RamIndex],5
        elseif Opcode == 1 then
            local Cell0,RamIndex = ReadInstructionIndex(InstructionIndex+1),Uint32_decode(ReadInstructionIndexRaw(InstructionIndex+2,4),true)
            RAM[RamIndex] = ReadCell(Cell0)
            return true,6
        elseif Opcode == 2 then
            local Len,RamIndex = ReadInstructionIndex(InstructionIndex+1),""
            for Index=InstructionIndex+2,(InstructionIndex+1)+Len do
                RamIndex = RamIndex .. ReadInstructionIndex(Index)
            end
            local Value = Value
            RAM[RamIndex] = nil
            return Value,Len+2
        elseif Opcode == 3 then
            return {}
        elseif Opcode == 4 then
            local Cell0,Cell1 = ReadInstructionIndex(InstructionIndex+1),ReadInstructionIndex(InstructionIndex+2)
            return ReadCell(Cell0)[ReadCell(Cell1)],3
        elseif Opcode == 5 then
            local Cell0,Cell1,Cell2 = ReadInstructionIndex(InstructionIndex+1),ReadInstructionIndex(InstructionIndex+2),ReadInstructionIndex(InstructionIndex+3)
            ReadCell(Cell0)[ReadCell(Cell1)] = ReadCell(Cell2)
            return true,4
        elseif Opcode == 6 then
            local Length,CellValue = Uint32_decode(ReadInstructionIndexRaw(InstructionIndex+1,4),true),""
            for Index=InstructionIndex+5,(InstructionIndex+4)+Length do
                CellValue = CellValue .. string.char(ReadInstructionIndex(Index))
            end
            return CellValue,Length+5
        elseif Opcode == 7 then
            local CellValue = Uint32_decode(ReadInstructionIndexRaw(InstructionIndex+1,4),true)
            return CellValue,5
        elseif Opcode == 8 then
            local CellValue = ReadCell(ReadInstructionIndex(InstructionIndex+1))
            while math.floor(CellValue) ~= 0 do
                CellValue = CellValue*0.1
            end
            return CellValue,2
        elseif Opcode == 9 then
            local CellValue = ReadCell(ReadInstructionIndex(InstructionIndex+1))
            return -CellValue,2
        elseif Opcode == 10 then
            local Str0,Str1 = ReadCell(ReadInstructionIndex(InstructionIndex+1)),ReadCell(ReadInstructionIndex(InstructionIndex+2))
            return Str0..Str1,3
        elseif Opcode == 11 then
            local Float0,Float1 = ReadCell(ReadInstructionIndex(InstructionIndex+1)),ReadCell(ReadInstructionIndex(InstructionIndex+2))
            return Float0+Float1,3
        elseif Opcode == 12 then
            local Float0,Float1 = ReadCell(ReadInstructionIndex(InstructionIndex+1)),ReadCell(ReadInstructionIndex(InstructionIndex+2))
            return Float0-Float1,3
        elseif Opcode == 13 then
            local Float0,Float1 = ReadCell(ReadInstructionIndex(InstructionIndex+1)),ReadCell(ReadInstructionIndex(InstructionIndex+2))
            return Float0*Float1,3
        elseif Opcode == 14 then
            local Float0,Float1 = ReadCell(ReadInstructionIndex(InstructionIndex+1)),ReadCell(ReadInstructionIndex(InstructionIndex+2))
            return Float0/Float1,3
        elseif Opcode == 15 then
            local Float0,Float1 = ReadCell(ReadInstructionIndex(InstructionIndex+1)),ReadCell(ReadInstructionIndex(InstructionIndex+2))
            return Float0^Float1,3
        elseif Opcode == 16 then
            local Float0,Float1 = ReadCell(ReadInstructionIndex(InstructionIndex+1)),ReadCell(ReadInstructionIndex(InstructionIndex+2))
            return Float0%Float1,3
        elseif Opcode == 17 then
            return false
        elseif Opcode == 18 then
            return true
        elseif Opcode == 253 then
            local Length,CellValue = Uint32_decode(ReadInstructionIndexRaw(InstructionIndex+1,4),true),""
            for Index=InstructionIndex+5,(InstructionIndex+4)+Length do
                CellValue = CellValue .. string.char(ReadInstructionIndex(Index))
            end
            return (getfenv and getfenv() or _G)[CellValue],Length+5
        elseif Opcode == 254 then
            local Length,CellValue = Uint32_decode(ReadInstructionIndexRaw(InstructionIndex+1,4),true),""
            for Index=InstructionIndex+5,(InstructionIndex+4)+Length do
                CellValue = CellValue .. string.char(ReadInstructionIndex(Index))
            end
            (getfenv and getfenv() or _G)[CellValue] = ReadCell(ReadInstructionIndex((InstructionIndex+5)+Length))
            return true,Length+6
        elseif Opcode == 255 then
            local Cell0,Len = ReadInstructionIndex(InstructionIndex+1),ReadInstructionIndex(InstructionIndex+2)
            local Arguments = {}
            for Index=InstructionIndex+3,(InstructionIndex+2)+Len do
                table.insert(Arguments,ReadCell(ReadInstructionIndex(Index)))
            end
            return ReadCell(Cell0)(unpack(Arguments)),3+Len
        end
    end
    while #Instructions > InstructionIndex do
        local PassIndexInt
        Cells[#Cells+1],PassIndexInt = ReadInstruction(ReadInstructionIndex(InstructionIndex),InstructionIndex,Cells)
        if Debug then print("Opcode > ",ReadInstructionIndex(InstructionIndex),"Index > ",InstructionIndex+1,"","Cell > ","\""..tostring(Cells[#Cells]).."\" #"..type(Cells[#Cells]),"Pass > ",PassIndexInt) end
        InstructionIndex = InstructionIndex + (PassIndexInt or 1)
        sleep(0.05)
    end
    return ReadCell(1)
end
return Interpreter
