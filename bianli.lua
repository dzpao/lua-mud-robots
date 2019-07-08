-- 遍历
-- bl 扬州 张三 5
-- bl 扬州南大街 张三 0

-- 快速遍历
-- xbl 扬州 张三 3
-- xbl 扬州 zhang san 0
-- xbl 扬州北大街 zhang san 2

--********************--
-- blok    -- 遍历成功后执行的alias
-- blfail  -- 遍历失败后执行的alias
-- blgo    -- 手动继续遍历 -- 错过以后执行
-- bllost  -- lost npc以后继续遍历 --> bllost 5
-- blreset -- 每次开启前建议执行一下，防止老的信息没有清除


--********************--


--~~~~~~~~~~~~~~~~~~~~
-- 遍历alias bl
--~~~~~~~~~~~~~~~~~~~~

add_alias("bl",function(p)
    var.bbl_found = nil
    var.do_stop = 0
    check_bbl = nil
    function check_stop() end
    function check_npc_in_maze() end
    function check_job_stop() end

    var.bl_stop_room = 0
    var.job_bl_npc_name = ""
    var.job_bl_npc_id = ""

    var.bbl_black_list = {}  -- 遍历黑名单，记录一些确认过不是的npc
    var.bbl_black_port = {}  -- 遍历黑名单，记录一些没有npc的 room
    var.bbl_white_list = {}  -- 遍历白名单
    var.bbl_check_go_back_list = {} -- 遍历回头

    add_alias("blgo",function() -- blgo 中断以后继续走
        var.do_stop = 0
        var.bl_stop_room = 0
        table.remove(var.job_search_table,1) --删除走过房间
        if null(var.job_search_table) then
            del_trigger("job_bianli_area_1")
            del_trigger("job_bianli_area_2")
            Run("blreset")
            Run("blfail") --执行blfail
        else
            var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称

            add_alias("cross_for_job",function()  -- 定义 cross_for_job 遍历的alias
                    local npc = var.job_bl_npc_name
                    exe("pro 你正在【遍历寻找"..npc.."】",5)
            end)

            go(var.job_search_table[1],function() -- 去 城市第一个房间
                var.bl_time_start = os.time()
                function after_goto()
                    del_trigger("job_bianli_area_1")
                    del_trigger("job_bianli_area_2")
                    Run("blreset")
                    Run("blfail") --执行blfail
                end
                bianli() --遍历
            end)
        end
    end)


    local input = p[-1]
    local city,name,range = "","",0
    if string.match(input,".*%S%s%d+") then --以数字结尾 比如 -- 扬州 张三 5
        city,name,range = string.match(input,"^(%S+) (%S+) (%d+)")
        range = tonumber(range)
    else -- 扬州 张三
        city,name = string.match(input,"^(%S+) (%S+)")
    end

    local check_zone_list = {}
    var.zone_list,check_zone_list = get_zonelist() -- job.lua

    if check_zone_list[city] then -- 有城市
        echo("$HIW$【遍历区域为】：$HIG$"..city.."$HIW$--$HIG$"..name)
        do_bianli_area(city,name,range) -- 区域遍历
    else                          -- 没有城市
        local zone,room = break_zoneroom(city)
        if room=="" then
            echo("$HIW$【遍历区域不存在】：$HIR$"..city)
            Run("blreset;blfail")
        else
            echo("$HIW$【遍历区域为】：$HIG$"..zone.."$HIW$--$HIG$"..name)
            do_bianli_room(zone,room,range,name) --房间名称遍历
        end
    end

end)

