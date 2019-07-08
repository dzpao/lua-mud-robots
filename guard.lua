-- 特殊路径 拦路人 迷宫

add_alias("after_crush",function()
    keepwalk()
end)


add_alias("crush",function(params)

    local crush = params[-1] or ""
    local myexp = var.exp or 10000

    if var["do_stop"]==nil or var["do_stop"]==0 then

        if crush == "busy" then                 --走路有busy    -- crush busy
            wa(1,function()
                check_busy(function()
                    if var["do_stop"]==nil or var["do_stop"]==0 then
                        exe("after_crush")
                    end
                end)
            end)
        elseif string.find(crush,"wait") then   -- crush wait wd 等待某个方向
            local dir=string.match(crush,"^wait (%S+.*)$")
            if dir~="" then
                crush_wait(dir)
            end
        elseif string.find(crush,"try") then   -- crush try wd 尝试进入某个方向
            local dir=string.match(crush,"^try (%S+.*)$")
            if dir~="" then
                crush_try(dir)
            end
        elseif string.find(crush,"delay") then   -- crush delay 等待某个时间 crush delay 1.5;
            local t=string.match(crush,"^delay (%S+)$")
                  t=tonumber(t) or 1
            if t==0 then
                check_maze(function()
                    exe("after_crush")
                end)
            else
                alarm("crush_delay",t,function()
                    check_maze(function()
                        exe("after_crush")
                    end)
                end)
            end
        else
            if var["roomobj"]~=nil and next(var["roomobj"])~=nil then
                local check_guard = ""
                for k,v in pairs(var["roomobj"]) do
                    if string.find(k,"绝情谷护法弟子") and var.roomname=="后堂" then
                        check_guard = v
                        var.crush_name = string.match(k,"%s(%S+)$")
                        break
                    end
                    if crush == v and not string.find(k,"昏迷不醒") then
                        check_guard = v --检查有没有
                        var.crush_name = string.match(k,".*位(%S+)$") or string.match(k,".*」(%S+)$") or string.match(k,".*只(%S+)$") or string.match(k,".*条(%S+)$") or string.match(k,"%s(%S+)$") or  k
                        break
                    end
                end

                if check_guard ~= "" then --有拦路的
                    local newbie = var["newbie"]

                    if newbie and newbie==1 then -- 新手只提示不动手
                        echo('  $HIW$由于Lua设置了 $HIY$var["newbie"]$HIW$=$HIY$1 $HIW$不再主动叫杀，建议:$NOR$')
                        echo("  $HIR$>>killall "..check_guard.."<<$NOR$")
                    else

--                      local must_kill = "nokill"
                        local must_kill = "kill"

                        -- wang xinglong
                        if check_guard == "jian zhanglao" then -- 简长老
                            must_kill = "kill"
                            var.migong = 1
                            var.check_guard_die = "enter;lead jian zhanglao"
                        elseif check_guard == "xiao zhao" then -- 小昭
                            must_kill = "nokill"
                            var.check_guard_die = "give kissme to xiao zhao"
                        elseif check_guard == "wang xinglong" then -- 王兴隆
                            must_kill = "nokill"
                            var.check_guard_die = "give kissme to wang xinglong"
                    --  elseif string.find("mei jian|lan jian|ju jian|zhu jian|jin yiwei|danei gaoshou|shoushan dizi|xunshan dizi|qing bing|guan bing|hongyi dizi|huangyi dizi|qingyi dizi|baiyi dizi|heiyi dizi|hufa lama|men zi",check_guard) then
                    --      must_kill = "kill"
                    --      var.check_guard_die = "lead "..check_guard  --不死不休
                        elseif var.roomname and var.roomname=="后堂" then --绝情谷
                            must_kill = "kill"
                            var.check_guard_die = "lead "..check_guard  -- 不死不休
                        else
                            must_kill = "kill"
                            var.check_guard_die = "lead "..check_guard  --不死不休
                            --var.check_guard_die = "give kissme to " .. check_guard
                        end

                        print("  拦路人:"..var.crush_name.."-->"..check_guard)

                        var.crush_id = check_guard
                        var.on_crush = true

                        open_trigger("guard_1")
                        open_trigger("guard_2")

                        if must_kill == "kill" then -- 必须杀死

                            set_timer("killall",1.5,function()
                                local guardpfm = var.guardpfm or "pfm"
                                if guardpfm == "" then guardpfm = "pfm" end
                                if not var.crush_id or var.crush_id =="" then var.crush_id = "kissme" end
                                if var.crush_id ~= "kissme" then
                                    exec("killall "..var.crush_id..";"..guardpfm..";"..var.check_guard_die)
                                end
                            end)

                            local guardpfm = var.guardpfm or "pfm"
                            if guardpfm == "" then guardpfm = "pfm" end
                            if not var.crush_id or var.crush_id =="" then var.crush_id = "kissme" end
                            exec("killall "..var.crush_id..";"..guardpfm..";"..var.check_guard_die)

                        else -- 可以只打昏

                            set_timer("killall",1.5,function()
                                local guardpfm = var.guardpfm or "pfm"
                                if guardpfm == "" then guardpfm = "pfm" end
                                if not var.crush_id or var.crush_id =="" then var.crush_id = "kissme" end
                                exec("hitall "..var.crush_id..";"..guardpfm..";"..var.check_guard_die)
                            end)

                            local guardpfm = var.guardpfm or "pfm"
                            if guardpfm == "" then guardpfm = "pfm" end
                            if not var.crush_id or var.crush_id =="" then var.crush_id = "kissme" end
                            if var.crush_id ~= "kissme" then
                                exec("hitall "..var.crush_id..";"..guardpfm..";"..var.check_guard_die)
                            end
                        end
                    end
                else    -- 没有拦路的

                    if var.do_stop==nil or var.do_stop==0 then

                        var.crush_id=""
                        var.on_crush=nil
                        exe("after_crush")

                    end
                end
            else
                exe("after_crush")
            end
        end
    end
end)



