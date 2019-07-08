-- job

function set_job(job)
    if job == "sl" then
        set_shaolin()
    else

    end

end


function close_last_job()
    local last_job = var.last_job or ""
    if last_job~="" then
        local count=0
        for i,j in pairs(trig_func) do
            for k,v in pairs(j) do
                if string.find(k,'^'..last_job) or string.find(k,'^job_'..last_job)  then
                    count = count+1
                    close_trigger(k)
                end
            end
        end
        Print(last_job..' 触发已经关闭: '..count..' 个')
    end
end

function close_trigger_by_job(s)
    local last_job = s or ""
    if last_job~="" then
        local count=0
        for k,v in pairs(trig_func) do
            if string.find(k,'^'..last_job) or string.find(k,'^job_'..last_job)  then
                count = count+1
                close_trigger(k)
            end
        end
        Print(last_job..' 触发已经关闭: '..count..' 个')
    end
end

function reset_job()
    var.job = ""
    var.job_step = 0
    var.diebao_fail = nil
--  var.job_stage="无任务"
    job_promote = {}

    var.job_zone_room=""
    var.job_room=""
    var.job_zone=""
    var.job_range=0
    var.job_npc_name=""
    var.job_npc_id=""

    var.killer_name=""
    var.killer_id=""
    var.killer2_name=""
    var.killer2_id=""
    var.killer_names=""        --多杀手
    var.killer_ids=""
    var.job_not_my_killer = "" --不是我的杀手

    check_this_room = nil
    function goto_ok() after_goto() end
    function check_stop() end                --走路 迷宫 检查停顿函数，返回值是函数可以执行 -- walk.lua
    function check_job_stop() end            --当出现cross 停顿时检测是否存在job 条件，返回值可以执行 --walk.lua
    function check_npc_in_maze() end
    function check_bbl() end

    after_blind = function() end            -- 你瞎了

    after_faint = function() end            -- 你晕了1

    after_faint2 = function() end           -- 你晕了2

    after_die = function() end              -- 你死了

    after_not_found = function() end        -- 没遇到杀手

    after_killer_meet = function()  end     -- 遇到杀手

    after_killer_faint = function()  end    -- 杀手晕了

    after_killer_die = function()   end     -- 杀手死了

    after_killer_win = function()   end     -- 杀手赢了

    after_killer_lose = function()  end     -- 杀手输了

    after_killer_lost = function()  end     -- 杀手跑了

    after_retreat = function()  end         -- 主动撤退

    job_win = function() end                -- 任务完成

    job_fail = function() end               -- 任务失败

    add_alias("after_faint",function()
        after_faint()
    end)

end

get_zonelist = function()   --得到所有区域table

    local zone_list,check_zone = {},{}

    for i=1,table.maxn(rooms) do
        if rooms[i] then
            if not check_zone[rooms[i].area] and not string.find("|新手村|汝阳王府|蒙古东部|蒙古北部|蒙古中部|蒙古西部|关外|壮族|星宿海新手|","|"..rooms[i].area.."|") then
                check_zone[rooms[i].area] = true
                table.insert(zone_list,rooms[i].area)
            end
        end
    end

    return zone_list,check_zone

end

function break_zoneroom(zoneroom) --分解  【扬州 北大街】

--  if zoneroom == "天龙寺崖间古松" then zoneroom = "无量山崖间古松" end
    if zoneroom == "白驼山大沙漠" then zoneroom = "丝绸之路大沙漠" end
    if zoneroom == "荆州荆州"   then zoneroom = "襄阳荆州" end
    if zoneroom == "荆州华容道" then zoneroom = "襄阳华容道" end
    if zoneroom == "荆州荆门"   then zoneroom = "襄阳荆门" end
    if zoneroom == "荆州官道" then zoneroom = "襄阳官道" end

    zoneroom=zoneroom or "none"
    local _,zone,room=RegEx(zoneroom,"^((?:北京|桃花岛|黄河南岸|湟中|少林寺|少林|杀手帮|古墓|成都|康亲王府|镇江|临安府|泰山|无量山|张家口|信阳|大轮寺|赞普|姑苏慕容|峨嵋|蒙古中部|大理城中|大理|长江北岸|长江|蒙古东部|星宿海新手|星宿|建康府南城|昆明|岳阳|归云庄|泉州|黄河北岸|凌霄城|汝阳王府|都统制府|牙山|襄阳|全真|明州|扬州|中原|神龙岛|蒙古北部|杭州提督府|荆州|平西王府|新手村|天坛|晋阳|嘉兴|福州|江州|丝绸之路|建康府北城|苏州|长安|华山村|华山|紫禁城|西湖梅庄|西湖|日月神教|天龙寺|桃源|白驼山|丐帮|麒麟村|峨眉后山|曲阜|灵州|岳王墓|南昌|关外|蒙古西部|汝阳王府|明教|灵鹫|回部|兰州|回族小镇|绝情谷|武当山|武当|洛阳|小山村|铁掌峰|荆州))(.*)")
    --荆州
    zone=zone or ""
    room=room or ""

    local format_zone={
        ["赞普"] = "大轮寺",
        ["华山村"] = "小山村",
        ["大理"] = "大理城中",
        ["明州"] = "嘉兴",
        ["武当"] = "武当山",
        ["少林"] = "少林寺",
        ["荆州"] = "襄阳", --新增20180810

    }

    if format_zone[zone] then
        zone = format_zone[zone]
    end

    room = string.match(room,"^的(.*)$") or room

    if  string.find(room,"泥人") then
        room = "泥人"
    end
    if room == "岳 飞 墓" then
        room = "岳飞墓"
    end

    return zone,room
end

--~~~~~~~~~~~~~~~~~~~~--
--     目的地遍历     --
--~~~~~~~~~~~~~~~~~~~~--
function get_room_list(zoneroom,range)

        if enter_rooms == nil or no_enter_rooms == nil then
            enter_rooms = {}
            no_enter_rooms = {}
        end

    local zone,room=break_zoneroom(zoneroom) --先分解一下
    if zone=="" and room=="" then --没分解开？
        echo("$HIW$注意未能正确识别该$HIR$房间名称$HIW$。$NOR$")
        return {},{},"",""
    elseif room=="" then --没有具体房间？那就区域搜索？【区域遍历】
        local list,center={},100


                for k,v in pairs(rooms) do
                    if v.area==zone then
                        if center == 100 then center = k end
                        if no_enter_rooms[center] then center = 100 end

                        if k~=100 then

                            if not no_enter_rooms[k] then    -- 不是禁止进入房间

                                if enter_rooms[k] then       -- 允许进入直接添加
                                    table.insert(list,k)
                                elseif k~=center and find_paths(center,k)=="" then --和周围房间不通，标注一下为禁止进入房间
                                    no_enter_rooms[k] = true -- 标志一下无法进入的房间
                                elseif k==center and find_paths(100,k)=="" then --和房间100不通，标注一下为禁止进入房间
                                    no_enter_rooms[k] = true -- 标志一下无法进入的房间
                                else
                                    enter_rooms[k] = true    -- 如果通联的话，加入列表，另外设定为允许进入房间
                                    table.insert(list,k)
                                end
                            end

                        else
                            table.insert(list,k)
                        end

                    end
                end

        list = remove_special_rooms (list)
        local list1=copytable(list)
        table.sort(list1)

        return list,list1,zone,""   --返回一个string 一个 table，万一需要用table呢

    else -- 有具体房间 和 区域 --【目的地遍历】

        local list,center={},100
        for k,v in pairs(rooms) do
            if v.area==zone and v.name==room then

                if center == 100 then center = k end
                if no_enter_rooms[center] then center = 100 end

                if k ~= 100 then
                    if not no_enter_rooms[k] then    -- 不是禁止进入房间

                        if enter_rooms[k] then       -- 允许进入直接添加
                            table.insert(list,k)
                        elseif k~=center and find_paths(center,k)=="" then --和周围房间不通，标注一下为禁止进入房间
                            no_enter_rooms[k] = true -- 标志一下无法进入的房间
                        elseif k==center and find_paths(100,k)=="" then --和房间100不通，标注一下为禁止进入房间
                            no_enter_rooms[k] = true -- 标志一下无法进入的房间
                        else
                            enter_rooms[k] = true    -- 如果通联的话，加入列表，另外设定为允许进入房间
                            table.insert(list,k)
                        end

                    end
                else
                    table.insert(list,k)

                end

            end
        end

        list = remove_special_rooms (list)
        local list1=copytable(list)

        table.sort(list1)

        return list,list1,zone,room
    end

end -- 返回 未重排房间table 重排房间table zone room

--~~~~~~~~~~~~~~~~~~~~~~~~--
--  目的地 + 深度范围遍历 --
--~~~~~~~~~~~~~~~~~~~~~~~~--
function get_searches_shendu(room_list,range,area)--得到目标房间list，周围深度为range的所有房间 【目的地+范围遍历】【深度遍历】

    if null(room_list) or type(room_list)~="table" then --null lordstar.lua 只能table格式
        return {},{},""
    end

    if null(no_enter_rooms) then
        no_enter_rooms = {}      --如果没有，就无法进入房间建立一个表
    end


    local to_explore = {}

    local check_room = 0
    for k,v in pairs(room_list) do
        if rooms[v] and not no_enter_rooms[v] and (not rooms[v].cost or rooms[v].cost<10000) then
            check_room = v
            table.insert(to_explore,v) --正常房间就加入到to_explore 表里
        end
    end

    if check_room == 0 then -- 检查room_list 里房间是否有禁止进入的，全部禁止则找不到
        return {},{},""
    end

    room_list = {}
    for k,v in pairs(to_explore) do
        table.insert(room_list,v) --重新加入以下rooms_list这次所有房间均是起点房间
    end


    range = tonumber(range) or 0 --范围
    range = range
    area  = area or ""

    local results_rooms = {}   --搜索房间的结果
    local confirm_results = {} --确认最终结果,加过结果的就不加了

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
    for key,value in ipairs(room_list) do


        local particles = {}            --搜索初始房间table

        table.insert(particles,value)   --加入第一个
        local distance = 0
        local check_distance = {}
              check_distance[value] = 0 --第一个距离0

        local explored_rooms = {}       --记录那些搜索过的房间
        local check_room = {}           --确认记录搜索结果

        if not check_room[value] and not confirm_results[value] then
            check_room[value] = true
            confirm_results[value] = true
            explored_rooms[value] = true
            table.insert(results_rooms,value) --结果也加入第一个
        end

        local new_generation = {}
        local to_explore = {}

        while #particles>0 do

            new_generation = {}

            for _,v in pairs(particles) do

                if rooms[v] then

                        for dir,dest in pairs(rooms[v].exits) do -- exits

                            if dir~="" and not string.find(dir,"cross_che") and not explored_rooms[dest] then --dir 未搜过

                                --************这里确认一下dest距离起点多少格
                                if check_distance[v] then
                                    distance = check_distance[v] + 1
                                else
                                    distance = distance + 1
                                end
                                if check_distance[dest] then
                                    check_distance[dest] = math.min(check_distance[dest],distance) --已经有了距离按照最短的计算
                                else
                                    check_distance[dest] = distance
                                end
                                --************这里确认一下dest距离起点多少格


                                if distance <= range and rooms[dest] and (rooms[dest].cost == nil or rooms[dest].cost<10000) and (area=="" or (area~="" and area == rooms[dest].area)) then

                                    if not no_enter_rooms[dest] and not check_room[dest] then

                                        check_room[dest] = true
                                        explored_rooms[dest] = true

                                        local need_to_explore_again = false

                                        for i,j in pairs(rooms[v].exits) do
                                            if not check_room[j] then

                                                need_to_explore_again = true

                                            end
                                        end

                                        if distance > range then need_to_explore_again = false end

                                        if need_to_explore_again then    --这个出口还有其他房间没遍历
                                            table.insert(to_explore,1,v) --加入到to_explore
                                            explored_rooms[v] = nil
                                        end

                                        table.insert(new_generation,1,dest) --加入到搜索队列

                                        if is_fangqi_room(dest) == false and not confirm_results[dest] then   -- 剔除一些需要放弃的房间
                                            confirm_results[dest] = true
                                            table.insert(results_rooms,dest)--加入到结果
                                        end


                                        break --跳出

                                    end


                                end

                            end  --dir
                        end -- exits

                end -- if rooms[v]

            end -- particles

            particles = new_generation

            if _G.next(particles) == nil and _G.next(to_explore) ~= nil then
                table.insert(particles,to_explore[1]) --没搜索队列，就从to_explore 拔一个进去
                table.remove(to_explore,1)            --把拔出去的删除
            end

        end --while
    end

    local results_rooms_new = copytable(results_rooms)
    table.sort(results_rooms_new)

    local check_room = table.concat(results_rooms,"|")

    to_explore,particles,new_generation,room_list,explored_rooms,check_distance,confirm_results = nil,nil,nil,nil,nil,nil,nil

    return results_rooms,results_rooms_new,check_room

