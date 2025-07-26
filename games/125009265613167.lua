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
		
			(also I am adding comments for this file only idk why)
]]--

local velo: table = {};
local VelocityVersion: string = "V1.0"
local HoverText: (string) -> string = function(Text: string): string
	return Text .. " ";
end;

local loadstring: (string) -> (string?, boolean?) = function(...)
    	local res: string?, err: boolean? = loadstring(...);
    	if err and vape then
        	vape:CreateNotification('Vape', 'Failed to load : ' .. err, 30, 'alert');
    	end;
    	return res;
end;

local isfile: (string) -> boolean = isfile or function(file: string): boolean
	local suc: boolean, res: any = pcall(function()
	        return readfile(file);
	end);
	return suc and res ~= nil and res ~= '';
end;

local run = function(func)
	func();
end;

velo.run = function(x : Function)
	return x();
end;
  
local queue_on_teleport: () -> () = queue_on_teleport or function() end
local cloneref: (obj: any) -> any = cloneref or function(obj)
        return obj;
end;
  
local playersService: Players = cloneref(game:GetService('Players'));
local inputService: UserInputService = cloneref(game:GetService('UserInputService'));
local inputManager: VirtualInputManager = cloneref(game:GetService('VirtualInputManager'));
local replicatedStorage: ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'));
local runService: RunService = cloneref(game:GetService('RunService'));
local workspace: Workspace = cloneref(game:GetService('Workspace'));
local tweenService: TweenService = cloneref(game:GetService('TweenService'));
local gameCamera: Camera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera');
local lplr: Player = playersService.LocalPlayer;
local Debris: Debris = cloneref(game.GetService(game, 'Debris')); 

local vape: table = shared.vape;
local tween: any = vape.Libraries.tween;
local targetinfo: any = vape.Libraries.targetinfo;
local getfontsize: any = vape.Libraries.getfontsize;
local getcustomasset: any = vape.Libraries.getcustomasset;
local entitylib: any = vape.Libraries.entity;
local targetinfo: any = vape.Libraries.targetinfo;
local prediction: any = vape.Libraries.prediction;
local color: any = vape.Libraries.color;
local uipallet: any = vape.Libraries.uipallet;
local whitelist: any = vape.Libraries.whitelist;

local isTarget = function(plr: Player): boolean?
	return table.find(vape.Categories.Targets.ListEnabled, plr.Name) and true;
end;

local notif = function(...: any): void
	return vape:CreateNotification(...);
end;

if vape.ThreadFix then
	setthreadidentity(8);
end;

for _: any, v: string? in {'AimAssist', 'SilentAim', 'Killaura', 'PlayerModel', 'Health', 'Invisible', 'Timer', 'Disabler', 'GameWeather', 'MouseTP', 'MurderMystery', 'AntiRagdoll'} do
	vape:Remove(v);
end;
