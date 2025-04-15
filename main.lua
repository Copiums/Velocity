--[[

    ____   ____     .__                .__  __          
    \   \ /   /____ |  |   ____   ____ |__|/  |_ ___.__.
     \   Y   // __ \|  |  /  _ \_/ ___\|  \   __<   |  |
      \     /\  ___/|  |_(  <_> )  \___|  ||  |  \___  |
       \___/  \___  >____/\____/ \___  >__||__|  / ____|
                  \/                 \/          \/      

       The #1 Roblox Bedwars Vape Config on the market.

        - luc - modules / organizer
		- null.wtf - modules 
		- copium - modules
		- sammz - modules
		- lr - modules
        - blanked - modules
        - gamesense - modules
        - sown - modules
        - relevant - executor
        - nick - first UI



       _  _                       _                 __ _  _       _                     _    _          
     _| |<_> ___ ___  ___  _ _  _| |    ___  ___   / /| |<_>._ _ | |__ _ _  ___  _ _  _| |_ <_> ___ ___ 
    / . || |<_-</ | '/ . \| '_>/ . | _ / . |/ . | / / | || || ' || / /| | |/ ._>| '_>  | |  | |<_-</ ._>
    \___||_|/__/\_|_.\___/|_|  \___|<_>\_. |\_. |/_/  |_||_||_|_||_\_\|__/ \___.|_|    |_|  |_|/__/\___.
                                       <___'<___'                                                       

]]--

repeat 
	task.wait() 
until game:IsLoaded();

if shared.vape then 
	shared.vape:Uninject();
end;

local copied: boolean = false;

local function copy_discord()
	if not copied then
		pcall(setclipboard, "https://discord.gg/vRwHydnW")
		copied = true;
	end;
end;

if identifyexecutor then
	if table.find({'Argon', 'Wave', 'Hyerin'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil;
	end;
	if ({identifyexecutor()})[1] == 'Delta' then
		getgenv().require = function(path)
			setthreadidentity(2);
			local args: any = {getrenv().require(path)};
			setthreadidentity(8);
			return unpack(args);
		end;
	end;
end;

local vape: any;
local loadstring = function(...)
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

local function downloadFile(path, func)
	if not isfile(path) then
		local suc: boolean, res: string? = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true);
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

local function finishLoading()
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

local gui: any = readfile('newvape/profiles/gui.txt');

if not isfolder('newvape/assets/'..gui) then
	makefolder('newvape/assets/'..gui);
end;

if not isfolder('newvape/sounds') then
	makefolder('newvape/sounds');
end;

vape = loadstring(downloadFile('newvape/guis/'..gui..'.lua'), 'gui')();
shared.vape = vape;

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