end
--function   未重排, 重排, 房间列表
-----------------------------------------------------------------------------

--~~~~~~~~~~~~~~~~~~~~~~~~--
--  目的地 + 广度范围遍历 --
--~~~~~~~~~~~~~~~~~~~~~~~~--
function get_searches(_room_list,range,area)--得到目标房间list，周围深度为range的所有房间 【目的地+范围遍历】【广度遍历】

    if null(_room_list) or type(_room_list)~="table" then --null lordstar.lua 只能table格式
        return {},{},""
    end

    if null(no_enter_rooms) then
        no_enter_rooms = {} --无法进入房间建立一个表
    end

    local room_list = copytable(_room_list) --copy一份table

    local check_room=room_list[1] or 0

    if not rooms[check_room] then --第一个房间不存在
        return {},{},""
    end

    local first_room = 0
    if #room_list == 1 then
        first_room = check_room  -- 这里我吧第一个房间在加上去
    end

    range = tonumber(range) or 0 --范围
    area  = area or ""

    local particles = {}     --搜索初始房间table
    local results_rooms = {} --搜索房间table
    local depth = 0
    for k,v in ipairs(room_list) do
        particles[k] = v     --搜索开始赋值为room_list
        results_rooms[k] = v --结果赋值为room_list
    end

    local explored_rooms={}
    local new_generation={}

    while #particles>0 and depth<range do
        new_generation = {}
        depth = depth + 1
        for _,v in pairs(particles) do

            if rooms[v] then
                    for dir,dest in pairs(rooms[v].exits) do -- exits
                        if dir~="" and not string.find(dir,"cross_che") and not explored_rooms[dest] then --dir 未搜过
                        -- 含有cross_che 的地方别搜了，别坐车到其他地方了
                            explored_rooms[dest] = true

                            if rooms[dest] and rooms[dest].cost<10000 and (area=="" or (area~="" and area==rooms[dest].area)) then
                                table.insert(new_generation,dest)
                                table.insert(results_rooms,dest)
                            end

                        end  --dir
                    end -- exits

            end -- if rooms[v]

        end -- particles

        particles = new_generation
    end --while

    local searchs,searchs1,check_room = {},{},{}
    for k,v in ipairs(results_rooms) do
            if not no_enter_rooms[v] then --排除无法进入的房间, get_room_list 函数里有了
                if not check_room[v] then --排除重复房间
                    check_room[v] = true
                    table.insert(searchs,v)
                    table.insert(searchs1,v)
                end
            end
    end

    check_room = table.concat(searchs,"|")

    table.sort(searchs1) --重新排列

    results,particles,new_generation,_room_list,room_list,explored_rooms = nil,nil,nil,nil,nil,nil

    return searchs,searchs1,check_room

end--function  未重排 重排

-----------------------------------------------------------------------------


function get_bianli(search_list) --组合成遍历路径
    if null(search_list) then
        return "",""
    else
        local bianli_table={}
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

        local bianli_path = table.concat(bianli_table,";cross_for_job;")
        bianli_path = "cross_for_job;"..bianli_path .. ";cross_for_job"

        bianli_path = string.match(bianli_path,"^;(.*)") or bianli_path
        bianli_path = string.match(bianli_path,"(.*);$") or bianli_path

        bianli_table,search_list = nil,nil

        bianli_pass_rooms = string.match(bianli_pass_rooms,"^|(.+)") or bianli_pass_rooms
        bianli_pass_rooms = string.match(bianli_pass_rooms,"(.+)|$") or bianli_pass_rooms

        return bianli_path,bianli_pass_rooms

    end
end


function bianli()

    var.path_rooms={}
        local n=1
        for k in string.gmatch(var.bianli_pass_rooms.."|","(.-)|") do
            k=tonumber(k)
            var.path_rooms[n]=k
            n=n+1
        end
        --以上设置一下遍历跟随

    var.follow_rooms_fail=nil --默认没失败 nil
    var.path_after = var.bianli
    keepwalk()

end


function get_shortest_room(fromid,objname,objname2) --得到最近的房间 sleep_rooms 银行? 家?

    local config_cost_think = 1       --考虑权重设置1，不考虑设置0
    local config_scan_depth = 10000   --最大搜索深度，否则跳出循环

    objname = objname or ""
    objname2 = objname2 or ""

    local done=false --未找完
    local found=false
    local paths={} --路径表
    local explored={fromid=true}
    local cost={}
    local cost_flag={}
    local explore_dest
    local depth,count=0,0

    local toid

    local particles={{["id"]=fromid,["path"]="",["room"]=""}} --从fromid开始

    while (not done) and next(particles)~=nil and depth < config_scan_depth do

            local new_generation = {} -- 新生成的碎片
            depth=depth+1

            for _, part in ipairs (particles) do
                if rooms[part.id] then --存在这个房间
                    count=count+1
                    if next(rooms[part.id].exits)~=nil then --这个房间存在出口
                        for dir, dest in pairs(rooms[part.id].exits) do

                            if dir~="" and not explored[dest] and rooms[dest] then

                                explore_dest=true

                                --权重问题
                                if config_cost_think==1  and rooms[dest].cost~=nil and rooms[dest].cost>0 and rooms[dest].cost<10000 and cost_flag[dest]==nil then --考虑权重问题

                                        if not cost[dest] then
                                            cost[dest]={["cost"]=rooms[dest].cost,["path"]=part.path..";"..dir,["room"]=part.room.."|"..dest}
                                            cost_flag[dest]=true
                                            explore_dest=false
                                        end

                                        if cost[dest]==nil or cost[dest].cost==0 then
                                            explore_dest=true
                                        end

                                end --权重
                                --权重问题处理结束

                                if explore_dest==true then
                                    explored[dest]=true
                                    if not paths[dest] then
                                            paths[dest]=part.path..";"..dir
                                            paths[dest.."room"]=part.room.."|"..dest
                                    end

                                --  if dest==toid then --如果dest等于toid 说明找到啦
                                        --objname


                                    if string.find(rooms[dest].name,"钱庄") and (objname=="bank" or objname=="钱庄") and not string.find(paths[dest],";cross_che_cj;") and not string.find(paths[dest],";cross_che_hh;") and dest~=28 then
                                        toid=dest
                                        done=true
                                        found=true
                                    end
                                    if string.find(rooms[dest].name,"当铺") and objname=="当铺" then
                                        toid=dest
                                        done=true
                                        found=true
                                    end

                                    if string.find(rooms[dest].name,"金店") and objname=="金店" then
                                        if var.jindian_black_list and type(var.jindian_black_list)=="table" and not var.jindian_black_list[dest] then
                                            toid=dest
                                            done=true
                                            found=true
                                        end
                                    end
                                    if not string.find(rooms[dest].area,"^北京") and string.find(rooms[dest].name,"荣宝斋") and objname=="荣宝斋" then
                                        toid=dest
                                        done=true
                                        found=true
                                    end
                                    if not null(rooms[dest].objs) then

                                        for obj_name,obj_id in pairs(rooms[dest].objs) do
                                            if objname2=="" and (obj_name==objname or obj_id==objname) then --objs里找到了
                                                toid=dest
                                                done=true
                                                found=true
                                            elseif objname~="" and objname2~="" and objname == obj_name and objname2 == obj_id then
                                                toid=dest
                                                done=true
                                                found=true
                                            end

                                        end

                                    end

                                    table.insert(new_generation,{["id"]=dest,["path"]=part.path..";"..dir,["room"]=part.room.."|"..dest})

                                end

                            end

                            if done then --既然done 是true了break吧
                                break
                            end
                        end -- for 每个出口信息

                    end
                end

                if done then --既然done 是true了break吧
                    break
                end

            end -- particles for 循环

            if config_cost_think == 1 and next(cost_flag)~=nil then --cost权重处理


                    if next(new_generation)==nil then --如果新的搜索表也是空的

                        for k,v in pairs(cost) do

                            cost[k].cost=0
                            cost_flag[k]=nil
                            table.insert(new_generation,{["id"]=k,["path"]=v.path,["room"]=v.room})

                        end
                    else --如果新的搜索表非空，权重-1
                        for k,_ in pairs(cost_flag) do
                            local _cost=cost[k].cost
                            if _cost>0 then _cost=_cost-1 end

                            cost[k].cost=_cost
                            if _cost==0 and cost_flag[k] then

                                cost_flag[k]=nil
                                table.insert(new_generation,{["id"]=k,["path"]=cost[k].path,["room"]=cost[k].room})

                            end
                        end
                    end
                end --cost权重处理

                particles = new_generation
    end -- while

    if found then
        local path=paths[toid]
        local path_rooms=paths[toid.."room"]
        done,found,explored,explore_dest,particles,new_generation,paths,cost,cost_flag=nil,nil,nil,nil,nil,nil,nil,nil,nil
        path=string.match(path,"^;(.+)") or path
        path_rooms=string.match(path_rooms,"^|(.+)") or path_rooms

        return path,path_rooms,depth,count,toid --返回值有  路径   经过的房间   搜索深度  搜索总房间数

    else
        done,found,explored,explore_dest,particles,new_generation,paths,cost,cost_flag=nil,nil,nil,nil,nil,nil,nil,nil,nil
        return "","",0,0,0
    end

end --

