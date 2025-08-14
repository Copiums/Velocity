--[[

		    ____   ____     .__                .__  __          
		    \   \ /   /____ |  |   ____   ____ |__|/  |_ ___.__.
		     \   Y   // __ \|  |  /  _ \_/ ___\|  \   __<   |  |
		      \     /\  ___/|  |_(  <_> )  \___|  ||  |  \___  |
		       \___/  \___  >____/\____/ \___  >__||__|  / ____|
		                  \/                 \/          \/      
		
		       The #1 Roblox Ink Game Script on the market.
		
		        - luc - founder / organizer
			- copium - modules / developer
			- rxma - Thank you bro
		
		
		
		       _  _                       _                 __ _  _       _                     _    _          
		     _| |<_> ___ ___  ___  _ _  _| |    ___  ___   / /| |<_>._ _ | |__ _ _  ___  _ _  _| |_ <_> ___ ___ 
		    / . || |<_-</ | '/ . \| '_>/ . | _ / . |/ . | / / | || || ' || / /| | |/ ._>| '_>  | |  | |<_-</ ._>
		    \___||_|/__/\_|_.\___/|_|  \___|<_>\_. |\_. |/_/  |_||_||_|_||_\_\|__/ \___.|_|    |_|  |_|/__/\___.
		                                       <___'<___'                                                       
		
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

for _: any, v: string? in {'ScriptHub', 'ChatBypass', 'Invisible', 'Timer', 'MurderMystery'} do
      vape:Remove(v);
end;

velo.run(function()
        local TeleportGame: table = {["Enabled"] = false}
        local originalCFrame: CFrame? = nil
        TeleportGame = vape.Categories.Blatant:CreateModule({
                ["Name"] = 'TeleportGame',
                ["HoverText"] = 'Teleports you to join game',
                ["Function"] = function(callback: boolean): void
                        if callback then
                                vape:CreateNotification('Velocity', 'Starting new game!', 30, 'warning');
                                if lplr then
                                        if lplr.Character and lplr.Character:FindFirstChild('HumanoidRootPart') then
                                                local hrp: Part = lplr.Character.HumanoidRootPart;
                                                originalCFrame = hrp.CFrame;
                                                hrp.CFrame = CFrame.new(194.3988, 54.4803, 0.5044);
                                        end;
                                end;
                        else
                                vape:CreateNotification('Velocity', 'Teleport Game Disabled', 30, 'alert')
                                if lplr and originalCFrame then
                                        if lplr.Character and lplr.Character:FindFirstChild('HumanoidRootPart') then
                                                local hrp: Part = lplr.Character.HumanoidRootPart;
                                                hrp.CFrame = originalCFrame;
                                        end;
                                        originalCFrame = nil;
                                end;
                        end;
                end,
                ["Default"] = false,
                ["ToolTip"] = 'Automatically makes you join game',
        })
end)

velo.run(function()
        local JoinQueue: table = {["Enabled"] = false}
        JoinQueue = vape.Categories.Velocity:CreateModule({
                ["Name"] = 'JoinQueue',
                ["HoverText"] = 'Automatically makes you join game',
                ["Function"] = function(callback: boolean): void
                        if callback then
                              	local Remotes: any = replicatedStorage:WaitForChild("Remotes")
                								local ClickedButton: any = Remotes:WaitForChild("ClickedButton")
                								ClickedButton:FireServer({ joining = true }) 
                        end;
                end,
                ["Default"] = false,
                ["ToolTip"] = 'Joins the game queue',
        })
end)

velo.run(function()
        local LeaveQueue: table = {["Enabled"] = false}
        LeaveQueue = vape.Categories.Velocity:CreateModule({
                ["Name"] = 'LeaveQueue',
                ["HoverText"] = 'Automatically makes you leave game',
                ["Function"] = function(callback: boolean): void
                        if callback then
                              	local Remotes: any = replicatedStorage:WaitForChild("Remotes")
								local ClickedButton: any = Remotes:WaitForChild("ClickedButton")
								ClickedButton:FireServer({ buttonname = "leave" })
                        end;
                end,
                ["Default"] = false,
                ["ToolTip"] = 'Leaves the game queue',
        })
end)
