--[[

		    ____   ____     .__                .__  __
		    \   \ /   /____ |  |   ____   ____ |__|/  |_ ___.__.
		     \   Y   // __ \|  |  /  _ \_/ ___\|  \   __<   |  |
		      \     /\  ___/|  |_(  <_> )  \___|  ||  |  \___  |
		       \___/  \___  >____/\____/ \___  >__||__|  / ____|
		                  \/                 \/          \/

		Custom modules template.

		The first time you join a game, Velocity saves this file as <PlaceId>custom.luau
		in your veloprivate (private and up) or veloplus (buyer) folder and runs it.
		Edit that copy; it runs every time you join that game, right before your profile
		loads, so your modules' settings save like any other module.
		Velocity never overwrites it. Delete it to get a fresh copy of this template.

		On Potassium, create or parent GUI objects in a module's Function or in a
		task.spawn loop, not inside RunService callbacks: Parent/Adornee writes there fail
		with "lacking capability Plugin".

]]

local vape: table = ... or shared.veloc;
local velo: table = {};
velo.run = function(callback: () -> ()): ()
	callback();
end;

local cloneref: (object: Instance) -> Instance = cloneref or function(object: Instance): Instance
	return object;
end;

-- services, please use those because they are safe. Prevents weak tables.
local playersService: Players = cloneref(game:GetService('Players'));
local runService: RunService = cloneref(game:GetService('RunService'));
local inputService: UserInputService = cloneref(game:GetService('UserInputService'));
local tweenService: TweenService = cloneref(game:GetService('TweenService'));
local textService: TextService = cloneref(game:GetService('TextService'));
local lightingService: Lighting = cloneref(game:GetService('Lighting'));
local replicatedStorage: ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'));
local lplr: Player = playersService.LocalPlayer;
local gameCamera: Camera = cloneref(workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera') or Instance.new('Camera'))

-- libs
local entitylib: table = vape.Libraries.entity;
local whitelist: table = vape.Libraries.whitelist;
local prediction: table = vape.Libraries.prediction;
local targetinfo: table? = vape.Libraries.targetinfo;
local getcustomasset: (path: string) -> string = vape.Libraries.getcustomasset or getcustomasset;

-- notification
local notif: (title: string, text: string, duration: number?, kind: string?) -> any = function(title: string, text: string, duration: number?, kind: string?): any
	return vape:CreateNotification(title, text, duration or 5, kind);
end;

local nearestEntity: (targets: table, range: number) -> table? = function(targets: table, range: number): table?
	return entitylib.EntityPosition({
		-- range, how far
		["Range"] = range,
		-- what part of entity it targets
		["Part"] = 'RootPart',
		-- player check
		["Players"] = targets.Players["Enabled"],
		-- NPC check
		["NPCs"] = targets.NPCs["Enabled"],
		-- wallcheck
		["Wallcheck"] = targets.Walls["Enabled"] or nil
	});
end;

local entitiesInRange: (targets: table, range: number, limit: number?) -> {table} = function(targets: table, range: number, limit: number?): {table}
	return entitylib.AllPosition({
		-- how far like killaura range
		["Range"] = range,
		-- what part of the player does it attack, you can switch to head.
		["Part"] = 'RootPart',
		-- how many entities does it search for
		["Limit"] = limit,
		-- Looks for players
		["Players"] = targets.Players["Enabled"],
		-- looks for NPCS
		["NPCs"] = targets.NPCs["Enabled"],
		-- wallcheck/player visibility best for legitting
		["Wallcheck"] = targets.Walls["Enabled"] or nil
	});
end;

-- nearest entity to mouse
local nearestToMouse: (targets: table, pixels: number) -> table? = function(targets: table, pixels: number): table?
	return entitylib.EntityMouse({
		-- distance away from player
		["Range"] = pixels,
		-- what part of the person, you can switch this to Head, ideally head.
		["Part"] = 'RootPart',
		-- targets Players
		["Players"] = targets.Players["Enabled"],
		-- targest NPCS
		["NPCs"] = targets.NPCs["Enabled"],
		-- wallcheck
		["Wallcheck"] = targets.Walls["Enabled"] or nil,
		-- is player visible
		["Origin"] = entitylib.isAlive and entitylib.character.RootPart.Position or nil
	});
end;

-- func header
velo.run(function(): ()
	-- enable toggle
	local ExampleCustom: table = {["Enabled"] = false};
	local Targets: table;
	local Range: table;
	local Notify: table;
	local lastTarget: table? = nil;

	-- module header, there is Combat, Velocity, Blatant, Render, Utility, Inventory to choose from
	ExampleCustom = vape.Categories.Utility:CreateModule({
		["Name"] = 'ExampleCustom',
		["Function"] = function(callback: boolean): ()
			lastTarget = nil;
			if not callback then
				return;
			end;
			-- please use clean when doing this it AUTO cleans up for you via clean api
			ExampleCustom:Clean(runService.Heartbeat:Connect(function(): ()
				if not entitylib.isAlive then
					return;
				end;
				local target: table? = nearestEntity(Targets, Range["Value"]);
				if target ~= lastTarget then
					lastTarget = target;
					if target and Notify["Enabled"] then
						notif('ExampleCustom', (target.Player and target.Player.Name or target.Character.Name)..' is within '..Range["Value"]..' studs', 3);
					end;
				end;
			end));
		end,
		["Tooltip"] = 'Example custom module: tells you when something enters range. Edit or delete it.'
	});
	Targets = ExampleCustom:CreateTargets({["Players"] = true});
	Range = ExampleCustom:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 1,
		["Max"] = 50,
		["Default"] = 18,
		["Suffix"] = function(value: number): string
			return value == 1 and 'stud' or 'studs';
		end
	});
	Notify = ExampleCustom:CreateToggle({
		["Name"] = 'Notify',
		["Default"] = true
	});
end);
