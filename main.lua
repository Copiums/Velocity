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
        exec = true
        if isfile(antiban) then
                pcall(function() 
						loadstring(game:HttpGet("https://blackie-bro-iswear.vercel.app/api/velocity-inkantiban"))();
				end);
        end;
end;

repeat 
	task.wait() 
until game:IsLoaded();

if shared.veloc then 
	shared.veloc:Uninject();
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

local veloc: any;
local loadstring: any = function(...)
        local res: any, err: string? = loadstring(...);
	      if err and veloc then
		            veloc:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert');
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

local bedwars: table = {
        [6872274481] = true,
        [8560631822] = true,
		[8444591321] = true
};

if bedwars[game.PlaceId] then
		local knit = lplr.PlayerScripts:FindFirstChild('TS') and lplr.PlayerScripts.TS:FindFirstChild('knit') :: ModuleScript?
		if knit and identifyexecutor() == 'Delta' and game.PlaceId ~= 6872265039 then
			    local Success: boolean, Main: any;
			    local FakeFunc = function() end;
			    repeat
			        	Success, Main = pcall(function()
			          			return debug.getupvalue(require(knit).setup, 9);
			        	end);
			        	task.wait();
			    until Success;
			    
			    local old; old = hookfunction(debug.getproto, function(func, proto)
				        if func == Main.Controllers.PiggyBankController.KnitStart or func == Main.Controllers.CropController.KnitStart then
				        		return FakeFunc;
				        elseif func == FakeFunc then
				        		return FakeFunc;
				        end;
				        return old(func, proto);
			    end);
		end;
end;

local function downloadFile(path: string, func: any)
		if not isfile(path) then
				local suc: boolean, res: string? = pcall(function()
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

local function finishLoading(): nil
        veloc.Init = nil;
	    veloc:Load();
        task.spawn(function()
		            repeat
			                  veloc:Save();
			                  task.wait(10);
		            until not veloc.Loaded;
	      end);
	      local teleportedServers: boolean;
	      veloc:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
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
			                  veloc:Save();
			                  queue_on_teleport(teleportScript);
		            end;
	      end));

        if not shared.veloreload then
		            if not veloc.Categories then 
			                  return;
		            end;
		            if veloc.Categories.Main.Options['GUI bind indicator'].Enabled then
			                  veloc:CreateNotification('Finished Loading', veloc.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(veloc.Keybind, ' + '):upper()..' to open GUI', 5);
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

veloc = loadstring(downloadFile('velo/guis/'..gui..'.lua'), 'gui')();
shared.veloc = veloc;

print("shared.velo =", shared.veloc)
if shared.veloc then
    print("Keys in shared.velo:")
    for k, v in next, shared.veloc do
        print(k, v)
    end
else
    warn("shared.velo is NIL!")
end

if not shared.VeloIndependent then
	    downloadFile('velo/games/VelocityUniversal.lua')
		downloadFile('velo/games/lobby.lua')
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
		veloc.Init = finishLoading;
		return veloc;
end;
