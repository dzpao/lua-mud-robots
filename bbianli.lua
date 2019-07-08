--bbianli.lua
--**********--
--    bbl   --
--**********--
--快速扫过,看到合适信息再折返

add_alias("bbl",function(p)
    echo("$HIG$ p = " .. p .. "$NOR$" )
--  Print("bbl")
    var.bbl_found = nil --默认未发现

    var.do_stop = 0
    check_bbl = nil
    check_npc_in_maze = function() end -- 让bbl停下来的检查函数
    function check_stop() end
    function check_npc_in_maze() end
    function check_job_stop() end

    var.bbl_black_list = {}  -- 遍历黑名单，记录一些确认过不是的npc
    var.bbl_black_port = {}  -- 遍历黑名单，记录一些没有npc的 room
    var.bbl_white_list = {}  -- 遍历白名单
    var.bbl_check_go_back_list = {} -- 遍历回头

    var.bl_stop_room = 0
    var.job_bl_npc_name = ""
    var.job_bl_npc_id = ""

    add_alias("blgo",function() -- blgo 中断以后继续走
--      Print("blgo")
        var.do_stop = 0
        var.bbl_found = nil
        var.bl_stop_room = 0
        check_bbl = nil
        check_npc_in_maze = function() end -- 让bbl停下来的检查函数
        --???

        if null(var.job_search_table) then
            del_trigger("job_bianli_area_1")
            del_trigger("job_bianli_area_2")
            Print("没有剩余房间了，无法blgo")
            Run("blreset")
            Run("blfail") --执行blfail
        else
            var.bianli,var.bianli_pass_rooms = get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称
            go(var.job_search_table[1],function() -- 去 剩余第一个房间
                var.bl_time_start = os.time()
                function after_goto()
                    del_trigger("job_bianli_area_1")
                    del_trigger("job_bianli_area_2")
                    Run("blreset")
                    Run("blfail") --执行blfail
                end

                Print("blgo 继续 bbianli")
                set_check_bbl() -- 设置一下
                bianli() --遍历
            end)
        end
    end)


    local input = p[-1]
    local city,name,range = "","",0

    if string.match(input,".*%S%s%d+") then --以数字结尾 比如 -- 扬州 张三 5
        city,name,range = string.match(input,"^(%S+) (.*) (%d+)$")
        range = tonumber(range)
    else -- 扬州 张三
        city,name = string.match(input,"^(%S+) (.*)$")
    end

    echo("$HIG$ city = " .. city .. "$NOR$" )
    echo("$HIG$ name = " .. name .. "$NOR$" )

    local check_zone_list = {}
    var.zone_list,check_zone_list = get_zonelist() -- job.lua

    if check_zone_list[city] then -- 有城市
        echo("$HIW$【遍历区域为】：$HIG$"..city.."$HIW$--$HIG$"..name)

        do_bbianli_area(city,name,range) -- 城市区域遍历
    else                          -- 没有城市
        local zone,room = break_zoneroom(city)
        if room=="" then
            if zone and zone~="" and check_zone_list[zone] then
                echo("$HIW$【遍历区域为】：$HIG$"..zone.."$HIW$--$HIG$"..name)

                do_bbianli_area(zone,name,range) -- 城市区域遍历
            else
                echo("$HIW$【遍历区域不存在】：$HIR$"..city)
                Run("blreset")
                Run("blfail")
            end
        else
            echo("$HIW$【遍历区域为】：$HIG$"..zone.."$HIW$--$HIG$"..name)
            do_bbianli_room(zone,room,range,name) --房间名称遍历 --指定扬州北大街 还是普通bl吧，懒得写了
        end
    end

end)

