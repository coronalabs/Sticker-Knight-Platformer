local M = {}

local json = require "json"
--local translate = require "com.ponywolf.translator"

-- are we running on a simulator?
local isSimulator = "simulator" == system.getInfo( "environment" )
local dir = isSimulator and "csv/" or "dat/"

-- Create your own 64 character string (with no
-- repeats) for even more "security" or randomize
-- "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
-- with http://textmechanic.com/String-Randomizer.html
local b = "w3Oqe0godWZhkKu1/HjVBiJ2yEYATIbLGDpa6sMvC5lnt8+RQcxf9UPFNmS47zXr"

-- Base64 encoding
local function enc(data)
  return ((data:gsub('.', function(x) 
          local r,b='',x:byte()
          for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
          return r;
        end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
      end)..({ '', '==', '=' })[#data%3+1])
end

-- Base64 decoding
local function dec(data)
  data = string.gsub(data, '[^'..b..'=]', '')
  return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
      end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
      end))
end

local function luafy(tbl)
  for k, v in pairs(tbl) do
    if v=="true" then
      tbl[k]=true
    elseif v=="false" then
      tbl[k]=false
    elseif tonumber(str) then
      tbl[k]=tonumber(v)
    elseif v=="" then
      tbl[k]=nil            
    elseif type(v) == "table" then
      luafy(v)
    end
  end
  return tbl
end

local function saveData(filename, contents)
  -- write the obscured data out as .dat file
  filename = filename:gsub(".csv",".dat")

  local path = system.pathForFile(filename, system.DocumentsDirectory)
  local file = io.open(path, "w")
  if file then
    for i = 1, #contents do  
      file:write( contents[i] .."\n" )
    end
    io.close( file )
    return true
  else
    print("Can't open ", filename)
    return false
  end
end

local function loadFile(filename)
  -- load a CSV if we are in the simulator,
  -- but save a obscured DAT file.
  -- load DAT and un-obscure if we are not in the sim
  if not isSimulator then
    filename = filename:gsub(".csv",".dat")
  end

  local path = system.pathForFile(dir .. filename, system.ResourceDirectory)

  local contents, obscured = {}, {}
  local file = io.open( path, "r" )
  if file then
    -- read all contents of file into a string
    for line in file:lines() do  
      if isSimulator then
        contents[#contents+1] = line
        obscured[#obscured+1] = enc(line)
      else
        contents[#contents+1] = dec(line)
      end
    end
    io.close( file )
  else
    print("File not found")
    return nil
  end
  if isSimulator then
    if saveData(filename, obscured) then
      print("Saved obscured CSV to DocumentsDirectory as", filename:gsub(".csv",".dat"))
    end
  end
  return contents
end

local function parseCSV(s)
  s = s .. ','        -- ending comma
  local t = {}        -- table to collect fields
  local fieldstart = 1
  repeat
    -- next field is quoted? (start with `"'?)
    if string.find(s, '^"', fieldstart) then
      local a, c
      local i  = fieldstart
      repeat
        -- find closing quote
        a, i, c = string.find(s, '"("?)', i+1)
      until c ~= '"'    -- quote not followed by quote?
      if not i then error('unmatched "') end
      local f = string.sub(s, fieldstart+1, i-1)
      table.insert(t, (string.gsub(f, '""', '"')))
      fieldstart = string.find(s, ',', i) + 1
    else                -- unquoted; find next comma
      local nexti = string.find(s, ',', fieldstart)
      table.insert(t, string.sub(s, fieldstart, nexti-1))
      fieldstart = nexti + 1
    end
  until fieldstart > string.len(s)
  return t
end

function M.load(filename)
  local csvTable = {}

  local contents = loadFile(filename)
  local keys = parseCSV(contents[1])
  for k = 1, #keys do keys[k] = keys[k]:gsub("\r","") end

  for i = 2, #contents do
    local item = #table + 1
    local values = parseCSV(contents[i])
    local row = {}
    for k = 1, #keys do
      row[keys[k]] = values[k]:gsub("\r","")
      row[keys[k]] = tonumber(row[keys[k]]) ~= nil and tonumber(row[keys[k]]) or row[keys[k]]
      if translate then
        if translate.keys[keys[k]] then
          local const 
          if row["id"] then 
            const = row["id"] .. "_" .. keys[k]
          end
          row[keys[k]] = translate(row[keys[k]], const)
        end
      end
    end
    if not(row["enabled"] == "FALSE") then
      table.insert(csvTable,row)
    end
  end

  --csvTable = luafy(csvTable)

  function csvTable:find(k,v)
    for i = 1, #self do
      --print(i,k,v)
      if self[i][k] == v then
        return self[i]
      end 
    end
    return {} 
  end

  return csvTable
end

return M