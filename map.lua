 --更新地图


--var.open_map_zbsd = false ---- [5527] 装备商店
--var.close_map_ouyangfeng = true -- 关闭欧阳锋地图 true, nil 或false开启
var.close_map_zbsd = 1               -- 1 装备商店
var.close_map_ouyangfeng = 1         -- 1 关闭欧阳锋地图
var.close_map_shaolin_jianyu = 1     -- 1 关闭少林监狱
var.close_map_shaolin_songshulin = 1 -- 1 关闭少林松树林
var.close_map_shaolin_fumoquan = 1   -- 1 伏魔圈
var.close_map_shenlongdao_pingtai = 1-- 1 神龙岛平台
var.close_map_heimuya = 1            -- 1 黑木崖关闭
var.close_map_duanyu = 1             -- 1 段誉关闭
var.close_map_baituo_shamo = 1       -- 1 白驼沙漠
var.close_map_shaolin_dmy = 1        -- 1 少林达摩院
var.close_map_shaolin_jly = 1        -- 1 少林戒律院
var.map_heimuya_jinshezhui = 0       -- 1 自动买金蛇锥 20 gold


var.map_meizhuang_sibao = nil        -- 自动 梅庄大米，别管



function check_map() --检查地图
    item = item or {}
    local sinan = item['司南'] or 0
    local shuikao = item['水靠'] or 0
--  local yandou=item["烟斗"] or 0
    local pipe = item['铜哨'] or 0
    local fish = item["鱼"] or 0
    local fire = item["fire"] or 0
    local emei = item["灭绝的邀请函"] or 0
    local shen = var.shen or 0
    local party = var.party or "普通百姓"
    local master = var.master or "无"

    local fuzhong = var.fuzhong or 0

    local dodge = 1
    if type(var.skills_level) == "table" then
        dodge = var.skills_level["dodge"] or 1
    end


    if fish>0 then shuikao=1 end --有鱼就算有水靠了

    local myexp = var.exp or 0
    local newbiemap = var.newbiemap or 0




    if emei>0 and var.update_map_emei==nil then         --身上有司南
        update_map("灭绝的邀请函")
    end
    if emei==0 and var.update_map_emei_lost==nil and party ~= "峨嵋派" then
        var.update_map_newbie = nil
        update_map("丢失灭绝的邀请函")
    end
    if party=="峨嵋派" and var.update_map_emei_lanlu==nil then
        update_map("峨嵋派拦路")
    end
    if sinan>0 and var.update_map_laolin==nil then         --身上有司南
        update_map("司南")
    end
    if sinan==0 and var.update_map_laolin_lost==nil then
        update_map("丢失司南")
    end
    if fire>0 and var.update_map_fire==nil then         --身上有司南
        update_map("火折")
    end
    if fire==0 and var.update_map_fire_lost==nil then
        update_map("丢失火折")
    end

    if fuzhong<19 and var.update_map_mogaoku==nil then
        update_map("开放莫高窟")
    end
    if fuzhong>18 and var.update_map_mogaoku_lost==nil then
        update_map("关闭莫高窟")
    end

    if shuikao>0 and var.update_map_shuikao==nil then  --身上有水靠
        update_map("水靠")
    end
    if shuikao==0 and var.update_map_shuikao_lost==nil then
        update_map("丢失水靠")
    end

    if pipe>0 and var.update_map_pipe==nil then        --身上有铜哨
        update_map("铜哨")
    end
    if pipe==0 and var.update_map_pipe_lost==nil then
        print("lost pipe")
        update_map("丢失铜哨")
    end

    if var.update_map_newbie==nil and (newbiemap==1 or myexp<500000) then --50万开启新手地图 或者设置了newbiemap 新手地图这个参数
        update_map("newbie")
    end
    if var.update_map_newbie==nil and (newbiemap==2 or myexp<1000000) then --1m左右
        update_map("newbie2")
    end
    if var.update_map_newbie==nil and newbiemap==3 then --10m左右all --小心
        update_map("newbie3")
    end
    if var.update_map_newbie==nil and newbiemap==4 then --10m左右all --小心
        update_map("newbie4")
    end

    if dodge > 100 and var.update_map_dodge==nil then         --身上有司南
        update_map("更新轻功达标以上房间")
    end

    if shen<0 and var.update_map_shen==nil then         --身上有司南
        update_map("负神删除陈近南房间")
    end
    if shen>-1 and var.update_map_shen==nil then         --身上有司南
        update_map("正神删除丁春秋房间")
    end

    if var.close_map_ouyangfeng and var.close_map_ouyangfeng==1 and party~="白驼山" and var.update_map_ouyangfeng==nil then
        update_map("删除欧阳锋房间")
    end

    if var.close_map_shaolin_songshulin and var.close_map_shaolin_songshulin==1 and var.update_map_shaolin_songshulin==nil then
        update_map("删除少林松树林")
    end

    if var.close_map_baituo_shamo and var.close_map_baituo_shamo==0 and var.update_map_baituo_shamo==nil then
        update_map("打开白驼山沙漠")
    end

    if var.close_map_shenlongdao_pingtai and var.close_map_shenlongdao_pingtai ==1 and var.update_map_shenlongdao_pingtai==nil then
        update_map("删除神龙岛平台")
    end
    if var.close_map_duanyu and var.close_map_duanyu ==0 and var.update_map_duanyu==nil then
        update_map("打开段誉房间")
    end
    if var.close_map_heimuya and var.close_map_heimuya == 0 and not var.update_close_map_heimuya then --长袖大宗师设置了var.close_map_heimuya = 0
        var.update_close_map_heimuya = true
        update_map("开启黑木崖")
    end
--[[
    if var.close_map_heimuya and var.close_map_heimuya == 1 and var.map_give_jinshe_zhui and not var.update_map_give_jinshe_zhui then --给了金蛇锥
        var.update_map_give_jinshe_zhui = true
        update_map("开启黑木崖")
    end

    if var.close_map_heimuya and var.close_map_heimuya == 1 and not var.map_give_jinshe_zhui and var.update_map_give_jinshe_zhui then --关掉金蛇锥
        var.update_map_give_jinshe_zhui = nil
        update_map("关闭黑木崖")
    end
]]
    if var.close_map_heimuya and var.close_map_heimuya == 1 and not var.update_close_map_heimuya_jinshezhui and var.map_give_jinshe_zhui == true then
        var.update_close_map_heimuya_jinshezhui = true
        update_map("开启黑木崖")
    end
    if var.map_meizhuang_sibao and not var.update_map_meizhuang_sibao and master~="任我行" then
        var.update_map_meizhuang_sibao = true
        update_map("开启梅庄四宝")
    end

    if var.map_meizhuang_sibao_fail and not var.update_map_meizhuang_sibao_fail and master~="任我行" then
        var.update_map_meizhuang_sibao_fail = true
        update_map("关闭梅庄四宝")
    end

    if not var.update_map_party_again then --再次更新门派
        var.update_map_party_again = true
        update_map(var.party)
    end



end

