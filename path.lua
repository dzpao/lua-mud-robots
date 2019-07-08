--路径

function pathfrom(fromid,toid) --两点路径，考虑了城市中心路径
    return find_paths(fromid,toid) --find_paths 直接算
end


function find_paths(fromid,toid) --两点路径

    fromid=tonumber(fromid) or 0
    toid=tonumber(toid) or 0

    if fromid==0 or toid==0 or fromid==toid or not rooms[fromid] or not rooms[toid] or (rooms[fromid].cost~=nil and rooms[fromid].cost>9999) or (rooms[toid].cost~=nil and rooms[toid].cost>9999) then
        return "","",0,0
    end -- 房间权重cost 1万以上表示不能进入!!!!!!

    if type(rooms[fromid].linkscount)~="number" then -- 新增更新地图格式，增加几个参数
        update_map_format()
    end

    local config_cost_think = 1       --考虑权重设置1，不考虑设置0
    local config_scan_depth = 10000   --最大搜索深度，否则跳出循环


    local done=false --未找完
    local found=false
    local paths={} --路径表
    local explored={fromid=true}
    local cost={}
    local cost_flag={}
    local explore_dest
    local depth,count=0,0

    local particles={{["id"]=fromid,["path"]="",["room"]=""}} --从fromid开始

    while (not done) and next(particles)~=nil and depth < config_scan_depth do

            local new_generation = {} -- 新生成的碎片
            depth=depth+1


            for _, part in ipairs (particles) do
                if rooms[part.id] then --存在这个房间

                    count=count+1
                    if next(rooms[part.id].exits)~=nil then --这个房间存在出口
                        for dir, dest in pairs(rooms[part.id].exits) do

                            if dir~="" and dest~= fromid and not explored[dest] and rooms[dest] then

                                explore_dest=true

                                --权重问题

                                if config_cost_think==1 and rooms[dest].cost~=nil and rooms[dest].cost>0 and rooms[dest].cost<10000 and cost_flag[dest]==nil then --考虑权重问题

                                        if not cost[dest] then

                                            local roomcost = rooms[dest].cost or 1
                                            if dir == "cross_che_cj" or dir == "cross_che_hh" then
                                                roomcost = 20
                                            end
                                            cost[dest] ={ ["cost"] = roomcost, ["path"] = part.path..";"..dir, ["room"] = part.room.."|"..dest}
                                            cost_flag[dest]=true
                                            explore_dest=false
                                        end

                                        if cost[dest]==nil or cost[dest].cost==0 or dest==toid then
                                            explore_dest=true
                                        end

                                end --权重


                                --权重问题处理结束

                                if explore_dest==true then

                                    explored[dest]=true
                                    if not paths[dest] then
                                            paths[dest] = part.path..";"..dir
                                            paths[dest.."room"]=part.room.."|"..dest
                                    end

                                    if dest==toid then --如果dest等于toid 说明找到啦
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
                            if not paths[k] then
                                table.insert(new_generation,{["id"]=k,["path"]=v.path,["room"]=v.room})
                            end

                        end
                    else --如果新的搜索表非空，权重-1
                        for k,_ in pairs(cost_flag) do
                            local _cost=cost[k].cost
                            if _cost>0 then _cost=_cost-1 end

                            cost[k].cost=_cost

                            if _cost==0 and cost_flag[k] then

                                cost_flag[k]=nil
                                if not paths[k] then
                                    table.insert(new_generation,{["id"]=k,["path"]=cost[k].path,["room"]=cost[k].room})
                                end

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

        return path,path_rooms,depth,count --返回值有  路径   经过的房间   搜索深度  搜索总房间数

    else
        done,found,explored,explore_dest,particles,new_generation,paths,cost,cost_flag=nil,nil,nil,nil,nil,nil,nil,nil,nil
        return "","",0,0
    end
end


--获取一些room数据
require "rooms"

