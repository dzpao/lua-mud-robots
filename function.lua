-- 函数

-- 常见见lordstar.lua

function trans(number) --转换中文数字为阿拉伯数字，非法输入默认0
    if type(number)~="string" then
        return 0
    else
        number=string.gsub(number,"零","*0+")
        number=string.gsub(number,"十","*10+")
        number=string.gsub(number,"百","*100+")
        number=string.gsub(number,"千","*1000+")
        number=string.gsub(number,"万","+0)*10000+(0+")
        number=string.gsub(number,"亿","+0)*100000000+(0+")
        number=string.gsub(number,"一","1")
        number=string.gsub(number,"二","2")
        number=string.gsub(number,"三","3")
        number=string.gsub(number,"四","4")
        number=string.gsub(number,"五","5")
        number=string.gsub(number,"六","6")
        number=string.gsub(number,"七","7")
        number=string.gsub(number,"八","8")
        number=string.gsub(number,"九","9")
        number=string.gsub(number," ","")
        number=string.gsub(number,"","")
        number=string.gsub(number,"　","")
        number="(0+"..number.."+0)"
        number=string.gsub(number,"++","+")
        number=string.gsub(number,"+%*","+")

        if string.match(number,'^[%d%+%-%*%/%(%)]+$') then --判断除了0-9 +-*/ 没有其他东西了
            number="return "..number
            local trans_math = loadstring(number)
            number=trans_math()
            trans_math=nil
            return number
        end
            return 0
    end
end

function convert_seconds (seconds)
  local hours = math.floor (seconds / 3600)
  seconds = seconds - (hours * 3600)
  local minutes = math.floor (seconds / 60)
  seconds = seconds - (minutes * 60)
  return hours, minutes, seconds
end -- function convert_seconds

function null(t) --null判断空，空的table,string, number=0  都返回true 其余返回false，非法输入返回true
    if type(t)=="table" and not (_G.next( t ) == nil) then
        return false
    elseif type(t)=="number" and t~=0 then
        return false
    elseif type(t)=="string" and t~="" then
        return false
    else
        return true
    end
end

function trim(s) --去除两边空白
    if s ~= nil then
        return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
    else
        return ""
    end
end

function list_to_table(list)
    local t={}
    list = list or ""
    for k,_ in string.gmatch(list..'|','(.-)|') do
        if k ~= "" then
            table.insert(t,k)
        end
    end
    return t
end

function list_to_check_table(list)
    local t={}
    list = list or ""
    for k,_ in string.gmatch(list..'|','(.-)|') do
        if k ~= "" then
        --  table.insert(t,k)
            t[k] = true
        end
    end
    return t
end

