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

local isfile: (string) -> boolean = isfile or function(file: string): booleanAdd commentMore actions
    local suc: boolean, res: string? = pcall(function(): string? return readfile(file) end);
    return suc and res ~= nil;
end;
local delfile: (string) -> () = delfile or function(file: string): () writefile(file, "") end;

local function downloadFile(path: string, func: ((string) -> any)?): string
	if not isfile(path) then
		local suc: boolean, res: string? = pcall(function(): string
			return game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true);
		end);
		if not suc or res == '404: Not Found' then
			error(res);
		end;
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res;
		end;
		writefile(path, res);
	end;
	return (func or readfile)(path);
end;

local function wipeFolder(path: string)
	if not isfolder(path) then 
        	return; 
    	end;
	for _, file: string in listfiles(path) do
		if file:find('loader') then 
           		 continue;
        	end;
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file);
		end;
	end;
end;

for _, folder: string in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis', 'newvape/sounds'} do
	if not isfolder(folder) then
		makefolder(folder);
	end;
end;

if not shared.VapeDeveloper then
	local _, subbed: string = pcall(function(): string
		return game:HttpGet('https://github.com/Copiums/Velocity');
	end);
	local commit: string? = subbed:find('currentOid');
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil;
	commit = commit and #commit == 40 and commit or 'main';
	if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit thenAdd commentMore actions
		wipeFolder('newvape');
		wipeFolder('newvape/games');
		wipeFolder('newvape/guis');
		wipeFolder('newvape/libraries');
	end;
	writefile('newvape/profiles/commit.txt', commit);
end;

return loadstring(downloadFile('newvape/main.lua'), 'main')();

