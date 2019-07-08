--gps 定位
function gps(s)

    s = s or ""
    var.roomzone = ""
    var.roomnearby = ""
    var.roomdesc = ""
    var.roomexit = ""
    var.gpsagain = 0


--  wait1(5,function()
    wait3(5,function() --用一个新的wait3
        open_trigger("gps_1")
        open_trigger("gps_2")
        open_trigger("gps_3")

        exe('time -s;look;q')
        exe('pro 你正在【定位中'..s..'】',10)
    end)

end

add_trigger("gps_1",'^[> ]*\\S{1,2}正在【定位中',function (params)

    var.migong = 0
    var.danxiang_dir = nil --单向迷宫清除
    del_timer("input")
    del_timer("wait3") --删除wait3
    close_trigger("gps_1")
    close_trigger("gps_2")
    close_trigger("gps_3")

    get_all() --捡垃圾 place.lua

    check_gps()

end)

add_trigger("gps_2","^[> ]*现在现实中的时间是",function (params)
    var.roomnearby = ""
    close_trigger("gps_2")

end)

add_trigger("gps_3","^[> ]*风景要慢慢的看。",function (params)
    var.gpsagain = 1

end)


function check_gps()

    if var.roomname and var.roomname=="灵堂" then
        exe("release end;ask gao seng about 离开;ask gao seng 2 about 离开;ask gao seng 3 about 离开;ask gao seng 4 about 离开;ask gao seng 5 about 离开")
        local i = math.random(6,10)
        exe("ask gao seng "..i.." about 离开")
    end
    if var["wrong_way"] ~= nil and var.follow_room_fail == nil and var.follow_room ~= nil and var["wrong_way"] == 0 and rooms[var.follow_room] and rooms[var.follow_room].name == var.roomname then -- 如果follow成功那就不要定位了

        var.gps=var.follow_room
        gps_ok()
        print("  地图跟随模式当前房间号【"..var.follow_room.."】")
    else

        if var.gpsagain>0 then
            print("  需要稍后重新定位...")
            wa(1,function()
                gps()
            end)
        else

            if var.nongwu_tianqi then -- 浓雾天气
                for k,v in pairs(rooms) do
                    if var.roomname and var.roomname == v.name then
                        local roomexit = ""
                        if v.links and v.links ~= "" then
                            roomexit = v.links
                        else
                            for i,j in pairs(v.exits) do
                                roomexit = roomexit .. ";" .. i
                            end
                        end
                        roomexit = string.match(roomexit,"^;(.+)") or roomexit
                        var.roomexit = roomexit -- 浓雾天气随机找一个已有房间的出口吧
                        break
                    end
                end
            end

            var.gps = getgps(var.roomname,var.roomdesc,var.roomexit,var.roomnearby,var.roomzone) -- 获得gps房间号
            var.gps = tonumber(var.gps) or 0

            if var.gps==0 then
                print("  定位失败")
                    if var.roomname and string.find(var.roomname,"的屋顶$") then
                        exe("leap down")
                    end
                if var.needsleep then      --有些客店要睡觉再走？

                    var.needsleep = nil
                    exe("up;n;e;w;u;enter")
                    do_walk_sleep(function() exe("out;s;d;w;s;e;gps") end) --睡一觉再走

                else

                    check_auto_kill(gps_fail)
                end
            else

                print("  定位成功位于【"..var.gps.."】")

                var["wrong_way"]=0

                if var.needsleep then --有些客店要睡觉再走？
                    var.needsleep = nil
                    exe("up;n;e;enter;w;up;enter")
                    do_walk_sleep(function() exe("out;s;d;w;s;e;gps") end)
                else
                    check_auto_kill(gps_ok)
                end
            end

        end
    end

end

--mhere 查看当前房间

add_alias("mhere",function()
    var.mhere = nil
    open_trigger("gps_1")
    open_trigger("gps_2")
    open_trigger("gps_3")
    open_trigger("gps_4")

    var.roomzone=""

    var.roomnearby=""
    var.roomdesc=""
    var.roomexit=""
    var.gpsagain=0
    exe('time -s;look;pro 你正在【查看房间号】',1)

end)

add_trigger("gps_4",'^[> ]*\\S{1,2}正在【查看房间号】并不是一个',function (params)
    del_timer("input")
    close_trigger("gps_1")
    close_trigger("gps_2")
    close_trigger("gps_3")
    close_trigger("gps_4")

    var.gps = getgps(var.roomname,var.roomdesc,var.roomexit,var.roomnearby,var.roomzone) --获得gps房间号
    var.gps = tonumber(var.gps) or 0

    if var.gps==0 then

                echo('    name = "'..var.roomname..'",')
                echo('    desc = "'..var.roomdesc..'",')
                echo('    area = "",')
                local a,b=sort(var.roomexit,";")
                echo('    relation = "'..var.roomnearby..'",')
                echo('    links = "'..a..'",')
                echo('    linkscount = '..b..',')
                echo("  房间号为【失败】")

                if var.roomnearby~="" and not rawequal(var.roomnearby,rooms[var.gps].relation) then
                    echo("  "..C.R.."Nearby不同")

                end
                if not rawequal(var.roomname,rooms[var.gps].name) then
                    echo("  "..C.R.."Name不同")
                    var.mhere = true
                end
                if not rawequal(var.roomdesc,rooms[var.gps].desc) then
                    echo("  "..C.R.."Desc不同")
                    var.mhere = true
                end
                local exits=sort(var.roomexit,";")
                if not rawequal(exits,rooms[var.gps].links) then
                echo("  "..C.R.."Exits不同")
                end
            else
                echo('    name = "'..var.roomname..'",')
                echo('    desc = "'..var.roomdesc..'",')


                local a,b=sort(var.roomexit,";")

                echo('    relation = "'..var.roomnearby..'",')
                echo('    links = "'..a..'",')
                echo('    linkscount = '..b..',')

                echo("  房间号为【"..var.gps.."】")
                if var.roomnearby~="" and not rawequal(var.roomnearby,rooms[var.gps].relation) then
                    echo("  "..C.R.."Nearby不同")
                end
                if not rawequal(var.roomname,rooms[var.gps].name) then
                    echo("  "..C.R.."Name不同")
                    var.mhere = true
                end
                if not rawequal(var.roomdesc,rooms[var.gps].desc) then
                    echo("  "..C.R.."Desc不同")
                    var.mhere = true
                end
                local exits=sort(var.roomexit,";")
                if not rawequal(exits,rooms[var.gps].links) then
                echo("  "..C.R.."Exits不同")
                end

    end
end)

function get_safety_random_move(roomname,exits)

        roomname = roomname or var.roomname
        exits = exits or var.roomexit
        local dirs={}
        for k in string.gmatch(exits..";","(.-);") do
            table.insert(dirs,k)
        end

        local function remove_table_value(t,str)
            local new_t = {}
            for k,v in pairs(t) do
                if v~= str then
                    table.insert(new_t,v)
                end
            end
            return new_t
        end

        if roomname == "南城外土路" then
            dirs = { "south", }
        --elseif 1==0 then --特殊地点还没完工
        elseif roomname == "蛇谷树林" then --蛇谷荒地
            dirs = remove_table_value(dirs,"east")
            dirs = remove_table_value(dirs,"southwest")
        elseif roomname == "雪地" then  --凌霄城松林
            dirs = remove_table_value(dirs,"northup")
        elseif roomname == "太湖边" then  --归云庄树林老虎
            dirs = remove_table_value(dirs,"south")
        elseif roomname == "小花园" then -- 康亲王府
            dirs = remove_table_value(dirs,"west")
        elseif roomname == "小路" then -- 王夫人
            dirs = remove_table_value(dirs,"south")
        elseif roomname == "嘉峪关" then -- 丝绸之路大沙漠
            dirs = remove_table_value(dirs,"west")
        elseif roomname == "戈壁" then -- 丝绸之路大沙漠
            dirs = remove_table_value(dirs,"east")
        elseif roomname == "练功场" then -- 欧阳锋
            dirs = remove_table_value(dirs,"south")
        elseif roomname == "院子" then -- 欧阳锋
            dirs = remove_table_value(dirs,"northup")
        elseif roomname == "六盘山" then -- 黑店
            dirs = remove_table_value(dirs,"westdown")
        elseif roomname == "小山坡" then -- 回族小沙漠
            dirs = remove_table_value(dirs,"southwest")
        elseif roomname == "紫霄宫" then -- 紫霄宫
            dirs = remove_table_value(dirs,"eastup")
        elseif roomname == "凌霄宫" then -- 凌霄宫
            dirs = remove_table_value(dirs,"eastup")
        elseif roomname == "武当广场" then -- 武当广场
            dirs = { "southdown", "eastdown" , "north", }
        elseif roomname == "后门" then -- 武当后门
            dirs = remove_table_value(dirs,"northup")
        elseif roomname == "千佛殿" then -- 少林千佛殿
            dirs = remove_table_value(dirs,"north")
        elseif roomname == "勤修场" then -- 少林戒律院
            dirs = remove_table_value(dirs,"northup")
        elseif roomname == "藏经阁一楼" then -- 藏经阁一楼
            dirs = { "east", }
        elseif roomname == "练武场" then -- 少林达摩院
            dirs = remove_table_value(dirs,"northup")
        elseif roomname == "天地会暗道" then -- 天地会暗道--不去north 陈近南房间
            dirs = remove_table_value(dirs,"north")
        elseif roomname == "大树上" then
            dirs = { "jump down" }
        elseif roomname == "树杈上" then
            dirs = { "climb down" }
        elseif roomname == "海中" then
            dirs = { "jump out" }
        elseif roomname == "泉水中" then
            dirs = { "jump out" }
        elseif roomname == "古墓墓洞" then
            dirs = { "enter guancai5", "enter guancai4", }
        end

    return dirs

end

function get_random_move(exits)

        local dirs = get_safety_random_move(var.roomname,var.roomexit) --获取一个安全的出口信息

        local n=#dirs
        if n==0 then
            dirs={"e","w","n","s"}
        end
        n=#dirs
        local m=n --返回一下出口总数
        n=dirs[math.random(n)]
        return n,m,dirs
end

function get_random_move_reverse() --得到随机移动的反方向
    if var.random_move_dirs==nil then var.random_move_dirs = {} end --随机走过哪些方向记录一下
    if null(var.random_move_dirs) then
        var.random_move_reverse=''
        return
    end

    local dir=''
    for _,v in ipairs(var.random_move_dirs) do
        if fangxiang[dir] then
            dir = fangxiang[dir] ..";"..dir
        end
    end
    dir = string.match(dir,'(.*);$') or dir
    var.random_move_reverse = dir
    var.random_move_dirs = {}
    return

end
--
function gps_ok()
--  echo("  房间号:"..var.gps)
    get_random_move_reverse() -- 随机走过哪些方向记录一下,反一下方向

    if var.random_move_reverse and var.random_move_reverse~='' then
        local i=get_room_by_path(var.gps,var.random_move_reverse)
        if rooms[i] then
            echo("  随机移动起点:"..i..'【'..rooms[i].name..'】')
        else
            echo('  随机移动起点:【丢失】')
        end
    end

    var.follow_rooms_fail = nil
    after_gps()
end

function getgps(name,desc,exits,relation,zone)
--           房间名称  房间描述  出口     周围信息
    zone=zone or ""
    relation=relation or ""
--  local by_exit = false
    if name=="" and desc=="" and exits=="" and relation=="" then
        return 0
    end
--[[
            local t={}
            for k in string.gmatch(exits..";",'(.-);') do
                table.insert(t,k)
            end
            table.sort(t)
            local links=""
            for k in ipairs(t) do
                links=links..";"..t[k]
            end
            exits=string.match(links,"^;(.+)") or links
            t=nil
            links=nil
    --      echo("  "..exits)
            --以上将方向重新排序一下
    --
    ]]
    exits=exits or ""
    local linkscount=0
    for k in string.gmatch(exits,'(.)') do
        linkscount=linkscount+string.byte(k)
    end
    --这里将出口east;west 转换成数字相加
--  echo('    linkscount = '..linkscount..',')

    --


    local n=0
    local gps_name={}
    local gps_name_exits={}
    local gps_name_desc={}
    local gps_exits_desc={}
    local gps_name_exits_desc={}
    local gps_name_exits_relation={}

    local gps_zone_name={}
    local gps_zone_name_exits={}
    local gps_zone_name_desc={}
    local gps_zone_exits_desc={}
    local gps_zone_name_exits_desc={}

    for k,v in pairs(rooms) do
        if rawequal(name,v.name) then
            n=#gps_name
            if n<3 then
                n=n+1
                gps_name[n]=k
            end
        end

--      if rawequal(name,v.name) and rawequal(exits,v.links) then
        if rawequal(name,v.name) and linkscount==v.linkscount then
            n=#gps_name_exits
            if n<3 then
                n=n+1
                gps_name_exits[n]=k
            end
        end

        if rawequal(name,v.name) and rawequal(desc,v.desc) then
            n=#gps_name_desc
            if n<3 then
                n=n+1
                gps_name_desc[n]=k
            end
        end

--      if rawequal(exits,v.links) and rawequal(desc,v.desc) then
        if rawequal(desc,v.desc) and linkscount==v.linkscount then
            n=#gps_exits_desc
            if n<3 then
                n=n+1
                gps_exits_desc[n]=k
            end
        end

--      if rawequal(name,v.name) and rawequal(exits,v.links) and rawequal(desc,v.desc) then
        if rawequal(name,v.name) and rawequal(desc,v.desc) and linkscount==v.linkscount then
            n=#gps_name_exits_desc
            if n<3 then
                n=n+1
                gps_name_exits_desc[n]=k
            end
        end
        --gps_exits_relation={}
--      if rawequal(name,v.name) and rawequal(exits,v.links) and rawequal(relation,v.relation) then
        if rawequal(name,v.name) and rawequal(relation,v.relation) and linkscount==v.linkscount then
            n=#gps_name_exits_relation
            if n<3 then
                n=n+1
                gps_name_exits_relation[n]=k
            end
        end
            if zone~="" then
                if rawequal(zone,v.area) and rawequal(name,v.name) then
                    n=#gps_zone_name
                    if n<3 then
                        n=n+1
                        gps_zone_name[n]=k
                    end
                end

        --      if rawequal(zone,v.area) and rawequal(name,v.name) and rawequal(exits,v.links) then
                if rawequal(name,v.name) and rawequal(zone,v.area) and linkscount==v.linkscount then
                    n=#gps_zone_name_exits
                    if n<3 then
                        n=n+1
                        gps_zone_name_exits[n]=k
                    end
                end

                if rawequal(zone,v.area) and rawequal(name,v.name) and rawequal(desc,v.desc) then
                    n=#gps_zone_name_desc
                    if n<3 then
                        n=n+1
                        gps_zone_name_desc[n]=k
                    end
                end

        --      if rawequal(zone,v.area) and rawequal(exits,v.links) and rawequal(desc,v.desc) then
                if rawequal(zone,v.area) and rawequal(desc,v.desc) and linkscount==v.linkscount then
                    n=#gps_zone_exits_desc
                    if n<3 then
                        n=n+1
                        gps_zone_exits_desc[n]=k
                    end
                end

        --      if rawequal(zone,v.area) and rawequal(name,v.name) and rawequal(exits,v.links) and rawequal(desc,v.desc) then
                if rawequal(zone,v.area) and rawequal(name,v.name) and rawequal(desc,v.desc) and linkscount==v.linkscount then
                    n=#gps_zone_name_exits_desc
                    if n<3 then
                        n=n+1
                        gps_zone_name_exits_desc[n]=k
                    end
                end
            end
    end
    n=#gps_name
    if n==1 then
        return gps_name[1]
    end
    n=#gps_name_exits
    if n==1 then
    --  Print("通过name exits 定位成功！")
        return gps_name_exits[1]
    end
    n=#gps_name_desc
    if n==1 then
        return gps_name_desc[1]
    end
    n=#gps_exits_desc
    if n==1 then
    --  Print("通过desc exits 定位成功！")
        return gps_exits_desc[1]
    end
    n=#gps_name_exits_desc
    if n==1 then
    --  Print("通过name desc exits 定位成功！")
        return gps_name_exits_desc[1]
    end

    n=#gps_name_exits_relation
    if n==1 then
        return gps_name_exits_relation[1]
    end

    if zone~="" then
        n=#gps_zone_name
        if n==1 then
            return gps_zone_name[1]
        end
        n=#gps_zone_name_exits
        if n==1 then
            return gps_zone_name_exits[1]
        end
        n=#gps_zone_name_desc
        if n==1 then
            return gps_zone_name_desc[1]
        end
        n=#gps_zone_exits_desc
        if n==1 then
            return gps_zone_exits_desc[1]
        end
        n=#gps_zone_name_exits_desc
        if n==1 then
            return gps_zone_name_exits_desc[1]
        end

    end
    return 0
end

function gps_fail()

    if var.gps_fail_times~=nil and var.gps_fail_times>1000 then var.gps_fail_times = nil end
    local gps_fail_times = var.gps_fail_times or 0

    var.migong = 0

    local desc = string.sub(var.roomdesc,1,20) --截取20个字
          desc = var.roomname .. desc

    if maze_gps[var.roomname] then
        if gps_fail_times<100 then
            gps_fail_times = gps_fail_times + 100
        else
            gps_fail_times = gps_fail_times + 1
        end
        if var.gps_fail_times~=nil then var.gps_fail_times = gps_fail_times end
        maze_gps[var.roomname]()


    elseif maze_gps[desc] then
        if gps_fail_times<100 then
            gps_fail_times = gps_fail_times + 100
        else
            gps_fail_times = gps_fail_times + 1
        end
        if var.gps_fail_times~=nil then var.gps_fail_times = gps_fail_times end
        maze_gps[desc]()

    else
        wa(1,function()
            gps_fail_times = gps_fail_times + 1
            if var.gps_fail_times~=nil then var.gps_fail_times = gps_fail_times end
            local n=get_random_move(var.roomexit)
            if var.random_move_dirs==nil then var.random_move_dirs = {} end
            table.insert(var.random_move_dirs,n)
            send(n)
            --gps()
            gps()
        end)
    end
end
--*******************
--      清除叫杀npc
--*******************
add_trigger("auto_kill_npc_add","^[> ]*看起来(巡山弟子|护林僧兵|小喽罗|土匪头|小土匪|老虎|巡城军士|疯子|宫内宿卫)想杀死你！",function(p)
    local auto_kill_npc = {
        ["xunshan dizi"] = "巡山弟子",
        ["seng bing"] = "护林僧兵",
        ["xiao louluo"] = "小喽罗",
        ["tufei tou"] = "土匪头",
        ["xiao tufei"] = "小土匪",
        ["tiger"] = "老虎",
        ["lao hu"] = "老虎",
        ["wolf"] = "狼|恶狼",
        ["crazy man"] = "疯子",
        ["tufei"] = "土匪",
        ["a shan"] = "阿善",
        ["huli"] = "狐狸",
        ["jiang yaoting"] = "江耀亭",
        ["bear"] = "黑熊",
        ["baozi"] = "豹子",
        ["bee"] = "蜜蜂",
        ["xiao tufei"] = "小土匪",
        ["tufei"] = "土匪",
        ["xiao louluo"] = "小喽罗",
        ["xuncheng junshi"] = "巡城军士",
        ["meng ge"] = "蒙哥",
        ["hei ying"] = "黑鹰",
        ["mei chaofeng"] = "梅超风",
        ["chen xuanfeng"] = "陈玄风",
        ["gongnei suwei"] = "宫内宿卫",
        ["wolf dog"] = "大狼狗",
    --  ["mang she"] = "蟒蛇",
    }
    local name,id = p[1],nil
    for k,v in pairs(auto_kill_npc) do
        if v == name then
            id = k
        end
    end

    if id ~= nil then
        var["roomobj"][name] = id
    end

end)

function check_auto_kill(action)

    local myexp = var.exp or 1000
    if myexp < 2000000 then -- 2m 一下不管叫杀npc，防止打不过
        action()
        return
    end
--  Print("check_auto_kill")
    local auto_kill_id,auto_kill_name

    local auto_kill_npc = {
        ["xunshan dizi"] = "巡山弟子",
        ["seng bing"] = "护林僧兵",
        ["xiao louluo"] = "小喽罗",
        ["tufei tou"] = "土匪头",
        ["xiao tufei"] = "小土匪",
        ["tiger"] = "老虎",
        ["lao hu"] = "老虎",
        ["wolf"] = "狼|恶狼",
        ["crazy man"] = "疯子",
        ["tufei"] = "土匪",
        ["a shan"] = "阿善",
        ["huli"] = "狐狸",
        ["jiang yaoting"] = "江耀亭",
        ["bear"] = "黑熊",
        ["baozi"] = "豹子",
        ["bee"] = "蜜蜂",
        ["xiao tufei"] = "小土匪",
        ["tufei"] = "土匪",
        ["xiao louluo"] = "小喽罗",
        ["xuncheng junshi"] = "巡城军士",
        ["meng ge"] = "蒙哥",
        ["hei ying"] = "黑鹰",
        ["mei chaofeng"] = "梅超风",
        ["chen xuanfeng"] = "陈玄风",
        ["gongnei suwei"] = "宫内宿卫",
        ["wolf dog"] = "大狼狗",
    --  ["mang she"] = "蟒蛇",
        --    二位小土匪(Xiao tufei)

    }
    local auto_kill_npc_place = {
    --  ["xunshan dizi"] = "巡山弟子",
    --  ["seng bing"] = "护林僧兵",
    --  ["xiao louluo"] = "小喽罗",
    --  ["tufei tou"] = "土匪头",
    --  ["xiao tufei"] = "小土匪",
    --  ["tiger"] = "老虎",
    --  ["lao hu"] = "老虎",
    --  ["wolf"] = "狼",
    --  ["crazy man"] = "疯子",
    --  ["tufei"] = "土匪",
        ["huli"] = "山路",
        ["jiang yaoting"] = "知府大堂",
        ["bear"] = "山路",
        ["baozi"] = "山路",
        ["xiao tufei"] = "五老峰",
        ["tufei"] = "林中小路",
        ["xiao louluo"] = "林中小路",
--      ["a shan"] = "阿善",

    }


    if  var.update_map_emei_lost == nil and var.update_map_emei == true then --有灭绝邀请函,删除巡山弟子叫杀
        auto_kill_npc["xunshan dizi"] = nil
    elseif  var.party and var.party == "峨嵋派" then --峨眉派,,删除巡山弟子叫杀
        auto_kill_npc["xunshan dizi"] = nil
    elseif  var.exp and var.exp < 10000000 then -- 10m 以下不对以下npc叫杀
        auto_kill_npc["mei chaofeng"] = nil
        auto_kill_npc["chen xuanfeng"] = nil
    end


    for k,v in pairs(var["roomobj"]) do
        if auto_kill_npc[v] then
    --  Print(k..":"..v.." --> "..auto_kill_npc[v])
        --  if string.find(k,auto_kill_npc[v]) then
            local k = string.match(k,".*位(%S+)$") or string.match(k,".*」(%S+)$") or string.match(k,".*只(%S+)$") or string.match(k,".*条(%S+)$") or string.match(k,"%s(%S+)$") or  k
        --  Print("k"..k)
            if string.find("|"..auto_kill_npc[v].."|","|"..k.."|") then
                --Print(k..":"..v)
                local roomname = var.roomname or "none"
                if auto_kill_npc_place[v] and string.find(auto_kill_npc_place[v],roomname) then
                    auto_kill_id = v
                    auto_kill_name = auto_kill_npc[v]
                --  Print(k..":"..v)
                    break
                elseif not auto_kill_npc_place[v] then
                    auto_kill_id = v
                    auto_kill_name = auto_kill_npc[v]
                --  Print(k..":"..v)
                    break
                end
            end
        end
    end
    if auto_kill_id then
        clear_auto_kill(auto_kill_id,auto_kill_name,action)
    else
        action()
    end
end

function clear_auto_kill(id,name,action)

    if not id or id == "" then id = "kissme" end
    var.crush_id = id

    check_maze(function()
        add_trigger("clear_auto_kill","^[> ]*这里没有 (.*)。",function (p)
            del_trigger("clear_auto_kill")
            if string.find(p[1],"kissme") or (var.crush_id and string.find(p[1],"^"..var.crush_id)) then
                del_timer("killall")
                check_maze(function()
                    action()
                end)
            end
        end)
        if not var.crush_id or var.crush_id =="" then var.crush_id = "kissme" end
        exe("killall "..var.crush_id..";lead "..var.crush_id)
        set_timer("killall",1,function()
            if not var.crush_id or var.crush_id =="" then var.crush_id = "kissme" end
            if var.crush_id ~= "kissme" then
                exe("killall "..var.crush_id..";lead "..var.crush_id)
            end
        end)
    end)
end

--迷宫或者 很多重名房间 辅助定位，随机移动有时候太慢了
maze_gps = {
    ["黑沼"] = function()
                        local r = math.random(6)
                        if r == 1 then
                            exe("e;n;w;s;s;w;gps")
                        elseif r == 2 then
                            exe("n;w;s;s;w;gps")
                        elseif r == 3 then
                            exe("w;s;s;w;gps")

                        elseif r == 4 then
                            exe("s;s;w;gps")
                        else
                            exe("s;w;gps")
                        end
                    end,

    ["云海"] =      function()
                        exe("w;s;gps")
                    end,

    ["茶花林"] = function()
                        local r = math.random(6)
                        if r == 1 then
                            exe("n;w;s;s;e;e;w;w;w;gps")
                        elseif r == 2 then
                            exe("w;s;s;e;e;w;w;w;gps")
                        elseif r == 3 then
                            exe("s;s;e;e;w;w;w;gps")
                        elseif r == 4 then
                            exe("s;e;e;w;w;w;gps")
                        elseif r == 5 then
                            exe("e;e;w;w;w;gps")
                        elseif r == 6 then
                            exe("e;e;e;w;w;w;gps")
                        else
                            exe("w;w;w;gps")
                        end
                    end,

    ["迷魂阵"] = function()
                        exe("e;e;e;e;e;e;e;e;e;e;gps")
                    end,
    ["密林林中阴森森的，除了几"] = function()
                        var.gps = 10213
                        var["wrong_way"]=0
                        gps_ok()
                    end,
--    林中阴森森 的，除了几 声鸟叫外再没有其他的声音，四周
    ["石阶你走在一条坚实的石阶"] = function()
                        local roomexit = var.roomexit or ""
                              roomexit = ";"..roomexit..";"
                        if string.find(roomexit,";northup;") and string.find(roomexit,";southeast;") and string.find(roomexit,";eastdown;") then
                        --  print(10017)
                            var["wrong_way"]=0
                            var.gps=10017
                            gps_ok()
                        else
                            exe("set brief 2")
                            walk_out_danxiang() --maze.lua
                        end

                    end,

--    你走在一条 坚实的石阶 上，不时地有进香客从你的身
    ["山野小径"] = function()
                        walk_to_shaolin(nil,"古墓")
                    end,
    ["天地会暗道"] = function()
                        exe("n;n;s;s;w;e;n;n;n;n;gps")
                    end,
    ["地下河"] = function()
                        exe("s;s;s;gps")
                    end,
                    --地下河
    ["乡野小路"] = function()
                        walk_to_shaolin(nil,"古墓")
                    end,

    ["黄河北岸"] = function()
                        var.migong = 0
                        local roomexit = var.roomexit or ""
                        --    roomexit = ";"..roomexit..";"
                        if have_fangxiang(roomexit,"east") and have_fangxiang(roomexit,"southwest") and have_fangxiang(roomexit,"northeast") then
                            var["wrong_way"]=0
                            var.gps=2816
                            gps_ok()

                        elseif have_fangxiang(roomexit,"west") and have_fangxiang(roomexit,"northwest") and have_fangxiang(roomexit,"southeast") then
                            var["wrong_way"]=0
                            var.gps=2814
                            gps_ok()

                        elseif have_fangxiang(roomexit,"north") and have_fangxiang(roomexit,"south") then
                            var["wrong_way"]=0
                            var.gps=2810
                            gps_ok()

                        elseif have_fangxiang(roomexit,"south") and have_fangxiang(roomexit,"northeast") and numitems(roomexit,";")==2 then
                            var["wrong_way"]=0
                            var.gps=2811
                            gps_ok()

                        elseif have_fangxiang(roomexit,"northeast") and have_fangxiang(roomexit,"southwest") then
                            exe("sw;sw;gps")
                        elseif have_fangxiang(roomexit,"northwest") and have_fangxiang(roomexit,"southeast") then
                            exe("nw;nw;n;gps")
                        else
                            wa(1,function()
                                local n=get_random_move(var.roomexit)
                                send(n)
                                gps()
                            end)
                        end
                    end,

    ["黄河南岸"] = function()
                        var.migong = 0
                        local roomexit = var.roomexit or ""
                        --    roomexit = ";"..roomexit..";"

                        if have_fangxiang(roomexit,"north") and have_fangxiang(roomexit,"south") then
                            var["wrong_way"]=0
                            var.gps=1803
                            gps_ok()

                        elseif have_fangxiang(roomexit,"south") and have_fangxiang(roomexit,"northeast") and numitems(roomexit,";")==2 then
                            var["wrong_way"]=0
                            var.gps=1804
                            gps_ok()
                        elseif have_fangxiang(roomexit,"southeast") and have_fangxiang(roomexit,"west") and numitems(roomexit,";")==2 then

                            var["wrong_way"]=0
                            var.gps=1807
                            gps_ok()
                        elseif have_fangxiang(roomexit,"southwest") and have_fangxiang(roomexit,"east") and numitems(roomexit,";")==2 then
                            var["wrong_way"]=0
                            var.gps=1808
                            gps_ok()

                        elseif have_fangxiang(roomexit,"northeast") and have_fangxiang(roomexit,"southwest") then
                            local r=math.random(2)
                            if r==1 then
                                exe("ne;gps")
                            else
                                exe("sw;gps")
                            end
                        elseif have_fangxiang(roomexit,"northwest") and have_fangxiang(roomexit,"southeast") then
                            local r=math.random(2)
                            if r==1 then
                                exe("nw;nw;nw;n;gps")
                            elseif r==2 then
                                exe("se;se;e;gps")
                            else
                                local r=math.random(2)
                                if r==1 then
                                    exe("se;gps")
                                else
                                    exe("nw;gps")
                                end
                            end
                        else
                            wa(1,function()
                                local n=get_random_move(var.roomexit)
                                send(n)
                                gps()
                            end)
                        end
                    end,
    ["长江岸边这里是长江北岸，远远"] = function()
                        var.migong = 0
                        local roomexit = var.roomexit or ""
                        --    roomexit = ";"..roomexit..";"

                        if have_fangxiang(roomexit,"north") and have_fangxiang(roomexit,"east") and have_fangxiang(roomexit,"west") then
                            var["wrong_way"]=0
                            var.gps=306
                            gps_ok()
                        elseif have_fangxiang(roomexit,"northwest") and have_fangxiang(roomexit,"southeast") then
                            exe("nw;gps")

                        elseif have_fangxiang(roomexit,"northeast") and have_fangxiang(roomexit,"southwest") then
                            exe("sw;sw;sw;w;nw;nw;gps")
                        else
                            local exits = random_item(var.roomexit,";") -- function.lua
                            if exits == "" then
                                exits = random_item("e;s;w;n")
                            end
                            exe(exits..";gps")
                        end
                    end,
    ["长江岸边这里是长江南岸，远远"] = function()
                        var.migong = 0
                        local roomexit = var.roomexit or ""
                        --    roomexit = ";"..roomexit..";"

                        if have_fangxiang(roomexit,"northwest") and have_fangxiang(roomexit,"southwest") then
                            var["wrong_way"]=0
                            var.gps=5103
                            gps_ok()
                        elseif have_fangxiang(roomexit,"northwest") and have_fangxiang(roomexit,"east") and have_fangxiang(roomexit,"south") then
                            var["wrong_way"]=0
                            var.gps=5116
                            gps_ok()
                        elseif have_fangxiang(roomexit,"northeast") and have_fangxiang(roomexit,"west") and have_fangxiang(roomexit,"south") then
                            exe("s;gps")
                        elseif have_fangxiang(roomexit,"west") and have_fangxiang(roomexit,"southeast") and have_fangxiang(roomexit,"southwest") then
                            var["wrong_way"]=0
                            var.gps=5110
                            gps_ok()
                        elseif have_fangxiang(roomexit,"northwest") and have_fangxiang(roomexit,"southeast") then
                            exe("nw;gps")
                        elseif have_fangxiang(roomexit,"northeast") and have_fangxiang(roomexit,"southwest") then
                            exe("sw;sw;sw;gps")
                        else
                            local exits = random_item(var.roomexit,";") -- function.lua
                            if exits == "" then
                                exits = random_item("e;s;w;n")
                            end
                            exe(exits..";gps")
                        end
                    end,

--  这是归云庄 前的太湖边 上的树林子，里面看起来阴森森的，让人不禁心寒！
--  截取 name + desc的10个字吧
--  很多迷宫都叫树林...
    ["树林这是归云庄前的太湖边"] = function()
                        exe("n;n;n;n;n;gps")
                    end,

    ["小船这艘小船是庄内的交通"] = function()
                        murong_row_boot("row qinyun",function() exe("gps") end)
                    end,

    ["竹林好一片郁郁葱葱的竹林"] = function()
                        exe("e;e;e;e;ed;gps")
                    end,

    ["树林到处开满了奇花异草，"] = function()
                        exe("w;w;w;w;w;gps")
                    end,

    ["大沙漠这是一片一望无际的大"] = function()
                        if var.roomdesc and string.find(var.roomdesc,"看来要走出这块沙漠并非易事。") then
                            check_busy(function()
                                exe("drink jiudai;drink jiudai;drink jiudai;drink jiudai;w;gps") --白驼山
                            end)
                        else
                            exe("e;e;e;e;s;s;s;s;e;e;e;e;gps") -- 明教
                        end
                    end,
    ["密林林中阴森森的，除了几"] = function()
                        if var.roomexit and var.roomexit=="east" then
                            var["wrong_way"]=0
                            var.gps=5946
                            gps_ok()
                        elseif var.roomexit and string.find(var.roomexit,"southdown") then
                            var["wrong_way"]=0
                            var.gps=10240
                            gps_ok()
                        else
                            local exits = random_item(var.roomexit,";") -- function.lua
                            if exits == "" then
                                exits = random_item("e;s;w;n")
                            end
                            exe(exits..";gps")
                        end
                    end,
    ["休息室这是黑木崖总堂所设的"] = function()
                        exe("open men;e;gps")
                    end,
    ["休息室"] = function()
                        exe("open men;n;e;gps")
                    end,
    ["果林"] = function()
                        local r,dir=math.random(3),""
                        if r==1 then
                            dir = "w"
                        elseif r==2 then
                            dir = "e"
                        elseif r==3 then
                            dir = "n"
                        end
                        exe(dir..";s;nu;s;nu;gps")
                    end,
    ["桃林"] = function()
                        leave_taolin(gps)
                    end,
    ["松树林你眼前骤然一黑，朦胧"] = function() --青云坪
                        exe("s;e;s;e;n;n;e;w;s;gps")
                    end,
    ["松林走入松林，视线不如先"] = function() --凌霄松林
                        exe("sd")
                        wa(2,function()
                            exe("gps")
                        end)
                    end,
    ["小沙漠这里是一片不大的沙漠"] = function() --南疆沙漠
                        exe("nw;sw;se;ne;drink;gps")
                    end,

    ["竹林这是一片密密的竹林。"] = function()
                        local roomexit = var.roomexit or ""
                        if have_fangxiang(roomexit,"west") and have_fangxiang(roomexit,"northwest") then
                        --1473 这个房间有个出口west 通向山野小径
                            var["wrong_way"]=0
                            var.gps=10746
                            gps_ok()
                        elseif have_fangxiang(roomexit,"northwest") and not have_fangxiang(roomexit,"west") then
                            local r=math.random(2)
                            if r==1 then
                                exe("se;n;s;w;e;w;e;e;s;w;n;nw;n;gps")
                            else
                                exe("nw;n;gps")
                            end
                        else
                            local r=math.random(4)
                            if r==1 then
                                exe("e;e;e;e;e;gps")
                            elseif r==2 then
                                exe("w;w;w;w;w;e;gps")
                            elseif r==3 then
                                exe("s;s;s;s;s;gps")
                            else
                                exe("n;n;n;n;n;gps")
                            end

                        end

                    end,
    ["五行洞"] = function()
                    local r=math.random(10)
                        if r==1 then
                            exe("e;e;e;gps")
                        elseif r==2 then
                            exe("s;s;s;gps")
                        elseif r==3 then
                            exe("w;w;w;gps")
                        else
                            exe("n;n;n;gps")
                        end
                    end,
    ["马车"] = function()
                        exe("xia;gps")
                    end,
    ["老林"] = function()
                        laolin_out(gps)
                    end,
    ["花园杭州提督府的花园，种"] = function()
                        leave_huayuan(function()
                                check_busy(function()
                                    exe("bo huacong")
                                    check_busy(function()
                                        exe("enter;gps")
                                    end)
                                end)
                            end,0)
                    end,

    ["小舟一叶小舟，从洞庭湖边"] = function()
                        var.dongting_boat = var.dongting_boat or 0
                        var.dongting_boat = var.dongting_boat + 1
                        if var.dongting_boat>10 then
                            var.dongting_boat = nil
                            exe("quit")
                        end
                    end,

    ["山路山路陡峭，林中郁郁葱"] = function()
                            exe("su;su;su;su;s;gps")
                    end,
    ["蛇谷荒地"] = function()
                        local exits = var.roomexit or "none"
                            exits = fangxiang_to_count(exits) or 0
                        if eixts == 2567 then --迷宫西边入口 --"northeast;west;southwest"
                            exe("ne;ne;nu;gps")
                        elseif exits == 3303 then --迷宫东边入口-- northeast;west;southeast;east
                            exe("w;nw;gps")
                        elseif exits == 3218 then -- wiki 说的出来路径 south;north;west;east;northeast
                            exe("w;sw;ne;gps")
                        else
                            ----
                            local dir = get_random_move(exits)
                            exe(dir..";gps")
                        end
                    end,
    ["练习室这是桃花岛的音乐练习"] = function()
                            exe("n;w;n;e;n;w;gps")
                    end,
    --    这是桃花岛 的音乐练习 室，供艺人练习(play)乐谱，排练节目之用。
--w;se;ne

--竹林 -
 --   这是一片密 密的竹林。这里人迹罕至，惟闻足底叩击路面，有僧
    --密林 -
   -- 林中阴森森 的，除了几 声鸟叫外再没有其他的声音，四周

}