isroomsname={} --判断是否为房间名称
getport={}     --得到某个东西的房间号
uniquerooms={} --房间名称唯一的房间
system_npc={} --系统npc

require "pinyin"
function update_map_format() --更新地图格式

    local check_unique_rooms={} --检查是不是唯一房间
    var = var
    local zonelist={}

    for k,v in pairs(rooms) do
        zonelist[v.area]=true

        if v.links==nil or v.links=="" then
            rooms[k].links=""
            rooms[k].linkscount=0
        else
            local linkscount=0
            for i in string.gmatch(v.links,'(.)') do
                linkscount=linkscount+string.byte(i)
            end
            rooms[k].linkscount=linkscount -- 每个links的出口转换数字加权一下
        end
        rooms[k].iexits={}
        for i,j in pairs(v.exits) do --加一个iexit格式
            rooms[k].iexits[j]=i
        end

        rooms[k].cost=rooms[k].cost or 0 --加一下cost?

        for m,n in pairs(v.objs) do
            system_npc[m]=n
            system_npc[n]=m
            getport[m]=k --npc 物品 name
            getport[n]=k --npc 物品 id
        end

        if not getport[v.area] then getport[v.area]=v.center end --区域
        if not getport[v.name] then getport[v.name]=k end --房间名
        if not getport[v.area.." "..v.name] then getport[v.area.." "..v.name]=k end -- 比如 "扬州 北大街"
        if not getport[v.area..v.name] then getport[v.area..v.name]=k end -- 比如 "扬州北大街"

        if v.name~="" then
            if v.name=="长江岸边" or v.name=="黄河南岸" or v.name=="黄河北岸"  then
                rooms[k].links=""
                rooms[k].relation=""
            end

            -- local roomnamefirst=string.gsub(v.name,"(...)",pinyinfirst)
            -- local roomnamefirst=string.gsub(v.name,"([\x00-\x7F\xC2-\xF4][\x80-\xBF]*)","%1%1")
            -- local roomnamefirst=string.gsub(v.name,"[\0-\x7F\xC2-\xF4][\x80-\xBF]*","%1%1")
            local roomnamefirst=string.gsub(v.name,utf8.charpattern,pinyinfirst)
            -- local roomnamefirst=string.gsub(v.name,"([\x00-\x7F\xC2-\xF4][\x80-\xBF]*)",pinyinfirst)

            -- local roomareafirst=string.gsub(v.area,"(...)",pinyinfirst)
            local roomareafirst=string.gsub(v.area,utf8.charpattern,pinyinfirst)

            if getport[roomnamefirst]==nil then getport[roomnamefirst]={} end
            if getport[roomnamefirst][v.name]==nil then getport[roomnamefirst][v.name]={} end
            if getport[roomareafirst..roomnamefirst]==nil then getport[roomareafirst..roomnamefirst]={} end
            if getport[roomareafirst..roomnamefirst][v.area..v.name]==nil then getport[roomareafirst..roomnamefirst][v.area..v.name]={} end

            table.insert(getport[roomnamefirst][v.name],k)
            table.insert(getport[roomareafirst..roomnamefirst][v.area..v.name],k)


        end


        if check_unique_rooms[v.name]==nil then check_unique_rooms[v.name]={} end
        table.insert(check_unique_rooms[v.name],k)

        isroomsname[v.name]=k

    end

    for k,v in pairs(check_unique_rooms) do

        if #v==1 then
            uniquerooms[k]=v[1]
        end
    end

    local t={}
    for k,v in pairs(zonelist) do
        table.insert(t,k)
    end
    var.zonelist=table.concat(t,"|")

    check_unique_rooms=nil
--  print("地图格式更新完毕!path.lua 函数 update_map_format()")
end
update_map_format()

-- goto gt sz 等等

function getgt(txt) --gt得到房间号
--print("gtgtgt")
    if txt==nil then return 0 end
    local n=tonumber(txt) or 0
    if n>0 then --本身就是房间号