function update_map(s)


    if s == "newbie" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        --慕容 qinyun
        logs(" 启用新手安全地图！")
        print("修改"..s.."路径成功 map.lua")
        var.update_map_newbie = true
        rooms[1118].exits["crush guan jia;n"] = nil --洛阳王家大门
        rooms[374].exits["crush tiger;ed"] = nil --襄阳黑风寨
        rooms[144].exits["crush jian zhanglao;e"] = nil

        rooms[134].exits["crush jiang yaoting;e"] = nil
        rooms[134].exits["e"] = 121

        rooms[5911].exits["nu"] = nil --gyz

        rooms[473].exits["crush zhongnian daozhang;n"] = nil

        rooms[2073].exits["out"] = nil --土匪窝边
        rooms[5403].exits["crush danei gaoshou;e"] = nil --风波亭
        rooms[5982].exits["crush delay 0;cai yanziwu"] = nil
        rooms[5982].exits["crush delay 0;cai tingxiang"] = nil
        rooms[5999].exits["cross_che_qytx"] = 6000  --qinyun tingxiang
        rooms[5999].exits["cross_che_qyyzw"] = 6013 --qinyun yanziwu
        --tingxiang
        rooms[6000].exits["crush delay 0;cai qinyun"] = nil
        rooms[6000].exits["crush delay 0;cai yanziwu"] = nil
--      rooms[6000].exits["cross_che_txqy"] = 5982
        --yanziwu
        rooms[6013].exits["crush delay 0;cai qinyun"] = nil --5982
        rooms[6013].exits["crush delay 0;cai tingxiang"] = nil --5982
--      rooms[6013].exits["cross_che_yzwqy"] = 5982
        --所有cai zhuang换坐船
        rooms[6073].exits["open door;w"] = nil --严妈妈
        --open door;w
        rooms[649].exits["crush delay 0;climb cliff;crush busy"] = nil --华山爬悬崖

        rooms[1894].exits["crossljg"] = nil --灵柩
        rooms[1955].exits["crush xiao wei;open door;s"] = nil --灵州

        rooms[2125].exits["crush sang jie;crush hufa lama;open door;enter"] = nil --桑杰

        rooms[1643].exits["hpbrief;cross_neili_west"] = nil --地下河去gm
        rooms[4270].exits["crush haoshou shouling;n"] = nil --星宿

        rooms[6399].exits["crush shoushan dizi;n"] = nil --emei

        rooms[5047].exits["crush hongyi dizi;enter"] = nil --sld
        rooms[5045].exits["crush baiyi dizi;crush hongyi dizi;crush qingyi dizi;crush huangyi dizi;crush heiyi dizi;w"] = nil --sld

        rooms[6536].exits["cross_che_wl"] = nil --wuliangshan

        rooms[6726].exits["crush bao biao;n"] = nil --pingxi

        rooms[1962].exits["crush wei shi;n"] = nil ---灵州皇宫
        rooms[5045].exits["crush baiyi dizi;crush hongyi dizi;crush qingyi dizi;crush huangyi dizi;crush heiyi dizi;w"] = nil --pingxi
        rooms[5047].exits["crush hongyi dizi;enter"] = nil --pingxi

        rooms[3239].exits["crush jin yiwei;w"] = nil --天坛

        rooms[2214].exits["crush xueshan dizi;nu"] = nil --负神雪山弟子

        rooms[1630].exits["n"] = nil --新人不去地下河古墓的

        rooms[10132].exits["cross_wd_climb"] = nil --武当 五老峰
        rooms[10228].exits["cross_wd_climb"] = nil --武当 五老峰

        rooms[6580].exits["crush zhu wanli;enter"] = nil --大理朱万里
        rooms[6581].exits["crush fu sigui;s"] = nil --大理朱万里

        rooms[10560].exits["crush xiao daotong;w"] = nil --武当小道童

        rooms[4270].exits["crush haoshou shouling;n"] = nil --星秀

        --4270 crush haoshou shouling;n
        rooms[392].exits["crush qin bing;u"] = nil  --xy

        rooms[2973].exits["u"] = nil  --铜雀台

        rooms[4169].exits["crush heijia junshi;n"] = nil
        rooms[10933].exits["enter"] = nil  --金刚伏魔圈



    elseif s == "newbie2" then   --1m
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        --慕容 qinyun
        logs(" 启用新手二段安全地图！")
        print("修改"..s.."路径成功 map.lua")
        var.update_map_newbie = true
        rooms[144].exits["crush jian zhanglao;e"] = 145
        rooms[4169].exits["crush heijia junshi;n"] = nil
    --  rooms[1118].exits["crush guan jia;n"] = nil --洛阳王家大门
    --  rooms[374].exits["crush tiger;ed"] = nil --襄阳黑风寨
        rooms[144].exits["crush jian zhanglao;e"] = nil
        rooms[5403].exits["crush danei gaoshou;e"] = nil --风波亭
    --  rooms[5982].exits["cai yanziwu"] = nil
    --  rooms[5982].exits["cai tingxiang"] = nil
    --  rooms[5999].exits["cross_che_qytx"] = 6000  --qinyun tingxiang
    --  rooms[5999].exits["cross_che_qyyzw"] = 6013 --qinyun yanziwu
        --tingxiang
    --  rooms[6000].exits["cai qinyun"] = nil
    --  rooms[6000].exits["cai yanziwu"] = nil
--      rooms[6000].exits["cross_che_txqy"] = 5982
        --yanziwu
    --  rooms[6013].exits["cai qinyun"] = nil --5982
    --  rooms[6013].exits["cai tingxiang"] = nil --5982