--这里没有 icer npcc 。
--黑熊惨嚎一声，死了！
--金环蛇倒在地上，死了！

add_trigger("guard_1","^[> ]*你身上没有 kissme 这样东西。",function (params)
    del_timer("input")
    open_trigger("guard_3")
end)

add_trigger("guard_2","^[> ]*这里没有 (.*)。",function (p)
    if string.find(p[1],"kissme") or (var.crush_id~=nil and var.crush_id~="" and string.match(p[1],var.crush_id)) then
        del_timer("input")
        del_timer("killall")
        close_trigger("guard_1")
        close_trigger("guard_2")
        close_trigger("guard_3")
        if var.crush_id and var.crush_id=="jian zhanglao" then exe("enter") end
            check_busy(function()
                if (var.do_stop==nil or var.do_stop==0) and var.on_crush  and var.crush_id~=nil and var.crush_id~="" then
                    if var.crush_id and var.crush_id=="jian zhanglao" then var.migong=0 end
                    var.on_crush=nil
                    var.crush_id=""
                    exe("after_crush")
                end
            end)
    end
end)

add_trigger("guard_3","^[> ]*(\\S+)死了(！|。)",function (params)
    if (var.do_stop==nil or var.do_stop==0) and (string.match(params[1],"^"..var.crush_name) or string.match(var.crush_name,params[1].."$") ) and var.crush_id~=nil and var.crush_id~="" and var.on_crush then
        print("拦路人:"..var.crush_name.."-->已清除。")
        set_timer("killall",1,function()
            if var.crush_id == nil or var.crush_id =="" then var.crush_id = "kissme" end

            if var.crush_id ~= "kissme" then
                if string.find(var.check_guard_die,"kissme") then
                    exec("hitall "..var.crush_id..";"..var.check_guard_die)
                else
                    exec("killall "..var.crush_id..";"..var.check_guard_die)
                end
            end
        end)
    end
end)

close_trigger("guard_1")
close_trigger("guard_2")
close_trigger("guard_3")



--*******************--
-- 走路busy
--*******************--

function crush_wait(dir)

    var.crush_wait_dir=dir
    var.crush_wait=nil
    add_trigger("crush_wait_1","^[> ]*(\\S{4,8}几乎没有路了，你走不了那么快。|此去往东是荒郊野岭，盗贼猛兽出没之地|吊桥还没有升起来，你就这样走了|你还在.*跋涉，一时半会恐怕走不出|你小心翼翼往前挪动，遇到艰险难行处，只好放慢脚步。|青海湖畔美不胜收，你不由停下脚步，欣赏起了风景。|这个方向过不去。)",function(p)
            var.crush_wait=true
    end)
    add_trigger("crush_wait_2","^[> ]*\\S{1,2}正在【尝试路径】",function(p)
        if var.do_stop==nil or var.do_stop==0 then
            if not var.crush_wait then
                del_trigger("crush_wait_1")
                del_trigger("crush_wait_2")
                exe("after_crush")
            else
                crush_wait(var.crush_wait_dir)
            end
        end
    end)
    check_busy(function()
        alarm("input",1.4,function()
            exec(var.crush_wait_dir..";pro 你正在【尝试路径】")
        end)
    end)

end

--*******************--
-- 进入可能进不去的房间
--*******************--
function crush_try(dir)

    var.crush_wait_dir=dir
    var.crush_wait=nil

    add_trigger("crush_wait_1","^[> ]*房间中已经有人在",function(p)
            var.crush_wait=true
            if var.path_rooms and var.path_rooms[2] then
                var.follow_room = var.path_rooms[1]
                table.remove(var.path_rooms,1)
                var.follow_room = var.path_rooms[1]
                table.remove(var.path_rooms,1)
            elseif var.path_rooms then
                var.follow_room = var.path_rooms[1]
                table.remove(var.path_rooms,1)
            end
    end)
    add_trigger("crush_wait_2","^[> ]*\\S{1,2}正在【尝试进入有人房间】",function(p)
        check_maze(function()
            del_trigger("crush_wait_1")
            del_trigger("crush_wait_2")
            if not var.crush_wait then -- 正常进入小校场
                local reverse_dir = fanfangxiang(dir) --进来的反方向
                exe(reverse_dir)
                keepwalk()
            else -- 进不去
                keepwalk()
            end
        end)
    end)

    exec(var.crush_wait_dir..";pro 你正在【尝试进入有人房间】")


end

function check_fight(action)

    timers["check_fight"] = action

    add_trigger("check_fight","^[> ]*(你要吐纳多少点精血？|中央广场，禁止刷屏！|这里人多眼杂，不宜有太多动作呀。|对不起，(.*)你只能老实呆着。)",function ()
        del_timer("check_fight")
        del_trigger("check_fight")

        if type(timers["check_fight"]) == "function" then
            local f = timers["check_fight"]
            timers["check_fight"] = nil
            f()
        end
    end)

    send("respirate zzz")

    set_timer("check_fight",1,function()
        send("respirate zzz")
    end)
end