function get_nearby_room(fromid,name) --得到最近的房间 sleep_rooms 银行? 家?

    local config_cost_think = 1       --考虑权重设置1，不考虑设置0
    local config_scan_depth = 10000   --最大搜索深度，否则跳出循环

    objname = objname or ""
    objname2 = objname2 or ""

    local done=false --未找完
    local found=false
    local paths={} --路径表
    local explored={fromid=true}
    local cost={}
    local cost_flag={}
    local explore_dest
    local depth,count=0,0

    local toid

    local particles={{["id"]=fromid,["path"]="",["room"]=""}} --从fromid开始

    while (not done) and next(particles)~=nil and depth < config_scan_depth do

            local new_generation = {} -- 新生成的碎片
            depth=depth+1

            for _, part in ipairs (particles) do
                if rooms[part.id] then --存在这个房间
                    count=count+1
                    if next(rooms[part.id].exits)~=nil then --这个房间存在出口
                        for dir, dest in pairs(rooms[part.id].exits) do

                            if dir~="" and not explored[dest] and rooms[dest] then

                                explore_dest=true

                                --权重问题
                                if config_cost_think==1  and rooms[dest].cost~=nil and rooms[dest].cost>0 and rooms[dest].cost<10000 and cost_flag[dest]==nil then --考虑权重问题

                                        if not cost[dest] then
                                            cost[dest]={["cost"]=rooms[dest].cost,["path"]=part.path..";"..dir,["room"]=part.room.."|"..dest}
                                            cost_flag[dest]=true
                                            explore_dest=false
                                        end

                                        if cost[dest]==nil or cost[dest].cost==0 then
                                            explore_dest=true
                                        end

                                end --权重
                                --权重问题处理结束

                                if explore_dest==true then
                                    explored[dest]=true
                                    if not paths[dest] then
                                            paths[dest]=part.path..";"..dir
                                            paths[dest.."room"]=part.room.."|"..dest
                                    end


                                    if rooms[dest].name==name then
                                        toid=dest
                                        done=true
                                        found=true
                                    end

                                    table.insert(new_generation,{["id"]=dest,["path"]=part.path..";"..dir,["room"]=part.room.."|"..dest})

                                end

                            end

                            if done then --既然done 是true了break吧
                                break
                            end
                        end -- for 每个出口信息

                    end
                end

                if done then --既然done 是true了break吧
                    break
                end

            end -- particles for 循环

            if config_cost_think == 1 and next(cost_flag)~=nil then --cost权重处理


                    if next(new_generation)==nil then --如果新的搜索表也是空的

                        for k,v in pairs(cost) do

                            cost[k].cost=0
                            cost_flag[k]=nil
                            table.insert(new_generation,{["id"]=k,["path"]=v.path,["room"]=v.room})

                        end
                    else --如果新的搜索表非空，权重-1
                        for k,_ in pairs(cost_flag) do
                            local _cost=cost[k].cost
                            if _cost>0 then _cost=_cost-1 end

                            cost[k].cost=_cost
                            if _cost==0 and cost_flag[k] then

                                cost_flag[k]=nil
                                table.insert(new_generation,{["id"]=k,["path"]=cost[k].path,["room"]=cost[k].room})

                            end
                        end
                    end
                end --cost权重处理

                particles = new_generation
    end -- while

    if found then
        local path=paths[toid]
        local path_rooms=paths[toid.."room"]
        done,found,explored,explore_dest,particles,new_generation,paths,cost,cost_flag=nil,nil,nil,nil,nil,nil,nil,nil,nil
        path=string.match(path,"^;(.+)") or path
        path_rooms=string.match(path_rooms,"^|(.+)") or path_rooms

        return path,path_rooms,depth,count,toid --返回值有  路径   经过的房间   搜索深度  搜索总房间数

    else
        done,found,explored,explore_dest,particles,new_generation,paths,cost,cost_flag=nil,nil,nil,nil,nil,nil,nil,nil,nil
        return "","",0,0,0
    end

end



function get_id(name)

    local id=""
    local ignore = {
        ["高僧"] = true,
        ["镖车"] = true,
        ["蒙面杀手"] = true,
        ["毫毛"] = true,
--      ["大榕树"] = true,
        ["信件"] = true,
    --  ["高僧"] = true,
    --  ["高僧"] = true,
    --  ["高僧"] = true,
    }

    if system_npc_list[name] then --path.lua 创建了这个table
        id = system_npc[name]
    elseif system_npc[name] then
        return false,id
    elseif ignore[name] then
        return id,false
    else --name.lua 获取id
        id = Name.TrancelateName(name)
    end
    if id == "" then
        print("获取id失败")
        return id,false
    end
    return id,true
end

function is_job_npc(name)

    local id = ""
    local ignore = {
        ["高僧"] = true,
        ["镖车"] = true,
        ["蒙面杀手"] = true,
        ["毫毛"] = true,
--      ["大榕树"] = true,
        ["回族长袍"] = true,
        ["飞镖"] = true,
        ["信件"] = true,
        ["金花"] = true,
    --  ["魏田虎"] = true,
    --  ["郭少柯"] = true,

    --  ["高僧"] = true,
    --  ["高僧"] = true,
    --  ["高僧"] = true,
    --  ["高僧"] = true,
    }

    if system_npc_list[name] then --path.lua 创建了这个table
        return false,id
    elseif system_npc[name] then
        return false,id
    elseif ignore[name] then
        return false,id
    else --name.lua 获取id
    --  if is_xingming(name) then
    --      return true,id
    --  else
    --      return false,id
    --  end
        id = Name.TrancelateName(name)
    end
    if id =="" then
        return false,id

    end
    return true,id
end

function is_xingming(name)
    if name == nil or name == "" then
        return false
    end

    local a = string.sub(name,1,2)
    local b = string.sub(name,1,4)
    if name_xing[a] or name_xing[b] then -- name_xing 更新在name.lua
        return true
    else
        return false
    end
end

function remove_special_rooms (list)
    if type(list)~="table" then
        return list
    else
        local new_list = {}
        local shen = var.shen or 0
        for _,v in pairs(list) do
            if v>9999 and v<10538 and rooms[v].name=="石阶" then

            elseif v>10699 and v<11020 and (rooms[v].name=="乡野小路" or rooms[v].name=="山野小径")  then

            elseif v == 2362 and var.close_map_ouyangfeng then --欧阳锋地图pass掉

            elseif (v == 1248 or v == 1249 or v == 1250) and shen < 0 then -- 负神清除陈近南房间

            else
                table.insert(new_list,v)
            end
        end
        return new_list
    end
end

function is_fangqi_room(id) --判断是不是要放弃一些房间
    if id == 2362 and var.close_map_ouyangfeng and var.close_map_ouyangfeng==1 then
        return true
    elseif id>9999 and id<10538 and rooms[id].name=="石阶" then
        return true
    elseif id>10699 and id<11020 and (rooms[id].name=="乡野小路" or rooms[id].name=="山野小径")  then
        return true
    else
        return false
    end
end

add_alias("testjob",function(p) --测试遍历  testjob 扬州北大街 张三
    var.debug=0
    var.job_zone_room=p[1]
    var.job_npc_name=p[2] or "张三"
    var.job_npc_id = get_id(var.job_npc_name)
    var.job_range = 4
    local range = 4
    local _


    local _,room_list,zone,room=get_room_list(var.job_zone_room,var.job_range)
    local a = table.concat(room_list,"|")
    print("目标房间："..a)

    local area = ""
    _,var.job_search_table=get_searches(room_list,range,area)

    local b= table.concat(var.job_search_table,"|")
    print("搜索列表:"..b)


    var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table)

    var.bianli = string.gsub(var.bianli,"cross_for_job","xixi")

    go(var.job_search_table[1],function()
        function after_goto() exe('say 遍历 '..var.job_zone_room..' 完成') end
        bianli()
    end)

end)


