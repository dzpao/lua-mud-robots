--房间信息抓取

--抓name
add_trigger("room_name","^[> ]*(\\S.*\\S)\\s+-(\\s*\\[.*\\]\\s*|\\s*|\\s*0)$",function (p)

    var.roomname = trim(p[1])
    var.nongwu_tianqi = nil -- 没有浓雾天气
    local follow_rooms_fail = var.follow_rooms_fail
    if var.roomname == "岳  飞  墓" then
        var.roomname = "岳飞墓"
    elseif string.find(var.roomname,'泥人') then
        var.roomname = "泥人"
    elseif string.find(var.roomname,'储物柜') then
        var.roomname = "储物柜"
    end

    var["roomobj"]={}
--  close_trigger("room_desc") --关闭抓取描述

    if var["wrong_way"] ~= nil and var["wrong_way"] > 0 then --走错路取消跟随
        var.follow_rooms_fail = 1
    --  Print(" 走错路")
    else
        --if var["migong"] and var["migong"] == 1 then
        --  local follow_room = var.follow_room or 0
        --  Print("  "..var.roomname..":迷宫前"..follow_room)
        --end
        if var.follow_rooms_fail == nil and (var["migong"] == nil or var["migong"] == 0)  and not var.map_no_follow_this_room and var.path_rooms ~= nil and next(var.path_rooms) ~= nil
            and not string.match("|马车|竹篓内|木船|善人渡|小木船|木船|小舟|太湖|接天桥|羊皮筏|黄河渡船|长江渡船|","|"..var.roomname.."|") then
                var.follow_room = var.path_rooms[1]
                if rooms[var.follow_room].name == var.roomname then
                    table.remove(var.path_rooms,1)
                    -- Print("  "..var.roomname..":"..var.follow_room)
                    -- Run("roomname="..var.roomname..";follow_room="..var.follow_room) --写入ls变量，谁写的？

                elseif var.roomname =="大厅" and var.follow_room and (rooms[var.follow_room].id ==2359 or rooms[var.follow_room].id ==2363 or rooms[var.follow_room].id ==2362) then
                    if rooms[var.follow_room].id == 2362 then table.remove(var.path_rooms,1) end
                    -- Print("  "..var.roomname..":2362 小心欧阳锋")
                elseif var.roomname =="大厅" and var.follow_room and (rooms[var.follow_room].id ==1247 or rooms[var.follow_room].id ==1248 or rooms[var.follow_room].id ==1249 or rooms[var.follow_room].id ==1250) then
                    if rooms[var.follow_room].id == 1248 then table.remove(var.path_rooms,1) end
                    -- Print("  "..var.roomname..":1248 小心陈近南")
                else
                    -- Print(" "..rooms[var.follow_room].name.."::"..var.roomname..":"..var.follow_room)
                --  var.follow_rooms_fail=1
                end
        end
    end

    if type(check_last_room) == "function" then -- -- 检查这次路过房间的信息
        local action = check_last_room(var.roomdesc_record)
        if type(action) == "function" then
            action()
        end
    end

    var.roomdesc = ""
    var.roomdesc_record = ""
    open_trigger("room_desc")

end)

-- 抓描述
add_trigger("room_desc","(.*)",function(params)

    if string.find(params[-1],"^%s*浓雾中你") or string.find(params[-1],"^%s*这里没有任何明显的出路。$") or string.find(params[-1],"^%s*这里......出口是.*。$") or string.find(params[-1],"^%s*这里......出口有.*。$") or string.find(params[-1],"^%s*这里$") or string.find(params[-1],"^%s*这里$")  or string.find(params[-1],"这是一个%S%S春") or string.find(params[-1],"这是一个%S%S夏") or string.find(params[-1],"这是一个%S%S秋") or string.find(params[-1],"这是一个%S%S冬") or string.find(params[-1],"这是一个春") or string.find(params[-1],"这是一个夏") or string.find(params[-1],"这是一个秋") or string.find(params[-1],"这是一个冬") or string.find(params[-1],"^%s*你可以看看%(look%)") or string.find(params[-1],"^%s*「....」:") or string.find(params[-1],"二只裂腹鱼") then
        close_trigger("room_desc")
    elseif string.find(params[-1],"^就在这里练.*lianjian.*就了玄铁剑法。$") then
        var.roomdesc=var.roomdesc..trim(params[-1])
        var.roomdesc_record = var.roomdesc
        close_trigger("room_desc")
    else
        if var.roomdesc=="" then
            var.roomdesc=trim(params[-1])
            var.roomdesc_record = var.roomdesc
        else
            var.roomdesc=var.roomdesc..trim(params[-1])
            var.roomdesc_record = var.roomdesc
        end
    end
end)
close_trigger("room_desc")