function do_bbianli_area(city,npc,range,quick) -- 区域遍历函数
    Print("函数 do_bbianli_area")
    check_bbl = nil
    check_npc_in_maze = function() end

    var.idle = 0 --偷懒一下
    var.job_bl_zone = city
    var.job_bl_npc_name = npc
    var.job_range = range or 0

    _,var.job_search_table,var.job_bl_zone,_ = get_room_list(city) -- 得到city的所有房间 var.job_search_table -- job.lua

    range = range or 0
    if range > 9 then range = 9 end
    if range>0 and range<10 then -- 如果有范围
    -- 范围就是 扬州城市，遍历完了再遍历 扬州周围几个格子，比如曲阜 信阳
        local job_search_table  = get_searches(var.job_search_table,range) -- 得到所有房间，注意包含了扬州的
        -- 这个范围多了可能有点卡

        local check_job_search_table = {}
        for k,v in pairs(var.job_search_table) do -- 原来扬州房间做一个check表 {[100]=true,[101]=true,}
            check_job_search_table[v] = true
        end

        local new_job_search_table = {} -- 新的table

        for k,v in pairs(job_search_table) do -- for 一下含扬州 + 周围房间table
            if not check_job_search_table[v] then -- 不在扬州范围
                table.insert(new_job_search_table,v) --加入到新的table里
            end
        end

        table.sort(new_job_search_table) --新的table排序

        for k,v in ipairs(new_job_search_table) do
            table.insert(var.job_search_table,v) -- for 一下新的table，在原来扬州table后面加入 周围range格子的房间
        end
    end


    quick = quick or nil

    if 1==0 and quick then -- 快速遍历!!! xbl -- 1==0 关闭了

        do_bianli_area_quick(city,npc,range)

    else        -- 以下一般遍历 bbl

        var.bianli,var.bianli_pass_rooms = get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称

        var.bianli = string.gsub(var.bianli,";cross_for_job;",";")
        var.bianli = string.gsub(var.bianli,"cross_for_job$","")
        var.bianli = string.gsub(var.bianli,"^cross_for_job","")

        go(var.job_search_table[1],function() -- 去 城市第一个房间
            var.bl_time_start = os.time()
            function after_goto()
                del_trigger("job_bianli_area_1")
                del_trigger("job_bianli_area_2")
                Run("blreset")
                Run("blfail") --执行blfail
            end
            --bianli() --遍历
            set_check_bbl() -- 设置一下bbl_check
            bbianli()
        end)
    end
end


function set_check_bbl(action)  -- 设置每一步，检查是否需要bbl
    Print("函数set_check_bbl")

        add_trigger("job_bianli_area_1","^[> ]*(.*)\\(([\\w\\' ]+)\\)(.*)",function(p)
            local id = string.lower(p[2])
            var.bbl_black_list = var.bbl_black_list or {}
            if not var.bbl_black_list[id] and (string.find(p[3]..p[1],var.job_bl_npc_name) or string.find(id,var.job_bl_npc_name)) then --名字或姓名含有
                if var.follow_room and var.roomname and not string.match("|马车|竹篓内|木船|善人渡|小木船|木船|小舟|太湖|接天桥|羊皮筏|黄河渡船|长江渡船|","|"..var.roomname.."|") then
                    follow_room = var.follow_room -- 在给出房间号，的时候直接跟随这个房间号
                    var.bbl_white_list[id] = follow_room
                end
            end
        end)

        add_trigger("job_bianli_area_2","^[> ]*\\S{1,2}正在查看【(\\S+)的信息】",function(p)
            local port = string.match(p[1],"房间(%d+)中")
            local port = tonumber(port) or 0
            var.bbl_port = port

            local check = is_bbl_job_npc_here()
            if check then
                var.do_stop = 1
                Print("bbl 回头 找 找到了")
                Run("blok") --找到了就在停顿房间
            else
                if var.do_stop and var.do_stop== 1 then
                    Print("停止？do_stop=1")

                elseif string.find(p[1],"房间") then --这是回头检查每个房间有没有了

                    var.bbl_last_room = port
                    var.bbl_black_port = var.bbl_black_port or {}
                    var.bbl_black_port[port] = true

                    if var.bbl_check_go_back_list == nil or next(var.bbl_check_go_back_list) then
                        Print("不对...继续走::")
                    --  var.do_stop = 0
                        keepwalk()
                    else
                        local check_list = {}
                        for k,v in ipairs(var.bbl_check_go_back_list) do
                            if not var.bbl_black_port[v] then
                                table.insert(check_list,v)
                            end
                        end
                        var.bbl_check_go_back_list = check_list
                        for k,v in ipairs(check_list) do
                            table.insert(var.bbl_check_go_back_list,v)
                        end
                        check_list = nil
                        Print("不对继续走...::")
                    --  var.do_stop = 0
                        keepwalk()
                    end
                elseif string.find(p[1],"继续遍历") then
                    set_check_bbl()
                    var.do_stop = 0
                    keepwalk()
                end
            end


        end)

    function check_npc_in_maze(action,types) -- 迷宫中遇到npc的行为
        Print(" check_npc_in_maze")
        local check = is_bbl_job_npc_here()
        if check then
            return function()
                var.do_stop = 1
                Print("check_npc_in_maze找到了")
                Run("blok") --找到了就在停顿房间
            end
        else
            return nil
        end
    end
    function check_bbl()
    --  Print("check_bbl")
        --**********************************--
        -- 首先检查当前房间是否有需要look的 --
        --**********************************--
        local done = is_bbl_job_npc_here()

        if done then

            return function()
                var.do_stop = 1
                Print("check_bbl找到了")
                Run("blok") --找到了就在停顿房间
            end

        else -- 当前房间没有，就查看有没有经过房间的white_list

            --return check_ddbbl_go_back() -- 吴非两种可能，回去或继续走
                                                                    if var.bbl_white_list ~= nil and next(var.bbl_white_list) ~= nil then -- 存在白名单
                                                                    local check_list = {}
                                                                    var.bbl_check_go_back_list = {} -- 要回去找到名单
                                                                    var.bbl_black_list = var.bbl_black_list or {} --黑名单id
                                                                    for k,v in pairs(var.bbl_white_list) do
                                                                --      if not check_list[v] and not var.bbl_black_list[k] then
                                                                        if not check_list[v] and not var.bbl_black_list[v] then
                                                                            table.insert(var.bbl_check_go_back_list,v)
                                                                            check_list[v] = true
                                                                        end

                                                                    end
                                                                    -- 注意这个bbl_check_go_back_list 格式是 {100,103,105} --每个地点可能有多个id，目前不管了
                                                                    if next(var.bbl_check_go_back_list)==nil then --好消息没有回头需求
                                                                        var.bbl_check_go_back_list = nil
                                                                        return nil
                                                                    else
                                                                --      Print("发现npc")
                                                                        local check_room = {}
                                                                        var.bbl_black_port = var.bbl_black_port or {} --黑名单房间号port
                                                                        for k,v in ipairs(var.bbl_check_go_back_list) do
                                                                            if not var.bbl_black_port[v] then
                                                                                table.insert(check_room,v)
                                                                            end
                                                                        end
                                                                        if next(check_room)==nil then -- 检查过房间号名单，结果无需回程
                                                                            check_room = nil
                                                                            return nil
                                                                        else
                                                                            var.bbl_check_go_back_list = {}
                                                                            for k,v in ipairs(check_room) do
                                                                                local roomnumber = tonumber(v)
                                                                                if roomnumber~=nil then
                                                                                    table.insert(var.bbl_check_go_back_list,v)
                                                                            --  else
                                                                            --      local roomname,roomnumber=string.match(v,"^(%D+)(%d+)$")
                                                                            --      if roomname and roomnumber then
                                                                            --          table.insert(var.bbl_check_go_back_list,v)
                                                                            --      end
                                                                                end
                                                                        --      Print("checkbl:"..v)
                                                                            end
                                                                            check_room = nil
                                                                            if next(var.bbl_check_go_back_list)~=nil then
                                                                            --  for k,v in pairs(var.bbl_check_go_back_list) do
                                                                            --      Print(v)
                                                                            --  end
                                                                                return bbl_go_back() -- 回到每个地点，这个以后再写吧
                                                                            else
                                                                                return nil
                                                                            end

                                                                        end

                                                                    end
                                                                else
                                                                    return nil
                                                                end

        end
    end

