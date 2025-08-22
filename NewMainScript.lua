--[[         _____                    _____                    _____                   _____          
        /\    \                  /\    \                  /\    \                 /\    \         
       /::\____\                /::\    \                /::\    \               /::\    \        
      /:::/    /               /::::\    \              /::::\    \             /::::\    \       
     /:::/    /               /::::::\    \            /::::::\    \           /::::::\    \      
    /:::/    /               /:::/\:::\    \          /:::/\:::\    \         /:::/\:::\    \     
   /:::/____/               /:::/__\:::\    \        /:::/__\:::\    \       /:::/__\:::\    \    
   |::|    |               /::::\   \:::\    \      /::::\   \:::\    \     /::::\   \:::\    \   
   |::|    |     _____    /::::::\   \:::\    \    /::::::\   \:::\    \   /::::::\   \:::\    \  
   |::|    |    /\    \  /:::/\:::\   \:::\    \  /:::/\:::\   \:::\____\ /:::/\:::\   \:::\    \ 
   |::|    |   /::\____\/:::/  \:::\   \:::\____\/:::/  \:::\   \:::|    /:::/__\:::\   \:::\____\
   |::|    |  /:::/    /\::/    \:::\  /:::/    /\::/    \:::\  /:::|____\:::\   \:::\   \::/    /
   |::|    | /:::/    /  \/____/ \:::\/:::/    /  \/_____/\:::\/:::/    / \:::\   \:::\   \/____/ 
   |::|____|/:::/    /            \::::::/    /            \::::::/    /   \:::\   \:::\    \     
   |:::::::::::/    /              \::::/    /              \::::/    /     \:::\   \:::\____\    
   \::::::::::/____/               /:::/    /                \::/____/       \:::\   \::/    /    
    ~~~~~~~~~~                    /:::/    /                  ~~              \:::\   \/____/     
                                 /:::/    /                                    \:::\    \         
                                /:::/    /                                      \:::\____\        
                                \::/    /                                        \::/    /        
                                 \/____/                                          \/____/         

    The #1 Roblox Bedwars Script on the market.

        - Xylex/7GrandDad - developer / organizer
]]--

local isfile: (string) -> boolean = isfile or function(file: string): boolean
    	local suc: boolean, res: string? = pcall(function(): string? return readfile(file) end);
    	return suc and res ~= nil;
end;
local delfile: (string) -> () = delfile or function(file: string): () writefile(file, "") end;

local function downloadFile(path: string, func: ((string) -> any)?): string
		if not isfile(path) then
				local suc: boolean, res: string? = pcall(function(): string
						return game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/'..select(1, path:gsub('velo/', '')), true);
				end);
				if not suc or res == '404: Not Found' then
						error(res);
				end;
				if path:find('.lua') then
						res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after velocity updates.\n'..res;
				end;
				writefile(path, res);
		end;
		return (func or readfile)(path);
end;

local function wipeFolder(path)
		if not isfolder(path) then return end
		for _, file in listfiles(path) do
				if file:find('loader') then continue end
				if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after velocity updates.')) == 1 then
						delfile(file);
				end;
		end;
end;

for _, folder: string in {'velo', 'velo/games', 'velo/profiles', 'velo/assets', 'velo/libraries', 'velo/guis', 'velo/sounds'} do
		if not isfolder(folder) then
				makefolder(folder);
		end;
end;

if not shared.VeloDeveloper then
		local _, subbed: string = pcall(function(): string
				return game:HttpGet('https://github.com/Copiums/Velocity');
		end);
		local commit: string? = subbed:find('currentOid');
		commit = commit and subbed:sub(commit + 13, commit + 52) or nil;
		commit = commit and #commit == 40 and commit or 'main';
		local firstInstall = not isfile('rust/profiles/commit.txt')
		if commit == 'main' or (isfile('velo/profiles/commit.txt') and readfile('velo/profiles/commit.txt') or '') ~= commit then
				wipeFolder('velo');
				wipeFolder('velo/games');
				wipeFolder('velo/guis');
				wipeFolder('velo/libraries');
		end;
		writefile('velo/profiles/commit.txt', commit);
		if firstInstall then
                local profiles = {
                        "default6872274481.txt",
						"2619619496.gui.txt",
                        "default6872265039.txt",
						"default125009265613167.txt",
						"default122816944483266.txt",
						"default108428559529058.txt",
						"default113555439745862.txt",
						"default99567941238278.txt",
                }
                for _, profile in next, profiles do
                        local path = 'velo/profiles/'..profile
                        downloadFile(path)
                end;
        end;
end;

return loadstring(downloadFile('velo/main.lua'), 'main')();

