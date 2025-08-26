local isfile: (file: string) -> boolean = isfile or function(file: string)
        local suc: boolean, res: string = pcall(function()
                return readfile(file);
        end);
        return suc and res ~= nil and res ~= '';
end;

local delfile: (file: string) -> nil = delfile or function(file: string)
        writefile(file, '');
end;

local downloadFile: (path: string, func: ((string) -> string)?) -> string = function(path: string, func: ((string) -> string)?)
        if not isfile(path) then
		local suc: boolean, res: string? = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/'..select(1, path:gsub('velo/', '')), true);
		end);
                if not suc or res == '404: Not Found' then
                        error(res);
                end;
                if path:find('.lua') then
                        res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after velocity updates.\n' .. res;
                end;
                writefile(path, res);
        end;
        return (func or readfile)(path);
end;

local wipeFolder: (path: string) -> nil = function(path: string)
        if not isfolder(path) then return; end;
        for _, file: string in listfiles(path) do
                if file:find('loader') then continue; end;
                if isfile(file) and select(1, readfile(file):find(
                        '--This watermark is used to delete the file if its cached, remove it to make the file persist after velocity updates.'
                )) == 1 then
                        delfile(file);
                end;
        end;
end;

for _, folder: string in {'velo', 'velo/games', 'velo/profiles', 'velo/assets', 'velo/libraries', 'velo/guis'} do
        if not isfolder(folder) then
                makefolder(folder);
        end;
end;

if not shared.VeloDeveloper then
        local _, subbed: string = pcall(function()
                return game:HttpGet('https://github.com/Copiums/Velocity');
        end);
        local commit: string? = subbed:find('currentOid');
        commit = commit and subbed:sub(commit + 13, commit + 52) or nil;
        commit = commit and #commit == 40 and commit or 'main';
        if commit == 'main' or (isfile('velo/profiles/commit.txt') and readfile('velo/profiles/commit.txt') or '') ~= commit then
                wipeFolder('velo');
                wipeFolder('velo/games');
                wipeFolder('velo/guis');
                wipeFolder('velo/libraries');
        end;
        writefile('velo/profiles/commit.txt', commit);
end;

return loadstring(downloadFile('velo/main.lua'), 'main')();
