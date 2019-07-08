--LordStar Lua基本模块

--~~~~~~~~~~~~~~--
--  1.变量var   --
--~~~~~~~~~~~~~~--


var = var or {}
            -- 所有变量存放在一个”var“的table里面，调用就可以var.name="lordstar" ,var['name']="lordstar", var["name"]="lordstar"
            -- 其他比如变量 a=kick 那么var[a] 相当于 var["kick"]
            -- 删除变量 var.name=nil
            -- 执行一串命令时候如果你之前有var.aa = hi ,那么可以用  exe('say @aa;haha') --可以解析这个变量

var.my_style = 1
-- 1 - 10
function get_style(s)
    if var.my_style == 1 then
        return "pro " .. s
    elseif var.my_style == 2 then
        return "response R: " .. s
    end

end

var.debug = var.debug or 0
            -- 调试参数
            -- 1 命令cmd
            -- 2 其他other
            -- 3 cmd+other

            -- 以下都含有 cmd 和 other
            -- 4 trigger
            -- 5 alias
            -- 6 timer
            -- 7 trigger alias
            -- 8 timer alias
            -- 9 trigger timer
            -- 10 trigger timer alias

marks = marks or {} --一些时间标志

C={} --颜色
C.d="$BLK$"
C.r="$RED$"
C.g="$GRN$"
C.y="$YEL$"
C.b="$BLU$"
C.m="$MAG$"
C.c="$CYN$"
C.x="$WHT$"
C.D="$NOR$"
C.R="$HIR$"
C.G="$HIG$"
C.Y="$HIY$"
C.B="$HIB$"
C.M="$HIM$"
C.C="$HIC$"
C.W="$HIW$"
C.k="$BNK$" --闪烁
C.u="$U$"   --下划线
C.v="$REV$" --反色

function echo(s)
    if (not var.no_echo or var.no_echo==0) then
--      return Echo(s)  --显示给界面，【可以被lordstar触发器】触发，可以加颜色 $HIG$ 详细见help nick
        if Show == nil then -- lordstar 3.0才有Show这个函数
            Echo(s)
        else
            return Show(s)
        end
    end
end

function print(s)
    if (not var.no_print or var.no_print==0) then
        return Print(s) --显示给界面，【不可以被触发】
    end
end

function send(s)    --send
    if var.debug and var.debug>0 then
        Print(s)
    end
    return Send(s) --发送给服务器
end

--~~~~~~~~~~~~~~~~~--
--  2.触发trigger  --
--~~~~~~~~~~~~~~~~~--

--rex = require("rex_pcre")               --载入正则模块 rex_pcre.dll

trig_rex = trig_rex or {["none"]={}}               --触发匹配表
trig_func = trig_func or {["none"]={}}             --触发内容执行function函数表
trig_disable = trig_disable or {["none"]={}}       --记录触发关闭表
reset_triggers = reset_triggers or {}   --每次匹配重置id,open close 表

line={}                                 --记录5000行历史
rawline={}                              --原始行信息,含颜色
from_server_line = ""
from_server_line_raw = ""

--last_trigger = ""

function OnReceive( raw , txt )         --服务器来信息触发
                 -- raw 原本的服务器行信息，含有颜色字符等<可用于颜色触发>
                 -- txt 处理过的服务器行信息，只含字串
--               Print("onReceive 开始")

    from_server_line = tostring(txt)      --把服务器信息转成string
    from_server_line_raw = tostring(raw)  --现在把这两行信息变成全局变量信息了，任何触发都可以使用


    local gag = RegEx(from_server_line,"^[> ]*[^\\.]{2}\\.\\.")
    if gag~="0" then
        from_server_line = string.match(from_server_line,"^.+%.%.(.*)")
        Print("诵经: "..from_server_line)
    end

    table.insert(line,1,from_server_line) --在line的table中插入第一个元素为一行信息
    line[5001] = nil                      --删除line记录5001行

    table.insert(rawline,1,from_server_line_raw)
    rawline[101] = nil                     --保存100行有颜色的信息

    reset_trigger()                       --重置所有trigger开启关闭状态
                                          --也就是说当你open_trigger("aa") close_trigger("aa") add_trigger()
                                          --只有在【下一行触发】的时候才生效!!!

    for group,v in pairs(trig_rex) do
        for id,_ in pairs(v) do
            local params,n,multi = {},"",false
            if string.find(id,"for_color") then                           --触发参数1-12， params[1] params[12] 我只写了12个，需要的另外加吧
                                                                          --简化处理颜色触发，触发器id含有    for_color
                n,params[1],params[2],params[3],params[4],params[5],params[6],params[7],params[8],params[9],params[10],params[11],params[12] = RegEx(from_server_line_raw,trig_rex[group][id])
            else
                if string.find(trig_rex[group][id],"%\\n") then -- 多行触发
                    local match_line = string.match(trig_rex[group][id],"%\\n(.-)$") or "" --不能以\\n结尾 不支持颜色多行触发
                    if match_line == "" then
                        n = "0"
                    else
                        multi = true --参数确认这是多行触发
                        n = RegEx(from_server_line,"^"..match_line)
                    end

                else
                    n,params[1],params[2],params[3],params[4],params[5],params[6],params[7],params[8],params[9],params[10],params[11],params[12] = RegEx(from_server_line,trig_rex[group][id])                     --触发参数1-12， params[1] params[12] 我只写了12个，需要的另外加吧
                end
            end