end

function is_bbl_job_npc_here()

        local done = false
        local black_list = {}
        if var.bbl_black_list ~= nil and next(var.bbl_black_list) ~= nil then
            for k,v in pairs(var.bbl_black_list) do
                black_list[k] = v -- 把yujie的黑名单copy一份
            end
        end

        var.bbl_white_list_here = {}

        if type(var["roomobj"])=="table" then
            for k,v in pairs(var["roomobj"]) do --查看一下房间的npc

                if not black_list[v] then -- job.lua
                    if string.find(k,var.job_bl_npc_name) or string.find(v,var.job_bl_npc_name) then
                            var.bbl_white_list_here[v] = true
                            done = true
                    end
                end
            end -- for
        end

        return done
end

function bbianli()

    Print("函数 bbianli")
    var.path_rooms={}
        local n=1
        for k in string.gmatch(var.bianli_pass_rooms.."|","(.-)|") do
            k=tonumber(k)
            var.path_rooms[n]=k
            n=n+1
        end
        --以上设置一下遍历跟随

    var.follow_rooms_fail = nil --默认没失败 nil
    var.path_after = var.bianli
    keepwalk()

end

--********
-- 回头找
--
function check_bbl_go_back() --检查是否需要回头
Print("函数 check_bbl_go_back")

                                                                if var.bbl_white_list ~= nil and next(var.bbl_white_list) ~= nil then -- 存在白名单
                                                                    local check_list = {}
                                                                    var.bbl_check_go_back_list = {} -- 要回去找到名单
                                                                    var.bbl_black_list = var.bbl_black_list or {} --黑名单id
                                                                    for k,v in pairs(var.bbl_white_list) do
                                                                    --  if not check_list[v] and not var.bbl_black_list[k] then
                                                                        if not check_list[v] and not var.bbl_black_list[v] then
                                                                            table.insert(var.bbl_check_go_back_list,v)
                                                                            check_list[v] = true
                                                                        end

                                                                    end
                                                                    -- 注意这个bbl_check_go_back_list 格式是 {100,103,105} --每个地点可能有多个id，目前不管了
                                                                    if next(var.bbl_check_go_back_list)==nil then --好消息没有回头需求
                                                                        var.bbl_check_go_back_list = nil
                                                                        return nil
                                                                    else
                                                                --      Print("发现npc")
                                                                        local check_room = {}
                                                                        var.bbl_black_port = var.bbl_black_port or {} --黑名单房间号port
                                                                        for k,v in ipairs(var.bbl_check_go_back_list) do
                                                                            if not var.bbl_black_port[v] then
                                                                                table.insert(check_room,v)
                                                                            end
                                                                        end
                                                                        if next(check_room)==nil then -- 检查过房间号名单，结果无需回程
                                                                            check_room = nil
                                                                            return nil
                                                                        else
                                                                            var.bbl_check_go_back_list = {}
                                                                            for k,v in ipairs(check_room) do
                                                                                local roomnumber = tonumber(v)
                                                                                if roomnumber~=nil then
                                                                                    table.insert(var.bbl_check_go_back_list,v)
                                                                            --  else
                                                                            --      local roomname,roomnumber=string.match(v,"^(%D+)(%d+)$")
                                                                            --      if roomname and roomnumber then
                                                                            --          table.insert(var.bbl_check_go_back_list,v)
                                                                            --      end
                                                                                end
                                                                        --      Print("checkbl:"..v)
                                                                            end
                                                                            check_room = nil
                                                                            if next(var.bbl_check_go_back_list)~=nil then
                                                                                return bbl_go_back() -- 回到每个地点，这个以后再写吧
                                                                            else
                                                                                return nil
                                                                            end

                                                                        end

                                                                    end
                                                                else
                                                                    return nil
                                                                end

