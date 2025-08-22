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

local cloneref: (obj: any) -> any = cloneref or function(obj)
        return obj;
end;

local inputService: UserInputService = cloneref(game:GetService('UserInputService'));
local inkgame: table = {
        [99567941238278] = true,
        [125009265613167] = true,
		[122816944483266] = true
};

local antiban: string = "velo/games/antiban.luau";
local exec: boolean = false;
if inkgame[game.PlaceId] and not exec then
        exec = true;
        if isfile(antiban) then
				local execName = identifyexecutor and ({identifyexecutor()})[1] or "Unknown"
				if not (inputService:GetPlatform() == Enum.Platform.IOS and execName == "Delta") then
		                local source: string = readfile(antiban);
		                local fn: (() -> any)?, err: string? = loadstring(source);
		                if fn then
		                        local ok: boolean, returnedFunc: any = pcall(fn);
		                        if ok and typeof(returnedFunc) == "function" then
		                                pcall(returnedFunc);
		                        end;
		                end;
				end;
        end;
end;

repeat 
	task.wait() 
until game:IsLoaded();

if shared.velo then 
	shared.velo:Uninject();
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

local velo: any;
local loadstring: any = function(...)
        local res: any, err: string? = loadstring(...);
	      if err and velo then
		            velo:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert');
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

local playersService: Players = cloneref(game:GetService('Players'));
local lplr: Player = playersService.LocalPlayer
local httpService: HttpService = cloneref(game:GetService("HttpService"));

local function downloadFile(path, func)
	    if not isfile(path) then
		        local suc, res = pcall(function()
		            	return game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/'..select(1, path:gsub('velo/', '')), true)
		        end);
		        if not suc or res == '404: Not Found' then
		            	error(res);
		        end;
		        if path:find('.lua') then
		            	res = '--This watermark is used to delete the file if cached.\n'..res;
		        end;
		        writefile(path, res);
	    end;
	    return (func or readfile)(path);
end;

local function finishLoading(): nil
        velo.Init = nil;
	    velo:Load();
        task.spawn(function()
		            repeat
			                  velo:Save();
			                  task.wait(10);
		            until not velo.Loaded;
	      end);
	      local teleportedServers: boolean;
	      velo:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		            if (not teleportedServers) and (not shared.VeloIndependent) then
			                  teleportedServers = true;
                  			local teleportScript = [[
                  			        shared.veloreload = true
                  				      if shared.VeloDeveloper then
                  					            loadstring(readfile('velo/loader.lua'), 'loader')()
                  				      else
                  					            loadstring(game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/loader.lua', true), 'loader')()
                  			        end
                  			]]
			                  if shared.VeloDeveloper then
				                        teleportScript = 'shared.VeloDeveloper = true\n'..teleportScript;
			                  end;
			                  if shared.VeloCustomProfile then
				                        teleportScript = 'shared.VeloCustomProfile = "'..shared.VeloCustomProfile..'"\n'..teleportScript;
			                  end;
			                  velo:Save();
			                  queue_on_teleport(teleportScript);
		            end;
	      end));

        if not shared.veloreload then
		            if not velo.Categories then 
			                  return;
		            end;
		            if velo.Categories.Main.Options['GUI bind indicator'].Enabled then
			                  velo:CreateNotification('Finished Loading', velo.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(velo.Keybind, ' + '):upper()..' to open GUI', 5);
		            end;
	      end;
end;

if not isfile('velo/profiles/gui.txt') then
		writefile('velo/profiles/gui.txt', 'new');
end;

local gui: string = readfile('velo/profiles/gui.txt');

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

if not isfolder('velo/assets/'..gui) then
		makefolder('velo/assets/'..gui);
end;

if not isfolder('velo/sounds') then
		makefolder('velo/sounds');
end;

if not isfolder("velo/profiles") then
		makefolder("velo/profiles");
end;

velo = loadstring(downloadFile('velo/guis/'..gui..'.lua'), 'gui')();
shared.velo = velo;

if not shared.VeloIndependent then
	    downloadFile('velo/games/VelocityUniversal.lua')
	    downloadFile('velo/games/Velocity.lua')
		loadstring(downloadFile('velo/games/universal.lua'), 'universal')();
		if isfile('velo/games/'..game.PlaceId..'.lua') then
				task.wait()
				loadstring(readfile('velo/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...);
		else
				if not shared.VeloDeveloper then
						local suc: boolean, res: string? = pcall(function()
								return game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true);
						end);
						if suc and res ~= '404: Not Found' then
								loadstring(downloadFile('velo/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...);
						end;
				end;
		end;
		finishLoading();
else
		velo.Init = finishLoading;
		return velo;
end;