--          if params[1] then                   --匹配成功
            if n~="0" then
                if multi == false then
                        if var.debug and (var.debug==4 or var.debug==7 or var.debug>8) and not string.find(id,"room") and not string.find(id,"hp") and not string.find(id,"status") then
                            Print('<Debug>:触发器 "'..id..'" :'..trig_rex[group][id])
                        end
                        params[-1]=from_server_line     --参数-1，params[-1]就是整行
                        params[0]=from_server_line      --参数0，params[0]就是整行

                                                        -- lordstar Lua        zmud
                                                        -- params[1]            %1 or %params(1)
                                                        -- params[-1]          %-1 or %params(-1)
                        trig_func[group][id](params)
                else
                    -- 这里处理多行触发
                    local num = 0
                    for k in string.gmatch(trig_rex[group][id].."\\n","(.-)\\n") do
                        num = num + 1
                    end
                    -- 一共num 行需要触发
                    if line[num] then -- 缓冲必须有num行才行
                        local line_new = ""
                        for i=num,1,-1 do
                            line_new = line_new .. line[i]
                        end


                            local match_new = trig_rex[group][id]
                            match_new = string.gsub(match_new,"%\\n^","%\\n")
                            match_new = string.gsub(match_new,"$%\\n","%\\n")
                            match_new = string.gsub(match_new,"%\\n","")

                            n,params[1],params[2],params[3],params[4],params[5],params[6],params[7],params[8],params[9],params[10],params[11],params[12],params[13],params[14],params[15],params[16],params[17],params[18],params[19],params[20] = RegEx(line_new,match_new)

                            if n~="0" then
                                params[-1]=line_new
                                params[0]=from_server_line
                                trig_func[group][id](params)
                            end

                    end


                end
            end
        end

    end