end

function bbl_go_back() -- 回头找
    Print("函数bbl_go_back")
    if not var.do_stop or var.do_stop == 0 then
        var.do_stop = 1
        check_bbl = nil
        check_npc_in_maze = function() end
        local check_room = {}
        for k,v in pairs(var.bbl_check_go_back_list) do

                table.insert(check_room,v)

        end
        var.bbl_check_go_back_list = {}
        for k,v in pairs(check_room) do
            table.insert(var.bbl_check_go_back_list,v)
        end
        check_room = nil

        alarm("bbl_timer",2,function()
            for k,v in pairs(var.bbl_check_go_back_list) do
                Print(k.."::"..v)
            end
            add_trigger("job_bianli_test_1","^[> ]*你正在【准备做好遍历】",function()
                del_trigger("job_bianli_test_1")
                var.do_stop = 0
                gg(var.bbl_check_go_back_list[1],function() -- 去需要遍历的第一个房间
                    bbl_go_back_bianli()
                end)
            end)
            var.wrong_way = 1
            exe("pro 你正在【准备做好遍历】")
        end)
    end

end

function bbl_go_back_bianli() -- 怎么找呢...我想想
    Print("函数bbl_go_back_bianli")
    if var.bbl_check_go_back_list == nil or next(var.bbl_check_go_back_list) == nil then --如果回去名单都不在了当然blgo了
        exe("blgo")
    end

                add_alias("cross_for_bbl",function(p)
                    if type(var["roomobj"])=="table" then
                        for k,v in pairs(var["roomobj"]) do --查看一下房间的npc

                            if string.find(k,var.job_bl_npc_name) or string.find(v,var.job_bl_npc_name) then
                                var.do_stop = 1
                            --  var.bbl_found = tonumber(p[1])
                            end
                        end
                    end
                    exe("pro 你正在查看【房间"..p[1].."中的信息】")
                end)

                add_alias("cross_for_bbl_stop",function()
                    exe("pro 你正在查看【继续遍历的信息】")
                end)
                -- 以上先定义两个alias再说

        local go_back_list,check_list = {},{}
        var.bbl_check_go_back_list = var.bbl_check_go_back_list or {}
        var.bbl_black_port = var.bbl_black_port or {}
        for k,v in ipairs(var.bbl_check_go_back_list) do
            if not var.bbl_black_port[v] and not check_list[v] then
                table.insert(go_back_list,v) -- 所有目标房间 前插入当前gps房间
                check_list[v] = true
            end
        end

        local num = go_back_list[1]

        if num == nil then --竟然没有一个房间。。。
            exe("blgo") --继续bbl吧
        else
            local path = "cross_for_bbl "..go_back_list[1]
            var.path_rooms = {}
            local last = 0
            for k,v in ipairs(go_back_list) do
                last = v
                if go_back_list[k+1] then -- 如果存在下一个房间的话
                    last = go_back_list[k+1]
                    local path_part,path_rooms = pathfrom(v,go_back_list[k+1])

                    for k in string.gmatch(path_rooms.."|","(.-)|") do
                        k = tonumber(k)
                    --  Print("v::"..v)
                        table.insert(var.path_rooms,k)
                    end

                    path = path .. ";" .. path_part .. ";cross_for_bbl "..go_back_list[k+1] -- cross_for_job 需要判断具体条件了

                end
            end
