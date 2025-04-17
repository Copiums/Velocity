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


local velo: table = {};
local function HoverText(Text: string): void
	return Text .. " "
end
local run = function(func) func() end
velo.run = function(x : Function)
	return x();
end;
local cloneref: any = cloneref or function(obj) 
	return obj;
end;
local playersService: Players = cloneref(game:GetService('Players'));
local replicatedStorage: ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'));
local inputService: UserInputService = cloneref(game:GetService('UserInputService'));

local lplr: Player = playersService.LocalPlayer;
local vape: any = shared.vape;
local entitylib: any = vape.Libraries.entity;
local sessioninfo: any = vape.Libraries.sessioninfo;
local bedwars: table = {};

local function notif(...)
	return vape:CreateNotification(...);
end;

velo.run(function()
	local function dumpRemote(tab)
		local ind: any = table.find(tab, 'Client');
		return ind and tab[ind + 1] or '';
	end;

	local KnitInit: any, Knit: any;
	repeat
		KnitInit, Knit = pcall(function() return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6) end);
		if KnitInit then 
			break;
		end;
		task.wait();
	until KnitInit;
	if not debug.getupvalue(Knit.Start, 1) then
		repeat task.wait() until debug.getupvalue(Knit.Start, 1);
	end;
	local Flamework: any = require(replicatedStorage['rbxts_include']['node_modules']['@flamework'].core.out).Flamework
	local Client: any = require(replicatedStorage.TS.remotes).default.Client

	bedwars = setmetatable({
		Client = Client,
		CrateItemMeta = debug.getupvalue(Flamework.resolveDependency('client/controllers/global/reward-crate/crate-controller@CrateController').onStart, 3),
		Store = require(lplr.PlayerScripts.TS.ui.store).ClientStore
	}, {
		__index = function(self, ind)
			rawset(self, ind, Knit.Controllers[ind])
			return rawget(self, ind)
		end
	});

	local kills: any = sessioninfo:AddItem('Kills');
	local beds: any = sessioninfo:AddItem('Beds');
	local wins: any = sessioninfo:AddItem('Wins');
	local games: any = sessioninfo:AddItem('Games');

	vape:Clean(function()
		table.clear(bedwars);
	end);
end);

for _, v in vape.Modules do
	if v.Category == 'Combat' or v.Category == 'Minigames' then
		vape:Remove(i);
	end;
end;

velo.run(function()
	local Sprint: table = {["Enabled"] = false};
	local old: any;
	
	Sprint = vape.Categories.Combat:CreateModule({
		["Name"] = 'Sprint',
		["Function"] = function(callback: boolean): void
			if callback then
				if inputService.TouchEnabled then 
					pcall(function() 
						lplr.PlayerGui.MobileUI['2'].Visible = false;
					end); 
				end;
				old = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local call: any = old(...);
					bedwars.SprintController:startSprinting();
					return call;
				end;
				Sprint:Clean(entitylib.Events.LocalAdded:Connect(function() 
					bedwars.SprintController:stopSprinting();
				end));
				bedwars.SprintController:stopSprinting();
			else
				if inputService.TouchEnabled then 
					pcall(function() 
						lplr.PlayerGui.MobileUI['2'].Visible = true;
					end); 
				end;
				bedwars.SprintController.stopSprinting = old;
				bedwars.SprintController:stopSprinting();
			end;
		end,
		["Tooltip"] = 'Sets your sprinting to true.';
	});
end)
	
velo.run(function()
	local AutoGamble: table = {["Enabled"] = false};
	AutoGamble = vape.Categories.Minigames:CreateModule({
		["Name"] = 'AutoGamble',
		["Function"] = function(callback: boolean): void
			if callback then
				AutoGamble:Clean(bedwars.Client:GetNamespace('RewardCrate'):Get('CrateOpened'):Connect(function(data)
					if data.openingPlayer == lplr then
						local tab: any = bedwars.CrateItemMeta[data.reward.itemType] or {displayName = data.reward.itemType or 'unknown'};
						notif('AutoGamble', 'Won '..tab.displayName, 5);
					end;
				end));
	
				repeat
					if not bedwars.CrateAltarController.activeCrates[1] then
						for _: any, v: any in bedwars.Store:getState().Consumable.inventory do
							if v.consumable:find('crate') then
								bedwars.CrateAltarController:pickCrate(v.consumable, 1);
								task.wait(1.2);
								if bedwars.CrateAltarController.activeCrates[1] and bedwars.CrateAltarController.activeCrates[1][2] then
									bedwars.Client:GetNamespace('RewardCrate'):Get('OpenRewardCrate'):SendToServer({
										crateId = bedwars.CrateAltarController.activeCrates[1][2].attributes.crateId
									});
								end;
								break;
							end;
						end;
					end;
					task.wait(1);
				until not AutoGamble["Enabled"];
			end;
		end,
		["Tooltip"] = 'Automatically opens lucky crates, piston inspired!'
	})
end)
	