--Print("onReceive 结束")
    --需要颜色触发的同学自己根据raw写一个把，或者直接写lordstar里面,或者id里面含有 【<<   for_color   >> 】
    --[2;37;0m[1;37m【求助】万金油[2;37;0m[1;32m(Wjyou)[2;37;0m[1;37m: find kodase[2;37;0m
    --建议在触发里面string.find(from_server_line_raw,'[1;37m【求助')
end


function add_trigger(id,trig_rex_string,trig_func_function,group) -- 添加触发
    if group == nil then
        trig_func["none"][id] = trig_func_function
        trig_disable["none"][id] = trig_rex_string
        open_trigger(id)
    else
        if trig_disable[group] == nil then
            trig_disable[group] = {}
            trig_disable[group] = {}
        end
        trig_func[group][id] = trig_func_function
        trig_disable[group][id] = trig_rex_string
        open_trigger_group(group,id)
    end
end

function open_trigger(id)   --打开触发
    reset_triggers[id] = "open"
end

function del_trigger(id)    --删除触发
    reset_triggers[id] = "delete"
end

function close_trigger(id)  --临时关闭触发
    reset_triggers[id] = "close"
end

function addtrigger(id,trig_rex_string,trig_func_function,group)   --添加触发
    if group==nil then
        trig_func["none"][id] = trig_func_function
        trig_disable["none"][id] = trig_rex_string
        open_trigger(id)
    else
        if trig_disable[group]==nil then
            trig_func[group]={}
            trig_disable[group]={}
        end
        trig_func[group][id] = trig_func_function
        trig_disable[group][id] = trig_rex_string
        open_trigger_group(group,id)
    end
end

function deltrigger(id)    --删除触发
    reset_triggers[id]="delete"
end

function closetrigger(id)  --临时关闭触发
    reset_triggers[id]="close"
end

function opentrigger(id)   --打开触发
    reset_triggers[id]="open"
end

function is_trigger(id,group)    --是触发么？
    group = group or "none"
    if trig_rex[group] and trig_rex[group][id] then
        return true
    else
        return false
    end
end

function is_trigger_closed(id,group) --触发关闭了么？
    group = group or "none"
    if trig_disable[group] and trig_disable[group][id] then
        return true
    else
        return false
    end
end

--~~~~~
-- 增加一组触发操作试试
function open_trigger_group(group,id)   --打开触发[组]
    if id==nil then
        reset_triggers[group] = "group_open"
    else
        reset_triggers[group] = "group_open_"..id
    end
end
function close_trigger_group(group,id)   --关闭触发[组]
    if id==nil then
        reset_triggers[group] = "group_close"
    else
        reset_triggers[group] = "group_close_"..id
    end
end
function del_trigger_group(group,id)     --删除触发[组]
    if id==nil then
        reset_triggers[group] = "group_delete"
    else
        reset_triggers[group] = "group_delete_"..id
    end
end
-- 增加一组触发操作试试2018.08.06
--~~~~~
function reset_trigger()       --更新触发器，【下一行生效】
    for id,v in pairs(reset_triggers) do
        if v=="open" then
            trig_rex["none"][id] = trig_disable["none"][id];

        elseif v=="close" then
            if trig_rex["none"][id] then
                trig_disable["none"][id] = trig_rex["none"][id]
            end
                trig_rex["none"][id] = nil;

        elseif v=="delete" then
            trig_rex["none"][id] = nil;
            trig_func["none"][id] = nil;
            trig_disable["none"][id] = nil;

        elseif v=="group_open" then
            trig_rex[id] = trig_disable[id];

        elseif string.find(v,"^group_open_") then
            if trig_rex[id] ==nil then trig_rex[id] ={} end
            local k = string.match(v,"^group_open_(.*)")
            trig_rex[id][k] = trig_disable[id][k];

        elseif v=="group_close" then
            if trig_rex[id] then trig_disable[id] = trig_rex[id] end
            if id~="none" then
                trig_rex[id] = nil --默认none这个组最好别删
            else
                trig_rex[id] = {}
            end

        elseif v=="group_delete" then
            trig_rex[id] = nil;
            trig_func[id] = nil;
            trig_disable[id] = nil;

        elseif string.find(v,"^group_close_") then
            if trig_rex[id] ==nil then trig_rex[id] ={} end
            local k = string.match(v,"^group_close_(.*)")
            if trig_rex[id][k]~=nil then
                trig_disable[id] = trig_disable[id] or {}
                trig_disable[id][k] = trig_rex[id][k]
                trig_rex[id][k] = nil
            end

        elseif string.find(v,"^group_delete_") then
            local k = string.match(v,"^group_delete_(.*)")
            if trig_rex[id] and trig_rex[id][k] then trig_rex[id][k] = nil end
            if trig_func[id] and trig_func[id][k] then trig_func[id][k] = nil end
            if trig_disable[id] and trig_disable[id][k] then trig_disable[id][k] = nil end
        end
    end
    reset_triggers={}  --清空reset复位table
end

--  ^[> ]*      开头
--  当不知道前面有多少个” > >“的时候建议用上述方法强制行首触发，记住就行  ^[> ]*

--  \s 等       换\\s
--  脚本中原来的正则需要转意，比如 \d变\\d   \S变\\S   \s变\\s   \D变\\D

--  (           \\(
--  匹配括号 可以用\\)

--  [           \\[
--  匹配中括号 可以用\\]

--  %           \\%
--  匹配百分号可以用\\%

--  ?           \\?
--  匹配问号可以用\\?

--  (\?:1|2|3)
--  多个选择都可以触发类zmud {aa|bb|cc}来了，可以用(\?:aa|bb|cc)

--  .*           *
--  匹配所有可能,相当于zmud的*

--  以下不管他

--  ,
--  :

--~~~~~~~~~~~~~~~~~--
--  3.定时器timer  --
--~~~~~~~~~~~~~~~~~--

timers=timers or {}

save_timer_actions={}             --保存所有定时器,格式id=function()

function call_timer_actions(s)    --主程序执行timer的指令，如 %%call_timer_actions(wait)
    if s~=nil and s~="" and save_timer_actions[s] then
        return save_timer_actions[s]()
    end
end

function killalltimer()            --杀掉所有timer
    print("Timer:清除所有定时器")
    DelMSTimer("input")
    DelMSTimer("wait")
    DelMSTimer("wait1")
    DelMSTimer("wait2")
    DelMSTimer("timer")
    DelMSTimer("alarm")
    DelMSTimer("plugin_check_busy")
    DelMSTimer("check_busy_1")
    DelMSTimer("check_busy_2")
    DelMSTimer("check_busy_3")
    DelMSTimer("check_busy_4")
    DelMSTimer("check_busy")
    DelMSTimer("idle")
    DelMSTimer("checkidle_mods")
    save_timer_actions={}
end

function add_timer(delay,f,id)     --一次性timer
    save_timer_actions[id]=f       -- 保存这个timer的action
    delay=math.ceil(delay*1000)    --时间转换为毫秒
    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 "..id.." 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay,1)
end

function addtimer(delay,f,id)     --一次性timer
    save_timer_actions[id]=f       -- 保存这个timer的action
    delay=math.ceil(delay*1000)    --时间转换为毫秒
    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 "..id.." 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay,1)
end

function del_timer(id)              --删除timer
    save_timer_actions[id]=nil
    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 "..id.." 已删除。")
    end
    return DelMSTimer(id)
end
function deltimer(id)              --删除timer
    save_timer_actions[id]=nil
    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 "..id.." 已删除。")
    end
    return DelMSTimer(id)
end

function set_timer(id,delay,action)   --设置定时器timer，无限次，不真实时间，受脚本运行速度影响 var["script_speed"]=1

    local script_speed = var["script_speed"] or 1
    save_timer_actions[id]=action
    delay=math.ceil(delay*script_speed*1000)
    delay=math.max(200,delay)

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 "..id.." 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay)

end
function settimer(id,delay,action)   --设置定时器timer，无限次，不真实时间，受脚本运行速度影响 var["script_speed"]=1

    local script_speed = var["script_speed"] or 1
    save_timer_actions[id]=action
    delay=math.ceil(delay*script_speed*1000)
    delay=math.max(200,delay)

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 "..id.." 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay)

end

function set_timer2(id,delay,action)  --设置定时器timer，无限次，真实时间

    save_timer_actions[id]=action
    delay=math.ceil(delay*1000)

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 "..id.." 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay)

end
function settimer2(id,delay,action)  --设置定时器timer，无限次，真实时间

    save_timer_actions[id]=action
    delay=math.ceil(delay*1000)

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 "..id.." 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay)

end

function unset_timer(id)               --删除定时器timer
    del_timer(id)
end
function unsettimer(id)                 --删除定时器timer
    del_timer(id)
end
function untimer(id)                    --删除定时器timer
    del_timer(id)
end

function delay(delays,action)           --等待wait，改名称为【delay】，防止和mc的wait.lua 冲突？

    local script_speed = var["script_speed"] or 1
    local id="delay"
    save_timer_actions[id]=action
    delays=math.ceil(delays*script_speed*1000)
    delays=math.max(1,delays)

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 delay 延时 "..delays.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delays,1)

end

function wa(delays,action)              --等待wait，改名称为【wa】，防止和mc的wait.lua 冲突？

    local script_speed  =var["script_speed"] or 1
    local id="delay"
    save_timer_actions[id]=action
    delays=math.ceil(delays*script_speed*1000)
    delays=math.max(1,delays)

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 delay 延时 "..delays.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delays,1)

end
function unwa()
    del_timer("delay")
end
function unwait()
    del_timer("delay")
end
function undelay()
    del_timer("delay")
end

function wait1(steps,action)           --wait1 按照指定步长等待

    local id="wait1"
    save_timer_actions[id]=action

    local script_speed =var["script_speed"] or 1
    local step_wait=var["step_wait"] or 15
    local delay=math.ceil(steps*script_speed*step_wait*1000)
          delay=math.max(1,delay)

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 wait1 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay,1)

end

function wait3(steps,action)           --wait2 按照指定步长等待

    local id="wait3"
    save_timer_actions[id]=action

    local script_speed =var["script_speed"] or 1
    local step_wait=var["step_wait"] or 15
    local delay=math.ceil(steps*script_speed*step_wait*1000)
          delay=math.max(1,delay)

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 wait1 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay,1)

end
function unwait3()
    del_timer("wait3")
end

function wa1(steps,action)           --wait1 按照指定步长等待

    local id="wait1"
    save_timer_actions[id]=action

    local script_speed =var["script_speed"] or 1
    local step_wait =var["step_wait"] or 15
    local delay=math.ceil(steps*script_speed*step_wait*1000)
          delay=math.max(1,delay)

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 wait1 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay,1)

