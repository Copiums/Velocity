--This watermark is used to delete the file if its cached, remove it to make the file persist after velocity updates.
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
		- xzxkw - modules
		- lr - modules
        - blanked - modules
        - gamesense - modules
        - sown - modules
        - relevant - modules
        - nick - first UI



       _  _                       _                 __ _  _       _                     _    _          
     _| |<_> ___ ___  ___  _ _  _| |    ___  ___   / /| |<_>._ _ | |__ _ _  ___  _ _  _| |_ <_> ___ ___ 
    / . || |<_-</ | '/ . \| '_>/ . | _ / . |/ . | / / | || || ' || / /| | |/ ._>| '_>  | |  | |<_-</ ._>
    \___||_|/__/\_|_.\___/|_|  \___|<_>\_. |\_. |/_/  |_||_||_|_||_\_\|__/ \___.|_|    |_|  |_|/__/\___.
                                       <___'<___'                                                       

]]--

local vape: any = shared.veloc;
local velo: table = {};
local loadTime: tick = tick();
local velocityVersion: string = "V1.0";
local hoverText: (Text: string) -> void = function(text: string): void
	return text .. " ";
end;

local loadstring: any = function(...: any)
	local res: string?, err: any = loadstring(...);
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert');
	end;
	return res;
end;

local isfile: (string) -> boolean = isfile or function(file: string): boolean
	local suc: boolean, res: any = pcall(function()
		return readfile(file);
	end);
	return suc and res ~= nil and res ~= '';
end;

local downloadFile: (path: string, func: any) -> ...any = function(path: string, func: any): ...any
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

local run: (func: Function?) -> () = function(func : Function?): ()
		func();
end;

velo.run = function(x : Function)
		return x();
end;

local queue_on_teleport: () -> () = queue_on_teleport or function() end;
local cloneref: (obj: any) -> any = cloneref or function(obj: any)
    return obj;
end;
local playersService: Players = cloneref(game:GetService('Players'));
local replicatedStorage: ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'));
local runService: RunService = cloneref(game:GetService('RunService'));
local inputService: UserInputService = cloneref(game:GetService('UserInputService'));
local tweenService: TweenService = cloneref(game:GetService('TweenService'));
local lightingService: Lighting = cloneref(game:GetService('Lighting'));
local marketplaceService: MarketplaceService = cloneref(game:GetService('MarketplaceService'));
local teleportService: TeleportService = cloneref(game:GetService('TeleportService'));
local httpService: HttpService = cloneref(game:GetService('HttpService'));
local guiService: GuiService = cloneref(game:GetService('GuiService'));
local groupService: GroupService = cloneref(game:GetService('GroupService'));
local textChatService: TextChatService = cloneref(game:GetService('TextChatService'));
local contextService: ContextActionService = cloneref(game:GetService('ContextActionService'));
local debris: Debris = cloneref(game:GetService('Debris')); 
local proximitypromptService: ProximityPromptService = cloneref(game:GetService('ProximityPromptService'));
local coreGui: CoreGui = cloneref(game:GetService('CoreGui'));
local gameCamera: Camera = cloneref(workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera') or Instance.new('Camera'));
local lplr: Player = playersService.LocalPlayer;
local vapeConnections: any = {};
local vapeInjected: boolean = true;
local vapeStore: any = {["Bindable"] = {}, ["raycast"] = RaycastParams.new(), ["MessageReceived"] = Instance.new('BindableEvent'), ["platform"] = inputService:GetPlatform()};
getgenv().vapeStore = vapeStore;

local assetfunction: any = getcustomasset;
local tween: any = vape.Libraries.tween;
local targetinfo: any = vape.Libraries.targetinfo;
local getfontsize: any = vape.Libraries.getfontsize;
local getfontbounds: any = vape.Libraries.getfontbounds;
local getcustomasset: any = vape.Libraries.getcustomasset;	

local targetStrafeVector: any, spiderShift: any, waypointFolder: any;
local Spider: table = {["Enabled"] = false};
local Phase: tbale = {["Enabled"] = false};

local addBlur: (parent: any) -> any = function(parent: any): any
	local blur: ImageLabel = Instance.new('ImageLabel');
	blur.Name = 'Blur';
	blur.Size = UDim2.new(1, 89, 1, 52);
	blur.Position = UDim2.fromOffset(-48, -31);
	blur.BackgroundTransparency = 1;
	blur.Image = getcustomasset('velo/assets/new/blur.png');
	blur.ScaleType = Enum.ScaleType.Slice;
	blur.SliceCenter = Rect.new(52, 31, 261, 502);
	blur.Parent = parent;
	return blur;
end;

local getItems: (item: string) -> table = function(item: string): table
	local items: table = {};
	for _, v: any in next, Enum[item]:GetEnumItems() do 
		table.insert(items, v["Name"]);
	end;
	return items;
end;

local calculateMoveVector: (vec: Vector3) -> Vector3 = function(vec: Vector3): Vector3
	local c: number, s: number;
	local _, _, _, r00: any, r01: any, r02: any, _, _, r12: any, _, _, r22: any = gameCamera.CFrame:GetComponents();
	if r12 < 1 and r12 > -1 then
		c = r22;
		s = r02;
	else
		c = r00;
		s = -r01 * math.sign(r12);
	end;
	vec = Vector3.new((c * vec.X + s * vec.Z), 0, (c * vec.Z - s * vec.X)) / math.sqrt(c * c + s * s);
	return vec.Unit == vec.Unit and vec.Unit or Vector3.zero;
end;

local isFriend: (plr: Player, recolor: boolean) -> boolean? = function(plr: Player, recolor: boolean): boolean?
	if vape.Categories.Friends.Options['Use friends']["Enabled"] then
		local friend: any = table.find(vape.Categories.Friends.ListEnabled, plr.Name) and true;
		if recolor then
			friend = friend and vape.Categories.Friends.Options['Recolor visuals']["Enabled"];
		end;
		return friend;
	end;
	return nil;
end;

local isTarget: (plr: Player) -> boolean? = function(plr: Player): boolean?
	return table.find(vape.Categories.Targets.ListEnabled, plr.Name) and true;
end;

local canClick: () -> nil = function()
	local mousepos: any = (inputService:GetMouseLocation() - guiService:GetGuiInset());
	for _: any, v: any in lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y) do
		local obj: ScreenGui? = v:FindFirstAncestorOfClass('ScreenGui');
		if v.Active and v.Visible and obj and obj["Enabled"] then
			return false;
		end;
	end;
	for _: any, v: any in coreGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y) do
		local obj: ScreenGui? = v:FindFirstAncestorOfClass('ScreenGui');
		if v.Active and v.Visible and obj and obj["Enabled"] then
			return false;
		end;
	end;
	return (not vape.gui.ScaledGui.ClickGui.Visible) and (not inputService:GetFocusedTextBox());
end;

local getTableSize: (tab: {[any]: any}) -> number = function(tab: {[any]: any}): number
    local ind: number = 0;
    for _ in tab do
        ind += 1;
    end;
    return ind;
end;

local getTool: () -> (any, any) = function(): (any, any)
	return lplr.Character and lplr.Character:FindFirstChildWhichIsA('Tool', true) or nil;
end;

local notif: (...any) -> void = function(...: any): void
    return vape:CreateNotification(...);
end;


local removeTags: (str: string) -> string = function(str: string): string
	str = str:gsub('<br%s*/>', '\n');
	return (str:gsub('<[^<>]->', ''));
end;

local visited: table, attempted: table, tpSwitch: boolean = {}, {}, false;
local cacheExpire: number?, cache: any = tick();
local serverHop: (pointer: boolean?, filter: any) -> any;
serverHop = function(pointer: boolean?, filter: any): any
	visited = shared.vapeserverhoplist and shared.vapeserverhoplist:split('/') or {};
	if not table.find(visited, game.JobId) then
		table.insert(visited, game.JobId);
	end;
	if not pointer then
		notif('Vape', 'Searching for an available server.', 2);
	end;
	local suc: boolean?, httpdata: any = pcall(function()
		return cacheExpire < tick() and game:HttpGet('https://games.roblox.com/v1/games/'..game.PlaceId..'/servers/Public?sortOrder='..(filter == 'Ascending' and 1 or 2)..'&excludeFullGames=true&limit=100'..(pointer and '&cursor='..pointer or '')) or cache;
	end);
	local data: any = suc and httpService:JSONDecode(httpdata) or nil;
	if data and data.data then
		for _, v: any in data.data do
			if tonumber(v.playing) < playersService.MaxPlayers and not table.find(visited, v.id) and not table.find(attempted, v.id) then
				cacheExpire, cache = tick() + 60, httpdata;
				table.insert(attempted, v.id);
				notif('Vape', 'Found! Teleporting.', 5);
				teleportService:TeleportToPlaceInstance(game.PlaceId, v.id);
				return;
			end;
		end;
		if data.nextPageCursor then
			serverHop(data.nextPageCursor, filter);
		else
			notif('Vape', 'Failed to find an available server.', 5, 'warning');
		end;
	else
		notif('Vape', 'Failed to grab servers. ('..(data and data.errors[1].message or 'no data')..')', 5, 'warning');
	end;
end;

vape:Clean(lplr.OnTeleport:Connect(function()
	if not tpSwitch then
		tpSwitch = true;
		queue_on_teleport("shared.vapeserverhoplist = '"..table.concat(visited, '/').."'\nshared.vapeserverhopprevious = '"..game.JobId.."'");
	end;
end));

local frictionTable: table, oldfrict: table, entitylib: any = {}, {};
local updateVelocity: () -> (any, any) = function(): (any, any)
	if getTableSize(frictionTable) > 0 then
		if entitylib.isAlive then
			for _, v: any in entitylib.character.Character:GetChildren() do
				if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' and not oldfrict[v] then
					oldfrict[v] = v.CustomPhysicalProperties or 'none';
					v.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.2, 0.5, 1, 1);
				end;
			end;
		end;
	else
		for i: any, v: any in oldfrict do
			i.CustomPhysicalProperties = v ~= 'none' and v or nil;
		end;
		table.clear(oldfrict);
	end;
end;

local hash: any = loadstring(downloadFile('velo/libraries/hash.lua'), 'hash')();
local prediction: any = loadstring(downloadFile('velo/libraries/prediction.lua'), 'prediction')();
entitylib = loadstring(downloadFile('velo/libraries/entity.lua'), 'entitylib')();
local whitelist: table = {
	["alreadychecked"] = {},
	["customtags"] = {},
	["tagcallback"] = {},
	["data"] = {["WhitelistedUsers"] = {}},
	["hashes"] = setmetatable({}, {
		["__index"] = function(_, data: any)
			return hash and hash.sha512(data..'SelfReport') or '';
		end
	}),
	["hooked"] = false,
	["loaded"] = false,
	["localprio"] = 0,
	["said"] = {},
	["animWatchers"] = {}
};
vape.Libraries.entity = entitylib;
vape.Libraries.whitelist = whitelist;
vape.Libraries.prediction = prediction;
vape.Libraries.hash = hash;
vape.Libraries.auraanims = {
	["Random"] = {},
	['Horizontal Spin'] = {
		{["CFrame"] = CFrame.Angles(math.rad(-10), math.rad(-90), math.rad(-80)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.Angles(math.rad(-10), math.rad(180), math.rad(-80)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.Angles(math.rad(-10), math.rad(90), math.rad(-80)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.Angles(math.rad(-10), 0, math.rad(-80)), ["Time"] = 0.12}
	},
	["Normal"] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.05}
	},
	["Slow"] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.15}
	},
	["New"] = {
		{["CFrame"] = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), ["Time"] = 0.12}
	},
	["Latest"] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), ["Time"] = 0.1}
	},
	['Vertical Spin'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), ["Time"] = 0.1}
	},
	['Exhibition'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2}
	},
	['Exhibition Old'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.15}
	},
	['Old Extend'] = {
		{["CFrame"] = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), ["Time"] = 0.01},
		{["CFrame"] = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), ["Time"] = 0.07},
		{["CFrame"] = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), ["Time"] = 0.07}
	},
	['Horizontal Spin'] = {
		{["CFrame"] = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-80)), ["Time"] = 0.14},
		{["CFrame"] = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(-100)), ["Time"] = 0.14},
		{["CFrame"] = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(180), math.rad(-100)), ["Time"] = 0.14},
		{["CFrame"] = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(270), math.rad(-80)), ["Time"] = 0.14}
	},
	['BlockHit'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), ["Time"] = 0.15}
	},
	["Moon"] = {
		{["CFrame"] = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), ["Time"] = 0.48},
		{["CFrame"] = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), ["Time"] = 0.33},
		{["CFrame"] = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), ["Time"] = 0.33}
	},
	['Rise'] = {
		{["CFrame"] = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), ["Time"] = 0.14},
		{["CFrame"] = CFrame.new(0.5, 0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), ["Time"] = 0.14}
	},
	['Jab'] = {
		{["CFrame"] = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.6, -0.6, 0.5) * CFrame.Angles(math.rad(-45), math.rad(50), math.rad(-105)), ["Time"] = 0.1}
	},
	['Exhibition2'] = {
		{["CFrame"] = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-80)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(1, 0, -0.3) * CFrame.Angles(math.rad(-80), math.rad(40), math.rad(-60)), ["Time"] = 0.16}
	},
	['Smooth'] = {
		{["CFrame"] = CFrame.new(1, 0, -0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), ["Time"] = 0.12}
	},
	['Butter'] = {
		{["CFrame"] = CFrame.new(3.0, -1.7, -1.1) * CFrame.Angles(math.rad(307), math.rad(57), math.rad(145)), ["Time"] = 0.18},
		{["CFrame"] = CFrame.new(3.0, -1.7, -1.3) * CFrame.Angles(math.rad(203), math.rad(57), math.rad(226)), ["Time"] = 0.14}
	},
	['Slash'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.01},
		{["CFrame"] = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), ["Time"] = 0.19}
	},
	['Slide'] = {
		{["CFrame"] = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.2, -1, -10) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), ["Time"] = 0.0},
		{["CFrame"] = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), ["Time"] = 0.3}
	},
	['Swong'] = {
		{["CFrame"] = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), ["Time"] = 0.2}
	},
	['Kill X'] = {
		{["CFrame"] = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(140), math.rad(53)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(45), math.rad(53)), ["Time"] = 0.12}
	},
	['Stab'] = {
		{["CFrame"] = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), ["Time"] = 0.1, ["Size"] = 2},
		{["CFrame"] = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(90), math.rad(-81)), ["Time"] = 0.1, ["Size"] = 5}
	},
	['Exhibition vertical spin'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), ["Time"] = 0.1}
	},
	['LiquidBounce'] = {
		{["CFrame"] = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), ["Time"] = 0.17}
	},
	['OddSwing'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.03, 0.07, -0.07) * CFrame.Angles(math.rad(-20), math.rad(-2), math.rad(-8)), ["Time"] = 0.15}
	},
	['Sigma'] = {
		{["CFrame"] = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), ["Time"] = 0.18},
		{["CFrame"] = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), ["Time"] = 0.18},
		{["CFrame"] = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), ["Time"] = 0.18}
	},
	['SigmaJello'] = {
		{["CFrame"] = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), ["Time"] = 0.18},
		{["CFrame"] = CFrame.new(0, -0.2, -1.7) * CFrame.Angles(math.rad(30), math.rad(111), math.rad(190)), ["Time"] = 0.18}
	},
	['Drop'] = {
		{["CFrame"] = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), ["Time"] = 0.19}
	},
	['Cookless'] = {
		{["CFrame"] = CFrame.new(2, -2.5, 0.2) * CFrame.Angles(math.rad(268), math.rad(54), math.rad(327)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(1.6, -2.5, 0.2) * CFrame.Angles(math.rad(189), math.rad(52), math.rad(347)), ["Time"] = 0.16}
	},
	['Roll'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(100)), ["Time"] = 0.2}
	},
	['Shrink'] = {
		{["CFrame"] = CFrame.new(0.3, 0, 0) * CFrame.Angles(math.rad(-2), math.rad(5), math.rad(25)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6), ["Time"] = 0.2}
	},
	['Push'] = {
		{["CFrame"] = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), ["Time"] = 0.35}
	},
	['Flat'] = {
		{["CFrame"] = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(-30), math.rad(-80)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(30), math.rad(-100)), ["Time"] = 0.15}
	},
	['Dortware'] = {
		{["CFrame"] = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), ["Time"] = 0.6},
		{["CFrame"] = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), ["Time"] = 0.6},
		{["CFrame"] = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), ["Time"] = 0.8},
		{["CFrame"] = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(80), math.rad(90)), ["Time"] = 1.2},
		{["CFrame"] = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), ["Time"] = 0.6},
		{["CFrame"] = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), ["Time"] = 0.6}
	},
	['Template'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.01},
		{["CFrame"] = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), ["Time"] = 0.19}
	},
	['Hamsterware'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(40), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-135)), ["Time"] = 0.1}
	},
	['CatV5'] = {
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), ["Time"] = 0.1}
	},
	['Astral2'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), ["Time"] = 0.15}
	},
	['Leaked'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(16), math.rad(59), math.rad(-90)), ["Time"] = 0.15}
	},
	['Slide3'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0},
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), ["Time"] = 0.16}
	},
	['Femboy'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), ["Time"] = 0},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), ["Time"] = 0.11}
	},
	['MontCostume'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.58) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.05}
	},
	['fdp slow'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.90},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.50}
	},
	['swong'] = {
		{["CFrame"] = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), ["Time"] = 0.1, ["RealDelay"] = 0.1},
		{["CFrame"] = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), ["Time"] = 0.2, ["RealDelay"] = 0.2}
	},
	['Blochit'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), ["Time"] = 0.15, ["RealDelay"] = 0.15},
		{["CFrame"] = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), ["Time"] = 0.15, ["RealDelay"] = 0.15}
	},
	['Future2'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.90},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.90},
	},
	['rise'] = {
		{["CFrame"] = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), ["Time"] = 0.14, ["RealDelay"] = 0.14},
		{["CFrame"] = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), ["Time"] = 0.14, ["RealDelay"] = 0.14}			
	},
	['mine (rel)'] = {
		{["CFrame"] = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), ["Time"] = 0.15}
		
	},
	['jab'] = {
		{["CFrame"] = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.6, -0.6, 0.5) * CFrame.Angles(math.rad(-45), math.rad(50), math.rad(-105)), ["Time"] = 0.1},					
	},
	['VAPE OLD'] = {
		{["CFrame"] = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), ["Time"] = 0.07, ["Size"] = 2},
		{["CFrame"] = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(90), math.rad(-81)), ["Time"] = 0.06, ["Size"] = 5},
	},
	['meelkware'] = {
		{["CFrame"] = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), ["Time"] = 0.02, ["Size"] = 2},
		{["CFrame"] = CFrame.new(0.69, -0.77 + 2, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), ["Time"] = 0.02, ["Size"] = 2},
		{["CFrame"] = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), ["Time"] = 0.02, ["Size"] = 2},
	},
	['pistonware blue'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(40), math.rad(55), math.rad(290)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(40), math.rad(70), math.rad(1)), ["Time"] = 0.15}
	},
	['idk'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(304)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(90), math.rad(304)), ["Time"] = 0.15}
	},
	['YourMom'] = {
		{["CFrame"] = CFrame.new(0.67, -0.68, 0.62) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-80)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.72, -0.72, 0.6) * CFrame.Angles(math.rad(-94), math.rad(70), math.rad(-28)), ["Time"] = 0.26}
	},
	['ZeroPrime'] = {
		{["CFrame"] = CFrame.new(0.7, -0.89, 0.6) * CFrame.Angles(math.rad(-45), math.rad(47), math.rad(-77)), ["Time"] = 0.14},
		{["CFrame"] = CFrame.new(0.67, -0.66, 0.59) * CFrame.Angles(math.rad(-76), math.rad(50), math.rad(-37)), ["Time"] = 0.26}
	},
	['DortVersion2'] = {
		{["CFrame"] = CFrame.new(0.72, -0.67, 0.68) * CFrame.Angles(math.rad(-35), math.rad(45), math.rad(-84)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.68, -0.74, 0.53) * CFrame.Angles(math.rad(-80), math.rad(50), math.rad(-35)), ["Time"] = 0.24}
	},
	['SlowSwordThrowAnim'] = {
		{["CFrame"] = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(270)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(3, 3, 3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(180)), ["Time"] = 0.1},
	   
	},
	['SwordThrowAnim'] = {
		{["CFrame"] = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(270)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(3, 3, 3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(180)), ["Time"] = 0.3},
	},
	  
	['FastSwordThrowAnim'] = {
		{["CFrame"] = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(270)), ["Time"] = 0.5},
		{["CFrame"] = CFrame.new(3, 3, 3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(180)), ["Time"] = 0.5},
	},
	['SlowAndFast'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.8},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.01}
	},
	['SkidWare'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(65), math.rad(-79)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(35), math.rad(-56)), ["Time"] = 0.2}
	},
	['Monsoon'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), ["Time"] = 0.07},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), ["Time"] = 0.13}
	},
	['N1san1StopFuckingAnnoyingMe'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), ["Time"] = 0.19}
	},
	['Spooky'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(54), math.rad(-56)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(38), math.rad(-23)), ["Time"] = 0.15}
	},
	['SkidWare New'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(98), math.rad(-354)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(65), math.rad(-68)), ["Time"] = 0.2}
	},
	['Kys'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(50), math.rad(50), math.rad(100)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(84), math.rad(50), math.rad(50)), ["Time"] = 0.3}
	},
	['Astral'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0},
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.900},
		{["CFrame"] = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), ["Time"] = 0.15}
	},
	['xarq0n1'] = {
		{["CFrame"] = CFrame.new(0, -3, 0) * CFrame.Angles(-math.rad(120), math.rad(530), -math.rad(220)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.9, 0, 1.5) * CFrame.Angles(math.rad(7), math.rad(30), math.rad(820)), ["Time"] = 0.2}
	},
	['xarq0n2'] = {
		{["CFrame"] = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(190)), ["Time"] = 0.8},
		{["CFrame"] = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(40), math.rad(1)), ["Time"] = 0.8}
	},
	['xarq0n3'] = {
		{["CFrame"] = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(195), math.rad(95), math.rad(130)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(300), math.rad(40), math.rad(1)), ["Time"] = 0.2}
	},
	['Swiss'] = {
		{["CFrame"] = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.15}
	},
	['SlowSwiss'] = {
		{["CFrame"] = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.25},
		{["CFrame"] = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.25}
	},
	['OldAstralAnim'] = {
		{["CFrame"] = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.1}
	},
	['SlowOldAstralAnim'] = {
		{["CFrame"] = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.4},
		{["CFrame"] = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.4}
	},
	['ZylaAnim'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), ["Time"] = 0.3}
	},
	['SliceAnim'] = {
		{["CFrame"] = CFrame.new(3, -4, 3) * CFrame.Angles(math.rad(90), math.rad(90), math.rad(90)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(-4, 3, -4) * CFrame.Angles(math.rad(111), math.rad(222), math.rad(333)), ["Time"] = 0.2}
	},
	['SlowSliceAnim'] = {
		{["CFrame"] = CFrame.new(3, -4, 3) * CFrame.Angles(math.rad(90), math.rad(90), math.rad(90)), ["Time"] = 0.4},
		{["CFrame"] = CFrame.new(-4, 3, -4) * CFrame.Angles(math.rad(111), math.rad(222), math.rad(333)), ["Time"] = 0.4}
	},
	['PistonWareBlock'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.00001} 
	},

	['1.8'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.16, -1.16, 1) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), ["Time"] = 0.12}
	},
	['Blocking'] = {
		{["CFrame"] = CFrame.new(-0.01, -3.51, -2.01) * CFrame.Angles(math.rad(-180), math.rad(85), math.rad(-180)), ["Time"] = 0}
	},
	['Swag2'] = {
		{["CFrame"] = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), ["Time"] = 0.13},
	},
	['Kawaii'] = {
		{["CFrame"] = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),["Time"] = 0},
		{["CFrame"] = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(-51), math.rad(48), math.rad(24)),["Time"] = 0.06},
		{["CFrame"] = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),["Time"] = 0.06}
	},
	['Swank'] = {
		{["CFrame"] = CFrame.new(-0.01, -.45, -0.7) * CFrame.Angles(math.rad(-0), math.rad(85), math.rad(0)),["Time"] = 0.1},
		{["CFrame"] = CFrame.new(-0.02, -.45, -0.7) * CFrame.Angles(math.rad(59), math.rad(19), math.rad(-37)),["Time"] = 0.09},
	},
	['Swank2'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.09},
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.09},
		{["CFrame"] = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), ["Time"] = 0.15}
	},
	['TenacityOld2'] = {
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), ["Time"] = 0.1}
	},
	['OldSwank3'] = {
		{["CFrame"] = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.4},
		{["CFrame"] = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.4}
	},
	['TenacityOld'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), ["Time"] = 0.3}
	},
	['AstolfoNew'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), ["Time"] = 0.3},
	},
	['Sigma2'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.05}
	},
	['Sigma3'] = {
		{["CFrame"] = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), ["Time"] = 0.18},
		{["CFrame"] = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), ["Time"] = 0.18},
		{["CFrame"] = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), ["Time"] = 0.18}
	},
	['Tap'] = {
		{["CFrame"] = CFrame.new(5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(10)), ["Time"] = 0.25},
		{["CFrame"] = CFrame.new(5, -1, -0.3) * CFrame.Angles(math.rad(-100), math.rad(-30), math.rad(10)), ["Time"] = 0.25}
	},
	['Swag'] = {
		{["CFrame"] = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(0)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(10), math.rad(70), math.rad(-90)), ["Time"] = 0.08},
	},
	['Suicide'] = {
		{["CFrame"] = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), ["Time"] = 0.05}
	},
	['Goofy2'] = {
		{["CFrame"] = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), ["Time"] = 0.10},
		{["CFrame"] = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), ["Time"] = 0.08}
	},
	['Rise2'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0},
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.900},
		{["CFrame"] = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), ["Time"] = 0.15}
	},
	['Rise4'] = {
		{["CFrame"] = CFrame.new(0.9,0,0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), ["Time"] = 0.14},
		{["CFrame"] = CFrame.new(0.5,-0.2,-0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), ["Time"] = 0.14}
	},
	['Rise3'] = {
		{["CFrame"] = CFrame.new(0.6, -1, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.6, -1.5, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), ["Time"] = 0.1}    
	},
	['Rise4'] = {
		{["CFrame"] = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), ["Time"] = 0.1}
	},
	['Swong2'] = {
		{["CFrame"] = CFrame.new(0,0,-.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0,-.3, -.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), ["Time"] = 0.2},
	},
	['Eternal'] = {
		{["CFrame"] = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), ["Time"] = 0.17}
	},
	['monkey'] = {
		{["CFrame"] = CFrame.new(0, -3, 0) * CFrame.Angles(-math.rad(120), math.rad(530), -math.rad(220)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.9, 0, 1.5) * CFrame.Angles(math.rad(7), math.rad(30), math.rad(820)), ["Time"] = 0.2}
	},
	['Throw'] = {
		{["CFrame"] = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(255), math.rad(122), math.rad(321)), ["Time"] = 0.5},
		{["CFrame"] = CFrame.new(1, 1, 1) * CFrame.Angles(math.rad(156), math.rad(54), math.rad(91)), ["Time"] = 0.5}
	},
	['Slide2'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0},
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), ["Time"] = 0.16}
	},
	['Ketamine2'] = {
		{["CFrame"] = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), ["Time"] = 0.07},
		{["CFrame"] = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), ["Time"] = 0.07},
		{["CFrame"] = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), ["Time"] = 0.07},
		{["CFrame"] = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), ["Time"] = 0.07},
	},
	['Astolfo2'] = {
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), ["Time"] = 0.1}
	},
	['Ketamine'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), ["Time"] = 0},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), ["Time"] = 0.11}
	},
	['Swiss2'] = {
		{["CFrame"] = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.25},
		{["CFrame"] = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.25}
	},
	['Old'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), ["Time"] = 0.3}
	},
	['Extension'] = {
		{["CFrame"] = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), ["Time"] = 0.07},
		{["CFrame"] = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), ["Time"] = 0.07},
	},
	['Astolfo'] = {
		{["CFrame"] = CFrame.new(5, -1, -1) * CFrame.Angles(math.rad(-40), math.rad(0), math.rad(0)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(5, -0.7, -1) * CFrame.Angles(math.rad(-120), math.rad(20), math.rad(-10)), ["Time"] = 0.05},
	},
	['German'] = {
		{["CFrame"] = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), ["Time"] = 0.10},
		{["CFrame"] = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), ["Time"] = 0.08}
	},
	['Penis'] = {
		{["CFrame"] = CFrame.new(-1.8, 0.5, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(-1.8, -0.21, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), ["Time"] = 0.05}
	},
	['KillMyself'] = {
		{["CFrame"] = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), ["Time"] = 0.05}
	},
	--scrxpted needs to do this ^^
	['SmootherExhibition'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.6},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.7},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.9},
		{["CFrame"] = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 1}
	},
	['PurpulV1'] = {
		{["CFrame"] = CFrame.new(0.33, -0.45, 0.3) * CFrame.Angles(math.rad(-23), math.rad(50), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.33, -0.7, 0.6) * CFrame.Angles(math.rad(-25), math.rad(50), math.rad(-90)), ["Time"] = 0.1}
	},
	['SuperSlowSlow'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.50},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.50}
	},
	-- cat v5
	['NewCatV5'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-70)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(1)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), ["Time"] = -0.2},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-22), math.rad(56), math.rad(-106)), ["Time"] = 0.1}
	},
	['blackwareFast'] = {
		{["CFrame"] = CFrame.new(1.49, -1, 0.12) * CFrame.Angles(math.rad(260), math.rad(55), math.rad(200)), ["Time"] = 0.30},
		{["CFrame"] = CFrame.new(0.37, -2, -0.4) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-20)), ["Time"] = 0.30}
	},
	['blackwareSlow'] = {
		{["CFrame"] = CFrame.new(1.5, -0.80, 0.14) * CFrame.Angles(math.rad(260), math.rad(50), math.rad(240)), ["Time"] = 0.40},
		{["CFrame"] = CFrame.new(0.5, -0.15, -0.6) * CFrame.Angles(math.rad(-40), math.rad(55), math.rad(-50)), ["Time"] = 0.40}
	},
	['blackMeteor'] = {
		{["CFrame"] = CFrame.new(0.80, -0.77, 0.9) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-90)), ["Time"] = 0.20},
		{["CFrame"] = CFrame.new(0.32, -0.81, 0.10) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), ["Time"] = 0.20}
	},
	['Blackware'] = {
		{["CFrame"] = CFrame.new(0.6, -0.7, 0.6) * CFrame.Angles(math.rad(-8), math.rad(40), math.rad(-60)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.49, -0.8, 0.3) * CFrame.Angles(math.rad(8), math.rad(40), math.rad(-10)), ["Time"] = 0.15}
	},
	['icespice'] = {
		{["CFrame"] = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(190)), ["Time"] = 0.8},
		{["CFrame"] = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(40), math.rad(1)), ["Time"] = 0.8}
	},
	['KEK'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), ["Time"] = 0.1}
	},
	['normalv2'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.09},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.09}
	},
	['sillydick'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), ["Time"] = 0.3}
	},
	['normalv3'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.06},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.05}
	},
	-- Prism
	['PRISMASTADAWN'] = {
		{["CFrame"] = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(190), math.rad(75), math.rad(90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(0.3, -2, .2) * CFrame.Angles(math.rad(190), math.rad(95), math.rad(80)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(120), math.rad(170), math.rad(90)), ["Time"] = 0.13},
	},
	['Custom+'] = {
		{["CFrame"] = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.03},
		{["CFrame"] = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.09},
		{["CFrame"] = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.13}
	},
	['FastslowBETTER'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.8},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.01}
	},	
	['cum'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), ["Time"] = 0.07},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), ["Time"] = 0.13}
	},
	['meteor4'] = {
		{["CFrame"] = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), ["Time"] = 0.35}
	},
	['meteor'] = {
		{["CFrame"] = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), ["Time"] = 0.17}
	},
	['meteor6'] = {
		{["CFrame"] = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), ["Time"] = 0.23},
	},
	['astrolfo'] = {
		{["CFrame"] = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), ["Time"] = 0.23},
		{["CFrame"] = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), ["Time"] = 0.19},
	},
	['idkthesenames'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), ["Time"] = 0.19}
	},
	['sexy'] = {
		{["CFrame"] = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(math.rad(190), math.rad(110), math.rad(90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), ["Time"] = 0.1}
	},
	-- meteor
	['meteor2'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), ["Time"] = 0.15}
	},
	['meteor7'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(10)), ["Time"] = 0.14},
	},
	['meteor8'] = {
		{["CFrame"] = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), ["Time"] = 0.14},
		{["CFrame"] = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), ["Time"] = 0.14},
	},
	['sexyfr'] = {
		{["CFrame"] = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), ["Time"] = 0.1}
	},
	['2cum'] = {
		{["CFrame"] = CFrame.new(0.7, -0.4, 0.612) * CFrame.Angles(math.rad(285), math.rad(65), math.rad(293)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(210), math.rad(70), math.rad(3)), ["Time"] = 0.13}
	},
	['fatbitch'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(45), math.rad(85)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(80), math.rad(60)), ["Time"] = 0.12},
	},
	['meteor3'] = {
		{["CFrame"] = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), ["Time"] = 0.13},
	},
	['random'] = {
		{["CFrame"] = CFrame.new(-0.06, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(97), math.rad(-92)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(-0.05, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-93)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(-0.03, -0.5, 0.4) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-91)), ["Time"] = 0.2}
	},
	['SlowAsstral'] = {
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.14},
		{["CFrame"] = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), ["Time"] = 0.26}
	},
	-- Moon
	['Karambit'] = {
		{["CFrame"] = CFrame.new(-0.01, 0, -1.51) * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0)), ["Time"] = 0},
		{["CFrame"] = CFrame.new(-0.01, -0.01, -1.51) * CFrame.Angles(math.rad(-155), math.rad(0), math.rad(-0)), ["Time"] = 0.03},
		{["CFrame"] = CFrame.new(-0.01, -0.01, -1.51) * CFrame.Angles(math.rad(120), math.rad(0), math.rad(0)), ["Time"] = 0.03},
		{["CFrame"] = CFrame.new(-0.01, -0.01, -1.51) * CFrame.Angles(math.rad(30), math.rad(-0), math.rad(0)), ["Time"] = 0.03},
		{["CFrame"] = CFrame.new(-0.01, 0, -1.51) * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0)), ["Time"] = 0.15}
	},
	['LiquidBounceV2'] = {
		{["CFrame"] = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), ["Time"] = 0.23}
	},
	['Tenacity'] = {
		{["CFrame"] = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), ["Time"] = 0.2}
	},
	['StabRemake'] = {
		{["CFrame"] = CFrame.new(2, -2.5, 0.2) * CFrame.Angles(math.rad(268), math.rad(54), math.rad(327)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(1.6, -2.5, 0.2) * CFrame.Angles(math.rad(189), math.rad(52), math.rad(347)), ["Time"] = 0.16}
	},
	['SlashRemake'] = {
		{["CFrame"] = CFrame.new(3.0, -1.7, -1.1) * CFrame.Angles(math.rad(307), math.rad(57), math.rad(145)), ["Time"] = 0.18},
		{["CFrame"] = CFrame.new(3.0, -1.7, -1.3) * CFrame.Angles(math.rad(203), math.rad(57), math.rad(226)), ["Time"] = 0.14}
	},
	['ExhiRemake'] = {
		{["CFrame"] = CFrame.new(1, 0, -0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), ["Time"] = 0.12}
	},
	['PushRemake'] = {
		{["CFrame"] = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), ["Time"] = 0.35}
	},
	['SwongRemake'] = {
		{["CFrame"] = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), ["Time"] = 0.2}
	},
	-- 0prime
	['BetterDortware'] = {
		{["CFrame"] = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), ["Time"] = 0.03},
		{["CFrame"] = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(80), math.rad(90)), ["Time"] = 0.07},
		{["CFrame"] = CFrame.new(0.5, -0.2, -0.8) * CFrame.Angles(math.rad(-150), math.rad(111), math.rad(20)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(0.5, -0.2, -0.8) * CFrame.Angles(math.rad(-150), math.rad(111), math.rad(20)), ["Time"] = 0.03}
	},
	['BingChilling'] = {
		{["CFrame"] = CFrame.new(0.07, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2}
	},
	['HypixelBlock'] = {
		{["CFrame"] = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.3, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2}
	},
	['INUMAURA'] = {
		{["CFrame"] = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-20), math.rad(20), math.rad(0)), ["Time"] = 0.30},
		{["CFrame"] = CFrame.new(0, -0.50, -0.30) * CFrame.Angles(math.rad(-40), math.rad(41), math.rad(0)), ["Time"] = 0.32},
		{["CFrame"] = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), ["Time"] = 0.32}
	},
	-- Voidware
	['Shake'] = {
		{["CFrame"] = CFrame.new(0.69, -0.8, 0.6) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-35)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.8, -0.71, 0.30) * CFrame.Angles(math.rad(-60), math.rad(39), math.rad(-55)), ["Time"] = 0.02},
		{["CFrame"] = CFrame.new(0.8, -2, 0.45) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-55)), ["Time"] = 0.03}
	},
	['PopV3'] = {
		{["CFrame"] = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.1}
	},
	['PopV4'] = {
		{["CFrame"] = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.01},
		{["CFrame"] = CFrame.new(0.7, -0.30, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.01},
		{["CFrame"] = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.01}
	},
	['Remake'] = {
		{["CFrame"] = CFrame.new(-0.10, -0.45, -0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-50)), ["Time"] = 0.01},
		{["CFrame"] = CFrame.new(0.7, -0.71, -1) * CFrame.Angles(math.rad(-90), math.rad(50), math.rad(-38)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.63, -0.1, 1.50) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.15}
	},
	['PopV2'] = {
		{["CFrame"] = CFrame.new(0.10, -0.3, -0.30) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(290)), ["Time"] = 0.09},
		{["CFrame"] = CFrame.new(0.10, 0.10, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.15},
	},
	['Bob'] = {
		{["CFrame"] = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(-0.7, -2.5, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2}
	},
	['Knife'] = {
		{["CFrame"] = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(4, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2},
	},
	['FunnyExhibition'] = {
		{["CFrame"] = CFrame.new(-1.5, -0.50, 0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.10},
		{["CFrame"] = CFrame.new(-0.55, -0.20, 1.5) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2},
	},
	['FasterSmooth'] = {
		{["CFrame"] = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), ["Time"] = 0.11},
		{["CFrame"] = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), ["Time"] = 0.11},
		{["CFrame"] = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), ["Time"] = 0.11},
	},
	['Smooth2'] = {
		{["CFrame"] = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), ["Time"] = 0.25},
		{["CFrame"] = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), ["Time"] = 0.25},
		{["CFrame"] = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), ["Time"] = 0.25},
	},
	['Funny'] = {
		{["CFrame"] = CFrame.new(0, 0, 1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-55), math.rad(0), math.rad(0)), ["Time"] = 0.15}
	},
	['FunnyFuture'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)),["Time"] = 0.25},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),["Time"] = 0.25}
	},
	['Goofy'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.25},
		{["CFrame"] = CFrame.new(-1, -1, 1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),["Time"] = 0.25},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-33)),["Time"] = 0.25}
	},
	['Future'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.10) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.20},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),["Time"] = 0.25}
	},
	['Pop'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),["Time"] = 0.25},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), ["Time"] = 0.35},
		{["CFrame"] = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.35}
	},
	['FunnyV2'] = {
		{["CFrame"] = CFrame.new(0.10, -0.5, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), ["Time"] = 0.45},
		{["CFrame"] = CFrame.new(-5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.45},
		{["CFrame"] = CFrame.new(5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.45},
	},
	['Slowest'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.72, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.1},
	},
	['BigAuraAnimation'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.09},
		{["CFrame"] = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.15},
	},
	-- Acronis
	['Acronisware'] = {
		{["CFrame"] = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.03},
		{["CFrame"] = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.13},
	},
	-- Snoopy
	['CustomSP+'] = {
		{["CFrame"] = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.03},
		{["CFrame"] = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.09},
		{["CFrame"] = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.13}
	},
	['FemboyActivis'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), ["Time"] = 0},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), ["Time"] = 0.11}
	},
	['Lift'] = {
		{["CFrame"] = CFrame.new(0.5, -0.5, 0.5) * CFrame.Angles(math.rad(-15), math.rad(0), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.5, -0.4, 0.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.3},
	},
	['SlowLift'] = {
		{["CFrame"] = CFrame.new(0.5, -0.5, 0.5) * CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0)), ["Time"] = 0.5},
		{["CFrame"] = CFrame.new(0.5, -0.4, 0.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 1},
	},
	['Shit'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(-0.1, -0.2, 0.05) * CFrame.Angles(math.rad(-15), math.rad(30), math.rad(15)), ["Time"] = 0.4},
		{["CFrame"] = CFrame.new(-0.12, -0.22, 0.06) * CFrame.Angles(math.rad(-10), math.rad(60), math.rad(25)), ["Time"] = 0.6},
		{["CFrame"] = CFrame.new(-0.1, -0.18, 0.08) * CFrame.Angles(math.rad(-25), math.rad(30), math.rad(10)), ["Time"] = 0.8},
		{["CFrame"] = CFrame.new(0.2, -0.15, -0.05) * CFrame.Angles(math.rad(-5), math.rad(0), math.rad(-10)), ["Time"] = 1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 1.2},
	},
	['SwingOld'] = {
		{["CFrame"] = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(5), math.rad(0), math.rad(5)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0, -0.48, 0) * CFrame.Angles(math.rad(-5), math.rad(0), math.rad(-5)), ["Time"] = 0.25},
		{["CFrame"] = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(5), math.rad(0), math.rad(5)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0, -0.52, 0) * CFrame.Angles(math.rad(-5), math.rad(0), math.rad(-5)), ["Time"] = 0.25},
	},		
	['throw'] = { 
		{["CFrame"] = CFrame.new(-0.04, -0.4, -1.05) * CFrame.Angles(math.rad(-30), math.rad(100), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.32, -0.81, 0.10) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), ["Time"] = 0.20},
		{["CFrame"] = CFrame.new(0.10, -0.5, -0.3) * CFrame.Angles(math.rad(-40), math.rad(55), math.rad(-50)), ["Time"] = 0.30},
		{["CFrame"] = CFrame.new(-0.04, -0.4, 0.5) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), ["Time"] = 0.15}
	},
	['OLD'] = { 
		{["CFrame"] = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), ["Time"] = 0.25},
		{["CFrame"] = CFrame.new(0.80, -0.77, 0.9) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-90)), ["Time"] = 0.20},
		{["CFrame"] = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.3, -0.4, 0.6) * CFrame.Angles(math.rad(-8), math.rad(40), math.rad(-60)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(-0.04, -0.4, -1.05) * CFrame.Angles(math.rad(-30), math.rad(100), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(-0.04, -0.4, 0.5) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), ["Time"] = 0.15}
	},
	['SwingAnimation'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-45), math.rad(0), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.2},
	},
	['ExhibitionV2'] = {
		{["CFrame"] = CFrame.new(0.65, -0.6, 0.7) * CFrame.Angles(math.rad(-60), math.rad(70), math.rad(-100)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.75, -0.65, 0.7) * CFrame.Angles(math.rad(-70), math.rad(80), math.rad(-50)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.8, -0.7, 0.75) * CFrame.Angles(math.rad(-80), math.rad(90), math.rad(-40)), ["Time"] = 0.3}
	},
	['FrontwardAscend'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0.2, -0.1) * CFrame.Angles(math.rad(10), math.rad(0), math.rad(0)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0, 0.4, -0.2) * CFrame.Angles(math.rad(20), math.rad(0), math.rad(0)), ["Time"] = 0.5},
		{["CFrame"] = CFrame.new(0, 0.2, -0.5) * CFrame.Angles(math.rad(10), math.rad(0), math.rad(0)), ["Time"] = 0.8},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 1.2}
	},
	['SpiralReturn'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(360), math.rad(0), math.rad(0)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0, 0, -2) * CFrame.Angles(math.rad(720), math.rad(0), math.rad(0)), ["Time"] = 0.6},
		{["CFrame"] = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(1080), math.rad(0), math.rad(0)), ["Time"] = 0.9},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1440), math.rad(0), math.rad(0)), ["Time"] = 1.2},
	},
	['Boomerang'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(2, 0, -1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(1, 0, -2) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.45},
		{["CFrame"] = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.6},
		{["CFrame"] = CFrame.new(-1, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.75},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.9},
	},
	['SmoothFlow'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(0), math.rad(20), math.rad(0)), ["Time"] = 0.4},
		{["CFrame"] = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), ["Time"] = 0.6},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.8},
	},
	['OldSmooth'] = {
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.25, -0.35, 0.3) * CFrame.Angles(math.rad(-15), math.rad(25), math.rad(-45)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), ["Time"] = 0.5},
		{["CFrame"] = CFrame.new(0.625, -0.355, 0.295) * CFrame.Angles(math.rad(-42), math.rad(30), math.rad(-64)), ["Time"] = 0.7},
		{["CFrame"] = CFrame.new(0.750, -0.71, 0.29) * CFrame.Angles(math.rad(-57), math.rad(55), math.rad(-81)), ["Time"] = 0.9},
		{["CFrame"] = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), ["Time"] = 1.1},
		{["CFrame"] = CFrame.new(0.25, -0.35, 0.3) * CFrame.Angles(math.rad(-15), math.rad(25), math.rad(-45)), ["Time"] = 1.3},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 1.5},
	},		
	['SlowlySmooth'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.25},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.5},
		{["CFrame"] = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), ["Time"] = 0.75},
		{["CFrame"] = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), ["Time"] = 1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 1.25},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 1.5},
	},
	['Meteor+'] = { 
		{["CFrame"] = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), ["Time"] = 0.15}
	},
	['ExhiCloneAndMeteor'] = {
		{["CFrame"] = CFrame.new(0.68, -0.7, 0.61) * CFrame.Angles(math.rad(-20), math.rad(45), math.rad(-85)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.695, -0.705, 0.595) * CFrame.Angles(math.rad(-60), math.rad(48), math.rad(-65)), ["Time"] = 0.3},
		{["CFrame"] = CFrame.new(0.72, -0.72, 0.58) * CFrame.Angles(math.rad(-90), math.rad(52), math.rad(-40)), ["Time"] = 0.45},
		{["CFrame"] = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), ["Time"] = 0.6},
		{["CFrame"] = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), ["Time"] = 0.75}
	},	
	['ExhibitionClone'] = {
		{["CFrame"] = CFrame.new(0.68, -0.7, 0.61) * CFrame.Angles(math.rad(-20), math.rad(45), math.rad(-85)), ["Time"] = 0.15},  
		{["CFrame"] = CFrame.new(0.695, -0.705, 0.595) * CFrame.Angles(math.rad(-60), math.rad(48), math.rad(-65)), ["Time"] = 0.3},  
		{["CFrame"] = CFrame.new(0.72, -0.72, 0.58) * CFrame.Angles(math.rad(-90), math.rad(52), math.rad(-40)), ["Time"] = 0.45}   
	},	
	['LatestClone'] = {
		{["CFrame"] = CFrame.new(0.68, -0.72, 0.12) * CFrame.Angles(math.rad(-63), math.rad(57), math.rad(-49)), ["Time"] = 0.4},
		{["CFrame"] = CFrame.new(0.17, -1.18, 0.52) * CFrame.Angles(math.rad(-177), math.rad(56), math.rad(31)), ["Time"] = 0.4}
	},
	['SpinClone'] = {
		{["CFrame"] = CFrame.new(0.5, -0.6, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.5, -0.55, 0) * CFrame.Angles(math.rad(0), math.rad(45), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.5, -0.5, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.5, -0.55, 0) * CFrame.Angles(math.rad(0), math.rad(135), math.rad(0)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.5, -0.6, 0) * CFrame.Angles(math.rad(0), math.rad(180), math.rad(0)), ["Time"] = 0.15},
	},
	["Inum's Ass"] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.05},
		{["CFrame"] = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), ["Time"] = 0.8},
		{["CFrame"] = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), ["Time"] = 0.01},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(65), math.rad(-79)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(35), math.rad(-56)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), ["Time"] = 0.07},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), ["Time"] = 0.13},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), ["Time"] = 0.19},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(54), math.rad(-56)), ["Time"] = 0.08},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(38), math.rad(-23)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(98), math.rad(-354)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(65), math.rad(-68)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.67, -0.66, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-85)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.72, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(59), math.rad(-50)), ["Time"] = 0.2},
		{["CFrame"] = CFrame.new(0.65, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-76)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.77, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(76), math.rad(-32)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(0.63, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(65), math.rad(-65)), ["Time"] = 0.21},
		{["CFrame"] = CFrame.new(0.73, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(49), math.rad(-25)), ["Time"] = 0.26}
	},
	['Ware'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(65), math.rad(-79)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(35), math.rad(-56)), ["Time"] = 0.2}
	},
	['Wearish'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.58) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), ["Time"] = 0.17}
	},
	-- Azura
	['Assura'] = {
		{["CFrame"] = CFrame.new(0.67, -0.66, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-85)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.72, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(59), math.rad(-50)), ["Time"] = 0.2}
	},
	["Assura Old"] = {
		{["CFrame"] = CFrame.new(0.65, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-76)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.77, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(76), math.rad(-32)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(0.63, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(65), math.rad(-65)), ["Time"] = 0.21},
		{["CFrame"] = CFrame.new(0.73, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(49), math.rad(-25)), ["Time"] = 0.26}
	},
	["Assura Combined"] = {
		{["CFrame"] = CFrame.new(0.67, -0.66, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-85)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.72, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(59), math.rad(-50)), ["Time"] = 0.14},
		{["CFrame"] = CFrame.new(0.65, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-76)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.77, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(76), math.rad(-32)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(0.63, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(65), math.rad(-65)), ["Time"] = 0.21},
		{["CFrame"] = CFrame.new(0.73, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(49), math.rad(-25)), ["Time"] = 0.26}
	},
	-- Scrxpted
	['ScrxptedIsBLACK'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), ["Time"] = 0.19}
	},
	-- Lunar
	["Lunar Old"] = {
		{["CFrame"] = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), ["Time"] = 0.15}
	},
	["Lunar New"] = {
		{["CFrame"] = CFrame.new(0.86, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), ["Time"] = 0.17},
		{["CFrame"] = CFrame.new(0.73, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), ["Time"] = 0.17}
	},
	["Lunar Fast"] = {
		{["CFrame"] = CFrame.new(0.95, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(0.40, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), ["Time"] = 0.15}
	},
	["LiquidBounceX"] = {
		{["CFrame"] = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(90), math.rad(-90)), ["Time"] = 0.45},
		{["CFrame"] = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), ["Time"] = 0.45},
		{["CFrame"] = CFrame.new(-0.01, -0.3, 0.4) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), ["Time"] = 0.32}
	},
	["Auto Block"] = {
		{["CFrame"] = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(65)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(110), math.rad(65)), ["Time"] = 0.15},
		{["CFrame"] = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(65), math.rad(65)), ["Time"] = 0.15}
	},
	['Switch'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), ["Time"] = 0.1},
		{["CFrame"] = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), ["Time"] = 0.1}
	},
	['Sideways'] = {
		{["CFrame"] = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), ["Time"] = 0.12},
		{["CFrame"] = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), ["Time"] = 0.12}
	},
	['Stand'] = {
		{["CFrame"] = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), ["Time"] = 0.1}
	}
};

local speedMethods: any;
local speedMethodList: table = {'Velocity'};
local speedMethods: {
    Velocity: (options: { Value: { Value: number } }, moveDirection: Vector3) -> (),
    CFrame: (options: { Value: { Value: number }, WallCheck: { ["Enabled"]: boolean }, rayCheck: { FilterDescendantsInstances: {any}, CollisionGroup: any }, TPTiming: number, TPFrequency: { Value: number }, WalkSpeed: number?, PulseLength: { Value: number }, PulseDelay: { Value: number } }, moveDirection: Vector3, dt: number) -> (),
    Impulse: (options: { Value: { Value: number } }, moveDirection: Vector3) -> (),
	TP: (options: { TPTiming: number, TPFrequency: { Value: number } }, moveDirection: Vector3) -> (),
    WalkSpeed: (options: { Value: { Value: number }, WalkSpeed: number? }) -> (),
    Pulse: (options: { Value: { Value: number }, PulseLength: { Value: number }, PulseDelay: { Value: number } }, moveDirection: Vector3) -> ()
} = {
	["Velocity"] = function(options: { Value: { Value: number } }, moveDirection: Vector3)
		local root: RootPart? = entitylib.character.RootPart;
		root.AssemblyLinearVelocity = (moveDirection * options["Value"]["Value"]) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0);
	end,
	["Impulse"] = function(options: { Value: { Value: number } }, moveDirection: Vector3)
		local root: RootPart? = entitylib.character.RootPart;
		local diff: CFrame? = ((moveDirection * options["Value"]["Value"]) - root.AssemblyLinearVelocity) * Vector3.new(1, 0, 1);
		if diff.Magnitude > (moveDirection == Vector3.zero and 10 or 2) then
			root:ApplyImpulse(diff * root.AssemblyMass);
		end;
	end,
	["CFrame"] = function(options: { Value: { Value: number }, WallCheck: { ["Enabled"]: boolean }, rayCheck: { FilterDescendantsInstances: {any}, CollisionGroup: any } }, moveDirection: Vector3, dt: number)
		local root: RootPart? = entitylib.character.RootPart;
		local dest: CFrame? = (moveDirection * math.max(options["Value"]["Value"] - entitylib.character.Humanoid.WalkSpeed, 0) * dt);
		if options.WallCheck["Enabled"] then
			options.rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera};
			options.rayCheck.CollisionGroup = root.CollisionGroup;
			local ray: Raycast = workspace:Raycast(root.Position, dest, options.rayCheck);
			if ray then
				dest = ((ray.Position + ray.Normal) - root.Position);
			end;
		end;
		root.CFrame += dest;
	end,
	 ["TP"] = function(options: { TPTiming: number, TPFrequency: { Value: number } }, moveDirection: Vector3)
		if options.TPTiming < os.clock() then
			options.TPTiming = os.clock() + options.TPFrequency["Value"];
			speedMethods.CFrame(options, moveDirection, 1);
		end;
	end,
	["WalkSpeed"] = function(options: { Value: { Value: number }, WalkSpeed: number? })
		if not options.WalkSpeed then options.WalkSpeed = entitylib.character.Humanoid.WalkSpeed; end;
		entitylib.character.Humanoid.WalkSpeed = options["Value"]["Value"];
	end,
	 ["Pulse"] = function(options: { Value: { Value: number }, PulseLength: { Value: number }, PulseDelay: { Value: number } }, moveDirection: Vector3)
		local root: RootPart? = entitylib.character.RootPart;
		local dt: Number? = math.max(options["Value"]["Value"] - entitylib.character.Humanoid.WalkSpeed, 0);
		dt = dt * (1 - math.min((os.clock() % (options.PulseLength["Value"] + options.PulseDelay["Value"])) / options.PulseLength["Value"], 1));
		root.AssemblyLinearVelocity = (moveDirection * (entitylib.character.Humanoid.WalkSpeed + dt)) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0);
	end;
};
for name: any in speedMethods do
	if not table.find(speedMethodList, name) then
		table.insert(speedMethodList, name);
	end;
end;

velo.run(function()
	entitylib.getUpdateConnections = function(ent: any): {RBXScriptConnection}
		local hum: Humanoid? = ent.Humanoid;
		return {
			hum:GetPropertyChangedSignal('Health'),
			hum:GetPropertyChangedSignal('MaxHealth'),
			{
				["Connect"] = function()
					ent.Friend = ent.Player and isFriend(ent.Player) or nil;
					ent.Target = ent.Player and isTarget(ent.Player) or nil;
					return {
						["Disconnect"] = function() end
					};
				end;
			}
		};
	end;

	entitylib.targetCheck = function(ent: any): boolean?
		if ent.TeamCheck then
			return ent:TeamCheck();
		end;
		if ent.NPC then return true; end;
		if isFriend(ent.Player) then return false; end;
		if not select(2, whitelist:get(ent.Player)) then return false; end;
		if vape.Categories.Main.Options['Teams by server']["Enabled"] then
			if not lplr.Team then return true; end;
			if not ent.Player.Team then return true; end;
			if ent.Player.Team ~= lplr.Team then return true; end;
			return #ent.Player.Team:GetPlayers() == #playersService:GetPlayers();
		end;
		return true;
	end;

	entitylib.getEntityColor = function(ent: any): any
		ent = ent.Player;
		if not (ent and vape.Categories.Main.Options['Use team color']["Enabled"]) then return; end;
		if isFriend(ent, true) then
			return Color3.fromHSV(vape.Categories.Friends.Options['Friends color']["Hue"], vape.Categories.Friends.Options['Friends color']["Sat"], vape.Categories.Friends.Options['Friends color']["Value"]);
		end;
		return tostring(ent.TeamColor) ~= 'White' and ent.TeamColor.Color or nil;
	end;

	vape:Clean(function()
		entitylib.kill();
		entitylib = nil;
	end);
	vape:Clean(vape.Categories.Friends.Update.Event:Connect(function() entitylib.refresh(); end));
	vape:Clean(vape.Categories.Targets.Update.Event:Connect(function() entitylib.refresh(); end));
	vape:Clean(entitylib.Events.LocalAdded:Connect(updateVelocity));
	vape:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
		gameCamera = cloneref(workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera') or Instance.new('Camera'));
	end));
end);

velo.run(function()
	local corePackages: any = game:GetService('CorePackages');
	local cachedModules: {[string]: any} = {};
	local findCoreModule: (name: string) -> any = function(name: string): any
		if cachedModules[name] then return cachedModules[name]; end;
		for _, desc: Instance in corePackages:GetDescendants() do
			if desc.Name == name and desc:IsA('ModuleScript') then
				local ok: boolean = pcall(getrenv().require, desc);
				if ok then
					cachedModules[name] = desc;
					return desc;
				end;
			end;
		end;
		return nil;
	end;

	local requireCore: (name: string) -> any = function(name: string): any
		local mod: any = findCoreModule(name);
		if not mod then return nil; end;
		return getrenv().require(mod);
	end;

	local signalAnimId: string = 'rbxassetid://92129176254703';

	whitelist.get = function(self: any, plr: Player): (number, boolean, any)
		local plrstr: string = self.hashes[plr.Name..plr.UserId];
		for _, v: any in self.data.WhitelistedUsers do
			if v.hash == plrstr then
				return v.level, v.attackable or whitelist.localprio >= v.level or whitelist.localprio == 0, v.tags;
			end;
		end;
		return 0, true;
	end;

	whitelist.isingame = function(self: any): boolean
		for _, v: Player in playersService:GetPlayers() do
			if self:get(v) ~= 0 then
				return true;
			end;
		end;
		return false;
	end;

	whitelist.tag = function(self: any, plr: Player, text: string?, rich: boolean?): string?
		local _a: number, _b: boolean, tags: any = self:get(plr);
		local plrtag: any = table.clone(tags or (self.customtags and self.customtags[plr.Name]) or {});
		local newtag: string = '';
		for _, v: any in (self.tagcallback or {}) do
			v(plr, plrtag, rich);
		end;
		if not text then
			return plrtag;
		end;
		for _, v: any in (plrtag or {}) do
			newtag = newtag..(rich and v.color and '<font color="#'..v.color:ToHex()..'">['..v.text..']</font>' or '['..removeTags(v.text)..']')..' ';
		end;
		return newtag;
	end;

	whitelist.getplayer = function(self: any, arg: string?, plr: Player): boolean
		if arg == 'default' and self.localprio == 0 then
			return true;
		end;
		if arg == 'buyer' and self.localprio == 1 then
			return true;
		end;
		if arg == 'private' and self.localprio == 2 then
			return true;
		end;
		if (arg == 'all' or arg == 'others') and plr ~= lplr then
			return true;
		end;
		if arg and lplr.Name:lower():sub(1, arg:len()) == arg:lower() then
			return true;
		end;
		return false;
	end;

	local getTargetsByMaxPrio: (maxPrio: number) -> {Player} = function(maxPrio: number): {Player}
		local result: {Player} = {};
		for _, v: Player in playersService:GetPlayers() do
			local prio: number = whitelist:get(v) or 0;
			if prio <= maxPrio then
				table.insert(result, v);
			end;
		end;
		return result;
	end;

	whitelist.findTargets = function(self: any, arg: string?, plr: Player): {Player}
		if not arg then return {}; end;
		local senderPrio: number = self:get(plr) or 0;
		local lower: string = arg:lower();
		if lower == 'default' and senderPrio >= 1 then
			return getTargetsByMaxPrio(0);
		end;
		if lower == 'buyer' and senderPrio >= 2 then
			return getTargetsByMaxPrio(1);
		end;
		if lower == 'private' and senderPrio >= 3 then
			return getTargetsByMaxPrio(2);
		end;
		if lower == 'master' and senderPrio >= 4 then
			return getTargetsByMaxPrio(3);
		end;
		if (lower == 'all' or lower == 'others') and senderPrio >= 1 then
			local result: {Player} = {};
			for _, v: Player in playersService:GetPlayers() do
				if v ~= plr then
					table.insert(result, v);
				end;
			end;
			return result;
		end;

		if senderPrio >= 1 then
			for _, v: Player in playersService:GetPlayers() do
				if v.Name:lower():sub(1, arg:len()) == lower then
					return {v};
				end;
			end;
		end;

		return {};
	end;

	whitelist.CheckPlayerType = function(self: any, plr: Player?): string
		if not plr then return 'DEFAULT'; end;
		local plrPriority: number = self:get(plr) or 0;
		if plrPriority == 0 then
			return 'DEFAULT';
		elseif plrPriority == 1 then
			return 'BUYER';
		elseif plrPriority == 2 then
			return 'VELOCITY PRIVATE';
		elseif plrPriority == 3 then
			return 'VELOCITY ADMIN';
		elseif plrPriority >= 4 then
			return 'VELOCITY OWNER';
		end;
		return 'DEFAULT';
	end;

	whitelist.flagVapeUser = function(self: any, plr: Player): ()
		if self.said[plr.Name] then return; end;
		self.said[plr.Name] = true;
		notif('Velo', plr.Name..' is using vape!', 60);
		self.customtags[plr.Name] = {{
			["text"] = 'VAPE USER';
			["color"] = Color3.new(1, 1, 0);
		}};
		local newent: any = entitylib.getEntity(plr);
		if newent then
			entitylib.Events.EntityUpdated:Fire(newent);
		end;
	end;

	local cmdAnimCodes: {[string]: number} = {
		["kill"] = 2, 
		["crash"] = 3, 
		["kick"] = 4, 
		["deletemap"] = 5,
		["jump"] = 6, 
		["void"] = 7, 
		["shutdown"] = 8, 
		["block"] = 9,
		["black"] = 10, 
		["troll"] = 11, 
		["ban"] = 12, 
		["murder"] = 13,
		["reveal"] = 14, 
		["trip"] = 15, 
		["sit"] = 16, 
		["unsit"] = 17,
		["freeze"] = 18, 
		["unfreeze"] = 19, 
		["lagback"] = 20, 
		["byfron"] = 21,
		["chipman"] = 22, 
		["rickroll"] = 23, 
		["josiah"] = 24, 
		["xylex"] = 25,
	};
	local animCodeCmds: {[number]: string} = {};
	for cmd: string, code: number in cmdAnimCodes do
		animCodeCmds[code] = cmd;
	end;

	local playSignalAnim: () -> () = function(): ()
		pcall(function(): ()
			local anim: Animation = Instance.new('Animation');
			anim.AnimationId = signalAnimId;
			local char: Model? = lplr.Character;
			local hum: Humanoid? = char and char:FindFirstChildOfClass('Humanoid');
			local animator: Animator? = hum and hum:FindFirstChildOfClass('Animator');
			if animator then
				local track: AnimationTrack = animator:LoadAnimation(anim);
				track:Play();
				task.wait(1);
				track:Stop();
			end;
		end);
	end;

	local playCommandAnim: (cmdName: string) -> () = function(cmdName: string): ()
		local code: number? = cmdAnimCodes[cmdName];
		if not code then return; end;
		pcall(function(): ()
			local char: Model? = lplr.Character;
			local hum: Humanoid? = char and char:FindFirstChildOfClass('Humanoid');
			local animator: Animator? = hum and hum:FindFirstChildOfClass('Animator');
			if not animator then return; end;
			for i: number = 1, code do
				local anim: Animation = Instance.new('Animation');
				anim.AnimationId = signalAnimId;
				local track: AnimationTrack = animator:LoadAnimation(anim);
				track:Play();
				task.wait(0.1);
				track:Stop();
				if i < code then task.wait(0.1); end;
			end;
		end);
	end;

	local whisperCommand: (target: Player, cmdName: string) -> () = function(target: Player, cmdName: string): ()
		pcall(function(): ()
			if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
				local oldchannel: any = textChatService.ChatInputBarConfiguration.TargetTextChannel;
				local newchannel: any = cloneref(game:GetService('RobloxReplicatedStorage')).ExperienceChat.WhisperChat:InvokeServer(target.UserId);
				if newchannel then
					newchannel:SendAsync('vc:'..cmdName);
				end;
				textChatService.ChatInputBarConfiguration.TargetTextChannel = oldchannel;
			elseif replicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
				replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('/w '..target.Name..' vc:'..cmdName, 'All');
			end;
		end);
	end;

	whitelist.stopWatchingAnimations = function(self: any, plr: Player): ()
		local watcher: any = self.animWatchers[plr];
		if not watcher then return; end;
		self.animWatchers[plr] = nil;
		if watcher.charConn then pcall(function(): () watcher.charConn:Disconnect(); end); end;
		if watcher.animConn then pcall(function(): () watcher.animConn:Disconnect(); end); end;
		if watcher.debounceThread then pcall(task.cancel, watcher.debounceThread); end;
	end;

	whitelist.watchAnimations = function(self: any, plr: Player): ()
		if plr == lplr then return; end;
		if self.animWatchers[plr] then return; end;

		local watcher: any = {["animCount"] = 0};
		self.animWatchers[plr] = watcher;

		local watchCharacter: (char: Model?) -> () = function(char: Model?): ()
			if watcher.animConn then
				pcall(function(): () watcher.animConn:Disconnect(); end);
				watcher.animConn = nil;
			end;
			if watcher.debounceThread then
				pcall(task.cancel, watcher.debounceThread);
				watcher.debounceThread = nil;
			end;
			watcher.animCount = 0;
			if not char then return; end;
			task.spawn(function(): ()
				local hum: Humanoid? = char:FindFirstChildOfClass('Humanoid') or char:WaitForChild('Humanoid', 5);
				local animator: Animator? = hum and (hum:FindFirstChildOfClass('Animator') or hum:WaitForChild('Animator', 5));
				if not animator or self.animWatchers[plr] ~= watcher or plr.Character ~= char then return; end;
				watcher.animConn = animator.AnimationPlayed:Connect(function(track: AnimationTrack): ()
					if track.Animation and track.Animation.AnimationId == signalAnimId then
						if self.localprio > 0 then
							self:flagVapeUser(plr);
							return;
						end;
						watcher.animCount += 1;
						if watcher.debounceThread then pcall(task.cancel, watcher.debounceThread); end;
						local wait: number = math.max(0.5, watcher.animCount * 0.15);
						watcher.debounceThread = task.delay(wait, function(): ()
							local count: number = watcher.animCount;
							watcher.animCount = 0;
							watcher.debounceThread = nil;
							if count == 1 then
								task.spawn(playSignalAnim);
							elseif count >= 2 then
								local cmdName: string? = animCodeCmds[count];
								if cmdName then
									local cmdFunc: any = self.commands[cmdName];
									if cmdFunc then
										task.spawn(function(): ()
											cmdFunc({}, plr);
										end);
									end;
								end;
							end;
						end);
					end;
				end);
			end);
		end;
		watcher.charConn = plr.CharacterAdded:Connect(watchCharacter);
		watchCharacter(plr.Character);
	end;

	whitelist.process = function(self: any, msg: string, plr: Player, rawText: string?): boolean
		local text: string = rawText or msg;
		local clean: string = text:gsub('^/w%s+%S+%s*', ''):gsub('^/whisper%s+%S+%s*', '');
		if plr == lplr and (clean == 'helloimusinginhaler' or clean:sub(1, 3) == 'vc:') then
			return true;
		end;
		if self.localprio > 0 and clean == 'helloimusinginhaler' and plr ~= lplr then
			self:flagVapeUser(plr);
			return true;
		end;
		local senderPrio: number = self:get(plr) or 0;
		if plr ~= lplr and senderPrio <= self.localprio then
			return false;
		end;
		local args: {string} = clean:split(' ');
		local cmdStr: string = args[1] and args[1]:lower() or '';
		if cmdStr == ';cmds' then
			if plr == lplr then task.spawn(whitelist.commands.cmds); end;
			return true;
		end;
		if cmdStr == ';arg' then
			if plr == lplr then task.spawn(whitelist.commands.arg); end;
			return true;
		end;
		if clean:sub(1, 3) == 'vc:' and plr ~= lplr then
			local vcSenderPrio: number = self:get(plr) or 0;
			if vcSenderPrio > self.localprio then
				local cmdName: string = clean:sub(4):lower();
				local cmdFunc: any = self.commands[cmdName];
				if cmdFunc then
					task.spawn(function(): ()
						cmdFunc({}, plr);
					end);
				end;
			end;
			return true;
		end;

		if plr == lplr then
			if cmdStr:sub(1, 1) == ';' then
				local cmdName: string = cmdStr:sub(2):lower();
				if self.commands[cmdName] and args[2] then
					local targets: {Player} = self:findTargets(args[2], lplr);
					for _, target: Player in targets do
						if target ~= lplr then
							task.spawn(function(): ()
								whisperCommand(target, cmdName);
							end);
						end;
					end;
					if cmdAnimCodes[cmdName] then
						task.spawn(function(): ()
							playCommandAnim(cmdName);
						end);
					end;
				end;
				return true;
			end;
			return false;
		end;

		if args[2] then
			local targets: {Player} = self:findTargets(args[2], plr);
			if table.find(targets, lplr) then
				local cmdArgs: {string} = {};
				for i: number = 3, #args do
					table.insert(cmdArgs, args[i]);
				end;
				for cmd: string, func: any in self.commands do
					if cmdStr == ';'..cmd:lower() then
						func(cmdArgs, plr);
						return true;
					end;
				end;
			end;
		end;
		return false;
	end;

	local legacyResults: {[any]: boolean} = {};
	local legacyResultCount: number = 0;
	whitelist.legacyprocess = function(self: any, data: any): boolean
		local plr: Player? = playersService:GetPlayerByUserId(data.SpeakerUserId);
		if not plr then
			return false;
		end;
		local id: any = data.ID;
		local result: boolean? = nil;
		if id ~= nil then
			result = legacyResults[id];
		end;
		if result == nil and type(data.Message) == 'string' and data.Message ~= '' then
			result = self:process(data.Message, plr) == true;
			if id ~= nil then
				legacyResults[id] = result;
				legacyResultCount += 1;
				if legacyResultCount > 300 then
					table.clear(legacyResults);
					legacyResultCount = 0;
				end;
			end;
		end;
		return result == true;
	end;
	local olduninject: any;
	whitelist.playeradded = function(self: any, v: Player?, joined: boolean?): ()
		if self:get(v) ~= 0 then
			if self.alreadychecked[v.UserId] then return; end;
			self.alreadychecked[v.UserId] = true;
			self:hook();
			if self.localprio == 0 then
				olduninject = vape.Uninject;
				vape.Uninject = function(): ()
					notif('Velo', 'No escaping the private members :)', 10);
				end;
				if joined then
					task.wait(10);
				end;
				local chatSent: boolean = false;
				if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
					pcall(function(): ()
						local oldchannel: any = textChatService.ChatInputBarConfiguration.TargetTextChannel;
						local newchannel: any = cloneref(game:GetService('RobloxReplicatedStorage')).ExperienceChat.WhisperChat:InvokeServer(v.UserId);
						if newchannel then
							newchannel:SendAsync('helloimusinginhaler');
							chatSent = true;
						end;
						textChatService.ChatInputBarConfiguration.TargetTextChannel = oldchannel;
					end);
				elseif replicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
					pcall(function(): ()
						replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('/w '..v.Name..' helloimusinginhaler', 'All');
						chatSent = true;
					end);
				end;
				if not chatSent then
					task.spawn(playSignalAnim);
				end;
			elseif self.localprio > 0 then
				task.wait(joined and 2 or 0);
				task.spawn(playSignalAnim);
			end;
		end;
	end;

	whitelist.hook = function(self: any): ()
		if self.hooked then return; end;
		self.hooked = true;

		local brighten: (c: any) -> any = function(c: any): any
			if typeof(c) ~= 'Color3' then return c; end;
			local m: number = math.max(c.R, c.G, c.B);
			if m > 0 and m < 0.55 then
				local s: number = 0.82 / m;
				return Color3.new(math.min(c.R * s, 1), math.min(c.G * s, 1), math.min(c.B * s, 1));
			end;
			return c;
		end;

		local tagObjs: (plr: Player) -> {any}? = function(plr: Player): {any}?
			local list: any = self:tag(plr);
			if type(list) ~= 'table' or #list == 0 then return nil; end;
			local out: {any} = {};
			for _, t: any in list do
				if typeof(t.color) == 'Color3' then
					out[#out + 1] = {["TagText"] = removeTags(t.text), ["TagColor"] = brighten(t.color)};
				else
					out[#out + 1] = {["TagText"] = removeTags(t.text)};
				end;
			end;
			return out;
		end;

		local lastSelf: string, lastTime: number = '', 0;
		local processSelf: (msg: string) -> () = function(msg: string): ()
			local now: number = os.clock();
			if msg == lastSelf and now - lastTime < 1 then return; end;
			lastSelf, lastTime = msg, now;
			pcall(self.process, self, msg, lplr);
		end;
		self.chattedConn = lplr.Chatted:Connect(processSelf);
		vape:Clean(self.chattedConn);

		local tcChannels: Instance? = textChatService:FindFirstChild('TextChannels');
		local useTextChat: boolean = textChatService.ChatVersion == Enum.ChatVersion.TextChatService
			or (tcChannels ~= nil and #tcChannels:GetChildren() > 0);

		if useTextChat then
			local original: any = getcallbackvalue and getcallbackvalue(textChatService, 'OnIncomingMessage');
			textChatService.OnIncomingMessage = function(message: any): any
				local props: any = nil;
				if original then
					local ok: boolean, r: any = pcall(original, message);
					if ok then props = r; end;
				end;
				if shared.veloc == vape then
					pcall(function(): ()
						local src: any = message.TextSource;
						local plr: Player? = src and playersService:GetPlayerByUserId(src.UserId);
						if not plr then return; end;
						local objs: {any}? = tagObjs(plr);
						if objs then
							local prefix: string = '';
							for _, o: any in objs do
								prefix = prefix..(o.TagColor and ('<font color="#'..o.TagColor:ToHex()..'">['..o.TagText..']</font> ') or ('['..o.TagText..'] '));
							end;
							props = props or Instance.new('TextChatMessageProperties');
							local existing: string = (props.PrefixText ~= '' and props.PrefixText) or message.PrefixText or '';
							if not existing:find((removeTags(prefix):gsub('%s+$', '')), 1, true) then
								props.PrefixText = prefix..existing;
							end;
						end;
						if plr == lplr then
							processSelf(message.Text);
						else
							pcall(self.process, self, message.Text, plr, message.Text);
						end;
					end);
				end;
				return props;
			end;
			vape:Clean(function(): ()
				pcall(function(): () textChatService.OnIncomingMessage = original; end);
			end);
		else
			local events: Instance? = replicatedStorage:FindFirstChild('DefaultChatSystemChatEvents');
			if events then
				pcall(function(): ()
					cloneref(game:GetService('Chat')):RegisterChatCallback(Enum.ChatCallbackType.OnClientFormattingMessage, function(message: any): any
						if shared.veloc ~= vape or type(message) ~= 'table' then return nil; end;
						local uid: number? = tonumber(message.SpeakerUserId);
						local plr: Player? = (uid and uid > 0 and playersService:GetPlayerByUserId(uid))
							or (type(message.FromSpeaker) == 'string' and playersService:FindFirstChild(message.FromSpeaker))
							or nil;
						if not plr then return nil; end;
						local objs: {any}? = tagObjs(plr);
						if not objs then return nil; end;
						local merged: {any} = {};
						for _, t: any in ((type(message.ExtraData) == 'table' and message.ExtraData.Tags) or {}) do
							merged[#merged + 1] = t;
						end;
						for _, o: any in objs do merged[#merged + 1] = o; end;
						return {["Tags"] = merged};
					end);
				end);
				local onLegacy: (data: any) -> () = function(data: any): ()
					if type(data) == 'table' and data.SpeakerUserId then
						pcall(whitelist.legacyprocess, whitelist, data);
					end;
				end;
				local onNew: any = events:FindFirstChild('OnNewMessage');
				local onFilter: any = events:FindFirstChild('OnMessageDoneFiltering');
				if onNew then vape:Clean(onNew.OnClientEvent:Connect(onLegacy)); end;
				if onFilter then vape:Clean(onFilter.OnClientEvent:Connect(onLegacy)); end;
			end;
		end;
	end;

	whitelist.announce = function(self: any, text: string): ()
		local success: boolean, sendToast: any = pcall(function(): any
			local getAppIdHook: any = getrenv().require(corePackages.Workspace.Packages._Workspace.AppCommonLib.AppCommonLib.Release.getNumericalApplicationId);
			local messageBusHook: any = getrenv().require(corePackages.Workspace.Packages._Workspace.MessageBus.MessageBus.MessageBus);
			messageBusHook.getMessageId = function(): () end;
			hookfunction(getAppIdHook, function(): number
				return 0;
			end);
			local localizationService: any = game:GetService('LocalizationService');
			local root: any = corePackages.Workspace.Packages._Index.NotificationModalsManager;
			local reactBlox: any = getrenv().require(root.ReactRoblox);
			local react: any = getrenv().require(root.React);
			local uiBlox: any = getrenv().require(root.UIBlox);
			uiBlox.init(getrenv().require(corePackages.Packages._Index.UIBlox.UIBlox.UIBloxDefaultConfig));
			local toastDialog: any = uiBlox.App.Dialog.Toast;
			local localization: any = getrenv().require(root.InExperienceLocales).Localization;
			local localProvider: any = getrenv().require(root.Localization).LocalizationProvider;
			local defaultTheme: any = getrenv().require(root.Style).StyleProviderWithDefaultTheme;
			local renderGui: any = nil;
			local createToast: any = function(content: any): any
				return react.createElement(localProvider, {
					["localization"] = localization.new(localizationService.RobloxLocaleId);
				}, {
					["StyleProvider"] = react.createElement(defaultTheme, {}, {
						["ToastWrapper"] = react.createElement('ScreenGui', {
							["IgnoreGuiInset"] = true;
							["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
							["ResetOnSpawn"] = false;
							["DisplayOrder"] = 12;
						}, {
							["Toast"] = react.createElement(toastDialog, {
								["duration"] = 20;
								["toastContent"] = content;
							});
						});
					});
				});
			end;
			return function(content: any): ()
				if not renderGui then
					local folder: Folder = Instance.new('Folder');
					folder.Name = 'UIBloxToast';
					folder.Parent = game:GetService('CoreGui');
					folder.ChildRemoved:Once(function(): ()
						folder:Destroy();
						renderGui = nil;
					end);
					renderGui = reactBlox.createRoot(folder);
				end;
				renderGui:render(react.createElement(createToast, content));
			end;
		end);
		if success then
			return sendToast({
				["toastTitle"] = text;
				["iconImage"] = getvapeasset('newvape/assets/new/vape.png');
				["swipeUpDismiss"] = true;
				["onActivated"] = function(): () end;
			});
		end;
		local container: TextButton = Instance.new('TextButton');
		container.Size = UDim2.new(1, -24, 0, 60);
		container.Position = UDim2.new(0.5, 0, 0, -60);
		container.AnchorPoint = Vector2.new(0.5, 0);
		container.BackgroundTransparency = 1;
		container.Text = '';
		container.Parent = vape.gui;
		local constraint: UISizeConstraint = Instance.new('UISizeConstraint');
		constraint.MinSize = Vector2.new(24, 60);
		constraint.MaxSize = Vector2.new(600, math.huge);
		constraint.Parent = container;
		local bkg: ImageLabel = Instance.new('ImageLabel');
		bkg.Size = UDim2.fromScale(1, 1);
		bkg.Position = UDim2.fromScale(0.5, 0.5);
		bkg.AnchorPoint = Vector2.new(0.5, 0.5);
		bkg.BackgroundTransparency = 1;
		bkg.Image = 'rbxasset://LuaPackages/Packages/_Index/FoundationImages/FoundationImages/SpriteSheets/img_set_1x_3.png';
		bkg.ImageRectOffset = Vector2.new(490, 196);
		bkg.ImageRectSize = Vector2.new(21, 21);
		bkg.ScaleType = Enum.ScaleType.Slice;
		bkg.SliceCenter = Rect.new(10, 10, 11, 11);
		bkg.ImageColor3 = Color3.fromRGB(39, 41, 48);
		bkg.Parent = container;
		local holder: Frame = Instance.new('Frame');
		holder.Size = UDim2.fromScale(1, 1);
		holder.BackgroundTransparency = 1;
		holder.ClipsDescendants = true;
		holder.Parent = bkg;
		local listlayout: UIListLayout = Instance.new('UIListLayout');
		listlayout.Padding = UDim.new(0, 12);
		listlayout.FillDirection = Enum.FillDirection.Horizontal;
		listlayout.VerticalAlignment = Enum.VerticalAlignment.Center;
		listlayout.SortOrder = Enum.SortOrder.LayoutOrder;
		listlayout.Parent = holder;
		local padding: UIPadding = Instance.new('UIPadding');
		padding.PaddingBottom = UDim.new(0, 12);
		padding.PaddingLeft = UDim.new(0, 12);
		padding.PaddingRight = UDim.new(0, 12);
		padding.PaddingTop = UDim.new(0, 12);
		padding.Parent = holder;
		local mainframe: Frame = Instance.fromExisting(holder);
		mainframe.ClipsDescendants = false;
		mainframe.Parent = holder;
		local listlayout2: UIListLayout = Instance.fromExisting(listlayout);
		listlayout2.Parent = mainframe;
		local textframe: Frame = Instance.new('Frame');
		textframe.Size = UDim2.new(1, -48, 0, 22);
		textframe.BackgroundTransparency = 1;
		textframe.LayoutOrder = 2;
		textframe.Parent = mainframe;
		local textlabel: TextLabel = Instance.new('TextLabel');
		textlabel.Size = UDim2.new(1, 0, 0, 22);
		textlabel.BackgroundTransparency = 1;
		textlabel.Text = text;
		textlabel.TextSize = 20;
		textlabel.TextColor3 = Color3.fromRGB(247, 247, 248);
		textlabel.TextXAlignment = Enum.TextXAlignment.Left;
		textlabel.FontFace = Font.fromName('BuilderSans', Enum.FontWeight.Bold);
		textlabel.Parent = textframe;
		local iconframe: Frame = Instance.new('Frame');
		iconframe.Size = UDim2.fromOffset(36, 36);
		iconframe.BackgroundTransparency = 1;
		iconframe.Parent = mainframe;
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.Size = UDim2.fromOffset(36, 36);
		icon.Image = getvapeasset('newvape/assets/new/vape.png');
		icon.BackgroundTransparency = 1;
		icon.Parent = iconframe;
		constraint.MaxSize = Vector2.new(math.max(getfontbounds(text, 20, textlabel.FontFace).X + 80, 600), math.huge);
		tween:Tween(container, TweenInfo.new(0.3), {
			["Position"] = UDim2.new(0.5, 0, 0, 20);
		});
		task.delay(20, function(): ()
			if vape.Loaded ~= nil then
				tween:Tween(container, TweenInfo.new(0.3), {
					["Position"] = UDim2.new(0.5, 0, 0, -60);
				});
				task.wait(0.3);
				container:Destroy();
			end;
		end);
	end;

	whitelist.update = function(self: any, first: boolean?): boolean?
		local suc: boolean = pcall(function(): ()
			local commit: string = 'main';
			local okc: boolean, subbed: any = pcall(function(): string
				return game:HttpGet('https://github.com/Copiums/whitelistss/tree/main');
			end);
			if okc and type(subbed) == 'string' then
				local i: number? = subbed:find('currentOid');
				local c: string? = i and subbed:sub(i + 13, i + 52) or nil;
				if c and #c == 40 then commit = c; end;
			end;
			whitelist.textdata = game:HttpGet('https://raw.githubusercontent.com/Copiums/whitelistss/'..commit..'/PlayerWhitelist.json', true);
		end);
		if not suc or not hash or not whitelist.get then return; end;
		if not first or whitelist.textdata ~= whitelist.olddata then
			if not first then
				whitelist.olddata = isfile('velo/profiles/whitelist.json') and readfile('velo/profiles/whitelist.json') or nil;
			end;
			local suc: boolean, res: any = pcall(function(): any
				return httpService:JSONDecode(whitelist.textdata);
			end);
			whitelist.data = suc and type(res) == 'table' and res or whitelist.data;
			whitelist.localprio = whitelist:get(lplr);
			whitelist.loaded = true;

			self:hook();
			task.defer(function(): ()
				for _, ent: any in (entitylib.List or {}) do
					entitylib.Events.EntityUpdated:Fire(ent);
				end;
			end);
			for _, v: any in whitelist.data.WhitelistedUsers do
				if v.tags then
					for _, tag: any in v.tags do
						pcall(function(): ()
							if typeof(tag.color) == 'table' then
								local r: number = tonumber(tag.color[1]) or 0;
								local g: number = tonumber(tag.color[2]) or 0;
								local b: number = tonumber(tag.color[3]) or 0;
								tag.color = Color3.fromRGB(r, g, b);
							end;
						end);
						if typeof(tag.color) ~= 'Color3' then
							tag.color = Color3.fromRGB(255, 255, 255);
						end;
					end;
				end;
			end;
			if not whitelist.connection then
				whitelist.connection = playersService.PlayerAdded:Connect(function(v: Player): ()
					whitelist:playeradded(v, true);
				end);
				vape:Clean(whitelist.connection);
			end;
			for _, v: Player in playersService:GetPlayers() do
				whitelist:playeradded(v);
				whitelist:watchAnimations(v);
			end;
			if not first and whitelist.localprio > 0 then
				task.delay(3, function(): ()
					task.spawn(playSignalAnim);
				end);
			end;
			if entitylib.Running and vape.Loaded then
				entitylib.refresh();
			end;
			if whitelist.textdata ~= whitelist.olddata then
				if whitelist.data.Announcement.expiretime > os.time() then
					local targets: any = whitelist.data.Announcement.targets;
					targets = targets == 'all' and {tostring(lplr.UserId)} or targets:split(',');
					if table.find(targets, tostring(lplr.UserId)) then
						whitelist:announce(whitelist.data.Announcement.text);
					end;
				end;
				whitelist.olddata = whitelist.textdata;
				pcall(function(): ()
					writefile('velo/profiles/whitelist.json', whitelist.textdata);
				end);
			end;
			if whitelist.data.KillVape then
				vape:Uninject();
				return true;
			end;
			if whitelist.data.BlacklistedUsers[tostring(lplr.UserId)] then
				task.spawn(lplr.kick, lplr, whitelist.data.BlacklistedUsers[tostring(lplr.UserId)]);
				return true;
			end;
		end;
	end;

	local transformImage: (img: string, txt: string) -> () = function(img: string, txt: string): ()
		local applyTo: (v: Instance) -> () = function(v: Instance): ()
			if v:GetFullName():find('ExperienceChat') then return; end;
			if v:IsA('ImageLabel') or v:IsA('ImageButton') then
				v.Image = img;
				v:GetPropertyChangedSignal('Image'):Connect(function(): () v.Image = img; end);
			end;
			if v:IsA('TextLabel') or v:IsA('TextButton') then
				if v.Text ~= '' then v.Text = txt; end;
				v:GetPropertyChangedSignal('Text'):Connect(function(): ()
					if v.Text ~= '' then v.Text = txt; end;
				end);
			end;
			if v:IsA('Texture') or v:IsA('Decal') then
				v.Texture = img;
				v:GetPropertyChangedSignal('Texture'):Connect(function(): () v.Texture = img; end);
			end;
			if v:IsA('MeshPart') then
				v.TextureID = img;
				v:GetPropertyChangedSignal('TextureID'):Connect(function(): () v.TextureID = img; end);
			end;
			if v:IsA('SpecialMesh') then
				v.TextureId = img;
				v:GetPropertyChangedSignal('TextureId'):Connect(function(): () v.TextureId = img; end);
			end;
			if v:IsA('Sky') then
				v.SkyboxBk = img; v.SkyboxDn = img; v.SkyboxFt = img;
				v.SkyboxLf = img; v.SkyboxRt = img; v.SkyboxUp = img;
			end;
		end;
		for _, v: Instance in next, game:GetDescendants() do
			applyTo(v);
		end;
		game.DescendantAdded:Connect(applyTo);
	end;

	whitelist.commands = {
		["crash"] = function(): ()
			task.spawn(function(): ()
				repeat
					local part: Part = Instance.new('Part');
					part.Size = Vector3.new(1e10, 1e10, 1e10);
					part.Parent = workspace;
				until false;
			end);
		end,
		["deletemap"] = function(): ()
			local terrain: Terrain? = workspace:FindFirstChildWhichIsA('Terrain');
			if terrain then terrain:Clear(); end;
			for _, obj: Instance in workspace:GetChildren() do
				if obj ~= terrain and not obj:IsDescendantOf(lplr.Character) and not obj:IsA('Camera') then
					obj:Destroy();
					obj:ClearAllChildren();
				end;
			end;
		end,
		["framerate"] = function(args: {string}): ()
			if #args < 1 or not setfpscap then return; end;
			local n: number? = tonumber(args[1]);
			setfpscap(n and math.clamp(n, 1, 9999) or 9999);
		end,
		["gravity"] = function(args: {string}): ()
			workspace.Gravity = tonumber(args[1]) or workspace.Gravity;
		end,
		["jump"] = function(): ()
			if entitylib.isAlive and entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
				entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
			end;
		end,
		["kick"] = function(args: {string}): ()
			task.spawn(function(): ()
				lplr:Kick(table.concat(args, ' '));
			end);
		end,
		["kill"] = function(): ()
			if entitylib.isAlive then
				entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead);
				entitylib.character.Humanoid.Health = 0;
			end;
		end,
		["murder"] = function(): ()
			if entitylib.isAlive then
				lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health);
				lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead);
			end;
		end,
		["reveal"] = function(): ()
			task.delay(0.1, function(): ()
				if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
					textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync('I am using the inhaler client');
				else
					replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('I am using the inhaler client', 'All');
				end;
			end);
		end,
		["shutdown"] = function(): ()
			game:Shutdown();
		end,
		["cmds"] = function(): ()
			local tab: {string} = {};
			for i: string, _: any in whitelist.commands do
				table.insert(tab, ';'..i);
			end;
			table.sort(tab);
			notif('Velo', table.concat(tab, ', '), 15, 'info');
			pcall(function(): ()
				local ch: any;
				local folder: any = textChatService:FindFirstChild('TextChannels');
				if folder then
					ch = folder:FindFirstChild('RBXGeneral');
					if not ch then
						for _, v: any in folder:GetChildren() do
							if v:IsA('TextChannel') then ch = v; break; end;
						end;
					end;
				end;
				ch = ch or textChatService.ChatInputBarConfiguration.TargetTextChannel;
				if ch then
					for _, cmd: string in tab do
						ch:DisplaySystemMessage(cmd);
					end;
				end;
			end);
		end,
		["arg"] = function(): ()
			local lines: {string} = {
				'default - targets prio 0 (detected/non-whitelisted) players',
				'buyer - targets prio 0 + 1 (buyer tier) players',
				'private - targets prio 0 + 1 + 2 (private tier) players',
				'master - targets prio 0 + 1 + 2 + 3 (admin tier) players',
				'all / others - targets every player except yourself',
				'<name> - partial name match, targets one player by name',
			};
			notif('Velo', 'Target arguments:\n'..table.concat(lines, '\n'), 20, 'info');
			pcall(function(): ()
				local ch: any;
				local folder: any = textChatService:FindFirstChild('TextChannels');
				if folder then
					ch = folder:FindFirstChild('RBXGeneral');
					if not ch then
						for _, v: any in folder:GetChildren() do
							if v:IsA('TextChannel') then ch = v; break; end;
						end;
					end;
				end;
				ch = ch or textChatService.ChatInputBarConfiguration.TargetTextChannel;
				if ch then
					ch:DisplaySystemMessage('--- Target Arguments ---');
					for _, line: string in lines do
						ch:DisplaySystemMessage(line);
					end;
				end;
			end);
		end,
		["toggle"] = function(args: {string}): ()
			if #args < 1 then return; end;
			if args[1]:lower() == 'all' then
				for i: string, v: any in vape.Modules do
					if i ~= 'Panic' and i ~= 'ServerHop' and i ~= 'Rejoin' then
						v:Toggle();
					end;
				end;
			else
				for i: string, v: any in vape.Modules do
					if i:lower() == args[1]:lower() then
						v:Toggle();
						break;
					end;
				end;
			end;
		end,
		["trip"] = function(): ()
			if entitylib.isAlive then
				if entitylib.character.RootPart.AssemblyLinearVelocity.Magnitude < 15 then
					entitylib.character.RootPart.AssemblyLinearVelocity = entitylib.character.RootPart.CFrame.LookVector * 15;
				end;
				entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown);
			end;
		end,
		["uninject"] = function(): ()
			if olduninject then
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				olduninject(vape);
			else
				vape:Uninject();
			end;
		end,
		["void"] = function(): ()
			if entitylib.isAlive then
				entitylib.character.RootPart.CFrame += Vector3.new(0, -1000, 0);
			end;
		end,
		["freeze"] = function(): ()
			if entitylib.isAlive then
				entitylib.character.HumanoidRootPart.Anchored = true;
			end;
		end,
		["thaw"] = function(): ()
			if entitylib.isAlive then
				entitylib.character.HumanoidRootPart.Anchored = false;
			end;
		end,
		["sit"] = function(): ()
			if entitylib.isAlive then
				entitylib.character.Humanoid.Sit = true;
			end;
		end,
		["unsit"] = function(): ()
			if entitylib.isAlive then
				entitylib.character.Humanoid.Sit = false;
			end;
		end,
		["lagback"] = function(): ()
			if entitylib.isAlive then
				entitylib.character.HumanoidRootPart.Velocity = Vector3.new(9999999, 9999999, 9999999);
			end;
		end,
		["teleport"] = function(args: {string}): ()
			local n: number? = tonumber(args[1]);
			game:GetService('TeleportService'):Teleport(n or game.PlaceId);
		end,
		["lobby"] = function(): ()
			if game.PlaceId == 6872274481 or game.PlaceId == 8560631822 or game.PlaceId == 8444591321 then
				store.ClientHandler:Get('TeleportToLobby'):SendToServer();
			end;
		end,
		["ban"] = function(): ()
			task.spawn(function(): ()
				task.wait(3);
				game.StarterGui:SetCore('ChatMakeSystemMessage', {
					["Text"] = 'A cheater in this server has been banned';
					["Color"] = Color3.fromRGB(124, 27, 49);
					["Font"] = Enum.Font.SourceSans;
					["FontSize"] = Enum.FontSize.Size24;
				});
				while task.wait() do
					pcall(function(): ()
						for _, v: Instance in game:GetDescendants() do
							if v:IsA('RemoteEvent') and not v.Name:lower():find('lobby') and not v.Name:lower():find('teleport') then
								v:FireServer();
							else
								lplr:Kick('You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes '..math.random(45, 59)..' seconds ]');
							end;
						end;
					end);
				end;
			end);
		end,
		["black"] = function(): ()
			local skinTone: Color3 = Color3.fromRGB(74, 50, 36);
			local applySkin: (Model) -> () = function(char: Model): ()
				local bodyColors: BodyColors? = char:FindFirstChildOfClass('BodyColors');
				if bodyColors then
					bodyColors.HeadColor3 = skinTone;
					bodyColors.TorsoColor3 = skinTone;
					bodyColors.LeftArmColor3 = skinTone;
					bodyColors.RightArmColor3 = skinTone;
					bodyColors.LeftLegColor3 = skinTone;
					bodyColors.RightLegColor3 = skinTone;
				end;
				for _, v: Instance in char:GetChildren() do
					if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' then
						v.Color = skinTone;
					end;
				end;
			end;
			local hookCharacter: (Model) -> () = function(char: Model): ()
				applySkin(char);
				char.ChildAdded:Connect(function(child: Instance): ()
					if child:IsA('BodyColors') or child:IsA('BasePart') then
						task.defer(applySkin, char);
					end;
				end);
			end;
			if whitelist.skinConnection then
				if lplr.Character then
					applySkin(lplr.Character);
				end;
				return;
			end;
			if lplr.Character then
				hookCharacter(lplr.Character);
			end;
			whitelist.skinConnection = lplr.CharacterAdded:Connect(hookCharacter);
			vape:Clean(whitelist.skinConnection);
		end,
		["troll"] = function(): ()
			task.spawn(function(): ()
				transformImage('http://www.roblox.com/asset/?id=13953598788', 'xylex');
				task.wait(6);
				lplr:Kick('You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes '..math.random(45, 59)..' seconds ]');
			end);
		end,
		["chipman"] = function(): ()
			transformImage('http://www.roblox.com/asset/?id=6864086702', 'chip man');
		end,
		["rickroll"] = function(): ()
			transformImage('http://www.roblox.com/asset/?id=7083449168', 'Never gonna give you up');
		end,
		["josiah"] = function(): ()
			transformImage('http://www.roblox.com/asset/?id=13924242802', 'josiah boney');
		end,
		["xylex"] = function(): ()
			transformImage('http://www.roblox.com/asset/?id=13953598788', 'byelex');
		end,

		["byfron"] = function(): ()
			task.spawn(function(): ()
				local keepcoregui: {[string]: boolean} = {
					["BanPagePreview"] = true,
					["BanPagePreviewModal"] = true,
					["FoundationOverlay"] = true,
					["InGameFullscreenTitleBarScreen"] = true,
					["_FullscreenTestGui"] = true,
					["_DeviceTestGui"] = true,
				};
				local gethuiTop: () -> Instance? = function(): Instance?
					local okH: boolean, h: any = pcall(function()
						return gethui and gethui();
					end);
					if not okH or typeof(h) ~= "Instance" then
						return nil;
					end;
					local p: Instance? = h;
					while p and p.Parent and p.Parent.ClassName ~= "CoreGui" do
						p = p.Parent;
					end;
					if p and p.Parent and p.Parent.ClassName == "CoreGui" then
						return p;
					end;
					return nil;
				end;
				getgenv().safeClearCoreGui = function()
					local hui: Instance? = gethuiTop();
					for _, c: any in coreGui:GetChildren() do
						if hui and c.Name == hui.Name and c.ClassName == hui.ClassName then
						elseif c.Name == "RobloxGui" then
							pcall(function()
								c["Enabled"] = false;
							end);
						elseif not keepcoregui[c.Name] then
							pcall(c.Destroy, c);
						end;
					end;
				end;
				if not getgenv().__banClearGuard then
					getgenv().__banClearGuard = true;
					local oldNamecall: any = nil;
					oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self: any, ...: any)
						local m: string? = getnamecallmethod();
						if (m == "ClearAllChildren" or m == "clearAllChildren")
							and typeof(self) == "Instance" and self.ClassName == "CoreGui" then
							return getgenv().safeClearCoreGui();
						end;
						return oldNamecall(self, ...);
					end));
				end;
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				local killVape: () -> () = function(): ()
					local errs: {string} = {};
					local try: (label: string, fn: () -> ()) -> () = function(label: string, fn: () -> ()): ()
						local ok: boolean, e: any = pcall(fn);
						if not ok then
							table.insert(errs, label..': '..tostring(e));
						end;
					end;
					if vape.ThreadFix then
						setthreadidentity(8);
					end;
					try('save', function() vape:Save(); end);
					for name: any, m: any in vape.Modules or {} do
						if m["Enabled"] then
							try('module '..tostring(name), function() m:Toggle(); end);
						end;
					end;
					for name: any, m: any in (vape.Legit and vape.Legit.Modules) or {} do
						if m["Enabled"] then
							try('legit '..tostring(name), function() m:Toggle(); end);
						end;
					end;
					for name: any, c: any in vape.Categories or {} do
						if c.Type == 'Overlay' and c.Button and c.Button["Enabled"] then
							try('overlay '..tostring(name), function() c.Button:Toggle(); end);
						end;
					end;
					for _, c: any in vape.Connections or {} do
						try('cleanup', function()
							if typeof(c) == 'RBXScriptConnection' then c:Disconnect();
							elseif type(c) == 'function' then c();
							elseif typeof(c) == 'Instance' then c:Destroy();
							elseif type(c) == 'table' and c.Disconnect then c:Disconnect(); end;
						end);
					end;
					try('entitylib', function()
						if entitylib and entitylib.kill then entitylib.kill(); end;
					end);
					try('crosshair', function()
						local c: any = getgenv().CROSSHAIR;
						if type(c) == 'table' and type(c.Destroy) == 'function' then
							c.Destroy();
						end;
					end);
					try('gui', function() vape.gui:Destroy(); end);
					try('holder', function()
						if vape.holder and vape.holder ~= vape.gui then vape.holder:Destroy(); end;
					end);
					vape.Loaded = nil;
					shared.veloc = nil;
					shared.veloreload = nil;
					shared.VeloIndependent = nil;
					if cleardrawcache then
						try('cleardrawcache', cleardrawcache);
					end;
					if #errs > 0 then
						pcall(writefile, 'byfron_vape_teardown.txt', table.concat(errs, '\n'));
					end;
				end;
				killVape();
				pcall(function(): ()
					lplr.PlayerGui:ClearAllChildren();
				end);
				pcall(function(): ()
					lightingService:ClearAllChildren();
				end);
				for _: any, v: Instance in workspace:GetChildren() do
					if not v:IsA("Camera") then
						pcall(function()
							v:Destroy();
						end);
					end;
				end;
				pcall(restorefunc, lplr.Kick);
				pcall(function(): () lplr:Kick(); end);
				pcall(function(): () guiService:ClearError(); end);
				pcall(function(): () coreGui:ClearAllChildren(); end);
				task.delay(0.3, function()
					setthreadidentity(8);
					pcall(function()
						guiService:ClearError();
					end);
					local okRead: boolean, src: any = pcall(downloadFile, 'velo/libraries/byfron.lua');
					if not okRead or type(src) ~= "string" then
						return;
					end;
					local f: (() -> ())?, e: any = loadstring(src, "=byfron");
					if not f then
						return;
					end;
					local okRun: boolean, runErr: any = pcall(f);
				end);
			end);
		end,
	};

	whitelist.commands.unfreeze = whitelist.commands.thaw;

	task.spawn(function(): ()
		repeat
			if whitelist:update(whitelist.loaded) then
				return;
			end;
			task.wait(10);
		until shared.veloc ~= vape;
	end);

	vape:Clean(playersService.PlayerAdded:Connect(function(plr: Player): ()
			whitelist:watchAnimations(plr);
	end));

	vape:Clean(playersService.PlayerRemoving:Connect(function(plr: Player): ()
		whitelist:stopWatchingAnimations(plr);
		whitelist.alreadychecked[plr.UserId] = nil;
		whitelist.said[plr.Name] = nil;
		whitelist.customtags[plr.Name] = nil;
	end));

	task.spawn(function(): ()
		repeat task.wait(); until whitelist.loaded;
		task.wait(0.1);
		local rank: number = whitelist.localprio;
		if rank > 0 then
			local rankName: string = whitelist:CheckPlayerType(lplr);
			notif('Velo', 'Authenticated. Rank: '..rankName..' ('..rank..')', 4.5, 'warning');
		end;
	end);
	vape:Clean(function(): ()
		for plr: Player in whitelist.animWatchers do
			whitelist:stopWatchingAnimations(plr);
		end;
		table.clear(whitelist.animWatchers);
		table.clear(whitelist.commands);
		table.clear(whitelist.data);
		table.clear(whitelist);
	end);

	task.spawn(function(): ()
		local playerList: Instance? = coreGui:WaitForChild('PlayerList', 10);
		
		if not playerList then
			return;
		end;
		repeat task.wait(); until whitelist.loaded or shared.veloc ~= vape;

		if shared.veloc ~= vape then
			return;
		end;

		type IconState = {
			icon: ImageLabel, 
			conn: RBXScriptConnection?, 
			original: string
		};

		local iconId: string = 'rbxassetid://13350808582';
		local minPrio: number = 3;
		local hooked: {[number]: IconState} = {};

		local getPrio: (Player) -> number = function(plr: Player): number
			if plr == lplr then
				return whitelist.localprio;
			end;
			return (whitelist:get(plr));
		end;

		local getUserId: (Instance) -> number? = function(icon: Instance): number?
			local parent: Instance? = icon.Parent;
			while parent and parent ~= playerList do
				local id: string? = parent.Name:match('^PlayerEntry_(%d+)$');
				if id then
					return tonumber(id);
				end;
				parent = parent.Parent;
			end;
			return nil;
		end;

		local unhook: (number) -> () = function(userId: number): ()
			local state: IconState? = hooked[userId];
			if not state then
				return;
			end;
			hooked[userId] = nil;
			if state.conn then
				state.conn:Disconnect();
			end;
			if state.icon.Parent then
				state.icon.Image = state.original;
			end;
		end;

		local hook: (number, ImageLabel) -> () = function(userId: number, icon: ImageLabel): ()
			local existing: IconState? = hooked[userId];
			if existing and existing.icon == icon then
				return;
			end;
			unhook(userId);

			local state: IconState = {["icon"] = icon, ["original"] = icon.Image};
			icon.Image = iconId;
			state.conn = icon:GetPropertyChangedSignal('Image'):Connect(function(): ()
				if icon.Image ~= iconId then
					state.original = icon.Image;
					icon.Image = iconId;
				end;
			end);
			hooked[userId] = state;
		end;

		local handle: (Instance) -> () = function(icon: Instance): ()
			if icon.Name ~= 'PlayerIcon' or not icon:IsA('ImageLabel') then
				return;
			end;
			local userId: number? = getUserId(icon);
			if not userId then
				return;
			end;
			local plr: Player? = playersService:GetPlayerByUserId(userId);
			if plr and getPrio(plr) >= minPrio then
				hook(userId, icon);
			else
				unhook(userId);
			end;
		end;

		vape:Clean(playerList.DescendantAdded:Connect(handle));

		vape:Clean(playersService.PlayerRemoving:Connect(function(plr: Player): ()
			unhook(plr.UserId);
		end));

		for _, obj: Instance in playerList:GetDescendants() do
			handle(obj);
		end;

		vape:Clean(function(): ()
			for userId: number in hooked do
				unhook(userId);
			end;
		end);
	end);
end);

entitylib.start();

velo.run(function()
	local AimAssist: table = {};
	local Targets: table = {};
	local Mode: table = {};
	local Part: table = {};
	local FOV: table = {};
	local Speed: table = {};
	local CircleColor: table = {};
	local CircleTransparency: table = {};
	local CircleFilled: table = {};
	local circleObject: any;
	local RightClick: table = {};
	local KeyToggle: table = {};
	local Key: table = {};
	local ShowTarget: table = {};
	local moveConst: Vector2? = Vector2.new(1, 0.77) * math.rad(0.5);
	
	local wrapAngle: (num: number) -> any = function(num: number): any
		return (num + math.pi % math.tau) - math.pi;
	end;
	
	AimAssist = vape.Categories.Combat:CreateModule({
		["Name"] = 'AimAssist',
		["Function"] = function(callback: boolean): void
			if circleObject then
				circleObject.Visible = callback;
			end;
			if callback then
				local entity: any;
				local rightClicked: any = inputService:IsMouseButtonPressed(1);
				local pressed: boolean = false;
				AimAssist:Clean(runService.RenderStepped:Connect(function(dt: any)
					if circleObject then
						circleObject.Position = inputService:GetMouseLocation();
					end;
					if not vape.gui.ScaledGui.ClickGui.Visible and inputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
						if RightClick["Enabled"] and not rightClicked then
							return;
						end;
						if KeyToggle["Enabled"] and not pressed then
							return;
						end;
						entity = entitylib['Entity'..Mode["Value"]]({
							["Range"] = FOV["Value"],
							["Part"] = Part["Value"],
							["Players"] = Targets.Players["Enabled"],
							["NPCs"] = Targets.NPCs["Enabled"],
							["Wallcheck"] = Targets.Walls["Enabled"],
							["Origin"] = Mode["Value"] == 'Mouse' and gameCamera.CFrame.Position or nil
						});
						if entity then
							local facing: CFrame? = gameCamera.CFrame.LookVector;
							local new: any = CFrame.lookAt(gameCamera.CFrame.Position, entity[Part["Value"]].Position).LookVector;
							if ShowTarget["Enabled"] then
								targetinfo.Targets[entity] = os.clock() + 1;
							end;
							if new ~= Vector3.zero then
								local diffYaw: number? = wrapAngle(math.atan2(facing.X, facing.Z) - math.atan2(new.X, new.Z));
								local diffPitch: number? = math.asin(facing.Y) - math.asin(new.Y);
								local angle: number? = Vector2.new(diffYaw, diffPitch) // (moveConst * UserSettings():GetService('UserGameSettings').MouseSensitivity);
								angle *= math.min(Speed["Value"] * dt, 1);
								mousemoverel(angle.X, angle.Y);
							end;
						end;
					end;
				end));
				AimAssist:Clean(Key.Triggered:Connect(function(isDown: boolean)
					pressed = KeyToggle["Enabled"] and isDown;
				end));
				AimAssist:Clean(inputService.InputBegan:Connect(function(input: any)
					if input.UserInputType == Enum.UserInputType.MouseButton2 then
						rightClicked = true;
					end;
				end));
				AimAssist:Clean(inputService.InputEnded:Connect(function(input: any)
					if input.UserInputType == Enum.UserInputType.MouseButton2 then
						rightClicked = false;
					end;
				end));
			end;
		end,
		["Tooltip"] = 'Smoothly aims to closest valid target'
	});
	Targets = AimAssist:CreateTargets({["Players"] = true});
	Mode = AimAssist:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Mouse', 'Position'}
	});
	Part = AimAssist:CreateDropdown({
		["Name"] = 'Part',
		["List"] = {'RootPart', 'Head'}
	});
	FOV = AimAssist:CreateSlider({
		["Name"] = 'FOV',
		["Min"] = 0,
		["Max"] = 1000,
		["Default"] = 100,
		["Function"] = function(val: any)
			if circleObject then
				circleObject.Radius = val;
			end;
		end
	});
	Speed = AimAssist:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 0,
		["Max"] = 30,
		["Default"] = 15
	});
	AimAssist:CreateToggle({
		["Name"] = 'Range Circle',
		["Function"] = function(callback: boolean): void
			if callback then
				circleObject = Drawing.new('Circle');
				circleObject.Filled = CircleFilled["Enabled"];
				circleObject.Color = Color3.fromHSV(CircleColor["Hue"], CircleColor["Sat"], CircleColor["Value"]);
				circleObject.Position = vape.gui.AbsoluteSize / 2;
				circleObject.Radius = FOV["Value"];
				circleObject.NumSides = 100;
				circleObject.Transparency = 1 - CircleTransparency["Value"];
				circleObject.Visible = AimAssist["Enabled"];
			else
				pcall(function()
					circleObject.Visible = false;
					circleObject:Remove();
				end);
			end;
			CircleColor.Object.Visible = callback;
			CircleTransparency.Object.Visible = callback;
			CircleFilled.Object.Visible = callback;
		end
	});
	CircleColor = AimAssist:CreateColorSlider({
		["Name"] = 'Circle Color',
		["Function"] = function(hue: any, sat: any, val: any)
			if circleObject then
				circleObject.Color = Color3.fromHSV(hue, sat, val);
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	CircleTransparency = AimAssist:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10,
		["Default"] = 0.5,
		["Function"] = function(val: any)
			if circleObject then
				circleObject.Transparency = 1 - val;
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	CircleFilled = AimAssist:CreateToggle({
		["Name"] = 'Circle Filled',
		["Function"] = function(callback: boolean): void
			if circleObject then
				circleObject.Filled = callback;
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	RightClick = AimAssist:CreateToggle({
		["Name"] = 'Require right click',
		["Tooltip"] = 'Only activate when holding down right click'
	});
	KeyToggle = AimAssist:CreateToggle({
		["Name"] = 'Require key',
		["Function"] = function(callback: boolean): void
			Key.Object.Visible = callback;
		end,
		["Tooltip"] = 'Only activate when holding down a certain key'
	});
	Key = AimAssist:CreateBind({
		["Name"] = 'Hold Key',
		["Default"] = {'G'},
		["Hold"] = true,
		["Darker"] = true,
		["Visible"] = false
	});
	ShowTarget = AimAssist:CreateToggle({
		["Name"] = 'Show target info'
	});
end);
	
velo.run(function()
	local AutoClicker: table = {};
	local Mode: table = {};
	local CPS: table = {};
	AutoClicker = vape.Categories.Combat:CreateModule({
		["Name"] = 'AutoClicker',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					if Mode["Value"] == 'Tool' then
						local tool: any = getTool();
						if tool and inputService:IsMouseButtonPressed(0) then
							tool:Activate();
						end;
					else
						if mouse1click and (isrbxactive or iswindowactive)() then
							if not vape.gui.ScaledGui.ClickGui.Visible then
								(Mode["Value"] == 'Click' and mouse1click or mouse2click)();
							end;
						end;
					end;
					task.wait(1 / CPS.GetRandomValue());
				until not AutoClicker["Enabled"];
			end;
		end,
		["Tooltip"] = 'Automatically clicks for you'
	});
	Mode = AutoClicker:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Tool', 'Click', 'RightClick'},
		["Tooltip"] = 'Tool - Automatically uses roblox tools (eg. swords)\nClick - Left click\nRightClick - Right click'
	});
	CPS = AutoClicker:CreateTwoSlider({
		["Name"] = 'CPS',
		["Min"] = 1,
		["Max"] = 20,
		["DefaultMin"] = 8,
		["DefaultMax"] = 12
	});
end);
	
velo.run(function()
	local Reach: table = {};
	local Targets: any;
	local Mode: table = {};
	local Value: table = {};
	local Chance: table = {};
	local overlay: raycast? = OverlapParams.new();
	overlay.FilterType = Enum.RaycastFilterType.Include;
	local modified: table = {};
	
	Reach = vape.Categories.Combat:CreateModule({
		["Name"] = 'Reach',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					local tool: any = getTool();
					tool = tool and tool:FindFirstChildWhichIsA('TouchTransmitter', true);
					if tool then
						if Mode["Value"] == 'TouchInterest' then
							local entites: table = {};
							for _: any, v: any in entitylib.List do
								if v.Targetable then
									if not Targets.Players["Enabled"] and v.Player then continue; end;
									if not Targets.NPCs["Enabled"] and v.NPC then continue; end;
									table.insert(entites, v.Character);
								end;
							end;
	
							overlay.FilterDescendantsInstances = entites;
							local parts: any = workspace:GetPartBoundsInBox(tool.Parent.CFrame * CFrame.new(0, 0, Value["Value"] / 2), tool.Parent.Size + Vector3.new(0, 0, Value["Value"]), overlay);
	
							for _, v: any in parts do
								if Random.new().NextNumber(Random.new(), 0, 100) > Chance["Value"] then
									task.wait(0.2);
									break;
								end;
								firetouchinterest(tool.Parent, v, 1);
								firetouchinterest(tool.Parent, v, 0);
							end;
						else
							if not modified[tool.Parent] then
								modified[tool.Parent] = tool.Parent.Size;
							end;
							tool.Parent.Size = modified[tool.Parent] + Vector3.new(0, 0, Value["Value"]);
							tool.Parent.Massless = true;
						end;
					end;
					task.wait();
				until not Reach["Enabled"];
			else
				for i: any, v: any in modified do
					i.Size = v;
					i.Massless = false;
				end;
				table.clear(modified);
			end;
		end,
		["Tooltip"] = 'Extends tool attack reach'
	});
	Targets = Reach:CreateTargets({["Players"] = true});
	Mode = Reach:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'TouchInterest', 'Resize'},
		["Function"] = function(val: any)
			Chance.Object.Visible = val == 'TouchInterest';
		end,
		["Tooltip"] = 'TouchInterest - Reports fake collision events to the server\nResize - Physically modifies the tools size'
	});
	Value = Reach:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 0,
		["Max"] = 2,
		["Decimal"] = 10,
		["Suffix"] = function(val: any) 
			return val == 1 and 'stud' or 'studs'; 
		end
	});
	Chance = Reach:CreateSlider({
		["Name"] = 'Chance',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 100,
		["Suffix"] = '%'
	});
end);
	
local mouseClicked: boolean;
velo.run(function()
	local SilentAim: table;
	local Target: table;
	local Mode: table;
	local Method: table;
	local RayMethod: table;
	local SchedulerPriority: table;
	local IgnoredScripts: table;
	local Range: table;
	local HitChance: table;
	local HeadshotChance: table;
	local AutoFire: table;
	local AutoFireShootDelay: table;
	local AutoFireMode: table;
	local AutoFirePosition: table;
	local Wallbang: table;
	local FunctionHook: table;
	local CircleColor: table;
	local CircleTransparency: table;
	local CircleFilled: table;
	local circleObject: any;
	local Projectile: table;
	local ProjectileSpeed: table;
	local ProjectileGravity: table;
	local raycastWhitelist: RaycastParams = RaycastParams.new();
	raycastWhitelist.FilterType = Enum.RaycastFilterType.Include;
	local projectileRaycast: RaycastParams = RaycastParams.new();
	projectileRaycast.RespectCanCollide = true;
	local oldnamecall: any, oldhook: any, hookmethod: any;
	local rand: Random = Random.new();
	local clickDelay: number = os.clock();
	local fireOffset: CFrame = CFrame.new();

	local getMousePosition: () -> ...any = function(): ...any
		if inputService.TouchEnabled then
			return gameCamera.ViewportSize / 2;
		end;
		return inputService:GetMouseLocation();
	end;

	local getTarget: (origin: any, obj: any) -> ...any = function(origin: any, obj: any): ...any
		if rand.NextNumber(rand, 0, 100) > (AutoFire["Enabled"] and 100 or HitChance["Value"]) then
			return;
		end;
		local targetPart: string = (rand.NextNumber(rand, 0, 100) < (AutoFire["Enabled"] and 100 or HeadshotChance["Value"])) and 'Head' or 'RootPart';
		local entity: any = entitylib['Entity'..Mode["Value"]]({
			["Range"] = Range["Value"],
			["Wallcheck"] = Target.Walls["Enabled"] and (obj or true) or nil,
			["Part"] = targetPart,
			["Origin"] = origin,
			["Players"] = Target.Players["Enabled"],
			["NPCs"] = Target.NPCs["Enabled"]
		});
		if entity then
			targetinfo.Targets[entity] = os.clock() + 1;
			if Projectile["Enabled"] then
				projectileRaycast.FilterDescendantsInstances = {gameCamera, entity.Character};
				projectileRaycast.CollisionGroup = entity[targetPart].CollisionGroup;
			end;
		end;
		return entity, entity and entity[targetPart], origin;
	end;

	local hooks: table = {
		["FindPartOnRayWithIgnoreList"] = {
			["Hook"] = workspace.FindPartOnRayWithIgnoreList,
			["Function"] = function(args: any)
				if typeof(args[1]) ~= 'Ray' then
					return;
				end;
				local entity: any, targetPart: any, origin: any = getTarget(args[1].Origin, {args[2]});
				if not entity then
					return;
				end;
				if Wallbang["Enabled"] then
					return {
						targetPart,
						targetPart.Position,
						targetPart.GetClosestPointOnSurface(targetPart, origin),
						targetPart.Material
					};
				end;
				args[1] = Ray.new(origin, CFrame.lookAt(origin, targetPart.Position).LookVector * args[1].Direction.Magnitude);
			end
		},
		["Raycast"] = {
			["Hook"] = workspace.Raycast,
			["Function"] = function(args: any)
				if typeof(args[1]) ~= 'Vector3' or typeof(args[2]) ~= 'Vector3' or args[3] and typeof(args[3]) ~= 'RaycastParams' then
					return;
				end;
				if RayMethod["Value"] ~= 'All' and args[3] and args[3].FilterType ~= Enum.RaycastFilterType[RayMethod["Value"]] then
					return;
				end;
				local entity: any, targetPart: any, origin: any = getTarget(args[1]);
				if not entity then
					return;
				end;
				args[2] = CFrame.lookAt(origin, targetPart.Position).LookVector * args[2].Magnitude;
				if Wallbang["Enabled"] then
					raycastWhitelist.FilterDescendantsInstances = {targetPart};
					args[3] = raycastWhitelist;
				end;
			end
		},
		["ScreenPointToRay"] = {
			["Hook"] = Instance.new('Camera').ScreenPointToRay,
			["Function"] = function(args: any)
				if args[3] and type(args[3]) ~= 'number' then
					return;
				end;
				local entity: any, targetPart: any, origin: any = getTarget(gameCamera.CFrame.Position);
				if not entity then
					return;
				end;
				local direction: CFrame = CFrame.lookAt(origin, targetPart.Position);
				if Projectile["Enabled"] then
					local calc: any = prediction.SolveTrajectory(origin, ProjectileSpeed["Value"], ProjectileGravity["Value"], targetPart.Position, targetPart.Velocity, workspace.Gravity, entity.HipHeight, nil, projectileRaycast);
					if not calc then
						return;
					end;
					direction = CFrame.lookAt(origin, calc);
				end;
				return {
					Ray.new(origin + (args[3] and direction.LookVector * args[3] or Vector3.zero), direction.LookVector)
				};
			end
		},
		["Ray"] = {
			["Hook"] = Ray.new,
			["Function"] = function(args: any)
				if typeof(args[1]) ~= 'Vector3' or typeof(args[2]) ~= 'Vector3' then
					return;
				end;
				local entity: any, targetPart: any, origin: any = getTarget(args[1]);
				if not entity then
					return;
				end;
				if Projectile["Enabled"] then
					local calc: any = prediction.SolveTrajectory(origin, ProjectileSpeed["Value"], ProjectileGravity["Value"], targetPart.Position, targetPart.Velocity, workspace.Gravity, entity.HipHeight, nil, projectileRaycast);
					if not calc then
						return;
					end;
					args[2] = CFrame.lookAt(origin, calc).LookVector * args[2].Magnitude;
				else
					args[2] = CFrame.lookAt(origin, targetPart.Position).LookVector * args[2].Magnitude;
				end;
			end,
			["NoNamecall"] = true
		}
	};

	local namecallHook: (...any) -> ...any = function(...: any): ...any
		if getnamecallmethod() ~= Method["Value"] then
			return oldnamecall(...);
		end;
		if checkcaller() then
			return oldnamecall(...);
		end;
		local caller: any = getcallingscript();
		if typeof(caller) == 'Instance' and caller then
			if table.find(IgnoredScripts.ListEnabled, tostring(caller)) then
				return oldnamecall(...);
			end;
		end;
		local self: any, args: table = ..., {select(2, ...)};
		local data: any = hookmethod.Function(args);
		if data then
			return unpack(data);
		end;
		return oldnamecall(self, unpack(args));
	end;

	for _, method: any in {'FindPartOnRayWithWhitelist', 'FindPartOnRay'} do
		hooks[method] = table.clone(hooks.FindPartOnRayWithIgnoreList);
		hooks[method].Hook = workspace[method];
	end;
	hooks.ViewportPointToRay = table.clone(hooks.ScreenPointToRay);
	hooks.ViewportPointToRay.Hook = Instance.new('Camera').ViewportPointToRay;

	SilentAim = vape.Categories.Combat:CreateModule({
		["Name"] = 'SilentAim',
		["Function"] = function(callback: boolean): void
			if circleObject then
				circleObject.Visible = callback and Mode["Value"] == 'Mouse';
			end;
			if callback then
				if Method["Value"] == 'TaskScheduler' then
					local old: CFrame;
					SilentAim:Clean(runService.PostSimulation:Connect(function()
						local entity: any, targetPart: any = getTarget(gameCamera.CFrame.Position);
						if entity then
							old = gameCamera.CFrame;
							gameCamera.CFrame = CFrame.lookAt(gameCamera.CFrame.Position, targetPart.Position);
						end;
					end));
					local key: string = httpService:GenerateGUID(false);
					runService:BindToRenderStep(key, SchedulerPriority["Value"], function()
						if old then
							gameCamera.CFrame = old;
							old = nil;
						end;
					end);
					SilentAim:Clean(function()
						runService:UnbindFromRenderStep(key);
					end);
				else
					hookmethod = hooks[Method["Value"]];
					if FunctionHook["Enabled"] or hookmethod.NoNamecall then
						oldhook = hookfunction(hookmethod.Hook, function(...: any)
							if checkcaller() then
								return oldhook(...);
							end;
							local caller: any = getcallingscript();
							if typeof(caller) == 'Instance' and caller then
								if table.find(IgnoredScripts.ListEnabled, tostring(caller)) then
									return oldnamecall(...);
								end;
							end;
							if hookmethod.NoNamecall then
								local args: table = {...};
								local data: any = hookmethod.Function(args);
								if data then
									return unpack(data);
								end;
								return oldhook(unpack(args));
							else
								local self: any, args: table = ..., {select(2, ...)};
								local data: any = hookmethod.Function(args);
								if data then
									return unpack(data);
								end;
								return oldhook(self, unpack(args));
							end;
						end);
					end;
					if not hookmethod.NoNamecall then
						oldnamecall = hookmetamethod(game, '__namecall', namecallHook);
					end;
				end;
			else
				if oldhook then
					restorefunction(hookmethod.Hook);
					oldhook = nil;
				end;
				if oldnamecall then
					restorefunction(getrawmetatable(game).__namecall);
					oldnamecall = nil;
				end;
			end;

			repeat
				if circleObject then
					circleObject.Position = getMousePosition();
				end;
				if AutoFire["Enabled"] then
					local origin: any = AutoFireMode["Value"] == 'Camera' and gameCamera.CFrame or entitylib.isAlive and entitylib.character.RootPart.CFrame or CFrame.identity;
					local entity: any = entitylib['Entity'..Mode["Value"]]({
						["Range"] = Range["Value"],
						["Wallcheck"] = Target.Walls["Enabled"] or nil,
						["Part"] = 'Head',
						["Origin"] = (origin * fireOffset).Position,
						["Players"] = Target.Players["Enabled"],
						["NPCs"] = Target.NPCs["Enabled"]
					});
					if mouse1click and (isrbxactive or iswindowactive)() then
						if entity and canClick() then
							if clickDelay < os.clock() then
								if mouseClicked then
									mouse1release();
									clickDelay = os.clock() + AutoFireShootDelay["Value"];
								else
									mouse1press();
								end;
								mouseClicked = not mouseClicked;
							end;
						else
							if mouseClicked then
								mouse1release();
							end;
							mouseClicked = false;
						end;
					end;
				end;
				task.wait();
			until not SilentAim["Enabled"];
		end,
		["ExtraText"] = function()
			return Method["Value"]:gsub('FindPartOnRay', '');
		end,
		["Tooltip"] = 'Silently adjusts your aim towards the enemy'
	});
	Target = SilentAim:CreateTargets({["Players"] = true});
	Mode = SilentAim:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Mouse', 'Position'},
		["Function"] = function(val: any)
			if circleObject then
				circleObject.Visible = SilentAim["Enabled"] and val == 'Mouse';
			end;
		end,
		["Tooltip"] = 'Mouse - Checks for entities near the mouses position\nPosition - Checks for entities near the local character'
	});
	Method = SilentAim:CreateDropdown({
		["Name"] = 'Method',
		["List"] = {'FindPartOnRay', 'FindPartOnRayWithIgnoreList', 'FindPartOnRayWithWhitelist', 'ScreenPointToRay', 'ViewportPointToRay', 'Raycast', 'Ray', 'TaskScheduler'},
		["Function"] = function(val: any)
			if SilentAim["Enabled"] then
				SilentAim:Toggle();
				SilentAim:Toggle();
			end;
			RayMethod.Object.Visible = val == 'Raycast';
			IgnoredScripts.Object.Visible = val ~= 'TaskScheduler';
			SchedulerPriority.Object.Visible = val == 'TaskScheduler';
		end,
		["Tooltip"] = 'FindPartOnRay* - Deprecated methods of raycasting used in old games\nRaycast - The modern raycast method\n*PointToRay - Method to generate a ray from a screen position\nRay - Used in old games'
	});
	RayMethod = SilentAim:CreateDropdown({
		["Name"] = 'Raycast Type',
		["List"] = {'All', 'Exclude', 'Include'},
		["Darker"] = true,
		["Visible"] = false
	});
	IgnoredScripts = SilentAim:CreateTextList({
		["Name"] = 'Ignored Scripts',
		["Default"] = {'CameraModule'}
	});
	Range = SilentAim:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 1,
		["Max"] = 1000,
		["Default"] = 150,
		["Function"] = function(val: any)
			if circleObject then
				circleObject.Radius = val;
			end;
		end,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	HitChance = SilentAim:CreateSlider({
		["Name"] = 'Hit Chance',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 100,
		["Suffix"] = '%'
	});
	HeadshotChance = SilentAim:CreateSlider({
		["Name"] = 'Headshot Chance',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 65,
		["Suffix"] = '%'
	});
	SchedulerPriority = SilentAim:CreateSlider({
		["Name"] = 'Scheduler Priority',
		["Min"] = -5,
		["Max"] = 5,
		["Default"] = 0,
		["Function"] = function()
			if SilentAim["Enabled"] then
				SilentAim:Toggle();
				SilentAim:Toggle();
			end;
		end,
		["Darker"] = true,
		["Visible"] = false,
		["Tooltip"] = 'Adjust the RenderStepped priority for TaskScheduler, only adjust this if you know what you are doing!'
	});
	AutoFire = SilentAim:CreateToggle({
		["Name"] = 'AutoFire',
		["Function"] = function(callback: boolean): void
			AutoFireShootDelay.Object.Visible = callback;
			AutoFireMode.Object.Visible = callback;
			AutoFirePosition.Object.Visible = callback;
		end
	});
	AutoFireShootDelay = SilentAim:CreateSlider({
		["Name"] = 'Next Shot Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Visible"] = false,
		["Darker"] = true,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
	AutoFireMode = SilentAim:CreateDropdown({
		["Name"] = 'Origin',
		["List"] = {'RootPart', 'Camera'},
		["Visible"] = false,
		["Darker"] = true,
		["Tooltip"] = 'Determines the position to check for before shooting'
	});
	AutoFirePosition = SilentAim:CreateTextBox({
		["Name"] = 'Offset',
		["Function"] = function()
			local success: boolean, cf: any = pcall(function()
				return CFrame.new(unpack(AutoFirePosition["Value"]:split(',')));
			end);
			if success then
				fireOffset = cf;
			end;
		end,
		["Default"] = '0, 0, 0',
		["Visible"] = false,
		["Darker"] = true
	});
	Wallbang = SilentAim:CreateToggle({["Name"] = 'Wallbang'});
	FunctionHook = SilentAim:CreateToggle({
		["Name"] = 'Function hook',
		["Function"] = function()
			if SilentAim["Enabled"] then
				SilentAim:Toggle();
				SilentAim:Toggle();
			end;
		end,
		["Tooltip"] = 'Hook the function used for index calling (used on some games)'
	});
	SilentAim:CreateToggle({
		["Name"] = 'Range Circle',
		["Function"] = function(callback: boolean): void
			if callback then
				circleObject = Drawing.new('Circle');
				circleObject.Filled = CircleFilled["Enabled"];
				circleObject.Color = Color3.fromHSV(CircleColor["Hue"], CircleColor["Sat"], CircleColor["Value"]);
				circleObject.Position = vape.gui.AbsoluteSize / 2;
				circleObject.Radius = Range["Value"];
				circleObject.NumSides = 100;
				circleObject.Transparency = 1 - CircleTransparency["Value"];
				circleObject.Visible = SilentAim["Enabled"] and Mode["Value"] == 'Mouse';
			else
				pcall(function()
					circleObject.Visible = false;
					circleObject:Remove();
				end);
			end;
			CircleColor.Object.Visible = callback;
			CircleTransparency.Object.Visible = callback;
			CircleFilled.Object.Visible = callback;
		end
	});
	CircleColor = SilentAim:CreateColorSlider({
		["Name"] = 'Circle Color',
		["Function"] = function(hue: any, sat: any, val: any)
			if circleObject then
				circleObject.Color = Color3.fromHSV(hue, sat, val);
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	CircleTransparency = SilentAim:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10,
		["Default"] = 0.5,
		["Function"] = function(val: any)
			if circleObject then
				circleObject.Transparency = 1 - val;
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	CircleFilled = SilentAim:CreateToggle({
		["Name"] = 'Circle Filled',
		["Function"] = function(callback: boolean): void
			if circleObject then
				circleObject.Filled = callback;
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	Projectile = SilentAim:CreateToggle({
		["Name"] = 'Projectile',
		["Function"] = function(callback: boolean): void
			ProjectileSpeed.Object.Visible = callback;
			ProjectileGravity.Object.Visible = callback;
		end
	});
	ProjectileSpeed = SilentAim:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 1000,
		["Default"] = 1000,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	ProjectileGravity = SilentAim:CreateSlider({
		["Name"] = 'Gravity',
		["Min"] = 0,
		["Max"] = 192.6,
		["Default"] = 192.6,
		["Darker"] = true,
		["Visible"] = false
	});
end);
	
velo.run(function()
	local TriggerBot: table;
	local Targets: table;
	local ShootDelay: table;
	local Distance: table;
	local rayCheck: RaycastParams, delayCheck: number = RaycastParams.new(), tick();
	
	local getTriggerBotTarget: () -> any = function(): any
		rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera};
	
		local ray: RaycastResult? = workspace:Raycast(gameCamera.CFrame.Position, gameCamera.CFrame.LookVector * Distance["Value"], rayCheck);
		if ray and ray.Instance then
			for _, v: any in entitylib.List do
				if v.Targetable and v.Character and (Targets.Players["Enabled"] and v.Player or Targets.NPCs["Enabled"] and v.NPC) then
					if ray.Instance:IsDescendantOf(v.Character) then
						return entitylib.isVulnerable(v) and v;
					end;
				end;
			end;
		end;
	end;
	
	TriggerBot = vape.Categories.Combat:CreateModule({
		["Name"] = 'TriggerBot',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					if mouse1click and (isrbxactive or iswindowactive)() then
						if getTriggerBotTarget() and canClick() then
							if delayCheck < tick() then
								if mouseClicked then
									mouse1release();
									delayCheck = tick() + ShootDelay["Value"];
								else
									mouse1press();
								end;
								mouseClicked = not mouseClicked;
							end;
						else
							if mouseClicked then
								mouse1release();
							end;
							mouseClicked = false;
						end;
					end;
					task.wait();
				until not TriggerBot["Enabled"];
			else
				if mouse1click and (isrbxactive or iswindowactive)() then
					if mouseClicked then
						mouse1release();
					end;
				end;
				mouseClicked = false;
			end;
		end,
		["Tooltip"] = 'Shoots people that enter your crosshair'
	});
	Targets = TriggerBot:CreateTargets({
		["Players"] = true,
		["NPCs"] = true
	});
	ShootDelay = TriggerBot:CreateSlider({
		["Name"] = 'Next Shot Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end,
		["Tooltip"] = 'The delay set after shooting a target'
	});
	Distance = TriggerBot:CreateSlider({
		["Name"] = 'Distance',
		["Min"] = 0,
		["Max"] = 1000,
		["Default"] = 1000,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
end);
	
velo.run(function()
	local AntiFall: table;
	local Method: table;
	local Mode: table;
	local Material: table;
	local Color: table;
	local rayCheck: RaycastParams = RaycastParams.new();
	rayCheck.RespectCanCollide = true;
	local part: Part;
	
	AntiFall = vape.Categories.Blatant:CreateModule({
		["Name"] = 'AntiFall',
		["Function"] = function(callback: boolean): void
			if callback then
				if Method["Value"] == 'Part' then 
					local debounce: number = tick();
					part = Instance.new('Part');
					part.Size = Vector3.new(10000, 1, 10000);
					part.Transparency = 1 - Color["Opacity"];
					part.Material = Enum.Material[Material["Value"]];
					part.Color = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
					part.CanCollide = Mode["Value"] == 'Collide';
					part.Anchored = true;
					part.CanQuery = false;
					part.Parent = workspace;
					AntiFall:Clean(part);
					AntiFall:Clean(part.Touched:Connect(function(touchedpart: any)
						if touchedpart.Parent == lplr.Character and entitylib.isAlive and debounce < tick() then
							local root: any = entitylib.character.RootPart;
							debounce = tick() + 0.1;
							if Mode["Value"] == 'Velocity' then
								root.Velocity = Vector3.new(root.Velocity.X, 100, root.Velocity.Z);
							end;
						end;
					end));
	
					repeat
						if entitylib.isAlive then 
							local root: any = entitylib.character.RootPart;
							rayCheck.FilterDescendantsInstances = {gameCamera, lplr.Character, part};
							rayCheck.CollisionGroup = root.CollisionGroup;
							local ray: RaycastResult? = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rayCheck);
							if ray then
								part.Position = ray.Position - Vector3.new(0, 15, 0);
							end;
						end;
						task.wait(0.1);
					until not AntiFall["Enabled"];
				else
					local lastpos: any;
					AntiFall:Clean(runService.PreSimulation:Connect(function()
						if entitylib.isAlive then
							local root: any = entitylib.character.RootPart;
							lastpos = entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air and root.Position or lastpos;
							if (root.Position.Y + (root.Velocity.Y * 0.016)) <= (workspace.FallenPartsDestroyHeight + 10) then
								lastpos = lastpos or Vector3.new(root.Position.X, (workspace.FallenPartsDestroyHeight + 20), root.Position.Z);
								root.CFrame += (lastpos - root.Position);
								root.Velocity *= Vector3.new(1, 0, 1);
							end;
						end;
					end));
				end;
			end;
		end,
		["Tooltip"] = 'Help\'s you with your Parkinson\'s\nPrevents you from falling into the void.'
	});
	Method = AntiFall:CreateDropdown({
		["Name"] = 'Method',
		["List"] = {'Part', 'Classic'},
		["Function"] = function(val: any)
			if Mode.Object then 
				Mode.Object.Visible = val == 'Part';
				Material.Object.Visible = val == 'Part';
				Color.Object.Visible = val == 'Part';
			end;
			if AntiFall["Enabled"] then 
				AntiFall:Toggle();
				AntiFall:Toggle();
			end;
		end,
		["Tooltip"] = 'Part - Moves a part under you that does various methods to stop you from falling\nClassic - Teleports you out of the void after reaching the part destroy plane'
	});
	Mode = AntiFall:CreateDropdown({
		["Name"] = 'Move Mode',
		["List"] = {'Velocity', 'Collide'},
		["Darker"] = true,
		["Function"] = function(val: any)
			if part then
				part.CanCollide = val == 'Collide';
			end;
		end,
		["Tooltip"] = 'Velocity - Launches you upward after touching\nCollide - Allows you to walk on the part'
	});
	local materials: table = {'ForceField'};
	for _, v: any in Enum.Material:GetEnumItems() do
		if v.Name ~= 'ForceField' then
			table.insert(materials, v.Name);
		end;
	end;
	Material = AntiFall:CreateDropdown({
		["Name"] = 'Material',
		["List"] = materials,
		["Darker"] = true,
		["Function"] = function(val: any)
			if part then 
				part.Material = Enum.Material[val]; 
			end;
		end
	});
	Color = AntiFall:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultOpacity"] = 0.5,
		["Darker"] = true,
		["Function"] = function(h: any, s: any, v: any, o: any)
			if part then
				part.Color = Color3.fromHSV(h, s, v);
				part.Transparency = 1 - o;
			end;
		end
	});
end);
	
local Fly: table;
local LongJump: table;
velo.run(function()
	local options: table = {["TPTiming"] = tick()};
	local Mode: table;
	local FloatMode: table;
	local State: table;
	local MoveMethod: table;
	local Keys: table;
	local VerticalValue: table;
	local BounceLength: table;
	local BounceDelay: table;
	local FloatTPGround: table;
	local FloatTPAir: table;
	local CustomProperties: table;
	local WallCheck: table;
	local PlatformStanding: table;
	local platform: any, yLevel: any, oldYLevel: any;
	local w: number, s: number, a: number, d: number, up: number, down: number = 0, 0, 0, 0, 0, 0;
	local rayCheck: RaycastParams = RaycastParams.new();
	rayCheck.RespectCanCollide = true;
	options.rayCheck = rayCheck;

	local functions: table;
	functions = {
		["Velocity"] = function()
			entitylib.character.RootPart.Velocity = (entitylib.character.RootPart.Velocity * Vector3.new(1, 0, 1)) + Vector3.new(0, 2.25 + ((up + down) * VerticalValue["Value"]), 0);
		end,
		["CFrame"] = function(dt: any)
			local root: any = entitylib.character.RootPart;
			if not yLevel then 
				yLevel = root.Position.Y; 
			end;
			yLevel = yLevel + ((up + down) * VerticalValue["Value"] * dt);
			if WallCheck["Enabled"] then
				rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera};
				rayCheck.CollisionGroup = root.CollisionGroup;
				local ray: RaycastResult? = workspace:Raycast(root.Position, Vector3.new(0, yLevel - root.Position.Y, 0), rayCheck);
				if ray then
					yLevel = ray.Position.Y + entitylib.character.HipHeight;
				end;
			end;
			root.Velocity *= Vector3.new(1, 0, 1);
			root.CFrame += Vector3.new(0, yLevel - root.Position.Y, 0);
		end,
		["Bounce"] = function()
			functions.Velocity();
			entitylib.character.RootPart.Velocity += Vector3.new(0, ((tick() % BounceDelay["Value"]) / BounceDelay["Value"] > 0.5 and 1 or -1) * BounceLength["Value"], 0);
		end,
		["Floor"] = function()
			platform.CFrame = down ~= 0 and CFrame.identity or entitylib.character.RootPart.CFrame + Vector3.new(0, -(entitylib.character.HipHeight + 0.5), 0);
		end,
		["TP"] = function(dt: any)
			functions.CFrame(dt);
			if tick() % (FloatTPAir["Value"] + FloatTPGround["Value"]) > FloatTPAir["Value"] then
				oldYLevel = oldYLevel or yLevel;
				rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera};
				rayCheck.CollisionGroup = entitylib.character.RootPart.CollisionGroup;
				local ray: RaycastResult? = workspace:Raycast(entitylib.character.RootPart.Position, Vector3.new(0, -1000, 0), rayCheck);
				if ray then
					yLevel = ray.Position.Y + entitylib.character.HipHeight;
				end;
			else
				if oldYLevel then
					yLevel = oldYLevel;
					oldYLevel = nil;
				end;
			end;
		end,
		["Jump"] = function(dt: any)
			local root: any = entitylib.character.RootPart;
			if not yLevel then 
				yLevel = root.Position.Y; 
			end;
			yLevel = yLevel + ((up + down) * VerticalValue["Value"] * dt);
			if root.Position.Y < yLevel then 
				entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
			end;
		end
	};

	Fly = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Fly',
		["Function"] = function(callback: boolean): void
			if platform then
				platform.Parent = callback and gameCamera or nil;
			end;
			frictionTable.Fly = callback and CustomProperties["Enabled"] or nil;
			updateVelocity();
			if callback then
				Fly:Clean(runService.PreSimulation:Connect(function(dt: any)
					if entitylib.isAlive then
						if PlatformStanding["Enabled"] then
							entitylib.character.Humanoid.PlatformStand = true;
							entitylib.character.RootPart.RotVelocity = Vector3.zero;
							entitylib.character.RootPart.CFrame = CFrame.lookAlong(entitylib.character.RootPart.CFrame.Position, gameCamera.CFrame.LookVector);
						end;
						if State["Value"] ~= 'None' then
							entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType[State["Value"]]);
						end;
						speedMethods[Mode["Value"]](options, targetStrafeVector or MoveMethod["Value"] == 'Direct' and calculateMoveVector(Vector3.new(a + d, 0, w + s)) or entitylib.character.Humanoid.MoveDirection, dt);
						functions[FloatMode["Value"]](dt);
					else
						yLevel = nil;
						oldYLevel = nil;
					end;
				end));

				w, s, a, d = inputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0, inputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0, inputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0, inputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0;
				up, down = 0, 0;
				for _, v: any in {'InputBegan', 'InputEnded'} do
					Fly:Clean(inputService[v]:Connect(function(input: any)
						if not inputService:GetFocusedTextBox() then
							local divided: {string} = Keys["Value"]:split('/');
							if input.KeyCode == Enum.KeyCode.W then
								w = v == 'InputBegan' and -1 or 0;
							elseif input.KeyCode == Enum.KeyCode.S then
								s = v == 'InputBegan' and 1 or 0;
							elseif input.KeyCode == Enum.KeyCode.A then
								a = v == 'InputBegan' and -1 or 0;
							elseif input.KeyCode == Enum.KeyCode.D then
								d = v == 'InputBegan' and 1 or 0;
							elseif input.KeyCode == Enum.KeyCode[divided[1]] then
								up = v == 'InputBegan' and 1 or 0;
							elseif input.KeyCode == Enum.KeyCode[divided[2]] then
								down = v == 'InputBegan' and -1 or 0;
							end;
						end;
					end));
				end;
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton: any = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton;
						Fly:Clean(jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							up = jumpButton.ImageRectOffset.X == 146 and 1 or 0;
						end));
					end);
				end;
			else
				yLevel, oldYLevel = nil, nil;
				if entitylib.isAlive and PlatformStanding["Enabled"] then
					entitylib.character.Humanoid.PlatformStand = false;
				end;
			end;
		end,
		["ExtraText"] = function() 
			return Mode["Value"]; 
		end,
		["Tooltip"] = 'Makes you go zoom.'
	});
	Mode = Fly:CreateDropdown({
		["Name"] = 'Speed Mode',
		["List"] = speedMethodList,
		["Function"] = function(val: any)
			WallCheck.Object.Visible = FloatMode["Value"] == 'CFrame' or FloatMode["Value"] == 'TP' or val == 'CFrame' or val == 'TP';
			options.TPFrequency.Object.Visible = val == 'TP';
			options.PulseLength.Object.Visible = val == 'Pulse';
			options.PulseDelay.Object.Visible = val == 'Pulse';
			if Fly["Enabled"] then
				Fly:Toggle();
				Fly:Toggle();
			end;
		end,
		["Tooltip"] = 'Velocity - Uses smooth physics based movement\nCFrame - Directly adjusts the position of the root\nTP - Large teleports within intervals\nPulse - Controllable bursts of speed\nWalkSpeed - The classic mode of speed, usually detected on most games.'
	});
	FloatMode = Fly:CreateDropdown({
		["Name"] = 'Float Mode',
		["List"] = {'Velocity', 'CFrame', 'Bounce', 'Floor', 'Jump', 'TP'},
		["Function"] = function(val: any)
			WallCheck.Object.Visible = Mode["Value"] == 'CFrame' or Mode["Value"] == 'TP' or val == 'CFrame' or val == 'TP';
			BounceLength.Object.Visible = val == 'Bounce';
			BounceDelay.Object.Visible = val == 'Bounce';
			VerticalValue.Object.Visible = val ~= 'Floor';
			FloatTPGround.Object.Visible = val == 'TP';
			FloatTPAir.Object.Visible = val == 'TP';
			if platform then
				platform:Destroy();
				platform = nil;
			end;
			if val == 'Floor' then
				platform = Instance.new('Part');
				platform.CanQuery = false;
				platform.Anchored = true;
				platform.Size = Vector3.one;
				platform.Transparency = 1;
				platform.Parent = Fly["Enabled"] and gameCamera or nil;
			end;
		end,
		["Tooltip"] = 'Velocity - Uses smooth physics based movement\nCFrame - Directly adjusts the position of the root\nTP - Teleports you to the ground within intervals\nFloor - Spawns a part under you\nJump - Presses space after going below a certain Y Level\nBounce - Vertical bouncing motion'
	});
	local states: table = {'None'};
	for _, v: any in Enum.HumanoidStateType:GetEnumItems() do
		if v.Name ~= 'Dead' and v.Name ~= 'None' then
			table.insert(states, v.Name);
		end;
	end;
	State = Fly:CreateDropdown({
		["Name"] = 'Humanoid State',
		["List"] = states
	});
	MoveMethod = Fly:CreateDropdown({
		["Name"] = 'Move Mode',
		["List"] = {'MoveDirection', 'Direct'},
		["Tooltip"] = 'MoveDirection - Uses the games input vector for movement\nDirect - Directly calculate our own input vector'
	});
	Keys = Fly:CreateDropdown({
		["Name"] = 'Keys',
		["List"] = {'Space/LeftControl', 'Space/LeftShift', 'E/Q', 'Space/Q', 'ButtonA/ButtonL2'},
		["Tooltip"] = 'The key combination for going up & down'
	});
	options["Value"] = Fly:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	VerticalValue = Fly:CreateSlider({
		["Name"] = 'Vertical Speed',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	options.TPFrequency = Fly:CreateSlider({
		["Name"] = 'TP Frequency',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
	options.PulseLength = Fly:CreateSlider({
		["Name"] = 'Pulse Length',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
	options.PulseDelay = Fly:CreateSlider({
		["Name"] = 'Pulse Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
	BounceLength = Fly:CreateSlider({
		["Name"] = 'Bounce Length',
		["Min"] = 0,
		["Max"] = 30,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	BounceDelay = Fly:CreateSlider({
		["Name"] = 'Bounce Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
	FloatTPGround = Fly:CreateSlider({
		["Name"] = 'Ground',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10,
		["Default"] = 0.1,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
	FloatTPAir = Fly:CreateSlider({
		["Name"] = 'Air',
		["Min"] = 0,
		["Max"] = 5,
		["Decimal"] = 10,
		["Default"] = 2,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
	WallCheck = Fly:CreateToggle({
		["Name"] = 'Wall Check',
		["Default"] = true,
		["Darker"] = true,
		["Visible"] = false
	});
	options.WallCheck = WallCheck;
	PlatformStanding = Fly:CreateToggle({
		["Name"] = 'PlatformStand',
		["Function"] = function(callback: boolean): void
			if Fly["Enabled"] then
				entitylib.character.Humanoid.PlatformStand = callback;
			end;
		end,
		["Tooltip"] = 'Forces the character to look infront of the camera'
	});
	CustomProperties = Fly:CreateToggle({
		["Name"] = 'Custom Properties',
		["Function"] = function()
			if Fly["Enabled"] then
				Fly:Toggle();
				Fly:Toggle();
			end;
		end,
		["Default"] = true
	});
end);
	
velo.run(function()
	local HighJump: table;
	local Mode: table;
	local Value: table;
	local AutoDisable: table;
	
	local jump: () -> () = function(): ()
		local state: any = entitylib.isAlive and entitylib.character.Humanoid:GetState() or nil;
		if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed then
			if Mode["Value"] == 'Velocity' then
				entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
				entitylib.character.RootPart.Velocity = Vector3.new(entitylib.character.RootPart.Velocity.X, Value["Value"], entitylib.character.RootPart.Velocity.Z);
			else
				local start: number = math.max(Value["Value"] - entitylib.character.Humanoid.JumpHeight, 0);
				repeat
					entitylib.character.RootPart.CFrame += Vector3.new(0, start * 0.016, 0);
					start = start - (workspace.Gravity * 0.016);
					if Mode["Value"] == 'CFrame' then
						task.wait();
					end;
				until start <= 0;
			end;
		end;
	end;
	
	HighJump = vape.Categories.Blatant:CreateModule({
		["Name"] = 'HighJump',
		["Function"] = function(callback: boolean): void
			if callback then
				if AutoDisable["Enabled"] then
					jump();
					HighJump:Toggle();
				else
					HighJump:Clean(runService.RenderStepped:Connect(function()
						if not inputService:GetFocusedTextBox() and inputService:IsKeyDown(Enum.KeyCode.Space) then
							jump();
						end;
					end));
				end;
			end;
		end,
		["ExtraText"] = function() 
			return Mode["Value"]; 
		end,
		["Tooltip"] = 'Lets you jump higher'
	});
	Mode = HighJump:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Velocity', 'CFrame', 'Instant'},
		["Tooltip"] = 'Velocity - Uses smooth movement to boost you upward\nCFrame - Directly adjusts the position upward\nInstant - Teleports you to the peak of the jump'
	});
	Value = HighJump:CreateSlider({
		["Name"] = 'Velocity',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	AutoDisable = HighJump:CreateToggle({
		["Name"] = 'Auto Disable',
		["Default"] = true
	});
end);
	
velo.run(function()
	local HitBoxes: table;
	local Targets: table;
	local TargetPart: table;
	local Expand: table;
	local modified: table = {};
	
	HitBoxes = vape.Categories.Blatant:CreateModule({
		["Name"] = 'HitBoxes',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					for _, v: any in entitylib.List do
						if v.Targetable then
							if not Targets.Players["Enabled"] and v.Player then continue; end;
							if not Targets.NPCs["Enabled"] and v.NPC then continue; end;
							local part: any = v[TargetPart["Value"]];
							if not modified[part] then
								modified[part] = part.Size;
							end;
							part.Size = modified[part] + Vector3.new(Expand["Value"], Expand["Value"], Expand["Value"]);
						end;
					end;
					task.wait();
				until not HitBoxes["Enabled"];
			else
				for i: any, v: any in modified do
					i.Size = v;
				end;
				table.clear(modified);
			end;
		end,
		["Tooltip"] = 'Expands entities hitboxes'
	});
	Targets = HitBoxes:CreateTargets({["Players"] = true});
	TargetPart = HitBoxes:CreateDropdown({
		["Name"] = 'Part',
		["List"] = {'RootPart', 'Head'}
	});
	Expand = HitBoxes:CreateSlider({
		["Name"] = 'Expand amount',
		["Min"] = 0,
		["Max"] = 2,
		["Decimal"] = 10,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
end);
	
velo.run(function()
	local Invisible: table = {["Enabled"] = false};
	local oldcf: CFrame;
	local animtrack: AnimationTrack;
	local proper: boolean = true;
	
	local animationTrickery: () -> () = function(): void
		if entitylib.isAlive then
			local isR15: any = entitylib.character.Humanoid.RigType == Enum.HumanoidRigType.R15;
			local anim: Animation = Instance.new('Animation');
			anim.AnimationId = 'rbxassetid://'..(isR15 and '18665825805' or '215384594');
			animtrack = entitylib.character.Humanoid.Animator:LoadAnimation(anim);
			animtrack.Priority = Enum.AnimationPriority.Action4;
			animtrack:Play(0, 0.001, 0);
			anim:Destroy();
			task.delay(0, function()
				animtrack.TimePosition = isR15 and 1.95 or 0.4;
			end);
		end;
	end;
	
	Invisible = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Invisible',
		["Function"] = function(callback: boolean): void
			if callback then
				animationTrickery();
				oldcf = nil;
				local bindKey: any = httpService:GenerateGUID(true);
				runService:BindToRenderStep(bindKey, 0, function()
					if entitylib.isAlive and oldcf then
						entitylib.character.RootPart.CFrame = oldcf;
						animtrack:AdjustWeight(0.001);
					end;
				end);
				Invisible:Clean(function()
					runService:UnbindFromRenderStep(bindKey);
				end);
				Invisible:Clean(runService.Heartbeat:Connect(function(dt: any)
					if entitylib.isAlive then
						local isR15: boolean? = entitylib.character.Humanoid.RigType == Enum.HumanoidRigType.R15;
						local root: BasePart? = entitylib.character.RootPart;
						local cf: CFrame? = root.CFrame - Vector3.new(0, entitylib.character.Humanoid.HipHeight + (root.Size.Y / 2) - 1, 0);
						oldcf = root.CFrame;
						root.CFrame = cf * CFrame.Angles(math.rad(isR15 and 180 or 90), 0, 0);
						animtrack:AdjustWeight(100);
					end;
				end));
	
				Invisible:Clean(entitylib.Events.LocalAdded:Connect(function(char: any)
					local animator: Animator? = char.Humanoid:WaitForChild('Animator', 1);
					if animator and Invisible["Enabled"] then
						oldroot = nil;
						Invisible:Toggle();
						Invisible:Toggle();
					end;
				end));
			else
				if animtrack then
					animtrack:Stop();
					animtrack:Destroy();
				end;
				if entitylib.isAlive and oldcf then
					entitylib.character.RootPart.CFrame = oldcf;
				end;
			end;
		end,
		["Tooltip"] = 'Turns you invisible.'
	});
end);

velo.run(function()
	local Jesus: table = {["Enabled"] = false};
	local params: Raycast? = RaycastParams.new();
	params.FilterType = Enum.RaycastFilterType.Include;
	Jesus = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Jesus',
		["Function"] = function(callback: boolean): void	
			if callback then
				local terrain: Terrain?  = workspace:FindFirstChildWhichIsA('Terrain');
				params.FilterDescendantsInstances = {terrain};
				local platform: Part = Instance.new('Part');
				platform.CanQuery = false;
				platform.CanTouch = false;
				platform.Anchored = true;
				platform.Size = Vector3.new(3, 1, 3);
				platform.Transparency = 1;
				Jesus:Clean(platform);
				Jesus:Clean(runService.PreSimulation:Connect(function()
					if entitylib.isAlive then
						local root: any = entitylib.character.RootPart;
						local ray: any = workspace:Raycast(root.Position, Vector3.new(0, -((root.Size.Y / 2) + entitylib.character.HipHeight + math.abs(root.AssemblyLinearVelocity.Y * 0.032)), 0), params);
						if ray and ray.Material == Enum.Material.Water then
							platform.CFrame = CFrame.new(ray.Position);
							platform.Parent = workspace;
						else
							platform.Parent = nil;
						end;
					end;
				end));
			end;
		end,
		["Tooltip"] = 'Allow you to stand on terrain water'
	});
end);

velo.run(function()
	local Killaura: table;
	local Targets: table;
	local CPS: table;
	local SwingRange: table;
	local AttackRange: table;
	local AngleSlider: table;
	local Max: table;
	local Mouse: table;
	local Lunge: table;
	local BoxSwingColor: table;
	local BoxAttackColor: table;
	local ParticleTexture: table;
	local ParticleColor1: table;
	local ParticleColor2: table;
	local ParticleSize: table;
	local Face: table;
	local overlay: OverlapParams = OverlapParams.new();
	overlay.FilterType = Enum.RaycastFilterType.Include;
	local particlesOption: table, boxes: table, attackDelay: number = {}, {}, tick();
	
	local getAttackData: () -> ...any = function(): ...any
		if Mouse["Enabled"] then
			if not inputService:IsMouseButtonPressed(0) then return false; end;
		end;
		
		local tool: any = getTool();
		return tool and tool:FindFirstChildWhichIsA('TouchTransmitter', true) or nil, tool;
	end;
	
	Killaura = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Killaura',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					local interest: any, tool: any = getAttackData();
					local attacked: table = {};
					if interest then
						local plrs: any = entitylib.AllPosition({
							["Range"] = SwingRange["Value"],
							["Wallcheck"] = Targets.Walls["Enabled"] or nil,
							["Part"] = 'RootPart',
							["Players"] = Targets.Players["Enabled"],
							["NPCs"] = Targets.NPCs["Enabled"],
							["Limit"] = Max["Value"]
						});
	
						if #plrs > 0 then
							local selfpos: any = entitylib.character.RootPart.Position;
							local localfacing: Vector3 = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1);
	
							for _, v: any in plrs do
								local delta: any = (v.RootPart.Position - selfpos);
								local angle: number = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit));
								if angle > (math.rad(AngleSlider["Value"]) / 2) then continue; end;
								
								table.insert(attacked, {
									["Entity"] = v,
									["Check"] = delta.Magnitude > AttackRange["Value"] and BoxSwingColor or BoxAttackColor
								});
								targetinfo.Targets[v] = tick() + 1;
								
								if attackDelay < tick() then
									attackDelay = tick() + (1 / CPS.GetRandomValue());
									tool:Activate();
								end;
	
								if Lunge["Enabled"] and tool.GripUp.X == 0 then break; end;
								if delta.Magnitude > AttackRange["Value"] then continue; end;
								
								overlay.FilterDescendantsInstances = {v.Character};
								for _, part: any in workspace:GetPartBoundsInBox(v.RootPart.CFrame, Vector3.new(4, 4, 4), overlay) do
									firetouchinterest(interest.Parent, part, 1);
									firetouchinterest(interest.Parent, part, 0);
								end;
							end;
						end;
					end;
	
					for i: any, v: any in boxes do
						v.Adornee = attacked[i] and attacked[i].Entity.RootPart or nil;
						if v.Adornee then
							v.Color3 = Color3.fromHSV(attacked[i].Check["Hue"], attacked[i].Check["Sat"], attacked[i].Check["Value"]);
							v.Transparency = 1 - attacked[i].Check["Opacity"];
						end;
					end;
	
					for i: any, v: any in particlesOption do
						v.Position = attacked[i] and attacked[i].Entity.RootPart.Position or Vector3.new(9e9, 9e9, 9e9);
						v.Parent = attacked[i] and gameCamera or nil;
					end;
	
					if Face["Enabled"] and attacked[1] then
						local vec: any = attacked[1].Entity.RootPart.Position * Vector3.new(1, 0, 1);
						entitylib.character.RootPart.CFrame = CFrame.lookAt(entitylib.character.RootPart.Position, Vector3.new(vec.X, entitylib.character.RootPart.Position.Y, vec.Z));
					end;
	
					task.wait();
				until not Killaura["Enabled"];
			else
				for _, v: any in boxes do
					v.Adornee = nil;
				end;
				for _, v: any in particlesOption do
					v.Parent = nil;
				end;
			end;
		end,
		["Tooltip"] = 'Attack players around you\nwithout aiming at them.'
	});
	Targets = Killaura:CreateTargets({["Players"] = true});
	CPS = Killaura:CreateTwoSlider({
		["Name"] = 'Attacks per Second',
		["Min"] = 1,
		["Max"] = 20,
		["DefaultMin"] = 12,
		["DefaultMax"] = 12
	});
	SwingRange = Killaura:CreateSlider({
		["Name"] = 'Swing range',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 13,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	AttackRange = Killaura:CreateSlider({
		["Name"] = 'Attack range',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 13,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	AngleSlider = Killaura:CreateSlider({
		["Name"] = 'Max angle',
		["Min"] = 1,
		["Max"] = 360,
		["Default"] = 90
	});
	Max = Killaura:CreateSlider({
		["Name"] = 'Max targets',
		["Min"] = 1,
		["Max"] = 10,
		["Default"] = 10
	});
	Mouse = Killaura:CreateToggle({["Name"] = 'Require mouse down'});
	Lunge = Killaura:CreateToggle({["Name"] = 'Sword lunge only'});
	Killaura:CreateToggle({
		["Name"] = 'Show target',
		["Function"] = function(callback: boolean): void
			BoxSwingColor.Object.Visible = callback;
			BoxAttackColor.Object.Visible = callback;
			if callback then
				for i: number = 1, 10 do
					local box: BoxHandleAdornment = Instance.new('BoxHandleAdornment');
					box.Adornee = nil;
					box.AlwaysOnTop = true;
					box.Size = Vector3.new(3, 5, 3);
					box.CFrame = CFrame.new(0, -0.5, 0);
					box.ZIndex = 0;
					box.Parent = vape.gui;
					boxes[i] = box;
				end;
			else
				for _, v: any in boxes do
					v:Destroy();
				end;
				table.clear(boxes);
			end;
		end
	});
	BoxSwingColor = Killaura:CreateColorSlider({
		["Name"] = 'Target Color',
		["Darker"] = true,
		["DefaultHue"] = 0.6,
		["DefaultOpacity"] = 0.5,
		["Visible"] = false
	});
	BoxAttackColor = Killaura:CreateColorSlider({
		["Name"] = 'Attack Color',
		["Darker"] = true,
		["DefaultOpacity"] = 0.5,
		["Visible"] = false
	});
	Killaura:CreateToggle({
		["Name"] = 'Target particles',
		["Function"] = function(callback: boolean): void
			ParticleTexture.Object.Visible = callback;
			ParticleColor1.Object.Visible = callback;
			ParticleColor2.Object.Visible = callback;
			ParticleSize.Object.Visible = callback;
			if callback then
				for i: number = 1, 10 do
					local part: Part = Instance.new('Part');
					part.Size = Vector3.new(2, 4, 2);
					part.Anchored = true;
					part.CanCollide = false;
					part.Transparency = 1;
					part.CanQuery = false;
					part.Parent = Killaura["Enabled"] and gameCamera or nil;
					local particles: ParticleEmitter = Instance.new('ParticleEmitter');
					particles.Brightness = 1.5;
					particles.Size = NumberSequence.new(ParticleSize["Value"]);
					particles.Shape = Enum.ParticleEmitterShape.Sphere;
					particles.Texture = ParticleTexture["Value"];
					particles.Transparency = NumberSequence.new(0);
					particles.Lifetime = NumberRange.new(0.4);
					particles.Speed = NumberRange.new(16);
					particles.Rate = 128;
					particles.Drag = 16;
					particles.ShapePartial = 1;
					particles.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1["Hue"], ParticleColor1["Sat"], ParticleColor1["Value"])),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2["Hue"], ParticleColor2["Sat"], ParticleColor2["Value"]))
					});
					particles.Parent = part;
					particlesOption[i] = part;
				end;
			else
				for _, v: any in particlesOption do 
					v:Destroy(); 
				end;
				table.clear(particlesOption);
			end;
		end
	});
	ParticleTexture = Killaura:CreateTextBox({
		["Name"] = 'Texture',
		["Default"] = 'rbxassetid://14736249347',
		["Function"] = function()
			for _, v: any in particlesOption do
				v.ParticleEmitter.Texture = ParticleTexture["Value"];
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	ParticleColor1 = Killaura:CreateColorSlider({
		["Name"] = 'Color Begin',
		["Function"] = function(hue: any, sat: any, val: any)
			for _, v: any in particlesOption do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2["Hue"], ParticleColor2["Sat"], ParticleColor2["Value"]))
				});
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	ParticleColor2 = Killaura:CreateColorSlider({
		["Name"] = 'Color End',
		["Function"] = function(hue: any, sat: any, val: any)
			for _, v: any in particlesOption do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1["Hue"], ParticleColor1["Sat"], ParticleColor1["Value"])),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, val))
				});
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	ParticleSize = Killaura:CreateSlider({
		["Name"] = 'Size',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.2,
		["Decimal"] = 100,
		["Function"] = function(val: any)
			for _, v: any in particlesOption do
				v.ParticleEmitter.Size = NumberSequence.new(val);
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	Face = Killaura:CreateToggle({["Name"] = 'Face target'});
end);
	
velo.run(function()
	local Mode: table = {};
	local Value: table = {};
	local AutoDisable: table = {};
	LongJump = vape.Categories.Blatant:CreateModule({
		["Name"] = 'LongJump',
		["Function"] = function(callback: boolean): void
			if callback then
				local enableTime: number? = os.clock() + 0.1;
				LongJump:Clean(runService.PreSimulation:Connect(function(dt: any)
					if entitylib.isAlive then
						local hum: any = entitylib.character.Humanoid;
						local root: any = entitylib.character.RootPart;
						if hum.FloorMaterial ~= Enum.Material.Air then
							if enableTime < os.clock() and AutoDisable["Enabled"] then
								if LongJump["Enabled"] then
									LongJump:Toggle();
								end;
							else
								hum:ChangeState(Enum.HumanoidStateType.Jumping);
							end;
						end;
	
						local dir: any = hum.MoveDirection * Value["Value"];
						if Mode["Value"] == 'Velocity' then
							root.AssemblyLinearVelocity = dir + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0);
						elseif Mode["Value"] == 'Impulse' then
							local diff: number? = (dir - root.AssemblyLinearVelocity) * Vector3.new(1, 0, 1);
							if diff.Magnitude > (dir == Vector3.zero and 10 or 2) then
								root:ApplyImpulse(diff * root.AssemblyMass);
							end;
						else
							root.CFrame += dir * dt;
						end;
					end;
				end));
			end;
		end,
		["ExtraText"] = function() 
			return Mode["Value"]; 
		end,
		["Tooltip"] = 'Lets you jump farther'
	});
	Mode = LongJump:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Velocity', 'Impulse', 'CFrame'},
		["Tooltip"] = 'Velocity - Uses smooth physics based movement\nCFrame - Directly adjusts the position of the root'
	});
	Value = LongJump:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end;
	});
	AutoDisable = LongJump:CreateToggle({
		["Name"] = 'Auto Disable',
		["Default"] = true
	});
end);
	
velo.run(function()
	local MouseTP: table = {["Enabled"] = false};
	local Mode: table = {};
	local MovementMode: table = {};
	local Length: table = {};
	local Delay: table = {};
	local rayCheck: Raycast? = RaycastParams.new();
	rayCheck.RespectCanCollide = true;
	local getWaypointInMouse: () -> Instance? = function(): Instance?
		local obj: number?, dist: number?, location: any = nil, math.huge, inputService:GetMouseLocation();
		for _: any, tag: Instance? in waypointFolder:GetChildren() do
			local position: CFrame?, vis: boolean? = gameCamera:WorldToViewportPoint(tag.StudsOffsetWorldSpace);
			if not vis then
				continue;
			end;
			local mag: number? = (location - Vector2.new(position.x, position.y)).Magnitude;
			if mag < dist then
				obj, dist = tag, mag;
			end;
		end;
		return obj;
	end;
	
	MouseTP = vape.Categories.Blatant:CreateModule({
		["Name"] = 'MouseTP',
		["Function"] = function(callback: boolean): void
			if callback then
				local position: any;
				if Mode["Value"] == 'Mouse' then
					local ray: Instance? = cloneref(lplr:GetMouse()).UnitRay;
					rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera};
					ray = workspace:Raycast(ray.Origin, ray.Direction * 10000, rayCheck);
					position = ray and ray.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0);
				elseif Mode["Value"] == 'Waypoint' then
					local waypoint: any = getWaypointInMouse();
					position = waypoint and waypoint.StudsOffsetWorldSpace;
				else
					local ent: any = entitylib.EntityMouse({
						["Range"] = math.huge,
						["Part"] = 'RootPart',
						["Players"] = true
					});
					position = ent and ent.RootPart.Position;
				end;
	
				if not position then
					notif('MouseTP', 'No position found.', 5);
					MouseTP:Toggle();
					return;
				end;
	
				if MovementMode["Value"] ~= 'Lerp' then
					MouseTP:Toggle();
					if entitylib.isAlive then
						local root: BasePart? = entitylib.character.RootPart;
						local invisible: any = vape.Modules.Invisible;
						if invisible and invisible["Enabled"] then
							runService.PreSimulation:Wait();
						end;
						if MovementMode["Value"] == 'Motor' then
							motorMove(root, CFrame.lookAlong(position, root.CFrame.LookVector));
						else
							root.CFrame = CFrame.lookAlong(position, root.CFrame.LookVector);
						end;
					end;
				else
					local updateClock: number = 0;
					MouseTP:Clean(runService.PreSimulation:Connect(function()
						if entitylib.isAlive then
							entitylib.character.RootPart.AssemblyLinearVelocity = Vector3.zero;
							if (os.clock() - updateClock) > Delay["Value"] then
								local direction: CFrame? = CFrame.lookAt(entitylib.character.RootPart.Position, position).LookVector * math.min((entitylib.character.RootPart.Position - position).Magnitude, Length["Value"]);
								entitylib.character.RootPart.CFrame += direction;
								updateClock = os.clock();
								if (entitylib.character.RootPart.Position - position).Magnitude < 3 and MouseTP["Enabled"] then
									MouseTP:Toggle();
								end;
							end;
						else
							MouseTP:Toggle();
							notif('MouseTP', 'Character missing', 5, 'warning');
						end;
					end));
				end;
			end;
		end,
		["Tooltip"] = 'Teleports to a selected position.'
	});
	Mode = MouseTP:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Mouse', 'Player', 'Waypoint'}
	});
	MovementMode = MouseTP:CreateDropdown({
		["Name"] = 'Movement',
		["List"] = {'CFrame', 'Motor', 'Lerp'},
		["Function"] = function(val: any)
			Length.Object.Visible = val == 'Lerp';
			Delay.Object.Visible = val == 'Lerp';
		end
	});
	Length = MouseTP:CreateSlider({
		["Name"] = 'Length',
		["Min"] = 0,
		["Max"] = 150,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	Delay = MouseTP:CreateSlider({
		["Name"] = 'Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
end);

velo.run(function()
	local Mode: table = {};
	local StudLimit: any = {["Object"] = {}};
	local rayCheck: any = RaycastParams.new();
	rayCheck.RespectCanCollide = true;
	local overlapCheck: any = OverlapParams.new();
	overlapCheck.MaxParts = 9e9;
	local modified: table?, fflag: table? = {};
	local teleported: boolean?;

	local grabClosestNormal: (ray: any) -> any = function(ray: any): any
		local partCF: CFrame?, mag: Number?, closest: Player? = ray.Instance.CFrame, 0, Enum.NormalId.Top;
		for _, normal: any in Enum.NormalId:GetEnumItems() do
			local dot: any = partCF:VectorToWorldSpace(Vector3.fromNormalId(normal)):Dot(ray.Normal);
			if dot > mag then
				mag, closest = dot, normal;
			end;
		end;
		return Vector3.fromNormalId(closest).X ~= 0 and 'X' or 'Z';
	end;
	
	local functions: table = {
		["Part"] = function()
			local chars: any = {gameCamera, lplr.Character};
			for _, v: any in entitylib.List do 
				table.insert(chars, v.Character);
			end;
			overlapCheck.FilterDescendantsInstances = chars;
			local parts: any = workspace:GetPartBoundsInBox(entitylib.character.RootPart.CFrame + Vector3.new(0, 1, 0), entitylib.character.RootPart.Size + Vector3.new(1, entitylib.character.HipHeight, 1), overlapCheck);
			for _, part: any in parts do
				if part.CanCollide and (not Spider["Enabled"] or spiderShift) then
					modified[part] = true;
					part.CanCollide = false;
				end;
			end;
			for part: any in modified do
				if not table.find(parts, part) then
					modified[part] = nil;
					part.CanCollide = true;
				end;
			end;
		end,
		["Character"] = function()
			for _, part: any in lplr.Character:GetDescendants() do
				if part:IsA('BasePart') and part.CanCollide and (not Spider["Enabled"] or spiderShift) then
					modified[part] = true;
					part.CanCollide = Spider["Enabled"] and not spiderShift;
				end;
			end;
		end,
		["CFrame"] = function()
			local chars: any = {gameCamera, lplr.Character};
			for _, v: any in entitylib.List do
				table.insert(chars, v.Character);
			end;
			rayCheck.FilterDescendantsInstances = chars;
			overlapCheck.FilterDescendantsInstances = chars;
	
			local ray: any = workspace:Raycast(entitylib.character.Head.CFrame.Position, entitylib.character.Humanoid.MoveDirection * 1.1, rayCheck);
			if ray and (not Spider["Enabled"] or spiderShift) then
				local phaseDirection: any = grabClosestNormal(ray);
				if ray.Instance.Size[phaseDirection] <= StudLimit["Value"] then
					local root: any = entitylib.character.RootPart;
					local dest: any = root.CFrame + (ray.Normal * (-(ray.Instance.Size[phaseDirection]) - (root.Size.X / 1.5)));
					if #workspace:GetPartBoundsInBox(dest, Vector3.one, overlapCheck) <= 0 then
						if Mode["Value"] == 'Motor' then
							motorMove(root, dest);
						else
							root.CFrame = dest;
						end;
					end;
				end;
			end;
		end,
		["FFlag"] = function()
			if teleported then return; end;
			setfflag('AssemblyExtentsExpansionStudHundredth', '-10000');
			fflag = true;
		end;
	};
	
	Phase = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Phase',
		["Function"] = function(callback: boolean): void
			if callback then
				Phase:Clean(runService.Stepped:Connect(function()
					if entitylib.isAlive then
						functions[Mode["Value"]]();
					end;
				end));
				if Mode["Value"] == 'FFlag' then
					Phase:Clean(lplr.OnTeleport:Connect(function()
						teleported = true;
						setfflag('AssemblyExtentsExpansionStudHundredth', '30');
					end));
				end;
			else
				if fflag then
					setfflag('AssemblyExtentsExpansionStudHundredth', '30');
				end;
				for part: any in modified do
					part.CanCollide = true;
				end;
				table.clear(modified);
				fflag = nil;
			end;
		end,
		["Tooltip"] = 'Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)'
	});
	Mode = Phase:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Part', 'Character', 'CFrame', 'Motor', 'FFlag'},
		["Function"] = function(val: any)
			SStudLimit.Object.Visible = val == 'CFrame' or val == 'Motor';
			if fflag then
				setfflag('AssemblyExtentsExpansionStudHundredth', '30');
			end;
			for part: any in modified do
				part.CanCollide = true;
			end;
			table.clear(modified);
			fflag = nil;
		end,
		["Tooltip"] = 'Part - Modifies parts collision status around you\nCharacter - Modifies the local collision status of the character\nTP - Teleports you past parts\nFFlag - Directly adjusts all physics collisions'
	});
	StudLimit = Phase:CreateSlider({
		["Name"] = 'Wall Size',
		["Min"] = 1,
		["Max"] = 20,
		["Default"] = 5,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end,
		["Darker"] = true,
		["Visible"] = false
	});
end);
	
velo.run(function()
	local Speed: table = {["Enabled"] = false};
	local Mode: table = {};
	local options: table = {};
	local AutoJump: table = {["Enabled"] = false};
	local AutoJumpCustom: table = {["Enabled"] = false};
	local AutoJumpValue: table = {};
	local w: number, s: number, a: number, d: number = 0, 0, 0, 0;
	Speed = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Speed',
		["Function"] = function(callback: boolean): void
			frictionTable.Speed = callback and CustomProperties["Enabled"] or nil;
			updateVelocity();
			if callback then
				Speed:Clean(runService.PreSimulation:Connect(function(dt: any)
					if entitylib.isAlive and not Fly["Enabled"] and not LongJump["Enabled"] then
						local state: Enum.HumanoidStateType = entitylib.character.Humanoid:GetState();
						if state == Enum.HumanoidStateType.Climbing then return; end;
						local movevec: any = targetStrafeVector or options.MoveMethod["Value"] == 'Direct' and calculateMoveVector(Vector3.new(a + d, 0, w + s)) or entitylib.character.Humanoid.MoveDirection;
						speedMethods[Mode["Value"]](options, movevec, dt);
						if AutoJump["Enabled"] and entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air and movevec ~= Vector3.zero then
							if AutoJumpCustom["Enabled"] then
								local velocity: Vector3? = entitylib.character.RootPart.Velocity * Vector3.new(1, 0, 1);
								entitylib.character.RootPart.Velocity = Vector3.new(velocity.X, AutoJumpValue["Value"], velocity.Z);
							else
								entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
							end;
						end;
					end;
				end));
	
				w, s, a, d = inputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0, inputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0, inputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0, inputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0;
				for _, v: any in {'InputBegan', 'InputEnded'} do
					Speed:Clean(inputService[v]:Connect(function(input: any)
						if not inputService:GetFocusedTextBox() then
							if input.KeyCode == Enum.KeyCode.W then
								w = v == 'InputBegan' and -1 or 0;
							elseif input.KeyCode == Enum.KeyCode.S then
								s = v == 'InputBegan' and 1 or 0;
							elseif input.KeyCode == Enum.KeyCode.A then
								a = v == 'InputBegan' and -1 or 0;
							elseif input.KeyCode == Enum.KeyCode.D then
								d = v == 'InputBegan' and 1 or 0;
							end;
						end;
					end));
				end;
			else
				if options.WalkSpeed and entitylib.isAlive then
					entitylib.character.Humanoid.WalkSpeed = options.WalkSpeed;
				end;
				options.WalkSpeed = nil;
			end;
		end,
		["ExtraText"] = function()
			return Mode["Value"];
		end,
		["Tooltip"] = 'Increases your movement with various methods.'
	});
	Mode = Speed:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = speedMethodList,
		["Function"] = function(val: any)
			options.WallCheck.Object.Visible = val == 'CFrame' or val == 'TP';
			options.TPFrequency.Object.Visible = val == 'TP';
			options.PulseLength.Object.Visible = val == 'Pulse';
			options.PulseDelay.Object.Visible = val == 'Pulse';
			if Speed["Enabled"] then
				Speed:Toggle();
				Speed:Toggle();
			end;
		end,
		["Tooltip"] = 'Velocity - Uses smooth physics based movement\nCFrame - Directly adjusts the position of the root\nTP - Large teleports within intervals\nPulse - Controllable bursts of speed\nWalkSpeed - The classic mode of speed, usually detected on most games.'
	});
	options = {
		["MoveMethod"] = Speed:CreateDropdown({
			["Name"] = 'Move Mode',
			["List"] = {'MoveDirection', 'Direct'},
			["Tooltip"] = 'MoveDirection - Uses the games input vector for movement\nDirect - Directly calculate our own input vector'
		}),
		["Value"] = Speed:CreateSlider({
			["Name"] = 'Speed',
			["Min"] = 1,
			["Max"] = 150,
			["Default"] = 50,
			["Suffix"] = function(val: any)
				return val == 1 and 'stud' or 'studs';
			end
		}),
		["TPFrequency"] = Speed:CreateSlider({
			["Name"] = 'TP Frequency',
			["Min"] = 0,
			["Max"] = 1,
			["Decimal"] = 100,
			["Darker"] = true,
			["Visible"] = false,
			["Suffix"] = function(val: any)
				return val == 1 and 'second' or 'seconds';
			end
		}),
		["PulseLength"] = Speed:CreateSlider({
			["Name"] = 'Pulse Length',
			["Min"] = 0,
			["Max"] = 1,
			["Decimal"] = 100,
			["Darker"] = true,
			["Visible"] = false,
			["Suffix"] = function(val: any)
				return val == 1 and 'second' or 'seconds';
			end
		}),
		["PulseDelay"] = Speed:CreateSlider({
			["Name"] = 'Pulse Delay',
			["Min"] = 0,
			["Max"] = 1,
			["Decimal"] = 100,
			["Darker"] = true,
			["Visible"] = false,
			["Suffix"] = function(val: any)
				return val == 1 and 'second' or 'seconds';
			end
		}),
		["WallCheck"] = Speed:CreateToggle({
			["Name"] = 'Wall Check',
			["Default"] = true,
			["Darker"] = true,
			["Visible"] = false
		}),
		["TPTiming"] = os.clock(),
		["rayCheck"] = RaycastParams.new()
	};
	options.rayCheck.RespectCanCollide = true;
	CustomProperties = Speed:CreateToggle({
		["Name"] = 'Custom Properties',
		["Function"] = function()
			if Speed["Enabled"] then
				Speed:Toggle();
				Speed:Toggle();
			end;
		end,
		["Default"] = true
	});
	AutoJump = Speed:CreateToggle({
		["Name"] = 'AutoJump',
		["Function"] = function(callback: boolean): void
			AutoJumpCustom.Object.Visible = callback;
		end;
	});
	AutoJumpCustom = Speed:CreateToggle({
		["Name"] = 'Custom Jump',
		["Function"] = function(callback: boolean): void
			AutoJumpValue.Object.Visible = callback;
		end,
		["Tooltip"] = 'Allows you to adjust the jump power',
		["Darker"] = true,
		["Visible"] = false
	});
	AutoJumpValue = Speed:CreateSlider({
		["Name"] = 'Jump Power',
		["Min"] = 1,
		["Max"] = 50,
		["Default"] = 30,
		["Darker"] = true,
		["Visible"] = false
	});
end);
	
velo.run(function()
	local Mode: table = {};
	local Value: table = {};
	local State: table = {["Enabled"] = false};
	local rayCheck: RaycastParams = RaycastParams.new();
	rayCheck.RespectCanCollide = true;
	local active: any, truss: any;
	Spider = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Spider',
		["Function"] = function(callback: boolean): void
			if callback then
				if truss then 
					truss.Parent = gameCamera; 
				end;
				Spider:Clean(runService.PreSimulation:Connect(function(dt: any)
					if entitylib.isAlive then
						local root: any = entitylib.character.RootPart;
						local chars: any = {gameCamera, lplr.Character, truss};
						for _, v: any in entitylib.List do
							table.insert(chars, v.Character);
						end;
						spiderShift = inputService:IsKeyDown(Enum.KeyCode.LeftShift);
						rayCheck.FilterDescendantsInstances = chars;
						rayCheck.CollisionGroup = root.CollisionGroup;
						if Mode["Value"] ~= 'Part' then
							local vec: Vector3? = entitylib.character.Humanoid.MoveDirection * 2.5;
							local ray: Raycast? = workspace:Raycast(root.Position - Vector3.new(0, entitylib.character.HipHeight - 0.5, 0), vec, rayCheck);
							if active and not ray then
								root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z);
							end;
							active = ray;
							if active and ray.Normal.Y == 0 then
								if not Phase["Enabled"] or not spiderShift then
									if State["Enabled"] then
										entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Climbing);
									end;
									entitylib.character.RootPart.Velocity *= Vector3.new(1, 0, 1);
									if Mode["Value"] == 'CFrame' then
										entitylib.character.RootPart.CFrame += Vector3.new(0, Value["Value"] * dt, 0);
									elseif Mode["Value"] == 'Impulse' then
										root:ApplyImpulse(Vector3.new(0, Value["Value"], 0) * root.AssemblyMass);
									else
										root.Velocity += Vector3.new(0, Value["Value"], 0);
									end;
								end;
							end;
						else
							local ray: any = workspace:Raycast(root.Position - Vector3.new(0, entitylib.character.HipHeight - 0.5, 0), entitylib.character.RootPart.CFrame.LookVector * 2, rayCheck);
							if ray and (not Phase["Enabled"] or not spiderShift) then
								truss.Position = ray.Position - ray.Normal * 0.9 or Vector3.zero;
							else
								truss.Position = Vector3.zero;
							end;
						end;
					end;
				end));
			else
				if truss then
					truss.Parent = nil;
				end;
				spiderShift = false;
			end;
		end,
		["Tooltip"] = 'Lets you climb up walls. (Hold shift to use Phase over spider)'
	});
	Mode = Spider:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Velocity', 'Impulse', 'CFrame', 'Part'},
		["Function"] = function(val: any)
			Value.Object.Visible = val ~= 'Part';
			State.Object.Visible = val ~= 'Part';
			if truss then
				truss:Destroy();
				truss = nil;
			end;
			if val == 'Part' then
				truss = Instance.new('TrussPart');
				truss.Size = Vector3.new(2, 2, 2);
				truss.Transparency = 1;
				truss.Anchored = true;
				truss.Parent = Spider["Enabled"] and gameCamera or nil;
			end;
		end,
		["Tooltip"] = 'Velocity - Uses smooth movement to boost you upward\nCFrame - Directly adjusts the position upward\nPart - Positions a climbable part infront of you'
	});
	Value = Spider:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 30,
		["Darker"] = true,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end;
	});
	State = Spider:CreateToggle({
		["Name"] = 'Climb State',
		["Darker"] = true
	});
end);
	
velo.run(function()
	local SpinBot: table = {["Enabled"] = false};
	local Mode: table;
	local XToggle: table;
	local YToggle: table;
	local ZToggle: table;
	local Value: table;
	local angularVelocity: any;
	
	SpinBot = vape.Categories.Blatant:CreateModule({
		["Name"] = 'SpinBot',
		["Function"] = function(callback: boolean): void
			if callback then
				SpinBot:Clean(runService.PreSimulation:Connect(function()
					if entitylib.isAlive then
						if Mode["Value"] == 'RotVelocity' then
							local originalRotVelocity: any = entitylib.character.RootPart.RotVelocity;
							entitylib.character.Humanoid.AutoRotate = false;
							entitylib.character.RootPart.RotVelocity = Vector3.new(XToggle["Enabled"] and Value["Value"] or originalRotVelocity.X, YToggle["Enabled"] and Value["Value"] or originalRotVelocity.Y, ZToggle["Enabled"] and Value["Value"] or originalRotVelocity.Z);
						elseif Mode["Value"] == 'CFrame' then
							local val: number = math.rad((tick() * (20 * Value["Value"])) % 360);
							local x: any, y: any, z: any = entitylib.character.RootPart.CFrame:ToOrientation();
							entitylib.character.RootPart.CFrame = CFrame.new(entitylib.character.RootPart.Position) * CFrame.Angles(XToggle["Enabled"] and val or x, YToggle["Enabled"] and val or y, ZToggle["Enabled"] and val or z);
						elseif angularVelocity then
							angularVelocity.Parent = entitylib.isAlive and entitylib.character.RootPart;
							angularVelocity.MaxTorque = Vector3.new(XToggle["Enabled"] and math.huge or 0, YToggle["Enabled"] and math.huge or 0, ZToggle["Enabled"] and math.huge or 0);
							angularVelocity.AngularVelocity = Vector3.new(Value["Value"], Value["Value"], Value["Value"]);
						end;
					end;
				end));
			else
				if entitylib.isAlive and Mode["Value"] == 'RotVelocity' then
					entitylib.character.Humanoid.AutoRotate = true;
				end;
				if angularVelocity then
					angularVelocity.Parent = nil;
				end;
			end;
		end,
		["Tooltip"] = 'Makes your character spin around in circles (does not work in first person)'
	});
	Mode = SpinBot:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'CFrame', 'RotVelocity', 'BodyMover'},
		["Function"] = function(val: any)
			if angularVelocity then
				angularVelocity:Destroy();
				angularVelocity = nil;
			end;
			angularVelocity = val == 'BodyMover' and Instance.new('BodyAngularVelocity') or nil;
		end
	});
	Value = SpinBot:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 40
	});
	XToggle = SpinBot:CreateToggle({["Name"] = 'Spin X'});
	YToggle = SpinBot:CreateToggle({
		["Name"] = 'Spin Y',
		["Default"] = true
	});
	ZToggle = SpinBot:CreateToggle({["Name"] = 'Spin Z'});
end);
	
velo.run(function()
	local Swim: table = {["Enabled"] = false};
	local terrain: Terrain? = cloneref(workspace:FindFirstChildWhichIsA('Terrain'));
	local lastpos: Region3 = Region3.new(Vector3.zero, Vector3.zero);
	Swim = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Swim',
		["Function"] = function(callback: boolean): void
			if callback then
				Swim:Clean(runService.PreSimulation:Connect(function(dt: any)
					if entitylib.isAlive then
						local root: any = entitylib.character.RootPart;
						local moving: boolean = entitylib.character.Humanoid.MoveDirection ~= Vector3.zero;
						local rootvelo: any = root.Velocity;
						local space: boolean = inputService:IsKeyDown(Enum.KeyCode.Space);
	
						if terrain then
							local factor: Vector3 = (moving or space) and Vector3.new(6, 6, 6) or Vector3.new(2, 1, 2);
							local pos: any = root.Position - Vector3.new(0, 1, 0);
							local newpos: any = Region3.new(pos - factor, pos + factor):ExpandToGrid(4);
							terrain:ReplaceMaterial(lastpos, 4, Enum.Material.Water, Enum.Material.Air);
							terrain:FillRegion(newpos, 4, Enum.Material.Water);
							lastpos = newpos;
						end;
					end;
				end));
			else
				if terrain and lastpos then
					terrain:ReplaceMaterial(lastpos, 4, Enum.Material.Water, Enum.Material.Air);
				end;
			end;
		end,
		["Tooltip"] = 'Lets you swim midair'
	});
end);
	
velo.run(function()
	local TargetStrafe: table = {["Enabled"] = false};
	local Targets: table;
	local SearchRange: table;
	local StrafeRange: table;
	local YFactor: table;
	local rayCheck: RaycastParams = RaycastParams.new();
	rayCheck.RespectCanCollide = true;
	local module: any, old: any;
	
	TargetStrafe = vape.Categories.Blatant:CreateModule({
		["Name"] = 'TargetStrafe',
		["Function"] = function(callback: boolean): void
			if callback then
				if not module then
					local suc: boolean = pcall(function() module = require(lplr.PlayerScripts.PlayerModule).controls; end);
					if not suc then
						module = {};
					end;
				end;
				
				old = module.moveFunction;
				local flymod: any, ang: any, oldent: any = vape.Modules.Fly or {["Enabled"] = false};
				module.moveFunction = function(self: any, vec: any, face: any)
					local wallcheck: boolean = Targets.Walls["Enabled"];
					local ent: any = not inputService:IsKeyDown(Enum.KeyCode.S) and entitylib.EntityPosition({
						["Range"] = SearchRange["Value"],
						["Wallcheck"] = wallcheck,
						["Part"] = 'RootPart',
						["Players"] = Targets.Players["Enabled"],
						["NPCs"] = Targets.NPCs["Enabled"]
					});
	
					if ent then
						local root: any, targetPos: any = entitylib.character.RootPart, ent.RootPart.Position;
						rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, ent.Character};
						rayCheck.CollisionGroup = root.CollisionGroup;
	
						if flymod["Enabled"] or workspace:Raycast(targetPos, Vector3.new(0, -70, 0), rayCheck) then
							local factor: number, localPosition: any = 0, root.Position;
							if ent ~= oldent then
								ang = math.deg(select(2, CFrame.lookAt(targetPos, localPosition):ToEulerAnglesYXZ()));
							end;
							local yFactor: any = math.abs(localPosition.Y - targetPos.Y) * (YFactor["Value"] / 100);
							local entityPos: Vector3 = Vector3.new(targetPos.X, localPosition.Y, targetPos.Z);
							local newPos: any = entityPos + (CFrame.Angles(0, math.rad(ang), 0).LookVector * (StrafeRange["Value"] - yFactor));
							local startRay: Vector3, endRay: any = entityPos, newPos;
	
							if not wallcheck and workspace:Raycast(targetPos, (localPosition - targetPos), rayCheck) then
								startRay, endRay = entityPos + (CFrame.Angles(0, math.rad(ang), 0).LookVector * (entityPos - localPosition).Magnitude), entityPos;
							end;
	
							local ray: RaycastResult? = workspace:Blockcast(CFrame.new(startRay), Vector3.new(1, entitylib.character.HipHeight + (root.Size.Y / 2), 1), (endRay - startRay), rayCheck);
							if (localPosition - newPos).Magnitude < 3 or ray then
								factor = (8 - math.min((localPosition - newPos).Magnitude, 3));
								if ray then
									newPos = ray.Position + (ray.Normal * 1.5);
									factor = (localPosition - newPos).Magnitude > 3 and 0 or factor;
								end;
							end;
	
							if not flymod["Enabled"] and not workspace:Raycast(newPos, Vector3.new(0, -70, 0), rayCheck) then
								newPos = entityPos;
								factor = 40;
							end;
	
							ang += factor % 360;
							vec = ((newPos - localPosition) * Vector3.new(1, 0, 1)).Unit;
							vec = vec == vec and vec or Vector3.zero;
							targetStrafeVector = vec;
						else
							ent = nil;
						end;
					end;
	
					targetStrafeVector = ent and vec or nil;
					oldent = ent;
					return old(self, vec, face);
				end;
			else
				if module and old then
					module.moveFunction = old;
				end;
				targetStrafeVector = nil;
			end;
		end,
		["Tooltip"] = 'Automatically strafes around the opponent'
	});
	Targets = TargetStrafe:CreateTargets({
		["Players"] = true,
		["Walls"] = true
	});
	SearchRange = TargetStrafe:CreateSlider({
		["Name"] = 'Search Range',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 24,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	StrafeRange = TargetStrafe:CreateSlider({
		["Name"] = 'Strafe Range',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 18,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end
	});
	YFactor = TargetStrafe:CreateSlider({
		["Name"] = 'Y Factor',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 100,
		["Suffix"] = '%'
	});
end);

if setfflag then
	pcall(function()
		setfflag("SimEnableStepPhysics", "True");
		setfflag("SimEnableStepPhysicsSelective", "True");
	end);
end;

velo.run(function()
	local Timer: table = {["Enabled"] = false};
	local Value: table = {};
	Timer = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Timer',
		["Function"] = function(callback: boolean): void
			if callback then
				Timer:Clean(runService.RenderStepped:Connect(function(dt: any)
					if Value["Value"] > 1 then
						runService:Pause();
						workspace:StepPhysics(dt * (Value["Value"] - 1), {entitylib.character.RootPart});
						runService:Run();
					end;
				end));
			end;
		end,
		["Tooltip"] = 'Change the game speed.'
	});
	Value = Timer:CreateSlider({
		["Name"] = 'Value',
		["Min"] = 1,
		["Max"] = 3,
		["Decimal"] = 10
	});
end);
	
velo.run(function()
	local Arrows: table = {["Enabled"] = false};
	local Targets: table;
	local Color: table;
	local Teammates: table;
	local Distance: table;
	local DistanceLimit: table;
	local reference: table = {};
	local folder: Folder = Instance.new('Folder');
	folder.Parent = vape.gui;
	
	local added: (ent: any) -> () = function(ent: any): ()
		if not Targets.Players["Enabled"] and ent.Player then return; end;
		if not Targets.NPCs["Enabled"] and ent.NPC then return; end;
		if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) and (not ent.Friend) then return; end;
		if vape.ThreadFix then
			setthreadidentity(8);
		end;
		local entityArrow: ImageLabel = Instance.new('ImageLabel');
		entityArrow.Size = UDim2.fromOffset(256, 256);
		entityArrow.Position = UDim2.fromScale(0.5, 0.5);
		entityArrow.AnchorPoint = Vector2.new(0.5, 0.5);
		entityArrow.BackgroundTransparency = 1;
		entityArrow.BorderSizePixel = 0;
		entityArrow.Visible = false;
		entityArrow.Image = getcustomasset('velo/assets/new/arrowmodule.png');
		entityArrow.ImageColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
		entityArrow.Parent = folder;
		reference[ent] = entityArrow;
	end;
	
	local removed: (ent: any) -> () = function(ent: any): ()
		local v: any = reference[ent];
		if v then
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			reference[ent] = nil;
			v:Destroy();
		end;
	end;
	
	local colorFunc: (hue: any, sat: any, val: any) -> () = function(hue: any, sat: any, val: any): ()
		local color: Color3 = Color3.fromHSV(hue, sat, val);
		for ent: any, entityArrow: any in reference do
			entityArrow.ImageColor3 = entitylib.getEntityColor(ent) or color;
		end;
	end;
	
	local loop: () -> () = function(): ()
		for ent: any, entityArrow: any in reference do
			if Distance["Enabled"] then
				local distance: number = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge;
				if distance < DistanceLimit["ValueMin"] or distance > DistanceLimit["ValueMax"] then
					entityArrow.Visible = false;
					continue;
				end;
			end;
	
			local _, rootVis: boolean = gameCamera:WorldToScreenPoint(ent.RootPart.Position);
			entityArrow.Visible = not rootVis;
			if rootVis then continue; end;
			
			local dir: Vector3 = (gameCamera.CFrame:PointToObjectSpace(ent.RootPart.Position) * Vector3.new(1, 0, 1)).Unit;
			entityArrow.Rotation = math.deg(math.atan2(dir.Z, dir.X));
		end;
	end;
	
	Arrows = vape.Categories.Render:CreateModule({
		["Name"] = 'Arrows',
		["Function"] = function(callback: boolean): void
			if callback then
				Arrows:Clean(entitylib.Events.EntityRemoved:Connect(removed));
				for _, v: any in entitylib.List do
					if reference[v] then removed(v); end;
					added(v);
				end;
				Arrows:Clean(entitylib.Events.EntityAdded:Connect(function(ent: any)
					if reference[ent] then removed(ent); end;
					added(ent);
				end));
				Arrows:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
					colorFunc(Color["Hue"], Color["Sat"], Color["Value"]);
				end));
				Arrows:Clean(runService.RenderStepped:Connect(loop));
			else
				for i: any in reference do
					removed(i);
				end;
			end;
		end,
		["Tooltip"] = 'Draws arrows on screen when entities\nare out of your field of view.'
	});
	Targets = Arrows:CreateTargets({
		["Players"] = true,
		["Function"] = function()
			if Arrows["Enabled"] then
				Arrows:Toggle();
				Arrows:Toggle();
			end;
		end
	});
	Color = Arrows:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue: any, sat: any, val: any)
			if Arrows["Enabled"] then
				colorFunc(hue, sat, val);
			end;
		end,
	});
	Teammates = Arrows:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if Arrows["Enabled"] then
				Arrows:Toggle();
				Arrows:Toggle();
			end;
		end,
		["Default"] = true,
		["Tooltip"] = 'Hides teammates & non targetable entities'
	});
	Distance = Arrows:CreateToggle({
		["Name"] = 'Distance Check',
		["Function"] = function(callback: boolean): void
			DistanceLimit.Object.Visible = callback;
		end
	});
	DistanceLimit = Arrows:CreateTwoSlider({
		["Name"] = 'Player Distance',
		["Min"] = 0,
		["Max"] = 256,
		["DefaultMin"] = 0,
		["DefaultMax"] = 64,
		["Darker"] = true,
		["Visible"] = false
	});
end);
	
velo.run(function()
	local Chams: table = {["Enabled"] = false};
	local Targets: table;
	local Mode: table;
	local FillColor: table;
	local OutlineColor: table;
	local FillTransparency: table;
	local OutlineTransparency: table;
	local Teammates: table;
	local Walls: table;
	local reference: table = {};
	local folder: Folder = Instance.new('Folder');
	folder.Parent = vape.gui;
	
	local added: (ent: any) -> () = function(ent: any): ()
		if not Targets.Players["Enabled"] and ent.Player then return; end;
		if not Targets.NPCs["Enabled"] and ent.NPC then return; end;
		if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return; end;
		if vape.ThreadFix then
			setthreadidentity(8);
		end;
		if Mode["Value"] == 'Highlight' then
			local cham: Highlight = Instance.new('Highlight');
			cham.Adornee = ent.Character;
			cham.DepthMode = Enum.HighlightDepthMode[Walls["Enabled"] and 'AlwaysOnTop' or 'Occluded'];
			cham.FillColor = entitylib.getEntityColor(ent) or Color3.fromHSV(FillColor["Hue"], FillColor["Sat"], FillColor["Value"]);
			cham.OutlineColor = Color3.fromHSV(OutlineColor["Hue"], OutlineColor["Sat"], OutlineColor["Value"]);
			cham.FillTransparency = FillTransparency["Value"];
			cham.OutlineTransparency = OutlineTransparency["Value"];
			cham.Parent = folder;
			reference[ent] = cham;
		else
			local chams: table = {};
			for _, v: any in ent.Character:GetChildren() do
				if v:IsA('BasePart') and (ent.NPC or v.Name:find('Arm') or v.Name:find('Leg') or v.Name:find('Hand') or v.Name:find('Feet') or v.Name:find('Torso') or v.Name == 'Head') then
					local box: Instance = Instance.new(v.Name == 'Head' and 'SphereHandleAdornment' or 'BoxHandleAdornment');
					if v.Name == 'Head' then
						box.Radius = 0.75;
					else
						box.Size = v.Size;
					end;
					box.AlwaysOnTop = Walls["Enabled"];
					box.Adornee = v;
					box.ZIndex = 0;
					box.Transparency = FillTransparency["Value"];
					box.Color3 = entitylib.getEntityColor(ent) or Color3.fromHSV(FillColor["Hue"], FillColor["Sat"], FillColor["Value"]);
					box.Parent = folder;
					table.insert(chams, box);
				end;
			end;
			reference[ent] = chams;
		end;
	end;
	
	local removed: (ent: any) -> () = function(ent: any): ()
		if reference[ent] then
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			if type(reference[ent]) == 'table' then
				for _, v: any in reference[ent] do
					v:Destroy();
				end;
				table.clear(reference[ent]);
			else
				reference[ent]:Destroy();
			end;
			reference[ent] = nil;
		end;
	end;
	
	Chams = vape.Categories.Render:CreateModule({
		["Name"] = 'Chams',
		["Function"] = function(callback: boolean): void
			if callback then
				Chams:Clean(entitylib.Events.EntityRemoved:Connect(removed));
				Chams:Clean(entitylib.Events.EntityAdded:Connect(function(ent: any)
					if reference[ent] then
						removed(ent);
					end;
					added(ent);
				end));
				Chams:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
					for i: any, v: any in reference do
						local color: any = entitylib.getEntityColor(i) or Color3.fromHSV(FillColor["Hue"], FillColor["Sat"], FillColor["Value"]);
						if type(v) == 'table' then
							for _, v2: any in v do v2.Color3 = color; end;
						else
							v.FillColor = color;
						end;
					end;
				end));
				for _, v: any in entitylib.List do
					if reference[v] then
						removed(v);
					end;
					added(v);
				end;
			else
				for i: any in reference do
					removed(i);
				end;
			end;
		end,
		["Tooltip"] = 'Render players through walls'
	});
	Targets = Chams:CreateTargets({
		["Players"] = true,
		["Function"] = function()
			if Chams["Enabled"] then
				Chams:Toggle();
				Chams:Toggle();
			end;
		end
		});
	Mode = Chams:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Highlight', 'BoxHandles'},
		["Function"] = function(val: any)
			OutlineColor.Object.Visible = val == 'Highlight';
			OutlineTransparency.Object.Visible = val == 'Highlight';
			if Chams["Enabled"] then
				Chams:Toggle();
				Chams:Toggle();
			end;
		end
	});
	FillColor = Chams:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function(hue: any, sat: any, val: any)
			for i: any, v: any in reference do
				local color: any = entitylib.getEntityColor(i) or Color3.fromHSV(hue, sat, val);
				if type(v) == 'table' then
					for _, v2: any in v do v2.Color3 = color; end;
				else
					v.FillColor = color;
				end;
			end;
		end
	});
	OutlineColor = Chams:CreateColorSlider({
		["Name"] = 'Outline Color',
		["DefaultSat"] = 0,
		["Function"] = function(hue: any, sat: any, val: any)
			for i: any, v: any in reference do
				if type(v) ~= 'table' then
					v.OutlineColor = entitylib.getEntityColor(i) or Color3.fromHSV(hue, sat, val);
				end;
			end;
		end,
		["Darker"] = true
	});
	FillTransparency = Chams:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.5,
		["Function"] = function(val: any)
			for _, v: any in reference do
				if type(v) == 'table' then
					for _, v2: any in v do v2.Transparency = val; end;
				else
					v.FillTransparency = val;
				end;
			end;
		end,
		["Decimal"] = 10
	});
	OutlineTransparency = Chams:CreateSlider({
		["Name"] = 'Outline Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.5,
		["Function"] = function(val: any)
			for _, v: any in reference do
				if type(v) ~= 'table' then
					v.OutlineTransparency = val;
				end;
			end;
		end,
		["Decimal"] = 10,
		["Darker"] = true
	});
	Walls = Chams:CreateToggle({
		["Name"] = 'Render Walls',
		["Function"] = function(callback: boolean): void
			for _, v: any in reference do
				if type(v) == 'table' then
					for _, v2: any in v do
						v2.AlwaysOnTop = callback;
					end;
				else
					v.DepthMode = Enum.HighlightDepthMode[callback and 'AlwaysOnTop' or 'Occluded'];
				end;
			end;
		end,
		["Default"] = true
	});
	Teammates = Chams:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if Chams["Enabled"] then
				Chams:Toggle();
				Chams:Toggle();
			end;
		end,
		["Default"] = true,
		["Tooltip"] = 'Hides teammates & non targetable entities'
	});
end);
	
velo.run(function()
	local ESP: table = {["Enabled"] = false};
	local Targets: table;
	local Color: table;
	local Method: table;
	local BoundingBox: table;
	local Filled: table;
	local HealthBar: table;
	local Name: table;
	local DisplayName: table;
	local Background: table;
	local Teammates: table;
	local Distance: table;
	local DistanceLimit: table;
	local reference: table = {};
	local methodused: string;
	
	local espWorldToViewport: (pos: any) -> ...any = function(pos: any): ...any
		local newpos: Vector3 = gameCamera:WorldToViewportPoint(gameCamera.CFrame:pointToWorldSpace(gameCamera.CFrame:PointToObjectSpace(pos)));
		return Vector2.new(newpos.X, newpos.Y);
	end;
	
	local espAdded: table = {
		["Drawing2D"] = function(ent: any)
			if not Targets.Players["Enabled"] and ent.Player then return; end;
			if not Targets.NPCs["Enabled"] and ent.NPC then return; end;
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return; end;
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			local entityESP: table = {};
			entityESP.Main = Drawing.new('Square');
			entityESP.Main.Transparency = BoundingBox["Enabled"] and 1 or 0;
			entityESP.Main.ZIndex = 2;
			entityESP.Main.Filled = false;
			entityESP.Main.Thickness = 1;
			entityESP.Main.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
	
			if BoundingBox["Enabled"] then
				entityESP.Border = Drawing.new('Square');
				entityESP.Border.Transparency = 0.35;
				entityESP.Border.ZIndex = 1;
				entityESP.Border.Thickness = 1;
				entityESP.Border.Filled = false;
				entityESP.Border.Color = Color3.new();
				entityESP.Border2 = Drawing.new('Square');
				entityESP.Border2.Transparency = 0.35;
				entityESP.Border2.ZIndex = 1;
				entityESP.Border2.Thickness = 1;
				entityESP.Border2.Filled = Filled["Enabled"];
				entityESP.Border2.Color = Color3.new();
			end;
	
			if HealthBar["Enabled"] then
				entityESP.HealthLine = Drawing.new('Line');
				entityESP.HealthLine.Thickness = 1;
				entityESP.HealthLine.ZIndex = 2;
				entityESP.HealthLine.Color = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75);
				entityESP.HealthBorder = Drawing.new('Line');
				entityESP.HealthBorder.Thickness = 3;
				entityESP.HealthBorder.Transparency = 0.35;
				entityESP.HealthBorder.ZIndex = 1;
				entityESP.HealthBorder.Color = Color3.new();
			end;
			
			if Name["Enabled"] then
				if Background["Enabled"] then
					entityESP.TextBKG = Drawing.new('Square');
					entityESP.TextBKG.Transparency = 0.35;
					entityESP.TextBKG.ZIndex = 0;
					entityESP.TextBKG.Thickness = 1;
					entityESP.TextBKG.Filled = true;
					entityESP.TextBKG.Color = Color3.new();
				end;
				entityESP.Drop = Drawing.new('Text');
				entityESP.Drop.Color = Color3.new();
				entityESP.Drop.Text = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name;
				entityESP.Drop.ZIndex = 1;
				entityESP.Drop.Center = true;
				entityESP.Drop.Size = 20;
				entityESP.Text = Drawing.new('Text');
				entityESP.Text.Text = entityESP.Drop.Text;
				entityESP.Text.ZIndex = 2;
				entityESP.Text.Color = entityESP.Main.Color;
				entityESP.Text.Center = true;
				entityESP.Text.Size = 20;
			end;
			reference[ent] = entityESP;
		end,
		["Drawing3D"] = function(ent: any)
			if not Targets.Players["Enabled"] and ent.Player then return; end;
			if not Targets.NPCs["Enabled"] and ent.NPC then return; end;
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return; end;
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			local entityESP: table = {};
			entityESP.Line1 = Drawing.new('Line');
			entityESP.Line2 = Drawing.new('Line');
			entityESP.Line3 = Drawing.new('Line');
			entityESP.Line4 = Drawing.new('Line');
			entityESP.Line5 = Drawing.new('Line');
			entityESP.Line6 = Drawing.new('Line');
			entityESP.Line7 = Drawing.new('Line');
			entityESP.Line8 = Drawing.new('Line');
			entityESP.Line9 = Drawing.new('Line');
			entityESP.Line10 = Drawing.new('Line');
			entityESP.Line11 = Drawing.new('Line');
			entityESP.Line12 = Drawing.new('Line');
	
			local color: any = entitylib.getEntityColor(ent) or Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
			for _, v: any in entityESP do
				v.Thickness = 1;
				v.Color = color;
			end;
	
			reference[ent] = entityESP;
		end,
		["DrawingSkeleton"] = function(ent: any)
			if not Targets.Players["Enabled"] and ent.Player then return; end;
			if not Targets.NPCs["Enabled"] and ent.NPC then return; end;
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return; end;
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			local entityESP: table = {};
			entityESP.Head = Drawing.new('Line');
			entityESP.HeadFacing = Drawing.new('Line');
			entityESP.Torso = Drawing.new('Line');
			entityESP.UpperTorso = Drawing.new('Line');
			entityESP.LowerTorso = Drawing.new('Line');
			entityESP.LeftArm = Drawing.new('Line');
			entityESP.RightArm = Drawing.new('Line');
			entityESP.LeftLeg = Drawing.new('Line');
			entityESP.RightLeg = Drawing.new('Line');
	
			local color: any = entitylib.getEntityColor(ent) or Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
			for _, v: any in entityESP do
				v.Thickness = 2;
				v.Color = color;
			end;
	
			reference[ent] = entityESP;
		end
	};
	
	local espRemoved: table = {
		["Drawing2D"] = function(ent: any)
			local entityESP: any = reference[ent];
			if entityESP then
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				reference[ent] = nil;
				for _, v: any in entityESP do
					pcall(function()
						v.Visible = false;
						v:Remove();
					end);
				end;
			end;
		end
	};
	espRemoved.Drawing3D = espRemoved.Drawing2D;
	espRemoved.DrawingSkeleton = espRemoved.Drawing2D;
	
	local espUpdated: table = {
		["Drawing2D"] = function(ent: any)
			local entityESP: any = reference[ent];
			if entityESP then
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				
				if entityESP.HealthLine then
					entityESP.HealthLine.Color = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75);
				end;
	
				if entityESP.Text then
					entityESP.Text.Text = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name;
					entityESP.Drop.Text = entityESP.Text.Text;
				end;
			end;
		end
	};
	
	local colorFunc: table = {
		["Drawing2D"] = function(hue: any, sat: any, val: any)
			local color: Color3 = Color3.fromHSV(hue, sat, val);
			for i: any, v: any in reference do
				v.Main.Color = entitylib.getEntityColor(i) or color;
				if v.Text then
					v.Text.Color = v.Main.Color;
				end;
			end;
		end,
		["Drawing3D"] = function(hue: any, sat: any, val: any)
			local color: Color3 = Color3.fromHSV(hue, sat, val);
			for i: any, v: any in reference do
				local playercolor: any = entitylib.getEntityColor(i) or color;
				for _, v2: any in v do
					v2.Color = playercolor;
				end;
			end;
		end
	};
	colorFunc.DrawingSkeleton = colorFunc.Drawing3D;
	
	local espLoop: table = {
		["Drawing2D"] = function()
			for ent: any, entityESP: any in reference do
				if Distance["Enabled"] then
					local distance: number = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge;
					if distance < DistanceLimit["ValueMin"] or distance > DistanceLimit["ValueMax"] then
						for _, obj: any in entityESP do
							obj.Visible = false;
						end;
						continue;
					end;
				end;
	
				local rootPos: Vector3, rootVis: boolean = gameCamera:WorldToViewportPoint(ent.RootPart.Position);
				for _, obj: any in entityESP do
					obj.Visible = rootVis;
				end;
				if not rootVis then continue; end;
	
				local topPos: Vector3 = gameCamera:WorldToViewportPoint((CFrame.lookAlong(ent.RootPart.Position, gameCamera.CFrame.LookVector) * CFrame.new(2, ent.HipHeight, 0)).p);
				local bottomPos: Vector3 = gameCamera:WorldToViewportPoint((CFrame.lookAlong(ent.RootPart.Position, gameCamera.CFrame.LookVector) * CFrame.new(-2, -ent.HipHeight - 1, 0)).p);
				local sizex: number, sizey: number = topPos.X - bottomPos.X, topPos.Y - bottomPos.Y;
				local posx: number, posy: number = (rootPos.X - sizex / 2),  ((rootPos.Y - sizey / 2));
				entityESP.Main.Position = Vector2.new(posx, posy) // 1;
				entityESP.Main.Size = Vector2.new(sizex, sizey) // 1;
				if entityESP.Border then
					entityESP.Border.Position = Vector2.new(posx - 1, posy + 1) // 1;
					entityESP.Border.Size = Vector2.new(sizex + 2, sizey - 2) // 1;
					entityESP.Border2.Position = Vector2.new(posx + 1, posy - 1) // 1;
					entityESP.Border2.Size = Vector2.new(sizex - 2, sizey + 2) // 1;
				end;
	
				if entityESP.HealthLine then
					local healthposy: number = sizey * math.clamp(ent.Health / ent.MaxHealth, 0, 1);
					entityESP.HealthLine.Visible = ent.Health > 0;
					entityESP.HealthLine.From = Vector2.new(posx - 6, posy + (sizey - (sizey - healthposy))) // 1;
					entityESP.HealthLine.To = Vector2.new(posx - 6, posy) // 1;
					entityESP.HealthBorder.From = Vector2.new(posx - 6, posy + 1) // 1;
					entityESP.HealthBorder.To = Vector2.new(posx - 6, (posy + sizey) - 1) // 1;
				end;
	
				if entityESP.Text then
					entityESP.Text.Position = Vector2.new(posx + (sizex / 2), posy + (sizey - 28)) // 1;
					entityESP.Drop.Position = entityESP.Text.Position + Vector2.new(1, 1);
					if entityESP.TextBKG then
						entityESP.TextBKG.Size = entityESP.Text.TextBounds + Vector2.new(8, 4);
						entityESP.TextBKG.Position = entityESP.Text.Position - Vector2.new(4 + (entityESP.Text.TextBounds.X / 2), 0);
					end;
				end;
			end;
		end,
		["Drawing3D"] = function()
			for ent: any, entityESP: any in reference do
				if Distance["Enabled"] then
					local distance: number = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge;
					if distance < DistanceLimit["ValueMin"] or distance > DistanceLimit["ValueMax"] then
						for _, obj: any in entityESP do
							obj.Visible = false;
						end;
						continue;
					end;
				end;
	
				local _, rootVis: boolean = gameCamera:WorldToViewportPoint(ent.RootPart.Position);
				for _, obj: any in entityESP do
					obj.Visible = rootVis;
				end;
				if not rootVis then continue; end;
	
				local point1: any = espWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, ent.HipHeight, 1.5));
				local point2: any = espWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, -ent.HipHeight, 1.5));
				local point3: any = espWorldToViewport(ent.RootPart.Position + Vector3.new(-1.5, ent.HipHeight, 1.5));
				local point4: any = espWorldToViewport(ent.RootPart.Position + Vector3.new(-1.5, -ent.HipHeight, 1.5));
				local point5: any = espWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, ent.HipHeight, -1.5));
				local point6: any = espWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, -ent.HipHeight, -1.5));
				local point7: any = espWorldToViewport(ent.RootPart.Position + Vector3.new(-1.5, ent.HipHeight, -1.5));
				local point8: any = espWorldToViewport(ent.RootPart.Position + Vector3.new(-1.5, -ent.HipHeight, -1.5));
				entityESP.Line1.From = point1;
				entityESP.Line1.To = point2;
				entityESP.Line2.From = point3;
				entityESP.Line2.To = point4;
				entityESP.Line3.From = point5;
				entityESP.Line3.To = point6;
				entityESP.Line4.From = point7;
				entityESP.Line4.To = point8;
				entityESP.Line5.From = point1;
				entityESP.Line5.To = point3;
				entityESP.Line6.From = point1;
				entityESP.Line6.To = point5;
				entityESP.Line7.From = point5;
				entityESP.Line7.To = point7;
				entityESP.Line8.From = point7;
				entityESP.Line8.To = point3;
				entityESP.Line9.From = point2;
				entityESP.Line9.To = point4;
				entityESP.Line10.From = point2;
				entityESP.Line10.To = point6;
				entityESP.Line11.From = point6;
				entityESP.Line11.To = point8;
				entityESP.Line12.From = point8;
				entityESP.Line12.To = point4;
			end;
		end,
		["DrawingSkeleton"] = function()
			for ent: any, entityESP: any in reference do
				if Distance["Enabled"] then
					local distance: number = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge;
					if distance < DistanceLimit["ValueMin"] or distance > DistanceLimit["ValueMax"] then
						for _, obj: any in entityESP do
							obj.Visible = false;
						end;
						continue;
					end;
				end;
	
				local _, rootVis: boolean = gameCamera:WorldToViewportPoint(ent.RootPart.Position);
				for _, obj: any in entityESP do
					obj.Visible = rootVis;
				end;
				if not rootVis then continue; end;
				
				local rigcheck: boolean = ent.Humanoid.RigType == Enum.HumanoidRigType.R6;
				pcall(function()
					local offset: CFrame = rigcheck and CFrame.new(0, -0.8, 0) or CFrame.identity;
					local head: any = espWorldToViewport((ent.Head.CFrame).p);
					local headfront: any = espWorldToViewport((ent.Head.CFrame * CFrame.new(0, 0, -0.5)).p);
					local toplefttorso: any = espWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(-1.5, 0.8, 0)).p);
					local toprighttorso: any = espWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(1.5, 0.8, 0)).p);
					local toptorso: any = espWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0, 0.8, 0)).p);
					local bottomtorso: any = espWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0, -0.8, 0)).p);
					local bottomlefttorso: any = espWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(-0.5, -0.8, 0)).p);
					local bottomrighttorso: any = espWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0.5, -0.8, 0)).p);
					local leftarm: any = espWorldToViewport((ent.Character[(rigcheck and 'Left Arm' or 'LeftHand')].CFrame * offset).p);
					local rightarm: any = espWorldToViewport((ent.Character[(rigcheck and 'Right Arm' or 'RightHand')].CFrame * offset).p);
					local leftleg: any = espWorldToViewport((ent.Character[(rigcheck and 'Left Leg' or 'LeftFoot')].CFrame * offset).p);
					local rightleg: any = espWorldToViewport((ent.Character[(rigcheck and 'Right Leg' or 'RightFoot')].CFrame * offset).p);
					entityESP.Head.From = toptorso;
					entityESP.Head.To = head;
					entityESP.HeadFacing.From = head;
					entityESP.HeadFacing.To = headfront;
					entityESP.UpperTorso.From = toplefttorso;
					entityESP.UpperTorso.To = toprighttorso;
					entityESP.Torso.From = toptorso;
					entityESP.Torso.To = bottomtorso;
					entityESP.LowerTorso.From = bottomlefttorso;
					entityESP.LowerTorso.To = bottomrighttorso;
					entityESP.LeftArm.From = toplefttorso;
					entityESP.LeftArm.To = leftarm;
					entityESP.RightArm.From = toprighttorso;
					entityESP.RightArm.To = rightarm;
					entityESP.LeftLeg.From = bottomlefttorso;
					entityESP.LeftLeg.To = leftleg;
					entityESP.RightLeg.From = bottomrighttorso;
					entityESP.RightLeg.To = rightleg;
				end);
			end;
		end;
	};
	
	ESP = vape.Categories.Render:CreateModule({
		["Name"] = 'ESP',
		["Function"] = function(callback: boolean): void
			if callback then
				methodused = 'Drawing'..Method["Value"];
				if espRemoved[methodused] then
					ESP:Clean(entitylib.Events.EntityRemoved:Connect(espRemoved[methodused]));
				end;
				if espAdded[methodused] then
					for _, v: any in entitylib.List do
						if reference[v] then
							espRemoved[methodused](v);
						end;
						espAdded[methodused](v);
					end;
					ESP:Clean(entitylib.Events.EntityAdded:Connect(function(ent: any)
						if reference[ent] then
							espRemoved[methodused](ent);
						end;
						espAdded[methodused](ent);
					end));
				end;
				if espUpdated[methodused] then
					ESP:Clean(entitylib.Events.EntityUpdated:Connect(espUpdated[methodused]));
					for _, v: any in entitylib.List do
						espUpdated[methodused](v);
					end;
				end;
				if colorFunc[methodused] then
					ESP:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
						colorFunc[methodused](Color["Hue"], Color["Sat"], Color["Value"]);
					end));
				end;
				if espLoop[methodused] then
					ESP:Clean(runService.RenderStepped:Connect(espLoop[methodused]));
				end;
			else
				if espRemoved[methodused] then
					for i: any in reference do
						espRemoved[methodused](i);
					end;
				end;
			end;
		end,
		["Tooltip"] = 'Extra Sensory Perception\nRenders an ESP on players.'
	});
	Targets = ESP:CreateTargets({
		["Players"] = true,
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle();
				ESP:Toggle();
			end;
		end;
	});
	Method = ESP:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'2D', '3D', 'Skeleton'},
		["Function"] = function(val: any)
			if ESP["Enabled"] then
				ESP:Toggle();
				ESP:Toggle();
			end;
			BoundingBox.Object.Visible = (val == '2D');
			Filled.Object.Visible = (val == '2D');
			HealthBar.Object.Visible = (val == '2D');
			Name.Object.Visible = (val == '2D');
			DisplayName.Object.Visible = Name.Object.Visible and Name["Enabled"];
			Background.Object.Visible = Name.Object.Visible and Name["Enabled"];
		end,
	});
	Color = ESP:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue: any, sat: any, val: any)
			if ESP["Enabled"] and colorFunc[methodused] then
				colorFunc[methodused](hue, sat, val);
			end;
		end;
	});
	BoundingBox = ESP:CreateToggle({
		["Name"] = 'Bounding Box',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle();
				ESP:Toggle();
			end;
		end,
		["Default"] = true,
		["Darker"] = true
	});
	Filled = ESP:CreateToggle({
		["Name"] = 'Filled',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle();
				ESP:Toggle();
			end;
		end,
		["Darker"] = true
	});
	HealthBar = ESP:CreateToggle({
		["Name"] = 'Health Bar',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle();
				ESP:Toggle();
			end;
		end,
		["Darker"] = true
	});
	Name = ESP:CreateToggle({
		["Name"] = 'Name',
		["Function"] = function(callback: boolean): void
			if ESP["Enabled"] then
				ESP:Toggle();
				ESP:Toggle();
			end;
			DisplayName.Object.Visible = callback;
			Background.Object.Visible = callback;
		end,
		["Darker"] = true
	});
	DisplayName = ESP:CreateToggle({
		["Name"] = 'Use Displayname',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle();
				ESP:Toggle();
			end;
		end,
		["Default"] = true,
		["Darker"] = true
	});
	Background = ESP:CreateToggle({
		["Name"] = 'Show Background',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle();
				ESP:Toggle();
			end;
		end,
		["Darker"] = true
	});
	Teammates = ESP:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle();
				ESP:Toggle();
			end;
		end,
		["Default"] = true,
		["Tooltip"] = 'Hides teammates & non targetable entities'
	});
	Distance = ESP:CreateToggle({
		["Name"] = 'Distance Check',
		["Function"] = function(callback: boolean): void
			DistanceLimit.Object.Visible = callback;
		end;
	});
	DistanceLimit = ESP:CreateTwoSlider({
		["Name"] = 'Player Distance',
		["Min"] = 0,
		["Max"] = 256,
		["DefaultMin"] = 0,
		["DefaultMax"] = 64,
		["Darker"] = true,
		["Visible"] = false
	});
end);

velo.run(function()
	local GamingChair: table = {["Enabled"] = false};
	local gamingChairSounds: table = {["Enabled"] = false};
	local Color: any;
	local wheelpositions: Vector3? = {
		Vector3.new(-0.8, -0.6, -0.18),
		Vector3.new(0.1, -0.6, -0.88),
		Vector3.new(0, -0.6, 0.7)
	};
	local chairhighlight: any;
	local currenttween: any;
	local movingsound: any;
	local flyingsound: any;
	local chairanim: any;
	local chair: any;
	local isAlive: (v: Player) -> Boolean = function(v: Player): Boolean
		if v.Character and v.Character:FindFirstChild("Humanoid") then
			if v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") then
				return true;
			end;
		end;
		return false;
	end; 
	local soundMap: table = {
		["chair roll"] = "rbxassetid://113636621692730",
		["chair fly"] = "rbxassetid://119469900948825",
	};
	local getSound: (key: string) -> string? = function(key: string): string?
		local info: any = soundMap[key];
		local get: (file: string, url: string) -> string? = function(file: string, url: string): string?
			local fullPath: string = "velo/sounds/" .. file;
			if not isfile(fullPath) then
				local v: string = game:HttpGet(url);
				if v then
					writefile(fullPath, v);
				else
					return nil;
				end;
			end;
			return nil;
		end;
	
		if type(info) == "string" then
			if string.match(info, "^rbxassetid://") then
				return info;
			else
				return nil;
			end;
		elseif type(info) == "table" then
			local filename: string = info[1];
			local url: string = info[2];
			local result: any = get(filename, url);
			return result;
		else
			return nil;
		end;
	end;

	GamingChair = vape.Categories.Render:CreateModule({
		["Name"] = 'GamingChair',
		["Function"] = function(callback: boolean): void
			if callback then
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				chair = Instance.new('MeshPart');
				chair.Color = Color3.fromRGB(21, 21, 21);
				chair.Size = Vector3.new(2.16, 3.6, 2.3) / Vector3.new(12.37, 20.636, 13.071);
				chair.CanCollide = false;
				chair.Massless = true;
				chair.MeshId = 'rbxassetid://12972961089';
				chair.Material = Enum.Material.SmoothPlastic;
				chair.Parent = workspace;
				movingsound = Instance.new('Sound');
				movingsound.SoundId = getSound("chair roll");
				movingsound.Volume = 0.4;
				movingsound.Looped = true;
				movingsound.Parent = workspace;
				flyingsound = Instance.new('Sound');
				flyingsound.SoundId = getSound("chair fly");
				flyingsound.Volume = 0.4;
				flyingsound.Looped = true;
				flyingsound.Parent = workspace;
				local chairweld: WeldConstraint = Instance.new('WeldConstraint');
				chairweld.Part0 = chair;
				chairweld.Parent = chair;
				if entitylib.isAlive then
					chair.CFrame = entitylib.character.RootPart.CFrame * CFrame.Angles(0, math.rad(-90), 0);
					chairweld.Part1 = entitylib.character.RootPart;
				end;
				chairhighlight = Instance.new('Highlight');
				chairhighlight.FillTransparency = 1;
				chairhighlight.OutlineColor = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
				chairhighlight.DepthMode = Enum.HighlightDepthMode.Occluded;
				chairhighlight.OutlineTransparency = 0.2;
				chairhighlight.Parent = chair;
				local chairarms: MeshPart = Instance.new('MeshPart');
				chairarms.Color = chair.Color;
				chairarms.Size = Vector3.new(1.39, 1.345, 2.75) / Vector3.new(97.13, 136.216, 234.031);
				chairarms.CFrame = chair.CFrame * CFrame.new(-0.169, -1.129, -0.013);
				chairarms.MeshId = 'rbxassetid://12972673898';
				chairarms.CanCollide = false;
				chairarms.Parent = chair;
				local chairarmsweld: WeldConstraint = Instance.new('WeldConstraint');
				chairarmsweld.Part0 = chairarms;
				chairarmsweld.Part1 = chair;
				chairarmsweld.Parent = chair;
				local chairlegs: MeshPart = Instance.new('MeshPart');
				chairlegs.Color = chair.Color;
				chairlegs.Name = 'Legs';
				chairlegs.Size = Vector3.new(1.8, 1.2, 1.8) / Vector3.new(10.432, 8.105, 9.488);
				chairlegs.CFrame = chair.CFrame * CFrame.new(0.047, -2.324, 0);
				chairlegs.MeshId = 'rbxassetid://13003181606';
				chairlegs.CanCollide = false;
				chairlegs.Parent = chair;
				local chairfan: MeshPart = Instance.new('MeshPart');
				chairfan.Color = chair.Color;
				chairfan.Name = 'Fan';
				chairfan.Size = Vector3.zero;
				chairfan.CFrame = chair.CFrame * CFrame.new(0, -1.873, 0);
				chairfan.MeshId = 'rbxassetid://13004977292';
				chairfan.CanCollide = false;
				chairfan.Parent = chair;
				local trails: table = {};
				for _, v: any in wheelpositions do
					local attachment: Attachment? = Instance.new('Attachment');
					attachment.Position = v;
					attachment.Parent = chairlegs;
					local attachment2: Attachment? = Instance.new('Attachment');
					attachment2.Position = v + Vector3.new(0, 0, 0.18);
					attachment2.Parent = chairlegs;
					local trail: Trail? = Instance.new('Trail');
					trail.Texture = 'http://www.roblox.com/asset/?id=13005168530';
					trail.TextureMode = Enum.TextureMode.Static;
					trail.Transparency = NumberSequence.new(0.5);
					trail.Color = ColorSequence.new(Color3.new(0.5, 0.5, 0.5));
					trail.Attachment0 = attachment;
					trail.Attachment1 = attachment2;
					trail.Lifetime = 20;
					trail.MaxLength = 60;
					trail.MinLength = 0.1;
					trail.Parent = chairlegs;
					table.insert(trails, trail);
				end;
				GamingChair:Clean(chair);
				GamingChair:Clean(movingsound);
				GamingChair:Clean(flyingsound);
				chairanim = {["Stop"] = function() end};
				local oldmoving: boolean = false;
				local oldflying: boolean = false;
				repeat
					if entitylib.isAlive and entitylib.character.Humanoid.Health > 0 then
						if not chairanim.IsPlaying then
							local temp2: Animation = Instance.new('Animation');
							temp2.AnimationId = entitylib.character.Humanoid.RigType == Enum.HumanoidRigType.R15 and 'http://www.roblox.com/asset/?id=2506281703' or 'http://www.roblox.com/asset/?id=178130996';
							chairanim = entitylib.character.Humanoid:LoadAnimation(temp2);
							chairanim.Priority = Enum.AnimationPriority.Movement;
							chairanim.Looped = true;
							chairanim:Play();
						end;
						chair.CFrame = entitylib.character.RootPart.CFrame * CFrame.Angles(0, math.rad(-90), 0);
						chairweld.Part1 = entitylib.character.RootPart;
						chairlegs.Velocity = Vector3.zero;
						chairlegs.CFrame = chair.CFrame * CFrame.new(0.047, -2.324, 0);
						chairfan.Velocity = Vector3.zero;
						chairfan.CFrame = chair.CFrame * CFrame.new(0.047, -1.873, 0) * CFrame.Angles(0, math.rad(tick() * 180 % 360), math.rad(180));
						local moving: CFrame? = entitylib.character.Humanoid:GetState() == Enum.HumanoidStateType.Running and entitylib.character.Humanoid.MoveDirection ~= Vector3.zero;
						local flying: boolean? = vape.Modules.Fly and vape.Modules.Fly["Enabled"] or vape.Modules.LongJump and vape.Modules.LongJump["Enabled"] or vape.Modules.InfiniteFly and vape.Modules.InfiniteFly["Enabled"];
						if movingsound.TimePosition > 1.9 then
							movingsound.TimePosition = 0.2;
						end;
						movingsound.PlaybackSpeed = (entitylib.character.RootPart.Velocity * Vector3.new(1, 0, 1)).Magnitude / 16;
						for _: any, v: any in trails do
							v["Enabled"] = not flying and moving;
							v.Color = ColorSequence.new(movingsound.PlaybackSpeed > 1.5 and Color3.new(1, 0.5, 0) or Color3.new());
						end;
						if moving ~= oldmoving then
							if movingsound.IsPlaying then
								if not moving then
									movingsound:Stop();
								end;
							else
								if not flying and moving then
									movingsound:Play();
								end;
							end;
							oldmoving = moving;
						end;
						if flying ~= oldflying then
							if flying then
								if movingsound.IsPlaying then
									movingsound:Stop();
								end;
								if not flyingsound.IsPlaying then
									flyingsound:Play();
								end;
								if currenttween then
									currenttween:Cancel();
								end;
								tween = tweenService:Create(chairlegs, TweenInfo.new(0.15), {
									["Size"] = Vector3.zero;
								});
								tween.Completed:Connect(function(state: any)
									if state == Enum.PlaybackState.Completed then
										chairfan.Transparency = 0;
										chairlegs.Transparency = 1;
										tween = tweenService:Create(chairfan, TweenInfo.new(0.15), {
											["Size"] = Vector3.new(1.534, 0.328, 1.537) / Vector3.new(791.138, 168.824, 792.027)
										});
										tween:Play();
									end;
								end);
								tween:Play();
							else
								if flyingsound.IsPlaying then
									flyingsound:Stop();
								end;
								if not movingsound.IsPlaying and moving then
									movingsound:Play();
								end;
								if currenttween then currenttween:Cancel(); end;
								tween = tweenService:Create(chairfan, TweenInfo.new(0.15), {
									["Size"] = Vector3.zero
								});
								tween.Completed:Connect(function(state: any)
									if state == Enum.PlaybackState.Completed then
										chairfan.Transparency = 1;
										chairlegs.Transparency = 0;
										tween = tweenService:Create(chairlegs, TweenInfo.new(0.15), {
											["Size"] = Vector3.new(1.8, 1.2, 1.8) / Vector3.new(10.432, 8.105, 9.488)
										});
										tween:Play();
									end;
								end);
								tween:Play();
							end;
							oldflying = flying;
						end;
					else
						chair.Anchored = true;
						chairlegs.Anchored = true;
						chairfan.Anchored = true;
						repeat task.wait(); until entitylib.isAlive and entitylib.character.Humanoid.Health > 0;
						if GamingChair["Enabled"] then
							GamingChair:Toggle();
							GamingChair:Toggle();
						end;
						chair.Anchored = false;
						chairlegs.Anchored = false;
						chairfan.Anchored = false;
						chairanim:Stop();
					end;
					task.wait();
				until not GamingChair["Enabled"];
			else
				if chairanim then
					chairanim:Stop();
				end;
			end;
		end,
		["Tooltip"] = 'Sit in the best gaming chair known to mankind.'
	});
	Color = GamingChair:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function(h: any, s: any, v: any)
			if chairhighlight then
				chairhighlight.OutlineColor = Color3.fromHSV(h, s, v);
			end;
		end;
	});
end);

velo.run(function()
	local Fullbright: table = {["Enabled"] = false};
	local Mode: any;
	local oldsettings: table = {};
	local flag: boolean;
	local changeLighting: (prop: any) -> () = function(prop: any): ()
		if flag then
			return;
		end;
		flag = true;
		lightingService.Ambient = Color3.new(1, 1, 1);
		lightingService.OutdoorAmbient = Color3.new(1, 1, 1);
		lightingService.Brightness = 3;
		runService.RenderStepped:Wait();
		flag = false;
	end;
	Fullbright = vape.Categories.Render:CreateModule({
		["Name"] = 'Fullbright',
		["Function"] = function(callback: boolean): void
			if callback then
				if Mode["Value"] == 'Lighting' then
					for _: {string?}, v: table? in {'Ambient', 'OutdoorAmbient', 'Brightness'} do
						oldsettings[v] = lightingService[v];
					end;
					Fullbright:Clean(lightingService.Changed:Connect(changeLighting));
					task.spawn(changeLighting);
				else
					local inst: PointLight = Instance.new('PointLight');
					inst.Range = 1000;
					Fullbright:Clean(inst);
					repeat
						inst.Parent = entitylib.isAlive and entitylib.character.RootPart or nil;
						task.wait(0.1);
					until not Fullbright["Enabled"];
				end;
			else
				flag = false;
				for i: any, v: any in oldsettings do
					lightingService[i] = v;
				end;
				table.clear(oldsettings);
			end;
		end,
		["Tooltip"] = 'Increase the lighting of the world around you.'
	});
	Mode = Fullbright:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Lighting', 'PointLight'},
		["Function"] = function()
			if Fullbright["Enabled"] then
				Fullbright:Toggle();
				Fullbright:Toggle();
			end;
		end;
	});
end);

velo.run(function()
	local Health: table = {["Enabled"] = false};
	local Size: table = {["Value"] = 18};
	local Stroke: table = {["Value"] = 1};
	local Offset: table = {["Value"] = 30};
	local FontOption: table = {["Value"] = Font.fromEnum(Enum.Font.Arial)};
	local label: TextLabel? = nil;

	Health = vape.Categories.Render:CreateModule({
		["Name"] = 'Health',
		["Function"] = function(callback: boolean): void
			if callback then
				label = Instance.new('TextLabel');
				label.Size = UDim2.fromOffset(100, 20);
				label.Position = UDim2.new(0.5, 6, 0.5, Offset["Value"]);
				label.AnchorPoint = Vector2.new(0.5, 0);
				label.BackgroundTransparency = 1;
				label.Text = '100 ❤️';
				label.TextSize = Size["Value"];
				label.TextStrokeTransparency = Stroke["Value"];
				label.FontFace = FontOption["Value"];
				label.Parent = vape.gui;
				Health:Clean(label);

				repeat
					label.Text = entitylib.isAlive and math.round(entitylib.character.Humanoid.Health)..' ❤️' or '';
					label.TextColor3 = entitylib.isAlive and Color3.fromHSV((entitylib.character.Humanoid.Health / entitylib.character.Humanoid.MaxHealth) / 2.8, 0.86, 1) or Color3.new();
					task.wait();
				until not Health["Enabled"];
			else
				label = nil;
			end;
		end,
		["Tooltip"] = 'Displays your health in the center of your screen.'
	});
	FontOption = Health:CreateFont({
		["Name"] = 'Font',
		["Default"] = 'Arial',
		["Function"] = function(value: Font): void
			if label then
				label.FontFace = value;
			end;
		end
	});
	Size = Health:CreateSlider({
		["Name"] = 'Size',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 18,
		["Function"] = function(value: number): void
			if label then
				label.TextSize = value;
			end;
		end
	});
	Stroke = Health:CreateSlider({
		["Name"] = 'Stroke Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 1,
		["Decimal"] = 10,
		["Function"] = function(value: number): void
			if label then
				label.TextStrokeTransparency = value;
			end;
		end
	});
	Offset = Health:CreateSlider({
		["Name"] = 'Y Offset',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 30,
		["Function"] = function(value: number): void
			if label then
				label.Position = UDim2.new(0.5, 6, 0.5, value);
			end;
		end
	});
end);
	
velo.run(function()
	local NameTags: table;
	local Targets: table;
	local Color: table;
	local Background: table;
	local Stroke: table;
	local DisplayName: table;
	local Health: table;
	local Distance: table;
	local DrawingToggle: table;
	local Scale: table;
	local FontOption: table;
	local Teammates: table;
	local FriendBorder: table;
	local DistanceCheck: table;
	local DistanceLimit: table;
	local strings: table, sizes: table, reference: table = {}, {}, {};
	local folder: Folder = Instance.new('Folder');
	folder.Parent = vape.gui;
	local methodused: string;
	
	local added: table = {
		["Normal"] = function(entity: any)
			if not Targets.Players["Enabled"] and entity.Player then return; end;
			if not Targets.NPCs["Enabled"] and entity.NPC then return; end;
			if Teammates["Enabled"] and (not entity.Targetable) and (not entity.Friend) then return; end;
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
	
			strings[entity] = entity.Player and whitelist:tag(entity.Player, true, true)..(DisplayName["Enabled"] and entity.Player.DisplayName or entity.Player.Name) or entity.Character.Name;
	
			if Health["Enabled"] then
				local healthColor: Color3 = Color3.fromHSV(math.clamp(entity.Health / entity.MaxHealth, 0, 1) / 2.5, 0.89, 0.75);
				strings[entity] = strings[entity]..' <font color="#'..healthColor:ToHex()..'">'..math.round(entity.Health)..'</font>';
			end;
	
			if Distance["Enabled"] then
				strings[entity] = '<font color="#55ff55">[</font><font color="#ffffff">%s</font><font color="#55ff55">]</font> '..strings[entity];
			end;
	
			local nametag: TextLabel = Instance.new('TextLabel');
			nametag.TextSize = 14 * Scale["Value"];
			nametag.FontFace = FontOption["Value"];
			local size: any = getfontbounds(removeTags(strings[entity]), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000));
			nametag.Name = entity.Player and entity.Player.Name or entity.Character.Name;
			nametag.Size = UDim2.fromOffset(size.X + 8, size.Y + 7);
			nametag.AnchorPoint = Vector2.new(0.5, 1);
			nametag.BackgroundColor3 = Color3.new();
			nametag.BackgroundTransparency = Background["Value"];
			nametag.TextStrokeTransparency = Stroke["Value"];
			nametag.BorderSizePixel = 0;
			nametag.Visible = false;
			nametag.Text = strings[entity];
			nametag.TextColor3 = entitylib.getEntityColor(entity) or Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
			nametag.RichText = true;
			nametag.Parent = folder;
	
			if FriendBorder["Enabled"] and not entity.Targetable then
				nametag.BorderSizePixel = 2;
				nametag.BorderColor3 = Color3.new(0, 1, 0);
			end;
	
			reference[entity] = nametag;
		end,
		["Drawing"] = function(entity: any)
			if not Targets.Players["Enabled"] and entity.Player then return; end;
			if not Targets.NPCs["Enabled"] and entity.NPC then return; end;
			if Teammates["Enabled"] and (not entity.Targetable) and (not entity.Friend) then return; end;
	
			local nametag: table = {};
			nametag.BG = Drawing.new('Square');
			nametag.BG.Filled = true;
			nametag.BG.Transparency = 1 - Background["Value"];
			nametag.BG.Color = Color3.new();
			nametag.BG.ZIndex = 1;
			nametag.Text = Drawing.new('Text');
			nametag.Text.Size = 15 * Scale["Value"];
			nametag.Text.Font = 0;
			nametag.Text.ZIndex = 2;
			strings[entity] = entity.Player and whitelist:tag(entity.Player, true)..(DisplayName["Enabled"] and entity.Player.DisplayName or entity.Player.Name) or entity.Character.Name;
	
			if Health["Enabled"] then
				strings[entity] = strings[entity]..' '..math.round(entity.Health);
			end;
	
			if Distance["Enabled"] then
				strings[entity] = '[%s] '..strings[entity];
			end;
	
			nametag.Text.Text = strings[entity];
			nametag.Text.Color = entitylib.getEntityColor(entity) or Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
			nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7);
			reference[entity] = nametag;
		end
	};
	
	local removed: table = {
		["Normal"] = function(entity: any)
			local v: any = reference[entity];
			if v then
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				reference[entity] = nil;
				strings[entity] = nil;
				sizes[entity] = nil;
				v:Destroy();
			end;
		end,
		["Drawing"] = function(entity: any)
			local v: any = reference[entity];
			if v then
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				reference[entity] = nil;
				strings[entity] = nil;
				sizes[entity] = nil;
				for _, obj: any in v do
					pcall(function()
						obj.Visible = false;
						obj:Remove();
					end);
				end;
			end;
		end
	};
	
	local updated: table = {
		["Normal"] = function(entity: any)
			local nametag: any = reference[entity];
			if nametag then
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				sizes[entity] = nil;
				strings[entity] = entity.Player and whitelist:tag(entity.Player, true, true)..(DisplayName["Enabled"] and entity.Player.DisplayName or entity.Player.Name) or entity.Character.Name;
	
				if Health["Enabled"] then
					local color: Color3 = Color3.fromHSV(math.clamp(entity.Health / entity.MaxHealth, 0, 1) / 2.5, 0.89, 0.75);
					strings[entity] = strings[entity]..' <font color="#'..color:ToHex()..'">'..math.round(entity.Health)..'</font>';
				end;
	
				if Distance["Enabled"] then
					strings[entity] = '<font color="#55ff55">[</font><font color="#ffffff">%s</font><font color="#55ff55">]</font> '..strings[entity];
				end;
	
				local size: any = getfontbounds(removeTags(strings[entity]), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000));
				nametag.Size = UDim2.fromOffset(size.X + 8, size.Y + 7);
				nametag.Text = strings[entity];
			end;
		end,
		["Drawing"] = function(entity: any)
			local nametag: any = reference[entity];
			if nametag then
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				sizes[entity] = nil;
				strings[entity] = entity.Player and whitelist:tag(entity.Player, true)..(DisplayName["Enabled"] and entity.Player.DisplayName or entity.Player.Name) or entity.Character.Name;
	
				if Health["Enabled"] then
					strings[entity] = strings[entity]..' '..math.round(entity.Health);
				end;
	
				if Distance["Enabled"] then
					strings[entity] = '[%s] '..strings[entity];
					nametag.Text.Text = entitylib.isAlive and string.format(strings[entity], math.floor((entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude)) or strings[entity];
				else
					nametag.Text.Text = strings[entity];
				end;
	
				nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7);
				nametag.Text.Color = entitylib.getEntityColor(entity) or Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
			end;
		end
	};
	
	local colorFunc: table = {
		["Normal"] = function(hue: any, sat: any, val: any)
			local color: Color3 = Color3.fromHSV(hue, sat, val);
			for entity: any, v: any in reference do
				v.TextColor3 = entitylib.getEntityColor(entity) or color;
			end;
		end,
		["Drawing"] = function(hue: any, sat: any, val: any)
			local color: Color3 = Color3.fromHSV(hue, sat, val);
			for entity: any, v: any in reference do
				v.Text.Color = entitylib.getEntityColor(entity) or color;
			end;
		end
	};
	
	local loop: table = {
		["Normal"] = function()
			for entity: any, nametag: any in reference do
				if DistanceCheck["Enabled"] then
					local distance: number = entitylib.isAlive and (entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude or math.huge;
					if distance < DistanceLimit["ValueMin"] or distance > DistanceLimit["ValueMax"] then
						nametag.Visible = false;
						continue;
					end;
				end;
	
				local headPos: Vector3, headVis: boolean = gameCamera:WorldToViewportPoint(entity.RootPart.Position + Vector3.new(0, entity.HipHeight + 1, 0));
				nametag.Visible = headVis;
				if not headVis then
					continue;
				end;
	
				if Distance["Enabled"] then
					local mag: number = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude) or 0;
					if sizes[entity] ~= mag then
						nametag.Text = string.format(strings[entity], mag);
						local ize: any = getfontbounds(removeTags(nametag.Text), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000));
						nametag.Size = UDim2.fromOffset(ize.X + 8, ize.Y + 7);
						sizes[entity] = mag;
					end;
				end;
	
				nametag.Position = UDim2.fromOffset(headPos.X, headPos.Y);
			end;
		end,
		["Drawing"] = function()
			for entity: any, nametag: any in reference do
				if DistanceCheck["Enabled"] then
					local distance: number = entitylib.isAlive and (entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude or math.huge;
					if distance < DistanceLimit["ValueMin"] or distance > DistanceLimit["ValueMax"] then
						nametag.Text.Visible = false;
						nametag.BG.Visible = false;
						continue;
					end;
				end;
	
				local headPos: Vector3, headVis: boolean = gameCamera:WorldToViewportPoint(entity.RootPart.Position + Vector3.new(0, entity.HipHeight + 1, 0));
				nametag.Text.Visible = headVis;
				nametag.BG.Visible = headVis;
				if not headVis then
					continue;
				end;
	
				if Distance["Enabled"] then
					local mag: number = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude) or 0;
					if sizes[entity] ~= mag then
						nametag.Text.Text = string.format(strings[entity], mag);
						nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7);
						sizes[entity] = mag;
					end;
				end;
	
				nametag.BG.Position = Vector2.new(headPos.X - (nametag.BG.Size.X / 2), headPos.Y - nametag.BG.Size.Y);
				nametag.Text.Position = nametag.BG.Position + Vector2.new(4, 3);
			end;
		end
	};
	
	NameTags = vape.Categories.Render:CreateModule({
		["Name"] = 'NameTags',
		["Function"] = function(callback: boolean)
			if callback then
				methodused = DrawingToggle["Enabled"] and 'Drawing' or 'Normal';
				if removed[methodused] then
					NameTags:Clean(entitylib.Events.EntityRemoved:Connect(removed[methodused]));
				end;
				if added[methodused] then
					for _, entity: any in entitylib.List do
						if reference[entity] then
							removed[methodused](entity);
						end;
						added[methodused](entity);
					end;
					NameTags:Clean(entitylib.Events.EntityAdded:Connect(function(entity: any)
						if reference[entity] then
							removed[methodused](entity);
						end;
						added[methodused](entity);
					end));
				end;
				if updated[methodused] then
					NameTags:Clean(entitylib.Events.EntityUpdated:Connect(updated[methodused]));
					for _, entity: any in entitylib.List do
						updated[methodused](entity);
					end;
				end;
				if colorFunc[methodused] then
					NameTags:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
						colorFunc[methodused](Color["Hue"], Color["Sat"], Color["Value"]);
					end));
				end;
				if loop[methodused] then
					NameTags:Clean(runService.RenderStepped:Connect(loop[methodused]));
				end;
			else
				if removed[methodused] then
					for entity: any in reference do
						removed[methodused](entity);
					end;
				end;
			end;
		end,
		["Tooltip"] = 'Renders nametags on entities through walls.'
	});
	Targets = NameTags:CreateTargets({
		["Players"] = true,
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end
	});
	FontOption = NameTags:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Arial',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end
	});
	Color = NameTags:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue: any, sat: any, val: any)
			if NameTags["Enabled"] and colorFunc[methodused] then
				colorFunc[methodused](hue, sat, val);
			end;
		end
	});
	Scale = NameTags:CreateSlider({
		["Name"] = 'Scale',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end,
		["Default"] = 1,
		["Min"] = 0.1,
		["Max"] = 1.5,
		["Decimal"] = 10
	});
	Background = NameTags:CreateSlider({
		["Name"] = 'Transparency',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end,
		["Default"] = 0.5,
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10
	});
	Stroke = NameTags:CreateSlider({
		["Name"] = 'Stroke Transparency',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end,
		["Default"] = 1,
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10
	});
	Health = NameTags:CreateToggle({
		["Name"] = 'Health',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end
	});
	Distance = NameTags:CreateToggle({
		["Name"] = 'Distance',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end
	});
	DisplayName = NameTags:CreateToggle({
		["Name"] = 'Use Displayname',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end,
		["Default"] = true
	});
	Teammates = NameTags:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end,
		["Default"] = true,
		["Tooltip"] = 'Hides teammates & non targetable entities'
	});
	FriendBorder = NameTags:CreateToggle({
		["Name"] = 'Friendly Border',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end,
		["Tooltip"] = 'Apply an outline over the entire nametag signaling a friendly entity.'
	});
	DrawingToggle = NameTags:CreateToggle({
		["Name"] = 'Drawing',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end
	});
	DistanceCheck = NameTags:CreateToggle({
		["Name"] = 'Distance Check',
		["Function"] = function(callback: boolean)
			DistanceLimit.Object.Visible = callback;
		end
	});
	DistanceLimit = NameTags:CreateTwoSlider({
		["Name"] = 'Player Distance',
		["Min"] = 0,
		["Max"] = 256,
		["DefaultMin"] = 0,
		["DefaultMax"] = 64,
		["Darker"] = true,
		["Visible"] = false
	});
end);
	
velo.run(function()
	local PlayerModel: table;
	local Mode: table;
	local Scale: table;
	local Mesh: table;
	local Texture: table;
	local Hide: table;
	local offsets: table = {};
	local rots: table = {};
	local models: table = {};
	
	local addMesh: (entity: any) -> () = function(entity: any): ()
		if vape.ThreadFix then
			setthreadidentity(8);
		end;
	
		if Hide["Enabled"] then
			for _, part: any in entity.Character:QueryDescendants('BasePart') do
				part.Transparency = 1;
			end;
		end;
	
		local root: any = entity.RootPart;
		local part: Part = Instance.new('Part');
		part.Size = Vector3.new(3, 3, 3);
		part.CFrame = root.CFrame * CFrame.new(offsets[1]["Value"], offsets[2]["Value"], offsets[3]["Value"]) * CFrame.Angles(math.rad(rots[1]["Value"]), math.rad(rots[2]["Value"]), math.rad(rots[3]["Value"]));
		part.CanCollide = false;
		part.CanQuery = false;
		part.Massless = true;
		part.Parent = workspace;
		local meshd: SpecialMesh = Instance.new('SpecialMesh');
		meshd.MeshId = Mesh["Value"];
		meshd.TextureId = Texture["Value"];
		meshd.Scale = Vector3.one * Scale["Value"];
		meshd.Parent = part;
		local weld: WeldConstraint = Instance.new('WeldConstraint');
		weld.Part0 = part;
		weld.Part1 = root;
		weld.Parent = part;
		models[root] = part;
	end;
	
	local removeMesh: (entity: any) -> () = function(entity: any): ()
		if models[entity.RootPart] then
			models[entity.RootPart]:Destroy();
			models[entity.RootPart] = nil;
		end;
	end;
	
	PlayerModel = vape.Categories.Render:CreateModule({
		["Name"] = 'PlayerModel',
		["Function"] = function(callback: boolean)
			if callback then
				if Mode["Value"] ~= 'Others' then
					PlayerModel:Clean(entitylib.Events.LocalAdded:Connect(addMesh));
					PlayerModel:Clean(entitylib.Events.LocalRemoved:Connect(removeMesh));
					if entitylib.isAlive then
						task.spawn(addMesh, entitylib.character);
					end;
				end;
	
				if Mode["Value"] ~= 'Local' then
					PlayerModel:Clean(entitylib.Events.EntityAdded:Connect(addMesh));
					PlayerModel:Clean(entitylib.Events.EntityRemoved:Connect(removeMesh));
					for _, ent: any in entitylib.List do
						task.spawn(addMesh, ent);
					end;
				end;
			else
				for _, part: any in models do
					part:Destroy();
				end;
				table.clear(models);
			end;
		end,
		["Tooltip"] = 'Change the player models to a Mesh'
	});
	Mode = PlayerModel:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Others', 'All', 'Local'},
		["Function"] = function()
			if PlayerModel["Enabled"] then
				PlayerModel:Toggle();
				PlayerModel:Toggle();
			end;
		end
	});
	Scale = PlayerModel:CreateSlider({
		["Name"] = 'Scale',
		["Min"] = 0,
		["Max"] = 2,
		["Default"] = 1,
		["Decimal"] = 100,
		["Function"] = function(val: any)
			for _, part: any in models do
				part.Mesh.Scale = Vector3.one * val;
			end;
		end
	});
	for _, name: any in {'Offset X', 'Offset Y', 'Offset Z'} do
		table.insert(offsets, PlayerModel:CreateSlider({
			["Name"] = name,
			["Min"] = -2,
			["Max"] = 2,
			["Default"] = 0,
			["Decimal"] = 10,
			["Function"] = function(val: any)
				for root: any, part: any in models do
					part.WeldConstraint["Enabled"] = false;
					part.CFrame = root.CFrame * CFrame.new(offsets[1]["Value"], offsets[2]["Value"], offsets[3]["Value"]) * CFrame.Angles(math.rad(rots[1]["Value"]), math.rad(rots[2]["Value"]), math.rad(rots[3]["Value"]));
					part.WeldConstraint["Enabled"] = true;
				end;
			end
		}));
	end;
	for _, name: any in {'Rotation X', 'Rotation Y', 'Rotation Z'} do
		table.insert(rots, PlayerModel:CreateSlider({
			["Name"] = name,
			["Min"] = 0,
			["Max"] = 360,
			["Function"] = function(val: any)
				for root: any, part: any in models do
					part.WeldConstraint["Enabled"] = false;
					part.CFrame = root.CFrame * CFrame.new(offsets[1]["Value"], offsets[2]["Value"], offsets[3]["Value"]) * CFrame.Angles(math.rad(rots[1]["Value"]), math.rad(rots[2]["Value"]), math.rad(rots[3]["Value"]));
					part.WeldConstraint["Enabled"] = true;
				end;
			end
		}));
	end;
	Hide = PlayerModel:CreateToggle({
		["Name"] = 'Hide entity',
		["Function"] = function()
			if PlayerModel["Enabled"] then
				PlayerModel:Toggle();
				PlayerModel:Toggle();
			end;
		end
	});
	Mesh = PlayerModel:CreateTextBox({
		["Name"] = 'Mesh',
		["Placeholder"] = 'mesh id',
		["Function"] = function()
			for _, part: any in models do
				part.Mesh.MeshId = Mesh["Value"];
			end;
		end
	});
	Texture = PlayerModel:CreateTextBox({
		["Name"] = 'Texture',
		["Placeholder"] = 'texture id',
		["Function"] = function()
			for _, part: any in models do
				part.Mesh.TextureId = Texture["Value"];
			end;
		end
	});
	
end);
	
velo.run(function()
	local Radar: table = {["Enabled"] = false};
	local Targets: table;
	local DotStyle: table;
	local PlayerColor: table;
	local Clamp: table;
	local reference: table = {};
	local bkg: Frame;
	
	local added: (ent: any) -> () = function(ent: any): ()
		if not Targets.Players["Enabled"] and ent.Player then return; end;
		if not Targets.NPCs["Enabled"] and ent.NPC then return; end;
		if (not ent.Targetable) and (not ent.Friend) then return; end;
		if vape.ThreadFix then
			setthreadidentity(8);
		end;
	
		local entityDot: Frame = Instance.new('Frame');
		entityDot.Size = UDim2.fromOffset(4, 4);
		entityDot.AnchorPoint = Vector2.new(0.5, 0.5);
		entityDot.BackgroundColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(PlayerColor["Hue"], PlayerColor["Sat"], PlayerColor["Value"]);
		entityDot.Parent = bkg;
		local entityCorner: UICorner = Instance.new('UICorner');
		entityCorner.CornerRadius = UDim.new(DotStyle["Value"] == 'Circles' and 1 or 0, 0);
		entityCorner.Parent = entityDot;
		local entityStroke: UIStroke = Instance.new('UIStroke');
		entityStroke.Color = Color3.new();
		entityStroke.Thickness = 1;
		entityStroke.Transparency = 0.8;
		entityStroke.Parent = entityDot;
		reference[ent] = entityDot;
	end;
	
	local removed: (ent: any) -> () = function(ent: any): ()
		local v: any = reference[ent];
		if v then
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			reference[ent] = nil;
			v:Destroy();
		end;
	end;
	
	Radar = vape:CreateOverlay({
		["Name"] = 'Radar',
		["Icon"] = getcustomasset('velo/assets/new/radaricon.png'),
		["Size"] = UDim2.fromOffset(14, 14),
		["Position"] = UDim2.fromOffset(12, 13),
		["Function"] = function(callback: boolean): void
			if callback then
				Radar:Clean(entitylib.Events.EntityRemoved:Connect(removed));
				for _, v: any in entitylib.List do
					if reference[v] then
						removed(v);
					end;
					added(v);
				end;
				Radar:Clean(entitylib.Events.EntityAdded:Connect(function(ent: any)
					if reference[ent] then
						removed(ent);
					end;
					added(ent);
				end));
				Radar:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
					for ent: any, entityDot: any in reference do
						entityDot.BackgroundColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(PlayerColor["Hue"], PlayerColor["Sat"], PlayerColor["Value"]);
					end;
				end));
				Radar:Clean(runService.RenderStepped:Connect(function()
					for ent: any, entityDot: any in reference do
						if entitylib.isAlive then
							local dt: Vector3 = CFrame.lookAlong(entitylib.character.RootPart.Position, gameCamera.CFrame.LookVector * Vector3.new(1, 0, 1)):PointToObjectSpace(ent.RootPart.Position);
							entityDot.Position = UDim2.fromOffset(Clamp["Enabled"] and math.clamp(108 + dt.X, 2, 214) or 108 + dt.X, Clamp["Enabled"] and math.clamp(108 + dt.Z, 8, 214) or 108 + dt.Z);
						end;
					end;
				end));
			else
				for ent: any in reference do 
					removed(ent); 
				end;
			end;
		end
	});
	Targets = Radar:CreateTargets({
		["Players"] = true,
		["Function"] = function()
			if Radar.Button["Enabled"] then
				Radar.Button:Toggle();
				Radar.Button:Toggle();
			end;
		end
	});
	DotStyle = Radar:CreateDropdown({
		["Name"] = 'Dot Style',
		["List"] = {'Circles', 'Squares'},
		["Function"] = function(val: any)
			for _, dot: any in reference do
				dot.UICorner.CornerRadius = UDim.new(val == 'Circles' and 1 or 0, 0);
			end;
		end
	});
	PlayerColor = Radar:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue: any, sat: any, val: any)
			for ent: any, entityDot: any in reference do
				entityDot.BackgroundColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(hue, sat, val);
			end;
		end
	});
	bkg = Instance.new('Frame');
	bkg.Size = UDim2.fromOffset(216, 216);
	bkg.Position = UDim2.fromOffset(2, 2);
	bkg.BackgroundColor3 = Color3.new();
	bkg.BackgroundTransparency = 0.5;
	bkg.ClipsDescendants = true;
	bkg.Parent = Radar.Children;
	local corner: UICorner = Instance.new('UICorner');
	corner.CornerRadius = UDim.new(0, 8);
	corner.Parent = bkg;
	local stroke: UIStroke = Instance.new('UIStroke');
	stroke.Thickness = 2;
	stroke.Color = Color3.new();
	stroke.Transparency = 0.4;
	stroke.Parent = bkg;
	local line1: Frame = Instance.new('Frame');
	line1.Size = UDim2.new(0, 2, 1, 0);
	line1.Position = UDim2.fromScale(0.5, 0.5);
	line1.AnchorPoint = Vector2.new(0.5, 0.5);
	line1.ZIndex = 0;
	line1.BackgroundColor3 = Color3.new(1, 1, 1);
	line1.BackgroundTransparency = 0.5;
	line1.BorderSizePixel = 0;
	line1.Parent = bkg;
	local line2: any = line1:Clone();
	line2.Size = UDim2.new(1, 0, 0, 2);
	line2.Parent = bkg;
	local bar: Frame = Instance.new('Frame');
	bar.Size = UDim2.new(1, -6, 0, 4);
	bar.Position = UDim2.fromOffset(3, 0);
	bar.BackgroundColor3 = Color3.fromHSV(0.44, 1, 1);
	bar.Parent = bkg;
	local barcorner: UICorner = Instance.new('UICorner');
	barcorner.CornerRadius = UDim.new(0, 8);
	barcorner.Parent = bar;
	Radar:CreateColorSlider({
		["Name"] = 'Bar Color',
		["Function"] = function(hue: any, sat: any, val: any)
			bar.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
		end
	});
	Radar:CreateToggle({
		["Name"] = 'Show Background',
		["Default"] = true,
		["Function"] = function(callback: boolean): void
			bkg.BackgroundTransparency = callback and 0.5 or 1;
			bar.BackgroundTransparency = callback and 0 or 1;
			stroke.Transparency = callback and 0.4 or 1;
		end
	});
	Radar:CreateToggle({
		["Name"] = 'Show Cross',
		["Default"] = true,
		["Function"] = function(callback: boolean): void
			line1.BackgroundTransparency = callback and 0.5 or 1;
			line2.BackgroundTransparency = callback and 0.5 or 1;
		end
	});
	Clamp = Radar:CreateToggle({
		["Name"] = 'Clamp Radar',
		["Default"] = true
	});
end);
	
velo.run(function()
	local Search: table = {["Enabled"] = false};
	local List: table;
	local Color: table;
	local FillTransparency: table;
	local reference: table = {};
	local folder: Folder = Instance.new('Folder');
	folder.Parent = vape.gui;
	
	local add: (v: any) -> () = function(v: any): ()
		if not table.find(List.ListEnabled, v.Name) then return; end;
		if v:IsA('BasePart') or v:IsA('Model') then
			local box: BoxHandleAdornment = Instance.new('BoxHandleAdornment');
			box.AlwaysOnTop = true;
			box.Adornee = v;
			box.Size = v:IsA('Model') and v:GetExtentsSize() or v.Size;
			box.ZIndex = 0;
			box.Transparency = FillTransparency["Value"];
			box.Color3 = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
			box.Parent = folder;
			reference[v] = box;
		end;
	end;
	
	Search = vape.Categories.Render:CreateModule({
		["Name"] = 'Search',
		["Function"] = function(callback: boolean): void
			if callback then
				Search:Clean(workspace.DescendantAdded:Connect(add));
				Search:Clean(workspace.DescendantRemoving:Connect(function(v: any)
					if reference[v] then
						reference[v]:Destroy();
						reference[v] = nil;
					end;
				end));
				
				for _, v: any in workspace:GetDescendants() do
					add(v);
				end;
			else
				folder:ClearAllChildren();
				table.clear(reference);
			end;
		end,
		["Tooltip"] = 'Draws box around selected parts\nAdd parts in Search frame'
	});
	List = Search:CreateTextList({
		["Name"] = 'Parts',
		["Function"] = function()
			if Search["Enabled"] then
				Search:Toggle();
				Search:Toggle();
			end;
		end
	});
	Color = Search:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function(hue: any, sat: any, val: any)
			for _, v: any in reference do
				v.Color3 = Color3.fromHSV(hue, sat, val);
			end;
		end
	});
	FillTransparency = Search:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Function"] = function(val: any)
			for _, v: any in reference do
				v.Transparency = val;
			end;
		end,
		["Decimal"] = 10
	});
end);
	
velo.run(function()
	local SessionInfo: table = {["Enabled"] = false};
	local FontOption: table;
	local TextSize: table;
	local BorderColor: table;
	local Title: table;
	local TitleOffset: table = {};
	local infoholder: Frame;
	local infolabel: TextLabel;
	local infostroke: UIStroke;
	
	SessionInfo = vape:CreateOverlay({
		["Name"] = 'Session Info',
		["Icon"] = getcustomasset('velo/assets/new/textguiicon.png'),
		["Size"] = UDim2.fromOffset(16, 12),
		["Position"] = UDim2.fromOffset(12, 14),
		["Function"] = function(callback: boolean): void
			if callback then
				local teleportedServers: boolean;
				SessionInfo:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
					if not teleportedServers then
						teleportedServers = true;
						queue_on_teleport("shared.vapesessioninfo = '"..httpService:JSONEncode(vape.Libraries.sessioninfo.Objects).."'");
					end;
				end));
	
				if shared.vapesessioninfo then
					for i: any, v: any in httpService:JSONDecode(shared.vapesessioninfo) do
						if vape.Libraries.sessioninfo.Objects[i] and v.Saved then
							vape.Libraries.sessioninfo.Objects[i]["Value"] = v["Value"];
						end;
					end;
				end;
	
				repeat
					if vape.Libraries.sessioninfo then
						local stuff: table = {''};
						if Title["Enabled"] then
							stuff[1] = TitleOffset["Enabled"] and '<b>Session Info</b>\n<font size="4"> </font>' or '<b>Session Info</b>';
						end;
						for i: any, v: any in vape.Libraries.sessioninfo.Objects do
							stuff[v.Index] = i..': '..v.Function(v["Value"]);
						end;
						if not Title["Enabled"] then
							table.remove(stuff, 1);
						end;
						infolabel.Text = table.concat(stuff, '\n');
						infolabel.FontFace = FontOption["Value"];
						infolabel.TextSize = TextSize["Value"];
						local size: any = getfontsize(removeTags(infolabel.Text), infolabel.TextSize, infolabel.FontFace);
						infoholder.Size = UDim2.fromOffset(size.X + 16, size.Y + (Title["Enabled"] and TitleOffset["Enabled"] and 4 or 16));
					end;
					task.wait(1);
				until not SessionInfo.Button or not SessionInfo.Button["Enabled"];
			end;
		end
	});
	FontOption = SessionInfo:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Arial'
	});
	SessionInfo:CreateColorSlider({
		["Name"] = 'Background Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue: any, sat: any, val: any, opacity: any)
			infoholder.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			infoholder.BackgroundTransparency = 1 - opacity;
		end
	});
	BorderColor = SessionInfo:CreateColorSlider({
		["Name"] = 'Border Color',
		["Function"] = function(hue: any, sat: any, val: any, opacity: any)
			infostroke.Color = Color3.fromHSV(hue, sat, val);
			infostroke.Transparency = 1 - opacity;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	TextSize = SessionInfo:CreateSlider({
		["Name"] = 'Text Size',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 16
	});
	Title = SessionInfo:CreateToggle({
		["Name"] = 'Title',
		["Function"] = function(callback: boolean): void
			if TitleOffset.Object then
				TitleOffset.Object.Visible = callback;
			end;
		end,
		["Default"] = true
	});
	TitleOffset = SessionInfo:CreateToggle({
		["Name"] = 'Offset',
		["Default"] = true,
		["Darker"] = true
	});
	SessionInfo:CreateToggle({
		["Name"] = 'Border',
		["Function"] = function(callback: boolean): void
			infostroke["Enabled"] = callback;
			BorderColor.Object.Visible = callback;
		end
	});
	infoholder = Instance.new('Frame');
	infoholder.BackgroundColor3 = Color3.new();
	infoholder.BackgroundTransparency = 0.5;
	infoholder.Parent = SessionInfo.Children;
	vape:Clean(SessionInfo.Children:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
		if vape.ThreadFix then 
			setthreadidentity(8); 
		end;
		local newside: boolean = SessionInfo.Children.AbsolutePosition.X > (vape.gui.AbsoluteSize.X / 2);
		infoholder.Position = UDim2.fromScale(newside and 1 or 0, 0);
		infoholder.AnchorPoint = Vector2.new(newside and 1 or 0, 0);
	end));
	local sessioninfocorner: UICorner = Instance.new('UICorner');
	sessioninfocorner.CornerRadius = UDim.new(0, 5);
	sessioninfocorner.Parent = infoholder;
	infolabel = Instance.new('TextLabel');
	infolabel.Size = UDim2.new(1, -16, 1, -16);
	infolabel.Position = UDim2.fromOffset(8, 8);
	infolabel.BackgroundTransparency = 1;
	infolabel.TextXAlignment = Enum.TextXAlignment.Left;
	infolabel.TextYAlignment = Enum.TextYAlignment.Top;
	infolabel.TextSize = 16;
	infolabel.TextColor3 = Color3.new(1, 1, 1);
	infolabel.TextStrokeColor3 = Color3.new();
	infolabel.TextStrokeTransparency = 0.8;
	infolabel.Font = Enum.Font.Arial;
	infolabel.RichText = true;
	infolabel.Parent = infoholder;
	infostroke = Instance.new('UIStroke');
	infostroke["Enabled"] = false;
	infostroke.Color = Color3.fromHSV(0.44, 1, 1);
	infostroke.Parent = infoholder;
	addBlur(infoholder);
	vape.Libraries.sessioninfo = {
		["Objects"] = {},
		["AddItem"] = function(self: any, name: any, startvalue: any, func: any, saved: any)
			func, saved = func or function(val: any) return val; end, saved == nil or saved;
			self.Objects[name] = {["Function"] = func, ["Saved"] = saved, ["Value"] = startvalue or 0, ["Index"] = getTableSize(self.Objects) + 2};
			return {
				["Increment"] = function(_, val: any)
					self.Objects[name]["Value"] += (val or 1);
				end
			};
		end
	};
	vape.Libraries.sessioninfo:AddItem('Time Played', os.clock(), function(value: any) 
		return os.date('!%X', math.floor(os.clock() - value)); 
	end);
end);
	
velo.run(function()
	local Tracers: table = {["Enabled"] = false};
	local Targets: table;
	local Color: table;
	local Transparency: table;
	local StartPosition: table;
	local EndPosition: table;
	local Teammates: table;
	local DistanceColor: table;
	local Distance: table;
	local DistanceLimit: table;
	local Behind: table;
	local reference: table = {};
	
	local added: (ent: any) -> () = function(ent: any): ()
		if not Targets.Players["Enabled"] and ent.Player then return; end;
		if not Targets.NPCs["Enabled"] and ent.NPC then return; end;
		if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return; end;
		if vape.ThreadFix then
			setthreadidentity(8);
		end;
	
		local entityTracer: any = Drawing.new('Line');
		entityTracer.Thickness = 1;
		entityTracer.Transparency = 1 - Transparency["Value"];
		entityTracer.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
		reference[ent] = entityTracer;
	end;
	
	local removed: (ent: any) -> () = function(ent: any): ()
		local v: any = reference[ent];
		if v then
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			reference[ent] = nil;
			pcall(function()
				v.Visible = false;
				v:Remove();
			end);
		end;
	end;
	
	local colorFunc: (hue: any, sat: any, val: any) -> () = function(hue: any, sat: any, val: any): ()
		if DistanceColor["Enabled"] then return; end;
		local tracerColor: Color3 = Color3.fromHSV(hue, sat, val);
		for ent: any, entityTracer: any in reference do
			entityTracer.Color = entitylib.getEntityColor(ent) or tracerColor;
		end;
	end;
	
	local loop: () -> () = function(): ()
		local screenSize: Vector2 = vape.gui.AbsoluteSize;
		local startVector: Vector2 = StartPosition["Value"] == 'Mouse' and inputService:GetMouseLocation() or Vector2.new(screenSize.X / 2, (StartPosition["Value"] == 'Middle' and screenSize.Y / 2 or screenSize.Y));
	
		for ent: any, entityTracer: any in reference do
			local distance: any = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude;
			if Distance["Enabled"] and distance then
				if distance < DistanceLimit["ValueMin"] or distance > DistanceLimit["ValueMax"] then
					entityTracer.Visible = false;
					continue;
				end;
			end;
			
			local pos: any = ent[EndPosition["Value"] == 'Torso' and 'RootPart' or 'Head'].Position;
			local rootPos: Vector3, rootVis: boolean = gameCamera:WorldToViewportPoint(pos);
			if not rootVis and Behind["Enabled"] then
				local tempPos: Vector3 = gameCamera.CFrame:PointToObjectSpace(pos);
				tempPos = CFrame.Angles(0, 0, (math.atan2(tempPos.Y, tempPos.X) + math.pi)):VectorToWorldSpace((CFrame.Angles(0, math.rad(89.9), 0):VectorToWorldSpace(Vector3.new(0, 0, -1))));
				rootPos = gameCamera:WorldToViewportPoint(gameCamera.CFrame:pointToWorldSpace(tempPos));
				rootVis = true;
			end;
			
			local endVector: Vector2 = Vector2.new(rootPos.X, rootPos.Y);
			entityTracer.Visible = rootVis;
			entityTracer.From = startVector;
			entityTracer.To = endVector;
			if DistanceColor["Enabled"] and distance then
				entityTracer.Color = Color3.fromHSV(math.min((distance / 128) / 2.8, 0.4), 0.89, 0.75);
			end;
		end;
	end;
	
	Tracers = vape.Categories.Render:CreateModule({
		["Name"] = 'Tracers',
		["Function"] = function(callback: boolean): void
			if callback then
				Tracers:Clean(entitylib.Events.EntityRemoved:Connect(removed));
				for _, v: any in entitylib.List do
					if reference[v] then
						removed(v);
					end;
					added(v);
				end;
				Tracers:Clean(entitylib.Events.EntityAdded:Connect(function(ent: any)
					if reference[ent] then
						removed(ent);
					end;
					added(ent);
				end));
				Tracers:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
					colorFunc(Color["Hue"], Color["Sat"], Color["Value"]);
				end));
				Tracers:Clean(runService.RenderStepped:Connect(loop));
			else
				for i: any in reference do
					removed(i);
				end;
			end;
		end,
		["Tooltip"] = 'Renders tracers on players.'
	});
	Targets = Tracers:CreateTargets({
		["Players"] = true,
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle();
				Tracers:Toggle();
			end;
		end
	});
	StartPosition = Tracers:CreateDropdown({
		["Name"] = 'Start Position',
		["List"] = {'Middle', 'Bottom', 'Mouse'},
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle();
				Tracers:Toggle();
			end;
		end
	});
	EndPosition = Tracers:CreateDropdown({
		["Name"] = 'End Position',
		["List"] = {'Head', 'Torso'},
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle();
				Tracers:Toggle();
			end;
		end
	});
	Color = Tracers:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue: any, sat: any, val: any)
			if Tracers["Enabled"] and colorFunc then
				colorFunc(hue, sat, val);
			end;
		end
	});
	Transparency = Tracers:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Function"] = function(val: any)
			for _, tracer: any in reference do
				tracer.Transparency = 1 - val;
			end;
		end,
		["Decimal"] = 10
	});
	DistanceColor = Tracers:CreateToggle({
		["Name"] = 'Color by distance',
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle();
				Tracers:Toggle();
			end;
		end
	});
	Distance = Tracers:CreateToggle({
		["Name"] = 'Distance Check',
		["Function"] = function(callback: boolean): void
			DistanceLimit.Object.Visible = callback;
		end
	});
	DistanceLimit = Tracers:CreateTwoSlider({
		["Name"] = 'Player Distance',
		["Min"] = 0,
		["Max"] = 256,
		["DefaultMin"] = 0,
		["DefaultMax"] = 64,
		["Darker"] = true,
		["Visible"] = false
	});
	Behind = Tracers:CreateToggle({
		["Name"] = 'Behind',
		["Default"] = true
	});
	Teammates = Tracers:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle();
				Tracers:Toggle();
			end;
		end,
		["Default"] = true,
		["Tooltip"] = 'Hides teammates & non targetable entities'
	});
end);
	
velo.run(function()
	local Waypoints: table = {["Enabled"] = false};
	local FontOption: table;
	local List: table;
	local Color: table;
	local Scale: table;
	local Background: table;
	waypointFolder = Instance.new('Folder');
	waypointFolder.Parent = vape.gui;
	
	Waypoints = vape.Categories.Render:CreateModule({
		["Name"] = 'Waypoints',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v: any in List.ListEnabled do
					local split: {string} = v:split('/');
					local tagSize: any = getfontsize(removeTags(split[2]), 14 * Scale["Value"], FontOption["Value"], Vector2.new(100000, 100000));
					local billboard: BillboardGui = Instance.new('BillboardGui');
					billboard.Size = UDim2.fromOffset(tagSize.X + 8, tagSize.Y + 7);
					billboard.StudsOffsetWorldSpace = Vector3.new(unpack(split[1]:split(',')));
					billboard.AlwaysOnTop = true;
					billboard.Parent = waypointFolder;
					local tag: TextLabel = Instance.new('TextLabel');
					tag.BackgroundColor3 = Color3.new();
					tag.BorderSizePixel = 0;
					tag.Visible = true;
					tag.RichText = true;
					tag.FontFace = FontOption["Value"];
					tag.TextSize = 14 * Scale["Value"];
					tag.BackgroundTransparency = Background["Value"];
					tag.Size = billboard.Size;
					tag.Text = split[2];
					tag.TextColor3 = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
					tag.Parent = billboard;
				end;
			else
				waypointFolder:ClearAllChildren();
			end;
		end,
		["Tooltip"] = 'Mark certain spots with a visual indicator'
	});
	FontOption = Waypoints:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Arial',
		["Function"] = function()
			if Waypoints["Enabled"] then
				Waypoints:Toggle();
				Waypoints:Toggle();
			end;
		end,
	});
	List = Waypoints:CreateTextList({
		["Name"] = 'Points',
		["Placeholder"] = 'x, y, z/name',
		["Function"] = function()
			if Waypoints["Enabled"] then
				Waypoints:Toggle();
				Waypoints:Toggle();
			end;
		end
	});
	Waypoints:CreateButton({
		["Name"] = 'Add current position',
		["Function"] = function()
			if entitylib.isAlive then
				local pos: any = entitylib.character.RootPart.Position // 1;
				List:ChangeValue(pos.X..','..pos.Y..','..pos.Z..'/Waypoint '..(#List.List + 1));
			end;
		end
	});
	Color = Waypoints:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function(hue: any, sat: any, val: any)
			for _, v: any in waypointFolder:GetChildren() do
				v.TextLabel.TextColor3 = Color3.fromHSV(hue, sat, val);
			end;
		end
	});
	Scale = Waypoints:CreateSlider({
		["Name"] = 'Scale',
		["Function"] = function()
			if Waypoints["Enabled"] then
				Waypoints:Toggle();
				Waypoints:Toggle();
			end;
		end,
		["Default"] = 1,
		["Min"] = 0.1,
		["Max"] = 1.5,
		["Decimal"] = 10
	});
	Background = Waypoints:CreateSlider({
		["Name"] = 'Transparency',
		["Function"] = function()
			if Waypoints["Enabled"] then
				Waypoints:Toggle();
				Waypoints:Toggle();
			end;
		end,
		["Default"] = 0.5,
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10
	});
	
end);
	
velo.run(function()
	local AnimationPlayer: table;
	local IDBox: table;
	local Priority: table;
	local Speed: table;
	local NoFetch: table;
	local track: any, anim: Animation;
	
	local playAnimation: (char: any) -> () = function(char: any): ()
		local oldTrack: any = track;
		if oldTrack then
			track = nil;
			oldTrack:Stop();
		end;
	
		local success: boolean, result: any = pcall(function()
			track = char.Humanoid.Animator:LoadAnimation(anim);
		end);
	
		if success then
			local comp: any = track;
			track.Priority = Enum.AnimationPriority[Priority["Value"]];
			track:Play();
			track:AdjustSpeed(Speed["Value"]);
	
			AnimationPlayer:Clean(track.Stopped:Connect(function()
				if comp == track then
					track:Play();
				end;
			end));
		else
			notif('AnimationPlayer', 'failed to load anim : '..(result or 'invalid animation id'), 5, 'warning');
		end;
	end;
	
	AnimationPlayer = vape.Categories.Utility:CreateModule({
		["Name"] = 'AnimationPlayer',
		["Function"] = function(callback: boolean)
			if callback then
				local success: boolean, id: any = pcall(function()
					if NoFetch["Enabled"] then
						return;
					end;
	
					local info: any = marketplaceService:GetProductInfo(tonumber(IDBox["Value"]));
					if not info or info.AssetTypeId ~= 24 then
						return string.match(game:GetObjects('rbxassetid://'..IDBox["Value"])[1].AnimationId, '%?id=(%d+)');
					else
						return IDBox["Value"];
					end;
				end);
	
				anim = Instance.new('Animation');
				anim.AnimationId = 'rbxassetid://'..(success and id or IDBox["Value"]);
	
				if entitylib.isAlive then
					playAnimation(entitylib.character);
				end;
	
				AnimationPlayer:Clean(entitylib.Events.LocalAdded:Connect(playAnimation));
				AnimationPlayer:Clean(anim);
			else
				if track then
					track:Stop();
				end;
			end;
		end,
		["Tooltip"] = 'Plays a specific animation of your choosing at a certain speed'
	});
	IDBox = AnimationPlayer:CreateTextBox({
		["Name"] = 'Animation',
		["Placeholder"] = 'anim (num only)',
		["Function"] = function(enter: any)
			if enter and AnimationPlayer["Enabled"] then
				AnimationPlayer:Toggle();
				AnimationPlayer:Toggle();
			end;
		end
	});
	local prio: table = {'Action4'};
	for _, v: any in Enum.AnimationPriority:GetEnumItems() do
		if v.Name ~= 'Action4' then
			table.insert(prio, v.Name);
		end;
	end;
	Priority = AnimationPlayer:CreateDropdown({
		["Name"] = 'Priority',
		["List"] = prio,
		["Function"] = function(val: any)
			if track then
				track.Priority = Enum.AnimationPriority[val];
			end;
		end
	});
	Speed = AnimationPlayer:CreateSlider({
		["Name"] = 'Speed',
		["Function"] = function(val: any)
			if track then
				track:AdjustSpeed(val);
			end;
		end,
		["Min"] = 0.1,
		["Max"] = 2,
		["Default"] = 1,
		["Decimal"] = 10
	});
	NoFetch = AnimationPlayer:CreateToggle({
		["Name"] = 'No Fetch',
		["Tooltip"] = 'Do not attempt to fetch the asset with GetObjects',
		["Default"] = true
	});
end);
	
velo.run(function()
	local AntiRagdoll: table = {["Enabled"] = false};
	
	AntiRagdoll = vape.Categories.Utility:CreateModule({
		["Name"] = 'AntiRagdoll',
		["Function"] = function(callback: boolean): void
			if entitylib.isAlive then
				entitylib.character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not callback);
			end;
			if callback then
				AntiRagdoll:Clean(entitylib.Events.LocalAdded:Connect(function(char: any)
					char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false);
				end));
			end;
		end,
		["Tooltip"] = 'Prevents you from getting knocked down in a ragdoll state'
	});
end);
	
velo.run(function()
	local AutoRejoin: table = {["Enabled"] = false};
	local Sort: table;
	
	AutoRejoin = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoRejoin',
		["Function"] = function(callback: boolean): void
			if callback then
				local check: boolean;
				AutoRejoin:Clean(guiService.ErrorMessageChanged:Connect(function(str: any)
					if (not check or guiService:GetErrorCode() ~= Enum.ConnectionError.DisconnectLuaKick) and guiService:GetErrorCode() ~= Enum.ConnectionError.DisconnectConnectionLost and not str:lower():find('ban') then
						check = true;
						serverHop(nil, Sort["Value"]);
					end;
				end));
			end;
		end,
		["Tooltip"] = 'Automatically rejoins into a new server if you get disconnected / kicked'
	});
	Sort = AutoRejoin:CreateDropdown({
		["Name"] = 'Sort',
		["List"] = {'Descending', 'Ascending'},
		["Tooltip"] = 'Descending - Prefers full servers\nAscending - Prefers empty servers'
	});
end);
	
velo.run(function()
	local Blink: table;
	local Type: table;
	local Fake: table;
	local AutoSend: table;
	local AutoSendLength: table;
	local folder: Folder = Instance.new('Folder');
	folder.Parent = vape.holder;
	local oldphys: string, oldsend: string;
	local boxes: table = {};
	local whitelist: table = {
		["Head"] = true,
		["Torso"] = true,
		["UpperTorso"] = true,
		["LowerTorso"] = true,
		['Left Arm'] = true,
		['Right Arm'] = true,
		['Left Leg'] = true,
		['Right Leg'] = true,
		["LeftUpperArm"] = true,
		["RightUpperArm"] = true,
		["LeftLowerArm"] = true,
		["RightLowerArm"] = true,
		["LeftHand"] = true,
		["RightHand"] = true,
		["LeftUpperLeg"] = true,
		["RightUpperLeg"] = true,
		["LeftLowerLeg"] = true,
		["RightLowerLeg"] = true,
		["LeftFoot"] = true,
		["RightFoot"] = true
	};
	
	local updateBoxes: () -> () = function(): ()
		if Blink["Enabled"] and Fake["Enabled"] and entitylib.isAlive then
			for _, part: any in entitylib.character.Character:GetChildren() do
				if part:IsA('BasePart') and whitelist[part.Name] then
					if not boxes[part.Name] then
						local box: Instance = Instance.new(part.Name == 'Head' and 'SphereHandleAdornment' or 'BoxHandleAdornment');
						if part.Name == 'Head' then
							box.Radius = 0.75;
						else
							box.Size = part.Size;
						end;
	
						box.AlwaysOnTop = true;
						box.Adornee = workspace;
						box.ZIndex = 10;
						box.Transparency = 0.5;
						box.Parent = folder;
						boxes[part.Name] = box;
					end;
	
					local box: any = boxes[part.Name];
					box.CFrame = workspace:GetModelCFrame():ToObjectSpace(part.CFrame);
				end;
			end;
		end;
	end;
	
	Blink = vape.Categories.Utility:CreateModule({
		["Name"] = 'Blink',
		["Function"] = function(callback: boolean)
			if callback then
				updateBoxes();
				local teleported: boolean;
				local timetaken: number = os.clock();
				Blink:Clean(lplr.OnTeleport:Connect(function()
					setfflag('PhysicsSenderMaxBandwidthBps', '38760');
					setfflag('DataSenderRate', '60');
					teleported = true;
				end));
	
				repeat
					local physicsrate: string, senderrate: string = '0', Type["Value"] == 'All' and '-1' or '60';
					if AutoSend["Enabled"] and (os.clock() - timetaken) > AutoSendLength["Value"] then
						updateBoxes();
						physicsrate, senderrate = '38760', '60';
						timetaken = os.clock();
					end;
	
					if physicsrate ~= oldphys or senderrate ~= oldsend then
						setfflag('PhysicsSenderMaxBandwidthBps', physicsrate);
						setfflag('DataSenderRate', senderrate);
						oldphys, oldsend = physicsrate, senderrate;
					end;
	
					task.wait(physicsrate == '38760' and 0.1 or 0.03);
				until (not Blink["Enabled"] and not teleported);
			else
				if setfflag then
					setfflag('PhysicsSenderMaxBandwidthBps', '38760');
					setfflag('DataSenderRate', '60');
				end;
	
				folder:ClearAllChildren();
				table.clear(boxes);
	
				oldphys, oldsend = nil, nil;
			end;
		end,
		["Tooltip"] = 'Chokes packets until disabled.'
	});
	Type = Blink:CreateDropdown({
		["Name"] = 'Type',
		["List"] = {'Movement Only', 'All'},
		["Tooltip"] = 'Movement Only - Only chokes movement packets\nAll - Chokes remotes & movement'
	});
	Fake = Blink:CreateToggle({
		["Name"] = 'Spawn fake',
		["Function"] = updateBoxes,
		["Tooltip"] = 'Spawns chams from where you started/are on the servers side.'
	});
	AutoSend = Blink:CreateToggle({
		["Name"] = 'Auto send',
		["Function"] = function(callback: boolean)
			AutoSendLength.Object.Visible = callback;
		end,
		["Tooltip"] = 'Automatically sends packets after the designated time limit has passed'
	});
	AutoSendLength = Blink:CreateSlider({
		["Name"] = 'Send threshold',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Tooltip"] = 'Allows you to choke your packets for a custom set time limit.\nAfter the time limit has passed, all packets will be sent.',
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
end);
	
velo.run(function()
	local ChatSpammer: table;
	local Lines: table;
	local Mode: table;
	local Delay: table;
	local Hide: table;
	local randomList: table = {};
	local oldchat: any;
	
	ChatSpammer = vape.Categories.Utility:CreateModule({
		["Name"] = 'ChatSpammer',
		["Function"] = function(callback: boolean)
			if callback then
				if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
					if Hide["Enabled"] and coreGui:FindFirstChild('ExperienceChat') then
						ChatSpammer:Clean(coreGui.ExperienceChat.appLayout.chatWindow.contentFrame.scrollingView.bottomLockedScrollView.scrollView.ChildAdded:Connect(function(msg: any)
							if msg.Name:sub(1, 2) == '0-' and msg.TextMessage.BodyText.Text == '<font color="#d4d4d4">You must wait before sending another message.</font>' then
								msg.Visible = false;
							end;
						end));
					end;
				elseif replicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
					if Hide["Enabled"] then
						oldchat = hookfunction(getconnections(replicatedStorage.DefaultChatSystemChatEvents.OnNewSystemMessage.OnClientEvent)[1].Function, function(data: any, ...: any)
							if data.Message:find('ChatFloodDetector') then return; end;
							return oldchat(data, ...);
						end);
					end;
				else
					notif('ChatSpammer', 'unsupported chat', 5, 'warning');
					ChatSpammer:Toggle();
					return;
				end;
	
				local index: number = 1;
				repeat
					local message: string = 'vxpe on top';
					if #Lines.ListEnabled > 0 then
						if Mode["Value"] == 'Order' then
							message = Lines.ListEnabled[index] or Lines.ListEnabled[1];
							index = (index % #Lines.ListEnabled) + 1;
						else
							if #randomList <= 0 then
								randomList = table.clone(Lines.ListEnabled);
							end;
	
							local entry: number = Random.new():NextInteger(1, #randomList);
							message = randomList[entry];
							table.remove(randomList, entry);
						end;
					end;
	
					if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(message);
					else
						replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, 'All');
					end;
	
					task.wait(Delay["Value"]);
				until not ChatSpammer["Enabled"];
			else
				if oldchat then
					hookfunction(getconnections(replicatedStorage.DefaultChatSystemChatEvents.OnNewSystemMessage.OnClientEvent)[1].Function, oldchat);
				end;
			end;
		end,
		["Tooltip"] = 'Automatically types in chat'
	});
	Lines = ChatSpammer:CreateTextList({
		["Name"] = 'Lines',
		["Function"] = function()
			table.clear(randomList);
		end
	});
	Mode = ChatSpammer:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Random', 'Order'}
	});
	Delay = ChatSpammer:CreateSlider({
		["Name"] = 'Delay',
		["Min"] = 0.1,
		["Max"] = 10,
		["Default"] = 1,
		["Decimal"] = 10,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end
	});
	Hide = ChatSpammer:CreateToggle({
		["Name"] = 'Hide Flood Message',
		["Default"] = true,
		["Function"] = function()
			if ChatSpammer["Enabled"] then
				ChatSpammer:Toggle();
				ChatSpammer:Toggle();
			end;
		end
	});
end);
	
velo.run(function()
	local Disabler: table = {["Enabled"] = false};
	
	local characterAdded: (char: Model?) -> () = function(char: Model?): ()
		for _, v: any in getconnections(char.RootPart:GetPropertyChangedSignal('CFrame')) do
			hookfunction(v.Function, function() end);
		end;
		for _, v: any in getconnections(char.RootPart:GetPropertyChangedSignal('Velocity')) do
			hookfunction(v.Function, function() end);
		end;
	end;
	
	Disabler = vape.Categories.Utility:CreateModule({
		["Name"] = 'Disabler',
		["Function"] = function(callback: boolean): void
			if callback then
				Disabler:Clean(entitylib.Events.LocalAdded:Connect(characterAdded));
				if entitylib.isAlive then
					characterAdded(entitylib.character);
				end;
			end;
		end,
		["Tooltip"] = 'Disables GetPropertyChangedSignal detections for movement'
	});
end);

velo.run(function()
	local HumSpoofer: table;
	local State: table;
	local ReplaceJump: table;
	local Jump: table;
	
	HumSpoofer = vape.Categories.Utility:CreateModule({
		["Name"] = 'HumSpoofer',
		["Function"] = function(callback: boolean)
			if callback then
				HumSpoofer:Clean(runService.Heartbeat:Connect(function()
					if entitylib.isAlive then
						local hum: any = entitylib.character.Humanoid;
						sethiddenproperty(hum, 'NetworkHumanoidState', Enum.HumanoidStateType[State["Value"]]["Value"]);
	
						if ReplaceJump["Enabled"] then
							sethiddenproperty(hum, 'JumpReplicate', Jump["Enabled"]);
						end;
					end;
				end));
			end;
		end,
		["Tooltip"] = 'Spoof humanoid and jump states on the server.'
	});
	local states: table = {};
	for _, v: any in Enum.HumanoidStateType:GetEnumItems() do
		if v.Name ~= 'None' then
			table.insert(states, v.Name);
		end;
	end;
	State = HumSpoofer:CreateDropdown({
		["Name"] = 'Humanoid State',
		["List"] = states
	});
	ReplaceJump = HumSpoofer:CreateToggle({
		["Name"] = 'Replace Jump',
		["Function"] = function(callback: boolean)
			Jump.Object.Visible = callback;
		end,
		["Tooltip"] = 'Replace the current jump state on the server'
	});
	Jump = HumSpoofer:CreateToggle({
		["Name"] = 'Jump State',
		["Visible"] = false,
		["Darker"] = true
	});
end);

velo.run(function()
	local LogSpammer: table;
	local Message: table;
	local rand: Random = Random.new();
	
	LogSpammer = vape.Categories.Utility:CreateModule({
		["Name"] = 'LogSpammer',
		["Function"] = function(callback: boolean)
			if callback then
				local useSignal: boolean = true;
	
				repeat
					if entitylib.isAlive then
						local animator: Animator? = entitylib.character.Humanoid:FindFirstChildWhichIsA('Animator');
	
						if animator then
							if replicatesignal and useSignal then
								useSignal = pcall(replicatesignal, animator.OnCombinedUpdate, ('http=507770677'..utf8.char(rand:NextInteger(1, 65535))..Message["Value"]):sub(1, 256), true, 0, 0.0001, 0, 0, Enum.AnimationPriority.Core, true, 255);
							else
								local anim: Animation = Instance.new('Animation');
								anim.AnimationId = ('http=507770677'..utf8.char(rand:NextInteger(1, 65535))..Message["Value"]):sub(1, 256);
								local track: AnimationTrack = animator:LoadAnimation(anim);
								track:Play(0, 0.0001, 0);
							end;
						end;
					end;
	
					task.wait();
				until not LogSpammer["Enabled"];
			end;
		end,
		["Tooltip"] = 'Use animations to spam the console of people ingame'
	});
	Message = LogSpammer:CreateTextBox({
		["Name"] = 'Message',
		["Placeholder"] = 'text (242 character limit)'
	});
end);

velo.run(function()
	vape.Categories.Utility:CreateModule({
		["Name"] = 'Panic',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v: any in vape.Modules do
					if v["Enabled"] then
						v:Toggle();
					end;
				end;
			end;
		end,
		["Tooltip"] = 'Disables all currently enabled modules'
	});
end);
	
velo.run(function()
	local Rejoin: table = {["Enabled"] = false};
	Rejoin = vape.Categories.Utility:CreateModule({
		["Name"] = 'Rejoin',
		["Function"] = function(callback: boolean): void
			if callback then
				notif('Rejoin', 'Rejoining...', 5);
				Rejoin:Toggle();
				if playersService.NumPlayers > 1 then
					teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId);
				else
					teleportService:Teleport(game.PlaceId);
				end;
			end;
		end,
		["Tooltip"] = 'Rejoins the server'
	});
end);
	
velo.run(function()
	local ServerHop: table = {["Enabled"] = false};
	local Sort: any;
	ServerHop = vape.Categories.Utility:CreateModule({
		["Name"] = 'ServerHop',
		["Function"] = function(callback: boolean): void
			if callback then
				ServerHop:Toggle();
				serverHop(nil, Sort["Value"]);
			end;
		end,
		["Tooltip"] = 'Teleports into a unique server'
	});
	Sort = ServerHop:CreateDropdown({
		["Name"] = 'Sort',
		["List"] = {'Full', 'Small'},
		["Tooltip"] = 'Descending - Prefers full servers\nAscending - Prefers empty servers'
	});
	ServerHop:CreateButton({
		["Name"] = 'Rejoin Previous Server',
		["Function"] = function()
			notif('ServerHop', shared.vapeserverhopprevious and 'Rejoining previous server...' or 'Cannot find previous server', 5);
			if shared.vapeserverhopprevious then
				teleportService:TeleportToPlaceInstance(game.PlaceId, shared.vapeserverhopprevious);
			end;
		end
	});
end);
	
velo.run(function()
	local StaffDetector: table = {["Enabled"] = false};
	local Mode: table = {};
	local Profile: table = {};
	local Users: table = {};
	local Group: table = {};
	local Role: table = {};
	
	local getRole: (plr: Player?, id: string?) -> any = function(plr: Player?, id: string?): any
		local suc: boolean, res: string?;
		for _ = 1, 3 do
			suc, res = pcall(function()
				return plr:GetRankInGroup(id);
			end);
			if suc then break; end;
		end;
		return suc and res or 0;
	end;
	
	local getLowestStaffRole: (roles: string?) -> any = function(roles: string?): any
		local highest: number? = math.huge;
		for _, v: any in roles do
			local low: string? = v.Name:lower();
			if (low:find('admin') or low:find('mod') or low:find('dev')) and v.Rank < highest then
				highest = v.Rank;
			end;
		end;
		return highest;
	end;
	
	local playerAdded: (plr: Player?) -> () = function(plr: Player?): ()
		if not vape.Loaded then 
			repeat task.wait(); until vape.Loaded;
		end;
	
		local user: number? = table.find(Users.ListEnabled, tostring(plr.UserId));
		if user or getRole(plr, tonumber(Group["Value"]) or 0) >= (tonumber(Role["Value"]) or 1) then
			notif('StaffDetector', 'Staff Detected ('..(user and 'blacklisted_user' or 'staff_role')..'): '..plr.Name, 60, 'alert');
			whitelist.customtags[plr.Name] = {{["text"] = 'GAME STAFF', ["color"] = Color3.new(1, 0, 0)}};
			
			if Mode["Value"] == 'Uninject' then
				task.spawn(function() 
					vape:Uninject();
				end);
				game:GetService('StarterGui'):SetCore('SendNotification', {
					["Title"] = 'StaffDetector',
					["Text"] = 'Staff Detected\n'..plr.Name,
					["Duration"] = 60,
				});
			elseif Mode["Value"] == 'ServerHop' then
				serverHop();
			elseif Mode["Value"] == 'Profile' then
				vape.Save = function() end;
				if vape.Profile ~= Profile["Value"] then
					vape.Profile = Profile["Value"];
					vape:Load(true, Profile["Value"]);
				end;
			elseif Mode["Value"] == 'AutoConfig' then
				vape.Save = function() end;
				for _, v: any in vape.Modules do
					if v["Enabled"] then
						v:Toggle();
					end;
				end;
			end;
		end;
	end;
	
	StaffDetector = vape.Categories.Utility:CreateModule({
		["Name"] = 'StaffDetector',
		["Function"] = function(callback: boolean): void
			if callback then
				if Group["Value"] == '' or Role["Value"] == '' then
					local placeinfo: number? = {["Creator"] = {["CreatorTargetId"] = tonumber(Group["Value"])}};
					if Group["Value"] == '' then
						placeinfo = marketplaceService:GetProductInfo(game.PlaceId);
						if placeinfo.Creator.CreatorType ~= 'Group' then
							local desc: string? = placeinfo.Description:split('\n');
							for _, str: any in desc do
								local _: any, begin: any = str:find('roblox.com/groups/');
								if begin then
									local endof: string? = str:find('/', begin + 1);
									placeinfo = {["Creator"] = {
										["CreatorType"] = 'Group', 
										["CreatorTargetId"] = str:sub(begin + 1, endof - 1)
									}};
								end;
							end;
						end;
	
						if placeinfo.Creator.CreatorType ~= 'Group' then
							notif('StaffDetector', 'Automatic Setup Failed (no group detected)', 60, 'warning');
							return;
						end;
					end;
	
					local groupinfo: any = groupService:GetGroupInfoAsync(placeinfo.Creator.CreatorTargetId);
					Group:SetValue(placeinfo.Creator.CreatorTargetId);
					Role:SetValue(getLowestStaffRole(groupinfo.Roles));
				end;
				
				if Group["Value"] == '' or Role["Value"] == '' then 
					return;
				end;
				
				StaffDetector:Clean(playersService.PlayerAdded:Connect(playerAdded));
				for _, v: any in playersService:GetPlayers() do
					task.spawn(playerAdded, v);
				end;
			end;
		end,
		["Tooltip"] = 'Detects people with a staff rank ingame'
	});
	Mode = StaffDetector:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Uninject', 'ServerHop', 'Profile', 'AutoConfig', 'Notify'},
		["Function"] = function(val: any)
			if Profile.Object then
				Profile.Object.Visible = val == 'Profile';
			end;
		end;
	});
	Profile = StaffDetector:CreateTextBox({
		["Name"] = 'Profile',
		["Default"] = 'default',
		["Darker"] = true,
		["Visible"] = false
	});
	Users = StaffDetector:CreateTextList({
		["Name"] = 'Users',
		["Placeholder"] = 'player (userid)'
	});
	Group = StaffDetector:CreateTextBox({
		["Name"] = 'Group',
		["Placeholder"] = 'Group Id'
	});
	Role = StaffDetector:CreateTextBox({
		["Name"] = 'Role',
		["Placeholder"] = 'Role Rank'
	});
end);

velo.run(function()
	local connections: table? = {};
	vape.Categories.World:CreateModule({
		["Name"] = 'Anti-AFK',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v: any in getconnections(lplr.Idled) do
					table.insert(connections, v);
					v:Disable();
				end;
			else
				for _, v: any in connections do
					v:Enable();
				end;
				table.clear(connections);
			end;
		end,
		["Tooltip"] = 'Lets you stay ingame without getting kicked'
	});
end);

velo.run(function()
	local FastProxPrompt: table;
	local Mode: table;
	local Value: table;
	local modified: table = {};
	local thread: any;
	
	FastProxPrompt = vape.Categories.World:CreateModule({
		["Name"] = 'FastProxPrompt',
		["Function"] = function(callback: boolean)
			if callback then
				if Mode["Value"] == 'Signal' then
					FastProxPrompt:Clean(proxService.PromptButtonHoldBegan:Connect(function(prompt: any, plr: any)
						if plr == lplr then
							thread = task.delay(prompt.HoldDuration * (Value["Value"] / 100), function()
								fireproximityprompt(prompt);
								thread = nil;
							end);
						end;
					end));
	
					FastProxPrompt:Clean(proxService.PromptButtonHoldEnded:Connect(function(prompt: any, plr: any)
						if plr == lplr and thread then
							task.cancel(thread);
							thread = nil;
						end;
					end));
				else
					FastProxPrompt:Clean(proxService.PromptShown:Connect(function(prompt: any)
						if not modified[prompt] then
							modified[prompt] = prompt.HoldDuration;
						end;
	
						prompt.HoldDuration = modified[prompt] * (Value["Value"] / 100);
					end));
	
					FastProxPrompt:Clean(proxService.PromptHidden:Connect(function(prompt: any)
						if modified[prompt] then
							prompt.HoldDuration = modified[prompt];
							modified[prompt] = nil;
						end;
					end));
				end;
			else
				if thread then
					task.cancel(thread);
					thread = nil;
				end;
	
				for prompt: any, oldDuration: any in modified do
					prompt.HoldDuration = oldDuration;
				end;
	
				table.clear(modified);
			end;
		end,
		["Tooltip"] = 'Allow you to adjust the HoldDuration time of a ProximityPrompt'
	});
	Mode = FastProxPrompt:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Signal', 'Property'},
		["Tooltip"] = 'Signal - Uses fireproximityprompt after the calculated delay\nProperty - Sets the HoldDuration property',
		["Function"] = function()
			if FastProxPrompt["Enabled"] then
				FastProxPrompt:Toggle();
				FastProxPrompt:Toggle();
			end;
		end
	});
	Value = FastProxPrompt:CreateSlider({
		["Name"] = 'Modifier',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 50,
		["Suffix"] = '%',
		["Function"] = function(val: any)
			for prompt: any, oldDuration: any in modified do
				prompt.HoldDuration = oldDuration * (val / 100);
			end;
		end
	});
end);

velo.run(function()
	local Freecam: table = {["Enabled"] = false};
	local Value: table = {};
	local randomkey: any, module: any, old: any = httpService:GenerateGUID(false);
	Freecam = vape.Categories.World:CreateModule({
		["Name"] = 'Freecam',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					task.wait(0.1);
					for _, v: any in getconnections(gameCamera:GetPropertyChangedSignal('CameraType')) do
						if v.Function then
							module = debug.getupvalue(v.Function, 1);
						end;
					end;
				until module or not Freecam["Enabled"];
	
				if module and module.activeCameraController and Freecam["Enabled"] then
					old = module.activeCameraController.GetSubjectPosition;
					local camPos: Vector3? = old(module.activeCameraController) or Vector3.zero;
					module.activeCameraController.GetSubjectPosition = function()
						return camPos;
					end;
	
					Freecam:Clean(runService.PreSimulation:Connect(function(dt: InputObject?)
						if not inputService:GetFocusedTextBox() then
							local forward: any = (inputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0) + (inputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0);
							local side: any = (inputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0) + (inputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0);
							local up: any = (inputService:IsKeyDown(Enum.KeyCode.Q) and -1 or 0) + (inputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0);
							dt = dt * (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and 0.25 or 1);
							camPos = (CFrame.lookAlong(camPos, gameCamera.CFrame.LookVector) * CFrame.new(Vector3.new(side, up, forward) * (Value["Value"] * dt))).Position;
						end;
					end));
	
					contextService:BindActionAtPriority('FreecamKeyboard'..randomkey, function() 
						return Enum.ContextActionResult.Sink; 
					end, false, Enum.ContextActionPriority.High["Value"],
						Enum.KeyCode.W,
						Enum.KeyCode.A,
						Enum.KeyCode.S,
						Enum.KeyCode.D,
						Enum.KeyCode.E,
						Enum.KeyCode.Q,
						Enum.KeyCode.Up,
						Enum.KeyCode.Down
					);
				end;
			else
				pcall(function()
					contextService:UnbindAction('FreecamKeyboard'..randomkey);
				end);
				if module and old then
					module.activeCameraController.GetSubjectPosition = old;
					module = nil;
					old = nil;
				end;
			end;
		end,
		["Tooltip"] = 'Lets you fly and clip through walls freely\nwithout moving your player server-sided.'
	});
	Value = Freecam:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end;
	});
end);
	
velo.run(function()
	local Gravity: table = {["Enabled"] = false};
	local Mode: table = {};
	local Value: table = {};
	local changed: any, old: any = false;
	Gravity = vape.Categories.World:CreateModule({
		["Name"] = 'Gravity',
		["Function"] = function(callback: boolean): void
			if callback then
				if Mode["Value"] == 'Workspace' then
					old = workspace.Gravity;
					workspace.Gravity = Value["Value"];
					Gravity:Clean(workspace:GetPropertyChangedSignal('Gravity'):Connect(function()
						if changed then return; end;
						changed = true;
						old = workspace.Gravity;
						workspace.Gravity = Value["Value"];
						changed = false;
					end));
				else
					Gravity:Clean(runService.PreSimulation:Connect(function(dt: any)
						if entitylib.isAlive and entitylib.character.Humanoid.FloorMaterial == Enum.Material.Air then
							entitylib.character.RootPart.AssemblyLinearVelocity += Vector3.new(0, dt * (workspace.Gravity - Value["Value"]), 0);
						end;
					end));
				end;
			else
				if old then
					workspace.Gravity = old;
					old = nil;
				end;
			end;
		end,
		["Tooltip"] = 'Changes the rate you fall'
	});
	Mode = Gravity:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Workspace', 'Velocity'},
		["Tooltip"] = 'Workspace - Adjusts the gravity for the entire game\nVelocity - Adjusts the local players gravity'
	});
	Value = Gravity:CreateSlider({
		["Name"] = 'Gravity',
		["Min"] = 0,
		["Max"] = 192,
		["Function"] = function(val: any)
			if Gravity["Enabled"] and Mode["Value"] == 'Workspace' then
				changed = true;
				workspace.Gravity = val;
				changed = false;
			end;
		end,
		["Default"] = 192
	});
end);
	
velo.run(function()
	local Parkour: table = {["Enabled"] = false};
	Parkour = vape.Categories.World:CreateModule({
		["Name"] = 'Parkour',
		["Function"] = function(callback: boolean): void
			if callback then 
				local oldfloor: any;
				Parkour:Clean(runService.RenderStepped:Connect(function()
					if entitylib.isAlive then 
						local material: any = entitylib.character.Humanoid.FloorMaterial;
						if material == Enum.Material.Air and oldfloor ~= Enum.Material.Air then 
							entitylib.character.Humanoid.Jump = true;
						end;
						oldfloor = material;
					end;
				end));
			end;
		end,
		["Tooltip"] = 'Automatically jumps after reaching the edge'
	});
end);
	
velo.run(function()
	local rayCheck: RayCastParams? = RaycastParams.new();
	rayCheck.RespectCanCollide = true;
	local module: any, old: any;
	vape.Categories.World:CreateModule({
		["Name"] = 'SafeWalk',
		["Function"] = function(callback: boolean): void
			if callback then
				if not module then
					local suc: boolean? = pcall(function() 
						module = require(lplr.PlayerScripts.PlayerModule).controls;
					end);
					if not suc then module = {}; end;
				end;
				
				old = module.moveFunction;
				module.moveFunction = function(self: any, vec: any, face: any)
					if entitylib.isAlive then
						rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera};
						local root: Humanoid? = entitylib.character.RootPart;
						local movedir: Vector3? = root.Position + vec;
						local ray: RaycastResult? = workspace:Raycast(movedir, Vector3.new(0, -15, 0), rayCheck);
						if not ray then
							local check: any = workspace:Blockcast(root.CFrame, Vector3.new(3, 1, 3), Vector3.new(0, -(entitylib.character.HipHeight + 1), 0), rayCheck);
							if check then
								vec = (check.Instance:GetClosestPointOnSurface(movedir) - root.Position) * Vector3.new(1, 0, 1);
							end;
						end;
					end;
	
					return old(self, vec, face);
				end;
			else
				if module and old then
					module.moveFunction = old;
				end;
			end;
		end,
		["Tooltip"] = 'Prevents you from walking off the edge of parts'
	});
end);

velo.run(function()
	local Wallhop: table;
	local Offset: table;
	local FPSCap: table;
	local params: OverlapParams = OverlapParams.new();
	params.RespectCanCollide = true;
	local oldfps: any;
	local oldvec: any;
	local timeout: number = os.clock();
	local set: any;
	
	local doCheck: () -> () = function(): ()
		if set then
			gameCamera.CFrame = CFrame.new(gameCamera.CFrame.Position.X, gameCamera.CFrame.Position.Y, gameCamera.CFrame.Position.Z, unpack(set, 4, set.n));
			set = nil;
		end;
	
		local hum: any = entitylib.isAlive and entitylib.character.Humanoid;
		if hum and hum.Jump and hum.MoveDirection.Magnitude > 0 then
			local root: any = entitylib.character.RootPart;
			params.CollisionGroup = root.CollisionGroup;
			params.FilterDescendantsInstances = {lplr.Character};
	
			if root.AssemblyLinearVelocity.Y < 0 and hum.FloorMaterial == Enum.Material.Air then
				local feet: any = root.Position;
				local parts: any = workspace:GetPartBoundsInBox(CFrame.new(root.Position - Vector3.new(0, entitylib.character.HipHeight / 2, 0)), Vector3.new(3, entitylib.character.HipHeight, 3), params);
				local doHop: boolean = false;
	
				for _, part: any in parts do
					local pos: any = part:GetClosestPointOnSurface(root.Position);
					local diff: any = (root.Position.Y - pos.Y);
	
					if diff > root.Size.Y / 2 then
						doHop = true;
						break;
					end;
				end;
	
				if doHop and (os.clock() - timeout) > 0.2 then
					set = table.pack(gameCamera.CFrame:GetComponents());
					gameCamera.CFrame *= CFrame.Angles(0, math.rad(Offset["Value"]), 0);
					timeout = os.clock();
				end;
			end;
		end;
	end;
	
	Wallhop = vape.Categories.World:CreateModule({
		["Name"] = 'Wallhop',
		["Function"] = function(callback: boolean)
			if callback then
				if FPSCap["Enabled"] then
					oldfps = getfpscap();
					setfpscap(60);
				end;
	
				if workspace.AuthorityMode == Enum.AuthorityMode.Server then
					Wallhop:Clean(runService:BindToSimulation(doCheck));
				else
					Wallhop:Clean(runService.RenderStepped:Connect(doCheck));
				end;
			else
				if oldfps then
					setfpscap(oldfps);
					oldfps = nil;
				end;
	
				set = nil;
			end;
		end,
		["Tooltip"] = 'Automatically rotates camera for wallhopping.'
	});
	Offset = Wallhop:CreateSlider({
		["Name"] = 'Offset',
		["Min"] = -45,
		["Max"] = 45,
		["Default"] = 45,
		["Suffix"] = 'degrees'
	});
	FPSCap = Wallhop:CreateToggle({
		["Name"] = 'FPS Cap',
		["Function"] = function(callback: boolean)
			if Wallhop["Enabled"] then
				Wallhop:Toggle();
				Wallhop:Toggle();
			end;
		end,
		["Tootip"] = 'Set the FPS to 60 while the module is enabled.'
	});
end);

velo.run(function()
	local Xray: table = {["Enabled"] = false};
	local List: table = {};
	local modified: table = {};
	
	local modifyPart: (v: BasePart?) -> () = function(v: BasePart?): ()
		if v:IsA('BasePart') and not table.find(List.ListEnabled, v.Name) then
			modified[v] = true;
			v.LocalTransparencyModifier = 0.5;
		end;
	end;
	
	Xray = vape.Categories.World:CreateModule({
		["Name"] = 'Xray',
		["Function"] = function(callback: boolean): void
			if callback then
				Xray:Clean(workspace.DescendantAdded:Connect(modifyPart));
				for _, v: any in workspace:GetDescendants() do
					modifyPart(v);
				end;
			else
				for i: any in modified do
					i.LocalTransparencyModifier = 0;
				end;
				table.clear(modified);
			end;
		end,
		["Tooltip"] = 'Renders whitelisted parts through walls.'
	});
	List = Xray:CreateTextList({
		["Name"] = 'Part',
		["Function"] = function()
			if Xray["Enabled"] then
				Xray:Toggle();
				Xray:Toggle();
			end;
		end;
	});
end);
	
velo.run(function()
	local MurderMystery: table;
	local murderer: any, sheriff: any, oldtargetable: any, oldgetcolor: any;
	
	local itemAdded: (tool: any, plr: any) -> () = function(tool: any, plr: any): ()
		if tool:IsA('Tool') then
			local check: any = tool:FindFirstChild('IsGun') and 'sheriff' or tool:FindFirstChild('KnifeServer') and 'murderer' or nil;
			check = check or tool.Name:lower():find('knife') and 'murderer' or tool.Name:lower():find('gun') and 'sheriff' or nil;
	
			if check == 'murderer' and plr ~= murderer then
				murderer = plr;
	
				if plr.Character then
					entitylib.refresh();
				end;
			elseif check == 'sheriff' and plr ~= sheriff then
				sheriff = plr;
	
				if plr.Character then
					entitylib.refresh();
				end;
			end;
		end;
	end;
	
	local playerAdded: (plr: any) -> () = function(plr: any): ()
		MurderMystery:Clean(plr.DescendantAdded:Connect(function(tool: any)
			itemAdded(tool, plr);
		end));
	
		local pack: Backpack? = plr:FindFirstChildWhichIsA('Backpack');
		if pack then
			for _, tool: any in pack:GetChildren() do
				itemAdded(tool, plr);
			end;
		end;
	
		if plr.Character then
			for _, tool: any in plr.Character:GetChildren() do
				itemAdded(tool, plr);
			end;
		end;
	end;
	
	MurderMystery = vape.Categories.World:CreateModule({
		["Name"] = 'MurderMystery',
		["Function"] = function(callback: boolean)
			if callback then
				oldtargetable, oldgetcolor = entitylib.targetCheck, entitylib.getEntityColor;
	
				entitylib.getEntityColor = function(entity: any)
					entity = entity.Player;
					if not (entity and vape.Settings.Modules.Options['Use team color']["Enabled"]) then return; end;
					if isFriend(entity, true) then
						return Color3.fromHSV(vape.Categories.Friends.Options['Friends color']["Hue"], vape.Categories.Friends.Options['Friends color']["Sat"], vape.Categories.Friends.Options['Friends color']["Value"]);
					end;
					return murderer == entity and Color3.new(1, 0.3, 0.3) or sheriff == entity and Color3.new(0, 0.5, 1) or nil;
				end;
	
				entitylib.targetCheck = function(entity: any)
					if entity.Player and isFriend(entity.Player) then
						return false;
					end;
	
					if murderer == lplr then
						return true;
					end;
	
					return murderer == entity.Player or sheriff == entity.Player;
				end;
	
				for _, plr: any in playersService:GetPlayers() do
					playerAdded(plr);
				end;
	
				MurderMystery:Clean(playersService.PlayerAdded:Connect(playerAdded));
				entitylib.refresh();
			else
				entitylib.getEntityColor = oldgetcolor;
				entitylib.targetCheck = oldtargetable;
				entitylib.refresh();
			end;
		end,
		["Tooltip"] = 'Automatic murder mystery teaming based on equipped roblox tools.'
	});
end);

velo.run(function()
	local Atmosphere: table = {["Enabled"] = false};
	local toggles: table = {};
	local ThemeName: any;
	local newobjects: table, oldobjects: table = {}, {};
	local stashed: table = {}; 
	local ils: any; 
	local savedProps: table = {
		'Brightness', 'ColorShift_Bottom', 'ColorShift_Top', 'OutdoorAmbient',
		'TimeOfDay', 'FogColor', 'FogEnd', 'FogStart', 'ExposureCompensation',
		'ShadowSoftness', 'Ambient', 'EnvironmentDiffuseScale', 'EnvironmentSpecularScale'
	};
	local beforeShaders: () -> table = function(): table
		local state: table = {["props"] = {}};
		for _, prop: string in savedProps do
			state["props"][prop] = lightingService[prop];
		end;
		state["WaterTransparency"] = workspace.Terrain.WaterTransparency;
		state["WaterReflectance"] = workspace.Terrain.WaterReflectance;
		return state;
	end;
	local restoreDefault: (lightingState: table?) -> void = function(lightingState: table?): void
		if not lightingState then return; end;
		for prop: string, value: any in lightingState["props"] do
			pcall(function() lightingService[prop] = value; end);
		end;
		workspace.Terrain.WaterTransparency = lightingState["WaterTransparency"];
		workspace.Terrain.WaterReflectance = lightingState["WaterReflectance"];
		for _, entry: table in stashed do
			pcall(function() entry["Object"].Parent = entry["Parent"]; end);
		end;
		table.clear(stashed);
	end;
	local stash: (obj: Instance) -> void = function(obj: Instance): void
		table.insert(stashed, {["Object"] = obj, ["Parent"] = obj.Parent});
		obj.Parent = nil;
	end;
	local apidump: table = {
		["Sky"] = {
			["SkyboxUp"] = 'Text',
			["SkyboxDn"] = 'Text',
			["SkyboxLf"] = 'Text',
			["SkyboxRt"] = 'Text',
			["SkyboxFt"] = 'Text',
			["SkyboxBk"] = 'Text',
			["SunTextureId"] = 'Text',
			["SunAngularSize"] = 'Number',
			["MoonTextureId"] = 'Text',
			["MoonAngularSize"] = 'Number',
			["StarCount"] = 'Number'
		},
		["Atmosphere"] = {
			["Color"] = 'Color',
			["Decay"] = 'Color',
			["Density"] = 'Number',
			["Offset"] = 'Number',
			["Glare"] = 'Number',
			["Haze"] = 'Number'
		},
		["BloomEffect"] = {
			["Intensity"] = 'Number',
			["Size"] = 'Number',
			["Threshold"] = 'Number'
		},
		["DepthOfFieldEffect"] = {
			["FarIntensity"] = 'Number',
			["FocusDistance"] = 'Number',
			["InFocusRadius"] = 'Number',
			["NearIntensity"] = 'Number'
		},
		["SunRaysEffect"] = {
			["Intensity"] = 'Number',
			["Spread"] = 'Number'
		},
		["ColorCorrectionEffect"] = {
			["TintColor"] = 'Color',
			["Saturation"] = 'Number',
			["Contrast"] = 'Number',
			["Brightness"] = 'Number'
		}
	};

	local skyThemes: table = {
		["NetherWorld"] = {
			["MoonAngularSize"] = 0,
			["SunAngularSize"] = 0,
			["SkyboxBk"] = 'rbxassetid://14365019002',
			["SkyboxDn"] = 'rbxassetid://14365023350',
			["SkyboxFt"] = 'rbxassetid://14365018399',
			["SkyboxLf"] = 'rbxassetid://14365018705',
			["SkyboxRt"] = 'rbxassetid://14365018143',
			["SkyboxUp"] = 'rbxassetid://14365019327',
		},
		["Neptune"] = {
			["SkyboxBk"] = 'rbxassetid://218955819',
			["SkyboxDn"] = 'rbxassetid://218953419',
			["SkyboxFt"] = 'rbxassetid://218954524',
			["SkyboxLf"] = 'rbxassetid://218958493',
			["SkyboxRt"] = 'rbxassetid://218957134',
			["SkyboxUp"] = 'rbxassetid://218950090',
		},
		["Velocity"] = {
			["SkyboxBk"] = 'rbxassetid://570557514',
			["SkyboxDn"] = 'rbxassetid://570557775',
			["SkyboxFt"] = 'rbxassetid://570557559',
			["SkyboxLf"] = 'rbxassetid://570557620',
			["SkyboxRt"] = 'rbxassetid://570557672',
			["SkyboxUp"] = 'rbxassetid://570557727',
		},
		["Minecraft"] = {
			["SkyboxBk"] = 'rbxassetid://591058823',
			["SkyboxDn"] = 'rbxassetid://591059876',
			["SkyboxFt"] = 'rbxassetid://591058104',
			["SkyboxLf"] = 'rbxassetid://591057861',
			["SkyboxRt"] = 'rbxassetid://591057625',
			["SkyboxUp"] = 'rbxassetid://591059642',
		},
		["Purple"] = {
			["SkyboxBk"] = "rbxassetid://8539982183",
			["SkyboxDn"] = "rbxassetid://8539981943",
			["SkyboxFt"] = "rbxassetid://8539981721",
			["SkyboxLf"] = "rbxassetid://8539981424",
			["SkyboxRt"] = "rbxassetid://8539980766",
			["SkyboxUp"] = "rbxassetid://8539981085",
			["MoonAngularSize"] = 0,
			["SunAngularSize"] = 0,
			["StarCount"] = 3000,
		},
		["日の出"] = {
			["SkyboxBk"] = "rbxassetid://600830446",
			["SkyboxDn"] = "rbxassetid://600831635",
			["SkyboxFt"] = "rbxassetid://600832720",
			["SkyboxLf"] = "rbxassetid://600886090",
			["SkyboxRt"] = "rbxassetid://600833862",
			["SkyboxUp"] = "rbxassetid://600835177",
		},
		["Sakura"] = {
			["SkyboxBk"] = "http://www.roblox.com/asset/?id=16694315897",
			["SkyboxDn"] = "http://www.roblox.com/asset/?id=16694319417",
			["SkyboxFt"] = "http://www.roblox.com/asset/?id=16694324910",
			["SkyboxLf"] = "http://www.roblox.com/asset/?id=16694328308",
			["SkyboxRt"] = "http://www.roblox.com/asset/?id=16694331447",
			["SkyboxUp"] = "http://www.roblox.com/asset/?id=16694334666",
			["SunAngularSize"] = 21,
			["StarCount"] = 3000,
		},
		["Hexagonal"] = {
			["SkyboxBk"] = "http://www.roblox.com/asset/?id=15876463105",
			["SkyboxDn"] = "http://www.roblox.com/asset/?id=15876464432",
			["SkyboxFt"] = "http://www.roblox.com/asset/?id=15876465852",
			["SkyboxLf"] = "http://www.roblox.com/asset/?id=15876467260",
			["SkyboxRt"] = "http://www.roblox.com/asset/?id=15876469097",
			["SkyboxUp"] = "http://www.roblox.com/asset/?id=15876470945",
			["SunAngularSize"] = 21,
			["StarCount"] = 3000,
		},
		["Reality"] = {
			["SkyboxBk"] = "http://www.roblox.com/asset/?id=6778646360",
			["SkyboxDn"] = "http://www.roblox.com/asset/?id=6778658683",
			["SkyboxFt"] = "http://www.roblox.com/asset/?id=6778648039",
			["SkyboxLf"] = "http://www.roblox.com/asset/?id=6778649136",
			["SkyboxRt"] = "http://www.roblox.com/asset/?id=6778650519",
			["SkyboxUp"] = "http://www.roblox.com/asset/?id=6778658364",
		},
		["LunarNight"] = {
			["SkyboxBk"] = 'rbxassetid://187713366',
			["SkyboxDn"] = 'rbxassetid://187712428',
			["SkyboxFt"] = 'rbxassetid://187712836',
			["SkyboxLf"] = 'rbxassetid://187713755',
			["SkyboxRt"] = 'rbxassetid://187714525',
			["SkyboxUp"] = 'rbxassetid://187712111',
			["SunAngularSize"] = 0,
			["StarCount"] = 0,
		},
		["FPSBoost"] = {
			["SkyboxBk"] = 'rbxassetid://11457548274',
			["SkyboxDn"] = 'rbxassetid://11457548274',
			["SkyboxFt"] = 'rbxassetid://11457548274',
			["SkyboxLf"] = 'rbxassetid://11457548274',
			["SkyboxRt"] = 'rbxassetid://11457548274',
			["SkyboxUp"] = 'rbxassetid://11457548274',
			["SunAngularSize"] = 0,
			["StarCount"] = 3000,
		},
		["Etheral"] = {
			["SkyboxBk"] = 'rbxassetid://16262356578',
			["SkyboxDn"] = 'rbxassetid://16262358026',
			["SkyboxFt"] = 'rbxassetid://16262360469',
			["SkyboxLf"] = 'rbxassetid://16262362003',
			["SkyboxRt"] = 'rbxassetid://16262363873',
			["SkyboxUp"] = 'rbxassetid://16262366016',
			["SunAngularSize"] = 21,
			["StarCount"] = 3000,
		},
		["Pandora"] = {
			["SkyboxBk"] = 'http://www.roblox.com/asset/?id=16739324092',
			["SkyboxDn"] = 'http://www.roblox.com/asset/?id=16739325541',
			["SkyboxFt"] = 'http://www.roblox.com/asset/?id=16739327056',
			["SkyboxLf"] = 'http://www.roblox.com/asset/?id=16739329370',
			["SkyboxRt"] = 'http://www.roblox.com/asset/?id=16739331050',
			["SkyboxUp"] = 'http://www.roblox.com/asset/?id=16739332736',
			["SunAngularSize"] = 21,
			["StarCount"] = 3000,
		},
		["Polaris"] = {
			["SkyboxBk"] = 'http://www.roblox.com/asset/?id=16823270864',
			["SkyboxDn"] = 'http://www.roblox.com/asset/?id=16823272150',
			["SkyboxFt"] = 'http://www.roblox.com/asset/?id=16823273508',
			["SkyboxLf"] = 'http://www.roblox.com/asset/?id=16823274898',
			["SkyboxRt"] = 'http://www.roblox.com/asset/?id=16823276281',
			["SkyboxUp"] = 'http://www.roblox.com/asset/?id=16823277547',
			["SunAngularSize"] = 21,
			["StarCount"] = 3000,
		},
		["Diaphanous"] = {
			["SkyboxBk"] = 'http://www.roblox.com/asset/?id=16888989874',
			["SkyboxDn"] = 'http://www.roblox.com/asset/?id=16888991855',
			["SkyboxFt"] = 'http://www.roblox.com/asset/?id=16888995219',
			["SkyboxLf"] = 'http://www.roblox.com/asset/?id=16888998994',
			["SkyboxRt"] = 'http://www.roblox.com/asset/?id=16889000916',
			["SkyboxUp"] = 'http://www.roblox.com/asset/?id=16889004122',
			["SunAngularSize"] = 21,
			["StarCount"] = 3000,
		},
		["Transcendent"] = {
			["SkyboxBk"] = 'http://www.roblox.com/asset/?id=17124357467',
			["SkyboxDn"] = 'http://www.roblox.com/asset/?id=17124359797',
			["SkyboxFt"] = 'http://www.roblox.com/asset/?id=17124362093',
			["SkyboxLf"] = 'http://www.roblox.com/asset/?id=17124365127',
			["SkyboxRt"] = 'http://www.roblox.com/asset/?id=17124367200',
			["SkyboxUp"] = 'http://www.roblox.com/asset/?id=17124369657',
			["SunAngularSize"] = 21,
			["StarCount"] = 3000,
		},
		["Truth"] = {
			["SkyboxBk"] = "http://www.roblox.com/asset/?id=144933338",
			["SkyboxDn"] = "http://www.roblox.com/asset/?id=144931530",
			["SkyboxFt"] = "http://www.roblox.com/asset/?id=144933262",
			["SkyboxLf"] = "http://www.roblox.com/asset/?id=144933244",
			["SkyboxRt"] = "http://www.roblox.com/asset/?id=144933299",
			["SkyboxUp"] = "http://www.roblox.com/asset/?id=144931564",
		},
		["RayTracing"] = {
			["SkyboxBk"] = "http://www.roblox.com/asset/?id=271042516",
			["SkyboxDn"] = "http://www.roblox.com/asset/?id=271077243",
			["SkyboxFt"] = "http://www.roblox.com/asset/?id=271042556",
			["SkyboxLf"] = "http://www.roblox.com/asset/?id=271042310",
			["SkyboxRt"] = "http://www.roblox.com/asset/?id=271042467",
			["SkyboxUp"] = "http://www.roblox.com/asset/?id=271077958",
		},
		["Nebula"] = {
			["MoonAngularSize"] = 0,
			["SunAngularSize"] = 0,
			["SkyboxBk"] = 'rbxassetid://5260808177',
			["SkyboxDn"] = 'rbxassetid://5260653793',
			["SkyboxFt"] = 'rbxassetid://5260817288',
			["SkyboxLf"] = 'rbxassetid://5260800833',
			["SkyboxRt"] = 'rbxassetid://5260811073',
			["SkyboxUp"] = 'rbxassetid://5260824661',
		},
		["Planets"] = {
			["MoonAngularSize"] = 0,
			["SunAngularSize"] = 0,
			["SkyboxBk"] = 'rbxassetid://15983968922',
			["SkyboxDn"] = 'rbxassetid://15983966825',
			["SkyboxFt"] = 'rbxassetid://15983965025',
			["SkyboxLf"] = 'rbxassetid://15983967420',
			["SkyboxRt"] = 'rbxassetid://15983966246',
			["SkyboxUp"] = 'rbxassetid://15983964246',
			["StarCount"] = 3000,
		},
		["Galaxy"] = {
			["SkyboxBk"] = "rbxassetid://159454299",
			["SkyboxDn"] = "rbxassetid://159454296",
			["SkyboxFt"] = "rbxassetid://159454293",
			["SkyboxLf"] = "rbxassetid://159454293",
			["SkyboxRt"] = "rbxassetid://159454293",
			["SkyboxUp"] = "rbxassetid://159454288",
			["SunAngularSize"] = 0,
		},
		["Blues"] = {
			["SkyboxBk"] = 'http://www.roblox.com/asset/?id=17124357467',
			["SkyboxDn"] = 'http://www.roblox.com/asset/?id=17124359797',
			["SkyboxFt"] = 'http://www.roblox.com/asset/?id=17124362093',
			["SkyboxLf"] = 'http://www.roblox.com/asset/?id=17124365127',
			["SkyboxRt"] = 'http://www.roblox.com/asset/?id=17124367200',
			["SkyboxUp"] = 'http://www.roblox.com/asset/?id=17124369657',
			["SunAngularSize"] = 21,
			["StarCount"] = 3000,
		},
		["Milkyway"] = {
			["MoonTextureId"] = 'rbxassetid://1075087760',
			["SkyboxBk"] = 'rbxassetid://2670643994',
			["SkyboxDn"] = 'rbxassetid://2670643365',
			["SkyboxFt"] = 'rbxassetid://2670643214',
			["SkyboxLf"] = 'rbxassetid://2670643070',
			["SkyboxRt"] = 'rbxassetid://2670644173',
			["SkyboxUp"] = 'rbxassetid://2670644331',
			["MoonAngularSize"] = 1.5,
			["StarCount"] = 500,
		},
		["Orange"] = {
			["SkyboxBk"] = 'rbxassetid://150939022',
			["SkyboxDn"] = 'rbxassetid://150939038',
			["SkyboxFt"] = 'rbxassetid://150939047',
			["SkyboxLf"] = 'rbxassetid://150939056',
			["SkyboxRt"] = 'rbxassetid://150939063',
			["SkyboxUp"] = 'rbxassetid://150939082',
		},
		["DarkMountains"] = {
			["SkyboxBk"] = 'rbxassetid://5098814730',
			["SkyboxDn"] = 'rbxassetid://5098815227',
			["SkyboxFt"] = 'rbxassetid://5098815653',
			["SkyboxLf"] = 'rbxassetid://5098816155',
			["SkyboxRt"] = 'rbxassetid://5098820352',
			["SkyboxUp"] = 'rbxassetid://5098819127',
		},
		["Space"] = {
			["MoonAngularSize"] = 0,
			["SunAngularSize"] = 0,
			["SkyboxBk"] = 'rbxassetid://166509999',
			["SkyboxDn"] = 'rbxassetid://166510057',
			["SkyboxFt"] = 'rbxassetid://166510116',
			["SkyboxLf"] = 'rbxassetid://166510092',
			["SkyboxRt"] = 'rbxassetid://166510131',
			["SkyboxUp"] = 'rbxassetid://166510114',
		},
		["Void"] = {
			["MoonAngularSize"] = 0,
			["SunAngularSize"] = 0,
			["SkyboxBk"] = 'rbxassetid://14543264135',
			["SkyboxDn"] = 'rbxassetid://14543358958',
			["SkyboxFt"] = 'rbxassetid://14543257810',
			["SkyboxLf"] = 'rbxassetid://14543275895',
			["SkyboxRt"] = 'rbxassetid://14543280890',
			["SkyboxUp"] = 'rbxassetid://14543371676',
		},
		["Stary"] = {
			["SkyboxBk"] = 'rbxassetid://248431616',
			["SkyboxDn"] = 'rbxassetid://248431677',
			["SkyboxFt"] = 'rbxassetid://248431598',
			["SkyboxLf"] = 'rbxassetid://248431686',
			["SkyboxRt"] = 'rbxassetid://248431611',
			["SkyboxUp"] = 'rbxassetid://248431605',
			["StarCount"] = 3000,
		},
		["Violet"] = {
			["SkyboxBk"] = 'rbxassetid://8107841671',
			["SkyboxDn"] = 'rbxassetid://6444884785',
			["SkyboxFt"] = 'rbxassetid://8107841671',
			["SkyboxLf"] = 'rbxassetid://8107841671',
			["SkyboxRt"] = 'rbxassetid://8107841671',
			["SkyboxUp"] = 'rbxassetid://8107849791',
			["SunTextureId"] = 'rbxassetid://6196665106',
			["MoonTextureId"] = 'rbxassetid://6444320592',
			["MoonAngularSize"] = 0,
		},
		["Cloudy"] = {
			["SkyboxBk"] = 'rbxassetid://15876597103',
			["SkyboxDn"] = 'rbxassetid://15876592775',
			["SkyboxFt"] = 'rbxassetid://15876640231',
			["SkyboxLf"] = 'rbxassetid://15876638420',
			["SkyboxRt"] = 'rbxassetid://15876595486',
			["SkyboxUp"] = 'rbxassetid://15876639348',
			["SunTextureId"] = 'rbxasset://sky/sun.jpg',
			["MoonTextureId"] = 'rbxasset://sky/moon.jpg',
			["MoonAngularSize"] = 11,
			["SunAngularSize"] = 21,
			["StarCount"] = 3000,
		}
	};
	local removeObject: (v: Instance?) -> void = function(v: Instance?): void
		if not table.find(newobjects, v) then
			local vt: table? = toggles[v.ClassName];
			if vt and vt.Toggle["Enabled"] then
				table.insert(oldobjects, v);
				v.Parent = game;
			end;
		end;
	end;
	local themes: (sky: Sky) -> void = function(sky: Sky): void
		local theme: any = ThemeName and skyThemes[ThemeName["Value"]];
		if not theme then return; end;
		for v: any, value: any in next, theme do
			pcall(function() sky[v] = value; end);
		end;
	end;
	local isLightingEffect: (v: Instance) -> boolean = function(v: Instance): boolean
		return v:IsA('PostEffect') or v:IsA('Sky') or v:IsA('Atmosphere') or v:IsA('Clouds');
	end;
	local addObject: (obj: Instance, parent: Instance?) -> Instance = function(obj: Instance, parent: Instance?): Instance
		table.insert(newobjects, obj);
		pcall(function() obj.Parent = parent or lightingService; end);
		return obj;
	end;
	Atmosphere = vape.Legit:CreateModule({
		["Name"] = 'Atmosphere',
		["Function"] = function(callback: boolean): void
			if callback then
				ils = beforeShaders();
				local r: any = workspace.Terrain;
				for _, v: any in lightingService:GetChildren() do
					if isLightingEffect(v) then
						stash(v);
					end;
				end;
				for _, v: any in workspace:GetDescendants() do
					if v:IsA("Clouds") then
						stash(v);
					end;
				end;
				lightingService.Brightness = 1;
				lightingService.EnvironmentDiffuseScale = 0.2;
				lightingService.EnvironmentSpecularScale = 0.82;
				local sunRays: SunRaysEffect = Instance.new('SunRaysEffect');
				addObject(sunRays);
				local atmosphere: Atmosphere = Instance.new('Atmosphere');
				addObject(atmosphere);
				local sky: Sky = Instance.new('Sky');
				sky.Name = 'ThemeSky';
				themes(sky);
				addObject(sky);
				local blur: BlurEffect = Instance.new('BlurEffect');
				blur.Size = 3.921;
				addObject(blur);
				local color_correction: ColorCorrectionEffect = Instance.new('ColorCorrectionEffect');
				color_correction.Saturation = 0.092;
				addObject(color_correction);
				local clouds: Clouds = Instance.new('Clouds');
				clouds.Cover = 0.4;
				addObject(clouds, r);
				r.WaterTransparency = 1;
				r.WaterReflectance = 1;
				for _, v: any in lightingService:GetChildren() do
					removeObject(v);
				end;
				Atmosphere:Clean(lightingService.ChildAdded:Connect(function(v: any)
					task.defer(removeObject, v);
				end));
				for className: any, classData: any in toggles do
					if classData.Toggle["Enabled"] then
						local obj: any = Instance.new(className);
						for propName: any, propData: any in classData.Objects do
							if propData.Type == 'ColorSlider' then
								obj[propName] = Color3.fromHSV(propData["Hue"], propData["Sat"], propData["Value"]);
							elseif apidump[className][propName] == 'Number' then
								obj[propName] = tonumber(propData["Value"]) or 0;
							else
								obj[propName] = propData["Value"];
							end;
						end;
						obj.Name = "Custom" .. className;
						table.insert(newobjects, obj);
						task.defer(function()
							pcall(function() obj.Parent = lightingService; end);
						end);
					end;
				end;
			else
				for _, v: any in newobjects do
					pcall(function() v:Destroy(); end);
				end;
				table.clear(newobjects);

				for _, v: any in oldobjects do
					pcall(function() v.Parent = lightingService; end);
				end;
				table.clear(oldobjects);

				restoreDefault(ils);
			end;
		end,
		["Tooltip"] = 'Custom lighting objects'
	});
	local skyboxes: table = {};
	for v: any, _ in next, skyThemes do
		table.insert(skyboxes, v);
	end;
	table.sort(skyboxes);
	ThemeName = Atmosphere:CreateDropdown({
		["Name"] = "Mode",
		["List"] = skyboxes,
		["Function"] = function(val: any)
			if Atmosphere["Enabled"] then
				Atmosphere:Toggle();
				Atmosphere:Toggle();
			end;
		end
	});

	for i: any, v: any in apidump do
		toggles[i] = {["Objects"] = {}};
		toggles[i].Toggle = Atmosphere:CreateToggle({
			["Name"] = i,
			["Function"] = function(callback: boolean): void
				if Atmosphere["Enabled"] then
					Atmosphere:Toggle();
					Atmosphere:Toggle();
				end;
				for _, toggle: any in toggles[i].Objects do
					toggle.Object.Visible = callback;
				end;
			end
		});

		for i2: any, v2: any in v do
			if v2 == 'Text' or v2 == 'Number' then
				toggles[i].Objects[i2] = Atmosphere:CreateTextBox({
					["Name"] = i2,
					["Function"] = function(enter: any)
						if Atmosphere["Enabled"] and enter then
							Atmosphere:Toggle();
							Atmosphere:Toggle();
						end;
					end,
					["Darker"] = true,
					["Default"] = v2 == 'Number' and '0' or nil,
					["Visible"] = false
				});
			elseif v2 == 'Color' then
				toggles[i].Objects[i2] = Atmosphere:CreateColorSlider({
					["Name"] = i2,
					["Function"] = function()
						if Atmosphere["Enabled"] then
							Atmosphere:Toggle();
							Atmosphere:Toggle();
						end;
					end,
					["Darker"] = true,
					["Visible"] = false
				});
			end;
		end;
	end;
end);


velo.run(function()
	local Breadcrumbs: table = {["Enabled"] = false};
	local Texture: table = {};
	local Lifetime: table = {};
	local Thickness: table = {};
	local FadeIn: any;
	local FadeOut: any;
	local trail: any, point: any, point2: any;
	Breadcrumbs = vape.Legit:CreateModule({
		["Name"] = 'Breadcrumbs',
		["Function"] = function(callback: boolean): void
			if callback then
				point = Instance.new('Attachment');
				point.Position = Vector3.new(0, Thickness["Value"] - 2.7, 0);
				point2 = Instance.new('Attachment');
				point2.Position = Vector3.new(0, -Thickness["Value"] - 2.7, 0);
				trail = Instance.new('Trail');
				trail.Texture = Texture["Value"] == '' and 'http://www.roblox.com/asset/?id=14166981368' or Texture["Value"];
				trail.TextureMode = Enum.TextureMode.Static;
				trail.Color = ColorSequence.new(Color3.fromHSV(FadeIn["Hue"], FadeIn["Sat"], FadeIn["Value"]), Color3.fromHSV(FadeOut["Hue"], FadeOut["Sat"], FadeOut["Value"]));
				trail.Lifetime = Lifetime["Value"];
				trail.Attachment0 = point;
				trail.Attachment1 = point2;
				trail.FaceCamera = true;
	
				Breadcrumbs:Clean(trail);
				Breadcrumbs:Clean(point);
				Breadcrumbs:Clean(point2);
				Breadcrumbs:Clean(entitylib.Events.LocalAdded:Connect(function(ent: Player?)
					point.Parent = ent.HumanoidRootPart;
					point2.Parent = ent.HumanoidRootPart;
					trail.Parent = gameCamera;
				end));
				if entitylib.isAlive then
					point.Parent = entitylib.character.RootPart;
					point2.Parent = entitylib.character.RootPart;
					trail.Parent = gameCamera;
				end;
			else
				trail = nil;
				point = nil;
				point2 = nil;
			end;
		end,
		["Tooltip"] = 'Shows a trail behind your character'
	});
	Texture = Breadcrumbs:CreateTextBox({
		["Name"] = 'Texture',
		["Placeholder"] = 'Texture Id',
		["Function"] = function(enter: any)
			if enter and trail then
				trail.Texture = Texture["Value"] == '' and 'http://www.roblox.com/asset/?id=14166981368' or Texture["Value"];
			end;
		end;
	});
	FadeIn = Breadcrumbs:CreateColorSlider({
		["Name"] = 'Fade In',
		["Function"] = function(hue: any, sat: any, val: any)
			if trail then
				trail.Color = ColorSequence.new(Color3.fromHSV(hue, sat, val), Color3.fromHSV(FadeOut["Hue"], FadeOut["Sat"], FadeOut["Value"]));
			end;
		end;
	});
	FadeOut = Breadcrumbs:CreateColorSlider({
		["Name"] = 'Fade Out',
		["Function"] = function(hue: any, sat: any, val: any)
			if trail then
				trail.Color = ColorSequence.new(Color3.fromHSV(FadeIn["Hue"], FadeIn["Sat"], FadeIn["Value"]), Color3.fromHSV(hue, sat, val));
			end;
		end;
	});
	Lifetime = Breadcrumbs:CreateSlider({
		["Name"] = 'Lifetime',
		["Min"] = 1,
		["Max"] = 5,
		["Default"] = 3,
		["Decimal"] = 10,
		["Function"] = function(val: any)
			if trail then
				trail.Lifetime = val;
			end;
		end,
		["Suffix"] = function(val: any)
			return val == 1 and 'second' or 'seconds';
		end;
	});
	Thickness = Breadcrumbs:CreateSlider({
		["Name"] = 'Thickness',
		["Min"] = 0,
		["Max"] = 2,
		["Default"] = 0.1,
		["Decimal"] = 100,
		["Function"] = function(val: any)
			if point then
				point.Position = Vector3.new(0, val - 2.7, 0);
			end;
			if point2 then
				point2.Position = Vector3.new(0, -val - 2.7, 0);
			end;
		end,
		["Suffix"] = function(val: any)
			return val == 1 and 'stud' or 'studs';
		end;
	});
end);

velo.run(function()
	local ChinaHat: table = {["Enabled"] = false};
	local Material: table = {["Value"] = "ForceField"};
	local Color: table = {};
	local hat: any;
	ChinaHat = vape.Legit:CreateModule({
		["Name"] = 'China Hat',
		["Function"] = function(callback: boolean): void
			if callback then
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				hat = Instance.new('MeshPart');
				hat.Size = Vector3.new(3, 0.7, 3);
				hat.Name = 'ChinaHat';
				hat.Material = Enum.Material[Material["Value"]];
				hat.Color = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
				hat.CanCollide = false;
				hat.CanQuery = false;
				hat.Massless = true;
				hat.MeshId = 'http://www.roblox.com/asset/?id=1778999';
				hat.Transparency = 1 - Color["Opacity"];
				hat.Parent = gameCamera;
				hat.CFrame = entitylib.isAlive and entitylib.character.Head.CFrame + Vector3.new(0, 1, 0) or CFrame.identity;
				local weld: WeldConstraint = Instance.new('WeldConstraint');
				weld.Part0 = hat;
				weld.Part1 = entitylib.isAlive and entitylib.character.Head or nil;
				weld.Parent = hat;
				ChinaHat:Clean(hat);
				ChinaHat:Clean(entitylib.Events.LocalAdded:Connect(function(char: Model?)
					if weld then 
						weld:Destroy();
					end;
					hat.Parent = gameCamera;
					hat.CFrame = char.Head.CFrame + Vector3.new(0, 1, 0);
					hat.Velocity = Vector3.zero;
					weld = Instance.new('WeldConstraint');
					weld.Part0 = hat;
					weld.Part1 = char.Head;
					weld.Parent = hat;
				end));
	
				repeat
					hat.LocalTransparencyModifier = ((gameCamera.CFrame.Position - gameCamera.Focus.Position).Magnitude <= 0.6 and 1 or 0);
					task.wait();
				until not ChinaHat["Enabled"];
			else
				hat = nil;
			end;
		end,
		["Tooltip"] = 'Puts a china hat on your character (ty mastadawn)'
	});
	local materials: any = {'ForceField'};
	for _, v: any in Enum.Material:GetEnumItems() do
		if v.Name ~= 'ForceField' then
			table.insert(materials, v.Name);
		end;
	end;
	Material = ChinaHat:CreateDropdown({
		["Name"] = 'Material',
		["List"] = materials,
		["Function"] = function(val: any)
			if hat then
				hat.Material = Enum.Material[val];
			end;
		end;
	});
	Color = ChinaHat:CreateColorSlider({
		["Name"] = 'Hat Color',
		["DefaultOpacity"] = 0.7,
		["Function"] = function(hue: any, sat: any, val: any, opacity: any)
			if hat then
				hat.Color = Color3.fromHSV(hue, sat, val);
				hat.Transparency = 1 - opacity;
			end;
		end;
	});
end);
	
velo.run(function()
	local Clock: table = {["Enabled"] = false}; 
	local TwentyFourHour: table = {["Enabled"] = false}; 
	local label: any;
	Clock = vape.Legit:CreateModule({
		["Name"] = 'Clock',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					label.Text = DateTime.now():FormatLocalTime('LT', TwentyFourHour["Enabled"] and 'zh-cn' or 'en-us');
					task.wait(1);
				until not Clock["Enabled"];
			end;
		end,
		["Size"] = UDim2.fromOffset(100, 41),
		["Tooltip"] = 'Shows the current local time'
	});
	Clock:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val: any)
			label.FontFace = val;
		end;
	});
	Clock:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue: any, sat: any, val: any, opacity: any)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			label.BackgroundTransparency = 1 - opacity;
		end;
	});
	TwentyFourHour = Clock:CreateToggle({
		["Name"] = '24 Hour Clock'
	});
	label = Instance.new('TextLabel');
	label.Size = UDim2.new(0, 100, 0, 41);
	label.BackgroundTransparency = 0.5;
	label.TextSize = 15;
	label.Font = Enum.Font.Gotham;
	label.Text = '0:00 PM';
	label.TextColor3 = Color3.new(1, 1, 1);
	label.BackgroundColor3 = Color3.new();
	label.Parent = Clock.Children;
	local corner: UICorner = Instance.new('UICorner');
	corner.CornerRadius = UDim.new(0, 4);
	corner.Parent = label;
end);
	
velo.run(function()
	local Disguise: table = {["Enabled"] = false}; 
	local Mode: table = {["Value"] = 'Character'}; 
	local IDBox: any;
	local desc: any;
	
	local itemAdded: (v: Player?, manual: any) -> () = function(v: Player?, manual: any): ()
		if (not v:GetAttribute('Disguise')) and ((v:IsA('Accessory') and (not v:GetAttribute('InvItem')) and (not v:GetAttribute('ArmorSlot'))) or v:IsA('ShirtGraphic') or v:IsA('Shirt') or v:IsA('Pants') or v:IsA('BodyColors') or manual) then
			repeat
				task.wait();
				v.Parent = game;
			until v.Parent == game;
			v:ClearAllChildren();
			v:Destroy();
		end;
	end;
	
	local characterAdded: (char: Model?) -> () = function(char: Model?): ()
		if Mode["Value"] == 'Character' then
			task.wait(0.1);
			char.Character.Archivable = true;
			local clone: any = char.Character:Clone();
			repeat
				if pcall(function()
					desc = playersService:GetHumanoidDescriptionFromUserId(IDBox["Value"] == '' and 239702688 or tonumber(IDBox["Value"]));
				end) then break; end;
				task.wait(1);
			until not Disguise["Enabled"];
			if not Disguise["Enabled"] then
				clone:ClearAllChildren();
				clone:Destroy();
				clone = nil;
				if desc then
					desc:Destroy();
					desc = nil;
				end;
				return;
			end;
			clone.Parent = game;
	
			local originalDesc: any = char.Humanoid:WaitForChild('HumanoidDescription', 2) or {
				["HeightScale"] = 1,
				["SetEmotes"] = function() end,
				["SetEquippedEmotes"] = function() end
			};
			originalDesc.JumpAnimation = desc.JumpAnimation;
			desc.HeightScale = originalDesc.HeightScale;
	
			for _, v: any in clone:GetChildren() do
				if v:IsA('Accessory') or v:IsA('ShirtGraphic') or v:IsA('Shirt') or v:IsA('Pants') then
					v:ClearAllChildren();
					v:Destroy();
				end;
			end;
	
			clone.Humanoid:ApplyDescriptionClientServer(desc);
			for _, v: any in char.Character:GetChildren() do
				itemAdded(v);
			end;
			Disguise:Clean(char.Character.ChildAdded:Connect(itemAdded));
	
			for _, v: any in clone:WaitForChild('Animate'):GetChildren() do
				if not char.Character:FindFirstChild('Animate') then return; end;
				local real: Animate? = char.Character.Animate:FindFirstChild(v.Name);
				if v and real then
					local anim: any = v:FindFirstChildWhichIsA('Animation') or {["AnimationId"] = ''};
					local realanim: any = real:FindFirstChildWhichIsA('Animation') or {["AnimationId"] = ''};
					if realanim then
						realanim.AnimationId = anim.AnimationId;
					end;
				end;
			end;
	
			for _, v: any in clone:GetChildren() do
				v:SetAttribute('Disguise', true);
				if v:IsA('Accessory') then
					for _, v2: any in v:GetDescendants() do
						if v2:IsA('Weld') and v2.Part1 then
							v2.Part1 = char.Character[v2.Part1.Name];
						end;
					end;
					v.Parent = char.Character;
				elseif v:IsA('ShirtGraphic') or v:IsA('Shirt') or v:IsA('Pants') or v:IsA('BodyColors') then
					v.Parent = char.Character;
				elseif v.Name == 'Head' and char.Head:IsA('MeshPart') and (not char.Head:FindFirstChild('FaceControls')) then
					char.Head.MeshId = v.MeshId;
				end;
			end;
	
			local localface: any = char.Character:FindFirstChild('face', true);
			local cloneface: any = clone:FindFirstChild('face', true);
			if localface and cloneface then
				itemAdded(localface, true);
				cloneface.Parent = char.Head;
			end;
			originalDesc:SetEmotes(desc:GetEmotes());
			originalDesc:SetEquippedEmotes(desc:GetEquippedEmotes());
			clone:ClearAllChildren();
			clone:Destroy();
			clone = nil;
			if desc then
				desc:Destroy();
				desc = nil;
			end;
		else
			local data: any;
			repeat
				if pcall(function()
					data = marketplaceService:GetProductInfo(IDBox["Value"] == '' and 43 or tonumber(IDBox["Value"]), Enum.InfoType.Bundle);
				end) then break; end;
				task.wait(1);
			until not Disguise["Enabled"];
			if not Disguise["Enabled"] then
				if data then
					table.clear(data);
					data = nil;
				end;
				return;
			end;
			if data.BundleType == 'AvatarAnimations' then
				local animate: Animate? = char.Character:FindFirstChild('Animate');
				if not animate then return; end;
				for _, v: any in desc.Items do
					local animtype: string? = v.Name:split(' ')[2]:lower();
					if animtype ~= 'animation' then
						local suc: boolean, res: string? = pcall(function() return game:GetObjects('rbxassetid://'..v.Id); end);
						if suc then
							animate[animtype]:FindFirstChildWhichIsA('Animation').AnimationId = res[1]:FindFirstChildWhichIsA('Animation', true).AnimationId;
						end;
					end;
				end;
			else
				notif('Disguise', 'that\'s not an animation pack', 5, 'warning');
			end;
		end;
	end;
	
	Disguise = vape.Legit:CreateModule({
		["Name"] = 'Disguise',
		["Function"] = function(callback: boolean): void
			if callback then
				Disguise:Clean(entitylib.Events.LocalAdded:Connect(characterAdded));
				if entitylib.isAlive then
					characterAdded(entitylib.character);
				end;
			end;
		end,
		["Tooltip"] = 'Changes your character or animation to a specific ID (animation packs or userid\'s only)'
	});
	Mode = Disguise:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Character', 'Animation'},
		["Function"] = function()
			if Disguise["Enabled"] then
				Disguise:Toggle();
				Disguise:Toggle();
			end;
		end;
	});
	IDBox = Disguise:CreateTextBox({
		["Name"] = 'Disguise',
		["Placeholder"] = 'Disguise User Id',
		["Function"] = function()
			if Disguise["Enabled"] then
				Disguise:Toggle();
				Disguise:Toggle();
			end;
		end;
	});
end);
	
velo.run(function()
	local FOV: table;
	local Value: table;
	local oldfov: number;
	
	FOV = vape.Legit:CreateModule({
		["Name"] = 'FOV',
		["Function"] = function(callback: boolean)
			if callback then
				oldfov = gameCamera.FieldOfView;
	
				FOV:Clean(runService.RenderStepped:Connect(function()
					gameCamera.FieldOfView = Value["Value"];
				end));
			else
				gameCamera.FieldOfView = oldfov;
			end;
		end,
		["Tooltip"] = 'Adjusts camera vision'
	});
	Value = FOV:CreateSlider({
		["Name"] = 'FOV',
		["Min"] = 30,
		["Max"] = 120
	});
end);
	
velo.run(function()
	--[[
		Grabbing an accurate count of the current framerate
		Source: https://devforum.roblox.com/t/get-client-FPS-trough-a-script/282631
	]]
	local FPS: table = {["Enabled"] = false}; 
	local label: any;
	FPS = vape.Legit:CreateModule({
		["Name"] = 'FPS',
		["Function"] = function(callback: boolean): void
			if callback then
				local frames: table = {};
				local startClock: number? = os.clock();
				local updateTick: number = tick();
				FPS:Clean(runService.Heartbeat:Connect(function()
					local updateClock: number? = os.clock();
					for i: number = #frames, 1, -1 do
						frames[i + 1] = frames[i] >= updateClock - 1 and frames[i] or nil;
					end;
					frames[1] = updateClock;
					if updateTick < tick() then
						updateTick = tick() + 1;
						label.Text = math.floor(os.clock() - startClock >= 1 and #frames or #frames / (os.clock() - startClock))..' FPS';
					end;
				end));
			end;
		end,
		["Size"] = UDim2.fromOffset(100, 41),
		["Tooltip"] = 'Shows the current framerate'
	});
	FPS:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val: any)
			label.FontFace = val;
		end;
	});
	FPS:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue: any, sat: any, val: any, opacity: any)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			label.BackgroundTransparency = 1 - opacity;
		end;
	});
	label = Instance.new('TextLabel');
	label.Size = UDim2.fromScale(1, 1);
	label.BackgroundTransparency = 0.5;
	label.TextSize = 15;
	label.Font = Enum.Font.Gotham;
	label.Text = 'inf FPS';
	label.TextColor3 = Color3.new(1, 1, 1);
	label.BackgroundColor3 = Color3.new();
	label.Parent = FPS.Children;
	local corner: UICorner = Instance.new('UICorner');
	corner.CornerRadius = UDim.new(0, 4);
	corner.Parent = label;
end);
	
velo.run(function()
	local Keystrokes: table = {["Enabled"] = false}; 
	local Style: table = {}; 
	local Color: table = {};
	local keys: any, holder: table? = {};
	
	local createKeystroke: (keybutton: any, pos: any, pos2: any, text: TextLabel?) -> () = function(keybutton: any, pos: any, pos2: any, text: TextLabel?): ()
		if keys[keybutton] then
			keys[keybutton].Key:Destroy();
			keys[keybutton] = nil;
		end;
		local key: Frame = Instance.new('Frame');
		key.Size = keybutton == Enum.KeyCode.Space and UDim2.new(0, 110, 0, 24) or UDim2.new(0, 34, 0, 36);
		key.BackgroundColor3 = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
		key.BackgroundTransparency = 1 - Color["Opacity"];
		key.Position = pos;
		key.Name = keybutton.Name;
		key.Parent = holder;
		local keytext: TextLabel = Instance.new('TextLabel');
		keytext.BackgroundTransparency = 1;
		keytext.Size = UDim2.fromScale(1, 1);
		keytext.Font = Enum.Font.Gotham;
		keytext.Text = text or keybutton.Name;
		keytext.TextXAlignment = Enum.TextXAlignment.Left;
		keytext.TextYAlignment = Enum.TextYAlignment.Top;
		keytext.Position = pos2;
		keytext.TextSize = keybutton == Enum.KeyCode.Space and 18 or 15;
		keytext.TextColor3 = Color3.new(1, 1, 1);
		keytext.Parent = key;
		local corner: UICorner = Instance.new('UICorner');
		corner.CornerRadius = UDim.new(0, 4);
		corner.Parent = key;
		keys[keybutton] = {["Key"] = key};
	end;
	
	Keystrokes = vape.Legit:CreateModule({
		["Name"] = 'Keystrokes',
		["Function"] = function(callback: boolean): void
			if callback then
				createKeystroke(Enum.KeyCode.W, UDim2.new(0, 38, 0, 0), UDim2.new(0, 6, 0, 5), Style["Value"] == 'Arrow' and '↑' or nil);
				createKeystroke(Enum.KeyCode.S, UDim2.new(0, 38, 0, 42), UDim2.new(0, 8, 0, 5), Style["Value"] == 'Arrow' and '↓' or nil);
				createKeystroke(Enum.KeyCode.A, UDim2.new(0, 0, 0, 42), UDim2.new(0, 7, 0, 5), Style["Value"] == 'Arrow' and '←' or nil);
				createKeystroke(Enum.KeyCode.D, UDim2.new(0, 76, 0, 42), UDim2.new(0, 8, 0, 5), Style["Value"] == 'Arrow' and '→' or nil);
	
				Keystrokes:Clean(inputService.InputBegan:Connect(function(inputType: InputObject?)
					local key: any = keys[inputType.KeyCode];
					if key then
						if key.Tween then
							key.Tween:Cancel();
						end;
						if key.Tween2 then
							key.Tween2:Cancel();
						end;
	
						key.Pressed = true;
						key.Tween = tweenService:Create(key.Key, TweenInfo.new(0.1), {
							["BackgroundColor3"] = Color3.new(1, 1, 1), 
							["BackgroundTransparency"] = 0
						});
						key.Tween2 = tweenService:Create(key.Key.TextLabel, TweenInfo.new(0.1), {
							["TextColor3"] = Color3.new()
						});
						key.Tween:Play();
						key.Tween2:Play();
					end;
				end));
	
				Keystrokes:Clean(inputService.InputEnded:Connect(function(inputType: InputObject?)
					local key: any = keys[inputType.KeyCode];
					if key then
						if key.Tween then
							key.Tween:Cancel();
						end;
						if key.Tween2 then
							key.Tween2:Cancel();
						end;
	
						key.Pressed = false;
						key.Tween = tweenService:Create(key.Key, TweenInfo.new(0.1), {
							["BackgroundColor3"] = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]), 
							["BackgroundTransparency"] = 1 - Color["Opacity"]
						});
						key.Tween2 = tweenService:Create(key.Key.TextLabel, TweenInfo.new(0.1), {
							["TextColor3"] = Color3.new(1, 1, 1)
						});
						key.Tween:Play();
						key.Tween2:Play();
					end;
				end));
			end;
		end,
		["Size"] = UDim2.fromOffset(110, 176),
		["Tooltip"] = 'Shows movement keys onscreen'
	});
	holder = Instance.new('Frame');
	holder.Size = UDim2.fromScale(1, 1);
	holder.BackgroundTransparency = 1;
	holder.Parent = Keystrokes.Children;
	Style = Keystrokes:CreateDropdown({
		["Name"] = 'Key Style',
		["List"] = {'Keyboard', 'Arrow'},
		["Function"] = function()
			if Keystrokes["Enabled"] then
				Keystrokes:Toggle();
				Keystrokes:Toggle();
			end;
		end;
	});
	Color = Keystrokes:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue: any, sat: any, val: any, opacity: any)
			for _, v: any in keys do
				if not v.Pressed then
					v.Key.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
					v.Key.BackgroundTransparency = 1 - opacity;
				end;
			end;
		end;
	});
	Keystrokes:CreateToggle({
		["Name"] = 'Show Spacebar',
		["Function"] = function(callback: boolean): void
			Keystrokes.Children.Size = UDim2.fromOffset(110, callback and 107 or 78);
			if callback then
				createKeystroke(Enum.KeyCode.Space, UDim2.new(0, 0, 0, 83), UDim2.new(0, 25, 0, -10), '______');
			else
				keys[Enum.KeyCode.Space].Key:Destroy();
				keys[Enum.KeyCode.Space] = nil;
			end;
		end,
		["Default"] = true
	});
end);
	
velo.run(function()
	local Memory: table = {["Enabled"] = false}; 
	local label: any;
	Memory = vape.Legit:CreateModule({
		["Name"] = 'Memory',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					label.Text = math.floor(tonumber(game:GetService('Stats'):FindFirstChild('PerformanceStats').Memory:GetValue()))..' MB';
					task.wait(1);
				until not Memory["Enabled"];
			end;
		end,
		["Size"] = UDim2.fromOffset(100, 41),
		["Tooltip"] = 'A label showing the memory currently used by roblox'
	});
	Memory:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val: any)
			label.FontFace = val;
		end;
	});
	Memory:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue: any, sat: any, val: any, opacity: any)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			label.BackgroundTransparency = 1 - opacity;
		end;
	});
	label = Instance.new('TextLabel');
	label.Size = UDim2.new(0, 100, 0, 41);
	label.BackgroundTransparency = 0.5;
	label.TextSize = 15;
	label.Font = Enum.Font.Gotham;
	label.Text = '0 MB';
	label.TextColor3 = Color3.new(1, 1, 1);
	label.BackgroundColor3 = Color3.new();
	label.Parent = Memory.Children;
	local corner: UICorner = Instance.new('UICorner');
	corner.CornerRadius = UDim.new(0, 4);
	corner.Parent = label;
end);
	
velo.run(function()
	local Ping: table = {["Enabled"] = false}; 
	local label: any;
	Ping = vape.Legit:CreateModule({
		["Name"] = 'Ping',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					label.Text = math.floor(tonumber(game:GetService('Stats'):FindFirstChild('PerformanceStats').Ping:GetValue()))..' ms';
					task.wait(1);
				until not Ping["Enabled"];
			end;
		end,
		["Size"] = UDim2.fromOffset(100, 41),
		["Tooltip"] = 'Shows the current connection speed to the roblox server'
	});
	Ping:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val: any)
			label.FontFace = val;
		end;
	});
	Ping:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue: any, sat: any, val: any, opacity: any)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			label.BackgroundTransparency = 1 - opacity;
		end;
	});
	label = Instance.new('TextLabel');
	label.Size = UDim2.new(0, 100, 0, 41);
	label.BackgroundTransparency = 0.5;
	label.TextSize = 15;
	label.Font = Enum.Font.Gotham;
	label.Text = '0 ms';
	label.TextColor3 = Color3.new(1, 1, 1);
	label.BackgroundColor3 = Color3.new();
	label.Parent = Ping.Children;
	local corner: UICorner = Instance.new('UICorner');
	corner.CornerRadius = UDim.new(0, 4);
	corner.Parent = label;
end);
	
velo.run(function()
	local SongBeats: table = {["Enabled"] = false};
	local List: table = {};
	local FOV: table = {["Enabled"] = false};
	local FOVValue: table = {};
	local Volume: table = {};
	local alreadypicked: any = {};
	local beattick: number = tick();
	local oldfov: any;
	local songobj: Sound;
	local songbpm: any;
	local songtween: any;
	
	local choosesong: () -> () = function(): ()
		local list: any = List.ListEnabled;
		if #alreadypicked >= #list then
			table.clear(alreadypicked);
		end;
	
		if #list <= 0 then
			notif('SongBeats', 'no songs', 10);
			SongBeats:Toggle();
			return;
		end;
	
		local chosensong: table? = list[math.random(1, #list)];
		if #list > 1 and table.find(alreadypicked, chosensong) then
			repeat
				task.wait();
				chosensong = list[math.random(1, #list)];
			until not table.find(alreadypicked, chosensong) or not SongBeats["Enabled"];
		end;
		if not SongBeats["Enabled"] then return; end;
	
		local split: string? = chosensong:split('/');
		if not isfile(split[1]) then
			notif('SongBeats', 'Missing song ('..split[1]..')', 10);
			SongBeats:Toggle();
			return;
		end;
	
		songobj.SoundId = assetfunction(split[1]);
		repeat task.wait(); until songobj.IsLoaded or not SongBeats["Enabled"];
		if SongBeats["Enabled"] then
			beattick = tick() + (tonumber(split[3]) or 0);
			songbpm = 60 / (tonumber(split[2]) or 50);
			songobj:Play();
		end;
	end;
	
	SongBeats = vape.Legit:CreateModule({
		["Name"] = 'Song Beats',
		["Function"] = function(callback: boolean):void
			if callback then
				songobj = Instance.new('Sound');
				songobj.Volume = Volume["Value"] / 100;
				songobj.Parent = workspace;
				oldfov = gameCamera.FieldOfView;
	
				repeat
					if not songobj.Playing then
						choosesong();
					end;
					if beattick < tick() and SongBeats["Enabled"] and FOV["Enabled"] then
						beattick = tick() + songbpm;
						gameCamera.FieldOfView = oldfov - FOVValue["Value"];
						songtween = tweenService:Create(gameCamera, TweenInfo.new(math.min(songbpm, 0.2), Enum.EasingStyle.Linear), {
							["FieldOfView"] = oldfov
						});
						songtween:Play();
					end;
					task.wait();
				until not SongBeats["Enabled"];
			else
				if songobj then
					songobj:Destroy();
				end;
				if songtween then
					songtween:Cancel();
				end;
				if oldfov then
					gameCamera.FieldOfView = oldfov;
				end;
				table.clear(alreadypicked);
			end;
		end,
		["Tooltip"] = 'Built in mp3 player'
	});
	List = SongBeats:CreateTextList({
		["Name"] = 'Songs',
		["Placeholder"] = 'filepath/bpm/start'
	});
	FOV = SongBeats:CreateToggle({
		["Name"] = 'Beat FOV',
		["Function"] = function(callback: boolean): void
			if FOVValue.Object then
				FOVValue.Object.Visible = callback;
			end;
			if SongBeats["Enabled"] then
				SongBeats:Toggle();
				SongBeats:Toggle();
			end;
		end,
		["Default"] = true
	});
	FOVValue = SongBeats:CreateSlider({
		["Name"] = 'Adjustment',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 5,
		["Darker"] = true
	});
	Volume = SongBeats:CreateSlider({
		["Name"] = 'Volume',
		["Function"] = function(val: any)
			if songobj then
				songobj.Volume = val / 100;
			end;
		end,
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 100,
		["Suffix"] = '%'
	});
end);
	
velo.run(function()
	local Speedmeter: table = {["Enabled"] = false};
	local label: any;
	Speedmeter = vape.Legit:CreateModule({
		["Name"] = 'Speedmeter',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					local lastpos: any = entitylib.isAlive and entitylib.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1) or Vector3.zero;
					local dt: any = task.wait(0.2);
					local newpos: any = entitylib.isAlive and entitylib.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1) or Vector3.zero;
					label.Text = math.round(((lastpos - newpos) / dt).Magnitude)..' sps';
				until not Speedmeter["Enabled"];
			end;
		end,
		["Size"] = UDim2.fromOffset(100, 41),
		["Tooltip"] = 'A label showing the average velocity in studs'
	});
	Speedmeter:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val: any)
			label.FontFace = val;
		end;
	});
	Speedmeter:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue: any, sat: any, val: any, opacity: any)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			label.BackgroundTransparency = 1 - opacity;
		end;
	});
	label = Instance.new('TextLabel');
	label.Size = UDim2.fromScale(1, 1);
	label.BackgroundTransparency = 0.5;
	label.TextSize = 15;
	label.Font = Enum.Font.Gotham;
	label.Text = '0 sps';
	label.TextColor3 = Color3.new(1, 1, 1);
	label.BackgroundColor3 = Color3.new();
	label.Parent = Speedmeter.Children;
	local corner: UICorner = Instance.new('UICorner');
	corner.CornerRadius = UDim.new(0, 4);
	corner.Parent = label;
end);
	
velo.run(function()
	local TimeChanger: table = {["Enabled"] = false};
	local Value: table = {["Value"] = 12};
	local old: any;
	TimeChanger = vape.Legit:CreateModule({
		["Name"] = 'Time Changer',
		["Function"] = function(callback: boolean): void
			if callback then
				old = lightingService.TimeOfDay;
				lightingService.TimeOfDay = Value["Value"]..':00:00';
			else
				lightingService.TimeOfDay = old;
				old = nil;
			end;
		end,
		["Tooltip"] = 'Change the time of the current world'
	});
	Value = TimeChanger:CreateSlider({
		["Name"] = 'Time',
		["Min"] = 0,
		["Max"] = 24,
		["Default"] = 12,
		["Function"] = function(val: any)
			if TimeChanger["Enabled"] then 
				lightingService.TimeOfDay = val..':00:00';
			end;
		end;
	});
end);

--[[


██╗░░░██╗███████╗██╗░░░░░░█████╗░░█████╗░██╗████████╗██╗░░░██╗
██║░░░██║██╔════╝██║░░░░░██╔══██╗██╔══██╗██║╚══██╔══╝╚██╗░██╔╝
╚██╗░██╔╝█████╗░░██║░░░░░██║░░██║██║░░╚═╝██║░░░██║░░░░╚████╔╝░
░╚████╔╝░██╔══╝░░██║░░░░░██║░░██║██║░░██╗██║░░░██║░░░░░╚██╔╝░░
░░╚██╔╝░░███████╗███████╗╚█████╔╝╚█████╔╝██║░░░██║░░░░░░██║░░░
░░░╚═╝░░░╚══════╝╚══════╝░╚════╝░░╚════╝░╚═╝░░░╚═╝░░░░░░╚═╝░░░

	- The Velocity Universal Custom Modules starts here.
	- reformatted and fixed by: Copium
]]

velo.run(function()
	local Envision: table = {["Enabled"] = false};
	local MotionBlur: table = {["Enabled"] = false};
	local MotionBlurIntensity: table = {["Value"] = 8.5};
	local Trails: table = {["Enabled"] = false};
	local TrailDistance: table = {["Value"] = 7};
	local TrailColor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 0};
	local Fire: table = {["Enabled"] = false};
	local FireParent: table = {["Value"] = 'PrimaryPart'};
	local FireFlame: table = {["Value"] = 25};
	local FireColor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 0};
	local FireColor2: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 0};
	local Sparkle: table = {["Enabled"] = false};
	local SparklesParent: table = {["Value"] = 'PrimaryPart'};
	local SparklesColor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 0};
	local maxTrailParts: number = 50;
	local trailinfo: TweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad);
	local trailparts: {Part} = {};
	local lastpos: Vector3? = nil;
	local fireobject: Fire? = nil;
	local sparklesobject: Sparkles? = nil;
	local hsv: (slider: table) -> Color3 = function(slider: table): Color3
		return Color3.fromHSV(slider["Hue"], slider["Sat"], slider["Value"]);
	end;
	local restart: () -> () = function(): ()
		if Envision["Enabled"] then
			Envision:Toggle();
			Envision:Toggle();
		end;
	end;
	local getEffectParent: (option: string) -> Instance? = function(option: string): Instance?
		local character: Model? = lplr.Character;
		local camera: Camera? = workspace.CurrentCamera;
		if not character or not camera then
			return nil;
		end;
		if (camera.CFrame.Position - camera.Focus.Position).Magnitude <= 0.6 then
			return character;
		end;
		return character:FindFirstChild(option) or character.PrimaryPart;
	end;
	local setParent: (object: Instance?, option: string) -> () = function(object: Instance?, option: string): ()
		if not object then return; end;
		local parent: Instance? = getEffectParent(option);
		if object.Parent ~= parent then
			pcall(function()
				object.Parent = parent;
			end);
		end;
	end;
	local updateEffects: () -> () = function(): ()
		setParent(fireobject, FireParent["Value"]);
		setParent(sparklesobject, SparklesParent["Value"]);
	end;
	local destroyEffects: () -> () = function(): ()
		if fireobject then
			fireobject:Destroy();
			fireobject = nil;
		end;
		if sparklesobject then
			sparklesobject:Destroy();
			sparklesobject = nil;
		end;
	end;
	local createEffects: () -> () = function(): ()
		destroyEffects();
		if Fire["Enabled"] then
			local object: Fire = Instance.new('Fire');
			object.Color = hsv(FireColor);
			object.SecondaryColor = hsv(FireColor2);
			object.Heat = FireFlame["Value"];
			fireobject = object;
		end;
		if Sparkle["Enabled"] then
			local object: Sparkles = Instance.new('Sparkles');
			object.SparkleColor = hsv(SparklesColor);
			sparklesobject = object;
		end;
		updateEffects();
	end;
	local createtrailpart: (cframe: CFrame, folder: Folder) -> () = function(cframe: CFrame, folder: Folder): ()
		local part: Part = Instance.new('Part');
		part.Anchored = true;
		part.CanCollide = false;
		part.CanQuery = false;
		part.CanTouch = false;
		part.CastShadow = false;
		part.Material = Enum.Material.Neon;
		part.Size = Vector3.new(2, 1, 1);
		part.Shape = Enum.PartType.Ball;
		part.Color = hsv(TrailColor);
		part.CFrame = cframe;
		part.Parent = folder;
		lastpos = cframe.Position;
		table.insert(trailparts, part);
		if #trailparts > maxTrailParts then
			table.remove(trailparts, 1):Destroy();
		end;
		task.delay(2.5, function()
			if not part.Parent then return; end;
			local tween: Tween = tweenService:Create(part, trailinfo, {["Transparency"] = 1});
			tween.Completed:Once(function()
				local index: number? = table.find(trailparts, part);
				if index then
					table.remove(trailparts, index);
				end;
				part:Destroy();
			end);
			tween:Play();
		end);
	end;
	local startTrails: () -> () = function(): ()
		local folder: Folder = Instance.new('Folder');
		folder.Name = 'EnvisionTrails';
		folder.Parent = workspace;
		Envision:Clean(folder);
		Envision:Clean(function()
			table.clear(trailparts);
			lastpos = nil;
		end);
		Envision:Clean(task.spawn(function()
			repeat
				local root: BasePart? = entitylib.isAlive and entitylib.character.RootPart or nil;
				if root and (not lastpos or (root.Position - lastpos).Magnitude > TrailDistance["Value"]) then
					createtrailpart(root.CFrame, folder);
				end;
				task.wait(0.03);
			until false;
		end));
	end;
	local startMotionBlur: () -> () = function(): ()
		local blur: BlurEffect = Instance.new('BlurEffect');
		blur.Size = 0;
		blur.Parent = lightingService;
		Envision:Clean(blur);
		local lastlook: Vector3? = nil;
		Envision:Clean(runService.RenderStepped:Connect(function(delta: number)
			local camera: Camera? = workspace.CurrentCamera;
			if not camera then return; end;
			local look: Vector3 = camera.CFrame.LookVector;
			local speed: number = lastlook and (look - lastlook).Magnitude / math.max(delta, 1 / 240) or 0;
			lastlook = look;
			local target: number = math.min(speed * MotionBlurIntensity["Value"] * 0.5, 56);
			local size: number = blur.Size + (target - blur.Size) * math.min(delta * 15, 1);
			if math.abs(size - blur.Size) > 0.05 then
				blur.Size = size;
			end;
		end));
	end;

	Envision = vape.Legit:CreateModule({
		["Name"] = "Envision",
		["Tooltip"] = "Lets you customize visuals!",
		["Function"] = function(callback: boolean): void
			if callback then
				if MotionBlur["Enabled"] then
					startMotionBlur();
				end;
				if Trails["Enabled"] then
					startTrails();
				end;
				if Fire["Enabled"] or Sparkle["Enabled"] then
					createEffects();
					Envision:Clean(destroyEffects);
					Envision:Clean(lplr.CharacterAdded:Connect(createEffects));
					Envision:Clean(task.spawn(function()
						repeat
							task.wait(0.1);
							updateEffects();
						until false;
					end));
				end;
			end;
		end
	});
	MotionBlur = Envision:CreateToggle({
		["Name"] = 'Motion Blur',
		["Tooltip"] = 'Blurs your screen while you turn your camera.',
		["Default"] = false,
		["Function"] = restart
	});
	MotionBlurIntensity = Envision:CreateSlider({
		["Name"] = 'Intensity',
		["Min"] = 2,
		["Max"] = 10,
		["Default"] = 8.5
	});
	Trails = Envision:CreateToggle({
		["Name"] = 'Trails Effect',
		["Tooltip"] = 'Leaves a trail of neon orbs behind you.',
		["Default"] = false,
		["Function"] = restart
	});
	TrailDistance = Envision:CreateSlider({
		["Name"] = 'Distance',
		["Min"] = 3,
		["Max"] = 10
	});
	TrailColor = Envision:CreateColorSlider({
		["Name"] = 'Trail Color',
		["Function"] = function(): ()
			local color: Color3 = hsv(TrailColor);
			for _, part: Part in trailparts do
				part.Color = color;
			end;
		end
	});
	Fire = Envision:CreateToggle({
		["Name"] = 'Fire Effect',
		["Tooltip"] = 'Sets your character on fire.',
		["Default"] = false,
		["Function"] = restart
	});
	FireParent = Envision:CreateDropdown({
		["Name"] = 'Parent',
		["List"] = {'PrimaryPart', 'Head'},
		["Function"] = updateEffects
	});
	FireFlame = Envision:CreateSlider({
		["Name"] = 'Flame',
		["Min"] = 1,
		["Max"] = 25,
		["Default"] = 25,
		["Function"] = function(value: number): ()
			if fireobject then
				fireobject.Heat = value;
			end;
		end
	});
	FireColor = Envision:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function(): ()
			if fireobject then
				fireobject.Color = hsv(FireColor);
			end;
		end
	});
	FireColor2 = Envision:CreateColorSlider({
		["Name"] = 'Color 2',
		["Function"] = function(): ()
			if fireobject then
				fireobject.SecondaryColor = hsv(FireColor2);
			end;
		end
	});
	Sparkle = Envision:CreateToggle({
		["Name"] = 'Sparkle Effect',
		["Tooltip"] = 'Adds sparkles to your character.',
		["Default"] = false,
		["Function"] = restart
	});
	SparklesParent = Envision:CreateDropdown({
		["Name"] = 'Sparkles Parent',
		["List"] = {'PrimaryPart', 'Head'},
		["Function"] = updateEffects
	});
	SparklesColor = Envision:CreateColorSlider({
		["Name"] = 'Sparkles Color',
		["Function"] = function(): ()
			if sparklesobject then
				sparklesobject.SparkleColor = hsv(SparklesColor);
			end;
		end
	});
end);

velo.run(function()
	local CustomChar: table = {["Enabled"] = false};
	local CustomCharHeadless: table = {["Enabled"] = false};
	local CustomCharMode: table = {["Value"] = 'Azura'};
	local CustomCharFill: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 1};
	local CustomCharOutline: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 1};
	local CustomCharFillTransparency: table = {["Value"] = 50};
	local CustomCharOutlineTransparency: table = {["Value"] = 0};
	local CustomCharCostume: table = {["Value"] = 'Nightmare'};
	local followers: Instance? = nil;
	local original: {[Instance]: number} = {};
	local costumes: {[Model]: table} = {};
	local headlessParts: {Instance} = {};
	local highlight: Highlight? = nil;
	local session: number = 0;
	local restart: () -> () = function(): ()
		if CustomChar["Enabled"] then
			CustomChar:Toggle();
			CustomChar:Toggle();
		end;
	end;
	local hidePart: (part: any, list: {Instance}) -> () = function(part: any, list: {Instance}): ()
		if original[part] == nil then
			original[part] = part.Transparency;
			table.insert(list, part);
		end;
		part.Transparency = 1;
	end;
	local restoreParts: (list: {Instance}) -> () = function(list: {Instance}): ()
		for _, part: any in list do
			local value: number? = original[part];
			if value ~= nil then
				original[part] = nil;
				part.Transparency = value;
			end;
		end;
		table.clear(list);
	end;
	local hideChild: (child: Instance, list: {Instance}) -> () = function(child: Instance, list: {Instance}): ()
		if child:IsA('BasePart') then
			hidePart(child, list);
			if child.Name == 'Head' then
				for _, decal: Instance in child:GetChildren() do
					if decal:IsA('Decal') then
						hidePart(decal, list);
					end;
				end;
			end;
		elseif child:IsA('Accessory') then
			local handle: Instance? = child:FindFirstChild('Handle');
			if handle and handle:IsA('BasePart') then
				hidePart(handle, list);
			end;
		end;
	end;
	local buildCostume: (character: Model, root: BasePart) -> Instance? = function(character: Model, root: BasePart): Instance?
		local name: string = CustomCharCostume["Value"];
		local anchor: BasePart = root;
		local costume: Instance;
		if name == 'amongusv2' then
			local part: Part = Instance.new('Part');
			part.Name = 'AmongUsPart';
			local mesh: SpecialMesh = Instance.new('SpecialMesh');
			mesh.MeshId = 'rbxassetid://6235963214';
			mesh.TextureId = 'rbxassetid://6235963270';
			mesh.Offset = Vector3.new(0, 0.3, 0);
			mesh.Scale = Vector3.new(0.11, 0.11, 0.11);
			mesh.Parent = part;
			costume = part;
			local torso: Instance? = character:FindFirstChild('UpperTorso') or character:FindFirstChild('Torso');
			if torso and torso:IsA('BasePart') then
				anchor = torso;
			end;
		else
			local template: Instance? = followers and followers:FindFirstChild(name);
			if not template or not template:IsA('PVInstance') then
				return nil;
			end;
			costume = template:Clone();
			costume.Name = 'Follower';
		end;
		local parts: {BasePart} = costume:IsA('BasePart') and {costume} or {};
		for _, desc: Instance in costume:GetDescendants() do
			if desc:IsA('BasePart') then
				table.insert(parts, desc);
			end;
		end;
		for _, part: BasePart in parts do
			part.Anchored = false;
			part.CanCollide = false;
			part.CanQuery = false;
			part.CanTouch = false;
			part.Massless = true;
		end;
		(costume :: any):PivotTo(anchor.CFrame);
		costume.Parent = character;
		for _, part: BasePart in parts do
			local weld: Weld = Instance.new('Weld');
			weld.Part0 = anchor;
			weld.Part1 = part;
			weld.C0 = anchor.CFrame:ToObjectSpace(part.CFrame);
			weld.Parent = part;
		end;
		return costume;
	end;
	local applyCostume: (ent: table) -> () = function(ent: table): ()
		local character: Model? = ent.Character;
		if not ent.Player or not character or not ent.RootPart or costumes[character] or not character.Parent then
			return;
		end;
		local costume: Instance? = buildCostume(character, ent.RootPart);
		if not costume then
			return;
		end;
		local parts: {Instance} = {};
		for _, child: Instance in character:GetChildren() do
			if child ~= costume then
				hideChild(child, parts);
			end;
		end;
		costumes[character] = {
			["Costume"] = costume,
			["Parts"] = parts,
			["Connection"] = character.ChildAdded:Connect(function(child: Instance)
				hideChild(child, parts);
			end)
		};
	end;
	local removeCostume: (character: Model?) -> () = function(character: Model?): ()
		local data: table? = character and costumes[character];
		if not data then
			return;
		end;
		costumes[character] = nil;
		data.Connection:Disconnect();
		data.Costume:Destroy();
		restoreParts(data.Parts);
	end;
	local applyHeadless: (character: Model?) -> () = function(character: Model?): ()
		local head: Instance? = character and character:FindFirstChild('Head');
		if head then
			hideChild(head, headlessParts);
		end;
	end;
	local updateHighlight: () -> () = function(): ()
		if not highlight then
			return;
		end;
		highlight.FillColor = Color3.fromHSV(CustomCharFill["Hue"], CustomCharFill["Sat"], CustomCharFill["Value"]);
		highlight.OutlineColor = Color3.fromHSV(CustomCharOutline["Hue"], CustomCharOutline["Sat"], CustomCharOutline["Value"]);
		highlight.FillTransparency = CustomCharFillTransparency["Value"] / 100;
		highlight.OutlineTransparency = CustomCharOutlineTransparency["Value"] / 100;
	end;
	local applyHighlight: (character: Model) -> () = function(character: Model): ()
		if highlight then
			highlight:Destroy();
		end;
		local object: Highlight = Instance.new('Highlight');
		object.Name = 'velo_cc';
		object.DepthMode = Enum.HighlightDepthMode.Occluded;
		object.Adornee = character;
		highlight = object;
		updateHighlight();
		object.Parent = character;
	end;
	local sweep: () -> () = function(): ()
		for character: Model in costumes do
			if not character.Parent then
				removeCostume(character);
			end;
		end;
		if headlessParts[1] and not headlessParts[1]:IsDescendantOf(workspace) then
			restoreParts(headlessParts);
		end;
		for part: any in original do
			if part.Transparency ~= 1 then
				part.Transparency = 1;
			end;
		end;
	end;
	CustomChar = vape.Categories.Velocity:CreateModule({
		["Name"] = 'CustomCharacter',
		["Tooltip"] = 'Customizes your character.',
		["Function"] = function(callback: boolean): void
			session += 1;
			if not callback then
				return;
			end;
			local id: number = session;
			local moon: boolean = CustomCharMode["Value"] == 'Moon';
			if moon and CustomCharCostume["Value"] ~= 'amongusv2' and not followers then
				local suc: boolean, res: any = pcall(function()
					return game:GetObjects('rbxassetid://14289122777')[1];
				end);
				followers = suc and res or nil;
				if id ~= session or not CustomChar["Enabled"] then
					return;
				end;
			end;
			CustomChar:Clean(function()
				for character: Model in costumes do
					removeCostume(character);
				end;
				restoreParts(headlessParts);
				if highlight then
					highlight:Destroy();
					highlight = nil;
				end;
			end);
			if moon then
				CustomChar:Clean(entitylib.Events.EntityAdded:Connect(applyCostume));
				CustomChar:Clean(entitylib.Events.LocalAdded:Connect(applyCostume));
				CustomChar:Clean(entitylib.Events.EntityRemoved:Connect(function(ent: table)
					removeCostume(ent.Character);
				end));
				CustomChar:Clean(entitylib.Events.LocalRemoved:Connect(function(ent: table)
					removeCostume(ent.Character);
				end));
				for _, ent: table in entitylib.List do
					applyCostume(ent);
				end;
				if entitylib.isAlive then
					applyCostume(entitylib.character);
				end;
			else
				CustomChar:Clean(lplr.CharacterAdded:Connect(applyHighlight));
				if lplr.Character then
					applyHighlight(lplr.Character);
				end;
			end;
			if CustomCharHeadless["Enabled"] then
				CustomChar:Clean(entitylib.Events.LocalAdded:Connect(function(ent: table)
					applyHeadless(ent.Character);
				end));
				CustomChar:Clean(entitylib.Events.LocalRemoved:Connect(function()
					restoreParts(headlessParts);
				end));
				if entitylib.isAlive then
					applyHeadless(entitylib.character.Character);
				end;
			end;
			if moon or CustomCharHeadless["Enabled"] then
				CustomChar:Clean(task.spawn(function()
					repeat
						task.wait(1);
						sweep();
					until false;
				end));
			end;
		end,
		["ExtraText"] = function(): string
			return CustomCharMode["Value"] == 'Moon' and CustomCharCostume["Value"] or CustomCharMode["Value"];
		end
	});
	CustomCharFill = CustomChar:CreateColorSlider({
		["Name"] = 'Fill Color',
		["Tooltip"] = 'Color to fill your character.',
		["Function"] = updateHighlight
	});
	CustomCharOutline = CustomChar:CreateColorSlider({
		["Name"] = 'Outline Color',
		["Tooltip"] = 'Color to outline your character.',
		["Function"] = updateHighlight
	});
	CustomCharFillTransparency = CustomChar:CreateSlider({
		["Name"] = 'Fill Transparency',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 50,
		["Tooltip"] = 'Transparency of the character color fill.',
		["Function"] = updateHighlight
	});
	CustomCharOutlineTransparency = CustomChar:CreateSlider({
		["Name"] = 'Outline Transparency',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 0,
		["Tooltip"] = 'Transparency of the character outline fill.',
		["Function"] = updateHighlight
	});
	CustomCharHeadless = CustomChar:CreateToggle({
		["Name"] = 'Headless',
		["Tooltip"] = 'Gives you headless.',
		["Function"] = restart
	});
	CustomCharMode = CustomChar:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Moon', 'Azura'},
		["Default"] = 'Azura',
		["Tooltip"] = 'Moon: costumes on every player. Azura: highlight on you.',
		["Function"] = restart
	});
	CustomCharCostume = CustomChar:CreateDropdown({
		["Name"] = 'Costume',
		["List"] = {
			'Freddy Plush',
			'amongusv2',
			'amongus',
			'chair',
			'friday',
			'maxwell',
			'paimon',
			'floppa',
			'Nightmare',
			'Nightmare Bonnie',
			'Dababy',
			'Bugs Bunny',
			'Rabbid',
			'KFC',
			'Furry',
			'Squidward'
		},
		["Default"] = 'Nightmare',
		["Function"] = function(): ()
			if CustomCharMode["Value"] == 'Moon' then
				restart();
			end;
		end
	});
end);

velo.run(function()
	local Cape: table = {["Enabled"] = false};
	local Texture: any;
	local part: any, motor: any;
	local CapeMode: table = {["Value"] = "Velocity"};
	local capeModeMap: table = {
		["Vape"] = "rbxassetid://13380453812",
		["Portal"] = "rbxassetid://14694086869",
		["Copium"] = "rbxassetid://14694061995",
		["Velocity"] = "rbxassetid://16728149213",
		["Azura"] = "rbxassetid://128937881305197",
		["Ape"] = "rbxassetid://93367474508586",
		["Laserware"] = "rbxassetid://125791563280089",
		["Snoopy"] = "rbxassetid://89328429998004",
		["Render"] = "rbxassetid://17140106485"
	};
	local createMotor: (char: any) -> () = function(char: any): ()
		if motor then 
			motor:Destroy(); 
		end;
		part.Parent = gameCamera;
		motor = Instance.new('Motor6D');
		motor.MaxVelocity = 0.08;
		motor.Part0 = part;
		motor.Part1 = char.Character:FindFirstChild('UpperTorso') or char.RootPart;
		motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(-90), 0);
		motor.C1 = CFrame.new(0, motor.Part1.Size.Y / 2, 0.45) * CFrame.Angles(0, math.rad(90), 0);
		motor.Parent = part;
	end;
	
	Cape = vape.Legit:CreateModule({
		["Name"] = 'Cape',
		["Function"] = function(callback: boolean): void
			if callback then
				part = Instance.new('Part');
				part.Size = Vector3.new(2, 4, 0.1);
				part.CanCollide = false;
				part.CanQuery = false;
				part.Massless = true;
				part.Transparency = 0;
				part.Material = Enum.Material.SmoothPlastic;
				part.Color = Color3.new();
				part.CastShadow = false;
				part.Parent = gameCamera;
				local capesurface: SurfaceGui = Instance.new('SurfaceGui');
				capesurface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud;
				capesurface.Adornee = part;
				capesurface.Parent = part;
	
				if Texture["Value"]:find('.webm') then
					local decal: VideoFrame = Instance.new('VideoFrame');
					decal.Video = getcustomasset(Texture["Value"]);
					decal.Size = UDim2.fromScale(1, 1);
					decal.BackgroundTransparency = 1;
					decal.Looped = true;
					decal.Parent = capesurface;
					decal:Play();
				else
					local decal: ImageLabel = Instance.new('ImageLabel');
					decal.Image = Texture["Value"] ~= '' and (Texture["Value"]:find('rbxasset') and Texture["Value"] or assetfunction(Texture["Value"])) or 'rbxassetid://14637958134';
					decal.Size = UDim2.fromScale(1, 1);
					decal.BackgroundTransparency = 1;
					decal.Parent = capesurface;
				end;
				Cape:Clean(part);
				Cape:Clean(entitylib.Events.LocalAdded:Connect(createMotor));
				if entitylib.isAlive then
					createMotor(entitylib.character);
				end;
	
				repeat
					if motor and entitylib.isAlive then
						local velo: number = math.min(entitylib.character.RootPart.Velocity.Magnitude, 90);
						motor.DesiredAngle = math.rad(6) + math.rad(velo) + (velo > 1 and math.abs(math.cos(tick() * 5)) / 3 or 0);
					end;
					capesurface["Enabled"] = (gameCamera.CFrame.Position - gameCamera.Focus.Position).Magnitude > 0.6;
					part.Transparency = (gameCamera.CFrame.Position - gameCamera.Focus.Position).Magnitude > 0.6 and 0 or 1;
					task.wait();
				until not Cape["Enabled"];
			else
				part = nil;
				motor = nil;
			end;
		end,
		["Tooltip"] = 'Add\'s a cape to your character'
	});
	Texture = Cape:CreateTextBox({
		["Name"] = 'Texture'
	});
	CapeMode = Cape:CreateDropdown({
		["Name"] ='Mode',
		["List"] = {
			'Vape',
			'Render',
			'Portal',
			'Copium',
			'Azura',
			'Ape',
			'Laserware',
			'Snoopy',
			'Velocity'
		},
		["HoverText"] = 'A cape mod.',
		["Value"] = 'Velocity',
		["Function"] = function(val: any) 
			if capeModeMap[val] then
                Texture["Value"] = capeModeMap[val];
            end;
		end
	});
end);

velo.run(function()
	local SkidRoaster: table = {["Enabled"] = false};
	local Mode: table = {["Value"] = "Custom"};
	local Delay: table = {["Value"] = 3.3};
	local SkidPhrases: table = {["ListEnabled"] = {}};
	local cope: table = {
	    "Snoopy more like shitnoopy!", "Skidding = NN", "Moon on top!", "UwuHub = skidding before GTA 6 LMFAO",
	    "Snoopy + Grass = skids", "Pisstonware", "Piston loves underaged girls and boys", 
	    "Acronis = NN", "Vape private?? 💀🤡", "Mysticware? = Mysticshit", 
	    "Tryna skid? KYS", "Imagine skidding and calling yourself a coder 🤡", 
	    "Ercho and Abyss still pasting in 2026 💀", "Don't be like Snoopy...", 
	    "Complexware = Skiddedware", "Skid Client & Nebulaware = shit", 
	    "Keep pasting cocosploit/Aurora.", "Voidware = garbage paste", 
	    "W zenith, W null.wtf, W Render", "Render on top - discord.gg/renderintents", 
	    "Velocity & Night on top RAH"
	};
	SkidRoaster = vape.Categories.Utility:CreateModule({
		["Name"] = "🤡",
		["Tooltip"] = "Roasts skids",
		["Function"] = function(callback: boolean): void
			if not callback then
				return;
			end;
			SkidRoaster:Clean(task.spawn(function(): ()
				local index: number = 0;
				repeat
					local message: string;
					local duration: number = Delay["Value"];
					if Mode["Value"] == "Custom" then
						local list: {string} = SkidPhrases["ListEnabled"] or {};
						message = #list > 0 and list[math.random(1, #list)] or "Voidware still pasting in 2025 be like 💀🤡";
					else
						index = index % #cope + 1;
						message = cope[index];
						duration = 3;
					end;
					notif("Vape", message, duration, 'warning');
					task.wait(Delay["Value"]);
				until false;
			end));
		end
	});
	Mode = SkidRoaster:CreateDropdown({
		["Name"] = "Mode",
		["List"] = {"Custom", "Copium"},
		["Tooltip"] = "Custom: random line from Phrases. Copium: cycles the built-in list."
	});
	SkidPhrases = SkidRoaster:CreateTextList({
		["Name"] = "Phrases"
	});
	Delay = SkidRoaster:CreateSlider({
		["Name"] = "Delay",
		["Min"] = 2,
		["Max"] = 5,
		["Default"] = 2,
		["Suffix"] = "s"
	});
end);

-- credits: Render
velo.run(function()
	local ChatMimic: table = {["Enabled"] = true};
	local ChatShowSender: table = {["Enabled"] = true};
	local CustomBlockList: table = {};
	local blacklisted: table = {
		'niga', 
		'niger', 
		'retard', 
		'ah', 
		'monkey', 
		'black', 
		'hitler', 
		'nazi', 
		'vape', 
		'gay',
		'voidware',
		'trans',
		'fatherless',
		'motherless',
		'noob',
		'shit', 
		'cum', 
		'dick', 
		'pussy', 
		'cock'
	};
	local lastsent: table = {};
	local messages: table = {};
	local sendmessage: (msg: string) -> void = function(msg: string)
		if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg);
		else
			replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, 'All');
		end;
	end;
	ChatMimic = vape.Categories.Utility:CreateModule({
		["Name"] = 'ChatMimic',
		["HoverText"] = 'Mimics others in chat.',
		["Function"] = function(callback: boolean): void
			if callback then 
				table.insert(ChatMimic.Connections, vapeStore.MessageReceived.Event:Connect(function(plr: any, text: any)
					task.wait();
					if plr == lplr or lastsent[plr] and lastsent[plr] > tick() then 
						return ;
					end;
					text = text:gsub('/bedwars', '/tptolobby');
					text = text:gsub('/lobby', '/tptolobby');
					local begin: any = (ChatShowSender["Enabled"] and '['..plr.DisplayName..']: ' or '');
					messages[plr] = (messages[plr] or {});
					if table.find(messages[plr], text) then 
						return;
					end;
					for i: any,v: any in blacklisted do 
						if text:lower():find(v) then 
							return;
						end;
					end;
					for i: any, v: any in next, ({'hack', 'exploit'}) do 
						if text:lower():find(v) and (text:lower():find('i\'m') or text:lower():find('me') or text:lower():find('i am')) then
							return;
						end;
					end;
					for i: any, v: any in next, CustomBlockList.ListEnabled or {} do
						if text:lower():find(v) and v ~= '' then 
							return; 
						end;
					end;
					sendmessage(begin..''..text);
					table.insert(messages, text);
					lastsent[plr] = tick() + 0.45;
				end));
			end;
		end;
	});
	ChatShowSender = ChatMimic:CreateToggle({
		["Name"] = 'Show Sender',
		["Default"] = true,
		["Function"] = function() end
	});
	CustomBlockList = ChatMimic:CreateTextList({
		["Name"] = 'Blacklisted',
		["TempText"] = 'Blacklisted Characters'
	});
end);

velo.run(function()
	local PlayerAttach: table = {["Enabled"] = false};
	local PlayerAttachRange: table = {["Value"] = 50};
	local PlayerAttachPersist: table = {};
	local PlayerAttachPlayers: table = {};
	PlayerAttach = vape.Categories.Velocity:CreateModule({
		["Name"] = 'PlayerAttach',
		["HoverText"] = 'Attach to players',
		["Function"] = function(callback: boolean): void
			if callback then 
				local plrs: any = entitylib.AllPosition({
					["Range"] = PlayerAttachRange["Value"],
					["Wallcheck"] = PlayerAttachPlayers.Walls["Enabled"] or nil,
					["Part"] = 'RootPart',
					["Players"] = PlayerAttachPlayers.Players["Enabled"],
					["NPCs"] = PlayerAttachPlayers.NPCs["Enabled"]
				});
				local found_player: boolean = false;
				local targetEntity: any;
				for i: any, v: any in next, plrs do
					if v and v.RootPart then
						targetEntity = v;
						found_player = true;
						break;
					end;
				end;

				if not found_player then
					return;
				end;
				task.spawn(function()
					repeat
						task.wait(0.1);
						if not entitylib.isAlive and not lplr.Character then 
							return;
						end;
						if targetEntity and targetEntity.RootPart then
							lplr.Character.PrimaryPart.CFrame = targetEntity.RootPart.CFrame;
						else
							return;
						end;
					until not PlayerAttach["Enabled"];
				end);
			end;
		end;
	});
	PlayerAttachRange = PlayerAttach:CreateSlider({
		["Name"] = "Range",
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 50,
		["Function"] = function(val: any)
			PlayerAttachRange["Value"] = val;
		end;
	});
	PlayerAttachPersist = PlayerAttach:CreateToggle({
		["Name"] = "Persist",
		["Default"] = false,
		["Function"] = function(val: any)
			PlayerAttachPersist["Enabled"] = val;
		end;
	});
	PlayerAttachPlayers = PlayerAttach:CreateTargets({
		["Players"] = true, 
		["NPCs"] = true
	});
end);

velo.run(function()
    local AirJump: table = {["Enabled"] = false};
	local Mode: table = {["Value"] = "State"};
	local Power: table = {["Value"] = 50};
	AirJump = vape.Categories.Velocity:CreateModule({
		["Name"] = "AirJump",
        ["HoverText"] = hoverText("Let's you jump in the air."),
		["Function"] = function(callback: boolean): void
			if callback then
				local connection: any = inputService["JumpRequest"]:Connect(function()
					if Mode["Value"] == "State" then
						lplr["Character"]["Humanoid"]:ChangeState("Jumping");
					else
						lplr["Character"]["HumanoidRootPart"]["Velocity"] += Vector3.new(0, Power["Value"], 0);
					end;
				end);
                AirJump["Connection"] = connection;
			else
               	if AirJump["Connection"] then
                    AirJump["Connection"]:Disconnect();
                    AirJump["Connection"] = nil;
                end;
			end;
		end,
        ["Default"] = false,
        ["ExtraText"] = function()
            return Mode["Value"];
        end;
	});
	Mode = AirJump:CreateDropdown({
		["Name"] = "Mode",
		["List"] = {
			"State",
			"Velocity"
		},
		["Default"] = "State",
		["HoverText"] = hoverText("Mode to customize the jumping ability."),
		["Function"] = function() end
	});
	Power = AirJump:CreateSlider({
		["Name"] = "Power",
		["Min"] = 1,
		["Max"] = 100,
		["HoverText"] = hoverText("Power to boost the velocity."),
		["Function"] = function() end,
		["Default"] = 50
	});
end);

velo.run(function()
	local Loader: table = {["Enabled"] = false};
    local Font: table = {["Value"] = "FredokaOne"};
	local Color: table = {
		["Hue"] = 0,
		["Sat"] = 0,
	    ["Value"] = 0
	};
	local Size: table = {["Value"] = 10};
	local Chat: table = {["Enabled"] = true};
	local Vape: table = {["Enabled"] = true};
	local round: (number: number) -> number = function(number: number): number
		local remainder: number? = number % 0.1;
		if remainder >= 0.05 then
			return number + (0.1 - remainder);
		else
			return number - remainder;
		end;
	end;
	Loader = vape.Categories.Velocity:CreateModule({
		["Name"] = "Loader",
		["Function"] = function(callback: boolean): void
			if callback then
				task.spawn(function()
                    local time: string = string.format("%.1f", round(tick() - loadTime));
					local message: string? = "[Velocity] [" .. velocityVersion .. "]:\n- Loaded in " .. time .. " seconds.\n- Logged in as " .. lplr["Name"] .. ".";
					if Chat["Enabled"] then
					    if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						local config: any = textChatService.ChatInputBarConfiguration;
						local targetChannel: any = config and config.TargetTextChannel;
						if targetChannel and targetChannel:IsA("TextChannel") then
							local color: any = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
							local r: any, g: any, b: any = color.R * 255, color.G * 255, color.B * 255;
							local coloredMessage: string? = string.format(
								'<font color="rgb(%d,%d,%d)">%s</font>',
								r, g, b, message
							);
							targetChannel:DisplaySystemMessage(coloredMessage);
						end;
					    else
					        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
					            ["Text"] = message,
					            ["Color"] = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]),
					            ["Font"] = Enum.Font[Font["Value"]],
					            ["TextSize"] = Size["Value"]
					        });
					    end;
					end;                            
				    task.wait();
			        if Vape["Enabled"] then
			            notif("[Velocity] [" .. velocityVersion .. "]", "Loaded in " .. time .. " seconds. Logged in as " .. lplr["Name"] .. ".", 5, 'warning');
			        end;
				end);
			end;
		end,
	});
    Font = Loader:CreateDropdown({
		["Name"] = "Font",
		["List"] = getItems("Font"),
		["HoverText"] = hoverText("Font of the text."),
		["Function"] = function()
			if Loader["Enabled"] then
				Loader:Toggle();
				Loader:Toggle();
			end;
		end;
	});
	Color = Loader:CreateColorSlider({
		["Name"] = "Color",
		["HoverText"] = hoverText("Color of the text."),
		["Function"] = function() end
	});
    Size = Loader:CreateTextBox({
	    ["Name"] = "Size",
	    ["TempText"] = "Size",
	    ["HoverText"] = hoverText("Size of the text."),
	    ["Function"] = function(callback: boolean): void 
	        if callback and Loader["Enabled"] then 
				Loader:Toggle();
				Loader:Toggle();
	        end;
        end;
    });
	Chat = Loader:CreateToggle({
		["Name"] = "Chat",
		["HoverText"] = hoverText("Sends a notification via chat."),
		["Function"] = function() end,
		["Default"] = true
	});
    Vape = Loader:CreateToggle({
		["Name"] = "Vape",
		["HoverText"] = hoverText("Sends a notification via vape."),
		["Function"] = function() end,
		["Default"] = true
	});
end);

velo.run(function()
	local BoostJump: table = {["Enabled"] = false};
	local BoostJumpRepeat: table = {["Value"] = 'Toggle'};
	local BoostJumpMethod: table = {["Value"] = 'Velocity'};
	local BoostJumpVelocity: table = {["Value"] = 600};
	local BoostJumpCFrame: table = {["Value"] = 1000};
	local BoostJumpTween: table = {["Value"] = 1000};
	local BoostJumpDuration: table = {["Value"] = 4};
	local BoostJumpDelay: table = {["Value"] = 7};
	local BoostJumpReduce: table = {["Value"] = 300};
	local BoostJumpSafe: table = {["Enabled"] = true};
	local activeTween: Tween? = nil;
	local verbs: {[string]: string} = {
		["Velocity"] = 'Boosted',
		["CFrame"] = 'Teleported',
		["Tween"] = 'Tweened'
	};
	local getAmount: (keep: boolean) -> number = function(keep: boolean): number
		local mode: string = BoostJumpMethod["Value"];
		local amount: number = mode == 'Velocity' and BoostJumpVelocity["Value"] or mode == 'CFrame' and BoostJumpCFrame["Value"] or BoostJumpTween["Value"];
		if keep and BoostJumpSafe["Enabled"] then
			amount = math.max(amount - BoostJumpReduce["Value"], 0);
		end;
		return amount;
	end;
	local boost: (keep: boolean) -> number? = function(keep: boolean): number?
		if not entitylib.isAlive then
			return nil;
		end;
		local root: BasePart = entitylib.character.RootPart;
		local mode: string = BoostJumpMethod["Value"];
		local amount: number = getAmount(keep);
		if mode == 'Velocity' then
			root.AssemblyLinearVelocity += Vector3.new(0, amount, 0);
		elseif mode == 'CFrame' then
			root.CFrame += Vector3.new(0, amount, 0);
		else
			if activeTween then
				activeTween:Cancel();
			end;
			activeTween = tweenService:Create(root, TweenInfo.new(BoostJumpDuration["Value"] / 10), {
				["CFrame"] = root.CFrame + Vector3.new(0, amount, 0)
			});
			activeTween:Play();
		end;
		return amount;
	end;
	local restart: () -> () = function(): ()
		if BoostJump["Enabled"] then
			BoostJump:Toggle();
			BoostJump:Toggle();
		end;
	end;
	BoostJump = vape.Categories.Velocity:CreateModule({
		["Name"] = 'BoostJump',
		["Tooltip"] = 'Boosts you high up in the air.',
		["Function"] = function(callback: boolean): void
			if not callback then
				return;
			end;
			if BoostJumpRepeat["Value"] == 'Toggle' then
				local amount: number? = boost(false);
				if amount then
					notif('BoostJump', verbs[BoostJumpMethod["Value"]] .. ' ' .. amount .. ' studs in the air.', 3);
				else
					notif('BoostJump', 'You need to be alive to boost.', 3);
				end;
				BoostJump:Toggle();
				return;
			end;
			BoostJump:Clean(function()
				if activeTween then
					activeTween:Cancel();
					activeTween = nil;
				end;
			end);
			BoostJump:Clean(task.spawn(function()
				repeat
					boost(true);
					task.wait(BoostJumpDelay["Value"] / 10);
				until false;
			end));
		end,
		["ExtraText"] = function(): string
			return BoostJumpRepeat["Value"];
		end
	});
	BoostJumpRepeat = BoostJump:CreateDropdown({
		["Name"] = 'Repeat',
		["List"] = {'Toggle', 'Keep'},
		["Default"] = 'Toggle',
		["Tooltip"] = 'Toggle: boost once. Keep: keep boosting while enabled.',
		["Function"] = restart
	});
	BoostJumpMethod = BoostJump:CreateDropdown({
		["Name"] = 'Boost',
		["List"] = {'Velocity', 'CFrame', 'Tween'},
		["Default"] = 'Velocity',
		["Tooltip"] = 'Mode to get boosted in the air.'
	});
	BoostJumpVelocity = BoostJump:CreateSlider({
		["Name"] = 'Velocity Boost',
		["Min"] = 1,
		["Max"] = 600,
		["Default"] = 600,
		["Tooltip"] = 'Amount of velocity to boost your character.'
	});
	BoostJumpCFrame = BoostJump:CreateSlider({
		["Name"] = 'CFrame Boost',
		["Min"] = 1,
		["Max"] = 1000,
		["Default"] = 1000,
		["Tooltip"] = 'Studs to teleport your character up.'
	});
	BoostJumpTween = BoostJump:CreateSlider({
		["Name"] = 'Tween Boost',
		["Min"] = 1,
		["Max"] = 1500,
		["Default"] = 1000,
		["Tooltip"] = 'Studs to tween your character up.'
	});
	BoostJumpDuration = BoostJump:CreateSlider({
		["Name"] = 'Tween Duration',
		["Min"] = 1,
		["Max"] = 10,
		["Default"] = 4,
		["Tooltip"] = 'Duration of the tween, in tenths of a second.'
	});
	BoostJumpDelay = BoostJump:CreateSlider({
		["Name"] = 'Keep Delay',
		["Min"] = 1,
		["Max"] = 15,
		["Default"] = 7,
		["Tooltip"] = 'Delay between boosts in Keep mode, in tenths of a second.'
	});
	BoostJumpReduce = BoostJump:CreateSlider({
		["Name"] = 'Reduce',
		["Min"] = 1,
		["Max"] = 400,
		["Default"] = 300,
		["Tooltip"] = 'Amount Safe takes off each boost in Keep mode.'
	});
	BoostJumpSafe = BoostJump:CreateToggle({
		["Name"] = 'Safe',
		["Default"] = true,
		["Tooltip"] = 'Reduces the boost power in Keep mode.'
	});
end);

velo.run(function()
	local ZoomUnlocker: table = {["Enabled"] = false};
	local ZoomUnlockerMode: table = {["Value"] = 'Infinite'};
	local ZoomUnlockerZoom: table = {["Value"] = 500};
	local zoomConnection: any, oldZoom: any = nil, nil;
	ZoomUnlocker = vape.Categories.Velocity:CreateModule({
		["Name"] ='ZoomUnlocker',
        ["HoverText"] = 'Unlocks the abillity to zoom more.',
		["Function"] = function(callback: boolean): void
			if callback then
				oldZoom = lplr["CameraMaxZoomDistance"];
				ZoomUnlocker = runService.Heartbeat:Connect(function()
					if ZoomUnlockerMode["Value"] == 'Infinite' then
						lplr["CameraMaxZoomDistance"] = 9e9;
					else
						lplr["CameraMaxZoomDistance"] = ZoomUnlockerZoom["Value"];
					end;
				end);
			else
				if ZoomUnlocker then ZoomUnlocker:Disconnect(); end;
				lplr["CameraMaxZoomDistance"] = oldZoom;
				oldZoom = nil;
			end;
		end,
        ["Default"] =false,
		["ExtraText"] = function()
            return ZoomUnlockerMode["Value"];
        end;
	});
	ZoomUnlockerMode = ZoomUnlocker:CreateDropdown({
		["Name"] ='Mode',
		["List"] = {
			'Infinite',
			'Custom'
		},
		["HoverText"] = 'Mode to unlock the zoom.',
		["Value"] = 'Infinite',
		["Function"] = function() end
	});
	ZoomUnlockerZoom = ZoomUnlocker:CreateSlider({
		["Name"] ='Zoom',
		["Min"] = 13,
		["Max"] = 1000,
		["HoverText"] = 'Amount to unlock the zoom.',
		["Function"] = function() end,
		["Default"] = 500
	});
end);

velo.run(function()
	local ScriptHub: table = {["Enabled"] = false};
	local Script: table = {["Value"] = "Dex"};
	ScriptHub = vape.Categories.Velocity:CreateModule({
		["Name"] = "ScriptHub",
		["HoverText"] = "Loads Scripts",
		["Function"] = function(callback: boolean): void
			if callback then
				if Script["Value"] == "Dex" then
					task.spawn(function()
						loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))();
					end);
				elseif Script["Value"] == "InfiniteYield" then
					task.spawn(function()
						loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))(); 
					end);
				end;
				ScriptHub:Toggle();
			end;
		end;
	});
	Script = ScriptHub:CreateDropdown({
		["Name"] ='Mode',
		["List"] = {
			'Dex',
			'InfiniteYield'
		},
		["Default"] ='Dex',
		["HoverText"] = 'Mode to execute script.',
		["Function"] = function() end;
	});	
end);

velo.run(function()
	local GameWeather: table = {["Enabled"] = false};
	local GameWeatherMode: table = {["Value"] = "Snow"};
	local SnowflakesSpread: table = {["Value"] = 35};
	local SnowflakesRate: table = {["Value"] = 28};
	local SnowflakesHigh: table = {["Value"] = 100};
	local emitters: {ParticleEmitter} = {};

	local snowTransparency: NumberSequence = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.16939899325371, 0),
		NumberSequenceKeypoint.new(0.23365999758244, 0.62841498851776, 0.37158501148224),
		NumberSequenceKeypoint.new(0.56209099292755, 0.38797798752785, 0.2771390080452),
		NumberSequenceKeypoint.new(0.90577298402786, 0.51912599802017, 0),
		NumberSequenceKeypoint.new(1, 1, 0)
	});
	local snowSize: NumberSequence = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0, 0),
		NumberSequenceKeypoint.new(0.039760299026966, 1.3114800453186, 0.32786899805069),
		NumberSequenceKeypoint.new(0.7554469704628, 0.98360699415207, 0.44038599729538),
		NumberSequenceKeypoint.new(1, 0, 0)
	});

	local getOrigin: () -> Vector3 = function(): Vector3
		if entitylib.isAlive and entitylib.character.RootPart then
			return entitylib.character.RootPart.Position;
		end;
		return workspace.CurrentCamera.CFrame.Position;
	end;

	local updateEmitters: () -> () = function(): ()
		for _, emitter: ParticleEmitter in emitters do
			emitter.Rate = SnowflakesRate["Value"];
			emitter.SpreadAngle = Vector2.new(SnowflakesSpread["Value"], SnowflakesSpread["Value"]);
		end;
	end;

	local createSnowEmitter: (parent: BasePart, rotSpeed: number, acceleration: Vector3) -> () = function(parent: BasePart, rotSpeed: number, acceleration: Vector3): ()
		local emitter: ParticleEmitter = Instance.new("ParticleEmitter");
		emitter.Texture = "rbxassetid://8158344433";
		emitter.RotSpeed = NumberRange.new(rotSpeed);
		emitter.Rotation = NumberRange.new(110);
		emitter.Acceleration = acceleration;
		emitter.Lifetime = NumberRange.new(8, 14);
		emitter.Speed = NumberRange.new(8, 18);
		emitter.EmissionDirection = Enum.NormalId.Bottom;
		emitter.Transparency = snowTransparency;
		emitter.Size = snowSize;
		emitter.Parent = parent;
		table.insert(emitters, emitter);
	end;

	local startSnow: () -> () = function(): ()
		local snowpart: Part = Instance.new("Part");
		snowpart.Name = "SnowParticle";
		snowpart.Size = Vector3.new(240, 0.5, 240);
		snowpart.Transparency = 1;
		snowpart.Anchored = true;
		snowpart.CanCollide = false;
		snowpart.CanQuery = false;
		snowpart.CanTouch = false;
		snowpart.CastShadow = false;
		snowpart.CFrame = CFrame.new(getOrigin() + Vector3.new(0, SnowflakesHigh["Value"], 0));
		createSnowEmitter(snowpart, 300, Vector3.zero);
		createSnowEmitter(snowpart, 100, Vector3.new(0, 0, 1));
		updateEmitters();
		snowpart.Parent = workspace;
		GameWeather:Clean(snowpart);
		GameWeather:Clean(function()
			table.clear(emitters);
		end);
		GameWeather:Clean(runService.Heartbeat:Connect(function()
			snowpart.CFrame = CFrame.new(getOrigin() + Vector3.new(0, SnowflakesHigh["Value"], 0));
		end));
	end;

	local startRain: () -> () = function(): ()
		local folder: Folder = Instance.new("Folder");
		folder.Name = "RainParticles";
		folder.Parent = workspace;
		GameWeather:Clean(folder);

		local sound: Sound = Instance.new("Sound");
		sound.SoundId = "rbxassetid://236148388";
		sound.Looped = true;
		sound.Volume = 0.05;
		sound.Parent = folder;
		sound:Play();

		local rayParams: RaycastParams = RaycastParams.new();
		rayParams.FilterType = Enum.RaycastFilterType.Exclude;

		local underRoof: (pos: Vector3) -> boolean = function(pos: Vector3): boolean
			local ignore: {Instance} = {folder, workspace.CurrentCamera};
			if lplr.Character then
				table.insert(ignore, lplr.Character);
			end;
			rayParams.FilterDescendantsInstances = ignore;
			return workspace:Raycast(pos, Vector3.new(0, 150, 0), rayParams) ~= nil;
		end;

		local drop: (origin: Vector3) -> () = function(origin: Vector3): ()
			local part: Part = Instance.new("Part");
			part.Size = Vector3.new(0.15, 2, 0.15);
			part.BrickColor = BrickColor.new("Steel blue");
			part.Material = Enum.Material.SmoothPlastic;
			part.Transparency = 0.25;
			part.Reflectance = 0.15;
			part.CanCollide = false;
			part.CanQuery = false;
			part.CastShadow = false;
			part.CFrame = CFrame.new(origin + Vector3.new(math.random(-100, 100), 150 + math.random(-50, 50), math.random(-100, 100)));
			local smoke: Smoke = Instance.new("Smoke");
			smoke.RiseVelocity = -25;
			smoke["Opacity"] = 0.25;
			smoke.Size = 25;
			smoke.Parent = part;
			part.Touched:Connect(function(hit: BasePart)
				if hit.Parent ~= folder then
					part:Destroy();
				end;
			end);
			part.Parent = folder;
			task.delay(3, part.Destroy, part);
		end;

		GameWeather:Clean(task.spawn(function()
			repeat
				local origin: Vector3 = getOrigin();
				local camPos: Vector3 = workspace.CurrentCamera.CFrame.Position;
				local covered: boolean = underRoof(origin);
				sound.Volume = covered and 0.02 or 0.05;
				if not covered then
					for _ = 1, 5 do
						drop(origin);
					end;
				end;
				if (camPos - origin).Magnitude > 100 and not underRoof(camPos) then
					for _ = 1, 5 do
						drop(camPos);
					end;
				end;
				task.wait(0.03);
			until not GameWeather["Enabled"];
		end));
	end;

	GameWeather = vape.Categories.Velocity:CreateModule({
		["Name"] = 'GameWeather',
		["Tooltip"] = 'Changes the weather.',
		["Function"] = function(callback: boolean): void
			if callback then
				if GameWeatherMode["Value"] == 'Rain' then
					startRain();
				else
					startSnow();
				end;
			end;
		end
	});
	GameWeatherMode = GameWeather:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Snow', 'Rain'},
		["Default"] = 'Snow',
		["Tooltip"] = 'Mode to change the weather.',
		["Function"] = function()
			if GameWeather["Enabled"] then
				GameWeather:Toggle();
				GameWeather:Toggle();
			end;
		end
	});
	SnowflakesSpread = GameWeather:CreateSlider({
		["Name"] = "Snow Spread",
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 35,
		["Function"] = updateEmitters
	});
	SnowflakesRate = GameWeather:CreateSlider({
		["Name"] = "Snow Rate",
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 28,
		["Function"] = updateEmitters
	});
	SnowflakesHigh = GameWeather:CreateSlider({
		["Name"] = "Snow High",
		["Min"] = 1,
		["Max"] = 200,
		["Default"] = 100
	});
end);

velo.run(function()
	local WaterMark: table = {["Enabled"] = false};
	local WaterMarkFont: table = {["Value"] = "SourceSansBold"};
	local WaterMarkColor: table = {["Hue"] = 1, ["Sat"] = 1, ["Value"] = 0.55};
	local WaterMarkPOS: table = {["Value"] = 36};
	local WaterMarkBGT: table = {["Value"] = 1};
	local WaterMarkTST: table = {["Value"] = 0};
	local WaterMarkZI: table = {["Value"] = 10};
	local textLabel: TextLabel? = nil;

	local updateLabel: () -> () = function(): ()
		if not textLabel then return; end;
		pcall(function()
			textLabel.Font = Enum.Font[WaterMarkFont["Value"]];
		end);
		textLabel.TextColor3 = Color3.fromHSV(WaterMarkColor["Hue"], WaterMarkColor["Sat"], WaterMarkColor["Value"]);
		textLabel.Position = UDim2.new(0, 0, 0, -WaterMarkPOS["Value"]);
		textLabel.BackgroundTransparency = WaterMarkBGT["Value"];
		textLabel.TextStrokeTransparency = WaterMarkTST["Value"];
		textLabel.ZIndex = WaterMarkZI["Value"];
	end;

	WaterMark = vape.Categories.Velocity:CreateModule({
		["Name"] = "TextMark",
		["Function"] = function(callback: boolean): void
			if callback then
				local screenGui: ScreenGui = Instance.new("ScreenGui");
				screenGui.Name = "TextMark";
				screenGui.ResetOnSpawn = false;
				screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;

				local label: TextLabel = Instance.new("TextLabel");
				label.Size = UDim2.new(1, 0, 0, 36);
				label.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
				label.TextScaled = true;
				label.Text = "Velocity [V1.0]";
				label.Parent = screenGui;

				local corner: UICorner = Instance.new("UICorner");
				corner.CornerRadius = UDim.new(0, 10);
				corner.Parent = label;

				textLabel = label;
				updateLabel();
				screenGui.Parent = lplr:FindFirstChildOfClass("PlayerGui") or lplr:WaitForChild("PlayerGui");
				WaterMark:Clean(screenGui);
				WaterMark:Clean(function()
					textLabel = nil;
				end);
			end;
		end
	});
	WaterMarkFont = WaterMark:CreateDropdown({
		["Name"] = "Font",
		["List"] = getItems("Font"),
		["Default"] = "SourceSansBold",
		["Tooltip"] = "Font of the text.",
		["Function"] = updateLabel
	});
	WaterMarkColor = WaterMark:CreateColorSlider({
		["Name"] = "Color",
		["DefaultHue"] = 1,
		["DefaultSat"] = 1,
		["DefaultValue"] = 0.55,
		["Function"] = updateLabel
	});
	WaterMarkPOS = WaterMark:CreateSlider({
		["Name"] = "Position",
		["Min"] = 1,
		["Max"] = 45,
		["Default"] = 36,
		["Function"] = updateLabel
	});
	WaterMarkBGT = WaterMark:CreateSlider({
		["Name"] = "Background Transparency",
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10,
		["Default"] = 1,
		["Function"] = updateLabel
	});
	WaterMarkTST = WaterMark:CreateSlider({
		["Name"] = "Stroke Transparency",
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10,
		["Default"] = 0,
		["Function"] = updateLabel
	});
	WaterMarkZI = WaterMark:CreateSlider({
		["Name"] = "ZIndex",
		["Min"] = 7,
		["Max"] = 15,
		["Default"] = 10,
		["Function"] = updateLabel
	});
end);

velo.run(function()
	local Luminescents: table = {["Enabled"] = false};
	local collectionService: CollectionService = cloneref(game:GetService('CollectionService'));
	local terrain: Terrain = workspace.Terrain;
	local lumColor: Color3 = Color3.fromHSV(0.44, 1, 1);
	local waterSize: Vector3 = Vector3.new(5000, 4, 5000);
	local skybox: {[string]: string} = {
		["SkyboxBk"] = 'rbxassetid://158422743',
		["SkyboxDn"] = 'rbxassetid://158422584',
		["SkyboxFt"] = 'rbxassetid://158423013',
		["SkyboxLf"] = 'rbxassetid://158423239',
		["SkyboxRt"] = 'rbxassetid://158422849',
		["SkyboxUp"] = 'rbxassetid://158422277'
	};
	local lightingMap: {{string}} = {
		{'ClockTime', 'ClockTime'},
		{'Brightness', 'Brightness'},
		{'ExposureCompensation', 'Exposure'},
		{'ShadowSoftness', 'ShadowSoftness'},
		{'EnvironmentDiffuseScale', 'EnvDiffuse'},
		{'EnvironmentSpecularScale', 'EnvSpecular'},
		{'GlobalShadows', 'GlobalShadows'},
		{'Ambient', 'Ambient'},
		{'OutdoorAmbient', 'OutdoorAmbient'},
		{'ColorShift_Top', 'ShiftTop'},
		{'ColorShift_Bottom', 'ShiftBottom'}
	};
	local fogKeys: {[string]: string} = {
		["FogStart"] = 'FogStart',
		["FogEnd"] = 'FogEnd',
		["FogColor"] = 'FogColor'
	};
	local terrainProps: {string} = {'WaterColor', 'WaterReflectance', 'WaterTransparency', 'WaterWaveSize', 'WaterWaveSpeed'};
	local singletons: {[string]: boolean} = {
		["Sky"] = true,
		["Atmosphere"] = true
	};
	local defs: {table} = {
		{["Type"] = 'Dropdown', ["Key"] = 'Preset', ["Name"] = 'Preset', ["List"] = {'Luminescent', 'Shaders', 'Custom'}, ["Default"] = 'Luminescent', ["Tooltip"] = 'Picking a preset fills in every setting below. Tweak anything afterwards.'},
		{["Type"] = 'Toggle', ["Key"] = 'Lock', ["Name"] = 'Lock Lighting', ["Default"] = true, ["Tooltip"] = 'Puts your lighting back if the game changes it.'},
		{["Type"] = 'Slider', ["Key"] = 'ClockTime', ["Name"] = 'Clock Time', ["Min"] = 0, ["Max"] = 24, ["Decimal"] = 10, ["Default"] = 8.7},
		{["Type"] = 'Slider', ["Key"] = 'Brightness', ["Name"] = 'Brightness', ["Min"] = 0, ["Max"] = 10, ["Decimal"] = 10, ["Default"] = 2},
		{["Type"] = 'Slider', ["Key"] = 'Exposure', ["Name"] = 'Exposure', ["Min"] = -3, ["Max"] = 3, ["Decimal"] = 100, ["Default"] = 0.3},
		{["Type"] = 'Slider', ["Key"] = 'ShadowSoftness', ["Name"] = 'Shadow Softness', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0},
		{["Type"] = 'Slider', ["Key"] = 'EnvDiffuse', ["Name"] = 'Diffuse Scale', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 1},
		{["Type"] = 'Slider', ["Key"] = 'EnvSpecular', ["Name"] = 'Specular Scale', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 1},
		{["Type"] = 'Toggle', ["Key"] = 'GlobalShadows', ["Name"] = 'Global Shadows', ["Default"] = true},
		{["Type"] = 'Dropdown', ["Key"] = 'Technology', ["Name"] = 'Technology', ["List"] = {'Game Default', 'Voxel', 'ShadowMap', 'Future', 'Compatibility'}, ["Default"] = 'Game Default', ["Tooltip"] = 'Lighting engine. Some executors cannot change this.'},
		{["Type"] = 'Color', ["Key"] = 'Ambient', ["Name"] = 'Ambient', ["Default"] = Color3.fromRGB(59, 33, 27)},
		{["Type"] = 'Color', ["Key"] = 'OutdoorAmbient', ["Name"] = 'Outdoor Ambient', ["Default"] = lumColor},
		{["Type"] = 'Color', ["Key"] = 'ShiftTop', ["Name"] = 'Color Shift Top', ["Default"] = lumColor},
		{["Type"] = 'Color', ["Key"] = 'ShiftBottom', ["Name"] = 'Color Shift Bottom', ["Default"] = lumColor},
		{["Type"] = 'Toggle', ["Key"] = 'Fog', ["Name"] = 'Fog', ["Default"] = true, ["Tooltip"] = 'The game ignores fog while Atmosphere is on.'},
		{["Type"] = 'Slider', ["Key"] = 'FogStart', ["Name"] = 'Fog Start', ["Group"] = 'Fog', ["Min"] = 0, ["Max"] = 1000, ["Default"] = 0},
		{["Type"] = 'Slider', ["Key"] = 'FogEnd', ["Name"] = 'Fog End', ["Group"] = 'Fog', ["Min"] = 0, ["Max"] = 10000, ["Default"] = 1000},
		{["Type"] = 'Color', ["Key"] = 'FogColor', ["Name"] = 'Fog Color', ["Group"] = 'Fog', ["Default"] = lumColor},
		{["Type"] = 'Toggle', ["Key"] = 'Atmosphere', ["Name"] = 'Atmosphere', ["Default"] = false},
		{["Type"] = 'Slider', ["Key"] = 'AtmDensity', ["Name"] = 'Atmosphere Density', ["Group"] = 'Atmosphere', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.35},
		{["Type"] = 'Slider', ["Key"] = 'AtmOffset', ["Name"] = 'Atmosphere Offset', ["Group"] = 'Atmosphere', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.3},
		{["Type"] = 'Slider', ["Key"] = 'AtmGlare', ["Name"] = 'Atmosphere Glare', ["Group"] = 'Atmosphere', ["Min"] = 0, ["Max"] = 10, ["Decimal"] = 10, ["Default"] = 0},
		{["Type"] = 'Slider', ["Key"] = 'AtmHaze', ["Name"] = 'Atmosphere Haze', ["Group"] = 'Atmosphere', ["Min"] = 0, ["Max"] = 10, ["Decimal"] = 10, ["Default"] = 0},
		{["Type"] = 'Color', ["Key"] = 'AtmColor', ["Name"] = 'Atmosphere Color', ["Group"] = 'Atmosphere', ["Default"] = Color3.fromRGB(185, 185, 185)},
		{["Type"] = 'Color', ["Key"] = 'AtmDecay', ["Name"] = 'Atmosphere Decay', ["Group"] = 'Atmosphere', ["Default"] = Color3.fromRGB(95, 102, 115)},
		{["Type"] = 'Toggle', ["Key"] = 'Sky', ["Name"] = 'Sky', ["Default"] = false},
		{["Type"] = 'Toggle', ["Key"] = 'Skybox', ["Name"] = 'Custom Skybox', ["Group"] = 'Sky', ["Default"] = true},
		{["Type"] = 'Toggle', ["Key"] = 'HideSunMoon', ["Name"] = 'Hide Sun & Moon', ["Group"] = 'Sky', ["Default"] = true},
		{["Type"] = 'Slider', ["Key"] = 'StarCount', ["Name"] = 'Star Count', ["Group"] = 'Sky', ["Min"] = 0, ["Max"] = 5000, ["Default"] = 2800},
		{["Type"] = 'Slider', ["Key"] = 'SunSize', ["Name"] = 'Sun Size', ["Group"] = 'Sky', ["Min"] = 0, ["Max"] = 60, ["Default"] = 2},
		{["Type"] = 'Slider', ["Key"] = 'MoonSize', ["Name"] = 'Moon Size', ["Group"] = 'Sky', ["Min"] = 0, ["Max"] = 60, ["Default"] = 0},
		{["Type"] = 'Toggle', ["Key"] = 'Bloom', ["Name"] = 'Bloom', ["Default"] = false},
		{["Type"] = 'Slider', ["Key"] = 'BloomIntensity', ["Name"] = 'Bloom Intensity', ["Group"] = 'Bloom', ["Min"] = 0, ["Max"] = 3, ["Decimal"] = 100, ["Default"] = 0.4},
		{["Type"] = 'Slider', ["Key"] = 'BloomSize', ["Name"] = 'Bloom Size', ["Group"] = 'Bloom', ["Min"] = 0, ["Max"] = 56, ["Default"] = 22},
		{["Type"] = 'Slider', ["Key"] = 'BloomThreshold', ["Name"] = 'Bloom Threshold', ["Group"] = 'Bloom', ["Min"] = 0, ["Max"] = 4, ["Decimal"] = 10, ["Default"] = 2.2},
		{["Type"] = 'Toggle', ["Key"] = 'Blur', ["Name"] = 'Blur', ["Default"] = true},
		{["Type"] = 'Slider', ["Key"] = 'BlurSize', ["Name"] = 'Blur Size', ["Group"] = 'Blur', ["Min"] = 0, ["Max"] = 56, ["Default"] = 5},
		{["Type"] = 'Toggle', ["Key"] = 'ColorCorrection', ["Name"] = 'Color Correction', ["Default"] = true},
		{["Type"] = 'Slider', ["Key"] = 'CCBrightness', ["Name"] = 'CC Brightness', ["Group"] = 'ColorCorrection', ["Min"] = -1, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0},
		{["Type"] = 'Slider', ["Key"] = 'CCContrast', ["Name"] = 'CC Contrast', ["Group"] = 'ColorCorrection', ["Min"] = -1, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0},
		{["Type"] = 'Slider', ["Key"] = 'CCSaturation', ["Name"] = 'CC Saturation', ["Group"] = 'ColorCorrection', ["Min"] = -1, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = -0.2},
		{["Type"] = 'Color', ["Key"] = 'CCTint', ["Name"] = 'CC Tint', ["Group"] = 'ColorCorrection', ["Default"] = Color3.fromRGB(255, 224, 219)},
		{["Type"] = 'Toggle', ["Key"] = 'SunRays', ["Name"] = 'Sun Rays', ["Default"] = false},
		{["Type"] = 'Slider', ["Key"] = 'RaysIntensity', ["Name"] = 'Rays Intensity', ["Group"] = 'SunRays', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.25},
		{["Type"] = 'Slider', ["Key"] = 'RaysSpread', ["Name"] = 'Rays Spread', ["Group"] = 'SunRays', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 1},
		{["Type"] = 'Toggle', ["Key"] = 'DepthOfField', ["Name"] = 'Depth Of Field', ["Default"] = false},
		{["Type"] = 'Slider', ["Key"] = 'DofFar', ["Name"] = 'Far Blur', ["Group"] = 'DepthOfField', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.1},
		{["Type"] = 'Slider', ["Key"] = 'DofNear', ["Name"] = 'Near Blur', ["Group"] = 'DepthOfField', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.75},
		{["Type"] = 'Slider', ["Key"] = 'DofFocus', ["Name"] = 'Focus Distance', ["Group"] = 'DepthOfField', ["Min"] = 0, ["Max"] = 200, ["Default"] = 50},
		{["Type"] = 'Slider', ["Key"] = 'DofRadius', ["Name"] = 'In Focus Radius', ["Group"] = 'DepthOfField', ["Min"] = 0, ["Max"] = 100, ["Default"] = 30},
		{["Type"] = 'Toggle', ["Key"] = 'Clouds', ["Name"] = 'Clouds', ["Default"] = false},
		{["Type"] = 'Slider', ["Key"] = 'CloudCover', ["Name"] = 'Cloud Cover', ["Group"] = 'Clouds', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.65},
		{["Type"] = 'Slider', ["Key"] = 'CloudDensity', ["Name"] = 'Cloud Density', ["Group"] = 'Clouds', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.5},
		{["Type"] = 'Color', ["Key"] = 'CloudColor', ["Name"] = 'Cloud Color', ["Group"] = 'Clouds', ["Default"] = Color3.fromRGB(230, 230, 230)},
		{["Type"] = 'Toggle', ["Key"] = 'Weather', ["Name"] = 'Dynamic Weather', ["Group"] = 'Clouds', ["Default"] = true, ["Tooltip"] = 'Slowly shifts the cloud cover around your setting.'},
		{["Type"] = 'Toggle', ["Key"] = 'Water', ["Name"] = 'Void Water', ["Default"] = false, ["Tooltip"] = 'Fills the void under block maps (BedWars style) with water.'},
		{["Type"] = 'Slider', ["Key"] = 'WaterOffset', ["Name"] = 'Water Depth', ["Group"] = 'Water', ["Min"] = 0, ["Max"] = 50, ["Default"] = 8, ["Tooltip"] = 'How far below the lowest block the water sits.'},
		{["Type"] = 'Color', ["Key"] = 'WaterColor', ["Name"] = 'Water Color', ["Group"] = 'Water', ["Default"] = Color3.fromRGB(0, 50, 70)},
		{["Type"] = 'Slider', ["Key"] = 'WaterReflectance', ["Name"] = 'Water Reflectance', ["Group"] = 'Water', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.7},
		{["Type"] = 'Slider', ["Key"] = 'WaterTransparency', ["Name"] = 'Water Transparency', ["Group"] = 'Water', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.25},
		{["Type"] = 'Slider', ["Key"] = 'WaveSize', ["Name"] = 'Wave Size', ["Group"] = 'Water', ["Min"] = 0, ["Max"] = 1, ["Decimal"] = 100, ["Default"] = 0.13},
		{["Type"] = 'Slider', ["Key"] = 'WaveSpeed', ["Name"] = 'Wave Speed', ["Group"] = 'Water', ["Min"] = 0, ["Max"] = 100, ["Default"] = 8},
		{["Type"] = 'Toggle', ["Key"] = 'NoSwim', ["Name"] = 'No Swimming', ["Group"] = 'Water', ["Default"] = true, ["Tooltip"] = 'Fall through the water instead of swimming in it.'},
		{["Type"] = 'Toggle', ["Key"] = 'HideMapClouds', ["Name"] = 'Hide Map Clouds', ["Default"] = false, ["Tooltip"] = "Hides the map's own cloud parts (workspace.Clouds)."}
	};
	local presets: {[string]: {[string]: any}} = {
		["Luminescent"] = {
			["ClockTime"] = 8.7, ["Brightness"] = 2, ["Exposure"] = 0.3, ["ShadowSoftness"] = 0, ["EnvDiffuse"] = 1, ["EnvSpecular"] = 1,
			["GlobalShadows"] = true, ["Technology"] = 'Game Default', ["Ambient"] = Color3.fromRGB(59, 33, 27),
			["OutdoorAmbient"] = lumColor, ["ShiftTop"] = lumColor, ["ShiftBottom"] = lumColor,
			["Fog"] = true, ["FogStart"] = 0, ["FogEnd"] = 1000, ["FogColor"] = lumColor,
			["Atmosphere"] = false, ["Sky"] = false, ["Bloom"] = false,
			["Blur"] = true, ["BlurSize"] = 5,
			["ColorCorrection"] = true, ["CCBrightness"] = 0, ["CCContrast"] = 0, ["CCSaturation"] = -0.2, ["CCTint"] = Color3.fromRGB(255, 224, 219),
			["SunRays"] = false, ["DepthOfField"] = false, ["Clouds"] = false, ["Water"] = false, ["HideMapClouds"] = false
		},
		["Shaders"] = {
			["ClockTime"] = 17.6, ["Brightness"] = 2.5, ["Exposure"] = 0, ["ShadowSoftness"] = 0.15, ["EnvDiffuse"] = 0.9, ["EnvSpecular"] = 0.9,
			["GlobalShadows"] = true, ["Technology"] = 'ShadowMap', ["Ambient"] = Color3.fromRGB(55, 55, 55),
			["OutdoorAmbient"] = Color3.fromRGB(55, 55, 55), ["ShiftTop"] = Color3.fromRGB(140, 120, 210), ["ShiftBottom"] = Color3.fromRGB(150, 100, 170),
			["Fog"] = false,
			["Atmosphere"] = true, ["AtmDensity"] = 0.35, ["AtmOffset"] = 0.3, ["AtmGlare"] = 0, ["AtmHaze"] = 0,
			["AtmColor"] = Color3.fromRGB(185, 185, 185), ["AtmDecay"] = Color3.fromRGB(95, 102, 115),
			["Sky"] = true, ["Skybox"] = true, ["HideSunMoon"] = true, ["StarCount"] = 2800, ["SunSize"] = 2, ["MoonSize"] = 0,
			["Bloom"] = true, ["BloomIntensity"] = 0.4, ["BloomSize"] = 22, ["BloomThreshold"] = 2.2,
			["Blur"] = false, ["ColorCorrection"] = false, ["SunRays"] = false, ["DepthOfField"] = false,
			["Clouds"] = true, ["CloudCover"] = 0.65, ["CloudDensity"] = 1, ["CloudColor"] = Color3.fromRGB(230, 230, 230), ["Weather"] = true,
			["Water"] = true, ["WaterOffset"] = 8, ["WaterColor"] = Color3.fromRGB(0, 50, 70), ["WaterReflectance"] = 0.7,
			["WaterTransparency"] = 0.25, ["WaveSize"] = 0.13, ["WaveSpeed"] = 8, ["NoSwim"] = true,
			["HideMapClouds"] = true
		}
	};
	local options: {[string]: table} = {};
	local defsByKey: {[string]: table} = {};
	local groups: {[string]: {table}} = {};
	local lightingKeys: {[string]: string} = {};
	local savedLighting: {[string]: any} = {};
	local savedTerrain: {[string]: any} = {};
	local created: {[string]: Instance} = {};
	local moved: {Instance} = {};
	local disabledClouds: {Clouds} = {};
	local hiddenParts: {[BasePart]: number} = {};
	local waterCFrame: CFrame? = nil;
	local waterBase: number? = nil;
	local swimDisabled: Humanoid? = nil;
	local weatherThread: thread? = nil;
	local weatherTween: Tween? = nil;
	local queued: boolean = false;

	for _, pair: {string} in lightingMap do
		lightingKeys[pair[1]] = pair[2];
	end;

	local on: (key: string) -> boolean = function(key: string): boolean
		local option: table? = options[key];
		return option ~= nil and option["Enabled"] == true;
	end;

	local get: (key: string) -> any = function(key: string): any
		local option: table = options[key];
		local kind: string = defsByKey[key].Type;
		if kind == 'Color' then
			return Color3.fromHSV(option["Hue"], option["Sat"], option["Value"]);
		elseif kind == 'Toggle' then
			return option["Enabled"];
		end;
		return option["Value"];
	end;

	local setProp: (object: any, prop: string, value: any) -> () = function(object: any, prop: string, value: any): ()
		if value ~= nil and object[prop] ~= value then
			object[prop] = value;
		end;
	end;

	local setProps: (object: any, props: {[string]: any}) -> () = function(object: any, props: {[string]: any}): ()
		for prop: string, value: any in props do
			setProp(object, prop, value);
		end;
	end;

	local setTechnology: (value: any) -> () = function(value: any): ()
		if value == nil or lightingService.Technology == value then
			return;
		end;
		local ok: boolean = pcall(function(): ()
			lightingService.Technology = value;
		end);
		if not ok and sethiddenproperty then
			pcall(sethiddenproperty, lightingService, 'Technology', value);
		end;
	end;

	local hideOthers: (className: string) -> () = function(className: string): ()
		for _, child: Instance in lightingService:GetChildren() do
			if child:IsA(className) then
				table.insert(moved, child);
				child.Parent = nil;
			end;
		end;
	end;

	local releaseOthers: (className: string) -> () = function(className: string): ()
		for i: number = #moved, 1, -1 do
			local child: Instance = moved[i];
			if child:IsA(className) then
				table.remove(moved, i);
				pcall(function(): ()
					child.Parent = lightingService;
				end);
			end;
		end;
	end;

	local gameSky: () -> Sky? = function(): Sky?
		for _, child: Instance in moved do
			if child:IsA('Sky') then
				return child;
			end;
		end;
		return nil;
	end;

	local syncEffect: (key: string, className: string, configure: (any) -> ()) -> () = function(key: string, className: string, configure: (any) -> ()): ()
		local object: any = created[key];
		if not on(key) then
			if object then
				object:Destroy();
				created[key] = nil;
				if singletons[className] then
					releaseOthers(className);
				end;
			end;
			return;
		end;
		if not object then
			object = Instance.new(className);
			created[key] = object;
			if singletons[className] then
				hideOthers(className);
			end;
			configure(object);
			object.Parent = lightingService;
			return;
		end;
		configure(object);
	end;

	local stopWeather: () -> () = function(): ()
		if weatherThread then
			task.cancel(weatherThread);
			weatherThread = nil;
		end;
		if weatherTween then
			weatherTween:Cancel();
			weatherTween = nil;
		end;
	end;

	local startWeather: (clouds: Clouds) -> () = function(clouds: Clouds): ()
		if weatherThread then
			return;
		end;
		weatherThread = task.spawn(function(): ()
			repeat
				task.wait(math.random(15, 20));
				local base: number = get('CloudCover');
				local roll: number = math.random(1, 100);
				local target: number = roll <= 40 and base * 0.7 or roll <= 70 and base or math.min(base + 0.25, 1);
				if weatherTween then
					weatherTween:Cancel();
				end;
				weatherTween = tweenService:Create(clouds, TweenInfo.new(10), {["Cover"] = target});
				weatherTween:Play();
			until false;
		end);
	end;

	local syncClouds: () -> () = function(): ()
		local clouds: any = created.Clouds;
		if not on('Clouds') then
			stopWeather();
			if clouds then
				clouds:Destroy();
				created.Clouds = nil;
			end;
			for _, other: Clouds in disabledClouds do
				pcall(function(): ()
					other["Enabled"] = true;
				end);
			end;
			table.clear(disabledClouds);
			return;
		end;
		if not clouds then
			for _, other: Instance in terrain:GetChildren() do
				if other:IsA('Clouds') and other["Enabled"] then
					other["Enabled"] = false;
					table.insert(disabledClouds, other);
				end;
			end;
			clouds = Instance.new('Clouds');
			clouds.Cover = get('CloudCover');
			created.Clouds = clouds;
			clouds.Parent = terrain;
		end;
		setProps(clouds, {
			["Density"] = get('CloudDensity'),
			["Color"] = get('CloudColor')
		});
		if on('Weather') then
			startWeather(clouds);
		else
			stopWeather();
			setProp(clouds, 'Cover', get('CloudCover'));
		end;
	end;

	local clearWater: () -> () = function(): ()
		if waterCFrame then
			terrain:FillBlock(waterCFrame, waterSize, Enum.Material.Air);
			waterCFrame = nil;
		end;
	end;

	local getLowestBlock: () -> number? = function(): number?
		local lowest: number? = nil;
		for _, block: Instance in collectionService:GetTagged('block') do
			if block:IsA('BasePart') then
				local bottom: number = block.Position.Y - block.Size.Y / 2;
				if not lowest or bottom < lowest then
					lowest = bottom;
				end;
			end;
		end;
		return lowest;
	end;

	local syncWater: () -> () = function(): ()
		if not on('Water') then
			clearWater();
			waterBase = nil;
			for prop: string, value: any in savedTerrain do
				setProp(terrain, prop, value);
			end;
			return;
		end;
		waterBase = waterBase or getLowestBlock();
		if waterBase then
			local level: number = waterBase - get('WaterOffset');
			if not waterCFrame or math.abs(waterCFrame.Position.Y - level) > 0.1 then
				clearWater();
				local center: Vector3 = entitylib.isAlive and entitylib.character.RootPart.Position or workspace.CurrentCamera.CFrame.Position;
				waterCFrame = CFrame.new(center.X, level, center.Z);
				terrain:FillBlock(waterCFrame, waterSize, Enum.Material.Water);
			end;
		end;
		setProps(terrain, {
			["WaterColor"] = get('WaterColor'),
			["WaterReflectance"] = get('WaterReflectance'),
			["WaterTransparency"] = get('WaterTransparency'),
			["WaterWaveSize"] = get('WaveSize'),
			["WaterWaveSpeed"] = get('WaveSpeed')
		});
	end;

	local syncSwim: () -> () = function(): ()
		local humanoid: Humanoid? = entitylib.isAlive and entitylib.character.Humanoid or nil;
		if on('Water') and on('NoSwim') and humanoid then
			if swimDisabled ~= humanoid then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false);
				swimDisabled = humanoid;
			end;
		elseif swimDisabled and not (on('Water') and on('NoSwim')) then
			swimDisabled:SetStateEnabled(Enum.HumanoidStateType.Swimming, true);
			swimDisabled = nil;
		end;
	end;

	local syncMapClouds: () -> () = function(): ()
		if on('HideMapClouds') then
			local folder: Instance? = workspace:FindFirstChild('Clouds');
			if folder then
				for _, part: Instance in folder:GetDescendants() do
					if part:IsA('BasePart') and hiddenParts[part] == nil then
						hiddenParts[part] = part.Transparency;
						part.Transparency = 1;
					end;
				end;
			end;
			return;
		end;
		for part: BasePart, transparency: number in hiddenParts do
			part.Transparency = transparency;
		end;
		table.clear(hiddenParts);
	end;

	local apply: () -> () = function(): ()
		if not Luminescents["Enabled"] then
			return;
		end;
		for _, pair: {string} in lightingMap do
			setProp(lightingService, pair[1], get(pair[2]));
		end;
		for prop: string, key: string in fogKeys do
			setProp(lightingService, prop, on('Fog') and get(key) or savedLighting[prop]);
		end;
		local technology: string = get('Technology');
		setTechnology(technology == 'Game Default' and savedLighting.Technology or Enum.Technology[technology]);
		syncEffect('Atmosphere', 'Atmosphere', function(object: any): ()
			setProps(object, {
				["Density"] = get('AtmDensity'),
				["Offset"] = get('AtmOffset'),
				["Glare"] = get('AtmGlare'),
				["Haze"] = get('AtmHaze'),
				["Color"] = get('AtmColor'),
				["Decay"] = get('AtmDecay')
			});
		end);
		syncEffect('Sky', 'Sky', function(object: any): ()
			local original: Sky? = gameSky();
			for prop: string, id: string in skybox do
				setProp(object, prop, on('Skybox') and id or original and original[prop] or '');
			end;
			setProps(object, {
				["StarCount"] = get('StarCount'),
				["SunAngularSize"] = get('SunSize'),
				["MoonAngularSize"] = get('MoonSize'),
				["SunTextureId"] = on('HideSunMoon') and '' or original and original.SunTextureId or 'rbxasset://sky/sun.jpg',
				["MoonTextureId"] = on('HideSunMoon') and '' or original and original.MoonTextureId or 'rbxasset://sky/moon.jpg'
			});
		end);
		syncEffect('Bloom', 'BloomEffect', function(object: any): ()
			setProps(object, {
				["Intensity"] = get('BloomIntensity'),
				["Size"] = get('BloomSize'),
				["Threshold"] = get('BloomThreshold')
			});
		end);
		syncEffect('Blur', 'BlurEffect', function(object: any): ()
			setProp(object, 'Size', get('BlurSize'));
		end);
		syncEffect('ColorCorrection', 'ColorCorrectionEffect', function(object: any): ()
			setProps(object, {
				["Brightness"] = get('CCBrightness'),
				["Contrast"] = get('CCContrast'),
				["Saturation"] = get('CCSaturation'),
				["TintColor"] = get('CCTint')
			});
		end);
		syncEffect('SunRays', 'SunRaysEffect', function(object: any): ()
			setProps(object, {
				["Intensity"] = get('RaysIntensity'),
				["Spread"] = get('RaysSpread')
			});
		end);
		syncEffect('DepthOfField', 'DepthOfFieldEffect', function(object: any): ()
			setProps(object, {
				["FarIntensity"] = get('DofFar'),
				["NearIntensity"] = get('DofNear'),
				["FocusDistance"] = get('DofFocus'),
				["InFocusRadius"] = get('DofRadius')
			});
		end);
		syncClouds();
		syncWater();
		syncSwim();
		syncMapClouds();
	end;

	local queueApply: () -> () = function(): ()
		if queued then
			return;
		end;
		queued = true;
		task.defer(function(): ()
			queued = false;
			apply();
		end);
	end;

	local cleanup: () -> () = function(): ()
		stopWeather();
		for _, object: Instance in created do
			object:Destroy();
		end;
		table.clear(created);
		for _, child: Instance in moved do
			pcall(function(): ()
				child.Parent = lightingService;
			end);
		end;
		table.clear(moved);
		for _, other: Clouds in disabledClouds do
			pcall(function(): ()
				other["Enabled"] = true;
			end);
		end;
		table.clear(disabledClouds);
		clearWater();
		waterBase = nil;
		for prop: string, value: any in savedTerrain do
			setProp(terrain, prop, value);
		end;
		if swimDisabled then
			swimDisabled:SetStateEnabled(Enum.HumanoidStateType.Swimming, true);
			swimDisabled = nil;
		end;
		for part: BasePart, transparency: number in hiddenParts do
			part.Transparency = transparency;
		end;
		table.clear(hiddenParts);
		for prop: string, value: any in savedLighting do
			if prop ~= 'Technology' then
				setProp(lightingService, prop, value);
			end;
		end;
		setTechnology(savedLighting.Technology);
		table.clear(savedLighting);
		table.clear(savedTerrain);
	end;

	local applyPreset: (name: string) -> () = function(name: string): ()
		local preset: {[string]: any}? = presets[name];
		if not preset then
			return;
		end;
		for key: string, value: any in preset do
			local option: table? = options[key];
			local kind: string = defsByKey[key].Type;
			if option then
				if kind == 'Slider' or kind == 'Dropdown' then
					option:SetValue(value);
				elseif kind == 'Toggle' then
					if option["Enabled"] ~= value then
						option:Toggle();
					end;
				elseif kind == 'Color' then
					local h: number, s: number, v: number = value:ToHSV();
					option:SetValue(h, s, v);
				end;
			end;
		end;
	end;

	Luminescents = vape.Legit:CreateModule({
		["Name"] = 'Luminescents',
		["Tooltip"] = 'Fully customizable lighting, sky, clouds, water and post effects.',
		["Function"] = function(callback: boolean): void
			if not callback then
				return;
			end;
			for _, pair: {string} in lightingMap do
				savedLighting[pair[1]] = lightingService[pair[1]];
			end;
			for prop: string in fogKeys do
				savedLighting[prop] = lightingService[prop];
			end;
			pcall(function(): ()
				savedLighting.Technology = lightingService.Technology;
			end);
			for _, prop: string in terrainProps do
				savedTerrain[prop] = terrain[prop];
			end;
			Luminescents:Clean(lightingService.Changed:Connect(function(prop: string)
				if not Luminescents["Enabled"] or not on('Lock') then
					return;
				end;
				local key: string? = lightingKeys[prop] or (on('Fog') and fogKeys[prop] or nil);
				if key then
					setProp(lightingService, prop, get(key));
				end;
			end));
			Luminescents:Clean(entitylib.Events.LocalAdded:Connect(queueApply));
			Luminescents:Clean(cleanup);
			apply();
		end
	});

	for _, def: table in defs do
		defsByKey[def.Key] = def;
		if def.Group then
			groups[def.Group] = groups[def.Group] or {};
		end;
	end;

	for _, def: table in defs do
		local props: table = {
			["Name"] = def.Name,
			["Tooltip"] = def.Tooltip,
			["Function"] = queueApply
		};
		if def.Group then
			props.Darker = true;
			props.Visible = defsByKey[def.Group].Default;
		end;
		if def.Type == 'Slider' then
			props.Min = def.Min;
			props.Max = def.Max;
			props.Decimal = def.Decimal;
			props.Default = def.Default;
		elseif def.Type == 'Toggle' then
			props.Default = def.Default;
			if groups[def.Key] then
				props.Function = function(enabled: boolean): ()
					for _, member: table in groups[def.Key] do
						member.Object.Visible = enabled;
					end;
					queueApply();
				end;
			end;
		elseif def.Type == 'Dropdown' then
			props.List = def.List;
			props.Default = def.Default;
			if def.Key == 'Preset' then
				props.Function = function(value: string, isClick: boolean?): ()
					if isClick then
						applyPreset(value);
					end;
				end;
			end;
		elseif def.Type == 'Color' then
			local h: number, s: number, v: number = def.Default:ToHSV();
			props.DefaultHue = h;
			props.DefaultSat = s;
			props.DefaultValue = v;
		end;
		local option: table = Luminescents['Create' .. (def.Type == 'Color' and 'ColorSlider' or def.Type)](Luminescents, props);
		options[def.Key] = option;
		if def.Group then
			table.insert(groups[def.Group], option);
		end;
	end;
end);

velo.run(function()
	local AnimationChanger: table = {["Enabled"] = false};
	local AnimFreeze: table = {["Enabled"] = false};
	local animList: {[string]: {[string]: number}} = {
		["Run"] = {
			["Cartoony"] = 10921082452, ["Levitation"] = 10921135644, ["Robot"] = 10921250460, ["Stylish"] = 10921276116,
			["Superhero"] = 10921291831, ["Zombie"] = 616163682, ["Ninja"] = 10921157929, ["Knight"] = 10921121197,
			["Mage"] = 10921148209, ["Pirate"] = 750783738, ["Elder"] = 10921104374, ["Toy"] = 10921306285,
			["Bubbly"] = 10921057244, ["Astronaut"] = 10921039308, ["Vampire"] = 10921320299, ["Werewolf"] = 10921336997,
			["Rthro"] = 10921261968, ["Oldschool"] = 10921240218, ["Toilet"] = 4417979645, ["Rthro Heavy Run"] = 3236836670,
			["Tryhard"] = 10921157929, ["Goofy"] = 4417979645, ["Tamar"] = 10921306285
		},
		["Walk"] = {
			["Cartoony"] = 10921082452, ["Levitation"] = 10921140719, ["Robot"] = 10921255446, ["Stylish"] = 10921283326,
			["Superhero"] = 10921298616, ["Zombie"] = 10921355261, ["Ninja"] = 10921162768, ["Knight"] = 10921127095,
			["Mage"] = 10921152678, ["Pirate"] = 750785693, ["Elder"] = 10921111375, ["Toy"] = 10921312010,
			["Bubbly"] = 10980888364, ["Astronaut"] = 10921046031, ["Vampire"] = 10921326949, ["Werewolf"] = 10921342074,
			["Rthro"] = 10921269718, ["Oldschool"] = 10921244891, ["Ud'zal"] = 3303162967, ["Tryhard"] = 10921162768,
			["Goofy"] = 10921162768, ["Tamar"] = 10921312010
		},
		["Fall"] = {
			["Cartoony"] = 10921077030, ["Levitation"] = 10921136539, ["Robot"] = 10921251156, ["Stylish"] = 10921278648,
			["Superhero"] = 10921293373, ["Zombie"] = 10921350320, ["Ninja"] = 10921159222, ["Knight"] = 10921122579,
			["Mage"] = 10921148939, ["Pirate"] = 750780242, ["Elder"] = 10921105765, ["Toy"] = 10921307241,
			["Bubbly"] = 10921061530, ["Astronaut"] = 10921040576, ["Vampire"] = 10921321317, ["Werewolf"] = 10921337907,
			["Rthro"] = 10921262864, ["Oldschool"] = 10921241244, ["Tryhard"] = 10921136539, ["Goofy"] = 10921136539,
			["Tamar"] = 10921136539
		},
		["Jump"] = {
			["Cartoony"] = 10921078135, ["Levitation"] = 10921137402, ["Robot"] = 10921252123, ["Stylish"] = 10921279832,
			["Superhero"] = 10921294559, ["Zombie"] = 10921351278, ["Ninja"] = 10921160088, ["Knight"] = 10921123517,
			["Mage"] = 10921149743, ["Pirate"] = 750782230, ["Elder"] = 10921107367, ["Toy"] = 10921308158,
			["Bubbly"] = 10921062673, ["Astronaut"] = 10921042494, ["Vampire"] = 10921322186, ["Werewolf"] = 1083218792,
			["Rthro"] = 10921263860, ["Oldschool"] = 10921242013, ["Tryhard"] = 10921137402, ["Goofy"] = 10921137402,
			["Tamar"] = 10921242013
		},
		["Climb"] = {
			["Cartoony"] = 10921070953, ["Levitation"] = 10921132092, ["Robot"] = 10921245669, ["Stylish"] = 10921525854,
			["Superhero"] = 10921346417, ["Zombie"] = 10921469135, ["Ninja"] = 10920908048, ["Knight"] = 10921116196,
			["Mage"] = 10921143404, ["Pirate"] = 750779899, ["Elder"] = 10921100400, ["Toy"] = 10921300839,
			["Bubbly"] = 10921053544, ["Astronaut"] = 10921032124, ["Vampire"] = 10921314188, ["Werewolf"] = 10921329322,
			["Rthro"] = 10921257536, ["Oldschool"] = 10921229866
		},
		["Idle"] = {
			["Cartoony"] = 10921071918, ["Levitation"] = 10921132962, ["Robot"] = 10921248039, ["Stylish"] = 10921272275,
			["Superhero"] = 10921288909, ["Zombie"] = 10921344533, ["Ninja"] = 10921155160, ["Knight"] = 10921117521,
			["Mage"] = 10921144709, ["Pirate"] = 750781874, ["Elder"] = 10921101664, ["Toy"] = 10921301576,
			["Bubbly"] = 10921054344, ["Astronaut"] = 10921034824, ["Vampire"] = 10921315373, ["Werewolf"] = 10921330408,
			["Rthro"] = 10921258489, ["Oldschool"] = 10921230744, ["Toilet"] = 4417977954, ["Ud'zal"] = 3303162274,
			["Tryhard"] = 10921301576, ["Goofy"] = 4417977954, ["Tamar"] = 10921034824
		},
		["Idle 2"] = {
			["Cartoony"] = 10921072875, ["Levitation"] = 10921133721, ["Robot"] = 10921248831, ["Stylish"] = 10921273958,
			["Superhero"] = 10921290167, ["Zombie"] = 10921345304, ["Ninja"] = 10921155867, ["Knight"] = 10921118894,
			["Mage"] = 10921145797, ["Pirate"] = 750782770, ["Elder"] = 10921102574, ["Toy"] = 10921302207,
			["Bubbly"] = 10921055107, ["Astronaut"] = 10921036806, ["Vampire"] = 10921316709, ["Werewolf"] = 10921333667,
			["Rthro"] = 10921259953, ["Oldschool"] = 10921232093, ["Toilet"] = 4417978624, ["Ud'zal"] = 3303162549,
			["Tryhard"] = 10921302207, ["Goofy"] = 4417978624, ["Tamar"] = 10921036806
		}
	};
	local slots: {table} = {
		{["Name"] = 'Run', ["Folder"] = 'run', ["Anim"] = 'RunAnim'},
		{["Name"] = 'Walk', ["Folder"] = 'walk', ["Anim"] = 'WalkAnim'},
		{["Name"] = 'Fall', ["Folder"] = 'fall', ["Anim"] = 'FallAnim'},
		{["Name"] = 'Jump', ["Folder"] = 'jump', ["Anim"] = 'JumpAnim'},
		{["Name"] = 'Climb', ["Folder"] = 'climb', ["Anim"] = 'ClimbAnim'},
		{["Name"] = 'Idle', ["Folder"] = 'idle', ["Anim"] = 'Animation1'},
		{["Name"] = 'Idle 2', ["Folder"] = 'idle', ["Anim"] = 'Animation2'}
	};
	local original: {[Animation]: string} = {};
	local current: Model? = nil;
	local queued: boolean = false;

	local getParts: (character: Model?) -> (any, Humanoid?) = function(character: Model?): (any, Humanoid?)
		if not character then
			return nil, nil;
		end;
		return character:FindFirstChild('Animate'), character:FindFirstChildOfClass('Humanoid');
	end;

	local playingTracks: (humanoid: Humanoid) -> {AnimationTrack} = function(humanoid: Humanoid): {AnimationTrack}
		local animator: Animator? = humanoid:FindFirstChildOfClass('Animator');
		return (animator or humanoid):GetPlayingAnimationTracks();
	end;

	local refresh: (animate: any, humanoid: Humanoid, freeze: boolean) -> () = function(animate: any, humanoid: Humanoid, freeze: boolean): ()
		animate["Enabled"] = false;
		if freeze then
			for _, track: AnimationTrack in playingTracks(humanoid) do
				track:AdjustSpeed(0);
			end;
			return;
		end;
		for _, track: AnimationTrack in playingTracks(humanoid) do
			track:Stop(0);
		end;
		animate["Enabled"] = true;
	end;
	local apply: (character: Model?) -> () = function(character: Model?): ()
		local animate: any, humanoid: Humanoid? = getParts(character);
		if not animate or not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
			return;
		end;
		current = character;
		for _, slot: table in slots do
			local folder: Instance? = animate:FindFirstChild(slot.Folder);
			local anim: Instance? = folder and folder:FindFirstChild(slot.Anim);
			local id: number? = animList[slot.Name][slot.Option["Value"]];
			if anim and anim:IsA('Animation') and id then
				if original[anim] == nil then
					original[anim] = anim.AnimationId;
				end;
				anim.AnimationId = 'rbxassetid://' .. id;
			end;
		end;
		refresh(animate, humanoid, AnimFreeze["Enabled"]);
	end;
	local restore: () -> () = function(): ()
		for anim: Animation, id: string in original do
			anim.AnimationId = id;
		end;
		table.clear(original);
		local animate: any, humanoid: Humanoid? = getParts(current);
		current = nil;
		if animate and humanoid then
			refresh(animate, humanoid, false);
		end;
	end;
	local queueApply: () -> () = function(): ()
		if queued or not AnimationChanger["Enabled"] then
			return;
		end;
		queued = true;
		task.defer(function(): ()
			queued = false;
			if AnimationChanger["Enabled"] and entitylib.isAlive then
				apply(entitylib.character.Character);
			end;
		end);
	end;
	AnimationChanger = vape.Categories.Utility:CreateModule({
		["Name"] = 'AnimationChanger',
		["Tooltip"] = 'Customize your animations freely (R15 only).',
		["Function"] = function(callback: boolean): void
			if not callback then
				return;
			end;
			AnimationChanger:Clean(entitylib.Events.LocalAdded:Connect(function(ent: table)
				local character: Model = ent.Character;
				if character:WaitForChild('Animate', 5) and AnimationChanger["Enabled"] then
					apply(character);
				end;
			end));
			AnimationChanger:Clean(entitylib.Events.LocalRemoved:Connect(function(): ()
				table.clear(original);
				current = nil;
			end));
			AnimationChanger:Clean(restore);
			if entitylib.isAlive then
				apply(entitylib.character.Character);
			end;
		end
	});
	for _, slot: table in slots do
		local list: {string} = {};
		for name: string in animList[slot.Name] do
			table.insert(list, name);
		end;
		table.sort(list);
		slot.Option = AnimationChanger:CreateDropdown({
			["Name"] = slot.Name,
			["List"] = list,
			["Default"] = 'Robot',
			["Function"] = queueApply
		});
	end;
	AnimFreeze = AnimationChanger:CreateToggle({
		["Name"] = 'Freeze',
		["Tooltip"] = 'Freezes your character in its current pose.',
		["Function"] = queueApply
	});
end);

velo.run(function()
	local Watermark: table = {["Enabled"] = false};
	local WatermarkTitle: table = {["Value"] = 'Copium'};
	local WatermarkSub: table = {["Value"] = 'dev build'};
	local WatermarkLink: table = {["Value"] = '.gg/packetv3'};
	local WatermarkColorA: table = {["Hue"] = 0.8, ["Sat"] = 0.6, ["Value"] = 0.83};
	local WatermarkColorB: table = {["Hue"] = 0.61, ["Sat"] = 0.58, ["Value"] = 0.93};
	local WatermarkSpeed: table = {["Value"] = 120};
	local WatermarkBackground: table = {["Value"] = 0};
	local labels: {TextLabel} = {};
	local main: Frame? = nil;
	local gradient: UIGradient? = nil;
	local update: () -> () = function(): ()
		if not main or not gradient then
			return;
		end;
		for index: number, option: table in {WatermarkTitle, WatermarkSub, WatermarkLink} do
			local text: string = tostring(option["Value"] or '');
			labels[index].Text = text;
			labels[index].Visible = text ~= '';
		end;
		gradient.Color = ColorSequence.new(
			Color3.fromHSV(WatermarkColorA["Hue"], WatermarkColorA["Sat"], WatermarkColorA["Value"]),
			Color3.fromHSV(WatermarkColorB["Hue"], WatermarkColorB["Sat"], WatermarkColorB["Value"])
		);
		main.BackgroundTransparency = WatermarkBackground["Value"];
	end;
	local build: (holder: Frame) -> () = function(holder: Frame): ()
		local frame: Frame = Instance.new('Frame');
		frame.Size = UDim2.fromScale(1, 1);
		frame.BackgroundColor3 = Color3.new(0, 0, 0);
		frame.BorderSizePixel = 0;
		frame.Parent = holder;
		local stroke: UIStroke = Instance.new('UIStroke');
		stroke.Color = Color3.new(1, 1, 1);
		stroke.Thickness = 3;
		stroke.Parent = frame;
		local strokeGradient: UIGradient = Instance.new('UIGradient');
		strokeGradient.Parent = stroke;
		local layout: UIListLayout = Instance.new('UIListLayout');
		layout.FillDirection = Enum.FillDirection.Horizontal;
		layout.VerticalAlignment = Enum.VerticalAlignment.Center;
		layout.SortOrder = Enum.SortOrder.LayoutOrder;
		layout.Padding = UDim.new(0, 10);
		layout.Parent = frame;
		local padding: UIPadding = Instance.new('UIPadding');
		padding.PaddingLeft = UDim.new(0, 7);
		padding.Parent = frame;
		for index: number = 1, 3 do
			local label: TextLabel = Instance.new('TextLabel');
			label.LayoutOrder = index;
			label.BackgroundTransparency = 1;
			label.Font = Enum.Font.Gotham;
			label.TextSize = 12;
			label.TextColor3 = Color3.new(1, 1, 1);
			label.TextXAlignment = Enum.TextXAlignment.Left;
			label.AutomaticSize = Enum.AutomaticSize.X;
			label.Size = UDim2.new(0, 0, 1, 0);
			label.Parent = frame;
			labels[index] = label;
		end;
		main = frame;
		gradient = strokeGradient;
	end;
	Watermark = vape.Legit:CreateModule({
		["Name"] = 'Watermark',
		["Size"] = UDim2.fromOffset(304, 27),
		["Tooltip"] = 'Shows a watermark on your screen.',
		["Function"] = function(callback: boolean): void
			if not callback then
				return;
			end;
			update();
			Watermark:Clean(runService.RenderStepped:Connect(function(delta: number)
				if gradient then
					gradient.Rotation = (gradient.Rotation + delta * WatermarkSpeed["Value"]) % 360;
				end;
			end));
		end
	});
	build(Watermark.Children);
	WatermarkTitle = Watermark:CreateTextBox({
		["Name"] = 'Title',
		["Default"] = 'Copium',
		["Function"] = update
	});
	WatermarkSub = Watermark:CreateTextBox({
		["Name"] = 'Subtitle',
		["Default"] = 'dev build',
		["Function"] = update
	});
	WatermarkLink = Watermark:CreateTextBox({
		["Name"] = 'Link',
		["Default"] = '.gg/packetv3',
		["Function"] = update
	});
	WatermarkColorA = Watermark:CreateColorSlider({
		["Name"] = 'Gradient Start',
		["DefaultHue"] = 0.8,
		["DefaultSat"] = 0.6,
		["DefaultValue"] = 0.83,
		["Function"] = update
	});
	WatermarkColorB = Watermark:CreateColorSlider({
		["Name"] = 'Gradient End',
		["DefaultHue"] = 0.61,
		["DefaultSat"] = 0.58,
		["DefaultValue"] = 0.93,
		["Function"] = update
	});
	WatermarkSpeed = Watermark:CreateSlider({
		["Name"] = 'Spin Speed',
		["Min"] = 0,
		["Max"] = 720,
		["Default"] = 120,
		["Tooltip"] = 'Outline gradient rotation, in degrees per second.'
	});
	WatermarkBackground = Watermark:CreateSlider({
		["Name"] = 'Background Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10,
		["Default"] = 0,
		["Function"] = update
	});
	update();
end);

velo.run(function()
	local AutoGoon: table = {["Enabled"] = false};
	local Speed: table = {["Value"] = 2};
	local animR6: string = 'rbxassetid://72042024';
	local animR15: string = 'rbxassetid://698251653';
	local track: AnimationTrack? = nil;
	local stop: () -> () = function(): ()
		if track then
			track:Stop();
			track:Destroy();
			track = nil;
		end;
	end;
	local play: (character: Model?) -> () = function(character: Model?): ()
		stop();
		local humanoid: Humanoid? = character and character:FindFirstChildOfClass('Humanoid');
		if not humanoid then
			return;
		end;
		local animation: Animation = Instance.new('Animation');
		animation.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15 and animR15 or animR6;
		local animator: any = humanoid:FindFirstChildOfClass('Animator') or humanoid;
		track = animator:LoadAnimation(animation);
		track.Looped = true;
		track:Play();
		track:AdjustSpeed(Speed["Value"]);
	end;

	AutoGoon = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoGoon',
		["Tooltip"] = 'You auto goon to randoms',
		["Function"] = function(callback: boolean): void
			if not callback then
				return;
			end;
			AutoGoon:Clean(stop);
			AutoGoon:Clean(entitylib.Events.LocalAdded:Connect(function(ent: table)
				play(ent.Character);
			end));
			if entitylib.isAlive then
				play(entitylib.character.Character);
			end;
		end
	});
	Speed = AutoGoon:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 0,
		["Max"] = 5,
		["Decimal"] = 10,
		["Default"] = 2,
		["Darker"] = true,
		["Suffix"] = 'x',
		["Function"] = function(value: number): ()
			if track then
				track:AdjustSpeed(value);
			end;
		end
	});
end);

--[[
velo.run(function()
        local AutoReport: table = {["Enabled"] = false};
        local AutoReportList: any = {};
        local AutoReportNotify: table = {["Enabled"] = false};
        local alreadyreported: table = {};
        local removerepeat: (str: string?) -> any = function(str: string?): any
                local new: string = "";
                local last: string = "";
                for _: any, v: string? in next, str:split("") do
                        if v ~= last then 
                                new ..= v ;
                                last = v ;
                        end;
                end;
                return new;
        end;
        local reporttable: table = {
                ["gay"] = "Bullying", ["gae"] = "Bullying", ["gey"] = "Bullying",
                ["hack"] = "Scamming", ["exploit"] = "Scamming", ["cheat"] = "Scamming",
                ["hecker"] = "Scamming", ["haxker"] = "Scamming", ["hacer"] = "Scamming",
                ["report"] = "Bullying", ["fat"] = "Bullying", ["black"] = "Bullying",
                ["getalife"] = "Bullying", ["fatherless"] = "Bullying", ["fk"] = "Bullying",
                ["disco"] = "Offsite Links", ["yt"] = "Offsite Links", ["dizcourde"] = "Offsite Links",
                ["retard"] = "Swearing", ["bad"] = "Bullying", ["trash"] = "Bullying", ["nolife"] = "Bullying",
                ["negar"] = "Bullying", ["loser"] = "Bullying", ["killyour"] = "Bullying", ["kys"] = "Bullying",
                ["hacktowin"] = "Bullying", ["bozo"] = "Bullying", ["kid"] = "Bullying", ["adopted"] = "Bullying",
                ["linlife"] = "Bullying", ["commitnotalive"] = "Bullying", ["vape"] = "Offsite Links",
                ["futureclient"] = "Offsite Links", ["download"] = "Offsite Links", ["youtube"] = "Offsite Links",
                ["die"] = "Bullying", ["lobby"] = "Bullying", ["ban"] = "Bullying", ["wizard"] = "Bullying",
                ["wisard"] = "Bullying", ["witch"] = "Bullying", ["magic"] = "Bullying"
        };
        local reporttableexact: table = {
                ["L"] = "Bullying",
        };
        local findreport: (msg: string?) -> ...any = function(msg: string?): ...any
                local str: string = removerepeat((msg or ""):gsub("%W+", ""):lower());
                for w: any, r: any in next, reporttable do
                        if str:find(w) then return r, w; end;
                end;
                for w: any, r: any in next, reporttableexact do
                        if str == w then return r, w; end;
                end;
                if AutoReportList.ListEnabled then
                        for _, w: any in next, AutoReportList.ListEnabled do
                                if str:find(w) then return "Bullying", w; end;
                        end;
                end;
                return nil;
        end;
        local handlechat: (plr: Player?, msg: string?) -> () = function(plr: Player?, msg: string?): ()
                if plr and plr ~= lplr and whitelist:get(plr) == 0 then
                        local reason: string?, match: any = findreport(msg);
                        if reason and not alreadyreported[plr] then
                                task.spawn(function()
                                        playersService:ReportAbuse(plr, reason, "he said a bad word");
                                end);
                                if AutoReportNotify["Enabled"] then
                                        notif("Vape", "Reported "..plr.Name.." for "..reason.." ("..match..")", 15, "alert");
                                end;
                                alreadyreported[plr] = true;
                        end;
                end;
        end;
        AutoReport = vape.Categories.Utility:CreateModule({
                ["Name"] ="AutoReport",
                ["Function"] = function(callback: boolean): void
                        if not callback then return; end;
                        if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                                table.insert(AutoReport.Connections, textChatService.MessageReceived:Connect(function(tab: any)
                                        if tab.TextSource then
                                                local plr: Player? = playersService:GetPlayerByUserId(tab.TextSource.UserId);
                                                handlechat(plr, tab.Text);
                                        end;
                                end));
                        elseif replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
                                table.insert(AutoReport.Connections, replicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(tab: any)
                                        handlechat(playersService:FindFirstChild(tab.FromSpeaker), tab.Message);
                                end));
                        else
                                notif("Vape", "Default chat not found.", 5);
                                AutoReport:Toggle();
                        end;
                end;
        });
        AutoReportNotify = AutoReport:CreateToggle({
                ["Name"] = "Notify",
                ["Function"] = function() end
        });
        AutoReportList = AutoReport:CreateTextList({
                ["Name"] = "Report Words",
                ["TempText"] = "phrase (to report)"
        });
end);

velo.run(function()
		local overParams: RaycastParams = RaycastParams.new();
		overParams.RespectCanCollide = true;
		overParams.FilterType = Enum.RaycastFilterType.Exclude;
		local clampVec: (vec: Vector3, max: number) -> Vector3 = function(vec: Vector3, max: number): Vector3
				if vec.Magnitude > max then
					return vec.Unit == vec.Unit and vec.Unit * max or Vector3.zero;
				end;
				return vec;
		end;
		AnticheatBypass = vape.Categories.Utility:CreateModule({
				["Name"] = 'AnticheatBypass',
				["Function"] = function(callback: boolean): void
					if callback then
							bypassRoot = Instance.new('Part');
							bypassRoot.CanCollide = false;
							bypassRoot.CanQuery = false;
							bypassRoot.Size = Vector3.new(2, 2, 2);
							bypassRoot.Material = Enum.Material.SmoothPlastic;
							bypassRoot.Transparency = 1;
							bypassRoot.Parent = workspace.CurrentCamera;
							AnticheatBypass:Clean(bypassRoot);
							local oldcf: CFrame? = nil;
							local tpTimer: number = 0;
							local fallTimer: number = 0;
							local bindKey: string = httpService:GenerateGUID(true);
							runService:BindToRenderStep(bindKey, 0, function()
									if entitylib.isAlive and oldcf and bypassRoot then
											entitylib.character.RootPart.CFrame = oldcf;
									end;
							end);
							AnticheatBypass:Clean(function()
									pcall(runService.UnbindFromRenderStep, runService, bindKey);
							end);
							AnticheatBypass:Clean(entitylib.Events.LocalAdded:Connect(function()
									oldcf = nil;
							end));
							AnticheatBypass:Clean(runService.Heartbeat:Connect(function(dt: any)
									if entitylib.isAlive then
											local root: Part = entitylib.character.RootPart;
											local hum: Humanoid = entitylib.character.Humanoid;
											if not oldcf then
													bypassRoot.CFrame = root.CFrame;
											end;
											oldcf = root.CFrame;

											local diff: Vector3 = (oldcf.Position - bypassRoot.Position) * Vector3.new(1, 0, 1);
											local united: Vector3 = diff.Unit;
											united = united == united and diff.Magnitude > 0.1 and united * entitylib.character.Humanoid.WalkSpeed or Vector3.zero;
											bypassRoot.AssemblyLinearVelocity = Vector3.new(united.X, 0, united.Z);
											bypassRoot.CFrame = CFrame.lookAlong(Vector3.new(bypassRoot.Position.X, root.Position.Y, bypassRoot.Position.Z), root.CFrame.LookVector);
											if diff.Magnitude > 6 and (os.clock() - tpTimer) > 0.85 then
													bypassRoot.CFrame += clampVec(diff, entitylib.character.Humanoid.WalkSpeed * 0.75);
													tpTimer = os.clock();
											end;
											overParams.CollisionGroup = root.CollisionGroup;
											overParams.FilterDescendantsInstances = {lplr.Character, gameCamera};
											local flyCheck: RaycastResult? = workspace:Raycast(bypassRoot.Position, Vector3.new(0, -8, 0), overParams);
											if not flyCheck then
													if fallTimer == 0 then
															fallTimer = os.clock();
													end;
													bypassRoot.CFrame -= Vector3.new(0, ((os.clock() - fallTimer) % 1) * 10, 0);
											else
													fallTimer = 0;
											end;
											root.CFrame = bypassRoot.CFrame;
											if root.AssemblyLinearVelocity.Magnitude < 0.1 then
													root.AssemblyLinearVelocity += Vector3.new(0, -0.1, 0);
											end;
									else
											bypassRoot.CFrame = CFrame.new();
											bypassRoot.AssemblyLinearVelocity = Vector3.zero;
									end;
							end));
					else
							bypassRoot = nil;
					end;
				end,
				["Tooltip"] = 'Using various methods to bypass the Anticheat.'
		});
end);
]]--

velo.run(function()
        local crosshair: table? = nil;
        local crosshairr: table = {["Enabled"] = false};
        local envKey: string = "CROSSHAIR";
        local crosshair: table? = nil;
        local Crosshairr: table = {["Enabled"] = false};
        local HideCursor: table = {["Enabled"] = true, ["Object"] = {["Visible"] = true}};
        local CursorIcon: table = {["Enabled"] = false, ["Object"] = {["Visible"] = true}};
        local IconOption: table = {["Value"] = "Triangle", ["Object"] = {["Visible"] = false}};
        local CustomIcon: table = {["Enabled"] = false, ["Object"] = {["Visible"] = false}};
        local ImageId: table = {["Value"] = "", ["Object"] = {["Visible"] = false}};
        local oldIcon: string? = nil;
        local iconConn: RBXScriptConnection? = nil;
        local cursorIcons: {[string]: string} = {
                ["CS:GO"] = "rbxassetid://14789879068",
                ["Old Roblox"] = "rbxassetid://13546344315",
                ["dx9ware"] = "rbxassetid://12233942144",
                ["Aimbot"] = "rbxassetid://8680062686",
                ["Triangle"] = "rbxassetid://14790304072",
                ["Crosshair"] = "rbxassetid://9943168532",
                ["Arrow"] = "rbxassetid://14790316561"
        };
        local Gap: table = {["Value"] = 15, ["Object"] = {["Visible"] = true}};
        local Length: table = {["Value"] = 5, ["Object"] = {["Visible"] = true}};
        local Thickness: table = {["Value"] = 1, ["Object"] = {["Visible"] = true}};
        local FillColor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 1, ["Object"] = {["Visible"] = true}};
        local Outline: table = {["Enabled"] = false, ["Object"] = {["Visible"] = true}};
        local OutlineWidth: table = {["Value"] = 1, ["Object"] = {["Visible"] = false}};
        local OutlineColor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 1, ["Object"] = {["Visible"] = false}};
        local Glow: table = {["Enabled"] = true, ["Object"] = {["Visible"] = true}};
        local GlowSpread: table = {["Value"] = 7, ["Object"] = {["Visible"] = true}};
        local GlowLayers: table = {["Value"] = 5, ["Object"] = {["Visible"] = true}};
        local GlowIntensity: table = {["Value"] = 0.35, ["Object"] = {["Visible"] = true}};
        local GlowFalloff: table = {["Value"] = 2.2, ["Object"] = {["Visible"] = true}};
        local GlowColor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 1, ["Object"] = {["Visible"] = true}};
        local Rotate: table = {["Enabled"] = true, ["Object"] = {["Visible"] = true}};
        local RotationSpeed: table = {["Value"] = 180, ["Object"] = {["Visible"] = true}};
        local RotationDirection: table = {["Value"] = "Clockwise", ["Object"] = {["Visible"] = true}};
        local Pulse: table = {["Enabled"] = false, ["Object"] = {["Visible"] = true}};
        local PulseAmount: table = {["Value"] = 2.5, ["Object"] = {["Visible"] = false}};
        local PulseSpeed: table = {["Value"] = 8, ["Object"] = {["Visible"] = false}};
        local TextEnabled: table = {["Enabled"] = true, ["Object"] = {["Visible"] = true}};
        local TextContent: table = {["Value"] = "veloc", ["Object"] = {["Visible"] = true}};
        local TextFont: table = {["Value"] = Font.fromEnum(Enum.Font.GothamBold), ["Object"] = {["Visible"] = true}};
        local TextSize: table = {["Value"] = 12, ["Object"] = {["Visible"] = true}};
        local TextOffset: table = {["Value"] = 7, ["Object"] = {["Visible"] = true}};
        local TextColor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 1, ["Object"] = {["Visible"] = true}};
        local TextOutline: table = {["Enabled"] = false, ["Object"] = {["Visible"] = true}};
        local TextOutlineThickness: table = {["Value"] = 2, ["Object"] = {["Visible"] = false}};
        local TextOutlineColor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 1, ["Object"] = {["Visible"] = false}};
        local TextGlow: table = {["Enabled"] = true, ["Object"] = {["Visible"] = true}};
        local TextGlowSpread: table = {["Value"] = 4, ["Object"] = {["Visible"] = true}};
        local TextGlowIntensity: table = {["Value"] = 0.4, ["Object"] = {["Visible"] = true}};
        local TextGlowColor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 1, ["Object"] = {["Visible"] = true}};
		local crosshairUrl: string = "https://raw.githubusercontent.com/Copiums/Velocity/refs/heads/main/libraries/crosshair.lua";
        --=========================================================
        --  CONFIG MIRROR
        --
        --  mainapi:Load() runs LoadOptions() on a module BEFORE it calls
        --  Toggle(), and every option's Load() ends in SetValue(), which
        --  fires that option's Function. So on profile load all of these
        --  callbacks run while the renderer does not exist yet. Same story
        --  any time a slider moves with the module off. Everything lands
        --  here first; Push() flushes it.
        --=========================================================
        local config: table = {
                ["HideCursor"] = true,
                ["Radius"] = 15,
                ["Length"] = 5,
                ["Thickness"] = 1,
                ["FillColor"] = Color3.fromRGB(255, 255, 255),
                ["FillTransparency"] = 1,

                ["Outline"] = false,
                ["OutlineWidth"] = 1,
                ["OutlineColor"] = Color3.fromRGB(240, 240, 240),
                ["OutlineTransparency"] = 1,

                ["Glow"] = true,
                ["GlowSpread"] = 7,
                ["GlowLayers"] = 5,
                ["GlowIntensity"] = 0.35,
                ["GlowFalloff"] = 2.2,
                ["GlowColor"] = Color3.fromRGB(255, 255, 255),

                ["Rotate"] = true,
                ["RotationSpeed"] = 180,
                ["RotationDirection"] = 1,

                ["Pulse"] = false,
                ["PulseAmount"] = 2.5,
                ["PulseSpeed"] = 8,

                ["Text"] = {
                        ["Enabled"] = true,
                        ["Content"] = "veloc",
                        ["FontFace"] = nil,
                        ["Size"] = 12,
                        ["Offset"] = 7,
                        ["Color"] = Color3.fromRGB(255, 255, 255),
                        ["Transparency"] = 0,

                        ["Outline"] = false,
                        ["OutlineThickness"] = 2,
                        ["OutlineColor"] = Color3.fromRGB(240, 240, 240),
                        ["OutlineTransparency"] = 0,

                        ["Glow"] = true,
                        ["GlowSpread"] = 4,
                        ["GlowIntensity"] = 0.4,
                        ["GlowColor"] = Color3.fromRGB(255, 255, 255),
                },
        };

        --=========================================================
        --  RENDERER HANDLE
        --=========================================================
        local getEnv: () -> table = function(): table
                if typeof(getgenv) == "function" then
                        return getgenv();
                end;
                return _G;
        end;
        local resolve: () -> table? = function(): table?
                local live: any = getEnv()[envKey];
                if type(live) == "table" and type(live.Settings) == "table" then
                        crosshair = live;
                        return live;
                end;
                return nil;
        end;
        local ensureLoaded: () -> boolean = function(): boolean
                if resolve() then
                        return true;
                end;

                if vape.ThreadFix then
                        setthreadidentity(8);
                end;
                local suc: boolean, res: any = pcall(function(): any
                        local body: string = game:HttpGet(crosshairUrl, true);
                        if type(body) ~= "string" or #body < 32 then
                                error("empty response (" .. tostring(#tostring(body)) .. " bytes)", 0);
                        end;
                        if body:sub(1, 1) == "<" then
                                error("got HTML, not Lua - check the raw URL / repo is public", 0);
                        end;

                        local chunk: any, err: any = loadstring(body);
                        if not chunk then
                                error("compile error: " .. tostring(err), 0);
                        end;

                        return chunk();
                end);

                if suc and type(res) == "table" and type(res.Settings) == "table" then
                        crosshair = res;
                        return true;
                end;
                pcall(function(): ()
                        if typeof(notif) == "function" then
                                notif("Custom Crosshair", "Renderer failed to load, see console.", 8, "alert");
                        elseif vape and vape.CreateNotification then
                                vape:CreateNotification("Custom Crosshair", "Renderer failed to load, see console.", 8, "alert");
                        end;
                end);
                return false;
        end;
        local push: () -> () = function(): ()
                local c: table? = resolve();
                if not c then
                        return;
                end;

                local s: table = c.Settings;
                local t: table = s.Text;

                s.HideCursor = config.HideCursor;
                s.Radius = config.Radius;
                s.Length = config.Length;
                s.Thickness = config.Thickness;
                s.FillColor = config.FillColor;
                s.FillTransparency = config.FillTransparency;

                s.Outline = config.Outline;
                s.OutlineWidth = config.OutlineWidth;
                s.OutlineColor = config.OutlineColor;
                s.OutlineTransparency = config.OutlineTransparency;

                s.Glow = config.Glow;
                s.GlowSpread = config.GlowSpread;
                s.GlowLayers = config.GlowLayers;
                s.GlowIntensity = config.GlowIntensity;
                s.GlowFalloff = config.GlowFalloff;
                s.GlowColor = config.GlowColor;

                s.Rotate = config.Rotate;
                s.RotationSpeed = config.RotationSpeed;
                s.RotationDirection = config.RotationDirection;

                s.Pulse = config.Pulse;
                s.PulseAmount = config.PulseAmount;
                s.PulseSpeed = config.PulseSpeed;

                t["Enabled"] = config.Text["Enabled"];
                t.Content = config.Text.Content;
                t.FontFace = config.Text.FontFace;
                t.Size = config.Text.Size;
                t.Offset = config.Text.Offset;
                t.Color = config.Text.Color;
                t.Transparency = config.Text.Transparency;

                t.Outline = config.Text.Outline;
                t.OutlineThickness = config.Text.OutlineThickness;
                t.OutlineColor = config.Text.OutlineColor;
                t.OutlineTransparency = config.Text.OutlineTransparency;

                t.Glow = config.Text.Glow;
                t.GlowSpread = config.Text.GlowSpread;
                t.GlowIntensity = config.Text.GlowIntensity;
                t.GlowColor = config.Text.GlowColor;

                s["Enabled"] = Crosshairr["Enabled"];
                c.Refresh();
        end;

        local set: (key: string, value: any) -> () = function(key: string, value: any): ()
                config[key] = value;
                push();
        end;

        local setText: (key: string, value: any) -> () = function(key: string, value: any): ()
                config.Text[key] = value;
                push();
        end;

        local show: (state: boolean, ...table) -> () = function(state: boolean, ...: table): ()
                for _: number, control: table in {...} do
                        control.Object.Visible = state;
                end;
        end;
        local getIcon: () -> string = function(): string
                if CustomIcon["Enabled"] then
                        local id: string = tostring(ImageId["Value"] or "");
                        if id:match("^%d+$") then
                                return "rbxassetid://" .. id;
                        end;
                        return id;
                end;
                return cursorIcons[IconOption["Value"]] or "";
        end;
        local applyCursor: () -> () = function(): ()
                if Crosshairr["Enabled"] and CursorIcon["Enabled"] then
                        if oldIcon == nil then
                                oldIcon = inputService.MouseIcon;
                        end;
                        local icon: string = getIcon();
                        if inputService.MouseIcon ~= icon then
                                inputService.MouseIcon = icon;
                        end;
                        if not iconConn then
                                iconConn = inputService:GetPropertyChangedSignal("MouseIcon"):Connect(function(): ()
                                        local current: string = inputService.MouseIcon;
                                        local wanted: string = getIcon();
                                        if current ~= wanted then
                                                oldIcon = current;
                                                inputService.MouseIcon = wanted;
                                        end;
                                end);
                        end;
                        return;
                end;
                if iconConn then
                        iconConn:Disconnect();
                        iconConn = nil;
                end;
                if oldIcon ~= nil then
                        inputService.MouseIcon = oldIcon;
                        oldIcon = nil;
                end;
        end;
        Crosshairr = vape.Categories.Render:CreateModule({
                ["Name"] = "CustomCrosshair",
                ["Function"] = function(callback: boolean): ()
                        if callback then
                                if not ensureLoaded() then
                                        Crosshairr:Toggle();
                                        return;
                                end;
                                push();
                                applyCursor();
                        else
                                local c: table? = resolve() or crosshair;
                                if c then
                                        c.Toggle(false);
                                end;
                                applyCursor();
                        end;
                end,
                ["Tooltip"] = "Replaces the mouse cursor with an animated crosshair.",
        });
        HideCursor = Crosshairr:CreateToggle({
                ["Name"] = "Hide Cursor",
                ["Default"] = true,
                ["Function"] = function(callback: boolean): ()
                        set("HideCursor", callback);
                end,
                ["Tooltip"] = "Hides the system mouse pointer while the crosshair is on."
        });
        CursorIcon = Crosshairr:CreateToggle({
                ["Name"] = "Cursor Icon",
                ["Function"] = function(callback: boolean): ()
                        show(callback, IconOption, CustomIcon);
                        show(callback and CustomIcon["Enabled"], ImageId);
                        applyCursor();
                end,
                ["Tooltip"] = "Swaps your mouse cursor's image. Only visible with Hide Cursor off."
        });
        IconOption = Crosshairr:CreateDropdown({
                ["Name"] = "Icon",
                ["List"] = {"CS:GO", "Old Roblox", "dx9ware", "Aimbot", "Triangle", "Crosshair", "Arrow"},
                ["Default"] = "Triangle",
                ["Function"] = applyCursor,
                ["Tooltip"] = "Icon to replace your cursor.",
                ["Darker"] = true,
                ["Visible"] = false
        });
        CustomIcon = Crosshairr:CreateToggle({
                ["Name"] = "Custom Icon",
                ["Function"] = function(callback: boolean): ()
                        show(callback and CursorIcon["Enabled"], ImageId);
                        applyCursor();
                end,
                ["Tooltip"] = "Use your own image ID instead of a preset.",
                ["Darker"] = true,
                ["Visible"] = false
        });
        ImageId = Crosshairr:CreateTextBox({
                ["Name"] = "Image ID",
                ["Placeholder"] = "Image ID",
                ["Function"] = applyCursor,
                ["Tooltip"] = "Custom image ID for your cursor (just the number works).",
                ["Darker"] = true,
                ["Visible"] = false
        });
        Gap = Crosshairr:CreateSlider({
                ["Name"] = "Gap",
                ["Min"] = 0,
                ["Max"] = 60,
                ["Default"] = 15,
                ["Function"] = function(val: number): ()
                        set("Radius", val);
                end,
                ["Tooltip"] = "Distance from the cursor to the middle of each dash.",
                ["Suffix"] = "px"
        });
        Length = Crosshairr:CreateSlider({
                ["Name"] = "Length",
                ["Min"] = 1,
                ["Max"] = 40,
                ["Default"] = 5,
                ["Function"] = function(val: number): ()
                        set("Length", val);
                end,
                ["Suffix"] = "px"
        });
        Thickness = Crosshairr:CreateSlider({
                ["Name"] = "Thickness",
                ["Min"] = 1,
                ["Max"] = 10,
                ["Default"] = 1,
                ["Function"] = function(val: number): ()
                        set("Thickness", val);
                end,
                ["Suffix"] = "px"
        });
        FillColor = Crosshairr:CreateColorSlider({
                ["Name"] = "Crosshair Color",
                ["Function"] = function(hue: number, sat: number, val: number, opacity: number?): ()
                        config.FillColor = Color3.fromHSV(hue, sat, val);
                        config.FillTransparency = opacity or 1;
                        push();
                end
        });
        Outline = Crosshairr:CreateToggle({
                ["Name"] = "Outline",
                ["Function"] = function(callback: boolean): ()
                        show(callback, OutlineWidth, OutlineColor);
                        set("Outline", callback);
                end
        });
        OutlineWidth = Crosshairr:CreateSlider({
                ["Name"] = "Outline Width",
                ["Min"] = 1,
                ["Max"] = 6,
                ["Default"] = 1,
                ["Function"] = function(val: number): ()
                        set("OutlineWidth", val);
                end,
                ["Tooltip"] = "Border thickness per side.",
                ["Suffix"] = "px",
                ["Darker"] = true,
                ["Visible"] = false
        });
        OutlineColor = Crosshairr:CreateColorSlider({
                ["Name"] = "Outline Color",
                ["Function"] = function(hue: number, sat: number, val: number, opacity: number?): ()
                        config.OutlineColor = Color3.fromHSV(hue, sat, val);
                        config.OutlineTransparency = opacity or 1;
                        push();
                end,
                ["Darker"] = true,
                ["Visible"] = false
        });
        Glow = Crosshairr:CreateToggle({
                ["Name"] = "Glow",
                ["Default"] = true,
                ["Function"] = function(callback: boolean): ()
                        show(callback, GlowSpread, GlowIntensity, GlowFalloff, GlowLayers, GlowColor);
                        set("Glow", callback);
                end
        });
        GlowSpread = Crosshairr:CreateSlider({
                ["Name"] = "Glow Spread",
                ["Min"] = 1,
                ["Max"] = 30,
                ["Default"] = 7,
                ["Function"] = function(val: number): ()
                        set("GlowSpread", val);
                end,
                ["Suffix"] = "px",
                ["Darker"] = true
        });
        GlowIntensity = Crosshairr:CreateSlider({
                ["Name"] = "Glow Intensity",
                ["Min"] = 0,
                ["Max"] = 1,
                ["Default"] = 0.35,
                ["Decimal"] = 100,
                ["Function"] = function(val: number): ()
                        set("GlowIntensity", val);
                end,
                ["Darker"] = true
        });
        GlowFalloff = Crosshairr:CreateSlider({
                ["Name"] = "Glow Falloff",
                ["Min"] = 1,
                ["Max"] = 4,
                ["Default"] = 2.2,
                ["Decimal"] = 10,
                ["Function"] = function(val: number): ()
                        set("GlowFalloff", val);
                end,
                ["Tooltip"] = "Higher = softer halo. Below 1.5 it starts to look like an outline.",
                ["Darker"] = true
        });
        GlowLayers = Crosshairr:CreateSlider({
                ["Name"] = "Glow Quality",
                ["Min"] = 1,
                ["Max"] = 16,
                ["Default"] = 5,
                ["Function"] = function(val: number): ()
                        set("GlowLayers", val);
                end,
                ["Tooltip"] = "Stacked bands used to fake the falloff. Costs a little performance.",
                ["Darker"] = true
        });
        GlowColor = Crosshairr:CreateColorSlider({
                ["Name"] = "Glow Color",
                ["Function"] = function(hue: number, sat: number, val: number): ()
                        set("GlowColor", Color3.fromHSV(hue, sat, val));
                end,
                ["Darker"] = true
        });
        Rotate = Crosshairr:CreateToggle({
                ["Name"] = "Rotate",
                ["Default"] = true,
                ["Function"] = function(callback: boolean): ()
                        show(callback, RotationSpeed, RotationDirection);
                        set("Rotate", callback);
                end
        });
        RotationSpeed = Crosshairr:CreateSlider({
                ["Name"] = "Rotation Speed",
                ["Min"] = 0,
                ["Max"] = 720,
                ["Default"] = 180,
                ["Function"] = function(val: number): ()
                        set("RotationSpeed", val);
                end,
                ["Tooltip"] = "Degrees per second.",
                ["Darker"] = true
        });
        RotationDirection = Crosshairr:CreateDropdown({
                ["Name"] = "Direction",
                ["List"] = {"Clockwise", "Counter-Clockwise"},
                ["Function"] = function(val: string): ()
                        set("RotationDirection", (if val == "Counter-Clockwise" then -1 else 1));
                end,
                ["Darker"] = true
        });
        Pulse = Crosshairr:CreateToggle({
                ["Name"] = "Pulse",
                ["Function"] = function(callback: boolean): ()
                        show(callback, PulseAmount, PulseSpeed);
                        set("Pulse", callback);
                end
        });
        PulseAmount = Crosshairr:CreateSlider({
                ["Name"] = "Pulse Amount",
                ["Min"] = 0,
                ["Max"] = 20,
                ["Default"] = 2.5,
                ["Decimal"] = 10,
                ["Function"] = function(val: number): ()
                        set("PulseAmount", val);
                end,
                ["Suffix"] = "px",
                ["Darker"] = true,
                ["Visible"] = false
        });
        PulseSpeed = Crosshairr:CreateSlider({
                ["Name"] = "Pulse Speed",
                ["Min"] = 1,
                ["Max"] = 20,
                ["Default"] = 8,
                ["Decimal"] = 10,
                ["Function"] = function(val: number): ()
                        set("PulseSpeed", val);
                end,
                ["Darker"] = true,
                ["Visible"] = false
        });
        TextEnabled = Crosshairr:CreateToggle({
                ["Name"] = "Text",
                ["Default"] = true,
                ["Function"] = function(callback: boolean): ()
                        show(callback, TextContent, TextFont, TextSize, TextOffset, TextColor, TextOutline, TextGlow);
                        show(callback and TextOutline["Enabled"], TextOutlineThickness, TextOutlineColor);
                        show(callback and TextGlow["Enabled"], TextGlowSpread, TextGlowIntensity, TextGlowColor);
                        setText("Enabled", callback);
                end
        });
        TextContent = Crosshairr:CreateTextBox({
                ["Name"] = "Text",
                ["Function"] = function(): ()
                        setText("Content", TextContent["Value"]);
                end,
                ["Darker"] = true
        });
        TextFont = Crosshairr:CreateFont({
                ["Name"] = "Font",
                ["Function"] = function(val: Font): ()
                        setText("FontFace", val);
                end,
                ["Darker"] = true
        });
        TextSize = Crosshairr:CreateSlider({
                ["Name"] = "Text Size",
                ["Min"] = 6,
                ["Max"] = 40,
                ["Default"] = 12,
                ["Function"] = function(val: number): ()
                        setText("Size", val);
                end,
                ["Darker"] = true
        });
        TextOffset = Crosshairr:CreateSlider({
                ["Name"] = "Text Offset",
                ["Min"] = -40,
                ["Max"] = 60,
                ["Default"] = 7,
                ["Function"] = function(val: number): ()
                        setText("Offset", val);
                end,
                ["Tooltip"] = "Gap between the crosshair's outer tip and the text.",
                ["Suffix"] = "px",
                ["Darker"] = true
        });
        TextColor = Crosshairr:CreateColorSlider({
                ["Name"] = "Text Color",
                ["Function"] = function(hue: number, sat: number, val: number, opacity: number?): ()
                        config.Text.Color = Color3.fromHSV(hue, sat, val);
                        config.Text.Transparency = 1 - (opacity or 1);
                        push();
                end,
                ["Darker"] = true
        });
        TextOutline = Crosshairr:CreateToggle({
                ["Name"] = "Text Outline",
                ["Function"] = function(callback: boolean): ()
                        show(callback, TextOutlineThickness, TextOutlineColor);
                        setText("Outline", callback);
                end,
                ["Darker"] = true
        });
        TextOutlineThickness = Crosshairr:CreateSlider({
                ["Name"] = "Outline Thickness",
                ["Min"] = 1,
                ["Max"] = 8,
                ["Default"] = 2,
                ["Function"] = function(val: number): ()
                        setText("OutlineThickness", val);
                end,
                ["Suffix"] = "px",
                ["Darker"] = true,
                ["Visible"] = false
        });
        TextOutlineColor = Crosshairr:CreateColorSlider({
                ["Name"] = "Text Outline Color",
                ["Function"] = function(hue: number, sat: number, val: number, opacity: number?): ()
                        config.Text.OutlineColor = Color3.fromHSV(hue, sat, val);
                        config.Text.OutlineTransparency = 1 - (opacity or 1);
                        push();
                end,
                ["Darker"] = true,
                ["Visible"] = false
        });
        TextGlow = Crosshairr:CreateToggle({
                ["Name"] = "Text Glow",
                ["Default"] = true,
                ["Function"] = function(callback: boolean): ()
                        show(callback, TextGlowSpread, TextGlowIntensity, TextGlowColor);
                        setText("Glow", callback);
                end,
                ["Darker"] = true
        });
        TextGlowSpread = Crosshairr:CreateSlider({
                ["Name"] = "Text Glow Spread",
                ["Min"] = 1,
                ["Max"] = 20,
                ["Default"] = 4,
                ["Function"] = function(val: number): ()
                        setText("GlowSpread", val);
                end,
                ["Suffix"] = "px",
                ["Darker"] = true
        });
        TextGlowIntensity = Crosshairr:CreateSlider({
                ["Name"] = "Text Glow Intensity",
                ["Min"] = 0,
                ["Max"] = 1,
                ["Default"] = 0.4,
                ["Decimal"] = 100,
                ["Function"] = function(val: number): ()
                        setText("GlowIntensity", val);
                end,
                ["Darker"] = true
        });
        TextGlowColor = Crosshairr:CreateColorSlider({
                ["Name"] = "Text Glow Color",
                ["Function"] = function(hue: number, sat: number, val: number): ()
                        setText("GlowColor", Color3.fromHSV(hue, sat, val));
                end,
                ["Darker"] = true
        });
end);

velo["run"](function(): ()
        --[[
                Lua OTP Library https://github.com/tilkinsc/LuaOTP/
                SpotAPI https://github.com/Aran404/SpotAPI

                MIT License

                Copyright (c) 2021 Cody Tilkins

                Permission is hereby granted, free of charge, to any person obtaining a copy
                of this software and associated documentation files (the "Software"), to deal
                in the Software without restriction, including without limitation the rights
                to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                copies of the Software, and to permit persons to whom the Software is
                furnished to do so, subject to the following conditions:

                The above copyright notice and this permission notice shall be included in all
                copies or substantial portions of the Software.

                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                SOFTWARE.
        ]]

        type CacheEntry = {Artists: {string}, Title: string, Cover: string?};
        type AuthData = {
                clientId: string,
                clientVersion: string,
                correlationId: string,
                fetchKey: string?,
                accessToken: string,
                expireTime: number;
        };
        type DealerInfo = {Dealer: string, Client: string};
        type Response = {Success: boolean, Body: string};
        type VeloTheme = {Background: Color3, Title: Color3, Artist: Color3, Time: Color3, BarBack: Color3};
        type VeloConfig = {
                Width: number,
                Height: number,
                Padding: number,
                Corner: number,
                CoverCorner: number,
                TitleSize: number,
                TextSize: number,
                BarThickness: number,
                Transparency: number,
                Scale: number,
                ShowCover: boolean,
                ShowTimes: boolean,
                ShowBar: boolean,
                ByPrefix: boolean,
                RoundBar: boolean,
                Shadow: boolean,
                Border: boolean;
        };
        type SpotifyHandlerT = {
                Cache: {[string]: CacheEntry},
                Socket: any,
                Headers: {[string]: string},
                Data: AuthData,
                Dealer: DealerInfo,
                clientToken: string,
                connectionId: string?,
                syncTime: number?,
                track: string?,
                coverUrl: string?,
                playPosition: number?,
                playRate: number,
                playDuration: number,
                Callback: (self: SpotifyHandlerT, data: any) -> (),
                Refresh: (self: SpotifyHandlerT) -> AuthData,
                GetSession: (self: SpotifyHandlerT) -> string,
                RequestCache: (self: SpotifyHandlerT, id: string, data: any) -> (),
                RegisterDevice: (self: SpotifyHandlerT, connectionId: string) -> (),
                RegisterSocket: (self: SpotifyHandlerT) -> (),
                Start: (self: SpotifyHandlerT) -> ();
        };

        local Spotify: any;
        local spotifyHandler: SpotifyHandlerT = {["Cache"] = {}} :: any;
        local currentStyle: string = 'Vape';
        local currentTheme: string = 'Dark';
        local lastTitle: string = 'Not playing';
        local lastArtists: {string} = {};
        local cfg: VeloConfig = {
                ["Width"] = 229,
                ["Height"] = 82,
                ["Padding"] = 10,
                ["Corner"] = 6,
                ["CoverCorner"] = 4,
                ["TitleSize"] = 14,
                ["TextSize"] = 11,
                ["BarThickness"] = 2,
                ["Transparency"] = 0,
                ["Scale"] = 1,
                ["ShowCover"] = true,
                ["ShowTimes"] = true,
                ["ShowBar"] = true,
                ["ByPrefix"] = true,
                ["RoundBar"] = true,
                ["Shadow"] = false,
                ["Border"] = false;
        };
        local veloThemes: {[string]: VeloTheme} = {
                ["Dark"] = {
                        ["Background"] = Color3["fromRGB"](15, 15, 15),
                        ["Title"] = Color3["fromRGB"](255, 255, 255),
                        ["Artist"] = Color3["fromRGB"](200, 200, 200),
                        ["Time"] = Color3["fromRGB"](170, 170, 170),
                        ["BarBack"] = Color3["fromRGB"](60, 60, 60);
                },
                ["Light"] = {
                        ["Background"] = Color3["fromRGB"](255, 255, 255),
                        ["Title"] = Color3["fromRGB"](0, 0, 0),
                        ["Artist"] = Color3["fromRGB"](60, 60, 60),
                        ["Time"] = Color3["fromRGB"](90, 90, 90),
                        ["BarBack"] = Color3["fromRGB"](200, 200, 200);
                },
                ["Nightly"] = {
                        ["Background"] = Color3["fromRGB"](0, 0, 0),
                        ["Title"] = Color3["fromRGB"](255, 255, 255),
                        ["Artist"] = Color3["fromRGB"](200, 200, 200),
                        ["Time"] = Color3["fromRGB"](170, 170, 170),
                        ["BarBack"] = Color3["fromRGB"](40, 40, 40);
                };
        };
        local customTheme: VeloTheme = table["clone"](veloThemes["Dark"]);
        local addCorner: (parent: GuiObject, radius: UDim?) -> UICorner = function(parent: GuiObject, radius: UDim?): UICorner
                local corner: UICorner = Instance["new"]('UICorner');
                corner["CornerRadius"] = radius or UDim["new"](0, 5);
                corner["Parent"] = parent;

                return corner;
        end;
        local formatTime: (sec: number) -> string = function(sec: number): string
                local total: number = math["max"](math["floor"](sec), 0);
                return string["format"]('%d:%02d', total // 60, total % 60);
        end;
        Spotify = vape:CreateOverlay({
                ["Name"] = 'Spotify',
                ["Icon"] = getcustomasset('velo/assets/new/spotify.png'),
                ["Size"] = UDim2["fromOffset"](16, 16),
                ["Position"] = UDim2["fromOffset"](12, 13),
                ["Function"] = function(callback: boolean): ()
                        if callback then
                                Spotify:Clean(task["spawn"](function(): ()
                                        spotifyHandler:Start();
                                end));
                        else
                                if spotifyHandler["Socket"] then
                                        spotifyHandler["Socket"]:Close();
                                        spotifyHandler["Socket"] = nil;
                                end;
                        end;
                end;
        });
        local holder: Frame = Instance["new"]('Frame');
        holder["BackgroundColor3"] = Color3["new"]();
        holder["BackgroundTransparency"] = 0.5;
        holder["Size"] = UDim2["fromOffset"](180, 55);
        holder["Parent"] = Spotify["Children"];
        addBlur(holder);
        addCorner(holder);
        local title: TextLabel = Instance["new"]('TextLabel');
        title["BackgroundTransparency"] = 1;
        title["Font"] = Enum["Font"]["Arial"];
        title["Position"] = UDim2["fromOffset"](6, 6);
        title["Size"] = UDim2["new"](1, -6, 0, 16);
        title["Text"] = lastTitle;
        title["TextColor3"] = Color3["new"](1, 1, 1);
        title["TextSize"] = 16;
        title["TextTruncate"] = Enum["TextTruncate"]["AtEnd"];
        title["TextXAlignment"] = Enum["TextXAlignment"]["Left"];
        title["Parent"] = holder;
        local artist: TextLabel = Instance["new"]('TextLabel');
        artist["BackgroundTransparency"] = 1;
        artist["Font"] = Enum["Font"]["Arial"];
        artist["Position"] = UDim2["fromOffset"](7, 24);
        artist["Size"] = UDim2["new"](1, -7, 0, 14);
        artist["Text"] = '';
        artist["TextColor3"] = Color3["new"](0.7, 0.7, 0.7);
        artist["TextSize"] = 14;
        artist["TextTruncate"] = Enum["TextTruncate"]["AtEnd"];
        artist["TextXAlignment"] = Enum["TextXAlignment"]["Left"];
        artist["Parent"] = holder;
        local progress: Frame = Instance["new"]('Frame');
        progress["BackgroundColor3"] = Color3["fromRGB"](26, 25, 26);
        progress["Position"] = UDim2["fromOffset"](6, 43);
        progress["Size"] = UDim2["new"](1, -46, 0, 4);
        progress["Parent"] = holder;
        addCorner(progress);
        local fill: Frame = Instance["new"]('Frame');
        fill["BackgroundColor3"] = Color3["fromHSV"](0.46, 0.96, 0.52);
        fill["Size"] = UDim2["fromScale"](0, 1);
        fill["Parent"] = progress;
        addCorner(fill);
        local duration: TextLabel = Instance["new"]('TextLabel');
        duration["BackgroundColor3"] = Color3["new"](1, 1, 1);
        duration["BackgroundTransparency"] = 1;
        duration["BorderColor3"] = Color3["new"]();
        duration["BorderSizePixel"] = 0;
        duration["Font"] = Enum["Font"]["Arial"];
        duration["Position"] = UDim2["new"](1, -32, 0, 37);
        duration["Size"] = UDim2["fromOffset"](40, 13);
        duration["Text"] = '0:00';
        duration["TextColor3"] = Color3["fromRGB"](170, 170, 170);
        duration["TextSize"] = 13;
        duration["TextXAlignment"] = Enum["TextXAlignment"]["Left"];
        duration["Parent"] = holder;
        local stroke: UIStroke = Instance["new"]('UIStroke');
        stroke["Enabled"] = false;
        stroke["Color"] = Color3["fromHSV"](0.44, 1, 1);
        stroke["Parent"] = holder;
        local card: Frame = Instance["new"]('Frame');
        card["BackgroundColor3"] = customTheme["Background"];
        card["BorderSizePixel"] = 0;
        card["Size"] = UDim2["fromOffset"](cfg["Width"], cfg["Height"]);
        card["Visible"] = false;
        card["Parent"] = Spotify["Children"];
        local cardCorner: UICorner = addCorner(card, UDim["new"](0, cfg["Corner"]));
        local cardScale: UIScale = Instance["new"]('UIScale');
        cardScale["Scale"] = cfg["Scale"];
        cardScale["Parent"] = card;
        local cardShadow: any = addBlur(card);
        cardShadow["Visible"] = cfg["Shadow"];
        local cardStroke: UIStroke = Instance["new"]('UIStroke');
        cardStroke["ApplyStrokeMode"] = Enum["ApplyStrokeMode"]["Border"];
        cardStroke["Color"] = Color3["fromRGB"](251, 142, 142);
        cardStroke["Enabled"] = cfg["Border"];
        cardStroke["Thickness"] = 1;
        cardStroke["Parent"] = card;
        local cover: ImageLabel = Instance["new"]('ImageLabel');
        cover["BackgroundColor3"] = Color3["fromRGB"](40, 40, 40);
        cover["BackgroundTransparency"] = 0;
        cover["BorderSizePixel"] = 0;
        cover["Image"] = '';
        cover["ScaleType"] = Enum["ScaleType"]["Crop"];
        cover["Parent"] = card;
        local coverCorner: UICorner = addCorner(cover, UDim["new"](0, cfg["CoverCorner"]));
        local vTitle: TextLabel = Instance["new"]('TextLabel');
        vTitle["BackgroundTransparency"] = 1;
        vTitle["Font"] = Enum["Font"]["ArimoBold"];
        vTitle["Text"] = lastTitle;
        vTitle["TextTruncate"] = Enum["TextTruncate"]["AtEnd"];
        vTitle["TextXAlignment"] = Enum["TextXAlignment"]["Left"];
        vTitle["TextYAlignment"] = Enum["TextYAlignment"]["Top"];
        vTitle["Parent"] = card;
        local vArtist: TextLabel = Instance["new"]('TextLabel');
        vArtist["BackgroundTransparency"] = 1;
        vArtist["Font"] = Enum["Font"]["Arimo"];
        vArtist["Text"] = '';
        vArtist["TextTruncate"] = Enum["TextTruncate"]["AtEnd"];
        vArtist["TextXAlignment"] = Enum["TextXAlignment"]["Left"];
        vArtist["TextYAlignment"] = Enum["TextYAlignment"]["Top"];
        vArtist["Parent"] = card;
        local vCurrent: TextLabel = Instance["new"]('TextLabel');
        vCurrent["BackgroundTransparency"] = 1;
        vCurrent["Font"] = Enum["Font"]["Arimo"];
        vCurrent["Text"] = '0:00';
        vCurrent["TextXAlignment"] = Enum["TextXAlignment"]["Left"];
        vCurrent["Parent"] = card;
        local vMax: TextLabel = Instance["new"]('TextLabel');
        vMax["BackgroundTransparency"] = 1;
        vMax["Font"] = Enum["Font"]["Arimo"];
        vMax["Text"] = '0:00';
        vMax["TextXAlignment"] = Enum["TextXAlignment"]["Right"];
        vMax["Parent"] = card;
        local vBar: Frame = Instance["new"]('Frame');
        vBar["BorderSizePixel"] = 0;
        vBar["Parent"] = card;
        local vBarCorner: UICorner = addCorner(vBar, UDim["new"](1, 0));
        local vBarFill: Frame = Instance["new"]('Frame');
        vBarFill["BackgroundColor3"] = Color3["fromRGB"](251, 142, 142);
        vBarFill["BorderSizePixel"] = 0;
        vBarFill["Size"] = UDim2["fromScale"](0, 1);
        vBarFill["Parent"] = vBar;
        local vBarFillCorner: UICorner = addCorner(vBarFill, UDim["new"](1, 0));
        local layoutCard: () -> () = function(): ()
                local w: number = cfg["Width"];
                local h: number = cfg["Height"];
                local pad: number = cfg["Padding"];
                local coverSize: number = math["max"](h - pad * 2, 0);
                local textX: number = cfg["ShowCover"] and (pad + coverSize + 10) or (pad + 2);
                local textW: number = math["max"](w - textX - pad, 0);
                local lineH: number = cfg["TextSize"] + 2;
                local rowY: number = h - pad - lineH;
                local timeW: number = cfg["ShowTimes"] and math["ceil"](cfg["TextSize"] * 3.2) or 0;
                local gap: number = cfg["ShowTimes"] and 6 or 0;
                local barX: number = textX + timeW + gap;
                local barW: number = math["max"](w - pad - timeW - gap - barX, 0);

                card["Size"] = UDim2["fromOffset"](w, h);
                card["BackgroundTransparency"] = cfg["Transparency"];
                cardCorner["CornerRadius"] = UDim["new"](0, cfg["Corner"]);
                cardScale["Scale"] = cfg["Scale"];
                cardShadow["Visible"] = cfg["Shadow"];
                cardStroke["Enabled"] = cfg["Border"];

                cover["Visible"] = cfg["ShowCover"];
                cover["Position"] = UDim2["fromOffset"](pad, pad);
                cover["Size"] = UDim2["fromOffset"](coverSize, coverSize);
                coverCorner["CornerRadius"] = UDim["new"](0, cfg["CoverCorner"]);

                vTitle["Position"] = UDim2["fromOffset"](textX, pad + 2);
                vTitle["Size"] = UDim2["fromOffset"](textW, cfg["TitleSize"] + 2);
                vTitle["TextSize"] = cfg["TitleSize"];
                vArtist["Position"] = UDim2["fromOffset"](textX, pad + cfg["TitleSize"] + 6);
                vArtist["Size"] = UDim2["fromOffset"](textW, lineH);
                vArtist["TextSize"] = cfg["TextSize"];

                vCurrent["Visible"] = cfg["ShowTimes"];
                vCurrent["Position"] = UDim2["fromOffset"](textX, rowY);
                vCurrent["Size"] = UDim2["fromOffset"](timeW, lineH);
                vCurrent["TextSize"] = cfg["TextSize"];
                vMax["Visible"] = cfg["ShowTimes"];
                vMax["Position"] = UDim2["fromOffset"](w - pad - timeW, rowY);
                vMax["Size"] = UDim2["fromOffset"](timeW, lineH);
                vMax["TextSize"] = cfg["TextSize"];

                vBar["Visible"] = cfg["ShowBar"];
                vBar["Position"] = UDim2["fromOffset"](barX, rowY + math["floor"]((lineH - cfg["BarThickness"]) / 2));
                vBar["Size"] = UDim2["fromOffset"](barW, cfg["BarThickness"]);
                vBarCorner["CornerRadius"] = cfg["RoundBar"] and UDim["new"](1, 0) or UDim["new"]();
                vBarFillCorner["CornerRadius"] = vBarCorner["CornerRadius"];
        end;
        local applyTheme: () -> () = function(): ()
                local theme: VeloTheme = currentTheme == 'Custom' and customTheme or veloThemes[currentTheme] or veloThemes["Dark"];
                card["BackgroundColor3"] = theme["Background"];
                vTitle["TextColor3"] = theme["Title"];
                vArtist["TextColor3"] = theme["Artist"];
                vCurrent["TextColor3"] = theme["Time"];
                vMax["TextColor3"] = theme["Time"];
                vBar["BackgroundColor3"] = theme["BarBack"];
        end;
        local setTrackText: (titleText: string, artists: {string}) -> () = function(titleText: string, artists: {string}): ()
                lastTitle = titleText;
                lastArtists = artists;
                local artistText: string = table["concat"](artists, ', ');
                title["Text"] = titleText;
                artist["Text"] = artistText;
                vTitle["Text"] = titleText;
                vArtist["Text"] = (cfg["ByPrefix"] and artistText ~= '') and ('By '..artistText) or artistText;
        end;
        local Style: any;
        local BackgroundColor: any;
        local BorderColor: any;
        local Border: any;
        local Theme: any;
        local CardBackground: any;
        local TitleColor: any;
        local ArtistColor: any;
        local TimeColor: any;
        local BarBackground: any;
        local BarColor: any;
        local Transparency: any;
        local Scale: any;
        local Width: any;
        local Height: any;
        local Padding: any;
        local CardCorner: any;
        local CoverCorner: any;
        local TitleSize: any;
        local TextSize: any;
        local BarThickness: any;
        local TitleFont: any;
        local ArtistFont: any;
        local TimeFont: any;
        local ShowCover: any;
        local ShowTimes: any;
        local ShowProgress: any;
        local RoundBar: any;
        local ByPrefix: any;
        local Shadow: any;
        local CardBorder: any;
        local CardBorderColor: any;
        local BorderThickness: any;
        local updateVisibility: () -> () = function(): ()
                local isVape: boolean = currentStyle == 'Vape';
                local isVelo: boolean = currentStyle == 'Velocity';
                local isCustom: boolean = isVelo and currentTheme == 'Custom';
                holder["Visible"] = isVape;
                card["Visible"] = isVelo;
                BackgroundColor["Object"]["Visible"] = isVape;
                Border["Object"]["Visible"] = isVape;
                BorderColor["Object"]["Visible"] = isVape and Border["Enabled"];
                Theme["Object"]["Visible"] = isVelo;
                CardBackground["Object"]["Visible"] = isCustom;
                TitleColor["Object"]["Visible"] = isCustom;
                ArtistColor["Object"]["Visible"] = isCustom;
                TimeColor["Object"]["Visible"] = isCustom;
                BarBackground["Object"]["Visible"] = isCustom;
                BarColor["Object"]["Visible"] = isVelo;
                Transparency["Object"]["Visible"] = isVelo;
                Scale["Object"]["Visible"] = isVelo;
                Width["Object"]["Visible"] = isVelo;
                Height["Object"]["Visible"] = isVelo;
                Padding["Object"]["Visible"] = isVelo;
                CardCorner["Object"]["Visible"] = isVelo;
                CoverCorner["Object"]["Visible"] = isVelo;
                TitleSize["Object"]["Visible"] = isVelo;
                TextSize["Object"]["Visible"] = isVelo;
                BarThickness["Object"]["Visible"] = isVelo;
                TitleFont["Object"]["Visible"] = isVelo;
                ArtistFont["Object"]["Visible"] = isVelo;
                TimeFont["Object"]["Visible"] = isVelo;
                ShowCover["Object"]["Visible"] = isVelo;
                ShowTimes["Object"]["Visible"] = isVelo;
                ShowProgress["Object"]["Visible"] = isVelo;
                RoundBar["Object"]["Visible"] = isVelo;
                ByPrefix["Object"]["Visible"] = isVelo;
                Shadow["Object"]["Visible"] = isVelo;
                CardBorder["Object"]["Visible"] = isVelo;
                CardBorderColor["Object"]["Visible"] = isVelo and CardBorder["Enabled"];
                BorderThickness["Object"]["Visible"] = isVelo and CardBorder["Enabled"];
        end;
        Style = Spotify:CreateDropdown({
                ["Name"] = 'Style',
                ["List"] = {'Vape', 'Velocity'},
                ["Function"] = function(value: string): ()
                        currentStyle = value;
                        updateVisibility();
                end;
        });
        BackgroundColor = Spotify:CreateColorSlider({
                ["Name"] = 'Background Color',
                ["DefaultValue"] = 0,
                ["DefaultOpacity"] = 0.5,
                ["Function"] = function(hue: number, sat: number, val: number, opacity: number): ()
                        holder["BackgroundColor3"] = Color3["fromHSV"](hue, sat, val);
                        holder["BackgroundTransparency"] = 1 - opacity;
                end;
        });
        BorderColor = Spotify:CreateColorSlider({
                ["Name"] = 'Border Color',
                ["Function"] = function(hue: number, sat: number, val: number, opacity: number): ()
                        stroke["Color"] = Color3["fromHSV"](hue, sat, val);
                        stroke["Transparency"] = 1 - opacity;
                end,
                ["Darker"] = true,
                ["Visible"] = false;
        });
        Border = Spotify:CreateToggle({
                ["Name"] = 'Border',
                ["Function"] = function(callback: boolean): ()
                        stroke["Enabled"] = callback;
                        BorderColor["Object"]["Visible"] = callback and currentStyle == 'Vape';
                end;
        });
        Theme = Spotify:CreateDropdown({
                ["Name"] = 'Theme',
                ["List"] = {'Dark', 'Light', 'Nightly', 'Custom'},
                ["Function"] = function(value: string): ()
                        currentTheme = value;
                        applyTheme();
                        updateVisibility();
                end;
        });
        CardBackground = Spotify:CreateColorSlider({
                ["Name"] = 'Card Background',
                ["DefaultHue"] = 0,
                ["DefaultSat"] = 0,
                ["DefaultValue"] = 15 / 255,
                ["Function"] = function(hue: number, sat: number, val: number): ()
                        customTheme["Background"] = Color3["fromHSV"](hue, sat, val);
                        applyTheme();
                end,
                ["Darker"] = true,
                ["Visible"] = false;
        });
        TitleColor = Spotify:CreateColorSlider({
                ["Name"] = 'Title Color',
                ["DefaultHue"] = 0,
                ["DefaultSat"] = 0,
                ["DefaultValue"] = 1,
                ["Function"] = function(hue: number, sat: number, val: number): ()
                        customTheme["Title"] = Color3["fromHSV"](hue, sat, val);
                        applyTheme();
                end,
                ["Darker"] = true,
                ["Visible"] = false;
        });
        ArtistColor = Spotify:CreateColorSlider({
                ["Name"] = 'Artist Color',
                ["DefaultHue"] = 0,
                ["DefaultSat"] = 0,
                ["DefaultValue"] = 200 / 255,
                ["Function"] = function(hue: number, sat: number, val: number): ()
                        customTheme["Artist"] = Color3["fromHSV"](hue, sat, val);
                        applyTheme();
                end,
                ["Darker"] = true,
                ["Visible"] = false;
        });
        TimeColor = Spotify:CreateColorSlider({
                ["Name"] = 'Time Color',
                ["DefaultHue"] = 0,
                ["DefaultSat"] = 0,
                ["DefaultValue"] = 170 / 255,
                ["Function"] = function(hue: number, sat: number, val: number): ()
                        customTheme["Time"] = Color3["fromHSV"](hue, sat, val);
                        applyTheme();
                end,
                ["Darker"] = true,
                ["Visible"] = false;
        });
        BarBackground = Spotify:CreateColorSlider({
                ["Name"] = 'Bar Background',
                ["DefaultHue"] = 0,
                ["DefaultSat"] = 0,
                ["DefaultValue"] = 60 / 255,
                ["Function"] = function(hue: number, sat: number, val: number): ()
                        customTheme["BarBack"] = Color3["fromHSV"](hue, sat, val);
                        applyTheme();
                end,
                ["Darker"] = true,
                ["Visible"] = false;
        });
        BarColor = Spotify:CreateColorSlider({
                ["Name"] = 'Bar Color',
                ["DefaultHue"] = 0,
                ["DefaultSat"] = 109 / 251,
                ["DefaultValue"] = 251 / 255,
                ["Function"] = function(hue: number, sat: number, val: number, opacity: number): ()
                        vBarFill["BackgroundColor3"] = Color3["fromHSV"](hue, sat, val);
                        vBarFill["BackgroundTransparency"] = 1 - opacity;
                end,
                ["Visible"] = false;
        });
        Transparency = Spotify:CreateSlider({
                ["Name"] = 'Transparency',
                ["Min"] = 0,
                ["Max"] = 1,
                ["Decimal"] = 100,
                ["Default"] = cfg["Transparency"],
                ["Function"] = function(val: number): ()
                        cfg["Transparency"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        Scale = Spotify:CreateSlider({
                ["Name"] = 'Scale',
                ["Min"] = 0.5,
                ["Max"] = 2,
                ["Decimal"] = 100,
                ["Default"] = cfg["Scale"],
                ["Function"] = function(val: number): ()
                        cfg["Scale"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        Width = Spotify:CreateSlider({
                ["Name"] = 'Width',
                ["Min"] = 150,
                ["Max"] = 400,
                ["Default"] = cfg["Width"],
                ["Function"] = function(val: number): ()
                        cfg["Width"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        Height = Spotify:CreateSlider({
                ["Name"] = 'Height',
                ["Min"] = 50,
                ["Max"] = 150,
                ["Default"] = cfg["Height"],
                ["Function"] = function(val: number): ()
                        cfg["Height"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        Padding = Spotify:CreateSlider({
                ["Name"] = 'Padding',
                ["Min"] = 2,
                ["Max"] = 20,
                ["Default"] = cfg["Padding"],
                ["Function"] = function(val: number): ()
                        cfg["Padding"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        CardCorner = Spotify:CreateSlider({
                ["Name"] = 'Card Corner',
                ["Min"] = 0,
                ["Max"] = 30,
                ["Default"] = cfg["Corner"],
                ["Function"] = function(val: number): ()
                        cfg["Corner"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        CoverCorner = Spotify:CreateSlider({
                ["Name"] = 'Cover Corner',
                ["Min"] = 0,
                ["Max"] = 30,
                ["Default"] = cfg["CoverCorner"],
                ["Function"] = function(val: number): ()
                        cfg["CoverCorner"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        TitleSize = Spotify:CreateSlider({
                ["Name"] = 'Title Size',
                ["Min"] = 8,
                ["Max"] = 28,
                ["Default"] = cfg["TitleSize"],
                ["Function"] = function(val: number): ()
                        cfg["TitleSize"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        TextSize = Spotify:CreateSlider({
                ["Name"] = 'Text Size',
                ["Min"] = 6,
                ["Max"] = 22,
                ["Default"] = cfg["TextSize"],
                ["Function"] = function(val: number): ()
                        cfg["TextSize"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        BarThickness = Spotify:CreateSlider({
                ["Name"] = 'Bar Thickness',
                ["Min"] = 1,
                ["Max"] = 10,
                ["Default"] = cfg["BarThickness"],
                ["Function"] = function(val: number): ()
                        cfg["BarThickness"] = val;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        TitleFont = Spotify:CreateFont({
                ["Name"] = 'Title Font',
                ["Default"] = 'ArimoBold',
                ["Function"] = function(font: Font): ()
                        vTitle["FontFace"] = font;
                end,
                ["Visible"] = false;
        });
        ArtistFont = Spotify:CreateFont({
                ["Name"] = 'Artist Font',
                ["Default"] = 'Arimo',
                ["Function"] = function(font: Font): ()
                        vArtist["FontFace"] = font;
                end,
                ["Visible"] = false;
        });
        TimeFont = Spotify:CreateFont({
                ["Name"] = 'Time Font',
                ["Default"] = 'Arimo',
                ["Function"] = function(font: Font): ()
                        vCurrent["FontFace"] = font;
                        vMax["FontFace"] = font;
                end,
                ["Visible"] = false;
        });
        ShowCover = Spotify:CreateToggle({
                ["Name"] = 'Show Cover',
                ["Default"] = cfg["ShowCover"],
                ["Function"] = function(callback: boolean): ()
                        cfg["ShowCover"] = callback;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        ShowTimes = Spotify:CreateToggle({
                ["Name"] = 'Show Times',
                ["Default"] = cfg["ShowTimes"],
                ["Function"] = function(callback: boolean): ()
                        cfg["ShowTimes"] = callback;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        ShowProgress = Spotify:CreateToggle({
                ["Name"] = 'Show Progress',
                ["Default"] = cfg["ShowBar"],
                ["Function"] = function(callback: boolean): ()
                        cfg["ShowBar"] = callback;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        RoundBar = Spotify:CreateToggle({
                ["Name"] = 'Round Bar',
                ["Default"] = cfg["RoundBar"],
                ["Function"] = function(callback: boolean): ()
                        cfg["RoundBar"] = callback;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        ByPrefix = Spotify:CreateToggle({
                ["Name"] = 'By Prefix',
                ["Default"] = cfg["ByPrefix"],
                ["Function"] = function(callback: boolean): ()
                        cfg["ByPrefix"] = callback;
                        setTrackText(lastTitle, lastArtists);
                end,
                ["Visible"] = false;
        });
        Shadow = Spotify:CreateToggle({
                ["Name"] = 'Shadow',
                ["Function"] = function(callback: boolean): ()
                        cfg["Shadow"] = callback;
                        layoutCard();
                end,
                ["Visible"] = false;
        });
        CardBorder = Spotify:CreateToggle({
                ["Name"] = 'Card Border',
                ["Function"] = function(callback: boolean): ()
                        cfg["Border"] = callback;
                        layoutCard();
                        CardBorderColor["Object"]["Visible"] = callback and currentStyle == 'Velocity';
                        BorderThickness["Object"]["Visible"] = callback and currentStyle == 'Velocity';
                end,
                ["Visible"] = false;
        });
        CardBorderColor = Spotify:CreateColorSlider({
                ["Name"] = 'Card Border Color',
                ["DefaultHue"] = 0,
                ["DefaultSat"] = 109 / 251,
                ["DefaultValue"] = 251 / 255,
                ["Function"] = function(hue: number, sat: number, val: number, opacity: number): ()
                        cardStroke["Color"] = Color3["fromHSV"](hue, sat, val);
                        cardStroke["Transparency"] = 1 - opacity;
                end,
                ["Darker"] = true,
                ["Visible"] = false;
        });
        BorderThickness = Spotify:CreateSlider({
                ["Name"] = 'Border Thickness',
                ["Min"] = 1,
                ["Max"] = 6,
                ["Default"] = 1,
                ["Function"] = function(val: number): ()
                        cardStroke["Thickness"] = val;
                end,
                ["Darker"] = true,
                ["Visible"] = false;
        });
        applyTheme();
        layoutCard();
        updateVisibility();

        do
                local blockSize: number = 64;
                local xor_with_0x5c: {[string]: string} = {};
                local xor_with_0x36: {[string]: string} = {};

                for i: number = 0, 255 do
                        xor_with_0x5c[string["char"](i)] = string["char"](bit32["bxor"](0x5c, i));
                        xor_with_0x36[string["char"](i)] = string["char"](bit32["bxor"](0x36, i));
                end;

                local numberToByteString: (number: number) -> string = function(number: number): string
                        local bytes: {string} = {};
                        while number ~= 0 do
                                table["insert"](bytes, string["char"](bit32["band"](number, 0xff)));
                                number = bit32["rshift"](number, 8);
                        end;

                        return string["rep"]('\0', math["max"](0, 8 - #bytes)) .. table["concat"](bytes, ''):reverse();
                end;

                local randomHexString: () -> string = function(): string
                        local data: {string} = table["create"](20);
                        for i: number = 1, 20 do
                                data[i] = string["format"]('%02x', math["random"]() * 255);
                        end;
                        return table["concat"](data);
                end;

                local hex_to_binary: (hex: string) -> string = function(hex: string): string
                        return (hex:gsub('..', function(num: string): string
                                return string["char"](tonumber(num, 16));
                        end));
                end;

                local hmac: (key: string, text: string) -> string = function(key: string, text: string): string
                        if #key > blockSize then
                                key = hex_to_binary(hash["sha1"](key));
                        end;

                        local key_xord_with_0x36: string = key:gsub('.', xor_with_0x36) .. string["rep"](string["char"](0x36), blockSize - #key);
                        local key_xord_with_0x5c: string = key:gsub('.', xor_with_0x5c) .. string["rep"](string["char"](0x5c), blockSize - #key);

                        return hex_to_binary(hash["sha1"](key_xord_with_0x5c .. hex_to_binary(hash["sha1"](key_xord_with_0x36 .. text))));
                end;

                local readURLAndConfig: (code: string) -> (string?, any) = function(code: string): (string?, any)
                        local appCfg: number? = code:find('appServerConfig\" type=\"text\/plain\">');
                        return code:match('(https://[^"\']+/web%-player%.[0-9a-f]+%.js)'), appCfg and httpService:JSONDecode((base64decode or (crypt and crypt["base64decode"]) or base64_decode)(code:sub(appCfg + 35, code:find('<', appCfg + 1) - 1))) or nil;
                end;

                local readOTPCodes: (code: string) -> (string?, number?) = function(code: string): (string?, number?)
                        local secret: number? = code:find("{secret:'");
                        if secret then
                                local version: number? = code:find('%,version', secret + 1);
                                local endbracket: number? = code:find('}', version + 1);
                                local otpCode: string = code:sub(secret + 9, version - 2);
                                local hashedOtp: {number} = table["create"](#otpCode);
                                for i: number = 1, #otpCode do
                                        hashedOtp[i] = bit32["bxor"](string["byte"](otpCode:sub(i, i)), (i - 1) % 33 + 9);
                                end;

                                return table["concat"](hashedOtp, ''), tonumber(code:sub(version + 9, endbracket - 1));
                        end;

                        return nil, nil;
                end;

                local readFetchHash: (code: string) -> string? = function(code: string): string?
                        local query: number? = code:find('fetchEntitiesForRecentlyPlayed","query",');
                        local ending: number? = code:find('",null', query);
                        return if query and ending then code:sub(query + 41, ending - 1) else nil;
                end;

                local stringToBytes: (str: string) -> {number} = function(str: string): {number}
                        local bytes: {number} = table["create"](#str);
                        for i: number = 1, #str do
                                bytes[i] = string["byte"](str:sub(i, i));
                        end;

                        return bytes;
                end;

                local safeRequest: (...any) -> Response = function(...: any): Response
                        local success: boolean, req: any = pcall(request, ...);
                        return success and req or {["Success"] = false, ["Body"] = req};
                end;

                local generateOTP: (input: number, secret: string) -> string = function(input: number, secret: string): string
                        local hash: string = hmac(secret, numberToByteString(input));
                        local offset: number = bit32["band"](string["byte"](hash:sub(-1, -1)), 0x0f) + 1;
                        local bHash: {number} = stringToBytes(hash);

                        local code: number = bit32["bor"](
                                bit32["lshift"](bit32["band"](bHash[offset], 0x7f), 24),
                                bit32["lshift"](bit32["band"](bHash[offset + 1], 0xff), 16),
                                bit32["lshift"](bit32["band"](bHash[offset + 2], 0xff), 8),
                                bit32["lshift"](bit32["band"](bHash[offset + 3], 0xff), 0)
                        );

                        local str_code: string = tostring(math["floor"](code % (10 ^ 6)));
                        while #str_code < 6 do
                                str_code = '0' .. str_code;
                        end;

                        return str_code;
                end;

                local toImageUrl: (uri: string?) -> string? = function(uri: string?): string?
                        if not uri or uri == '' then
                                return nil;
                        end;

                        local imageId: string? = uri:match('^spotify:image:(%w+)$');
                        if imageId then
                                return 'https://i.scdn.co/image/' .. imageId;
                        end;

                        return if uri:find('^https?://') then uri else nil;
                end;

                local coverToken: number = 0;
                local lastCoverPath: string? = nil;
                local setCover: (url: string?) -> () = function(url: string?): ()
                        coverToken += 1;
                        local token: number = coverToken;

                        if not url then
                                cover["Image"] = '';
                                return;
                        end;

                        local path: string = 'velo/cache/spotify_' .. (url:match('(%w+)$') or tostring(token)) .. '.png';
                        task["spawn"](function(): ()
                                if not isfile(path) then
                                        local res: Response = safeRequest({
                                                ["Url"] = url,
                                                ["Method"] = 'GET';
                                        });

                                        if not res["Success"] or token ~= coverToken then
                                                return;
                                        end;

                                        writefile(path, res["Body"]);
                                end;

                                if token ~= coverToken then
                                        return;
                                end;

                                local ok: boolean, asset: any = pcall(assetfunction, path);
                                if ok and type(asset) == 'string' then
                                        cover["Image"] = asset;
                                end;

                                if lastCoverPath and lastCoverPath ~= path and delfile and isfile(lastCoverPath) then
                                        pcall(delfile, lastCoverPath);
                                end;

                                lastCoverPath = path;
                        end);
                end;

                spotifyHandler["Callback"] = function(self: SpotifyHandlerT, data: any): ()
                        local state: any = data["player_state"];
                        if state then
                                local currentTime: number = (data["timestamp"] / 1000);
                                local posAsTime: number = tonumber(state["position_as_of_timestamp"]) / 1000;
                                local diff: number = currentTime - (tonumber(state["timestamp"]) / 1000);
                                self["playPosition"] = posAsTime + (state["is_paused"] and 0 or diff);
                                self["playRate"] = state["playback_speed"];
                                self["playDuration"] = tonumber(state["duration"] or 1000) / 1000;

                                local track: any = state["track"];
                                if track then
                                        self:RequestCache(track["uri"], track);
                                        self["track"] = track["uri"];

                                        local entry: CacheEntry = self["Cache"][self["track"]];
                                        local meta: any = track["metadata"] or {};
                                        setTrackText(meta["title"] or entry["Title"], entry["Artists"]);

                                        local coverUrl: string? = toImageUrl(meta["image_large_url"] or meta["image_url"] or meta["image_xlarge_url"] or meta["image_small_url"]) or entry["Cover"];
                                        if coverUrl ~= self["coverUrl"] then
                                                self["coverUrl"] = coverUrl;
                                                setCover(coverUrl);
                                        end;
                                end;
                        end;
                end;

                spotifyHandler["Refresh"] = function(self: SpotifyHandlerT): AuthData
                        local mainPage: Response = safeRequest({
                                ["Url"] = 'https://open.spotify.com',
                                ["Method"] = 'GET',
                                ["Headers"] = self["Headers"];
                        });

                        if mainPage["Success"] then
                                local scriptUrl: string?, appCfg: any = readURLAndConfig(mainPage["Body"]);

                                if scriptUrl and appCfg then
                                        local scriptCode: Response = safeRequest({
                                                ["Url"] = scriptUrl,
                                                ["Method"] = 'GET',
                                                ["Headers"] = self["Headers"];
                                        });

                                        if scriptCode["Success"] then
                                                local fetchKey: string? = readFetchHash(scriptCode["Body"]);
                                                local otpCode: string?, version: number? = readOTPCodes(scriptCode["Body"]);

                                                if otpCode and version then
                                                        local localKey: string = generateOTP(os["time"]() // 30, otpCode);
                                                        local serverKey: string = generateOTP(appCfg["serverTime"] // 30, otpCode);
                                                        local authData: Response = safeRequest({
                                                                ["Url"] = 'https://open.spotify.com/api/token?reason=init&productType=web-player&totp='..localKey..'&totpServer='..serverKey..'&totpVer='..version,
                                                                ["Method"] = 'GET',
                                                                ["Headers"] = self["Headers"];
                                                        });

                                                        if authData["Success"] then
                                                                local authJson: any = httpService:JSONDecode(authData["Body"]);

                                                                return {
                                                                        ["clientId"] = authJson["clientId"],
                                                                        ["clientVersion"] = appCfg["clientVersion"],
                                                                        ["correlationId"] = appCfg["correlationId"],
                                                                        ["fetchKey"] = fetchKey,
                                                                        ["accessToken"] = authJson["accessToken"],
                                                                        ["expireTime"] = authJson["accessTokenExpirationTimestampMs"] / 1000;
                                                                };
                                                        else
                                                                error('Failed to get auth data: '..authData["Body"]);
                                                        end;
                                                else
                                                        error('Failed to get OTP codes');
                                                end;
                                        else
                                                error('Failed to get script data: '..scriptCode["Body"]);
                                        end;
                                else
                                        error('Failed to get script url or app config.');
                                end;
                        else
                                error('Failed to get main page: '..mainPage["Body"]);
                        end;
                end;

                spotifyHandler["GetSession"] = function(self: SpotifyHandlerT): string
                        local sessionData: Response = safeRequest({
                                ["Url"] = 'https://clienttoken.spotify.com/v1/clienttoken',
                                ["Method"] = 'POST',
                                ["Headers"] = {
                                        ["Accept"] = 'application/json',
                                        ['Content-Type'] = 'application/json',
                                        ["Origin"] = 'https://open.spotify.com',
                                        ["Referer"] = 'https://open.spotify.com/',
                                        ['User-Agent'] = self["Headers"]['User-Agent'];
                                },
                                ["Body"] = httpService:JSONEncode({
                                        ["client_data"] = {
                                                ["client_id"] = self["Data"]["clientId"],
                                                ["client_version"] = self["Data"]["clientVersion"],
                                                ["js_sdk_data"] = {
                                                        ["device_brand"] = 'unknown',
                                                        ["device_id"] = self["Data"]["correlationId"],
                                                        ["device_model"] = 'unknown',
                                                        ["device_type"] = 'computer',
                                                        ["os"] = 'windows',
                                                        ["os_version"] = 'NT 10.0';
                                                };
                                        };
                                });
                        });

                        if sessionData["Success"] then
                                local sessionJson: any = httpService:JSONDecode(sessionData["Body"]);
                                return sessionJson["granted_token"]["token"];
                        else
                                error('Failed to get device session: '..sessionData["Body"]);
                        end;
                end;

                spotifyHandler["RequestCache"] = function(self: SpotifyHandlerT, id: string, data: any): ()
                        if not self["Cache"][id] then
                                self["Cache"][id] = {["Artists"] = {'None'}, ["Title"] = 'Unknown'};

                                if id:find('spotify:local') then
                                        local lArtist: string = data["metadata"]["artist_uri"]:sub(15);
                                        self["Cache"][id]["Artists"] = {lArtist ~= '' and lArtist or 'None'};
                                        return;
                                end;

                                if self["Data"]["fetchKey"] then
                                        task["spawn"](function(): ()
                                                local dataRequest: Response = safeRequest({
                                                        ["Url"] = 'https://api-partner.spotify.com/pathfinder/v2/query',
                                                        ["Method"] = 'POST',
                                                        ["Headers"] = {
                                                                ["Accept"] = 'application/json',
                                                                ["Authorization"] = 'Bearer '..self["Data"]["accessToken"],
                                                                ['Content-Type'] = 'application/json',
                                                                ['client-token'] = self["clientToken"],
                                                                ["Origin"] = 'https://open.spotify.com',
                                                                ["Referer"] = 'https://open.spotify.com/',
                                                                ['User-Agent'] = self["Headers"]['User-Agent'];
                                                        },
                                                        ["Body"] = httpService:JSONEncode({
                                                                ["extensions"] = {
                                                                        ["persistedQuery"] = {
                                                                                ["sha256Hash"] = self["Data"]["fetchKey"],
                                                                                ["version"] = 1;
                                                                        };
                                                                },
                                                                ["variables"] = {
                                                                        ["uris"] = {id};
                                                                },
                                                                ["operationName"] = 'fetchEntitiesForRecentlyPlayed';
                                                        });
                                                });

                                                if dataRequest["Success"] then
                                                        local data: any = httpService:JSONDecode(dataRequest["Body"]);
                                                        local track: any = data["data"]["lookup"][1];

                                                        if track and track["data"] then
                                                                table["clear"](self["Cache"][id]["Artists"]);

                                                                if track["data"]["__typename"] == 'Track' then
                                                                        self["Cache"][id]["Title"] = track["data"]["name"];
                                                                        for _: number, artist: any in track["data"]["artists"]["items"] do
                                                                                table["insert"](self["Cache"][id]["Artists"], artist["profile"]["name"]);
                                                                        end;
                                                                elseif track["data"]["__typename"] == 'Episode' then
                                                                        table["insert"](self["Cache"][id]["Artists"], track["data"]["podcastV2"]["data"]["publisher"]["name"]);
                                                                end;

                                                                local foundCover: boolean, coverSource: any = pcall(function(): any
                                                                        local art: any = track["data"]["albumOfTrack"] and track["data"]["albumOfTrack"]["coverArt"] or track["data"]["coverArt"];
                                                                        return art and art["sources"] and art["sources"][1] and art["sources"][1]["url"];
                                                                end);

                                                                if foundCover and type(coverSource) == 'string' then
                                                                        self["Cache"][id]["Cover"] = coverSource;
                                                                end;

                                                                if self["track"] == id then
                                                                        setTrackText(self["Cache"][id]["Title"], self["Cache"][id]["Artists"]);

                                                                        if not self["coverUrl"] and self["Cache"][id]["Cover"] then
                                                                                self["coverUrl"] = self["Cache"][id]["Cover"];
                                                                                setCover(self["coverUrl"]);
                                                                        end;
                                                                end;
                                                        end;
                                                end;
                                        end);
                                end;
                        end;
                end;

                spotifyHandler["RegisterDevice"] = function(self: SpotifyHandlerT, connectionId: string): ()
                        if not self["connectionId"] then
                                self["connectionId"] = connectionId;

                                local sessionId: string = randomHexString();
                                local deviceReq: Response = safeRequest({
                                        ["Url"] = 'https://'..self["Dealer"]["Client"]..'/track-playback/v1/devices',
                                        ["Method"] = 'POST',
                                        ["Headers"] = {
                                                ["Authorization"] = 'Bearer '..self["Data"]["accessToken"],
                                                ['Content-Type'] = 'application/json',
                                                ['client-token'] = self["clientToken"],
                                                ["Origin"] = 'https://open.spotify.com',
                                                ["Referer"] = 'https://open.spotify.com/',
                                                ['User-Agent'] = self["Headers"]['User-Agent'];
                                        },
                                        ["Body"] = httpService:JSONEncode({
                                                ["device"] = {
                                                        ["brand"] = 'spotify',
                                                        ["capabilities"] = {
                                                                ["change_volume"] = true,
                                                                ["enable_play_token"] = true,
                                                                ["supports_file_media_type"] = true,
                                                                ["play_token_lost_behavior"] = 'pause',
                                                                ["disable_connect"] = false,
                                                                ["audio_podcasts"] = true,
                                                                ["video_playback"] = true,
                                                                ["manifest_formats"] = {
                                                                        'file_ids_mp3',
                                                                        'file_urls_mp3',
                                                                        'manifest_urls_audio_ad',
                                                                        'manifest_ids_video',
                                                                        'file_urls_external',
                                                                        'file_ids_mp4',
                                                                        'file_ids_mp4_dual',
                                                                        'manifest_urls_audio_ad';
                                                                },
                                                                ["supports_preferred_media_type"] = true,
                                                                ["supports_playback_offsets"] = true,
                                                                ["supports_playback_speed"] = true;
                                                        },
                                                        ["device_id"] = sessionId,
                                                        ["device_type"] = 'computer',
                                                        ["metadata"] = {},
                                                        ["model"] = 'web_player',
                                                        ["name"] = 'Web Player (Firefox)',
                                                        ["platform_identifier"] = 'web_player windows 10;firefox 158.0;desktop',
                                                        ["is_group"] = false,
                                                        ["is_public"] = false,
                                                        ["correlation_id"] = self["Data"]["correlationId"],
                                                        ["client_version"] = 'harmony:4.81.1-1f3d48b7f';
                                                },
                                                ["outro_endcontent_snooping"] = false,
                                                ["connection_id"] = self["connectionId"],
                                                ["client_version"] = 'harmony:4.81.1-1f3d48b7f',
                                                ["volume"] = 65535;
                                        }):gsub('"metadata":%[%]', '"metadata":{}');
                                });

                                if deviceReq["Success"] then
                                        local registerReq: Response = safeRequest({
                                                ["Url"] = 'https://'..self["Dealer"]["Client"]..'/connect-state/v1/devices/hobs_'..sessionId,
                                                ["Method"] = 'PUT',
                                                ["Headers"] = {
                                                        ["Accept"] = 'application/json',
                                                        ["Authorization"] = 'Bearer '..self["Data"]["accessToken"],
                                                        ['client-token'] = self["clientToken"],
                                                        ["Origin"] = 'https://open.spotify.com',
                                                        ["Referer"] = 'https://open.spotify.com/',
                                                        ['x-spotify-connection-id'] = self["connectionId"],
                                                        ['User-Agent'] = self["Headers"]['User-Agent'];
                                                },
                                                ["Body"] = httpService:JSONEncode({
                                                        ["member_type"] = 'CONNECT_STATE',
                                                        ["device"] = {
                                                                ["device_info"] = {
                                                                        ["capabilities"] = {
                                                                                ["can_be_player"] = false,
                                                                                ["hidden"] = true,
                                                                                ["needs_full_player_state"] = true;
                                                                        };
                                                                };
                                                        };
                                                });
                                        });

                                        if registerReq["Success"] then
                                                self:Callback(httpService:JSONDecode(registerReq["Body"]));
                                        else
                                                notif('Spotify', 'Failed to register device: '..registerReq["Body"], 30, 'alert');
                                        end;
                                else
                                        notif('Spotify', 'Failed to register device: '..deviceReq["Body"], 30, 'alert');
                                end;
                        end;
                end;

                spotifyHandler["RegisterSocket"] = function(self: SpotifyHandlerT): ()
                        if not self["Dealer"] then
                                local dealerReq: Response = safeRequest({
                                        ["Url"] = 'https://apresolve.spotify.com/?type=dealer-g2&type=spclient',
                                        ["Method"] = 'GET',
                                        ["Headers"] = {
                                                ["Origin"] = 'https://open.spotify.com',
                                                ["Referer"] = 'https://open.spotify.com/',
                                                ['User-Agent'] = self["Headers"]['User-Agent'];
                                        };
                                });

                                if dealerReq["Success"] then
                                        local dealerJson: any = httpService:JSONDecode(dealerReq["Body"]);

                                        if dealerJson['dealer-g2'][1] and dealerJson["spclient"][1] then
                                                self["Dealer"] = {
                                                        ["Dealer"] = dealerJson['dealer-g2'][1]:sub(1, dealerJson['dealer-g2'][1]:find(':') - 1),
                                                        ["Client"] = dealerJson["spclient"][1]:sub(1, dealerJson["spclient"][1]:find(':') - 1);
                                                };
                                        else
                                                notif('Spotify', 'No available dealers', 30, 'alert');
                                                return;
                                        end;
                                else
                                        notif('Spotify', 'Failed to get dealers: '..dealerReq["Body"], 30, 'alert');
                                        return;
                                end;
                        end;

                        self["Socket"] = WebSocket["connect"]('wss://'..self["Dealer"]["Dealer"]..'/?access_token='..self["Data"]["accessToken"]);
                        self["syncTime"] = os["clock"]() - 6;

                        self["Socket"]["OnMessage"]:Connect(function(rawPayload: string): ()
                                local payload: any = httpService:JSONDecode(rawPayload);

                                if payload["headers"] and payload["headers"]['Spotify-Connection-Id'] then
                                        self["syncTime"] = nil;
                                        self:RegisterDevice(payload["headers"]['Spotify-Connection-Id']);
                                elseif payload["payloads"] and #payload["payloads"] > 0 then
                                        for _: number, data: any in payload["payloads"] do
                                                if data["cluster"] and data["cluster"]["player_state"] then
                                                        self:Callback(data["cluster"]);
                                                        break;
                                                end;
                                        end;
                                elseif payload["type"] == 'pong' then
                                        self["syncTime"] = nil;
                                end;
                        end);

                        self["Socket"]["OnClose"]:Connect(function(): ()
                                self["connectionId"] = nil;
                                self["syncTime"] = nil;
                                self["Socket"] = nil;
                        end);
                end;

                spotifyHandler["Start"] = function(self: SpotifyHandlerT): ()
                        local cookiePath: string = 'velo/profiles/spotify.txt';
                        if not isfile(cookiePath) then
                                writefile(cookiePath, '');
                        end;

                        local cookie: string = (readfile(cookiePath) or ''):gsub('%s+', ''):gsub('^sp_dc=', ''):gsub(';$', '');
                        if cookie == '' then
                                notif('Spotify', 'Paste your sp_dc cookie into velo/profiles/spotify.txt, then toggle Spotify again.', 30, 'warning');
                                return;
                        end;

                        if isfolder and makefolder and not isfolder('velo/cache') then
                                makefolder('velo/cache');
                        end;

                        self["Headers"] = {
                                ["Cookie"] = 'sp_dc='..cookie..';',
                                ['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:158.0) Gecko/20100101 Firefox/158.0';
                        };

                        local data: any = isfile('velo/profiles/spotifydata.txt') and httpService:JSONDecode(readfile('velo/profiles/spotifydata.txt')) or {["expireTime"] = 0};
                        if data["expireTime"] > os["time"]() then
                                self["Data"] = data;
                        else
                                notif('Spotify', 'Authenticating...', 10, 'info');

                                local success: boolean;
                                success, data = pcall(function(): AuthData
                                        return self:Refresh();
                                end);

                                if success then
                                        notif('Spotify', 'Logged in!', 10, 'info');
                                        writefile('velo/profiles/spotifydata.txt', httpService:JSONEncode(data));
                                        self["Data"] = data;
                                else
                                        notif('Spotify', data, 10, 'alert');
                                        return;
                                end;
                        end;

                        if not self["clientToken"] then
                                local success: boolean, deviceToken: any = pcall(function(): string
                                        return self:GetSession();
                                end);

                                if success then
                                        self["clientToken"] = deviceToken;
                                else
                                        notif('Spotify', deviceToken, 10, 'alert');
                                        return;
                                end;
                        end;

                        self:RegisterSocket();
                        local pingCooldown: number = os["clock"]() + 30;

                        repeat
                                local delta: number = task["wait"](0.1);

                                if self["Socket"] then
                                        if self["syncTime"] and (os["clock"]() - self["syncTime"]) > 10 then
                                                pingCooldown = os["clock"]() + 30;
                                                self["Socket"]:Close();
                                                self["Socket"]["OnClose"]:Wait();
                                                self:RegisterSocket();
                                        elseif pingCooldown < os["clock"]() then
                                                self["Socket"]:Send('{"type":"ping"}');
                                                self["syncTime"] = os["clock"]();
                                                pingCooldown = os["clock"]() + 30;
                                        end;

                                        if self["playPosition"] then
                                                self["playPosition"] = math["clamp"](self["playPosition"] + (delta * self["playRate"]), 0.01, self["playDuration"]);
                                                local percent: number = self["playPosition"] / self["playDuration"];
                                                duration["Text"] = formatTime(self["playPosition"]);
                                                fill["Size"] = UDim2["fromScale"](percent, 1);
                                                vCurrent["Text"] = formatTime(self["playPosition"]);
                                                vMax["Text"] = formatTime(self["playDuration"]);
                                                vBarFill["Size"] = UDim2["fromScale"](percent, 1);
                                        end;
                                end;
                        until false;
                end;
        end;
end);
