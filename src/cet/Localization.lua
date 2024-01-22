--[[
Copyright (c) 2024 [Marco4413](https://github.com/Marco4413/CP77-DiscordRPC2)

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
    _locale = {},
    _localeName = nil,
    _fallbackLocale = {},
    _locales = { ["en"] = require "locales/en" }
}

Localization._fallbackLocale = Localization._locales["en"]

---@param localeName string The name used internally by the Localization system to identify the locale
---@param locale table The key-value pairs defining the translation
---@return boolean ok Whether the locale was registered
---@return string|nil error The reason the locale was not registered, if any
function Localization:RegisterLocale(localeName, locale)
    if type(localeName) ~= "string" then
        return false, "Provided locale name is not a string."
    elseif type(locale) ~= "table" then
        return false, "Provided locale is not a table."
    elseif self._locales[localeName] then
        return false, "Duplicate locale."
    end

    self._locales[localeName] = locale
    return true, nil
end

function Localization:SetLocale(localeName)
    local newLocale = self._locales[localeName]
    if not newLocale then return false; end
    self._locale = newLocale
    self._localeName = localeName
    return true
end

Localization:SetLocale("en")

function Localization:GetLocales()
    local availLocales = {}
    for k, v in next, self._locales do
        table.insert(availLocales, {
            name = k,
            displayName = v["Locale.Name"] or k
        })
    end
    return availLocales
end

function Localization:GetCurrentLocale()
    return {
        name = self._localeName,
        displayName = self._locale["Locale.Name"] or self._localeName
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
    return self._locale[key] or self._fallbackLocale[key] or key
end

function Localization:GetFormatted(key, formats)
    return self.FormatString(self:Get(key), formats)
end

return Localization