end
--删除wait1
function unwait1()
    del_timer("wait1")
end
function unwa1()
    del_timer("wait1")
end
--等待wait2
function wait2(delay,action)

    local script_speed =var["script_speed"] or 1
    save_timer_actions[id]=action
    delay=math.ceil(delay*script_speed*1000)
    delay=math.max(1,delay)
    local id="wait2"

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 wait2 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay,1)

end
function wa2(delay,action)

    local script_speed =var["script_speed"] or 1
    save_timer_actions[id]=action
    delay=math.ceil(delay*script_speed*1000)
    delay=math.max(1,delay)
    local id="wait2"

    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器 wait2 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay,1)

end
--删除wait2
function unwait2()

    del_timer("wait2")
end
function unwa2()
    del_timer("wait2")
end

--zmud #alarm
function alarm(id,delay,action) --一次性alarm吧，多次用timer，alarm是真实时间

    save_timer_actions[id]=action
    delay=math.ceil(delay*1000)
    delay=math.max(1,delay)
    id=id or "alarm"
    if var["debug"] and (var["debug"]==6 or var["debug"]>7) then
        Print("\n<Debug>:定时器Alarm "..id.." 延时 "..delay.." 毫秒。")
    end
    return AddMSTimer(id,"%%call_timer_actions("..id..")",delay,1)


end

--zmud unalarm
function unalarm(id)
    del_timer(id)
end

--~~~~~~~~~~~~~~~~~--
--  4.别名alias    --
--~~~~~~~~~~~~~~~~~--

alias = alias or {}--alias 表


function OnSend(cmd)  -- 执行客户端送来指令cmd
    cmd=tostring(cmd)
    if var["debug"] and var["debug"]>0 then
        Print(cmd)
    end

    for match in string.gmatch(cmd..";","(.-);") do
        if string.match(match,"(#%d+)%s-.+") then
        local alias_times=string.match(match,"#(%d+)%s.+")
        local alias_action=string.match(match,"#%d+%s(.+)")
            for i=1,times do
                if string.match(alias_action,"(%S+)") and string.match(alias_action,"(%S+)")~="" and alias[string.match(alias_action,"(%S+)")] then
                    local i=0
                    local params={"","","","","","","","","","","","","",""}
                    for match in string.gmatch(alias_action,"(%S+)") do
                        params[i]=expand(match)
                        i=i+1
                    end

                    if alias[params[0]] then
                        if var.debug and (var.debug==5 or var.debug==7 or var.debug==8 or var.debug>9) then
                            Echo("$HIW$<Debug>:Alias: "..params[0])
                        end
                        params[-1] = string.match(alias_action,"^"..params[0].." (.+)")
                        if params[-1] then  params[-1]= expand(params[-1]) end
                            alias[params[0]](params)
                            return false
                    end

                end
            end
        else
            if string.match(match,"(%S+)") and string.match(match,"(%S+)")~="" and alias[string.match(match,"(%S+)")] then
                    local i=0
                    local matchs
                    local params={"","","","","","","","","","","","","",""}
                    for matchs in string.gmatch(match,"(%S+)") do
                        params[i]=expand(matchs)
                        i=i+1
                    end

                    if alias[params[0]] then
                        if var.debug and (var.debug==5 or var.debug==7 or var.debug==8 or var.debug>9) then
                            Echo("$HIW$<Debug>:Alias: "..params[0])
                        end
                        params[-1] = string.match(match,"^"..params[0].." (.+)")
                        if params[-1] then  params[-1]= expand(params[-1]) end
                            alias[params[0]](params)
                            return false
                    end

                end
        end
    end

end


--2)增加alias
function add_alias(cmd,alias_function)
    alias[cmd]=alias_function
end

--3)删除alias
function del_alias(cmd)
    alias[cmd]=nil
end
--2)增加alias
function addalias(cmd,alias_function)
    alias[cmd]=alias_function
end

--3)删除alias
function delalias(cmd)
    alias[cmd]=nil
end