function do_bianli_area(city,npc,range,quick) -- 区域遍历函数

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

    -- Print(table.concat(var.job_search_table,"|"))-- var.job_search_table 目前就是需要遍历的 扬州+扬州周围n格房间

    quick = quick or nil

    if quick then -- 快速遍历!!! xbl

        do_bianli_area_quick(city,npc,range)

    else        -- 以下一般遍历 bl
                        function check_job_stop()
                    --  Print("")
                                del_timer("input")
                                local name = var.job_bl_npc_name or "none"
                                local found = false --未发现

                                if type(var["roomobj"])=="table" then
                                    for k,v in pairs(var["roomobj"]) do --查看一下房间的npc
                                        --  local npc = string.match(k,".*位(%S+)$") or string.match(k,".*」(%S+)$") or string.match(k,".*只(%S+)$") or string.match(k,".*条(%S+)$") or string.match(k,"%s(%S+)$") or k
                                        --if string.find(v, ' ') and is_job_npc(npc) then
                                         --   echo("$HIW$do_bianli_area")
                                        --  Send("look " .. v) -- 这样做真的好么？ 加一个isnpc判断
                                        --end
                local s = string.match(k,"%s(%S+)$") or k
        --      local _,names = RegEx(s,"(\?\:张一千两|粒|文|枚|盒|块|锭|双|件|两|张|份|本|个|颗|封|根|把|支|柄|条|只|茧|」|位|只|条)(\\S+)$")
        local n,names = RegEx(s,"(?:」|位)(\\S+)$")
                       if n=="0" then names = s end

                local is_npc,vid = is_job_npc(names)
                if not is_npc then  is_npc,vid = is_job_npc(s)  end --发现一个bug，比如npc叫 封大宝 feng 会被前面正则吃掉
                if is_npc and vid == v and string.find(v," ") then -- job.lua
                    Send("look " .. v) -- 这样做真的好么？ 加一个isnpc判断
                end


                                        if string.find(k,name.."$") or string.find(k,names.." 慕容世家内鬼") or string.find(k,names.." 慕容世家家贼") then
                                        -- name写xxx发现的也算吧
                                            var.job_bl_npc_id = v
                                            found = true
                                            echo("$HIW$【遍历区域发现人物】：$HIR$"..name.."$NOR$")
                                            var.bl_time_start = var.bl_time_start or os.time()
                                            local bl_time = os.time() - var.bl_time_start
                                            logs("$HIW$【任务记录】$HIY$遍历bl耗时: "..bl_time.." 秒")
                                            break
                                        end
                                    end
                                end

                                if found then --发现了

                                        if var.job_search_table and var.job_search_table[1] then
                                            var.bl_stop_room = var.job_search_table[1]
                                        elseif var.follow_rooms_fail==nil then
                                            var.bl_stop_room = var.follow_room
                                        end

                                    return function()
                                    Print("return blok")
                                    Run("blok") end -- 执行alias blok
                                else
                                    return function()

                                        table.remove(var.job_search_table,1) --删除走过房间
                                        check_busy(function()
                                            keepwalk() --继续走
                                        end)
                                    end
                                end
                        end

                    add_trigger("job_bianli_area_1","^[> ]*\\S{1,2}正在【遍历寻找(\\S+)】",function(p)
                        del_timer("input")

                        local found = false --未发现

                        if type(var["roomobj"])=="table" then
                            for k,v in pairs(var["roomobj"]) do --查看一下房间的npc
                            --      local name = string.match(k,".*位(%S+)$") or string.match(k,".*」(%S+)$") or string.match(k,".*只(%S+)$") or string.match(k,".*条(%S+)$") or string.match(k,"%s(%S+)$") or k
                            --  if string.find(v, ' ') and is_job_npc(npc) then
                            --      echo("$HIW$do_bianli_area")
                            --      Send("look " .. v)
                            --  end
                local s = string.match(k,"%s(%S+)$") or k
            --  local _,names = RegEx(s,"(\?\:张一千两|粒|文|枚|盒|块|锭|双|件|两|张|份|本|个|颗|封|根|把|支|柄|条|只|茧|」|位|只|条)(\\S+)$")
--local _,names = RegEx(s,"(\?\:」|位)(\\S+)$")
--          names = names or s
            local n,names = RegEx(s,"(?:」|位)(\\S+)$")
                       if n=="0" then names = s end

                local is_npc,vid = is_job_npc(names)
                if not is_npc then  is_npc,vid = is_job_npc(s)  end --发现一个bug，比如npc叫 封大宝 feng 会被前面正则吃掉
                if is_npc and vid == v and string.find(v," ") then -- job.lua
                    Send("look " .. v) -- 这样做真的好么？ 加一个isnpc判断
                end

                                if string.find(k,p[1].."$") or string.find(k,names.." 慕容世家内鬼") or string.find(k,names.." 慕容世家家贼") then
                                    var.job_bl_npc_id = v
                                    found = true
                                    echo("$HIW$【遍历区域发现人物】：$HIR$"..p[1].."$NOR$")

                                    break
                                end
                            end
                        end

                        if found then --发现了
                            var.bl_time_start = var.bl_time_start or os.time()
                            local bl_time = os.time() - var.bl_time_start
                            logs("$HIW$【任务记录】$HIY$遍历bl耗时: "..bl_time.." 秒")
                            Run("blok") -- 执行alias blok
                        else
                            table.remove(var.job_search_table,1) --删除走过房间
                            check_busy(function()
                                keepwalk() --继续走
                            end)
                        end
                    end)

        var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称

        add_alias("cross_for_job",function()  -- 定义 cross_for_job 遍历的alias
                local npc = var.job_bl_npc_name
                exe("pro 你正在【遍历寻找"..npc.."】",5)
        end)

        go(var.job_search_table[1],function() -- 去 城市第一个房间
            var.bl_time_start = os.time()
            function after_goto()
                del_trigger("job_bianli_area_1")
                del_trigger("job_bianli_area_2")
                Run("blreset")
                Run("blfail") --执行blfail
            end
            bianli() --遍历
        end)
    end