--      rooms[6013].exits["cross_che_yzwqy"] = 5982
        --所有cai zhuang换坐船
    --  rooms[6073].exits["open door;w"] = nil --严妈妈
        --open door;w
    --  rooms[649].exits["climb cliff"] = nil --华山爬悬崖

    --  rooms[1894].exits["crossljg"] = nil --灵柩
        rooms[1902].exits["crush lan jian;crush mei jian;n"] = nil --灵柩

        rooms[2125].exits["crush sang jie;crush hufa lama;open door;enter"] = nil --桑杰

    --  rooms[1643].exits["hpbrief;cross_neili_west"] = nil --地下河去gm
    --  rooms[4270].exits["crush haoshou shouling;n"] = nil --星宿

    --  rooms[6399].exits["crush shoushan dizi;n"] = nil --emei

    --  rooms[5047].exits["crush hongyi dizi;enter"] = nil --sld
        rooms[5045].exits["crush baiyi dizi;crush hongyi dizi;crush qingyi dizi;crush huangyi dizi;crush heiyi dizi;w"] = nil --sld

    --  rooms[6536].exits["cross_che_wl"] = nil --wuliangshan

    --  rooms[6726].exits["crush bao biao;n"] = nil --pingxi


    --  rooms[5045].exits["crush baiyi dizi;crush hongyi dizi;crush qingyi dizi;crush huangyi dizi;crush heiyi dizi;w"] = nil --pingxi
    --  rooms[5047].exits["crush hongyi dizi;enter"] = nil --pingxi

        rooms[3239].exits["crush jin yiwei;w"] = nil --天坛

    --  rooms[2214].exits["crush xueshan dizi;nu"] = nil --负神雪山弟子

    --  rooms[1630].exits["n"] = nil --新人不去地下河古墓的

    --  rooms[10132].exits["cross_wd_climb"] = nil --武当 五老峰
    --  rooms[10228].exits["cross_wd_climb"] = nil --武当 五老峰

    --  rooms[6580].exits["crush zhu wanli;enter"] = nil --大理朱万里
    --  rooms[6581].exits["crush fu sigui;s"] = nil --大理朱万里

    --  rooms[10560].exits["crush xiao daotong;w"] = nil --武当小道童

    --  rooms[4270].exits["crush haoshou shouling;n"] = nil --星秀

        --4270 crush haoshou shouling;n
    --  rooms[392].exits["crush qin bing;u"] = nil  --xy

        rooms[2973].exits["u"] = nil  --铜雀台
        rooms[10933].exits["enter"] = nil  --金刚伏魔圈
        --                 crush delay 0;give 10 silver to zhuang ding;crush delay 2;n
        rooms[3966].exits["crush delay 0;give 10 silver to zhuang ding;crush delay 2;n"] = nil
        rooms[3966].exits["crush zhuang ding;n"] = 3967

        --10228
    elseif s == "newbie3" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 启用全部地图！3级地图")
        print("修改"..s.."路径成功 map.lua")
        var.update_map_newbie = true
        --rooms[217].exits["ed"] = 259 --杀手帮下去
        rooms[144].exits["crush jian zhanglao;e"] = 145

        rooms[425].exits["n"] = nil
        rooms[425].exits["s"] = nil
        rooms[425].exits["crush shou jiang;n"] = 426
        rooms[425].exits["crush shou jiang;s"] = 424

        rooms[424].exits["crush delay 4;answer 送信;n"] = nil
        rooms[424].exits["s"] = nil
        rooms[424].exits["crush shou jiang;crush delay 4;answer 送信;n"] = 425
        rooms[424].exits["crush shou jiang;s"] = 423
        -- 蒙哥

        rooms[3125].exits["w"] = 3126
        rooms[3126].exits["e"] = nil
        rooms[3126].exits["crush ao bai;e"] = 3125
        --鳌拜

        rooms[5403].exits["crush danei gaoshou;e"] = 5404
        --风波亭

        rooms[10933].exits["enter"] = nil  --金刚伏魔圈
        --rooms[2973].exits["u"] = nil  --铜雀台
        rooms[3085].exits["crush shi wei;s"] = 3086
        rooms[3088].exits["crush shi wei;s"] = 3089
        rooms[3101].exits["crush shi wei;n"] = 3102
        rooms[3103].exits["crush shi wei;s"] = 3104
        -- 北京几个部委

    --  rooms[10933].exits["enter"] = 10934 --金刚伏魔圈
    -- 加入杀梅超风
        rooms[5912].exits["w"] = nil -- 5913
        rooms[5913].exits["w"] = nil -- 5914
        rooms[5914].exits["e"] = nil -- 5913
        rooms[5912].exits["n"] = nil -- 5915
        rooms[5915].exits["n"] = nil -- 5916
        rooms[5916].exits["s"] = nil -- 5915
        rooms[3966].exits["crush delay 0;give 10 silver to zhuang ding;crush delay 2;n"] = nil
        rooms[3966].exits["crush zhuang ding;n"] = 3967
        rooms[5912].exits["crush mei chaofeng;crush chen xuanfeng;crush hei ying;w"] = 5913
        rooms[5913].exits["crush mei chaofeng;crush chen xuanfeng;crush snake;w"] = 5914
        rooms[5914].exits["crush mei chaofeng;crush chen xuanfeng;crush ju mang;crush snake;e"] = 5913
        rooms[5912].exits["crush mei chaofeng;crush chen xuanfeng;crush hei ying;n"] = 5915
        rooms[5915].exits["crush mei chaofeng;crush chen xuanfeng;n"] = 5916
        rooms[5916].exits["crush mei chaofeng;crush chen xuanfeng;s"] = 5915

        rooms[134].exits["e"] = nil
        rooms[134].exits["crush ya yi;crush jiang yaoting;e"] = 121 --jiang yaoting 扬州
    elseif s == "newbie4" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 启用全部地图！危险4级别地图")
        print("修改"..s.."路径成功 map.lua")
        var.update_map_newbie = true
        --rooms[217].exits["ed"] = 259 --杀手帮下去
        rooms[144].exits["crush jian zhanglao;e"] = 145

        rooms[425].exits["n"] = nil
        rooms[425].exits["s"] = nil
        rooms[425].exits["crush shou jiang;n"] = 426
        rooms[425].exits["crush shou jiang;s"] = 424

        rooms[424].exits["crush delay 4;answer 送信;n"] = nil
        rooms[424].exits["s"] = nil
        rooms[424].exits["crush shou jiang;crush delay 4;answer 送信;n"] = 425
        rooms[424].exits["crush shou jiang;s"] = 423
        -- 蒙哥

        rooms[3125].exits["w"] = 3126
        rooms[3126].exits["e"] = nil
        rooms[3126].exits["crush ao bai;e"] = 3125
        --鳌拜

        rooms[5403].exits["crush danei gaoshou;e"] = 5404
        --风波亭

        rooms[3966].exits["crush delay 0;give 10 silver to zhuang ding;crush delay 2;n"] = nil
        rooms[3966].exits["crush zhuang ding;n"] = 3967

        --rooms[2973].exits["u"] = nil  --铜雀台
        rooms[3085].exits["crush shi wei;s"] = 3086
        rooms[3088].exits["crush shi wei;s"] = 3089
        rooms[3101].exits["crush shi wei;n"] = 3102
        rooms[3103].exits["crush shi wei;s"] = 3104
        -- 北京几个部委

        rooms[10933].exits["enter"] = 10934
        --金刚伏魔圈
    -- 加入杀梅超风
        rooms[5912].exits["w"] = nil -- 5913
        rooms[5913].exits["w"] = nil -- 5914
        rooms[5914].exits["e"] = nil -- 5913
        rooms[5912].exits["n"] = nil -- 5915
        rooms[5915].exits["n"] = nil -- 5916
        rooms[5916].exits["s"] = nil -- 5915

        rooms[5912].exits["crush mei chaofeng;crush chen xuanfeng;crush hei ying;w"] = 5913
        rooms[5913].exits["crush mei chaofeng;crush chen xuanfeng;crush snake;w"] = 5914
        rooms[5914].exits["crush mei chaofeng;crush chen xuanfeng;crush ju mang;crush snake;e"] = 5913
        rooms[5912].exits["crush mei chaofeng;crush chen xuanfeng;crush hei ying;n"] = 5915
        rooms[5915].exits["crush mei chaofeng;crush chen xuanfeng;n"] = 5916
        rooms[5916].exits["crush mei chaofeng;crush chen xuanfeng;s"] = 5915

        rooms[134].exits["e"] = nil
        rooms[134].exits["crush ya yi;crush jiang yaoting;e"] = 121 --jiang yaoting 扬州

    elseif s == "开启黑木崖" then
        logs(" 开启黑木崖")
--      var.update_close_map_heimuya_fail = true
--      rooms[7000].exits["cross_che_mz_in"] = 7001 --进梅庄
        rooms[3870].exits["cross_che_ry"] = 3890 --黑木崖下

    elseif s == "关闭黑木崖" then
        logs(" 关闭黑木崖")
