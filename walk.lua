-- walk.lua 行走

var["walk_step"] = var["walk_step"] or 12
var["walk_wait"] = var["walk_wait"] or 0.5
var["step_wait"] = var["walk_wait"]/var["walk_step"]
var["debug"] = 0
var["newbie"] = 3

function after_goto() end         --行走完成之后的命令
function check_job_stop() end     --任务停止
function check_stop() end         --检查是否要停止，job中可以定义该函数，默认nil
function check_npc_in_maze() end  --检查迷宫有没有npc



function go(towhere,action) -- 去一个房间号，然后执行一个动作

    towhere = towhere or 0

    if action==nil then
        function after_goto() end
    else
        function after_goto() action() end
    end

    function after_gps()

        local path,path_rooms = pathfrom(var.gps,towhere)

        var.path_rooms={}
        for k in string.gmatch(path_rooms.."|","(.-)|") do
            k = tonumber(k)
            table.insert(var.path_rooms,k)
        end

        var.follow_rooms_fail = nil --默认地图跟随玩家未失败 nil

        breakpath(path)             --分解path为path_before 和 path_after
        dowalk()                    --行走
    end

    gps("go "..towhere.." 定位")

end

--**********
-- gt
--**********
function gt(towhere)
    var.do_stop = 0
    local toid = getgt(towhere) --getgt path.lua

    if toid > 0 then

        print(towhere.." "..toid )
        del_timer("idle") -- gt的时候不检测发呆
        go(toid)

    elseif toid == -1 then

    else
        echo("你无法到达:"..towhere)
    end
end

add_alias("gps",function(p)
    gps("alias GPS定位")
end)

add_alias("gt",function(p)

    local toid = getgt(p[-1]) --getgt path.lua
    if toid > 0 then
        go(toid)
    elseif toid == -1 then

    else
        echo("你无法到达:"..p[-1])
    end

end)
--**********
--  函数
--**********
function breakpath(path) --分解路径

    local walk_step = var["walk_step"] or 15
    local path_before,path_after,path_cross,path_before_raw,path_count="","","","",0

    if path~=nil and path~="" then --分解空路径？

        for match in string.gmatch(path..";","(.-);") do
            path_count=path_count+1
            path_before_raw=path_before or ""
            path_before=path_before..";"..match
            if string.find(match,"^cr") then
                path_cross=match
                path_after=string.match(";"..path,"^"..path_before.."(.+)") or ""
                path_before=path_before_raw
                break
            elseif path_count==walk_step then
                path_after=string.match(";"..path,"^"..path_before.."(.+)") or ""
                break
            end
        end
        path_after=string.match(path_after,"^;(.+)") or path_after --除去以";"开始的符号
        path_before=string.match(path_before,"^;(.+)") or path_before--除去以";"开始的符号
    end
    var["path_before"],var["path_after"],var["path_cross"],var["path_count"]=path_before,path_after,path_cross,path_count

end


function dowalk(action)

    local path = var["path_before"]

    if var.path_before == "" then

        if var.path_cross == "" then

            if type(action) == "function" then
                action()
            else

                open_trigger("walk_2")
                exe('pro 你正在【行走完成】')
                alarm("input",10,function()
                    gps("走路完成超时10秒")
                end)

            end
        else
            exec(var["path_cross"])
        end
    else
        if var["path_cross"]=="" then

            if var["path_after"]=="" then

                if type(action) == "function" then

                    exe(path)
                    action()

                else


                    open_trigger("walk_2")
                    path = path .. ";pro 你正在【行走完成】"

                    wait1(var["path_count"]+2,function()
                        check_busy(function()
                            exec(path)
                            alarm("input",10,function()
                                gps("走路快要完成超时10秒")
                            end)
                        end)
                    end)


                end
            else
                    open_trigger("walk_1")
                    path = path .. ";pro 你正在【休息一下】"

                    wait1(var["path_count"]+2,function()
                        check_busy(function()
                            exec(path)
                            alarm("input",10,function()
                                gps("走路休息超时10秒")
                            end)
                        end)
                    end)
            end
        else
                    open_trigger("walk_3")
                    path = path .. ";pro 你正在【暂停一下】"

                    wait1(var["path_count"]+2,function()
                        check_busy(function()
                            exec(path)
                            alarm("input",10,function()
                                gps("走路暂停超时10秒")
                            end)
                        end)
                    end)

        end

    end
end

add_alias("keepwalk",function() -- 继续行走keepwalk
    keepwalk()
end)

function keepwalk(action)       -- 继续行走keepwalk
    if var["do_stop"] == nil or var["do_stop"] == 0 then
        breakpath(var["path_after"]) --继续分解剩余路径
        dowalk(action) --行走路径
    end
end