function random_item(list,sep)
    local t={}
    list = list or ""
    sep = sep or "|"
    if list == "" or not string.find(list,sep) then
        return list
    end

    for k,_ in string.gmatch(list..sep,'(.-)'..sep) do
        if k ~= "" then
            table.insert(t,k)
        end
    end

    local n = #t
    if n==0 then return list end
    local n = math.random(#t)
    local s = t[n] or ""
    t = nil

    return s

end

function ismember(s,list,sep)
    s = s or ""
    list = list or ""
    sep = sep or "|"

    local count = 0
    for k,_ in string.gmatch(list..sep,'(.-)'..sep) do
        count = count+1
        if k == s then
            break
        end
    end
    return count
end

function nitem(list,n,sep)
    n = n or 0
    list = list or ""
    sep = sep or "|"
    if n ==0 or list == "" then return "" end

    local count,theitem = 0,""
    for k,_ in string.gmatch(list..sep,'(.-)'..sep) do
        count = count+1
        if count == n then
            theitem = k
            break
        end
    end
    return theitem
end

function numitems(list,sep)

    list = list or ""
    sep = sep or "|"

    if list == "" then return 0 end

    local count = 0
    for k,_ in string.gmatch(list..sep,'(.-)'..sep) do
        count = count+1
    end
    return count
end

fangxiang = {
    ["east"]="west",
    ["west"]="east",
    ["south"]="north",
    ["north"]="south",
    ["enter"]="out",
    ["out"]="enter",
    ["up"]="down",
    ["down"]="up",
    ["e"]="west",
    ["w"]="east",
    ["s"]="north",
    ["n"]="south",
    ["u"]="down",
    ["d"]="up",

    ["southeast"]="northwest",
    ["southwest"]="northeast",
    ["northwest"]="southeast",
    ["northeast"]="southwest",
    ["se"]="northwest",
    ["sw"]="northeast",
    ["nw"]="southeast",
    ["ne"]="southwest",

    ["southdown"]="northup",
    ["southup"]="northdown",
    ["eastup"]="westdown",
    ["eastdown"]="westup",
    ["northdown"]="southup",
    ["northup"]="southdown",
    ["westdown"]="eastup",
    ["westup"]="eastdown",
    ["sd"]="northup",
    ["su"]="northdown",
    ["eu"]="westdown",
    ["ed"]="westup",
    ["nd"]="southup",
    ["nu"]="southdown",
    ["wd"]="eastup",
    ["wu"]="eastdown",

    ["上"]="down", --先反的吧,实际可以反反得正...好吧我承认我偷懒了
    ["下"]="up",
    ["东"]="west",
    ["西"]="east",
    ["南"]="north",
    ["北"]="south",

    ["东上"]="westdown",
    ["西上"]="eastdown",
    ["南上"]="northdown",
    ["北上"]="southdown",

    ["东下"]="westup",
    ["西下"]="eastup",
    ["南下"]="northup",
    ["北下"]="southup",

    ["东北"]="southwest",
    ["西北"]="southeast",
    ["东南"]="northwest",
    ["西南"]="northeast",

    ["小道"]="xiaodao", --几个特例...
    ["小路"]="xiaolu",
    ["xiaodao"]="xiaodao",
    ["xiaolu"]="xiaolu",

}

function count_to_fangxiang(count) --数字--转-->方向
    local fangxiang_count ={
    [429] = "east",
    [563] = "south",
    [451] = "west",
    [555] = "north",
    [229] = "up",
    [440] = "down",
    [344] = "out",
    [542] = "enter",

    [984] = "northeast",
    [992] = "southeast",
    [1014] = "southwest",
    [1006] = "northwest",

    [658] = "eastup",
    [792] = "southup",
    [680] = "westup",
    [784] = "northup",

    [869] = "eastdown",
    [1003] = "southdown",
    [891] = "westdown",
    [995] = "northdown",

    [658] = "xiaolu",
    [741] = "xiaodao",
    }
    if fangxiang_count[count] then
        return fangxiang_count[count]
    else
        return ""
    end

end

function fangxiang_to_count(s) --方向--转-->数字
    if s==nil then
        return 0
    else
        local count = 0
        for i in string.gmatch(s,'(.)') do
            count = count + string.byte(i)
        end
        return count
    end

end

function have_fangxiang(exits,dir) -- "east;south" "southup"
    if exits and dir and exits~="" and dir~="" then
        local exits_table = {}
        for k in string.gmatch(exits..";","(.-);") do
            local count = fangxiang_to_count(k)
            exits_table[count] = k
        end
        local new_dir = fangxiang_to_count(dir)
    --  Print(new_dir)
        if exits_table[new_dir] then
        --  local k = exits_table[new_dir]
        --  Print(k)
        --  Print(dir.."::"..k)
            exits_table = nil
            return true
        else
            exits_table = nil
            return false
        end
    else
        return false
    end
end

function fanfangxiang(dir) --得到反方向，返回""空的表示失败了
--比如 east的是west

    if dir==nil then
        return ""
    end

    dir=string.lower(dir)

    if fangxiang[dir] then
        return fangxiang[dir]
    else
        return ""
    end
end

function isfangxiang(dir) --是方向么？
    if dir==nil then
        return false
    else
    dir = string.match(dir,"go (.*)") or string.match(dir,"ganche to (.*)") or dir

    if fangxiang[dir] then
        return true
    end
        return false
    end
end

function sort(s,sep) --排序
    if type(s)~="string" or s=="" then
        return s,0
    else
        if sep==nil or type(sep)~="string" then
            sep="|"
        end

            local t={}
    --      print(sep)
            for k in string.gmatch(s..sep,'(.-)'..sep) do
                table.insert(t,k)
        --      print(k)
            end
            table.sort(t)
            local links=""
            for k in ipairs(t) do
    --          print(k..t[k])
                links=links..sep..t[k]
            end
            local s=string.match(links,"^"..sep.."(.+)") or links
            t=nil
            links=nil

            local linkscount=0
            for k in string.gmatch(s,'(.)') do
                linkscount=linkscount+string.byte(k)
            end
            --这里将出口east;west 转换成数字相加

            --  echo('    linkscount = '..linkscount..',')


            return s,linkscount
    end
    return s,0

end

function copytable(object) --复制table，深拷贝
    if type (object) ~= "table" then
      return object
    else
    local new_table={}
     for index, value in pairs (object) do
      new_table [index] =value
    end
        return setmetatable (new_table, getmetatable (object))
    end
end

function similar(a,b) --a 和 b的相似度，以a为准0-100
    if not a or not b or a == "" or b == "" then
        return 0
    end


end
--
--  tprint.lua

--[[

For debugging what tables have in them, prints recursively

See forum thread:  http://www.gammon.com.au/forum/?id=4903

eg.

require "tprint"

   tprint (GetStyleInfo (20))

--]]

function tprint (t, indent, done) --照搬mc的
  -- in case we run it standalone
  local Note = Note or print
 -- local Tell = Tell or io.write
 local Tell = Tell or print

  -- show strings differently to distinguish them from numbers
  local function show (val)
    if type (val) == "string" then
      return '"' .. val .. '"'
    else
      return tostring (val)
    end -- if
  end -- show
  -- entry point here
  done = done or {}
  indent = indent or 0
  for key, value in pairs (t) do
    Tell (string.rep (" ", indent)) -- indent it
    if type (value) == "table" and not done [value] then
      done [value] = true
      Note (show (key), ":");
      tprint (value, indent + 2, done)
    else
      Tell (show (key), "=")
      print (show (value))
    end
  end
end