end

--**********
-- blget
--**********
add_alias("blget",function(p)
    var.bbl_found = nil
    check_bbl = nil
    var.do_stop = 0
    function check_stop() end
    function check_npc_in_maze() end
    function check_job_stop() end
    var.bl_stop_room = 0
    var.job_bl_npc_name = ""
    var.job_bl_npc_id = ""

    var.bbl_black_list = {}  -- 遍历黑名单，记录一些确认过不是的npc
    var.bbl_black_port = {}  -- 遍历黑名单，记录一些没有npc的 room
    var.bbl_white_list = {}  -- 遍历白名单
    var.bbl_check_go_back_list = {} -- 遍历回头

    local job_search_table,maxnumber = {},0
    for k,v in pairs(rooms) do
        if not rooms[k].cost or rooms[k].cost<10000 and not no_enter_rooms[k] and enter_rooms[k] then
            job_search_table[k] = true
            if k> maxnumber then
                maxnumber = k
            end
        end
    end
    var.job_search_table = {}
    for k=1,maxnumber do
        if job_search_table[k] then
            table.insert(var.job_search_table,k)
        end
    end
        go(var.job_search_table[1],function() -- 去 城市第一个房间
            var.bl_time_start = os.time()
            function after_goto()
                del_trigger("job_bianli_area_1")
                del_trigger("job_bianli_area_2")
                Run("blreset")
                Run("changejob") --执行blfail
            end
            var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称
            var.bianli = string.gsub(var.bianli,"cross_for_job",p[-1])
            bianli() --遍历
        end)

end)


--~~~~~~~~~~~~~~~~~~~~
-- 快速遍历alias xbl
--~~~~~~~~~~~~~~~~~~~~