--  print("gt1")
        if rooms[n] then
            return n
        else --不存在...
            return 0
        end
    elseif string.match(txt,"^%a+$") then --字母
    --  print("gt2")
        local id=txt
        local gt_list={ --部分兼容gt，找不到不怪我了
            ["bt"]={["area"]="白驼",["room"]="戈壁"},
            ["bxs"]={["area"]="百晓生",["room"]="醉仙楼二楼"},
            ["bj"]={["area"]="北京",["room"]="永安门"},
            ["cd"]={["area"]="成都",["room"]="总督府门前"},
            ["cz"]={["area"]="虫子",["room"]="丽春院密室"},
            ["dl"]={["area"]="大理",["room"]="十字路口"},
            ["qbl"]={["area"]="大轮千步岭",["room"]="千步岭"},
            ["dls"]={["area"]="大轮寺",["room"]="大轮寺山门"},
            ["xkt"]={["area"]="大轮谢客亭",["room"]="谢客亭"},
            ["ddj"]={["area"]="都大锦",["room"]="龙门镖局"},
            ["em"]={["area"]="峨嵋",["room"]="玉女池"},
            ["qfa"]={["area"]="峨嵋千佛庵",["room"]="千佛庵大殿"},
            ["fds"]={["area"]="发呆室",["room"]="发呆室"},
            ["fz"]={["area"]="福州",["room"]="福威镖局"},
            ["gb"]={["area"]="丐帮",["room"]="土地庙"},
            ["gm"]={["area"]="古墓",["room"]="断龙石"},
            ["ha"]={["area"]="古墓河岸",["room"]="河岸"},
            ["ms"]={["area"]="古墓密室",["room"]="密室"},
            ["xt"]={["area"]="古墓小厅",["room"]="小厅"},
            ["gjc"]={["area"]="挂剑祠",["room"]="挂剑祠"},
            ["gw"]={["area"]="关外",["room"]="集市"},
            ["yinz"]={["area"]="归云隐者",["room"]="隐者居"},
            ["gy"]={["area"]="归云庄",["room"]="归云亭"},
            ["hanz"]={["area"]="汉中",["room"]="汉中"},
            ["hz"]={["area"]="杭州",["room"]="大理寺"},
            ["hmy"]={["area"]="黑木崖",["room"]="成德殿"},
            ["hhh"]={["area"]="红花会",["room"]="杭州分舵大门"},
            ["hyd"]={["area"]="胡一刀",["room"]="高粱地"},
            ["bs"]={["area"]="花园别墅区",["room"]="花园别墅区"},
            ["hs"]={["area"]="华山",["room"]="书房"},
            ["cll"]={["area"]="华山苍龙岭",["room"]="苍龙岭"},
            ["xc"]={["area"]="华山村",["room"]="打谷场"},
            ["hb"]={["area"]="淮北",["room"]="淮北"},
            ["hb1"]={["area"]="黄河渡口北1",["room"]="无"},
            ["hb2"]={["area"]="黄河渡口北2",["room"]="风陵渡"},
            ["hb3"]={["area"]="黄河渡口北3",["room"]="无"},
            ["hb4"]={["area"]="黄河渡口北4",["room"]="无"},
            ["hn1"]={["area"]="黄河渡口南1",["room"]="无"},
            ["hn2"]={["area"]="黄河渡口南2",["room"]="孟津渡"},
            ["hn3"]={["area"]="黄河渡口南3",["room"]="无"},
            ["hn4"]={["area"]="黄河渡口南4",["room"]="无"},
            ["jx"]={["area"]="嘉兴",["room"]="嘉兴城"},
            ["jyg"]={["area"]="嘉峪关",["room"]="嘉峪关"},
            ["jmg"]={["area"]="剑门关",["room"]="剑门关"},
            ["jz"]={["area"]="江州",["room"]="韩家"},
            ["jy"]={["area"]="晋阳",["room"]="萧府"},
            ["jzh"]={["area"]="荆州",["room"]="荆州"},
            ["km"]={["area"]="昆明",["room"]="神威镖局"},
            ["fd"]={["area"]="琅缳福地",["room"]="琅缳福地"},
            ["lld"]={["area"]="老林东",["room"]="老林尽头"},
            ["llx"]={["area"]="老林西",["room"]="老林边缘"},
            ["lj"]={["area"]="灵鹫",["room"]="百丈涧"},
            ["dzt"]={["area"]="灵鹫独尊厅",["room"]="独尊厅大门"},
            ["lz"]={["area"]="灵州",["room"]="皇宫大门"},
            ["lxc"]={["area"]="凌霄城",["room"]="凌霄大厅"},
            ["ljz"]={["area"]="陆家庄",["room"]="陆家庄"},
            ["ly"]={["area"]="洛阳",["room"]="洛阳中心广场"},
            ["ll"]={["area"]="绿柳山庄",["room"]="绿柳山庄大门"},
            ["mt"]={["area"]="曼陀山庄",["room"]="小桥"},
            ["mz"]={["area"]="梅庄",["room"]="梅庄天井"},
            ["mlb"]={["area"]="苗岭北",["room"]="无"},
            ["mlx"]={["area"]="苗岭西",["room"]="无"},
            ["mj"]={["area"]="明教",["room"]="半山门"},
            ["mgk"]={["area"]="莫高窟",["room"]="莫高窟"},
            ["mr"]={["area"]="慕容",["room"]="湖边"},
            ["mrf"]={["area"]="慕容复",["room"]="茶馆"},
            ["nc"]={["area"]="南昌",["room"]="白家"},
            ["ny"]={["area"]="南阳",["room"]="南阳城"},
            ["px"]={["area"]="平西王府",["room"]="平西王府大门"},
            ["pyh"]={["area"]="鄱阳湖",["room"]="鄱阳湖边"},
            ["py"]={["area"]="濮阳",["room"]="濮阳"},
            ["qlc"]={["area"]="麒麟村",["room"]="岳飞家"},
            ["qy"]={["area"]="琴韵小筑",["room"]="琴韵小居"},
            ["qhb"]={["area"]="青海湖北",["room"]="黄羊滩"},
            ["qhn"]={["area"]="青海湖南",["room"]="无"},
            ["qf"]={["area"]="曲埠",["room"]="孔庙"},
            ["qq"]={["area"]="曲清",["room"]="荣昌交易行"},
            ["qzh"]={["area"]="全真教",["room"]="崇玄台"},
            ["qz"]={["area"]="泉州",["room"]="泉州港"},
            ["ry"]={["area"]="日月神教",["room"]="小村庄"},
            ["rbz"]={["area"]="荣宝斋",["room"]="荣宝斋"},
            ["rz"]={["area"]="汝州",["room"]="汝州城"},
            ["ssb"]={["area"]="杀手帮",["room"]="万纶台"},
            ["lvz"]={["area"]="沙漠绿洲",["room"]="沙漠绿洲"},
            ["shg"]={["area"]="山海关",["room"]="山海关南门"},
            ["fzl"]={["area"]="少林方丈楼",["room"]="方丈楼"},
            ["sl"]={["area"]="少林寺",["room"]="少林寺"},
            ["sld"]={["area"]="神龙岛",["room"]="海滩"},
            ["fengd"]={["area"]="神龙峰顶",["room"]="峰顶"},
            ["sy"]={["area"]="神龙山腰",["room"]="小回廊"},
            ["skf"]={["area"]="史可法",["room"]="城北军营"},
            ["sdb"]={["area"]="蜀道北",["room"]="无"},
            ["sdn"]={["area"]="蜀道南",["room"]="无"},
            ["sz"]={["area"]="苏州",["room"]="宝带桥"},
            ["taih"]={["area"]="太湖",["room"]="太湖边"},
            ["tais"]={["area"]="泰山",["room"]="南天门"},
            ["dzf"]={["area"]="泰山岱宗坊",["room"]="岱宗坊"},
            ["tgk"]={["area"]="塘沽口",["room"]="塘沽口"},
            ["th"]={["area"]="桃花岛",["room"]="庆元港"},
            ["tyc"]={["area"]="桃园村",["room"]="桃园小路"},
            ["ty"]={["area"]="桃源",["room"]="桃源驿站"},
            ["tdh"]={["area"]="天地会",["room"]="侧厅"},
            ["tls"]={["area"]="天龙寺",["room"]="瑞鹤门"},
            ["tzf"]={["area"]="天柱峰",["room"]="天柱峰下"},
            ["tz"]={["area"]="铁掌峰",["room"]="小亭"},
            ["tx"]={["area"]="听香水榭",["room"]="听香水榭"},
            ["wat"]={["area"]="万安塔",["room"]="万安塔"},
            ["wjg"]={["area"]="万劫谷",["room"]="万劫谷"},
            ["gd"]={["area"]="无量谷底",["room"]="谷底"},
            ["wl"]={["area"]="无量山",["room"]="无量山后山"},
            ["yb"]={["area"]="无量玉璧",["room"]="无量玉璧"},
            ["wd"]={["area"]="武当",["room"]="武当广场"},
            ["wdc"]={["area"]="武当村",["room"]="武当山门"},
            ["wm"]={["area"]="武庙",["room"]="武庙"},
            ["wys"]={["area"]="武夷山",["room"]="武夷山路"},
            ["xyz"]={["area"]="戏园子",["room"]="戏园子"},
            ["xy"]={["area"]="襄阳",["room"]="襄阳当铺"},
            ["xf"]={["area"]="萧峰",["room"]="望星楼二层"},
            ["xz"]={["area"]="小镇",["room"]="小镇"},
            ["xiny"]={["area"]="信阳",["room"]="镇淮桥"},
            ["xx"]={["area"]="星宿",["room"]="巨岩"},
            ["txg"]={["area"]="星宿天秀宫",["room"]="天秀宫"},
            ["xch"]={["area"]="许昌",["room"]="许昌城"},
            ["xs"]={["area"]="雪山派",["room"]="桥头"},
            ["ys"]={["area"]="牙山",["room"]="牙山湾中心"},
            ["yzw"]={["area"]="燕子坞",["room"]="燕子坞大门"},
            ["yz"]={["area"]="扬州",["room"]="中央广场"},
            ["ct"]={["area"]="扬州",["room"]="中央广场"},
            ["yiz"]={["area"]="驿站",["room"]="驿站"},
            ["yg"]={["area"]="瑛姑",["room"]="黑沼小屋"},
            ["cym"]={["area"]="应天朝阳门",["room"]="朝阳门"},
            ["lb"]={["area"]="应天吏部",["room"]="吏部衙门"},
            ["scm"]={["area"]="应天神策门",["room"]="神策门"},
            ["slj"]={["area"]="应天司礼监",["room"]="司礼监"},
            ["zyc"]={["area"]="应天杂役处",["room"]="杂役处"},
            ["zym"]={["area"]="应天正阳门",["room"]="正阳门"},
            ["ywm"]={["area"]="岳王墓",["room"]="墓前广场"},
            ["yy"]={["area"]="岳阳",["room"]="南门内大街"},
            ["zp"]={["area"]="赞普",["room"]="赞普广场"},
            ["zjk"]={["area"]="张家口",["room"]="大境门"},
            ["zz"]={["area"]="张志",["room"]="荆西镖局"},
            ["ca"]={["area"]="长安",["room"]="朱雀门"},
            ["jb1"]={["area"]="长江渡口北1",["room"]="扬子津"},
            ["jb2"]={["area"]="长江渡口北2",["room"]="无"},
            ["jb3"]={["area"]="长江渡口北3",["room"]="无"},
            ["jb4"]={["area"]="长江渡口北4",["room"]="无"},
            ["jn1"]={["area"]="长江渡口南1",["room"]="无"},
            ["jn2"]={["area"]="长江渡口南2",["room"]="采石矶"},
            ["jn3"]={["area"]="长江渡口南3",["room"]="无"},
            ["jn4"]={["area"]="长江渡口南4",["room"]="无"},
            ["zj"]={["area"]="镇江",["room"]="梦溪园"},
            ["zx"]={["area"]="朱熹",["room"]="岳麓书院"},
            ["zf"]={["area"]="庄府",["room"]="庄府大门"},
            ["tdf"]={["area"]="提督府",["room"]="提督府正门"},
            ["xh"]={["area"]="西湖",["room"]="孤山"},
            ["hsz"]={["area"]="韩世忠",["room"]="大厅"},
            ["jnqz"]={["area"]="江南钱庄",["room"]="江南钱庄"},
            ["hzbs"]={["area"]="杭州别墅",["room"]="无"},
            ["lanz"]={["area"]="兰州",["room"]="兰州西门"},
            ["hzh"]={["area"]="湟中",["room"]="湟中中心"},
            }
            if gt_list[id] then -- 字母型gt id在列表中
                local k=gt_list[id].area.." "..gt_list[id].room
                k=getport[k]
                if k then -- 区域+房间
                    gt_list=nil
                    return k
                end

                k=gt_list[id].room --房间
                      k=getport[k]
                if k then
                    gt_list=nil
                    return k
                end

                    k=gt_list[id].area --区域
                    k=getport[k]
                if k then
                    gt_list=nil
                    return k
                end
                print(3)
                    gt_list=nil --没了
                    return 0

            elseif getport[txt] then --如果仅仅首字母呢
        --  print(1)
        gt_list=nil --没了

                if type(getport[txt])=="table" then
                    local m,n=0,0

                    for k,v in pairs(getport[txt]) do
                        for kk,vv in pairs(v) do
                            m=m+1
                            n=vv
                            if string.match(k,"^"..rooms[vv].area) then
                                echo("  $HIW$你的目标地点是不是:【$HIY$"..k.."$HIW$】，可以输入$HIY$gt "..vv.."$NOR$")
                            else
                                echo("  $HIW$你的目标地点是不是:【$HIY$"..rooms[vv].area..k.."$HIW$】，可以输入$HIY$gt "..vv.."$NOR$")
                            end
                        end
                    end

                    if m==1 then
                        echo("  $HIW$唯一目标，$HIG$自动行走!$NOR$")
                        return n
                    else
                        return -1
                    end
                else
                    return getport[txt]
                end
            else
                gt_list=nil --没了
                    return 0

            end

    elseif  getport[txt] then
    --print(2)


        return getport[txt]
    else
    --print(4)
        return 0
    end