is_lordstar_alias = {} --是不是ls的alias，优先于lua alias执行
--4)执行cmd
function exec_alias(cmd)
        if string.match(cmd,"(%S+)") and string.match(cmd,"(%S+)")~="" and alias[string.match(cmd,"(%S+)")] then
                local i=0
                local params={"","","","","","","","","",""}
                for match in string.gmatch(cmd,"(%S+)") do
                        params[i]=expand(match)
                        i=i+1
                end

                -- local check_lordstar_alias=GetAlias(params[0]) or ""
                if 1==0 and check_lordstar_alias~="" then
                    Run(cmd)
                else

                    if alias[params[0]] then
                            if var.debug and (var.debug==5 or var.debug==7 or var.debug==8 or var.debug>9) then
                                Echo("$HIW$<Debug>:Alias: "..params[0])
                            end
                            params[-1] = string.match(cmd,"^"..params[0].." (.+)")
                            if params[-1] then  params[-1]= expand(params[-1]) end
                            alias[params[0]](params)
                    end

                end
        else
            send(expand(cmd))
        end
end

--5)分解解析alias指令by";",然后执行,可以解析#10 w
function exec(cmd,t)
        if t~=nil and type(t)=="number" then
            alarm("input",t,function() --启用一个input 计时器，时间为t，收到触发请及时，del_timer("input")
                exec(cmd)
            end)
        end
        for match in string.gmatch(cmd..";","(.-);") do
                if string.match(match,"(#%d+)%s-.+") then
                local times=string.match(match,"#(%d+)%s.+")
                local action=string.match(match,"#%d+%s(.+)")
                        for i=1,times do
                                exec_alias(action)
                        end
                else
                        exec_alias(match)
                end
        end
end

function exes(cmd,t)
        if t~=nil and type(t)=="number" then
            alarm("input",t,function() --启用一个input 计时器，时间为t，收到触发请及时，del_timer("input")
                exes(cmd)
            end)
        end
        for match in string.gmatch(cmd..";","(.-);") do
                if string.match(match,"(#%d+)%s-.+") then
                local times=string.match(match,"#(%d+)%s.+")
                local action=string.match(match,"#%d+%s(.+)")
                        for i=1,times do
                                exec_alias(action)
                        end
                else
                        exec_alias(match)
                end
        end
end

function exe(cmd,t) --和exes一样
        if t~=nil and type(t)=="number" then
            alarm("input",t,function() --启用一个input 计时器，时间为t，收到触发请及时，del_timer("input")
                exe(cmd)
            end)
        end
        for match in string.gmatch(cmd..";","(.-);") do
                if string.match(match,"(#%d+)%s-.+") then
                local times=string.match(match,"#(%d+)%s.+")
                local action=string.match(match,"#%d+%s(.+)")
                        for i=1,times do
                                exec_alias(action)
                        end
                else
                        exec_alias(match)
                end
        end
end
--6)展开变量by @
function expand(cmd)
    if string.match(cmd,"@%S+") then
        cmd=string.gsub(cmd,"@([%w_]+)",var) --变量只能由字母 数字 下划线组成，其他不认识，比如@hha_1
        cmd=string.gsub(cmd,"@([%w_]+)","")  --没找到的var 为空
        return cmd
    else
        return cmd
    end
end

--##以下定义一些alias##--

--var listv查看变量
--trigger listt tri查看触发器
--setconfig 打开设置文件
--loadconfig 导入设置
--lista 查看alias
--listi 查看身上的物品
--setvar set_var 设置变量
--getvar get_var 显示变量

add_alias("var",function (p)
    Print("Lua 变量")

    local count=0
    for k,v in pairs(var) do
        if type(v)=="number" or type(v)=="string" then
            Print(k.." = "..v..",")
        else
            Print(k.." = "..type(v)..",")
        end
        count=count+1
    end

    Print("Lua 变量数"..count)
end)

add_alias("setconfig",function(p)

    setconfig()

end)
add_alias("loadsetting",function(p)

    loadsetting()

end)
add_alias("listv",function(p)

    for k,v in pairs(var) do
        if type(v)=="string" or type(v)=="number" then
            Print("#var "..k.." = "..v)
        else
            Print("#var "..k.." = "..tostring(v))
        end

    end
    Print("  以上变量")

end)

add_alias("listt",function(p)

    for i,j in pairs(trig_rex) do
    for k,v in pairs(j) do

            Print("#trigger "..k.." = "..v.." <--"..i)


    end
    end
    Print("  以上触发")

end)

add_alias("trigger",function(p)

    for i,j in pairs(trig_rex) do
    for k,v in pairs(j) do

            Print("#trigger "..k.." = "..v.." <--"..i)


    end
    end
    Print("  以上触发")

end)

add_alias("tri",function(p)

    for i,j in pairs(trig_rex) do
    for k,v in pairs(j) do

            Print("#trigger "..k.." = "..v.." <--"..i)


    end
    end
    Print("  以上触发")

end)

add_alias("lista",function(p)

    for k,v in pairs(alias) do

            Print("#alias "..k.." = "..tostring(v))


    end
    Print("  以上别名")

end)

add_alias("listi",function(p)

    for k,v in pairs(item) do

            Print("item物品 "..k.." = "..tostring(v))


    end
    Print("  以上物品")

end)

add_alias("listjifa",function(p)

    for k,v in pairs(var.jifa) do

            Print("  "..k.." = "..tostring(v))


    end
    Print(" 以上 jifa")

end)
add_alias("listskills",function(p)

    for k,v in pairs(var.skills_level) do

            Print("  "..k.." = "..tostring(v) .." max "..var.skills_maxlevel[k])


    end
    Print(" 以上 jifa")

end)