add_alias("xbl",function(p)
var.bbl_found = nil
    check_bbl = nil
    var.do_stop = 0
    function check_stop() end
    function check_npc_in_maze() end
    function check_job_stop() end
    var.bl_stop_room = 0
    var.job_bl_npc_name = ""
    var.job_bl_npc_id = ""

    var.bbl_black_list = {}  -- 遍历黑名单，记录一些确认过不是的npc
    var.bbl_black_port = {}  -- 遍历黑名单，记录一些没有npc的 room
    var.bbl_white_list = {}  -- 遍历白名单
--  var.bbl_white_list_here = {}
    var.bbl_check_go_back_list = {} -- 遍历回头

    --add_alias("blgo",function() -- blgo 中断以后继续走

    --  Run("blreset")
    --  var.do_stop = 0
    --  var.bl_stop_room = 0
    --end)
    add_alias("blgo",function() -- blgo 中断以后继续走
        var.do_stop = 0
        var.bl_stop_room = 0
        Run("blreset")
        --table.remove(var.job_search_table,1) --删除走过房间
        if null(var.job_search_table) then
            del_trigger("job_bianli_area_1")
            del_trigger("job_bianli_area_2")
            Run("blreset")
            Run("blfail") --执行blfail
        else
            var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称

            add_alias("do_job",function()   -- job alias --do_job -- 系统遍历会形成 e;do_job;s;do_job
                table.remove(var.job_search_table,1)
                exe("renqin "..var.job_bl_npc_id)
            end)

                function check_npc_in_maze(action) -- 迷宫中遇到npc的行为
                    var.roomobj = var.roomobj or {}
                    local done = false
                    for k,v in pairs(var.roomobj) do
                        if (var.job_bl_npc_name ~= "" and string.find(k,var.job_bl_npc_name)) or (var.job_bl_npc_id ~= "" and string.find(v,var.job_bl_npc_id))  then
                            done = true
                            break
                        end
                    end

                    if done then
                        function check_npc_in_maze() end
                        exe("renqin "..var.job_bl_npc_id)
                        return action
                    else
                        return nil
                    end
                end -- -- 迷宫中遇到npc的行为

                var.bianli = string.gsub(var.bianli,"cross_for_job","do_job") -- 系统遍历会形成 e;cross_for_job;s;cross_for_job
            go(var.job_search_table[1],function() -- 去 城市第一个房间
            --  var.bl_time_start = os.time()
                function after_goto()
                    del_trigger("job_bianli_area_1")
                    del_trigger("job_bianli_area_2")
                    Run("blreset")
                    Run("blfail") --执行blfail
                end
                bianli() --遍历
            end)                                                                      -- 替换为 e;do_job;s;do_job
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

    local check_zone_list = {}
    var.zone_list,check_zone_list = get_zonelist() -- job.lua


    if check_zone_list[city] then -- 有城市
        echo("$HIW$【遍历区域为】：$HIG$"..city.."$HIW$--$HIG$"..name)
        do_bianli_area(city,name,range,true)
    else                          -- 没有城市
        local zone,room = break_zoneroom(city)
        if room=="" then
            echo("$HIW$【遍历区域不存在】：$HIR$"..city)
            Run("blreset;blfail")
        else
            echo("$HIW$【遍历区域为】：$HIG$"..zone.."$HIW$--$HIG$"..name)

            do_bianli_room(zone,room,range,nil,name,1)
        end
    end

end)

function do_bianli_area_quick(city,npc,range)
    --你看着铁匠铺伙计欲言又止，铁匠铺伙计暗地里翻了个白眼：这人好变态啊。
    add_trigger("job_bianli_area_1","^[> ]*\\S{1,2}看着(\\S+)欲言又止",function(p)
        del_timer("input")
        var.do_stop = 1
        var.wrong_way = 1

        var.job_bl_npc_name = p[1]

        if var.follow_rooms_fail==nil then
            var.bl_stop_room = var.follow_room
        end

        echo("$HIW$【遍历区域发现人物】：$HIR$"..p[1].."$NOR$")
        var.bl_time_start = var.bl_time_start or os.time()
        local bl_time = os.time() - var.bl_time_start
        --logs("$HIW$【任务记录】$HIY$快速遍历xbl耗时: "..bl_time.." 秒")

        wa(1,function()
            function check_job_stop() end
            Run("blok")
        end)
    end)


    if string.find(npc,"^%w") then --英文
        var.job_bl_npc_id = npc
        var.job_bl_npc_name = ""
    else -- 中文
        var.job_bl_npc_name = npc
        var.job_bl_npc_id = get_id(npc)
    end


    var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称

        add_alias("do_job",function()   -- job alias --do_job -- 系统遍历会形成 e;do_job;s;do_job
            table.remove(var.job_search_table,1)
            exe("renqin "..var.job_bl_npc_id)
        end)

                function check_npc_in_maze(action) -- 迷宫中遇到npc的行为
                    var.roomobj = var.roomobj or {}
                    local done = false
                    for k,v in pairs(var.roomobj) do
                        Print(k.."::"..v .." --> job_bl_npc "..var.job_bl_npc_name.."::"..var.job_bl_npc_id)
                        if (var.job_bl_npc_name ~= "" and string.find(k,var.job_bl_npc_name)) or (var.job_bl_npc_id ~= "" and string.find(v,var.job_bl_npc_id)) then
--                      or string.find(k,var.job_bl_npc_name.." 慕容世家内鬼") or string.find(k,var.job_bl_npc_name.." 慕容世家家贼")  then
    Show("$HIW$发现了!!!")
                            done = true
                            break
                        end
                    end

                    if done then
                        function check_npc_in_maze() end
                        exe("renqin "..var.job_bl_npc_id)
                        return action
                    else
                        return nil
                    end
                end -- -- 迷宫中遇到npc的行为

                var.bianli = string.gsub(var.bianli,"cross_for_job","do_job") -- 系统遍历会形成 e;cross_for_job;s;cross_for_job
                                                                              -- 替换为 e;do_job;s;do_job

        go(var.job_search_table[1],function() -- 去 城市第一个房间
            var.bl_time_start = os.time()
            function after_goto()
                del_trigger("job_bianli_area_1")
                del_trigger("job_bianli_area_2")
                Run("blreset")
                Run("blfail") --执行blfail
            end
            bianli() --遍历
        end)



end

add_alias("blreset",function()
    var.do_stop = 0
    function check_stop() end
    function check_npc_in_maze() end
    function check_job_stop() end

end)
--~~~~~~~~~~~~~~~~
-- 丢失npc继续 bllost
--~~~~~~~~~~~~~~~~

add_alias("bllost",function(p)
    check_bbl = nil
    var.do_stop = 0
    var.wrong_way = 1
    function check_stop() end
    function check_npc_in_maze() end
    function check_job_stop() end
--  var.bl_time_start = os.time()

    if p[-1]~="" and tonumber(p[-1]) then -- 周围 n 格
        var.job_range = tonumber(p[-1])
    else                                  -- 直接输入默认周围 3 格
        var.job_range = 3
    end
    do_bianli_by_lost(var.bl_stop_room,var.job_range,var.job_bl_npc_name,var.job_bl_npc_id)
end)

function do_bianli_by_lost(bl_stop_room,job_range,job_bl_npc_name,job_bl_npc_id) --丢失后的遍历,慢速遍历

    var.gps_fail_times = 0 -- 修改gps增加了失败次数

    function after_gps() --定义gps后的行为
        if (job_bl_npc_name==nil or job_bl_npc_name=="") and (job_bl_npc_id or job_bl_npc_id =="") then -- id name 都没有还找啥找呢
            return
        end
        if var.roomname  and var.roomname == "大沙漠" and var.roomdesc and string.find(var.roomdesc,"看来要走出这块沙漠并非易事。") then
            var.do_stop = 0
            job_win() --回家？
        end
        local start_port
        if var.gps_fail_times>99 and var.bl_stop_room>0 then -- 迷宫中出来的
            start_port = var.bl_stop_room
        else
            start_port = var.gps -- 否则以gps为起点
        end

        job_range = job_range or 3

        var.job_room_table = {}
        table.insert(var.job_room_table,start_port) -- 起点

        var.job_search_table = get_searches(var.job_room_table,job_range) --周围房间

        var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称


        --***********

        add_trigger("job_bianli_area_1","^[> ]*\\S{1,2}正在【遍历寻找(\\S*)】并不是一个",function(p)
                    --                                         > 你正在【遍历寻找寻找流氓头】并不是一个北侠的职业，目前没有相关的信息。
                        del_timer("input")


                        local found = false --未发现

                        if type(var["roomobj"])=="table" then
                            for k,v in pairs(var["roomobj"]) do --查看一下房间的npc
                        --      Print(k.."::"..p[1])
                                if (var.job_bl_npc_name~="" and string.find(k,var.job_bl_npc_name)) or (var.job_bl_npc_id~="" and v==var.job_bl_npc_id) or string.find(k,p[1].." 慕容世家内鬼") or string.find(k,p[1].." 慕容世家家贼") then
                            --      Print("!!!!!")
                                    found = true
                                    echo("$HIW$【原地重新遍历发现人物】：$HIR$"..p[1].."$NOR$")
                                    break
                                end
                            end
                        end

                        if found then --发现了
                            var.bl_time_start = var.bl_time_start or os.time()
                            local bl_time = os.time() - var.bl_time_start
                            logs("$HIW$【任务记录】$HIY$原地重新遍历bl耗时: "..bl_time.." 秒")
                            Run("blok") -- 执行alias blok
                        else
                            table.remove(var.job_search_table,1) --删除走过房间
                            check_busy(function()
                                keepwalk() --继续走
                            end)
                        end
        end)



        add_alias("cross_for_job",function()  -- 定义 cross_for_job 遍历的alias
                local npc = var.job_bl_npc_name
                exe("pro 你正在【遍历寻找"..npc.."】",5)
        end)

        go(var.job_search_table[1],function() -- 去 城市第一个房间
            var.bl_time_start = os.time()
            function after_goto()
                del_trigger("job_bianli_area_1")
                del_trigger("job_bianli_area_2")
                Run("blreset")
                Run("blfail") --执行blfail
            end
            bianli() --遍历
        end)

    end

    gps("do_bianli_by_lost")

end

--~~~~~~~~~~~~~~~~~~~~
-- 房间遍历alias bll
-- bl 扬州北大街 张三 5
--~~~~~~~~~~~~~~~~~~~~

function do_bianli_room(zone,room,range,name,id,quick) -- 按照房间遍历函数

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

    --  if 1==0 and (n==1 or zone_room=="丐帮暗道" or quick == 0) then --这个用广度搜索吧 关闭
    --      var.job_search_table,search_table = get_searches(job_room_table,var.job_range) -- job.lua 函数
    --  else
        if n>9 then
            if var.job_range>3 then var.job_range=3 end
        end

            search_table,var.job_search_table = get_searches(job_room_table,var.job_range) -- job.lua 函数 --重新排列了房间号

    --  end
    if n == 1 then
        table.insert(var.job_search_table,job_room_table[1])
    end


    if quick==1 then -- 快速遍历!!!

        local npc = id or name
        do_bianli_area_quick(city,npc,range)

    else -- 以下一般遍历
                    if 1==1 then --测试一下
                        function check_job_stop()

                                del_timer("input")
                                local name = var.job_bl_npc_name or ""
                                local id = var.job_bl_npc_id or ""
                                local found = false --未发现

                                if type(var["roomobj"])=="table" then
                                    for k,v in pairs(var["roomobj"]) do --查看一下房间的npc

                                        if (k~="" and name~="" and string.find(k,name)) or (v~="" and id~="" and string.find(v,id)) or string.find(k,name.." 慕容世家内鬼") or string.find(k,name.." 慕容世家家贼") then

                                            found = true
                                            echo("$HIW$【遍历区域发现人物】：$HIR$"..name.."$NOR$")
                                        --  echo("k::"..k)
                                        --  echo("v::"..v)
                                        --  echo("id::"..id)
                                            var.bl_time_start = var.bl_time_start or os.time()
                                            local bl_time = os.time() - var.bl_time_start
                                            logs("$HIW$【任务记录】$HIY$遍历bl耗时: "..bl_time.." 秒")
                                            break
                                        end
                                    end
                                end

                                if found then --发现了

                                        if var.job_search_table and var.job_search_table[1] then
                                            var.bl_stop_room = var.job_search_table[1]
                                        elseif var.follow_rooms_fail==nil then
                                            var.bl_stop_room = var.follow_room
                                        end

                                    return function()  Run("blok") end -- 执行alias blok
                                else
                                    return function()

                                        table.remove(var.job_search_table,1) --删除走过房间
                                        check_busy(function()
                                            keepwalk() --继续走
                                        end)
                                    end
                                end
                        end

                    end
                    add_trigger("job_bianli_area_1","^[> ]*\\S{1,2}正在【遍历寻找(\\S+)】并不是一个",function(p)
                    --                                         > 你正在【遍历寻找寻找流氓头】并不是一个北侠的职业，目前没有相关的信息。
                        del_timer("input")

                        local found = false --未发现

                        if type(var["roomobj"])=="table" then

                            for k,v in pairs(var["roomobj"]) do --查看一下房间的npc

                                if string.find(k,p[1]) or v==p[1] or string.find(k,p[1].." 慕容世家内鬼") or string.find(k,p[1].." 慕容世家家贼") then

                                    found = true
                                    echo("$HIW$【遍历区域发现人物】：$HIR$"..p[1].."$NOR$")
                                --  echo("k::"..k)
                                --          echo("p 1::"..p[1])
                                        --  echo("id::"..id)
                                    break
                                end
                            end
                        end

                        if found then --发现了
                        --  function check_job_stop() end
                            var.bl_time_start = var.bl_time_start or os.time()
                            local bl_time = os.time() - var.bl_time_start
                            logs("$HIW$【任务记录】$HIY$遍历bl耗时: "..bl_time.." 秒")
                            Run("blok") -- 执行alias blok
                        else
                            table.remove(var.job_search_table,1) --删除走过房间
                            check_busy(function()
                                keepwalk() --继续走
                            end)
                        end
                    end)

        var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称

        add_alias("cross_for_job",function()  -- 定义 cross_for_job 遍历的alias
                local npc = var.job_bl_npc_name
                exe("pro 你正在【遍历寻找"..npc.."】",5)
        end)

        go(var.job_search_table[1],function() -- 去 城市第一个房间
            var.bl_time_start = os.time()
            function after_goto()
                del_trigger("job_bianli_area_1")
                del_trigger("job_bianli_area_2")
                Run("blreset")
                Run("blfail") --执行blfail
            end
            bianli() --遍历
        end)
    end
end

--**********--
--    dbbl   --
--**********--
--快速扫过谍报,看到合适信息再折返

require "dbbianli"

--*******--
-- bbl
--*******--
require "bbianli"
