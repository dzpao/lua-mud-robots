if utf8 == nil then
    utf8 = {}
    utf8.charpattern = "[\0-\127\194-\244][\128-\191]*"
end

-- 字符串到拼音（首字母）
function string2pinyin(s)
     for p, c in utf8.codes(s) do
     end
end

printf = function(s,...)
    return Print(s:format(...))
end

lua_require = require
require = function (name)
    t1 = os.clock()
    ret = lua_require(name)
    t2 = os.clock()
    elapse = t2 - t1
    printf("消耗时间 %.3fs 以加载 %s", elapse, name)
    return ret
end

GetVar = function (name)
    return var.name
end

Run=exe
Show=Echo