add_alias("set_var",function(p)
    local l,w=string.match(p[-1],"^(%S+) "),string.match(p[-1],"^%S+ (.+)")
    if l~=nil and w~=nil and l~="" and w~="" then
        if tonumber(w)==nil then
            var[l]=w
            print("  "..l.." = "..w)
        else
            var[l]=tonumber(w)
            print("  "..l.." = "..w)
        end
    end
end)
add_alias("setvar",function(p)
    local l,w=string.match(p[-1],"^(%S+) "),string.match(p[-1],"^%S+ (.+)")
    if l~=nil and w~=nil and l~="" and w~="" then
        if tonumber(w)==nil then
            var[l]=w
            print("  "..l.." = "..w)
        else
            var[l]=tonumber(w)
            print("  "..l.." = "..w)
        end
    end
end)

function set_var(l,w)
    if l~=nil and w~=nil and l~="" and w~="" then
        if tonumber(w)==nil then
            var[l]=w
            print("  "..l.." = "..w)
        else
            var[l]=tonumber(w)
            print("  "..l.." = "..w)
        end
    end

end
function setvar(l,w)
    if l~=nil and w~=nil and l~="" and w~="" then
        if tonumber(w)==nil then
            var[l]=w
            print("  "..l.." = "..w)
        else
            var[l]=tonumber(w)
            print("  "..l.." = "..w)
        end
    end

end
function add_var(l,w)
    if l~=nil and w~=nil and l~="" and w~="" then
        if tonumber(w)==nil then
            var[l]=w
            print("  "..l.." = "..w)
        else
            var[l]=tonumber(w)
            print("  "..l.." = "..w)
        end
    end

end
function addvar(l,w)
    if l~=nil and w~=nil and l~="" and w~="" then
        if tonumber(w)==nil then
            var[l]=w
            print("  "..l.." = "..w)
        else
            var[l]=tonumber(w)
            print("  "..l.." = "..w)
        end
    end

end

add_alias("getvar",function(p)
    local l=p[-1]
    if l~=nil and l~="" then
        if var[l] then
            print("变量: "..l.." = "..var[l])
--          return var[l]
        end
    end
    print("变量: "..l.." = 无")
--  return ""
end)

add_alias("get_var",function(p)
    local l=p[-1]
    if l~=nil and l~="" then
        if var[l] then
            print("变量: "..l.." = "..var[l])
--          return var[l]
        end
    end
    print("变量: "..l.." = 无")
--  return ""
end)

function getvar(l)
    if l~=nil and l~="" then
        if var[l] then
    --      print("变量: "..l.." = "..var[l])
            return var[l]
        end
    end
--  print("变量: "..l.." = 无")
    return ""
end
function get_var(l)
    if l~=nil and l~="" then
        if var[l] then
            print("变量: "..l.." = "..var[l])
            return var[l]
        end
    end
    print("变量: "..l.." = 无")
    return ""
end

--##以上常用alias##--

--~~~~~~~~~~~~~~~~~--
--  5.检查busy     --
--~~~~~~~~~~~~~~~~~--


function check_busy(action)
    timers["check_busy"]=action
    open_trigger("check_busy_1")
    if var.roomname and var.roomname =="洗象池边" then
        return check_busy3(action)
    else
        send("checkbusy")
        --  send("qiecuo 11 22 33")
        set_timer("check_busy_1",1,function()
        send("checkbusy")
        --  send("qiecuo 11 22 33")
        end)
    end
end


function check_busy2(action)
    timers["check_busy2"]=action
    open_trigger("check_busy_2")
    send("jifa jifa jifa")
    set_timer("check_busy_2",1,function()
        send("jifa jifa jifa")
    end)
end

function check_busy3(action)
    timers["check_busy"]=action
    open_trigger("check_busy_1")
    send("checkbusy")
    set_timer("check_busy_1",1,function()
        send("checkbusy")
    end)
end

function check_busy4(action)
    timers["check_busy4"]=action
    open_trigger("check_busy_4")
    send("hpbrief")
    set_timer("check_busy_4",1,function()
        send("hpbrief")
    end)
end

function b(action) --学习zmud 简化check_busy 用b
    timers["check_busy"]=action
    open_trigger("check_busy_1")
    send("halt")
    set_timer("check_busy_1",1,function()
        send("halt")
    end)
end
function bb(action) --学习zmud 简化check_busy 用bb
    timers["check_busy2"]=action
    open_trigger("check_busy_2")
    send("jifa jifa jifa")
    set_timer("check_busy_2",1,function()
        send("jifa jifa jifa")
    end)
end


-- check_busy 定时输入halt，成功以后执行
add_trigger("check_busy_1","^[> ]*(你二人以性命相搏，岂能说停就停！|你现在不忙。|你不忙)",function (params)
--  print("check_busy_1-->你现在不忙。")
    close_trigger("check_busy_1")
    del_timer("check_busy_1")

    if type(timers["check_busy"])=="function" then
        local f=timers["check_busy"]
        timers["check_busy"]=nil
        f()
    end
end)

add_trigger("check_busy_2","^[> ]*没有这个技能种类，用 enable",function (params)
    close_trigger("check_busy_2")
    del_timer("check_busy_2")

    if type(timers["check_busy2"])=="function" then
        local f=timers["check_busy2"]
        timers["check_busy"]=nil
        f()
    end
end)