--      var.update_close_map_heimuya_fail = true
--      rooms[7000].exits["cross_che_mz_in"] = 7001 --进梅庄
        rooms[3870].exits["cross_che_ry"] = nil --黑木崖下

    elseif s == "开启梅庄四宝" then
        logs(" 开启梅庄")
    --  var.update_map_meizhuang_sibao = true
        rooms[7000].exits["cross_che_mz_in"] = 7001 --进梅庄

    elseif s == "关闭梅庄四宝" then
        logs(" 关闭梅庄")
    --  var.update_map_meizhuang_sibao_fail = true
        rooms[7000].exits["cross_che_mz_in"] = nil
        --[[
        if var.party and var.party ~="日月神教" and var.close_map_heimuya == 1 then --黑木崖
            rooms[3870].exits["cross_che_ry"] = nil --黑木崖下
        end
        if var.party and var.party ~="日月神教" and var.master and var.master ~="任我行" and var.close_map_meizhuang == 1 then --梅庄
            rooms[7000].exits["cross_che_mz_in"] = nil --进梅庄
        end
        ]]
        -- 以后最好可以根据金蛇锥 和负重临时判断是否需要开启

    elseif s == "古墓派" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        var.update_map_party = true
        logs(" 修改古墓地图！")
        print("修改"..s.."路径成功 map.lua")
        rooms[1683].exits["hpbrief;cross_neili_south"] = nil --关闭搬石头出古墓
        rooms[1660].exits["crush delay 0;ask sun popo about 出墓"] = 1529 --门派出来
        rooms[1528].exits["crush delay 0;ask yang nu about 进墓"] = 1679 --进去 --杨过

    elseif s == "星宿派" then


        if var.exp and var.exp>=100000 then
            enter_rooms = {}    -- 重置允许进入房间
            no_enter_rooms = {} -- 重置禁止进入房间
            var.update_map_party = true
            logs(" 大于10万修改星宿派地图成功！")
            rooms[4301].exits["s"] = 4284
            rooms[4284].exits["crush delay 0;juan zhulian"] = 4301

            rooms[4270].exits["crush haoshou shouling;n"] = nil
            rooms[4270].exits["n"] = 4271

            rooms[4275].exits["crush gushou shouling;n"] = nil
            rooms[4275].exits["n"] = 4277

            rooms[4291].exits["crush caihua zi;enter"] = nil
            rooms[4291].exits["enter"] = 4292

            rooms[4291].exits["crush caihua zi;enter"] = nil
            rooms[4291].exits["enter"] = 4292



        elseif var.exp and var.exp<100000 then
            enter_rooms = {}    -- 重置允许进入房间
            no_enter_rooms = {} -- 重置禁止进入房间
            var.update_map_party = true
            logs(" 小于10万exp修改星宿派地图成功！")
            rooms[4270].exits["crush haoshou shouling;n"] = nil
            rooms[4270].exits["n"] = 4271

            rooms[4275].exits["crush gushou shouling;n"] = nil
            rooms[4275].exits["n"] = 4277

            rooms[4291].exits["crush caihua zi;enter"] = nil
            rooms[4291].exits["enter"] = 4292

            rooms[4291].exits["crush caihua zi;enter"] = nil
            rooms[4291].exits["enter"] = 4292

        end
    elseif s == "神龙教" then
        logs(" 修改神龙教地图！")
        var.update_map_party = true
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间

        rooms[2968].exits["cross_che_sld_boat"] = nil
        rooms[5000].exits["cross_che_boat"] = nil
        rooms[5045].exits["crush baiyi dizi;crush hongyi dizi;crush qingyi dizi;crush huangyi dizi;crush heiyi dizi;w"] = nil
        rooms[5047].exits["crush hongyi dizi;enter"] = nil
        rooms[5061].exits["crush hongyi dizi;crush huangyi dizi;crush qingyi dizi;crush baiyi dizi;crush heiyi dizi;n"] = nil

        rooms[2968].exits["crush delay 0;find boat"] = 5000
        rooms[5000].exits["crush delay 0;find boat"] = 2968
        rooms[5045].exits["w"] = 5068
        rooms[5047].exits["enter"] = 5048
        rooms[5061].exits["n"] = 5074

    elseif s == "大轮寺" then
        logs(" 修改大轮寺地图！")
        var.update_map_party = true
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        rooms[2125].exits["crush sang jie;crush hufa lama;open door;enter"] = nil --桑杰
                         --crush sang jie;crush hufa lama;open door;enter
        rooms[2125].exits["xixi;open door;enter"] = 2126

        rooms[2139].exits["crush zayi lama;u"] = nil --杂役喇嘛
        rooms[2139].exits["u"] = 2140

        rooms[2126].exits["crush hufa lama;se"] = nil --饭厅
        rooms[2126].exits["crush hufa lama;e"] = nil
        rooms[2126].exits["crush hufa lama;w"] = nil
        rooms[2126].exits["crush hufa lama;n"] = nil

        rooms[2126].exits["se"] = 2127
        rooms[2126].exits["e"] = 2129
        rooms[2126].exits["w"] = 2131
        rooms[2126].exits["n"] = 2133

        rooms[2134].exits["crush hufa lama;open door;nw"] = nil --舍利塔
        rooms[2134].exits["open door;nw"] = 2141

        rooms[2106].exits["crush hu bayin;w"] = nil --呼巴音
        rooms[2106].exits["w"] = 2107



    elseif s == "明教" then
        logs(" 修改明教地图！")
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        var.update_map_party = true
        rooms[3999].exits["n"] = 4003
        rooms[3992].exits["crush yan yuan;crush qi zhong;nu"] = nil
        rooms[3992].exits["nu"] = 3997

    elseif s == "日月神教" then
        logs(" 修改日月神教地图！")
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        var.update_map_party = true
        rooms[3843].exits["crush tong baixiong;n"] = nil
        rooms[3843].exits["n"] = 3853
        rooms[3870].exits["cross_che_ry"] = 3890 --黑木崖下
        rooms[3901].exits["enter"] = 3906 --承德殿

        if var.master and var.master == "任我行" then
            rooms[7000].exits["cross_che_mz_in"] = nil --进梅庄
            rooms[7000].exits["crush delay 0;knock gate 4;knock gate 2;knock gate 5;knock gate 3"] = 7001 --进梅庄
            rooms[7001].exits["cross_che_mz_out"] = nil --出梅庄
            rooms[7001].exits["open gate;s"] = 7000     --出梅庄
    --  else
    --      rooms[7000].exits["cross_che_mz_in"] = 7001 --进梅庄
        end


    elseif s == "灵鹫宫" then
        logs(" 修改灵鹫宫地图！")
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        var.update_map_party = true

        rooms[1894].exits["crossljg"] = nil
        rooms[1894].exits["crush delay 0;ask yu popo about 上山"] = 1895

        rooms[1902].exits["crush lan jian;crush mei jian;n"] = nil
        rooms[1902].exits["n"] = 1903

        rooms[1903].exits["crush zhu jian;crush ju jian;e"] = nil
        rooms[1903].exits["e"] = 1904

        rooms[1903].exits["crush zhu jian;crush ju jian;n"] = nil
        rooms[1903].exits["n"] = 1915

        rooms[1903].exits["crush zhu jian;crush ju jian;w"] = nil
        rooms[1903].exits["w"] = 1919

    elseif s == "天龙寺" then
        logs(" 修改大理地图！")
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        var.update_map_party = true
        rooms[6580].exits["crush zhu wanli;enter"] = nil
        rooms[6580].exits["enter"] = 6639

        rooms[6581].exits["crush fu sigui;s"] = nil
        rooms[6581].exits["s"] = 6630

        rooms[6561].exits["n"] = 6562
        rooms[6562].objs["男性睡觉"] = "sleep"
        rooms[6562].objs["女性睡觉"] = "sleep"
        rooms[6562].objs["无性睡觉"] = "sleep"


    elseif s == "峨嵋派" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改峨嵋派地图！")
        var.update_map_party = true
        rooms[6399].exits["crush shoushan dizi;n"] = nil
        rooms[6399].exits["n"] = 6400
        rooms[6400].exits["crush wenyue shitai;crush wenxin shitai;crush xunshan dizi;nu"] = nil
        rooms[6400].exits["nu"] = 6401
        rooms[6401].exits["crush xunshan dizi;nu"] = nil
        rooms[6401].exits["nu"] = 6402

    elseif s == "负神删除陈近南房间" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 负神删除陈近南房间！")
        var.update_map_shen = true
        rooms[1247].exits["n"] = nil
        rooms[1248] = nil
        rooms[1249].exits["e"] = nil
        rooms[1250].exits["w"] = nil
        rooms[1247].exits["n;w"] = 1249
        rooms[1247].exits["n;e"] = 1250
        rooms[1248] = nil
        rooms[1249].exits["e;s"] = 1247
        rooms[1250].exits["w;s"] = 1247
        -- 以上快速越过陈近南


        rooms[2224].exits["tell zzxc in;tell @damixs in;yell bridge;n"] = nil -- 凌霄城
        rooms[2224].exits["cross_lxc_yell"] = 2227

    elseif s == "删除欧阳锋房间" then
        var.update_map_ouyangfeng = true
        logs(" 删除欧阳锋房间！")
        rooms[2359].exits["nu;n"] = 2363
        rooms[2363].exits["s;sd"] = 2359
        rooms[2362] = nil
    elseif s == "删除少林松树林" then
        var.update_map_shaolin_songshulin = true
        logs(" 删除少林松树林！")
        rooms[10923].exits["e"] = nil

    elseif s == "打开白驼山沙漠" then
        var.update_map_baituo_shamo = true
        logs(" 打开白驼山沙漠！")
        rooms[2832].exits["crush delay 0;w"] = 2850

    elseif s == "删除神龙岛平台" then
        var.update_map_shenlongdao_pingtai = true
        logs(" 删除神龙岛平台！")
        rooms[5061].exits["crush hongyi dizi;crush huangyi dizi;crush qingyi dizi;crush baiyi dizi;crush heiyi dizi;n"] = nil
                --        "crush hongyi dizi;crush huangyi dizi;crush qingyi dizi;crush baiyi dizi;crush heiyi dizi;n"
    elseif s == "打开段誉房间" then
        var.update_map_duanyu = true
        logs(" 打开段誉房间")
        rooms[6561].exits["n"] = nil
        rooms[6561].exits["crush duan yu;n"] = 6562
        --
    elseif s == "正神删除丁春秋房间" then
        logs(" 正神删除丁春秋房间！")
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        var.update_map_shen = true
    --  rooms[4283].exits["n"] = nil

        rooms[2214].exits["crush xueshan dizi;nu"] = nil
        rooms[2214].exits["nu"] = 2218 --雪山弟子雪关拦路

        rooms[2224].exits["tell zzxc in;tell @damixs in;yell bridge;n"] = 2227 -- 凌霄城
        rooms[2224].exits["cross_lxc_yell"] = nil

        if var.exp and var.exp>10000000 then
    --      rooms[1248].exits["e"] = nil
    --      rooms[1248].exits["crush ma chaoxing;e"] = 1250
        end

        if 1==0 and var.shen and var.shen<1001 then
            rooms[2380].exits["crush men wei;e"] = nil
            rooms[2380].exits["e"] = 2377

            rooms[2358].exits["crush men wei;n"] = nil
            rooms[2358].exits["n"] = 2359

            rooms[4270].exits["crush haoshou shouling;n"] = nil
            rooms[4270].exits["n"] = 4271

            rooms[4275].exits["crush gushou shouling;n"] = nil
            rooms[4275].exits["n"] = 4277
        end

    elseif s == "姑苏慕容" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改姑苏慕容地图！")
        var.update_map_party = true
