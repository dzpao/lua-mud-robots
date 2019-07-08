--**********--
--    dbbl   --
--**********--
--快速扫过谍报,看到合适信息再折返

add_alias("dbbl",function(p)
    Print("alias dbbl")
    var.bbl_found = nil
    var.do_stop = 0

    check_bbl = nil check_npc_in_maze = function() end -- 让bbl停下来的检查函数
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
        Print("blgo")
        var.do_stop = 0
        var.diezhan_found = nil
        var.bl_stop_room = 0
        check_bbl = nil check_npc_in_maze = function() end -- 让bbl停下来的检查函数

    --???   table.remove(var.job_search_table,1) --删除走过房间
        if null(var.job_search_table) then
            del_trigger("job_bianli_area_1")
            del_trigger("job_bianli_area_2")
            Print("blgo no rooms")
            Run("blreset")
            Run("blfail") --执行blfail
        else
        --  var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称


        --  add_alias("cross_for_bbl",function()  -- 定义 cross_for_bbl 遍历的alias
        --          local npc = var.job_bl_npc_name
        --          exe("pro 你正在【遍历寻找"..npc.."】",5)
        --  end)

            go(var.job_search_table[1],function() -- 去 城市第一个房间
                var.bl_time_start = os.time()
                function after_goto()
                    del_trigger("job_bianli_area_1")
                    del_trigger("job_bianli_area_2")
                    Run("blreset")
                    Run("blfail") --执行blfail
                end
                var.bianli,var.bianli_pass_rooms=get_dbbianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称
                Print("blgo bianli")
                set_check_dbbl()
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
    --  do_bianli_area(city,name,range) -- 区域遍历
        do_dbbianli_area(city,name,range)
    else                          -- 没有城市
        local zone,room = break_zoneroom(city)
        if room=="" then
            echo("$HIW$【遍历区域不存在】：$HIR$"..city)
            Run("blreset;blfail")
        else
            echo("$HIW$【遍历区域为】：$HIG$"..zone.."$HIW$--$HIG$"..name)
    --      do_bianli_room(zone,room,range,name) --房间名称遍历 --指定扬州北大街 还是普通bl吧，懒得写了
                                                -- 暂时还没做
            do_bbianli_room(zone,room,range,name)
        end
    end

end)

function do_dbbianli_area(city,npc,range,quick) -- 区域遍历函数
    Print("函数 do_dbbianli_area")
    check_bbl = nil check_npc_in_maze = function() end

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

    if 1==0 and quick then -- 快速遍历!!! xbl
    -- 1==0 关闭了

        do_bianli_area_quick(city,npc,range)

    else        -- 以下一般遍历 bl
        var.bianli,var.bianli_pass_rooms=get_dbbianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称


        add_trigger("job_bianli_area_1","^[> ]*\\S{1,2}正在【路过(\\S+)】",function(p)

            local roomnum = tonumber(p[1]) -- 房间号

            if var.job_search_table~=nil and next(var.job_search_table) then
                if roomnum == var.job_search_table[1] then
                    table.remove(var.job_search_table,1)
                else
                --  Print("  bbl房间获取失败，但是还是删除了当前第一个房间")
                    Print("  bbl房间获取失败，请查看")
                --  table.remove(var.job_search_table,1)
                end
            end

            var.bbl_black_port = var.bbl_black_port or {} --黑名单房间号port

            if var.bbl_black_port[roomnum] then
                return
            end

            local black_list = {}
            if var.bbl_black_list ~= nil and next(var.bbl_black_list) ~= nil then
                for k,v in pairs(var.bbl_black_list) do
                    black_list[k] = v -- 把yujie的黑名单copy一份
                end
            end

            var.bbl_white_list = var.bbl_white_list or {}
            -- 目前先写一个针对御姐任务的bbl，其他case by case吧
            if type(var["roomobj"])=="table" then
                for k,v in pairs(var["roomobj"]) do --查看一下房间的npc
                    local s = string.match(k,"%s(%S+)$") or k
                    local n,names = RegEx(s,"(?:」|位)(\\S+)$")
                    if n=="0" then names = s end -- 未匹配到

                    local is_npc,vid = is_job_npc(names)
                    local is_name_type = is_xingming(names) or false -- 判断是不是姓名格式

                    if not is_npc and s then    is_npc,vid = is_job_npc(s)  end
                    if is_npc and vid == v and not black_list[v] and is_name_type then -- job.lua

                        if string.find(k,"将军府 武士") or string.find(k,"老艄公") or string.find(k," 引路人 ")
                        or (string.find(k,"老板 ") and string.find(var.roomname,"当铺"))
                        or string.find(k,"饱学之士 ")
                        or string.find(k,"掌柜 ") or string.find(k,"大师傅 ") then
                        elseif v == "feilong bangzhu" then
                        else
                            if string.find(v," ") then -- id含有空格
                            --  Print("  add-->"..v)
                                var.bbl_white_list[v] = roomnum -- 可能是npc所以加入到白名单格式 ["zhang san"] = 100,
                            end
                        end
                    end
                end -- for
            end
        end)


        add_trigger("job_bianli_area_2","^[> ]*\\S{1,2}正在查看【(\\S+)的信息】",function(p)
            if var.diezhan_found then --交给db.lua处理吧
                check_bbl = nil check_npc_in_maze = function() end
            --  goto_ok = nil
                Print("db找到了?")
            else

            if var.do_stop and var.do_stop== 1 then
                Print("停止？do_stop=1")
            else
            -->          你正在查看【当前所在的信息】并不是一个北侠的职业，目前没有相关的信息。
                if string.find(p[1],"当前所在") then -- bbl_go_back 之前检查一下当前房间
                    Print("出发前检查没有，检查是否需要回头::")
                    local check = check_ddbbl_go_back()

                    if check == nil then
                        for k,v in pairs(var["roomobj"]) do
                            var.bbl_black_list[v] = true
                        end

                        Print("没有")
                        keepwalk() -- 没有继续往前走
                    end

                elseif p[1] == "迷宫中" then -- 迷宫做检查npc信息

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
                        Print("迷宫中不对继续走...::")

                        wa(1,function()
                            exe("keepmigong")
                        end)

                elseif string.find(p[1],"房间") then --这是回头检查每个房间有没有了

                    local port = string.match(p[1],"房间(%d+)中")
                    local port = tonumber(port) or 0

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
                        Print("不对继续走...")
                    --  var.do_stop = 0
                        keepwalk()
                    end
                elseif string.find(p[1],"继续遍历") then
                    set_check_dbbl()
                    var.do_stop = 0
                    keepwalk()
                end

            end
            end
        end)
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
            set_check_dbbl() -- 设置一下bbl_check
            dbbianli()
        end)
    end
