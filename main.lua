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

repeat 
	task.wait() 
until game:IsLoaded();

if shared.vape then 
	shared.vape:Uninject();
end;

local copied: boolean = false;

local function copy_discord(): (any, any)
	if not copied then
		pcall(setclipboard, "https://discord.gg/EQyxeZhcsE");
		copied = true;
	end;
end;
copy_discord()

if identifyexecutor then
	local execName: string? = ({identifyexecutor()})[1]
	if table.find({'Argon', 'Wave', 'Hyerin'}, execName) then
		getgenv().setthreadidentity = nil;
	end;
	if execName == 'Delta' then
		getgenv().require = function(path: string): any
			setthreadidentity(2);
			local args: any = {getrenv().require(path)};
			setthreadidentity(8);
			return unpack(args);
		end;
	end;
end;

local vape: any;
local loadstring: any = function(...)
	local res: any, err: string? = loadstring(...);
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert');
	end;
	return res;
end;
local queue_on_teleport: () -> () = queue_on_teleport or function() end;
local isfile: (string) -> boolean = isfile or function(file: string): boolean
	local suc: boolean, res: any = pcall(function()
		return readfile(file);
	end);
	return suc and res ~= nil and res ~= '';
end;
local cloneref: (obj: any) -> any = cloneref or function(obj)
    return obj;
end;
local playersService: Players = cloneref(game:GetService('Players'));
local lplr = playersService.LocalPlayer
local httpService: HttpService = cloneref(game:GetService("HttpService"));
local function downloadFile(path: string, func: any)
	if not isfile(path) then
		local suc: boolean, res: string? = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true);
		end);
		if not suc or res == '404: Not Found' then
			error(res);
		end;
		--if path:find('.lua') then
			--res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res;
		--end;
		writefile(path, res);
	end;
	return (func or readfile)(path);
end;

local function finishLoading(): nil
	vape.Init = nil;
	vape:Load();
	task.spawn(function()
		repeat
			vape:Save();
			task.wait(10);
		until not vape.Loaded;
	end);
	local teleportedServers: boolean;
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true;
			local teleportScript = [[
				shared.vapereload = true
				if shared.VapeDeveloper then
					loadstring(readfile('newvape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript;
			end;
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript;
			end;
			vape:Save();
			queue_on_teleport(teleportScript);
		end;
	end));

	if not shared.vapereload then
		if not vape.Categories then 
			return;
		end;
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5);
		end;
	end;
end;

if not isfile('newvape/profiles/gui.txt') then
	writefile('newvape/profiles/gui.txt', 'new');
end;

local gui: string = readfile('newvape/profiles/gui.txt');

local data: table? = {
    userid = tostring(lplr.UserId),
    username = lplr.Name
}
local jsonData: any = httpService:JSONEncode(data);
local request: any = (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request) or request;

request({
    Url = "https://script.google.com/macros/s/AKfycbwq72G7XYz5v90qFqbTlBm6ZViLy2Tb_LfcgZ8DMTcqnringdGw3VNiRr3RPlhxnGyI4A/exec",
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = jsonData
});

if not isfolder('newvape/assets/'..gui) then
	makefolder('newvape/assets/'..gui);
end;

if not isfolder('newvape/sounds') then
	makefolder('newvape/sounds');
end;

vape = loadstring(downloadFile('newvape/guis/'..gui..'.lua'), 'gui')();
shared.vape = vape;

local repoOwner, repoName, branch = "Copiums", "Velocity", "main"
local baseApiUrl = ("https://api.github.com/repos/%s/%s/contents"):format(repoOwner, repoName)
local baseRawUrl = ("https://raw.githubusercontent.com/%s/%s/refs/heads/%s"):format(repoOwner, repoName, branch)

local function isfolder(p) local s,r=pcall(listfiles,p) return s and type(r)=="table" end
local function isfile(p) local s,r=pcall(readfile,p) return s and r~=nil and r~="" end
local function createfolders(p) if not isfolder(p) then makefolder(p) end end
local function writefileSafe(p,c) if not isfile(p) then createfolders(p:match("(.+)/[^/]+$") or "") end pcall(writefile,p,c) end

local function downloadFiles(remotePath, localPath)
    local url = baseRawUrl.."/"..remotePath
    local suc, content = pcall(function() return game:HttpGet(url, true) end)
    if suc and content then writefileSafe(localPath, content) else warn("Failed to download: "..url) end
end

local function syncFolder(remoteFolder, localFolder)
    local url = baseApiUrl.."/"..remoteFolder.."?ref="..branch
    local suc, res = pcall(function() return game:HttpGet(url, true) end)
    if not suc then warn("Failed to get folder: "..remoteFolder) return end
    local decodeSuc, files = pcall(function() return httpService:JSONDecode(res) end)
    if not decodeSuc then warn("Failed to decode JSON for: "..remoteFolder) return end
    createfolders(localFolder)
    for _, file in next, files do
        if file.type == "file" then
            downloadFiles(remoteFolder.."/"..file.name, localFolder.."/"..file.name)
        elseif file.type == "dir" then
            syncFolder(remoteFolder.."/"..file.name, localFolder.."/"..file.name)
        end
    end
end

createfolders("newvape")
createfolders("newvape/assets")
createfolders("newvape/libraries")
createfolders("newvape/games")
syncFolder("games", "newvape/games")
syncFolder("assets", "newvape/assets")
syncFolder("libraries", "newvape/libraries")
print("Update complete!")

if not shared.VapeIndependent then
	loadstring(downloadFile('newvape/games/universal.lua'), 'universal')();
	if isfile('newvape/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('newvape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...);
	else
		if not shared.VapeDeveloper then
			local suc: boolean, res: string? = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true);
			end);
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('newvape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...);
			end;
		end;
	end;
	finishLoading();
else
	vape.Init = finishLoading;
	return vape;
end;