--      rooms[5980].exits["cross_che_szmr"] = 5982
--      rooms[5982].exits["cross_che_mrsz"] = 5980
        rooms[5980].exits["cross_che_szmr"] = nil
        rooms[5982].exits["cross_che_mrsz"] = nil
        rooms[5980].exits["crush delay 0;find boat"] = 5982
        rooms[5982].exits["crush delay 0;find boat"] = 5980
        rooms[6010].exits["s"] = 6011 --厨房
        rooms[6042].exits["crush delay 0;bo huacao"] = 6043 --bo
        rooms[6042].exits["crush delay 0;look zhuang;cai huanshi"] = 6044 --bo


    elseif s == "白驼山" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改白驼山地图！")
        var.update_map_party = true
        rooms[2364].exits["crush delay 0;ask trainer about 练功"] = 2361

    elseif s == "桃花岛" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改桃花岛地图！")
        var.update_map_party = true
        rooms[5951].exits["e"] = 5963 --归云
        rooms[5966].exits["crush zong guan;s"] = nil --归云
        rooms[5966].exits["s"] = 5974 --归云
        rooms[5966].exits["e"] = 5975 --归云

        rooms[5963].objs["男性睡觉"] = "sleep"
        rooms[5963].objs["女性睡觉"] = "sleep"
        rooms[5963].objs["无性睡觉"] = "sleep"

    elseif s == "朝廷" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改朝廷地图！")
        var.update_map_party = true

          rooms[5491].exits["northwest"] = 5500

    elseif s == "华山派" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改华山派地图！")
        var.update_map_party = true

        rooms[652].exits["crush lu dayou;s"] = nil
        rooms[652].exits["s"] = 653

        rooms[656].exits["n"] = 659
        rooms[656].exits["crush liang fa;n"] = nil

    elseif s == "峨嵋派拦路" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改峨嵋派拦路地图！")
        var.update_map_emei_lanlu = true

        rooms[6399].exits["crush shoushan dizi;n"] = nil
        rooms[6399].exits["n"] = 6400
        rooms[6400].exits["crush wenyue shitai;crush wenxin shitai;crush xunshan dizi;nu"] = nil
        rooms[6400].exits["nu"] = 6401
        rooms[6401].exits["crush xunshan dizi;nu"] = nil
        rooms[6401].exits["nu"] = 6402

    elseif s == "丐帮" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改丐帮地图！")
        var.update_map_party = true
        rooms[117].exits["enter"] = 144 --简长老踢人
        rooms[144].exits["crush jian zhanglao;e"] = nil
        rooms[144].exits["e"] = 145

    elseif s == "全真派" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改全真派地图！")
        var.update_map_party = true
        rooms[1597].exits["s"] = 1598


    elseif s == "少林派" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改少林派地图！")
        var.update_map_party = true
        rooms[1353].exits["crush xu ming;crush xu tong;eu"] = nil
        rooms[1353].exits["eu"] = 1354

        if var.close_map_shaolin_jly and var.close_map_shaolin_jly == 0 then
            rooms[1402].exits["nu"] = 1408 --戒律院
        end

        if var.close_map_shaolin_dmy and var.close_map_shaolin_dmy == 0 then
            rooms[1460].exits["nu"] = 1461 --达摩院
            rooms[1461].exits["sd"] = 1460
        end

    elseif s == "关闭达摩院" then
        rooms[1460].exits["nu"] = nil --达摩院
        rooms[1461].exits["sd"] = nil

    elseif s == "男性" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改男性适用地图！")
        var.update_map_sex = true

        rooms[6631] = nil
        rooms[6630].exits["e"] = nil --dl

        rooms[5062] = nil
        rooms[5061].exits["s"] = nil --sld

        rooms[220] = nil
        rooms[218].exits["s"] = nil --ssb

        rooms[5335] = nil
        rooms[5333].exits["w"] = nil --quanzhou

        rooms[2300] = nil
        rooms[2297].exits["s"] = nil --lxc
        --crush xu ming;crush xu tong;eu
        rooms[1353].exits["crush xu ming;crush xu tong;eu"] = nil --少林
        rooms[1353].exits["unwield all;eu"] = 1354

        rooms[1354].exits["e"] = nil
        rooms[1354].exits["nu"] = nil
        rooms[1354].exits["wieldweapon;e"] = 1355
        rooms[1354].exits["wieldweapon;nu"] = 1356

        rooms[2151].exits["crush delay 2;eu"] = nil --男性baoxiang不拦路
        rooms[2151].exits["eu"] = 2152



    elseif s == "女性" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 修改女性适用地图！")
        var.update_map_sex = true

        rooms[6633] = nil
        rooms[6630].exits["w"] = nil --dl

        rooms[5063] = nil
        rooms[5061].exits["w"] = nil --sld

        rooms[219] = nil
        rooms[218].exits["n"] = nil --ssb

    elseif s == "华山村王小二" then
        enter_rooms[627] = true   -- 重置允许进入房间
        no_enter_rooms[627] = nil
        logs(" 增加王小二地图！")
        var.update_map_wangxiaoer = true
        rooms[615].exits["crush delay 0;enter hole"] = 627

    elseif s == "襄阳郭靖" then
        enter_rooms[344] = true
        no_enter_rooms[344] = nil
        logs(" 增加襄阳郭靖地图！")
        var.update_map_guojing = true
        rooms[343].exits["s"] = 344


    elseif s == "襄阳雪峰山顶" then

        no_enter_rooms[427] = nil
        no_enter_rooms[428] = nil
        no_enter_rooms[429] = nil
        no_enter_rooms[430] = nil
        logs(" 增加襄阳雪峰山顶地图！")
        var.update_map_xuefeng = true

        rooms[331].exits["u"] = 427

    elseif s == "司南" then
        --enter_rooms = {}    -- 重置允许进入房间
        --no_enter_rooms = {} -- 重置禁止进入房间
        for k,v in pairs(no_enter_rooms) do
            if rooms[k] and rooms[k].area=="壮族" then
                no_enter_rooms[k] = nil
            end
        end
        logs(" 增加壮族老林地图！")
        var.update_map_laolin = true
        var.update_map_laolin_lost = nil
        rooms[5447].exits["cross_che_lafll"] = 6799 --临安府 -- 老林
    elseif s == "丢失司南" then
        --enter_rooms = {}    -- 重置允许进入房间
        --no_enter_rooms = {} -- 重置禁止进入房间
        for k,v in pairs(enter_rooms) do
            if rooms[k] and rooms[k].area=="壮族" then
                enter_rooms[k] = nil
            end
        end
        logs(" 删除壮族老林地图！")
        var.update_map_laolin_lost = true
        var.update_map_laolin = nil
        rooms[5447].exits["cross_che_lafll"] = nil

    elseif s == "灭绝的邀请函" then
        --enter_rooms = {}    -- 重置允许进入房间
        --no_enter_rooms = {} -- 重置禁止进入房间
        for k,v in pairs(no_enter_rooms) do
            if rooms[k] and string.find(rooms[k].area,"^峨") then
                no_enter_rooms[k] = nil
            end
        end

        logs(" 修改灭绝的邀请函地图!")
        var.update_map_emei = true
        var.update_map_emei_lost = nil
        rooms[6399].exits["crush shoushan dizi;n"] = nil
        rooms[6399].exits["n"] = 6400
        rooms[6400].exits["crush wenyue shitai;crush wenxin shitai;crush xunshan dizi;nu"] = nil
        rooms[6400].exits["nu"] = 6401
        rooms[6401].exits["crush xunshan dizi;nu"] = nil
        rooms[6401].exits["nu"] = 6402


    elseif s == "丢失灭绝的邀请函" then
        --enter_rooms = {}    -- 重置允许进入房间
        --no_enter_rooms = {} -- 重置禁止进入房间
        for k,v in pairs(enter_rooms) do
            if rooms[k] and string.find(rooms[k].area,"^峨") and k>6399 then --山门以上
                enter_rooms[k] = nil
            end
        end
        logs(" 删除灭绝的邀请函地图！")
        var.update_map_emei_lost = true
        var.update_map_emei = nil
        rooms[6399].exits["crush shoushan dizi;n"] = 6400
        rooms[6399].exits["n"] = nil
        rooms[6400].exits["crush wenyue shitai;crush wenxin shitai;crush xunshan dizi;nu"] = 6401
        rooms[6400].exits["nu"] = nil
        rooms[6401].exits["crush xunshan dizi;nu"] = 6402
        rooms[6401].exits["nu"] = nil

    elseif s == "水靠" then
        no_enter_rooms[6124] = nil
        enter_rooms[6124] = true
        logs(" 增加玄铁剑山洞地图！")
        var.update_map_shuikao = true
        var.update_map_shuikao_lost = nil

        rooms[6122].exits["ask yu fu about 过河;give fish to yu fu;crush delay 2;swim"] = 6124


    elseif s == "丢失水靠" then
        enter_rooms[6124] = nil
        no_enter_rooms[6124] = true
        logs(" 删除玄铁剑山洞地图！")
        var.update_map_shuikao_lost = true
        var.update_map_shuikao = nil

        rooms[6122].exits["ask yu fu about 过河;give fish to yu fu;crush delay 2;swim"] = nil

    elseif s == "开放莫高窟" then
    --  no_enter_rooms[2833] = nil
    --  no_enter_rooms[2834] = nil
        no_enter_rooms[2835] = nil
    --  rooms[2830].exits["crush delay 2;climb mount"] = 2833
        rooms[2834].exits["crush delay 0;drop coin;enter hole"] = 2835
        var.update_map_mogaoku_lost = nil
        var.update_map_mogaoku = true

    elseif s == "关闭莫高窟" then
    --  enter_rooms[2833] = nil
    --  enter_rooms[2834] = nil
        enter_rooms[2835] = nil
    --  rooms[2830].exits["crush delay 2;climb mount"] = nil
        rooms[2834].exits["crush delay 0;drop coin;enter hole"] = nil
        var.update_map_mogaoku_lost = true
        var.update_map_mogaoku = nil

    elseif s == "铜哨" then

        no_enter_rooms[5968] = nil
        no_enter_rooms[5969] = nil
        no_enter_rooms[5970] = nil
        no_enter_rooms[5971] = nil
        no_enter_rooms[5972] = nil
        no_enter_rooms[5973] = nil

        logs(" 增加归云庄桃林地图！")
        var.update_map_pipe = true
        var.update_map_pipe_lost = nil
        rooms[5960].exits["crush a xiang;blow pipe"] = 5968

    elseif s == "丢失铜哨" then

        enter_rooms[5968] = nil
        enter_rooms[5969] = nil
        enter_rooms[5970] = nil
        enter_rooms[5971] = nil
        enter_rooms[5972] = nil
        enter_rooms[5973] = nil
        logs(" 删除归云庄桃林地图！")
        var.update_map_pipe_lost = true
        var.update_map_pipe = nil

        rooms[5960].exits["crush a xiang;blow pipe"] = nil



    elseif s == "火折" then
        logs(" 增加福州密室地图！")
        var.update_map_fire = true
        var.update_map_fire_lost = nil

        no_enter_rooms[5374] = nil
        no_enter_rooms[5375] = nil
        no_enter_rooms[5376] = nil
        rooms[5372].exits["crush delay 0;use fire;zuan"] = 5374

    elseif s == "丢失火折" then
        logs(" 删除福州密室地图！")
        var.update_map_fire = nil
        var.update_map_fire_lost = true
        enter_rooms[5374] = nil
        enter_rooms[5375] = nil
        enter_rooms[5376] = nil
        rooms[5372].exits["crush delay 0;use fire;zuan"] = nil

    elseif s == "修改为护镖地图" then

        yell_boat_low_cost()  --过江权重变低
        rooms[1815].exits["cross_che_hh"] = nil --长安黄河兰州
        rooms[2823].exits["cross_che_hh"] = nil --长安黄河兰州

        rooms[2015] = nil -- 树洞下
        rooms[2078] = nil -- 树洞下

        rooms[6354].exits["crush wait nd"] = 794 --金牛道 30
        rooms[794].exits["su"] = 6354 --金牛道 30

    --  rooms[1999].exits["sw"] = 2192 --灵州-大轮寺
        rooms[1999].exits["sw"] = nil --灵州-大轮寺

        rooms[6354].cost = 0 --金牛道 30
        rooms[2175].cost = 0 --藏边土路 30
        rooms[6331].cost = 0 --瞿塘巫峡纤道 30
        --rooms[2192].cost = 0-- 牧场 30
        rooms[1856].cost = 0-- 六盘山 50
        rooms[452].cost = 0-- 沼泽 20

        --黄河

        --删除坐车
        rooms[2095].exits["cross_che_dlsjz"] = nil -- 5738 大轮寺--江州
        rooms[2095].exits["cross_che_dlscd"] = nil -- 6356 大轮寺--成都
        rooms[2095].exits["cross_che_dlskm"] = nil -- 6686 大轮寺--昆明
    --  rooms[2095].exits["cross_che_dlsjx"] = nil -- 6686 大轮寺--昆明

        rooms[5738].exits["cross_che_jzcd"] = nil --江州-成都
        rooms[6356].exits["cross_che_cdjz"] = nil --成都-江州

        rooms[5738].exits["cross_che_jzdls"] = nil -- 5738 江州--大轮寺
        rooms[6356].exits["cross_che_cddls"] = nil -- 6356 成都--大轮寺
        rooms[6686].exits["cross_che_kmdls"] = nil -- 6686 昆明--大轮寺
    --  rooms[6106].exits["cross_che_jxdls"] = nil -- 6686 大轮寺--昆明

    elseif s == "取消护镖地图" then
    --  logs(" 取消护镖地图！")

        yell_boat_high_cost() --过江权重变高
        normal_enter_boat()

        rooms[1815].exits["cross_che_hh"] = 2823 --长安黄河兰州
        rooms[2823].exits["cross_che_hh"] = 1815 --长安黄河兰州

        rooms[6354].exits["crush wait nd"] = nil --金牛道 30
        rooms[794].exits["su"] = nil --金牛道 30

        rooms[1999].exits["sw"] = nil --灵州-大轮寺

        rooms[2015] = {
            id = 2015,
            name = "树洞下",
            desc = "这是老槐树底部，四周光线昏暗，人影晃晃，似乎有几个黑暗的洞口在你身边，通向四面八方。  一位老乞丐大咧咧地坐在正中的地上。不经意中你发现墙壁上画着幅粗糙的路线草图（map）。 ##梁长老=liang zhanglao;",
            area = "丐帮",
            relation = "",
            links = "",
            exits = {
              ["1"] = 2017,
              ["5"] = 2071,
              ["3"] = 2065,
              ["2"] = 2062,
              ["u"] = 2016,
              ["4"] = 2068,
              ["7"] = 2014,
              ["9"] = 2074,
              },
            objs = {
              ["梁长老"] = "liang zhanglao",
              },
            cost = 0,
            center = 2016,
            }
        rooms[2078] = {
            id = 2078,
            name = "暗道",
            desc = "这是丐帮 极其秘密的地下通道，乃用丐帮几辈人之心血掘成。",
            area = "丐帮",
            relation = "雪洞              暗道＼        ／暗道／雪洞",
            links = "northeast;northwest;southwest",
            exits = {
              ["ne"] = 2077,
              ["sw"] = 2080,
              ["nw"] = 2079,
              },
            objs = {
              },
            cost = 0,
            center = 2016,
            }


        rooms[6354].cost = 50 --金牛道 30
        rooms[2175].cost = 30 --藏边土路 30
        rooms[6331].cost = 30 --瞿塘巫峡纤道 30
        --rooms[2192].cost = 0-- 牧场 30
        rooms[1856].cost = 50-- 六盘山 50
        rooms[452].cost = 20-- 沼泽 20


        --继续坐车
        rooms[2095].exits["cross_che_dlsjz"] = 5738 -- 大轮寺--江州
        rooms[2095].exits["cross_che_dlscd"] = 6356 --大轮寺--成都
        rooms[2095].exits["cross_che_dlskm"] = 6686 --大轮寺--昆明
    --  rooms[2095].exits["cross_che_dlsjx"] = 6106 -- 6686 大轮寺--昆明

        --
        rooms[5738].exits["cross_che_jzcd"] = 6356 --江州-成都
        rooms[6356].exits["cross_che_cdjz"] = 5738 --成都-江州

        rooms[5738].exits["cross_che_jzdls"] = 2095 -- 5738 江州--大轮寺
        rooms[6356].exits["cross_che_cddls"] = 2095 -- 6356 成都--大轮寺
        rooms[6686].exits["cross_che_kmdls"] = 2095 -- 6686 昆明--大轮寺
    --  rooms[6106].exits["cross_che_jxdls"] = 2095 -- 6686 大轮寺--昆明

    elseif s=="更新轻功达标以上房间" then
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间
        logs(" 增加轻功100以上地图！")
        var.update_map_dodge = true

        rooms[6536].exits["cross_che_wl"] = 6537 --wuliangshan


    --  rooms[3239].exits["crush jin yiwei;w"] = 3240 --天坛


        rooms[1630].exits["n"] = 1631

    else



    end

    -- 其他
    if var.close_map_zbsd and var.close_map_zbsd == 0 and not var.update_map_zbsd then
        enter_rooms[5527] = true
        no_enter_rooms[5527] = nil
        var.update_map_zbsd = true
        logs(" 增加装备商店地图!")
        rooms[5490].exits["w"] = 5527

    end