--          path = string.match(path,"(.+);cross_for_bbl (%d+)$") or path --除去以";"开始的符号

            path = path .. ";cross_for_bbl_stop"
--          path = string.match(path,"^;(.+)") or path --除去以";"开始的符号

        -- 以上回去遍历设置好了

        -- 接下来的bl还没设置呢
            if var.job_search_table~=nil and next(var.job_search_table)~=nil and var.job_search_table[1] == last then
                table.remove(var.job_search_table,1) --如果继续遍历的第一个 和 折返的最后一个一样删除最后要遍历的第一个
            end

            if var.job_search_table==nil or next(var.job_search_table) == nil then

            else

                local bbianli,bbianli_pass_rooms = get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称

                local path_connect,pass_room_connect = pathfrom(last,var.job_search_table[1])

                for k in string.gmatch(pass_room_connect.."|","(.-)|") do
                        k = tonumber(k)
                        table.insert(var.path_rooms,k)
                end
                for k in string.gmatch(bbianli_pass_rooms.."|","(.-)|") do
                        k = tonumber(k)
                        table.insert(var.path_rooms,k)
                end

                path = path .. ";" .. path_connect .. ";"..bbianli

            end

            var.follow_rooms_fail = nil --默认没失败 nil

            var.path_after = path
            check_bbl = nil check_npc_in_maze = function() end
            keepwalk()
        end

end

function do_bbianli_room(zone,room,range,name,id,quick) -- 按照房间遍历函数

    var.idle = 0 --偷懒一下
    if name then var.job_bl_npc_name = name end
    if id then var.job_bl_npc_id = id end
    local zone_room = zone .. room
    var.job_range = range or 0
    local quick = quick or 0

    if zone=="" or room =="" then
        echo("$HIW$【遍历区域不存在】：$HIR$"..zone..room)
        Run("blreset;blfail")
        return
    end

    local job_room_table = get_room_list(zone..room)

    if null(job_room_table) then
        echo("$HIW$【遍历区域不存在】：$HIR$"..zone..room)
        Run("blreset;blfail")
        return
    end


        local n = table.maxn(job_room_table)    --目标房间只有一个


        if n>9 then
            if var.job_range>3 then var.job_range=3 end -- 如果目标有10个比如 石阶，那么范围不能大于3
        end

        local search_table = {}
        search_table,var.job_search_table = get_searches(job_room_table,var.job_range) -- job.lua 函数 --重新排列了房间号


        if n == 1 then
            table.insert(var.job_search_table,job_room_table[1]) --如果目标唯一，那么将这个 房间插入到第一个
        end
        --  2  3  4  5  6
        --  7  8  1X 9  10
        --  11 12 13 14 15
        -- 最终优先1，然后才是2-15


    if 1==0 and quick==1 then -- 快速遍历!!! 1===0 关闭了

        local npc = id or name
        do_bianli_area_quick(city,npc,range)

    else -- 以下一般遍历

        var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称
        var.bianli = string.gsub(var.bianli,";cross_for_job;",";")
        var.bianli = string.gsub(var.bianli,"cross_for_job$","")
        var.bianli = string.gsub(var.bianli,"^cross_for_job","")
        var.bianli = string.match(var.bianli,"(.*);$") or string.match(var.bianli,"^;(.*)") or var.bianli

        go(var.job_search_table[1],function() -- 去 城市第一个房间
            check_bbl = nil check_npc_in_maze = function() end
            var.bl_time_start = os.time()
            function after_goto()
                del_trigger("job_bianli_area_1")
                del_trigger("job_bianli_area_2")
                Run("blreset")
                Run("blfail") --执行blfail
            end
            --bianli() --遍历
            set_check_bbl() -- 设置一下bbl_check
            bbianli()
        end)
    end
end