add_trigger("check_busy_4","^[> ]*#.*非战斗\\,不忙",function (params)
    close_trigger("check_busy_4")
    del_timer("check_busy_4")

    if type(timers["check_busy4"])=="function" then
        local f=timers["check_busy4"]
        timers["check_busy4"]=nil
        f()
    end
end)
close_trigger("check_busy_1")--触发常闭
close_trigger("check_busy_2")--触发常闭
close_trigger("check_busy_4")--触发常闭
--~~~~~~~~~~~~~~~~~--
--  6.常用函数     --
--~~~~~~~~~~~~~~~~~--

--每个人喜欢的函数都不同，自己写自己常用的吧
--转移到function.lua




--~~~~~~~~~~~~~~~~~--
--  6.常用设置     --
--~~~~~~~~~~~~~~~~~--

function loadsetting() --导入一个配置文本

    local fileicludes=nil
    local fileconfig=nil
    local filepasswd=nil
    local filepath=nil
    local path
    local passwd

    local id=GetVar('id') or ""
        var=var or {}

        path=Result("%syspath()") --%syspath() 在ls里面是得到软件目录
                                  --Result 是lua调用ls的方法
        var.filepath=path

    if id~=nil and id~="" then


        passwd=GetVar('passwd') or "" --找找密码

        if passwd=="" then
            filepasswd=io.open(var.filepath..id.."\\"..id..".txt","r") --文件里找承
            if filepasswd~=nil then
                passwd=passwdf:read()
                filepasswd:close()
            end
        end

        if passwd~=nil and passwd~="" and passwd~=" " then
            var.passwd=passwd

            fileconfig=io.open(var.filepath..id.."\\my-config.txt")

            if fileconfig~=nil then
                fileconfig:close()
                for line in io.lines(var.filepath..id.."\\my-config.txt") do
                    local m1,m2=string.match(line,"^var%[(.*)%]%=(.*)")
                    if m1 then
                        m1=string.gsub(m1,'%"',"")
                        m2=string.gsub(m2,'%"',"")
                        local m3=tonumber(m2)
                        if m3==nil then
                            var[m1]=m2
                            print('var["'..m1..'"]="'..m2..'"')
                        else
                            print('var["'..m1..'"]='..m3..'')
                            var[m1]=m3
                        end
                    end
                end


                var["do_stop"]=0
                var["wrong_way"]=0
                var["walk_wait"]=var["walk_wait"] or 1
                var["walk_step"]=var["walk_step"] or 12
                var["step_wait"]=var["walk_wait"]/var["walk_step"] or 40
                Echo("$HIW$载入设置文件$HIB$ID->$HIG$"..id.."$HIB$:"..var.filepath..id.."\\my-config.txt")
                if type(load_other_setting)=="function" then
                    load_other_setting() --其他设置，万一定义了呢
                end

            end
        end
    else
            for line in io.lines(var.filepath.."includes\\my-config.txt") do
                    local m1,m2=string.match(line,"^var%[(.*)%]%=(.*)")
                    if m1 then
                        m1=string.gsub(m1,'%"',"")
                        m2=string.gsub(m2,'%"',"")
                        local m3=tonumber(m2)
                        if m3==nil then
                            var[m1]=m2
                            print('var["'..m1..'"]="'..m2..'"')
                        else
                            print('var["'..m1..'"]='..m3..'')
                            var[m1]=m3
                        end
                    end
                end

                var["do_stop"]=0
                var["wrong_way"]=0
                var["walk_wait"]=var["walk_wait"] or 1
                var["walk_step"]=var["walk_step"] or 12
                var["step_wait"]=var["walk_wait"]/var["walk_step"]
                print("")
                print("载入通用:"..var.filepath.."includes\\my-config.txt")
                Echo("$HIR$警告未找到id!")
                if type(load_other_setting)=="function" then
                    load_other_setting() --其他设置，万一定义了呢
                end
    end


end


function setconfig(id)
    local fileicludes=nil
    local fileconfig=nil
    local filepasswd=nil
    local filepath=nil
    local id= id or GetVar("id") or ""
    if id~="" then

        local   path=Result("%syspath()") --%syspath() 在ls里面是得到软件目录
                                          --Result 是lua调用ls的方法
        var.filepath=path

        local fileconfig=io.open(path..id.."\\my-config.txt",'r') --检查文仿

        if fileconfig==nil then --config不存圿
            os.execute('md "'..path..id..'"') -- md id
            os.execute('md "'..path..id..'\\log"') -- md id
            os.execute('md "'..path..id..'\\die"') -- md id
            os.execute('md "'..path..id..'\\job"') -- md id
            os.execute('copy "' ..path..'includes\\my-config.txt"'.. ',"'..path..id..'\\my-config.txt"')
            os.execute('copy "' ..path..'includes\\id.txt"'.. ',"'..path..id..'\\'..id..'.txt"')
            print("Copy设置:"..var.filepath.."includes\\my-config.txt 到 "..id)
            local passwd=GetVar('passwd') or ""
            if passwd=="" then
                passwd=var.passwd or "" --系统变量没有passwd就去lua变量承
            end
            if passwd~="" then --有密砿
                var.passwd=passwd
                filepasswd=io.open(path..id.."\\"..id..".txt","w+")
                filepasswd:write(var.passwd)
                filepasswd:close()
                Echo("$HIW$密码更新！")
            end

        else
            fileconfig:close() --关掉
            Echo("$HIG$存在设置文件！")
            local passwd=GetVar('passwd') or ""
            if passwd=="" then
                passwd=var.passwd or "" --系统变量没有passwd就去lua变量承
            end
            if passwd~="" then --有密砿
                var.passwd=passwd
                filepasswd=io.open(path..id.."\\"..id..".txt","w+")
                filepasswd:write(var.passwd)
                filepasswd:close()
                Echo("$HIW$密码更新！")
            end
        end

    end