end

function close_mr_caizhuang()

        rooms[5982].exits["crush delay 0;cai yanziwu"] = nil
        rooms[5982].exits["crush delay 0;cai tingxiang"] = nil
        rooms[6000].exits["crush delay 0;cai qinyun"] = nil
        rooms[6000].exits["crush delay 0;cai yanziwu"] = nil
        rooms[6013].exits["crush delay 0;cai qinyun"] = nil --5982
        rooms[6013].exits["crush delay 0;cai tingxiang"] = nil --5982
        rooms[5999].exits["cross_che_qytx"] = 6000  --qinyun tingxiang
        rooms[5999].exits["cross_che_qyyzw"] = 6013 --qinyun yanziwu
end

function yell_boat_high_cost()
    rooms[1790].cost = 1
    rooms[1796].cost = 1
    rooms[1811].cost = 1
    rooms[1815].cost = 1
    rooms[2800].cost = 1
    rooms[2806].cost = 1
    rooms[2819].cost = 1
    rooms[2823].cost = 1

    rooms[281].cost = 1
    rooms[298].cost = 1
    rooms[307].cost = 1
    rooms[5100].cost = 1
    rooms[5118].cost = 1
    rooms[5127].cost = 1
end

function yell_boat_low_cost()
    rooms[1790].cost = 0
    rooms[1796].cost = 0
    rooms[1811].cost = 0
    rooms[1815].cost = 0
    rooms[2800].cost = 0
    rooms[2806].cost = 0
    rooms[2819].cost = 0
    rooms[2823].cost = 0

    rooms[281].cost = 0
    rooms[298].cost = 0
    rooms[307].cost = 0
    rooms[5100].cost = 0
    rooms[5118].cost = 0
    rooms[5127].cost = 0