--抓出口
add_trigger("room_exit","^[> ]*这里.*(?:方向|出口|出路)(.*)$",function (p)
    close_trigger("room_desc")

    local l = string.match(p[1],"(.*)并不是一个") or p[1]

    l=string.gsub(l,"和",";")
    l=string.gsub(l,"是","")
    l=string.gsub(l,"有","")
    l=string.gsub(l,"、",";")
    l=string.gsub(l," ","")
    l=string.gsub(l,"。","")

    var.roomexit=l

    if type(check_this_room) == "function" then -- -- 检查这次路过房间的信息
        local action = check_this_room(var.roomdesc)
        if type(action) == "function" then
            action()
        end
    end
end)
add_trigger("room_exit_2","^[> ]*浓雾中你.*出口通往(.*)方向。",function (p)
    close_trigger("room_desc")
--  Print(string.sub(var.roomdesc,0,10))
    local   l=p[1]
            l=string.gsub(l,"和",";")
            l=string.gsub(l,"是","")
            l=string.gsub(l,"有","")
            l=string.gsub(l,"、",";")
            l=string.gsub(l," ","")
            l=string.gsub(l,"。","")
    var.roomexit=l
    var.nongwu_tianqi = true

    if type(check_this_room) == "function" then -- -- 检查这次路过房间的信息
        local action = check_this_room(var.roomdesc)
        if type(action) == "function" then
            action()
        end
    end

end)
--你跃上小舟，小船晃了晃，你吓得脸色苍白。
add_trigger("room_exit_3","^[> ]*(你跃上小舟，小船晃了晃，你吓得脸色苍白。|你可以看看(look):guancai,picture|二只裂腹鱼\\(Liefu yu\\)|你可以看看(look):jiang)",function (p)
        close_trigger("room_desc")
        var.roomexit = ""
        if type(check_this_room) == "function" then -- -- 检查这次路过房间的信息
            local action = check_this_room(var.roomdesc)
            if type(action) == "function" then
                action()
            end
        end
end)

--抓物品
add_trigger("room_obj","(.*)\\(([\\w\\' ]+)\\)(.*)",function (params)
    if type(var["roomobj"])=="table" then
        if params[2] == "Gold" then
            if string.find(from_server_line_raw,"1;33m黄金") then
                var["roomobj"][params[3]..params[1]]=string.lower(params[2])
            end
        else
            var["roomobj"][params[3]..params[1]]=string.lower(params[2])
        end
    end
end)

add_trigger("rooms_climb_start","^[> ]*你一咬牙，.*住崖上的岩石，手脚并用",function()
    Print("  开始爬悬崖")
    var.map_no_follow_this_room = true -- 主要用于地图跟随，不要跟随这个悬崖
end)
add_trigger("rooms_climb_over","^[> ]*(你爬的精疲力竭，忽然发现已经到二天门。|你抬头仰望，突然发现峰顶就在眼前，顿时气力倍增，双脚一蹬跳了上去。|你爬的精疲力竭，忽然发现已经到山顶，你提起纵身，一个鹞子翻身跃上山顶。|你低头一看，离地面只有丈余高，你转身一跳，稳稳的落在地上。|你身在半空，双手乱挥，只盼能抓到什么东西，这么乱挥一阵，又下堕下百馀丈。|你终于爬到崖洞中)",function(p)
    Print("爬悬崖完毕")
    var.map_no_follow_this_room = nil -- 主要用于地图跟随，不要跟随这个悬崖
    if string.find(p[1],"你身在半空，双手乱挥，只盼能抓到什么东西，这么乱挥一阵，又下堕下百馀丈。") then
        exe("pro    这里没有任何明显的出路。")
    end
end)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  检查房间物品npc 等 check_room_obj()
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function check_room_obj(obj)

    local have_obj = false
    local roomobj = var.roomobj or {}

    for k,v in pairs(roomobj) do
        if v==obj or string.find(k,obj.."$") then
            have_obj = true
            break
        end
    end

    roomobj = nil

    return have_obj

end

function get_all()
    local gold = check_room_obj("gold")
    local silver = check_room_obj("silver")

    if gold then
        exe("get gold")
    end
    if silver then
        exe("get silver")
    end

end
