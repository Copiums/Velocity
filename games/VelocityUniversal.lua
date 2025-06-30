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
repeat task.wait() until game:IsLoaded()
local velo: table = {};
local LoadTime: tick = tick()
local VelocityVersion: string = "V1.0"
local function HoverText(Text: string): void
	return Text .. " ";
end;

local loadstring: any = function(...)
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

local function downloadFile(path: string, func: any)
	if not isfile(path) then
		local suc: boolean, res: string? = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end);
		if not suc or res == '404: Not Found' then
			error(res);
		end;
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end;
		writefile(path, res);
	end;
	return (func or readfile)(path);
end;

local run = function(func : Function?)
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
local Debris: Debris = cloneref(game:GetService('Debris')); 
local proximitypromptService: ProximityPromptService = cloneref(game:GetService('ProximityPromptService'));
local coreGui: CoreGui = cloneref(game:GetService('CoreGui'));
local gameCamera: Camera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
local lplr: Player = playersService.LocalPlayer
local assetfunction: any = getcustomasset
local vapeConnections: any = {}
local vapeInjected: boolean = true;
local vapeStore: any = {Bindable = {}, raycast = RaycastParams.new(), MessageReceived = Instance.new('BindableEvent'), platform = inputService:GetPlatform()}
getgenv().vapeStore = vapeStore

local vape: table = shared.vape
local tween: any = vape.Libraries.tween
local targetinfo: any = vape.Libraries.targetinfo
local getfontsize: any = vape.Libraries.getfontsize
local getcustomasset: any = vape.Libraries.getcustomasset


local TargetStrafeVector: any, SpiderShift: any, WaypointFolder: any
local Spider: table = {["Enabled"] = false}
local Phase: tbale = {["Enabled"] = false}

local function addBlur(parent)
	local blur: ImageLabel = Instance.new('ImageLabel');
	blur.Name = 'Blur';
	blur.Size = UDim2.new(1, 89, 1, 52);
	blur.Position = UDim2.fromOffset(-48, -31);
	blur.BackgroundTransparency = 1;
	blur.Image = getcustomasset('newvape/assets/new/blur.png');
	blur.ScaleType = Enum.ScaleType.Slice;
	blur.SliceCenter = Rect.new(52, 31, 261, 502);
	blur.Parent = parent;
	return blur;
end;

local function GetItems(item: string): table
	local Items: table = {}
	for _, v in next, Enum[item]:GetEnumItems() do 
		table.insert(Items, v["Name"]);
	end;
	return Items;
end;

local function calculateMoveVector(vec: Vector3): Vector3
	local c: number, s: number;
	local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = gameCamera.CFrame:GetComponents();
	if R12 < 1 and R12 > -1 then
		c = R22;
		s = R02;
	else
		c = R00;
		s = -R01 * math.sign(R12);
	end;
	vec = Vector3.new((c * vec.X + s * vec.Z), 0, (c * vec.Z - s * vec.X)) / math.sqrt(c * c + s * s);
	return vec.Unit == vec.Unit and vec.Unit or Vector3.zero;
end;

local function isFriend(plr: Player, recolor: boolean): boolean?
	if vape.Categories.Friends.Options['Use friends']["Enabled"] then
		local friend: any = table.find(vape.Categories.Friends.ListEnabled, plr.Name) and true
		if recolor then
			friend = friend and vape.Categories.Friends.Options['Recolor visuals']["Enabled"];
		end;
		return friend;
	end;
	return nil;
end;

local function isTarget(plr: Player): boolean?
	return table.find(vape.Categories.Targets.ListEnabled, plr.Name) and true;
end;

local canClick: () -> nil = function()
	local mousepos: any = (inputService:GetMouseLocation() - guiService:GetGuiInset());
	for _: any, v: any in lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y) do
		local obj: ScreenGui? = v:FindFirstAncestorOfClass('ScreenGui')
		if v.Active and v.Visible and obj and obj["Enabled"] then
			return false;
		end;
	end;
	for _: any, v: any in coreGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y) do
		local obj: ScreenGui? = v:FindFirstAncestorOfClass('ScreenGui')
		if v.Active and v.Visible and obj and obj["Enabled"] then
			return false;
		end;
	end;
	return (not vape.gui.ScaledGui.ClickGui.Visible) and (not inputService:GetFocusedTextBox());
end;

local function getTableSize(tab: {[any]: any}): number
    local ind: number = 0;
    for _ in tab do
        ind += 1;
    end;
    return ind;
end;

local function getTool(): (any, any)
	return lplr.Character and lplr.Character:FindFirstChildWhichIsA('Tool', true) or nil;
end;

local function notif(...: any): void
    return vape:CreateNotification(...);
end;


local function removeTags(str: string): string
	str = str:gsub('<br%s*/>', '\n');
	return (str:gsub('<[^<>]->', ''));
end;

local visited: table, attempted: table, tpSwitch: boolean = {}, {}, false
local cacheExpire: number?, cache: any = tick()
local function serverHop(pointer: boolean?, filter: any): any
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
		for _, v in data.data do
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

local frictionTable: table, oldfrict: table, entitylib: any = {}, {}
local function updateVelocity(): (any, any)
	if getTableSize(frictionTable) > 0 then
		if entitylib.isAlive then
			for _, v in entitylib.character.Character:GetChildren() do
				if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' and not oldfrict[v] then
					oldfrict[v] = v.CustomPhysicalProperties or 'none';
					v.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.2, 0.5, 1, 1);
				end;
			end;
		end;
	else
		for i, v in oldfrict do
			i.CustomPhysicalProperties = v ~= 'none' and v or nil;
		end;
		table.clear(oldfrict);
	end;
end;

local hash: any = loadstring(downloadFile('newvape/libraries/hash.lua'), 'hash')()
local prediction: any = loadstring(downloadFile('newvape/libraries/prediction.lua'), 'prediction')()
entitylib = loadstring(downloadFile('newvape/libraries/entity.lua'), 'entitylib')()
local whitelist: table = {
	alreadychecked = {},
	customtags = {},
	data = {WhitelistedUsers = {}},
	hashes = setmetatable({}, {
		__index = function(_, v)
			return hash and hash.sha512(v..'SelfReport') or ''
		end
	}),
	hooked = false,
	loaded = false,
	localprio = 0,
	said = {}
};
vape.Libraries.entity = entitylib;
vape.Libraries.whitelist = whitelist;
vape.Libraries.prediction = prediction;
vape.Libraries.hash = hash;
vape.Libraries.auraanims = {
	Random = {},
	['Horizontal Spin'] = {
		{CFrame = CFrame.Angles(math.rad(-10), math.rad(-90), math.rad(-80)), Time = 0.12},
		{CFrame = CFrame.Angles(math.rad(-10), math.rad(180), math.rad(-80)), Time = 0.12},
		{CFrame = CFrame.Angles(math.rad(-10), math.rad(90), math.rad(-80)), Time = 0.12},
		{CFrame = CFrame.Angles(math.rad(-10), 0, math.rad(-80)), Time = 0.12}
	},
	["Normal"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
	},
	["Slow"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
	},
	["New"] = {
		{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
		{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
	},
	["Latest"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
	},
	['Vertical Spin'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
	},
	['Exhibition'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
	['Exhibition Old'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
	},
	['Old Extend'] = {
		{CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.1},
		{CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
		{CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.01},
		{CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
		{CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07}
	},
	['Horizontal Spin'] = {
		{CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-80)), Time = 0.14},
		{CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(-100)), Time = 0.14},
		{CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(180), math.rad(-100)), Time = 0.14},
		{CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(270), math.rad(-80)), Time = 0.14}
	},
	['BlockHit'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
		{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
	},
	["Moon"] = {
		{CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.48},
		{CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.33},
		{CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.33}
	},
	['Rise'] = {
		{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
		{CFrame = CFrame.new(0.5, 0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
	},
	['Jab'] = {
		{CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.6, -0.6, 0.5) * CFrame.Angles(math.rad(-45), math.rad(50), math.rad(-105)), Time = 0.1}
	},
	['Exhibition2'] = {
		{CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-80)), Time = 0.12},
		{CFrame = CFrame.new(1, 0, -0.3) * CFrame.Angles(math.rad(-80), math.rad(40), math.rad(-60)), Time = 0.16}
	},
	['Smooth'] = {
		{CFrame = CFrame.new(1, 0, -0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
		{CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
	},
	['Butter'] = {
		{CFrame = CFrame.new(3.0, -1.7, -1.1) * CFrame.Angles(math.rad(307), math.rad(57), math.rad(145)), Time = 0.18},
		{CFrame = CFrame.new(3.0, -1.7, -1.3) * CFrame.Angles(math.rad(203), math.rad(57), math.rad(226)), Time = 0.14}
	},
	['Slash'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
		{CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
	},
	['Slide'] = {
		{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
		{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3},
		{CFrame = CFrame.new(0.2, -1, -10) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.0},
		{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
		{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3}
	},
	['Swong'] = {
		{CFrame = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
		{CFrame = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2}
	},
	['Kill X'] = {
		{CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(140), math.rad(53)), Time = 0.12},
		{CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(45), math.rad(53)), Time = 0.12}
	},
	['Stab'] = {
		{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.1, Size = 2},
		{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(90), math.rad(-81)), Time = 0.1, Size = 5}
	},
	['Exhibition vertical spin'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
	},
	['LiquidBounce'] = {
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
	},
	['OddSwing'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
		{CFrame = CFrame.new(0.03, 0.07, -0.07) * CFrame.Angles(math.rad(-20), math.rad(-2), math.rad(-8)), Time = 0.15}
	},
	['Sigma'] = {
		{CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
		{CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
		{CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
	},
	['SigmaJello'] = {
		{CFrame = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.18},
		{CFrame = CFrame.new(0, -0.2, -1.7) * CFrame.Angles(math.rad(30), math.rad(111), math.rad(190)), Time = 0.18}
	},
	['Drop'] = {
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19}
	},
	['Cookless'] = {
		{CFrame = CFrame.new(2, -2.5, 0.2) * CFrame.Angles(math.rad(268), math.rad(54), math.rad(327)), Time = 0.17},
		{CFrame = CFrame.new(1.6, -2.5, 0.2) * CFrame.Angles(math.rad(189), math.rad(52), math.rad(347)), Time = 0.16}
	},
	['Roll'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(100)), Time = 0.2}
	},
	['Shrink'] = {
		{CFrame = CFrame.new(0.3, 0, 0) * CFrame.Angles(math.rad(-2), math.rad(5), math.rad(25)), Time = 0.2},
		{CFrame = CFrame.new(0.69, -0.71, 0.6), Time = 0.2}
	},
	['Push'] = {
		{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
		{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
	},
	['Flat'] = {
		{CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(-30), math.rad(-80)), Time = 0.15},
		{CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(30), math.rad(-100)), Time = 0.15}
	},
	['Dortware'] = {
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
		{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.8},
		{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(80), math.rad(90)), Time = 1.2},
		{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6},
		{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6}
	},
	['Template'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
		{CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
	},
	['Hamsterware'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-135)), Time = 0.1}
	},
	['CatV5'] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
	['Astral2'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
	},
	['Leaked'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(16), math.rad(59), math.rad(-90)), Time = 0.15}
	},
	['Slide3'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
	},
	['Femboy'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
		{CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
	},
	['MontCostume'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.58) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.17},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
	},
	['fdp slow'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.90},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.50}
	},
	['swong'] = {
		{CFrame = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1, RealDelay = 0.1},
		{CFrame = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2, RealDelay = 0.2}
	},
	['Blochit'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15, RealDelay = 0.15},
		{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15, RealDelay = 0.15}
	},
	['Future2'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.90},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.90},
	},
	['rise'] = {
		{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14, RealDelay = 0.14},
		{CFrame = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14, RealDelay = 0.14}			
	},
	['mine (rel)'] = {
		{CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.3},
		{CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15}
		
	},
	['jab'] = {
		{CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.6, -0.6, 0.5) * CFrame.Angles(math.rad(-45), math.rad(50), math.rad(-105)), Time = 0.1},					
	},
	['VAPE OLD'] = {
		{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.07, Size = 2},
		{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(90), math.rad(-81)), Time = 0.06, Size = 5},
	},
	['meelkware'] = {
		{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.02, Size = 2},
		{CFrame = CFrame.new(0.69, -0.77 + 2, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.02, Size = 2},
		{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.02, Size = 2},
	},
	['pistonware blue'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(40), math.rad(55), math.rad(290)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(40), math.rad(70), math.rad(1)), Time = 0.15}
	},
	['idk'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(304)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(90), math.rad(304)), Time = 0.15}
	},
	['YourMom'] = {
		{CFrame = CFrame.new(0.67, -0.68, 0.62) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-80)), Time = 0.12},
		{CFrame = CFrame.new(0.72, -0.72, 0.6) * CFrame.Angles(math.rad(-94), math.rad(70), math.rad(-28)), Time = 0.26}
	},
	['ZeroPrime'] = {
		{CFrame = CFrame.new(0.7, -0.89, 0.6) * CFrame.Angles(math.rad(-45), math.rad(47), math.rad(-77)), Time = 0.14},
		{CFrame = CFrame.new(0.67, -0.66, 0.59) * CFrame.Angles(math.rad(-76), math.rad(50), math.rad(-37)), Time = 0.26}
	},
	['DortVersion2'] = {
		{CFrame = CFrame.new(0.72, -0.67, 0.68) * CFrame.Angles(math.rad(-35), math.rad(45), math.rad(-84)), Time = 0.12},
		{CFrame = CFrame.new(0.68, -0.74, 0.53) * CFrame.Angles(math.rad(-80), math.rad(50), math.rad(-35)), Time = 0.24}
	},
	['SlowSwordThrowAnim'] = {
		{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(270)), Time = 0.1},
		{CFrame = CFrame.new(3, 3, 3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(180)), Time = 0.1},
	   
	},
	['SwordThrowAnim'] = {
		{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(270)), Time = 0.3},
		{CFrame = CFrame.new(3, 3, 3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(180)), Time = 0.3},
	},
	  
	['FastSwordThrowAnim'] = {
		{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(270)), Time = 0.5},
		{CFrame = CFrame.new(3, 3, 3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(180)), Time = 0.5},
	},
	['SlowAndFast'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.8},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.01}
	},
	['SkidWare'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(65), math.rad(-79)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(35), math.rad(-56)), Time = 0.2}
	},
	['Monsoon'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), Time = 0.07},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), Time = 0.13}
	},
	['N1san1StopFuckingAnnoyingMe'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19}
	},
	['Spooky'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(54), math.rad(-56)), Time = 0.08},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(38), math.rad(-23)), Time = 0.15}
	},
	['SkidWare New'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(98), math.rad(-354)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(65), math.rad(-68)), Time = 0.2}
	},
	['Kys'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(50), math.rad(50), math.rad(100)), Time = 0.3},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(84), math.rad(50), math.rad(50)), Time = 0.3}
	},
	['Astral'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.900},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
	},
	['xarq0n1'] = {
		{CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(-math.rad(120), math.rad(530), -math.rad(220)), Time = 0.2},
		{CFrame = CFrame.new(0.9, 0, 1.5) * CFrame.Angles(math.rad(7), math.rad(30), math.rad(820)), Time = 0.2}
	},
	['xarq0n2'] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(190)), Time = 0.8},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(40), math.rad(1)), Time = 0.8}
	},
	['xarq0n3'] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(195), math.rad(95), math.rad(130)), Time = 0.1},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(300), math.rad(40), math.rad(1)), Time = 0.2}
	},
	['Swiss'] = {
		{CFrame = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
		{CFrame = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
	},
	['SlowSwiss'] = {
		{CFrame = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.25},
		{CFrame = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.25}
	},
	['OldAstralAnim'] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.1}
	},
	['SlowOldAstralAnim'] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.4},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.4}
	},
	['ZylaAnim'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
	['SliceAnim'] = {
		{CFrame = CFrame.new(3, -4, 3) * CFrame.Angles(math.rad(90), math.rad(90), math.rad(90)), Time = 0.2},
		{CFrame = CFrame.new(-4, 3, -4) * CFrame.Angles(math.rad(111), math.rad(222), math.rad(333)), Time = 0.2}
	},
	['SlowSliceAnim'] = {
		{CFrame = CFrame.new(3, -4, 3) * CFrame.Angles(math.rad(90), math.rad(90), math.rad(90)), Time = 0.4},
		{CFrame = CFrame.new(-4, 3, -4) * CFrame.Angles(math.rad(111), math.rad(222), math.rad(333)), Time = 0.4}
	},
	['PistonWareBlock'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.00001} 
	},

	['1.8'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.12},
		{CFrame = CFrame.new(0.16, -1.16, 1) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.12}
	},
	['Blocking'] = {
		{CFrame = CFrame.new(-0.01, -3.51, -2.01) * CFrame.Angles(math.rad(-180), math.rad(85), math.rad(-180)), Time = 0}
	},
	['Swag2'] = {
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
	},
	['Kawaii'] = {
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(-51), math.rad(48), math.rad(24)),Time = 0.06},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0.06}
	},
	['Swank'] = {
		{CFrame = CFrame.new(-0.01, -.45, -0.7) * CFrame.Angles(math.rad(-0), math.rad(85), math.rad(0)),Time = 0.1},
		{CFrame = CFrame.new(-0.02, -.45, -0.7) * CFrame.Angles(math.rad(59), math.rad(19), math.rad(-37)),Time = 0.09},
	},
	['Swank2'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
	},
	['TenacityOld2'] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
	['OldSwank3'] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.4},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.4}
	},
	['TenacityOld'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
	['AstolfoNew'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
	},
	['Sigma2'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
	},
	['Sigma3'] = {
		{CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
		{CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
		{CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
	},
	['Tap'] = {
		{CFrame = CFrame.new(5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(10)), Time = 0.25},
		{CFrame = CFrame.new(5, -1, -0.3) * CFrame.Angles(math.rad(-100), math.rad(-30), math.rad(10)), Time = 0.25}
	},
	['Swag'] = {
		{CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(0)), Time = 0.08},
		{CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(10), math.rad(70), math.rad(-90)), Time = 0.08},
	},
	['Suicide'] = {
		{CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
		{CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
	},
	['Goofy2'] = {
		{CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
		{CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
		{CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
	},
	['Rise2'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.900},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
	},
	['Rise4'] = {
		{CFrame = CFrame.new(0.9,0,0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
		{CFrame = CFrame.new(0.5,-0.2,-0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
	},
	['Rise3'] = {
		{CFrame = CFrame.new(0.6, -1, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.6, -1.5, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}    
	},
	['Rise4'] = {
		{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
	},
	['Swong2'] = {
		{CFrame = CFrame.new(0,0,-.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
		{CFrame = CFrame.new(0,-.3, -.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2},
	},
	['Eternal'] = {
		{CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
		{CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
	},
	['monkey'] = {
		{CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(-math.rad(120), math.rad(530), -math.rad(220)), Time = 0.2},
		{CFrame = CFrame.new(0.9, 0, 1.5) * CFrame.Angles(math.rad(7), math.rad(30), math.rad(820)), Time = 0.2}
	},
	['Throw'] = {
		{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(255), math.rad(122), math.rad(321)), Time = 0.5},
		{CFrame = CFrame.new(1, 1, 1) * CFrame.Angles(math.rad(156), math.rad(54), math.rad(91)), Time = 0.5}
	},
	['Slide2'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
	},
	['Ketamine2'] = {
		{CFrame = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), Time = 0.07},
		{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
		{CFrame = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), Time = 0.07},
		{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
	},
	['Astolfo2'] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
	['Ketamine'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
		{CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
	},
	['Swiss2'] = {
		{CFrame = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.25},
		{CFrame = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.25}
	},
	['Old'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
	['Extension'] = {
		{CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.2},
		{CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
		{CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.1},
		{CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
		{CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07},
	},
	['Astolfo'] = {
		{CFrame = CFrame.new(5, -1, -1) * CFrame.Angles(math.rad(-40), math.rad(0), math.rad(0)), Time = 0.05},
		{CFrame = CFrame.new(5, -0.7, -1) * CFrame.Angles(math.rad(-120), math.rad(20), math.rad(-10)), Time = 0.05},
	},
	['German'] = {
		{CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
		{CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
		{CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
	},
	['Penis'] = {
		{CFrame = CFrame.new(-1.8, 0.5, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05},
		{CFrame = CFrame.new(-1.8, -0.21, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05}
	},
	['KillMyself'] = {
		{CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
		{CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
	},
	--scrxpted needs to do this ^^
	['SmootherExhibition'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.6},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.3},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.7},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.9},
		{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 1}
	},
	['PurpulV1'] = {
		{CFrame = CFrame.new(0.33, -0.45, 0.3) * CFrame.Angles(math.rad(-23), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.33, -0.7, 0.6) * CFrame.Angles(math.rad(-25), math.rad(50), math.rad(-90)), Time = 0.1}
	},
	['SuperSlowSlow'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.50},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.50}
	},
	-- cat v5
	['NewCatV5'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-70)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(1)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = -0.2},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-22), math.rad(56), math.rad(-106)), Time = 0.1}
	},
	['blackwareFast'] = {
		{CFrame = CFrame.new(1.49, -1, 0.12) * CFrame.Angles(math.rad(260), math.rad(55), math.rad(200)), Time = 0.30},
		{CFrame = CFrame.new(0.37, -2, -0.4) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-20)), Time = 0.30}
	},
	['blackwareSlow'] = {
		{CFrame = CFrame.new(1.5, -0.80, 0.14) * CFrame.Angles(math.rad(260), math.rad(50), math.rad(240)), Time = 0.40},
		{CFrame = CFrame.new(0.5, -0.15, -0.6) * CFrame.Angles(math.rad(-40), math.rad(55), math.rad(-50)), Time = 0.40}
	},
	['blackMeteor'] = {
		{CFrame = CFrame.new(0.80, -0.77, 0.9) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-90)), Time = 0.20},
		{CFrame = CFrame.new(0.32, -0.81, 0.10) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.20}
	},
	['Blackware'] = {
		{CFrame = CFrame.new(0.6, -0.7, 0.6) * CFrame.Angles(math.rad(-8), math.rad(40), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.49, -0.8, 0.3) * CFrame.Angles(math.rad(8), math.rad(40), math.rad(-10)), Time = 0.15}
	},
	['icespice'] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(190)), Time = 0.8},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(40), math.rad(1)), Time = 0.8}
	},
	['KEK'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.1}
	},
	['normalv2'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.09},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.09}
	},
	['sillydick'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
	['normalv3'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.06},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
	},
	-- Prism
	['PRISMASTADAWN'] = {
		{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(190), math.rad(75), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(0.3, -2, .2) * CFrame.Angles(math.rad(190), math.rad(95), math.rad(80)), Time = 0.13},
		{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(120), math.rad(170), math.rad(90)), Time = 0.13},
	},
	['Custom+'] = {
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
	},
	['FastslowBETTER'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.8},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.01}
	},	
	['cum'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), Time = 0.07},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), Time = 0.13}
	},
	['meteor4'] = {
		{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
		{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
	},
	['meteor'] = {
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
	},
	['meteor6'] = {
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
	},
	['astrolfo'] = {
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19},
	},
	['idkthesenames'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19}
	},
	['sexy'] = {
		{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(math.rad(190), math.rad(110), math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
	},
	-- meteor
	['meteor2'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
		{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
	},
	['meteor7'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
		{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(10)), Time = 0.14},
	},
	['meteor8'] = {
		{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
		{CFrame = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14},
	},
	['sexyfr'] = {
		{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
	},
	['2cum'] = {
		{CFrame = CFrame.new(0.7, -0.4, 0.612) * CFrame.Angles(math.rad(285), math.rad(65), math.rad(293)), Time = 0.13},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(210), math.rad(70), math.rad(3)), Time = 0.13}
	},
	['fatbitch'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(45), math.rad(85)), Time = 0.12},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(80), math.rad(60)), Time = 0.12},
	},
	['meteor3'] = {
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
	},
	['random'] = {
		{CFrame = CFrame.new(-0.06, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(97), math.rad(-92)), Time = 0.2},
		{CFrame = CFrame.new(-0.05, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-93)), Time = 0.3},
		{CFrame = CFrame.new(-0.03, -0.5, 0.4) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-91)), Time = 0.2}
	},
	['SlowAsstral'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.14},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.26}
	},
	-- Moon
	['Karambit'] = {
		{CFrame = CFrame.new(-0.01, 0, -1.51) * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0)), Time = 0},
		{CFrame = CFrame.new(-0.01, -0.01, -1.51) * CFrame.Angles(math.rad(-155), math.rad(0), math.rad(-0)), Time = 0.03},
		{CFrame = CFrame.new(-0.01, -0.01, -1.51) * CFrame.Angles(math.rad(120), math.rad(0), math.rad(0)), Time = 0.03},
		{CFrame = CFrame.new(-0.01, -0.01, -1.51) * CFrame.Angles(math.rad(30), math.rad(-0), math.rad(0)), Time = 0.03},
		{CFrame = CFrame.new(-0.01, 0, -1.51) * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0)), Time = 0.15}
	},
	['LiquidBounceV2'] = {
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.23}
	},
	['Tenacity'] = {
		{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.2},
		{CFrame = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.2}
	},
	['StabRemake'] = {
		{CFrame = CFrame.new(2, -2.5, 0.2) * CFrame.Angles(math.rad(268), math.rad(54), math.rad(327)), Time = 0.17},
		{CFrame = CFrame.new(1.6, -2.5, 0.2) * CFrame.Angles(math.rad(189), math.rad(52), math.rad(347)), Time = 0.16}
	},
	['SlashRemake'] = {
		{CFrame = CFrame.new(3.0, -1.7, -1.1) * CFrame.Angles(math.rad(307), math.rad(57), math.rad(145)), Time = 0.18},
		{CFrame = CFrame.new(3.0, -1.7, -1.3) * CFrame.Angles(math.rad(203), math.rad(57), math.rad(226)), Time = 0.14}
	},
	['ExhiRemake'] = {
		{CFrame = CFrame.new(1, 0, -0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
		{CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
	},
	['PushRemake'] = {
		{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
		{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
	},
	['SwongRemake'] = {
		{CFrame = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
		{CFrame = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2}
	},
	-- 0prime
	['BetterDortware'] = {
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.03},
		{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(80), math.rad(90)), Time = 0.07},
		{CFrame = CFrame.new(0.5, -0.2, -0.8) * CFrame.Angles(math.rad(-150), math.rad(111), math.rad(20)), Time = 0.13},
		{CFrame = CFrame.new(0.5, -0.2, -0.8) * CFrame.Angles(math.rad(-150), math.rad(111), math.rad(20)), Time = 0.03}
	},
	['BingChilling'] = {
		{CFrame = CFrame.new(0.07, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
	['HypixelBlock'] = {
		{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0.3, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
	['INUMAURA'] = {
		{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-20), math.rad(20), math.rad(0)), Time = 0.30},
		{CFrame = CFrame.new(0, -0.50, -0.30) * CFrame.Angles(math.rad(-40), math.rad(41), math.rad(0)), Time = 0.32},
		{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.32}
	},
	-- Voidware
	['Shake'] = {
		{CFrame = CFrame.new(0.69, -0.8, 0.6) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-35)), Time = 0.05},
		{CFrame = CFrame.new(0.8, -0.71, 0.30) * CFrame.Angles(math.rad(-60), math.rad(39), math.rad(-55)), Time = 0.02},
		{CFrame = CFrame.new(0.8, -2, 0.45) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-55)), Time = 0.03}
	},
	['PopV3'] = {
		{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1}
	},
	['PopV4'] = {
		{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.01},
		{CFrame = CFrame.new(0.7, -0.30, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.01},
		{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.01}
	},
	['Remake'] = {
		{CFrame = CFrame.new(-0.10, -0.45, -0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-50)), Time = 0.01},
		{CFrame = CFrame.new(0.7, -0.71, -1) * CFrame.Angles(math.rad(-90), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(0.63, -0.1, 1.50) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
	},
	['PopV2'] = {
		{CFrame = CFrame.new(0.10, -0.3, -0.30) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(290)), Time = 0.09},
		{CFrame = CFrame.new(0.10, 0.10, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
	},
	['Bob'] = {
		{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(-0.7, -2.5, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
	['Knife'] = {
		{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(4, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
	},
	['FunnyExhibition'] = {
		{CFrame = CFrame.new(-1.5, -0.50, 0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.10},
		{CFrame = CFrame.new(-0.55, -0.20, 1.5) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
	},
	['FasterSmooth'] = {
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.11},
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.11},
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.11},
	},
	['Smooth2'] = {
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.25},
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.25},
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.25},
	},
	['Funny'] = {
		{CFrame = CFrame.new(0, 0, 1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
		{CFrame = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-55), math.rad(0), math.rad(0)), Time = 0.15}
	},
	['FunnyFuture'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)),Time = 0.25},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
	},
	['Goofy'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
		{CFrame = CFrame.new(-1, -1, 1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-33)),Time = 0.25}
	},
	['Future'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.10) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.20},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
	},
	['Pop'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.35},
		{CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.35}
	},
	['FunnyV2'] = {
		{CFrame = CFrame.new(0.10, -0.5, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.45},
		{CFrame = CFrame.new(-5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
		{CFrame = CFrame.new(5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
	},
	['Slowest'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.72, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
	},
	['BigAuraAnimation'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
		{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
	},
	-- Acronis
	['Acronisware'] = {
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
	},
	-- Snoopy
	['CustomSP+'] = {
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
	},
	['FemboyActivis'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
		{CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
	},
	['Lift'] = {
		{CFrame = CFrame.new(0.5, -0.5, 0.5) * CFrame.Angles(math.rad(-15), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0.5, -0.4, 0.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.3},
	},
	['SlowLift'] = {
		{CFrame = CFrame.new(0.5, -0.5, 0.5) * CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0)), Time = 0.5},
		{CFrame = CFrame.new(0.5, -0.4, 0.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 1},
	},
	['Shit'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(-0.1, -0.2, 0.05) * CFrame.Angles(math.rad(-15), math.rad(30), math.rad(15)), Time = 0.4},
		{CFrame = CFrame.new(-0.12, -0.22, 0.06) * CFrame.Angles(math.rad(-10), math.rad(60), math.rad(25)), Time = 0.6},
		{CFrame = CFrame.new(-0.1, -0.18, 0.08) * CFrame.Angles(math.rad(-25), math.rad(30), math.rad(10)), Time = 0.8},
		{CFrame = CFrame.new(0.2, -0.15, -0.05) * CFrame.Angles(math.rad(-5), math.rad(0), math.rad(-10)), Time = 1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 1.2},
	},
	['SwingOld'] = {
		{CFrame = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(5), math.rad(0), math.rad(5)), Time = 0.2},
		{CFrame = CFrame.new(0, -0.48, 0) * CFrame.Angles(math.rad(-5), math.rad(0), math.rad(-5)), Time = 0.25},
		{CFrame = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(5), math.rad(0), math.rad(5)), Time = 0.2},
		{CFrame = CFrame.new(0, -0.52, 0) * CFrame.Angles(math.rad(-5), math.rad(0), math.rad(-5)), Time = 0.25},
	},		
	['throw'] = { 
		{CFrame = CFrame.new(-0.04, -0.4, -1.05) * CFrame.Angles(math.rad(-30), math.rad(100), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.32, -0.81, 0.10) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.20},
		{CFrame = CFrame.new(0.10, -0.5, -0.3) * CFrame.Angles(math.rad(-40), math.rad(55), math.rad(-50)), Time = 0.30},
		{CFrame = CFrame.new(-0.04, -0.4, 0.5) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.15}
	},
	['OLD'] = { 
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.25},
		{CFrame = CFrame.new(0.80, -0.77, 0.9) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-90)), Time = 0.20},
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.3, -0.4, 0.6) * CFrame.Angles(math.rad(-8), math.rad(40), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(-0.04, -0.4, -1.05) * CFrame.Angles(math.rad(-30), math.rad(100), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(-0.04, -0.4, 0.5) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.15}
	},
	['SwingAnimation'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-45), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.2},
	},
	['ExhibitionV2'] = {
		{CFrame = CFrame.new(0.65, -0.6, 0.7) * CFrame.Angles(math.rad(-60), math.rad(70), math.rad(-100)), Time = 0.1},
		{CFrame = CFrame.new(0.75, -0.65, 0.7) * CFrame.Angles(math.rad(-70), math.rad(80), math.rad(-50)), Time = 0.2},
		{CFrame = CFrame.new(0.8, -0.7, 0.75) * CFrame.Angles(math.rad(-80), math.rad(90), math.rad(-40)), Time = 0.3}
	},
	['FrontwardAscend'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.1},
		{CFrame = CFrame.new(0, 0.2, -0.1) * CFrame.Angles(math.rad(10), math.rad(0), math.rad(0)), Time = 0.3},
		{CFrame = CFrame.new(0, 0.4, -0.2) * CFrame.Angles(math.rad(20), math.rad(0), math.rad(0)), Time = 0.5},
		{CFrame = CFrame.new(0, 0.2, -0.5) * CFrame.Angles(math.rad(10), math.rad(0), math.rad(0)), Time = 0.8},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 1.2}
	},
	['SpiralReturn'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.05},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(360), math.rad(0), math.rad(0)), Time = 0.3},
		{CFrame = CFrame.new(0, 0, -2) * CFrame.Angles(math.rad(720), math.rad(0), math.rad(0)), Time = 0.6},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(1080), math.rad(0), math.rad(0)), Time = 0.9},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1440), math.rad(0), math.rad(0)), Time = 1.2},
	},
	['Boomerang'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.05},
		{CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
		{CFrame = CFrame.new(2, 0, -1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.3},
		{CFrame = CFrame.new(1, 0, -2) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.6},
		{CFrame = CFrame.new(-1, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.75},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.9},
	},
	['SmoothFlow'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.05},
		{CFrame = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(0), math.rad(20), math.rad(0)), Time = 0.4},
		{CFrame = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), Time = 0.6},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.8},
	},
	['OldSmooth'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.1},
		{CFrame = CFrame.new(0.25, -0.35, 0.3) * CFrame.Angles(math.rad(-15), math.rad(25), math.rad(-45)), Time = 0.3},
		{CFrame = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), Time = 0.5},
		{CFrame = CFrame.new(0.625, -0.355, 0.295) * CFrame.Angles(math.rad(-42), math.rad(30), math.rad(-64)), Time = 0.7},
		{CFrame = CFrame.new(0.750, -0.71, 0.29) * CFrame.Angles(math.rad(-57), math.rad(55), math.rad(-81)), Time = 0.9},
		{CFrame = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), Time = 1.1},
		{CFrame = CFrame.new(0.25, -0.35, 0.3) * CFrame.Angles(math.rad(-15), math.rad(25), math.rad(-45)), Time = 1.3},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 1.5},
	},		
	['SlowlySmooth'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.5},
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.75},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 1.25},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 1.5},
	},
	['Meteor+'] = { 
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
	},
	['ExhiCloneAndMeteor'] = {
		{CFrame = CFrame.new(0.68, -0.7, 0.61) * CFrame.Angles(math.rad(-20), math.rad(45), math.rad(-85)), Time = 0.15},
		{CFrame = CFrame.new(0.695, -0.705, 0.595) * CFrame.Angles(math.rad(-60), math.rad(48), math.rad(-65)), Time = 0.3},
		{CFrame = CFrame.new(0.72, -0.72, 0.58) * CFrame.Angles(math.rad(-90), math.rad(52), math.rad(-40)), Time = 0.45},
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.6},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.75}
	},	
	['ExhibitionClone'] = {
		{CFrame = CFrame.new(0.68, -0.7, 0.61) * CFrame.Angles(math.rad(-20), math.rad(45), math.rad(-85)), Time = 0.15},  
		{CFrame = CFrame.new(0.695, -0.705, 0.595) * CFrame.Angles(math.rad(-60), math.rad(48), math.rad(-65)), Time = 0.3},  
		{CFrame = CFrame.new(0.72, -0.72, 0.58) * CFrame.Angles(math.rad(-90), math.rad(52), math.rad(-40)), Time = 0.45}   
	},	
	['LatestClone'] = {
		{CFrame = CFrame.new(0.68, -0.72, 0.12) * CFrame.Angles(math.rad(-63), math.rad(57), math.rad(-49)), Time = 0.4},
		{CFrame = CFrame.new(0.17, -1.18, 0.52) * CFrame.Angles(math.rad(-177), math.rad(56), math.rad(31)), Time = 0.4}
	},
	['SpinClone'] = {
		{CFrame = CFrame.new(0.5, -0.6, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
		{CFrame = CFrame.new(0.5, -0.55, 0) * CFrame.Angles(math.rad(0), math.rad(45), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0.5, -0.5, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)), Time = 0.15},
		{CFrame = CFrame.new(0.5, -0.55, 0) * CFrame.Angles(math.rad(0), math.rad(135), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0.5, -0.6, 0) * CFrame.Angles(math.rad(0), math.rad(180), math.rad(0)), Time = 0.15},
	},
	["Inum's Ass"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
		{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.8},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.01},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(65), math.rad(-79)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(35), math.rad(-56)), Time = 0.2},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), Time = 0.07},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), Time = 0.13},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(54), math.rad(-56)), Time = 0.08},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(38), math.rad(-23)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(98), math.rad(-354)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(65), math.rad(-68)), Time = 0.2},
		{CFrame = CFrame.new(0.67, -0.66, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-85)), Time = 0.1},
		{CFrame = CFrame.new(0.72, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(59), math.rad(-50)), Time = 0.2},
		{CFrame = CFrame.new(0.65, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-76)), Time = 0.15},
		{CFrame = CFrame.new(0.77, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(76), math.rad(-32)), Time = 0.17},
		{CFrame = CFrame.new(0.63, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(65), math.rad(-65)), Time = 0.21},
		{CFrame = CFrame.new(0.73, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(49), math.rad(-25)), Time = 0.26}
	},
	['Ware'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(65), math.rad(-79)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(35), math.rad(-56)), Time = 0.2}
	},
	['Wearish'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.58) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.17}
	},
	-- Azura
	['Assura'] = {
		{CFrame = CFrame.new(0.67, -0.66, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-85)), Time = 0.1},
		{CFrame = CFrame.new(0.72, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(59), math.rad(-50)), Time = 0.2}
	},
	["Assura Old"] = {
		{CFrame = CFrame.new(0.65, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-76)), Time = 0.15},
		{CFrame = CFrame.new(0.77, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(76), math.rad(-32)), Time = 0.17},
		{CFrame = CFrame.new(0.63, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(65), math.rad(-65)), Time = 0.21},
		{CFrame = CFrame.new(0.73, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(49), math.rad(-25)), Time = 0.26}
	},
	["Assura Combined"] = {
		{CFrame = CFrame.new(0.67, -0.66, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-85)), Time = 0.12},
		{CFrame = CFrame.new(0.72, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(59), math.rad(-50)), Time = 0.14},
		{CFrame = CFrame.new(0.65, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-76)), Time = 0.15},
		{CFrame = CFrame.new(0.77, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(76), math.rad(-32)), Time = 0.17},
		{CFrame = CFrame.new(0.63, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(65), math.rad(-65)), Time = 0.21},
		{CFrame = CFrame.new(0.73, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(49), math.rad(-25)), Time = 0.26}
	},
	-- Scrxpted
	['ScrxptedIsBLACK'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19}
	},
	-- Lunar
	["Lunar Old"] = {
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
	},
	["Lunar New"] = {
		{CFrame = CFrame.new(0.86, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.17},
		{CFrame = CFrame.new(0.73, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.17}
	},
	["Lunar Fast"] = {
		{CFrame = CFrame.new(0.95, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.40, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
	},
	["LiquidBounceX"] = {
		{CFrame = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(90), math.rad(-90)), Time = 0.45},
		{CFrame = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Time = 0.45},
		{CFrame = CFrame.new(-0.01, -0.3, 0.4) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Time = 0.32}
	},
	["Auto Block"] = {
		{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(65)), Time = 0.15},
		{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(110), math.rad(65)), Time = 0.15},
		{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(65), math.rad(65)), Time = 0.15}
	},
	['Switch'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
	},
	['Sideways'] = {
		{CFrame = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), Time = 0.12},
		{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.12},
		{CFrame = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), Time = 0.12},
		{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.12}
	},
	['Stand'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1}
	}
}

local SpeedMethods: any;
local SpeedMethodList: table = {'Velocity'}
local SpeedMethods: {
    Velocity: (options: { Value: { Value: number } }, moveDirection: Vector3) -> (),
    CFrame: (options: { Value: { Value: number }, WallCheck: { ["Enabled"]: boolean }, rayCheck: { FilterDescendantsInstances: {any}, CollisionGroup: any }, TPTiming: number, TPFrequency: { Value: number }, WalkSpeed: number?, PulseLength: { Value: number }, PulseDelay: { Value: number } }, moveDirection: Vector3, dt: number) -> (),
    TP: (options: { TPTiming: number, TPFrequency: { Value: number } }, moveDirection: Vector3) -> (),
    WalkSpeed: (options: { Value: { Value: number }, WalkSpeed: number? }) -> (),
    Pulse: (options: { Value: { Value: number }, PulseLength: { Value: number }, PulseDelay: { Value: number } }, moveDirection: Vector3) -> ()
} = {
	Velocity = function(options: { Value: { Value: number } }, moveDirection: Vector3)
		local root: RootPart? = entitylib.character.RootPart;
		root.AssemblyLinearVelocity = (moveDirection * options.Value.Value) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0);
	end,
	 CFrame = function(options: { Value: { Value: number }, WallCheck: { ["Enabled"]: boolean }, rayCheck: { FilterDescendantsInstances: {any}, CollisionGroup: any } }, moveDirection: Vector3, dt: number)
		local root: RootPart? = entitylib.character.RootPart;
		local dest: CFrame? = (moveDirection * math.max(options.Value.Value - entitylib.character.Humanoid.WalkSpeed, 0) * dt);
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
	 TP = function(options: { TPTiming: number, TPFrequency: { Value: number } }, moveDirection: Vector3)
		if options.TPTiming < tick() then
			options.TPTiming = tick() + options.TPFrequency.Value;
			SpeedMethods.CFrame(options, moveDirection, 1)
		end;
	end,
	WalkSpeed = function(options: { Value: { Value: number }, WalkSpeed: number? })
		if not options.WalkSpeed then options.WalkSpeed = entitylib.character.Humanoid.WalkSpeed end;
		entitylib.character.Humanoid.WalkSpeed = options.Value.Value;
	end,
	 Pulse = function(options: { Value: { Value: number }, PulseLength: { Value: number }, PulseDelay: { Value: number } }, moveDirection: Vector3)
		local root: Humanoid? = entitylib.character.RootPart;
		local dt: number = math.max(options.Value.Value - entitylib.character.Humanoid.WalkSpeed, 0);
		dt = dt * (1 - math.min((tick() % (options.PulseLength.Value + options.PulseDelay.Value)) / options.PulseLength.Value, 1));
		root.AssemblyLinearVelocity = (moveDirection * (entitylib.character.Humanoid.WalkSpeed + dt)) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0);
	end;
};
for name in SpeedMethods do
	if not table.find(SpeedMethodList, name) then
		table.insert(SpeedMethodList, name);
	end;
end;

velo.run(function()
	entitylib.getUpdateConnections = function(ent: any): {RBXScriptConnection}
		local hum: Humanoid? = ent.Humanoid;
		return {
			hum:GetPropertyChangedSignal('Health'),
			hum:GetPropertyChangedSignal('MaxHealth'),
			{
				Connect = function()
					ent.Friend = ent.Player and isFriend(ent.Player) or nil;
					ent.Target = ent.Player and isTarget(ent.Player) or nil;
					return {
						Disconnect = function() end
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
		if not (ent and vape.Categories.Main.Options['Use team color']["Enabled"]) then return end;
		if isFriend(ent, true) then
			return Color3.fromHSV(vape.Categories.Friends.Options['Friends color'].Hue, vape.Categories.Friends.Options['Friends color'].Sat, vape.Categories.Friends.Options['Friends color'].Value);
		end;
		return tostring(ent.TeamColor) ~= 'White' and ent.TeamColor.Color or nil;
	end;

	vape:Clean(function()
		entitylib.kill();
		entitylib = nil;
	end);
	vape:Clean(vape.Categories.Friends.Update.Event:Connect(function() entitylib.refresh() end));
	vape:Clean(vape.Categories.Targets.Update.Event:Connect(function() entitylib.refresh() end));
	vape:Clean(entitylib.Events.LocalAdded:Connect(updateVelocity));
	vape:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
		gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera');
	end));
end);

velo.run(function()
	function whitelist:get(plr: Player)
		local plrstr: any = self.hashes[plr.Name..plr.UserId];
		for _, v in self.data.WhitelistedUsers do
			if v.hash == plrstr then
				return v.level, v.attackable or whitelist.localprio >= v.level, v.tags;
			end;
		end;
		return 0, true;
	end;

	function whitelist:isingame(): boolean
		for _, v in playersService:GetPlayers() do
			if self:get(v) ~= 0 then return true; end;
		end;
		return false;
	end;
	
	function whitelist:tag(plr: Player, text: string?, rich: boolean?): string?
		local plrtag: any = (select(3, self:get(plr)) or self.customtags[plr.Name]) or {};
		local newtag: string = '';
		if not text then return plrtag; end;
		for _, v in plrtag do
			newtag = newtag..(rich and '<font color="#'..v.color:ToHex()..'">['..v.text..']</font>' or '['..removeTags(v.text)..']')..' ';
		end;
		return newtag;
	end;

	local olduninject: any;
	function whitelist:playeradded(v: Player?, joined: boolean?)
		if self:get(v) ~= 0 then
			if self.alreadychecked[v.UserId] then return; end;
			self.alreadychecked[v.UserId] = true;
			self:hook();
			if self.localprio == 0 then
				olduninject = vape.Uninject;
				vape.Uninject = function()
					notif('Vape', 'No escaping the private members :)', 10);
				end;
				if joined then
					task.wait(10);
				end;
				if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
					local oldchannel: any = textChatService.ChatInputBarConfiguration.TargetTextChannel;
					local newchannel: any = cloneref(game:GetService('RobloxReplicatedStorage')).ExperienceChat.WhisperChat:InvokeServer(v.UserId);
					if newchannel then
						newchannel:SendAsync('helloimusinginhaler');
					end;
					textChatService.ChatInputBarConfiguration.TargetTextChannel = oldchannel;
				elseif replicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
					replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('/w '..v.Name..' helloimusinginhaler', 'All');
				end;
			end;
		end;
	end;

	function whitelist:process(msg: string, plr: Player): boolean
		local otherprio: any = self:get(plr);
		if plr == lplr and msg == 'helloimusinginhaler' then 
			return true;
		end;
		if self.localprio > 0 and not self.said[plr.Name] and msg == 'helloimusinginhaler' and plr ~= lplr then
			self.said[plr.Name] = true
			notif('Vape', plr.Name..' is using vape!', 60)
			self.customtags[plr.Name] = {{
				text = 'VAPE USER',
				color = Color3.new(1, 1, 0)
			}};
			local newent: any = entitylib.getEntity(plr);
			if newent then
				entitylib.Events.EntityUpdated:Fire(newent);
			end;
			return true;
		end;
		return false;
	end;

	function whitelist:newchat(obj: TextLabel, plr: Player?, skip: boolean?)
		obj.Text = self:tag(plr, true, true) .. obj.Text;
		local sub:string? = obj.Text:find(':  ');
		if sub then
			local message: string? = obj.Text:sub(sub + 4);
			if not skip and self:process(message, plr) then
				obj.Visible = true;
			end;
		end;
	end;


	function whitelist:oldchat(func)
        	local oldchat: (...any) -> any = func
        	func = function(data: any, ...)
            		local plr: Player? = game:GetService("Players"):GetPlayerByUserId(data.SpeakerUserId);
            		if plr then
                		data.ExtraData.Tags = data.ExtraData.Tags or {};
                		for _, v in next, self:tag(plr) do
                    			table.insert(data.ExtraData.Tags, {TagText = v.text, TagColor = v.color});
               		 	end;
                		if data.Message and self:checkmessage(data.Message, plr) then 
                    			data.Message = '';
               		 	end;
            		end;
            		return oldchat(data, ...);
        	end;
        	table.insert(connection, {
            		Disconnect = function()
                		func = oldchat;
            		end;
        	});
    	end;

	function whitelist:hook()
	        if self.hooked then return; end;
		self.hooked = true;
		local exp: ExperienceChat? = coreGui:FindFirstChild('ExperienceChat');
		if not exp then
		        return;
		end;
		if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		        if exp:FindFirstChild('appLayout', 5) then
		        	local scrollView: RCTScrollContentView? = exp:FindFirstChild('RCTScrollContentView', true)
		            	if not scrollView then
		                	return;
		            	end;
		            	table.insert(vapeConnections, scrollView.ChildAdded:Connect(function(obj)
		                	local userId: number? = tonumber(obj.Name:split('-')[1]);
		                	if not userId then 
						return; 
					end;
		                	local plr: Player? = game:GetService("Players"):GetPlayerByUserId(userId);
		                	if not plr then 
						return; 
					end;
		                	local textMessage: string? = obj:FindFirstChild('TextMessage', true);
		                	if not textMessage or not textMessage:IsA("Frame") then 
						return; 
					end;
		                	local prefix: any = textMessage:FindFirstChild("PrefixText")
		                	local body: any = textMessage:FindFirstChild("BodyText")
		                	if prefix and prefix:IsA("TextLabel") then
		                    		local tagText: any = self:tag(plr, true, true)
		                    		if tagText:sub(-1) ~= " " then
		                        		tagText = tagText .. " ";
		                    		end;
						prefix.Text = prefix.Text:gsub(":?%s*$", " ") .. ": ";
						if not prefix.Text:match(": $") then
						        prefix.Text = prefix.Text:gsub(":?$", " ") .. ":  ";
						end;
		                    		prefix.Text = tagText .. prefix.Text;
		                	end;
		                	if body and body:IsA("TextLabel") then
		                    		self:newchat(body, plr, true);
		                	else
		                    		local fallback: any = textMessage:FindFirstChildWhichIsA("TextLabel")
		                        		or textMessage:FindFirstChildWhichIsA("TextButton")
		                        		or textMessage:FindFirstChildWhichIsA("TextBox");
		                    		if fallback then
		                        		whitelist:newchat(fallback, plr, true);
		                    		end;
		                	end;
		            	end));
		        end;
		elseif replicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
            		pcall(function()
                		local message: any = replicatedStorageService.DefaultChatSystemChatEvents.OnNewMessage
                		if message and message.OnClientEvent then
                    			for i: any, v: any in next, message.OnClientEvent:GetConnections() do
                        			local updated: any = v.Function and tostring(v.Function):find('UpdateMessagePostedInChannel')
                        			if updated then
                            				whitelist:oldchat(v.Function)
                            				break
                        			end
                    			end
                		end
                		local filter: any = replicatedStorageService.DefaultChatSystemChatEvents.OnMessageDoneFiltering
                		if filter and filter.OnClientEvent then
                    			for i: any, v: any in next, filter.OnClientEvent:GetConnections() do
                        			local updated: any  = v.Function and tostring(v.Function):find('UpdateMessageFiltered')
                        			if updated then
                            				whitelist:oldchat(v.Function)
                            				break;
                        			end;
                    			end;
                		end;
            		end);
        	end;

		if exp then
			local bubblechat: any = exp:WaitForChild('bubbleChat', 5)
			if bubblechat then
				vape:Clean(bubblechat.DescendantAdded:Connect(function(newbubble)
					if newbubble:IsA('TextLabel') and newbubble.Text:find('helloimusinginhaler') then
						newbubble.Parent.Parent.Visible = false;
					end;
				end));
			end;
		end;
	end;

	function whitelist:f(): ()
		if setfpscap then 
			setfpscap(9e9); 
		end;
		for i: any, v: any in {} do end;
		game:Shutdown();
		while true do end;
		return;
	end;

	function whitelist:update(first)
		local suc: boolean? = pcall(function()
			local _, subbed = pcall(function() 
				return game:HttpGet('https://github.com/Copiums/whitelistss/tree/main') 
			end)
			local commit: string? = subbed:find('currentOid')
			commit = commit and subbed:sub(commit + 13, commit + 52) or nil;
			commit = commit and #commit == 40 and commit or 'main';
			whitelist.textdata = game:HttpGet('https://raw.githubusercontent.com/Copiums/whitelistss/'..commit..'/PlayerWhitelist.json', true);
		end);
		if not suc or not hash or not whitelist.get then return true; end;
		whitelist.loaded = true;

		local olddatas: any = isfile('newvape/profiles/whitelist.json')
		whitelist.olddata = olddatas and readfile('newvape/profiles/whitelist.json') or nil;

		if not first or whitelist.textdata ~= whitelist.olddata then
			local suc, res = pcall(function()
				return httpService:JSONDecode(whitelist.textdata);
			end);

			whitelist.data = suc and type(res) == 'table' and res or whitelist.data;
			whitelist.localprio = whitelist:get(lplr) or 0;


			if whitelist.textdata ~= whitelist.olddata then
				whitelist.olddata = whitelist.textdata;
				pcall(function()
					writefile('newvape/profiles/whitelist.json', whitelist.textdata);
				end);
			end;

			for _, v in whitelist.data.WhitelistedUsers or {} do
				if v.tags then
					for _, tag in v.tags do
						tag.color = Color3.fromRGB(unpack(tag.color))
					end
				end
			end

			if whitelist.data.Announcement.expiretime > os.time() then
				local targets: any = whitelist.data.Announcement.targets;
				targets = targets == 'all' and {tostring(lplr.UserId)} or targets:split(',');

				if table.find(targets, tostring(lplr.UserId)) then
					local hint: Hint? = Instance.new('Hint')
					hint.Text = 'VAPE ANNOUNCEMENT: '..whitelist.data.Announcement.text;
					hint.Parent = workspace;
					game:GetService('Debris'):AddItem(hint, 20);
				end;
			end;

			if not whitelist.connection then
				whitelist.connection = playersService.PlayerAdded:Connect(function(v)
					whitelist:playeradded(v, true);
				end);
				vape:Clean(whitelist.connection);
			end;

			for _, v in playersService:GetPlayers() do
				whitelist:playeradded(v);
			end;

			if not whitelist.connection then
                whitelist.connection = playersService.PlayerAdded:Connect(function(v)
                    whitelist:playeradded(v, true);
                end);
            end;

			if entitylib.Running and vape.Loaded then
				entitylib.refresh();
			end;

			if whitelist.data.KillVape then
				vape:Uninject();
				return true;
			end;

			if whitelist.data.BlacklistedUsers[tostring(lplr.UserId)] then
				task.spawn(lplr.Kick, lplr, whitelist.data.BlacklistedUsers[tostring(lplr.UserId)]);
				return true;
			else 
				return false;
			end;
		end;
	end;

	function whitelist:renderNametag(plr: Player)
		if not plr or not plr:IsA("Player") or self:get(plr) == 0 or whitelist.localprio < 3 then return; end;
		local playerList: PlayerList? = coreGui:WaitForChild("PlayerList", 10);
		if not playerList then return; end;
		local success: boolean, playerIcon: any = pcall(function()
			local path: table? = {
				"Children", "OffsetFrame", "PlayerScrollList", "SizeOffsetFrame",
				"ScrollingFrameContainer", "ScrollingFrameClippingFrame", "ScollingFrame",
				"OffsetUndoFrame", "p_" .. plr.UserId, "ChildrenFrame",
				"NameFrame", "BGFrame", "OverlayFrame", "PlayerIcon"
			};
			local obj: any = playerList;
			for _, name in next, path do
				obj = obj:FindFirstChild(name);
				if not obj then return; end;
			end;
			return obj
		end);
		if success and playerIcon and playerIcon:IsA("ImageLabel") then
			playerIcon.Image = "rbxassetid://13350808582";
		end;
	end;

	function whitelist:CheckPlayerType(plr: any): any
		if not plr then 
			return 'DEFAULT'; 
		end;
		local plrPriority, _, _ = self:get(plr) or 0;
		if plrPriority == 0 then
			return 'DEFAULT';
		elseif plrPriority == 1 then
			return 'BUYER';
		elseif plrPriority == 2 then
			return 'VELOCITY PRIVATE';
		elseif plrPriority >= 3 then
			return 'VELOCITY OWNER';
		else
			return 'DEFAULT';
		end;
	end;	

	task.spawn(function()
		repeat
			if whitelist:update(whitelist.loaded) then 
				return;
			end;
			task.wait(10);
		until vape.Loaded == nil;
	end);


	task.spawn(function()
		repeat task.wait() until whitelist.loaded;
		if whitelist.localprio >= 3 then
			task.spawn(function()
				repeat
					task.wait(0.5);
					whitelist:renderNametag(lplr);
					whitelist:renderNametag(v);
				until vape.Loaded == nil;
			end);
		end;
	end);
	
	
	vape:Clean(function()
		table.clear(whitelist.data);
		table.clear(whitelist);
		if whitelist.connection then
			whitelist.connection:Disconnect();
			whitelist.connection = nil;
		end;
	end);

	vape:Clean(textChatService.MessageReceived:Connect(function(message)
		if message.TextSource then
			local success: boolean?, plr: any = pcall(playersService.GetPlayerByUserId, playersService, message.TextSource.UserId)
			whitelist:process(message.Text, plr);
		end;
	end));
end);

velo.run(function()
	repeat 
		task.wait();
	until whitelist.loaded;
	task.wait(0.1);
	task.spawn(function()
		local priolist: table = {
			["DEFAULT"] = 0,
			["BUYER"] = 1,
			["VELOCITY PRIVATE"] = 2,
			["VELOCITY OWNER"] = 3
		}
		local function findplayers(arg: any, plr: any): any
			local temp: table = {}
			local continuechecking: boolean = true;
			if arg == "default" and continuechecking and whitelist:CheckPlayerType(lplr) == "DEFAULT" then table.insert(temp, lplr) continuechecking = false end
			if arg == "teamdefault" and continuechecking and whitelist:CheckPlayerType(lplr) == "DEFAULT" and plr and lplr:GetAttribute("Team") ~= plr:GetAttribute("Team") then table.insert(temp, lplr) continuechecking = false end
			if arg == "buyer" and continuechecking and whitelist:CheckPlayerType(lplr) == "BUYER" then table.insert(temp, lplr) continuechecking = false end
			if arg == "private" and continuechecking and whitelist:CheckPlayerType(lplr) == "VELOCITY PRIVATE" then table.insert(temp, lplr) continuechecking = false end
			if arg == "owner" and continuechecking and whitelist:CheckPlayerType(lplr) == "VELOCITY OWNER" then table.insert(temp, lplr) continuechecking = false end
			for i: any, v: Player? in next, playersService:GetPlayers() do 
				if continuechecking and v.Name:lower():sub(1, arg:len()) == arg:lower() then 
					table.insert(temp, v);
					continuechecking = false; 
				end;
			end;
			return temp;
		end;
		local function transformImage(img: string, txt: string)
			local function funnyfunc(v: Instance)
				if v:GetFullName():find("ExperienceChat") == nil then
					if v:IsA("ImageLabel") or v:IsA("ImageButton") then
						v.Image = img
						v:GetPropertyChangedSignal("Image"):Connect(function()
							v.Image = img;
						end);
					end;
					if v:IsA("TextLabel") or v:IsA("TextButton") then
						if v.Text ~= "" then
							v.Text = txt;
						end;
						v:GetPropertyChangedSignal("Text"):Connect(function()
							if v.Text ~= "" then
								v.Text = txt
							end;
						end);
					end;
					if v:IsA("Texture") or v:IsA("Decal") then
						v.Texture = img
						v:GetPropertyChangedSignal("Texture"):Connect(function()
							v.Texture = img;
						end);
					end;
					if v:IsA("MeshPart") then
						v.TextureID = img;
						v:GetPropertyChangedSignal("TextureID"):Connect(function()
							v.TextureID = img;
						end);
					end;
					if v:IsA("SpecialMesh") then
						v.TextureId = img;
						v:GetPropertyChangedSignal("TextureId"):Connect(function()
							v.TextureId = img;
						end);
					end;
					if v:IsA("Sky") then
						v.SkyboxBk = img
						v.SkyboxDn = img
						v.SkyboxFt = img
						v.SkyboxLf = img
						v.SkyboxRt = img
						v.SkyboxUp = img
					end;
				end;
			end;
	
			for i: any, v: Instance in next, game:GetDescendants() do
				funnyfunc(v)
			end;
			game.DescendantAdded:Connect(funnyfunc)
		end;
	
		local vapePrivateCommands: table = {
			byfron = function()
				task.spawn(function()
					if vape.ThreadFix then
						setthreadidentity(8)
					end
					local UIBlox: any  = getrenv().require(game:GetService('CorePackages').UIBlox)
					local Roact: any  = getrenv().require(game:GetService('CorePackages').Roact)
					UIBlox.init(getrenv().require(game:GetService('CorePackages').Workspace.Packages.RobloxAppUIBloxConfig))
					local auth: any  = getrenv().require(coreGui.RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme: any  = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Style).Themes.DarkTheme
					local fonttokens: any  = getrenv().require(game:GetService("CorePackages").Packages._Index.UIBlox.UIBlox.App.Style.Tokens).getTokens('Desktop', 'Dark', true)
					local buildersans: any  = getrenv().require(game:GetService('CorePackages').Packages._Index.UIBlox.UIBlox.App.Style.Fonts.FontLoader).new(true, fonttokens):loadFont()
					local tLocalization: any  = getrenv().require(game:GetService('CorePackages').Workspace.Packages.RobloxAppLocales).Localization
					local localProvider: any = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Localization).LocalizationProvider
					lplr.PlayerGui:ClearAllChildren()
					vape.gui["Enabled"] = false
					coreGui:ClearAllChildren()
					lightingService:ClearAllChildren()
					for _, v in workspace:GetChildren() do
						pcall(function()
							v:Destroy()
						end)
					end
					lplr.kick(lplr)
					guiService:ClearError()
					local gui = Instance.new('ScreenGui')
					gui.IgnoreGuiInset = true
					gui.Parent = coreGui
					local frame = Instance.new('ImageLabel')
					frame.BorderSizePixel = 0
					frame.Size = UDim2.fromScale(1, 1)
					frame.BackgroundColor3 = Color3.fromRGB(224, 223, 225)
					frame.ScaleType = Enum.ScaleType.Crop
					frame.Parent = gui
					task.delay(0.3, function()
						frame.Image = 'rbxasset://textures/ui/LuaApp/graphic/Auth/GridBackground.jpg'
					end)
					task.delay(0.6, function()
						local modPrompt = Roact.createElement(auth, {
							style = {},
							screenSize = vape.gui.AbsoluteSize or Vector2.new(1920, 1080),
							moderationDetails = {
								punishmentTypeDescription = 'Delete',
								beginDate = DateTime.fromUnixTimestampMillis(DateTime.now().UnixTimestampMillis - ((60 * math.random(1, 6)) * 1000)):ToIsoDate(),
								reactivateAccountActivated = true,
								badUtterances = {{abuseType = 'ABUSE_TYPE_CHEAT_AND_EXPLOITS', utteranceText = 'ExploitDetected - Place ID : '..game.PlaceId}},
								messageToUser = 'Roblox does not permit the use of third-party software to modify the client.'
							},
							termsActivated = function() end,
							communityGuidelinesActivated = function() end,
							supportFormActivated = function() end,
							reactivateAccountActivated = function() end,
							logoutCallback = function() end,
							globalGuiInset = {top = 0}
						})
	
						local screengui: ScreenGui? = Roact.createElement(localProvider, {
							localization = tLocalization.new('en-us')
						}, {Roact.createElement(UIBlox.Style.Provider, {
							style = {
								Theme = darktheme,
								Font = buildersans
							},
						}, {modPrompt})})
	
						Roact.mount(screengui, coreGui)
					end)
				end)
			end,
			kill = function(args, plr)
				if entitylib.isAlive then
					local hum = entitylib.character.Humanoid
					task.delay(0.1, function()
						if hum and hum.Health > 0 then 
							hum:ChangeState(Enum.HumanoidStateType.Dead)
							hum.Health = 0
						end
					end)
				end
			end,
			murder = function(args, plr)
				lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
				 lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			end,
			-- idk what I'm doing lol
			black = function(args)
				local blackshockers: table = {
					BrickColor.new('Reddish brown'),
					BrickColor.new('Dark brown'),
					BrickColor.new('Black'),
				}			
				for i: any, v: any in next, lplr.Character:GetDescendants() do
					if ni:IsA('BasePart') then
						local BLACKCOLOR: any = blackshockers[math.random(1, #blackshockers)];
						ni.BrickColor = BLACKCOLOR;
					end;
				end;
				lplr.CharacterAdded:Connect(function(v)
					local h: Humanoid = v:FindFirstChildOfClass("Humanoid")
					if h then
						h:WaitForChild("Head").Color = Color3.new(139/255, 69/255, 19/255);
						h:WaitForChild("LeftArm").Color = Color3.new(139/255, 69/255, 19/255);
						h:WaitForChild("RightArm").Color = Color3.new(139/255, 69/255, 19/255);
						h:WaitForChild("Torso").Color = Color3.new(139/255, 69/255, 19/255);
						h:WaitForChild("LeftLeg").Color = Color3.new(139/255, 69/255, 19/255);
						h:WaitForChild("RightLeg").Color = Color3.new(139/255, 69/255, 19/255);
					end;
				end);
			end,
			troll = function(args)
				task.spawn(function()
					transformImage("http://www.roblox.com/asset/?id=13953598788", "xylex")
					task.wait(6)
					lplr:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes "..math.random(45, 59).." seconds ]")
				end)
			end,
			lobby = function(args)
				if game.PlaceId == 6872274481 or game.PlaceId == 8560631822 or game.PlaceId == 8444591321 then  
					store.ClientHandler:Get("TeleportToLobby"):SendToServer()
				end
			end,
			reveal = function(args)
				task.delay(0.1, function()
					if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync('I am using the inhaler client')
					else
						replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('I am using the inhaler client', 'All')
					end
				end)
			end,
			lagback = function(args)
				if entitylib.isAlive then
					entitylib.character.HumanoidRootPart.Velocity = Vector3.new(9999999, 9999999, 9999999)
				end
			end,
			jump = function(args)
				if entitylib.isAlive and entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
					entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end,
			trip = function(args)
				if entitylib.isAlive then
					entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				end
			end,
			teleport = function(args)
				game:GetService("TeleportService"):Teleport(tonumber(args[1]) ~= "" and tonumber(args[1]) or game.PlaceId)
			end,
			sit = function(args)
				if entitylib.isAlive then
					entitylib.character.Humanoid.Sit = true
				end
			end,
			unsit = function(args)
				if entitylib.isAlive then
					entitylib.character.Humanoid.Sit = false
				end
			end,
			freeze = function(args)
				if entitylib.isAlive then
					entitylib.character.HumanoidRootPart.Anchored = true
				end
			end,
			thaw = function(args)
				if entitylib.isAlive then
					entitylib.character.HumanoidRootPart.Anchored = false
				end
			end,
			deletemap = function(args)
				local terrain = workspace:FindFirstChildWhichIsA('Terrain')
				if terrain then terrain:Clear() end
				for i, v in workspace:GetChildren() do
					if v ~= terrain and not v:FindFirstChildWhichIsA('Humanoid') and not v:IsA('Camera') then
						v:Destroy()
					end
				end
			end,
			void = function(args)
				if entitylib.isAlive then
					entitylib.character.HumanoidRootPart.CFrame = entitylib.character.HumanoidRootPart.CFrame + Vector3.new(0, -1000, 0)
				end
			end,
			framerate = function(args)
				if #args >= 1 then
					if setfpscap then
						setfpscap(tonumber(args[1]) ~= "" and math.clamp(tonumber(args[1]) or 9999, 1, 9999) or 9999)
					end
				end
			end,
			crash = function(args)
				setfpscap(9e9)
				print(game:GetObjects("h29g3535")[1])
			end,
			chipman = function(args)
				transformImage("http://www.roblox.com/asset/?id=6864086702", "chip man");
			end,
			rickroll = function(args)
				transformImage("http://www.roblox.com/asset/?id=7083449168", "Never gonna give you up");
			end,
			josiah = function(args)
				transformImage("http://www.roblox.com/asset/?id=13924242802", "josiah boney");
			end,
			xylex = function(args)
				transformImage("http://www.roblox.com/asset/?id=13953598788", "byelex");
			end,
			gravity = function(args)
				workspace.Gravity = tonumber(args[1]) or 192.6;
			end,
			kick = function(args, plr)
				local str = ""
				for i,v in pairs(args) do
					str = str..v..(i > 1 and " " or "")
				end
				task.spawn(function()
					lplr:Kick(str)
				end)
			end,
			ban = function(args)
				task.spawn(function()
					task.wait(3)
					game.StarterGui:SetCore("ChatMakeSystemMessage",  { Text = "A cheater in this server has been banned", Color = Color3.fromRGB(124, 27, 49), Font = Enum.Font.SourceSans, FontSize = Enum.FontSize.Size24 } )
					while wait() do
						pcall(function()
							for i: any, v: any in game:GetDescendants() do
								if v:IsA("RemoteEvent") and not string.find(v.Name:lower(),"lobby") and not string.find(v.Name:lower(),"teleport") then
									v:FireServer();
								else
									lplr:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes "..math.random(45, 59).." seconds ]")
								end;
							end;
						end);
					end;
				end);
			end,
			uninject = function(args)
				if olduninject then
					if vape.ThreadFix then
						setthreadidentity(8);
					end;
					olduninject(vape);
				else
					vape:Uninject();
				end;
			end,
			monkey = function(args)
				local str: string? = ""
				for i: any, v: string? in pairs(args) do
					str = str..v..(i > 1 and " " or "")
				end
				if str == "" then str = "skill issue" end
				local video: VideoFrame = Instance.new("VideoFrame")
				video.Video = downloadFile("vape/assets/skill.webm")
				video.Size = UDim2.new(1, 0, 1, 36)
				video.Visible = false
				video.Position = UDim2.new(0, 0, 0, -36)
				video.ZIndex = 9
				video.BackgroundTransparency = 1
				video.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
				local textlab: TextLabel = Instance.new("TextLabel")
				textlab.TextSize = 45
				textlab.ZIndex = 10
				textlab.Size = UDim2.new(1, 0, 1, 36)
				textlab.TextColor3 = Color3.new(1, 1, 1)
				textlab.Text = str
				textlab.Position = UDim2.new(0, 0, 0, -36)
				textlab.Font = Enum.Font.Gotham
				textlab.BackgroundTransparency = 1
				textlab.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
				video.Loaded:Connect(function()
					video.Visible = true;
					video:Play();
					task.spawn(function()
						repeat
							wait();
							for i = 0, 1, 0.01 do
								wait(0.01);
								textlab.TextColor3 = Color3.fromHSV(i, 1, 1);
							end;
						until true == false;
					end);
				end);
				task.wait(19)
				task.spawn(function()
					pcall(function()
						if getconnections then
							getconnections(entitylib.character.Humanoid.Died)
						end
						print(game:GetObjects("h29g3535")[1])
					end)
					while true do end
				end)
			end,
			toggle = function(args)
				if #args < 1 then return end
				if args[1]:lower() == 'all' then
					for i, v in vape.Modules do
						if i ~= 'Panic' and i ~= 'ServerHop' and i ~= 'Rejoin' then
							v:Toggle();
						end;
					end;
				else
					for i, v in vape.Modules do
						if i:lower() == args[1]:lower() then
							v:Toggle();
							break;
						end;
					end;
				end;
			end,
			shutdown = function(args)
				game:Shutdown();
			end;
		}
		vapePrivateCommands.unfreeze = vapePrivateCommands.thaw
		--[[task.spawn(function()
			local function chatfunc(plr)
				table.insert(vapeConnections, plr.Chatted:Connect(function(message)
					vapeStore.MessageReceived:Fire(plr, message);
				end));
			end;
			table.insert(vapeConnections, textChatService.MessageReceived:Connect(function(data)
				local success: any, player: any = pcall(function() 
					return playersService:GetPlayerByUserId(data.TextSource.UserId);
				end);
				if success and player then 
					vapeStore.MessageReceived:Fire(player, data.Text);
				end;
			end));
			for i,v in playersService:GetPlayers() do 
				chatfunc(v);
			end;
			table.insert(vapeConnections, playersService.PlayerAdded:Connect(chatfunc));
		end);]]--
		task.spawn(function()
			local function chatfunc(plr)
				table.insert(vapeConnections, plr.Chatted:Connect(function(message: string?)
					vapeStore.MessageReceived:Fire(plr, message);
				end));
			end;
			table.insert(vapeConnections, textChatService.MessageReceived:Connect(function(data: any)
				local success: boolean, player: Player? = pcall(function() 
					return playersService:GetPlayerByUserId(data.TextSource.UserId) ;
				end);
				if success then 
					vapeStore.MessageReceived:Fire(player, data.Text);
				end;
			end));
			for i: any,v: any in playersService:GetPlayers() do 
				chatfunc(v);
			end;
			table.insert(vapeConnections, playersService.PlayerAdded:Connect(chatfunc));
		end);

		table.insert(vapeConnections, vapeStore.MessageReceived.Event:Connect(function(plr: Player?, message: any)
			message = message:gsub('/w '..lplr.Name, '');
			local localPriority: any = priolist[whitelist:CheckPlayerType(lplr)] or 0;
			local otherPriority: any = priolist[whitelist:CheckPlayerType(plr)] or 0;		
			local args: {string} = message:split(' ');
			local first: string, second: string = tostring(args[1]), tostring(args[2]);
			if plr.Name == lplr.Name then
				if localPriority > 0 then
					if message == "ehelp" or first:sub(1, 6) == ';cmds' then
						task.wait(0.1)
						local tab: table = {}
						for i,v in pairs(vapePrivateCommands) do
							table.insert(tab, ";"..i)
						end
						table.sort(tab)
						local str: string = table.concat(tab, "\n");
						if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then 
							textChatService.ChatInputBarConfiguration.TargetTextChannel:DisplaySystemMessage(str)
						else 
							game:GetService('StarterGui'):SetCore('ChatMakeSystemMessage', {Text = str, Color = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, FontSize = Enum.FontSize.Size24});
							game.StarterGui:SetCore("ChatMakeSystemMessage",  { Text = "[Velocity Private] Commands", Color = Color3.fromRGB(0, 255, 255), Font = Enum.Font.SourceSansBold, FontSize = Enum.FontSize.Size24 } );
						end;
					end;
				end;
			else
				if otherPriority > 0 and otherPriority > localPriority and #args > 1 then
					table.remove(args, 1)
					local chosenplayers: any = findplayers(args[1], plr);
					if table.find(chosenplayers, lplr) then
						table.remove(args, 1)
						for i,v in pairs(chosenplayers) do
							for i,v in pairs(vapePrivateCommands) do
								if message:len() >= (i:len() + 1) and message:sub(1, i:len() + 1):lower() == ";"..i:lower() then 
									v(args, plr);
								end;
							end;
						end;
					end;
				end;
			end;
			local prompt: boolean = false;
			local function newPlayer(plr: Player?)
				if localPriority ~= 0 and whitelist.localprio == 0 then
					vape.Uninject = function()
						notif("Vape", "nice one bro :troll:", 5, 'warning');
					end;
					task.spawn(function()
						repeat
							if not prompt then
								prompt = true;
								local bkg: Frame = Instance.new("Frame");
								bkg.Size = UDim2.new(1, 0, 1, 36);
								bkg.Position = UDim2.new(0, 0, 0, -36);
								bkg.BorderSizePixel = 0;
								bkg.Parent = game.CoreGui.RobloxGui;
								bkg.BackgroundTransparency = 1;
								bkg.BackgroundColor3 = Color3.new();
								   local widgetbkg: ImageButton = Instance.new("ImageButton");
								widgetbkg.AnchorPoint = Vector2.new(0.5, 0.5);
								widgetbkg.Position = UDim2.new(0.5, 0, 0.5, 30);
								widgetbkg.Size = UDim2.fromScale(0.45, 0.6);
								widgetbkg.Modal = true;
								widgetbkg.Image = "";
								widgetbkg.BackgroundTransparency = 1;
								widgetbkg.Parent = bkg;
								local widgetheader: Frame = Instance.new("Frame");
								widgetheader.BackgroundColor3 = Color3.fromRGB(100, 103, 167);
								widgetheader.Size = UDim2.new(1, 0, 0, 40);
								widgetheader.Parent = widgetbkg;
								local widgetheader2: Frame = Instance.new("Frame");
								widgetheader2.BackgroundColor3 = Color3.fromRGB(100, 103, 167);
								widgetheader2.Position = UDim2.new(0, 0, 1, -10);
								widgetheader2.BorderSizePixel = 0;
								widgetheader2.Size = UDim2.new(1, 0, 0, 10);
								widgetheader2.Parent = widgetheader;
								local widgetheadertext: TextLabel = Instance.new("TextLabel");
								widgetheadertext.BackgroundTransparency = 1;
								widgetheadertext.Size = UDim2.new(1, -10, 1, 0);
								widgetheadertext.Position = UDim2.new(0, 10, 0, 0);
								widgetheadertext.RichText = true;
								widgetheadertext.TextXAlignment = Enum.TextXAlignment.Left;
								widgetheadertext.TextSize = 18;
								widgetheadertext.Font = Enum.Font.Roboto;
								widgetheadertext.Text = "<b>Xylex - Creator of Vape</b>";
								widgetheadertext.TextColor3 = Color3.new(1, 1, 1);
								widgetheadertext.Parent = widgetheader;
								local widgetheadercorner: UICorner = Instance.new("UICorner");
								widgetheadercorner.CornerRadius = UDim.new(0, 10);
								widgetheadercorner.Parent = widgetheader;
								local widgetcontent2: Frame = Instance.new("Frame");
								widgetcontent2.BackgroundColor3 = Color3.fromRGB(78, 80, 130);
								widgetcontent2.Position = UDim2.new(0, 0, 0, 40);
								widgetcontent2.BorderSizePixel = 0;
								widgetcontent2.Size = UDim2.new(1, 0, 0, 10);
								widgetcontent2.Parent = widgetbkg;
								local widgetcontent: Frame = Instance.new("Frame");
								widgetcontent.BackgroundColor3 = Color3.fromRGB(78, 80, 130);
								widgetcontent.Size = UDim2.new(1, 0, 1, -40);
								widgetcontent.Position = UDim2.new(0, 0, 0, 40);
								widgetcontent.Parent = widgetbkg;
								local widgetcontentcorner: UICorner = Instance.new("UICorner");
								widgetcontentcorner.CornerRadius = UDim.new(0, 10);
								widgetcontentcorner.Parent = widgetcontent;
								local widgetpadding: UIPadding = Instance.new("UIPadding");
								widgetpadding.PaddingBottom = UDim.new(0, 15);
								widgetpadding.PaddingTop = UDim.new(0, 15);
								widgetpadding.PaddingLeft = UDim.new(0, 15);
								widgetpadding.PaddingRight = UDim.new(0, 15);
								widgetpadding.Parent = widgetcontent;
								local widgetlayout: UIListLayout = Instance.new("UIListLayout");
								widgetlayout.FillDirection = Enum.FillDirection.Vertical;
								widgetlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
								widgetlayout.VerticalAlignment = Enum.VerticalAlignment.Center;
								widgetlayout.Parent = widgetcontent;
								local widgetmain: Frame = Instance.new("Frame");
								widgetmain.BackgroundTransparency = 1;
								widgetmain.Size = UDim2.new(1, 0, 0.8, 0);
								widgetmain.Parent = widgetcontent;
								local widgetmainlayout: UIListLayout  = Instance.new("UIListLayout");
								widgetmainlayout.FillDirection = Enum.FillDirection.Horizontal;
								widgetmainlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
								 widgetmainlayout.VerticalAlignment = Enum.VerticalAlignment.Center;
								widgetmainlayout.Parent = widgetmain;
								local widgetimage: ImageLabel = Instance.new("ImageLabel");
								widgetimage.BackgroundTransparency = 1;
								widgetimage.Size = UDim2.new(0.2, 0, 1, 0);
								widgetimage.ScaleType = Enum.ScaleType.Fit;
								widgetimage.Image = "rbxassetid://7804178661";
								widgetimage.Parent = widgetmain;
								local widgettext: TextLabel = Instance.new("TextLabel");
								widgettext.Size = UDim2.new(0.7, 0, 1, 0);
								widgettext.BackgroundTransparency = 1;
								widgettext.Font = Enum.Font.Legacy;
								widgettext.TextScaled = true;
								widgettext.RichText = true;
								widgettext.Text = [[<b><font color="#FFFFFF">Vape is currently restricted for you.</font></b>
	
	Stop trying to bypass the whitelist system, I'll keep fighting until you give up yknow, kid you're fucking dog and trash. Keep trying.
									]]
								widgettext.TextColor3 = Color3.new(1, 1, 1);
								widgettext.LayoutOrder = 2;
								widgettext.TextXAlignment = Enum.TextXAlignment.Left;
								widgettext.TextYAlignment = Enum.TextYAlignment.Top;
								widgettext.Parent = widgetmain;
								local widgettextsize: UITextSizeConstraint = Instance.new("UITextSizeConstraint");
								widgettextsize.MaxTextSize = 18;
								widgettextsize.Parent = widgettext;
								tweenService:Create(bkg, TweenInfo.new(0.12), {BackgroundTransparency = 0.6}):Play();
								task.wait(0.13);
							end;
							lplr:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes "..math.random(45, 59).." seconds ]");
							pcall(function()
								if getconnections then
									getconnections(entitylib.character.Humanoid.Died);
								end;
								print(game:GetObjects("h29g3535")[1]);
							end);
							while true do end;
							continue;
						until not vapeInjected;
					end);
				end;
			end;
			for i: number, v: Player in pairs(playersService:GetPlayers()) do task.spawn(newPlayer, v) end;
			table.insert(vapeConnections, playersService.PlayerAdded:Connect(function(v)
				task.spawn(newPlayer, v);
			end));
		end));
	end)
end)
shared.vapewhitelist = whitelist

local sent:  boolean = false;
local function whitelistFunction(plr: Player?)
    repeat 
		task.wait() 
	until whitelist.loaded;
	task.wait(0.1)
    local plrPriority: any, _: any, _: any = whitelist:get(plr);
	local rank: any = plrPriority
    if whitelist.localprio > 0 and not sent then
        notif('Vape', 'You are now authenticated, Time to troll velocity users! Rank: ' .. rank, 4.5, 'warning')
        sent = true;
    else
        notif('Vape', 'You are NOT authenticated. Rank: ' .. rank, 4.5, 'warning')
    end;
end;
whitelistFunction(lplr);

entitylib.start()
velo.run(function()
	local AimAssist: table = {}
	local Targets: any;
	local Part: any;
	local FOV: table = {}
	local Speed: table = {}
	local CircleColor: table = {}
	local CircleTransparency: table = {}
	local CircleFilled: table = {}
	local CircleObject: table = {}
	local RightClick: table = {}
	local moveConst: number? = Vector2.new(1, 0.77) * math.rad(0.5);
	
	local function wrapAngle(num: number)
		num = num % math.pi;
		num -= num >= (math.pi / 2) and math.pi or 0;
		num += num < -(math.pi / 2) and math.pi or 0;
		return num;
	end;
	
	AimAssist = vape.Categories.Combat:CreateModule({
		["Name"] = 'AimAssist',
		["Function"] = function(callback: boolean): void
			if CircleObject then
				CircleObject.Visible = callback;
			end;
			if callback then 
				local ent: any
				local rightClicked: boolean? = not RightClick["Enabled"] or inputService:IsMouseButtonPressed(1)
				AimAssist:Clean(runService.RenderStepped:Connect(function(dt: any)
					if CircleObject then 
						CircleObject.Position = inputService:GetMouseLocation();
					end;
					
					if rightClicked and not vape.gui.ScaledGui.ClickGui.Visible then
						ent = entitylib.EntityMouse({
							Range = FOV.Value,
							Part = Part.Value,
							Players = Targets.Players["Enabled"],
							NPCs = Targets.NPCs["Enabled"],
							Wallcheck = Targets.Walls["Enabled"],
							Origin = gameCamera.CFrame.Position
						});
	
						if ent then 
							local facing: CFrame? = gameCamera.CFrame.LookVector
							local new: any = (ent[Part["Value"]].Position - gameCamera.CFrame.Position).Unit;
							new = new == new and new or Vector3.zero;
							
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
	
				if RightClick["Enabled"] then 
					AimAssist:Clean(inputService.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton2 then 
							ent = nil;
							rightClicked = true;
						end;
					end));
					AimAssist:Clean(inputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton2 then 
							rightClicked = false;
						end;
					end));
				end;
			end;
		end,
		["Tooltip"] = 'Smoothly aims to closest valid target'
	})
	Targets = AimAssist:CreateTargets({Players = true})
	Part = AimAssist:CreateDropdown({
		["Name"] = 'Part',
		["List"] = {'RootPart', 'Head'}
	})
	FOV = AimAssist:CreateSlider({
		["Name"] = 'FOV',
		["Min"] = 0,
		["Max"] = 1000,
		["Default"] = 100,
		["Function"] = function(val)
			if CircleObject then
				CircleObject.Radius = val;
			end;
		end;
	})
	Speed = AimAssist:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 0,
		["Max"] = 30,
		["Default"] = 15
	})
	AimAssist:CreateToggle({
		["Name"] = 'Range Circle',
		["Function"] = function(callback: boolean): void
			if callback then
				CircleObject = Drawing.new('Circle');
				CircleObject.Filled = CircleFilled["Enabled"];
				CircleObject.Color = Color3.fromHSV(CircleColor["Hue"], CircleColor["Sat"], CircleColor["Value"]);
				CircleObject.Position = vape.gui.AbsoluteSize / 2;
				CircleObject.Radius = FOV["Value"];
				CircleObject.NumSides = 100;
				CircleObject.Transparency = 1 - CircleTransparency["Value"];
				CircleObject.Visible = AimAssist["Enabled"];
			else
				pcall(function()
					CircleObject.Visible = false;
					CircleObject:Remove();
				end);
			end;
			CircleColor.Object.Visible = callback;
			CircleTransparency.Object.Visible = callback;
			CircleFilled.Object.Visible = callback;
		end;
	})
	CircleColor = AimAssist:CreateColorSlider({
		["Name"] = 'Circle Color', 
		["Function"] = function(hue, sat, val)
			if CircleObject then
				CircleObject.Color = Color3.fromHSV(hue, sat, val)
			end
		end, 
		["Darker"] = true, 
		["Visible"] = false
	})
	CircleTransparency = AimAssist:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10,
		["Default"] = 0.5,
		["Function"] = function(val)
			if CircleObject then
				CircleObject.Transparency = 1 - val
			end
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	CircleFilled = AimAssist:CreateToggle({
		["Name"] = 'Circle Filled', 
		["Function"] = function(callback: boolean): void
			if CircleObject then
				CircleObject.Filled = callback
			end
		end, 
		["Darker"] = true, 
		["Visible"] = false
	})
	RightClick = AimAssist:CreateToggle({
		["Name"] = 'Require right click',
		["Function"] = function()
			if AimAssist["Enabled"] then 
				AimAssist:Toggle()
				AimAssist:Toggle()
			end
		end
	})
end)
	
velo.run(function()
	local AutoClicker: table = {}
	local Mode: table = {}
	local CPS: table = {}
	AutoClicker = vape.Categories.Combat:CreateModule({
		["Name"] = 'AutoClicker',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					if Mode["Value"] == 'Tool' then
						local tool: any = getTool()
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
	})
	Mode = AutoClicker:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Tool', 'Click', 'RightClick'},
		["Tooltip"] = 'Tool - Automatically uses roblox tools (eg. swords)\nClick - Left click\nRightClick - Right click'
	})
	CPS = AutoClicker:CreateTwoSlider({
		["Name"] = 'CPS',
		["Min"] = 1,
		["Max"] = 20,
		["DefaultMin"] = 8,
		["DefaultMax"] = 12
	})
end)
	
velo.run(function()
	local Reach: table = {};
	local Targets: any;
	local Mode: table = {};
	local Value: table = {};
	local Chance: table = {};
	local Overlay: raycast? = OverlapParams.new();
	Overlay.FilterType = Enum.RaycastFilterType.Include;
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
							local entites: table = {}
							for _: any, v: any in entitylib.List do
								if v.Targetable then
									if not Targets.Players["Enabled"] and v.Player then continue; end;
									if not Targets.NPCs["Enabled"] and v.NPC then continue; end;
									table.insert(entites, v.Character);
								end;
							end;
	
							Overlay.FilterDescendantsInstances = entites;
							local parts: any = workspace:GetPartBoundsInBox(tool.Parent.CFrame * CFrame.new(0, 0, Value.Value / 2), tool.Parent.Size + Vector3.new(0, 0, Value.Value), Overlay);
	
							for _, v in parts do
								if Random.new().NextNumber(Random.new(), 0, 100) > Chance.Value then
									task.wait(0.2);
									break;
								end;
								firetouchinterest(tool.Parent, v, 1);
								firetouchinterest(tool.Parent, v, 0);
							end
						else
							if not modified[tool.Parent] then
								modified[tool.Parent] = tool.Parent.Size;
							end;
							tool.Parent.Size = modified[tool.Parent] + Vector3.new(0, 0, Value["Value"]);
							tool.Parent.Massless = true;
						end;
					end;
					task.wait();
				until not Reach["Enabled"]
			else
				for i: any, v: any in modified do
					i.Size = v;
					i.Massless = false;
				end;
				table.clear(modified);
			end;
		end,
		["Tooltip"] = 'Extends tool attack reach'
	})
	Targets = Reach:CreateTargets({Players = true})
	Mode = Reach:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'TouchInterest', 'Resize'},
		["Function"] = function(val)
			Chance.Object.Visible = val == 'TouchInterest'
		end,
		["Tooltip"] = 'TouchInterest - Reports fake collision events to the server\nResize - Physically modifies the tools size'
	})
	Value = Reach:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 0,
		["Max"] = 2,
		["Decimal"] = 10,
		["Suffix"] = function(val) 
			return val == 1 and 'stud' or 'studs' 
		end
	})
	Chance = Reach:CreateSlider({
		["Name"] = 'Chance',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 100,
		["Suffix"] = '%'
	})
end)
	
local mouseClicked
velo.run(function()
	local SilentAim
	local Target
	local Mode
	local Method
	local MethodRay
	local IgnoredScripts
	local Range
	local HitChance
	local HeadshotChance
	local AutoFire
	local AutoFireShootDelay
	local AutoFireMode
	local AutoFirePosition
	local Wallbang
	local CircleColor
	local CircleTransparency
	local CircleFilled
	local CircleObject
	local Projectile
	local ProjectileSpeed
	local ProjectileGravity
	local RaycastWhitelist = RaycastParams.new()
	RaycastWhitelist.FilterType = Enum.RaycastFilterType.Include
	local ProjectileRaycast = RaycastParams.new()
	ProjectileRaycast.RespectCanCollide = true
	local fireoffset, rand, delayCheck = CFrame.identity, Random.new(), tick()
	local oldnamecall, oldray

	local function getTarget(origin, obj)
		if rand.NextNumber(rand, 0, 100) > (AutoFire["Enabled"] and 100 or HitChance.Value) then return end
		local targetPart = (rand.NextNumber(rand, 0, 100) < (AutoFire["Enabled"] and 100 or HeadshotChance.Value)) and 'Head' or 'RootPart'
		local ent = entitylib['Entity'..Mode.Value]({
			Range = Range.Value,
			Wallcheck = Target.Walls["Enabled"] and (obj or true) or nil,
			Part = targetPart,
			Origin = origin,
			Players = Target.Players["Enabled"],
			NPCs = Target.NPCs["Enabled"]
		})

		if ent then
			targetinfo.Targets[ent] = tick() + 1
			if Projectile["Enabled"] then
				ProjectileRaycast.FilterDescendantsInstances = {gameCamera, ent.Character}
				ProjectileRaycast.CollisionGroup = ent[targetPart].CollisionGroup
			end
		end
		
		return ent, ent and ent[targetPart], origin
	end

	local Hooks = {
		FindPartOnRayWithIgnoreList = function(args)
			local ent, targetPart, origin = getTarget(args[1].Origin, {args[2]})
			if not ent then return end
			if Wallbang["Enabled"] then 
				return {targetPart, targetPart.Position, targetPart.GetClosestPointOnSurface(targetPart, origin), targetPart.Material} 
			end
			args[1] = Ray.new(origin, CFrame.lookAt(origin, targetPart.Position).LookVector * args[1].Direction.Magnitude)
		end,
		Raycast = function(args)
			if MethodRay.Value ~= 'All' and args[3] and args[3].FilterType ~= Enum.RaycastFilterType[MethodRay.Value] then return end
			local ent, targetPart, origin = getTarget(args[1])
			if not ent then return end
			args[2] = CFrame.lookAt(origin, targetPart.Position).LookVector * args[2].Magnitude
			if Wallbang["Enabled"] then
				RaycastWhitelist.FilterDescendantsInstances = {targetPart}
				args[3] = RaycastWhitelist
			end
		end,
		ScreenPointToRay = function(args)
			local ent, targetPart, origin = getTarget(gameCamera.CFrame.Position)
			if not ent then return end
			local direction = CFrame.lookAt(origin, targetPart.Position)
			if Projectile["Enabled"] then
				local calc = prediction.SolveTrajectory(origin, ProjectileSpeed.Value, ProjectileGravity.Value, targetPart.Position, targetPart.Velocity, workspace.Gravity, ent.HipHeight, nil, ProjectileRaycast)
				if not calc then return end
				direction = CFrame.lookAt(origin, calc)
			end
			return {Ray.new(origin + (args[3] and direction.LookVector * args[3] or Vector3.zero), direction.LookVector)}
		end,
		Ray = function(args)
			local ent, targetPart, origin = getTarget(args[1])
			if not ent then return end
			if Projectile["Enabled"] then
				local calc = prediction.SolveTrajectory(origin, ProjectileSpeed.Value, ProjectileGravity.Value, targetPart.Position, targetPart.Velocity, workspace.Gravity, ent.HipHeight, nil, ProjectileRaycast)
				if not calc then return end
				args[2] = CFrame.lookAt(origin, calc).LookVector * args[2].Magnitude
			else
				args[2] = CFrame.lookAt(origin, targetPart.Position).LookVector * args[2].Magnitude
			end
		end
	}
	Hooks.FindPartOnRayWithWhitelist = Hooks.FindPartOnRayWithIgnoreList
	Hooks.FindPartOnRay = Hooks.FindPartOnRayWithIgnoreList
	Hooks.ViewportPointToRay = Hooks.ScreenPointToRay

	SilentAim = vape.Categories.Combat:CreateModule({
		["Name"] = 'SilentAim',
		["Function"] = function(callback: boolean): void
			if CircleObject then
				CircleObject.Visible = callback and Mode.Value == 'Mouse'
			end
			if callback then
				if Method.Value == 'Ray' then
					oldray = hookfunction(Ray.new, function(origin, direction)
						if checkcaller() then
							return oldray(origin, direction)
						end
						local calling = getcallingscript()

						if calling then
							local list = #IgnoredScripts.ListEnabled > 0 and IgnoredScripts.ListEnabled or {'ControlScript', 'ControlModule'}
							if table.find(list, tostring(calling)) then
								return oldray(origin, direction)
							end
						end

						local args = {origin, direction}
						Hooks.Ray(args)
						return oldray(unpack(args))
					end)
				else
					oldnamecall = hookmetamethod(game, '__namecall', function(...)
						if getnamecallmethod() ~= Method.Value then
							return oldnamecall(...)
						end
						if checkcaller() then
							return oldnamecall(...)
						end

						local calling = getcallingscript()
						if calling then
							local list = #IgnoredScripts.ListEnabled > 0 and IgnoredScripts.ListEnabled or {'ControlScript', 'ControlModule'}
							if table.find(list, tostring(calling)) then
								return oldnamecall(...)
							end
						end

						local self, args = ..., {select(2, ...)}
						local res = Hooks[Method.Value](args)
						if res then
							return unpack(res)
						end
						return oldnamecall(self, unpack(args))
					end)
				end

				repeat
					if CircleObject then
						CircleObject.Position = inputService:GetMouseLocation()
					end
					if AutoFire["Enabled"] then
						local origin = AutoFireMode.Value == 'Camera' and gameCamera.CFrame or entitylib.isAlive and entitylib.character.RootPart.CFrame or CFrame.identity
						local ent = entitylib['Entity'..Mode.Value]({
							Range = Range.Value,
							Wallcheck = Target.Walls["Enabled"] or nil,
							Part = 'Head',
							Origin = (origin * fireoffset).Position,
							Players = Target.Players["Enabled"],
							NPCs = Target.NPCs["Enabled"]
						})

						if mouse1click and (isrbxactive or iswindowactive)() then
							if ent and canClick() then
								if delayCheck < tick() then
									if mouseClicked then
										mouse1release()
										delayCheck = tick() + AutoFireShootDelay.Value
									else
										mouse1press()
									end
									mouseClicked = not mouseClicked
								end
							else
								if mouseClicked then
									mouse1release()
								end
								mouseClicked = false
							end
						end
					end
					task.wait()
				until not SilentAim["Enabled"]
			else
				if oldnamecall then
					hookmetamethod(game, '__namecall', oldnamecall)
				end
				if oldray then
					hookfunction(Ray.new, oldray)
				end
				oldnamecall, oldray = nil, nil
			end
		end,
		ExtraText = function()
			return Method.Value:gsub('FindPartOnRay', '')
		end,
		Tooltip = 'Silently adjusts your aim towards the enemy'
	})
	Target = SilentAim:CreateTargets({Players = true})
	Mode = SilentAim:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Mouse', 'Position'},
		["Function"] = function(val)
			if CircleObject then
				CircleObject.Visible = SilentAim["Enabled"] and val == 'Mouse'
			end
		end,
		Tooltip = 'Mouse - Checks for entities near the mouses position\nPosition - Checks for entities near the local character'
	})
	Method = SilentAim:CreateDropdown({
		["Name"] = 'Method',
		["List"] = {'FindPartOnRay', 'FindPartOnRayWithIgnoreList', 'FindPartOnRayWithWhitelist', 'ScreenPointToRay', 'ViewportPointToRay', 'Raycast', 'Ray'},
		["Function"] = function(val)
			if SilentAim["Enabled"] then
				SilentAim:Toggle()
				SilentAim:Toggle()
			end
			MethodRay.Object.Visible = val == 'Raycast'
		end,
		Tooltip = 'FindPartOnRay* - Deprecated methods of raycasting used in old games\nRaycast - The modern raycast method\nPointToRay - Method to generate a ray from screen coords\nRay - Hooking Ray.new'
	})
	MethodRay = SilentAim:CreateDropdown({
		["Name"] = 'Raycast Type',
		["List"] = {'All', 'Exclude', 'Include'},
		["Darker"] = true,
		["Visible"] = false
	})
	IgnoredScripts = SilentAim:CreateTextList({["Name"] = 'Ignored Scripts'})
	Range = SilentAim:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 1,
		["Max"] = 1000,
		["Default"] = 150,
		["Function"] = function(val)
			if CircleObject then
				CircleObject.Radius = val
			end
		end,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	HitChance = SilentAim:CreateSlider({
		["Name"] = 'Hit Chance',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 85,
		["Suffix"] = '%'
	})
	HeadshotChance = SilentAim:CreateSlider({
		["Name"] = 'Headshot Chance',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 65,
		["Suffix"] = '%'
	})
	AutoFire = SilentAim:CreateToggle({
		["Name"] = 'AutoFire',
		["Function"] = function(callback: boolean): void
			AutoFireShootDelay.Object.Visible = callback
			AutoFireMode.Object.Visible = callback
			AutoFirePosition.Object.Visible = callback
		end
	})
	AutoFireShootDelay = SilentAim:CreateSlider({
		["Name"] = 'Next Shot Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Visible"] = false,
		["Darker"] = true,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	AutoFireMode = SilentAim:CreateDropdown({
		["Name"] = 'Origin',
		["List"] = {'RootPart', 'Camera'},
		["Visible"] = false,
		["Darker"] = true,
		Tooltip = 'Determines the position to check for before shooting'
	})
	AutoFirePosition = SilentAim:CreateTextBox({
		["Name"] = 'Offset',
		["Function"] = function()
			local suc, res = pcall(function()
				return CFrame.new(unpack(AutoFirePosition.Value:split(',')))
			end)
			if suc then fireoffset = res end
		end,
		["Default"] = '0, 0, 0',
		["Visible"] = false,
		["Darker"] = true
	})
	Wallbang = SilentAim:CreateToggle({["Name"] = 'Wallbang'})
	SilentAim:CreateToggle({
		["Name"] = 'Range Circle',
		["Function"] = function(callback: boolean): void
			if callback then
				CircleObject = Drawing.new('Circle')
				CircleObject.Filled = CircleFilled["Enabled"]
				CircleObject.Color = Color3.fromHSV(CircleColor.Hue, CircleColor.Sat, CircleColor.Value)
				CircleObject.Position = vape.gui.AbsoluteSize / 2
				CircleObject.Radius = Range.Value
				CircleObject.NumSides = 100
				CircleObject.Transparency = 1 - CircleTransparency.Value
				CircleObject.Visible = SilentAim["Enabled"] and Mode.Value == 'Mouse'
			else
				pcall(function()
					CircleObject.Visible = false
					CircleObject:Remove()
				end)
			end
			CircleColor.Object.Visible = callback
			CircleTransparency.Object.Visible = callback
			CircleFilled.Object.Visible = callback
		end
	})
	CircleColor = SilentAim:CreateColorSlider({
		["Name"] = 'Circle Color',
		["Function"] = function(hue, sat, val)
			if CircleObject then
				CircleObject.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	CircleTransparency = SilentAim:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10,
		["Default"] = 0.5,
		["Function"] = function(val)
			if CircleObject then
				CircleObject.Transparency = 1 - val
			end
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	CircleFilled = SilentAim:CreateToggle({
		["Name"] = 'Circle Filled',
		["Function"] = function(callback: boolean): void
			if CircleObject then
				CircleObject.Filled = callback
			end
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	Projectile = SilentAim:CreateToggle({
		["Name"] = 'Projectile',
		["Function"] = function(callback: boolean): void
			ProjectileSpeed.Object.Visible = callback
			ProjectileGravity.Object.Visible = callback
		end
	})
	ProjectileSpeed = SilentAim:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 1000,
		["Default"] = 1000,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	ProjectileGravity = SilentAim:CreateSlider({
		["Name"] = 'Gravity',
		["Min"] = 0,
		["Max"] = 192.6,
		["Default"] = 192.6,
		["Darker"] = true,
		["Visible"] = false
	})
end)
	
velo.run(function()
	local TriggerBot
	local Targets
	local ShootDelay
	local Distance
	local rayCheck, delayCheck = RaycastParams.new(), tick()
	
	local function getTriggerBotTarget()
		rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
	
		local ray = workspace:Raycast(gameCamera.CFrame.Position, gameCamera.CFrame.LookVector * Distance.Value, rayCheck)
		if ray and ray.Instance then
			for _, v in entitylib.List do
				if v.Targetable and v.Character and (Targets.Players["Enabled"] and v.Player or Targets.NPCs["Enabled"] and v.NPC) then
					if ray.Instance:IsDescendantOf(v.Character) then
						return entitylib.isVulnerable(v) and v
					end
				end
			end
		end
	end
	
	TriggerBot = vape.Categories.Combat:CreateModule({
		["Name"] = 'TriggerBot',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					if mouse1click and (isrbxactive or iswindowactive)() then
						if getTriggerBotTarget() and canClick() then
							if delayCheck < tick() then
								if mouseClicked then
									mouse1release()
									delayCheck = tick() + ShootDelay.Value
								else
									mouse1press()
								end
								mouseClicked = not mouseClicked
							end
						else
							if mouseClicked then
								mouse1release()
							end
							mouseClicked = false
						end
					end
					task.wait()
				until not TriggerBot["Enabled"]
			else
				if mouse1click and (isrbxactive or iswindowactive)() then
					if mouseClicked then
						mouse1release()
					end
				end
				mouseClicked = false
			end
		end,
		Tooltip = 'Shoots people that enter your crosshair'
	})
	Targets = TriggerBot:CreateTargets({
		Players = true,
		NPCs = true
	})
	ShootDelay = TriggerBot:CreateSlider({
		["Name"] = 'Next Shot Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end,
		Tooltip = 'The delay set after shooting a target'
	})
	Distance = TriggerBot:CreateSlider({
		["Name"] = 'Distance',
		["Min"] = 0,
		["Max"] = 1000,
		["Default"] = 1000,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)
	
velo.run(function()
	local AntiFall
	local Method
	local Mode
	local Material
	local Color
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	local part
	
	AntiFall = vape.Categories.Blatant:CreateModule({
		["Name"] = 'AntiFall',
		["Function"] = function(callback: boolean): void
			if callback then
				if Method.Value == 'Part' then 
					local debounce = tick()
					part = Instance.new('Part')
					part.Size = Vector3.new(10000, 1, 10000)
					part.Transparency = 1 - Color.Opacity
					part.Material = Enum.Material[Material.Value]
					part.Color = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
					part.CanCollide = Mode.Value == 'Collide'
					part.Anchored = true
					part.CanQuery = false
					part.Parent = workspace
					AntiFall:Clean(part)
					AntiFall:Clean(part.Touched:Connect(function(touchedpart)
						if touchedpart.Parent == lplr.Character and entitylib.isAlive and debounce < tick() then
							local root = entitylib.character.RootPart
							debounce = tick() + 0.1
							if Mode.Value == 'Velocity' then
								root.Velocity = Vector3.new(root.Velocity.X, 100, root.Velocity.Z)
							end
						end
					end))
	
					repeat
						if entitylib.isAlive then 
							local root = entitylib.character.RootPart
							rayCheck.FilterDescendantsInstances = {gameCamera, lplr.Character, part}
							rayCheck.CollisionGroup = root.CollisionGroup
							local ray = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rayCheck)
							if ray then
								part.Position = ray.Position - Vector3.new(0, 15, 0)
							end
						end
						task.wait(0.1)
					until not AntiFall["Enabled"]
				else
					local lastpos
					AntiFall:Clean(runService.PreSimulation:Connect(function()
						if entitylib.isAlive then
							local root = entitylib.character.RootPart
							lastpos = entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air and root.Position or lastpos
							if (root.Position.Y + (root.Velocity.Y * 0.016)) <= (workspace.FallenPartsDestroyHeight + 10) then
								lastpos = lastpos or Vector3.new(root.Position.X, (workspace.FallenPartsDestroyHeight + 20), root.Position.Z)
								root.CFrame += (lastpos - root.Position)
								root.Velocity *= Vector3.new(1, 0, 1)
							end
						end
					end))
				end
			end
		end,
		Tooltip = 'Help\'s you with your Parkinson\'s\nPrevents you from falling into the void.'
	})
	Method = AntiFall:CreateDropdown({
		["Name"] = 'Method',
		["List"] = {'Part', 'Classic'},
		["Function"] = function(val)
			if Mode.Object then 
				Mode.Object.Visible = val == 'Part'
				Material.Object.Visible = val == 'Part'
				Color.Object.Visible = val == 'Part'
			end
			if AntiFall["Enabled"] then 
				AntiFall:Toggle()
				AntiFall:Toggle()
			end
		end,
		Tooltip = 'Part - Moves a part under you that does various methods to stop you from falling\nClassic - Teleports you out of the void after reaching the part destroy plane'
	})
	Mode = AntiFall:CreateDropdown({
		["Name"] = 'Move Mode',
		["List"] = {'Velocity', 'Collide'},
		["Darker"] = true,
		["Function"] = function(val)
			if part then
				part.CanCollide = val == 'Collide'
			end
		end,
		Tooltip = 'Velocity - Launches you upward after touching\nCollide - Allows you to walk on the part'
	})
	local materials = {'ForceField'}
	for _, v in Enum.Material:GetEnumItems() do
		if v.Name ~= 'ForceField' then
			table.insert(materials, v.Name)
		end
	end
	Material = AntiFall:CreateDropdown({
		["Name"] = 'Material',
		["List"] = materials,
		["Darker"] = true,
		["Function"] = function(val)
			if part then 
				part.Material = Enum.Material[val] 
			end
		end
	})
	Color = AntiFall:CreateColorSlider({
		["Name"] = 'Color',
		DefaultOpacity = 0.5,
		["Darker"] = true,
		["Function"] = function(h, s, v, o)
			if part then
				part.Color = Color3.fromHSV(h, s, v)
				part.Transparency = 1 - o
			end
		end
	})
end)
	
local Fly
local LongJump
velo.run(function()
	local Options = {TPTiming = tick()}
	local Mode
	local FloatMode
	local State
	local MoveMethod
	local Keys
	local VerticalValue
	local BounceLength
	local BounceDelay
	local FloatTPGround
	local FloatTPAir
	local CustomProperties
	local WallCheck
	local PlatformStanding
	local Platform, YLevel, OldYLevel
	local w, s, a, d, up, down = 0, 0, 0, 0, 0, 0
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	Options.rayCheck = rayCheck

	local Functions
	Functions = {
		Velocity = function()
			entitylib.character.RootPart.Velocity = (entitylib.character.RootPart.Velocity * Vector3.new(1, 0, 1)) + Vector3.new(0, 2.25 + ((up + down) * VerticalValue.Value), 0)
		end,
		CFrame = function(dt)
			local root = entitylib.character.RootPart
			if not YLevel then 
				YLevel = root.Position.Y 
			end
			YLevel = YLevel + ((up + down) * VerticalValue.Value * dt)
			if WallCheck["Enabled"] then
				rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
				rayCheck.CollisionGroup = root.CollisionGroup
				local ray = workspace:Raycast(root.Position, Vector3.new(0, YLevel - root.Position.Y, 0), rayCheck)
				if ray then
					YLevel = ray.Position.Y + entitylib.character.HipHeight
				end
			end
			root.Velocity *= Vector3.new(1, 0, 1)
			root.CFrame += Vector3.new(0, YLevel - root.Position.Y, 0)
		end,
		Bounce = function()
			Functions.Velocity()
			entitylib.character.RootPart.Velocity += Vector3.new(0, ((tick() % BounceDelay.Value) / BounceDelay.Value > 0.5 and 1 or -1) * BounceLength.Value, 0)
		end,
		Floor = function()
			Platform.CFrame = down ~= 0 and CFrame.identity or entitylib.character.RootPart.CFrame + Vector3.new(0, -(entitylib.character.HipHeight + 0.5), 0)
		end,
		TP = function(dt)
			Functions.CFrame(dt)
			if tick() % (FloatTPAir.Value + FloatTPGround.Value) > FloatTPAir.Value then
				OldYLevel = OldYLevel or YLevel
				rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
				rayCheck.CollisionGroup = entitylib.character.RootPart.CollisionGroup
				local ray = workspace:Raycast(entitylib.character.RootPart.Position, Vector3.new(0, -1000, 0), rayCheck)
				if ray then
					YLevel = ray.Position.Y + entitylib.character.HipHeight
				end
			else
				if OldYLevel then
					YLevel = OldYLevel
					OldYLevel = nil
				end
			end
		end,
		Jump = function(dt)
			local root = entitylib.character.RootPart
			if not YLevel then 
				YLevel = root.Position.Y 
			end
			YLevel = YLevel + ((up + down) * VerticalValue.Value * dt)
			if root.Position.Y < YLevel then 
				entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	}

	Fly = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Fly',
		["Function"] = function(callback: boolean): void
			if Platform then
				Platform.Parent = callback and gameCamera or nil
			end
			frictionTable.Fly = callback and CustomProperties["Enabled"] or nil
			updateVelocity()
			if callback then
				Fly:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive then
						if PlatformStanding["Enabled"] then
							entitylib.character.Humanoid.PlatformStand = true
							entitylib.character.RootPart.RotVelocity = Vector3.zero
							entitylib.character.RootPart.CFrame = CFrame.lookAlong(entitylib.character.RootPart.CFrame.Position, gameCamera.CFrame.LookVector)
						end
						if State.Value ~= 'None' then
							entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType[State.Value])
						end
						SpeedMethods[Mode.Value](Options, TargetStrafeVector or MoveMethod.Value == 'Direct' and calculateMoveVector(Vector3.new(a + d, 0, w + s)) or entitylib.character.Humanoid.MoveDirection, dt)
						Functions[FloatMode.Value](dt)
					else
						YLevel = nil
						OldYLevel = nil
					end
				end))

				w, s, a, d = inputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0, inputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0, inputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0, inputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
				up, down = 0, 0
				for _, v in {'InputBegan', 'InputEnded'} do
					Fly:Clean(inputService[v]:Connect(function(input)
						if not inputService:GetFocusedTextBox() then
							local divided = Keys.Value:split('/')
							if input.KeyCode == Enum.KeyCode.W then
								w = v == 'InputBegan' and -1 or 0
							elseif input.KeyCode == Enum.KeyCode.S then
								s = v == 'InputBegan' and 1 or 0
							elseif input.KeyCode == Enum.KeyCode.A then
								a = v == 'InputBegan' and -1 or 0
							elseif input.KeyCode == Enum.KeyCode.D then
								d = v == 'InputBegan' and 1 or 0
							elseif input.KeyCode == Enum.KeyCode[divided[1]] then
								up = v == 'InputBegan' and 1 or 0
							elseif input.KeyCode == Enum.KeyCode[divided[2]] then
								down = v == 'InputBegan' and -1 or 0
							end
						end
					end))
				end
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						Fly:Clean(jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							up = jumpButton.ImageRectOffset.X == 146 and 1 or 0
						end))
					end)
				end
			else
				YLevel, OldYLevel = nil, nil
				if entitylib.isAlive and PlatformStanding["Enabled"] then
					entitylib.character.Humanoid.PlatformStand = false
				end
			end
		end,
		ExtraText = function() 
			return Mode.Value 
		end,
		Tooltip = 'Makes you go zoom.'
	})
	Mode = Fly:CreateDropdown({
		["Name"] = 'Speed Mode',
		["List"] = SpeedMethodList,
		["Function"] = function(val)
			WallCheck.Object.Visible = FloatMode.Value == 'CFrame' or FloatMode.Value == 'TP' or val == 'CFrame' or val == 'TP'
			Options.TPFrequency.Object.Visible = val == 'TP'
			Options.PulseLength.Object.Visible = val == 'Pulse'
			Options.PulseDelay.Object.Visible = val == 'Pulse'
			if Fly["Enabled"] then
				Fly:Toggle()
				Fly:Toggle()
			end
		end,
		Tooltip = 'Velocity - Uses smooth physics based movement\nCFrame - Directly adjusts the position of the root\nTP - Large teleports within intervals\nPulse - Controllable bursts of speed\nWalkSpeed - The classic mode of speed, usually detected on most games.'
	})
	FloatMode = Fly:CreateDropdown({
		["Name"] = 'Float Mode',
		["List"] = {'Velocity', 'CFrame', 'Bounce', 'Floor', 'Jump', 'TP'},
		["Function"] = function(val)
			WallCheck.Object.Visible = Mode.Value == 'CFrame' or Mode.Value == 'TP' or val == 'CFrame' or val == 'TP'
			BounceLength.Object.Visible = val == 'Bounce'
			BounceDelay.Object.Visible = val == 'Bounce'
			VerticalValue.Object.Visible = val ~= 'Floor'
			FloatTPGround.Object.Visible = val == 'TP'
			FloatTPAir.Object.Visible = val == 'TP'
			if Platform then
				Platform:Destroy()
				Platform = nil
			end
			if val == 'Floor' then
				Platform = Instance.new('Part')
				Platform.CanQuery = false
				Platform.Anchored = true
				Platform.Size = Vector3.one
				Platform.Transparency = 1
				Platform.Parent = Fly["Enabled"] and gameCamera or nil
			end
		end,
		Tooltip = 'Velocity - Uses smooth physics based movement\nCFrame - Directly adjusts the position of the root\nTP - Teleports you to the ground within intervals\nFloor - Spawns a part under you\nJump - Presses space after going below a certain Y Level\nBounce - Vertical bouncing motion'
	})
	local states = {'None'}
	for _, v in Enum.HumanoidStateType:GetEnumItems() do
		if v.Name ~= 'Dead' and v.Name ~= 'None' then
			table.insert(states, v.Name)
		end
	end
	State = Fly:CreateDropdown({
		["Name"] = 'Humanoid State',
		["List"] = states
	})
	MoveMethod = Fly:CreateDropdown({
		["Name"] = 'Move Mode',
		["List"] = {'MoveDirection', 'Direct'},
		Tooltip = 'MoveDirection - Uses the games input vector for movement\nDirect - Directly calculate our own input vector'
	})
	Keys = Fly:CreateDropdown({
		["Name"] = 'Keys',
		["List"] = {'Space/LeftControl', 'Space/LeftShift', 'E/Q', 'Space/Q', 'ButtonA/ButtonL2'},
		Tooltip = 'The key combination for going up & down'
	})
	Options.Value = Fly:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	VerticalValue = Fly:CreateSlider({
		["Name"] = 'Vertical Speed',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	Options.TPFrequency = Fly:CreateSlider({
		["Name"] = 'TP Frequency',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	Options.PulseLength = Fly:CreateSlider({
		["Name"] = 'Pulse Length',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	Options.PulseDelay = Fly:CreateSlider({
		["Name"] = 'Pulse Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	BounceLength = Fly:CreateSlider({
		["Name"] = 'Bounce Length',
		["Min"] = 0,
		["Max"] = 30,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	BounceDelay = Fly:CreateSlider({
		["Name"] = 'Bounce Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	FloatTPGround = Fly:CreateSlider({
		["Name"] = 'Ground',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10,
		["Default"] = 0.1,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	FloatTPAir = Fly:CreateSlider({
		["Name"] = 'Air',
		["Min"] = 0,
		["Max"] = 5,
		["Decimal"] = 10,
		["Default"] = 2,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	WallCheck = Fly:CreateToggle({
		["Name"] = 'Wall Check',
		["Default"] = true,
		["Darker"] = true,
		["Visible"] = false
	})
	Options.WallCheck = WallCheck
	PlatformStanding = Fly:CreateToggle({
		["Name"] = 'PlatformStand',
		["Function"] = function(callback: boolean): void
			if Fly["Enabled"] then
				entitylib.character.Humanoid.PlatformStand = callback
			end
		end,
		Tooltip = 'Forces the character to look infront of the camera'
	})
	CustomProperties = Fly:CreateToggle({
		["Name"] = 'Custom Properties',
		["Function"] = function()
			if Fly["Enabled"] then
				Fly:Toggle()
				Fly:Toggle()
			end
		end,
		["Default"] = true
	})
end)
	
velo.run(function()
	local HighJump
	local Mode
	local Value
	local AutoDisable
	
	local function jump()
		local state = entitylib.isAlive and entitylib.character.Humanoid:GetState() or nil
		if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed then
			if Mode.Value == 'Velocity' then
				entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				entitylib.character.RootPart.Velocity = Vector3.new(entitylib.character.RootPart.Velocity.X, Value.Value, entitylib.character.RootPart.Velocity.Z)
			else
				local start = math.max(Value.Value - entitylib.character.Humanoid.JumpHeight, 0)
				repeat
					entitylib.character.RootPart.CFrame += Vector3.new(0, start * 0.016, 0)
					start = start - (workspace.Gravity * 0.016)
					if Mode.Value == 'CFrame' then
						task.wait()
					end
				until start <= 0
			end
		end
	end
	
	HighJump = vape.Categories.Blatant:CreateModule({
		["Name"] = 'HighJump',
		["Function"] = function(callback: boolean): void
			if callback then
				if AutoDisable["Enabled"] then
					jump()
					HighJump:Toggle()
				else
					HighJump:Clean(runService.RenderStepped:Connect(function()
						if not inputService:GetFocusedTextBox() and inputService:IsKeyDown(Enum.KeyCode.Space) then
							jump()
						end
					end))
				end
			end
		end,
		ExtraText = function() 
			return Mode.Value 
		end,
		Tooltip = 'Lets you jump higher'
	})
	Mode = HighJump:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Velocity', 'CFrame', 'Instant'},
		Tooltip = 'Velocity - Uses smooth movement to boost you upward\nCFrame - Directly adjusts the position upward\nInstant - Teleports you to the peak of the jump'
	})
	Value = HighJump:CreateSlider({
		["Name"] = 'Velocity',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AutoDisable = HighJump:CreateToggle({
		["Name"] = 'Auto Disable',
		["Default"] = true
	})
end)
	
velo.run(function()
	local HitBoxes
	local Targets
	local TargetPart
	local Expand
	local modified = {}
	
	HitBoxes = vape.Categories.Blatant:CreateModule({
		["Name"] = 'HitBoxes',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					for _, v in entitylib.List do
						if v.Targetable then
							if not Targets.Players["Enabled"] and v.Player then continue end
							if not Targets.NPCs["Enabled"] and v.NPC then continue end
							local part = v[TargetPart.Value]
							if not modified[part] then
								modified[part] = part.Size
							end
							part.Size = modified[part] + Vector3.new(Expand.Value, Expand.Value, Expand.Value)
						end
					end
					task.wait()
				until not HitBoxes["Enabled"]
			else
				for i, v in modified do
					i.Size = v
				end
				table.clear(modified)
			end
		end,
		Tooltip = 'Expands entities hitboxes'
	})
	Targets = HitBoxes:CreateTargets({Players = true})
	TargetPart = HitBoxes:CreateDropdown({
		["Name"] = 'Part',
		["List"] = {'RootPart', 'Head'}
	})
	Expand = HitBoxes:CreateSlider({
		["Name"] = 'Expand amount',
		["Min"] = 0,
		["Max"] = 2,
		["Decimal"] = 10,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)
	
velo.run(function()
	local Invisible
	local clone, oldroot, hip, valid
	local animtrack
	local proper = true
	
	local function doClone()
		if entitylib.isAlive and entitylib.character.Humanoid.Health > 0 then
			hip = entitylib.character.Humanoid.HipHeight
			oldroot = entitylib.character.HumanoidRootPart
			if not lplr.Character.Parent then 
				return false 
			end
	
			lplr.Character.Parent = game
			clone = oldroot:Clone()
			clone.Parent = lplr.Character
			oldroot.Parent = gameCamera
			clone.CFrame = oldroot.CFrame
	
			lplr.Character.PrimaryPart = clone
			entitylib.character.HumanoidRootPart = clone
			entitylib.character.RootPart = clone
			lplr.Character.Parent = workspace
	
			for _, v in lplr.Character:GetDescendants() do
				if v:IsA('Weld') or v:IsA('Motor6D') then
					if v.Part0 == oldroot then 
						v.Part0 = clone 
					end
					if v.Part1 == oldroot then 
						v.Part1 = clone 
					end
				end
			end
	
			return true
		end
	
		return false
	end
	
	local function revertClone()
		if not oldroot or not oldroot:IsDescendantOf(workspace) or not entitylib.isAlive then 
			return false 
		end
	
		lplr.Character.Parent = game
		oldroot.Parent = lplr.Character
		lplr.Character.PrimaryPart = oldroot
		entitylib.character.HumanoidRootPart = oldroot
		entitylib.character.RootPart = oldroot
		lplr.Character.Parent = workspace
		oldroot.CanCollide = true
	
		for _, v in lplr.Character:GetDescendants() do
			if v:IsA('Weld') or v:IsA('Motor6D') then
				if v.Part0 == clone then 
					v.Part0 = oldroot 
				end
				if v.Part1 == clone then 
					v.Part1 = oldroot 
				end
			end
		end
	
		local oldpos = clone.CFrame
		if clone then
			clone:Destroy()
			clone = nil
		end
	
		oldroot.CFrame = oldpos
		oldroot = nil
		entitylib.character.Humanoid.HipHeight = hip or 2
	end
	
	local function animationTrickery()
		if entitylib.isAlive then 
			local anim = Instance.new('Animation')
			anim.AnimationId = 'http://www.roblox.com/asset/?id=18537363391'
			animtrack = entitylib.character.Humanoid.Animator:LoadAnimation(anim)
			animtrack.Priority = Enum.AnimationPriority.Action4
			animtrack:Play(0, 1, 0)
			anim:Destroy()
			animtrack.Stopped:Connect(function()
				if Invisible["Enabled"] then 
					animationTrickery()
				end	
			end)
	
			task.delay(0, function()
				animtrack.TimePosition = 0.77
				task.delay(1, function()
					animtrack:AdjustSpeed(math.huge)
				end)
			end)
		end
	end
	
	Invisible = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Invisible',
		["Function"] = function(callback: boolean): void
			if callback then 
				if not proper then
					notif('Invisible', 'Broken state detected', 3, 'alert')
					Invisible:Toggle()
					return
				end
	
				success = doClone()
				if not success then
					Invisible:Toggle()
					return
				end
	
				animationTrickery()
				Invisible:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive and oldroot then
						local root = entitylib.character.RootPart
						local cf = root.CFrame - Vector3.new(0, entitylib.character.Humanoid.HipHeight + (root.Size.Y / 2) - 1, 0)
	
						if isnetworkowner and not isnetworkowner(oldroot) then 
							root.CFrame = oldroot.CFrame
							root.Velocity = oldroot.Velocity
							return
						end
	
						oldroot.CFrame = cf * CFrame.Angles(math.rad(180), 0, 0)
						oldroot.Velocity = root.Velocity
						oldroot.CanCollide = false
					end
				end))
	
				Invisible:Clean(entitylib.Events.LocalAdded:Connect(function(char)
					local animator = char.Humanoid:WaitForChild('Animator', 1)
					if animator and Invisible["Enabled"] then 
						oldroot = nil
						Invisible:Toggle()
						Invisible:Toggle()
					end
				end))
			else
				if animtrack then 
					animtrack:Stop()
					animtrack:Destroy()
				end
				
				if success and clone and oldroot and proper then
					proper = true
					if oldroot and clone then 
						revertClone() 
					end
				end
			end
		end,
		Tooltip = 'Turns you invisible.'
	})
end)
	
velo.run(function()
	local Killaura
	local Targets
	local CPS
	local SwingRange
	local AttackRange
	local AngleSlider
	local Max
	local Mouse
	local Lunge
	local BoxSwingColor
	local BoxAttackColor
	local ParticleTexture
	local ParticleColor1
	local ParticleColor2
	local ParticleSize
	local Face
	local Overlay = OverlapParams.new()
	Overlay.FilterType = Enum.RaycastFilterType.Include
	local Particles, Boxes, AttackDelay = {}, {}, tick()
	
	local function getAttackData()
		if Mouse["Enabled"] then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end
		
		local tool = getTool()
		return tool and tool:FindFirstChildWhichIsA('TouchTransmitter', true) or nil, tool
	end
	
	Killaura = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Killaura',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					local interest, tool = getAttackData()
					local attacked = {}
					if interest then
						local plrs = entitylib.AllPosition({
							Range = SwingRange.Value,
							Wallcheck = Targets.Walls["Enabled"] or nil,
							Part = 'RootPart',
							Players = Targets.Players["Enabled"],
							NPCs = Targets.NPCs["Enabled"],
							Limit = Max.Value
						})
	
						if #plrs > 0 then
							local selfpos = entitylib.character.RootPart.Position
							local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
	
							for _, v in plrs do
								local delta = (v.RootPart.Position - selfpos)
								local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
								if angle > (math.rad(AngleSlider.Value) / 2) then continue end
								
								table.insert(attacked, {
									Entity = v,
									Check = delta.Magnitude > AttackRange.Value and BoxSwingColor or BoxAttackColor
								})
								targetinfo.Targets[v] = tick() + 1
								
								if AttackDelay < tick() then
									AttackDelay = tick() + (1 / CPS.GetRandomValue())
									tool:Activate()
								end
	
								if Lunge["Enabled"] and tool.GripUp.X == 0 then break end
								if delta.Magnitude > AttackRange.Value then continue end
								
								Overlay.FilterDescendantsInstances = {v.Character}
								for _, part in workspace:GetPartBoundsInBox(v.RootPart.CFrame, Vector3.new(4, 4, 4), Overlay) do
									firetouchinterest(interest.Parent, part, 1)
									firetouchinterest(interest.Parent, part, 0)
								end
							end
						end
					end
	
					for i, v in Boxes do
						v.Adornee = attacked[i] and attacked[i].Entity.RootPart or nil
						if v.Adornee then
							v.Color3 = Color3.fromHSV(attacked[i].Check.Hue, attacked[i].Check.Sat, attacked[i].Check.Value)
							v.Transparency = 1 - attacked[i].Check.Opacity
						end
					end
	
					for i, v in Particles do
						v.Position = attacked[i] and attacked[i].Entity.RootPart.Position or Vector3.new(9e9, 9e9, 9e9)
						v.Parent = attacked[i] and gameCamera or nil
					end
	
					if Face["Enabled"] and attacked[1] then
						local vec = attacked[1].Entity.RootPart.Position * Vector3.new(1, 0, 1)
						entitylib.character.RootPart.CFrame = CFrame.lookAt(entitylib.character.RootPart.Position, Vector3.new(vec.X, entitylib.character.RootPart.Position.Y, vec.Z))
					end
	
					task.wait()
				until not Killaura["Enabled"]
			else
				for _, v in Boxes do
					v.Adornee = nil
				end
				for _, v in Particles do
					v.Parent = nil
				end
			end
		end,
		Tooltip = 'Attack players around you\nwithout aiming at them.'
	})
	Targets = Killaura:CreateTargets({Players = true})
	CPS = Killaura:CreateTwoSlider({
		["Name"] = 'Attacks per Second',
		["Min"] = 1,
		["Max"] = 20,
		["DefaultMin"] = 12,
		["DefaultMax"] = 12
	})
	SwingRange = Killaura:CreateSlider({
		["Name"] = 'Swing range',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 13,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AttackRange = Killaura:CreateSlider({
		["Name"] = 'Attack range',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 13,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AngleSlider = Killaura:CreateSlider({
		["Name"] = 'Max angle',
		["Min"] = 1,
		["Max"] = 360,
		["Default"] = 90
	})
	Max = Killaura:CreateSlider({
		["Name"] = 'Max targets',
		["Min"] = 1,
		["Max"] = 10,
		["Default"] = 10
	})
	Mouse = Killaura:CreateToggle({["Name"] = 'Require mouse down'})
	Lunge = Killaura:CreateToggle({["Name"] = 'Sword lunge only'})
	Killaura:CreateToggle({
		["Name"] = 'Show target',
		["Function"] = function(callback: boolean): void
			BoxSwingColor.Object.Visible = callback
			BoxAttackColor.Object.Visible = callback
			if callback then
				for i = 1, 10 do
					local box = Instance.new('BoxHandleAdornment')
					box.Adornee = nil
					box.AlwaysOnTop = true
					box.Size = Vector3.new(3, 5, 3)
					box.CFrame = CFrame.new(0, -0.5, 0)
					box.ZIndex = 0
					box.Parent = vape.gui
					Boxes[i] = box
				end
			else
				for _, v in Boxes do
					v:Destroy()
				end
				table.clear(Boxes)
			end
		end
	})
	BoxSwingColor = Killaura:CreateColorSlider({
		["Name"] = 'Target Color',
		["Darker"] = true,
		DefaultHue = 0.6,
		DefaultOpacity = 0.5,
		["Visible"] = false
	})
	BoxAttackColor = Killaura:CreateColorSlider({
		["Name"] = 'Attack Color',
		["Darker"] = true,
		DefaultOpacity = 0.5,
		["Visible"] = false
	})
	Killaura:CreateToggle({
		["Name"] = 'Target particles',
		["Function"] = function(callback: boolean): void
			ParticleTexture.Object.Visible = callback
			ParticleColor1.Object.Visible = callback
			ParticleColor2.Object.Visible = callback
			ParticleSize.Object.Visible = callback
			if callback then
				for i = 1, 10 do
					local part = Instance.new('Part')
					part.Size = Vector3.new(2, 4, 2)
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1
					part.CanQuery = false
					part.Parent = Killaura["Enabled"] and gameCamera or nil
					local particles = Instance.new('ParticleEmitter')
					particles.Brightness = 1.5
					particles.Size = NumberSequence.new(ParticleSize.Value)
					particles.Shape = Enum.ParticleEmitterShape.Sphere
					particles.Texture = ParticleTexture.Value
					particles.Transparency = NumberSequence.new(0)
					particles.Lifetime = NumberRange.new(0.4)
					particles.Speed = NumberRange.new(16)
					particles.Rate = 128
					particles.Drag = 16
					particles.ShapePartial = 1
					particles.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
					})
					particles.Parent = part
					Particles[i] = part
				end
			else
				for _, v in Particles do 
					v:Destroy() 
				end
				table.clear(Particles)
			end
		end
	})
	ParticleTexture = Killaura:CreateTextBox({
		["Name"] = 'Texture',
		["Default"] = 'rbxassetid://14736249347',
		["Function"] = function()
			for _, v in Particles do
				v.ParticleEmitter.Texture = ParticleTexture.Value
			end
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	ParticleColor1 = Killaura:CreateColorSlider({
		["Name"] = 'Color Begin',
		["Function"] = function(hue, sat, val)
			for _, v in Particles do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
				})
			end
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	ParticleColor2 = Killaura:CreateColorSlider({
		["Name"] = 'Color End',
		["Function"] = function(hue, sat, val)
			for _, v in Particles do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, val))
				})
			end
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	ParticleSize = Killaura:CreateSlider({
		["Name"] = 'Size',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.2,
		["Decimal"] = 100,
		["Function"] = function(val)
			for _, v in Particles do
				v.ParticleEmitter.Size = NumberSequence.new(val)
			end
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	Face = Killaura:CreateToggle({["Name"] = 'Face target'})
end)
	
velo.run(function()
	local Mode
	local Value
	local AutoDisable
	
	LongJump = vape.Categories.Blatant:CreateModule({
		["Name"] = 'LongJump',
		["Function"] = function(callback: boolean): void
			if callback then
				local exempt = tick() + 0.1
				LongJump:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive then
						if entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
							if exempt < tick() and AutoDisable["Enabled"] then
								if LongJump["Enabled"] then
									LongJump:Toggle()
								end
							else
								entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							end
						end
	
						local root = entitylib.character.RootPart
						if Mode.Value == 'Velocity' then
							root.AssemblyLinearVelocity = (entitylib.character.Humanoid.MoveDirection * Value.Value) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
						else
							root.CFrame += (entitylib.character.Humanoid.MoveDirection * Value.Value * dt)
						end
					end
				end))
			end
		end,
		ExtraText = function() 
			return Mode.Value 
		end,
		Tooltip = 'Lets you jump farther'
	})
	Mode = LongJump:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Velocity', 'CFrame'},
		Tooltip = 'Velocity - Uses smooth physics based movement\nCFrame - Directly adjusts the position of the root'
	})
	Value = LongJump:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AutoDisable = LongJump:CreateToggle({
		["Name"] = 'Auto Disable',
		["Default"] = true
	})
end)
	
velo.run(function()
	local MouseTP
	local Mode
	local MovementMode
	local Length
	local Delay
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	
	local function getWaypointInMouse()
		local returned, distance, mouseLocation = nil, math.huge, inputService:GetMouseLocation()
		for _, v in WaypointFolder:GetChildren() do
			local position, vis = gameCamera:WorldToViewportPoint(v.StudsOffsetWorldSpace)
			if not vis then continue end
			local mag = (mouseLocation - Vector2.new(position.x, position.y)).Magnitude
			if mag < distance then
				returned, distance = v, mag
			end
		end
		return returned
	end
	
	MouseTP = vape.Categories.Blatant:CreateModule({
		["Name"] = 'MouseTP',
		["Function"] = function(callback: boolean): void
			if callback then
				local position
				if Mode.Value == 'Mouse' then
					local ray = cloneref(lplr:GetMouse()).UnitRay
					rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
					ray = workspace:Raycast(ray.Origin, ray.Direction * 10000, rayCheck)
					position = ray and ray.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0)
				elseif Mode.Value == 'Waypoint' then
					local waypoint = getWaypointInMouse()
					position = waypoint and waypoint.StudsOffsetWorldSpace
				else
					local ent = entitylib.EntityMouse({
						Range = math.huge,
						Part = 'RootPart',
						Players = true
					})
					position = ent and ent.RootPart.Position
				end
	
				if not position then
					notif('MouseTP', 'No position found.', 5)
					MouseTP:Toggle()
					return
				end
	
				if MovementMode.Value == 'Normal' then
					if entitylib.isAlive then
						entitylib.character.RootPart.CFrame = CFrame.lookAlong(position, entitylib.character.RootPart.CFrame.LookVector)
					end
					MouseTP:Toggle()
				else
					MouseTP:Clean(runService.Heartbeat:Connect(function()
						if entitylib.isAlive then
							entitylib.character.RootPart.Velocity = Vector3.zero
						end
					end))
					
					repeat
						if entitylib.isAlive then
							local direction = CFrame.lookAt(entitylib.character.RootPart.Position, position).LookVector * math.min((entitylib.character.RootPart.Position - position).Magnitude, Length.Value)
							entitylib.character.RootPart.CFrame += direction
							if (entitylib.character.RootPart.Position - position).Magnitude < 3 and MouseTP["Enabled"] then
								MouseTP:Toggle()
							end
						elseif MouseTP["Enabled"] then
							MouseTP:Toggle()
							notif('MouseTP', 'Character missing', 5, 'warning')
						end
						task.wait(Delay.Value)
					until not MouseTP["Enabled"]
				end
			end
		end,
		Tooltip = 'Teleports to a selected position.'
	})
	Mode = MouseTP:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Mouse', 'Player', 'Waypoint'}
	})
	MovementMode = MouseTP:CreateDropdown({
		["Name"] = 'Movement',
		["List"] = {'Normal', 'Lerp'},
		["Function"] = function(val)
			Length.Object.Visible = val == 'Lerp'
			Delay.Object.Visible = val == 'Lerp'
		end
	})
	Length = MouseTP:CreateSlider({
		["Name"] = 'Length',
		["Min"] = 0,
		["Max"] = 150,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	Delay = MouseTP:CreateSlider({
		["Name"] = 'Delay',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
end)

velo.run(function()
	local Mode
	local StudLimit = {Object = {}}
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	local overlapCheck = OverlapParams.new()
	overlapCheck.MaxParts = 9e9
	local modified, fflag = {}
	local teleported

	local function grabClosestNormal(ray)
		local partCF, mag, closest = ray.Instance.CFrame, 0, Enum.NormalId.Top
		for _, normal in Enum.NormalId:GetEnumItems() do
			local dot = partCF:VectorToWorldSpace(Vector3.fromNormalId(normal)):Dot(ray.Normal)
			if dot > mag then
				mag, closest = dot, normal
			end
		end
		return Vector3.fromNormalId(closest).X ~= 0 and 'X' or 'Z'
	end
	
	local Functions = {
		Part = function()
			local chars = {gameCamera, lplr.Character}
			for _, v in entitylib.List do 
				table.insert(chars, v.Character) 
			end
			overlapCheck.FilterDescendantsInstances = chars
	
			local parts = workspace:GetPartBoundsInBox(entitylib.character.RootPart.CFrame + Vector3.new(0, 1, 0), entitylib.character.RootPart.Size + Vector3.new(1, entitylib.character.HipHeight, 1), overlapCheck)
			for _, part in parts do
				if part.CanCollide and (not Spider["Enabled"] or SpiderShift) then
					modified[part] = true
					part.CanCollide = false
				end
			end
	
			for part in modified do
				if not table.find(parts, part) then
					modified[part] = nil
					part.CanCollide = true
				end
			end
		end,
		Character = function()
			for _, part in lplr.Character:GetDescendants() do
				if part:IsA('BasePart') and part.CanCollide and (not Spider["Enabled"] or SpiderShift) then
					modified[part] = true
					part.CanCollide = Spider["Enabled"] and not SpiderShift
				end
			end
		end,
		TP = function()
			local chars = {gameCamera, lplr.Character}
			for _, v in entitylib.List do
				table.insert(chars, v.Character)
			end
			rayCheck.FilterDescendantsInstances = chars
			overlapCheck.FilterDescendantsInstances = chars
			
			local ray = workspace:Raycast(entitylib.character.Head.CFrame.Position, entitylib.character.Humanoid.MoveDirection * 1.1, rayCheck)
			if ray and (not Spider["Enabled"] or SpiderShift) then
				local phaseDirection = grabClosestNormal(ray)
				if ray.Instance.Size[phaseDirection] <= StudLimit.Value then
					local dest = entitylib.character.RootPart.CFrame + (ray.Normal * (-(ray.Instance.Size[phaseDirection]) - (entitylib.character.RootPart.Size.X / 1.5)))
					if #workspace:GetPartBoundsInBox(dest, Vector3.one, overlapCheck) <= 0 then
						entitylib.character.RootPart.CFrame = dest
					end
				end
			end
		end,
		FFlag = function()
			if teleported then return end
			setfflag('AssemblyExtentsExpansionStudHundredth', '-10000')
			fflag = true
		end
	}
	
	Phase = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Phase',
		["Function"] = function(callback: boolean): void
			if callback then
				Phase:Clean(runService.Stepped:Connect(function()
					if entitylib.isAlive then
						Functions[Mode["Value"]]()
					end
				end))
				if Mode["Value"] == 'FFlag' then
					Phase:Clean(lplr.OnTeleport:Connect(function()
						teleported = true
						setfflag('AssemblyExtentsExpansionStudHundredth', '30')
					end))
				end
			else
				if fflag then
					setfflag('AssemblyExtentsExpansionStudHundredth', '30')
				end
				for part in modified do
					part.CanCollide = true
				end
				table.clear(modified)
				fflag = nil
			end
		end,
		Tooltip = 'Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)'
	})
	Mode = Phase:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Part', 'Character', 'TP', 'FFlag'},
		["Function"] = function(val)
			StudLimit.Object.Visible = val == 'TP'
			if fflag then
				setfflag('AssemblyExtentsExpansionStudHundredth', '30')
			end
			for part in modified do
				part.CanCollide = true
			end
			table.clear(modified)
			fflag = nil
		end,
		Tooltip = 'Part - Modifies parts collision status around you\nCharacter - Modifies the local collision status of the character\nTP - Teleports you past parts\nFFlag - Directly adjusts all physics collisions'
	})
	StudLimit = Phase:CreateSlider({
		["Name"] = 'Wall Size',
		["Min"] = 1,
		["Max"] = 20,
		["Default"] = 5,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end,
		["Darker"] = true,
		["Visible"] = false
	})
end)
	
velo.run(function()
	local Speed
	local Mode
	local Options
	local AutoJump
	local AutoJumpCustom
	local AutoJumpValue
	local w, s, a, d = 0, 0, 0, 0
	
	Speed = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Speed',
		["Function"] = function(callback: boolean): void
			frictionTable.Speed = callback and CustomProperties["Enabled"] or nil
			updateVelocity()
			if callback then
				Speed:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive and not Fly["Enabled"] and not LongJump["Enabled"] then
						local state = entitylib.character.Humanoid:GetState()
						if state == Enum.HumanoidStateType.Climbing then return end
						local movevec = TargetStrafeVector or Options.MoveMethod.Value == 'Direct' and calculateMoveVector(Vector3.new(a + d, 0, w + s)) or entitylib.character.Humanoid.MoveDirection
						SpeedMethods[Mode.Value](Options, movevec, dt)
						if AutoJump["Enabled"] and entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air and movevec ~= Vector3.zero then
							if AutoJumpCustom["Enabled"] then
								local velocity = entitylib.character.RootPart.Velocity * Vector3.new(1, 0, 1)
								entitylib.character.RootPart.Velocity = Vector3.new(velocity.X, AutoJumpValue.Value, velocity.Z)
							else
								entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							end
						end
					end
				end))
	
				w, s, a, d = inputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0, inputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0, inputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0, inputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
				for _, v in {'InputBegan', 'InputEnded'} do
					Speed:Clean(inputService[v]:Connect(function(input)
						if not inputService:GetFocusedTextBox() then
							if input.KeyCode == Enum.KeyCode.W then
								w = v == 'InputBegan' and -1 or 0
							elseif input.KeyCode == Enum.KeyCode.S then
								s = v == 'InputBegan' and 1 or 0
							elseif input.KeyCode == Enum.KeyCode.A then
								a = v == 'InputBegan' and -1 or 0
							elseif input.KeyCode == Enum.KeyCode.D then
								d = v == 'InputBegan' and 1 or 0
							end
						end
					end))
				end
			else
				if Options.WalkSpeed and entitylib.isAlive then
					entitylib.character.Humanoid.WalkSpeed = Options.WalkSpeed
				end
				Options.WalkSpeed = nil
			end
		end,
		ExtraText = function()
			return Mode.Value
		end,
		Tooltip = 'Increases your movement with various methods.'
	})
	Mode = Speed:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = SpeedMethodList,
		["Function"] = function(val)
			Options.WallCheck.Object.Visible = val == 'CFrame' or val == 'TP'
			Options.TPFrequency.Object.Visible = val == 'TP'
			Options.PulseLength.Object.Visible = val == 'Pulse'
			Options.PulseDelay.Object.Visible = val == 'Pulse'
			if Speed["Enabled"] then
				Speed:Toggle()
				Speed:Toggle()
			end
		end,
		Tooltip = 'Velocity - Uses smooth physics based movement\nCFrame - Directly adjusts the position of the root\nTP - Large teleports within intervals\nPulse - Controllable bursts of speed\nWalkSpeed - The classic mode of speed, usually detected on most games.'
	})
	Options = {
		MoveMethod = Speed:CreateDropdown({
			["Name"] = 'Move Mode',
			["List"] = {'MoveDirection', 'Direct'},
			["Tooltip"] = 'MoveDirection - Uses the games input vector for movement\nDirect - Directly calculate our own input vector'
		}),
		Value = Speed:CreateSlider({
			["Name"] = 'Speed',
			["Min"] = 1,
			["Max"] = 150,
			["Default"] = 50,
			["Suffix"] = function(val)
				return val == 1 and 'stud' or 'studs'
			end
		}),
		TPFrequency = Speed:CreateSlider({
			["Name"] = 'TP Frequency',
			["Min"] = 0,
			["Max"] = 1,
			["Decimal"] = 100,
			["Darker"] = true,
			["Visible"] = false,
			["Suffix"] = function(val)
				return val == 1 and 'second' or 'seconds'
			end
		}),
		PulseLength = Speed:CreateSlider({
			["Name"] = 'Pulse Length',
			["Min"] = 0,
			["Max"] = 1,
			["Decimal"] = 100,
			["Darker"] = true,
			["Visible"] = false,
			["Suffix"] = function(val)
				return val == 1 and 'second' or 'seconds'
			end
		}),
		PulseDelay = Speed:CreateSlider({
			["Name"] = 'Pulse Delay',
			["Min"] = 0,
			["Max"] = 1,
			["Decimal"] = 100,
			["Darker"] = true,
			["Visible"] = false,
			["Suffix"] = function(val)
				return val == 1 and 'second' or 'seconds'
			end
		}),
		WallCheck = Speed:CreateToggle({
			["Name"] = 'Wall Check',
			["Default"] = true,
			["Darker"] = true,
			["Visible"] = false
		}),
		TPTiming = tick(),
		rayCheck = RaycastParams.new()
	}
	Options.rayCheck.RespectCanCollide = true
	CustomProperties = Speed:CreateToggle({
		["Name"] = 'Custom Properties',
		["Function"] = function()
			if Speed["Enabled"] then
				Speed:Toggle()
				Speed:Toggle()
			end
		end,
		["Default"] = true
	})
	AutoJump = Speed:CreateToggle({
		["Name"] = 'AutoJump',
		["Function"] = function(callback: boolean): void
			AutoJumpCustom.Object.Visible = callback
		end
	})
	AutoJumpCustom = Speed:CreateToggle({
		["Name"] = 'Custom Jump',
		["Function"] = function(callback: boolean): void
			AutoJumpValue.Object.Visible = callback
		end,
		Tooltip = 'Allows you to adjust the jump power',
		["Darker"] = true,
		["Visible"] = false
	})
	AutoJumpValue = Speed:CreateSlider({
		["Name"] = 'Jump Power',
		["Min"] = 1,
		["Max"] = 50,
		["Default"] = 30,
		["Darker"] = true,
		["Visible"] = false
	})
end)
	
velo.run(function()
	local Mode: table = {}
	local Value: table = {}
	local State: table = {["Enabled"] = false}
	local rayCheck: RaycastParams = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	local Active: any, Truss: any
	Spider = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Spider',
		["Function"] = function(callback: boolean): void
			if callback then
				if Truss then Truss.Parent = gameCamera end
				Spider:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive then
						local root = entitylib.character.RootPart
						local chars = {gameCamera, lplr.Character, Truss}
						for _, v in entitylib.List do
							table.insert(chars, v.Character)
						end
						SpiderShift = inputService:IsKeyDown(Enum.KeyCode.LeftShift)
						rayCheck.FilterDescendantsInstances = chars
						rayCheck.CollisionGroup = root.CollisionGroup
	
						if Mode.Value ~= 'Part' then
							local vec = entitylib.character.Humanoid.MoveDirection * 2.5
							local ray = workspace:Raycast(root.Position - Vector3.new(0, entitylib.character.HipHeight - 0.5, 0), vec, rayCheck)
							if Active and not ray then
								root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
							end
	
							Active = ray
							if Active and ray.Normal.Y == 0 then
								if not Phase["Enabled"] or not SpiderShift then
									if State["Enabled"] then
										entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
									end
									entitylib.character.RootPart.Velocity *= Vector3.new(1, 0, 1)
									if Mode.Value == 'CFrame' then
										entitylib.character.RootPart.CFrame += Vector3.new(0, Value.Value * dt, 0)
									else
										entitylib.character.RootPart.Velocity += Vector3.new(0, Value.Value, 0)
									end
								end
							end
						else
							local ray = workspace:Raycast(root.Position - Vector3.new(0, entitylib.character.HipHeight - 0.5, 0), entitylib.character.RootPart.CFrame.LookVector * 2, rayCheck)
							if ray and (not Phase["Enabled"] or not SpiderShift) then
								Truss.Position = ray.Position - ray.Normal * 0.9 or Vector3.zero
							else
								Truss.Position = Vector3.zero
							end
						end
					end
				end))
			else
				if Truss then
					Truss.Parent = nil
				end
				SpiderShift = false
			end
		end,
		Tooltip = 'Lets you climb up walls. (Hold shift to use Phase over spider)'
	})
	Mode = Spider:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Velocity', 'CFrame', 'Part'},
		["Function"] = function(val)
			Value.Object.Visible = val ~= 'Part'
			State.Object.Visible = val ~= 'Part'
			if Truss then
				Truss:Destroy()
				Truss = nil
			end
			if val == 'Part' then
				Truss = Instance.new('TrussPart')
				Truss.Size = Vector3.new(2, 2, 2)
				Truss.Transparency = 1
				Truss.Anchored = true
				Truss.Parent = Spider["Enabled"] and gameCamera or nil
			end
		end,
		Tooltip = 'Velocity - Uses smooth movement to boost you upward\nCFrame - Directly adjusts the position upward\nPart - Positions a climbable part infront of you'
	})
	Value = Spider:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 30,
		["Darker"] = true,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	State = Spider:CreateToggle({
		["Name"] = 'Climb State',
		["Darker"] = true
	})
end)
	
velo.run(function()
	local SpinBot: table = {["Enabled"] = false}
	local Mode
	local XToggle
	local YToggle
	local ZToggle
	local Value
	local AngularVelocity
	
	SpinBot = vape.Categories.Blatant:CreateModule({
		["Name"] = 'SpinBot',
		["Function"] = function(callback: boolean): void
			if callback then
				SpinBot:Clean(runService.PreSimulation:Connect(function()
					if entitylib.isAlive then
						if Mode.Value == 'RotVelocity' then
							local originalRotVelocity = entitylib.character.RootPart.RotVelocity
							entitylib.character.Humanoid.AutoRotate = false
							entitylib.character.RootPart.RotVelocity = Vector3.new(XToggle["Enabled"] and Value.Value or originalRotVelocity.X, YToggle["Enabled"] and Value.Value or originalRotVelocity.Y, ZToggle["Enabled"] and Value.Value or originalRotVelocity.Z)
						elseif Mode.Value == 'CFrame' then
							local val = math.rad((tick() * (20 * Value.Value)) % 360)
							local x, y, z = entitylib.character.RootPart.CFrame:ToOrientation()
							entitylib.character.RootPart.CFrame = CFrame.new(entitylib.character.RootPart.Position) * CFrame.Angles(XToggle["Enabled"] and val or x, YToggle["Enabled"] and val or y, ZToggle["Enabled"] and val or z)
						elseif AngularVelocity then
							AngularVelocity.Parent = entitylib.isAlive and entitylib.character.RootPart
							AngularVelocity.MaxTorque = Vector3.new(XToggle["Enabled"] and math.huge or 0, YToggle["Enabled"] and math.huge or 0, ZToggle["Enabled"] and math.huge or 0)
							AngularVelocity.AngularVelocity = Vector3.new(Value.Value, Value.Value, Value.Value)
						end
					end
				end))
			else
				if entitylib.isAlive and Mode.Value == 'RotVelocity' then
					entitylib.character.Humanoid.AutoRotate = true
				end
				if AngularVelocity then
					AngularVelocity.Parent = nil
				end
			end
		end,
		Tooltip = 'Makes your character spin around in circles (does not work in first person)'
	})
	Mode = SpinBot:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'CFrame', 'RotVelocity', 'BodyMover'},
		["Function"] = function(val)
			if AngularVelocity then
				AngularVelocity:Destroy()
				AngularVelocity = nil
			end
			AngularVelocity = val == 'BodyMover' and Instance.new('BodyAngularVelocity') or nil
		end
	})
	Value = SpinBot:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 40
	})
	XToggle = SpinBot:CreateToggle({["Name"] = 'Spin X'})
	YToggle = SpinBot:CreateToggle({
		["Name"] = 'Spin Y',
		["Default"] = true
	})
	ZToggle = SpinBot:CreateToggle({["Name"] = 'Spin Z'})
end)
	
velo.run(function()
	local Swim: table = {["Enabled"] = false}
	local terrain = cloneref(workspace:FindFirstChildWhichIsA('Terrain'))
	local lastpos = Region3.new(Vector3.zero, Vector3.zero)
	
	Swim = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Swim',
		["Function"] = function(callback: boolean): void
			if callback then
				Swim:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive then
						local root = entitylib.character.RootPart
						local moving = entitylib.character.Humanoid.MoveDirection ~= Vector3.zero
						local rootvelo = root.Velocity
						local space = inputService:IsKeyDown(Enum.KeyCode.Space)
	
						if terrain then
							local factor = (moving or space) and Vector3.new(6, 6, 6) or Vector3.new(2, 1, 2)
							local pos = root.Position - Vector3.new(0, 1, 0)
							local newpos = Region3.new(pos - factor, pos + factor):ExpandToGrid(4)
							terrain:ReplaceMaterial(lastpos, 4, Enum.Material.Water, Enum.Material.Air)
							terrain:FillRegion(newpos, 4, Enum.Material.Water)
							lastpos = newpos
						end
					end
				end))
			else
				if terrain and lastpos then
					terrain:ReplaceMaterial(lastpos, 4, Enum.Material.Water, Enum.Material.Air)
				end
			end
		end,
		Tooltip = 'Lets you swim midair'
	})
end)
	
velo.run(function()
	local TargetStrafe: table = {["Enabled"] = false}
	local Targets
	local SearchRange
	local StrafeRange
	local YFactor
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	local module, old
	
	TargetStrafe = vape.Categories.Blatant:CreateModule({
		["Name"] = 'TargetStrafe',
		["Function"] = function(callback: boolean): void
			if callback then
				if not module then
					local suc = pcall(function() module = require(lplr.PlayerScripts.PlayerModule).controls end)
					if not suc then
						module = {}
					end
				end
				
				old = module.moveFunction
				local flymod, ang, oldent = vape.Modules.Fly or {Enabled = false}
				module.moveFunction = function(self, vec, face)
					local wallcheck = Targets.Walls["Enabled"]
					local ent = not inputService:IsKeyDown(Enum.KeyCode.S) and entitylib.EntityPosition({
						Range = SearchRange.Value,
						Wallcheck = wallcheck,
						Part = 'RootPart',
						Players = Targets.Players["Enabled"],
						NPCs = Targets.NPCs["Enabled"]
					})
	
					if ent then
						local root, targetPos = entitylib.character.RootPart, ent.RootPart.Position
						rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, ent.Character}
						rayCheck.CollisionGroup = root.CollisionGroup
	
						if flymod["Enabled"] or workspace:Raycast(targetPos, Vector3.new(0, -70, 0), rayCheck) then
							local factor, localPosition = 0, root.Position
							if ent ~= oldent then
								ang = math.deg(select(2, CFrame.lookAt(targetPos, localPosition):ToEulerAnglesYXZ()))
							end
							local yFactor = math.abs(localPosition.Y - targetPos.Y) * (YFactor.Value / 100)
							local entityPos = Vector3.new(targetPos.X, localPosition.Y, targetPos.Z)
							local newPos = entityPos + (CFrame.Angles(0, math.rad(ang), 0).LookVector * (StrafeRange.Value - yFactor))
							local startRay, endRay = entityPos, newPos
	
							if not wallcheck and workspace:Raycast(targetPos, (localPosition - targetPos), rayCheck) then
								startRay, endRay = entityPos + (CFrame.Angles(0, math.rad(ang), 0).LookVector * (entityPos - localPosition).Magnitude), entityPos
							end
	
							local ray = workspace:Blockcast(CFrame.new(startRay), Vector3.new(1, entitylib.character.HipHeight + (root.Size.Y / 2), 1), (endRay - startRay), rayCheck)
							if (localPosition - newPos).Magnitude < 3 or ray then
								factor = (8 - math.min((localPosition - newPos).Magnitude, 3))
								if ray then
									newPos = ray.Position + (ray.Normal * 1.5)
									factor = (localPosition - newPos).Magnitude > 3 and 0 or factor
								end
							end
	
							if not flymod["Enabled"] and not workspace:Raycast(newPos, Vector3.new(0, -70, 0), rayCheck) then
								newPos = entityPos
								factor = 40
							end
	
							ang += factor % 360
							vec = ((newPos - localPosition) * Vector3.new(1, 0, 1)).Unit
							vec = vec == vec and vec or Vector3.zero
							TargetStrafeVector = vec
						else
							ent = nil
						end
					end
	
					TargetStrafeVector = ent and vec or nil
					oldent = ent
					return old(self, vec, face)
				end
			else
				if module and old then
					module.moveFunction = old
				end
				TargetStrafeVector = nil
			end
		end,
		Tooltip = 'Automatically strafes around the opponent'
	})
	Targets = TargetStrafe:CreateTargets({
		["Players"] = true,
		["Walls"] = true
	})
	SearchRange = TargetStrafe:CreateSlider({
		["Name"] = 'Search Range',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 24,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	StrafeRange = TargetStrafe:CreateSlider({
		["Name"] = 'Strafe Range',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 18,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	YFactor = TargetStrafe:CreateSlider({
		["Name"] = 'Y Factor',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 100,
		["Suffix"] = '%'
	})
end)

setfflag("SimEnableStepPhysics", "True")
setfflag("SimEnableStepPhysicsSelective", "True")
velo.run(function()
	local Timer
	local Value
	Timer = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Timer',
		["Function"] = function(callback: boolean): void
			if callback then
				Timer:Clean(runService.RenderStepped:Connect(function(dt)
					if Value.Value > 1 then
						runService:Pause()
						workspace:StepPhysics(dt * (Value.Value - 1), {entitylib.character.RootPart})
						runService:Run()
					end
				end))
			end
		end,
		Tooltip = 'Change the game speed.'
	})
	Value = Timer:CreateSlider({
		["Name"] = 'Value',
		["Min"] = 1,
		["Max"] = 3,
		["Decimal"] = 10
	})
end)
	
velo.run(function()
	local Arrows: table = {["Enabled"] = false}
	local Targets
	local Color
	local Teammates
	local Distance
	local DistanceLimit
	local Reference = {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	
	local function Added(ent)
		if not Targets.Players["Enabled"] and ent.Player then return end
		if not Targets.NPCs["Enabled"] and ent.NPC then return end
		if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) and (not ent.Friend) then return end
		if vape.ThreadFix then
			setthreadidentity(8)
		end
		local EntityArrow = Instance.new('ImageLabel')
		EntityArrow.Size = UDim2.fromOffset(256, 256)
		EntityArrow.Position = UDim2.fromScale(0.5, 0.5)
		EntityArrow.AnchorPoint = Vector2.new(0.5, 0.5)
		EntityArrow.BackgroundTransparency = 1
		EntityArrow.BorderSizePixel = 0
		EntityArrow.Visible = false
		EntityArrow.Image = getcustomasset('newvape/assets/new/arrowmodule.png')
		EntityArrow.ImageColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
		EntityArrow.Parent = Folder
		Reference[ent] = EntityArrow
	end
	
	local function Removed(ent)
		local v = Reference[ent]
		if v then
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			Reference[ent] = nil
			v:Destroy()
		end
	end
	
	local function ColorFunc(hue, sat, val)
		local color = Color3.fromHSV(hue, sat, val)
		for ent, EntityArrow in Reference do
			EntityArrow.ImageColor3 = entitylib.getEntityColor(ent) or color
		end
	end
	
	local function Loop()
		for ent, EntityArrow in Reference do
			if Distance["Enabled"] then
				local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
				if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
					EntityArrow.Visible = false
					continue
				end
			end
	
			local _, rootVis = gameCamera:WorldToScreenPoint(ent.RootPart.Position)
			EntityArrow.Visible = not rootVis
			if rootVis then continue end
			
			local dir = (gameCamera.CFrame:PointToObjectSpace(ent.RootPart.Position) * Vector3.new(1, 0, 1)).Unit
			EntityArrow.Rotation = math.deg(math.atan2(dir.Z, dir.X))
		end
	end
	
	Arrows = vape.Categories.Render:CreateModule({
		["Name"] = 'Arrows',
		["Function"] = function(callback: boolean): void
			if callback then
				Arrows:Clean(entitylib.Events.EntityRemoved:Connect(Removed))
				for _, v in entitylib.List do
					if Reference[v] then Removed(v) end
					Added(v)
				end
				Arrows:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
					if Reference[ent] then Removed(ent) end
					Added(ent)
				end))
				Arrows:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
					ColorFunc(Color.Hue, Color.Sat, Color.Value)
				end))
				Arrows:Clean(runService.RenderStepped:Connect(Loop))
			else
				for i in Reference do
					Removed(i)
				end
			end
		end,
		Tooltip = 'Draws arrows on screen when entities\nare out of your field of view.'
	})
	Targets = Arrows:CreateTargets({
		Players = true,
		["Function"] = function()
			if Arrows["Enabled"] then
				Arrows:Toggle()
				Arrows:Toggle()
			end
		end
	})
	Color = Arrows:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue, sat, val)
			if Arrows["Enabled"] then
				ColorFunc(hue, sat, val)
			end
		end,
	})
	Teammates = Arrows:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if Arrows["Enabled"] then
				Arrows:Toggle()
				Arrows:Toggle()
			end
		end,
		["Default"] = true,
		Tooltip = 'Hides teammates & non targetable entities'
	})
	Distance = Arrows:CreateToggle({
		["Name"] = 'Distance Check',
		["Function"] = function(callback: boolean): void
			DistanceLimit.Object.Visible = callback
		end
	})
	DistanceLimit = Arrows:CreateTwoSlider({
		["Name"] = 'Player Distance',
		["Min"] = 0,
		["Max"] = 256,
		DefaultMin = 0,
		DefaultMax = 64,
		["Darker"] = true,
		["Visible"] = false
	})
end)
	
velo.run(function()
	local Chams: table = {["Enabled"] = false}
	local Targets
	local Mode
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency
	local Teammates
	local Walls
	local Reference = {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	
	local function Added(ent)
		if not Targets.Players["Enabled"] and ent.Player then return end
		if not Targets.NPCs["Enabled"] and ent.NPC then return end
		if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return end
		if vape.ThreadFix then
			setthreadidentity(8)
		end
		if Mode.Value == 'Highlight' then
			local cham = Instance.new('Highlight')
			cham.Adornee = ent.Character
			cham.DepthMode = Enum.HighlightDepthMode[Walls["Enabled"] and 'AlwaysOnTop' or 'Occluded']
			cham.FillColor = entitylib.getEntityColor(ent) or Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
			cham.OutlineColor = Color3.fromHSV(OutlineColor.Hue, OutlineColor.Sat, OutlineColor.Value)
			cham.FillTransparency = FillTransparency.Value
			cham.OutlineTransparency = OutlineTransparency.Value
			cham.Parent = Folder
			Reference[ent] = cham
		else
			local chams = {}
			for _, v in ent.Character:GetChildren() do
				if v:IsA('BasePart') and (ent.NPC or v.Name:find('Arm') or v.Name:find('Leg') or v.Name:find('Hand') or v.Name:find('Feet') or v.Name:find('Torso') or v.Name == 'Head') then
					local box = Instance.new(v.Name == 'Head' and 'SphereHandleAdornment' or 'BoxHandleAdornment')
					if v.Name == 'Head' then
						box.Radius = 0.75
					else
						box.Size = v.Size
					end
					box.AlwaysOnTop = Walls["Enabled"]
					box.Adornee = v
					box.ZIndex = 0
					box.Transparency = FillTransparency.Value
					box.Color3 = entitylib.getEntityColor(ent) or Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
					box.Parent = Folder
					table.insert(chams, box)
				end
			end
			Reference[ent] = chams
		end
	end
	
	local function Removed(ent)
		if Reference[ent] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			if type(Reference[ent]) == 'table' then
				for _, v in Reference[ent] do
					v:Destroy()
				end
				table.clear(Reference[ent])
			else
				Reference[ent]:Destroy()
			end
			Reference[ent] = nil
		end
	end
	
	Chams = vape.Categories.Render:CreateModule({
		["Name"] = 'Chams',
		["Function"] = function(callback: boolean): void
			if callback then
				Chams:Clean(entitylib.Events.EntityRemoved:Connect(Removed))
				Chams:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
					if Reference[ent] then
						Removed(ent)
					end
					Added(ent)
				end))
				Chams:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
					for i, v in Reference do
						local color = entitylib.getEntityColor(i) or Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
						if type(v) == 'table' then
							for _, v2 in v do v2.Color3 = color end
						else
							v.FillColor = color
						end
					end
				end))
				for _, v in entitylib.List do
					if Reference[v] then
						Removed(v)
					end
					Added(v)
				end
			else
				for i in Reference do
					Removed(i)
				end
			end
		end,
		Tooltip = 'Render players through walls'
	})
	Targets = Chams:CreateTargets({
		Players = true,
		["Function"] = function()
			if Chams["Enabled"] then
				Chams:Toggle()
				Chams:Toggle()
			end
		end
		})
	Mode = Chams:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Highlight', 'BoxHandles'},
		["Function"] = function(val)
			OutlineColor.Object.Visible = val == 'Highlight'
			OutlineTransparency.Object.Visible = val == 'Highlight'
			if Chams["Enabled"] then
				Chams:Toggle()
				Chams:Toggle()
			end
		end
	})
	FillColor = Chams:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function(hue, sat, val)
			for i, v in Reference do
				local color = entitylib.getEntityColor(i) or Color3.fromHSV(hue, sat, val)
				if type(v) == 'table' then
					for _, v2 in v do v2.Color3 = color end
				else
					v.FillColor = color
				end
			end
		end
	})
	OutlineColor = Chams:CreateColorSlider({
		["Name"] = 'Outline Color',
		DefaultSat = 0,
		["Function"] = function(hue, sat, val)
			for i, v in Reference do
				if type(v) ~= 'table' then
					v.OutlineColor = entitylib.getEntityColor(i) or Color3.fromHSV(hue, sat, val)
				end
			end
		end,
		["Darker"] = true
	})
	FillTransparency = Chams:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.5,
		["Function"] = function(val)
			for _, v in Reference do
				if type(v) == 'table' then
					for _, v2 in v do v2.Transparency = val end
				else
					v.FillTransparency = val
				end
			end
		end,
		["Decimal"] = 10
	})
	OutlineTransparency = Chams:CreateSlider({
		["Name"] = 'Outline Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.5,
		["Function"] = function(val)
			for _, v in Reference do
				if type(v) ~= 'table' then
					v.OutlineTransparency = val
				end
			end
		end,
		["Decimal"] = 10,
		["Darker"] = true
	})
	Walls = Chams:CreateToggle({
		["Name"] = 'Render Walls',
		["Function"] = function(callback: boolean): void
			for _, v in Reference do
				if type(v) == 'table' then
					for _, v2 in v do
						v2.AlwaysOnTop = callback
					end
				else
					v.DepthMode = Enum.HighlightDepthMode[callback and 'AlwaysOnTop' or 'Occluded']
				end
			end
		end,
		["Default"] = true
	})
	Teammates = Chams:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if Chams["Enabled"] then
				Chams:Toggle()
				Chams:Toggle()
			end
		end,
		["Default"] = true,
		Tooltip = 'Hides teammates & non targetable entities'
	})
end)
	
velo.run(function()
	local ESP: table = {["Enabled"] = false}
	local Targets
	local Color
	local Method
	local BoundingBox
	local Filled
	local HealthBar
	local Name
	local DisplayName
	local Background
	local Teammates
	local Distance
	local DistanceLimit
	local Reference = {}
	local methodused
	
	local function ESPWorldToViewport(pos)
		local newpos = gameCamera:WorldToViewportPoint(gameCamera.CFrame:pointToWorldSpace(gameCamera.CFrame:PointToObjectSpace(pos)))
		return Vector2.new(newpos.X, newpos.Y)
	end
	
	local ESPAdded = {
		Drawing2D = function(ent)
			if not Targets.Players["Enabled"] and ent.Player then return end
			if not Targets.NPCs["Enabled"] and ent.NPC then return end
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return end
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			local EntityESP = {}
			EntityESP.Main = Drawing.new('Square')
			EntityESP.Main.Transparency = BoundingBox["Enabled"] and 1 or 0
			EntityESP.Main.ZIndex = 2
			EntityESP.Main.Filled = false
			EntityESP.Main.Thickness = 1
			EntityESP.Main.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
	
			if BoundingBox["Enabled"] then
				EntityESP.Border = Drawing.new('Square')
				EntityESP.Border.Transparency = 0.35
				EntityESP.Border.ZIndex = 1
				EntityESP.Border.Thickness = 1
				EntityESP.Border.Filled = false
				EntityESP.Border.Color = Color3.new()
				EntityESP.Border2 = Drawing.new('Square')
				EntityESP.Border2.Transparency = 0.35
				EntityESP.Border2.ZIndex = 1
				EntityESP.Border2.Thickness = 1
				EntityESP.Border2.Filled = Filled["Enabled"]
				EntityESP.Border2.Color = Color3.new()
			end
	
			if HealthBar["Enabled"] then
				EntityESP.HealthLine = Drawing.new('Line')
				EntityESP.HealthLine.Thickness = 1
				EntityESP.HealthLine.ZIndex = 2
				EntityESP.HealthLine.Color = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
				EntityESP.HealthBorder = Drawing.new('Line')
				EntityESP.HealthBorder.Thickness = 3
				EntityESP.HealthBorder.Transparency = 0.35
				EntityESP.HealthBorder.ZIndex = 1
				EntityESP.HealthBorder.Color = Color3.new()
			end
			
			if Name["Enabled"] then
				if Background["Enabled"] then
					EntityESP.TextBKG = Drawing.new('Square')
					EntityESP.TextBKG.Transparency = 0.35
					EntityESP.TextBKG.ZIndex = 0
					EntityESP.TextBKG.Thickness = 1
					EntityESP.TextBKG.Filled = true
					EntityESP.TextBKG.Color = Color3.new()
				end
				EntityESP.Drop = Drawing.new('Text')
				EntityESP.Drop.Color = Color3.new()
				EntityESP.Drop.Text = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
				EntityESP.Drop.ZIndex = 1
				EntityESP.Drop.Center = true
				EntityESP.Drop.Size = 20
				EntityESP.Text = Drawing.new('Text')
				EntityESP.Text.Text = EntityESP.Drop.Text
				EntityESP.Text.ZIndex = 2
				EntityESP.Text.Color = EntityESP.Main.Color
				EntityESP.Text.Center = true
				EntityESP.Text.Size = 20
			end
			Reference[ent] = EntityESP
		end,
		Drawing3D = function(ent)
			if not Targets.Players["Enabled"] and ent.Player then return end
			if not Targets.NPCs["Enabled"] and ent.NPC then return end
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return end
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			local EntityESP = {}
			EntityESP.Line1 = Drawing.new('Line')
			EntityESP.Line2 = Drawing.new('Line')
			EntityESP.Line3 = Drawing.new('Line')
			EntityESP.Line4 = Drawing.new('Line')
			EntityESP.Line5 = Drawing.new('Line')
			EntityESP.Line6 = Drawing.new('Line')
			EntityESP.Line7 = Drawing.new('Line')
			EntityESP.Line8 = Drawing.new('Line')
			EntityESP.Line9 = Drawing.new('Line')
			EntityESP.Line10 = Drawing.new('Line')
			EntityESP.Line11 = Drawing.new('Line')
			EntityESP.Line12 = Drawing.new('Line')
	
			local color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			for _, v in EntityESP do
				v.Thickness = 1
				v.Color = color
			end
	
			Reference[ent] = EntityESP
		end,
		DrawingSkeleton = function(ent)
			if not Targets.Players["Enabled"] and ent.Player then return end
			if not Targets.NPCs["Enabled"] and ent.NPC then return end
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return end
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			local EntityESP = {}
			EntityESP.Head = Drawing.new('Line')
			EntityESP.HeadFacing = Drawing.new('Line')
			EntityESP.Torso = Drawing.new('Line')
			EntityESP.UpperTorso = Drawing.new('Line')
			EntityESP.LowerTorso = Drawing.new('Line')
			EntityESP.LeftArm = Drawing.new('Line')
			EntityESP.RightArm = Drawing.new('Line')
			EntityESP.LeftLeg = Drawing.new('Line')
			EntityESP.RightLeg = Drawing.new('Line')
	
			local color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			for _, v in EntityESP do
				v.Thickness = 2
				v.Color = color
			end
	
			Reference[ent] = EntityESP
		end
	}
	
	local ESPRemoved = {
		Drawing2D = function(ent)
			local EntityESP = Reference[ent]
			if EntityESP then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Reference[ent] = nil
				for _, v in EntityESP do
					pcall(function()
						v.Visible = false
						v:Remove()
					end)
				end
			end
		end
	}
	ESPRemoved.Drawing3D = ESPRemoved.Drawing2D
	ESPRemoved.DrawingSkeleton = ESPRemoved.Drawing2D
	
	local ESPUpdated = {
		Drawing2D = function(ent)
			local EntityESP = Reference[ent]
			if EntityESP then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				
				if EntityESP.HealthLine then
					EntityESP.HealthLine.Color = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
				end
	
				if EntityESP.Text then
					EntityESP.Text.Text = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
					EntityESP.Drop.Text = EntityESP.Text.Text
				end
			end
		end
	}
	
	local ColorFunc = {
		Drawing2D = function(hue, sat, val)
			local color = Color3.fromHSV(hue, sat, val)
			for i, v in Reference do
				v.Main.Color = entitylib.getEntityColor(i) or color
				if v.Text then
					v.Text.Color = v.Main.Color
				end
			end
		end,
		Drawing3D = function(hue, sat, val)
			local color = Color3.fromHSV(hue, sat, val)
			for i, v in Reference do
				local playercolor = entitylib.getEntityColor(i) or color
				for _, v2 in v do
					v2.Color = playercolor
				end
			end
		end
	}
	ColorFunc.DrawingSkeleton = ColorFunc.Drawing3D
	
	local ESPLoop = {
		Drawing2D = function()
			for ent, EntityESP in Reference do
				if Distance["Enabled"] then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						for _, obj in EntityESP do
							obj.Visible = false
						end
						continue
					end
				end
	
				local rootPos, rootVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position)
				for _, obj in EntityESP do
					obj.Visible = rootVis
				end
				if not rootVis then continue end
	
				local topPos = gameCamera:WorldToViewportPoint((CFrame.lookAlong(ent.RootPart.Position, gameCamera.CFrame.LookVector) * CFrame.new(2, ent.HipHeight, 0)).p)
				local bottomPos = gameCamera:WorldToViewportPoint((CFrame.lookAlong(ent.RootPart.Position, gameCamera.CFrame.LookVector) * CFrame.new(-2, -ent.HipHeight - 1, 0)).p)
				local sizex, sizey = topPos.X - bottomPos.X, topPos.Y - bottomPos.Y
				local posx, posy = (rootPos.X - sizex / 2),  ((rootPos.Y - sizey / 2))
				EntityESP.Main.Position = Vector2.new(posx, posy) // 1
				EntityESP.Main.Size = Vector2.new(sizex, sizey) // 1
				if EntityESP.Border then
					EntityESP.Border.Position = Vector2.new(posx - 1, posy + 1) // 1
					EntityESP.Border.Size = Vector2.new(sizex + 2, sizey - 2) // 1
					EntityESP.Border2.Position = Vector2.new(posx + 1, posy - 1) // 1
					EntityESP.Border2.Size = Vector2.new(sizex - 2, sizey + 2) // 1
				end
	
				if EntityESP.HealthLine then
					local healthposy = sizey * math.clamp(ent.Health / ent.MaxHealth, 0, 1)
					EntityESP.HealthLine.Visible = ent.Health > 0
					EntityESP.HealthLine.From = Vector2.new(posx - 6, posy + (sizey - (sizey - healthposy))) // 1
					EntityESP.HealthLine.To = Vector2.new(posx - 6, posy) // 1
					EntityESP.HealthBorder.From = Vector2.new(posx - 6, posy + 1) // 1
					EntityESP.HealthBorder.To = Vector2.new(posx - 6, (posy + sizey) - 1) // 1
				end
	
				if EntityESP.Text then
					EntityESP.Text.Position = Vector2.new(posx + (sizex / 2), posy + (sizey - 28)) // 1
					EntityESP.Drop.Position = EntityESP.Text.Position + Vector2.new(1, 1)
					if EntityESP.TextBKG then
						EntityESP.TextBKG.Size = EntityESP.Text.TextBounds + Vector2.new(8, 4)
						EntityESP.TextBKG.Position = EntityESP.Text.Position - Vector2.new(4 + (EntityESP.Text.TextBounds.X / 2), 0)
					end
				end
			end
		end,
		Drawing3D = function()
			for ent, EntityESP in Reference do
				if Distance["Enabled"] then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						for _, obj in EntityESP do
							obj.Visible = false
						end
						continue
					end
				end
	
				local _, rootVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position)
				for _, obj in EntityESP do
					obj.Visible = rootVis
				end
				if not rootVis then continue end
	
				local point1 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, ent.HipHeight, 1.5))
				local point2 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, -ent.HipHeight, 1.5))
				local point3 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(-1.5, ent.HipHeight, 1.5))
				local point4 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(-1.5, -ent.HipHeight, 1.5))
				local point5 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, ent.HipHeight, -1.5))
				local point6 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, -ent.HipHeight, -1.5))
				local point7 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(-1.5, ent.HipHeight, -1.5))
				local point8 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(-1.5, -ent.HipHeight, -1.5))
				EntityESP.Line1.From = point1
				EntityESP.Line1.To = point2
				EntityESP.Line2.From = point3
				EntityESP.Line2.To = point4
				EntityESP.Line3.From = point5
				EntityESP.Line3.To = point6
				EntityESP.Line4.From = point7
				EntityESP.Line4.To = point8
				EntityESP.Line5.From = point1
				EntityESP.Line5.To = point3
				EntityESP.Line6.From = point1
				EntityESP.Line6.To = point5
				EntityESP.Line7.From = point5
				EntityESP.Line7.To = point7
				EntityESP.Line8.From = point7
				EntityESP.Line8.To = point3
				EntityESP.Line9.From = point2
				EntityESP.Line9.To = point4
				EntityESP.Line10.From = point2
				EntityESP.Line10.To = point6
				EntityESP.Line11.From = point6
				EntityESP.Line11.To = point8
				EntityESP.Line12.From = point8
				EntityESP.Line12.To = point4
			end
		end,
		DrawingSkeleton = function()
			for ent, EntityESP in Reference do
				if Distance["Enabled"] then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						for _, obj in EntityESP do
							obj.Visible = false
						end
						continue
					end
				end
	
				local _, rootVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position)
				for _, obj in EntityESP do
					obj.Visible = rootVis
				end
				if not rootVis then continue end
				
				local rigcheck = ent.Humanoid.RigType == Enum.HumanoidRigType.R6
				pcall(function()
					local offset = rigcheck and CFrame.new(0, -0.8, 0) or CFrame.identity
					local head = ESPWorldToViewport((ent.Head.CFrame).p)
					local headfront = ESPWorldToViewport((ent.Head.CFrame * CFrame.new(0, 0, -0.5)).p)
					local toplefttorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(-1.5, 0.8, 0)).p)
					local toprighttorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(1.5, 0.8, 0)).p)
					local toptorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0, 0.8, 0)).p)
					local bottomtorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0, -0.8, 0)).p)
					local bottomlefttorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(-0.5, -0.8, 0)).p)
					local bottomrighttorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0.5, -0.8, 0)).p)
					local leftarm = ESPWorldToViewport((ent.Character[(rigcheck and 'Left Arm' or 'LeftHand')].CFrame * offset).p)
					local rightarm = ESPWorldToViewport((ent.Character[(rigcheck and 'Right Arm' or 'RightHand')].CFrame * offset).p)
					local leftleg = ESPWorldToViewport((ent.Character[(rigcheck and 'Left Leg' or 'LeftFoot')].CFrame * offset).p)
					local rightleg = ESPWorldToViewport((ent.Character[(rigcheck and 'Right Leg' or 'RightFoot')].CFrame * offset).p)
					EntityESP.Head.From = toptorso
					EntityESP.Head.To = head
					EntityESP.HeadFacing.From = head
					EntityESP.HeadFacing.To = headfront
					EntityESP.UpperTorso.From = toplefttorso
					EntityESP.UpperTorso.To = toprighttorso
					EntityESP.Torso.From = toptorso
					EntityESP.Torso.To = bottomtorso
					EntityESP.LowerTorso.From = bottomlefttorso
					EntityESP.LowerTorso.To = bottomrighttorso
					EntityESP.LeftArm.From = toplefttorso
					EntityESP.LeftArm.To = leftarm
					EntityESP.RightArm.From = toprighttorso
					EntityESP.RightArm.To = rightarm
					EntityESP.LeftLeg.From = bottomlefttorso
					EntityESP.LeftLeg.To = leftleg
					EntityESP.RightLeg.From = bottomrighttorso
					EntityESP.RightLeg.To = rightleg
				end)
			end
		end
	}
	
	ESP = vape.Categories.Render:CreateModule({
		["Name"] = 'ESP',
		["Function"] = function(callback: boolean): void
			if callback then
				methodused = 'Drawing'..Method.Value
				if ESPRemoved[methodused] then
					ESP:Clean(entitylib.Events.EntityRemoved:Connect(ESPRemoved[methodused]))
				end
				if ESPAdded[methodused] then
					for _, v in entitylib.List do
						if Reference[v] then
							ESPRemoved[methodused](v)
						end
						ESPAdded[methodused](v)
					end
					ESP:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
						if Reference[ent] then
							ESPRemoved[methodused](ent)
						end
						ESPAdded[methodused](ent)
					end))
				end
				if ESPUpdated[methodused] then
					ESP:Clean(entitylib.Events.EntityUpdated:Connect(ESPUpdated[methodused]))
					for _, v in entitylib.List do
						ESPUpdated[methodused](v)
					end
				end
				if ColorFunc[methodused] then
					ESP:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
						ColorFunc[methodused](Color.Hue, Color.Sat, Color.Value)
					end))
				end
				if ESPLoop[methodused] then
					ESP:Clean(runService.RenderStepped:Connect(ESPLoop[methodused]))
				end
			else
				if ESPRemoved[methodused] then
					for i in Reference do
						ESPRemoved[methodused](i)
					end
				end
			end
		end,
		Tooltip = 'Extra Sensory Perception\nRenders an ESP on players.'
	})
	Targets = ESP:CreateTargets({
		Players = true,
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle()
				ESP:Toggle()
			end
		end
	})
	Method = ESP:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'2D', '3D', 'Skeleton'},
		["Function"] = function(val)
			if ESP["Enabled"] then
				ESP:Toggle()
				ESP:Toggle()
			end
			BoundingBox.Object.Visible = (val == '2D')
			Filled.Object.Visible = (val == '2D')
			HealthBar.Object.Visible = (val == '2D')
			Name.Object.Visible = (val == '2D')
			DisplayName.Object.Visible = Name.Object.Visible and Name["Enabled"]
			Background.Object.Visible = Name.Object.Visible and Name["Enabled"]
		end,
	})
	Color = ESP:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue, sat, val)
			if ESP["Enabled"] and ColorFunc[methodused] then
				ColorFunc[methodused](hue, sat, val)
			end
		end
	})
	BoundingBox = ESP:CreateToggle({
		["Name"] = 'Bounding Box',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle()
				ESP:Toggle()
			end
		end,
		["Default"] = true,
		["Darker"] = true
	})
	Filled = ESP:CreateToggle({
		["Name"] = 'Filled',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle()
				ESP:Toggle()
			end
		end,
		["Darker"] = true
	})
	HealthBar = ESP:CreateToggle({
		["Name"] = 'Health Bar',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle()
				ESP:Toggle()
			end
		end,
		["Darker"] = true
	})
	Name = ESP:CreateToggle({
		["Name"] = 'Name',
		["Function"] = function(callback: boolean): void
			if ESP["Enabled"] then
				ESP:Toggle()
				ESP:Toggle()
			end
			DisplayName.Object.Visible = callback
			Background.Object.Visible = callback
		end,
		["Darker"] = true
	})
	DisplayName = ESP:CreateToggle({
		["Name"] = 'Use Displayname',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle()
				ESP:Toggle()
			end
		end,
		["Default"] = true,
		["Darker"] = true
	})
	Background = ESP:CreateToggle({
		["Name"] = 'Show Background',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle()
				ESP:Toggle()
			end
		end,
		["Darker"] = true
	})
	Teammates = ESP:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if ESP["Enabled"] then
				ESP:Toggle()
				ESP:Toggle()
			end
		end,
		["Default"] = true,
		Tooltip = 'Hides teammates & non targetable entities'
	})
	Distance = ESP:CreateToggle({
		["Name"] = 'Distance Check',
		["Function"] = function(callback: boolean): void
			DistanceLimit.Object.Visible = callback
		end
	})
	DistanceLimit = ESP:CreateTwoSlider({
		["Name"] = 'Player Distance',
		["Min"] = 0,
		["Max"] = 256,
		DefaultMin = 0,
		DefaultMax = 64,
		["Darker"] = true,
		["Visible"] = false
	})
end)
	
velo.run(function()
	local GamingChair: table = {["Enabled"] = false}
	local GamingChairSounds: table = {["Enabled"] = false};
	local Color
	local wheelpositions = {
		Vector3.new(-0.8, -0.6, -0.18),
		Vector3.new(0.1, -0.6, -0.88),
		Vector3.new(0, -0.6, 0.7)
	}
	local chairhighlight
	local currenttween
	local movingsound
	local flyingsound
	local chairanim
	local chair
	local function isAlive(v: Player): Boolean
		if v.Character and v.Character:FindFirstChild("Humanoid") then
			if v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") then
				return true;
			end;
		end;
		return false;
	end; 
	local soundMap: table = {
		["chair roll"] = {"ChairRolling.mp3", "https://raw.githubusercontent.com/Copiums/Velocity/main/assets/ChairRolling.mp3"},
		["chair fly"] = {"ChairFlying", "https://raw.githubusercontent.com/Copiums/Velocity/main/assets/ChairFlying.mp3"},
	};
	local function getSound(key: string): string?
		local info: any = soundMap[key]
		local function Get(file: string, url: string): string?
			local fullPath: string = "newvape/sounds/" .. file;
			if not isfile(fullPath) then
				local v: string = game:HttpGet(url);
				if v then
					writefile(fullPath, v);
				else
					return nil;
				end;
			end;
			return getcustomasset(fullPath);
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
			local result: any = Get(filename, url);
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
					setthreadidentity(8)
				end
				chair = Instance.new('MeshPart')
				chair.Color = Color3.fromRGB(21, 21, 21)
				chair.Size = Vector3.new(2.16, 3.6, 2.3) / Vector3.new(12.37, 20.636, 13.071)
				chair.CanCollide = false
				chair.Massless = true
				chair.MeshId = 'rbxassetid://12972961089'
				chair.Material = Enum.Material.SmoothPlastic
				chair.Parent = workspace
				movingsound = Instance.new('Sound')
				movingsound.SoundId = getSound("chair roll")
				movingsound.Volume = 0.4
				movingsound.Looped = true
				movingsound.Parent = workspace
				flyingsound = Instance.new('Sound')
				flyingsound.SoundId = getSound("chair fly")
				flyingsound.Volume = 0.4
				flyingsound.Looped = true
				flyingsound.Parent = workspace
				local chairweld = Instance.new('WeldConstraint')
				chairweld.Part0 = chair
				chairweld.Parent = chair
				if entitylib.isAlive then
					chair.CFrame = entitylib.character.RootPart.CFrame * CFrame.Angles(0, math.rad(-90), 0)
					chairweld.Part1 = entitylib.character.RootPart
				end
				chairhighlight = Instance.new('Highlight')
				chairhighlight.FillTransparency = 1
				chairhighlight.OutlineColor = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
				chairhighlight.DepthMode = Enum.HighlightDepthMode.Occluded
				chairhighlight.OutlineTransparency = 0.2
				chairhighlight.Parent = chair
				local chairarms = Instance.new('MeshPart')
				chairarms.Color = chair.Color
				chairarms.Size = Vector3.new(1.39, 1.345, 2.75) / Vector3.new(97.13, 136.216, 234.031)
				chairarms.CFrame = chair.CFrame * CFrame.new(-0.169, -1.129, -0.013)
				chairarms.MeshId = 'rbxassetid://12972673898'
				chairarms.CanCollide = false
				chairarms.Parent = chair
				local chairarmsweld = Instance.new('WeldConstraint')
				chairarmsweld.Part0 = chairarms
				chairarmsweld.Part1 = chair
				chairarmsweld.Parent = chair
				local chairlegs = Instance.new('MeshPart')
				chairlegs.Color = chair.Color
				chairlegs.Name = 'Legs'
				chairlegs.Size = Vector3.new(1.8, 1.2, 1.8) / Vector3.new(10.432, 8.105, 9.488)
				chairlegs.CFrame = chair.CFrame * CFrame.new(0.047, -2.324, 0)
				chairlegs.MeshId = 'rbxassetid://13003181606'
				chairlegs.CanCollide = false
				chairlegs.Parent = chair
				local chairfan = Instance.new('MeshPart')
				chairfan.Color = chair.Color
				chairfan.Name = 'Fan'
				chairfan.Size = Vector3.zero
				chairfan.CFrame = chair.CFrame * CFrame.new(0, -1.873, 0)
				chairfan.MeshId = 'rbxassetid://13004977292'
				chairfan.CanCollide = false
				chairfan.Parent = chair
				local trails = {}
				for _, v in wheelpositions do
					local attachment = Instance.new('Attachment')
					attachment.Position = v
					attachment.Parent = chairlegs
					local attachment2 = Instance.new('Attachment')
					attachment2.Position = v + Vector3.new(0, 0, 0.18)
					attachment2.Parent = chairlegs
					local trail = Instance.new('Trail')
					trail.Texture = 'http://www.roblox.com/asset/?id=13005168530'
					trail.TextureMode = Enum.TextureMode.Static
					trail.Transparency = NumberSequence.new(0.5)
					trail.Color = ColorSequence.new(Color3.new(0.5, 0.5, 0.5))
					trail.Attachment0 = attachment
					trail.Attachment1 = attachment2
					trail.Lifetime = 20
					trail.MaxLength = 60
					trail.MinLength = 0.1
					trail.Parent = chairlegs
					table.insert(trails, trail)
				end
				GamingChair:Clean(chair)
				GamingChair:Clean(movingsound)
				GamingChair:Clean(flyingsound)
				chairanim = {Stop = function() end}
				local oldmoving = false
				local oldflying = false
				repeat
					if entitylib.isAlive and entitylib.character.Humanoid.Health > 0 then
						if not chairanim.IsPlaying then
							local temp2 = Instance.new('Animation')
							temp2.AnimationId = entitylib.character.Humanoid.RigType == Enum.HumanoidRigType.R15 and 'http://www.roblox.com/asset/?id=2506281703' or 'http://www.roblox.com/asset/?id=178130996'
							chairanim = entitylib.character.Humanoid:LoadAnimation(temp2)
							chairanim.Priority = Enum.AnimationPriority.Movement
							chairanim.Looped = true
							chairanim:Play()
						end
						chair.CFrame = entitylib.character.RootPart.CFrame * CFrame.Angles(0, math.rad(-90), 0)
						chairweld.Part1 = entitylib.character.RootPart
						chairlegs.Velocity = Vector3.zero
						chairlegs.CFrame = chair.CFrame * CFrame.new(0.047, -2.324, 0)
						chairfan.Velocity = Vector3.zero
						chairfan.CFrame = chair.CFrame * CFrame.new(0.047, -1.873, 0) * CFrame.Angles(0, math.rad(tick() * 180 % 360), math.rad(180))
						local moving = entitylib.character.Humanoid:GetState() == Enum.HumanoidStateType.Running and entitylib.character.Humanoid.MoveDirection ~= Vector3.zero
						local flying = vape.Modules.Fly and vape.Modules.Fly["Enabled"] or vape.Modules.LongJump and vape.Modules.LongJump["Enabled"] or vape.Modules.InfiniteFly and vape.Modules.InfiniteFly["Enabled"]
						if movingsound.TimePosition > 1.9 then
							movingsound.TimePosition = 0.2
						end
						movingsound.PlaybackSpeed = (entitylib.character.RootPart.Velocity * Vector3.new(1, 0, 1)).Magnitude / 16
						for _, v in trails do
							v["Enabled"] = not flying and moving
							v.Color = ColorSequence.new(movingsound.PlaybackSpeed > 1.5 and Color3.new(1, 0.5, 0) or Color3.new())
						end
						if moving ~= oldmoving then
							if movingsound.IsPlaying then
								if not moving then
									movingsound:Stop()
								end
							else
								if not flying and moving then
									movingsound:Play()
								end
							end
							oldmoving = moving
						end
						if flying ~= oldflying then
							if flying then
								if movingsound.IsPlaying then
									movingsound:Stop()
								end
								if not flyingsound.IsPlaying then
									flyingsound:Play()
								end
								if currenttween then
									currenttween:Cancel()
								end
								tween = tweenService:Create(chairlegs, TweenInfo.new(0.15), {
									Size = Vector3.zero
								})
								tween.Completed:Connect(function(state)
									if state == Enum.PlaybackState.Completed then
										chairfan.Transparency = 0
										chairlegs.Transparency = 1
										tween = tweenService:Create(chairfan, TweenInfo.new(0.15), {
											Size = Vector3.new(1.534, 0.328, 1.537) / Vector3.new(791.138, 168.824, 792.027)
										})
										tween:Play()
									end
								end)
								tween:Play()
							else
								if flyingsound.IsPlaying then
									flyingsound:Stop()
								end
								if not movingsound.IsPlaying and moving then
									movingsound:Play()
								end
								if currenttween then currenttween:Cancel() end
								tween = tweenService:Create(chairfan, TweenInfo.new(0.15), {
									Size = Vector3.zero
								})
								tween.Completed:Connect(function(state)
									if state == Enum.PlaybackState.Completed then
										chairfan.Transparency = 1
										chairlegs.Transparency = 0
										tween = tweenService:Create(chairlegs, TweenInfo.new(0.15), {
											Size = Vector3.new(1.8, 1.2, 1.8) / Vector3.new(10.432, 8.105, 9.488)
										})
										tween:Play()
									end
								end)
								tween:Play()
							end
							oldflying = flying
						end
					else
						chair.Anchored = true
						chairlegs.Anchored = true
						chairfan.Anchored = true
						repeat task.wait() until entitylib.isAlive and entitylib.character.Humanoid.Health > 0
						if GamingChair["Enabled"] then
							GamingChair:Toggle()
							GamingChair:Toggle()
						end;
						chair.Anchored = false
						chairlegs.Anchored = false
						chairfan.Anchored = false
						chairanim:Stop()
					end
					task.wait()
				until not GamingChair["Enabled"]
			else
				if chairanim then
					chairanim:Stop()
				end
			end
		end,
		["Tooltip"] = 'Sit in the best gaming chair known to mankind.'
	})
	Color = GamingChair:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function(h, s, v)
			if chairhighlight then
				chairhighlight.OutlineColor = Color3.fromHSV(h, s, v)
			end
		end
	})
end)
	
velo.run(function()
	local Health: table = {["Enabled"] = false};
	Health = vape.Categories.Render:CreateModule({
		["Name"] = 'Health',
		["Function"] = function(callbac: boolean): void
			if callback then
				local label: TextLabel = Instance.new('TextLabel');
				label.Size = UDim2.fromOffset(100, 20);
				label.Position = UDim2.new(0.5, 6, 0.5, 30);
				label.AnchorPoint = Vector2.new(0.5, 0);
				label.BackgroundTransparency = 1;
				label.Text = '100 ❤️';
				label.TextSize = 18;
				label.Font = Enum.Font.Arial;
				label.Parent = vape.gui;
				Health:Clean(label)
				
				repeat
					label.Text = entitylib.isAlive and math.round(entitylib.character.Humanoid.Health)..' ❤️' or '';
					label.TextColor3 = entitylib.isAlive and Color3.fromHSV((entitylib.character.Humanoid.Health / entitylib.character.Humanoid.MaxHealth) / 2.8, 0.86, 1) or Color3.new();
					task.wait();
				until not Health["Enabled"];
			end;
		end,
		Tooltip = 'Displays your health in the center of your screen.'
	})
end)
	
velo.run(function()
	local NameTags: table = {["Enabled"] = false};
	local Targets: any
	local Color
	local Background
	local DisplayName
	local Health
	local Distance
	local DrawingToggle
	local Scale
	local FontOption
	local Teammates
	local DistanceCheck
	local DistanceLimit
	local Strings, Sizes, Reference = {}, {}, {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	local methodused
	
	local Added: table = {
		Normal = function(ent)
			if not Targets.Players["Enabled"] and ent.Player then return end
			if not Targets.NPCs["Enabled"] and ent.NPC then return end
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return end
			if vape.ThreadFix then
				setthreadidentity(8)
			end
	
			Strings[ent] = ent.Player and whitelist:tag(ent.Player, true, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
			
			if Health["Enabled"] then
				local healthColor = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
				Strings[ent] = Strings[ent]..' <font color="rgb('..tostring(math.floor(healthColor.R * 255))..','..tostring(math.floor(healthColor.G * 255))..','..tostring(math.floor(healthColor.B * 255))..')">'..math.round(ent.Health)..'</font>'
			end
	
			if Distance["Enabled"] then
				Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..Strings[ent]
			end
	
			local nametag: TextLabel = Instance.new('TextLabel')
			nametag.TextSize = 14 * Scale.Value
			nametag.FontFace = FontOption.Value
			local ize: any = getfontsize(removeTags(Strings[ent]), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
			nametag.Name = ent.Player and ent.Player.Name or ent.Character.Name
			nametag.Size = UDim2.fromOffset(ize.X + 8, ize.Y + 7)
			nametag.AnchorPoint = Vector2.new(0.5, 1)
			nametag.BackgroundColor3 = Color3.new()
			nametag.BackgroundTransparency = Background.Value
			nametag.BorderSizePixel = 0
			nametag.Visible = false
			nametag.Text = Strings[ent]
			nametag.TextColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			nametag.RichText = true
			nametag.Parent = Folder
			Reference[ent] = nametag
		end,
		Drawing = function(ent)
			if not Targets.Players["Enabled"] and ent.Player then return end
			if not Targets.NPCs["Enabled"] and ent.NPC then return end
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return end
			if vape.ThreadFix then
				setthreadidentity(8)
			end
	
			local nametag: table = {}
			nametag.BG = Drawing.new('Square')
			nametag.BG.Filled = true
			nametag.BG.Transparency = 1 - Background.Value
			nametag.BG.Color = Color3.new()
			nametag.BG.ZIndex = 1
			nametag.Text = Drawing.new('Text')
			nametag.Text.Size = 15 * Scale.Value
			nametag.Text.Font = 0
			nametag.Text.ZIndex = 2
			Strings[ent] = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
			
			if Health["Enabled"] then
				Strings[ent] = Strings[ent]..' '..math.round(ent.Health)
			end
	
			if Distance["Enabled"] then
				Strings[ent] = '[%s] '..Strings[ent]
			end
	
			nametag.Text.Text = Strings[ent]
			nametag.Text.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
			Reference[ent] = nametag
		end
	}
	
	local Removed: table = {
		Normal = function(ent)
			local v = Reference[ent]
			if v then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Reference[ent] = nil
				Strings[ent] = nil
				Sizes[ent] = nil
				v:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = Reference[ent]
			if v then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Reference[ent] = nil
				Strings[ent] = nil
				Sizes[ent] = nil
				for _, v2 in v do
					pcall(function()
						v2.Visible = false
						v2:Remove()
					end)
				end
			end
		end
	}
	
	local Updated: table = {
		Normal = function(ent)
			local nametag = Reference[ent]
			if nametag then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Sizes[ent] = nil
				Strings[ent] = ent.Player and whitelist:tag(ent.Player, true, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
				
				if Health["Enabled"] then
					local color = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
					Strings[ent] = Strings[ent]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Health)..'</font>'
				end
	
				if Distance["Enabled"] then
					Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..Strings[ent]
				end
	
				local ize = getfontsize(removeTags(Strings[ent]), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
				nametag.Size = UDim2.fromOffset(ize.X + 8, ize.Y + 7)
				nametag.Text = Strings[ent]
			end
		end,
		Drawing = function(ent)
			local nametag = Reference[ent]
			if nametag then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Sizes[ent] = nil
				Strings[ent] = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
				
				if Health["Enabled"] then
					Strings[ent] = Strings[ent]..' '..math.round(ent.Health)
				end
	
				if Distance["Enabled"] then
					Strings[ent] = '[%s] '..Strings[ent]
					nametag.Text.Text = entitylib.isAlive and string.format(Strings[ent], math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude)) or Strings[ent]
				else
					nametag.Text.Text = Strings[ent]
				end
	
				nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
				nametag.Text.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			end
		end
	}
	
	local ColorFunc: table = {
		Normal = function(hue, sat, val)
			local color = Color3.fromHSV(hue, sat, val)
			for i, v in Reference do
				v.TextColor3 = entitylib.getEntityColor(i) or color
			end
		end,
		Drawing = function(hue, sat, val)
			local color = Color3.fromHSV(hue, sat, val)
			for i, v in Reference do
				v.Text.Color = entitylib.getEntityColor(i) or color
			end
		end
	}
	
	local Loop: table = {
		Normal = function()
			for ent, nametag in Reference do
				if DistanceCheck["Enabled"] then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						nametag.Visible = false
						continue
					end
				end
	
				local headPos, headVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0))
				nametag.Visible = headVis
				if not headVis then
					continue
				end
	
				if Distance["Enabled"] then
					local mag = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude) or 0
					if Sizes[ent] ~= mag then
						nametag.Text = string.format(Strings[ent], mag)
						local ize = getfontsize(removeTags(nametag.Text), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
						nametag.Size = UDim2.fromOffset(ize.X + 8, ize.Y + 7)
						Sizes[ent] = mag
					end
				end
				nametag.Position = UDim2.fromOffset(headPos.X, headPos.Y)
			end
		end,
		Drawing = function()
			for ent, nametag in Reference do
				if DistanceCheck["Enabled"] then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						nametag.Text.Visible = false
						nametag.BG.Visible = false
						continue
					end
				end
	
				local headPos, headVis = gameCamera:WorldToScreenPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0))
				nametag.Text.Visible = headVis
				nametag.BG.Visible = headVis
				if not headVis then
					continue
				end
	
				if Distance["Enabled"] then
					local mag = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude) or 0
					if Sizes[ent] ~= mag then
						nametag.Text.Text = string.format(Strings[ent], mag)
						nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
						Sizes[ent] = mag
					end
				end
				nametag.BG.Position = Vector2.new(headPos.X - (nametag.BG.Size.X / 2), headPos.Y + (nametag.BG.Size.Y / 2))
				nametag.Text.Position = nametag.BG.Position + Vector2.new(4, 2.5)
			end
		end
	}
	
	NameTags = vape.Categories.Render:CreateModule({
		["Name"] = 'NameTags',
		["Function"] = function(callback: boolean): void
			if callback then
				methodused = DrawingToggle["Enabled"] and 'Drawing' or 'Normal'
				if Removed[methodused] then
					NameTags:Clean(entitylib.Events.EntityRemoved:Connect(Removed[methodused]))
				end
				if Added[methodused] then
					for _, v in entitylib.List do
						if Reference[v] then
							Removed[methodused](v)
						end
						Added[methodused](v)
					end
					NameTags:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
						if Reference[ent] then
							Removed[methodused](ent)
						end
						Added[methodused](ent)
					end))
				end
				if Updated[methodused] then
					NameTags:Clean(entitylib.Events.EntityUpdated:Connect(Updated[methodused]))
					for _, v in entitylib.List do
						Updated[methodused](v)
					end
				end
				if ColorFunc[methodused] then
					NameTags:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
						ColorFunc[methodused](Color.Hue, Color.Sat, Color.Value)
					end))
				end
				if Loop[methodused] then
					NameTags:Clean(runService.RenderStepped:Connect(Loop[methodused]))
				end
			else
				if Removed[methodused] then
					for i in Reference do
						Removed[methodused](i)
					end
				end
			end
		end,
		["Tooltip"] = 'Renders nametags on entities through walls.'
	})
	Targets = NameTags:CreateTargets({
		["Players"] = true,
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	FontOption = NameTags:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Arial',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	Color = NameTags:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue, sat, val)
			if NameTags["Enabled"] and ColorFunc[methodused] then
				ColorFunc[methodused](hue, sat, val)
			end
		end
	})
	Scale = NameTags:CreateSlider({
		["Name"] = 'Scale',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		["Default"] = 1,
		["Min"] = 0.1,
		["Max"] = 1.5,
		["Decimal"] = 10
	})
	Background = NameTags:CreateSlider({
		["Name"] = 'Transparency',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		["Default"] = 0.5,
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10
	})
	Health = NameTags:CreateToggle({
		["Name"] = 'Health',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	Distance = NameTags:CreateToggle({
		["Name"] = 'Distance',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	DisplayName = NameTags:CreateToggle({
		["Name"] = 'Use Displayname',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		["Default"] = true
	})
	Teammates = NameTags:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		["Default"] = true,
		["Tooltip"] = 'Hides teammates & non targetable entities'
	})
	DrawingToggle = NameTags:CreateToggle({
		["Name"] = 'Drawing',
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	DistanceCheck = NameTags:CreateToggle({
		["Name"] = 'Distance Check',
		["Function"] = function(callback: boolean): void
			DistanceLimit.Object.Visible = callback
		end
	})
	DistanceLimit = NameTags:CreateTwoSlider({
		["Name"] = 'Player Distance',
		["Min"] = 0,
		["Max"] = 256,
		["DefaultMin"] = 0,
		["DefaultMax"] = 64,
		["Darker"] = true,
		["Visible"] = false
	})
end)
	
velo.run(function()
	local PlayerModel: table = {["Enabled"] = false}
	local Scale
	local Local
	local Mesh
	local Texture
	local Rots = {}
	local models = {}
	
	local function addMesh(ent)
		if vape.ThreadFix then 
			setthreadidentity(8)
		end
		local root = ent.RootPart
		local part = Instance.new('Part')
		part.Size = Vector3.new(3, 3, 3)
		part.CFrame = root.CFrame * CFrame.Angles(math.rad(Rots[1].Value), math.rad(Rots[2].Value), math.rad(Rots[3].Value))
		part.CanCollide = false
		part.CanQuery = false
		part.Massless = true
		part.Parent = workspace
		local meshd = Instance.new('SpecialMesh')
		meshd.MeshId = Mesh.Value
		meshd.TextureId = Texture.Value
		meshd.Scale = Vector3.one * Scale.Value
		meshd.Parent = part
		local weld = Instance.new('WeldConstraint')
		weld.Part0 = part
		weld.Part1 = root
		weld.Parent = part
		models[root] = part
	end
	
	local function removeMesh(ent)
		if models[ent.RootPart] then 
			models[ent.RootPart]:Destroy()
			models[ent.RootPart] = nil
		end
	end
	
	PlayerModel = vape.Categories.Render:CreateModule({
		["Name"] = 'PlayerModel',
		["Function"] = function(callback: boolean): void
			if callback then 
				if Local["Enabled"] then 
					PlayerModel:Clean(entitylib.Events.LocalAdded:Connect(addMesh))
					PlayerModel:Clean(entitylib.Events.LocalRemoved:Connect(removeMesh))
					if entitylib.isAlive then 
						task.spawn(addMesh, entitylib.character)
					end
				end
				PlayerModel:Clean(entitylib.Events.EntityAdded:Connect(addMesh))
				PlayerModel:Clean(entitylib.Events.EntityRemoved:Connect(removeMesh))
				for _, ent in entitylib.List do 
					task.spawn(addMesh, ent)
				end
			else
				for _, part in models do 
					part:Destroy()
				end
				table.clear(models)
			end
		end,
		Tooltip = 'Change the player models to a Mesh'
	})
	Scale = PlayerModel:CreateSlider({
		["Name"] = 'Scale',
		["Min"] = 0,
		["Max"] = 2,
		["Default"] = 1,
		["Decimal"] = 100,
		["Function"] = function(val)
			for _, part in models do 
				part.Mesh.Scale = Vector3.one * val
			end
		end
	})
	for _, name in {'Rotation X', 'Rotation Y', 'Rotation Z'} do 
		table.insert(Rots, PlayerModel:CreateSlider({
			["Name"] = name,
			["Min"] = 0,
			["Max"] = 360,
			["Function"] = function(val)
				for root, part in models do 
					part.WeldConstraint["Enabled"] = false
					part.CFrame = root.CFrame * CFrame.Angles(math.rad(Rots[1].Value), math.rad(Rots[2].Value), math.rad(Rots[3].Value))
					part.WeldConstraint["Enabled"] = true
				end
			end
		}))
	end
	Local = PlayerModel:CreateToggle({
		["Name"] = 'Local',
		["Function"] = function()
			if PlayerModel["Enabled"] then 
				PlayerModel:Toggle()
				PlayerModel:Toggle()
			end
		end
	})
	Mesh = PlayerModel:CreateTextBox({
		["Name"] = 'Mesh',
		Placeholder = 'mesh id',
		["Function"] = function()
			for _, part in models do 
				part.Mesh.MeshId = Mesh.Value
			end
		end
	})
	Texture = PlayerModel:CreateTextBox({
		["Name"] = 'Texture',
		Placeholder = 'texture id',
		["Function"] = function()
			for _, part in models do 
				part.Mesh.TextureId = Texture.Value
			end
		end
	})
	
end)
	
velo.run(function()
	local Radar: table = {["Enabled"] = false}
	local Targets
	local DotStyle
	local PlayerColor
	local Clamp
	local Reference = {}
	local bkg
	
	local function Added(ent)
		if not Targets.Players["Enabled"] and ent.Player then return end
		if not Targets.NPCs["Enabled"] and ent.NPC then return end
		if (not ent.Targetable) and (not ent.Friend) then return end
		if vape.ThreadFix then
			setthreadidentity(8)
		end
	
		local EntityDot = Instance.new('Frame')
		EntityDot.Size = UDim2.fromOffset(4, 4)
		EntityDot.AnchorPoint = Vector2.new(0.5, 0.5)
		EntityDot.BackgroundColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(PlayerColor.Hue, PlayerColor.Sat, PlayerColor.Value)
		EntityDot.Parent = bkg
		local EntityCorner = Instance.new('UICorner')
		EntityCorner.CornerRadius = UDim.new(DotStyle.Value == 'Circles' and 1 or 0, 0)
		EntityCorner.Parent = EntityDot
		local EntityStroke = Instance.new('UIStroke')
		EntityStroke.Color = Color3.new()
		EntityStroke.Thickness = 1
		EntityStroke.Transparency = 0.8
		EntityStroke.Parent = EntityDot
		Reference[ent] = EntityDot
	end
	
	local function Removed(ent)
		local v = Reference[ent]
		if v then
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			Reference[ent] = nil
			v:Destroy()
		end
	end
	
	Radar = vape:CreateOverlay({
		["Name"] = 'Radar',
		Icon = getcustomasset('newvape/assets/new/radaricon.png'),
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromOffset(12, 13),
		["Function"] = function(callback: boolean): void
			if callback then
				Radar:Clean(entitylib.Events.EntityRemoved:Connect(Removed))
				for _, v in entitylib.List do
					if Reference[v] then
						Removed(v)
					end
					Added(v)
				end
				Radar:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
					if Reference[ent] then
						Removed(ent)
					end
					Added(ent)
				end))
				Radar:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
					for ent, EntityDot in Reference do
						EntityDot.BackgroundColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(PlayerColor.Hue, PlayerColor.Sat, PlayerColor.Value)
					end
				end))
				Radar:Clean(runService.RenderStepped:Connect(function()
					for ent, EntityDot in Reference do
						if entitylib.isAlive then
							local dt = CFrame.lookAlong(entitylib.character.RootPart.Position, gameCamera.CFrame.LookVector * Vector3.new(1, 0, 1)):PointToObjectSpace(ent.RootPart.Position)
							EntityDot.Position = UDim2.fromOffset(Clamp["Enabled"] and math.clamp(108 + dt.X, 2, 214) or 108 + dt.X, Clamp["Enabled"] and math.clamp(108 + dt.Z, 8, 214) or 108 + dt.Z)
						end
					end
				end))
			else
				for ent in Reference do 
					Removed(ent) 
				end
			end
		end
	})
	Targets = Radar:CreateTargets({
		Players = true,
		["Function"] = function()
			if Radar.Button["Enabled"] then
				Radar.Button:Toggle()
				Radar.Button:Toggle()
			end
		end
	})
	DotStyle = Radar:CreateDropdown({
		["Name"] = 'Dot Style',
		["List"] = {'Circles', 'Squares'},
		["Function"] = function(val)
			for _, dot in Reference do
				dot.UICorner.CornerRadius = UDim.new(val == 'Circles' and 1 or 0, 0)
			end
		end
	})
	PlayerColor = Radar:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue, sat, val)
			for ent, EntityDot in Reference do
				EntityDot.BackgroundColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(hue, sat, val)
			end
		end
	})
	bkg = Instance.new('Frame')
	bkg.Size = UDim2.fromOffset(216, 216)
	bkg.Position = UDim2.fromOffset(2, 2)
	bkg.BackgroundColor3 = Color3.new()
	bkg.BackgroundTransparency = 0.5
	bkg.ClipsDescendants = true
	bkg.Parent = Radar.Children
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = bkg
	local stroke = Instance.new('UIStroke')
	stroke.Thickness = 2
	stroke.Color = Color3.new()
	stroke.Transparency = 0.4
	stroke.Parent = bkg
	local line1 = Instance.new('Frame')
	line1.Size = UDim2.new(0, 2, 1, 0)
	line1.Position = UDim2.fromScale(0.5, 0.5)
	line1.AnchorPoint = Vector2.new(0.5, 0.5)
	line1.ZIndex = 0
	line1.BackgroundColor3 = Color3.new(1, 1, 1)
	line1.BackgroundTransparency = 0.5
	line1.BorderSizePixel = 0
	line1.Parent = bkg
	local line2 = line1:Clone()
	line2.Size = UDim2.new(1, 0, 0, 2)
	line2.Parent = bkg
	local bar = Instance.new('Frame')
	bar.Size = UDim2.new(1, -6, 0, 4)
	bar.Position = UDim2.fromOffset(3, 0)
	bar.BackgroundColor3 = Color3.fromHSV(0.44, 1, 1)
	bar.Parent = bkg
	local barcorner = Instance.new('UICorner')
	barcorner.CornerRadius = UDim.new(0, 8)
	barcorner.Parent = bar
	Radar:CreateColorSlider({
		["Name"] = 'Bar Color',
		["Function"] = function(hue, sat, val)
			bar.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
		end
	})
	Radar:CreateToggle({
		["Name"] = 'Show Background',
		["Default"] = true,
		["Function"] = function(callback: boolean): void
			bkg.BackgroundTransparency = callback and 0.5 or 1
			bar.BackgroundTransparency = callback and 0 or 1
			stroke.Transparency = callback and 0.4 or 1
		end
	})
	Radar:CreateToggle({
		["Name"] = 'Show Cross',
		["Default"] = true,
		["Function"] = function(callback: boolean): void
			line1.BackgroundTransparency = callback and 0.5 or 1
			line2.BackgroundTransparency = callback and 0.5 or 1
		end
	})
	Clamp = Radar:CreateToggle({
		["Name"] = 'Clamp Radar',
		["Default"] = true
	})
end)
	
velo.run(function()
	local Search: table = {["Enabled"] = false}
	local List
	local Color
	local FillTransparency
	local Reference = {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	
	local function Add(v)
		if not table.find(List.ListEnabled, v.Name) then return end
		if v:IsA('BasePart') or v:IsA('Model') then
			local box = Instance.new('BoxHandleAdornment')
			box.AlwaysOnTop = true
			box.Adornee = v
			box.Size = v:IsA('Model') and v:GetExtentsSize() or v.Size
			box.ZIndex = 0
			box.Transparency = FillTransparency.Value
			box.Color3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			box.Parent = Folder
			Reference[v] = box
		end
	end
	
	Search = vape.Categories.Render:CreateModule({
		["Name"] = 'Search',
		["Function"] = function(callback: boolean): void
			if callback then
				Search:Clean(workspace.DescendantAdded:Connect(Add))
				Search:Clean(workspace.DescendantRemoving:Connect(function(v)
					if Reference[v] then
						Reference[v]:Destroy()
						Reference[v] = nil
					end
				end))
				
				for _, v in workspace:GetDescendants() do
					Add(v)
				end
			else
				Folder:ClearAllChildren()
				table.clear(Reference)
			end
		end,
		Tooltip = 'Draws box around selected parts\nAdd parts in Search frame'
	})
	List = Search:CreateTextList({
		["Name"] = 'Parts',
		["Function"] = function()
			if Search["Enabled"] then
				Search:Toggle()
				Search:Toggle()
			end
		end
	})
	Color = Search:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function(hue, sat, val)
			for _, v in Reference do
				v.Color3 = Color3.fromHSV(hue, sat, val)
			end
		end
	})
	FillTransparency = Search:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Function"] = function(val)
			for _, v in Reference do
				v.Transparency = val
			end
		end,
		["Decimal"] = 10
	})
end)
	
velo.run(function()
	local SessionInfo: table = {["Enabled"] = false}
	local FontOption
	local TextSize
	local BorderColor
	local Title
	local TitleOffset = {}
	local infoholder
	local infolabel
	local infostroke
	
	SessionInfo = vape:CreateOverlay({
		["Name"] = 'Session Info',
		Icon = getcustomasset('newvape/assets/new/textguiicon.png'),
		Size = UDim2.fromOffset(16, 12),
		Position = UDim2.fromOffset(12, 14),
		["Function"] = function(callback: boolean): void
			if callback then
				local teleportedServers
				SessionInfo:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
					if not teleportedServers then
						teleportedServers = true
						queue_on_teleport("shared.vapesessioninfo = '"..httpService:JSONEncode(vape.Libraries.sessioninfo.Objects).."'")
					end
				end))
	
				if shared.vapesessioninfo then
					for i, v in httpService:JSONDecode(shared.vapesessioninfo) do
						if vape.Libraries.sessioninfo.Objects[i] and v.Saved then
							vape.Libraries.sessioninfo.Objects[i].Value = v.Value
						end
					end
				end
	
				repeat
					if vape.Libraries.sessioninfo then
						local stuff = {''}
						if Title["Enabled"] then
							stuff[1] = TitleOffset["Enabled"] and '<b>Session Info</b>\n<font size="4"> </font>' or '<b>Session Info</b>'
						end
						for i, v in vape.Libraries.sessioninfo.Objects do
							stuff[v.Index] = i..': '..v.Function(v.Value)
						end
						if not Title["Enabled"] then
							table.remove(stuff, 1)
						end
						infolabel.Text = table.concat(stuff, '\n')
						infolabel.FontFace = FontOption.Value
						infolabel.TextSize = TextSize.Value
						local size = getfontsize(removeTags(infolabel.Text), infolabel.TextSize, infolabel.FontFace)
						infoholder.Size = UDim2.fromOffset(size.X + 16, size.Y + (Title["Enabled"] and TitleOffset["Enabled"] and 4 or 16))
					end
					task.wait(1)
				until not SessionInfo.Button or not SessionInfo.Button["Enabled"]
			end
		end
	})
	FontOption = SessionInfo:CreateFont({
		["Name"] = 'Font',
		Blacklist = 'Arial'
	})
	SessionInfo:CreateColorSlider({
		["Name"] = 'Background Color',
		DefaultValue = 0,
		DefaultOpacity = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			infoholder.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			infoholder.BackgroundTransparency = 1 - opacity
		end
	})
	BorderColor = SessionInfo:CreateColorSlider({
		["Name"] = 'Border Color',
		["Function"] = function(hue, sat, val, opacity)
			infostroke.Color = Color3.fromHSV(hue, sat, val)
			infostroke.Transparency = 1 - opacity
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	TextSize = SessionInfo:CreateSlider({
		["Name"] = 'Text Size',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 16
	})
	Title = SessionInfo:CreateToggle({
		["Name"] = 'Title',
		["Function"] = function(callback: boolean): void
			if TitleOffset.Object then
				TitleOffset.Object.Visible = callback
			end
		end,
		["Default"] = true
	})
	TitleOffset = SessionInfo:CreateToggle({
		["Name"] = 'Offset',
		["Default"] = true,
		["Darker"] = true
	})
	SessionInfo:CreateToggle({
		["Name"] = 'Border',
		["Function"] = function(callback: boolean): void
			infostroke["Enabled"] = callback
			BorderColor.Object.Visible = callback
		end
	})
	infoholder = Instance.new('Frame')
	infoholder.BackgroundColor3 = Color3.new()
	infoholder.BackgroundTransparency = 0.5
	infoholder.Parent = SessionInfo.Children
	vape:Clean(SessionInfo.Children:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
		if vape.ThreadFix then 
			setthreadidentity(8) 
		end
		local newside = SessionInfo.Children.AbsolutePosition.X > (vape.gui.AbsoluteSize.X / 2)
		infoholder.Position = UDim2.fromScale(newside and 1 or 0, 0)
		infoholder.AnchorPoint = Vector2.new(newside and 1 or 0, 0)
	end))
	local sessioninfocorner = Instance.new('UICorner')
	sessioninfocorner.CornerRadius = UDim.new(0, 5)
	sessioninfocorner.Parent = infoholder
	infolabel = Instance.new('TextLabel')
	infolabel.Size = UDim2.new(1, -16, 1, -16)
	infolabel.Position = UDim2.fromOffset(8, 8)
	infolabel.BackgroundTransparency = 1
	infolabel.TextXAlignment = Enum.TextXAlignment.Left
	infolabel.TextYAlignment = Enum.TextYAlignment.Top
	infolabel.TextSize = 16
	infolabel.TextColor3 = Color3.new(1, 1, 1)
	infolabel.TextStrokeColor3 = Color3.new()
	infolabel.TextStrokeTransparency = 0.8
	infolabel.Font = Enum.Font.Arial
	infolabel.RichText = true
	infolabel.Parent = infoholder
	infostroke = Instance.new('UIStroke')
	infostroke["Enabled"] = false
	infostroke.Color = Color3.fromHSV(0.44, 1, 1)
	infostroke.Parent = infoholder
	addBlur(infoholder)
	vape.Libraries.sessioninfo = {
		Objects = {},
		AddItem = function(self, name, startvalue, func, saved)
			func, saved = func or function(val) return val end, saved == nil or saved
			self.Objects[name] = {Function = func, Saved = saved, Value = startvalue or 0, Index = getTableSize(self.Objects) + 2}
			return {
				Increment = function(_, val)
					self.Objects[name].Value += (val or 1)
				end
			}
		end
	}
	vape.Libraries.sessioninfo:AddItem('Time Played', os.clock(), function(value) 
		return os.date('!%X', math.floor(os.clock() - value)) 
	end)
end)
	
velo.run(function()
	local Tracers: table = {["Enabled"] = false}
	local Targets
	local Color
	local Transparency
	local StartPosition
	local EndPosition
	local Teammates
	local DistanceColor
	local Distance
	local DistanceLimit
	local Behind
	local Reference = {}
	
	local function Added(ent)
		if not Targets.Players["Enabled"] and ent.Player then return end
		if not Targets.NPCs["Enabled"] and ent.NPC then return end
		if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return end
		if vape.ThreadFix then
			setthreadidentity(8)
		end
	
		local EntityTracer = Drawing.new('Line')
		EntityTracer.Thickness = 1
		EntityTracer.Transparency = 1 - Transparency.Value
		EntityTracer.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
		Reference[ent] = EntityTracer
	end
	
	local function Removed(ent)
		local v = Reference[ent]
		if v then
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			Reference[ent] = nil
			pcall(function()
				v.Visible = false
				v:Remove()
			end)
		end
	end
	
	local function ColorFunc(hue, sat, val)
		if DistanceColor["Enabled"] then return end
		local tracerColor = Color3.fromHSV(hue, sat, val)
		for ent, EntityTracer in Reference do
			EntityTracer.Color = entitylib.getEntityColor(ent) or tracerColor
		end
	end
	
	local function Loop()
		local screenSize = vape.gui.AbsoluteSize
		local startVector = StartPosition.Value == 'Mouse' and inputService:GetMouseLocation() or Vector2.new(screenSize.X / 2, (StartPosition.Value == 'Middle' and screenSize.Y / 2 or screenSize.Y))
	
		for ent, EntityTracer in Reference do
			local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude
			if Distance["Enabled"] and distance then
				if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
					EntityTracer.Visible = false
					continue
				end
			end
			
			local pos = ent[EndPosition.Value == 'Torso' and 'RootPart' or 'Head'].Position
			local rootPos, rootVis = gameCamera:WorldToViewportPoint(pos)
			if not rootVis and Behind["Enabled"] then
				local tempPos = gameCamera.CFrame:PointToObjectSpace(pos)
				tempPos = CFrame.Angles(0, 0, (math.atan2(tempPos.Y, tempPos.X) + math.pi)):VectorToWorldSpace((CFrame.Angles(0, math.rad(89.9), 0):VectorToWorldSpace(Vector3.new(0, 0, -1))))
				rootPos = gameCamera:WorldToViewportPoint(gameCamera.CFrame:pointToWorldSpace(tempPos))
				rootVis = true
			end
			
			local endVector = Vector2.new(rootPos.X, rootPos.Y)
			EntityTracer.Visible = rootVis
			EntityTracer.From = startVector
			EntityTracer.To = endVector
			if DistanceColor["Enabled"] and distance then
				EntityTracer.Color = Color3.fromHSV(math.min((distance / 128) / 2.8, 0.4), 0.89, 0.75)
			end
		end
	end
	
	Tracers = vape.Categories.Render:CreateModule({
		["Name"] = 'Tracers',
		["Function"] = function(callback: boolean): void
			if callback then
				Tracers:Clean(entitylib.Events.EntityRemoved:Connect(Removed))
				for _, v in entitylib.List do
					if Reference[v] then
						Removed(v)
					end
					Added(v)
				end
				Tracers:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
					if Reference[ent] then
						Removed(ent)
					end
					Added(ent)
				end))
				Tracers:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
					ColorFunc(Color.Hue, Color.Sat, Color.Value)
				end))
				Tracers:Clean(runService.RenderStepped:Connect(Loop))
			else
				for i in Reference do
					Removed(i)
				end
			end
		end,
		Tooltip = 'Renders tracers on players.'
	})
	Targets = Tracers:CreateTargets({
		Players = true,
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle()
				Tracers:Toggle()
			end
		end
	})
	StartPosition = Tracers:CreateDropdown({
		["Name"] = 'Start Position',
		["List"] = {'Middle', 'Bottom', 'Mouse'},
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle()
				Tracers:Toggle()
			end
		end
	})
	EndPosition = Tracers:CreateDropdown({
		["Name"] = 'End Position',
		["List"] = {'Head', 'Torso'},
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle()
				Tracers:Toggle()
			end
		end
	})
	Color = Tracers:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue, sat, val)
			if Tracers["Enabled"] and ColorFuncs then
				ColorFuncs(hue, sat, val)
			end
		end
	})
	Transparency = Tracers:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Function"] = function(val)
			for _, tracer in Reference do
				tracer.Transparency = 1 - val
			end
		end,
		["Decimal"] = 10
	})
	DistanceColor = Tracers:CreateToggle({
		["Name"] = 'Color by distance',
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle()
				Tracers:Toggle()
			end
		end
	})
	Distance = Tracers:CreateToggle({
		["Name"] = 'Distance Check',
		["Function"] = function(callback: boolean): void
			DistanceLimit.Object.Visible = callback
		end
	})
	DistanceLimit = Tracers:CreateTwoSlider({
		["Name"] = 'Player Distance',
		["Min"] = 0,
		["Max"] = 256,
		["DefaultMin"] = 0,
		["DefaultMax"] = 64,
		["Darker"] = true,
		["Visible"] = false
	})
	Behind = Tracers:CreateToggle({
		["Name"] = 'Behind',
		["Default"] = true
	})
	Teammates = Tracers:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function()
			if Tracers["Enabled"] then
				Tracers:Toggle()
				Tracers:Toggle()
			end
		end,
		["Default"] = true,
		["Tooltip"] = 'Hides teammates & non targetable entities'
	})
end)
	
velo.run(function()
	local Waypoints: table = {["Enabled"] = false}
	local FontOption
	local List
	local Color
	local Scale
	local Background
	WaypointFolder = Instance.new('Folder')
	WaypointFolder.Parent = vape.gui
	
	Waypoints = vape.Categories.Render:CreateModule({
		["Name"] = 'Waypoints',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v in List.ListEnabled do
					local split = v:split('/')
					local tagSize = getfontsize(removeTags(split[2]), 14 * Scale.Value, FontOption.Value, Vector2.new(100000, 100000))
					local billboard = Instance.new('BillboardGui')
					billboard.Size = UDim2.fromOffset(tagSize.X + 8, tagSize.Y + 7)
					billboard.StudsOffsetWorldSpace = Vector3.new(unpack(split[1]:split(',')))
					billboard.AlwaysOnTop = true
					billboard.Parent = WaypointFolder
					local tag = Instance.new('TextLabel')
					tag.BackgroundColor3 = Color3.new()
					tag.BorderSizePixel = 0
					tag.Visible = true
					tag.RichText = true
					tag.FontFace = FontOption.Value
					tag.TextSize = 14 * Scale.Value
					tag.BackgroundTransparency = Background.Value
					tag.Size = billboard.Size
					tag.Text = split[2]
					tag.TextColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
					tag.Parent = billboard
				end
			else
				WaypointFolder:ClearAllChildren()
			end
		end,
		Tooltip = 'Mark certain spots with a visual indicator'
	})
	FontOption = Waypoints:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Arial',
		["Function"] = function()
			if Waypoints["Enabled"] then
				Waypoints:Toggle()
				Waypoints:Toggle()
			end
		end,
	})
	List = Waypoints:CreateTextList({
		["Name"] = 'Points',
		["Placeholder"] = 'x, y, z/name',
		["Function"] = function()
			if Waypoints["Enabled"] then
				Waypoints:Toggle()
				Waypoints:Toggle()
			end
		end
	})
	Waypoints:CreateButton({
		["Name"] = 'Add current position',
		["Function"] = function()
			if entitylib.isAlive then
				local pos = entitylib.character.RootPart.Position // 1
				List:ChangeValue(pos.X..','..pos.Y..','..pos.Z..'/Waypoint '..(#List.List + 1))
			end
		end
	})
	Color = Waypoints:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function(hue, sat, val)
			for _, v in WaypointFolder:GetChildren() do
				v.TextLabel.TextColor3 = Color3.fromHSV(hue, sat, val)
			end
		end
	})
	Scale = Waypoints:CreateSlider({
		["Name"] = 'Scale',
		["Function"] = function()
			if Waypoints["Enabled"] then
				Waypoints:Toggle()
				Waypoints:Toggle()
			end
		end,
		["Default"] = 1,
		["Min"] = 0.1,
		["Max"] = 1.5,
		["Decimal"] = 10
	})
	Background = Waypoints:CreateSlider({
		["Name"] = 'Transparency',
		["Function"] = function()
			if Waypoints["Enabled"] then
				Waypoints:Toggle()
				Waypoints:Toggle()
			end
		end,
		["Default"] = 0.5,
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 10
	})
	
end)
	
velo.run(function()
	local AnimationPlayer: table = {["Enabled"] = false}
	local IDBox
	local Priority
	local Speed
	local anim, animobject
	
	local function playAnimation(char)
		local animcheck = anim
		if animcheck then
			anim = nil
			animcheck:Stop()
		end
	
		local suc, res = pcall(function()
			anim = char.Humanoid.Animator:LoadAnimation(animobject)
		end)
	
		if suc then
			local currentanim = anim
			anim.Priority = Enum.AnimationPriority[Priority.Value]
			anim:Play()
			anim:AdjustSpeed(Speed.Value)
			AnimationPlayer:Clean(anim.Stopped:Connect(function()
				if currentanim == anim then
					anim:Play()
				end
			end))
		else
			notif('AnimationPlayer', 'failed to load anim : '..(res or 'invalid animation id'), 5, 'warning')
		end
	end
	
	AnimationPlayer = vape.Categories.Utility:CreateModule({
		["Name"] = 'AnimationPlayer',
		["Function"] = function(callback: boolean): void
			if callback then
				animobject = Instance.new('Animation')
				local suc, id = pcall(function()
					return string.match(game:GetObjects('rbxassetid://'..IDBox.Value)[1].AnimationId, '%?id=(%d+)')
				end)
				animobject.AnimationId = 'rbxassetid://'..(suc and id or IDBox.Value)
				
				if entitylib.isAlive then 
					playAnimation(entitylib.character) 
				end
				AnimationPlayer:Clean(entitylib.Events.LocalAdded:Connect(playAnimation))
				AnimationPlayer:Clean(animobject)
			else
				if anim then
					anim:Stop()
				end
			end
		end,
		Tooltip = 'Plays a specific animation of your choosing at a certain speed'
	})
	IDBox = AnimationPlayer:CreateTextBox({
		["Name"] = 'Animation',
		Placeholder = 'anim (num only)',
		["Function"] = function(enter)
			if enter and AnimationPlayer["Enabled"] then
				AnimationPlayer:Toggle()
				AnimationPlayer:Toggle()
			end
		end
	})
	local prio = {'Action4'}
	for _, v in Enum.AnimationPriority:GetEnumItems() do
		if v.Name ~= 'Action4' then
			table.insert(prio, v.Name)
		end
	end
	Priority = AnimationPlayer:CreateDropdown({
		["Name"] = 'Priority',
		["List"] = prio,
		["Function"] = function(val)
			if anim then
				anim.Priority = Enum.AnimationPriority[val]
			end
		end
	})
	Speed = AnimationPlayer:CreateSlider({
		["Name"] = 'Speed',
		["Function"] = function(val)
			if anim then
				anim:AdjustSpeed(val)
			end
		end,
		["Min"] = 0.1,
		["Max"] = 2,
		["Decimal"] = 10
	})
end)
	
velo.run(function()
	local AntiRagdoll: table = {["Enabled"] = false}
	
	AntiRagdoll = vape.Categories.Utility:CreateModule({
		["Name"] = 'AntiRagdoll',
		["Function"] = function(callback: boolean): void
			if entitylib.isAlive then
				entitylib.character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not callback)
			end
			if callback then
				AntiRagdoll:Clean(entitylib.Events.LocalAdded:Connect(function(char)
					char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				end))
			end
		end,
		Tooltip = 'Prevents you from getting knocked down in a ragdoll state'
	})
end)
	
velo.run(function()
	local AutoRejoin: table = {["Enabled"] = false}
	local Sort
	
	AutoRejoin = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoRejoin',
		["Function"] = function(callback: boolean): void
			if callback then
				local check
				AutoRejoin:Clean(guiService.ErrorMessageChanged:Connect(function(str)
					if (not check or guiService:GetErrorCode() ~= Enum.ConnectionError.DisconnectLuaKick) and guiService:GetErrorCode() ~= Enum.ConnectionError.DisconnectConnectionLost and not str:lower():find('ban') then
						check = true
						serverHop(nil, Sort.Value)
					end
				end))
			end
		end,
		Tooltip = 'Automatically rejoins into a new server if you get disconnected / kicked'
	})
	Sort = AutoRejoin:CreateDropdown({
		["Name"] = 'Sort',
		["List"] = {'Descending', 'Ascending'},
		Tooltip = 'Descending - Prefers full servers\nAscending - Prefers empty servers'
	})
end)
	
velo.run(function()
	local Blink: table = {["Enabled"] = false}
	local Type
	local AutoSend
	local AutoSendLength
	local oldphys, oldsend
	
	Blink = vape.Categories.Utility:CreateModule({
		["Name"] = 'Blink',
		["Function"] = function(callback: boolean): void
			if callback then
				local teleported
				Blink:Clean(lplr.OnTeleport:Connect(function()
					setfflag('S2PhysicsSenderRate', '15')
					setfflag('DataSenderRate', '60')
					teleported = true
				end))
	
				repeat
					local physicsrate, senderrate = '0', Type.Value == 'All' and '-1' or '60'
					if AutoSend["Enabled"] and tick() % (AutoSendLength.Value + 0.1) > AutoSendLength.Value then
						physicsrate, senderrate = '15', '60'
					end
	
					if physicsrate ~= oldphys or senderrate ~= oldsend then
						setfflag('S2PhysicsSenderRate', physicsrate)
						setfflag('DataSenderRate', senderrate)
						oldphys, oldsend = physicsrate, oldsend
					end
					
					task.wait(0.03)
				until (not Blink["Enabled"] and not teleported)
			else
				if setfflag then
					setfflag('S2PhysicsSenderRate', '15')
					setfflag('DataSenderRate', '60')
				end
				oldphys, oldsend = nil, nil
			end
		end,
		Tooltip = 'Chokes packets until disabled.'
	})
	Type = Blink:CreateDropdown({
		["Name"] = 'Type',
		["List"] = {'Movement Only', 'All'},
		Tooltip = 'Movement Only - Only chokes movement packets\nAll - Chokes remotes & movement'
	})
	AutoSend = Blink:CreateToggle({
		["Name"] = 'Auto send',
		["Function"] = function(callback: boolean): void
			AutoSendLength.Object.Visible = callback
		end,
		Tooltip = 'Automatically send packets in intervals'
	})
	AutoSendLength = Blink:CreateSlider({
		["Name"] = 'Send threshold',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Darker"] = true,
		["Visible"] = false,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
end)
	
velo.run(function()
	local ChatSpammer: table = {["Enabled"] = false}
	local Lines
	local Mode
	local Delay
	local Hide
	local oldchat
	
	ChatSpammer = vape.Categories.Utility:CreateModule({
		["Name"] = 'ChatSpammer',
		["Function"] = function(callback: boolean): void
			if callback then
				if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
					if Hide["Enabled"] and coreGui:FindFirstChild('ExperienceChat') then
						ChatSpammer:Clean(coreGui.ExperienceChat:FindFirstChild('RCTScrollContentView', true).ChildAdded:Connect(function(msg)
							if msg.Name:sub(1, 2) == '0-' and msg.ContentText == 'You must wait before sending another message.' then
								msg.Visible = false
							end
						end))
					end
				elseif replicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
					if Hide["Enabled"] then
						oldchat = hookfunction(getconnections(replicatedStorage.DefaultChatSystemChatEvents.OnNewSystemMessage.OnClientEvent)[1].Function, function(data, ...)
							if data.Message:find('ChatFloodDetector') then return end
							return oldchat(data, ...)
						end)
					end
				else
					notif('ChatSpammer', 'unsupported chat', 5, 'warning')
					ChatSpammer:Toggle()
					return
				end
				
				local ind = 1
				repeat
					local message = (#Lines.ListEnabled > 0 and Lines.ListEnabled[math.random(1, #Lines.ListEnabled)] or 'vxpe on top')
					if Mode.Value == 'Order' and #Lines.ListEnabled > 0 then
						message = Lines.ListEnabled[ind] or Lines.ListEnabled[1]
						ind = (ind % #Lines.ListEnabled) + 1
					end
	
					if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(message)
					else
						replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, 'All')
					end
	
					task.wait(Delay.Value)
				until not ChatSpammer["Enabled"]
			else
				if oldchat then
					hookfunction(getconnections(replicatedStorage.DefaultChatSystemChatEvents.OnNewSystemMessage.OnClientEvent)[1].Function, oldchat)
				end
			end
		end,
		Tooltip = 'Automatically types in chat'
	})
	Lines = ChatSpammer:CreateTextList({["Name"] = 'Lines'})
	Mode = ChatSpammer:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Random', 'Order'}
	})
	Delay = ChatSpammer:CreateSlider({
		["Name"] = 'Delay',
		["Min"] = 0.1,
		["Max"] = 10,
		["Default"] = 1,
		["Decimal"] = 10,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	Hide = ChatSpammer:CreateToggle({
		["Name"] = 'Hide Flood Message',
		["Default"] = true,
		["Function"] = function()
			if ChatSpammer["Enabled"] then
				ChatSpammer:Toggle()
				ChatSpammer:Toggle()
			end
		end
	})
end)
	
velo.run(function()
	local Disabler: table = {["Enabled"] = false}
	
	local function characterAdded(char)
		print('yes')
		for _, v in getconnections(char.RootPart:GetPropertyChangedSignal('CFrame')) do
			hookfunction(v.Function, function() end)
		end
		for _, v in getconnections(char.RootPart:GetPropertyChangedSignal('Velocity')) do
			hookfunction(v.Function, function() end)
		end
	end
	
	Disabler = vape.Categories.Utility:CreateModule({
		["Name"] = 'Disabler',
		["Function"] = function(callback: boolean): void
			if callback then
				Disabler:Clean(entitylib.Events.LocalAdded:Connect(characterAdded))
				if entitylib.isAlive then
					characterAdded(entitylib.character)
				end
			end
		end,
		Tooltip = 'Disables GetPropertyChangedSignal detections for movement'
	})
end)
	
velo.run(function()
	vape.Categories.Utility:CreateModule({
		["Name"] = 'Panic',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v in vape.Modules do
					if v["Enabled"] then
						v:Toggle()
					end
				end
			end
		end,
		Tooltip = 'Disables all currently enabled modules'
	})
end)
	
velo.run(function()
	local Rejoin: table = {["Enabled"] = false}
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
		Tooltip = 'Rejoins the server'
	})
end)
	
velo.run(function()
	local ServerHop: table = {["Enabled"] = false}
	local Sort: any;
	ServerHop = vape.Categories.Utility:CreateModule({
		["Name"] = 'ServerHop',
		["Function"] = function(callback: boolean): void
			if callback then
				ServerHop:Toggle()
				serverHop(nil, Sort.Value)
			end;
		end,
		["Tooltip"] = 'Teleports into a unique server'
	})
	Sort = ServerHop:CreateDropdown({
		["Name"] = 'Sort',
		["List"] = {'Full', 'Small'},
		["Tooltip"] = 'Descending - Prefers full servers\nAscending - Prefers empty servers'
	})
	ServerHop:CreateButton({
		["Name"] = 'Rejoin Previous Server',
		["Function"] = function()
			notif('ServerHop', shared.vapeserverhopprevious and 'Rejoining previous server...' or 'Cannot find previous server', 5)
			if shared.vapeserverhopprevious then
				teleportService:TeleportToPlaceInstance(game.PlaceId, shared.vapeserverhopprevious)
			end
		end
	})
end)
	
velo.run(function()
	local StaffDetector: table = {["Enabled"] = false}
	local Mode: table = {}
	local Profile: table = {}
	local Users: table = {}
	local Group: table = {}
	local Role: table = {}
	
	local function getRole(plr, id)
		local suc, res
		for _ = 1, 3 do
			suc, res = pcall(function()
				return plr:GetRankInGroup(id)
			end)
			if suc then break end
		end
		return suc and res or 0
	end
	
	local function getLowestStaffRole(roles)
		local highest = math.huge
		for _, v in roles do
			local low = v.Name:lower()
			if (low:find('admin') or low:find('mod') or low:find('dev')) and v.Rank < highest then
				highest = v.Rank
			end
		end
		return highest
	end
	
	local function playerAdded(plr)
		if not vape.Loaded then 
			repeat task.wait() until vape.Loaded 
		end
	
		local user = table.find(Users.ListEnabled, tostring(plr.UserId))
		if user or getRole(plr, tonumber(Group["Value"]) or 0) >= (tonumber(Role["Value"]) or 1) then
			notif('StaffDetector', 'Staff Detected ('..(user and 'blacklisted_user' or 'staff_role')..'): '..plr.Name, 60, 'alert')
			whitelist.customtags[plr.Name] = {{text = 'GAME STAFF', color = Color3.new(1, 0, 0)}}
			
			if Mode["Value"] == 'Uninject' then
				task.spawn(function() 
					vape:Uninject() 
				end)
				game:GetService('StarterGui'):SetCore('SendNotification', {
					Title = 'StaffDetector',
					Text = 'Staff Detected\n'..plr.Name,
					Duration = 60,
				})
			elseif Mode["Value"] == 'ServerHop' then
				serverHop()
			elseif Mode["Value"] == 'Profile' then
				vape.Save = function() end
				if vape.Profile ~= Profile["Value"] then
					vape.Profile = Profile["Value"]
					vape:Load(true, Profile["Value"])
				end
			elseif Mode["Value"] == 'AutoConfig' then
				vape.Save = function() end
				for _, v in vape.Modules do
					if v["Enabled"] then
						v:Toggle()
					end
				end
			end
		end
	end
	
	StaffDetector = vape.Categories.Utility:CreateModule({
		["Name"] = 'StaffDetector',
		["Function"] = function(callback: boolean): void
			if callback then
				if Group["Value"] == '' or Role["Value"] == '' then
					local placeinfo = {Creator = {CreatorTargetId = tonumber(Group["Value"])}}
					if Group["Value"] == '' then
						placeinfo = marketplaceService:GetProductInfo(game.PlaceId)
						if placeinfo.Creator.CreatorType ~= 'Group' then
							local desc = placeinfo.Description:split('\n')
							for _, str in desc do
								local _, begin = str:find('roblox.com/groups/')
								if begin then
									local endof = str:find('/', begin + 1)
									placeinfo = {Creator = {
										CreatorType = 'Group', 
										CreatorTargetId = str:sub(begin + 1, endof - 1)
									}}
								end
							end
						end
	
						if placeinfo.Creator.CreatorType ~= 'Group' then
							notif('StaffDetector', 'Automatic Setup Failed (no group detected)', 60, 'warning')
							return
						end
					end
	
					local groupinfo = groupService:GetGroupInfoAsync(placeinfo.Creator.CreatorTargetId)
					Group:SetValue(placeinfo.Creator.CreatorTargetId)
					Role:SetValue(getLowestStaffRole(groupinfo.Roles))
				end
				
				if Group["Value"] == '' or Role["Value"] == '' then 
					return 
				end
				
				StaffDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
				for _, v in playersService:GetPlayers() do
					task.spawn(playerAdded, v)
				end
			end
		end,
		["Tooltip"] = 'Detects people with a staff rank ingame'
	})
	Mode = StaffDetector:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Uninject', 'ServerHop', 'Profile', 'AutoConfig', 'Notify'},
		["Function"] = function(val)
			if Profile.Object then
				Profile.Object.Visible = val == 'Profile'
			end
		end
	})
	Profile = StaffDetector:CreateTextBox({
		["Name"] = 'Profile',
		["Default"] = 'default',
		["Darker"] = true,
		["Visible"] = false
	})
	Users = StaffDetector:CreateTextList({
		["Name"] = 'Users',
		["Placeholder"] = 'player (userid)'
	})
	Group = StaffDetector:CreateTextBox({
		["Name"] = 'Group',
		["Placeholder"] = 'Group Id'
	})
	Role = StaffDetector:CreateTextBox({
		["Name"] = 'Role',
		["Placeholder"] = 'Role Rank'
	})
end)

velo.run(function()
	local connections: table? = {}
	vape.Categories.World:CreateModule({
		["Name"] = 'Anti-AFK',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v in getconnections(lplr.Idled) do
					table.insert(connections, v)
					v:Disable()
				end
			else
				for _, v in connections do
					v:Enable()
				end
				table.clear(connections)
			end
		end,
		["Tooltip"] = 'Lets you stay ingame without getting kicked'
	})
end)
	
velo.run(function()
	local Freecam: table = {["Enabled"] = false}
	local Value: table = {}
	local randomkey: any, module: any, old: any = httpService:GenerateGUID(false)
	
	Freecam = vape.Categories.World:CreateModule({
		["Name"] = 'Freecam',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					task.wait(0.1)
					for _, v in getconnections(gameCamera:GetPropertyChangedSignal('CameraType')) do
						if v.Function then
							module = debug.getupvalue(v.Function, 1)
						end
					end
				until module or not Freecam["Enabled"]
	
				if module and module.activeCameraController and Freecam["Enabled"] then
					old = module.activeCameraController.GetSubjectPosition
					local camPos = old(module.activeCameraController) or Vector3.zero
					module.activeCameraController.GetSubjectPosition = function()
						return camPos
					end
	
					Freecam:Clean(runService.PreSimulation:Connect(function(dt)
						if not inputService:GetFocusedTextBox() then
							local forward = (inputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0) + (inputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
							local side = (inputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0) + (inputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0)
							local up = (inputService:IsKeyDown(Enum.KeyCode.Q) and -1 or 0) + (inputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0)
							dt = dt * (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and 0.25 or 1)
							camPos = (CFrame.lookAlong(camPos, gameCamera.CFrame.LookVector) * CFrame.new(Vector3.new(side, up, forward) * (Value.Value * dt))).Position
						end
					end))
	
					contextService:BindActionAtPriority('FreecamKeyboard'..randomkey, function() 
						return Enum.ContextActionResult.Sink 
					end, false, Enum.ContextActionPriority.High.Value,
						Enum.KeyCode.W,
						Enum.KeyCode.A,
						Enum.KeyCode.S,
						Enum.KeyCode.D,
						Enum.KeyCode.E,
						Enum.KeyCode.Q,
						Enum.KeyCode.Up,
						Enum.KeyCode.Down
					)
				end
			else
				pcall(function()
					contextService:UnbindAction('FreecamKeyboard'..randomkey)
				end)
				if module and old then
					module.activeCameraController.GetSubjectPosition = old
					module = nil
					old = nil
				end
			end
		end,
		["Tooltip"] = 'Lets you fly and clip through walls freely\nwithout moving your player server-sided.'
	})
	Value = Freecam:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 150,
		["Default"] = 50,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)
	
velo.run(function()
	local Gravity: table = {["Enabled"] = false}
	local Mode: table = {}
	local Value: table = {}
	local changed: any, old: any = false
	Gravity = vape.Categories.World:CreateModule({
		["Name"] = 'Gravity',
		["Function"] = function(callback: boolean): void
			if callback then
				if Mode.Value == 'Workspace' then
					old = workspace.Gravity
					workspace.Gravity = Value.Value
					Gravity:Clean(workspace:GetPropertyChangedSignal('Gravity'):Connect(function()
						if changed then return end
						changed = true
						old = workspace.Gravity
						workspace.Gravity = Value.Value
						changed = false
					end))
				else
					Gravity:Clean(runService.PreSimulation:Connect(function(dt)
						if entitylib.isAlive and entitylib.character.Humanoid.FloorMaterial == Enum.Material.Air then
							entitylib.character.RootPart.AssemblyLinearVelocity += Vector3.new(0, dt * (workspace.Gravity - Value.Value), 0)
						end
					end))
				end
			else
				if old then
					workspace.Gravity = old
					old = nil
				end
			end
		end,
		["Tooltip"] = 'Changes the rate you fall'
	})
	Mode = Gravity:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Workspace', 'Velocity'},
		["Tooltip"] = 'Workspace - Adjusts the gravity for the entire game\nVelocity - Adjusts the local players gravity'
	})
	Value = Gravity:CreateSlider({
		["Name"] = 'Gravity',
		["Min"] = 0,
		["Max"] = 192,
		["Function"] = function(val)
			if Gravity["Enabled"] and Mode.Value == 'Workspace' then
				changed = true
				workspace.Gravity = val
				changed = false
			end
		end,
		["Default"] = 192
	})
end)
	
velo.run(function()
	local Parkour: table = {["Enabled"] = false}
	Parkour = vape.Categories.World:CreateModule({
		["Name"] = 'Parkour',
		["Function"] = function(callback: boolean): void
			if callback then 
				local oldfloor
				Parkour:Clean(runService.RenderStepped:Connect(function()
					if entitylib.isAlive then 
						local material = entitylib.character.Humanoid.FloorMaterial
						if material == Enum.Material.Air and oldfloor ~= Enum.Material.Air then 
							entitylib.character.Humanoid.Jump = true
						end
						oldfloor = material
					end
				end))
			end
		end,
		["Tooltip"] = 'Automatically jumps after reaching the edge'
	})
end)
	
velo.run(function()
	local rayCheck: RayCastParams? = RaycastParams.new();
	rayCheck.RespectCanCollide = true
	local module, old
	vape.Categories.World:CreateModule({
		["Name"] = 'SafeWalk',
		["Function"] = function(callback: boolean): void
			if callback then
				if not module then
					local suc = pcall(function() 
						module = require(lplr.PlayerScripts.PlayerModule).controls 
					end)
					if not suc then module = {} end
				end
				
				old = module.moveFunction
				module.moveFunction = function(self, vec, face)
					if entitylib.isAlive then
						rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
						local root = entitylib.character.RootPart
						local movedir = root.Position + vec
						local ray = workspace:Raycast(movedir, Vector3.new(0, -15, 0), rayCheck)
						if not ray then
							local check = workspace:Blockcast(root.CFrame, Vector3.new(3, 1, 3), Vector3.new(0, -(entitylib.character.HipHeight + 1), 0), rayCheck)
							if check then
								vec = (check.Instance:GetClosestPointOnSurface(movedir) - root.Position) * Vector3.new(1, 0, 1)
							end
						end
					end
	
					return old(self, vec, face)
				end
			else
				if module and old then
					module.moveFunction = old
				end
			end
		end,
		["Tooltip"] = 'Prevents you from walking off the edge of parts'
	})
end)
	
velo.run(function()
	local Xray: table = {["Enabled"] = false}
	local List: table = {}
	local modified: table = {}
	
	local function modifyPart(v)
		if v:IsA('BasePart') and not table.find(List.ListEnabled, v.Name) then
			modified[v] = true
			v.LocalTransparencyModifier = 0.5
		end
	end
	
	Xray = vape.Categories.World:CreateModule({
		["Name"] = 'Xray',
		["Function"] = function(callback: boolean): void
			if callback then
				Xray:Clean(workspace.DescendantAdded:Connect(modifyPart))
				for _, v in workspace:GetDescendants() do
					modifyPart(v)
				end
			else
				for i in modified do
					i.LocalTransparencyModifier = 0
				end
				table.clear(modified)
			end
		end,
		["Tooltip"] = 'Renders whitelisted parts through walls.'
	})
	List = Xray:CreateTextList({
		["Name"] = 'Part',
		["Function"] = function()
			if Xray["Enabled"] then
				Xray:Toggle()
				Xray:Toggle()
			end
		end
	})
end)
	
velo.run(function()
	local MurderMystery: table = {["Enabled"] = false}
	local murderer: any, sheriff: any, oldtargetable: any, oldgetcolor: any
	
	local function itemAdded(v, plr)
		if v:IsA('Tool') then
			local check = v:FindFirstChild('IsGun') and 'sheriff' or v:FindFirstChild('KnifeServer') and 'murderer' or nil
			check = check or v.Name:lower():find('knife') and 'murderer' or v.Name:lower():find('gun') and 'sheriff' or nil
			if check == 'murderer' and plr ~= murderer then
				murderer = plr
				if plr.Character then
					entitylib.refresh()
				end
			elseif check == 'sheriff' and plr ~= sheriff then
				sheriff = plr
				if plr.Character then
					entitylib.refresh()
				end
			end
		end
	end
	
	local function playerAdded(plr)
		MurderMystery:Clean(plr.DescendantAdded:Connect(function(v)
			itemAdded(v, plr)
		end))
		local pack = plr:FindFirstChildWhichIsA('Backpack')
		if pack then
			for _, v in pack:GetChildren() do
				itemAdded(v, plr)
			end
		end
		if plr.Character then
			for _, v in plr.Character:GetChildren() do
				itemAdded(v, plr)
			end
		end
	end
	
	MurderMystery = vape.Categories.Minigames:CreateModule({
		["Name"] = 'MurderMystery',
		["Function"] = function(callback: boolean): void
			if callback then
				oldtargetable, oldgetcolor = entitylib.targetCheck, entitylib.getEntityColor
				entitylib.getEntityColor = function(ent)
					ent = ent.Player
					if not (ent and vape.Categories.Main.Options['Use team color']["Enabled"]) then return end
					if isFriend(ent, true) then
						return Color3.fromHSV(vape.Categories.Friends.Options['Friends color'].Hue, vape.Categories.Friends.Options['Friends color'].Sat, vape.Categories.Friends.Options['Friends color'].Value)
					end
					return murderer == ent and Color3.new(1, 0.3, 0.3) or sheriff == ent and Color3.new(0, 0.5, 1) or nil
				end
				entitylib.targetCheck = function(ent)
					if ent.Player and isFriend(ent.Player) then return false end
					if murderer == lplr then return true end
					return murderer == ent.Player or sheriff == ent.Player
				end
				for _, v in playersService:GetPlayers() do
					playerAdded(v)
				end
				MurderMystery:Clean(playersService.PlayerAdded:Connect(playerAdded))
				entitylib.refresh()
			else
				entitylib.getEntityColor = oldgetcolor
				entitylib.targetCheck = oldtargetable
				entitylib.refresh()
			end
		end,
		["Tooltip"] = 'Automatic murder mystery teaming based on equipped roblox tools.'
	})
end)

velo.run(function()
	local Atmosphere: table = {["Enabled"] = false};
	local Toggles: table = {}
	local themeName: any;
	local newobjects: table, oldobjects: table = {}, {}
    local function BeforeShaders()
        return {
            Brightness = lightingService.Brightness,
            ColorShift_Bottom = lightingService.ColorShift_Bottom,
            ColorShift_Top = lightingService.ColorShift_Top,
            OutdoorAmbient = lightingService.OutdoorAmbient,
            TimeOfDay = lightingService.TimeOfDay,
            FogColor = lightingService.FogColor,
            FogEnd = lightingService.FogEnd,
            FogStart = lightingService.FogStart,
            ExposureCompensation = lightingService.ExposureCompensation,
            ShadowSoftness = lightingService.ShadowSoftness,
            Ambient = lightingService.Ambient,
            children = lightingService:GetChildren()
        }
    end
    local function restoreDefault(lightingState)
        lightingService:ClearAllChildren()
        lightingService.Brightness = lightingState.Brightness
        lightingService.ColorShift_Bottom = lightingState.ColorShift_Bottom
        lightingService.ColorShift_Top = lightingState.ColorShift_Top
        lightingService.OutdoorAmbient = lightingState.OutdoorAmbient
        lightingService.TimeOfDay = lightingState.TimeOfDay
        lightingService.FogColor = lightingState.FogColor
        lightingService.FogEnd = lightingState.FogEnd
        lightingService.FogStart = lightingState.FogStart
        lightingService.ExposureCompensation = lightingState.ExposureCompensation
        lightingService.ShadowSoftness = lightingState.ShadowSoftness
        lightingService.Ambient = lightingState.Ambient
        for _, child in next, workspace.ItemDrops:GetChildren() do
            child.Parent = lightingService
        end
    end
	local apidump: table = {
		Sky = {
			SkyboxUp = 'Text',
			SkyboxDn = 'Text',
			SkyboxLf = 'Text',
			SkyboxRt = 'Text',
			SkyboxFt = 'Text',
			SkyboxBk = 'Text',
			SunTextureId = 'Text',
			SunAngularSize = 'Number',
			MoonTextureId = 'Text',
			MoonAngularSize = 'Number',
			StarCount = 'Number'
		},
		Atmosphere = {
			Color = 'Color',
			Decay = 'Color',
			Density = 'Number',
			Offset = 'Number',
			Glare = 'Number',
			Haze = 'Number'
		},
		BloomEffect = {
			Intensity = 'Number',
			Size = 'Number',
			Threshold = 'Number'
		},
		DepthOfFieldEffect = {
			FarIntensity = 'Number',
			FocusDistance = 'Number',
			InFocusRadius = 'Number',
			NearIntensity = 'Number'
		},
		SunRaysEffect = {
			Intensity = 'Number',
			Spread = 'Number'
		},
		ColorCorrectionEffect = {
			TintColor = 'Color',
			Saturation = 'Number',
			Contrast = 'Number',
			Brightness = 'Number'
		}
	}
    local skyThemes: table = {
        NetherWorld = {
            MoonAngularSize = 0,
            SunAngularSize = 0,
            SkyboxBk = 'rbxassetid://14365019002',
            SkyboxDn = 'rbxassetid://14365023350',
            SkyboxFt = 'rbxassetid://14365018399',
            SkyboxLf = 'rbxassetid://14365018705',
            SkyboxRt = 'rbxassetid://14365018143',
            SkyboxUp = 'rbxassetid://14365019327',
        },
        Neptune = {
		    SkyboxBk = 'rbxassetid://218955819',
		    SkyboxDn = 'rbxassetid://218953419',
		    SkyboxFt = 'rbxassetid://218954524',
		    SkyboxLf = 'rbxassetid://218958493',
		    SkyboxRt = 'rbxassetid://218957134',
		    SkyboxUp = 'rbxassetid://218950090',
        },
        Velocity = {
            SkyboxBk = 'rbxassetid://570557514',
            SkyboxDn = 'rbxassetid://570557775',
            SkyboxFt = 'rbxassetid://570557559',
            SkyboxLf = 'rbxassetid://570557620',
            SkyboxRt = 'rbxassetid://570557672',
            SkyboxUp = 'rbxassetid://570557727',
        },
        Minecraft = {
            SkyboxBk = 'rbxassetid://591058823',
            SkyboxDn = 'rbxassetid://591059876',
            SkyboxFt = 'rbxassetid://591058104',
            SkyboxLf = 'rbxassetid://591057861',
            SkyboxRt = 'rbxassetid://591057625',
            SkyboxUp = 'rbxassetid://591059642',
        },
        Purple = {
            SkyboxBk = "rbxassetid://8539982183",
            SkyboxDn = "rbxassetid://8539981943",
            SkyboxFt = "rbxassetid://8539981721",
            SkyboxLf = "rbxassetid://8539981424",
            SkyboxRt = "rbxassetid://8539980766",
            SkyboxUp = "rbxassetid://8539981085",
            MoonAngularSize = 0,
            SunAngularSize = 0,
            StarCount = 3000,
        }, 
        ["日の出"] = {
			SkyboxBk = "rbxassetid://600830446",
			SkyboxDn = "rbxassetid://600831635",
			SkyboxFt = "rbxassetid://600832720",
			SkyboxLf = "rbxassetid://600886090",
			SkyboxRt = "rbxassetid://600833862",
			SkyboxUp = "rbxassetid://600835177",
        },
        Sakura = {
            SkyboxBk = "http://www.roblox.com/asset/?id=16694315897",
            SkyboxDn = "http://www.roblox.com/asset/?id=16694319417",
            SkyboxFt = "http://www.roblox.com/asset/?id=16694324910",
            SkyboxLf = "http://www.roblox.com/asset/?id=16694328308",
            SkyboxRt = "http://www.roblox.com/asset/?id=16694331447",
            SkyboxUp = "http://www.roblox.com/asset/?id=16694334666",
            SunAngularSize = 21,
            StarCount = 3000,
        },
        Hexagonal = {
            SkyboxBk = "http://www.roblox.com/asset/?id=15876463105",
            SkyboxDn = "http://www.roblox.com/asset/?id=15876464432",
            SkyboxFt = "http://www.roblox.com/asset/?id=15876465852",
            SkyboxLf = "http://www.roblox.com/asset/?id=15876467260",
            SkyboxRt = "http://www.roblox.com/asset/?id=15876469097",
            SkyboxUp = "http://www.roblox.com/asset/?id=15876470945",
            SunAngularSize = 21,
            StarCount = 3000,
        },
        Reality = {
            SkyboxBk = "http://www.roblox.com/asset/?id=6778646360",
            SkyboxDn = "http://www.roblox.com/asset/?id=6778658683",
            SkyboxFt = "http://www.roblox.com/asset/?id=6778648039",
            SkyboxLf = "http://www.roblox.com/asset/?id=6778649136",
            SkyboxRt = "http://www.roblox.com/asset/?id=6778650519",
            SkyboxUp = "http://www.roblox.com/asset/?id=6778658364",
        },
        LunarNight = {
            SkyboxBk = 'rbxassetid://187713366',
            SkyboxDn = 'rbxassetid://187712428',
            SkyboxFt = 'rbxassetid://187712836',
            SkyboxLf = 'rbxassetid://187713755',
            SkyboxRt = 'rbxassetid://187714525',
            SkyboxUp = 'rbxassetid://187712111',
            SunAngularSize = 0,
            StarCount = 0,
        },
        FPSBoost = {
            SkyboxBk = 'rbxassetid://11457548274',
            SkyboxDn = 'rbxassetid://11457548274',
            SkyboxFt = 'rbxassetid://11457548274',
            SkyboxLf = 'rbxassetid://11457548274',
            SkyboxRt = 'rbxassetid://11457548274',
            SkyboxUp = 'rbxassetid://11457548274',
            SunAngularSize = 0,
            StarCount = 3000,
        },
        Etheral = {
            SkyboxBk = 'rbxassetid://16262356578',
            SkyboxDn = 'rbxassetid://16262358026',
            SkyboxFt = 'rbxassetid://16262360469',
            SkyboxLf = 'rbxassetid://16262362003',
            SkyboxRt = 'rbxassetid://16262363873',
            SkyboxUp = 'rbxassetid://16262366016',
            SunAngularSize = 21,
            StarCount = 3000,
        },
        Pandora = {
            SkyboxBk = 'http://www.roblox.com/asset/?id=16739324092',
            SkyboxDn = 'http://www.roblox.com/asset/?id=16739325541',
            SkyboxFt = 'http://www.roblox.com/asset/?id=16739327056',
            SkyboxLf = 'http://www.roblox.com/asset/?id=16739329370',
            SkyboxRt = 'http://www.roblox.com/asset/?id=16739331050',
            SkyboxUp = 'http://www.roblox.com/asset/?id=16739332736',
            SunAngularSize = 21,
            StarCount = 3000,
        },
        Polaris = {
            SkyboxBk = 'http://www.roblox.com/asset/?id=16823270864',
            SkyboxDn = 'http://www.roblox.com/asset/?id=16823272150',
            SkyboxFt = 'http://www.roblox.com/asset/?id=16823273508',
            SkyboxLf = 'http://www.roblox.com/asset/?id=16823274898',
            SkyboxRt = 'http://www.roblox.com/asset/?id=16823276281',
            SkyboxUp = 'http://www.roblox.com/asset/?id=16823277547',
            SunAngularSize = 21,
            StarCount = 3000,
        },
        Diaphanous = {
            SkyboxBk = 'http://www.roblox.com/asset/?id=16888989874',
            SkyboxDn = 'http://www.roblox.com/asset/?id=16888991855',
            SkyboxFt = 'http://www.roblox.com/asset/?id=16888995219',
            SkyboxLf = 'http://www.roblox.com/asset/?id=16888998994',
            SkyboxRt = 'http://www.roblox.com/asset/?id=16889000916',
            SkyboxUp = 'http://www.roblox.com/asset/?id=16889004122',
            SunAngularSize = 21,
            StarCount = 3000,
        },
        Transcendent = {
            SkyboxBk = 'http://www.roblox.com/asset/?id=17124357467',
            SkyboxDn = 'http://www.roblox.com/asset/?id=17124359797',
            SkyboxFt = 'http://www.roblox.com/asset/?id=17124362093',
            SkyboxLf = 'http://www.roblox.com/asset/?id=17124365127',
            SkyboxRt = 'http://www.roblox.com/asset/?id=17124367200',
            SkyboxUp = 'http://www.roblox.com/asset/?id=17124369657',
            SunAngularSize = 21,
            StarCount = 3000,
        },
        Truth = {
            SkyboxBk = "http://www.roblox.com/asset/?id=144933338",
            SkyboxDn = "http://www.roblox.com/asset/?id=144931530",
            SkyboxFt = "http://www.roblox.com/asset/?id=144933262",
            SkyboxLf = "http://www.roblox.com/asset/?id=144933244",
            SkyboxRt = "http://www.roblox.com/asset/?id=144933299",
            SkyboxUp = "http://www.roblox.com/asset/?id=144931564",
        },
        RayTracing = {
            SkyboxBk = "http://www.roblox.com/asset/?id=271042516",
            SkyboxDn = "http://www.roblox.com/asset/?id=271077243",
            SkyboxFt = "http://www.roblox.com/asset/?id=271042556",
            SkyboxLf = "http://www.roblox.com/asset/?id=271042310",
            SkyboxRt = "http://www.roblox.com/asset/?id=271042467",
            SkyboxUp = "http://www.roblox.com/asset/?id=271077958",
        },
        Nebula = {
            MoonAngularSize = 0,
            SunAngularSize = 0,
            SkyboxBk = 'rbxassetid://5260808177',
            SkyboxDn = 'rbxassetid://5260653793',
            SkyboxFt = 'rbxassetid://5260817288',
            SkyboxLf = 'rbxassetid://5260800833',
            SkyboxRt = 'rbxassetid://5260811073',
            SkyboxUp = 'rbxassetid://5260824661',
        },
        Planets = {
            MoonAngularSize = 0,
            SunAngularSize = 0,
            SkyboxBk = 'rbxassetid://15983968922',
            SkyboxDn = 'rbxassetid://15983966825',
            SkyboxFt = 'rbxassetid://15983965025',
            SkyboxLf = 'rbxassetid://15983967420',
            SkyboxRt = 'rbxassetid://15983966246',
            SkyboxUp = 'rbxassetid://15983964246',
            StarCount = 3000,
        },
        Galaxy = {
            SkyboxBk = "rbxassetid://159454299",
            SkyboxDn = "rbxassetid://159454296",
            SkyboxFt = "rbxassetid://159454293",
            SkyboxLf = "rbxassetid://159454293",
            SkyboxRt = "rbxassetid://159454293",
            SkyboxUp = "rbxassetid://159454288",
            SunAngularSize = 0,
        }, 
        Blues = {
            SkyboxBk = 'http://www.roblox.com/asset/?id=17124357467',
            SkyboxDn = 'http://www.roblox.com/asset/?id=17124359797',
            SkyboxFt = 'http://www.roblox.com/asset/?id=17124362093',
            SkyboxLf = 'http://www.roblox.com/asset/?id=17124365127',
            SkyboxRt = 'http://www.roblox.com/asset/?id=17124367200',
            SkyboxUp = 'http://www.roblox.com/asset/?id=17124369657',
            SunAngularSize = 21,
            StarCount = 3000,
        },
        Milkyway = {
            MoonTextureId = 'rbxassetid://1075087760',
            SkyboxBk = 'rbxassetid://2670643994',
            SkyboxDn = 'rbxassetid://2670643365',
            SkyboxFt = 'rbxassetid://2670643214',
            SkyboxLf = 'rbxassetid://2670643070',
            SkyboxRt = 'rbxassetid://2670644173',
            SkyboxUp = 'rbxassetid://2670644331',
            MoonAngularSize = 1.5,
            StarCount = 500,
        },
        Orange = {
            SkyboxBk = 'rbxassetid://150939022',
            SkyboxDn = 'rbxassetid://150939038',
            SkyboxFt = 'rbxassetid://150939047',
            SkyboxLf = 'rbxassetid://150939056',
            SkyboxRt = 'rbxassetid://150939063',
            SkyboxUp = 'rbxassetid://150939082',
        },
        DarkMountains = {
            SkyboxBk = 'rbxassetid://5098814730',
            SkyboxDn = 'rbxassetid://5098815227',
            SkyboxFt = 'rbxassetid://5098815653',
            SkyboxLf = 'rbxassetid://5098816155',
            SkyboxRt = 'rbxassetid://5098820352',
            SkyboxUp = 'rbxassetid://5098819127',
        },
        Space = {
            MoonAngularSize = 0,
            SunAngularSize = 0,
            SkyboxBk = 'rbxassetid://166509999',
            SkyboxDn = 'rbxassetid://166510057',
            SkyboxFt = 'rbxassetid://166510116',
            SkyboxLf = 'rbxassetid://166510092',
            SkyboxRt = 'rbxassetid://166510131',
            SkyboxUp = 'rbxassetid://166510114',
        },
        Void = {
            MoonAngularSize = 0,
            SunAngularSize = 0,
            SkyboxBk = 'rbxassetid://14543264135',
            SkyboxDn = 'rbxassetid://14543358958',
            SkyboxFt = 'rbxassetid://14543257810',
            SkyboxLf = 'rbxassetid://14543275895',
            SkyboxRt = 'rbxassetid://14543280890',
            SkyboxUp = 'rbxassetid://14543371676',
        },
        Stary = {
            SkyboxBk = 'rbxassetid://248431616',
            SkyboxDn = 'rbxassetid://248431677',
            SkyboxFt = 'rbxassetid://248431598',
            SkyboxLf = 'rbxassetid://248431686',
            SkyboxRt = 'rbxassetid://248431611',
            SkyboxUp = 'rbxassetid://248431605',
			StarCount = 3000,       
        },
		Violet = {
			SkyboxBk = 'rbxassetid://8107841671',
			SkyboxDn = 'rbxassetid://6444884785',
			SkyboxFt = 'rbxassetid://8107841671',
			SkyboxLf = 'rbxassetid://8107841671',
			SkyboxRt = 'rbxassetid://8107841671',
			SkyboxUp = 'rbxassetid://8107849791',
			SunTextureId = 'rbxassetid://6196665106',
			MoonTextureId = 'rbxassetid://6444320592',
			MoonAngularSize = 0
        }
    }
    local ILS: any = BeforeShaders()
	local function removeObject(v)
		if not table.find(newobjects, v) then 
			local toggle = Toggles[v.ClassName]
			if toggle and toggle.Toggle["Enabled"] then
				table.insert(oldobjects, v)
				v.Parent = game
			end
		end
	end
	
	local function themes(val)
        local theme = skyThemes[themeName["Value"]]
        if theme then
            local sky = lightingService:FindFirstChild("CustomSky") or Instance.new("Sky", lightingService)
            for v, value in next, theme do
                if v ~= "Atmosphere" then
                    sky[v] = value
                end
            end
        end;
    end;

	Atmosphere = vape.Legit:CreateModule({
		["Name"] = 'Atmosphere',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v in lightingService:GetChildren() do
                    if v:IsA('PostEffect') or v:IsA('Sky') or v:IsA('Atmosphere') or v:IsA('Clouds') then
                        v:Destroy()
                    end
                end

                for _, v in workspace:GetDescendants() do
                    if v:IsA("Clouds") then
                        v:Destroy()
                    end;
                end;
				local d: number = 0
				local r: any = workspace.Terrain
				for _, v in lightingService:GetChildren() do
                    if v:IsA('PostEffect') or v:IsA('Sky') or v:IsA('Atmosphere') or v:IsA('Clouds') then -- Added Clouds
                        v:Destroy();
                    end;
                end;
				lightingService.Brightness = d + 1;
                lightingService.EnvironmentDiffuseScale = d + 0.2;
                lightingService.EnvironmentSpecularScale = d + 0.82;

                local sunRays = Instance.new('SunRaysEffect')
                table.insert(newobjects, sunRays)
                pcall(function() sunRays.Parent = lightingService end)

                local atmosphere = Instance.new('Atmosphere')
                table.insert(newobjects, atmosphere)
                pcall(function() atmosphere.Parent = lightingService end)

                local sky = Instance.new('Sky')
                table.insert(newobjects, sky)
                pcall(function() sky.Parent = lightingService end)

                local blur = Instance.new('BlurEffect')
                blur.Size = d + 3.921
                table.insert(newobjects, blur)
                pcall(function() blur.Parent = lightingService end)

                local color_correction = Instance.new('ColorCorrectionEffect')
                color_correction.Saturation = d + 0.092
                table.insert(newobjects, color_correction)
                pcall(function() color_correction.Parent = lightingService end)

                local clouds = Instance.new('Clouds')
                clouds.Cover = d + 0.4
                table.insert(newobjects, clouds)
                pcall(function() clouds.Parent = r end)

                r.WaterTransparency = d + 1
                r.WaterReflectance = d + 1

				themes()
				for _, v in lightingService:GetChildren() do
					removeObject(v)
				end
				Atmosphere:Clean(lightingService.ChildAdded:Connect(function(v)
					task.defer(removeObject, v)
				end))
	
				for className, classData in Toggles do
					if classData.Toggle["Enabled"] then
						local obj: any = Instance.new(className)
						for propName, propData in classData.Objects do
							if propData.Type == 'ColorSlider' then
								obj[propName] = Color3.fromHSV(propData.Hue, propData.Sat, propData.Value)
							else
								if apidump[className][propName] == 'Number' then
									obj[propName] = tonumber(propData.Value) or 0
								else
									obj[propName] = propData.Value
								end
							end
						end
						obj.Name = "Custom" .. className
						table.insert(newobjects, obj)
						task.defer(function()
							pcall(function() obj.Parent = lightingService end)
						end)
					end
				end
			else
                for _, v in newobjects do
                    if v and v.Destroy then
                        v:Destroy()
                    end
                end
                for _, v in oldobjects do
                    pcall(function() v.Parent = lightingService end)
                end
                table.clear(newobjects)
                table.clear(oldobjects)
				for _, v in lightingService:GetChildren() do
                    if v:IsA("ColorCorrectionEffect") then
                        v:Destroy()
                    end
                end
				restoreDefault(ILS)
			end
		end,
		["Tooltip"] = 'Custom lighting objects'
	})
	local skyboxes: table = {}
    for v,_ in next, skyThemes do
        table.insert(skyboxes, v)
    end
	themeName = Atmosphere:CreateDropdown({
        ["Name"] = "Mode",
        ["List"] = skyboxes,
        ["Function"] = function(val) end;
    })
	for i, v in apidump do
		Toggles[i] = {Objects = {}}
		Toggles[i].Toggle = Atmosphere:CreateToggle({
			["Name"] = i,
			["Function"] = function(callback: boolean): void
				if Atmosphere["Enabled"] then
					Atmosphere:Toggle()
					Atmosphere:Toggle()
				end
				for _, toggle in Toggles[i].Objects do
					toggle.Object.Visible = callback
				end
			end
		})
	
		for i2, v2 in v do
			if v2 == 'Text' or v2 == 'Number' then
				Toggles[i].Objects[i2] = Atmosphere:CreateTextBox({
					["Name"] = i2,
					["Function"] = function(enter)
						if Atmosphere["Enabled"] and enter then
							Atmosphere:Toggle()
							Atmosphere:Toggle()
						end
					end,
					["Darker"] = true,
					["Default"] = v2 == 'Number' and '0' or nil,
					["Visible"] = false
				})
			elseif v2 == 'Color' then
				Toggles[i].Objects[i2] = Atmosphere:CreateColorSlider({
					["Name"] = i2,
					["Function"] = function()
						if Atmosphere["Enabled"] then
							Atmosphere:Toggle()
							Atmosphere:Toggle()
						end
					end,
					["Darker"] = true,
					["Visible"] = false
				})
			end
		end
	end
end)

velo.run(function()
	local Breadcrumbs: table = {["Enabled"] = false}
	local Texture: table = {}
	local Lifetime: table = {}
	local Thickness: table = {}
	local FadeIn: any;
	local FadeOut: any
	local trail: any, point: any, point2: any;
	Breadcrumbs = vape.Legit:CreateModule({
		["Name"] = 'Breadcrumbs',
		["Function"] = function(callback: boolean): void
			if callback then
				point = Instance.new('Attachment')
				point.Position = Vector3.new(0, Thickness["Value"] - 2.7, 0)
				point2 = Instance.new('Attachment')
				point2.Position = Vector3.new(0, -Thickness["Value"] - 2.7, 0)
				trail = Instance.new('Trail')
				trail.Texture = Texture["Value"] == '' and 'http://www.roblox.com/asset/?id=14166981368' or Texture.Value
				trail.TextureMode = Enum.TextureMode.Static
				trail.Color = ColorSequence.new(Color3.fromHSV(FadeIn.Hue, FadeIn.Sat, FadeIn.Value), Color3.fromHSV(FadeOut.Hue, FadeOut.Sat, FadeOut.Value))
				trail.Lifetime = Lifetime["Value"]
				trail.Attachment0 = point
				trail.Attachment1 = point2
				trail.FaceCamera = true
	
				Breadcrumbs:Clean(trail)
				Breadcrumbs:Clean(point)
				Breadcrumbs:Clean(point2)
				Breadcrumbs:Clean(entitylib.Events.LocalAdded:Connect(function(ent)
					point.Parent = ent.HumanoidRootPart
					point2.Parent = ent.HumanoidRootPart
					trail.Parent = gameCamera
				end))
				if entitylib.isAlive then
					point.Parent = entitylib.character.RootPart
					point2.Parent = entitylib.character.RootPart
					trail.Parent = gameCamera
				end
			else
				trail = nil
				point = nil
				point2 = nil
			end
		end,
		["Tooltip"] = 'Shows a trail behind your character'
	})
	Texture = Breadcrumbs:CreateTextBox({
		["Name"] = 'Texture',
		["Placeholder"] = 'Texture Id',
		["Function"] = function(enter)
			if enter and trail then
				trail.Texture = Texture["Value"] == '' and 'http://www.roblox.com/asset/?id=14166981368' or Texture.Value
			end
		end
	})
	FadeIn = Breadcrumbs:CreateColorSlider({
		["Name"] = 'Fade In',
		["Function"] = function(hue, sat, val)
			if trail then
				trail.Color = ColorSequence.new(Color3.fromHSV(hue, sat, val), Color3.fromHSV(FadeOut.Hue, FadeOut.Sat, FadeOut.Value))
			end
		end
	})
	FadeOut = Breadcrumbs:CreateColorSlider({
		["Name"] = 'Fade Out',
		["Function"] = function(hue, sat, val)
			if trail then
				trail.Color = ColorSequence.new(Color3.fromHSV(FadeIn.Hue, FadeIn.Sat, FadeIn.Value), Color3.fromHSV(hue, sat, val))
			end
		end
	})
	Lifetime = Breadcrumbs:CreateSlider({
		["Name"] = 'Lifetime',
		["Min"] = 1,
		["Max"] = 5,
		["Default"] = 3,
		["Decimal"] = 10,
		["Function"] = function(val)
			if trail then
				trail.Lifetime = val
			end
		end,
		["Suffix"] = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	Thickness = Breadcrumbs:CreateSlider({
		["Name"] = 'Thickness',
		["Min"] = 0,
		["Max"] = 2,
		["Default"] = 0.1,
		["Decimal"] = 100,
		["Function"] = function(val)
			if point then
				point.Position = Vector3.new(0, val - 2.7, 0)
			end
			if point2 then
				point2.Position = Vector3.new(0, -val - 2.7, 0)
			end
		end,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)

velo.run(function()
	local ChinaHat: table = {["Enabled"] = false}
	local Material: table = {["Value"] = "ForceField"}
	local Color: table = {}
	local hat: any;
	ChinaHat = vape.Legit:CreateModule({
		["Name"] = 'China Hat',
		["Function"] = function(callback: boolean): void
			if callback then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				hat = Instance.new('MeshPart')
				hat.Size = Vector3.new(3, 0.7, 3)
				hat.Name = 'ChinaHat'
				hat.Material = Enum.Material[Material["Value"]]
				hat.Color = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
				hat.CanCollide = false
				hat.CanQuery = false
				hat.Massless = true
				hat.MeshId = 'http://www.roblox.com/asset/?id=1778999'
				hat.Transparency = 1 - Color.Opacity
				hat.Parent = gameCamera
				hat.CFrame = entitylib.isAlive and entitylib.character.Head.CFrame + Vector3.new(0, 1, 0) or CFrame.identity
				local weld = Instance.new('WeldConstraint')
				weld.Part0 = hat
				weld.Part1 = entitylib.isAlive and entitylib.character.Head or nil
				weld.Parent = hat
				ChinaHat:Clean(hat)
				ChinaHat:Clean(entitylib.Events.LocalAdded:Connect(function(char)
					if weld then 
						weld:Destroy() 
					end
					hat.Parent = gameCamera
					hat.CFrame = char.Head.CFrame + Vector3.new(0, 1, 0)
					hat.Velocity = Vector3.zero
					weld = Instance.new('WeldConstraint')
					weld.Part0 = hat
					weld.Part1 = char.Head
					weld.Parent = hat
				end))
	
				repeat
					hat.LocalTransparencyModifier = ((gameCamera.CFrame.Position - gameCamera.Focus.Position).Magnitude <= 0.6 and 1 or 0)
					task.wait()
				until not ChinaHat["Enabled"]
			else
				hat = nil
			end
		end,
		["Tooltip"] = 'Puts a china hat on your character (ty mastadawn)'
	})
	local materials: any = {'ForceField'}
	for _, v in Enum.Material:GetEnumItems() do
		if v.Name ~= 'ForceField' then
			table.insert(materials, v.Name)
		end
	end
	Material = ChinaHat:CreateDropdown({
		["Name"] = 'Material',
		["List"] = materials,
		["Function"] = function(val)
			if hat then
				hat.Material = Enum.Material[val]
			end
		end
	})
	Color = ChinaHat:CreateColorSlider({
		["Name"] = 'Hat Color',
		["DefaultOpacity"] = 0.7,
		["Function"] = function(hue, sat, val, opacity)
			if hat then
				hat.Color = Color3.fromHSV(hue, sat, val)
				hat.Transparency = 1 - opacity
			end
		end
	})
end)
	
velo.run(function()
	local Clock: table = {["Enabled"] = false} 
	local TwentyFourHour: table = {["Enabled"] = false} 
	local label: any;
	Clock = vape.Legit:CreateModule({
		["Name"] = 'Clock',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					label.Text = DateTime.now():FormatLocalTime('LT', TwentyFourHour["Enabled"] and 'zh-cn' or 'en-us')
					task.wait(1)
				until not Clock["Enabled"]
			end
		end,
		Size = UDim2.fromOffset(100, 41),
		["Tooltip"] = 'Shows the current local time'
	})
	Clock:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val)
			label.FontFace = val
		end
	})
	Clock:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			label.BackgroundTransparency = 1 - opacity
		end
	})
	TwentyFourHour = Clock:CreateToggle({
		["Name"] = '24 Hour Clock'
	})
	label = Instance.new('TextLabel')
	label.Size = UDim2.new(0, 100, 0, 41)
	label.BackgroundTransparency = 0.5
	label.TextSize = 15
	label.Font = Enum.Font.Gotham
	label.Text = '0:00 PM'
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundColor3 = Color3.new()
	label.Parent = Clock.Children
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = label
end)
	
velo.run(function()
	local Disguise: table = {["Enabled"] = false} 
	local Mode: table = {["Value"] = 'Character'} 
	local IDBox: any;
	local desc: any;
	
	local function itemAdded(v, manual)
		if (not v:GetAttribute('Disguise')) and ((v:IsA('Accessory') and (not v:GetAttribute('InvItem')) and (not v:GetAttribute('ArmorSlot'))) or v:IsA('ShirtGraphic') or v:IsA('Shirt') or v:IsA('Pants') or v:IsA('BodyColors') or manual) then
			repeat
				task.wait()
				v.Parent = game
			until v.Parent == game
			v:ClearAllChildren()
			v:Destroy()
		end
	end
	
	local function characterAdded(char)
		if Mode["Value"] == 'Character' then
			task.wait(0.1)
			char.Character.Archivable = true
			local clone = char.Character:Clone()
			repeat
				if pcall(function()
					desc = playersService:GetHumanoidDescriptionFromUserId(IDBox["Value"] == '' and 239702688 or tonumber(IDBox["Value"]))
				end) then break end
				task.wait(1)
			until not Disguise["Enabled"]
			if not Disguise["Enabled"] then
				clone:ClearAllChildren()
				clone:Destroy()
				clone = nil
				if desc then
					desc:Destroy()
					desc = nil
				end
				return
			end
			clone.Parent = game
	
			local originalDesc = char.Humanoid:WaitForChild('HumanoidDescription', 2) or {
				HeightScale = 1,
				SetEmotes = function() end,
				SetEquippedEmotes = function() end
			}
			originalDesc.JumpAnimation = desc.JumpAnimation
			desc.HeightScale = originalDesc.HeightScale
	
			for _, v in clone:GetChildren() do
				if v:IsA('Accessory') or v:IsA('ShirtGraphic') or v:IsA('Shirt') or v:IsA('Pants') then
					v:ClearAllChildren()
					v:Destroy()
				end
			end
	
			clone.Humanoid:ApplyDescriptionClientServer(desc)
			for _, v in char.Character:GetChildren() do
				itemAdded(v)
			end
			Disguise:Clean(char.Character.ChildAdded:Connect(itemAdded))
	
			for _, v in clone:WaitForChild('Animate'):GetChildren() do
				if not char.Character:FindFirstChild('Animate') then return end
				local real = char.Character.Animate:FindFirstChild(v.Name)
				if v and real then
					local anim = v:FindFirstChildWhichIsA('Animation') or {AnimationId = ''}
					local realanim = real:FindFirstChildWhichIsA('Animation') or {AnimationId = ''}
					if realanim then
						realanim.AnimationId = anim.AnimationId
					end
				end
			end
	
			for _, v in clone:GetChildren() do
				v:SetAttribute('Disguise', true)
				if v:IsA('Accessory') then
					for _, v2 in v:GetDescendants() do
						if v2:IsA('Weld') and v2.Part1 then
							v2.Part1 = char.Character[v2.Part1.Name]
						end
					end
					v.Parent = char.Character
				elseif v:IsA('ShirtGraphic') or v:IsA('Shirt') or v:IsA('Pants') or v:IsA('BodyColors') then
					v.Parent = char.Character
				elseif v.Name == 'Head' and char.Head:IsA('MeshPart') and (not char.Head:FindFirstChild('FaceControls')) then
					char.Head.MeshId = v.MeshId
				end
			end
	
			local localface = char.Character:FindFirstChild('face', true)
			local cloneface = clone:FindFirstChild('face', true)
			if localface and cloneface then
				itemAdded(localface, true)
				cloneface.Parent = char.Head
			end
			originalDesc:SetEmotes(desc:GetEmotes())
			originalDesc:SetEquippedEmotes(desc:GetEquippedEmotes())
			clone:ClearAllChildren()
			clone:Destroy()
			clone = nil
			if desc then
				desc:Destroy()
				desc = nil
			end
		else
			local data
			repeat
				if pcall(function()
					data = marketplaceService:GetProductInfo(IDBox["Value"] == '' and 43 or tonumber(IDBox["Value"]), Enum.InfoType.Bundle)
				end) then break end
				task.wait(1)
			until not Disguise["Enabled"]
			if not Disguise["Enabled"] then
				if data then
					table.clear(data)
					data = nil
				end
				return
			end
			if data.BundleType == 'AvatarAnimations' then
				local animate = char.Character:FindFirstChild('Animate')
				if not animate then return end
				for _, v in desc.Items do
					local animtype = v.Name:split(' ')[2]:lower()
					if animtype ~= 'animation' then
						local suc, res = pcall(function() return game:GetObjects('rbxassetid://'..v.Id) end)
						if suc then
							animate[animtype]:FindFirstChildWhichIsA('Animation').AnimationId = res[1]:FindFirstChildWhichIsA('Animation', true).AnimationId
						end
					end
				end
			else
				notif('Disguise', 'that\'s not an animation pack', 5, 'warning')
			end
		end
	end
	
	Disguise = vape.Legit:CreateModule({
		["Name"] = 'Disguise',
		["Function"] = function(callback: boolean): void
			if callback then
				Disguise:Clean(entitylib.Events.LocalAdded:Connect(characterAdded))
				if entitylib.isAlive then
					characterAdded(entitylib.character)
				end
			end
		end,
		["Tooltip"] = 'Changes your character or animation to a specific ID (animation packs or userid\'s only)'
	})
	Mode = Disguise:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Character', 'Animation'},
		["Function"] = function()
			if Disguise["Enabled"] then
				Disguise:Toggle()
				Disguise:Toggle()
			end
		end
	})
	IDBox = Disguise:CreateTextBox({
		["Name"] = 'Disguise',
		["Placeholder"] = 'Disguise User Id',
		["Function"] = function()
			if Disguise["Enabled"] then
				Disguise:Toggle()
				Disguise:Toggle()
			end
		end
	})
end)
	
velo.run(function()
	local FOV: table = {["Enabled"] = false} 
	local Value: table = {["Value"] = 120} 
	local oldfov: any;
	FOV = vape.Legit:CreateModule({
		["Name"] = 'FOV',
		["Function"] = function(callback: boolean): void
			if callback then
				oldfov = gameCamera.FieldOfView
				repeat
					gameCamera.FieldOfView = Value.Value
					task.wait()
				until not FOV["Enabled"]
			else
				gameCamera.FieldOfView = oldfov
			end
		end,
		["Tooltip"] = 'Adjusts camera vision'
	})
	Value = FOV:CreateSlider({
		["Name"] = 'FOV',
		["Min"] = 30,
		["Max"] = 120
	})
end)
	
velo.run(function()
	--[[
		Grabbing an accurate count of the current framerate
		Source: https://devforum.roblox.com/t/get-client-FPS-trough-a-script/282631
	]]
	local FPS: table = {["Enabled"] = false} 
	local label: any;
	FPS = vape.Legit:CreateModule({
		["Name"] = 'FPS',
		["Function"] = function(callback: boolean): void
			if callback then
				local frames = {}
				local startClock = os.clock()
				local updateTick = tick()
				FPS:Clean(runService.Heartbeat:Connect(function()
					local updateClock = os.clock()
					for i = #frames, 1, -1 do
						frames[i + 1] = frames[i] >= updateClock - 1 and frames[i] or nil
					end
					frames[1] = updateClock
					if updateTick < tick() then
						updateTick = tick() + 1
						label.Text = math.floor(os.clock() - startClock >= 1 and #frames or #frames / (os.clock() - startClock))..' FPS'
					end
				end))
			end
		end,
		Size = UDim2.fromOffset(100, 41),
		["Tooltip"] = 'Shows the current framerate'
	})
	FPS:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val)
			label.FontFace = val
		end
	})
	FPS:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			label.BackgroundTransparency = 1 - opacity
		end
	})
	label = Instance.new('TextLabel')
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.5
	label.TextSize = 15
	label.Font = Enum.Font.Gotham
	label.Text = 'inf FPS'
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundColor3 = Color3.new()
	label.Parent = FPS.Children
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = label
end)
	
velo.run(function()
	local Keystrokes: table = {["Enabled"] = false} 
	local Style: table = {} 
	local Color: table = {}
	local keys: any, holder: table? = {}
	
	local function createKeystroke(keybutton, pos, pos2, text)
		if keys[keybutton] then
			keys[keybutton].Key:Destroy()
			keys[keybutton] = nil
		end
		local key = Instance.new('Frame')
		key.Size = keybutton == Enum.KeyCode.Space and UDim2.new(0, 110, 0, 24) or UDim2.new(0, 34, 0, 36)
		key.BackgroundColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
		key.BackgroundTransparency = 1 - Color.Opacity
		key.Position = pos
		key.Name = keybutton.Name
		key.Parent = holder
		local keytext = Instance.new('TextLabel')
		keytext.BackgroundTransparency = 1
		keytext.Size = UDim2.fromScale(1, 1)
		keytext.Font = Enum.Font.Gotham
		keytext.Text = text or keybutton.Name
		keytext.TextXAlignment = Enum.TextXAlignment.Left
		keytext.TextYAlignment = Enum.TextYAlignment.Top
		keytext.Position = pos2
		keytext.TextSize = keybutton == Enum.KeyCode.Space and 18 or 15
		keytext.TextColor3 = Color3.new(1, 1, 1)
		keytext.Parent = key
		local corner = Instance.new('UICorner')
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = key
		keys[keybutton] = {Key = key}
	end
	
	Keystrokes = vape.Legit:CreateModule({
		["Name"] = 'Keystrokes',
		["Function"] = function(callback: boolean): void
			if callback then
				createKeystroke(Enum.KeyCode.W, UDim2.new(0, 38, 0, 0), UDim2.new(0, 6, 0, 5), Style.Value == 'Arrow' and '↑' or nil)
				createKeystroke(Enum.KeyCode.S, UDim2.new(0, 38, 0, 42), UDim2.new(0, 8, 0, 5), Style.Value == 'Arrow' and '↓' or nil)
				createKeystroke(Enum.KeyCode.A, UDim2.new(0, 0, 0, 42), UDim2.new(0, 7, 0, 5), Style.Value == 'Arrow' and '←' or nil)
				createKeystroke(Enum.KeyCode.D, UDim2.new(0, 76, 0, 42), UDim2.new(0, 8, 0, 5), Style.Value == 'Arrow' and '→' or nil)
	
				Keystrokes:Clean(inputService.InputBegan:Connect(function(inputType)
					local key = keys[inputType.KeyCode]
					if key then
						if key.Tween then
							key.Tween:Cancel()
						end
						if key.Tween2 then
							key.Tween2:Cancel()
						end
	
						key.Pressed = true
						key.Tween = tweenService:Create(key.Key, TweenInfo.new(0.1), {
							BackgroundColor3 = Color3.new(1, 1, 1), 
							BackgroundTransparency = 0
						})
						key.Tween2 = tweenService:Create(key.Key.TextLabel, TweenInfo.new(0.1), {
							TextColor3 = Color3.new()
						})
						key.Tween:Play()
						key.Tween2:Play()
					end
				end))
	
				Keystrokes:Clean(inputService.InputEnded:Connect(function(inputType)
					local key = keys[inputType.KeyCode]
					if key then
						if key.Tween then
							key.Tween:Cancel()
						end
						if key.Tween2 then
							key.Tween2:Cancel()
						end
	
						key.Pressed = false
						key.Tween = tweenService:Create(key.Key, TweenInfo.new(0.1), {
							BackgroundColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value), 
							BackgroundTransparency = 1 - Color.Opacity
						})
						key.Tween2 = tweenService:Create(key.Key.TextLabel, TweenInfo.new(0.1), {
							TextColor3 = Color3.new(1, 1, 1)
						})
						key.Tween:Play()
						key.Tween2:Play()
					end
				end))
			end
		end,
		Size = UDim2.fromOffset(110, 176),
		["Tooltip"] = 'Shows movement keys onscreen'
	})
	holder = Instance.new('Frame')
	holder.Size = UDim2.fromScale(1, 1)
	holder.BackgroundTransparency = 1
	holder.Parent = Keystrokes.Children
	Style = Keystrokes:CreateDropdown({
		["Name"] = 'Key Style',
		["List"] = {'Keyboard', 'Arrow'},
		["Function"] = function()
			if Keystrokes["Enabled"] then
				Keystrokes:Toggle()
				Keystrokes:Toggle()
			end
		end
	})
	Color = Keystrokes:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			for _, v in keys do
				if not v.Pressed then
					v.Key.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
					v.Key.BackgroundTransparency = 1 - opacity
				end
			end
		end
	})
	Keystrokes:CreateToggle({
		["Name"] = 'Show Spacebar',
		["Function"] = function(callback: boolean): void
			Keystrokes.Children.Size = UDim2.fromOffset(110, callback and 107 or 78)
			if callback then
				createKeystroke(Enum.KeyCode.Space, UDim2.new(0, 0, 0, 83), UDim2.new(0, 25, 0, -10), '______')
			else
				keys[Enum.KeyCode.Space].Key:Destroy()
				keys[Enum.KeyCode.Space] = nil
			end
		end,
		["Default"] = true
	})
end)
	
velo.run(function()
	local Memory: table = {["Enabled"] = false} 
	local label: any;
	Memory = vape.Legit:CreateModule({
		["Name"] = 'Memory',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					label.Text = math.floor(tonumber(game:GetService('Stats'):FindFirstChild('PerformanceStats').Memory:GetValue()))..' MB'
					task.wait(1)
				until not Memory["Enabled"]
			end
		end,
		Size = UDim2.fromOffset(100, 41),
		["Tooltip"] = 'A label showing the memory currently used by roblox'
	})
	Memory:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val)
			label.FontFace = val
		end
	})
	Memory:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			label.BackgroundTransparency = 1 - opacity
		end
	})
	label = Instance.new('TextLabel')
	label.Size = UDim2.new(0, 100, 0, 41)
	label.BackgroundTransparency = 0.5
	label.TextSize = 15
	label.Font = Enum.Font.Gotham
	label.Text = '0 MB'
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundColor3 = Color3.new()
	label.Parent = Memory.Children
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = label
end)
	
velo.run(function()
	local Ping: table = {["Enabled"] = false} 
	local label: any;
	Ping = vape.Legit:CreateModule({
		["Name"] = 'Ping',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					label.Text = math.floor(tonumber(game:GetService('Stats'):FindFirstChild('PerformanceStats').Ping:GetValue()))..' ms'
					task.wait(1)
				until not Ping["Enabled"]
			end
		end,
		Size = UDim2.fromOffset(100, 41),
		["Tooltip"] = 'Shows the current connection speed to the roblox server'
	})
	Ping:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val)
			label.FontFace = val
		end
	})
	Ping:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			label.BackgroundTransparency = 1 - opacity
		end
	})
	label = Instance.new('TextLabel')
	label.Size = UDim2.new(0, 100, 0, 41)
	label.BackgroundTransparency = 0.5
	label.TextSize = 15
	label.Font = Enum.Font.Gotham
	label.Text = '0 ms'
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundColor3 = Color3.new()
	label.Parent = Ping.Children
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = label
end)
	
velo.run(function()
	local SongBeats: table = {["Enabled"] = false}
	local List: table = {};
	local FOV: table = {["Enabled"] = false}
	local FOVValue: table = {}
	local Volume: table = {};
	local alreadypicked: any = {}
	local beattick: number = tick()
	local oldfov: any;
	local songobj: Sound;
	local songbpm: any;
	local songtween: any;
	
	local function choosesong()
		local list = List.ListEnabled
		if #alreadypicked >= #list then
			table.clear(alreadypicked)
		end
	
		if #list <= 0 then
			notif('SongBeats', 'no songs', 10)
			SongBeats:Toggle()
			return
		end
	
		local chosensong = list[math.random(1, #list)]
		if #list > 1 and table.find(alreadypicked, chosensong) then
			repeat
				task.wait()
				chosensong = list[math.random(1, #list)]
			until not table.find(alreadypicked, chosensong) or not SongBeats["Enabled"]
		end
		if not SongBeats["Enabled"] then return end
	
		local split = chosensong:split('/')
		if not isfile(split[1]) then
			notif('SongBeats', 'Missing song ('..split[1]..')', 10)
			SongBeats:Toggle()
			return
		end
	
		songobj.SoundId = assetfunction(split[1])
		repeat task.wait() until songobj.IsLoaded or not SongBeats["Enabled"]
		if SongBeats["Enabled"] then
			beattick = tick() + (tonumber(split[3]) or 0)
			songbpm = 60 / (tonumber(split[2]) or 50)
			songobj:Play()
		end
	end
	
	SongBeats = vape.Legit:CreateModule({
		["Name"] = 'Song Beats',
		["Function"] = function(callback: boolean):void
			if callback then
				songobj = Instance.new('Sound')
				songobj.Volume = Volume["Value"] / 100
				songobj.Parent = workspace
				oldfov = gameCamera.FieldOfView
	
				repeat
					if not songobj.Playing then
						choosesong()
					end
					if beattick < tick() and SongBeats["Enabled"] and FOV["Enabled"] then
						beattick = tick() + songbpm
						gameCamera.FieldOfView = oldfov - FOVValue["Value"]
						songtween = tweenService:Create(gameCamera, TweenInfo.new(math.min(songbpm, 0.2), Enum.EasingStyle.Linear), {
							FieldOfView = oldfov
						})
						songtween:Play()
					end
					task.wait()
				until not SongBeats["Enabled"]
			else
				if songobj then
					songobj:Destroy()
				end
				if songtween then
					songtween:Cancel()
				end
				if oldfov then
					gameCamera.FieldOfView = oldfov
				end
				table.clear(alreadypicked)
			end
		end,
		Tooltip = 'Built in mp3 player'
	})
	List = SongBeats:CreateTextList({
		["Name"] = 'Songs',
		["Placeholder"] = 'filepath/bpm/start'
	})
	FOV = SongBeats:CreateToggle({
		["Name"] = 'Beat FOV',
		["Function"] = function(callback: boolean): void
			if FOVValue.Object then
				FOVValue.Object.Visible = callback
			end
			if SongBeats["Enabled"] then
				SongBeats:Toggle()
				SongBeats:Toggle()
			end
		end,
		["Default"] = true
	})
	FOVValue = SongBeats:CreateSlider({
		["Name"] = 'Adjustment',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 5,
		["Darker"] = true
	})
	Volume = SongBeats:CreateSlider({
		["Name"] = 'Volume',
		["Function"] = function(val)
			if songobj then
				songobj.Volume = val / 100
			end
		end,
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 100,
		["Suffix"] = '%'
	})
end)
	
velo.run(function()
	local Speedmeter: table = {["Enabled"] = false};
	local label: any;
	Speedmeter = vape.Legit:CreateModule({
		["Name"] = 'Speedmeter',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					local lastpos: any = entitylib.isAlive and entitylib.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1) or Vector3.zero
					local dt: any = task.wait(0.2)
					local newpos: any = entitylib.isAlive and entitylib.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1) or Vector3.zero
					label.Text = math.round(((lastpos - newpos) / dt).Magnitude)..' sps'
				until not Speedmeter["Enabled"]
			end
		end,
		Size = UDim2.fromOffset(100, 41),
		Tooltip = 'A label showing the average velocity in studs'
	})
	Speedmeter:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val)
			label.FontFace = val
		end
	})
	Speedmeter:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			label.BackgroundTransparency = 1 - opacity
		end
	})
	label = Instance.new('TextLabel')
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.5
	label.TextSize = 15
	label.Font = Enum.Font.Gotham
	label.Text = '0 sps'
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundColor3 = Color3.new()
	label.Parent = Speedmeter.Children
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = label
end)
	
velo.run(function()
	local TimeChanger: table = {["Enabled"] = false};
	local Value: table = {["Value"] = 12};
	local old: any;
	
	TimeChanger = vape.Legit:CreateModule({
		["Name"] = 'Time Changer',
		["Function"] = function(callback: boolean): void
			if callback then
				old = lightingService.TimeOfDay
				lightingService.TimeOfDay = Value["Value"]..':00:00'
			else
				lightingService.TimeOfDay = old
				old = nil
			end
		end,
		Tooltip = 'Change the time of the current world'
	})
	Value = TimeChanger:CreateSlider({
		["Name"] = 'Time',
		["Min"] = 0,
		["Max"] = 24,
		["Default"] = 12,
		["Function"] = function(val)
			if TimeChanger["Enabled"] then 
				lightingService.TimeOfDay = val..':00:00'
			end
		end
	})
end)

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
	local color: () -> {Hue: number, Sat: number, Value: number} = function()
		return {Hue = 0, Sat = 0, Value = 0};
	end;
    local motionblur: table = {["Enabled"] = false};
    local motionblurtarget: table = {["Enabled"] = false};
    local motionblurintensity: table = {["Value"] = 8.5};
    local blur: any = {};
    local sparkle: table = {["Enabled"] = false};
    local sparklesparent: table = {["Value"] = 'Head'};
    local sparklescolor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 0};
    local sparklesobject: any;
    local sparklestask: any;
    local fire: table = {["Enabled"] = false};
    local fireparent: table = {["Value"] = 'Head'};
    local fireflame: table = {["Value"] = 25};
    local firecolor: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 0};
    local firecolor2: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 0};
    local fireobject: any;
    local firetask: any;
    local trails: table = {["Enabled"] = false};
    local traildistance: table = {["Value"] = 7};
	local trailparts: table = setmetatable({}, {__index = table, insert = table.insert, remove = table.remove, length = function(self) return #self end});
    local lastpos: any;
    local lastpart: any;
	local trailcolor: table = color();
	local function isAlive(v: Player): Boolean
		if v.Character and v.Character:FindFirstChild("Humanoid") then
			if v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") then
				return true;
			end;
		end;
		return false;
	end; 
    local createtrailpart = function()
        local part: Part = Instance.new("Part", workspace)
        part["Anchored"] = true
        part["Material"] = Enum["Material"]["Neon"]
        part["Size"] = Vector3["new"](2, 1, 1)
        part["Shape"] = Enum["PartType"]["Ball"]
        part["CFrame"] = lplr["Character"]["PrimaryPart"]["CFrame"]
        part["CanCollide"] = false
        part["Color"] = Color3.fromHSV(trailcolor["Hue"], trailcolor["Sat"], trailcolor["Value"])
		lastpart = part
        lastpos = part["Position"]
		table.insert(trailparts, part)
		task.delay(2.5, function()
			tweenService:Create(part, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
			repeat task.wait() until (part.Transparency == 1);
			part:Destroy();
		end);
		return part;
    end;
    local lightfire = function()
        pcall(task.cancel, firetask)
        fireobject = Instance.new('Fire')
        fireobject["Color"] = Color3.fromHSV(firecolor["Hue"], firecolor["Sat"], firecolor["Value"])
        fireobject["SecondaryColor"] = Color3.fromHSV(firecolor2["Hue"], firecolor2["Sat"], firecolor2["Value"])
        fireobject["Heat"] = fireflame["Value"]
        firetask = task.spawn(function()
            repeat task.wait()
                pcall(function() fireobject["Parent"] = (gameCamera.CFrame.Position - gameCamera.Focus.Position).Magnitude <= 0.6 and lplr.Character or lplr.Character[fireparent["Value"]] end)
                task.wait();
            until false;
        end);
    end;
    local addsparkle = function()
        pcall(task.cancel, sparklestask)
        local sparkle: Sparkles = Instance.new('Sparkles')
        sparkle["Color"] = Color3.fromHSV(sparklescolor["Hue"], sparklescolor["Sat"], sparklescolor["Value"])
        sparklesobject = sparkle
        sparklestask = task.spawn(function()
            repeat task.wait()
                pcall(function() sparkle.Parent = (gameCamera.CFrame.Position - gameCamera.Focus.Position).Magnitude <= 0.6 and lplr.Character or lplr.Character[sparklesparent["Value"]] end)
                task.wait();
            until false;
        end);
    end;
    Envision = vape.Legit:CreateModule({
        ["Name"] = "Envision",
        ["HoverText"] = HoverText("Let's you customize visuals!"),
        ["Function"] = function(callback: boolean): void
            if callback then
				if not sparkle.Connections then
					sparkle.Connections = {}
				end
				if not fire.Connections then
					fire.Connections = {}
				end
				if not trails.Connections then
					trails.Connections = {}
				end
				task.spawn(function()
					if motionblur["Enabled"] then
						task.spawn(function()
							repeat task.wait() 
							until (isAlive(lplr) or not motionblur["Enabled"])
						end)
						table.insert(motionblur.Connections, lplr.Character.PrimaryPart:GetPropertyChangedSignal('CFrame'):Connect(function()
							if motionblurtarget["Enabled"] and vapeTargetInfo.Targets.Killaura == nil then 
								return;
							end;
							if blur["Parent"] == nil then 
								blur = Instance.new("BlurEffect");
								blur.Parent = lightingService;
								Debris:AddItem(blur, 0);
							end;
							blur["Size"] = motionblurintensity["Value"];
						end));
						table.insert(motionblur.Connections, lplr.CharacterAdded:Connect(function()
							motionblur["ToggleButton"]();
							motionblur["ToggleButton"]();
						end));
					end;										
					if sparkle["Enabled"] then
						task.spawn(function() addsparkle() end) 
						table.insert(sparkle.Connections, lplr.CharacterAdded:Connect(addsparkle));
					else
						pcall(task.cancel, sparklestask);
						pcall(function() sparklesobject:Destroy() end);
					end;
					if fire["Enabled"] then
						task.spawn(function() lightfire() end);
						table.insert(fire.Connections, lplr.CharacterAdded:Connect(lightfire));
					else
						if fireobject then
							fireobject:Destroy();
						end;
					end;
					if trails["Enabled"] then
						task.spawn(function()
							repeat task.wait()
								if isAlive(lplr) and (lastpos == nil or (lplr.Character.PrimaryPart.Position - lastpos).Magnitude > traildistance["Value"]) then
									createtrailpart();
								end;
							until not trails["Enabled"] or not Envision["Enabled"];
						end)
					end;
				end)
            else
                if fireobject then
					fireobject:Destroy();
				end;
                pcall(task.cancel, sparklestask);
                pcall(function() sparklesobject:Destroy() end);
				trailparts = {};
            end;
        end;
    })
    motionblur = Envision:CreateToggle({
        ['Name'] = 'Motion Blur',
        ['HoverText'] = 'motion blur',
        ['Default'] = false,
        ['Function'] = function() end
    })
    motionblurintensity = Envision:CreateSlider({
        ['Name'] = 'Intensity',
        ['Min'] = 2,
        ['Max'] = 10,
        ['Default'] = 8.5,
        ['Function'] = function() end
    })
    trails = Envision:CreateToggle({
        ['Name'] = 'Trails Effect',
        ['HoverText'] = 'Only works when killaura is active.',
        ['Default'] = false,
        ['Function'] = function() end
    })
    traildistance = Envision:CreateSlider({
        ['Name'] = 'Distance',
        ['Min'] = 3,
        ['Max'] = 10,
        ['Function'] = function() end
    })
	trailcolor = Envision:CreateColorSlider({
		["Name"] ="Trail Color",
		["Function"] = function()
			for i,v in trailparts do 
				v.Color = Color3.fromHSV(trailcolor["Hue"], trailcolor["Sat"], trailcolor["Value"]);
			end;
		end,
	})
    fire = Envision:CreateToggle({
        ['Name'] = 'Fire Effect',
        ['HoverText'] = 'Only works when killaura is active.',
        ['Default'] = false,
        ['Function'] = function() end
    })
    fireparent = Envision:CreateDropdown({
        ['Name'] = 'Parent',
        ['List'] = {'PrimaryPart', 'Head'},
        ['Function'] = function() end
    })
    fireflame = Envision:CreateSlider({
        ['Name'] = 'Flame', 
        ['Min'] = 1,
        ['Max'] = 25,
        ['Default'] = 25,
        ['Function'] = function(value)
            if fireobject and fire["Enabled"] then 
                fireobject["Heat"] = value
            end;
        end;
    })
    firecolor = Envision:CreateColorSlider({
        ['Name'] = 'Color',
        ['Function'] = function()
            if fireobject and fire["Enabled"] then 
                fireobject["Color"] = Color3.fromHSV(firecolor['Hue'], firecolor['Sat'], firecolor['Value'])
            end;
        end;
    })
    firecolor2 = Envision:CreateColorSlider({
        ['Name'] = 'Color 2',
        ['Function'] = function()
            if fireobject and fire['Enabled'] then 
                fireobject["SecondaryColor"] = Color3.fromHSV(firecolor2['Hue'], firecolor2['Sat'], firecolor2['Value'])
            end;
        end;
    })
    sparkle = Envision:CreateToggle({
        ['Name'] = 'Sparkle Effect',
        ['HoverText'] = 'sparkles effect.',
        ['Default'] = false,
        ['Function'] = function() end
    })
    sparklesparent = Envision:CreateDropdown({
        ['Name'] = 'Sparkles Parent',
        ['List'] = {'PrimaryPart', 'Head'},
        ['Function'] = function() end
    })
    sparklescolor = Envision:CreateColorSlider({
        ['Name'] = 'Sparkles Color',
        ['Function'] = function()
            if sparklesobject then
                sparklesobject["Color"] = Color3.fromHSV(sparklescolor['Hue'], sparklescolor['Sat'], sparklescolor['Value'])
            end;
        end;
    })
end)

velo.run(function()
	local custom_char: table = {["Enabled"] = false};
	local custom_char_headless: table = {["Enabled"] = false};
	local custom_char_fc: table = {};
	local custom_char_oc: table = {};
	local custom_char_ft: table = {};
	local custom_char_ot: table = {};
	local y: any, z: any, z1: any = nil, nil, nil;
	local function isAlive(v: Player): Boolean
		if v.Character and v.Character:FindFirstChild("Humanoid") then
			if v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") then
				return true;
			end;
		end;
		return false;
	end;
	custom_char = vape.Categories.Velocity:CreateModule({
		["Name"] = 'CustomCharacter',
		["HoverText"] = 'Customizes your character.',
		["Function"] = function(callback: boolean): void
			if callback then
				if custom_char_headless["Enabled"] then
					task.spawn(function()
						repeat task.wait()
							local old: any, yz: any = nil, nil;
							local x: any = old;
							if isAlive(lplr) and lplr.Character and lplr.Character:FindFirstChild("Head") then
								lplr["Character"]["Head"]["Transparency"] = 1
								y = lplr["Character"]["Head"]:FindFirstChild('face');
								if yz then
									old = yz;
									y1["Parent"] = workspace;
								end;
								for _, v in next, lplr.Character:GetChildren() do
									if v:IsA'Accessory' then
										v["Handle"]["Transparency"] = 0;
									end;
								end;
							end;
						until not custom_char_headless["Enabled"];
					end);
				else
					lplr["Character"]["Head"]["Transparency"] = 0;
					for _, v in pairs(lplr.Character:GetChildren()) do
						if v:IsA'Accessory' then
							v["Handle"]["Transparency"] = 0;
						end;
					end;
					if old then
						old["Parent"] = entitylib["character"]["Head"];
						old = x;
					end;
				end;
				pcall(function()
					local cc: table? = {};
					cc.__index = cc;
					function cc.n(a, b, c, d, e, f, g, h)
						local self = setmetatable({}, cc);
						self.a = a;
						self.b = b;
						self.c = c;
						self.d = d;
						self.e = e;
						self.f = f;
						self.g = g;
						self.h = h;
						return self;
					end;
					function cc:s()
						local a: any = self.a;
						local b: any = self.b;
						local c: any = self.c;
						local d: any = self.d;
						local e: any = self.e;
						local f: any = self.f;
						local g: any = self.g;
						local h1: any = self.h;
						local cc_meta: table? = {
							__index = function(self, x)
								if x == 'on' then
									return function()
										local h = Instance.new('Highlight');
										h.Parent = lplr.Character;
										h.DepthMode = 'Occluded';
										h.Enabled = callback;
										h.FillColor = Color3.fromHSV(a, b, c);
										h.FillTransparency = g / 100;
										h.Name = 'velo_cc';
										h.OutlineColor = Color3.fromHSV(d, e, f);
										h.OutlineTransparency = h1 / 100;
										h.Adornee = lplr.Character;
										z = lplr.CharacterAdded:Connect(function()
											z1 = lplr.Character.ChildAdded:Connect(function(x)
												local h = Instance.new('Highlight');
												h.Parent = x;
												h.DepthMode = 'Occluded';
												h["Enabled"] = callback;
												h.FillColor = Color3.fromHSV(a, b, c);
												h.FillTransparency = g / 100;
												h.Name = 'velo_cc';
												h.OutlineColor = Color3.fromHSV(d, e, f);
												h.OutlineTransparency = h1 / 100;
												h.Adornee = x;
											end);
										end);
									end;
								end;
							end;
						};
						local cc_val: table? = setmetatable({}, cc_meta);
						cc_val:on();
					end;
					local cc_vd: table? = cc.n(
						custom_char_fc.Hue,
						custom_char_fc.Sat,
						custom_char_fc.Val,
						custom_char_oc.Hue,
						custom_char_oc.Sat,
						custom_char_oc.Val,
						custom_char_ft.Value,
						custom_char_ot.Value
					)
					cc_vd:s();
				end)
			else
				local cc: table? = {};
				cc.__index = cc;
				function cc.n()
					local self = setmetatable({}, cc);
					return self;
				end;
				function cc:s()
					local cc_meta: table? = {
						__index = function(self, x)
							if x == 'on' then
								return function()
									if z then
										z:Disconnect();
									end;
									if z1 then
										z1:Disconnect();
									end;
									for _, v in next, lplr.Character:GetDescendants() do
										if v:IsA('Highlight') then
											v:Destroy();
										end;
									end;
								end;
							end;
						end;
					};
					local cc_val = setmetatable({}, cc_meta);
					cc_val:on();
				end;
				local cc_vd = cc.n();
				cc_vd:s();
			end;
		end;
	});
	custom_char_fc = custom_char:CreateColorSlider({
		["Name"] = 'Fill Color',
		["HoverText"] = 'Color to fill your character.',
		["Function"] = function(h, s, v)
			custom_char_fc.Hue = h;
			custom_char_fc.Sat = s;
			custom_char_fc.Val = v;
			if custom_char["Enabled"] then
				if lplr.Character then
					for _, v in next, lplr.Character:GetDescendants() do
						if v:IsA('Highlight') then
							v.FillColor = Color3.fromHSV(custom_char_fc.Hue, custom_char_fc.Sat, custom_char_fc.Val);
						end;
					end;
				end;
			end;
		end;
	});
	custom_char_oc = custom_char:CreateColorSlider({
		["Name"] = 'Outline Color',
		["HoverText"] = 'Color to outline your character.',
		["Function"] = function(h, s, v) 
			custom_char_oc.Hue = h;
			custom_char_oc.Sat = s;
			custom_char_oc.Val = v;
			if custom_char["Enabled"] then
				if lplr.Character then
					for _, v in next, lplr.Character:GetDescendants() do
						if v:IsA('Highlight') then
							v.OutlineColor = Color3.fromHSV(custom_char_oc.Hue, custom_char_oc.Sat, custom_char_oc.Val);
						end;
					end;
				end;
			end;
		end;
	});
	custom_char_ft = custom_char:CreateSlider({
		["Name"] = 'Fill Transparency',
		["Min"] = 0,
		["Max"] = 100,
		["HoverText"] = 'Transparency of the character color fill.',
		["Function"] = function(val)
			if custom_char["Enabled"] then
				if lplr.Character then
					for _, v in next, lplr.Character:GetDescendants() do
						if v:IsA('Highlight') then
							v.FillTransparency = val / 100;
						end;
					end;
				end;
			end;
		end,
		["Default"] = 50
	});
	custom_char_ot = custom_char:CreateSlider({
		["Name"] = 'Outline Transparency',
		["Min"] = 0,
		["Max"] = 100,
		["HoverText"] = 'Transparency of the character outline fill.',
		["Function"] = function(val)
			if custom_char["Enabled"] then
				if lplr.Character then
					for _, v in next, lplr.Character:GetDescendants() do
						if v:IsA('Highlight') then
							v.OutlineTransparency = val / 100;
						end;
					end;
				end;
			end;
		end,
		["Default"] = 0
	});
	custom_char_headless = custom_char:CreateToggle({
		["Name"] = "Headless",
		["HoverText"] = "Gives you headless",
		["Function"] = function() end
	});
end)

velo.run(function()
	local Cape: table = {["Enabled"] = false};
	local Texture: any;
	local part: any, motor: any
	local CapeMode: table = {["Value"] = "Velocity"}
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
	}
	local function createMotor(char)
		if motor then 
			motor:Destroy() 
		end
		part.Parent = gameCamera
		motor = Instance.new('Motor6D')
		motor.MaxVelocity = 0.08
		motor.Part0 = part
		motor.Part1 = char.Character:FindFirstChild('UpperTorso') or char.RootPart
		motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(-90), 0)
		motor.C1 = CFrame.new(0, motor.Part1.Size.Y / 2, 0.45) * CFrame.Angles(0, math.rad(90), 0)
		motor.Parent = part
	end
	
	Cape = vape.Legit:CreateModule({
		["Name"] = 'Cape',
		["Function"] = function(callback: boolean): void
			if callback then
				part = Instance.new('Part')
				part.Size = Vector3.new(2, 4, 0.1)
				part.CanCollide = false
				part.CanQuery = false
				part.Massless = true
				part.Transparency = 0
				part.Material = Enum.Material.SmoothPlastic
				part.Color = Color3.new()
				part.CastShadow = false
				part.Parent = gameCamera
				local capesurface = Instance.new('SurfaceGui')
				capesurface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
				capesurface.Adornee = part
				capesurface.Parent = part
	
				if Texture.Value:find('.webm') then
					local decal = Instance.new('VideoFrame')
					decal.Video = getcustomasset(Texture.Value)
					decal.Size = UDim2.fromScale(1, 1)
					decal.BackgroundTransparency = 1
					decal.Looped = true
					decal.Parent = capesurface
					decal:Play()
				else
					local decal = Instance.new('ImageLabel')
					decal.Image = Texture.Value ~= '' and (Texture.Value:find('rbxasset') and Texture.Value or assetfunction(Texture.Value)) or 'rbxassetid://14637958134'
					decal.Size = UDim2.fromScale(1, 1)
					decal.BackgroundTransparency = 1
					decal.Parent = capesurface
				end
				Cape:Clean(part)
				Cape:Clean(entitylib.Events.LocalAdded:Connect(createMotor))
				if entitylib.isAlive then
					createMotor(entitylib.character)
				end
	
				repeat
					if motor and entitylib.isAlive then
						local velo = math.min(entitylib.character.RootPart.Velocity.Magnitude, 90)
						motor.DesiredAngle = math.rad(6) + math.rad(velo) + (velo > 1 and math.abs(math.cos(tick() * 5)) / 3 or 0)
					end
					capesurface["Enabled"] = (gameCamera.CFrame.Position - gameCamera.Focus.Position).Magnitude > 0.6
					part.Transparency = (gameCamera.CFrame.Position - gameCamera.Focus.Position).Magnitude > 0.6 and 0 or 1
					task.wait()
				until not Cape["Enabled"]
			else
				part = nil
				motor = nil
			end
		end,
		["Tooltip"] = 'Add\'s a cape to your character'
	})
	Texture = Cape:CreateTextBox({
		["Name"] = 'Texture'
	})
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
		["Function"] = function(val) 
			if capeModeMap[val] then
                		Texture["Value"] = capeModeMap[val]
            		end
		end
	})
end)

velo.run(function()
    local SkidRoaster: table = {["Enabled"] = false}
    local Mode: table = {["Value"] = "Custom"}
    local delay: table = {["Value"] = 3.3}
    SkidRoaster = vape.Categories.Utility:CreateModule({
        ["Name"] = "🤡",
        ["Function"] = function(callback: boolean): void
            if callback then
                task.spawn(function()
                    repeat
                        if Mode["Value"] == "Custom" then
                            notif("Vape", #SkidPhrases.ListEnabled > 0 and SkidPhrases.ListEnabled[math.random(1, #SkidPhrases.ListEnabled)] or "Voidware still pasting in 2025 be like 💀🤡", delay["Value"], 'warning')
                            task.wait(delay["Value"])
                        else
                            notif("Vape", "Snoopy more like shitnoopy!", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Skidding = NN", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Moon on top!", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Snoopy + Grass = skids", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Pistonware? nah bro. Pisstonware", 3, 'warning')
                            task.wait(delay["Value"])
			    notif("Vape", "Piston loves underaged girls and boys", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Acronis = NN", 3)
                            task.wait(delay["Value"])
                            notif("Vape", "Vape private?? 💀🤡", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Mysticware? = Mysticshit", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Really bro? Tryna skid? KYS", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Imagine skidding and then call yourself a coder 🤡", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Ercho and Abyss still pasting in 2026 💀", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "How to not get doxxed? Don't be like Snoopy please...", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Complexware?? Simpleware and Skiddedware", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "Remember, Skid Client and Nebulaware are shit.", 3, 'warning')
                            task.wait(delay["Value"])
			    notif("Vape", "Keep pasting cocosploit/Aurora.", 3, 'warning')
                            task.wait(delay["Value"])
			    notif("Vape", "Voidware = garbage paste made by autistic child", 3, 'warning')
                            task.wait(delay["Value"])
                            notif("Vape", "W Zenith, W null.wtf, W blanked", 3, 'warning')
                            task.wait(delay["Value"])
			    notif("Vape", "Packet on top fellas, discord.gg/packet", 3, 'warning')
                            task.wait(delay["Value"])
			    notif("Vape", "Velocity & Night on top RAH", 3, 'warning')
                            task.wait(delay["Value"])
                        end;
                    until not SkidRoaster["Enabled"];
                end);
            end;
        end,
        HoverText = "Roasts skids",
    })
    Mode = SkidRoaster:CreateDropdown({
        ["Name"] = "Mode",
        ["List"] = {"Custom", "Copium"},
        ["Function"] = function() end
    })
    SkidPhrases = SkidRoaster:CreateTextList({
        ["Name"] = "Phrases",
        ["TempText"] = "SkidRoaster Phrases",
    })
    delay = SkidRoaster:CreateSlider({
        ["Name"] = "Delay",
        ["Min"] = 2,
        ["Max"] = 5,
        ["Default"] = 2,
        ["Function"] = function() end
    })
end)

-- credits: Render
velo.run(function()
	local ChatMimic: table = {["Enabled"] = true}
	local ChatShowSender: table = {["Enabled"] = true}
	local customblocklist: table = {}
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
				table.insert(ChatMimic.Connections, vapeStore.MessageReceived.Event:Connect(function(plr, text)
					task.wait();
					if plr == lplr or lastsent[plr] and lastsent[plr] > tick() then 
						return ;
					end;
					text = text:gsub('/bedwars', '/tptolobby');
					text = text:gsub('/lobby', '/tptolobby');
					local begin: any = (ChatShowSender["Enabled"] and '['..plr.DisplayName..']: ' or '');
					messages[plr] = (messages[plr] or {})
					if table.find(messages[plr], text) then 
						return;
					end;
					for i,v in blacklisted do 
						if text:lower():find(v) then 
							return;
						end;
					end;
					for i: any, v: any in next, ({'hack', 'exploit'}) do 
						if text:lower():find(v) and (text:lower():find('i\'m') or text:lower():find('me') or text:lower():find('i am')) then
							return;
						end;
					end;
					for i: any, v: any in next, customblocklist.ListEnabled or {} do
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
	})
	ChatShowSender = ChatMimic:CreateToggle({
		["Name"] = 'Show Sender',
		["Default"] = true,
		["Function"] = function() end
	})
	customblocklist = ChatMimic:CreateTextList({
		["Name"] = 'Blacklisted',
		["TempText"] = 'Blacklisted Characters'
	})
end)

velo.run(function()
	local playerattach: table = {["Enabled"] = false};
	local playerattachrange: table = {["Value"] = 50}
	local playerattachpersist: table = {};
	local playerattachplayers: table = {};
	playerattach = vape.Categories.Velocity:CreateModule({
		["Name"] = 'PlayerAttach',
		["HoverText"] = 'Attach to players',
		["Function"] = function(callback: boolean): void
			if callback then 
				local plrs: any = entitylib.AllPosition({
					Range = playerattachrange.Value,
					Wallcheck = playerattachplayers.Walls["Enabled"] or nil,
					Part = 'RootPart',
					Players = playerattachplayers.Players["Enabled"],
					NPCs = playerattachplayers.NPCs["Enabled"]
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
						task.wait(0.1)
						if not entitylib.isAlive and not lplr.Character then 
							return;
						end;
						if targetEntity and targetEntity.RootPart then
							lplr.Character.PrimaryPart.CFrame = targetEntity.RootPart.CFrame;
						else
							return;
						end;
					until not playerattach["Enabled"];
				end);
			end;
		end;
	})
	playerattachrange = playerattach:CreateSlider({
		["Name"] = "Range",
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 50,
		["Function"] = function(val)
			playerattachrange["Value"] = val;
		end;
	})
	playerattachpersist = playerattach:CreateToggle({
		["Name"] = "Persist",
		["Default"] = false,
		["Function"] = function(val)
			playerattachpersist["Enabled"] = val;
		end;
	})
	playerattachplayers = playerattach:CreateTargets({
		["Players"] = true, 
		["NPCs"] = true
	});
end)

velo.run(function()
    	local AirJump: table = {["Enabled"] = false}
	local Mode: table = {["Value"] = "State"}
	local Power: table = {["Value"] = 50}
	AirJump = vape.Categories.Velocity:CreateModule({
		["Name"] = "AirJump",
        	["HoverText"] = HoverText("Let's you jump in the air."),
		["Function"] = function(callback: boolean): void
			if callback then
				local connection: any = inputService["JumpRequest"]:Connect(function()
					if Mode["Value"] == "State" then
						lplr["Character"]["Humanoid"]:ChangeState("Jumping")
					else
						lplr["Character"]["HumanoidRootPart"]["Velocity"] += Vec3(0, Power["Value"], 0)
					end
				end)
                		AirJump["Connection"] = connection
			else
               			 if AirJump["Connection"] then
                    			AirJump["Connection"]:Disconnect()
                    			AirJump["Connection"] = nil
                		end
			end
		end,
        	["Default"] = false,
        	["ExtraText"] = function()
            		return Mode["Value"]
        	end
	})
	Mode = AirJump:CreateDropdown({
		["Name"] = "Mode",
		["List"] = {
			"State",
			"Velocity"
		},
		["Default"] = "State",
		["HoverText"] = HoverText("Mode to customize the jumping ability."),
		["Function"] = function() end
	})
	Power = AirJump:CreateSlider({
		["Name"] = "Power",
		["Min"] = 1,
		["Max"] = 100,
		["HoverText"] = HoverText("Power to boost the velocity."),
		["Function"] = function() end,
		["Default"] = 50
	})
end)

velo.run(function()
	local Loader: table = {["Enabled"] = false}
        local Font: table = {["Value"] = "FredokaOne"}
	local Color: table = {
		["Hue"] = 0,
		["Sat"] = 0,
	        ["Value"] = 0
	}
	local Size: table = {["Value"] = 10}
	local Chat: table = {["Enabled"] = true}
	local Vape: table = {["Enabled"] = true}
	local function Round(number: number): number
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
                    			local Time = string.format("%.1f", Round(tick() - LoadTime))
					local message: string? = "[Velocity] [" .. VelocityVersion .. "]:\n- Loaded in " .. Time .. " seconds.\n- Logged in as " .. lplr["Name"] .. "."
					if Chat["Enabled"] then
					    if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						local config: any = textChatService.ChatInputBarConfiguration
						local targetChannel: any = config and config.TargetTextChannel
						if targetChannel and targetChannel:IsA("TextChannel") then
							local color: any = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"])
							local r: any, g: any, b: any = color.R * 255, color.G * 255, color.B * 255
							local coloredMessage: string? = string.format(
								'<font color="rgb(%d,%d,%d)">%s</font>',
								r, g, b, message
							);
							targetChannel:DisplaySystemMessage(coloredMessage);
						end;
					    else
					        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
					            Text = message,
					            Color = Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]),
					            Font = Enum.Font[Font["Value"]],
					            TextSize = Size["Value"]
					        });
					    end;
					end;                            
				        task.wait()
			                if Vape["Enabled"] then
			                 	notif("[Velocity] [" .. VelocityVersion .. "]", "Loaded in " .. Time .. " seconds. Logged in as " .. lplr["Name"] .. ".", 5, 'warning')
			                end;
				end);
			end;
		end,
	})
    	Font = Loader:CreateDropdown({
		["Name"] = "Font",
		["List"] = GetItems("Font"),
		["HoverText"] = HoverText("Font of the text."),
		["Function"] = function()
			if Loader["Enabled"] then
				Loader:Toggle();
				Loader:Toggle();
			end;
		end;
	})
	Color = Loader:CreateColorSlider({
		["Name"] = "Color",
		["HoverText"] = HoverText("Color of the text."),
		["Function"] = function() end
	})
        Size = Loader:CreateTextBox({
	        ["Name"] = "Size",
	        ["TempText"] = "Size",
	        ["HoverText"] = HoverText("Size of the text."),
	        ["Function"] = function(callback: boolean): void 
	                if callback and Loader["Enabled"] then 
				Loader:Toggle();
				Loader:Toggle();
	                end;
                end;
        })
	Chat = Loader:CreateToggle({
		["Name"] = "Chat",
		["HoverText"] = HoverText("Sends a notification via chat."),
		["Function"] = function() end,
		["Default"] = true
	})
    	Vape = Loader:CreateToggle({
		["Name"] = "Vape",
		["HoverText"] = HoverText("Sends a notification via vape."),
		["Function"] = function() end,
		["Default"] = true
	})
end)

velo.run(function()
    	local boost_jump: table = {["Enabled"] = false};
	local boost_jump_m: table = {["Value"] = 'Toggle'};
	local boost_jump_b: table = {["Value"] = 'Velocity'};
	local boost_jump_vb: table = {["Value"] = 600};
	local boost_jump_cf: table = {["Value"] = 1000};
	local boost_jump_twb: table = {["Value"] = 1000};
	local boost_jump_twd: table = {["Value"] = 4};
	local boost_jump_k: table = {["Value"] = 7};
	local boost_jump_r: table = {["Value"] = 300};
	local boost_jump_s: table = {["Enabled"] = true};
	boost_jump = vape.Categories.Velocity:CreateModule({
		["Name"] ='BoostJump',
        	["HoverText"] = 'Boosts you high up in the air.',
		["Function"] = function(callback: boolean): void
			if callback then
				local bj = {};
				bj.__index = bj;
				function bj.n(v : Number, c : Number, t : Number, d : Number, r : Number, k : Number, b : Number, m : Number, h : Boolean, l : Boolean, z : Number)
					local self = setmetatable({}, bj);
					self.v = v;
					self.c = c;
					self.t = t;
					self.d = d;
					self.r = r;
					self.k = k;
					self.b = b;
					self.m = m;
					self.h = h;
					self.l = l;
					self.z = z;
					return self;
				end;
				function bj:s()
					local v = self.v;
					local c = self.c;
					local t = self.t;
					local d = self.d;
					local r = self.r;
					local k = self.k;
					local b = self.b;
					local m = self.m;
					local z = self.z;
					local h = self.h;
					local l = self.l;
					local bj_meta = {
						__index = function(self, x)
							if x == 'on' then
								return function()
									task.spawn(function()
										if m == 'Toggle' then
											if b == 'Velocity' then
												entitylib.character.HumanoidRootPart.Velocity += Vec3(z, v, z);
												notif("BoostJump", "Boosted " .. v .. " studs in the air.", 3)
												boost_jump:Toggle(l);
											elseif b == 'CFrame' then
												entitylib.character.HumanoidRootPart.CFrame += Vec3(z, c, z);
												notif("BoostJump", "Teleported " .. c .. " studs in the air.", 3)
												boost_jump:Toggle(l);
											else
												tweenService:Create(entitylib.character.HumanoidRootPart, TweenInfo.new(d), {
													CFrame = entitylib.character.HumanoidRootPart.CFrame + Vec3(z, t, z)
												}):Play();
												notif("BoostJump", "Tweened " .. t .. " studs in the air.", 3)
												boost_jump:Toggle(l);
											end;
										else
											repeat
												if b == 'Velocity' then
													entitylib.character.HumanoidRootPart.Velocity += Vec3(z, h and v - r or v, z);
												elseif b == 'CFrame' then
													entitylib.character.HumanoidRootPart.CFrame += Vec3(z, h and c - r or c, z);
												else
													tweenService:Create(entitylib.character.HumanoidRootPart, TweenInfo.new(d), {
														CFrame = entitylib.character.HumanoidRootPart.CFrame + Vec3(z, h and t - r or t, z)
													}):Play();
												end;
												task.wait(k);
											until not boost_jump["Enabled"];
										end;
									end);
								end;
							end;
						end;
					};
					local bj_val = setmetatable({}, bj_meta);
					bj_val:on();
				end;
				local new_bj = bj.n(
					boost_jump_vb["Value"],
					boost_jump_cf["Value"],
					boost_jump_twb["Value"],
					boost_jump_twd["Value"] / 10,
					boost_jump_r["Value"],
					boost_jump_k["Value"] / 10,
					boost_jump_b["Value"],
					boost_jump_m["Value"],
					boost_jump_s["Enabled"],
					false, 0
				);
				new_bj:s();
			end
		end,
        	["Default"] =false,
        	["ExtraText"] = function()
            		return boost_jump_m["Value"];
        	end;
	})
	boost_jump_m = boost_jump:CreateDropdown({
		["Name"] ='Repeat',
		["List"] = {
			'Toggle',
			'Keep'
		},
		["Default"] ='Toggle',
		["HoverText"] = 'Mode to keep the module on while boosting.',
		["Function"] = function() end
	})
	boost_jump_b = boost_jump:CreateDropdown({
		["Name"] ='Boost',
		["List"] = {
			'Velocity',
			'CFrame',
			'Tween'
		},
		["Default"] ='Velocity',
		["HoverText"] = 'Mode to get boosted in the air.',
		["Function"] = function() end
	})
	boost_jump_vb = boost_jump:CreateSlider({
		["Name"] ='Velocity Boost',
		["Min"] =1,
		["Max"] =600,
		["HoverText"] = 'Amount of velocity to boost your character.',
		["Function"] = function() end,
		["Default"] =600
	})
	boost_jump_cf = boost_jump:CreateSlider({
		["Name"] ='CFrame Boost',
		["Min"] =1,
		["Max"] =1000,
		["HoverText"] = 'Amount of cframe to boost your character.',
		["Function"] = function() end,
		["Default"] =1000
	})
	boost_jump_twb = boost_jump:CreateSlider({
		["Name"] ='Tween Boost',
		["Min"] =1,
		["Max"] =1500,
		["HoverText"] = 'Position to end the tween.',
		["Function"] = function() end,
		["Default"] =1000
	})
	boost_jump_twd = boost_jump:CreateSlider({
		["Name"] ='Tween Duration',
		["Min"] =1,
		["Max"] =10,
		["HoverText"] = 'Duration of the tweening that boosts your character.',
		["Function"] = function() end,
		["Default"] =4
	})
	boost_jump_k = boost_jump:CreateSlider({
		["Name"] ='Keep Delay',
		["Min"] =1,
		["Max"] =15,
		["HoverText"] = 'Delay to reboost when using \'Keep\' mode.',
		["Function"] = function() end,
		["Default"] =7
	})
	boost_jump_r = boost_jump:CreateSlider({
		["Name"] ='Reduce',
		["Min"] =1,
		["Max"] =400,
		["HoverText"] = 'Amount to reduce the boost power when using \'Keep\' mode.',
		["Function"] = function() end,
		["Default"] =300
	})
	boost_jump_s = boost_jump:CreateToggle({
		["Name"] ='Safe',
		["HoverText"] = 'Reduces the boost power when using \'Keep\' mode.',
		["Function"] = function() end,
		["Default"] =true
	})
end)

velo.run(function()
	local CustomCursor: table = {["Enabled"] = false}
	local Icon: table = {["Value"] = "Triangle"}
    	local Image: table = {["Value"] = ""}
	local Custom: table = {["Enabled"] = false}
    	local Old: table = {
		["CS:GO"] = "rbxassetid://14789879068",
		["Old Roblox"] = "rbxassetid://13546344315",
		["dx9ware"] = "rbxassetid://12233942144",
		["Aimbot"] = "rbxassetid://8680062686",
		["Triangle"] = "rbxassetid://14790304072",
		["Crosshair"] = "rbxassetid://9943168532",
		["Arrow"] = "rbxassetid://14790316561"
	}
	CustomCursor = vape.Categories.Velocity:CreateModule({
		["Name"] = "CustomCursor",
		["HoverText"] = HoverText("Modifies your cursor's image."),
		["Function"] = function(callback: boolean): void
			if callback then
				task.spawn(function()
					repeat
						if Custom["Enabled"] then
							inputService["MouseIcon"] = "rbxassetid://" .. Image["Value"]
						else
							inputService["MouseIcon"] = Old[Icon["Value"]]
						end
                        			task.wait(0)
					until not CustomCursor["Enabled"]
				end)
			else
				inputService["MouseIcon"] = ""
				task.wait()
				inputService["MouseIcon"] = ""
			end
		end
	})
	Icon = CustomCursor:CreateDropdown({
		["Name"] = "Icon",
		["List"] = {
	            "CS:GO",
	            "Old Roblox",
	            "dx9ware",
	            "Aimbot",
	            "Triangle",
		    "Crosshair",
	            "Arrow"
	        },
        	["Default"] = "Triangle",
        	["HoverText"] = HoverText("Icon to replace your cursor."),
		["Function"] = function() end
	})
    	Image = CustomCursor:CreateTextBox({
		["Name"] = "Image ID",
		["TempText"] = "Image ID",
        	["HoverText"] = HoverText("Custom Image ID for your cursor."),
		["FocusLost"] = function(enter) 
			if CustomCursor["Enabled"] then 
				CustomCursor["ToggleButton"]()
				CustomCursor["ToggleButton"]()
			end
		end
	})
	Custom = CustomCursor:CreateToggle({
		["Name"] = "Custom Icon",
        	["HoverText"] = HoverText("Let's you insert a custom Image ID."),
		["Function"] = function() end,
        	["Default"] = false
	})
end)

velo.run(function()
	local ZoomUnlocker: table = {["Enabled"] = false}
	local ZoomUnlockerMode: table = {["Value"] = 'Infinite'}
	local ZoomUnlockerZoom: table = {["Value"] = 500}
	local ZoomConnection, OldZoom = nil, nil
	ZoomUnlocker = vape.Categories.Velocity:CreateModule({
		["Name"] ='ZoomUnlocker',
        	["HoverText"] = 'Unlocks the abillity to zoom more.',
		["Function"] = function(callback: boolean): void
			if callback then
				OldZoom = lplr["CameraMaxZoomDistance"]
				ZoomUnlocker = runService.Heartbeat:Connect(function()
					if ZoomUnlockerMode["Value"] == 'Infinite' then
						lplr["CameraMaxZoomDistance"] = 9e9
					else
						lplr["CameraMaxZoomDistance"] = ZoomUnlockerZoom["Value"]
					end
				end)
			else
				if ZoomUnlocker then ZoomUnlocker:Disconnect() end
				lplr["CameraMaxZoomDistance"] = OldZoom
				OldZoom = nil
			end
		end,
        	["Default"] =false,
		["ExtraText"] = function()
            		return ZoomUnlockerMode["Value"]
        	end
	})
	ZoomUnlockerMode = ZoomUnlocker:CreateDropdown({
		["Name"] ='Mode',
		["List"] = {
			'Infinite',
			'Custom'
		},
		["HoverText"] = 'Mode to unlock the zoom.',
		["Value"] = 'Infinite',
		["Function"] = function() end
	})
	ZoomUnlockerZoom = ZoomUnlocker:CreateSlider({
		["Name"] ='Zoom',
		["Min"] =13,
		["Max"] =1000,
		["HoverText"] = 'Amount to unlock the zoom.',
		["Function"] = function() end,
		["Default"] =500
	})
end)

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
						loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
					end);
				elseif Script["Value"] == "InfiniteYield" then
					task.spawn(function()
						loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() 
					end);
				end;
				ScriptHub:Toggle();
			end;
		end;
	})
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
end)

velo.run(function()
	local GameWeather: table = {["Enabled"] = false}
	local GameWeatherMode: table = {["Value"] = "Snow"}
	local SnowflakesSpread: table = {["Value"] = 35}
	local SnowflakesRate: table = {["Value"] = 28}
	local SnowflakesHigh: table = {["Value"] = 100}
	GameWeather = vape.Categories.Velocity:CreateModule({
		["Name"] ='GameWeather',
		["HoverText"] = 'Changes the weather.',
		["Function"] = function(callback: boolean): void 
			if callback then
				task.spawn(function()
					if game_weather_m["Value"] == 'Snow' then
						-- vape gametheme code
						local snowpart = Instance.new("Part")
						snowpart.Size = Vector3.new(240,0.5,240)
						snowpart.Name ="SnowParticle"
						snowpart.Transparency = 1
						snowpart.CanCollide = false
						snowpart.Position = Vector3.new(0,120,286)
						snowpart.Anchored = true
						snowpart.Parent = workspace
						local snow: ParticleEmitter = Instance.new("ParticleEmitter")
						snow.RotSpeed = NumberRange.new(300)
						snow.VelocitySpread = SnowflakesSpread["Value"]
						snow.Rate = SnowflakesRate["Value"]
						snow.Texture = "rbxassetid://8158344433"
						snow.Rotation = NumberRange.new(110)
						snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
						snow.Lifetime = NumberRange.new(8,14)
						snow.Speed = NumberRange.new(8,18)
						snow.EmissionDirection = Enum.NormalId.Bottom
						snow.SpreadAngle = Vector2.new(35,35)
						snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
						snow.Parent = snowpart
						local windsnow = Instance.new("ParticleEmitter")
						windsnow.Acceleration = Vector3.new(0,0,1)
						windsnow.RotSpeed = NumberRange.new(100)
						windsnow.VelocitySpread = SnowflakesSpread["Value"]
						windsnow.Rate = SnowflakesRate["Value"]
						windsnow.Texture = "rbxassetid://8158344433"
						windsnow.EmissionDirection = Enum.NormalId.Bottom
						windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
						windsnow.Lifetime = NumberRange.new(8,14)
						windsnow.Speed = NumberRange.new(8,18)
						windsnow.Rotation = NumberRange.new(110)
						windsnow.SpreadAngle = Vector2.new(35,35)
						windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
						windsnow.Parent = snowpart
						repeat task.wait(0)
							if entitylib.isAlive then 
								snowpart.Position = entitylib.character.HumanoidRootPart.Position + Vec3(0, SnowflakesHigh.Value, 0)
							end
						until not vapeInjected
					else
						-- creds to AntiMonacoGang
						repeat task.wait(0)
							local Player = game:GetService('Players').LocalPlayer
							local Camera = workspace.CurrentCamera
							repeat wait() until Player.Character ~= nil
							local Torso = Player.Character:WaitForChild("UpperTorso")
							local RainSound = Instance.new("Sound", Camera)
							RainSound.SoundId = "http://www.roblox.com/asset/?ID=236148388"
							RainSound.Looped = true
							RainSound:Play()
							function Particle(cframe)
								local Spread = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
								local Part = Instance.new("Part", Camera)
								local Smoke = Instance.new("Smoke", Part)
								Part.CanCollide = false
								Part.Transparency = 0.25
								Part.Reflectance = 0.15
								Smoke.RiseVelocity = -25
								Smoke.Opacity = 0.25
								Smoke.Size = 25
								Part.BrickColor = BrickColor.new("Steel blue")
								Part.FormFactor = Enum.FormFactor.Custom
								Part.Size = Vector3.new(0.15, 2, 0.15)
								Part.CFrame = CFrame.new(cframe.p + (cframe:vectorToWorldSpace(Vector3.new(0, 1, 0)).unit * 150) + Spread) * CFrame.Angles(0, math.atan2(cframe.p.X, cframe.p.Z) + math.pi, 0)
								game:GetService("Debris"):AddItem(Part, 3)
								Instance.new("BlockMesh", Part)
								Part.Touched:Connect(function(Hit)
									Part:Destroy()
								end)
							end
							function Roof(cframe)
								return workspace:FindPartOnRayWithIgnoreList(Ray.new(cframe.p, cframe.p * Vector3.new(0, 150, 0)), {Player.Character})
							end
							-- if Camera ~= nil and Torso ~= nil then
								if Roof(Torso.CFrame) == nil then
									for _ = 1, 5 do
										if (Camera.CFrame.p - Torso.CFrame.p).Magnitude > 100 then
											Particle(Camera.CFrame)
											Particle(Torso.CFrame)
										else
											Particle(Torso.CFrame)
										end
									end
									RainSound.Volume = 0.05
								else
									RainSound.Volume = 0.05
									if Roof(Camera.CFrame) == nil then
										for _ = 1, 5 do
											Particle(Camera.CFrame)
										end
									end
								end
								RainSound:Destroy()
							-- end
						until (not GameWeather["Enabled"])
					end
				end)
			else
				for _, v in next, workspace:GetChildren() do
					if v.Name == "SnowParticle" then
						v:Remove()
					end
				end
			end
		end
	})
	game_weather_m = GameWeather:CreateDropdown({
		["Name"] ='Mode',
		["List"] = {
			'Snow',
			'Rain'
		},
		["Default"] ='Snow',
		["HoverText"] = 'Mode to change the weather.',
		["Function"] = function() end;
	});
	SnowflakesSpread = GameWeather:CreateSlider({
		["Name"] ="Snow Spread",
		["Min"] =1,
		["Max"] =100,
		["Function"] = function() end,
		["Default"] =35
	})
	SnowflakesRate = GameWeather:CreateSlider({
		["Name"] ="Snow Rate",
		["Min"] =1,
		["Max"] =100,
		["Function"] = function() end,
		["Default"] =28
	})
	SnowflakesHigh = GameWeather:CreateSlider({
		["Name"] ="Snow High",
		["Min"] =1,
		["Max"] =200,
		["Function"] = function() end,
		["Default"] =100
	})
end)

velo.run(function()
	local WaterMark: table = {["Enabled"] = false}
	local WaterMarkBGT: table = {["Value"] = 1}
	local WaterMarkZI: table = {["Value"] = 10}
	local WaterMarkPOS: table = {["Value"] = 36}
	local WaterMarkTST: table = {["Value"] = 0}
    	local WaterMarkFont: table = {["Value"] = Enum.Font.SourceSansBold}
	local WaterMarkColor: table = {["Hue"] = 1, ["Sat"] = 1, ["Value"] = 0.55}
	local ScreenGui: ScreenGui = Instance.new("ScreenGui")
	local TextLabel: TextLabel = Instance.new("TextLabel")
	local UICorner: UICorner = Instance.new("UICorner")
	ScreenGui.Parent = lplr:WaitForChild("PlayerGui")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	TextLabel.Parent = ScreenGui
	TextLabel.Size = UDim2.new(1, 0, 0, 36)
	TextLabel.BackgroundTransparency = WaterMarkBGT["Value"]
	TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.ZIndex = WaterMarkZI["Value"]
	TextLabel.TextStrokeTransparency = WaterMarkTST["Value"]
	TextLabel.TextScaled = true
	TextLabel.Font = WaterMarkFont["Value"]
	TextLabel.TextColor3 = Color3.fromHSV(WaterMarkColor["Hue"], WaterMarkColor["Sat"], WaterMarkColor["Value"])
	TextLabel.Position = UDim2.new(0, 0, 0, -WaterMarkPOS["Value"])
	UICorner.Parent = TextLabel
	UICorner.CornerRadius = UDim.new(0, 10)
	WaterMark = vape.Categories.Velocity:CreateModule({
		["Name"] ="TextMark",
		["Function"] = function(callback: boolean): void
			if callback then
				TextLabel.Text = "Velocity [V1.0]"
                TextLabel.Font = WaterMarkFont["Value"]
			else
				TextLabel.Text = ""
                TextLabel.Font = WaterMarkFont["Value"]
			end
		end
	})
    	WaterMarkFont = WaterMark:CreateDropdown({
		["Name"] ="Font",
		["List"] = GetItems("Font"),
		["HoverText"] = "Font of the text.",
		["Function"] = function()
			if WaterMark["Enabled"] then
				WaterMark:Toggle();
				WaterMark:Toggle();
			end
		end
	})
	WaterMarkColor = WaterMark:CreateColorSlider({
		["Name"] ="Color",
		["Function"] = function() 
			if TextLabel then
				TextLabel.TextColor3 = Color3.fromHSV(WaterMarkColor["Hue"], WaterMarkColor["Sat"], WaterMarkColor["Value"])
			end
		end
	})
	WaterMarkPOS = WaterMark:CreateSlider({
		["Name"] ="Position",
		["Min"] =1,
		["Max"] =45, 
		["Function"] = function(val) end,
		["Default"] =36
	})
	WaterMarkBGT = WaterMark:CreateSlider({
		["Name"] ="Background Transparency",
		["Min"] =0,
		["Max"] =1, 
		["Function"] = function(val) end,
		["Default"] =1
	})
	WaterMarkTST = WaterMark:CreateSlider({
		["Name"] ="Stroke Transparency",
		["Min"] =0,
		["Max"] =1, 
		["Function"] = function(val) end,
		["Default"] =0
	})
	WaterMarkZI = WaterMark:CreateSlider({
		["Name"] ="ZIndex",
		["Min"] =7,
		["Max"] =15, 
		["Function"] = function(val) end,
		["Default"] =10
	})
end)

velo.run(function()
	local instaprompt: table = {
		Enabled = false,
		Connections = {}
	};
	instaprompt = vape.Categories.Velocity:CreateModule({
		["Name"] = 'InstantInteract',
		["Function"] = function(callback: boolean): void
			if callback then
				table.insert(instaprompt.Connections, proximitypromptService.PromptButtonHoldBegan:Connect(function(prompt)
					fireproximityprompt(prompt);
				end));
			end;
		end;
	});
end)

velo.run(function()
    local og: table = {}                                                        
    local function default()
        og = {
            Brightness = lightingService.Brightness,
            ColorShift_Top = lightingService.ColorShift_Top,
            ColorShift_Bottom = lightingService.ColorShift_Bottom,
            OutdoorAmbient = lightingService.OutdoorAmbient,
            ClockTime = lightingService.ClockTime,
            FogColor = lightingService.FogColor,
            FogStart = lightingService.FogStart,
            FogEnd = lightingService.FogEnd,
            ExposureCompensation = lightingService.ExposureCompensation,
            ShadowSoftness = lightingService.ShadowSoftness,
            Ambient = lightingService.Ambient
        }
    end;
    local Luminescents: table = {["Enabled"] = false};
    local Blurs: any;
    local ColorCorrectionEffect: any;
    local SkyColor: table = {["Value"] = 1};
    local light: any;
    local on: boolean = false;
	Luminescents = vape.Legit:CreateModule({
		["Name"] = 'Luminescents',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat task.wait() until game:IsLoaded()
                Blurs = Instance.new("BlurEffect");
                Blurs.Parent = lightingService;
                Blurs.Size = 5;
                ColorCorrectionEffect = Instance.new("ColorCorrectionEffect");
                ColorCorrectionEffect.Parent = lightingService;
                ColorCorrectionEffect.Saturation = -0.2;
                ColorCorrectionEffect.TintColor = Color3.fromRGB(255, 224, 219);
                lightingService.ClockTime = 8.7;
                lightingService.FogEnd = 1000;
                lightingService.FogStart = 0;
                lightingService.ExposureCompensation = 0.30;
                lightingService.ShadowSoftness = 0;
                lightingService.Ambient = Color3.fromRGB(59, 33, 27);
                lightingService.ColorShift_Bottom = Color3.fromHSV(SkyColor["Hue"], SkyColor["Sat"], SkyColor["Value"]);
                lightingService.ColorShift_Top = Color3.fromHSV(SkyColor["Hue"], SkyColor["Sat"], SkyColor["Value"]);
                lightingService.OutdoorAmbient = Color3.fromHSV(SkyColor["Hue"], SkyColor["Sat"], SkyColor["Value"]);
                lightingService.FogColor = Color3.fromHSV(SkyColor["Hue"], SkyColor["Sat"], SkyColor["Value"]);
            else
                if ColorCorrectionEffect and ColorCorrectionEffect.Parent then 
                    ColorCorrectionEffect:Destroy();
                end;
                if Blurs and Blurs.Parent then 
                    Blurs:Destroy();
                end;
                for k, v in pairs(og) do
                    lightingService[k] = v;
                end;
            end;
        end;
    })
    SkyColor = Luminescents:CreateColorSlider({
        ["Name"] ='Color',
        ["Function"] = function(hue, sat, val)
            if light then
                lightingService.ColorShift_Bottom = Color3.fromHSV(SkyColor["Hue"], SkyColor["Sat"], SkyColor["Value"]);
                lightingService.ColorShift_Top = Color3.fromHSV(SkyColor["Hue"], SkyColor["Sat"], SkyColor["Value"]);
                lightingService.OutdoorAmbient = Color3.fromHSV(SkyColor["Hue"], SkyColor["Sat"], SkyColor["Value"]);
                lightingService.FogColor = Color3.fromHSV(SkyColor["Hue"], SkyColor["Sat"], SkyColor["Value"]);
            end;
        end;
    })
end)

local synapsev3: string = syn and syn.toast_notification and "V3" or "";
velo.run(function()
	local AutoReport: table = {["Enabled"] = false}
	local AutoReportList: any = {}
	local AutoReportNotify: table = {["Enabled"] = false}
	local alreadyreported: table = {}
	local removerepeat = function(str: string?)
		local new: string = ""
		local last: string = ""
		for _: any, v: string? in next, str:split("") do
			if v ~= last then new ..= v last = v; end;
		end;
		return new;
	end;
	local reporttable: table = {
		gay = "Bullying", gae = "Bullying", gey = "Bullying",
		hack = "Scamming", exploit = "Scamming", cheat = "Scamming",
		hecker = "Scamming", haxker = "Scamming", hacer = "Scamming",
		report = "Bullying", fat = "Bullying", black = "Bullying",
		getalife = "Bullying", fatherless = "Bullying", fk = "Bullying",
		disco = "Offsite Links", yt = "Offsite Links", dizcourde = "Offsite Links",
		retard = "Swearing", bad = "Bullying", trash = "Bullying", nolife = "Bullying",
		negar = "Bullying", loser = "Bullying", killyour = "Bullying", kys = "Bullying",
		hacktowin = "Bullying", bozo = "Bullying", kid = "Bullying", adopted = "Bullying",
		linlife = "Bullying", commitnotalive = "Bullying", vape = "Offsite Links",
		futureclient = "Offsite Links", download = "Offsite Links", youtube = "Offsite Links",
		die = "Bullying", lobby = "Bullying", ban = "Bullying", wizard = "Bullying",
		wisard = "Bullying", witch = "Bullying", magic = "Bullying"
	};
	local reporttableexact: table = {
		L = "Bullying",
	};
	local function findreport(msg: string?)
		local str: string = removerepeat((msg or ""):gsub("%W+", ""):lower());
		for w, r in next, reporttable do
			if str:find(w) then return r, w end;
		end;
		for w, r in next, reporttableexact do
			if str == w then return r, w end;
		end;
		if AutoReportList.ListEnabled then
			for _, w in next, AutoReportList.ListEnabled do
				if str:find(w) then return "Bullying", w; end;
			end;
		end;
		return nil;
	end;
    local function handlechat(plr: Player?, msg: string?)
		if plr and plr ~= lplr and whitelist:get(plr) == 0 then
			local reason: string?, match: any = findreport(msg);
			if reason and not alreadyreported[plr] then
				task.spawn(function()
					if not syn or reportplayer then
						if reportplayer then
							reportplayer(plr, reason, "he said a bad word");
						else
							playersService:ReportAbuse(plr, reason, "he said a bad word");
						end;
					end;
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
				table.insert(AutoReport.Connections, textChatService.MessageReceived:Connect(function(tab)
					if tab.TextSource then
						local plr: Player? = playersService:GetPlayerByUserId(tab.TextSource.UserId);
						handlechat(plr, tab.Text);
					end;
				end));
			elseif replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
				table.insert(AutoReport.Connections, replicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(tab)
					handlechat(playersService:FindFirstChild(tab.FromSpeaker), tab.Message);
				end));
			else
				notif("Vape", "Default chat not found.", 5)
				AutoReport:Toggle()
			end;
		end;
	})
	AutoReportNotify = AutoReport:CreateToggle({
		["Name"] = "Notify",
		["Function"] = function() end
	})
	AutoReportList = AutoReport:CreateTextList({
		["Name"] = "Report Words",
		["TempText"] = "phrase (to report)"
	});
end)	
	