end

function update_map_pozhen() --破阵地图更新，回来残血一律不杀人
        var.update_map_pozhen = 1
        enter_rooms = {}    -- 重置允许进入房间
        no_enter_rooms = {} -- 重置禁止进入房间

        rooms[2377].exits["w"] = nil --baituo 西门不进去，回不来
        rooms[3054].exits["cross_che_zjc"] = nil --紫禁城声望不够
        rooms[5370].exits["break men;n"] = nil --进去就没内力出来了 -- 可能
        rooms[1643].exits["hpbrief;cross_neili_west"] = nil --地下河进去古墓没法出来

        rooms[3992].exits["crush yan yuan;crush qi zhong;nu"] = nil --明教看门打不过

end


--[[
function add_rooms() --手动的...
    if not var.addroom then var.addroom=10699 end
        var.addroom = var.addroom +1
    print(var.addroom)
        chatline=chatline or ""
    local softpath=Result("%syspath()")



    local chatfile=io.open(softpath.."save\\map.txt","a+")
    local lens=chatfile:seek("end") --检查文件大小

        if lens>5000000 then --chat文件太大了 5m
            chatfile:close()
            local newchatfile=io.open(softpath.."save\\chat.txt","w+")
            newchatfile:write("["..os.date("%m月%d日%H时%M分%S秒").."] "..chatline.."\n")
            newchatfile:close()
        else
chatfile:write('\n')
            chatfile:write("  ["..var.addroom.."] = {")
            chatfile:write('\n')
            chatfile:write("    id = "..var.addroom..",")
            chatfile:write('\n')
            chatfile:write('    name = "'..var.roomname..'",')
            chatfile:write('\n')
            chatfile:write('    desc = "'..var.roomdesc..'",')
            chatfile:write('\n')
            chatfile:write('    area = "武当山",')
            chatfile:write('\n')
            chatfile:write('    relation = "",')
            chatfile:write('\n')
            chatfile:write('    links = "",')
            chatfile:write('\n')
            chatfile:write('    exits = {')
            chatfile:write('\n')
            local n = numitems(var.roomexit,";")
            for k=1,n do
            chatfile:write('      ["'..nitem(var.roomexit,k,";")..'"] = "",')
chatfile:write('\n')
            end
            chatfile:write('      },')
            chatfile:write('\n')
            chatfile:write('    objs = {')
            chatfile:write('\n')
            chatfile:write('      },')
            chatfile:write('\n')
            chatfile:write('    cost = 0,')
            chatfile:write('\n')
            chatfile:write("    center = 471,")
            chatfile:write('\n')
            chatfile:write('    },')
            chatfile:write('\n')



            chatfile:close()
        end

end
]]
function add_rooms() --手动的...
    if not var.addroom then var.addroom=10989 end
        var.addroom = var.addroom +1
    print(var.addroom)
        chatline=chatline or ""
    local softpath=Result("%syspath()")



    local chatfile=io.open(softpath.."save\\map.txt","a+")
    local lens=chatfile:seek("end") --检查文件大小

        if lens>5000000 then --chat文件太大了 5m
            chatfile:close()
            local newchatfile=io.open(softpath.."save\\chat.txt","w+")
            newchatfile:write("["..os.date("%m月%d日%H时%M分%S秒").."] "..chatline.."\n")
            newchatfile:close()
        else