end

function get_dbbianli(search_list) --组合成遍历路径 get_bbianli 用于bbl
    Print("函数 get_dbbianli")
    if null(search_list) then
        return "","","",{},{}
    else
        local bianli_table = {}
        local bianli_pass_rooms = ""


        for k,v in ipairs(search_list) do
            if search_list[k+1] then

                local bianli_path,pass_rooms = find_paths(v,search_list[k+1])

                if bianli_path=="" then
                    print("警告：发现无法进入房间:"..v.." --> "..search_list[k+1])
                else
                    bianli_pass_rooms = bianli_pass_rooms .."|".. pass_rooms
                    table.insert(bianli_table,bianli_path)
                end
            end
        end

        local bianli_path = "pro 你正在【路过" .. search_list[1] .. "】"
        for k,v in ipairs(bianli_table) do
            if search_list[k+1] then
                bianli_path =  bianli_path .. ";" ..v.. ";pro 你正在【路过"..search_list[k+1].."】"
            end
        end

        bianli_path = string.match(bianli_path,"^;(.*)") or bianli_path
        bianli_path = string.match(bianli_path,"(.*);$") or bianli_path

        bianli_table = nil

        bianli_pass_rooms = string.match(bianli_pass_rooms,"^|(.+)") or bianli_pass_rooms
        bianli_pass_rooms = string.match(bianli_pass_rooms,"(.+)|$") or bianli_pass_rooms

        return bianli_path,bianli_pass_rooms,bianli_pass_rooms,search_list,search_list

    end
end

function set_check_dbbl()  -- 设置每一步，检查是否需要bbl
    Print("函数set_check_dbbl")
    function check_npc_in_maze(action,types) -- 迷宫中遇到npc的行为

        local check = is_db_job_npc_here()
        if check then
        --  npc_in_maze_action = action

            for _,v in pairs(var["roomobj"]) do
                if string.find(v," ") and not var.bbl_black_list[v] then
                    Send("look "..v)
                end
            end
            Send("pro 你正在查看【迷宫中的信息】")
        else
            --action()
            return nil
        end
    end
    function check_bbl()
        Print("check_bbl")
        --**********************************--
        -- 首先检查当前房间是否有需要look的 --
        --**********************************--
        local done = is_db_job_npc_here()

        if done then
        --  var.do_stop = 1
            for k,_ in pairs(var.bbl_white_list_here) do
                if  not var.bbl_black_list[k] then
                    Send("look "..k)
                end
            end
