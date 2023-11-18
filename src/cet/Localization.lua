--[[
Copyright (c) 2023 [Marco4413](https://github.com/Marco4413/CP77-DiscordRPC2)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

local Localization = {
    locale = {},
    localeName = nil,
    fallbackLocale = {},
    locales = {
        ["en"] = require "locales/en",
        ["it"] = require "locales/it",
    }
}

Localization.fallbackLocale = Localization.locales["en"]

function Localization:SetLocale(localeName)
    local newLocale = self.locales[localeName]
    if not newLocale then return false; end
    self.locale = newLocale
    self.localeName = localeName
    return true
end

Localization:SetLocale("en")

function Localization:GetLocales()
    local availLocales = {}
    for k, v in next, self.locales do
        table.insert(availLocales, {
            name = k,
            displayName = v["Locale.Name"] or k
        })
    end
    return availLocales
end

function Localization:GetCurrentLocale()
    return {
        name = self.localeName,
        displayName = self.locale["Locale.Name"] or self.localeName
    }
end

---@param str string
---@param formats table
---@return string
function Localization.FormatString(str, formats)
    if not (str and formats) then return str; end
    local res = str:gsub("({([^}]+)})", function (expr, key)
        local format = formats[key] or formats[tonumber(key)]
        return (not format) and expr or format
    end)
    return res
end

function Localization:Get(key)
    return self.locale[key] or self.fallbackLocale[key] or key
end

function Localization:GetFormatted(key, formats)
    return self.FormatString(self:Get(key), formats)
end

return Localization
