-- 特殊路径 迷宫

function check_npc_in_maze() end --检查迷宫有没有npc
function check_stop() end        --检查是否要停止

function check_maze(action)

    if not var.do_stop or var.do_stop == 0 then
        local needstop = check_stop()
        if needstop == nil then
            action()
        else
            needstop()
        end
    end

end

function check_maze_full(action)

    if not var.do_stop or var.do_stop == 0 then
        local needstop = check_stop()
        if needstop == nil then
            local npc_found = check_npc_in_maze(action)
            if npc_found == nil then
                action()
            else
                npc_found(action)
            end
        else
            needstop()
        end
    end
end


function map_follow_maze() --保持迷宫中继续地图跟随你的走路，略吊
    if var.follow_rooms_fail==nil and (var["migong"]==nil or var["migong"]==0) and var.path_rooms~=nil and next(var.path_rooms)~=nil then
        Print("map_follow_maze")
        var.follow_room=var.path_rooms[1]
        table.remove(var.path_rooms,1)
        if rooms[var.follow_room].name==var.roomname then
        else
            var.follow_rooms_fail=1
        end
    end
end

function normal_enter_boat() --正常坐船

    add_alias("do_walk_enter",function()
        exe("enter")
    end)
    add_alias("do_walk_out",function()
        exe("out")
        del_trigger("maze_dujiang_5")
        keepwalk()
    end)
    add_alias("force_walk_out",function()
        keepwalk()
    end)

    add_alias("do_walk_enter_boat",function()
        exe("enter boat")
    end)

    add_alias("after_crush",function()
        keepwalk()
    end)
end

normal_enter_boat()

--********************--
--  白驼山西门        --
--********************--

