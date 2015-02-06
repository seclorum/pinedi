
--[[

    ** General-purpose environment/debugging methods

]]

function dump_environment_details()

  print ("               Display Name : ", MOAIEnvironment.appDisplayName)
  print ("                     App ID : ", MOAIEnvironment.appID)
  print ("                App Version :  ", MOAIEnvironment.appVersion)
  print ("            Cache Directory : ", MOAIEnvironment.cacheDirectory)
  print ("   Carrier ISO Country Code : ", MOAIEnvironment.carrierISOCountryCode)
  print ("Carrier Mobile Country Code : ", MOAIEnvironment.carrierMobileCountryCode)
  print ("Carrier Mobile Network Code : ", MOAIEnvironment.carrierMobileNetworkCode)
  print ("               Carrier Name : ", MOAIEnvironment.carrierName)
  print ("            Connection Type : ", MOAIEnvironment.connectionType)
  print ("               Country Code : ", MOAIEnvironment.countryCode)
  print ("                    CPU ABI : ", MOAIEnvironment.cpuabi)
  print ("               Device Brand : ", MOAIEnvironment.devBrand)
  print ("                Device Name : ", MOAIEnvironment.devName)
  print ("        Device Manufacturer : ", MOAIEnvironment.devManufacturer)
  print ("                Device Mode : ", MOAIEnvironment.devModel)
  print ("            Device Platform : ", MOAIEnvironment.devPlatform)
  print ("             Device Product : ", MOAIEnvironment.devProduct)
  print ("         Document Directory : ", MOAIEnvironment.documentDirectory)
  print ("         iOS Retina Display : ", MOAIEnvironment.iosRetinaDisplay)
  print ("              Language Code : ", MOAIEnvironment.languageCode)
  print ("                   OS Brand : ", MOAIEnvironment.osBrand)
  print ("                 OS Version : ", MOAIEnvironment.osVersion)
  print ("         Resource Directory : ", MOAIEnvironment.resourceDirectory)
  print ("                 Screen DPI : ", MOAIEnvironment.screenDpi)
  print ("              Screen Height : ", MOAIEnvironment.screenHeight)
  print ("               Screen Width : ", MOAIEnvironment.screenWidth)
  print ("            Screen Vertical : ", MOAIEnvironment.verticalResolution)
  print ("          Screen Horizontal : ", MOAIEnvironment.horizontalResolution)
  print ("                       UDID : ", MOAIEnvironment.udid)
end

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  print ("Table Print:")
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end
--print(to_string {"Lua", user="Mariacher", {{co=coroutine.create(function() end),{number=12345.6789}}, func=function() end}, boolt=true} )


--[[
   Author: Julio Manuel Fernandez-Diaz
   Date:   January 12, 2007
   (For Lua 5.1)

   Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()

   Formats tables with cycles recursively to any depth.
   The output is returned as a string.
   References to other tables are shown as values.
   Self references are indicated.

   The string returned is "Lua code", which can be procesed
   (in the case in which indent is composed by spaces or "--").
   Userdata and function keys and values are shown as strings,
   which logically are exactly not equivalent to the original code.

   This routine can serve for pretty formating tables with
   proper indentations, apart from printing them:

      print(table.show(t, "t"))   -- a typical use

   Heavily based on "Saving tables with cycles", PIL2, p. 113.

   Arguments:
      t is the table.
      name is the name of the table (optional)
      indent is a first indentation (optional).
--]]
function table.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" or type(o) == "boolean" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value]
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end


--// CHILL CODE ™ //--
-- table.ordered( [comp] )
--
-- Lua 5.x add-on for the table library.
-- Table using sorted index.  Uses binary table for fast Lookup.
-- http://lua-users.org/wiki/OrderedTable by PhilippeFremy

-- table.ordered( [comp] )
-- Returns an ordered table. Can only take strings as index.
-- fcomp is a comparison function behaves behaves just like
-- fcomp in table.sort( t [, fcomp] ).
function table.ordered(fcomp)
  local newmetatable = {}

  -- sort func
  newmetatable.fcomp = fcomp

  -- sorted subtable
  newmetatable.sorted = {}

  -- behavior on new index
  function newmetatable.__newindex(t, key, value)
    if type(key) == "string" then
      local fcomp = getmetatable(t).fcomp
      local tsorted = getmetatable(t).sorted
      table.binsert(tsorted, key , fcomp)
      rawset(t, key, value)
    end
  end

  -- behaviour on indexing
  function newmetatable.__index(t, key)
    if key == "n" then
      return table.getn( getmetatable(t).sorted )
    end
    local realkey = getmetatable(t).sorted[key]
    if realkey then
      return realkey, rawget(t, realkey)
    end
  end

  local newtable = {}

  -- set metatable
  return setmetatable(newtable, newmetatable)
end

--// table.binsert( table, value [, comp] )
--
-- LUA 5.x add-on for the table library.
-- Does binary insertion of a given value into the table
-- sorted by [,fcomp]. fcomp is a comparison function
-- that behaves like fcomp in in table.sort(table [, fcomp]).
-- This method is faster than doing a regular
-- table.insert(table, value) followed by a table.sort(table [, comp]).
function table.binsert(t, value, fcomp)
  -- Initialise Compare function
  local fcomp = fcomp or function( a, b ) return a < b end

  --  Initialise Numbers
  local iStart, iEnd, iMid, iState =  1, table.getn( t ), 1, 0

  -- Get Insertposition
  while iStart <= iEnd do
    -- calculate middle
    iMid = math.floor( ( iStart + iEnd )/2 )

    -- compare
    if fcomp( value , t[iMid] ) then
      iEnd = iMid - 1
      iState = 0
    else
      iStart = iMid + 1
      iState = 1
    end
  end

  local pos = iMid+iState
  table.insert( t, pos, value )
  return pos
end

-- Iterate in ordered form
-- returns 3 values i, index, value
-- ( i = numerical index, index = tableindex, value = t[index] )
function orderedPairs(t)
  return orderedNext, t
end
function orderedNext(t, i)
  i = i or 0
  i = i + 1
  local index = getmetatable(t).sorted[i]
  if index then
    return i, index, t[index]
  end
end

