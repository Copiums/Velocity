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
local runService: RunService = cloneref(game:GetService('RunService'));
local replicatedStorage: ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'));
local inputService: UserInputService = cloneref(game:GetService('UserInputService'));

local lplr: Player = playersService.LocalPlayer;
local vape: any = shared.vape;
local entitylib: any = vape.Libraries.entity;
local sessioninfo: any = vape.Libraries.sessioninfo;
local whitelist: any = vape.Libraries.whitelist;
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
	local tags: string? = select(3, whitelist:get(lplr)) or whitelist.customtags[lplr.Name] or {}
	local tagData: table? = tags[1]
	if lplr.Character and lplr.Character:FindFirstChild("Head") then
		local displayNameGui: Nametag? = lplr.Character.Head:FindFirstChild("Nametag");
		if displayNameGui and displayNameGui.DisplayNameContainer and displayNameGui.DisplayNameContainer:FindFirstChild("DisplayName") then
			if tagData then
				local hexColor: any = string.format("%02X%02X%02X",
					math.floor(tagData.color.R * 255),
					math.floor(tagData.color.G * 255),
					math.floor(tagData.color.B * 255))

				local tagText: string? = string.format('<font color="#%s">[%s] </font>', hexColor, tagData.text);
				displayNameGui.DisplayNameContainer.DisplayName.Text = tagText .. lplr.DisplayName;
			else
				displayNameGui.DisplayNameContainer.DisplayName.Text = lplr.DisplayName;
			end;
		end;
	end;
end);

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
	