end


enter_rooms = {}     -- 可进入房间列表
no_enter_rooms = {}  -- 无法进入房间列表

--~~~~~~~~~~~~~~~~
--   区域遍历房间列表
--~~~~~~~~~~~~~~~~
area_bianli = {
    get_zonelist = function()   --得到所有区域table
--      if null(area_bianli.zone_list) then
            local zone_list,check_zone = {},{}
            for i=1,table.maxn(rooms) do
                if rooms[i] then
                --扬州|信阳|杀手帮|长江北岸|襄阳|武当山|小山村|华山|长安|洛阳|汝阳王府|中原|少林寺|古墓|全真|曲阜|泰山|黄河南岸|回疆小镇|回部|灵鹫|灵州|丐帮|麒麟村|大轮寺|凌霄城|白驼山|绝情谷|黄河北岸|丝绸之路|晋阳|北京|紫禁城|天坛|康亲王府|张家口|日月神教|明教|兰州|湟中|神龙岛|长江|岳阳|桃源|铁掌峰|南昌|泉州|福州|岳王墓|临安府|西湖|建康府南城|都统制府|建康府北城|江州|镇江|苏州|归云庄|姑苏慕容|嘉兴|牙山|桃花岛|杭州提督府|成都|峨嵋|峨眉后山|天龙寺|无量山|大理城中|昆明|平西王府
                    if not check_zone[rooms[i].area] and not string.find("|新手村|汝阳王府|蒙古东部|蒙古北部|蒙古中部|蒙古西部|关外|壮族|星宿海新手|","|"..rooms[i].area.."|") then
                        check_zone[rooms[i].area] = true
                        table.insert(zone_list,rooms[i].area)
                    end
                end
            end
    --      Print(table.concat(zone_list,"|"))
    --      area_bianli.zone_list = copytable(zone_list)
            return zone_list
    --  else
        --  return area_bianli.zone_list
    --  end
    end,

    get_bianli = function (area) --得到一个区域的所有遍历房间 table
        if area == nil or area == "" then
            return {}
        end

        if enter_rooms == nil or no_enter_rooms == nil then
            enter_rooms = {}
            no_enter_rooms = {}
        end

                local list,center = {},100

                for k,v in pairs(rooms) do
                    if v.area==area then

                    if center == 100 then center = k end
                    if no_enter_rooms[center] then center = 100 end

                        if k ~= 100 then
                            if not no_enter_rooms[k] then    -- 不是禁止进入房间

                                if enter_rooms[k] then       -- 允许进入直接添加
                                    table.insert(list,k)
                                elseif k~=center and find_paths(center,k)=="" then --和周围房间不通，标注一下为禁止进入房间
                                    no_enter_rooms[k] = true -- 标志一下无法进入的房间
                                elseif k==center and find_paths(100,k)=="" then --和周围房间不通，标注一下为禁止进入房间
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

                table.sort(list)

            --  area_bianli[area]=copytable(list)

                return list

    end,




}
area_bianli.zone_list = area_bianli:get_zonelist()