end


function lua_to_var() --血条
--qi
    local t=os.time()
    var.fullme_time = var.fullme_time or t
    local fullme_remain = var.fullme_time + 60*60 - os.time()
    if fullme_remain>15*60 then
        local hours, minutes, seconds = convert_seconds(fullme_remain)
        var.fullme_remain = "$HIW$Fullme剩余 $HIG$"..hours.."$HIW$ 小时 $HIG$"..minutes.."$HIW$ 分 $HIG$"..seconds.."$HIW$ 秒"
    elseif fullme_remain>0 then
        local hours, minutes, seconds = convert_seconds(fullme_remain)
        var.fullme_remain = "$HIW$Fullme剩余 $HIY$"..hours.."$HIW$ 小时 $HIY$"..minutes.."$HIW$ 分 $HIY$"..seconds.."$HIW$ 秒"
    else
        var.fullme_remain = "$HIW$Fullme剩余 $HIR$0$HIW$ 小时 $HIR$0$HIW$ 分 $HIR$0$HIW$ 秒"
    end
--qi
    local qixue=var.qi or 10
    local maxqi=var.maxqi or 10
    local hurt=var.hurtqi or 100
--  print(qixue)
    local hurt = var.hurtqi or 100 --

    local hurtqi=qixue*hurt/(maxqi+1)

    local r=math.floor(hurtqi/10) or 5
    local qi

    if hurtqi>95 then
        qi="$HIG$"..string.rep("█",10)
    elseif hurtqi>49 then
        if 1==1 or hurt==100 then
        qi="$HIG$"..string.rep("█",r).."$BLK$"..string.rep("█",10-r)
        else
        qi="$HIG$"..string.rep("█",r).."$RED$"..string.rep("█",10-r)
        end
    elseif hurtqi>9 and r>0 then
        if 1==1 or hurt==100 then
        qi="$HIR$"..string.rep("█",r).."$BLK$"..string.rep("█",10-r)
        else
        qi="$HIR$"..string.rep("█",r).."$RED$"..string.rep("█",10-r)
        end
    elseif hurtqi>4 then
        if 1==1 or hurt==100 then
        qi="$HIR$"..string.rep("█",1).."$BLK$"..string.rep("█",9)
        else
        qi="$HIR$"..string.rep("█",1).."$RED$"..string.rep("█",9)
        end
    else
        qi="$BLK$"..string.rep("█",10)
    end
--  print(qi)

    local showqi=qi

--jing
    local qixue=var.jing or 10
    local maxqi=var.maxjing or 10
    local hurt=var.hurtjing or 100

    local hurtqi=qixue*hurt/(maxqi+1)
    local r=math.floor(hurtqi/10) or 5
    local qi
    if hurtqi>95 then
        qi="$BLU$"..string.rep("█",10)
    elseif hurtqi>49 then
        qi="$BLU$"..string.rep("█",r).."$BLK$"..string.rep("█",10-r)
    elseif hurtqi>9 and r>0 then
        qi="$HIR$"..string.rep("█",r).."$BLK$"..string.rep("█",10-r)
    elseif hurtqi>4 then
        qi="$HIR$"..string.rep("█",1).."$BLK$"..string.rep("█",9)
            else
        qi="$BLK$"..string.rep("█",10)
    end


local showjing=qi

--neili
    local neili=var.neili or 100
    local maxneili=var.maxneili or 100
    local hurtqi=neili*100/(maxneili+1)



    local r=math.floor(hurtqi/10) or 5
    local qi
    if hurtqi>95 then
        qi="$HIY$"..string.rep("█",10)
    elseif hurtqi>49 then
        qi="$HIY$"..string.rep("█",r).."$BLK$"..string.rep("█",10-r)
    elseif hurtqi>9 and r>0 then
        qi="$HIR$"..string.rep("█",r).."$BLK$"..string.rep("█",10-r)
    elseif hurtqi>4 then
        qi="$HIR$"..string.rep("█",1).."$BLK$"..string.rep("█",9)
    else
        qi="$BLK$"..string.rep("█",10)
    end

    local showneili=qi


    --jingli
    local neili=var.jingli or 100
    local maxneili=var.maxjingli or 100
    local hurtqi=neili*100/(maxneili+1)

    local r=math.floor(hurtqi/10) or 5
    local qi
    if hurtqi>95 then
        qi="$HIC$"..string.rep("█",10)
    elseif hurtqi>49 then
        qi="$HIC$"..string.rep("█",r).."$BLK$"..string.rep("█",10-r)
    elseif hurtqi>9 and r>0 then
        qi="$HIR$"..string.rep("█",r).."$BLK$"..string.rep("█",10-r)
    elseif hurtqi>4 then
        qi="$HIR$"..string.rep("█",1).."$BLK$"..string.rep("█",9)
            else
        qi="$BLK$"..string.rep("█",10)
    end
    local showjingli=qi


    SetVar("showjingjingli","$HIW$$HIW$精神:"..showjing.." $HIW$精力:"..showjingli)
    if math.random(2)==1 then
        SetVar("showqineili","$HIW$气血:"..showqi.." $HIW$内力:"..showneili)
    else
        SetVar("showqineili","$HIW$气血:"..showqi.." $HIW$内力:"..showneili..".")
    end

end

Run=exe