--          Send("pro 你正在查看【迷宫中的信息】")
            Send("pro 你正在查看【当前所在的信息】") --插件当前房间
            return function() end

        else -- 当前房间没有，就查看有没有经过房间的white_list

            --return check_ddbbl_go_back() -- 吴非两种可能，回去或继续走
                                                                    if var.bbl_white_list ~= nil and next(var.bbl_white_list) ~= nil then -- 存在白名单
                                                                    local check_list = {}
                                                                    var.bbl_check_go_back_list = {} -- 要回去找到名单
                                                                    var.bbl_black_list = var.bbl_black_list or {} --黑名单id
                                                                    for k,v in pairs(var.bbl_white_list) do
                                                                        --if not check_list[v] and not var.bbl_black_list[k] then
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
                                                                                table.insert(var.bbl_check_go_back_list,v)
                                                                            end
                                                                            check_room = nil
                                                                            return dbbl_go_back() -- 回到每个地点，这个以后再写吧

                                                                        end

                                                                    end
                                                                else
                                                                    return nil
                                                                end

        end
    end

end


function dbbianli()

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

function is_db_job_npc_here()

        local done = false
        local black_list = {}
        if var.bbl_black_list ~= nil and next(var.bbl_black_list) ~= nil then
            for k,v in pairs(var.bbl_black_list) do
                black_list[k] = v -- 把yujie的黑名单copy一份
                Print("black_list:"..k)
            end
        end

        var.bbl_white_list_here = {}

        if type(var["roomobj"])=="table" then
            for k,v in pairs(var["roomobj"]) do --查看一下房间的npc
                local s = string.match(k,"%s(%S+)$") or k
                local n,names = RegEx(s,"(?:」|位)(\\S+)$")
                if n=="0" then names = s end --未匹配到

                local is_npc,vid = is_job_npc(names)
                local is_name_type = is_xingming(names) or false
        --      local is_name_type = true
                if not is_npc and s then is_npc,vid = is_job_npc(s) end --发现一个bug，比如npc叫 封大宝 feng 会被前面正则吃掉
                if is_npc and vid == v and not black_list[v] and is_name_type then -- job.lua

                    if string.find(k,"将军府 武士") or string.find(k,"老艄公") or string.find(k," 引路人 ")
                --  or string.find(k,"老板 ")
                    or (string.find(k,"老板 ") and string.find(var.roomname,"当铺"))
                    or string.find(k,"饱学之士 ")
                    or string.find(k,"掌柜 ") or string.find(k,"大师傅 ") then
                    elseif v == "feilong bangzhu" then
                    else
                        if string.find(v," ") then -- id含有空格
                            var.bbl_white_list_here[v] = true
                            done = true
                        end
                    end
                end
            end -- for
        end

        return done
end


--********
-- 回头找
--
function check_ddbbl_go_back() --检查是否需要回头
Print("函数 check_dbbl_go_back")

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
                                                                                table.insert(var.bbl_check_go_back_list,v)
                                                                            end
                                                                            check_room = nil
                                                                            return dbbl_go_back() -- 回到每个地点，这个以后再写吧

                                                                        end

                                                                    end
                                                                else
                                                                    return nil
                                                                end

end

function dbbl_go_back() -- 回头找
Print("函数dbbl_go_back")
    if not var.do_stop or var.do_stop == 0 then
        var.do_stop = 1
        check_bbl = nil check_npc_in_maze = function() end
        alarm("bbl_timer",2,function()
            for k,v in pairs(var.bbl_check_go_back_list) do
                Print(k.."::"..v)

            end
            add_trigger("job_bianli_test_1","^[> ]*你正在【准备做好遍历】",function()
                del_trigger("job_bianli_test_1")
                var.do_stop = 0
                gg(var.bbl_check_go_back_list[1],function() -- 去需要遍历的第一个房间

                    dbbl_go_back_bianli()
                end)
            end)
            var.wrong_way = 1
            exe("pro 你正在【准备做好遍历】")
        end)
    end

end

function dbbl_go_back_bianli() -- 怎么找呢...我想想
Print("函数bbl_go_back_bianli")
    if var.bbl_check_go_back_list == nil or next(var.bbl_check_go_back_list) == nil then --如果回去名单都不在了当然blgo了
        exe("blgo")
    end

                add_alias("cross_for_bbl",function(p)
                    if type(var["roomobj"])=="table" then
                        for k,v in pairs(var["roomobj"]) do --查看一下房间的npc
                            local s = string.match(k,"%s(%S+)$") or k

                            local n,names = RegEx(s,"(?:」|位)(\\S+)$")
                            if n=="0" then names = s end --未匹配到

                            local is_npc,vid = is_job_npc(names)
                            local is_name_type = is_xingming(names) or false
                        --  local is_name_type = true
                            if not is_npc and s then    is_npc,vid = is_job_npc(s)  end --发现一个bug，比如npc叫 封大宝 feng 会被前面正则吃掉
                            if is_npc and vid==v and string.find(v," ") and is_name_type and not var.bbl_black_list[v] then
                        --  if string.find(v," ") then
                                Send("look "..v)
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

                local bbianli,bbianli_pass_rooms = get_dbbianli(var.job_search_table) -- 得到遍历path，和path经过哪些房间名称

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