add_alias("crossbtin",function(p) --进蛇谷 crossbtin

    add_alias("keepmigong",function() exe("crossbtin") end) --继续迷宫的alias

    var.migong=1

    check_maze(function()
--  check_maze_full(function()

        if var.roomname and var.roomname=="竹林" then
            var.migong = 0
            close_trigger("maze_bt_ximen")
            keepwalk()
        else
            open_trigger("maze_bt_ximen")
            local r = math.random(5)
            if r==1 then
                exe("s;pro 你正在【进入白驼山西门】",5)
            elseif r==2 then
                exe("n;pro 你正在【进入白驼山西门】",5)
            else
                exe("w;pro 你正在【进入白驼山西门】",5)
            end
        end
    end)
end)

add_trigger("maze_bt_ximen","^[> ]*\\S{1,2}正在【进入白驼山西门】",function(params)

    close_trigger("maze_bt_ximen")
    del_timer("input")--判断输入的定时器

    check_maze_full(function()

                if var.roomname and var.roomname=="竹林" then
                    var.migong=0
                    map_follow_maze()

                    keepwalk()
                elseif  var.roomname and var.roomname=="草丛" then
                    exec("crossbtin")
                else
                    var.follow_rooms_fail=1
                    gps()
                end

    end)
end)


add_alias("crossbtout",function(p)

    add_alias("keepmigong",function() exe("crossbtout") end) --继续迷宫的alias

    var.migong=1
    check_maze(function()
--  check_maze_full(function()

        if var.roomname and var.roomname=="西门" then
            var.migong=0
            close_trigger("maze_bt_ximen_out")
            keepwalk()
        else
            open_trigger("maze_bt_ximen_out")
            local r=math.random(6)
            if r==1 then
                exe("s;pro 你正在【离开白驼山西门】",5)
            elseif r==2 then
                exe("n;pro 你正在【离开白驼山西门】",5)
            elseif r==3 then
                exe("e;pro 你正在【离开白驼山西门】",5)
            else
                exe("n;s;e;pro 你正在【离开白驼山西门】",5)
            end
        end

    end)
end)

add_trigger("maze_bt_ximen_out","^[> ]*\\S{1,2}正在【离开白驼山西门】",function(params)

    close_trigger("maze_bt_ximen_out")
    del_timer("input")--判断输入的定时器

    check_maze_full(function()

                    if var.roomname and var.roomname=="西门" then
                        var.migong=0
                        map_follow_maze()

                        keepwalk()

                    elseif  var.roomname and var.roomname=="草丛" then
                        exec("crossbtout")
                    elseif  var.roomname and var.roomname=="树林" then
                        exec("e;crossbtout")
                    else
                        var.follow_rooms_fail=1
                        gps()
                    end

    end)
end)

close_trigger("maze_bt_ximen_out")
close_trigger("maze_bt_ximen")
--~~~~~~~~~~~~--
-- 杀手帮迷宫 --
--~~~~~~~~~~~~--

--crossssb  in杀手帮 果林
--crossssbb  out杀手帮 果林

add_alias("crossssb",function(p) -- in进入杀手帮 果林

    add_alias("keepmigong",function() exe("crossssb") end) --继续迷宫的alias

    var.migong=1
    check_maze_full(function()

            local r=math.random(2)
            if r == 1 then
                open_trigger("maze_ssb")
            --  exec("e;s;pro 你正在【进入杀手帮果林】",5)
                exe("e;pro 你正在【进入杀手帮果林east】",5)
            else
                open_trigger("maze_ssb")
            --  exec("n;s;pro 你正在【进入杀手帮果林】",5)
                exe("n;pro 你正在【进入杀手帮果林north】",5)
            end
    end)
end)

add_alias("crossssbb",function(p)  --out离开杀手帮 果林

    add_alias("keepmigong",function() exe("crossssbb") end) --继续迷宫的alias

    var.migong=1
    check_maze(function()

            local r=math.random(2)
            if r == 1 then
                open_trigger("maze_ssbb")
            --  exec("e;s;pro 你正在【离开杀手帮果林】",5)
                exe("e;pro 你正在【离开杀手帮果林east】",5)
            else
                open_trigger("maze_ssbb")
            --  exec("n;s;pro 你正在【离开杀手帮果林】",5)
                exe("n;pro 你正在【离开杀手帮果林north】",5)
            end
    end)
end)

add_trigger("maze_ssb","^[> ]*\\S{1,2}正在【进入杀手帮果林(.*)】",function(params)

    del_timer("input")--判断输入的定时器
    var.maze_ssb_dir = params[1]
    check_maze_full(function()

                if var.roomname and var.roomname=="后山" then
                    close_trigger("maze_ssb")
                    var.migong=0
                    map_follow_maze()

                    keepwalk()

                elseif  var.roomname and var.roomname=="大道" then
                    close_trigger("maze_ssb")
                    exe("n;crossssb")
                elseif  var.roomname and var.roomname=="果林" then
                    if var.maze_ssb_dir == "south" then
                        exe("crossssb")
                    else
                        exe("s;pro 你正在【进入杀手帮果林south】",5)
                    end
                else
                    close_trigger("maze_ssb")
                    var.follow_rooms_fail=1
                    gps()
                end
    end)

end)

add_trigger("maze_ssbb","^[> ]*\\S{1,2}正在【离开杀手帮果林(.*)】",function(params)

    del_timer("input")--判断输入的定时器
    var.maze_ssb_dir = params[1]
    check_maze_full(function()

                if var.roomname and var.roomname=="大道" then
                    close_trigger("maze_ssbb")
                    var.migong=0
                    map_follow_maze()
                    keepwalk()
                elseif  var.roomname and var.roomname=="后山" then
                    close_trigger("maze_ssbb")
                    exe("s;crossssbb")
                elseif  var.roomname and var.roomname=="果林" then
                    if var.maze_ssb_dir == "south" then
                        exe("crossssbb")
                    else
                        exe("s;pro 你正在【离开杀手帮果林south】",5)
                    end
                else
                    close_trigger("maze_ssbb")
                    var.follow_rooms_fail=1
                    gps()
                end
    end)

end)
close_trigger("maze_ssb")
close_trigger("maze_ssbb")

--~~~~~~~~~~~~~~--
-- 武当后山迷宫 --
--~~~~~~~~~~~~~~--
--crosswd  in
--crosswdb  out

add_alias("crosswd",function(params)--武当后山

    add_alias("keepmigong",function() exe("crosswd") end) --继续迷宫的alias

    var.migong=1
    local check=tonumber(params[-1]) or 0

    if check==0 then
        wudang_maze_explored={} --加一个剔除房间看看
        send("set brief 2")
    end



    local needstop=check_stop()

    if needstop==nil then
        if var.do_stop==nil or var.do_stop==0 then
            open_trigger("maze_wd")
            exec("pro 你正在【进入武当后山】",1)
        end
    else
        needstop()
    end

end)

add_alias("crosswdb",function(params)--离开武当

    add_alias("keepmigong",function() exe("crosswdb") end) --继续迷宫的alias

    var.migong=1
    local check=tonumber(params[-1]) or 0

    if check==0 then
        wudang_maze_explored={} --加一个剔除房间看看
        send("set brief 2")
    end

    local needstop=check_stop()

    if needstop==nil then
        if var.do_stop==nil or var.do_stop==0 then
            open_trigger("maze_wdb")
            exec("pro 你正在【离开武当后山】",1)
        end
    else
        needstop()
    end
end)

add_trigger("maze_wd","^[> ]*\\S{1,2}正在【进入武当后山】",function(params)
    del_timer("input")--判断输入的定时器
    check_maze_full(function()
        var.roomname = var.roomname or ""
        var.roomexit = var.roomexit or ""
        if var.roomname == "密林" and have_fangxiang(var.roomexit,"southdown") then
            var.migong=0
            map_follow_maze()
            close_trigger("maze_wd")
            keepwalk()
        elseif  string.find("|密林|灌木丛|倒下的巨树|山涧|林间空地|","|"..var.roomname.."|") then
            local roomexit = string.gsub(";"..var.roomexit..";",";northup;",";")
            roomexit = string.gsub(";"..roomexit..";",";southdown;",";")
            roomexit = string.match(roomexit,"^;(.*)") or roomexit
            roomexit = string.match(roomexit,"(.*);$") or roomexit
            local dir = random_item(roomexit,";") -- function.lua
    --      print("dir->"..dir)
            exe(dir..";pro 你正在【进入武当后山】",10)
        else
            var.follow_rooms_fail=1
            gps()
        end
    end)
end)
add_trigger("maze_wdb","^[> ]*\\S{1,2}正在【离开武当后山】",function(params)
    del_timer("input")--判断输入的定时器
    check_maze_full(function()
        var.roomname = var.roomname or ""
        var.roomexit = var.roomexit or ""
        if var.roomname == "密林" and have_fangxiang(var.roomexit,"northup") then
            var.migong=0
            map_follow_maze()
            close_trigger("maze_wdb")
            keepwalk()
        elseif  string.find("|密林|灌木丛|倒下的巨树|山涧|林间空地|","|"..var.roomname.."|") then
            local roomexit = string.gsub(";"..var.roomexit..";",";northup;",";")
            roomexit = string.gsub(";"..roomexit..";",";southdown;",";")
            roomexit = string.match(roomexit,"^;(.*)") or roomexit
            roomexit = string.match(roomexit,"(.*);$") or roomexit
            local dir = random_item(roomexit,";") -- function.lua
            exe(dir..";pro 你正在【离开武当后山】",10)
        else
            var.follow_rooms_fail=1
            gps()
        end
    end)
end)

close_trigger("maze_wd")
close_trigger("maze_wdb")


--***************--
--    武当爬山   --
--***************--
add_alias("cross_wd_climb",function()
--  var.migong = 1
    check_maze(function()
        add_trigger("maze_wd_climb","^[> ]*(你抬头仰望，突然发现峰顶就在眼前|你爬的精疲力竭，忽然发现已经到|你低头一看，离地面只有丈余高，你转身一跳，稳稳的落在地上。|你终于爬到崖洞中)",function()
            del_trigger('maze_wd_climb')
            check_maze(function()
    --          var.migong = 0
                keepwalk()
            end)
        end)
        exe("climb")
    end)

end)

--***************--
--    武当石阶   --
--***************--
function walk_out_danxiang(action)
    var.migong = 1

    add_trigger("daxiang_walk_1","^[> ]*你尝试单向路径行走并不是一个北侠的职业，目前没有相关的信息。",function (params)
        del_timer("input")
        var.roomname = var.roomname or ""
        var.roomexit = var.roomexit or ""
        var.danxiang_dir = var.danxiang_dir or "" --之前的单向路径

        local where = var.danxiang_where
        check_maze(function()
            local next_dir = "" -- 方向

            if (var.roomname and var.roomname ~="石阶" and var.roomname ~="山野小径") or (numitems(var.roomexit,";")>2) then --不是石阶就执行action 或 gps >2表示不是单向路了
                del_trigger("daxiang_walk_1")
                if type(action)=="function" then
                    action()
                else
                    exe("gps")
                end
            else
                if var.danxiang_dir=="" then  -- 之前没有走过
                    if var.roomexit == "" then
                        walk_out_danxiang(action)
                    else
                        next_dir = random_item(var.roomexit,";")
                    end
                else
                    if numitems(var.roomexit,";")==2 then --两个出口
                        if string.find(";"..var.roomexit..";",";"..var.danxiang_dir..";") then
                            next_dir = fanfangxiang(var.danxiang_dir) --反方向
                            next_dir = string.gsub(";"..var.roomexit..";",";"..next_dir..";","") --删除这个反方向
                            next_dir = string.gsub(next_dir,";","") --删除;
                            --留下真的方向了
                        else
                            next_dir = random_item(var.roomexit,";") --虽然有，但是不对，所以继续随机
                        end

                    else --其他就gps吧搞不定了
                        del_trigger("daxiang_walk_1")
                        var.migong=0
                        map_follow_maze()
                        if type(action)=="function" then
                            action()
                        else
                            exe("gps")
                        end
                    end
                end


            end

            if next_dir and next_dir ~= "" then
                var.danxiang_dir = next_dir
                exe(next_dir..";pro 你尝试单向路径行走",5)
            end

        end)
    end)

    exe("look;pro 你尝试单向路径行走",5)
end


add_alias("dxwd",function(p)
    if p[-1] and p[-1]~="" then
        var.danxiang_dir = p[-1]
    end
    walk_out_danxiang()
end)

--***************--
-- 少林山野小径  --
--***************--

add_alias("dxsl",function(p)  -- dxsl 古墓 nu
    local where,fangxiang_dir="",""
    if p[1] and p[1]~="" then
        where = p[1]
    end
    if p[2] and p[2]~="" then
        fangxiang_dir = p[2]
    end
    walk_to_shaolin(function() exe("say 测试一下!") end,where,fangxiang_dir)
end)

function walk_to_shaolin(action,where,fangxiang_dir)
    var.migong = 1
                   -- 完成后动作 哪里   开始的方向
    if fangxiang_dir ~= nil then
        var.daxiang_dir = fangxiang_dir
--  -开始方向有的话就定义一下单向方向，当然也可以缺省的

    end
    if where == nil or where == "" then --不知道去哪里么？
        where = "古墓" --那就去gm好了
    end

    add_trigger("daxiang_walk_1","^[> ]*你尝试单向路径行走并不是一个北侠的职业，目前没有相关的信息。",function (params)
        del_timer("input")
        check_maze(function()
            local next_dir = ""
            if var.roomname and var.roomname~="山野小径" and var.roomname~="半山腰" and var.roomname~="岔路口" and var.roomname~="五乳峰" and var.roomname~="二祖庵" and var.roomname~="乡野小路" and var.roomname~="山谷" and var.roomname~="初祖庵"  then --不在迷宫?

                    if string.find("|山坡|虎牢关|千佛殿|石阶|竹林|松树林|",var.roomname) and ((var.roomname == "千佛殿" and where=="少林寺后山") or (var.roomname == "千佛殿" and where=="少林寺") or (var.roomname == "竹林" and where=="达摩洞") or (var.roomname == "竹林" and where=="竹林") or (var.roomname == "虎牢关" and where=="洛阳") or (var.roomname == "山坡" and where=="古墓") or (var.roomname == "石阶" and where=="少林寺前山") or (var.roomname == "松树林" and where=="松树林") or (var.roomname == "松树林" and where=="青云坪")) then
                        exe("say 我在哪里?")
                        var.migong = 0
                        map_follow_maze()
                        del_trigger("daxiang_walk_1")
                        if type(action)=="function" then
                            action() -- ok了
                        else
                            exe("gps")
                        end
                    else
                        if action==nil then --没有定义下一步的action的话就gps吧
                            var.migong = 0
                            map_follow_maze()
                            del_trigger("daxiang_walk_1")
                            exe("gps")
                        else
                            exe("say 继续走么?")
                            local next_dir = ""
                            if var.roomname == "山坡" then
                                next_dir = "eastup"
                            elseif var.roomname == "虎牢关" then
                                next_dir = "southwest"
                            elseif var.roomname == "千佛殿" then
                                next_dir = "north"
                            elseif var.roomname == "石阶" then
                                next_dir = "westdown"
                            elseif var.roomname == "竹林" then
                                next_dir = "west"
                            elseif var.roomname == "松树林" then--单向吧，我想想

                            end
                            var.danxiang_dir = next_dir
                            exe(next_dir..";pro 你尝试单向路径行走",5)
                        end

                    end
            else

                if var.danxiang_dir=="" then  -- 之前没有走过
                    if var.roomexit == "" then
                        walk_to_shaolin(action,where,var.daxiang_dir)
                    else
                        next_dir = random_item(var.roomexit,";")
                    end
                else
                    if numitems(var.roomexit,";")<2 then --一个出口 没有出口
                        var.danxiang_lupai = nil
                        walk_to_shaolin_check(action,where,var.danxiang_dir) --检查
                    elseif numitems(var.roomexit,";")==2 then -- 两个出口

                                            if var.danxiang_dir == nil or var.danxiang_dir=="" then --没走过？
                                                next_dir = random_item(var.roomexit,";")

                                            else --走过一个方向?
                                                next_dir = fanfangxiang(var.danxiang_dir)
                                                if string.find(";"..var.roomexit..";",";"..next_dir..";") then --这个反方向在本房间出口

                                                    --那么走另外一个方向
                                                    next_dir = string.gsub(";"..var.roomexit..";",";"..next_dir..";","") --删除这个反方向
                                                    next_dir = string.gsub(next_dir,";","")
                                                    echo("$HIW$上次方向:$HIB$"..var.danxiang_dir.."$HIW$本次方向:$HIG$"..next_dir.."$NOR$")

                                                else --虽然走过，但是方向不对，重新走吧
                                                    next_dir = random_item(var.roomexit,";")
                                                end

                                            end

                    else --更多出口?
                        var.danxiang_lupai = nil
                        walk_to_shaolin_check(action,where,var.danxiang_dir) --检查
                    end
                end

                if next_dir~= "" then
                    var.danxiang_dir = next_dir
                    exe(next_dir..";pro 你尝试单向路径行走",5)
                end

            end
        end)
    end)
    exe("look;pro 你尝试单向路径行走",5)
end

function walk_to_shaolin_check(action,where,fangxiang_dir)
        add_trigger("daxiang_walk_2","^[> ]*\\S+(?:出来|通向|达到|古墓|少林|洛阳|青云|松树林)",function()
            if string.find(line[2],"通向") or string.find(line[2],"达到") or string.find(line[2],"出来") then
                var.danxiang_lupai = line[2]..line[1]
            end
        end)

        add_trigger("daxiang_walk_1","^[> ]*你正在检查需要前往的方向并不是一个北侠的职业，目前没有相关的信息。",function (params)
            del_timer("input")
            local next_dir,dir,info,lupai = "","","",var.danxiang_lupai
            if 1==0 then --到达

            elseif var.roomname == "初祖庵" and where == "达摩洞" then --到了吧
                var.migong = 0
                map_follow_maze()
                del_trigger("daxiang_walk_1")
                if type(action)=="function" then
                            action() -- ok了
                else
                        exe("gps")
                end
            else

                if var.danxiang_lupai and var.danxiang_lupai ~= "" then --路牌信息读到了...
                    lupai = var.danxiang_lupai

                    next_dir = string.match(lupai,"^(.+)"..where)

                    if where == "少林寺后山" and next_dir==nil then
                        next_dir = string.match(lupai,"^(.+)少林寺")
                    end
                    if where == "青云坪" and next_dir==nil then
                        next_dir = string.match(lupai,"^(.+)松树林")
                    end
                    if where == "竹林" then
                        next_dir = string.match(lupai,"^(.+)达摩洞")
                    end

                    if next_dir == nil then
                        print("lupai不对")
                        next_dir = "这个路牌是不对的"
                    end

                    local i,j,l,t= "","","",{}
                    for k in string.gmatch(next_dir,'(..)') do
                        l = j
                        j = i
                        i = k
                        if k == "面" then
                            table.insert(t,l..j)
                        end
                    end
                    for _,v in ipairs(t) do
                        next_dir = v
                    end

                    if next_dir ~= "" then --没有下一步方向?

                        info = next_dir
                        if info == "东北" then
                            dir = "northeast"
                        elseif info == "东南" then
                            dir = "southeast"
                        elseif info == "西北" then
                            dir = "northwest"
                        elseif info == "西南" then
                            dir = "southwest"
                        elseif string.match(info,'东$') then
                            if string.find(";"..var.roomexit..";",";eastup;") then
                                dir = "eastup"
                            elseif string.find(";"..var.roomexit..";",";eastdown;") then
                                dir = "eastdown"
                            else
                                dir = "east"
                            end
                        elseif string.match(info,'南$') then
                            if string.find(";"..var.roomexit..";",";southup;") then
                                dir = "shouthup"
                            elseif string.find(";"..var.roomexit..";",";southdown;") then
                                dir = "southdown"
                            else
                                dir = "south"
                            end
                        elseif string.match(info,'西$') then
                            if string.find(";"..var.roomexit..";",";westup;") then
                                dir = "westup"
                            elseif string.find(";"..var.roomexit..";",";westdown;") then
                                dir = "westdown"
                            else
                                dir = "west"
                            end
                        elseif string.match(info,'北$') then
                            if string.find(";"..var.roomexit..";",";northup;") then
                                dir = "northup"
                            elseif string.find(";"..var.roomexit..";",";northdown;") then
                                dir = "northdown"
                            else
                                dir = "north"
                            end
                        end
                    end

                end
                if dir == "" then --还是没有...
                    if var.danxiang_dir == nil or var.danxiang_dir =="" then --上次也没有...
                        local roomexit = string.gsub(";"..var.roomexit..";",";enter;",";")
                        dir = string.match(roomexit,"^;(.+)") or roomexit
                        dir = string.match(dir,"(.+);$") or roomexit
                        if dir == "" then
                            dir = random_item(var.roomexit,";")
                        else
                            dir = random_item(dir,";")
                        end
                    else
                        local roomexit = string.gsub(";"..var.roomexit..";",";enter;",";")
                        next_dir = fanfangxiang(var.danxiang_dir)
                        roomexit = string.gsub(roomexit,";"..next_dir..";",";")
                        dir = string.match(roomexit,"^;(.+)") or roomexit
                        dir = string.match(dir,"(.+);$") or roomexit
                        if dir == "" then
                            dir = random_item(var.roomexit,";")
                        else
                            dir = random_item(dir,";")
                        end
                    end
                end

                    var.danxiang_dir = dir
                    del_trigger("daxiang_walk_1")
                    del_trigger("daxiang_walk_2")
                    echo("$HIW$尝试方向:$HIG$"..dir)
                    exe(dir)
                    walk_to_shaolin(action,where,var.danxiang_dir)

            end
        end)

        wa(1,function()
            exe("look lupai;pro 你正在检查需要前往的方向",5)
        end)


end

add_alias("cross_che_slcza",function() --少林 初祖an
    check_maze(function()
        var.danxiang_dir = "north"
        exe("north")
        walk_to_shaolin(keepwalk,"达摩洞","north")
    end)
end)
add_alias("cross_che_czasl",function() --初祖an sl
    check_maze(function()
        var.danxiang_dir = "northup"
        exe("northup")
        walk_to_shaolin(keepwalk,"少林后山","northup")
    end)
end)

add_alias("cross_che_czagm",function() --初祖an gm
    check_maze(function()
        var.danxiang_dir = "northup"
        exe("northup")
        walk_to_shaolin(keepwalk,"古墓","northup")
    end)
end)
add_alias("cross_che_gmcza",function() --初祖an gm
    check_maze(function()
        var.danxiang_dir = "eastup"
        exe("eastup")
        walk_to_shaolin(keepwalk,"达摩洞","eastup")
    end)
end)
add_alias("cross_che_czadmd",function() --初祖an 达摩洞
    check_maze(function()
        var.danxiang_dir = "up"
        exe("up")
        walk_to_shaolin(keepwalk,"竹林","up")
    --  walk_out_danxiang(keepwalk)
    end)
end)

add_alias("cross_che_dmdcza",function() --初祖an 达摩洞
    check_maze(function()
        var.danxiang_dir = "west"
        exe("west")
        walk_to_shaolin(keepwalk,"达摩洞","west")
    --  walk_out_danxiang(keepwalk)
    end)
end)
----"cross_che_slqyp"
add_alias("cross_che_slqyp",function() --少林an 青云平
    check_maze(function()
        var.danxiang_dir = "north"
        exe("north")
        walk_to_shaolin(keepwalk,"青云坪","north")
    --  walk_out_danxiang(keepwalk)
    end)
end)
add_alias("cross_che_qypsl",function() -- 青云平 少林
    check_maze(function()
        var.danxiang_dir = "northwest"
        exe("northwest")
        walk_to_shaolin(keepwalk,"少林寺","northwest")
    --  walk_out_danxiang(keepwalk)
    end)
end)

add_alias("cross_che_syxj",function() --千佛殿 --山野小径 本来就是一个north，我改成难走的
    check_maze(function()
        exe("north")
        keepwalk()
    end)

end)
--~~~~~~~~~~~~--
-- 灵鹫宫tiesuo --
--~~~~~~~~~~~~--

add_alias("crossljg",function()

    check_maze(function()
            add_trigger("maze_ljg","^[> ]*你终于来到了对面，心里的石头终于落地。",function()
                var["idle"] = 0
        --      var.migong = 0
                del_trigger("maze_ljg")
                keepwalk()
            end)
        --  var.migong = 1
            exec("zou tiesuo")
    end)

end)

--~~~~~~~~~~~~--
-- 白驼山-扬州 --
--~~~~~~~~~~~~--

add_alias("cross_che_yzbt",function() --yz bt 问路

    check_maze(function()
            add_trigger("maze_bt_1","^[> ]*钱眼开左右看了看，偷偷对着你做了个数钱的手势。",function()
                if string.find(line[2],"你向钱眼开打听有关『白驼山』的消息。") then
                    del_trigger("maze_bt_1")
                    del_timer("timer")
                    exe("crossyzbt2")
                end
            end)
            set_timer("timer",10,function() send("ask qian yankai about 白驼山") end)
            exe("ask qian yankai about 白驼山")
    end)

end)

add_alias("crossyzbt2",function() --yz bt 2 给钱

    check_maze(function()
            add_trigger("maze_bt_2","^[> ]*你沿着钱眼开指点的途径，很快来到白驼山下。",function()
                var["idle"] = 0
                del_trigger("maze_bt_2")
                del_trigger("maze_bt_3")
                del_trigger("maze_bt_4")
                alarm("wait",2,function()
                    keepwalk()
                end)

            end)

            add_trigger("maze_bt_3","^[> ]*你没有那么多的白银。",function() --没钱给?
                exe("qu 200 silver")
                wa(2,function()
                    exe("crossyzbt2")
                end)
            end)
            add_trigger("maze_bt_4","^[> ]*你身上没有 gold 这样东西。",function() --没钱给?
                exe("qu 2 gold")
                wa(2,function()
                    exe("crossyzbt2")
                end)
            end)

            local party=var.party or "普通百姓"
            if party=="白驼山" then
                exe("give 20 silver to qian yankai")
            else
                exe("give 1 gold to qian yankai")
            end
    end)

end)

add_alias("cross_che_btyz",function() --bt yz

    check_maze(function()
            add_trigger("maze_bt_3","^[> ]*\\S{1,2}正在【离开白驼山】",function()
                del_trigger("maze_bt_3")
                if string.find(line[2],"你搬动了花盆，只见花盆下面露出一个黑幽幽的洞口。") then
                    send("down")
                    keepwalk()
                else
                    send("move pen")
                    send("down")
                    keepwalk()
                end

            end)
            exe("move pen;pro 你正在【离开白驼山】")
    end)

end)
--~~~~~~~~~~~~--
-- 慕容  船   --
--~~~~~~~~~~~~--

function murong_boat(where)

    check_maze(function()
        local party=var.party or "普通百姓"
        if party=="姑苏慕容" and (not where or where ~= "mantuo")then
            exe("find boat")
        else
            add_trigger("maze_mr_1","^[> ]*你跃上小舟，船就划了起来。",function()
                del_timer("timer")
            end)
            add_trigger("maze_mr_2","^[> ]*(绿衣少女将小船系在树枝之上，你跨上岸去。|小舟终于划到近岸，你从船上走了出来。|你熟门熟路地找到一条小舟，解开绳子，划了起来。)",function()
                var["idle"] = 0
                check_maze(function()
                    del_trigger("maze_mr_0")
                    del_trigger("maze_mr_1")
                    del_trigger("maze_mr_2")
                    keepwalk()
                end)
            end)

            set_timer("timer",2,function()
                exe("ask girl about 拜庄;do_walk_enter_boat")
            end)
            exe("ask girl about 拜庄;do_walk_enter_boat")
        end

    end)
end

add_alias("cross_che_szmr",function() -- sz mr 苏州-慕容
    murong_boat()
end)

add_alias("cross_che_mrsz",function() -- mr sz 慕容-苏州
    murong_boat()
end)

add_alias("cross_che_mtmr",function() -- mt mr 曼陀-慕容
    murong_boat("mantuo")
end)

-- row boat
function murong_row_boot(row,action)
    if not var.do_stop or var.do_stop == 0 then
        local needstop = check_stop()
        if needstop == nil then

            add_trigger("maze_row_1","^[> ]*不知过了多久，船终于靠岸了，你累得满头大汗。",function()
                check_maze(function()
                    var["idle"] = 0
                    del_trigger("maze_row_1")
                    if type(action)=="function" then
                        action()
                    else
                        keepwalk()
                    end
                end)
            end)
            if row == "row qinyun" then
                exe("do_walk_enter_boat")
            end
            exe(row)
        else
            needstop()
        end
    end
end

add_alias("cross_che_mrmt",function() -- mr mt
    murong_row_boot("row mantuo")
end)

add_alias("cross_che_qytx",function() --qy tx 琴韵 听香
    murong_row_boot("row tingxiang")
end)
add_alias("cross_che_qyyzw",function() --qy yzw 琴韵 yzw
    murong_row_boot("row yanziwu")
end)

add_alias("cross_che_yzwqy",function() --yzw qy 琴韵
    murong_row_boot("row qinyun")
end)
add_alias("cross_che_txqy",function() --tx qy  听香 琴韵
    murong_row_boot("row qinyun")
end)



--~~~~~~~~~~~~--
-- 大轮寺 --
--~~~~~~~~~~~~--

add_alias("crossdls",function()

    check_maze(function()

            add_trigger("maze_dls","^[> ]*\\S{4,16}白了你一眼道：“门已经开着你还敲？”",function()
                del_trigger("maze_dls")
                del_trigger("maze_dls_2")
                del_timer("input")
                send("nu")
                keepwalk()
            end)
            add_trigger("maze_dls_2","^[> ]*你突然发现原来门是开着的，直接进去就行了。",function()
                del_trigger("maze_dls")
                del_trigger("maze_dls_2")
                del_timer("input")
                send("nu")
                keepwalk()
            end)
            send("knock gate")
            set_timer("input",1.5,function()
                send("knock gate")
            end)

    end)
end)
--~~~~~~~~~~~~~~~~~~~~--
--       桃花岛       --
--~~~~~~~~~~~~~~~~~~~~--

add_alias("cross_che_boat",function()  --thd 桃花岛

    check_maze(function()
            add_trigger("maze_thd_1","^[> ]*你(朝船夫挥了挥手便跨上岸去。|沿着踏板走了上去。)",function()
                var["idle"] = 0
        --      var.migong = 0
                del_trigger("maze_thd_1")
                --keepwalk()
                exe("force_walk_out")
            end)
        --  var.migong = 1
            exe("do_walk_enter_boat")
    end)

end)



--你朝船夫挥了挥手便跨上岸去。
--~~~~~~~~~~~~~~~~~~~~--
--       坐马车       --
--~~~~~~~~~~~~~~~~~~~~--
--过江坐船


function dujiang(where)
--  var.migong = 1
    check_maze(function()
            add_trigger("maze_dujiang_1","^[> ]*只听得江面上隐隐传来：“别急嘛，这儿正忙着呐……”",function()
                if string.find(line[2],"^[> ]*你.*一声") then --确认上一句是你自己yell的
                    alarm("input",1,function()
                        send("yell boat")
                    end)
                end
            end)

            add_trigger("maze_dujiang_2","^[> ]*(?:岸边一只渡船上的老艄公说道：正等着你呢，上来吧。|一叶扁舟缓缓地驶了过来，艄公将一块踏脚板搭上堤岸，以便乘客)",function()
                if string.find(line[2],"^[> ]*你.*一声") then --确认上一句是你自己yell的
                    del_timer("input")
                    close_trigger("maze_dujiang_2")
                    exe("do_walk_enter;pro 你正在【检查坐船】",15) --enter
                end
            end)

            add_trigger("maze_dujiang_3","^[> ]*艄公一把拉住你，你还没付钱呢？",function() --没钱了...
                echo("  $HIW$重要事件说五遍$HIY$你$HIW$没有$HIR$钱钱钱钱钱$HIW$啦？$NOR$")
                del_trigger("maze_dujiang_2")
                del_trigger("maze_dujiang_3")
                del_trigger("maze_dujiang_4")
                del_trigger("maze_dujiang_5")
                del_trigger("maze_dujiang_6")
                del_timer("input")
            --  var.migong = 0
            end)

            add_trigger("maze_dujiang_4","^[> ]*\\S{1,2}正在【检查坐船】",function() --万一shao gong 死了？检查一下吧
                del_timer("input")
                --> 羊皮筏 -
                Print("船在哪里:"..var.roomname)
                if var.roomname and (string.find(var.roomname,"船") or string.find(var.roomname,"舟") or string.find(var.roomname,"羊皮筏")) then
                    var["wrong_way"]=0
                    echo("  $HIW$成功坐船!")
                else
                    open_trigger("maze_dujiang_2")
                    dujiang() --再来
                end
            end)
            --
            add_trigger("maze_dujiang_5","^[> ]*艄公要继续做生意了，所有人被赶下了渡船。",function() --没钱了...
                del_trigger("maze_dujiang_1")
                del_trigger("maze_dujiang_2")
                del_trigger("maze_dujiang_3")
                del_trigger("maze_dujiang_4")
                del_trigger("maze_dujiang_5")
                del_trigger("maze_dujiang_6")
        --      var.migong = 0
                var["idle"] = 0
                exe("force_walk_out")
            --  keepwalk()
            end)

            add_trigger("maze_dujiang_6","^[> ]*艄公说“到啦，上岸吧”，随即把一块踏脚板搭上堤岸。",function() --没钱了...
                var.migong = 0
                var["idle"] = 0
                del_trigger("maze_dujiang_1")
                del_trigger("maze_dujiang_2")
                del_trigger("maze_dujiang_3")
                del_trigger("maze_dujiang_4")
            --  del_trigger("maze_dujiang_5")
                del_trigger("maze_dujiang_6")
                exe("do_walk_out")
            --  keepwalk()
            end)

            if where and where=="changjiang" then
                exes("ask shao gong about jiang;yell boat")
            elseif where and where=="huanghe" then
                exes("ask shao gong about huanghe;yell boat")
            else
                exes("ask shao gong about jiang;ask shao gong about huanghe;yell boat")
            end
            alarm("input",2,function() send("yell boat") end)

    end)

end

function yellboat()
--  var.migong = 1
    check_maze(function()

            add_trigger("maze_dujiang_1","^[> ]*只听得江面上隐隐传来：“别急嘛，这儿正忙着呐……”",function()
                if string.find(line[2],"^[> ]*你.*一声") then --确认上一句是你自己yell的
                    print("maze_dujiang_1")
                    alarm("input",1,function()
                        send("yell boat")
                    end)
                end
            end)

            add_trigger("maze_dujiang_2","^[> ]*(?:岸边一只渡船上的老艄公说道：正等着你呢，上来吧。|一叶扁舟缓缓地驶了过来，艄公将一块踏脚板搭上堤岸，以便乘客)",function()
                if string.find(line[2],"^[> ]*你.*一声") then --确认上一句是你自己yell的
                    print("maze_dujiang_2")
                    del_timer("input")
                    exe("do_walk_enter;pro 你正在【检查坐船】",15) --enter
                end
            end)

            add_trigger("maze_dujiang_3","^[> ]*艄公一把拉住你，你还没付钱呢？",function() --没钱了...
                echo("  $HIW$重要事件说五遍$HIY$你$HIW$没有$HIR$钱钱钱钱钱$HIW$啦？$NOR$")
                del_trigger("maze_dujiang_2")
                del_trigger("maze_dujiang_3")
                del_trigger("maze_dujiang_4")
                del_trigger("maze_dujiang_5")
                del_trigger("maze_dujiang_6")
                del_timer("input")
        --      var.migong = 0
            end)

            add_trigger("maze_dujiang_4","^[> ]*\\S{1,2}正在【检查坐船】",function() --万一shao gong 死了？检查一下吧
                del_timer("input")
                if var.roomname and (string.find(var.roomname,"船") or string.find(var.roomname,"舟")) then --没在船上

                    var["wrong_way"]=0
                    Print("  成功坐船!")
            --      var.migong = 0
                else
                    yellboat()
                end
            end)
            --
            add_trigger("maze_dujiang_5","^[> ]*艄公要继续做生意了，所有人被赶下了渡船。",function() --没钱了...
                del_trigger("maze_dujiang_1")
                del_trigger("maze_dujiang_2")
                del_trigger("maze_dujiang_3")
                del_trigger("maze_dujiang_4")
                del_trigger("maze_dujiang_5")
                del_trigger("maze_dujiang_6")
        --      var.migong = 0
                var["idle"] = 0
                keepwalk()
            end)
            --艄公将一块踏脚板搭上堤岸，形成一个向上的阶梯。
            --艄公说“到啦，上岸吧”，随即把一块踏脚板搭上堤岸。
            add_trigger("maze_dujiang_6","^[> ]*艄公(将一块踏脚板搭上堤岸，形成一个向上的阶梯。|说“到啦，上岸吧”，随即把一块踏脚板搭上堤岸。)",function() --没钱了...
                del_trigger("maze_dujiang_1")
                del_trigger("maze_dujiang_2")
                del_trigger("maze_dujiang_3")
                del_trigger("maze_dujiang_4")
                del_trigger("maze_dujiang_5")
                del_trigger("maze_dujiang_6")
                var.migong = 0
                var["idle"] = 0
                exe("do_walk_out")
            --  keepwalk()
            end)

            exes("yell boat")
            alarm("input",2,function() send("yell boat") end)

    end)

end

add_alias("cross_che_hh",function()
    dujiang("huanghe")
end)
add_alias("cross_che_cj",function()
    dujiang("changjiang")
end)

--~~~~~~~~~~~~~~~~~~~~--
--       坐马车       --
--~~~~~~~~~~~~~~~~~~~~--

function zuomache(tocity)

    check_maze(function()

            add_trigger("maze_mache_1","^[> ]*你身上没有车资.*车夫拒绝开车。",function() --没钱
                del_timer("input")
                echo("  $HIW$重要事件说五遍$HIY$你$HIW$没有$HIR$钱钱钱钱钱$HIW$啦？$NOR$")
            end)
            add_trigger("maze_mache_2","^[> ]*马车缓缓开动，向着",function() --没钱
                del_timer("input")

            end)
            add_trigger("maze_mache_3","^[> ]*大车停稳了下来，你可以下车",function() --没钱
                var["idle"] = 0
                var.migong = 0
                del_timer("input")
                del_trigger("maze_mache_1")
                del_trigger("maze_mache_2")
                del_trigger("maze_mache_3")
                send("xia")
                keepwalk()
            end)

        --  var.migong = 1
            exe("gu che;qu "..tocity,2)

    end)
end

add_alias("cross_che_cddls",function()  --cd lx 成都到大轮寺
    zuomache("dalunsi")
end)

add_alias("cross_che_dlscd",function()  --dls cd 大轮寺到成都
    zuomache("chengdu")
end)

add_alias("cross_che_dlsjz",function()  --dls jz 大轮寺到江州
    zuomache("jiangzhou")
end)

add_alias("cross_che_dlskm",function()  --dls km 大轮寺到昆明
    zuomache("kunming")
end)
add_alias("cross_che_kmdls",function()  --km lx 昆明到大轮寺
    zuomache("dalunsi")
end)

add_alias("cross_che_dlssz",function()  --dls sz 大轮寺到苏州
    zuomache("suzhou")
end)
add_alias("cross_che_szdls",function()  --sz lx 苏州到大轮寺
    zuomache("dalunsi")
end)

add_alias("cross_che_dlsjx",function()  --dls jx 大轮寺到嘉兴
    zuomache("jiaxing")
end)
add_alias("cross_che_jxdls",function()  --km jx 嘉兴到大轮寺
    zuomache("dalunsi")
end)

add_alias("cross_che_cdjz",function()  --cd jz 成都到江州
    zuomache("jiangzhou")
end)
add_alias("cross_che_jzcd",function()  --jz cd 江州成都
    zuomache("chengdu")
end)

add_alias("cross_che_jzdls",function()  --jz dls 江州到大轮寺
    zuomache("dalunsi")
end)

add_alias("cross_che_lzbt",function()  --lz bt 兰州 白驼
    zuomache("baituoshan")
end)

add_alias("cross_che_btlz",function()  --lz bt 兰州 白驼
    zuomache("lanzhou")
end)



add_alias("cross_che_lxdl",function()  --lx jz 凌霄到江州
    zuomache("dalichengzhong")
end)
add_alias("cross_che_dllx",function()  --lx jz 凌霄到江州
    zuomache("lingxiaocheng")
end)

add_alias("cross_che_jzdl",function()  --lx jz 凌霄到江州
    zuomache("dalichengzhong")
end)
add_alias("cross_che_dljz",function()  --lx jz 凌霄到江州
    zuomache("jiangzhou")
end)
--~~~~~~~~~~~~~~~~~~~~--
--       红花会      --
--~~~~~~~~~~~~~~~~~~~~--

add_alias("crossyellboat",function()
    check_maze(function()
        yellboat()
    end)
end)

-- 无量山
add_alias("cross_che_wl",function()
    check_maze(function()
        add_trigger("wuliang","^[>]*你身在半空，双手乱挥，只盼能抓到什么东西，这么乱挥一阵，又下堕下百馀丈。",function()
            del_timer("input")
            close_trigger("wuliang")
    --      var.migong = 0
            keepwalk()
        end)
    --  var.migong = 1
        exe("climb yafeng",10)
    end)
end)
add_alias("cross_che_wlb",function() --无量山出来--这里检查了一下dodge
    var.skills_level = var.skills_level or {}
    local dodge_level = var.skills_level["dodge"] or 1
    if dodge_level>100 then
        check_maze(function()
            add_trigger("wuliang","^[>]*你终于一步步的终于挨到了桥头",function()
                del_timer("input")
                close_trigger("wuliang")
                keepwalk()
            end)
            exe("guo qiao")
        end)

    else
        Print("dodge 不够，需要quit")
    end

end)




--紫禁城

add_alias("cross_che_zjc",function()
    var.map_no_follow_this_room = true
    check_maze(function()
        local party = var.party or ""
        add_trigger("maze_temp","^[> ]*\\S{1,2}正在【进入紫禁城】",function()
            del_trigger("maze_temp")
            del_trigger("maze_temp_2")
            del_timer("input")
            check_maze(function()
                    var.map_no_follow_this_room = nil
                    map_follow_maze()
                    keepwalk()
            end)
        end)
        --钱老本给了你一个皇宫通行令！
        add_trigger("maze_temp_2","^[> ]*钱老本给了你一个皇宫通行令！",function()
            del_trigger("maze_temp_2")
            del_timer("input")
            check_maze(function()
                check_busy(function()
                    exe("sw;e;n;n;n;pro 你正在【进入紫禁城】")
                end)
            end)
        end)
        if party == "天地会" then
            exe("ask qian laoben about 进宫")
        else
            item = item or {}
            local gold = item["gold"] or 0
            if 1==0 and gold == 0 then
                qu_gold(1,jin_gong)
            else
                exe("ask qian laoben about 进宫;give 1 gold to qian laoben;ask qian laoben about 进宫")

            end
        end
    end)
end)
--> 一等侍卫上前挡住你，朗声说道：皇宫禁地，禁止闲杂人等出入！
function jin_gong() --进宫怕gold不够
    send("i2")
    gg("北京屠宰场",function()
        exe("cross_che_zjc")
    end)
end

-- 峨眉后山
--crossemb
--
--        4/5/6     6    4/5/6
--                4/5/6

--                  0                    1
--             7    3   2       1/2/7    7  1/2/7
--                  4                    0

--                  4/5/6
--       4/5/6      4       5
--                  3


--        5   6
--n;w;e;w;n;w;e;s;e;e;n
--结论就是。。。悲剧了只能w;s出来了

add_alias("crossemb",function()

    add_alias("keepmigong",function() exe("crossemb") end) --继续迷宫的alias

    var.migong = 1
    check_maze(function()
        add_trigger("maze_yunhai","^[> ]*\\S{1,2}正在【离开云海】",function()
            if var.roomname and var.roomname == "云海入口" then
                del_trigger("maze_yunhai")
                var.migong = 0
                map_follow_maze()
                keepwalk()
            elseif var.roomname == nil or var.roomname == "云海" then
                wait1(3,function()
                    exe("w;s;pro 你正在【离开云海】")
                end)
            elseif var.roomname == "云海出口" then
                exe("s;w;s;pro 你正在【离开云海】")
            else
                del_trigger("maze_yunhai")
                var.migong = 0
                exe("gps")
            end
        end)

        exe("s;pro 你正在【离开云海】")

    end)
end)

--石壁上竟是你之前刻上的路线：
--左 后 右 前 右 前 后 前
-- crossfmq
-- crossgw
-- crosssldzl

--你之前刻上的路线是：
--前 后 前 右 前 右 后 左

add_alias("cross_jqg_in",function()
    open_trigger("jqg_1")
    send("pro 你正在【进入绝情谷】")
end)

add_alias("cross_jqg_out",function()
    open_trigger("jqg_2")
    send("pro 你正在【离开绝情谷】")
end)

add_trigger("jqg_1","^[> ]*\\S{1,2}正在【进入绝情谷】",function(p)
    close_trigger("jqg_1")
    check_maze(function()
        if var.jqg_path_in==nil or var.jqg_path_in=="" then
            leave_jqg()
        else
            open_trigger("jqg_3")
            wait1(10,function()
                exe(var.jqg_path_in)
    --          keepwalk()
            end)
        end
    end)
end)

add_trigger("jqg_2","^[> ]*\\S{1,2}正在【离开绝情谷】",function(p)
    close_trigger("jqg_2")
    check_maze(function()
        if var.jqg_path_out==nil or var.jqg_path_out=="" then
            leave_jqg()
        else
            open_trigger("jqg_3")
            wait1(10,function()
                exe(var.jqg_path_out)
        --      keepwalk()
            end)
        end
    end)
end)

add_trigger("jqg_3","^[> ]*你终于走出了这段黑暗的山洞。",function(p)
    close_trigger("jqg_3")
        check_maze(function()
            keepwalk()
        end)

end)
close_trigger("jqg_1")
close_trigger("jqg_2")
close_trigger("jqg_3")



add_trigger("jqg_maze","^[> ]*(?:石壁上竟是你之前刻上的路线：|你之前刻上的路线是：)",function(p)
    if string.find(p[-1],"石壁上竟是") then
        open_trigger("jqg_maze_1") --进
    else
        open_trigger("jqg_maze_2")
    end
end)
add_trigger("jqg_maze_1","^[> ]*(?:前|后|左|右)",function(p)
    close_trigger("jqg_maze_1")
    local t={}
    for k in string.gmatch(p[-1],"(%S+) ") do
        if k=="前" then
            table.insert(t,"move qian")
        elseif k=="后" then
            table.insert(t,"move hou")
        elseif k=="左" then
            table.insert(t,"move zuo")
        elseif k=="右" then
            table.insert(t,"move you")
        end
    end
    var.jqg_path_in = table.concat(t,";")
    print("jqg in"..var.jqg_path_in)
end)

add_trigger("jqg_maze_2","^[> ]*(?:前|后|左|右)",function(p)
    close_trigger("jqg_maze_2")

    local t={}
    for k in string.gmatch(p[-1],"(%S+) ") do
        if k=="前" then
            table.insert(t,"move qian")
        elseif k=="后" then
            table.insert(t,"move hou")
        elseif k=="左" then
            table.insert(t,"move zuo")
        elseif k=="右" then
            table.insert(t,"move you")
        end
    end
    var.jqg_path_out = table.concat(t,";")
    print("jqg out"..var.jqg_path_out)
end)

close_trigger("jqg_maze_1")
close_trigger("jqg_maze_2")

function leave_jqg()

    add_trigger("alias_1","^[> ]*\\{1,2}正在【穿越绝情谷】",function(p)

        local check_line = ""
        for k,v in pairs(line) do
            if string.find(v,"你仔细记下了山洞中的第") then --新人？

                leave_jqg_new()
                return
            elseif string.find(v,"你一时不查，一头撞在了石壁上，立刻把你撞了个七荤八素。") then

                leave_jqg_new()
                return
            elseif string.find(v,"黑灯瞎火的，你也不敢走得太快，上次头上撞的瘀青还没有消下去。") then
                leave_jqg_new()
                return
            elseif string.find(v,"你莫名其妙退回了原地。") then
                return

            elseif string.find(v,"你向.*方.*离") then

                check_line = v
                break
            elseif string.find(v,"你终于走出了这段黑暗的山洞。") then
                return

            end
        end
        if string.find(check_line,"你向.*方.*离") then

            var.jqg_fangxiang = var.jqg_fangxiang or ""

            local fx = string.match(check_line,"你向(.*)方迅速离去。")
            if fx=="左" then
            var.jqg_fangxiang = var.jqg_fangxiang..";move zuo"
            elseif fx=="右" then
            var.jqg_fangxiang = var.jqg_fangxiang..";move you"
            elseif fx=="前" then
            var.jqg_fangxiang = var.jqg_fangxiang..";move qian"
            elseif fx=="后" then
            var.jqg_fangxiang = var.jqg_fangxiang..";move hou"
            end

            var.jqg_fangxiang=string.match(var.jqg_fangxiang,"^;(.+)") or var.jqg_fangxiang

            local fx_next = var.jqg_fx or "move zuo"

            if var.jqg_fx == "move zuo" then
                fx_next = "move you"
            elseif var.jqg_fx == "move you" then
                fx_next = "move qian"
            elseif var.jqg_fx == "move qian" then
                fx_next = "move hou"
            elseif var.jqg_fx == "move hou" then
                fx_next = "move zuo"
            end
            var.jqg_fx = fx_next

            exe(fx_next..";pro 你正在【穿越绝情谷】")

        end

    end)

    add_trigger("alias_2","^[> ]*你莫名其妙退回了原地。",function(p)
            var.jqg_fangxiang = var.jqg_fangxiang or ""
            var.jqg_fx = var.jqg_fx or "move zuo"
            local fx_next

            if var.jqg_fx == "move zuo" then
                fx_next = "move you"
            elseif var.jqg_fx == "move you" then
                fx_next = "move qian"
            elseif var.jqg_fx == "move qian" then
                fx_next = "move hou"
            elseif var.jqg_fx == "move hou" then
                fx_next = "move zuo"
            end

            var.jqg_fx = fx_next
            fx_next = var.jqg_fangxiang ..";".. fx_next..";pro 你正在【穿越绝情谷】"
            fx_next = string.match(fx_next,"^;(.+)") or fx_next
            wait1(8,function()
                exe(fx_next)
            end)

    end)
    add_trigger("alias_3","^[> ]*你终于走出了这段黑暗的山洞。",function(p)
        del_trigger("alias_1")
        del_trigger("alias_2")
        del_trigger("alias_3")
        del_timer("timer")

        local check_line = ""
        for k,v in pairs(line) do
            if string.find(v,"你向(.*)方迅速离去。") then
                check_line = v
                break
            end
        end
        local fx = string.match(check_line,"你向(.*)方迅速离去。") or ""
            var.jqg_fangxiang = var.jqg_fangxiang or ""
            if fx=="左" then
            var.jqg_fangxiang = var.jqg_fangxiang..";move zuo"
            elseif fx=="右" then
            var.jqg_fangxiang = var.jqg_fangxiang..";move you"
            elseif fx=="前" then
            var.jqg_fangxiang = var.jqg_fangxiang..";move qian"
            elseif fx=="后" then
            var.jqg_fangxiang = var.jqg_fangxiang..";move hou"
            end
    --      print(fx)
            print(var.jqg_fangxiang)
        local t={}

        for k in string.gmatch(var.jqg_fangxiang..";","(.+);") do
            table.insert(t,1,k)
        end
        local a=table.concat(t,";")
    --  print("f"..a)

        check_maze(function()
            keepwalk()
        end)

    end)

        var.jqg_fangxiang = ""
        exe("move zuo;pro 你正在【穿越绝情谷】")

end

function leave_jqg_new()

    set_timer("timer",2,function()
            var.jqg_fx = var.jqg_fx or "move zuo"
            local fx_next =""
            if var.jqg_fx == "move zuo" then
                fx_next = "move you"
            elseif var.jqg_fx == "move you" then
                fx_next = "move qian"
            elseif var.jqg_fx == "move qian" then
                fx_next = "move hou"
            elseif var.jqg_fx == "move hou" then
                fx_next = "move zuo"
            end
            var.jqg_fx=fx_next
            exe(fx_next)
    end)
end

--神龙岛

add_alias("cross_sld_light",function() --look light
    check_maze(function()
        add_trigger("maze_sld_1","^[> ]*\\S{1,2}正在【神龙岛看灯光】",function()
            if var.sld_light then
                del_timer("timer")
                del_trigger("maze_sld_1")
                del_trigger("maze_sld_2")
                exe("push light")
                keepwalk()
            end
        end)
        add_trigger("maze_sld_2","^[> ]*你仔细看了一下照明灯，发现手握的地方非常光滑。",function()
            var.sld_light = true
        end)
        set_timer("timer",1,function()
            exe("do 2 look light;pro 你正在【神龙岛看灯光】")
        end)
    end)
end)

add_alias("crosssldzl",function(p) --sld 竹林

    add_alias("keepmigong",function() exe("crosssldzl") end) --继续迷宫的alias

    check_maze(function()
        var.migong = 1
        add_trigger("maze_sld_1","^[> ]*\\S{1,2}正在【穿越神龙岛竹林】",function()
            check_maze_full(function()
            --  if var.roomexit and string.find(var.roomexit,"westup") then
                if var.roomexit and have_fangxiang(var.roomexit,"westup") then
                    del_trigger("maze_sld_1")
                    var.migong = 0
                    exe("wu")
                    keepwalk()
                else
                    wa(0.5,function()
                        exe("w;pro 你正在【穿越神龙岛竹林】")
                    end)
                end
            end)
        end)
    --  exe("w;w;w;w;pro 你正在【穿越神龙岛竹林】")
        exe("w;pro 你正在【穿越神龙岛竹林】")
    end)

end)

add_alias("crosssldzlb",function(p) --sld 竹林

    add_alias("keepmigong",function() exe("crosssldzlb") end) --继续迷宫的alias

    check_maze(function()
        var.migong=1
        add_trigger("maze_sld_1","^[> ]*\\S{1,2}正在【穿越神龙岛竹林】并不是一个",function()

            check_maze(function()
                if var.roomexit and have_fangxiang(var.roomexit,"eastdown") then
                    del_trigger("maze_sld_1")
                    var.migong=0
                    map_follow_maze()
                    keepwalk()
                else
                    exe("e;pro 你正在【穿越神龙岛竹林】")
                end
            end)
        end)
--      exe("ed;e;e;e;e;pro 你正在【穿越神龙岛竹林】")
        exe("ed;pro 你正在【穿越神龙岛竹林】")
    end)

end)
add_alias("cross_sld_sl",function(p) --sld 树林

    add_alias("keepmigong",function() exe("cross_sld_sl") end) --继续迷宫的alias

    check_maze(function()
        var.migong = 1
        add_trigger("maze_sld_1","^[> ]*\\S{1,2}正在【穿越神龙岛树林】",function()

            check_maze(function()
                if var.roomname and var.roomname == "海滩" then
                    del_trigger("maze_sld_1")
                    var.migong=0
                    map_follow_maze()
                    keepwalk()
                elseif  var.roomname and var.roomname == "树林" then
                    local r = math.random(10)
                    if r == 2 then
                        exe("n")
                    elseif r == 3 then
                        exe("s")
                    else
                        exe("w")
                    end
                    exe("pro 你正在【穿越神龙岛树林】")
                else
                    del_trigger("maze_sld_1")
                    var.migong=0
                    map_follow_maze()
                    exe("gps")
                end
            end)
        end)
        exe("w;pro 你正在【穿越神龙岛树林】")
    end)

end)


add_alias("cross_che_sld_boat",function()  --神龙岛 借用 thd

    check_maze(function()
        local party = var.party or "普通百姓"
        if party == "神龙岛" then
            send("find boat")
            keepwalk()
        else
            add_trigger("maze_thd_1","^[> ]*你(?:朝船夫挥了挥手便跨上岸去。|沿着踏板走了上去。)",function()
                var["idle"] = 0
            --  var.migong = 0
                del_trigger("maze_thd_1")
                keepwalk()
            end)
        --  var.migong = 1
            exe("do_walk_enter_boat")
        end
    end)

end)

--回部

add_alias("cross_kill_wolf",function()  --回部

    check_maze_full(function()
    --  var.migong=1
        wa(2,function()
            add_trigger("maze_temp","^[> ]*\\S{1,2}正在查看【回部狼好多】并不是一个",function()
                exe("crush wolf")
            end)
            exe("look;pro 你正在查看【回部狼好多】")
        end)
    end)

end)
--
--cross_neili_west
--
--你走到石头前，左右旋了一番。
--你只听一声轰响，巨石被掀起少许。
--古墓
add_alias("cross_neili_west",function() -- banstone west

        check_maze(function()

            do_dazuo_path(function()

                    exe("ban stone;w")
                    keepwalk()

            end)
        end)

end)

add_alias("cross_neili_south",function() -- banstone west

        check_maze(function()

            do_dazuo_path(function()

                    exe("ban stone;s")
                    keepwalk()

            end)
        end)

end)

add_alias("cross_neili_push_stone",function() -- banstone west wl

        check_maze(function()

            do_dazuo_path(function()
                    exe("push stone;s")
                    keepwalk()

            end)
        end)

end)

add_alias("cross_neili_break_south",function() -- banstone west

        check_maze(function()

            do_dazuo_path(function()

                    exe("break men;s")
                    keepwalk()

            end)
        end)

end)

add_alias("cross_neili_down",function() -- banstone west

        check_maze(function()

            do_dazuo_path(function()

                    exe("ban shan;d")
                    keepwalk()

            end)
        end)

end)
--*******************
-- 桃花岛桃林
--*******************

--
--  2 --1
--       \
--        0
--  2以后cross_thd_taolin
add_alias("cross_thd_taolin",function(p) --桃花岛桃林

    add_alias("keepmigong",function() exe("cross_thd_taolin") end) --继续迷宫的alias

    leave_taolin(keepwalk)
end)

function leave_taolin(action)



    var.migong=1
    check_maze_full(function()

        add_trigger("maze_thd_1","^[> ]*你查看【是否可以走出桃林】并不是一个北侠的职业，目前没有相关的信息。",function()
            del_timer("input")
            check_maze(function()
                    if var.roomname and var.roomname=="桃林" and not string.find(var.roomexit,"east") then --出来了吧
                        del_trigger("maze_thd_1")
                        del_trigger("maze_thd_2")
                        var.migong=0
                        map_follow_maze()
                        action()
                    elseif var.roomname and var.roomname~="桃林" then --出来了吧
                        del_trigger("maze_thd_1")
                        del_trigger("maze_thd_2")
                        var.migong=0
                        exe("gps")
                    else
                        if var.danxiang_dir==nil then
                            local r = math.random(4)
                            local dir = {"east","west","south","north",}
                            local to = dir[r]
                            var.danxiang_dir = nil --提示方向清空
                            exe(to..";pro 你查看【是否可以走出桃林】",5)
                        else
                            local dir
                            if var.danxiang_dir =="东" then
                                dir = "e"
                            elseif var.danxiang_dir =="南" then
                                dir = "s"
                            elseif var.danxiang_dir =="西" then
                                dir = "w"
                            elseif var.danxiang_dir =="北" then
                                dir = "n"
                            end
                            var.danxiang_dir = nil

                            local r = math.random(10)
                            if r>0 then
                                exe(dir..";e;pro 你查看【是否可以走出桃林】",5)
                            else                                               --可能出来不是east，我也不确认，给予其他出来可能吧
                                local r = math.random(3)
                                if r==1 then
                                    exe(dir..";w;pro 你查看【是否可以走出桃林】",5)
                                elseif r==2 then
                                    exe(dir..";s;pro 你查看【是否可以走出桃林】",5)
                                else
                                    exe(dir..";n;pro 你查看【是否可以走出桃林】",5)
                                end
                            end
                        end
                    end
            end)
        end)
        add_trigger("maze_thd_2","^[> ]*你累的精疲力尽但始终无法走出这片桃林，(.*)面看起来好像是回去的路。",function(p)
            var.danxiang_dir = p[1]
        end)

        if var.roomname and var.roomname=="桃林" and not string.find(var.roomexit,"east") then --出来了吧
            del_trigger("maze_thd_1")
            del_trigger("maze_thd_2")
            var.migong=0
            map_follow_maze()
            action()
        elseif var.roomname and var.roomname~="桃林" then --出来了吧
            del_trigger("maze_thd_1")
            del_trigger("maze_thd_2")
            var.migong=0
            exe("gps")
        else
            local r = math.random(4)
            local dir = {"east","west","south","north",}
            local to = dir[r]

            var.danxiang_dir = nil --提示方向清空

            exe(to..";pro 你查看【是否可以走出桃林】",5)

        end

    end)
end

add_alias("cross_busy_south",function()
    check_maze(function()

        check_busy(function()
            exe("s")
            keepwalk()
        end)

    end)
end)
add_alias("cross_busy_north",function()
    check_maze(function()

        check_busy(function()
            exe("north")
            keepwalk()
        end)

    end)
end)
add_alias("cross_busy_wu",function()
    check_maze(function()

        check_busy(function()
            exe("westup")
            keepwalk()
        end)

    end)
end)
add_alias("cross_busy_ed",function()
    check_maze(function()

        check_busy(function()
            exe("eastdown")
            keepwalk()
        end)

    end)
end)
add_alias("cross_busy_answer_songxin",function()
    add_trigger("maze_mg_songxin","^[> ]*营门守将说道：「既是大汗的使者，请进请进。」",function()
        del_timer("wait")
        del_trigger("maze_mg_songxin")
        keepwalk()

    end)
    check_maze(function()
        exe("answer 送信")
        wa(2,function()
            del_trigger("maze_mg_songxin")
                keepwalk()

        end)
    end)
end)

--狱卒嘿嘿地笑着：今儿个你可落在我手里了...！
--玄痛喝道：杖责三百，将你打入僧监拘押三月，非洗心悔改，不得释放！意图越狱者罪加一等！
--你慢慢睁开眼睛，清醒了过来。
add_alias("cross_sl_wuxingdong",function()
    leave_wxd(keepwalk)

end)
function leave_wxd(action)
    var.migong = 1
    check_maze_full(function()
        add_trigger("maze_sl_wxd","^[> ]*你查看【五行洞是不是红色的】并不是一个北侠的职业，目前没有相关的信息。",function(p)
            check_maze(function()
                if var.roomname and var.roomname~="五行洞" then
                    del_trigger("maze_sl_wxd")
                    del_trigger("maze_sl_wxd_2")
                    exe("gps")
                elseif var.wuxingdong_hongse then
                        del_trigger("maze_sl_wxd")
                        del_trigger("maze_sl_wxd_2")
                        var.migong=0
                        map_follow_maze()
                        action()
                else
                    exe("s;pro 你查看【五行洞是不是红色的】")
                end
            end)

        end)
        add_trigger("maze_sl_wxd_2","^[> ]*五行洞 -",function(p)
            local ansi = from_server_line_raw
            print("颜色："..from_server_line_raw)
            if string.find(ansi,"1;31m五行洞") then --红色
                var.wuxingdong_hongse = true
            else
                var.wuxingdong_hongse = false
            end
        end)
        exe("s;pro 你查看【五行洞是不是红色的】")
    end)
end
--[[
add_alias("cross_gb_zhanglao",function(p) --sld 竹林

    check_maze(function()
        var.migong=1
        add_trigger("maze_sld_1","^[> ]*设定环境变量：action.*穿越神龙岛竹林",function()
            check_maze(function()
                del_trigger("maze_sld_1")
                var.migong=0
                map_follow_maze()
                keepwalk()
            end)
        end)
        exe("w;w;w;w;wu;set action 穿越神龙岛竹林...")
    end)

end)
]]
--********************--
--     襄阳黑风寨     --
--********************--

function leave_shanzhai(where,action)

    var.migong = 1
    add_trigger("maze_temp","你正在【进入山寨为(\\S+)】并不是一个北侠的职业，目前没有相关的信息。",function(p)
        del_timer("input")
        check_maze_full(function()
            if var.roomname and var.roomname~="山路" and var.roomname~="乱葬岗" and var.roomname~="黑松岭" then --走错了?
                print("shanzhai 1")
                del_trigger("maze_temp")
                del_trigger("maze_temp_2")
                var.migong = 0
                exe("gps")
            else
                if var.roomname=="山路" then
                    print("shanzhai 2")
                    exe("ed;eu;pro 你正在【进入山寨为"..p[1].."】",5)
                elseif var.roomname=="黑松寨山门" then
                    print("shanzhai 3")
                    if p[1] == "大门" then
                        var.migong = 0
                        map_follow_maze()
                        action()
                    else
                        exe("ed;eu;pro 你正在【进入山寨为"..p[1].."】",5)
                    end
                elseif var.roomname=="乱葬岗" then
                    print("shanzhai 4")
                    if p[1] == "红色" and var.shanzai_color == "红色" then
                        del_trigger("maze_temp")
                        del_trigger("maze_temp_2")
                        var.migong = 0
                        map_follow_maze()
                        action()
                    elseif p[1] == "青色" and var.shanzai_color == "青色" then
                        del_trigger("maze_temp")
                        del_trigger("maze_temp_2")
                        var.migong = 0
                        map_follow_maze()
                        action()
            --      elseif p[1] == "大门" then
                    else
                        exe("wd;wd;ed;eu;pro 你正在【进入山寨为"..p[1].."】",5)
            --      else
                    end
                else
                    del_trigger("maze_temp")
                    del_trigger("maze_temp_2")
                    var.migong = 0
                    exe("gps")
                end

            end
        end)
    end)
    add_trigger("maze_temp_2","^[> ]*乱葬岗 -",function(p)
            local ansi = from_server_line_raw
            print("颜色："..from_server_line_raw)
            if string.find(ansi,"1;36m乱葬岗") then --青色
                var.shanzai_color = "青色"
            elseif string.find(ansi,"1;35m乱葬岗") then --青色
                var.shanzai_color = "红色"
            end
    end)


    check_maze(function()
        if where then
            var.shanzai_color = "无"
            if where == "红色" then
                exe("eu;pro 你正在【进入山寨为红色】",5)
            elseif where == "青色" then
                exe("eu;pro 你正在【进入山寨为青色】",5)
            elseif where == "大门" then
                exe("eu;pro 你正在【进入山寨为大门】",5)
            end
        end
    end)
end

add_alias("cross_shanzhai_hong",function()
    add_alias("keepmigong",function() exe("cross_shanzhai_hong") end) --继续迷宫的alias
    leave_shanzhai("红色",keepwalk)
end)
add_alias("cross_shanzhai_qing",function()
    add_alias("keepmigong",function() exe("cross_shanzhai_qing") end) --继续迷宫的alias
    leave_shanzhai("青色",keepwalk)
end)
add_alias("cross_shanzhai_damen",function()
    add_alias("keepmigong",function() exe("cross_shanzhai_damen") end) --继续迷宫的alias
    leave_shanzhai("大门",keepwalk)
end)

--********************--
--     壮族老林       --
--********************--

    --壮族
  -- 5447 5462 临安府 老林尽头
  --6800
add_alias("laolin",function()  --手动输入laolin
    add_alias("keepmigong",function() exe("laolin") end) --继续迷宫的alias
    laolin_in()
end)
add_alias("laolinout",function() -- 手动laolin out
    add_alias("keepmigong",function() exe("laolinout") end) --继续迷宫的alias
    laolin_out()
end)

add_alias("cross_che_lafll",function() -- 临安府laf --> 老林ll --虽然只是enter 还是加一个alias，防止错入？
    add_alias("keepmigong",function() exe("cross_che_lafll") end) --继续迷宫的alias
    check_maze(function()
        exe("enter")
        keepwalk()
    end)
end)

add_alias("cross_che_lafzz",function() -- 临安府laf --> 壮族zz
    add_alias("keepmigong",function() exe("cross_che_lafzz") end) --继续迷宫的alias
    laolin_in(keepwalk)
end)
add_alias("cross_che_zzlaf",function() -- 壮族zz --> 临安府laf
    add_alias("keepmigong",function() exe("cross_che_zzlaf") end) --继续迷宫的alias
    laolin_out(keepwalk)
end)

function laolin_in(action)
    var.migong = 1
    add_trigger("laolin_1","^[> ]*你查看【老林路径】并不是一个北侠的职业，目前没有相关的信息。",function()
        del_timer("input")
        check_maze_full(function()
            if var.roomname and var.roomname=="老林" then
                if not var.danxiang_dir then
                    exe("nu;pro 你查看【老林路径】")
                elseif var.danxiang_dir == "out" then
                    del_trigger("laolin_1")
                    del_trigger("laolin_2")
                    del_trigger("laolin_3")
                    del_trigger("laolin_4")
                    exe("out;say 进来了")
                        var.migong = 0
                        map_follow_maze()
                    if type(action)=="function" then
                        action()
                    else
                        exe("changejob")
                    end
                else
                    exe("@danxiang_dir;pro 你查看【老林路径】",5)
                end
            else
                    del_trigger("laolin_1")
                    del_trigger("laolin_2")
                    del_trigger("laolin_3")
                    del_trigger("laolin_4")
                    exe("gps")

            end
        end)
    end)
    add_trigger("laolin_2","^[> ]*你发现前面似乎有人迹，加快了脚步赶过去，却什么也没有发现。",function()
        if not var.danxiang_dir then
            var.danxiang_dir = "nu"
        end
        if var.danxiang_dir == "nu" then
            var.danxiang_dir = "nd"
        elseif var.danxiang_dir == "nd" then
            var.danxiang_dir = "n"
        elseif var.danxiang_dir == "n" then
            var.danxiang_dir = "nd"
        else
            var.danxiang_dir = "nu"
        end
    end)
    add_trigger("laolin_3","^[> ]*你像无头苍蝇一样在老林子里打转，根本不知道该往哪去！",function()
        local r = math.random(3)
        if r==1 then
            var.danxiang_dir = "nu"
        elseif r==2 then
            var.danxiang_dir = "su"
        else
            var.danxiang_dir = "s"
        end
    end)
    add_trigger("laolin_4","^[> ]*在你筋疲力尽之际，终于找到了出路",function()
        var.danxiang_dir = "out"
    end)

    var.danxiang_dir = "nu" --单向迷宫清除
    exe("nu;pro 你查看【老林路径】",5)
end
--> 你像无头苍蝇一样在老林子里打转，根本不知道该往哪去！
--你查看【老林路径】并不是一个北侠的职业，目前没有相关的信息。
--你发现前面似乎有人迹，加快了脚步赶过去，却什么也没有发现。
--在你筋疲力尽之际，终于找到了出路(out)。
function laolin_out(action)
    var.migong = 1
    add_trigger("laolin_1","^[> ]*你查看【老林路径】并不是一个北侠的职业，目前没有相关的信息。",function()
        del_timer("input")
        check_maze_full(function()
            if var.roomname and var.roomname=="老林" then
                if not var.danxiang_dir then
                    exe("eu;pro 你查看【老林路径】")
                elseif var.danxiang_dir == "out" then
                    del_trigger("laolin_1")
                    del_trigger("laolin_2")
                    del_trigger("laolin_3")
                    del_trigger("laolin_4")
                    exe("out;say 进来了")
                        var.migong = 0
                        map_follow_maze()
                    if type(action)=="function" then
                        action()
                    else
                        exe("changejob")
                    end
                else
                    exe("@danxiang_dir;pro 你查看【老林路径】",5)
                end
            else
                    del_trigger("laolin_1")
                    del_trigger("laolin_2")
                    del_trigger("laolin_3")
                    del_trigger("laolin_4")
                    exe("gps")
            end
        end)
    end)
    add_trigger("laolin_2","^[> ]*你发现前面似乎有人迹，加快了脚步赶过去，却什么也没有发现。",function()
        if not var.danxiang_dir then
            var.danxiang_dir = "eu"
        end
        if var.danxiang_dir == "eu" then
            var.danxiang_dir = "ed"
        elseif var.danxiang_dir == "ed" then
            var.danxiang_dir = "e"
        elseif var.danxiang_dir == "e" then
            var.danxiang_dir = "eu"
        else
            var.danxiang_dir = "eu"
        end
    end)
    add_trigger("laolin_3","^[> ]*你像无头苍蝇一样在老林子里打转，根本不知道该往哪去！",function()
        local r = math.random(3)
        if r==1 then
            var.danxiang_dir = "eu"
        elseif r==2 then
            var.danxiang_dir = "su"
        else
            var.danxiang_dir = "s"
        end
    end)
    add_trigger("laolin_4","^[> ]*在你筋疲力尽之际，终于找到了出路",function()
        var.danxiang_dir = "out"
    end)

    var.danxiang_dir = "eu" --单向迷宫清除
    exe("eu;pro 你查看【老林路径】",5)

end

--*******************
--无量山迷魂阵
--*******************
add_alias("cross_wl_mmz",function()

    add_alias("keepmigong",function() exe("cross_wl_mmz") end) --继续迷宫的alias

    var.migong = 1
    add_trigger("maze_wls","^[> ]*你尝试【离开无量山迷魂阵】并不是一个北侠的职业，目前没有相关的信息。",function()
        del_timer("input")
        check_maze_full(function()
            if not var.roomname or (var.roomname~="迷魂阵" and var.roomname~="羊肠小路") then
            --  print("1-->gps"..var.roomname)
                del_trigger("maze_wls")
                exe("gps")
            else
                if var.roomname=="羊肠小路" then
                --  print("2 -- keepwalk")
                    del_trigger("maze_wls")
                    var.migong = 0
                    map_follow_maze()
                    keepwalk()

                elseif var.roomname=="迷魂阵" then
                --  print("3 -- migong")
                    exe("e;pro 你尝试【离开无量山迷魂阵】",5)
                end
            end
        end)
    end)
    exe("pro 你尝试【离开无量山迷魂阵】",5)
end)

--*******************
--提督府花园
--*******************
--cross_tdf_huayuan
--    杭州提督府的花园，种着五颜六色的鲜花，香味扑鼻，另人陶醉。你一走进来，
--感觉失去了方向。心里有种不祥的预感。这里的花丛（huacong）比别的地方都
--茂盛。
--    杭州提督府的花园，种着五颜六色的鲜花，香味扑鼻，另人陶醉。你一走进来，
--感觉失去了方向。心里有种不祥的预感。这里看起来似乎和其他地方不太一样，
--有一股让人觉得很危险的气息。
--这里的花丛远比别的地方茂密，不知道是否可以拨(bo)开看看。
--你用手拨开了花从，竟然发现有一条很小的路。

add_alias("cross_tdf_huayuan",function()
    add_alias("keepmigong",function() exe("cross_tdf_huayuan") end) --继续迷宫的alias
    leave_huayuan(keepwalk,0) --尝试2次
end)

function leave_huayuan(action,times)
    var.migong = 1
    if times==nil then var.tidufu_cishu = 0 end
    if type(times)=="number" then var.tidufu_cishu = times end

        add_trigger("maze_tdf_1","^[> ]*你尝试【观察提督府花园",function() --看
            del_timer("input")
            check_maze_full(function()
                if string.find(var.roomdesc,"有一股让人觉得很危险的气息。") then --方向危险
                    local dir = {"east","south","north","west"}
                    local t = {}
                    for k,v in pairs(dir) do
                        if v~=var.tidufu_look_fangxiang then
                            table.insert(t,v)
                        end
                    end

                    local r=math.random(#t)
                    var.tidufu_look_fangxiang = t[r]
                    var.roomdesc = ""
                    exe("look @tidufu_look_fangxiang;pro 你尝试【观察提督府花园@tidufu_look_fangxiang】",5)

                elseif string.find(var.roomdesc,"这里的花丛") then --出口
                    var.tidufu_huayaun = var.tidufu_huayaun or 0
                    var.tidufu_huayaun = var.tidufu_huayaun + 1
                    if var.tidufu_huayaun>var.tidufu_cishu then --出去
                        check_busy(function()
                            exe("@tidufu_look_fangxiang;pro 你尝试【离开提督府花园@tidufu_look_fangxiang】",5)
                        end)
                    else
                        check_busy(function()
                            exe("@tidufu_look_fangxiang;pro 你尝试【漫步提督府花园@tidufu_look_fangxiang】",5)
                        end)

                    end
                elseif string.find(var.roomdesc,"心里有种不祥的预感") then --其他房间
                        check_busy(function()
                            exe("@tidufu_look_fangxiang;pro 你尝试【漫步提督府花园@tidufu_look_fangxiang】",5)
                        end)

                elseif not  string.find(var.roomdesc,"心里有种不祥的预感") and var.roomname and var.roomname=="花园" then --描述不对有雾么
                    wa(10,function() --等10秒再看？
                        var.roomdesc = ""
                        exe("look @tidufu_look_fangxiang;pro 你尝试【观察提督府花园@tidufu_look_fangxiang】",5)
                    end)
                elseif var.roomname and var.roomname~="花园" then --不在花园中？
                    exe("gps")
                end
            end)
        end)

    add_trigger("maze_tdf_2","^[> ]*你尝试【漫步提督府花园",function() --看好了走
        del_timer("input")
        check_maze_full(function()
            local r = math.random(4)
            local dir = {"east","south","north","west"}
            var.tidufu_look_fangxiang = dir[r]
            exe("look @tidufu_look_fangxiang;pro 你尝试【观察提督府花园@tidufu_look_fangxiang】",5) --继续看 ...
        end)
    end)
    add_trigger("maze_tdf_3","^[> ]*你尝试【离开提督府花园",function() --离开吧
        del_timer("input")
        check_maze_full(function()
            del_trigger("maze_tdf_1")
            del_trigger("maze_tdf_2")
            del_trigger("maze_tdf_3")
            var.migong = 0
            map_follow_maze()
            check_busy(function()
                action()
            end)
        end)
    end)
--  --李可秀盯着你仔细看看说道：抓错了，不是红花会的，打一顿扔出去！
    check_maze(function()
        var.tidufu_huayaun = 0  --尝试次数
        local r = math.random(4)
        local dir = {"east","south","north","west"}
        var.tidufu_look_fangxiang = dir[r]
        var.roomdesc = ""
        exe("look @tidufu_look_fangxiang;pro 你尝试【观察提督府花园@tidufu_look_fangxiang】",5)
    end)
end
--**********--
--  黑木崖
--**********--
add_alias("cross_che_ry",function()  --黑木崖zhulou

    check_maze(function()
        add_trigger("maze_riyue_1","^[> ]*你定了定神，走了出来。",function()
            var["idle"] = 0
            del_trigger("maze_riyue_1")
            del_trigger("maze_riyue_2")
            del_trigger("maze_riyue_3")
            keepwalk()
        end)
        add_trigger("maze_riyue_2","^[> ]*你身上背的东西太多，竹篓负担不下。",function()
            exe("drop silver;enter zhu lou")
        end)
        add_trigger("maze_riyue_3","^[> ]*竹篓里已经有人了.*不下你。",function()
            wa(5,function()
                exe("enter zhu lou")
            end)
        end)
        exe("drop coin;enter zhu lou")
    end)
end)

--梅庄

add_alias("cross_che_mz_out",function() --梅庄出来 本来就是一个open gate s，我改成难走的,小心身上别自己带四宝!!!
    check_maze(function()
        exe("give guangling san to sibao;give ouxue pu to sibao;give xishan tu to sibao;give shuaiyi tie to sibao")
        check_busy(function()
        exe("give guangling san to sibao;give ouxue pu to sibao;give xishan tu to sibao;give shuaiyi tie to sibao")
            check_busy(function()
                exe("give guangling san to sibao;give ouxue pu to sibao;give xishan tu to sibao;give shuaiyi tie to sibao")
                check_busy(function()
                    exe("open gate;south")
                    keepwalk()
                end)
            end)
        end)
    end)
end)

add_alias("cross_che_mz_in",function() --梅庄进去，比较麻烦吧
    check_maze(function()
        --四宝(sibao)告诉你：马上到，这是一条自动回复
        --四宝(sibao)告诉你：请稍后，这是一条自动回复
        --四宝(sibao)告诉你：送书完成，这是一条自动回复
        --四宝(sibao)告诉你：没书了，这是一条自动回复
        add_trigger("maze_meizhuang_1","^[> ]*无法联系到【sibao】",function()
            var.map_meizhuang_sibao = nil  --梅庄四宝大米检查
            del_timer("input")
            del_trigger("maze_meizhuang_1")
            del_trigger("maze_meizhuang_2")
            del_trigger("maze_meizhuang_3")
            del_trigger("maze_meizhuang_4")
            exe("changejob")
        end)
        add_trigger("maze_meizhuang_2","^[> ]*四宝\\(sibao\\)告诉你：没书了",function()
            var.map_meizhuang_sibao = nil  --梅庄四宝大米检查
            del_timer("input")
            del_trigger("maze_meizhuang_1")
            del_trigger("maze_meizhuang_2")
            del_trigger("maze_meizhuang_3")
            del_trigger("maze_meizhuang_4")
            exe("changejob")
        end)
        add_trigger("maze_meizhuang_3","^[> ]*四宝\\(sibao\\)告诉你：送书完成",function()
            var.meizhuang_sibao_return = nil
            exe("knock gate 4;knock gate 2;knock gate 5;knock gate 3;drop ouxue pu;drop xishan tu;drop shuaiyi tie;give guangling san to sibao;pro 归还【guangling san】给sibao",60)

        end)

        add_trigger("maze_meizhuang_4","^[> ]*归还【(.*)】给sibao",function(p)
            del_timer("input")
            if var.meizhuang_sibao_return then
                if p[1]=="guangling san" then
                    var.meizhuang_sibao_return = nil
                    check_busy(function()
                    --  exe("give ouxue pu to sibao;pro 归还【ouxue pu】给sibao")
                        var.meizhuang_sibao_return = nil
                        del_trigger("maze_meizhuang_1")
                        del_trigger("maze_meizhuang_2")
                        del_trigger("maze_meizhuang_3")
                        del_trigger("maze_meizhuang_4")
                        del_trigger("maze_meizhuang_5")
                        keepwalk()
                    --新的只给一本
                    end)
                elseif p[1]=="ouxue pu" then
                    var.meizhuang_sibao_return = nil
                    check_busy(function()
                        exe("give xishan tu to sibao;pro 归还【xishan tu】给sibao")
                    end)
                elseif p[1]=="xishan tu" then
                    var.meizhuang_sibao_return = nil
                    check_busy(function()
                        exe("give shuaiyi tie to sibao;pro 归还【shuaiyi tie】给sibao")
                    end)
                elseif p[1]=="shuaiyi tie" then
                    var.meizhuang_sibao_return = nil
                    del_trigger("maze_meizhuang_1")
                    del_trigger("maze_meizhuang_2")
                    del_trigger("maze_meizhuang_3")
                    del_trigger("maze_meizhuang_4")
                    del_trigger("maze_meizhuang_5")
                    keepwalk()
                end
            else
                check_busy(function()
                    exe("give "..p[1].." to sibao;pro 归还【"..p[1].."】给sibao")
                end)
            end
        end)
        add_trigger("maze_meizhuang_5","^[> ]*你给四宝一本《",function()
            var.meizhuang_sibao_return = true
        end)

        exe("tell sibao 送书服务")
        alarm("input",60,function()
            exe("pro 无法联系到【sibao】")
        end)
    end)
end)

add_alias("cross_emei_fenghuangtai_in",function() --峨眉凤凰台in
    if var.do_stop and var.do_stop == 0 then
        var.migong = 1
        add_trigger("maze_emei_fenghuangtai_1","^[> ]*白猿想让你推（tui）这块石头。",function()
            del_trigger("maze_emei_fenghuangtai_1")
            del_trigger("maze_emei_fenghuangtai_2")
            var.migong = 0
            keepwalk()
        end)
        add_trigger("maze_emei_fenghuangtai_2","^[> ]*(你推了半天，但石块一动不动。|哪有你要推的东西啊？)",function()
            del_trigger("maze_emei_fenghuangtai_1")
            del_trigger("maze_emei_fenghuangtai_2")
            keepwalk()
        end)
        exe("ask baiyuan about 帮助;ask baiyuan 2 about 帮助;tui stone")
    end
end)

add_alias("cross_emei_fenghuangtai_out",function() --峨眉凤凰台out
    if var.do_stop and var.do_stop == 0 then
        add_trigger("maze_emei_fenghuangtai_3","^[> ]*你正在【离开峨嵋洞穴】",function()
            del_trigger("maze_emei_fenghuangtai_3")
            if var.migong and var.migong==1 then
                var.migong = 0
                local need_remove = 0
                if var.path_rooms then
                    local n = table.maxn(var.path_rooms)
                    for i=1,n do
                        if not var.path_rooms[i] then
                            break
                        else
                            if var.path_rooms[i]>6393 then
                                break
                            elseif var.path_rooms[i]<6389 then
                                break
                            else
                                 need_remove = need_remove + 1
                            end
                        end
                    end
                end
                while need_remove>0 do
                    var.follow_room=var.path_rooms[1]
                    table.remove(var.path_rooms,1)
                    need_remove = need_remove - 1
                end
                Print(var.path_rooms[1])
            end
            keepwalk()
        end)

        exe("out;pro 你正在【离开峨嵋洞穴】")
    end
end)

add_alias("cross_lxc_yell",function()
    add_trigger("maze_lxc_1","^[> ]* 你正在【进入凌霄城】",function()
        del_trigger("maze_lxc_1")
        add_trigger("maze_lxc_2","^[> ]*.*(吊桥已经放下来|只听得轧轧声响，吊桥缓缓放下)",function()
            del_trigger("maze_lxc_2")
            exe("n")
            keepwalk()
        end)
        exe("tell zzxc in;tell @damixs in;yell bridge")
    end)
    exe("pro 你正在【进入凌霄城】")
end)
