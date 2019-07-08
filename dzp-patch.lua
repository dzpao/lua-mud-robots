-- 字符串到拼音（首字母）
function string2pinyin(s)
     for p, c in utf8.codes(s) do
     end
end

if utf8 == nil then
    utf8 = {}
    -- utf8.charpattern = "[\0-\x7F\xC2-\xF4][\x80-\xBF]*"
    utf8.charpattern = "[\0-\127\194-\244][\128-\191]*"
end
