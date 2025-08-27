local velo = shared.veloc
local loadstring = function(...)
    local res, err = loadstring(...)
    if err and velo then
        velo:CreateNotification('Velo', 'Failed to load : '..err, 30, 'alert')
    end
    return res
end

local isfile = isfile or function(file)
    local suc, res = pcall(function()
        return readfile(file)
    end)
    return suc and res ~= nil and res ~= ''
end

local function downloadFile(path, func)
    if not isfile(path) then
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/'..select(1, path:gsub('velo/', '')), true)
        end)
        if not suc or res == '404: Not Found' then
            error(res)
        end
        if path:find('.lua') then
            res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after velocity updates.\n'..res
        end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

velo.Place = 8768229691
if isfile('velo/games/'..velo.Place..'.lua') then
    loadstring(readfile('velo/games/'..velo.Place..'.lua'), 'skywars')()
else
    if not shared.VeloDeveloper then
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/games/'..velo.Place..'.lua', true)
        end)
        if suc and res ~= '404: Not Found' then
            loadstring(downloadFile('velo/games/'..velo.Place..'.lua'), 'skywars')()
        end
    end
end