velo.run(function()
	local HotbarVisuals: table = {}
	local HotbarRounding: table  = {}
	local HotbarHighlight: table  = {}
	local HotbarColorToggle: table  = {}
	local HotbarHideSlotIcons: table  = {}
	local HotbarSlotNumberColorToggle: table  = {}
	local HotbarSpacing: table  = {Value = 0}
	local HotbarInvisibility: table  = {Value = 4}
	local HotbarRoundRadius: table  = {Value = 8}
	local HotbarColor: table  = {}
	local HotbarHighlightColor: table  = {}
	local HotbarSlotNumberColor: table  = {}
	local hotbarcoloricons: table  = {}
	local hotbarsloticons: table  = {}
	local hotbarobjects: table  = {}
	local hotbarslotgradients: table  = {}
	local inventoryiconobj: any = nil

	local function hotbarFunction(): (any, any)
		local icons: any = ({pcall(function() return lplr.PlayerGui.hotbar["1"].ItemsHotbar end)})[2];
		if not (icons and typeof(icons) == "Instance") then return end;

		inventoryiconobj = icons;
		pcall(function()
			local layout: UIListLayout? = icons:FindFirstChildOfClass("UIListLayout");
			if layout then layout.Padding = UDim.new(0, HotbarSpacing.Value); end
		end);

		for _, v: Instance in pairs(icons:GetChildren()) do
			local sloticon: TextLabel? = ({pcall(function() return v:FindFirstChildWhichIsA("ImageButton"):FindFirstChildWhichIsA("TextLabel") end)})[2];
			if typeof(sloticon) ~= "Instance" then continue end;

			local parent: GuiObject = sloticon.Parent;
			table.insert(hotbarcoloricons, parent);
			sloticon.Parent.Transparency = 0.1 * HotbarInvisibility.Value;

			if HotbarColorToggle.Enabled and not HotbarVisualsGradient.Enabled then
				parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value);
			elseif HotbarVisualsGradient.Enabled and not parent:FindFirstChildWhichIsA("UIGradient") then
				parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				local g: UIGradient = Instance.new("UIGradient");
				g.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))
				});
				g.Parent = parent;
				table.insert(hotbarslotgradients, g);
			end;

			if HotbarRounding.Enabled then
				local r: UICorner = Instance.new("UICorner"); r.CornerRadius = UDim.new(0, HotbarRoundRadius.Value);
				r.Parent = parent; table.insert(hotbarobjects, r);
			end;

			if HotbarHighlight.Enabled then
				local hl: UIStroke = Instance.new("UIStroke");
				hl.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value);
				hl.Thickness = 1.3; hl.Parent = parent;
				table.insert(hotbarobjects, hl);
			end;

			if HotbarHideSlotIcons.Enabled then sloticon.Visible = false; end;
			table.insert(hotbarsloticons, sloticon);
		end;
	end;

	HotbarVisuals = vape.Categories.Render:CreateModule({
		["Name"] = 'HotbarVisuals',
		["HoverText"] = 'Add customization to your hotbar.',
		["Function"] = function(callback: boolean): void
			if callback then 
				task.spawn(function()
					table.insert(HotbarVisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == "hotbar" then hotbarFunction(); end
					end));
					hotbarFunction();
				end);
				table.insert(HotbarVisuals.Connections, runService.RenderStepped:Connect(function()
					for _, v in hotbarcoloricons do pcall(function() v.Transparency = 0.1 * HotbarInvisibility["Value"]; end); end
				end));
			else
				for _: any, v: any in hotbarsloticons do pcall(function() v.Visible = true; end); end
				for _: any, v: any in hotbarcoloricons do pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46); end); end
				for _: any, v: any in hotbarobjects do pcall(function() v:Destroy(); end); end
				for _: any, v: any in hotbarslotgradients do pcall(function() v:Destroy(); end); end
				table.clear(hotbarobjects); table.clear(hotbarsloticons); table.clear(hotbarcoloricons);
			end;
		end;
	})
	local function forceRefresh()
		if HotbarVisuals["Enabled"] then HotbarVisuals.ToggleButton(false); HotbarVisuals.ToggleButton(false); end
	end;
	HotbarColorToggle = HotbarVisuals:CreateToggle({
		["Name"] = "Slot Color",
		["Function"] = function(callback: boolean): void pcall(function() HotbarColor.Object.Visible = callback; end); forceRefresh(); end
	});
	HotbarVisualsGradient = HotbarVisuals:CreateToggle({
		["Name"] = "Gradient Slot Color",
		["Function"] = function(callback: boolean): void
			pcall(function()
				HotbarVisualsGradientColor.Object.Visible = callback;
				HotbarVisualsGradientColor2.Object.Visible = callback;
			end);
			forceRefresh();
		end;
	});
	HotbarVisualsGradientColor = HotbarVisuals:CreateColorSlider({
		["Name"] = 'Gradient Color',
		["Function"] = function(h, s, v)
			for i: any, v: any in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end;
		end;
	})
	HotbarVisualsGradientColor2 = HotbarVisuals:CreateColorSlider({
		["Name"] = 'Gradient Color 2',
		["Function"] = function(h, s, v)
			for i: any,v: any in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end;
		end;
	})
	HotbarColor = HotbarVisuals:CreateColorSlider({
		["Name"] = 'Slot Color',
		["Function"] = function(h, s, v)
			for i: any,v: any in hotbarcoloricons do
				if HotbarColorToggle["Enabled"] then
					pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end) 
				end
			end
		end
	})
	HotbarRounding = HotbarVisuals:CreateToggle({
		["Name"] = 'Rounding',
		["Function"] = function(callback: boolean): void pcall(function() HotbarRoundRadius.Object.Visible = state; end); forceRefresh(); end
	})
	HotbarRoundRadius = HotbarVisuals:CreateSlider({
		["Name"] = 'Corner Radius',
		["Min"] = 1,
		["Max"] = 20,
		["Function"] = function(callback: boolean): void
			for i,v in hotbarobjects do 
				pcall(function() v.CornerRadius = UDim.new(0, callback) end)
			end
		end
	})
	HotbarHighlight = HotbarVisuals:CreateToggle({
		["Name"] = 'Outline Highlight',
		["Function"] = function(callback: boolean): void pcall(function() HotbarHighlightColor.Object.Visible = state; end); forceRefresh(); end
	})
	HotbarHighlightColor = HotbarVisuals:CreateColorSlider({
		["Name"] = 'Highlight Color',
		["Function"] = function(h, s, v)
			for i,v in hotbarobjects do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	})
	HotbarHideSlotIcons = HotbarVisuals:CreateToggle({
		["Name"] = "No Slot Numbers", ["Function"] = forceRefresh
	});
	HotbarInvisibility = HotbarVisuals:CreateSlider({
		["Name"] = 'Invisibility',
		["Min"] = 0,
		["Max"] = 10,
		["Default"] = 4,
		["Function"] = function(value)
			for i,v in hotbarcoloricons do 
				pcall(function() v.Transparency = (0.1 * value) end); 
			end
		end
	})
	HotbarSpacing = HotbarVisuals:CreateSlider({
		["Name"] = 'Spacing',
		["Min"] = 0,
		["Max"] = 5,
		["Function"] = function(value)
			if HotbarVisuals["Enabled"] then 
				pcall(function() inventoryiconobj:FindFirstChildOfClass('UIListLayout').Padding = UDim.new(0, value) end)
			end
		end
	})
	HotbarColor.Object.Visible = false
	HotbarRoundRadius.Object.Visible = false
	HotbarHighlightColor.Object.Visible = false
end);