full_zonename = {
["扬州"] = "扬州",
["信阳"] = "信阳",
["杀手"] = "杀手帮",
["长江"] = "长江北岸",
["襄阳"] = "襄阳",
["武当"] = "武当山",
["小山"] = "小山村",
["华山"] = "华山",
["长安"] = "长安",
["洛阳"] = "洛阳",
["中原"] = "中原",
["少林"] = "少林寺",
["古墓"] = "古墓",
["全真"] = "全真",
["曲阜"] = "曲阜",
["泰山"] = "泰山",
["黄河"] = "黄河南岸",
["回疆"] = "回族小镇",
["回族"] = "回族小镇",
["回部"] = "回部",
["灵鹫"] = "灵鹫",
["灵州"] = "灵州",
["丐帮"] = "丐帮",
["麒麟"] = "麒麟村",
["大轮"] = "大轮寺",
["凌霄"] = "凌霄城",
["白驼"] = "白驼山",
["绝情"] = "绝情谷",
["黄河"] = "黄河北岸",
["丝绸"] = "丝绸之路",
["晋阳"] = "晋阳",
["北京"] = "北京",
["紫禁"] = "紫禁城",
["天坛"] = "天坛",
["康亲"] = "康亲王府",
["张家"] = "张家口",
["日月"] = "日月神教",
["明教"] = "明教",
["兰州"] = "兰州",
["湟中"] = "湟中",
["神龙"] = "神龙岛",
["长江"] = "长江",
["岳阳"] = "岳阳",
["桃源"] = "桃源",
["铁掌"] = "铁掌峰",
["南昌"] = "南昌",
["泉州"] = "泉州",
["福州"] = "福州",
["岳王"] = "岳王墓",
["临安"] = "临安府",
["西湖"] = "西湖",
["建康"] = "建康府南城",
["都统"] = "都统制府",
["建康"] = "建康府北城",
["江州"] = "江州",
["镇江"] = "镇江",
["苏州"] = "苏州",
["归云"] = "归云庄",
["姑苏"] = "姑苏慕容",
["嘉兴"] = "嘉兴",
["牙山"] = "牙山",
["桃花"] = "桃花岛",
["杭州"] = "杭州提督府",
["成都"] = "成都",
["峨嵋"] = "峨嵋",
["峨眉"] = "峨眉后山",
["天龙"] = "天龙寺",
["无量"] = "无量山",
["大理"] = "大理城中",
["昆明"] = "昆明",
["平西"] = "平西王府",
["荆州"] = "襄阳", -- 新增20180810
--
["北京"]="北京",
["凌霄城"]="凌霄城",
["襄阳"]="襄阳",
["湟中"]="湟中",
["桃花岛"]="桃花岛",
["古墓"]="古墓",
["回疆小镇"]="回族小镇",
["回族小镇"]="回族小镇",
["桃源"]="桃源",
["镇江"]="镇江",
["临安府"]="临安府",
["泰山"]="泰山",
["铁掌峰"]="铁掌峰",
["小山村"]="小山村",
["信阳"]="信阳",
["都统制府"]="都统制府",
["黄河北岸"]="黄河北岸",
["无量山"]="无量山",
["江州"]="江州",
["康亲王府"]="康亲王府",
["武当山"]="武当山",
["姑苏慕容"]="姑苏慕容",
["峨眉后山"]="峨眉后山",
["长江"]="长江",
["昆明"]="昆明",
["神龙岛"]="神龙岛",
["绝情谷"]="绝情谷",
["扬州"]="扬州",
["少林寺"]="少林寺",
["牙山"]="牙山",
["全真"]="全真",
["杀手帮"]="杀手帮",
["中原"]="中原",
["大轮寺"]="大轮寺",
["白驼山"]="白驼山",
["岳王墓"]="岳王墓",
["晋阳"]="晋阳",
["丝绸之路"]="丝绸之路",
["平西王府"]="平西王府",
["泉州"]="泉州",
["长安"]="长安",
["华山"]="华山",
["杭州提督府"]="杭州提督府",
["西湖"]="西湖",
["回部"]="回部",
["天龙寺"]="天龙寺",
["峨嵋"]="峨嵋",
["灵鹫"]="灵鹫",
["成都"]="成都",
["丐帮"]="丐帮",
["嘉兴"]="嘉兴",
["归云庄"]="归云庄",
["曲阜"]="曲阜",
["灵州"]="灵州",
["苏州"]="苏州",
["南昌"]="南昌",
["紫禁城"]="紫禁城",
["明教"]="明教",
["日月神教"]="日月神教",
["福州"]="福州",
["大理城中"]="大理城中",
["岳阳"]="岳阳",
["兰州"]="兰州",
["建康府北城"]="建康府北城",
["洛阳"]="洛阳",
["麒麟村"]="麒麟村",
["天坛"]="天坛",
["张家口"]="张家口",
}

--用法：  local a = area_bianli.get_bianli("扬州")

function get_room_by_path(from,path) --由一个路径得到目标房间,不存在返回0，存在放回房间号
    if from==nil or not rooms[from] or path==nil or path=='' then
        return 0
    end

    local i,to,done=from,0,false
    for j in string.gmatch(path..';','(.-);') do

        if done ==true then
            break
        end
        if rooms[i] then
            local rightfx=false

            for k,v in pairs(rooms[i].exits) do
                local mapfx=fangxiang[k]
                      mapfx=fangxiang[mapfx]
                local fx=fangxiang[j]
                        fx=fangxiang[fx]
                if fx==mapfx and rightfx==false then
                    rightfx=true
                    i = v
                    to = v
                end
            end
        else
            to = 0
            done = true
            break
        end
    end

    return to

end

function show_no_enter_rooms()
for k,v in pairs(no_enter_rooms) do
    echo("  $HIW$"..k.." --> $HIR$"..rooms[k].name.."$HIG$"..rooms[k].area)

end
end