--**********--
--  触发
--**********--
add_trigger("walk_1","^[> ]*\\S{1,2}正在【休息一下】",function(params)

    close_trigger("walk_1")
    del_timer("input")--判断输入的定时器

    local bbl_stop,need_stop = nil,nil
    if check_bbl ~= nil then bbl_stop = check_bbl() end    --新增bbl
    if check_stop ~= nil then need_stop = check_stop() end --检查check_stop

    if var.do_stop == nil or var.do_stop == 0 then
        if bbl_stop == nil then
            if need_stop == nil then

                    if var["wrong_way"] == nil or var["wrong_way"] == 0 then
                        check_auto_kill(keepwalk) -- gps.lua check_auto_kill
                    else
                        gps("走错路需要重新定位")
                    end

            else
                need_stop()
                need_stop = nil
            end
        else
            bbl_stop()
            bbl_stop = nil
        end
    end
end)

add_trigger("walk_2","^[> ]*\\S{1,2}正在【行走完成】",function(params) -- 走路完成

    close_trigger("walk_2")
    del_timer("input")--判断走路的定时器

    -- local neicun = collectgarbage("count")
    -- collectgarbage("collect") --整理一下lua的内存
    -- print("  内存:"..neicun.." --> "..collectgarbage("count"))

    local bbl_stop,need_stop
    if check_bbl ~= nil then bbl_stop = check_bbl() end     --新增bbl
    if check_stop ~= nil then need_stop = check_stop() end  --检查check_stop

    if var.do_stop == nil or var.do_stop == 0 then
        if bbl_stop == nil then
            if need_stop == nil then

                    if var.wrong_way and var.wrong_way ~= 0 then echo("\n"..C.x.."<Debug>:路径出错【"..var["wrong_way"].."步】") end
                    if var.wrong_way == nil or var.wrong_way == 0 then
                            after_goto()
                    else
                        gps("走路出错")
                    end

            else
                need_stop()
                need_stop = nil
            end
        else
            bbl_stop()
            bbl_stop = nil
        end
    end
end)

add_alias("after_goto",function()
    return
end)

--【3】 中途含有特殊路径"cr" (cross or crush)
add_trigger("walk_3","^[> ]*\\S{1,2}正在【暂停一下】",function(params)

    close_trigger("walk_3")
    del_timer("input")--判断走路的定时器

    local is_job_stop,job_stop,bl_stop,need_stop = check_job_stop(),nil,nil,nil
    if var["path_cross"] and var["path_cross"]=="cross_for_job" and is_job_stop ~= nil then
        job_stop = is_job_stop
    end
    -- 备注一下以免忘记, check_job_stop 只有在cross_for_job 这个alias的时候起作用

    if check_bbl ~= nil then bbl_stop = check_bbl() end    --新增bbl
    if check_stop ~= nil then need_stop = check_stop() end --需呀暂停嘛？

    if var["do_stop"] == nil or var["do_stop"] == 0 then

        if bbl_stop == nil then
            if job_stop == nil then --检查是否有job 停顿需求

                if need_stop == nil then    --检查是否需要停顿

                        if var["wrong_way"] and var["wrong_way"]~=0 then echo("\n"..C.x.."<Debug>:路径出错【"..var["wrong_way"].."步】") end
                        if var["wrong_way"]==nil or var["wrong_way"]==0 then
                            check_auto_kill(function() --清除自动叫杀
                                exec(var["path_cross"])
                            end)
                        else
                            gps("走路超时")
                        end

                else
                    need_stop()
                    need_stop = nil
                end
            else
                job_stop()
                job_stop = nil
            end
        else
            bbl_stop()
            bbl_stop = nil
        end
    end
end)


--【4】特殊中断情况
add_trigger("walk_4","^[> ]*(你要去的区域还没有连通。|哎哟，你一头撞在墙上，才发现这个方向没有出路。|你不小心被什么东西绊了一下，差点摔个大跟头。|这个方向没有出路。|只见你脚下一滑，仰面摔了个大马趴，原来你踩了个西瓜皮。|你从山上滚了下来，只觉得浑身无处不疼。|你反应迅速，急忙双手抱头，身体蜷曲。眼前昏天黑地，顺着山路直滚了下去。|你一不小心脚下踏了个空，... 啊...！|你正在路上走着，忽见右首山谷中露出一点灯火！|王夫人哼了一声：“楼上是我)",function(params)
    if var["migong"] == nil or var["migong"] == 0 then --迷宫中不管走错不走错
        var["wrong_way"] = var["wrong_way"] or 0
        var["wrong_way"] = var["wrong_way"]+1
    end
end)

add_trigger("walk_5","^[> ]*\\S{1,2}正在【行走停顿】",function (p)
    check_maze(function()
        exe("after_crush")
    end)
end)


close_trigger("walk_1")
close_trigger("walk_2")
close_trigger("walk_3")
-- 4 中断情况是常开触发
close_trigger("walk_5")


--********************--
--   任务行走函数 gg  --
--********************--

function gg(where,action)

    local toid = getgt(where) --getgt path.lua
    if toid>0 then
        go(toid,action)
    else
        echo("你无法到达:"..where)
    end
end
