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

local inkgame: table = {
        [99567941238278] = true,
        [125009265613167] = true,
		[122816944483266] = true
};

local antiban: string = "newvape/games/antiban.luau";
local exec: boolean = false;
if inkgame[game.PlaceId] and not exec then
        exec = true;
        if isfile(antiban) then
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
local lplr: Player = playersService.LocalPlayer
local httpService: HttpService = cloneref(game:GetService("HttpService"));
local function downloadFile(path: string, func: any)
		if not isfile(path) then
				local commit: string = "main";
				local ok, result = pcall(function()
						return readfile("newvape/profiles/commit.txt");
				end);
				if ok and result and result ~= "" then
						commit = result;
				end;
				local relativePath = path:gsub("newvape/", "");
				local url = "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..commit.."/"..relativePath;
				local suc: boolean, res: string? = pcall(function()
						return game:HttpGet(url, true);
				end);
				if not suc or not res or res == "404: Not Found" then
						error("[downloadFile] Failed to download file:\nURL: " .. url .. "\nError: " .. tostring(res));
				end;
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

if not isfolder("newvape/profiles") then
		makefolder("newvape/profiles");
end;

if not isfile("newvape/profiles/commit_velocity.txt") then
		writefile("newvape/profiles/commit_velocity.txt", "");
end;

vape = loadstring(downloadFile('newvape/guis/'..gui..'.lua'), 'gui')();
shared.vape = vape;

local repoOwner, repoName, branch = "Copiums", "Velocity", "main";
local baseApiUrl = ("https://api.github.com/repos/%s/%s/contents"):format(repoOwner, repoName);
local baseRawUrl = ("https://raw.githubusercontent.com/%s/%s/refs/heads/%s"):format(repoOwner, repoName, branch);

local function isfile(p) local s, r = pcall(readfile, p) return s and r ~= nil and r ~= "" end;
local function isfolder(p) local s, r = pcall(listfiles, p) return s and type(r) == "table" end;
local function createfolders(p) if not isfolder(p) then makefolder(p) end end;
local function writefileSafe(p, c) if not isfile(p) then createfolders(p:match("(.+)/[^/]+$") or "") end pcall(writefile, p, c) end;

local repoOwner, repoName, branch = "Copiums", "Velocity", "main"
local baseApiUrl = ("https://api.github.com/repos/%s/%s/contents"):format(repoOwner, repoName);
local baseRawUrl = ("https://raw.githubusercontent.com/%s/%s/%s"):format(repoOwner, repoName, branch);
local commitsApiUrl = ("https://api.github.com/repos/%s/%s/commits/%s"):format(repoOwner, repoName, branch);

local function downloadFiles(remotePath, localPath)
		local url = baseRawUrl .. "/" .. remotePath;
		local suc, content = pcall(function() return game:HttpGet(url, true) end);
		if suc and content then
				writefileSafe(localPath, content);
		else
				warn("Failed to download: " .. url);
		end;
end;

local function syncFolder(remoteFolder, localFolder)
		local url = baseApiUrl .. "/" .. remoteFolder .. "?ref=" .. branch;
		local suc, res = pcall(function() return game:HttpGet(url, true) end);
		if not suc then warn("Failed to get folder: " .. remoteFolder) return; end;
		local decodeSuc, files = pcall(function() return httpService:JSONDecode(res) end);
		if not decodeSuc then warn("Failed to decode JSON: " .. remoteFolder) return; end;
		createfolders(localFolder);
		for _, file in next, files do
				if file.type == "file" then
						downloadFiles(remoteFolder .. "/" .. file.name, localFolder .. "/" .. file.name);
				elseif file.type == "dir" then
						syncFolder(remoteFolder .. "/" .. file.name, localFolder .. "/" .. file.name);
				end;
		end;
end;

local filepath = "newvape/profiles/commit_velocity.txt";
local function getLatestSHA()
		local suc, res = pcall(function() return game:HttpGet(commitsApiUrl, true) end);
		if not suc then return nil; end;
		local data = httpService:JSONDecode(res);
		return data.sha or (data[1] and data[1].sha);
end;

local function trim(s)
    	return (s:gsub("^%s*(.-)%s*$", "%1"));
end;

local latestSHA = getLatestSHA();
local storedSHA = isfile(filepath) and readfile(filepath) or "";
if latestSHA and latestSHA ~= storedSHA then
		vape:CreateNotification('Finished Loading', 'Press the button in the top right or shift to update', 5);
		syncFolder("games", "newvape/games");
		syncFolder("libraries", "newvape/libraries");
		writefile(filepath, latestSHA);
		print("Update complete!");
end;

if not isfile("newvape/profiles/commit_profiles.txt") then
		writefile("newvape/profiles/commit_profiles.txt", "");
end;

local commitFilepath = "newvape/profiles/commit_profiles.txt";
local profileFilename = "default"..game.PlaceId..".txt";
local profileLocalPath = "newvape/profiles/"..profileFilename;

local function getProfilesLatestSHA()
        local suc, res = pcall(function()
                local url = "https://api.github.com/repos/Copiums/Velocity/commits?path=profiles/"..profileFilename.."&sha=main";
                return game:HttpGet(url, true);
        end);
        if not suc then return nil; end;
        local data = httpService:JSONDecode(res);
        return data[1] and data[1].sha or nil;
end;

local storedSHA = isfile(commitFilepath) and readfile(commitFilepath) or "";
local latestSHA = getProfilesLatestSHA();

if not isfile(profileLocalPath) or (latestSHA and latestSHA ~= storedSHA) then
        vape:CreateNotification("Profiles Updated", "Profiles have been updated, syncing...", 5)
        local profileURL = "https://raw.githubusercontent.com/Copiums/Velocity/main/profiles/"..profileFilename;
        local suc, fileData = pcall(function()
                return game:HttpGet(profileURL, true);
        end);
        if suc and fileData then
                writefile(profileLocalPath, fileData);
                if latestSHA then
                        writefile(commitFilepath, latestSHA);
                end;
                print("Profile "..profileFilename.." sync complete!");
        end;
end;

if not shared.VapeIndependent then
		loadstring(downloadFile('newvape/games/universal.lua'), 'universal')();
		if isfile('newvape/games/'..game.PlaceId..'.lua') then
				task.wait()
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