chatfile:write('\n')
            chatfile:write("  ["..var.addroom.."] = {")
            chatfile:write('\n')
            chatfile:write("    id = "..var.addroom..",")
            chatfile:write('\n')
            chatfile:write('    name = "'..var.roomname..'",')
            chatfile:write('\n')
            chatfile:write('    desc = "'..var.roomdesc..'",')
            chatfile:write('\n')
            chatfile:write('    area = "少林寺",')
            chatfile:write('\n')
            chatfile:write('    relation = "",')
            chatfile:write('\n')
            chatfile:write('    links = "",')
            chatfile:write('\n')
            chatfile:write('    exits = {')
            chatfile:write('\n')
            local n = numitems(var.roomexit,";")
            for k=1,n do
            chatfile:write('      ["'..nitem(var.roomexit,k,";")..'"] = "",')
chatfile:write('\n')
            end
            chatfile:write('      },')
            chatfile:write('\n')
            chatfile:write('    objs = {')
            chatfile:write('\n')
            chatfile:write('      },')
            chatfile:write('\n')
            chatfile:write('    cost = 0,')
            chatfile:write('\n')
            chatfile:write("    center = 1467,")
            chatfile:write('\n')
            chatfile:write('    },')
            chatfile:write('\n')



            chatfile:close()
        end

end

function load_other_setting()
    if not var.update_map_newbie and var["newbiemap"] and var["newbiemap"]==1 then
        update_map("newbie")
    end
end

function output_rooms()
    local path = Result('%syspath()')
    local file=io.open(path.."new_rooms.txt","w+")

    file:write('rooms = {\n')
    for i = 1,20000 do
        if rooms[i] then
            local j = i*2
            file:write('  ['..j..'] = {\n')
            file:write('    id = '..j..',\n')
            file:write('    name = "'..rooms[i].name..'",\n')
            file:write('    desc = "'..rooms[i].desc..'",\n')
            file:write('    area = "'..rooms[i].area..'",\n')
            file:write('    relation = "'..rooms[i].relation..'",\n')
            file:write('    links = "'..rooms[i].links..'",\n')

            local linkscount = 0
            if rooms[i].links==nil or rooms[i].links=="" then
                linkscount=0
            else
                linkscount=0
                for a in string.gmatch(rooms[i].links,'(.)') do
                    linkscount=linkscount+string.byte(a)
                end
            end

            file:write('    linkscount = '..linkscount..',\n')

            file:write('    exits = {\n')
            for k,v in pairs(rooms[i].exits) do
                local b = v*2
                file:write('      ["'..k..'"] = '..b..',\n')
            end
            file:write('    },\n')

            file:write('    objs = {\n')
            for k,v in pairs(rooms[i].objs) do
                file:write('      ["'..k..'"] = "'..v..'",\n')
            end
            file:write('    },\n')
            file:write('    cost = 0,\n')
            file:write('    center = 0,\n')
            file:write('    },\n')
        end
    end
    file:write('}')
    file:close()
    file = nil
end