add_alias("testbl",function(p) --测试遍历  testbl 1
    var.debug=0
    var.job_zone_room=p[1]
    var.job_npc_name=p[2] or "张三"
    var.job_npc_id = get_id(var.job_npc_name)
    var.job_range = 4
    local range = 4
    local _

    local n = p[1]
            n = tonumber(n)
        local   area = nitem(var.zonelist,n)
        print('area'..area)
        var.job_search_table= get_room_list(area)
    --  for k,v in pairs(rooms) do
    --      if v.area==area then
    --      table.insert(var.job_search_table,k)
    --      end
    --  end
table.sort(var.job_search_table)
    local b= table.concat(var.job_search_table,"|")
    print("搜索列表:"..b)


    var.bianli,var.bianli_pass_rooms=get_bianli(var.job_search_table)

    var.bianli = string.gsub(var.bianli,"cross_for_job","xixi")

    go(var.job_search_table[1],function()
        function after_goto() exe('say 遍历 '..var.job_zone_room..' 完成') end
        bianli()
    end)

end)
system_npc_list={
["左全"] = "zuo quan",
["左金吾卫将军"] = "jin wu",
["左二把"] = "zuo erba",
["醉酒的大臣"] = "da chen",
["醉汉"] = "zui han",
["族头人"] = "zu touren",
["总管"] = "zong guan",
["总管"] = "guan",
["宗赞王子"] = "zongzan wangzi",
["紫衫使者"] = "zishan shizhe",
["紫骝马"] = "ziliu ma",
["卓秀才"] = "zhuo xiucai",
["卓松德光"] = "zayi lama",
["壮族头领"] = "zhuangzu touling",
["壮族少女"] = "shao nu",
["壮族青年"] = "qing nian",
["庄中有"] = "xueshan dizi",
["庄中杨"] = "xueshan dizi",
["庄中胜"] = "xueshan dizi",
["庄中派"] = "xueshan dizi",
["庄中凌"] = "xueshan dizi",
["庄允城"] = "zhuang yuncheng",
["庄童"] = "zhuang tong",
["庄仆"] = "zhuang pu",
["庄夫人"] = "san furen",
["庄东"] = "zhuang dong",
["庄丁"] = "zhuang ding",
["竹叶青蛇"] = "qing she",
["竹叶青"] = "zhuye qing",
["竹箫"] = "zhu xiao",
["竹青蛇"] = "she",
["竹剑"] = "zhu jian",
["竹笛"] = "zhu di",
["朱熹"] = "zhu xi",
["朱妹"] = "zhu mei",
["朱亮"] = "zhu liang",
["朱国治"] = "zhu guozhi",
["朱断云"] = "zhu duanyun",
["朱丹臣"] = "zhu danchen",
["朱聪"] = "zhu cong",
["周中雄"] = "xueshan dizi",
["周中功"] = "xueshan dizi",
["周芷若"] = "zhou zhiruo",
["周艺芝"] = "zhou yizhi",
["周五输"] = "zhou wushu",
["周侗"] = "zhou tong",
["周颠"] = "zhou dian",
["周处"] = "zhou chu",
["周伯通"] = "zhou botong",
["钟茗"] = "zhong ming",
["中年僧人"] = "seng ren",
["中年乞丐"] = "qi gai",
["中年女佣"] = "nvyong",
["中年马夫"] = "ma fu",
["中年道长"] = "zhongnian daozhang",
["制香道长"] = "zhixiang daozhang",
["志明长老"] = "zhiming zhanglao",
["执箫少女"] = "xiao",
["知客道长"] = "zhike daozhang",
["支麻鸭"] = "zhima ya",
["郑中足"] = "xueshan dizi",
["郑中派"] = "xueshan dizi",
["郑万金"] = "zheng wanjin",
["郑七灭"] = "zheng qimie",
["甄有庆"] = "zhen youqing",
["哲罗星"] = "zheluo xing",
["哲布尊巴丹"] = "huofo",
["赵中足"] = "xueshan dizi",
["赵中有"] = "xueshan dizi",
["赵中城"] = "xueshan dizi",
["赵中昌"] = "xueshan dizi",
["赵志敬"] = "zhao zhijing",
["赵云"] = "shangshan shizhe",
["赵亿同"] = "liangong dizi",
["赵一伤"] = "zhao yishang",
["赵齐贤"] = "zhao qixian",
["赵灵珠"] = "zhao lingzhu",
["赵老板"] = "zhao laoban",
["赵狗儿"] = "zhao gouer",
["赵半山"] = "zhao banshan",
["帐房先生"] = "zhangfang xiansheng",
["掌柜"] = "zhang gui",
["长枪"] = "chang qiang",
["长剑"] = "changjian",
["长鞭"] = "chang bian",
["章老三"] = "zhang laosan",
["章进"] = "zhang jin",
["张中"] = "zhang zhong",
["张志"] = "zhang zhi",
["张帐房"] = "zhang zhangfang",
["张允"] = "zhang yun",
["张小花"] = "zhang xiaohua",
["张显"] = "zhang xian",
["张无忌"] = "zhang wuji",
["张铁匠"] = "zhang tiejiang",
["张涛"] = "zhang tao",
["张松溪"] = "zhang songxi",
["张氏"] = "zhang shi",
["张三丰"] = "zhang sanfeng",
["张刘氏"] = "zhang liushi",
["张老四"] = "zhang laosi",
["张老汉"] = "zhang laohan",
["张老板"] = "zhang laoban",
["张康年"] = "zhang kangnian",
["张经"] = "zhang jing",
["张二楞"] = "zhang tiejiang",
["张德福"] = "zhang defu",
["张淡月"] = "zhang danyue",
["张翠山"] = "zhang cuishan",
["张崇威"] = "zhang chongwei",
["张阿生"] = "zhang asheng",
["摘星子"] = "zhaixing zi",
["扎卡"] = "hufa lama",
["则桑花"] = "jinxiang ke",
["枣红马"] = "zaohong ma",
["杂役尼姑"] = "zayi nigu",
["杂役道人"] = "zayi daoren",
["云中鹤"] = "yun zhonghe",
["云游僧人"] = "yunyou sengren",
["岳阳统制弓手"] = "tongzhi gongshou",
["岳阳弓手"] = "gong shou",
["岳无凝"] = "yue wuning",
["岳母"] = "yue mu",
["岳灵珊"] = "yue lingshan",
["岳不群"] = "yue buqun",
["袁天罡"] = "yuan tiangang",
["园丁"] = "yuan ding",
["御前左军士兵"] = "shi bing",
["御前右军士兵"] = "shi bing",
["御马翁"] = "yu maweng",
["狱卒"] = "yu zu",
["虞中亿"] = "xueshan dizi",
["虞中添"] = "xueshan dizi",
["虞中功"] = "xueshan dizi",
["虞中城"] = "xueshan dizi",
["渔夫"] = "yu fu",
["俞莲舟"] = "yu lianzhou",
["俞岱岩"] = "yu daiyan",
["余鱼同"] = "yu yutong",
["余婆婆"] = "yu popo",
["余玠"] = "yu jie",
["余洪兴"] = "yu hongxing",
["于中凌"] = "xueshan dizi",
["右金吾卫将军"] = "jin wu",
["酉鸡"] = "zodiac animal",
["游蛇"] = "you she",
["游人"] = "you ren",
["游客"] = "you ke",
["游方和尚"] = "youfang heshang",
["游方和尚"] = "seng ren",
["营门守军"] = "shou jun",
["营门守将"] = "shou jiang",
["英俊潇洒"] = "wulin mengzhu",
["隐者"] = "yin zhe",
["尹志平"] = "yin zhiping",
["尹霜叶"] = "yin shuangye",
["银针"] = "yin zhen",
["银丝卷"] = "yin si",
["银环蛇"] = "yinhuan she",
["殷野王"] = "yin yewang",
["殷天正"] = "yin tianzheng",
["殷梨亭"] = "yin liting",
["殷老板"] = "yin laoban",
["殷锦"] = "yin jin",
["驿站伙计"] = "huo ji",
["驿丞"] = "yi cheng",
["一等侍卫"] = "yideng shiwei",
["叶二娘"] = "ye erniang",
["业仓喜"] = "hufa lama",
["野兔"] = "ye tu",
["耶律楚材"] = "yelv chucai",
["药铺老板"] = "lao ban",
["药铺伙计"] = "yaopu huoji",
["窈娘"] = "yao niang",
["腰鼓"] = "yao gu",
["养精丹"] = "yangjing dan",
["养鸡人"] = "yangji ren",
["杨中有"] = "xueshan dizi",
["杨中盛"] = "xueshan dizi",
["杨中安"] = "xueshan dizi",
["杨永福"] = "yang yongfu",
["杨溢之"] = "yang yizhi",
["杨逍"] = "yang xiao",
["杨铁匠"] = "yang tiejiang",
["杨女"] = "yang nu",
["杨莲亭"] = "yang lianting",
["杨老板"] = "yang tiejiang",
["杨过"] = "yang guo",
["杨成协"] = "yang chengxie",
["羊肉串"] = "yangrou chuan",
["扬州炒饭"] = "yangzhou chaofan",
["扬雪儿"] = "yang xuer",
["扬铁匠"] = "yang tiejiang",
["扬冰儿"] = "yang binger",
["雁云刀"] = "yanyun blade",
["眼镜蛇"] = "she",
["颜垣"] = "yan yuan",
["严七宏"] = "yan qihong",
["严姬娴"] = "yan jixian",
["严贵绅"] = "yan guishen",
["衙役"] = "ya yi",
["牙人"] = "ya ren",
["丫鬟"] = "ya huan",
["丫环"] = "ya huan",
["巡山弟子"] = "xunshan dizi",
["巡城武将"] = "wu jiang",
["巡城守将"] = "shou jiang",
["巡城士兵"] = "shi bing",
["巡城军士"] = "xuncheng junshi",
["巡捕"] = "xun bu",
["熏田鸡"] = "tian ji",
["血刀老祖"] = "xuedao laozu",
["雪山派掌门人「威德先生」白自在"] = "bai zizai",
["雪参玉蟾丹"] = "yuchan dan",
["雪豹"] = "xue bao",
["薛老板"] = "xue laoban",
["玄真道长"] = "xuan zhen",
["玄彦大师"] = "hcc npc",
["玄难大师"] = "xuannan dashi",
["玄苦大师"] = "xuanku dashi",
["玄惠大师"] = "xuanhui dashi",
["玄慈大师"] = "xuanci dashi",
["玄悲大师"] = "xuanbei dashi",
["轩辕三光"] = "xuanyuan sanguang",
["许雪亭"] = "xu xueting",
["徐中和"] = "xueshan dizi",
["徐云生"] = "xu yunsheng",
["徐元文"] = "xu yuanwen",
["徐天宏"] = "xu tianhong",
["徐天川"] = "xu tianchuan",
["虚竹"] = "xu zhu",
["虚通"] = "xu tong",
["虚明"] = "xu ming",
["虚劫"] = "xu jie",
["虚呆"] = "xu dai",
["袖中剑"] = "xiuzhong jian",
["熊胆"] = "xiong dan",
["雄武营营官"] = "wu jiang",
["雄武营甲士"] = "jia shi",
["刑思"] = "xing si",
["星宿派号手"] = "haoshou",
["星宿派鼓手"] = "gushou",
["星宿派钹手"] = "boshou",
["辛然"] = "xin ran",
["心砚"] = "xin yan",
["谢中飞"] = "xueshan dizi",
["谢一绝"] = "xie yijue",
["谢逊"] = "xie xun",
["校尉"] = "xiao wei",
["晓晓"] = "lxiao npc",
["小昭"] = "xiao zhao",
["小丫鬟"] = "ya huan",
["小偷"] = "xiao tou",
["小童"] = "xiaotong",
["小童"] = "xiao tong",
["小唐"] = "xiao tang",
["小太监"] = "xiao taijian",
["小松鼠"] = "xiao songshu",
["小厮子"] = "xiao si",
["小厮"] = "xiao si",
["小青"] = "xiao qing",
["小妾"] = "xiao qie",
["小乞丐"] = "xiao qigai",
["小女孩"] = "little girl",
["小尼姑"] = "nigu",
["小蜜蜂"] = "little bee",
["小毛"] = "xiao mao",
["小鹿"] = "xiao lu",
["小喽罗"] = "xiao louluo",
["小龙女"] = "xiao longnu",
["小流氓"] = "punk",
["小玲"] = "xiao ling",
["小兰"] = "xiao lan",
["小鸡"] = "xiao ji",
["小伙计"] = "xiao huoji",
["小黄门"] = "xiao huangmen",
["小欢"] = "xiao huan",
["小虹"] = "xiao hong",
["小红娘"] = "xiao hongniang",
["小红"] = "xiao hong",
["小和尚"] = "xiao heshang",
["小孩"] = "xiao hai",
["小孩"] = "kid",
["小丐"] = "xiao gai",
["小贩"] = "xiao fan",
["小二"] = "xiao er",
["小道童"] = "xiao daotong",
["小道姑"] = "xiao daogu",
["小翠"] = "xiao cui",
["小宝贝"] = "bao bei",
["小白兔"] = "xiao baitu",
["萧峰"] = "xiao feng",
["萧半和"] = "xiao banhe",
["向问天"] = "xiang wentian",
["襄阳守军"] = "shou jun",
["襄阳守将"] = "shou jiang",
["冼老板"] = "xian laoban",
["冼克行"] = "xian kexing",
["闲汉"] = "xian han",
["鲜肉粽子"] = "xianrou zongzi",
["夏中雪"] = "xueshan dizi",
["夏中祥"] = "xueshan dizi",
["夏中顺"] = "xueshan dizi",
["夏中凌"] = "xueshan dizi",
["夏中进"] = "xueshan dizi",
["夏国相"] = "xia guoxiang",
["下人"] = "xia ren",
["下棋的"] = "xiaqi",
["喜来乐"] = "xi laile",
["西夏名商"] = "xixia mingshang",
["西夏公主"] = "princess",
["西夏兵"] = "xixia bing",
["西门守将"] = "shou jiang",
["舞蛇人"] = "wushe ren",
["武修文"] = "wu xiuwen",
["武三通"] = "wu santong",
["武将"] = "wu jiang",
["武虎康"] = "wu hukang",
["武馆教头"] = "wuguan jiaotou",
["武馆弟子"] = "wuguan dizi",
["武敦儒"] = "wu dunru",
["武当派真人「武当六侠」殷梨亭"] = "yin liting",
["五等侍卫"] = "wudeng shiwei",
["吴中有"] = "xueshan dizi",
["吴中雪"] = "xueshan dizi",
["吴中胜"] = "xueshan dizi",
["吴中城"] = "xueshan dizi",
["吴中昌"] = "xueshan dizi",
["吴之荣"] = "wu zhirong",
["吴应雄"] = "wu yingxiong",
["吴希真"] = "wu xizhen",
["吴檀浑"] = "wu tanhun",
["吴三桂"] = "wu sangui",
["吴六奇"] = "wu liuqi",
["吴六破"] = "wu liupo",
["无影针"] = "wuying zhen",
["无性睡觉"] = "sleep",
["无赖"] = "wu lai",
["无际"] = "vast npc",
["无根道长"] = "wugen daozhang",
["无尘道长"] = "wuchen daozhang",
["无嗔大师"] = "wuchen dashi",
["无常棒"] = "wuchang bang",
["巫医"] = "wu yi",
["倭寇"] = "wo kou",
["闻万夫"] = "wen wanfu",
["闻苍松"] = "wen cangsong",
["文月师太"] = "wenyue shitai",
["文怡师太"] = "wenyi shitai",
["文虚师太"] = "wenxu shitai",
["文心师太"] = "wenxin shitai",
["文闲师太"] = "wenxian shitai",
["文善师太"] = "wenshan shitai",
["文凌师太"] = "wenling shitai",
["温有方"] = "wen youfang",
["温有道"] = "wen youdao",
["温卧儿"] = "wenwo er",
["温峤"] = "wen qiao",
["魏官"] = "wei guan",
["卫中同"] = "xueshan dizi",
["卫中龙"] = "xueshan dizi",
["卫士长"] = "weishi zhang",
["卫春华"] = "wei chunhua",
["嵬名聿正"] = "weiming yuzheng",
["韦一笑"] = "wei yixiao",
["韦小宝"] = "wei xiaobao",
["韦春芳"] = "wei chunfang",
["忘情石"] = "wangqing shi",
["王重阳"] = "wang chongyang",
["王中志"] = "xueshan dizi",
["王中有"] = "xueshan dizi",
["王中胜"] = "xueshan dizi",
["王中城"] = "xueshan dizi",
["王语嫣"] = "wang yuyan",
["王兴隆"] = "wang xinglong",
["王小月"] = "wang xiaoyue",
["王小天"] = "wang xiaotian",
["王小二"] = "wang xiaoer",
["王武通"] = "wang wutong",
["王五"] = "wang wu",
["王铁匠"] = "wang tiejiang",
["王铁"] = "wang tie",
["王三力"] = "wang sanli",
["王裴氏"] = "wang peishi",
["王明"] = "wang ming",
["王进宝"] = "wang jinbao",
["王合计"] = "wang heji",
["王贵"] = "wang gui",
["王府执事"] = "zhi shi",
["王府卫士"] = "wei shi",
["王府侍女"] = "shi nv",
["王府仆人"] = "pu ren",
["王府门房"] = "men fang",
["王福贵"] = "wang fugui",
["王二愣"] = "wang erleng",
["王德"] = "wang de",
["王处一"] = "wang chuyi",
["王八衰"] = "wang bashuai",
["汪万翼"] = "wang wanyi",
["万年玄冰"] = "xuan bing",
["托松萨却"] = "jinxiang ke",
["托钵僧"] = "tuobo seng",
["土匪"] = "tufei",
["土匪"] = "tu fei",
["屠宰场伙计"] = "huo ji",
["屠夫"] = "tu fu",
["秃笔翁"] = "tubi weng",
["童百熊"] = "tong baixiong",
["铜人"] = "tong ren",
["铜钱镖"] = "tongqian biao",
["铜锤"] = "hammer",
["铜钹"] = "tong bo",
["铁杖"] = "tie zhang",
["铁掌帮众"] = "bang zhong",
["铁掌帮副帮主"] = "durer npc",
["铁游夏"] = "tie youxia",
["铁人"] = "tie ren",
["铁锹"] = "tie qiao",
["铁铺伙计"] = "huo ji",
["铁匠铺伙计"] = "tiejianpu huoji",
["铁匠"] = "tie jiang",
["铁甲"] = "armor",
["铁棍"] = "tiegun",
["铁斧"] = "tie fu",
["铁锤"] = "hammer",
["铁匕首"] = "tie bishou",
["贴身丫鬟"] = "ya huan",
["挑夫"] = "tiao fu",
["田伯光"] = "tian boguang",
["天天好味道"] = "jason npc",
["天神随从"] = "tianshen suicong",
["天山童姥"] = "tong lao",
["天狼子"] = "tianlang zi",
["陶生圣"] = "tao shengsheng",
["陶琨"] = "tao kun",
["趟子手"] = "tangzi shou",
["唐洋"] = "tang yang",
["唐楠"] = "tang nan",
["唐老板"] = "tang laoban",
["汤永澄"] = "tang yongcheng",
["汤怀"] = "tang huai",
["汤洪氏"] = "tang hongshi",
["谭友纪"] = "tan youji",
["谭处端"] = "tan chuduan",
["昙宗大师"] = "tan zong",
["太医"] = "taiyi",
["太叔巡捕"] = "xun bu",
["太监"] = "taijian",
["锁喉镖"] = "suohou biao",
["索额图"] = "suo etu",
["孙中顺"] = "xueshan dizi",
["孙中克"] = "xueshan dizi",
["孙万年"] = "sun wannian",
["孙思邈"] = "sun simiao",
["孙思克"] = "sun sike",
["孙三毁"] = "sun sanhui",
["孙拳"] = "sun quan",
["孙婆婆"] = "sun popo",
["孙不二"] = "sun buer",
["孙剥皮"] = "sun baopi",
["算卦先生"] = "suangua xiansheng",
["酸儒文人"] = "suanru wenren",
["酸梅汤"] = "suanmei tang",
["素衣卫士"] = "wei shi",
["素面"] = "su mian",
["素煎饺"] = "jian jiao",
["素鸡"] = "suji",
["酥油茶"] = "suyou cha",
["苏州少女"] = "girl",
["苏州女孩"] = "girl",
["苏万虹"] = "su wanhong",
["苏荃"] = "su quan",
["苏梦清"] = "su mengqing",
["苏冈"] = "su gang",
["宋远桥"] = "song yuanqiao",
["宋青书"] = "song qingshu",
["宋老板"] = "song laoban",
["松子糕"] = "songzi gao",
["松鼠"] = "song shu",
["四等侍卫"] = "sideng shiwei",
["司马卿"] = "sima qing",
["说不得"] = "shuo bude",
["水无几"] = "shui wuji",
["水桶"] = "shui tong",
["水老板"] = "shui laoban",
["水壶"] = "pot",
["水缸"] = "shui gang",
["双儿"] = "shuang er",
["书生"] = "shu sheng",
["瘦头陀"] = "shou toutuo",
["守寺僧兵"] = "seng bing",
["守山弟子"] = "shoushan dizi",
["守门武将"] = "wu jiang",
["守城校尉"] = "shoucheng xiaowei",
["守城武将"] = "wu jiang",
["守城士兵"] = "shi bing",
["侍者"] = "shi zhe",
["侍卫首领"] = "shiwei shouling",
["侍卫教头"] = "shiwei jiaotou",
["侍卫"] = "shi wei",
["侍女"] = "shi nv",
["侍从"] = "shi cong",
["仕女"] = "shi nu",
["士兵"] = "shi bing",
["史青山"] = "shi qingshan",
["史可法"] = "shi kefa",
["史春秋"] = "shi chunqiu",
["时峰亮"] = "shi fengliang",
["石宗"] = "jinxiang ke",
["石锁"] = "shi suo",
["石双英"] = "shi shuangying",
["石嫂"] = "shi sao",
["石拉巴岗"] = "zayi lama",
["石匠"] = "shi jiang",
["石碑"] = "shi bei",
["十三弦古筝"] = "gu zheng",
["施龙翼"] = "shi longyi",
["狮吼子"] = "shihou zi",
["胜谛"] = "sheng di",
["生煎馒头"] = "shengjian mantou",
["沈中亿"] = "xueshan dizi",
["沈中高"] = "xueshan dizi",
["沈千盅"] = "shen qianzhong",
["神照上人"] = "shenzhao shangren",
["神龙长老"] = "shenlong zhanglao",
["神龙羹"] = "shenlong geng",
["神灵"] = "shen ling",
["申涛"] = "shen tao",
["蛇奴"] = "she nu",
["玄慈大师"] = "xuanci dashi",
["烧饭僧"] = "shaofan seng",
["上官云"] = "shangguan yun",
["上等养精丹"] = "shangdeng yangjingdan",
["上等金创药"] = "shangdeng jinchuangyao",
["商人"] = "shang ren",
["善勇"] = "shan yong",
["珊瑚白菜"] = "shanhu baicai",
["山核桃"] = "shan hetao",
["傻姑"] = "sha gu",
["沙弥"] = "sha mi",
["沙虫"] = "sha chong",
["杀威大棒"] = "shawei bang",
["杀手帮弟子"] = "dizi",
["僧人"] = "seng ren",
["僧侣"] = "seng lv",
["扫地僧"] = "saodi seng",
["桑仲"] = "hufa lama",
["桑结"] = "sang jie",
["三等侍卫"] = "sandeng shiwei",
["赛西施"] = "sai xishi",
["瑞栋"] = "rui dong",
["蕊初"] = "rui chu",
["阮颖"] = "ruan ying",
["汝阳王妃"] = "wang fei",
["如云"] = "ru yun",
["熔炉"] = "rong lu",
["日月教众"] = "riyue jiaozhong",
["日本浪人"] = "riben langren",
["任盈盈"] = "ren yingying",
["任我行"] = "ren woxing",
["榷场管事"] = "quechang guanshi",
["全金发"] = "quan jinfa",
["曲妍"] = "qu yan",
["曲清"] = "qu qing",
["曲灵风"] = "qu lingfeng",
["裘万家"] = "qiu wanjia",
["裘千丈"] = "qiu qianzhang",
["裘千仞"] = "qiu qianren",
["丘处机"] = "qiu chuji",
["穷小贩"] = "xiao fan",
["穷汉"] = "poor man",
["擎雷杀手"] = "lei",
["清蒸鲫鱼"] = "qingzheng jiyu",
["清缘比丘"] = "qingyuan biqiu",
["清晓比丘"] = "qingxiao biqiu",
["清无比丘"] = "qingwu biqiu",
["清闻比丘"] = "qingwen biqiu",
["清为比丘"] = "qingwei biqiu",
["清水葫芦"] = "qingshui hulu",
["清善比丘"] = "qingshan biqiu",
["清乐比丘"] = "qingle biqiu",
["清观比丘"] = "qingguan biqiu",
["清风"] = "qing feng",
["清法比丘"] = "qingfa biqiu",
["清兵头目"] = "qingbing tou",
["清兵"] = "qing bing",
["青衣武士"] = "wei shi",
["青衣弟子"] = "qingyi dizi",
["青塘勇士"] = "qingtang yongshi",
["青塘士卒"] = "qingtang shizu",
["青锋剑"] = "qingfeng sword",
["秦伟邦"] = "qin weibang",
["秦桧"] = "qin hui",
["亲兵头"] = "qin bingtou",
["亲兵"] = "qin bing",
["樵夫"] = "qiao fu",
["钱庄掌柜"] = "qianzhuang zhanggui",
["钱庄伙计"] = "huo ji",
["钱中忠"] = "xueshan dizi",
["钱中彦"] = "xueshan dizi",
["钱眼开"] = "qian yankai",
["钱老本"] = "qian laoben",
["钱二败"] = "qian erbai",
["前院总管太监"] = "zong guan",
["千年松果"] = "song guo",
["千年人参"] = "qiannian renshen",
["千年灵芝"] = "ling zhi",
["乞丐"] = "qi gai",
["齐自勉"] = "qi zimian",
["齐中亿"] = "xueshan dizi",
["齐中功"] = "xueshan dizi",
["齐元凯"] = "qi yuankai",
["齐平生"] = "qi pingsheng",
["戚家军千总"] = "qian zong",
["戚继光"] = "qi jiguang",
["七弦古琴"] = "gu qin",
["七寸子蛇"] = "she",
["仆人"] = "pu ren",
["破欲"] = "po yu",
["破贪"] = "po tan",
["破慢"] = "po man",
["破痴"] = "po chi",
["破嗔"] = "po chen",
["破爱"] = "po ai",
["婆子"] = "pozi",
["泼皮"] = "po pi",
["萍水逢"] = "ping shui",
["凭吊者"] = "baixing",
["平一指"] = "ping yizhi",
["票友"] = "piao you",
["皮货商人"] = "pihuo shangren",
["皮背心"] = "pi beixin",
["彭有敬"] = "peng youjing",
["彭莹玉"] = "peng yingyu",
["彭波"] = "peng bo",
["配丹方"] = "dan fang",
["裴罗"] = "pei luo",
["陪从"] = "pei cong",
["胖头陀"] = "pang toutuo",
["胖嫂"] = "pang sao",
["潘生"] = "pan sheng",
["潘木雨"] = "pan muyu",
["欧冶子"] = "feilong bangzhu",
["欧阳克"] = "ouyang ke",
["欧阳锋"] = "ouyang feng",
["女性睡觉"] = "sleep",
["女孩"] = "girl",
["女管家"] = "guan jia",
["女赌客"] = "du ke",
["农民"] = "man",
["农家妇女"] = "woman",
["农妇"] = "woman",
["农夫"] = "nong fu",
["牛肉汤"] = "niurou tang",
["宁中则"] = "ning zhongze",
["尼摩星"] = "nimo xing",
["尼姑"] = "nigu",
["尼姑"] = "ni gu",
["内宅总管太监"] = "zong guan",
["楠木茶盅"] = "cha zhong",
["南翔小笼"] = "nanxiang xiaolong",
["南贤"] = "nan xian",
["南希仁"] = "nan xiren",
["南门守将"] = "shou jiang",
["南海神尼"] = "nanhai shenni",
["南海鳄神"] = "nanhai eshen",
["南国姑娘"] = "girl",
["南昌守门将领"] = "wu jiang",
["南昌城门守军"] = "shou jun",
["男性睡觉"] = "sleep",
["男孩"] = "boy",
["慕容能"] = "jujing bangzhu",
["慕容复"] = "murong fu",
["慕容博"] = "murong bo",
["牧羊人"] = "muyang ren",
["牧羊犬"] = "muyang quan",
["沐剑屏"] = "mu jianping",
["木卓伦"] = "muzhuolun",
["木制琵琶"] = "mu pipa",
["木鱼槌"] = "muyu chui",
["木桶"] = "mu tong",
["木人"] = "mu ren",
["牡丹茶"] = "mudan cha",
["莫中和"] = "xueshan dizi",
["莫不收"] = "mo bushou",
["陌生人薛尽忠"] = "mosheng ren",
["陌生人凌天赐"] = "mosheng ren",
["陌生人韩明"] = "mosheng ren",
["磨刀匠"] = "modao jiang",
["摩诃巴思"] = "mohe basi",
["铭文商人"] = "mingwen shangren",
["明珠"] = "ming zhu",
["明州知府"] = "zhi fu",
["明州捕快"] = "bu kuai",
["明月寒星戟"] = "mingyue ji",
["明月"] = "ming yue",
["民女"] = "min nv",
["灭绝师太"] = "miejue shitai",
["庙祝"] = "miao zhu",
["妙龄女子"] = "nv zi",
["妙回春"] = "miao huichun",
["绵羊"] = "sheep",
["蜜桃"] = "mi tao",
["蜜饯"] = "mi jian",
["蜜蜂"] = "bee",
["密汁甜藕"] = "mizhi tianou",
["麋鹿"] = "xiao lu",
["弥勒像"] = "mile xiang",
["孟之经"] = "meng zhijing",
["孟温礼"] = "jingzhao yin",
["孟珙"] = "meng gong",
["蒙帕喀"] = "hufa lama",
["蒙汗药"] = "menghan yao",
["蒙古亲兵"] = "qin bing",
["蒙古牧民"] = "mu min",
["蒙古妇女"] = "fu nu",
["蒙哥"] = "meng ge",
["门子"] = "men zi",
["门卫"] = "men wei",
["美人"] = "mei ren",
["美貌女郎"] = "nv lang",
["媒婆"] = "mei_po",
["梅老板"] = "mei laoban",
["梅剑"] = "mei jian",
["梅花鹿"] = "meihua lu",
["梅超风"] = "mei chaofeng",
["没藏讹庞"] = "mozang epang",
["牦牛"] = "mao niu",
["毛惟昌"] = "mao weichang",
["卖艺人"] = "maiyi ren",
["买卖提"] = "maimaiti",
["玛真喀图"] = "hufa lama",
["玛松业则"] = "zayi lama",
["马钰"] = "ma yu",
["马善均"] = "ma shanjun",
["马三"] = "ma san",
["马喇"] = "ma la",
["马俱为"] = "ma juwei",
["马行空"] = "ma xingkong",
["马光祖"] = "ma guangzu",
["马夫"] = "ma fu",
["马超兴"] = "ma chaoxing",
["马宝"] = "ma bao",
["麻绳"] = "ma sheng",
["麻雀"] = "maque",
["麻辣豆腐"] = "mala doufu",
["麻将馆小姐"] = "girl",
["绿竹翁"] = "lvzhu weng",
["绿营清兵"] = "qing bing",
["绿营会众"] = "lvying huizhong",
["绿衣女郎"] = "girl",
["吕文德"] = "lv wende",
["骆冰"] = "luo bing",
["鹿杖客"] = "luzhang ke",
["陆云"] = "lu yun",
["陆无双"] = "lu wushuang",
["陆世清"] = "lu shiqing",
["陆立鼎"] = "lu liding",
["陆机"] = "lu ji",
["陆冠英"] = "lu guanying",
["陆高轩"] = "lu gaoxuan",
["陆夫人"] = "lu furen",
["陆大有"] = "lu dayou",
["陆乘风"] = "lu chengfeng",
["鲁有脚"] = "lu youjiao",
["卢东月"] = "lu dongyue",
["龙珍环"] = "long zhenhuan",
["龙华天"] = "long huatian",
["遛鸟的"] = "liuniao",
["六等侍卫"] = "liudeng shiwei",
["柳大洪"] = "liu dahong",
["琉璃茄子"] = "liuli qiezi",
["流氓头"] = "liumang tou",
["流氓"] = "liu mang",
["刘中霄"] = "xueshan dizi",
["刘中胜"] = "xueshan dizi",
["刘中城"] = "xueshan dizi",
["刘老板"] = "liu laoban",
["刘坤浪"] = "liu kunlang",
["刘富贵"] = "liu fugui",
["刘处玄"] = "liu chuxuan",
["令狐涛卿"] = "linghu taoqing",
["令狐胜雪"] = "linghu shengxue",
["凌云"] = "ling yun",
["凌勇"] = "ling yong",
["凌波微步图谱"] = "lingbo-weibu",
["灵智上人"] = "lingzhi shangren",
["灵芝"] = "ling zhi",
["灵鹫宫弟子"] = "dizi",
["林震南"] = "lin zhennan",
["林涛八"] = "lin taoba",
["林平之"] = "lin pingzhi",
["林满血"] = "liangong dizi",
["猎户"] = "lie hu",
["烈火旗众"] = "qi zhong",
["廖自砺"] = "liao zili",
["梁自进"] = "liang zijin",
["梁长老"] = "liang zhanglao",
["梁丘巡捕"] = "xun bu",
["梁柳鹤"] = "liang liuhe",
["梁弘三"] = "liang hongsan",
["梁飞卿"] = "liang feiqing",
["梁发"] = "liang fa",
["炼丹人"] = "liandan ren",
["炼丹炉"] = "liandu lu",
["炼丹炉"] = "liandan lu",
["练功弟子"] = "liangong dizi",
["涟电杀手"] = "dian",
["莲花生大士"] = "lianhuasheng dashi",
["李忠"] = "li zhong",
["李中顺"] = "xueshan dizi",
["李中发"] = "xueshan dizi",
["李招财"] = "li zhaocai",
["李余"] = "li yu",
["李万山"] = "li wanshan",
["李铁嘴"] = "fortune teller",
["李天垣"] = "li tianyuan",
["李四摧"] = "li sicui",
["李四"] = "li si",
["李双海"] = "li shuanghai",
["李如一"] = "li ruyi",
["李秋水"] = "li qiushui",
["李莫愁"] = "li mochou",
["李明霞"] = "li mingxia",
["李力世"] = "li lishi",
["李老五"] = "li laowu",
["李老三"] = "li laosan",
["李可秀"] = "li kexiu",
["李斧头"] = "li futou",
["李大哥"] = "li dage",
["李大风"] = "li dafeng",
["李布衣"] = "li buyi",
["李保长"] = "li baozhang",
["礼品店小姐"] = "girl",
["黎生"] = "li sheng",
["冷谦"] = "leng qian",
["老者"] = "lao zhe",
["老丈"] = "lao zhang",
["老唐"] = "lao tang",
["老鼠"] = "lao shu",
["老艄公"] = "shao gong",
["老渠"] = "lao qu",
["老仆"] = "lao pu",
["老婆婆"] = "old woman",
["老农"] = "lao nong",
["老虎"] = "lao hu",
["老和尚"] = "lao heshang",
["老汉"] = "lao han",
["老顾"] = "lao gu",
["老妇人"] = "oldwoman",
["老夫子"] = "lao fuzi",
["老道士"] = "lao daoshi",
["老大娘"] = "old woman",
["老船家"] = "chuan jia",
["老材"] = "lao cai",
["老白"] = "lao bai",
["劳德诺"] = "lao denuo",
["浪人头目"] = "langren tou",
["浪回头"] = "lang huitou",
["郎武师"] = "lang wushi",
["兰州刺史"] = "ci shi",
["兰剑"] = "lan jian",
["蜡烛"] = "la zhu",
["昆明守城官兵"] = "guan bing",
["昆明城门守将"] = "shou jiang",
["快活三"] = "kuaihuo san",
["库房看守"] = "kufang kanshou",
["枯荣大师"] = "kurong dashi",
["孔颖达"] = "guozijian jijiu",
["孔引康"] = "kong yinkang",
["孔翘"] = "kong qiao",
["崆潮杀手"] = "chao",
["空空儿"] = "kong kong",
["客栈老板"] = "kezhan laoban",
["客卿"] = "ke qing",
["客店伙计"] = "kedian huoji",
["可怜妇人"] = "fu ren",
["柯中益"] = "xueshan dizi",
["柯中进"] = "xueshan dizi",
["柯镇恶"] = "ke zhene",
["柯万钧"] = "ke wanjun",
["烤鸡腿"] = "jitui",
["烤鸡翅"] = "kao jichi",
["康熙"] = "kang xi",
["康广陵"] = "kang guangling",
["康府侍卫"] = "shi wei",
["看守"] = "kan shou",
["看客"] = "kan ke",
["看管竹篓的弟子"] = "di zi",
["砍刀"] = "blade",
["砍柴人"] = "kanchai ren",
["巨岩"] = "ju yan",
["巨木旗众"] = "qi zhong",
["巨蟒"] = "ju mang",
["巨鲸帮帮众"] = "bang zhong",
["菊剑"] = "ju jian",
["酒神张"] = "jiushen zhang",
["酒客"] = "jiu ke",
["酒馆老板"] = "jiuguan laoban",
["酒杯"] = "jiu bei",
["鸠摩智"] = "jiumo zhi",
["静真师太"] = "jingzhen shitai",
["静照师太"] = "jingzhao shitai",
["静玄师太"] = "jingxuan shitai",
["静虚师太"] = "jingxu shitai",
["静心师太"] = "jingxin shitai",
["静闲师太"] = "jingxian shitai",
["静空师太"] = "jingkong shitai",
["静迦师太"] = "jingjia shitai",
["静慧师太"] = "jinghui shitai",
["静和师太"] = "jinghe shitai",
["静风师太"] = "jingfeng shitai",
["静道师太"] = "jingdao shitai",
["静慈师太"] = "jingci shitai",
["净难"] = "xiao shami",
["净苦"] = "xiao shami",
["净慈"] = "xiao shami",
["净悲"] = "xiao shami",
["荆门守军"] = "jingmen shoujun",
["荆浪"] = "jing lang",
["禁军战士"] = "jinjun zhanshi",
["进香客"] = "jinxiang ke",
["进香客"] = "jingxiang ke",
["锦衣卫士"] = "wei shi",
["锦衣卫"] = "jin yiwei",
["锦蛇"] = "jin she",
["锦囊"] = "jin nang",
["金庸"] = "jin yong",
["金镶玉"] = "jin xiangyu",
["金吾卫卫士"] = "jin wu",
["金丝雀"] = "sparrow",
["金群龙"] = "jin qunlong",
["金乞儿"] = "jin qier",
["金轮法王"] = "jinlun fawang",
["金环蛇"] = "jin she",
["金瓜"] = "golden hammer",
["金凤紫电戟"] = "zidian ji",
["金风"] = "jin feng",
["金刀"] = "jin dao",
["金创药"] = "jinchuang yao",
["戒尺"] = "ruler",
["街头小贩"] = "xiao fan",
["教头"] = "trainer",
["教书先生"] = "jiaoshu xiansheng",
["觉远大师"] = "jueyuan dashi",
["脚夫"] = "jiao fu",
["匠人"] = "jiang ren",
["蒋中和"] = "xueshan dizi",
["蒋中发"] = "xueshan dizi",
["蒋四根"] = "jiang sigen",
["讲经法师"] = "jiangjing fashi",
["江耀亭"] = "jiang yaoting",
["江上游"] = "jiang shangyou",
["江来福"] = "jiang laifu",
["江湖艺人"] = "jianghu yiren",
["江湖豪客"] = "jianghu haoke",
["江不二"] = "jiang buer",
["江百胜"] = "jiang baisheng",
["剑客"] = "jian ke",
["建筑商"] = "jianzhu shang",
["建宁公主"] = "jianning gongzhu",
["简长老"] = "jian zhanglao",
["尖吻蝮蛇"] = "jianwenfu she",
["贾苑琦"] = "jia yuanqi",
["贾万玉"] = "jia wanyu",
["贾老六"] = "jia laoliu",
["贾布"] = "jia bu",
["家丁"] = "jia ding",
["佳凝"] = "fae shizhe",
["鸡腿"] = "jitui",
["机关人"] = "jiguan ren",
["霍青桐"] = "huo qingtong",
["霍都"] = "huo du",
["伙计"] = "huoji",
["伙计"] = "huo ji",
["火折"] = "fire",
["火焰"] = "huo yan",
["火蛇"] = "she",
["浑天仪"] = "huntian yi",
["慧真尊者"] = "huizhen zunzhe",
["慧虚尊者"] = "huixu zunzhe",
["慧修尊者"] = "huixiu zunzhe",
["慧色尊者"] = "huise zunzhe",
["慧如尊者"] = "huiru zunzhe",
["慧名尊者"] = "huiming zunzhe",
["慧空尊者"] = "huikong zunzhe",
["慧可祖师"] = "huike laozu",
["慧洁尊者"] = "huijie zunzhe",
["慧合尊者"] = "huihe zunzhe",
["回族战士"] = "zhan shi",
["回族妇女"] = "woman",
["回鹘汉子"] = "huihu hanzi",
["回鹘贵人"] = "gui ren",
["黄钟公"] = "huangzhong gong",
["黄中栋"] = "xueshan dizi",
["黄中城"] = "xueshan dizi",
["黄中昌"] = "xueshan dizi",
["黄衣卫士"] = "wei shi",
["黄衣弟子"] = "huangyi dizi",
["黄药师"] = "huang yaoshi",
["黄鸭"] = "huang ya",
["黄铜大钟"] = "huangtong dazhong",
["黄铜大钟"] = "da zhong",
["黄铜大水缸"] = "shui gang",
["黄面道人"] = "huangmian daoren",
["黄眉僧"] = "huangmei seng",
["黄毛鬼"] = "huangmao gui",
["黄骠马"] = "huangbiao ma",
["皇太后"] = "huang taihou",
["皇宫卫士"] = "wei shi",
["皇甫阁"] = "huangpu ge",
["欢"] = "whuan npc",
["化骨针"] = "huagu zhen",
["华山弟子"] = "dizi",
["华绛"] = "hua jiang",
["华赫艮"] = "hua hegen",
["花万紫"] = "hua wanzi",
["花农"] = "hua nong",
["花老板"] = "hua laoban",
["花匠"] = "guardner",
["花季少女"] = "shao nv",
["花雕酒袋"] = "jiudai",
["护院武士领队"] = "weishi lingdui",
["护院武士"] = "wei shi",
["护院武师"] = "hu yuan",
["护寺僧人"] = "husi sengren",
["虎骨"] = "hu gu",
["蝴蝶"] = "hu die",
["葫芦"] = "hulu",
["胡有光"] = "hotion",
["胡一刀"] = "hu yidao",
["胡雪源"] = "hu xueyuan",
["胡九"] = "sui cong",
["胡金科"] = "hu jinke",
["胡姬"] = "hu ji",
["胡贵"] = "hu gui",
["胡八"] = "sui cong",
["狐狸"] = "huli",
["呼延万善"] = "huyan wanshan",
["呼延金柯"] = "huyan jinke",
["呼巴音"] = "hu bayin",
["厚土旗众"] = "qi zhong",
["猴子"] = "monkey",
["洪水旗众"] = "qi zhong",
["洪七公"] = "hong qigong",
["洪安通"] = "hong antong",
["红缨枪"] = "hongying qiang",
["红衣武士"] = "wei shi",
["红衣弟子"] = "hongyi dizi",
["红烧牛肉"] = "hongshao niurou",
["红烧狗肉"] = "gou rou",
["红花会众"] = "honghua huizhong",
["红冠鸡"] = "dou ji",
["红豆"] = "hongdou npc",
["黑鹰"] = "hei ying",
["黑衣弟子"] = "heiyi dizi",
["黑熊"] = "bear",
["黑蛇"] = "hei she",
["黑色披风"] = "heise pifeng",
["黑林钵夫"] = "heilin bofu",
["黑老板"] = "hei laoban",
["黑甲军士"] = "heijia junshi",
["黑冠巨蟒"] = "snake",
["黑白子"] = "heibai zi",
["鹤笔翁"] = "hebi weng",
["何师我"] = "he shiwo",
["何红药"] = "he hongyao",
["何不净"] = "he bujing",
["喝水"] = "drink",
["号手首领"] = "haoshou shouling",
["郝有贵"] = "hao yougui",
["郝宏捷"] = "hao hongjie",
["郝大通"] = "hao datong",
["郝巴"] = "hao ba",
["好逑汤"] = "haoqiu tang",
["豪客"] = "hao ke",
["行者"] = "xingzhe",
["汗血宝马"] = "hanxue ma",
["韩中亿"] = "xueshan dizi",
["韩中发"] = "xueshan dizi",
["韩员外"] = "han yuanwai",
["韩小莹"] = "han xiaoying",
["韩世忠"] = "han shizhong",
["韩痕"] = "han hen",
["韩宝驹"] = "han baoju",
["海公公"] = "hai gonggong",
["海法法师"] = "haifa fashi",
["哈老板"] = "ha laoban",
["过彦之"] = "guo yanzhi",
["郭中雄"] = "xueshan dizi",
["郭中添"] = "xueshan dizi",
["郭没"] = "guo mo",
["郭隆"] = "jingzhao shaoyin",
["郭靖"] = "guo jing",
["郭芙"] = "guo fu",
["龟童"] = "gui tong",
["龟奴"] = "gui nu",
["龟壳"] = "gui ke",
["归云庄武士"] = "wu shi",
["归云庄卫士"] = "wei shi",
["管事"] = "guan shi",
["管家"] = "guan jia",
["官差"] = "guan chai",
["官兵"] = "guan bing",
["观想兽"] = "guanxiang shou",
["关胜虎"] = "guan shenghu",
["关安基"] = "guan anji",
["鼓手首领"] = "gushou shouling",
["谷虚道长"] = "guxu daozhang",
["古笃诚"] = "gu ducheng",
["古董商"] = "gudong shang",
["古董店掌柜"] = "gudong zhanggui",
["古董店学徒"] = "gudong xuetu",
["古锭刀"] = "guding dao",
["苟读"] = "gou du",
["龚湘富"] = "gong xiangfu",
["宫女"] = "gongnv",
["宫女"] = "gong nu",
["宫内宿卫"] = "gongnei suwei",
["功德箱"] = "gongde xiang",
["公子哥"] = "gongzi",
["公冶乾"] = "gongye qian",
["公孙止"] = "gongsun zhi",
["公孙绿萼"] = "gongsun lve",
["公平子"] = "gongping zi",
["耿中龙"] = "xueshan dizi",
["耿万钟"] = "geng wanzhong",
["歌女"] = "ge nu",
["歌妓"] = "ge ji",
["高长老"] = "gao zhanglao",
["高彦超"] = "gao yanchao",
["高升泰"] = "gao shengtai",
["罡风杀手"] = "feng",
["钢刀"] = "blade",
["干粮"] = "gan liang",
["甘文焜"] = "gan wenkun",
["傅中凌"] = "xueshan dizi",
["傅中和"] = "xueshan dizi",
["傅思归"] = "fu sigui",
["傅快杰"] = "fu kuaijie",
["副将"] = "fu jiang",
["抚琴少女"] = "qin",
["符敏仪"] = "fu minyi",
["芙蓉花菇"] = "furong huagu",
["夫子"] = "fu zi",
["凤月刀"] = "fengyue dao",
["冯中霄"] = "xueshan dizi",
["冯正东"] = "feng zhengdong",
["冯锡范"] = "feng xifan",
["冯铁匠"] = "feng",
["蜂王"] = "feng wang",
["疯子"] = "crazy man",
["封万里"] = "feng wanli",
["封不平"] = "feng buping",
["风波恶"] = "feng boe",
["粪桶"] = "fen tong",
["汾酒"] = "fen jiu",
["费东云"] = "fei dongyun",
["翡翠甜饼"] = "feicui tianbing",
["肥鸭"] = "fei ya",
["霏云杀手"] = "yun",
["飞贼"] = "fei zei",
["飞龙帮众"] = "bang zhong",
["飞镖"] = "fei biao",
["坊丁"] = "fang ding",
["方怡"] = "fang yi",
["方天画戟"] = "fangtian ji",
["范遥"] = "fan yao",
["范骅"] = "fan ye",
["樊一翁"] = "fan yiweng",
["法正大师"] = "fazheng dashi",
["伐木道长"] = "famu daozhang",
["二张诸葛弩"] = "zhuge nu",
["二碗糯米粥"] = "nuomi zhou",
["二块硫磺"] = "liu huang",
["二颗野果"] = "ye guo",
["二具石锁"] = "shi suo",
["二件军服"] = "jun fu",
["二杆长枪"] = "chang qiang",
["二等侍卫"] = "erdeng shiwei",
["二串羊肉串"] = "yangrou chuan",
["恶狼"] = "wolf",
["恶霸"] = "e ba",
["夺命追魂枪"] = "duoming qiang",
["多卓央却"] = "jian gong",
["多隆"] = "duo long",
["断肠散"] = "duanchang san",
["段正淳"] = "duan zhengchun",
["段云四"] = "duan yunsi",
["段誉"] = "duan yu",
["段陉"] = "duan jin",
["段成彩"] = "duan chengcai",
["短弯刀"] = "duan wan dao",
["短剑"] = "duanjian",
["渡月"] = "duyue npc",
["度吐迷"] = "du tumi",
["杜凝"] = "du ning",
["杜老板"] = "du laoban",
["杜柯龙"] = "du kelong",
["独孤梦"] = "dugu meng",
["独孤彪涛"] = "dugu biaotao",
["都府亲军"] = "qin jun",
["都大锦"] = "du dajin",
["冬菜包"] = "dongcai bao",
["东门守将"] = "shou jiang",
["丁中霄"] = "xueshan dizi",
["丁坚"] = "ding jian",
["丁丁"] = "ding ding",
["丁春秋"] = "ding chunqiu",
["钓鱼人"] = "diaoyu ren",
["钓鱼老翁"] = "diaoyu laoweng",
["雕雏"] = "diao chu",
["店小二"] = "xiao er",
["第松业"] = "jinxiang ke",
["弟子"] = "dizi",
["地主老财"] = "dizhu",
["地痞"] = "dipi",
["地痞"] = "di pi",
["地保"] = "dibao",
["邓威云"] = "deng weiyun",
["邓百川"] = "deng baichuan",
["道正禅师"] = "daozheng chanshi",
["道一禅师"] = "daoyi chanshi",
["道象禅师"] = "daoxiang chanshi",
["道相禅师"] = "daoxiang chanshi",
["道童"] = "daotong",
["道士"] = "shaohuo daoshi",
["道品禅师"] = "daopin chanshi",
["道鸟禅师"] = "daoniao npc",
["道觉禅师"] = "daojue chanshi",
["道果禅师"] = "daoguo chanshi",
["道成禅师"] = "daocheng chanshi",
["道尘禅师"] = "daochen chanshi",
["盗墓高手"] = "daomu gaoshou",
["刀客"] = "dao ke",
["刀白凤"] = "dao baifeng",
["当铺伙计"] = "huo ji",
["淡妆丽人"] = "li ren",
["单刀"] = "dan dao",
["黛绮丝"] = "dai qisi",
["戴金亮"] = "dai jinliang",
["戴豹浪"] = "dai baolang",
["傣族首领"] = "daizu shouling",
["大长老"] = "da zhanglao",
["大丫鬟"] = "da yahuan",
["大土司"] = "da tusi",
["大宋官兵"] = "guan bing",
["大食商人"] = "dashi shangren",
["大内高手"] = "danei gaoshou",
["大明武将"] = "wu jiang",
["大狼狗"] = "wolf dog",
["打铁僧"] = "datie seng",
["打铁铺老板"] = "lao ban",
["打铁炉"] = "datie lu",
["打手"] = "da shou",
["达摩老祖"] = "damo laozu",
["达尔巴"] = "daer ba",
["村长"] = "cun zhang",
["村姑"] = "cun gu",
["翠花"] = "cui hua",
["崔中飞"] = "xueshan dizi",
["崔中发"] = "xueshan dizi",
["崔掌柜"] = "cui zhanggui",
["崔员外"] = "cui yuanwai",
["崔莺莺"] = "cui yingying",
["崔老汉"] = "cui laohan",
["崔百泉"] = "cui baiquan",
["崔百全"] = "cui baiquan",
["粗瓷大碗"] = "wan",
["苁?quechang guanshi;"] = "",
["磁仙鹤"] = "ci xianhe",
["慈善箱"] = "cishang xiang",
["垂钓老翁"] = "chidiao laoweng",
["船夫"] = "chuan fu",
["传功弟子"] = "chuangong dizi",
["褚中霄"] = "xueshan dizi",
["褚中克"] = "xueshan dizi",
["褚万里"] = "zhu wanli",
["褚万春"] = "chu wanchun",
["楚大业"] = "chu daye",
["厨师"] = "chu shi",
["厨娘"] = "chu niang",
["出尘子"] = "chuchen zi",
["丑雕"] = "chou diao",
["虫子"] = "chong zi",
["冲虚道长"] = "chongxu daozhang",
["池中同"] = "xueshan dizi",
["池中功"] = "xueshan dizi",
["池中高"] = "xueshan dizi",
["澄志"] = "chengzhi luohan",
["澄知"] = "chengzhi luohan",
["澄欲"] = "chengyu luohan",
["澄意"] = "chengyi luohan",
["澄信"] = "chengxin luohan",
["澄心"] = "chengxin luohan",
["澄思"] = "chengsi luohan",
["澄识"] = "chengshi luohan",
["澄尚"] = "chengshang luohan",
["澄明"] = "chengming luohan",
["澄灭"] = "chengmie luohan",
["澄灵"] = "chengling luohan",
["澄净"] = "chengjing luohan",
["澄坚"] = "chengjian luohan",
["澄寂"] = "chengji luohan",
["澄和"] = "chenghe luohan",
["澄行"] = "chengxing luohan",
["澄观"] = "chengguan luohan",
["程玉环"] = "cheng yuhuan",
["程英"] = "cheng ying",
["程药发"] = "cheng yaofa",
["程遥伽"] = "cheng yaojia",
["程青霜"] = "cheng qingshuang",
["程灵素"] = "cheng lingsu",
["城门守卫"] = "chengmen shouwei",
["成自学"] = "cheng zixue",
["成中杨"] = "xueshan dizi",
["成中龙"] = "xueshan dizi",
["成都士卒"] = "shi zu",
["成都城门官"] = "chengmen guan",
["成不忧"] = "cheng buyou",
["陈子"] = "chen zi",
["陈中志"] = "xueshan dizi",
["陈震骐"] = "chen zhenqi",
["陈玄风"] = "chen xuanfeng",
["陈小二"] = "xiao fan",
["陈叁"] = "chen san",
["陈近南"] = "chen jinnan",
["陈家洛"] = "chen jialuo",
["陈阿婆"] = "chen apo",
["常赫志"] = "chang hezhi",
["常伯志"] = "chang bozhi",
["昌昌喀"] = "zayi lama",
["茶碗"] = "wan",
["茶馆伙计"] = "chaguan huoji",
["茶馆活计"] = "huo ji",
["茶博士"] = "cha boshi",
["曾从龙"] = "zeng conglong",
["草莓"] = "cao mei",
["曹苑英"] = "cao yuanying",
["藏族牧民"] = "zangzu mumin",
["藏族妇女"] = "zangzu funv",
["藏经阁道长"] = "daozhang",
["藏獒"] = "zang ao",
["彩绸"] = "whip",
["采花子"] = "caihua zi",
["布衣神相"] = "buyi shenxiang",
["不火不毛"] = "fefe man",
["圣火令"] = "shenghuo ling",
["钹手首领"] = "boshou shouling",
["菠菜粉条"] = "bocai fentiao",
["波斯商人"] = "bosi shangren",
["兵器架"] = "bingqi jia",
["兵部侍郎"] = "bingbu shilang",
["冰雪翡翠糕"] = "gao",
["冰"] = "icer npc",
["镖头"] = "biao tou",
["镖客"] = "biao ke",
["碧玉笛"] = "biyu di",
["婢女"] = "bi nu",
["本因方丈"] = "benyin fangzhang",
["本相大师"] = "benxiang dashi",
["本观大师"] = "benguan dashi",
["本尘大师"] = "benchen dashi",
["本参大师"] = "bencan dashi",
["贝锦仪"] = "bei jinyi",
["北侠英雄大会纪念碑"] = "jinian bei",
["北侠车船通"] = "pkuxkx pass2",
["北门守将"] = "shou jiang",
["北丑"] = "bei chou",
["鲍大楚"] = "bao dachu",
["豹子"] = "baozi",
["保镖"] = "bao biao",
["宝象"] = "bao xiang",
["包子"] = "baozi",
["包轩浪"] = "bao xuanlang",
["包万叶"] = "bao wanye",
["包袱"] = "bao fu",
["包方圆"] = "bao fangyuan",
["包打听"] = "bao dating",
["包不同"] = "bao butong",
["斑头雁"] = "bantou yan",
["摆夷判官"] = "pan guan",
["摆夷女子"] = "girl",
["摆夷老叟"] = "oldman",
["百晓生"] = "bai xiaosheng",
["百草酒"] = "baicao jiu",
["白自在"] = "bai zizai",
["白中有"] = "xueshan dizi",
["白猿"] = "bai yuan",
["白衣武士"] = "wei shi",
["白衣少女"] = "white lady",
["白衣弟子"] = "baiyi dizi",
["白万剑"] = "bai wanjian",
["白兔"] = "bai tu",
["白菁菁"] = "Bai jingjing",
["白鹤"] = "bai he",
["白骨架"] = "gu jia",
["白发老人"] = "baifa laoren",
["白雕"] = "bai diao",
["白阿绣"] = "bai axiu",
["靶子"] = "ba zi",
["巴依"] = "bayi",
["巴天石"] = "ba tianshi",
["巴朗星"] = "ba langxing",
["八旗子弟"] = "baqi zidi",
["鳌拜"] = "ao bai",
["安轩林"] = "an xuanlin",
["爱爱"] = "aiai npc",
["矮长老"] = "ai zhanglao",
["阿紫"] = "a zi",
["阿朱"] = "a zhu",
["阿香"] = "a xiang",
["阿善"] = "a shan",
["阿庆嫂"] = "aqing sao",
["阿牧"] = "a mu",
["阿拉木罕"] = "alamuhan",
["阿根"] = "pu ren",
["阿凡提"] = "afanti",
["阿碧"] = "a bi",
["『星宿毒经〖上册〗』"] = "du jing",
["『襄阳城导游』"] = "luyou tu",
["『旅游指南』"] = "zhinan",
["石炭"] = "Shi tan",
["火铜"] = "Huo tong",
["镖车"] = "Biao che",
["老大娘"] = "Old woman",
["武将"] = "Wu jiang",
["铁匕首"] = "Tie bishou",

["木桩子"] = "mu zhuangzi",
["满不懂"] = "man budong",
["大丑"] = "da chou",
["二丑"] = "er chou",
["三丑"] = "san chou",
["四丑"] = "si chou",
["五丑"] = "wu chou",
["狗皮"] = "gou pi",
["钓杆"] = "diao gan",
["军服"] = "jun fu",
["戒刀"] = "jie dao",
["绣花绷架"] = "xiuhua bengjia",
["雕桌"] = "diao zhuo",
["军服"] = "jun fu",
["色愣"] = "se leng",
["野果"] = "ye guo",
["小铃铛"] = "xiao lingdang",
["硫磺"] = "liu huang",
["皮靴"] = "pi xue",
["喜鹊"] = "xi que",
["小土匪"] = "xiao tufei",
["大刀"] = "da dao",
["酸秀才"] = "suan xiucai",
["木刀"] = "mu dao",
["木剑"] = "mu jian",

["蟒蛇"] = "mang she",
["游蛇"] = "you she",
["蛇皮"] = "she pi",
["木剑"] = "mu jian",

["玉箫"] = "yu xiao",
["鱼翅"] = "yu chi",
["青葫芦"] = "qing hulu",
["帛绢"] = "bo juan",
["禅杖"] = "chan zhang",
["蛇胆"] = "she dan",
["蛇肉"] = "she rou",
["白骨"] = "bai gu",
["虎皮"] = "hu pi",
["狗皮"] = "gou pi",
--> 禅杖(Chan zhang)
--> 帛绢(Bo juan)
--> 青葫芦(Qing hulu)
--> 鱼翅(Yu chi)
--    游蛇(You she)
--> 蟒蛇(Mang she)
--> 酸秀才(Suan xiucai)
--    喜鹊(Xi que)
--> 皮靴(Pi xue)
--> 小铃铛(Xiao lingdang)
--    二颗野果(Ye guo)
--> 雕桌(Diao zhuo)
--> 绣花绷架(Xiuhua bengjia)
--> (Jie dao)
--> 军服(Jun fu)
--> 钓杆(Diao gan)
--["回族长袍"] = "huizu changpao",
--["红玫瑰"] = "red rose",
--["铁掌帮众"] = "bang zong",
}
