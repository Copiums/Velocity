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


local velo: table = {};
shared.nuker_range = 30;
shared.velocity_client = true;
local Vec2: Vector2 = Vector2.new;
local Vec3: Vector3 = Vector3.new;
local CFr: CFrame = CFrame.new;

local function HoverText(Text: string): void
	return Text .. " ";
end;

local queue_on_teleport: () -> () = queue_on_teleport or function() end
local cloneref: (obj: any) -> any = cloneref or function(obj)
    return obj;
end;

local playersService: Players = cloneref(game:GetService('Players'))
local replicatedStorage: ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService: RunService = cloneref(game:GetService('RunService'))
local inputService: InputService = cloneref(game:GetService('UserInputService'))
local tweenService: TweenService = cloneref(game:GetService('TweenService'))
local httpService: HttpService = cloneref(game:GetService('HttpService'))
local lightingService: Lighting = cloneref(game:GetService("Lighting"))
local textChatService: TextChatService = cloneref(game:GetService('TextChatService'))
local collectionService: CollectionService = cloneref(game:GetService('CollectionService'))
local workspace: Workspace = cloneref(game.GetService(game, "Workspace"));
local Debris: Debris = cloneref(game.GetService(game, 'Debris')); 
local contextActionService: ContextActionService = cloneref(game:GetService('ContextActionService'))
local coreGui: CoreGui = cloneref(game:GetService('CoreGui'))
local starterGui: StarterGui = cloneref(game:GetService('StarterGui'))
local vapeEvents: { [string]: BindableEvent } = setmetatable({}, {
    __index = function(self, index: any): BindableEvent
        self[index] = Instance.new("BindableEvent");
        return self[index];
    end;
});

local isnetworkowner: (part: Instance?) -> boolean = identifyexecutor and table.find({'AWP', 'Nihon'}, ({identifyexecutor()})[1]) and isnetworkowner or function()
	return true;
end;

local gameCamera: Camera = workspace.CurrentCamera;
local lplr: Player = playersService.LocalPlayer;
local assetfunction: any = getcustomasset;

local vape: table = shared.vape;
local entitylib: any = vape.Libraries.entity;
local targetinfo: any = vape.Libraries.targetinfo;
local sessioninfo: any = vape.Libraries.sessioninfo;
local uipallet: any = vape.Libraries.uipallet;
local tween: any = vape.Libraries.tween;
local color: any = vape.Libraries.color;
local whitelist: any = vape.Libraries.whitelist;
local prediction: any = vape.Libraries.prediction;
local getfontsize: any = vape.Libraries.getfontsize;
local getcustomasset: any = vape.Libraries.getcustomasset;

local cheatengine: boolean = false;
local store: table = {
	attackReach = 0,
	attackSpeed = .05,
	attackReachUpdate = tick(),
	damage = {},
	damageBlockFail = tick(),
	hand = {},
	inventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	inventories = {},
	matchState = 0,
	queueType = 'bedwars_test',
	tools = {},
	killaurainfo = nil,
	antifallpart = nil
};
local Reach: table = {};
local HitBoxes: table = {};
local InfiniteFly: table = {["Enabled"] = false};
local StoreDamage: any;
local TrapDisabler: any;
local AntiFallPart: any;
local vapeInjected: boolean = true;
local bedwars: table, remotes: table, sides: table, oldinvrender: table = {}, {}, {};
local synapsev3: string = syn and syn.toast_notification and "V3" or "";
local worldtoscreenpoint: (pos: Vector3) -> (Vector3, boolean) = function(pos: Vector3): (Vector3, boolean)
	if synapsev3 == "V3" then
		local scr: { Vector3 } = worldtoscreen({pos});
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0;
	end;
	return gameCamera.WorldToScreenPoint(gameCamera, pos);
end;
local run = function(func : Function)
	func();
end;

velo.run = function(x : Function)
	return x();
end;

local function isAlive(plr: Player): boolean
    local suc: boolean, res: boolean = pcall(function()
        plr = plr or lplr;
        return plr["Character"] and plr["Character"]["Humanoid"] and plr["Character"]["Humanoid"]["Health"] > 0;
    end);
    return suc and res or suc;
end;

local function GetItems(item: string): table
	local Items: table = {};
	for _, v in next, Enum[item]:GetEnumItems() do 
		table.insert(Items, v["Name"]) ;
	end;
	return Items;
end;

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

local function isVulnerable(plr: Player): boolean
	return plr.Humanoid.Health > 0 and not plr.Character:FindFirstChildWhichIsA("ForceField");
end;

local function collection(tags: {string} | string?, module: {Clean: (self: any) -> void}?, customadd: ((objs: table, v: Instance, tag: string) -> void)?, customremove: ((objs: table?, v: Instance?, tag: string?) -> void)?): (table, (self: any) -> void)
	tags = typeof(tags) ~= 'table' and {tags} or tags;
	local objs: table?, connections: table? = {}, {};
	for _, tag in tags do
		table.insert(connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			if customadd then
				customadd(objs, v, tag);
				return;
			end;
			table.insert(objs, v);
		end));
		table.insert(connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if customremove then
				customremove(objs, v, tag);
				return;
			end;
			v = table.find(objs, v);
			if v then
				table.remove(objs, v);
			end;
		end));

		for _, v in collectionService:GetTagged(tag) do
			if customadd then
				customadd(objs, v, tag);
				continue;
			end;
			table.insert(objs, v);
		end;
	end;

	local cleanFunc: ((self: any) -> void)? = function(self)
		for _, v in connections do
			v:Disconnect();
		end;
		table.clear(connections);
		table.clear(objs);
		table.clear(self);
	end;
	if module then
		module:Clean(cleanFunc);
	end;
	return objs, cleanFunc;
end;

local function getBestArmor(slot: any): any
	local closest: any, mag: number? = nil, 0;
	for _, item in store.inventory.inventory.items do
		local meta: any = item and bedwars.ItemMeta[item.itemType] or {};
		if meta.armor and meta.armor.slot == slot then
			local newmag: number = (meta.armor.damageReductionMultiplier or 0);
			if newmag > mag then
				closest, mag = item, newmag;
			end;
		end;
	end;
	return closest;
end;

local function getBow(): (any, number?) 
	local bestBow: any, bestBowSlot: number?, bestBowDamage: number = nil, nil, 0;
	for slot: number, item: any in store.inventory.inventory.items do
		local bowMeta: any = bedwars.ItemMeta[item.itemType].projectileSource;
		if bowMeta and table.find(bowMeta.ammoItemTypes, 'arrow') then
			local bowDamage: number = bedwars.ProjectileMeta[bowMeta.projectileType('arrow')].combat.damage or 0
			if bowDamage > bestBowDamage then
				bestBow, bestBowSlot, bestBowDamage = item, slot, bowDamage;
			end;
		end;
	end;
	return bestBow, bestBowSlot;
end;

local function getRoactRender(func: (any) -> any): () -> any
	return debug.getupvalue(debug.getupvalue(debug.getupvalue(func, 3).render, 2).render, 1);
end

local function getItem(itemName: string, inv: table?): (table?, number?)
	for slot: number, item: table in (inv or store.inventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot;
		end;
	end;
	return nil;
end;

local function getSword(): (any, number?) 
	local bestSword: any, bestSwordSlot: number?, bestSwordDamage: number = nil, nil, 0; 
	for slot: number, item: any in store.inventory.inventory.items do
		local swordMeta: any = bedwars.ItemMeta[item.itemType].sword;
		if swordMeta then
			local swordDamage: number = swordMeta.damage or 0;
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage;
            end; 
        end; 
    end; 
    return bestSword, bestSwordSlot; 
end;

local function getTool(breakType: string?): (any, number?)
	local bestTool: any, bestToolSlot: number?, bestToolDamage: number = nil, nil, 0
	for slot: number, item: any in store.inventory.inventory.items do
		local toolMeta: any = bedwars.ItemMeta[item.itemType].breakBlock;
		if toolMeta then
			local toolDamage: number = toolMeta[breakType] or 0;
			if toolDamage > bestToolDamage then
				bestTool, bestToolSlot, bestToolDamage = item, slot, toolDamage;
			end;
		end;
	end;
	return bestTool, bestToolSlot;
end;

local function getWool(): (any, any) 
	for _, wool in (inv or store.inventory.inventory.items) do
		if wool.itemType:find('wool') then
			return wool and wool.itemType, wool and wool.amount;
		end;
	end;
end;

local function getStrength(plr: Player): number
	if not plr.Player then
		return 0;
	end;
	local strength: number = 0
	for _, v in (store.inventories[plr.Player] or {items = {}}).items do
		local itemmeta: any = bedwars.ItemMeta[v.itemType];
		if itemmeta and itemmeta.sword and itemmeta.sword.damage > strength then
			strength = itemmeta.sword.damage;
		end;
	end;
	return strength;
end;

local function getPlacedBlock(pos: Vector3?): (table, Vector3?)
	if not pos then
		return;
	end;
	local roundedPosition: Vector3 = bedwars.BlockController:getBlockPosition(pos);
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition;
end;

local function getBlocksInPoints(s: Vector3?, e: Vector3?): {Vector3?}
	local blocks: any, list: table = bedwars.BlockController:getStore(), {}
	for x = s.X, e.X do
		for y = s.Y, e.Y do
			for z = s.Z, e.Z do
				local vec: Vector3 = Vector3.new(x, y, z);
				if blocks:getBlockAt(vec) then
					table.insert(list, vec * 3);
				end;
			end;
		end;
	end;
	return list;
end;

local function getShieldAttribute(char: Instance): number
	local returned: number = 0;
	for name: string, val: any in char:GetAttributes() do
		if name:find('Shield') and type(val) == 'number' and val > 0 then
			returned += val;
		end;
	end;
	return returned;
end;

local damagedata: table = {
	lastHit = tick(),
	Multi = 1,
};

local function getSpeed(): number
	local multi: number?, increase: boolean?, modifiers: any = 0, true, bedwars.SprintController:getMovementStatusModifier():getModifiers()
	for v in modifiers do
		local val: number = v.constantSpeedMultiplier and v.constantSpeedMultiplier or 0
		if val and val > math.max(multi, 1) then
			increase = false;
			multi = val - (0.06 * math.round(val));
		end;
	end;
	if cheatengine then
		for i: any, effect: any in lplr.PlayerGui.StatusEffectHudScreen.StatusEffectHud:GetChildren() do
			if effect.ClassName ~= "UIListLayout" and table.find({ "Speed Boost" }, effect.Name) then
				if effect.Name == "WindWalkerEffect" then
					local count: number? = tonumber(effect.EffectStack.Text)
					if count and count >= 1 then
						multi = multi + 1.3;
					end;
				else
					multi = multi + 0.16;
				end;
			end;
		end;
	end;	
	if damagedata.lastHit > tick() then
		multi += damagedata.Multi;
	end;	
	for v in modifiers do
		multi += math.max((v.moveSpeedMultiplier or 0) - 1, 0)
	end		
	if multi > 0 and increase then
		multi += 0.16 + (0.02 * math.round(multi));
	end;
	return 20 * (multi + 1);
end;

local function getTableSize(tab: {[any]: any}): number
    	local ind: number = 0;
    	for _ in tab do
        	ind += 1;
    	end;
    	return ind;
end;

local function hotbarSwitch(slot: number?): boolean
	if slot and store.inventory.hotbarSlot ~= slot then
		bedwars.Store:dispatch({
			type = 'InventorySelectHotbarSlot',
			slot = slot
		});
		vapeEvents.InventoryChanged.Event:Wait();
		return true;
	end;
	return false;
end;

local function isFriend(plr: Player, recolor: Boolean): boolean?
	if vape.Categories.Friends.Options['Use friends']["Enabled"] then
		local friend: any = table.find(vape.Categories.Friends.ListEnabled, plr["Name"]) and true;
		if recolor then
			friend = friend and vape.Categories.Friends.Options['Recolor visuals']["Enabled"];
		end;
		return friend;
	end;
	return nil;
end;

local function isTarget(plr: Player): boolean?
	return table.find(vape.Categories.Targets.ListEnabled, plr["Name"]) and true;
end;

local function notif(...: any): void
    return vape:CreateNotification(...);
end;

local function removeTags(str: string): string
	str = str:gsub('<br%s*/>', '\n');
	return (str:gsub('<[^<>]->', ''));
end;

local function roundPos(vec: Vector3?): Vector3?
	return Vector3.new(math.round(vec.X / 3) * 3, math.round(vec.Y / 3) * 3, math.round(vec.Z / 3) * 3);
end;

pcall(function()
	replicatedStorage.rbxts_include.node_modules['@rbxts'].net.out._NetManaged.SetInvItem = bedwars.Client:Get(remotes.EquipItem);
end);

local function switchItem(tool: any, delayTime: number): void
	delayTime = delayTime or 0.04;
	local check: any = lplr.Character and lplr.Character:FindFirstChild('HandInvItem') or nil;
	if check and check["Value"]~= tool and tool.Parent ~= nil then
		pcall(function()
			replicatedStorage.rbxts_include.node_modules['@rbxts'].net.out._NetManaged.SetInvItem:InvokeServer({hand = tool});
		end);
		task.spawn(function()
			bedwars.Client:Get(remotes.EquipItem):CallServerAsync({hand = tool});
		end);
		check["Value"]= tool;
		if delayTime > 0 then
			task.wait(delayTime);
		end;
		return true;
	end;
end;

local function waitForChildOfType(obj: Instance?, name: string?, timeout: number?, prop: boolean?): Instance?
	local check: number?, returned: any = tick() + timeout;
	repeat
		returned = prop and obj[name] or obj:FindFirstChildOfClass(name);
		if returned and returned.Name ~= 'UpperTorso' or check < tick() then
			break;
		end;
		task.wait();
	until false;
	return returned;
end;

local RunLoops: {RenderStepTable: {any}, StepTable: {any}, HeartTable: {any}} = {RenderStepTable = {}, StepTable = {}, HeartTable = {}};
getgenv().RunLoops = RunLoops
do
	function RunLoops:BindToRenderStep(name: any, func: any): any
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(function(...) pcall(func, unpack({...})) end);
		end;
	end;

	function RunLoops:UnbindFromRenderStep(name: any): any
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect();
			RunLoops.RenderStepTable[name] = nil;
		end;
	end;

	function RunLoops:BindToStepped(name: any, func: any): any
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(function(...) pcall(func, unpack({...})) end);
		end;
	end;

	function RunLoops:UnbindFromStepped(name: any): any
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect();
			RunLoops.StepTable[name] = nil;
		end;
	end;

	function RunLoops:BindToHeartbeat(name: any, func: any): any
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(function(...) pcall(func, unpack({...})) end);
		end;
	end;

	function RunLoops:UnbindFromHeartbeat(name: any): any
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect();
			RunLoops.HeartTable[name] = nil;
		end;
	end;
end;

local frictionTable: table?, oldfrict: table? = {}, {}
local frictionConnection: any;
local frictionState: any;

local function modifyVelocity(v: BasePart?): any
	if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' and not oldfrict[v] then
		oldfrict[v] = v.CustomPhysicalProperties or 'none';
		v.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.2, 0.5, 1, 1);
	end;
end;

local function updateVelocity(force: boolean?): any
	local newState: boolean? = getTableSize(frictionTable) > 0;
	if frictionState ~= newState or force then
		if frictionConnection then
			frictionConnection:Disconnect();
		end;
		if newState then
			if entitylib.isAlive then
				for _, v in entitylib.character.Character:GetDescendants() do
					modifyVelocity(v);
				end;
				frictionConnection = entitylib.character.Character.DescendantAdded:Connect(modifyVelocity);
			end;
		else
			for i, v in oldfrict do
				i.CustomPhysicalProperties = v ~= 'none' and v or nil;
			end;
			table.clear(oldfrict);
		end;
	end;
	frictionState = newState;
end;

local function EntityNearMouse(distance: number): any
	local closestEntity: any = nil;
	local closestMagnitude: number = distance or math.huge;
	if not lplr.Character or not lplr.Character:FindFirstChild("Head") then 
		return nil ;
	end;
	local mousePos: Vector2 = inputService:GetMouseLocation();
	for _, v in next, playersService:GetPlayers() do
		if v ~= lplr and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("Humanoid").Health > 0 then
			local rootPart: any = v.Character:FindFirstChild("HumanoidRootPart");
			if rootPart then
				local screenPos: any, onScreen: any = worldtoscreenpoint(rootPart.Position);
				if onScreen then
					local mag: any = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude;
					if mag <= closestMagnitude then
						closestEntity = v.Character;
						closestMagnitude = mag;
					end;
				end;
			end;
		end;
	end;
	return closestEntity;
end;


local kitorder: table = {
	hannah = 5,
	spirit_assassin = 4,
	dasher = 3,
	jade = 2,
	regent = 1
};

local sortmethods: table = {
	Damage = function(a, b)
		return a.Entity.Character:GetAttribute('LastDamageTakenTime') < b.Entity.Character:GetAttribute('LastDamageTakenTime')
	end,
	Distance = function(a, b)
		return (a.Entity.Character.PrimaryPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude < (b.Entity.Character.PrimaryPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
	end,
	Threat = function(a, b)
		return getStrength(a.Entity) > getStrength(b.Entity)
	end,
	Kit = function(a, b)
		return (a.Entity.Player and kitorder[a.Entity.Player:GetAttribute('PlayingAsKit')] or 0) > (b.Entity.Player and kitorder[b.Entity.Player:GetAttribute('PlayingAsKit')] or 0)
	end,
	Health = function(a, b)
		return a.Entity.Health < b.Entity.Health
	end,
	Angle = function(a, b)
		local selfrootpos: Vector3 = entitylib.character.RootPart.Position;
		local localfacing: CFrame? = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1);
		local angle: number? = math.acos(localfacing:Dot(((a.Entity.RootPart.Position - selfrootpos) * Vector3.new(1, 0, 1)).Unit));
		local angle2: number? = math.acos(localfacing:Dot(((b.Entity.RootPart.Position - selfrootpos) * Vector3.new(1, 0, 1)).Unit));
		return angle < angle2;
	end;
};

velo.run(function()
	local oldstart: any = entitylib.start;
	local function customEntity(ent: Instance?)
		if ent:HasTag('inventory-entity') and not ent:HasTag('Monster') then
			return;
		end;

		entitylib.addEntity(ent, nil, ent:HasTag('Drone') and function(self)
			local droneplr: any = playersService:GetPlayerByUserId(self.Character:GetAttribute('PlayerUserId'));
			return not droneplr or lplr:GetAttribute('Team') ~= droneplr:GetAttribute('Team')
		end or function(self)
			return lplr:GetAttribute('Team') ~= self.Character:GetAttribute('Team');
		end);
	end;

	entitylib.start = function(): (any, any)
		oldstart();
		if entitylib.Running then
			for _, ent in collectionService:GetTagged('entity') do
				customEntity(ent);
			end;
			table.insert(entitylib.Connections, collectionService:GetInstanceAddedSignal('entity'):Connect(customEntity))
			table.insert(entitylib.Connections, collectionService:GetInstanceRemovedSignal('entity'):Connect(function(ent)
				entitylib.removeEntity(ent);
			end));
		end;
	end;

	entitylib.addPlayer = function(plr: Player?)
		if plr.Character then
			entitylib.refreshEntity(plr.Character, plr);
		end;
		entitylib.PlayerConnections[plr] = {
			plr.CharacterAdded:Connect(function(char)
				entitylib.refreshEntity(char, plr);
			end),
			plr.CharacterRemoving:Connect(function(char)
				entitylib.removeEntity(char, plr == lplr);
			end),
			plr:GetAttributeChangedSignal('Team'):Connect(function()
				for _, v in entitylib.List do
					if v.Targetable ~= entitylib.targetCheck(v) then
						entitylib.refreshEntity(v.Character, v.Player);
					end;
				end;

				if plr == lplr then
					entitylib.start();
				else
					entitylib.refreshEntity(plr.Character, plr);
				end;
			end);
		};
	end;

	entitylib.addEntity = function(char: Model?, plr: Player?, teamfunc: (self: any) -> boolean?)
		if not char then return; end;
		entitylib.EntityThreads[char] = task.spawn(function()
			local hum: Humanoid?, humrootpart: any, head: Head?;
			if plr then
				hum = waitForChildOfType(char, 'Humanoid', 10);
				humrootpart = hum and waitForChildOfType(hum, 'RootPart', workspace.StreamingEnabled and 9e9 or 10, true);
				head = char:WaitForChild('Head', 10) or humrootpart;
			else
				hum = {HipHeight = 0.5};
				humrootpart = waitForChildOfType(char, 'PrimaryPart', 10, true);
				head = humrootpart;
			end;
			local updateobjects: any = plr and plr ~= lplr and {
				char:WaitForChild('ArmorInvItem_0', 5),
				char:WaitForChild('ArmorInvItem_1', 5),
				char:WaitForChild('ArmorInvItem_2', 5),
				char:WaitForChild('HandInvItem', 5)
			} or {};

			if hum and humrootpart then
				local entity: table = {
					Connections = {},
					Character = char,
					Health = (char:GetAttribute('Health') or 100) + getShieldAttribute(char),
					Head = head,
					Humanoid = hum,
					HumanoidRootPart = humrootpart,
					HipHeight = hum.HipHeight + (humrootpart.Size.Y / 2) + (hum.RigType == Enum.HumanoidRigType.R6 and 2 or 0),
					Jumps = 0,
					JumpTick = tick(),
					Jumping = false,
					LandTick = tick(),
					MaxHealth = char:GetAttribute('MaxHealth') or 100,
					NPC = plr == nil,
					Player = plr,
					RootPart = humrootpart,
					TeamCheck = teamfunc
				};

				if plr == lplr then
					entity.AirTime = tick();
					entitylib.character = entity;
					entitylib.isAlive = true;
					entitylib.Events.LocalAdded:Fire(entity);
					table.insert(entitylib.Connections, char.AttributeChanged:Connect(function(attr)
						vapeEvents.AttributeChanged:Fire(attr);
					end));
				else
					entity.Targetable = entitylib.targetCheck(entity);

					for _, v in entitylib.getUpdateConnections(entity) do
						table.insert(entity.Connections, v:Connect(function()
							entity.Health = (char:GetAttribute('Health') or 100) + getShieldAttribute(char);
							entity.MaxHealth = char:GetAttribute('MaxHealth') or 100;
							entitylib.Events.EntityUpdated:Fire(entity);
						end));
					end;

					for _, v in updateobjects do
						table.insert(entity.Connections, v:GetPropertyChangedSignal('Value'):Connect(function()
							task.delay(0.1, function()
								if bedwars.getInventory then
									store.inventories[plr] = bedwars.getInventory(plr);
									entitylib.Events.EntityUpdated:Fire(entity);
								end;
							end);
						end));
					end;

					if plr then
						local anim: Animate = char:FindFirstChild('Animate');
						if anim then
							pcall(function()
								anim = anim.jump:FindFirstChildWhichIsA('Animation').AnimationId;
								table.insert(entity.Connections, hum.Animator.AnimationPlayed:Connect(function(playedanim)
									if playedanim.Animation.AnimationId == anim then
										entity.JumpTick = tick();
										entity.Jumps += 1;
										entity.LandTick = tick() + 1;
										entity.Jumping = entity.Jumps > 1;
									end;
								end));
							end);
						end;

						task.delay(0.1, function()
							if bedwars.getInventory then
								store.inventories[plr] = bedwars.getInventory(plr);
							end;
						end);
					end;
					table.insert(entitylib.List, entity);
					entitylib.Events.EntityAdded:Fire(entity);
				end;

				table.insert(entity.Connections, char.ChildRemoved:Connect(function(part)
					if part == humrootpart or part == hum or part == head then
						if part == humrootpart and hum.RootPart then
							humrootpart = hum.RootPart;
							entity.RootPart = hum.RootPart;
							entity.HumanoidRootPart = hum.RootPart;
							return;
						end;
						entitylib.removeEntity(char, plr == lplr);
					end;
				end));
			end;
			entitylib.EntityThreads[char] = nil;
		end);
	end;

	entitylib.getUpdateConnections = function(ent: any): {RBXScriptConnection}?
		local char: any = ent.Character;
		local tab: table? = {
			char:GetAttributeChangedSignal('Health'),
			char:GetAttributeChangedSignal('MaxHealth'),
			{
				Connect = function()
					ent.Friend = ent.Player and isFriend(ent.Player) or nil;
					ent.Target = ent.Player and isTarget(ent.Player) or nil;
					return {Disconnect = function() end};
				end;
			}
		};

		for name: string?, val: any in char:GetAttributes() do
			if name:find('Shield') and type(val) == 'number' then
				table.insert(tab, char:GetAttributeChangedSignal(name));
			end;
		end;

		return tab;
	end;

	entitylib.targetCheck = function(ent: any): boolean?
		if ent.TeamCheck then
			return ent:TeamCheck();
		end;
		if ent.NPC then return true; end;
		if isFriend(ent.Player) then return false; end;
		if not select(2, whitelist:get(ent.Player)) then return false; end;
		return lplr:GetAttribute('Team') ~= ent.Player:GetAttribute('Team');
	end;
	vape:Clean(entitylib.Events.LocalAdded:Connect(updateVelocity));
end);
entitylib.start();


local Disabler: any;

velo.run(function()
	local function Instances(name: string?, Type: string?): any
		for i: any, v: any in next, game:GetDescendants() do
			if v.Name:lower() == name:lower() and v.ClassName:lower() == Type:lower() then
				return v;
			end;
		end;
		return Instance.new(Type);
	end;

	Disabler = {
		StepOnSnapTrap = Instances("StepOnSnapTrap", "RemoteEvent"),
		TriggerInvisibleLandmine = Instances("TriggerInvisibleLandmine", "RemoteEvent")
	}
end)

velo.run(function()
	local KnitInit: boolean;
	local Knit: any;
	local knitModule: table = require(lplr.PlayerScripts.TS.knit);
	local findKnitIndex: () -> number? = function()
		for i: number = 1, 20 do
	        	local success: boolean, value: any = pcall(function()
	                	return debug.getupvalue(knitModule.setup, i)
	            	end)
	            	if success and type(value) == "table" then
	                	if value.Controllers and type(value.Controllers) == "table" and value.Start then
	                    		return i;
	                	end;
	            	end;
	        end;
	        return nil;
	end;
	local knitIndex: number? = findKnitIndex();
	if not knitIndex then
	        return;
	end;
	for i: number = 1, 7 do
	        task.wait(0.07)
	        KnitInit, Knit = pcall(function()
	            	return debug.getupvalue(knitModule.setup, knitIndex);
	        end);
	        if KnitInit then break; end;
	end;
	local cheatengine: boolean = not KnitInit;
	if not cheatengine and not debug.getupvalue(Knit.Start, 1) then
	        repeat task.wait() until debug.getupvalue(Knit.Start, 1);
	end;
	local engine_loader: any = loadfile('newvape/libraries/constructor.lua')() :: table;
	local Flamework: any = ({pcall(function() return require(replicatedStorage['rbxts_include']['node_modules']['@flamework'].core.out).Flamework end)})[2];
	local InventoryUtil: any = ({pcall(function() return require(replicatedStorage.TS.inventory['inventory-util']).InventoryUtil end)})[2];
	local Client: any = ({pcall(function() return require(replicatedStorage.TS.remotes).default.Client end)})[2] or {Get = function() end};
	local OldGet: any, OldBreak: any = Client.Get;

	bedwars = setmetatable(cheatengine and engine_loader.controllers or {
		SoundList = require(replicatedStorage.TS.sound['game-sound']).GameSound,
		SoundManager = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).SoundManager,
		AnimationType = require(replicatedStorage.TS.animation['animation-type']).AnimationType,
		AnimationUtil = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out['shared'].util['animation-util']).AnimationUtil,
		AppController = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.controllers['app-controller']).AppController,
		AbilityController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController'),
		BedwarsKitMeta = require(replicatedStorage.TS.games.bedwars.kit['bedwars-kit-meta']).BedwarsKitMeta,
		BlockBreaker = Knit.Controllers.BlockBreakController.blockBreaker,
		BlockController = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out).BlockEngine,
		BlockPlacer = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client.placement['block-placer']).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib['block-engine']['client-block-engine']).ClientBlockEngine,
		BowConstantsTable = debug.getupvalue(Knit.Controllers.ProjectileController.enableBeam, 8),
		ClickHold = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.ui.lib.util['click-hold']).ClickHold,
		Client = Client,
		ClientConstructor = require(replicatedStorage['rbxts_include']['node_modules']['@rbxts'].net.out.client),
		ClientDamageBlock = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.shared.remotes).BlockEngineRemotes.Client,
		CombatConstant = require(replicatedStorage.TS.combat['combat-constant']).CombatConstant,
		DamageIndicator = Knit.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker['kill-effect'].effects['default-kill-effect']),
		EmoteType = require(replicatedStorage.TS.locker.emote['emote-type']).EmoteType,
		GameAnimationUtil = require(replicatedStorage.TS.animation['animation-util']).GameAnimationUtil,
		getIcon = function(item: any, showinv: boolean): any
			local itemmeta: any = bedwars.ItemMeta[item.itemType];
			return itemmeta and showinv and itemmeta.image or '';
		end,
		getInventory = function(plr: Player): any
			local suc: boolean, res: any = pcall(function()
				return InventoryUtil.getInventory(plr);
			end);
			return suc and res or {
				items = {},
				armor = {}
			};
		end,
		ItemMeta = debug.getupvalue(require(replicatedStorage.TS.item['item-meta']).getItemMeta, 1),
		HudAliveCount = require(lplr.PlayerScripts.TS.controllers.global['top-bar'].ui.game['hud-alive-player-counts']).HudAlivePlayerCounts,
		KillEffectMeta = require(replicatedStorage.TS.locker['kill-effect']['kill-effect-meta']).KillEffectMeta,
		KillFeedController = Flamework.resolveDependency('client/controllers/game/kill-feed/kill-feed-controller@KillFeedController'),
		Knit = Knit,
		KnockbackUtil = require(replicatedStorage.TS.damage['knockback-util']).KnockbackUtil,
		NametagController = Knit.Controllers.NametagController,
		MageKitUtil = require(replicatedStorage.TS.games.bedwars.kit.kits.mage['mage-kit-util']).MageKitUtil,
		ProjectileMeta = require(replicatedStorage.TS.projectile['projectile-meta']).ProjectileMeta,
		QueryUtil = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).GameQueryUtil,
		QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui['queue-card']).QueueCard,
		QueueMeta = require(replicatedStorage.TS.game['queue-meta']).QueueMeta,
		Roact = require(replicatedStorage['rbxts_include']['node_modules']['@rbxts']['roact'].src),
		RuntimeLib = require(replicatedStorage['rbxts_include'].RuntimeLib),
		SoundList = require(replicatedStorage.TS.sound['game-sound']).GameSound,
		SoundManager = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).SoundManager,
		Store = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		TeamUpgradeMeta = debug.getupvalue(require(replicatedStorage.TS.games.bedwars['team-upgrade']['team-upgrade-meta']).getTeamUpgradeMetaForQueue, 6),
		UILayers = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).UILayers,
		VisualizerUtils = require(lplr.PlayerScripts.TS.lib.visualizer['visualizer-utils']).VisualizerUtils,
		WeldTable = require(replicatedStorage.TS.util['weld-util']).WeldUtil,
		WinEffectMeta = require(replicatedStorage.TS.locker['win-effect']['win-effect-meta']).WinEffectMeta,
		ZapNetworking = require(lplr.PlayerScripts.TS.lib.network)
	}, {
		__index = function(self: table, ind: string?)
			rawset(self, ind, Knit.Controllers[ind]);
			return rawget(self, ind);
		end;
	})

	local remoteNames: table? = {
		AfkStatus = debug.getproto(Knit.Controllers.AfkController.KnitStart, 1),
		AttackEntity = Knit.Controllers.SwordController.sendServerRequest,
		BeePickup = Knit.Controllers.BeeNetController.trigger,
		ConsumeBattery = debug.getproto(Knit.Controllers.BatteryController.onKitLocalActivated, 1),
		CannonAim = debug.getproto(Knit.Controllers.CannonController.startAiming, 5),
		CannonLaunch = Knit.Controllers.CannonHandController.launchSelf,
		ConsumeItem = debug.getproto(Knit.Controllers.ConsumeController.onEnable, 1),
		ConsumeSoul = Knit.Controllers.GrimReaperController.consumeSoul,
		ConsumeTreeOrb = debug.getproto(Knit.Controllers.EldertreeController.createTreeOrbInteraction, 1),
		DepositPinata = debug.getproto(debug.getproto(Knit.Controllers.PiggyBankController.KnitStart, 2), 5),
		DragonBreath = debug.getproto(Knit.Controllers.VoidDragonController.onKitLocalActivated, 5),
		DragonEndFly = debug.getproto(Knit.Controllers.VoidDragonController.flapWings, 1),
		DragonFly = Knit.Controllers.VoidDragonController.flapWings,
		DropItem = Knit.Controllers.ItemDropController.dropItemInHand,
		EquipItem = debug.getproto(require(replicatedStorage.TS.entity.entities['inventory-entity']).InventoryEntity.equipItem, 3),
		FireProjectile = debug.getupvalue(Knit.Controllers.ProjectileController.launchProjectileWithValues, 2),
		GroundHit = Knit.Controllers.FallDamageController.KnitStart,
		GuitarHeal = Knit.Controllers.GuitarController.performHeal,
		HannahKill = debug.getproto(Knit.Controllers.HannahController.registerExecuteInteractions, 1),
		HarvestCrop = debug.getproto(debug.getproto(Knit.Controllers.CropController.KnitStart, 4), 1),
		KaliyahPunch = debug.getproto(Knit.Controllers.DragonSlayerController.onKitLocalActivated, 1),
		MageSelect = debug.getproto(Knit.Controllers.MageController.registerTomeInteraction, 1),
		MinerDig = debug.getproto(Knit.Controllers.MinerController.setupMinerPrompts, 1),
		PickupItem = Knit.Controllers.ItemDropController.checkForPickup,
		PickupMetal = debug.getproto(Knit.Controllers.HiddenMetalController.onKitLocalActivated, 4),
		ReportPlayer = require(lplr.PlayerScripts.TS.controllers.global.report['report-controller']).default.reportPlayer,
		ResetCharacter = debug.getproto(Knit.Controllers.ResetController.createBindable, 1),
		SpawnRaven = debug.getproto(Knit.Controllers.RavenController.KnitStart, 1),
		SummonerClawAttack = Knit.Controllers.SummonerClawHandController.attack,
		WarlockTarget = debug.getproto(Knit.Controllers.WarlockStaffController.KnitStart, 2)
	}
	
	local function dumpRemote(tab: table)
		local ind: any;
		for i: any, v: any in tab do
			if v == 'Client' then
				ind = i;
				break;
			end;
		end;
		return ind and tab[ind + 1] or '';
	end;

	for i: any, v: any in remoteNames do
		local remote: any = dumpRemote(debug.getconstants(v))
		if remote == '' then
			notif('Vape', 'Failed to grab remote ('..i..')', 10, 'alert');
		end;
		remotes[i] = remote;
	end;

	OldBreak = bedwars.BlockController.isBlockBreakable;

	Client.Get = function(self, remoteName)
		local call: any = OldGet(self, remoteName);
		if remoteName == remotes.AckKnockback then
			return {
				instance = call.instance,
				SendToServer = function(_, knockback)
					return call:SendToServer(knockback);
				end;
			}
		elseif remoteName == remotes.AttackEntity then
			return {
				instance = call.instance,
				SendToServer = function(_, attackTable, ...)
					local suc: any?, plr: Player? = pcall(function()
						return playersService:GetPlayerFromCharacter(attackTable.entityInstance);
					end);

					local selfpos: any = attackTable.validate.selfPosition.value;
					local targetpos: any = attackTable.validate.targetPosition.value;
					store.attackReach = ((selfpos - targetpos).Magnitude * 100) // 1 / 100;
					store.attackReachUpdate = tick() + 1;
					if Reach["Enabled"] or HitBoxes["Enabled"] then
						attackTable.validate.raycast = attackTable.validate.raycast or {};
						attackTable.validate.selfPosition.value += CFrame.lookAt(selfpos, targetpos).LookVector * math.max((selfpos - targetpos).Magnitude - 14.399, 0);
					end;
					if suc and plr then
						if not select(2, whitelist:get(plr)) then return; end;
					end;

					return call:SendToServer(attackTable, ...);
				end;
			};
		elseif remoteName == 'StepOnSnapTrap' and TrapDisabler["Enabled"] then
			return {SendToServer = function() end};
		end;

		return call;
	end;

	bedwars.BlockController.isBlockBreakable = function(self: any, breakTable: table, plr: Player): boolean
		local obj: any = bedwars.BlockController:getStore():getBlockAt(breakTable.blockPosition)

		if obj and obj["Name"] == 'bed' then
			for _, plr in playersService:GetPlayers() do
				if obj:GetAttribute('Team'..(plr:GetAttribute('Team') or 0)..'NoBreak') and not select(2, whitelist:get(plr)) then
					return false;
				end;
			end;
		end;

		return OldBreak(self, breakTable, plr);
	end;
	local cache: any, blockhealthbar: table = {}, {blockHealth = -1, breakingBlockPosition = Vector3.zero}
	store.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, 'wool_white');

		
	local function getBlockHealth(block: Instance?, blockpos: Vector3?): number?
		local blockdata: Instance? = bedwars.BlockController:getStore():getBlockData(blockpos);
		return (blockdata and (blockdata:GetAttribute('1') or blockdata:GetAttribute('Health')) or block:GetAttribute('Health'));
	end;
		
	local function getBlockHits(block: Instance?, blockpos: Vector3?): number?
		if not block then return 0; end;
		local breaktype: string? = bedwars.ItemMeta[block["Name"]].block.breakType;
		local tool: Instance? = store.tools[breaktype];
		tool = tool and bedwars.ItemMeta[tool.itemType].breakBlock[breaktype] or 2;
		return getBlockHealth(block, bedwars.BlockController:getBlockPosition(blockpos)) / tool;
	end;

		--[[
			Pathfinding using a luau version of dijkstra's algorithm
			Source: https://stackoverflow.com/questions/39355587/speeding-up-dijkstras-algorithm-to-solve-a-3d-maze
		]]
	local function calculatePath(target: Instance?, blockpos: Vector3): (Vector3?, number?, { [Vector3]: Vector3? })
		if cache[blockpos] then
			return unpack(cache[blockpos]);
		end;
		local visited: table, unvisited: table, distances: table, air: table, path: table = {}, {{0, blockpos}}, {[blockpos] = 0}, {}, {};	
		for _ = 1, 10000 do
			local _, node: any = next(unvisited);
			if not node then break; end;
			table.remove(unvisited, 1);
			visited[node[2]] = true;

			for _, side in sides do
				side = node[2] + side
				if visited[side] then continue; end;

				local block: any = getPlacedBlock(side);
				if not block or block:GetAttribute('NoBreak') or block == target then
					if not block then
						air[node[2]] = true;
					end;
					continue;
				end;

				local curdist: any = getBlockHits(block, side) + node[1];
				if curdist < (distances[side] or math.huge) then
					table.insert(unvisited, {curdist, side});
					distances[side] = curdist;
					path[side] = node[2];
				end;
			end;
		end;

		local pos: any, cost: number = nil, math.huge;
		for node in air do
			if distances[node] < cost then
				pos, cost = node, distances[node];
			end;
		end;

		if pos then
			cache[blockpos] = {
				pos,
				cost,
				path
			};
			return pos, cost, path;
		end;
	end;

	bedwars.placeBlock = function(pos: any, item: any)
		if getItem(item) then
			store.blockPlacer.blockType = item;
			return store.blockPlacer:placeBlock(bedwars.BlockController:getBlockPosition(pos));
		end;
	end;

	bedwars.breakBlock = function(block: any, effects: any, anim: any, customHealthbar: any)
		if lplr:GetAttribute('DenyBlockBreak') or not entitylib.isAlive or InfiniteFly["Enabled"] then return; end;
		local handler: any = bedwars.BlockController:getHandlerRegistry():getHandler(block["Name"]);
		local cost, pos, target, path = math.huge;

		for _, v in (handler and handler:getContainedPositions(block) or {block.Position / 3}) do
			local dpos, dcost, dpath = calculatePath(block, v * 3);
			if dpos and dcost < cost then
				cost, pos, target, path = dcost, dpos, v * 3, dpath;
			end;
		end;

		if pos then
			if (entitylib.character.RootPart.Position - pos).Magnitude > 30 then return; end;
			local dblock: any, dpos: any = getPlacedBlock(pos);
			if not dblock then return; end;

			if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) > 0.4 then
				local breaktype: any = bedwars.ItemMeta[dblock["Name"]].block.breakType;
				local tool: any = store.tools[breaktype];
				if tool then
					switchItem(tool.tool);
				end;
			end;

			if blockhealthbar.blockHealth == -1 or dpos ~= blockhealthbar.breakingBlockPosition then
				blockhealthbar.blockHealth = getBlockHealth(dblock, dpos);
				blockhealthbar.breakingBlockPosition = dpos;
			end;

			bedwars.ClientDamageBlock:Get('DamageBlock'):CallServerAsync({
				blockRef = {blockPosition = dpos},
				hitPosition = pos,
				hitNormal = Vector3.FromNormalId(Enum.NormalId.Top)
			}):andThen(function(result)
				if result then
					if result == 'cancelled' then
						store.damageBlockFail = tick() + 1;
						return;
					end;

					if effects then
						local blockdmg: number = (blockhealthbar.blockHealth - (result == 'destroyed' and 0 or getBlockHealth(dblock, dpos)))
						customHealthbar = customHealthbar or bedwars.BlockBreaker.updateHealthbar;
						customHealthbar(bedwars.BlockBreaker, {blockPosition = dpos}, blockhealthbar.blockHealth, dblock:GetAttribute('MaxHealth'), blockdmg, dblock);
						blockhealthbar.blockHealth = math.max(blockhealthbar.blockHealth - blockdmg, 0);

						if blockhealthbar.blockHealth <= 0 then
							bedwars.BlockBreaker.breakEffect:playBreak(dblock["Name"], dpos, lplr)
							bedwars.BlockBreaker.healthbarMaid:DoCleaning();
							blockhealthbar.breakingBlockPosition = Vector3.zero;
						else
							bedwars.BlockBreaker.breakEffect:playHit(dblock["Name"], dpos, lplr);
						end;
					end;

					if anim then
						local animation: any = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1));
						bedwars.ViewmodelController:playAnimation(15);
						task.wait(0.3);
						animation:Stop();
						animation:Destroy();
					end;
				end;
			end);

			if effects then
				return pos, path, target;
			end;
		end;
	end;


	for _, v in Enum.NormalId:GetEnumItems() do
		table.insert(sides, Vector3.FromNormalId(v) * 3);
	end;

	local function updateStore(new: table, old: table): nil
		if new.Bedwars ~= old.Bedwars then
			store.equippedKit = new.Bedwars.kit ~= 'none' and new.Bedwars.kit or '';
		end;

		if new.Game ~= old.Game then
			store.matchState = new.Game.matchState;
			store.queueType = new.Game.queueType or 'bedwars_test';
		end;

		if new.Inventory ~= old.Inventory then
			local newinv: any = (new.Inventory and new.Inventory.observedInventory or {inventory = {}});
			local oldinv: any = (old.Inventory and old.Inventory.observedInventory or {inventory = {}});
			store.inventory = newinv;

			if newinv ~= oldinv then
				vapeEvents.InventoryChanged:Fire();
			end;

			if newinv.inventory.items ~= oldinv.inventory.items then
				vapeEvents.InventoryAmountChanged:Fire();
				store.tools.sword = getSword();
				for _, v in {'stone', 'wood', 'wool'} do
					store.tools[v] = getTool(v);
				end;
			end;

			if newinv.inventory.hand ~= oldinv.inventory.hand then
				local currentHand:  any, toolType: string = new.Inventory.observedInventory.inventory.hand, '';
				if currentHand then
					local handData: any = bedwars.ItemMeta[currentHand.itemType];
					toolType = handData.sword and 'sword' or handData.block and 'block' or currentHand.itemType:find('bow') and 'bow';
				end;

				store.hand = {
					tool = currentHand and currentHand.tool,
					amount = currentHand and currentHand.amount or 0,
					toolType = toolType
				};
			end;
		end;
	end;

	local storeChanged: any = bedwars.Store.changed:connect(updateStore);
	updateStore(bedwars.Store:getState(), {});

	for _, event in {'MatchEndEvent', 'EntityDeathEvent', 'BedwarsBedBreak', 'BalloonPopped', 'AngelProgress', 'GrapplingHookFunctions'} do
		if not vape.Connections then return; end;
		bedwars.Client:WaitFor(event):andThen(function(connection)
			vape:Clean(connection:Connect(function(...)
				vapeEvents[event]:Fire(...);
			end));
		end);
	end;

				
	vape:Clean(bedwars.ZapNetworking.EntityDamageEventZap.On(function(...)
		vapeEvents.EntityDamageEvent:Fire({
			entityInstance = ...,
			damage = select(2, ...),
			damageType = select(3, ...),
			fromPosition = select(4, ...),
			fromEntity = select(5, ...),
			knockbackMultiplier = select(6, ...),
			knockbackId = select(7, ...),
			disableDamageHighlight = select(13, ...)
		});
	end));


	for _: any, event: any in {'PlaceBlockEvent', 'BreakBlockEvent'} do
		vape:Clean(bedwars.ZapNetworking[event..'Zap'].On(function(...)
			local data: table? = {
				blockRef = {
					blockPosition = ...,
				},
				player = select(5, ...)
			}
			for i: any, v: any in cache do
				if ((data.blockRef.blockPosition * 3) - v[1]).Magnitude <= 30 then
					table.clear(v[3]);
					table.clear(v);
					cache[i] = nil;
				end;
			end;
			vapeEvents[event]:Fire(data);
		end));
	end;

	vape:Clean(vapeEvents.KnockbackReceived.Event:Connect(function()
		notif('StoreDamage', 'Added damage packet: '..#store.damage, 3);
	end));

	store.blocks = collection('block', gui);
	store.shop = collection({'BedwarsItemShop', 'TeamUpgradeShopkeeper'}, gui, function(tab, obj)
		table.insert(tab, {
			Id = obj["Name"],
			RootPart = obj,
			Shop = obj:HasTag('BedwarsItemShop'),
			Upgrades = obj:HasTag('TeamUpgradeShopkeeper')
		});
	end);
	store.enchant = collection({'enchant-table', 'broken-enchant-table'}, gui, nil, function(tab, obj, tag)
		if obj:HasTag('enchant-table') and tag == 'broken-enchant-table' then return; end;
		obj = table.find(tab, obj);
		if obj then
			table.remove(tab, obj);
		end;
	end);

	local kills: any = sessioninfo:AddItem('Kills');
	local beds: any = sessioninfo:AddItem('Beds');
	local wins: any = sessioninfo:AddItem('Wins');
	local games: any = sessioninfo:AddItem('Games');
	sessioninfo:AddItem('Packets', 0, function()
		return #store.damage
	end, false);

	local mapname: string = 'Unknown';
	sessioninfo:AddItem('Map', 0, function()
		return mapname
	end, false);

	task.delay(1, function()
		games:Increment();
	end);

	task.spawn(function()
		pcall(function()
			repeat task.wait() until store.matchState ~= 0 or vape.Loaded == nil
			if vape.Loaded == nil then return; end;
			mapname = workspace:WaitForChild('Map', 5):WaitForChild('Worlds', 5):GetChildren()[1]["Name"];
			mapname = string.gsub(string.split(mapname, '_')[2] or mapname, '-', '') or 'Blank';
		end);
	end);

	pcall(function()
		vape:Clean(vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
			if bedTable.player and bedTable.player.UserId == lplr.UserId then
				beds:Increment();
			end;
		end));

		vape:Clean(vapeEvents.MatchEndEvent.Event:Connect(function(winTable)
			if (bedwars.Store:getState().Game.myTeam or {}).id == winTable.winningTeamId or lplr.Neutral then
				wins:Increment();
			end;
		end));

		vape:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
			local killer: any = playersService:GetPlayerFromCharacter(deathTable.fromEntity);
			local killed: any = playersService:GetPlayerFromCharacter(deathTable.entityInstance);
			if not killed or not killer then return; end;

			if killed ~= lplr and killer == lplr then
				kills:Increment();
			end;
		end));
	end);

	task.spawn(function()
		repeat
			if entitylib.isAlive then
				entitylib.character.AirTime = entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entitylib.character.AirTime;
			end;

			for _, v in entitylib.List do
				v.LandTick = math.abs(v.RootPart.Velocity.Y) < 0.1 and v.LandTick or tick();
				if (tick() - v.LandTick) > 0.2 and v.Jumps ~= 0 then
					v.Jumps = 0;
					v.Jumping = false;
				end;
			end;
			task.wait();
		until vape.Loaded == nil;
	end);

	pcall(function()
		if getthreadidentity and setthreadidentity then
			local old: any = getthreadidentity();
			setthreadidentity(2);
			bedwars.Shop = require(replicatedStorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop;
			bedwars.ShopItems = debug.getupvalue(debug.getupvalue(bedwars.Shop.getShopItem, 1), 2);
			bedwars.Shop.getShopItem('iron_sword', lplr);
			setthreadidentity(old);
			store.shopLoaded = true;
		else
			task.spawn(function()
				repeat
					task.wait(0.1)
				until vape.Loaded == nil or bedwars.AppController:isAppOpen('BedwarsItemShopApp');
				bedwars.Shop = require(replicatedStorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop;
				bedwars.ShopItems = debug.getupvalue(debug.getupvalue(bedwars.Shop.getShopItem, 1), 2);
				store.shopLoaded = true;
			end);
		end;
	end);

	vape:Clean(function()
		Client.Get = OldGet;
		bedwars.BlockController.isBlockBreakable = OldBreak;
		store.blockPlacer:disable();
		for _, v in vapeEvents do
			v:Destroy();
		end;
		for _, v in cache do
			table.clear(v[3]);
			table.clear(v);
		end;
		table.clear(store.blockPlacer);
		table.clear(vapeEvents);
		table.clear(bedwars);
		table.clear(store);
		table.clear(cache);
		table.clear(sides);
		table.clear(remotes);
		storeChanged:disconnect();
		storeChanged = nil;
	end);
end);

--[[

    The Start Velocity Modules | Bedwars                                           
    The #1 vape mod you'll ever see. (Other than Render or prob CatVape/Skidvape)

]]

if vape.ThreadFix then
	setthreadidentity(8);
end;


for _, v in {'AntiRagdoll', 'TriggerBot', 'SilentAim', 'AutoRejoin', 'Rejoin', 'Disabler', 'Timer', 'SpinBot','ServerHop', 'MouseTP', 'MurderMystery', 'Anti-AFK'} do
	vape:Remove(v);
end;

velo.run(function()
        local old: any;
        AutoCharge = vape.Categories.Combat:CreateModule({
                ["Name"] = 'AutoCharge',
                ["Function"] = function(callback: boolean): void
                        debug.setconstant(bedwars.SwordController.attackEntity, 58, callback and 'damage' or 'multiHitCheckDurationSec')
                        if callback then
                                local chargeSwingTime: number = 0;
                                local canSwing: boolean?;
                                old = bedwars.SwordController.sendServerRequest;
                                bedwars.SwordController.sendServerRequest = function(self, ...)
                                        if (os.clock() - chargeSwingTime) < AutoChargeTime["Value"] then 
                                                return; 
                                        end;
                                        self.lastSwingServerTimeDelta = 0.5;
                                        chargeSwingTime = os.clock();
                                        canSwing = true;
                                        local item: any = self:getHandItem();
                                        if item and item.tool then
                                                self:playSwordEffect(bedwars.ItemMeta[item.tool.Name], false);
                                        end;
                                        return old(self, ...);
                                end;
                                oldSwing = bedwars.SwordController.playSwordEffect;
                                bedwars.SwordController.playSwordEffect = function(...)
                                        if not canSwing then return; end;
                                        canSwing = false;
                                        return oldSwing(...);
                                end;
                        else
                                if old then
                                        bedwars.SwordController.sendServerRequest = old;
                                        old = nil;
                                end;
                                if oldSwing then
                                        bedwars.SwordController.playSwordEffect = oldSwing;
                                        oldSwing = nil;
                                end;
                        end;
                end,
                ["Tooltip"] = 'Allows you to get charged hits while spam clicking.'
        })
        AutoChargeTime = AutoCharge:CreateSlider({
                ["Name"] = 'Charge Time',
                ["Min"] = 0,
                ["Max"] = 0.5,
                ["Default"] = 0.4,
                ["Decimal"] = 100
        })
end)

		velo.run(function()
        local AimAssist: table = {["Enabled"] = false}
        local Targets: table = {Players = {["Enabled"] = false}};
        local Sort: table = {["Value"] = "Damage"}
        local AimSpeed: table = {["Value"] = 1}
        local Distance: table = {["Value"] = 9}
        local AngleSlider: table = {["Value"] = 360}
        local StrafeIncrease: table = {["Enabled"] = false}
        local KillauraTarget: table = {["Enabled"] = false}
        local ClickAim: table = {["Enabled"] = false}
        AimAssist = vape.Categories.Combat:CreateModule({
                ["Name"] = 'AimAssist',
                ["Function"] = function(callback: boolean): void
                        if callback then
                                AimAssist:Clean(runService.Heartbeat:Connect(function(dt)
                                        if entitylib.isAlive and store.hand.toolType == 'sword' and ((not ClickAim.Enabled) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
                                                local ent: any = KillauraTarget["Enabled"] and store.KillauraTarget or entitylib.EntityPosition({
                                                        Range = Distance["Value"],
                                                        Part = 'RootPart',
                                                        Wallcheck = Targets.Walls["Enabled"],
                                                        Players = Targets.Players["Enabled"],
                                                        NPCs = Targets.NPCs["Enabled"],
                                                        Sort = sortmethods[Sort["Value"]]
                                                });
                                                if ent then
                                                        local delta: Vector3? = (ent.RootPart.Position - entitylib.character.RootPart.Position);
                                                        local localfacing: CFrame = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1);
                                                        local angle: number = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit));
                                                        if angle >= (math.rad(AngleSlider["Value"]) / 2) then return; end;
                                                        targetinfo.Targets[ent] = tick() + 1;
                                                        gameCamera.CFrame = gameCamera.CFrame:Lerp(CFrame.lookAt(gameCamera.CFrame.p, ent.RootPart.Position), (AimSpeed.Value + (StrafeIncrease.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 10 or 0)) * dt);
                                                end;
                                        end;
                                end));
                        end;
                end,
                ["Tooltip"] = 'Smoothly aims to closest valid target with sword'
        })
        Targets = AimAssist:CreateTargets({
                ["Players"] = true, 
                ["Walls"] = true
        })
        local methods: table? = {'Damage', 'Distance'};
        for i in sortmethods do
                if not table.find(methods, i) then
                        table.insert(methods, i);
                end;
        end;
        Sort = AimAssist:CreateDropdown({
                ["Name"] = 'Target Mode',
                ["List"] = methods
        })
        AimSpeed = AimAssist:CreateSlider({
                ["Name"] = 'Aim Speed',
                ["Min"] = 1,
                ["Max"] = 20,
                ["Default"] = 6
        })
        Distance = AimAssist:CreateSlider({
                ["Name"] = 'Distance',
                ["Min"] = 1,
                ["Max"] = 30,
                ["Default"] = 30,
                ["Suffx"] = function(val) 
                        return val == 1 and 'stud' or 'studs' 
                end
        })
        AngleSlider = AimAssist:CreateSlider({
                ["Name"] = 'Max angle',
                ["Min"] = 1,
                ["Max"] = 360,
                ["Default"] = 70
        })
        ClickAim = AimAssist:CreateToggle({
                ["Name"] = 'Click Aim',
                ["Default"] = true
        })
        KillauraTarget = AimAssist:CreateToggle({
                ["Name"] = 'Use killaura target'
        })
        StrafeIncrease = AimAssist:CreateToggle({["Name"] = 'Strafe increase'})
end)

velo.run(function()
	local AutoClicker: table = {["Enabled"] = false}
	local CPS: table = {["Value"] = 9}
	local BlockCPS: table = {}
	local Thread: any;
	local AutoClick: () -> nil = function()
		if Thread then
			task.cancel(Thread);
		end;
		Thread = task.delay(1 / 7, function()
			repeat
				if not bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then
					local blockPlacer: any = bedwars.BlockPlacementController.blockPlacer;
					if store.hand.toolType == 'block' and blockPlacer then
						if (workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) >= ((1 / 12) * 0.5) then
							local mouseinfo: any = blockPlacer.clientManager:getBlockSelector():getMouseInfo(0);
							if mouseinfo and mouseinfo.placementPosition == mouseinfo.placementPosition then
								task.spawn(blockPlacer.placeBlock, blockPlacer, mouseinfo.placementPosition);
							end;
						end;
					elseif store.hand.toolType == 'sword' and bedwars.DaoController.chargingMaid == nil then
						bedwars.SwordController:swingSwordAtMouse();
					end;
				end;
	
				task.wait(1 / (store.hand.toolType == 'block' and BlockCPS or CPS).GetRandomValue());
			until not AutoClicker["Enabled"]
		end);
	end;
	AutoClicker = vape.Categories.Combat:CreateModule({
		["Name"] = 'AutoClicker',
		["Function"] = function(callback: boolean): void
			if callback then
				AutoClicker:Clean(inputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then 
						AutoClick(); 
					end;
				end));
				AutoClicker:Clean(inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and Thread then
						task.cancel(Thread);
						Thread = nil;
					end;
				end));
	
				if inputService.TouchEnabled then
					pcall(function()
						AutoClicker:Clean(lplr.PlayerGui.MobileUI['2'].MouseButton1Down:Connect(AutoClick));
						AutoClicker:Clean(lplr.PlayerGui.MobileUI['2'].MouseButton1Up:Connect(function()
							if Thread then
								task.cancel(Thread);
								Thread = nil;
							end;
						end));
					end);
				end;
			else
				if Thread then 
					task.cancel(Thread);
					Thread = nil;
				end;
			end;
		end,
		["Tooltip"] = 'Hold attack button to automatically click';
	})
	CPS = AutoClicker:CreateTwoSlider({
		["Name"] = 'CPS',
		["Min"] = 1,
		["Max"] = 9,
		["DefaultMin"] = 7,
		["DefaultMax"] = 7
	})
	AutoClicker:CreateToggle({
		["Name"] = 'Place Blocks',
		["Default"] = true,
		["Function"] = function(callback: boolean): void
			if BlockCPS.Object then 
				BlockCPS.Object.Visible = callback 
			end
		end
	})
	BlockCPS = AutoClicker:CreateTwoSlider({
		["Name"] = 'Block CPS',
		["Min"] = 1,
		["Max"] = 12,
		["DefaultMin"] = 12,
		["DefaultMax"] = 12,
		["Darker"] = true
	})
end)
	
velo.run(function()
	local old: any;
	vape.Categories.Combat:CreateModule({
		["Name"] = 'NoClickDelay',
		["Function"] = function(callback: boolean): void
			if callback then
				old = bedwars.SwordController.isClickingTooFast;
				bedwars.SwordController.isClickingTooFast = function(self)
					self.lastSwing = tick();
					return false;
				end;
			else
				bedwars.SwordController.isClickingTooFast = old;
			end;
		end,
		["Tooltip"] = 'Remove the CPS cap';
	});
end)
	
velo.run(function()
	local Length: table = {["Value"] = 14.4}
	Reach = vape.Categories.Combat:CreateModule({
		["Name"] = 'Reach',
		["Function"] = function(callback: boolean): void
			bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = callback and Length["Value"] + 2 or 14.4
		end,
		["Tooltip"] = 'Extends attack reach'
	})
	Length = Reach:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 0,
		["Max"] = 18,
		["Function"] = function(val)
			if Reach["Enabled"] then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2;
			end;
		end,
		["Suffix"] = function(val) 
			return val == 1 and 'stud' or 'studs' 
		end
	})
end)
	
velo.run(function()
	local Sprint: table =  {["Enabled"] = false};
	local old: any;
	Sprint = vape.Categories.Combat:CreateModule({
		["Name"] = 'Sprint',
		["Function"] = function(callback: boolean): void
			if callback then
				if inputService.TouchEnabled then 
					pcall(function() 
						lplr.PlayerGui.MobileUI['4'].Visible = false; 
					end);
				end;
				old = bedwars.SprintController.stopSprinting;
				bedwars.SprintController.stopSprinting = function(...)
					local call: any = old(...);
					bedwars.SprintController:startSprinting()
					return call;
				end;
				Sprint:Clean(entitylib.Events.LocalAdded:Connect(function() 
					task.delay(0.1, function() 
						bedwars.SprintController:stopSprinting(); 
					end);
				end));
				bedwars.SprintController:stopSprinting();
			else
				if inputService.TouchEnabled then 
					pcall(function() 
						lplr.PlayerGui.MobileUI['4'].Visible = true; 
					end); 
				end;
				bedwars.SprintController.stopSprinting = old;
				bedwars.SprintController:stopSprinting();
			end;
		end,
		["Tooltip"] = 'Sets your sprinting to true.'
	});
end)
	
velo.run(function()
	local TriggerBot: table = {["Enabled"] = false};
	local CPS: table = {["Value"] = 7};
	local rayParams: any = RaycastParams.new();
	TriggerBot = vape.Categories.Combat:CreateModule({
		["Name"] = 'TriggerBot',
		["Function"] = function(callback: boolean): void
			if callback then 
				repeat
					local doAttack: any;
					if not bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then
						if entitylib.isAlive and store.hand.toolType == 'sword' and bedwars.DaoController.chargingMaid == nil then
							local attackRange: any = bedwars.ItemMeta[store.hand.tool["Name"]].sword.attackRange;
							rayParams.FilterDescendantsInstances = {lplr.Character};
							local unit: any = lplr:GetMouse().UnitRay;
							local localPos: Vector3 = entitylib.character.RootPart.Position;
							local rayRange: any = (attackRange or 14.4);
							local ray: any = bedwars.QueryUtil:raycast(unit.Origin, unit.Direction * 200, rayParams);
							if ray and (localPos - ray.Instance.Position).Magnitude <= rayRange then 
								local limit: any = (attackRange);
								for _, ent in entitylib.List do 
									doAttack = ray.Instance:IsDescendantOf(ent.Character) and (localPos - ent.RootPart.Position).Magnitude <= rayRange;
									if doAttack then 
										break;
									end;
								end;
							end;
	
							doAttack = doAttack or bedwars.SwordController:getTargetInRegion(attackRange or 3.8 * 3, 0)
							if doAttack then 
								bedwars.SwordController:swingSwordAtMouse();
							end;
						end;
					end;
	
					task.wait(doAttack and 1 / CPS.GetRandomValue() or 0.016);
				until not TriggerBot["Enabled"];
			end;
		end,
		["Tooltip"] = 'Automatically swings when hovering over a entity'
	})
	CPS = TriggerBot:CreateTwoSlider({
		["Name"] = 'CPS',
		["Min"] = 1,
		["Max"] = 9,
		["DefaultMin"] = 7,
		["DefaultMax"] = 7
	})
end)
	
velo.run(function()
	local Velocity: table = {["Enabled"] = false};
	local Horizontal: table = {["Value"] = 100};
	local Vertical: table = {["Value"] = 100};
	local Chance: table = {["Value"] = 100};
	local TargetCheck: table = {["Enabled"] = false};
	local rand: any, old: any = Random.new()
	Velocity = vape.Categories.Combat:CreateModule({
		["Name"] = 'Velocity',
		["Function"] = function(callback: boolean): void
			if callback then
				old = bedwars.KnockbackUtil.applyKnockback;
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					if rand:NextNumber(0, 100) > Chance["Value"] then return end
					local check: any = (not TargetCheck["Enabled"]) or entitylib.EntityPosition({
						Range = 50,
						Part = 'RootPart',
						Players = true
					});
					if check then
						knockback = knockback or {};
						if Horizontal["Value"] == 0 and Vertical["Value"] == 0 then return; end;
						knockback.horizontal = (knockback.horizontal or 1) * (Horizontal["Value"] / 100);
						knockback.vertical = (knockback.vertical or 1) * (Vertical["Value"] / 100);
					end;
					return old(root, mass, dir, knockback, ...);
				end;
			else
				bedwars.KnockbackUtil.applyKnockback = old;
			end;
		end,
		["Tooltip"] = 'Reduces knockback taken'
	})
	Horizontal = Velocity:CreateSlider({
		["Name"] = "Horizontal",
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 0,
		["Suffix"] = '%'
	})
	Vertical = Velocity:CreateSlider({
		["Name"] = "Vertical",
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 0,
		["Suffix"] = '%'
	})
	Chance = Velocity:CreateSlider({
		["Name"] = 'Chance',
		["Min"] = 0,
		["Max"] = 100,
		["Default"] = 100,
		["Suffix"] = '%'
	})
	TargetCheck = Velocity:CreateToggle({Name = 'Only when targeting'})
end)

local AntiFallDirection: any;
velo.run(function()
	local AntiFall: table = {["Enabled"] = false};
	local Mode: table = {["Value"] = "Velocity"};
	local Material: table = {["Value"] = "Plastic"};
	local Color: table = {}
	local rayCheck: RaycastParams = RaycastParams.new()
	rayCheck.RespectCanCollide = true;

	local function getNearGround(): (any, any)
		local localPosition: Vector3, mag: any, closest: number? = entitylib.character.RootPart.Position, 60
		local blocks: Instance? = getBlocksInPoints(bedwars.BlockController:getBlockPosition(localPosition - Vector3.new(30, 30, 30)), bedwars.BlockController:getBlockPosition(localPosition + Vector3.new(30, 30, 30)));
		for _, v in blocks do
			if not getPlacedBlock(v + Vector3.new(0, 3, 0)) then
				local newmag: Vector3? = (localPosition - v).Magnitude;
				if newmag < mag then
					mag, closest = newmag, v + Vector3.new(0, 3, 0);
				end;
			end;
		end;
		table.clear(blocks);
		return closest;
	end;

	local function getLowGround(): (any, any)
		local mag: number = math.huge;
		for _, pos in bedwars.BlockController:getStore():getAllBlockPositions() do
			pos = pos * 3;
			if pos.Y < mag and not getPlacedBlock(pos + Vector3.new(0, 3, 0)) then
				mag = pos.Y;
			end;
		end;
		return mag;
	end;
	AntiFall = vape.Categories.Blatant:CreateModule({
		["Name"] = 'AntiFall',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat task.wait() until store.matchState ~= 0 or (not AntiFall["Enabled"]);
				if not AntiFall["Enabled"] then 
					return; 
				end;
				local pos: any, debounce: number? = getLowGround(), tick();
				if pos ~= math.huge then
					AntiFallPart = Instance.new('Part');
					AntiFallPart.Size = Vector3.new(10000, 1, 10000);
					AntiFallPart.Transparency = 1 - Color.Opacity;
					AntiFallPart.Material = Enum.Material[Material["Value"]];
					AntiFallPart.Color = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value);
					AntiFallPart.Position = Vector3.new(0, pos - 2, 0);
					AntiFallPart.CanCollide = Mode["Value"] == 'Collide';
					AntiFallPart.Anchored = true;
					AntiFallPart.CanQuery = false;
					AntiFallPart.Parent = workspace;
					AntiFall:Clean(AntiFallPart);
					AntiFall:Clean(AntiFallPart.Touched:Connect(function(touched)
						if touched.Parent == lplr.Character and entitylib.isAlive and debounce < tick() then
							debounce = tick() + 0.1;
							if Mode["Value"] == 'Normal' then
								local top: any = getNearGround();
								if top then
									local lastTeleport: any = lplr:GetAttribute('LastTeleported');
									local connection: any;
									connection = runService.PreSimulation:Connect(function()
										if vape.Modules.Fly.Enabled or vape.Modules.InfiniteFly.Enabled or vape.Modules.LongJump.Enabled then
											connection:Disconnect();
											AntiFallDirection = nil;
											return;
										end;

										if entitylib.isAlive and lplr:GetAttribute('LastTeleported') == lastTeleport then
											local delta: Vector3? = ((top - entitylib.character.RootPart.Position) * Vector3.new(1, 0, 1));
											local root: RootPart? = entitylib.character.RootPart;
											AntiFallDirection = delta.Unit == delta.Unit and delta.Unit or Vector3.zero;
											root.Velocity *= Vector3.new(1, 0, 1);
											rayCheck.FilterDescendantsInstances = {gameCamera, lplr.Character};
											rayCheck.CollisionGroup = root.CollisionGroup;

											local ray: RaycastResult? = workspace:Raycast(root.Position, AntiFallDirection, rayCheck);
											if ray then
												for _ = 1, 10 do
													local dpos: Vector3? = roundPos(ray.Position + ray.Normal * 1.5) + Vector3.new(0, 3, 0);
													if not getPlacedBlock(dpos) then
														top = Vector3.new(top.X, pos.Y, top.Z);
														break;
													end;
												end;
											end;

											root.CFrame += Vector3.new(0, top.Y - root.Position.Y, 0);
											if not frictionTable.Speed then
												root.AssemblyLinearVelocity = (AntiFallDirection * getSpeed()) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0);
											end;

											if delta.Magnitude < 1 then
												connection:Disconnect();
												AntiFallDirection = nil;
											end;
										else
											connection:Disconnect();
											AntiFallDirection = nil;
										end;
									end);
									AntiFall:Clean(connection);
								end;
							elseif Mode["Value"] == 'Velocity' then
								entitylib.character.RootPart.Velocity = Vector3.new(entitylib.character.RootPart.Velocity.X, 100, entitylib.character.RootPart.Velocity.Z);
							end;
						end;
					end));
				end;
			else
				AntiFallDirection = nil;
			end;
		end,
		["Tooltip"] = 'Help\'s you with your Parkinson\'s\nPrevents you from falling into the void.'
	})
	Mode = AntiFall:CreateDropdown({
		["Name"] = 'Move Mode',
		["List"] = {'Normal', 'Collide', 'Velocity'},
		["Function"] = function(val)
			if AntiFallPart then
				AntiFallPart.CanCollide = val == 'Collide';
			end;
		end,
		["Tooltip"] = 'Normal - Smoothly moves you towards the nearest safe point\nVelocity - Launches you upward after touching\nCollide - Allows you to walk on the part'
	})
	local materials: table? = {'ForceField'}
	for _, v in Enum.Material:GetEnumItems() do
		if v["Name"] ~= 'ForceField' then
			table.insert(materials, v["Name"]);
		end;
	end;
	Material = AntiFall:CreateDropdown({
		["Name"] = 'Material',
		["List"] = materials,
		["Function"] = function(val)
			if AntiFallPart then 
				AntiFallPart.Material = Enum.Material[val]; 
			end;
		end;
	})
	Color = AntiFall:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultOpacity"] = 0.5,
		["Function"] = function(h, s, v, o)
			if AntiFallPart then
				AntiFallPart.Color = Color3.fromHSV(h, s, v);
				AntiFallPart.Transparency = 1 - o;
			end;
		end;
	})
end)

-- skidded from catvape. Why? I am busy with Ink game and since Im the only dev I got lazy.
-- So this is TEMEPORAY NOT PERMNAMENT, I WILL REMOVE THIS CODE
-- ALL credits to MaxLaserTech and QwertyUI		
getgenv().FlyLandTick = tick()
local NoFall
run(function()
	local Mode
	local rayParams = RaycastParams.new()
	local tracked
	local oldroot
	local clone
	local hip = 2.3
	local function createClone()
		if entitylib.isAlive and entitylib.character.Humanoid.Health > 0 and (not oldroot or not oldroot.Parent) then
			hip = entitylib.character.Humanoid.HipHeight
			oldroot = entitylib.character.HumanoidRootPart
			if not lplr.Character.Parent then return false end
			lplr.Character.Parent = game
			clone = oldroot:Clone()
			clone.Parent = lplr.Character
			oldroot.Transparency = 0
			Instance.new('Highlight', oldroot)
			oldroot.Parent = gameCamera
			store.rootpart = clone
			bedwars.QueryUtil:setQueryIgnored(oldroot, true)
			lplr.Character.PrimaryPart = clone
			lplr.Character.Parent = workspace
			for _, v in lplr.Character:GetDescendants() do
				if v:IsA('Weld') or v:IsA('Motor6D') then
					if v.Part0 == oldroot then v.Part0 = clone end
					if v.Part1 == oldroot then v.Part1 = clone end
				end
			end
			return true
		end
		return false
	end
	local function destroyClone()
		if not oldroot or not oldroot.Parent or not entitylib.isAlive then return false end
		lplr.Character.Parent = game
		oldroot.Parent = lplr.Character
		lplr.Character.PrimaryPart = oldroot
		lplr.Character.Parent = workspace
		for _, v in lplr.Character:GetDescendants() do
			if v:IsA('Weld') or v:IsA('Motor6D') then
				if v.Part0 == clone then v.Part0 = oldroot end
				if v.Part1 == clone then v.Part1 = oldroot end
			end
		end
		oldroot.CanCollide = true
		if clone then
			clone:Destroy()
			clone = nil
		end
		entitylib.character.Humanoid.HipHeight = hip or 2.6
		oldroot.Transparency = 1
		oldroot = nil
		store.rootpart = nil
	end
	NoFall = vape.Categories.Blatant:CreateModule({
		["Name"] = 'NoFall',
		["Function"] = function(callback: boolean): void
			if callback then
				local tracked = 0
				local extraGravity = 0
				if Mode.Value == 'Spoof' then
					NoFall:Clean(runService.PreSimulation:Connect(function(dt)
						if entitylib.isAlive then
							local root = entitylib.character.RootPart
							if root.AssemblyLinearVelocity.Y < -85 then
								rayParams.FilterDescendantsInstances = {lplr.Character, gameCamera}
								rayParams.CollisionGroup = root.CollisionGroup
								local rootSize = root.Size.Y / 2 + entitylib.character.HipHeight
								local ray = workspace:Blockcast(root.CFrame, Vector3.new(3, 3, 3), Vector3.new(0, (tracked * 0.1) - rootSize, 0), rayParams)
								if not ray then
									root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -86, root.AssemblyLinearVelocity.Z)
									root.CFrame += Vector3.new(0, extraGravity * dt, 0)
									extraGravity += -workspace.Gravity * dt
								end
							else
								extraGravity = 0
							end
						end
					end))
				else
					local rootylevel = nil
					NoFall:Clean(runService.PostSimulation:Connect(function()
						if ((workspace:GetServerTimeNow() - lplr:GetAttribute('LastTeleported')) < 2 or tick() < FlyLandTick or not entitylib.isAlive or not isnetworkowner((oldroot and oldroot.Parent) and oldroot or entitylib.character.RootPart) or pingSpiking) and oldroot and oldroot.Parent then
							destroyClone()
							return
						end
						if oldroot and oldroot.Parent then
							oldroot.CFrame = CFrame.lookAlong(Vector3.new(clone.Position.X, rootylevel or clone.Position.Y, clone.Position.Z), clone.CFrame.LookVector)
							oldroot.AssemblyLinearVelocity = Vector3.zero
						end
					end))
					repeat
						if (workspace:GetServerTimeNow() - lplr:GetAttribute('LastTeleported')) < 2 or (tick() < FlyLandTick) or not entitylib.isAlive or not isnetworkowner((oldroot and oldroot.Parent) and oldroot or entitylib.character.RootPart) or pingSpiking then
							task.wait();
							continue;
						else
							if not oldroot or not oldroot.Parent then
								createClone();
							end;
							rayParams.FilterDescendantsInstances = {lplr.Character, gameCamera, oldroot, clone}
							rayParams.CollisionGroup = oldroot.CollisionGroup
							if (tick() - entitylib.character.AirTime) < 1.6 then
								local raycast = workspace:Blockcast(clone.CFrame, Vector3.new(3, 3, 3), Vector3.new(0, -7, 0), rayParams)
								local uppercast = workspace:Blockcast(clone.CFrame, Vector3.new(3, 3, 3), Vector3.new(0, 6.1, 0), rayParams)
								if raycast then
									rootylevel = uppercast and (uppercast.Position.Y - 1) or (clone.CFrame.Y + 6)
									task.wait(0.1)
									rootylevel = nil
									task.wait(0.1)
								end
							end
						end
						task.wait()
					until not NoFall["Enabled"]
				end
			else
				destroyClone()
			end
		end,
		Tooltip = 'Prevents you from taking fall damage.'
	})
	Mode = NoFall:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Spoof', 'Packet'},
		["Default"] = 'Spoof',
		["Function"] = function()
			if NoFall.Enabled then
				NoFall:Toggle()
				NoFall:Toggle()
			end
		end
	})
end)

-- sorry skidded catvape, too busy with ink game anticheat
local namecall; namecall = hookmetamethod(game, '__namecall', function(self, ...)
	if getnamecallmethod() == 'FireServer' and tostring(self) == 'GroundHit' and NoFall.Enabled then
		local args = {...}
		if args[3] then
			args[3] = 1/1
		end
		return namecall(self, unpack(args))
	end
	return namecall(self, ...)
end)

velo.run(function()
	local Mode: table = {};
	local Expand: table = {};
	local objects: any, set: any = {}
	
	local function createHitbox(ent: any)
		if ent.Targetable and ent.Player then
			local hitbox: Part = Instance.new('Part');
			hitbox.Size = Vector3.new(3, 6, 3) + Vector3.one * (Expand.Value / 5);
			hitbox.Position = ent.RootPart.Position;
			hitbox.CanCollide = false;
			hitbox.Massless = true;
			hitbox.Color = Color3.fromHSV(Color.Hue or 0, Color.Sat or 0, Color.Val or 1)
			hitbox.Transparency = 1;
			hitbox.Parent = ent.Character;
			local weld: Motor6D = Instance.new('Motor6D');
			weld.Part0 = hitbox;
			weld.Part1 = ent.RootPart;
			weld.Parent = hitbox;
			objects[ent] = hitbox;
		end;
	end;
	
	HitBoxes = vape.Categories.Blatant:CreateModule({
		["Name"] = 'HitBoxes',
		["Function"] = function(callback: boolean): void
			if callback then
				debug.setconstant(bedwars.SwordController.swingSwordInRegion, 6, callback and (Expand["Value"] / 3) or 3.8);
				if Mode["Value"] == 'Sword' then
					debug.setconstant(bedwars.SwordController.swingSwordInRegion, 6, (Expand["Value"] / 3));
					set = true;
				else
					HitBoxes:Clean(entitylib.Events.EntityAdded:Connect(createHitbox));
					HitBoxes:Clean(entitylib.Events.EntityRemoving:Connect(function(ent)
						if objects[ent] then
							objects[ent]:Destroy();
							objects[ent] = nil;
						end;
					end));
					for _, ent in entitylib.List do
						createHitbox(ent);
					end;
				end;
			else
				if set then
					debug.setconstant(bedwars.SwordController.swingSwordInRegion, 6, 3.8);
					set = nil;
				end;
				for _: any, part: any in objects do
					part:Destroy();
				end;
				table.clear(objects);
			end;
		end,
		["Tooltip"] = 'Expands attack hitbox'
	})
	Mode = HitBoxes:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Sword', 'Player'},
		["Function"] = function()
			if HitBoxes["Enabled"] then
				HitBoxes:Toggle()
				HitBoxes:Toggle()
			end
		end,
		Tooltip = 'Sword - Increases the range around you to hit entities\nPlayer - Increases the players hitbox'
	})
	Expand = HitBoxes:CreateSlider({
		["Name"] = 'Expand amount',
		["Min"] = 0,
		["Max"] = 14.4,
		["Default"] = 14.4,
		["Decimal"] = 10,
		["Function"] = function(val)
			if HitBoxes["Enabled"] then
				if Mode["Value"] == 'Sword' then
					debug.setconstant(bedwars.SwordController.swingSwordInRegion, 6, (val / 3));
				else
					for _, part in objects do
						part.Size = Vector3.new(3, 6, 3) + Vector3.one * (val / 5);
					end;
				end;
			end;
		end,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs';
		end;
	})
	Color = HitBoxes:CreateColorSlider({
		["Name"] = "Hitbox Color",
		["HoverText"] = "Color of the hitbox parts.",
		["Function"] = function(h, s, v)
			Color.Hue = h
			Color.Sat = s
			Color.Val = v
			local col = Color3.fromHSV(h, s, v)
			for _, part in objects do
				if part and part:IsA("BasePart") then
					part.Color = col
				end
			end
		end
	})
end)

velo.run(function()
	vape.Categories.Blatant:CreateModule({
		["Name"] = 'KeepSprint',
		["Function"] = function(callback: boolean): void
			debug.setconstant(bedwars.SprintController.startSprinting, 5, callback and 'blockSprinting' or 'blockSprint')
			bedwars.SprintController:stopSprinting()
		end,
		["Tooltip"] = 'Lets you sprint with a speed potion.'
	})
end)

local Fly: any;
local LongJump: any;
velo.run(function()
        local Value: table = {}
        local VerticalValue: table = {}
        local WallCheck: table? = {}
        local PopBalloons: table? = {}
        local TP: table? = {}
        local rayCheck: any = RaycastParams.new();
        rayCheck.RespectCanCollide = true;
        local up: number?, down: number?, old: any = 0, 0;
        Fly = vape.Categories.Blatant:CreateModule({
                ["Name"] = 'Fly',
                ["Function"] = function(callback: boolean): void
                        frictionTable.Fly = callback or nil;
                        updateVelocity();
                        if callback then
                                up, down, old = 0, 0, bedwars.BalloonController.deflateBalloon
                                bedwars.BalloonController.deflateBalloon = function() end
                                local tpTick: number?, tpToggle: boolean?, oldy: any = tick(), true;

                                if lplr.Character and (lplr.Character:GetAttribute('InflatedBalloons') or 0) == 0 and getItem('balloon') then
                                        bedwars.BalloonController:inflateBalloon();
                                end;
                                Fly:Clean(vapeEvents.AttributeChanged.Event:Connect(function(changed)
                                        if changed == 'InflatedBalloons' and (lplr.Character:GetAttribute('InflatedBalloons') or 0) == 0 and getItem('balloon') then
                                                bedwars.BalloonController:inflateBalloon();
                                        end;
                                end));
                                Fly:Clean(runService.PreSimulation:Connect(function(dt)
                                        if entitylib.isAlive and not InfiniteFly.Enabled and isnetworkowner(entitylib.character.RootPart) then
                                                local flyAllowed: boolean? = (lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or store.matchState == 2;
                                                local mass: number? = (1.5 + (flyAllowed and 6 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)) + ((up + down) * VerticalValue["Value"]);
                                                local root: any, moveDirection: any = entitylib.character.RootPart, entitylib.character.Humanoid.MoveDirection;
                                                local velo: number = getSpeed();
                                                local destination: number? = (moveDirection * math.max(Value["Value"] - velo, 0) * dt);
                                                rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, AntiFallPart};
                                                rayCheck.CollisionGroup = root.CollisionGroup;

                                                if WallCheck["Enabled"] then
                                                        local ray: Raycast? = workspace:Raycast(root.Position, destination, rayCheck);
                                                        if ray then
                                                                destination = ((ray.Position + ray.Normal) - root.Position);
                                                        end;
                                                end;

                                                if not flyAllowed then
                                                        if tpToggle then
                                                                local airleft: number? = (tick() - entitylib.character.AirTime)
                                                                if airleft > 2 then
                                                                        if not oldy then
                                                                                local ray: any = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rayCheck)
                                                                                if ray and TP["Enabled"] then
                                                                                        tpToggle = false;
                                                                                        oldy = root.Position.Y;
                                                                                        tpTick = tick() + 0.11;
                                                                                        root.CFrame = CFrame.lookAlong(Vector3.new(root.Position.X, ray.Position.Y + entitylib.character.HipHeight, root.Position.Z), root.CFrame.LookVector);
                                                                                end;
                                                                        end;
                                                                end;
                                                        else
                                                                if oldy then
                                                                        if tpTick < tick() then
                                                                                local newpos: any = Vector3.new(root.Position.X, oldy, root.Position.Z);
                                                                                root.CFrame = CFrame.lookAlong(newpos, root.CFrame.LookVector);
                                                                                tpToggle = true;
                                                                                oldy = nil;
                                                                        else
                                                                                mass = 0;
                                                                        end;
                                                                end;
                                                        end;
                                                end;

                                                root.CFrame += destination;
                                                root.AssemblyLinearVelocity = (moveDirection * velo) + Vector3.new(0, mass, 0);
                                        end;
                                end));
                                Fly:Clean(inputService.InputBegan:Connect(function(input)
                                        if not inputService:GetFocusedTextBox() then
                                                if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
                                                        up = 1;
                                                elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL2 then
                                                        down = -1;
                                                end;
                                        end;
                                end));
                                Fly:Clean(inputService.InputEnded:Connect(function(input)
                                        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
                                                up = 0;
                                        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL2 then
                                                down = 0;
                                        end;
                                end));
                                if inputService.TouchEnabled then
                                        pcall(function()
                                                local jumpButton: any = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton;
                                                Fly:Clean(jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
                                                        up = jumpButton.ImageRectOffset.X == 146 and 1 or 0;
                                                end));
                                        end);
                                end;
                        else
                                bedwars.BalloonController.deflateBalloon = old;
                                if PopBalloons.Enabled and entitylib.isAlive and (lplr.Character:GetAttribute('InflatedBalloons') or 0) > 0 then
                                        for _ = 1, 3 do
                                                bedwars.BalloonController:deflateBalloon();
                                        end;
                                end;
                        end;
                end,
                ["ExtraText"] = function()
                        return 'Heatseeker'
                end,
                ["Tooltip"] = 'Makes you go zoom.'
        })
        Value = Fly:CreateSlider({
                ["Name"] = 'Speed',
                ["Min"] = 1,
                ["Max"] = 23,
                ["Default"] = 23,
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
                        return val == 1 and 'stud' or 'studs';
                end;
        })
        WallCheck = Fly:CreateToggle({
                ["Name"] = 'Wall Check',
                ["Default"] = true
        })
        PopBalloons = Fly:CreateToggle({
                ["Name"] = 'Pop Balloons',
                ["Default"] = true
        })
        TP = Fly:CreateToggle({
                ["Name"] = 'TP Down',
                ["Default"] = true
        })
end)

local Attacking
run(function()
	local Killaura: table = {["Enabled"] = false};
	local Targets: table = {Players = {["Enabled"] = false}};
	local Sort: table = {};
	local SwingRange: table = {};
	local AttackRange: table = {};
	local ChargeTime: table = {};
	local UpdateRate: table = {["Value"] = 540};
	local AngleSlider: table = {["Value"] = 360};
	local MaxTargets: table = {["Value"] = 5};
	local Mouse: table = {};
	local Swing: table = {};
	local GUI: table = {};
	local BoxSwingColor: table = {};
	local BoxAttackColor: table = {};
	local ParticleTexture: table = {};
	local ParticleColor1: table = {};
	local ParticleColor2: table = {};
	local ParticleSize: table = {};
	local Face: table = {};
	local Animation: table = {};
	local AnimationMode: table = {};
	local AnimationSpeed: table = {};
	local AnimationTween: table = {};
	local Limit: table = {};
	local LegitAura: table? = {}
	local Particles: table?, Boxes: table? = {}, {}
	local anims: any, AnimDelay: any, AnimTween: any, armC0: any = vape.Libraries.auraanims, tick()
	local AttackRemote: any = {FireServer = function() end};
	task.spawn(function()
		AttackRemote = bedwars.Client:Get(remotes.AttackEntity).instance;
	end);
	local lastSwingServerTime: number = 0;
	local lastSwingServerTimeDelta: number = 0;
	local function getAttackData(): (any, any)
		if Mouse["Enabled"] then
			if not inputService:IsMouseButtonPressed(0) then return false; end;
		end;
		if GUI["Enabled"] then
			if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then return false; end;
		end;

		local sword: any = Limit["Enabled"] and store.hand or store.tools.sword;
		if not sword or not sword.tool then return false; end;

		local meta: any = bedwars.ItemMeta[sword.tool["Name"]];
		if Limit["Enabled"] then
			if store.hand.toolType ~= 'sword' or bedwars.DaoController.chargingMaid then return false; end;
		end;
		if LegitAura["Enabled"] then
			if (tick() - bedwars.SwordController.lastSwing) > 0.2 then return false; end;
		end;
		return sword, meta;
	end;
	local killaurarangecirclepart: Instance? = nil;
	local killaurarangecircle: table = {};
	local killauracolor: table = {};
	Killaura = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Killaura',
		["Function"] = function(callback: boolean): void
			if callback then
				if inputService.TouchEnabled then
					pcall(function()
						lplr.PlayerGui.MobileUI['2'].Visible = Limit.Enabled
					end)
				end
				if inputService.TouchEnabled then 
					pcall(function() 
						lplr.PlayerGui.MobileUI['2'].Visible = Limit["Enabled"];
					end); 
				end;
				if Animation["Enabled"] then
					local fake: any = {
						Controllers = {
							ViewmodelController = {
								isVisible = function()
									return not Attacking
								end,
								playAnimation = function(...)
									if not Attacking then
										bedwars.ViewmodelController:playAnimation(select(2, ...))
									end;
								end;
							}
						}
					};
					if killaurarangecircle["Enabled"] and killaurarangecirclepart == nil and Killaura["Enabled"] then
			                    	killaurarangecirclepart = Instance.new("MeshPart");
			                    	killaurarangecirclepart.MeshId = "rbxassetid://3726303797";
			                    	killaurarangecirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
			                    	killaurarangecirclepart.CanCollide = false;
			                    	killaurarangecirclepart.Anchored = true;
			                    	killaurarangecirclepart.Material = Enum.Material.Neon;
			                    	killaurarangecirclepart.Size = Vector3.new(AttackRange.Value * 0.7, 0.01, AttackRange.Value * 0.7);
			                    	killaurarangecirclepart.Parent = gameCamera;
			                    	bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true);
			                end;

					task.spawn(function()
						local started: boolean = false;
						repeat
							if Attacking then
								if not armC0 then 
									armC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0; 
								end;
								local first: any = not started;
								started = true;

								if AnimationMode["Value"]== 'Random' then
									anims.Random = {{CFrame = CFrame.Angles(math.rad(math.random(1, 360)), math.rad(math.random(1, 360)), math.rad(math.random(1, 360))), Time = 0.12}};
								end;

								for _, v in anims[AnimationMode["Value"]] do
									AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(first and (AnimationTween["Enabled"] and 0.001 or 0.1) or v.Time / AnimationSpeed["Value"], Enum.EasingStyle.Linear), {
										C0 = armC0 * v.CFrame
									});
									AnimTween:Play();
									AnimTween.Completed:Wait();
									first = false;
									if (not Killaura["Enabled"]) or (not Attacking) then break; end;
								end;
							elseif started then
								started = false;
								AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(AnimationTween["Enabled"] and 0.001 or 0.3, Enum.EasingStyle.Exponential), {
									C0 = armC0
								});
								AnimTween:Play()
							end;

							if not started then 
								task.wait(1 / UpdateRate["Value"]);
							end;
						until (not Killaura["Enabled"]) or (not Animation["Enabled"]);
					end);
				end;

				local swingCooldown: number = 0;
				lastSwingServerTime = Workspace:GetServerTimeNow();
                		lastSwingServerTimeDelta = 0;				
				repeat
					if killaurarangecircle["Enabled"] and killaurarangecirclepart then
			                        if entitylib.isAlive and entitylib.character.HumanoidRootPart then
			                            	killaurarangecirclepart.Position = entitylib.character.HumanoidRootPart.Position - Vector3.new(0, entitylib.character.Humanoid.HipHeight, 0)
			                        end
			                end
					local attacked: any, sword: any, meta: any = {}, getAttackData();
					Attacking = false;
					store.KillauraTarget = nil;
					if sword then
						local plrs: any = entitylib.AllPosition({
							Range = SwingRange.Value,
							Wallcheck = Targets.Walls.Enabled or nil,
							Part = 'RootPart',
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Limit = MaxTargets.Value,
							Sort = sortmethods[Sort.Value]
						});

						if #plrs > 0 then
							switchItem(sword.tool, 0);
							local selfpos: Vector3? = entitylib.character.RootPart.Position;
							local localfacing: Vector3? = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1);

							for _: any, v: any in plrs do
								if workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack < ChargeTime.Value then continue end				
								local delta: number? = (v.RootPart.Position - selfpos);
								local angle: number? = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit));
								if angle > (math.rad(AngleSlider["Value"]) / 2) then continue; end;

								table.insert(attacked, {
									Entity = v,
									Check = delta.Magnitude > AttackRange.Value and BoxSwingColor or BoxAttackColor
								});
								targetinfo.Targets[v] = tick() + 1;

								if not Attacking then
									Attacking = true;
									store.KillauraTarget = v;
									if not Swing["Enabled"] and AnimDelay <= tick() and not LegitAura["Enabled"] then
										AnimDelay = tick() + (meta.sword.respectAttackSpeedForEffects and meta.sword.attackSpeed or 0.25);
										bedwars.SwordController:playSwordEffect(meta, false);
										if meta.displayName:find(' Scythe') then 
											bedwars.ScytheController:playLocalAnimation();
										end;

										if vape.ThreadFix then 
											setthreadidentity(8); 
										end;
									end;
								end;

								if delta.Magnitude > AttackRange["Value"] then continue; end;
								if delta.Magnitude < 14.4 and (tick() - swingCooldown) < ChargeTime["Value"] then continue; end;
								local actualRoot: any = v.Character.PrimaryPart;
								if actualRoot then
									local dir: any = CFrame.lookAt(selfpos, actualRoot.Position).LookVector;
									local pos: any = selfpos + dir * math.max(delta.Magnitude - 14.399, 0);
									swingCooldown = tick();
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
                                    					bedwars.SwordController.lastSwingServerTime = workspace:GetServerTimeNow()
									lastSwingServerTimeDelta = workspace:GetServerTimeNow() - lastSwingServerTime
                                    					lastSwingServerTime = workspace:GetServerTimeNow()
									store.attackReach = (delta.Magnitude * 100) // 1 / 100;
									store.attackReachUpdate = tick() + 1;

									if delta.Magnitude < 14.4 and ChargeTime["Value"] > 0.11 then
										AnimDelay = tick();
									end;

									AttackRemote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = 0},
										lastSwingServerTimeDelta = lastSwingServerTimeDelta,
										entityInstance = v.Character,
										validate = {
											raycast = {
												cameraPosition = {value = pos},
												cursorDirection = {value = dir}
											},
											targetPosition = {value = actualRoot.Position},
											selfPosition = {value = pos}
										}
									});
								end;
							end;
						end;
					end;

					for i: any, v: any in Boxes do
						v.Adornee = attacked[i] and attacked[i].Entity.RootPart or nil
						if v.Adornee then
							v.Color3 = Color3.fromHSV(attacked[i].Check.Hue, attacked[i].Check.Sat, attacked[i].Check.Value)
							v.Transparency = 1 - attacked[i].Check.Opacity
						end;
					end;

					for i: any, v: any in Particles do
						v.Position = attacked[i] and attacked[i].Entity.RootPart.Position or Vector3.new(9e9, 9e9, 9e9);
						v.Parent = attacked[i] and gameCamera or nil;
					end;

					if Face["Enabled"] and attacked[1] then
						local vec: Vector3? = attacked[1].Entity.RootPart.Position * Vector3.new(1, 0, 1);
						entitylib.character.RootPart.CFrame = CFrame.lookAt(entitylib.character.RootPart.Position, Vector3.new(vec.X, entitylib.character.RootPart.Position.Y + 0.001, vec.Z));
					end;

					--#attacked > 0 and #attacked * 0.02 or
					task.wait(1 / UpdateRate.Value);
				until not Killaura.Enabled;
			else
				if killaurarangecirclepart then 
				        killaurarangecirclepart:Destroy();
				        killaurarangecirclepart = nil;
				end;
				store.KillauraTarget = nil
				for _, v in Boxes do
					v.Adornee = nil;
				end;
				for _, v in Particles do
					v.Parent = nil;
				end;
				if inputService.TouchEnabled then
					pcall(function()
						lplr.PlayerGui.MobileUI['2'].Visible = true;
					end);
				end;
				debug.setupvalue(oldSwing or bedwars.SwordController.playSwordEffect, 6, bedwars.Knit);
				debug.setupvalue(bedwars.ScytheController.playLocalAnimation, 3, bedwars.Knit);
				Attacking = false;
				if armC0 then
					AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(AnimationTween.Enabled and 0.001 or 0.3, Enum.EasingStyle.Exponential), {
						C0 = armC0
					});
					AnimTween:Play();
				end;
			end;
		end,
		["ExtraText"] = function() return "Public" end;
		["Tooltip"] = 'Attack players around you\nwithout aiming at them.'
	})
	Targets = Killaura:CreateTargets({
		["Players"] = true, 
		["NPCs"] = true
	});
	local methods: table = {'Damage', 'Distance'}
	for i in sortmethods do
		if not table.find(methods, i) then
			table.insert(methods, i);
		end;
	end;
	SwingRange = Killaura:CreateSlider({
		["Name"] = 'Swing range',
		["Min"] = 1,
		["Max"] = 18,
		["Default"] = 18,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AttackRange = Killaura:CreateSlider({
		["Name"] = 'Attack range',
		["Min"] = 1,
		["Max"] = 18,
		["Default"] = 18,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	ChargeTime = Killaura:CreateSlider({
		["Name"] = 'Charge time',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.42,
		["Decimal"] = 100
	})
	AngleSlider = Killaura:CreateSlider({
		["Name"] = 'Max angle',
		["Min"] = 1,
		["Max"] = 360,
		["Default"] = 360
	})
	UpdateRate = Killaura:CreateSlider({
		["Name"] = 'Update rate',
		["Min"] = 1,
		["Max"] = 540,
		["Default"] = 60,
		["Suffix"] = 'hz'
	})
	MaxTargets = Killaura:CreateSlider({
		["Name"] = 'Entities',
		["Min"] = 1,
		["Max"] = 10,
		["Default"] = 5
	})
	Sort = Killaura:CreateDropdown({
		["Name"] = 'Target Mode',
		["List"] = methods
	})
	killaurarangecircle = Killaura:CreateToggle({
        	Name = "Range Visualizer",
        	Function = function(callback: boolean): void
            		if callback then 
                		killaurarangecirclepart = Instance.new("MeshPart")
		                killaurarangecirclepart.MeshId = "rbxassetid://3726303797"
		                killaurarangecirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
		                killaurarangecirclepart.CanCollide = false
		                killaurarangecirclepart.Anchored = true
		                killaurarangecirclepart.Material = Enum.Material.Neon
		                killaurarangecirclepart.Size = Vector3.new(AttackRange.Value * 0.7, 0.01, AttackRange.Value * 0.7)
		                if Killaura.Enabled then 
		                    	killaurarangecirclepart.Parent = gameCamera
		                end
		                bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true)
            		else
		                if killaurarangecirclepart then 
		                    	killaurarangecirclepart:Destroy()
		                    	killaurarangecirclepart = nil
		                end
            		end
        	end
    	})
    	killauracolor = Killaura:CreateColorSlider({
         	Name = 'colour',
         	Darker = true,
		DefaultHue = 0.6,
		DefaultOpacity = 0.5,
		Visible = true
	})
	Mouse = Killaura:CreateToggle({["Name"] = 'Require mouse down'})
	Swing = Killaura:CreateToggle({["Name"] = 'No Swing'})
	GUI = Killaura:CreateToggle({["Name"] = 'GUI check'})
	Killaura:CreateToggle({
		["Name"] = 'Show target',
		["Function"] = function(callback: boolean): void
			BoxSwingColor.Object.Visible = callback
			BoxAttackColor.Object.Visible = callback
			if callback then
				for i = 1, 10 do
					local box: BoxHandleAdornment = Instance.new('BoxHandleAdornment');
					box.Adornee = nil;
					box.AlwaysOnTop = true;
					box.Size = Vector3.new(6, 8, 6);
					box.CFrame = CFrame.new(0, -0.5, 0);
					box.ZIndex = 0;
					box.Parent = vape.gui;
					Boxes[i] = box;
				end;
			else
				for _, v in Boxes do 
					v:Destroy();
				end;
				table.clear(Boxes);
			end;
		end;
	})
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
				for i = 1, 10 do
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
						ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)), 
						ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
					});
					particles.Parent = part;
					Particles[i] = part;
				end;
			else
				for _, v in Particles do 
					v:Destroy();
				end;
				table.clear(Particles);
			end;
		end;
	})
	ParticleTexture = Killaura:CreateTextBox({
		["Name"] = 'Texture',
		["Default"] = 'rbxassetid://14736249347',
		["Function"] = function()
			for _, v in Particles do
				v.ParticleEmitter.Texture = ParticleTexture["Value"]
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
				});
			end;
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
		["Function"] = function(val)
			for _, v in Particles do
				v.ParticleEmitter.Size = NumberSequence.new(val);
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	Face = Killaura:CreateToggle({["Name"] = 'Face target'})
	Animation = Killaura:CreateToggle({
		["Name"] = 'Custom Animation',
		["Function"] = function(callback: boolean): void
			AnimationMode.Object.Visible = callback;
			AnimationTween.Object.Visible = callback;
			AnimationSpeed.Object.Visible = callback;
			if Killaura["Enabled"] then
				Killaura:Toggle();
				Killaura:Toggle();
			end;
		end;
	})
	local animnames: table = {}
	for i in anims do 
		table.insert(animnames, i);
	end;
	AnimationMode = Killaura:CreateDropdown({
		["Name"] = 'Animation Mode',
		["List"] = animnames,
		["Darker"] = true,
		["Visible"] = false
	})
	AnimationSpeed = Killaura:CreateSlider({
		["Name"] = 'Animation Speed',
		["Min"] = 0,
		["Max"] = 2,
		["Default"] = 1,
		["Decimal"] = 10,
		["Darker"] = true,
		["Visible"] = false
	})
	AnimationTween = Killaura:CreateToggle({
		["Name"] = 'No Tween',
		["Darker"] = true,
		["Visible"] = false
	})
	Limit = Killaura:CreateToggle({
		["Name"] = 'Limit to items',
		["Function"] = function(callback: boolean): void
			if inputService.TouchEnabled and Killaura["Enabled"] then 
				pcall(function() 
					lplr.PlayerGui.MobileUI['2'].Visible = callback;
				end);
			end;
		end,
		["Tooltip"] = 'Only attacks when the sword is held'
	});
	--[[LegitAura = Killaura:CreateToggle({
		Name = 'Swing only',
		Tooltip = 'Only attacks while swinging manually'
	})]]
end)
											
velo.run(function()
	local Value: table = {["Value"] = 38}
	local start: any;
	local JumpTick: number?, JumpSpeed: number?, Extend: any, Direction: any = tick(), 0, false;
	local projectileRemote: any = replicatedStorage.rbxts_include.node_modules['@rbxts'].net.out._NetManaged.ProjectileFire
	local knockbackRemote: any = replicatedStorage.rbxts_include.node_modules['@rbxts'].net.out._NetManaged.AckKnockback
	
	local function launchProjectile(item: {tool: any?, itemType: string?}, pos: Vector3?, proj: string?, speed: number?)
		if not pos then return; end;
		pos = pos - entitylib.character.RootPart.CFrame.LookVector * 0.1;
		local shootPosition: CFrame = (CFrame.lookAlong(pos, Vector3.new(0, -speed, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ)));
		switchItem(item.tool, 0);
		task.wait(0.2);
		bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta[proj], proj, proj, shootPosition.Position, '', shootPosition.LookVector * speed, {drawDurationSeconds = 1});
		if projectileRemote:InvokeServer(item.tool, proj, proj, shootPosition.Position, pos, shootPosition.LookVector * speed, httpService:GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045) then
			local shoot: string? = bedwars.ItemMeta[item.itemType].projectileSource.launchSound;
			shoot = shoot and shoot[math.random(1, #shoot)] or nil;
		end;
	end;
	local LongJumpMethods: table = {
		cannon = function(_, pos)
			pos = pos - Vector3.new(0, (entitylib.character.HipHeight + (entitylib.character.RootPart.Size.Y / 2)) - 3, 0);
			local rounded: Vector3? = Vector3.new(math.round(pos.X / 3) * 3, math.round(pos.Y / 3) * 3, math.round(pos.Z / 3) * 3);
			bedwars.placeBlock(rounded, 'cannon', false);
			task.delay(0, function()
				local block: any, blockpos: any = getPlacedBlock(rounded);
				if block and block["Name"] == 'cannon' and (entitylib.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then
					local vec: CFrame? = entitylib.character.HumanoidRootPart.CFrame.LookVector;
					local breaktype: any = bedwars.ItemMeta[block.Name].block.breakType;
					local tool: any = store.tools[breaktype];
					if tool then 
						switchItem(tool.tool) ;
					end;
					bedwars.Client:Get(remotes.CannonAim):SendToServer({
						cannonBlockPos = blockpos,
						lookVector = vec
					});
					local broken: number = 0.1;
					if bedwars.BlockController:calculateBlockDamage(lplr, {blockPosition = blockpos}) < block:GetAttribute('Health') then
						broken = 0.4;
						bedwars.breakBlock(block, true, true);
					end;
					task.delay(broken, function()
						for _ = 1, 3 do
							local call: any = bedwars.Client:Get(remotes.CannonLaunch):CallServer({cannonBlockPos = blockpos});
							if call then
								bedwars.breakBlock(block, true, true);
								JumpSpeed = 5.25 * Value["Value"]
								JumpTick = tick() + 2.3;
								Direction = Vector3.new(vec.X, 0, vec.Z).Unit;
								break;
							end;
							task.wait(0.1);
						end;
					end);
				end;
			end);
		end,
		cat = function()
			LongJump:Clean(vapeEvents.CatPounce.Event:Connect(function()
				local vec: CFrame? = entitylib.character.RootPart.CFrame.LookVector;
				JumpSpeed = 4.5 * Value["Value"];
				JumpTick = tick() + 2.5;
				Direction = Vector3.new(vec.X, 0, vec.Z).Unit;
				entitylib.character.RootPart.Velocity = Vector3.zero;
			end));
	
			if not bedwars.AbilityController:canUseAbility('CAT_POUNCE') then
				repeat task.wait() until bedwars.AbilityController:canUseAbility('CAT_POUNCE') or not LongJump["Enabled"];
			end;
	
			if bedwars.AbilityController:canUseAbility('CAT_POUNCE') and LongJump["Enabled"] then
				bedwars.AbilityController:useAbility('CAT_POUNCE');
			end;
		end,
		fireball = function(item, pos)
			launchProjectile(item, pos, 'fireball', 60);
		end,
		grappling_hook = function(item, pos)
			launchProjectile(item, pos, 'grappling_hook_projectile', 140);
		end,
		jade_hammer = function(item)
			if not bedwars.AbilityController:canUseAbility(item.itemType..'_jump') then
				repeat task.wait() until bedwars.AbilityController:canUseAbility(item.itemType..'_jump') or not LongJump["Enabled"];
			end;
			if bedwars.AbilityController:canUseAbility(item.itemType..'_jump') and LongJump["Enabled"] then
				bedwars.AbilityController:useAbility(item.itemType..'_jump');
				local vec: CFrame? = entitylib.character.RootPart.CFrame.LookVector;
				JumpSpeed = 2.5 * Value["Value"];
				JumpTick = tick() + 2.5;
				Direction = Vector3.new(vec.X, 0, vec.Z).Unit;
			end;
		end,
		tnt = function(item, pos)
			pos = pos - Vector3.new(0, (entitylib.character.HipHeight + (entitylib.character.RootPart.Size.Y / 2)) - 3, 0);
			local rounded: Vector3? = Vector3.new(math.round(pos.X / 3) * 3, math.round(pos.Y / 3) * 3, math.round(pos.Z / 3) * 3);
			start = Vector3.new(rounded.X, start.Y, rounded.Z) + (entitylib.character.RootPart.CFrame.LookVector * (item.itemType == 'pirate_gunpowder_barrel' and 2.6 or 0.2));
			bedwars.placeBlock(rounded, item.itemType, false);
		end,
		wood_dao = function(item, pos)
			if (lplr.Character:GetAttribute('CanDashNext') or 0) > workspace:GetServerTimeNow() or not bedwars.AbilityController:canUseAbility('dash') then
				repeat task.wait() until (lplr.Character:GetAttribute('CanDashNext') or 0) < workspace:GetServerTimeNow() and bedwars.AbilityController:canUseAbility('dash') or not LongJump["Enabled"];
			end;
			if LongJump["Enabled"] then
				bedwars.SwordController.lastAttack = workspace:GetServerTimeNow();
				switchItem(item.tool, 0.1);
				local vec: CFrame? = entitylib.character.RootPart.CFrame.LookVector;
				replicatedStorage['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].useAbility:FireServer('dash', {
					direction = vec,
					origin = pos,
					weapon = item.itemType
				});
				JumpSpeed = 4.5 * Value["Value"];
				JumpTick = tick() + 2.4;
				Direction = Vector3.new(vec.X, 0, vec.Z).Unit;
			end;
		end;
	};
	for _, v in {'stone_dao', 'iron_dao', 'diamond_dao', 'emerald_dao'} do
		LongJumpMethods[v] = LongJumpMethods.wood_dao;
	end;
	LongJumpMethods.void_axe = LongJumpMethods.jade_hammer;
	LongJumpMethods.siege_tnt = LongJumpMethods.tnt;
	LongJumpMethods.pirate_gunpowder_barrel = LongJumpMethods.tnt;
	LongJump = vape.Categories.Blatant:CreateModule({
		["Name"] = 'LongJump',
		["Function"] = function(callback: boolean): void
			frictionTable.LongJump = callback or nil
			updateVelocity();
			if callback then
				LongJump:Clean(vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and damageTable.fromEntity == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then
						local knockbackBoost: number = Value["Value"]* (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal or 1);
						if knockbackBoost >= JumpSpeed then
							local pos: Vector3? = damageTable.fromPosition and Vector3.new(damageTable.fromPosition.X, damageTable.fromPosition.Y, damageTable.fromPosition.Z) or damageTable.fromEntity and damageTable.fromEntity.PrimaryPart.Position;
							if not pos then return; end;
							local vec: Vector3? = (entitylib.character.RootPart.Position - pos);
							Extend = StoreDamage["Enabled"];
							JumpSpeed = knockbackBoost;
							JumpTick = tick() + (StoreDamage["Enabled"] and 4.3 or 2.5);
							Direction = Vector3.new(vec.X, 0, vec.Z).Unit;
						end;
					end;
				end));
				LongJump:Clean(vapeEvents.GrapplingHookFunctions.Event:Connect(function(dataTable)
					if dataTable.hookFunction == 'PLAYER_IN_TRANSIT' then
						local vec: CFrame? = entitylib.character.RootPart.CFrame.LookVector;
						JumpSpeed = 2.5 * Value["Value"];
						JumpTick = tick() + 3.5;
						Direction = Vector3.new(vec.X, 0, vec.Z).Unit;
					end;
				end));
				start = entitylib.isAlive and entitylib.character.RootPart.Position or nil;
				LongJump:Clean(runService.PreSimulation:Connect(function(dt)
					local root: Vector3? = entitylib.isAlive and entitylib.character.RootPart or nil;
					if root and isnetworkowner(root) then
						if JumpTick > tick() then
							root.AssemblyLinearVelocity = Direction * (getSpeed() + ((JumpTick - tick()) > 1.1 and JumpSpeed or 0)) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0);
							if entitylib.character.Humanoid.FloorMaterial == Enum.Material.Air and not start then
								root.AssemblyLinearVelocity += Vector3.new(0, dt * (workspace.Gravity - (Extend and 6 or 23)), 0);
							else
								root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, (Extend and 10 or 15), root.AssemblyLinearVelocity.Z);
							end;
							start = nil;
						else
							root.AssemblyLinearVelocity = Vector3.zero;
							if start then 
								root.CFrame = CFrame.lookAlong(start, root.CFrame.LookVector); 
							end;
							JumpSpeed = 0;
						end;
					else
						start = nil;
					end;
				end));
	
				for i, v in LongJumpMethods do
					local item: any = getItem(i);
					if item or store.equippedKit == i then
						task.spawn(v, item, start);
						break;
					end;
				end;
			else
				JumpTick = tick();
				Direction = nil;
				JumpSpeed = 0;
				Extend = false;
			end;
		end,
		["ExtraText"] = function() 
			return 'Heatseeker' 
		end,
		["Tooltip"] = 'Lets you jump farther'
	})
	Value = LongJump:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 38,
		["Default"] = 38,
		["Suffix"] = function(val) 
			return val == 1 and 'stud' or 'studs';
		end;
	})
end)

velo.run(function()
	local old: any;
	vape.Categories.Blatant:CreateModule({
		["Name"] = 'NoSlowdown',
		["Function"] = function(callback: boolean): void
			local modifier: any = bedwars.SprintController:getMovementStatusModifier();
			if callback then
				old = modifier.addModifier;
				modifier.addModifier = function(self, tab)
					if tab.moveSpeedMultiplier then
						tab.moveSpeedMultiplier = math.max(tab.moveSpeedMultiplier, 1);
					end;
					return old(self, tab);
				end;
	
				for i in modifier.modifiers do
					if (i.moveSpeedMultiplier or 1) < 1 then
						modifier:removeModifier(i);
					end;
				end;
			else
				modifier.addModifier = old;
				old = nil;
			end;
		end,
		["Tooltip"] = 'Prevents slowing down when using items.'
	})
end)

velo.run(function()
	local SpinBot: table = {["Enabled"] = false}
	local Mode: table = {}
	local XToggle: table = {}
	local YToggle: table = {}
	local ZToggle: table = {}
	local Value: table = {}
	local AngularVelocity: any;
	SpinBot = vape.Categories.Blatant:CreateModule({
		["Name"] = 'SpinBot',
		["Function"] = function(callback: boolean): void
			if callback then
				SpinBot:Clean(runService.PreSimulation:Connect(function()
					if entitylib.isAlive and not LongJump["Enabled"] then
						if Mode["Value"] == 'RotVelocity' then
							local originalRotVelocity: Vector3? = entitylib.character.RootPart.RotVelocity;
							entitylib.character.Humanoid.AutoRotate = false;
							entitylib.character.RootPart.RotVelocity = Vector3.new(XToggle["Enabled"] and Value.Value or originalRotVelocity.X, YToggle["Enabled"] and Value.Value or originalRotVelocity.Y, ZToggle["Enabled"] and Value.Value or originalRotVelocity.Z);
						elseif Mode["Value"] == 'CFrame' then
							local val: number = math.rad((tick() * (20 * Value.Value)) % 360);
							local x: number?, y: number?, z: number? = entitylib.character.RootPart.CFrame:ToOrientation();
							entitylib.character.RootPart.CFrame = CFrame.new(entitylib.character.RootPart.Position) * CFrame.Angles(XToggle["Enabled"] and val or x, YToggle["Enabled"] and val or y, ZToggle["Enabled"] and val or z);
						elseif AngularVelocity then
							AngularVelocity.Parent = entitylib.isAlive and entitylib.character.RootPart;
							AngularVelocity.MaxTorque = Vector3.new(XToggle["Enabled"] and math.huge or 0, YToggle["Enabled"] and math.huge or 0, ZToggle["Enabled"] and math.huge or 0);
							AngularVelocity.AngularVelocity = Vector3.new(Value.Value, Value.Value, Value.Value);
						end;
					end;
				end));
			else
				if entitylib.isAlive and Mode.Value == 'RotVelocity' then
					entitylib.character.Humanoid.AutoRotate = true;
				end;
				if AngularVelocity then
					AngularVelocity.Parent = nil;
				end;
			end;
		end,
		["Tooltip"] = 'Makes your character spin around in circles (does not work in first person)'
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
	local TargetPart: table = {}
	local Targets: table = {}
	local FOV: table = {["Value"] = 1000}
	local OtherProjectiles: table = {["Enabled"] = false}
	local rayCheck: RaycastParams? = RaycastParams.new()
	rayCheck.FilterType = Enum.RaycastFilterType.Include
	rayCheck.FilterDescendantsInstances = {workspace:FindFirstChild('Map')}
	local old: any;
	local ProjectileAimbot = vape.Categories.Blatant:CreateModule({
		["Name"] = 'ProjectileAimbot',
		["Function"] = function(callback: boolean): void
			if callback then
				old = bedwars.ProjectileController.calculateImportantLaunchValues;
				bedwars.ProjectileController.calculateImportantLaunchValues = function(...)
					local self: any, projmeta: any, worldmeta: any, origin: any, shootpos: Vector3? = ...
					local plr: Player? = entitylib.EntityMouse({
						Part = 'RootPart',
						Range = FOV.Value,
						Players = Targets.Players["Enabled"],
						NPCs = Targets.NPCs["Enabled"],
						Wallcheck = Targets.Walls["Enabled"],
						Origin = entitylib.isAlive and (shootpos or entitylib.character.RootPart.Position) or Vector3.zero
					});
					if plr then
						local pos: Vector3? = shootpos or self:getLaunchPosition(origin);
						if not pos then
							return old(...);
						end;
						if (not OtherProjectiles["Enabled"]) and not projmeta.projectile:find('arrow') then
							return old(...);
						end;
						local meta: any = projmeta:getProjectileMeta();
						local lifetime: number = (worldmeta and meta.predictionLifetimeSec or meta.lifetimeSec or 3);
						local gravity: number = (meta.gravitationalAcceleration or 196.2) * projmeta.gravityMultiplier;
						local projSpeed: number = (meta.launchVelocity or 100);
						local offsetpos: Vector3? = pos + (projmeta.projectile == 'owl_projectile' and Vector3.zero or projmeta.fromPositionOffset);
						local balloons: number? = plr.Character:GetAttribute('InflatedBalloons');
						local playerGravity: number = workspace.Gravity;
						if balloons and balloons > 0 then
							playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))));
						end;
						if plr.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then
							playerGravity = 6;
						end;
						local newlook: CFrame = CFrame.new(offsetpos, plr[TargetPart.Value].Position) * CFrame.new(projmeta.projectile == 'owl_projectile' and Vector3.zero or Vector3.new(bedwars.BowConstantsTable.RelX, bedwars.BowConstantsTable.RelY, bedwars.BowConstantsTable.RelZ));
						local calc: any = prediction.SolveTrajectory(newlook.p, projSpeed, gravity, plr[TargetPart.Value].Position, projmeta.projectile == 'telepearl' and Vector3.zero or plr[TargetPart.Value].Velocity, playerGravity, plr.HipHeight, plr.Jumping and 42.6 or nil, rayCheck);
						if calc then
							targetinfo.Targets[plr] = tick() + 1;
							return {
								initialVelocity = CFrame.new(newlook.Position, calc).LookVector * projSpeed,
								positionFrom = offsetpos,
								deltaT = lifetime,
								gravitationalAcceleration = gravity,
								drawDurationSeconds = 5
							};
						end;
					end;
	
					return old(...);
				end;
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = old;
			end;
		end,
		["Tooltip"] = 'Silently adjusts your aim towards the enemy'
	})
	Targets = ProjectileAimbot:CreateTargets({
		["Players"] = true,
		["Walls"] = true
	})
	TargetPart = ProjectileAimbot:CreateDropdown({
		["Name"] = 'Part',
		["List"] = {'RootPart', 'Head'}
	})
	FOV = ProjectileAimbot:CreateSlider({
		["Name"] = 'FOV',
		["Min"] = 1,
		["Max"] = 1000,
		["Default"] = 1000
	})
	OtherProjectiles = ProjectileAimbot:CreateToggle({
		["Name"] = 'Other Projectiles',
		["Default"] = true
	})
end)
	
velo.run(function()
	local ProjectileAura: table = {["Enabled"] = false}; 
	local Targets: table = {}
	local Range: table = {["Value"] = 1000};
	local List: table = {}
	local rayCheck: RaycastParams? = RaycastParams.new()
	rayCheck.FilterType = Enum.RaycastFilterType.Include;
	local projectileRemote: any = replicatedStorage.rbxts_include.node_modules['@rbxts'].net.out._NetManaged.ProjectileFire
	local FireDelays: table? = {};
	task.spawn(function()
		projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance;
	end);
	
	local function getAmmo(check: {ammoItemTypes: {string}}): string?
		for _, item in store.inventory.inventory.items do
			if check.ammoItemTypes and table.find(check.ammoItemTypes, item.itemType) then
				return item.itemType;
			end;
		end;
	end;
	
	local function getProjectiles(): {any}
		local items: table = {};
		for _, item in store.inventory.inventory.items do
			local proj: any = bedwars.ItemMeta[item.itemType].projectileSource;
			local ammo: any = proj and getAmmo(proj);
			if ammo and table.find(List.ListEnabled, ammo) then
				table.insert(items, {
					item, 
					ammo, 
					proj.projectileType(ammo), 
					proj
				});
			end;
		end;
		return items;
	end;
	ProjectileAura = vape.Categories.Blatant:CreateModule({
		["Name"] = 'ProjectileAura',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) > 0.5 and not LongJump["Enabled"] then
						local ent: Player? = entitylib.EntityPosition({
							Part = 'RootPart',
							Range = Range.Value,
							Players = Targets.Players["Enabled"],
							NPCs = Targets.NPCs["Enabled"],
							Wallcheck = Targets.Walls["Enabled"]
						});
						if ent then
							local pos: Vector3 = entitylib.character.RootPart.Position;
							for _, data in getProjectiles() do
								local item: any, ammo: any, projectile: any, itemMeta: any = unpack(data);
								if (FireDelays[item.itemType] or 0) < tick() then
									rayCheck.FilterDescendantsInstances = {workspace.Map};
									local meta: any = bedwars.ProjectileMeta[projectile];
									local projSpeed: number, gravity: number = meta.launchVelocity, meta.gravitationalAcceleration or 196.2;
									local calc: number? = prediction.SolveTrajectory(pos, projSpeed, gravity, ent.RootPart.Position, ent.RootPart.Velocity, workspace.Gravity, ent.HipHeight, ent.Jumping and 42.6 or nil, rayCheck);
									if calc then
										targetinfo.Targets[ent] = tick() + 1;
										local switched: any = switchItem(item.tool);
	
										task.spawn(function()
											local dir: CFrame?, id: any = CFrame.lookAt(pos, calc).LookVector, httpService:GenerateGUID(true);
											local shootPosition: CFrame? = (CFrame.new(pos, calc) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).Position;
											bedwars.ProjectileController:createLocalProjectile(meta, ammo, projectile, shootPosition, id, dir * projSpeed, {drawDurationSeconds = 1});
											local res: any = projectileRemote:InvokeServer(item.tool, ammo, projectile, shootPosition, pos, dir * projSpeed, id, {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045);
											if not res then
												FireDelays[item.itemType] = tick()
											else
												local shoot: any = itemMeta.launchSound;
												shoot = shoot and shoot[math.random(1, #shoot)] or nil;
												if shoot then 
													bedwars.SoundManager:playSound(shoot);
												end;
											end;
										end);
	
										FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec;
										if switched then 
											task.wait(0.05); 
										end;
									end;
								end;
							end;
						end;
					end;
					task.wait(0.1);
				until not ProjectileAura["Enabled"];
			end;
		end,
		["Tooltip"] = 'Shoots people around you'
	})
	Targets = ProjectileAura:CreateTargets({
		["Players"] = true, 
		["Walls"] = true
	})
	List = ProjectileAura:CreateTextList({
		["Name"] = 'Projectiles',
		["Default"] = {'arrow', 'snowball'}
	})
	Range = ProjectileAura:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 1,
		["Max"] = 50,
		["Default"] = 50,
		["Suffix"] = function(val) 
			return val == 1 and 'stud' or 'studs';
		end;
	})
end)

velo.run(function()
	local Speed: table = {["Enabled"] = false};
	local Value: table = {["Value"] = 23};
	local WallCheck: table = {["Enabled"] = false};
	local AutoJump: table = {["Enabled"] = false};
	local AlwaysJump: table = {["Enabled"] = false};
	local rayCheck: any = RaycastParams.new();
	rayCheck.RespectCanCollide = true;
	Speed = vape.Categories.Blatant:CreateModule({
		["Name"] = 'Speed',
		["Function"] = function(callback: boolean): void
			frictionTable.Speed = callback or nil;
			updateVelocity();
			pcall(function() 
				debug.setconstant(bedwars.WindWalkerController.updateSpeed, 7, callback and 'constantSpeedMultiplier' or 'moveSpeedMultiplier'); 
			end);
			if callback then
				Speed:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive and not Fly["Enabled"] and not LongJump["Enabled"] and isnetworkowner(entitylib.character.RootPart) then
						local state: any = entitylib.character.Humanoid:GetState()
						if state == Enum.HumanoidStateType.Climbing then return; end;
						local root: any = entitylib.character.RootPart;
						local moveDirection: any = AntiFallDirection or entitylib.character.Humanoid.MoveDirection;
						local now: number = tick();
						local velo: number = getSpeed();
						local destination: number? = (moveDirection * math.max(Value.Value - velo, 0) * dt)
	
						if WallCheck["Enabled"] then
							rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera};
							rayCheck.CollisionGroup = root.CollisionGroup;
							local ray: any = workspace:Raycast(root.Position, destination, rayCheck);
							if ray then
								destination = ((ray.Position + ray.Normal) - root.Position);
							end;
						end;
	
						root.CFrame += destination;
						root.AssemblyLinearVelocity = (moveDirection * velo) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0);
						if AutoJump["Enabled"] and (state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed) and moveDirection ~= Vector3.zero and (Attacking or AlwaysJump["Enabled"]) then
							entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
						end;
					end;
				end));
			end;
		end,
		["ExtraText"] = function() 
			return 'Heatseeker' 
		end,
		["Tooltip"] = 'Increases your movement with various methods.'
	})
	Value = Speed:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 1,
		["Max"] = 23,
		["Default"] = 23,
		["Suffix"] = function(val) 
			return val == 1 and 'stud' or 'studs'; 
		end;
	})
	WallCheck = Speed:CreateToggle({
		["Name"] = 'Wall Check',
		["Default"] = true
	})
	AutoJump = Speed:CreateToggle({
		["Name"] = 'AutoJump',
		["Function"] = function(callback)
			AlwaysJump.Object.Visible = callback;
		end;
	})
	AlwaysJump = Speed:CreateToggle({
		["Name"] = 'Always Jump',
		["Visible"] = false,
		["Darker"] = true
	})
end)
				
velo.run(function()
	local BedESP: table ={["Enabled"] = false}
	local Reference: table = {};
	local Folder: Folder = Instance.new('Folder');
	Folder.Parent = vape.gui;
	
	local function Added(bed)
		if not BedESP["Enabled"] then return; end;
		local BedFolder: Folder = Instance.new('Folder');
		BedFolder.Parent = Folder;
		Reference[bed] = BedFolder;
		local bedparts: any = bed:GetChildren();
		table.sort(bedparts, function(a, b) 
			return a["Name"] > b["Name"];
		end);
	
		for _, part in bedparts do
			if part:IsA('BasePart') and part["Name"] ~= 'Blanket' then
				local boxhandle: BoxHandleAdornment = Instance.new('BoxHandleAdornment');
				boxhandle.Size = part.Size + Vector3.new(.01, .01, .01);
				boxhandle.AlwaysOnTop = true;
				boxhandle.ZIndex = 2;
				boxhandle.Visible = true;
				boxhandle.Adornee = part;
				boxhandle.Color3 = part.Color;
				if part["Name"] == 'Legs' then
					boxhandle.Color3 = Color3.fromRGB(167, 112, 64);
					boxhandle.Size = part.Size + Vector3.new(.01, -1, .01);
					boxhandle.CFrame = CFrame.new(0, -0.4, 0);
					boxhandle.ZIndex = 0
				end;
				boxhandle.Parent = BedFolder;
			end;
		end;
		table.clear(bedparts);
	end;
	
	BedESP = vape.Categories.Render:CreateModule({
		["Name"] = 'BedESP',
		["Function"] = function(callback: boolean): void
			if callback then
				BedESP:Clean(collectionService:GetInstanceAddedSignal('bed'):Connect(function(bed) 
					task.delay(0.2, Added, bed);
				end));
				BedESP:Clean(collectionService:GetInstanceRemovedSignal('bed'):Connect(function(bed)
					if Reference[bed] then
						Reference[bed]:Destroy();
						Reference[bed] = nil;
					end;
				end));
				for _, bed in collectionService:GetTagged('bed') do 
					Added(bed);
				end;
			else
				Folder:ClearAllChildren();
				table.clear(Reference);
			end;
		end,
		["Tooltip"] = 'Render Beds through walls'
	})
end)

velo.run(function()
	local KitESP: table = {["Enabled"] = false}
	local Background: table = {["Enabled"] = false}
	local Color: table = {}
	local Reference: table? = {}
	local Folder: Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	
	local ESPKits: table = {
		alchemist = {'alchemist_ingedients', 'wild_flower'},
		beekeeper = {'bee', 'bee'},
		bigman = {'treeOrb', 'natures_essence_1'},
		ghost_catcher = {'ghost', 'ghost_orb'},
		metal_detector = {'hidden-metal', 'iron'},
		sheep_herder = {'SheepModel', 'purple_hay_bale'},
		sorcerer = {'alchemy_crystal', 'wild_flower'},
		star_collector = {'stars', 'crit_star'}
	};
	
	local function Added(v: any, icon: any): any
		local billboard: BillboardGui = Instance.new('BillboardGui');
		billboard.Parent = Folder;
		billboard.Name = icon;
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0);
		billboard.Size = UDim2.fromOffset(36, 36);
		billboard.AlwaysOnTop = true;
		billboard.ClipsDescendants = false;
		billboard.Adornee = v;
		local blur: any = addBlur(billboard);
		blur.Visible = Background["Enabled"];
		local image: ImageLabel = Instance.new('ImageLabel');
		image.Size = UDim2.fromOffset(36, 36);
		image.Position = UDim2.fromScale(0.5, 0.5);
		image.AnchorPoint = Vector2.new(0.5, 0.5);
		image.BackgroundColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value);
		image.BackgroundTransparency = 1 - (Background["Enabled"] and Color.Opacity or 0);
		image.BorderSizePixel = 0;
		image.Image = bedwars.getIcon({itemType = icon}, true);
		image.Parent = billboard;
		local uicorner: UICorner = Instance.new('UICorner');
		uicorner.CornerRadius = UDim.new(0, 4);
		uicorner.Parent = image;
		Reference[v] = billboard;
	end;
	
	local function addKit(tag: any, icon: any): any
		KitESP:Clean(collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			Added(v.PrimaryPart, icon);
		end));
		KitESP:Clean(collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if Reference[v.PrimaryPart] then
				Reference[v.PrimaryPart]:Destroy();
				Reference[v.PrimaryPart] = nil;
			end;
		end));
		for _, v in collectionService:GetTagged(tag) do
			Added(v.PrimaryPart, icon);
		end;
	end;
	
	KitESP = vape.Categories.Render:CreateModule({
		["Name"] = 'KitESP',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat task.wait() until store.equippedKit ~= '' or (not KitESP["Enabled"]);
				local kit: any = KitESP["Enabled"] and ESPKits[store.equippedKit] or nil;
				if kit then
					addKit(kit[1], kit[2]);
				end;
			else
				Folder:ClearAllChildren();
				table.clear(Reference);
			end;
		end,
		["Tooltip"] = 'ESP for certain kit related objects'
	})
	Background = KitESP:CreateToggle({
		["Name"] = 'Background',
		["Function"] = function(callback: boolean): void
			if Color.Object then Color.Object.Visible = callback; end;
			for _, v in Reference do
				v.ImageLabel.BackgroundTransparency = 1 - (callback and Color.Opacity or 0);
				v.Blur.Visible = callback;
			end;
		end,
		["Default"] = true
	})
	Color = KitESP:CreateColorSlider({
		["Name"] = 'Background Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			for _, v in Reference do
				v.ImageLabel.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
				v.ImageLabel.BackgroundTransparency = 1 - opacity;
			end;
		end,
		["Darker"] = true
	})
end)

velo.run(function()
	local NameTags: table = {["Enabled"] = false};
	local Targets: table = {Players = {["Enabled"] = false}};
	local Color: table = {["Value"] = 0.44};
	local Background: table = {};
	local DisplayName: table = {["Enabled"] = false};
	local Health: table = {["Enabled"] = false};
	local Distance: table = {["Enabled"] = false};
	local Equipment: table = {["Enabled"] = false};
	local DrawingToggle: table = {["Enabled"] = false};
	local Scale: table = {["Value"] = 10};
	local FontOption: any;
	local Teammates: table = {["Enabled"] = true};
	local DistanceCheck: table = {["Enabled"] = false};
	local DistanceLimit: any;
	local Strings: table = {}
	local Sizes: table = {}
	local Reference: table = {}	
	local Folder: Folder = Instance.new('Folder');
	Folder.Parent = vape.gui;
	local methodused: any;
	local fontitems: any = {'Arial'}
	local kititems: table = {
		jade = 'jade_hammer',
		archer = 'tactical_crossbow',
		cowgirl = 'lasso',
		dasher = 'wood_dao',
		axolotl = 'axolotl',
		yeti = 'snowball',
		smoke = 'smoke_block',
		trapper = 'snap_trap',
		pyro = 'flamethrower',
		davey = 'cannon',
		regent = 'void_axe',
		baker = 'apple',
		builder = 'builder_hammer',
		farmer_cletus = 'carrot_seeds',
		melody = 'guitar',
		barbarian = 'rageblade',
		gingerbread_man = 'gumdrop_bounce_pad',
		spirit_catcher = 'spirit',
		fisherman = 'fishing_rod',
		oil_man = 'oil_consumable',
		santa = 'tnt',
		miner = 'miner_pickaxe',
		sheep_herder = 'crook',
		beast = 'speed_potion',
		metal_detector = 'metal_detector',
		cyber = 'drone',
		vesta = 'damage_banner',
		lumen = 'light_sword',
		ember = 'infernal_saber',
		queen_bee = 'bee'
	};
	
	local Added: table = {
		Normal = function(ent)
			if not Targets.Players["Enabled"] and ent.Player then return; end;
			if not Targets.NPCs["Enabled"] and ent.NPC then return; end;
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return; end;
			local EntityNameTag: TextLabel = Instance.new('TextLabel');
			EntityNameTag.BackgroundColor3 = Color3.new();
			EntityNameTag.BorderSizePixel = 0;
			EntityNameTag.Visible = false;
			EntityNameTag.RichText = true;
			EntityNameTag.AnchorPoint = Vector2.new(0.5, 1);
			EntityNameTag.Name = ent.Player and ent.Player["Name"] or ent.Character["Name"];
			EntityNameTag.FontFace = FontOption["Value"];
			EntityNameTag.TextSize = 14 * Scale["Value"];
			EntityNameTag.BackgroundTransparency = Background["Value"];
			Strings[ent] = ent.Player and whitelist:tag(ent.Player, true, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player["Name"]) or ent.Character["Name"];
			if Health["Enabled"] then
				local healthColor: Color3 = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75);
				Strings[ent] = Strings[ent]..' <font color="rgb('..tostring(math.floor(healthColor.R * 255))..','..tostring(math.floor(healthColor.G * 255))..','..tostring(math.floor(healthColor.B * 255))..')">'..math.round(ent.Health)..'</font>';
			end;
			if Distance["Enabled"] then
				Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..Strings[ent];
			end;
			if Equipment["Enabled"] then
				for i: any, v: any in {'Hand', 'Helmet', 'Chestplate', 'Boots', 'Kit'} do
					local Icon: ImageLabel = Instance.new('ImageLabel');
					Icon.Name = v;
					Icon.Size = UDim2.fromOffset(30, 30);
					Icon.Position = UDim2.fromOffset(-60 + (i * 30), -30);
					Icon.BackgroundTransparency = 1;
					Icon.Image = '';
					Icon.Parent = EntityNameTag;
				end;
			end;
			local nametagSize: any = getfontsize(removeTags(Strings[ent]), EntityNameTag.TextSize, EntityNameTag.FontFace, Vector2.new(100000, 100000));
			EntityNameTag.Size = UDim2.fromOffset(nametagSize.X + 8, nametagSize.Y + 7);
			EntityNameTag.Text = Strings[ent];
			EntityNameTag.TextColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]);
			EntityNameTag.Parent = Folder;
			Reference[ent] = EntityNameTag;
		end,
		Drawing = function(ent)
			if not Targets.Players["Enabled"] and ent.Player then return; end;
			if not Targets.NPCs["Enabled"] and ent.NPC then return; end;
			if Teammates["Enabled"] and (not ent.Targetable) and (not ent.Friend) then return; end;
			local EntityNameTag: any = {};
			EntityNameTag.BG = Drawing.new('Square');
			EntityNameTag.BG.Filled = true;
			EntityNameTag.BG.Transparency = 1 - Background["Value"];
			EntityNameTag.BG.Color = Color3.new();
			EntityNameTag.BG.ZIndex = 1;
			EntityNameTag.Text = Drawing.new('Text');
			EntityNameTag.Text.Size = 15 * Scale["Value"];
			EntityNameTag.Text.Font = (math.clamp((table.find(fontitems, FontOption.Value) or 1) - 1, 0, 3));
			EntityNameTag.Text.ZIndex = 2;
			Strings[ent] = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player["Name"]) or ent.Character["Name"]
			if Health["Enabled"] then
				Strings[ent] = Strings[ent]..' '..math.round(ent.Health);
			end;
			if Distance["Enabled"] then
				Strings[ent] = '[%s] '..Strings[ent];
			end;
			EntityNameTag.Text.Text = Strings[ent];
			EntityNameTag.Text.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value);
			EntityNameTag.BG.Size = Vector2.new(EntityNameTag.Text.TextBounds.X + 8, EntityNameTag.Text.TextBounds.Y + 7);
			Reference[ent] = EntityNameTag;
		end;
	};

	local Removed: table = {
		Normal = function(ent)
			local v: any = Reference[ent];
			if v then
				Reference[ent] = nil;
				Strings[ent] = nil;
				Sizes[ent] = nil;
				v:Destroy();
			end;
		end,
		Drawing = function(ent)
			local v: any = Reference[ent];
			if v then
				Reference[ent] = nil;
				Strings[ent] = nil;
				Sizes[ent] = nil;
				for _, obj in v do
					pcall(function() 
						obj.Visible = false;
						obj:Remove(); 
					end);
				end;
			end;
		end;
	}
	
	local Updated: table = {
		Normal = function(ent)
			local EntityNameTag: any = Reference[ent];
			if EntityNameTag then
				Sizes[ent] = nil;
				Strings[ent] = ent.Player and whitelist:tag(ent.Player, true, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player["Name"]) or ent.Character["Name"];
				if Health["Enabled"] then
					local healthColor: Color3 = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75);
					Strings[ent] = Strings[ent]..' <font color="rgb('..tostring(math.floor(healthColor.R * 255))..','..tostring(math.floor(healthColor.G * 255))..','..tostring(math.floor(healthColor.B * 255))..')">'..math.round(ent.Health)..'</font>';
				end;
				if Distance["Enabled"] then
					Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..Strings[ent];
				end;
				if Equipment["Enabled"] and store.inventories[ent.Player] then
					local inventory: any = store.inventories[ent.Player];
					EntityNameTag.Hand.Image = bedwars.getIcon(inventory.hand or {itemType = ''}, true);
					EntityNameTag.Helmet.Image = bedwars.getIcon(inventory.armor[4] or {itemType = ''}, true);
					EntityNameTag.Chestplate.Image = bedwars.getIcon(inventory.armor[5] or {itemType = ''}, true);
					EntityNameTag.Boots.Image = bedwars.getIcon(inventory.armor[6] or {itemType = ''}, true);
					EntityNameTag.Kit.Image = bedwars.getIcon({itemType = kititems[ent.Player:GetAttribute('PlayingAsKit')] or ''}, true);
				end;
				local nametagSize: any = getfontsize(removeTags(Strings[ent]), EntityNameTag.TextSize, EntityNameTag.FontFace, Vector2.new(100000, 100000));
				EntityNameTag.Size = UDim2.fromOffset(nametagSize.X + 8, nametagSize.Y + 7);
				EntityNameTag.Text = Strings[ent];
			end;
		end,
		Drawing = function(ent)
			local EntityNameTag: any = Reference[ent];
			if EntityNameTag then
				Sizes[ent] = nil;
				Strings[ent] = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName["Enabled"] and ent.Player.DisplayName or ent.Player["Name"]) or ent.Character["Name"];
				if Health["Enabled"] then
					Strings[ent] = Strings[ent]..' '..math.round(ent.Health);
				end;
				if Distance["Enabled"] then
					Strings[ent] = '[%s] '..Strings[ent]
					EntityNameTag.Text.Text = entitylib.isAlive and string.format(Strings[ent], (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude // 1) or Strings[ent];
				else
					EntityNameTag.Text.Text = Strings[ent];
				end;
				EntityNameTag.BG.Size = Vector2.new(EntityNameTag.Text.TextBounds.X + 8, EntityNameTag.Text.TextBounds.Y + 7);
				EntityNameTag.Text.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value);
			end;
		end;
	}
	
	local ColorFunc: table = {
		Normal = function(hue, sat, val)
			local tagColor: Color3 = Color3.fromHSV(hue, sat, val);
			for i: any, v: any in Reference do
				v.TextColor3 = entitylib.getEntityColor(i) or tagColor;
			end;
		end,
		Drawing = function(hue, sat, val)
			local tagColor: Color3 = Color3.fromHSV(hue, sat, val);
			for i: any, v: any in Reference do
				v.Text.Text.Color = entitylib.getEntityColor(i) or tagColor;
			end;
		end;
	}
	
	local Loop: table = {
		Normal = function()
			for ent, EntityNameTag in Reference do
				if DistanceCheck["Enabled"] then
					local distance: any = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						EntityNameTag.Visible = false;
						continue;
					end;
				end;
				local headPos: any, headVis: any = gameCamera:WorldToViewportPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0))
				EntityNameTag.Visible = headVis;
				if not headVis then
					continue;
				end;
				if Distance["Enabled"] and entitylib.isAlive then
					local mag: any = (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude // 1;
					if Sizes[ent] ~= mag then
						EntityNameTag.Text = string.format(Strings[ent], mag);
						local nametagSize: any = getfontsize(removeTags(EntityNameTag.Text), EntityNameTag.TextSize, EntityNameTag.FontFace, Vector2.new(100000, 100000));
						EntityNameTag.Size = UDim2.fromOffset(nametagSize.X + 8, nametagSize.Y + 7);
						Sizes[ent] = mag;
					end;
				end;
				EntityNameTag.Position = UDim2.fromOffset(headPos.X, headPos.Y);
			end;
		end,
		Drawing = function()
			for ent, EntityNameTag in Reference do
				if DistanceCheck["Enabled"] then
					local distance: any = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge;
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						EntityNameTag.Text.Visible = false;
						EntityNameTag.BG.Visible = false;
						continue;
					end;
				end;
				local headPos: any, headVis: any = gameCamera:WorldToViewportPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0));
				EntityNameTag.Text.Visible = headVis;
				EntityNameTag.BG.Visible = headVis and Background["Enabled"];
				if not headVis then
					continue;
				end;
				if Distance["Enabled"] and entitylib.isAlive then
					local mag: any = (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude // 1;
					if Sizes[ent] ~= mag then
						EntityNameTag.Text.Text = string.format(Strings[ent], mag);
						EntityNameTag.BG.Size = Vector2.new(EntityNameTag.Text.TextBounds.X + 8, EntityNameTag.Text.TextBounds.Y + 7);
						Sizes[ent] = mag;
					end;
				end;
				EntityNameTag.BG.Position = Vector2.new(headPos.X - (EntityNameTag.BG.Size.X / 2), headPos.Y + (EntityNameTag.BG.Size.Y / 2));
				EntityNameTag.Text.Position = EntityNameTag.BG.Position + Vector2.new(4, 2.5);
			end;
		end;
	}
	
	NameTags = vape.Categories.Render:CreateModule({
		["Name"] = 'NameTags',
		["Function"] = function(callback: boolean): void
			if callback then
				methodused = DrawingToggle["Enabled"] and 'Drawing' or 'Normal';
				if Removed[methodused] then
					NameTags:Clean(entitylib.Events.EntityRemoved:Connect(Removed[methodused]));
				end;
				if Added[methodused] then
					for _, v in entitylib.List do
						if Reference[v] then 
							Removed[methodused](v) ;
						end
						Added[methodused](v);
					end;
					NameTags:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
						if Reference[ent] then 
							Removed[methodused](ent) ;
						end;
						Added[methodused](ent);
					end));
				end;
				if Updated[methodused] then
					NameTags:Clean(entitylib.Events.EntityUpdated:Connect(Updated[methodused]));
					for _, v in entitylib.List do 
						Updated[methodused](v); 
					end;
				end;
				if ColorFunc[methodused] then
					NameTags:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
						ColorFunc[methodused](Color.Hue, Color.Sat, Color.Value);
					end));
				end;
				if Loop[methodused] then
					NameTags:Clean(runService.RenderStepped:Connect(Loop[methodused]));
				end;
			else
				if Removed[methodused] then
					for i in Reference do 
						Removed[methodused](i);
					end;
				end;
			end;
		end,
		["Tooltip"] = 'Renders nametags on entities through walls.'
	})
	Targets = NameTags:CreateTargets({
		["Players"] = true, 
		["Function"] = function()
			if NameTags["Enabled"] then
				NameTags:Toggle();
				NameTags:Toggle();
			end;
		end,
	})
	FontOption = NameTags:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Arial',
		["Function"] = function() 
			if NameTags["Enabled"] then 
				NameTags:Toggle(); 
				NameTags:Toggle(); 
			end;
		end,
	})
	Color = NameTags:CreateColorSlider({
		["Name"] = 'Player Color',
		["Function"] = function(hue, sat, val)
			if NameTags["Enabled"] and ColorFunc[methodused] then
				ColorFunc[methodused](hue, sat, val);
			end;
		end,
	})
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
	Health = NameTags:CreateToggle({
		["Name"] = 'Health',
		["Function"] = function() 
			if NameTags["Enabled"] then 
				NameTags:Toggle(); 
				NameTags:Toggle(); 
			end;
		end,
	})
	Distance = NameTags:CreateToggle({
		["Name"] = 'Distance',
		["Function"] = function() 
			if NameTags["Enabled"] then 
				NameTags:Toggle(); 
				NameTags:Toggle(); 
			end;
		end,
	})
	Equipment = NameTags:CreateToggle({
		["Name"] = 'Equipment',
		["Function"] = function() 
			if NameTags["Enabled"] then 
				NameTags:Toggle(); 
				NameTags:Toggle(); 
			end; 
		end,
	})
	DisplayName = NameTags:CreateToggle({
		["Name"] = 'Use Displayname',
		["Function"] = function() 
			if NameTags["Enabled"] then 
				NameTags:Toggle(); 
				NameTags:Toggle(); 
			end; 
		end,
		["Default"] = true;
	})
	Teammates = NameTags:CreateToggle({
		["Name"] = 'Priority Only',
		["Function"] = function() 
			if NameTags["Enabled"] then 
				NameTags:Toggle(); 
				NameTags:Toggle(); 
			end; 
		end,
		["Default"] = true;
	})
	DrawingToggle = NameTags:CreateToggle({
		["Name"] = 'Drawing',
		["Function"] = function() 
			if NameTags["Enabled"] then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end; 
		end,
	})
	DistanceCheck = NameTags:CreateToggle({
		["Name"] = 'Distance Check',
		["Function"] = function(callback)
			DistanceLimit.Object.Visible = callback;
		end;
	})
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
	local StorageESP: table = {["Enabled"] = false}
	local List: table = {};
	local Background: table = {["Enabled"] = false}
	local Color: table = {};
	local Reference: table = {};
	local Folder: Folder = Instance.new('Folder');
	Folder.Parent = vape.gui;
	
	local function nearStorageItem(item: string): string?
		for _, v in List.ListEnabled do
			if item:find(v) then return v end
		end
	end
	
	local function refreshAdornee(v: Instance?)
		local chest: Instance? = v.Adornee:FindFirstChild('ChestFolderValue')
		chest = chest and chest["Value"]or nil;
		if not chest then 
			v.Enabled = false; 
			return;
		end;
	
		local chestitems: Instance? = chest and chest:GetChildren() or {};
		for _, obj in v.Frame:GetChildren() do
			if obj:IsA('ImageLabel') and obj["Name"] ~= 'Blur' then 
				obj:Destroy(); 
			end;
		end;
	
		v.Enabled = false
		local alreadygot: table = {}
		for _, item in chestitems do
			if not alreadygot[item["Name"]] and (table.find(List.ListEnabled, item["Name"]) or nearStorageItem(item["Name"])) then
				alreadygot[item["Name"]] = true;
				v.Enabled = true;
				local blockimage: ImageLabel = Instance.new('ImageLabel');
				blockimage.Size = UDim2.fromOffset(32, 32);
				blockimage.BackgroundTransparency = 1;
				blockimage.Image = bedwars.getIcon({itemType = item["Name"]}, true);
				blockimage.Parent = v.Frame;
			end;
		end;
		table.clear(chestitems);
	end;
	
	local function Added(v: Instance)
		local chest: Instance? = v:WaitForChild('ChestFolderValue', 3);
		if not (chest and StorageESP["Enabled"]) then return; end;
		chest = chest.Value;
		local billboard: BillboardGui = Instance.new('BillboardGui');
		billboard.Parent = Folder;
		billboard.Name = 'chest';
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0);
		billboard.Size = UDim2.fromOffset(36, 36);
		billboard.AlwaysOnTop = true;
		billboard.ClipsDescendants = false;
		billboard.Adornee = v;
		local blur: Blur? = addBlur(billboard);
		blur.Visible = Background["Enabled"];
		local frame: Frame = Instance.new('Frame');
		frame.Size = UDim2.fromScale(1, 1);
		frame.BackgroundColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value);
		frame.BackgroundTransparency = 1 - (Background["Enabled"] and Color.Opacity or 0);
		frame.Parent = billboard;
		local layout: UIListLayout = Instance.new('UIListLayout');
		layout.FillDirection = Enum.FillDirection.Horizontal;
		layout.Padding = UDim.new(0, 4);
		layout.VerticalAlignment = Enum.VerticalAlignment.Center;
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			billboard.Size = UDim2.fromOffset(math.max(layout.AbsoluteContentSize.X + 4, 36), 36);
		end);
		layout.Parent = frame;
		local corner: UICorner = Instance.new('UICorner');
		corner.CornerRadius = UDim.new(0, 4);
		corner.Parent = frame;
		Reference[v] = billboard;
		StorageESP:Clean(chest.ChildAdded:Connect(function(item)
			if table.find(List.ListEnabled, item["Name"]) or nearStorageItem(item["Name"]) then
				refreshAdornee(billboard);
			end;
		end));
		StorageESP:Clean(chest.ChildRemoved:Connect(function(item)
			if table.find(List.ListEnabled, item["Name"]) or nearStorageItem(item["Name"]) then
				refreshAdornee(billboard);
			end;
		end));
		task.spawn(refreshAdornee, billboard);
	end;
	
	StorageESP = vape.Categories.Render:CreateModule({
		["Name"] = 'StorageESP',
		["Function"] = function(callback: boolean): void
			if callback then
				StorageESP:Clean(collectionService:GetInstanceAddedSignal('chest'):Connect(Added));
				for _, v in collectionService:GetTagged('chest') do 
					task.spawn(Added, v);
				end;
			else
				table.clear(Reference);
				Folder:ClearAllChildren();
			end;
		end,
		["Tooltip"] = 'Displays items in chests';
	})
	List = StorageESP:CreateTextList({
		["Name"] = 'Item',
		["Function"] = function()
			for _, v in Reference do 
				task.spawn(refreshAdornee, v);
			end;
		end;
	})
	Background = StorageESP:CreateToggle({
		["Name"] = 'Background',
		["Function"] = function(callback: boolean): void
			if Color.Object then Color.Object.Visible = callback; end;
			for _, v in Reference do
				v.Frame.BackgroundTransparency = 1 - (callback and Color.Opacity or 0);
				v.Blur.Visible = callback;
			end;
		end,
		["Default"] = true
	})
	Color = StorageESP:CreateColorSlider({
		["Name"] = 'Background Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			for _, v in Reference do
				v.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
				v.Frame.BackgroundTransparency = 1 - opacity;
			end;
		end,
		["Darker"] = true
	})
end)
	
velo.run(function()
	local AutoBalloon: table = {["Enabled"] = false}
	AutoBalloon = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoBalloon',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat task.wait() until store.matchState ~= 0 or (not AutoBalloon["Enabled"]);
				if not AutoBalloon["Enabled"] then return; end;
				local lowestpoint: number = math.huge;
				for _, v in store.blocks do
					local point: number? = (v.Position.Y - (v.Size.Y / 2)) - 50;
					if point < lowestpoint then 
						lowestpoint = point; 
					end;
				end;
				repeat
					if entitylib.isAlive then
						if entitylib.character.RootPart.Position.Y < lowestpoint and (lplr.Character:GetAttribute('InflatedBalloons') or 0) < 3 then
							local balloon: any = getItem('balloon');
							if balloon then
								for _ = 1, 3 do 
									bedwars.BalloonController:inflateBalloon() ;
								end;
							end;
							task.wait(0.1);
						end;
					end;
					task.wait(0.1);
				until not AutoBalloon["Enabled"];
			end;
		end,
		["Tooltip"] = 'Inflates when you fall into the void'
	})
end)
	
velo.run(function()
	local AutoKit: table = {["Enabled"] = false}
	local Legit: table = {}
	local Toggles: table = {}
	
	local function kitCollection(id: any, func: (any) -> void, range: number, specific: boolean)
		local objs: any = type(id) == 'table' and id or collection(id, AutoKit);
		repeat
			if entitylib.isAlive then
				local localPosition: Vector3 = entitylib.character.RootPart.Position;
				for _, v in objs do
					if InfiniteFly["Enabled"] or not AutoKit["Enabled"] then break; end;
					local part: Model? = not v:IsA('Model') and v or v.PrimaryPart;
					if part and (part.Position - localPosition).Magnitude <= (not Legit["Enabled"] and specific and math.huge or range) then
						func(v);
					end;
				end;
			end;
			task.wait(0.1);
		until not AutoKit["Enabled"];
	end;
	
	local AutoKitFunctions: table = {
		battery = function()
			repeat
				if entitylib.isAlive then
					local localPosition: Vector3 = entitylib.character.RootPart.Position;
					for i, v in bedwars.BatteryEffectsController.liveBatteries do
						if (v.position - localPosition).Magnitude <= 10 then
							local BatteryInfo: any = bedwars.BatteryEffectsController:getBatteryInfo(i);
							if not BatteryInfo or BatteryInfo.activateTime >= workspace:GetServerTimeNow() or BatteryInfo.consumeTime + 0.1 >= workspace:GetServerTimeNow() then continue; end;
							BatteryInfo.consumeTime = workspace:GetServerTimeNow();
							bedwars.Client:Get(remotes.ConsumeBattery):SendToServer({batteryId = i});
						end;
					end;
				end;
				task.wait(0.1);
			until not AutoKit["Enabled"];
		end,
		bigman = function()
			kitCollection('treeOrb', function(v)
				if bedwars.Client:Get(remotes.ConsumeTreeOrb):CallServer({treeOrbSecret = v:GetAttribute('TreeOrbSecret')}) then
					v:Destroy();
				end;
			end, 12, false);
		end,
		cat = function()
			local old: any = bedwars.CatController.leap;
			bedwars.CatController.leap = function(...)
				vapeEvents.CatPounce:Fire();
				old(...);
			end;
	
			AutoKit:Clean(function()
				bedwars.CatController.leap = old;
			end);
		end,
		dragon_slayer = function()
			kitCollection('KaliyahPunchInteraction', function(v)
				bedwars.DragonSlayerController:deleteEmblem(v);
				bedwars.DragonSlayerController:playPunchAnimation(Vector3.zero);
				bedwars.Client:Get(remotes.KaliyahPunch):SendToServer({
					target = v
				});
			end, 18, true);
		end,
		farmer_cletus = function()
			kitCollection('HarvestableCrop', function(v)
				if bedwars.Client:Get(remotes.HarvestCrop):CallServer({position = bedwars.BlockController:getBlockPosition(v.Position)}) then
					bedwars.GameAnimationUtil.playAnimation(lplr.Character, bedwars.AnimationType.PUNCH);
					bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST);
				end;
			end, 10, false);
		end,
		fisherman = function()
			local old: any = bedwars.FishingMinigameController.startMinigame;
			bedwars.FishingMinigameController.startMinigame = function(_, _, result)
				result({win = true});
			end;
			AutoKit:Clean(function()
				bedwars.FishingMinigameController.startMinigame = old;
			end);
		end,
		gingerbread_man = function()
			local old: any = bedwars.LaunchPadController.attemptLaunch;
			bedwars.LaunchPadController.attemptLaunch = function(...)
				local res: any = {old(...)};
				local self, block: any = ...
				if (workspace:GetServerTimeNow() - self.lastLaunch) < 0.4 then
					if block:GetAttribute('PlacedByUserId') == lplr.UserId and (block.Position - entitylib.character.RootPart.Position).Magnitude < 30 then
						task.spawn(bedwars.breakBlock, block, false, nil, true);
					end;
				end;
				return unpack(res);
			end;
			AutoKit:Clean(function()
				bedwars.LaunchPadController.attemptLaunch = old;
			end);
		end,
		hannah = function()
			kitCollection('HannahExecuteInteraction', function(v)
				local billboard: any = bedwars.Client:Get(remotes.HannahKill):CallServer({
					user = lplr,
					victimEntity = v
				}) and v:FindFirstChild('Hannah Execution Icon')
				if billboard then
					billboard:Destroy();
				end;
			end, 30, true);
		end,
		grim_reaper = function()
			kitCollection(bedwars.GrimReaperController.soulsByPosition, function(v)
				if entitylib.isAlive and lplr.Character:GetAttribute('Health') <= (lplr.Character:GetAttribute('MaxHealth') / 4) and (not lplr.Character:GetAttribute('GrimReaperChannel')) then
					bedwars.Client:Get(remotes.ConsumeSoul):CallServer({
						secret = v:GetAttribute('GrimReaperSoulSecret')
					});
				end;
			end, 120, false);
		end,
		melody = function()
			repeat
				local mag: number?, hp: number?, ent: number? = 30, math.huge;
				if entitylib.isAlive then
					local localPosition: Vector3 = entitylib.character.RootPart.Position;
					for _, v in entitylib.List do
						if v.Player and v.Player:GetAttribute('Team') == lplr:GetAttribute('Team') then
							local newmag: Vector3? = (localPosition - v.RootPart.Position).Magnitude;
							if newmag <= mag and v.Health < hp and v.Health < v.MaxHealth then
								mag, hp, ent = newmag, v.Health, v;
							end;
						end;
					end;
				end;
	
				if ent and getItem('guitar') then
					bedwars.Client:Get(remotes.GuitarHeal):SendToServer({
						healTarget = ent.Character
					});
				end;
				task.wait(0.1);
			until not AutoKit["Enabled"];
		end,
		metal_detector = function()
			kitCollection('hidden-metal', function(v)
				bedwars.Client:Get(remotes.PickupMetal):SendToServer({
					id = v:GetAttribute('Id')
				});
			end, 20, false);
		end,
		miner = function()
			kitCollection('petrified-player', function(v)
				bedwars.Client:Get(remotes.MinerDig):SendToServer({
					petrifyId = v:GetAttribute('PetrifyId')
				});
			end, 6, true);
		end,
		pinata = function()
			kitCollection(lplr["Name"]..':pinata', function(v)
				if getItem('candy') then
					bedwars.Client:Get(remotes.DepositPinata):CallServer(v);
				end;
			end, 6, true);
		end,
		spirit_assassin = function()
			kitCollection('EvelynnSoul', function(v)
				bedwars.SpiritAssassinController:useSpirit(lplr, v)
			end, 120, true);
		end,
		star_collector = function()
			kitCollection('stars', function(v)
				bedwars.StarCollectorController:collectEntity(lplr, v, v["Name"])
			end, 20, false);
		end,
		summoner = function()
			AutoKit:Clean(bedwars.Client:Get('SummonerClawAttackFromServer'):Connect(function(data)
				if data.player == lplr then
					bedwars.SummonerKitController:clawAttack(data.player, data.position, data.direction);
				end;
			end));
			repeat
				local plr: Player? = entitylib.EntityPosition({
					Range = 31,
					Part = 'RootPart',
					Players = true
				});
	
				if plr then
					local localPosition: Vector3? = entitylib.character.RootPart.Position;
					local shootDir: CFrame? = CFrame.lookAt(localPosition, plr.RootPart.Position).LookVector;
					localPosition += shootDir * math.max((localPosition - plr.RootPart.Position).Magnitude - 16, 0);
					bedwars.Client:Get(remotes.SummonerClawAttack):SendToServer({
						position = localPosition,
						direction = shootDir,
						clientTime = workspace:GetServerTimeNow()
					});
				end;
				task.wait(0.1);
			until not AutoKit["Enabled"];
		end,		
		void_dragon = function()
			local old: any = bedwars.VoidDragonController.voidDragonActive;
			local oldflap: any = bedwars.VoidDragonController.flapWings;
	
			bedwars.VoidDragonController.voidDragonActive = function(self, ...)
				local Client: any = bedwars.Client;
				local Remote: any = remotes.DragonEndFly;
				self.SpeedMaid:GiveTask(function()
					Client:Get(Remote):SendToServer();
				end);
				task.spawn(function()
					for i = 1, 10 do
						if bedwars.Client:Get(remotes.DragonFly):CallServer() then
							local modifier: any = bedwars.SprintController:getMovementStatusModifier():addModifier({
								blockSprint = true,
								constantSpeedMultiplier = 1.7
							});
							self.SpeedMaid:GiveTask(modifier);
							break;
						end;
					end;
				end);
				return old(self, ...);
			end;
			bedwars.VoidDragonController.flapWings = function() end;
	
			AutoKit:Clean(function()
				bedwars.VoidDragonController.voidDragonActive = old;
				bedwars.VoidDragonController.flapWings = oldflap;
				task.spawn(function()
					bedwars.Client:Get(remotes.DragonEndFly):SendToServer();
				end);
			end);
	
			repeat
				if bedwars.VoidDragonController.inDragonForm then
					local plr: Player? = entitylib.EntityPosition({
						Range = 30,
						Part = 'RootPart',
						Players = true
					});
					if plr then
						bedwars.Client:Get(remotes.DragonBreath):SendToServer({
							player = lplr,
							targetPoint = plr.RootPart.Position
						});
					end;
				end;
				task.wait(0.1);
			until not AutoKit["Enabled"];
		end;
	};
	
	AutoKit = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoKit',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat task.wait() until store.equippedKit ~= '' or (not AutoKit["Enabled"]);
				if AutoKit["Enabled"] and AutoKitFunctions[store.equippedKit] and Toggles[store.equippedKit]["Enabled"] then
					AutoKitFunctions[store.equippedKit]();
				end;
			end;
		end,
		["Tooltip"] = 'Automatically uses kit abilities.'
	})
	Legit = AutoKit:CreateToggle({["Name"] = 'Legit Range'})
	for i in AutoKitFunctions do
		Toggles[i] = AutoKit:CreateToggle({
			["Name"] = bedwars.BedwarsKitMeta[i].name,
			["Default"] = true
		});
	end;
end)
	
velo.run(function()
	local AutoPlay: table = {["Enabled"] = false}
	local Random: table = {["Enabled"] = false}
	local function isEveryoneDead(): (any, any)
		return #bedwars.Store:getState().Party.members <= 0;
	end;
	local function joinQueue(): (any, any)
		if not bedwars.Store:getState().Game.customMatch and bedwars.Store:getState().Party.leader.userId == lplr.UserId and bedwars.Store:getState().Party.queueState == 0 then
			if Random["Enabled"] then
				local listofmodes: table = {};
				for i, v in bedwars.QueueMeta do
					if not v.disabled and not v.voiceChatOnly and not v.rankCategory then 
						table.insert(listofmodes, i); 
					end;
				end;
				bedwars.QueueController:joinQueue(listofmodes[math.random(1, #listofmodes)]);
			else
				bedwars.QueueController:joinQueue(store.queueType);
			end;
		end;
	end;
	
	AutoPlay = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoPlay',
		["Function"] = function(callback: boolean): void
			if callback then
				AutoPlay:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill and deathTable.entityInstance == lplr.Character and isEveryoneDead() and store.matchState ~= 2 then
						joinQueue();
					end;
				end));
				AutoPlay:Clean(vapeEvents.MatchEndEvent.Event:Connect(joinQueue));
			end;
		end,
		["Tooltip"] = 'Automatically queues after the match ends.'
	})
	Random = AutoPlay:CreateToggle({
		["Name"] = 'Random',
		["Tooltip"] = 'Chooses a random mode'
	})
end)

velo.run(function()
	local AutoShoot: table = {["Enabled"] = false}
	local shooting: boolean, old: any = false;
	local function getCrossbows(): (any, any)
		local crossbows: table = {}
		for i: any, v: any in store.inventory.hotbar do
			if v.item and v.item.itemType:find('crossbow') and i ~= (store.inventory.hotbarSlot + 1) then table.insert(crossbows, i - 1); end;
		end;
		return crossbows
	end;
	AutoShoot = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoShoot',
		["Function"] = function(callback: boolean): void
			if callback then
				old = bedwars.ProjectileController.createLocalProjectile;
				bedwars.ProjectileController.createLocalProjectile = function(...)
					local source: any, data: any, proj: any = ...;
					if source and (proj == 'arrow' or proj == 'fireball') and not shooting then
						task.spawn(function()
							local bows = getCrossbows();
							if #bows > 0 then
								shooting = true;
								task.wait(0.15);
								local selected: any = store.inventory.hotbarSlot;
								for _, v in getCrossbows() do
									if hotbarSwitch(v) then
										task.wait(0.05);
										mouse1click();
										task.wait(0.05);
									end;
								end;
								hotbarSwitch(selected);
								shooting = false;
							end;
						end);
					end;
					return old(...);
				end;
			else
				bedwars.ProjectileController.createLocalProjectile = old;
			end;
		end,
		["Tooltip"] = 'Automatically crossbow macro\'s'
	})
end)

velo.run(function()
	local AutoVoidDrop: table = {["Enabled"] = false}
	AutoVoidDrop = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoVoidDrop',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat task.wait() until store.matchState ~= 0 or (not AutoVoidDrop["Enabled"]);
				if not AutoVoidDrop["Enabled"] then return; end;
				local lowestpoint: number? = math.huge;
				for _, v in store.blocks do
					local point: Vector3? = (v.Position.Y - (v.Size.Y / 2)) - 50;
					if point < lowestpoint then 
						lowestpoint = point; 
					end;
				end;
				repeat
					if entitylib.isAlive then
						if entitylib.character.RootPart.Position.Y < lowestpoint and (lplr.Character:GetAttribute('InflatedBalloons') or 0) <= 0 and not getItem('balloon') then
							for _, item in {'iron', 'diamond', 'emerald', 'gold'} do 
								item = getItem(item);
								if item then 
									item = bedwars.Client:Get(remotes.DropItem):CallServer({
										item = item.tool,
										amount = item.amount
									});
									if item then 
										item:SetAttribute('ClientDropTime', tick() + 100);
									end;
								end;
							end;
						end;
					end;
					task.wait(0.1);
				until not AutoVoidDrop["Enabled"];
			end;
		end,
		["Tooltip"] = 'Drops resources when you fall into the void'
	})
end)

velo.run(function()
	local MissileTP: table = {["Enabled"] = false}
	MissileTP = vape.Categories.Utility:CreateModule({
		["Name"] = 'MissileTP',
		["Function"] = function(callback: boolean): void
			if callback then
				MissileTP:Toggle();
				local plr: Player? = entitylib.EntityMouse({
					Range = 1000,
					Players = true,
					Part = 'RootPart'
				});
	
				if getItem('guided_missile') and plr then
					local projectile: any = bedwars.RuntimeLib.await(bedwars.GuidedProjectileController.fireGuidedProjectile:CallServerAsync('guided_missile'));
					if projectile then
						local projectilemodel: any? = projectile.model;
						if not projectilemodel.PrimaryPart then
							projectilemodel:GetPropertyChangedSignal('PrimaryPart'):Wait();
						end;
	
						local bodyforce: BodyForce = Instance.new('BodyForce');
						bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0);
						bodyforce.Name = 'AntiGravity';
						bodyforce.Parent = projectilemodel.PrimaryPart;
	
						repeat
							projectile.model:SetPrimaryPartCFrame(CFrame.lookAlong(plr.RootPart.CFrame.p, gameCamera.CFrame.LookVector));
							task.wait(0.1);
						until not projectile.model or not projectile.model.Parent;
					else
						notif('MissileTP', 'Missile on cooldown.', 3);
					end;
				end;
			end;
		end,
		["Tooltip"] = 'Spawns and teleports a missile to a player\nnear your mouse.'
	})
end)

local sv2: table = {}
velo.run(function()
	local PickupRange: table = {["Enabled"] = false};
	local Range: table = {["Value"] = 10};
	local Network: table = {["Enabled"] = false};
	local Lower: table = {["Enabled"] = false};
	local remote: any = replicatedStorage.rbxts_include.node_modules['@rbxts'].net.out._NetManaged.PickupItemDrop;
	PickupRange = vape.Categories.Utility:CreateModule({
		["Name"] = 'PickupRange',
		["Function"] = function(callback: boolean): void
			if callback then
				local items: any = collection('ItemDrop', PickupRange);
				repeat
					if entitylib.isAlive then
						local localPosition: Vector3? = entitylib.character.RootPart.Position;
						for _: any, v: any in items do
							if tick() - (v:GetAttribute('ClientDropTime') or 0) < 2 then 
								continue; 
							end;
							if table.find(sv2, v:GetAttribute('DropTime')) then 
								continue; 
							end;
							if isnetworkowner(v) and Network["Enabled"] and entitylib.character.Humanoid.Health > 0 then 
								v.CFrame = CFrame.new(localPosition - Vector3.new(0, 3, 0)); 
							end;
							
							if (localPosition - v.Position).Magnitude <= Range["Value"]then
								if Lower["Enabled"] and (localPosition.Y - v.Position.Y) < (entitylib.character.HipHeight - 1) then continue end
								task.spawn(function()
									remote:InvokeServer({
										itemDrop = v
									});
								end);
							end;
						end;
					end;
					task.wait(0.1);
				until not PickupRange["Enabled"];
			end;
		end,
		["Tooltip"] = 'Picks up items from a farther distance';
	})
	Range = PickupRange:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 1,
		["Max"] = 10,
		["Default"] = 10,
		["Suffix"] = function(val) 
			return val == 1 and 'stud' or 'studs'; 
		end;
	})
	Network = PickupRange:CreateToggle({
		["Name"] = 'Network TP',
		["Default"] = true
	})
	Lower = PickupRange:CreateToggle({["Name"] = 'Feet Check'})
end)
	
velo.run(function()
	local RavenTP: table = {["Enabled"] = false}
	RavenTP = vape.Categories.Utility:CreateModule({
		["Name"] = 'RavenTP',
		["Function"] = function(callback: boolean): void
			if callback then
				RavenTP:Toggle();
				local plr: Player? = entitylib.EntityMouse({
					Range = 1000,
					Players = true,
					Part = 'RootPart'
				});
				if getItem('raven') and plr then
					bedwars.Client:Get(remotes.SpawnRaven):CallServerAsync():andThen(function(projectile)
						if projectile then
							local bodyforce: BodyForce = Instance.new('BodyForce');
							bodyforce.Force = Vector3.new(0, projectile.PrimaryPart.AssemblyMass * workspace.Gravity, 0);
							bodyforce.Parent = projectile.PrimaryPart;
	
							if plr then
								task.spawn(function()
									for _ = 1, 20 do
										if plr.RootPart and projectile then
											projectile:SetPrimaryPartCFrame(CFrame.lookAlong(plr.RootPart.Position, gameCamera.CFrame.LookVector));
										end;
										task.wait(0.05);
									end;
								end);
								task.wait(0.3);
								bedwars.RavenController:detonateRaven();
							end;
						end;
					end);
				end;
			end;
		end,
		["Tooltip"] = 'Spawns and teleports a raven to a player\nnear your mouse.'
	})
end)


velo.run(function()
	local Scaffold: table = {["Enabled"] = false};
	local Expand: table = {["Enabled"] = false};
	local Tower: table = {["Enabled"] = false};
	local Downwards: table = {["Enabled"] = false};
	local Diagonal: table = {["Enabled"] = false};
	local LimitItem: table = {["Enabled"] = false};
	local Mouse: table = {["Enabled"] = false};
	local adjacent: table?, lastpos: Vector3? = {}, Vector3.zero;
	
	for x = -3, 3, 3 do
		for y = -3, 3, 3 do
			for z = -3, 3, 3 do
				local vec: Vector3? = Vector3.new(x, y, z);
				if vec ~= Vector3.zero then
					table.insert(adjacent, vec); 
				end;
			end;
		end;
	end;
	
	local function nearCorner(poscheck: any, pos: any): Vector3?
		local startpos: Vector3? = poscheck - Vector3.new(3, 3, 3);
		local endpos: Vector3? = poscheck + Vector3.new(3, 3, 3);
		local check: Vector3? = poscheck + (pos - poscheck).Unit * 100;
		return Vector3.new(math.clamp(check.X, startpos.X, endpos.X), math.clamp(check.Y, startpos.Y, endpos.Y), math.clamp(check.Z, startpos.Z, endpos.Z));
	end;
	
	local function blockProximity(pos: number?): any
		local mag: number?, returned: number? = 60;
		local tab: any = getBlocksInPoints(bedwars.BlockController:getBlockPosition(pos - Vector3.new(21, 21, 21)), bedwars.BlockController:getBlockPosition(pos + Vector3.new(21, 21, 21)));
		for _, v in tab do
			local blockpos: Vector3? = nearCorner(v, pos);
			local newmag: Vector3? = (pos - blockpos).Magnitude;
			if newmag < mag then
				mag, returned = newmag, blockpos;
			end;
		end;
		table.clear(tab);
		return returned;
	end;
	
	local function checkAdjacent(pos: Vector3?): boolean
		for _, v in adjacent do
			if getPlacedBlock(pos + v) then 
				return true ;
			end;
		end;
		return false;
	end;
	
	local function getBlock(): (any, any)
		for _, item in store.inventory.inventory.items do
			if bedwars.ItemMeta[item.itemType].block then
				return item.itemType, item.amount;
			end;
		end;
	end;
	
	Scaffold = vape.Categories.Utility:CreateModule({
		["Name"] = 'Scaffold',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					if entitylib.isAlive then
						local wool: any = store.hand.toolType == 'block' and store.hand.tool["Name"] or (not LimitItem["Enabled"]) and (getWool() or getBlock());
						if Mouse["Enabled"] then
							if not inputService:IsMouseButtonPressed(0) then
								wool = nil;
							end;
						end;
						if wool then
							local root: Vector3 = entitylib.character.RootPart;
							if Tower["Enabled"] and inputService:IsKeyDown(Enum.KeyCode.Space) and (not inputService:GetFocusedTextBox()) then
								root.Velocity = Vector3.new(root.Velocity.X, 38, root.Velocity.Z);
							end;
	
							for i = Expand.Value, 1, -1 do
								local currentpos: Vector3? = roundPos(root.Position - Vector3.new(0, entitylib.character.HipHeight + (Downwards["Enabled"] and inputService:IsKeyDown(Enum.KeyCode.LeftShift) and 4.5 or 1.5), 0) + entitylib.character.Humanoid.MoveDirection * (i * 3));
								if Diagonal["Enabled"] then
									if math.abs(math.round(math.deg(math.atan2(-entitylib.character.Humanoid.MoveDirection.X, -entitylib.character.Humanoid.MoveDirection.Z)) / 45) * 45) % 90 == 45 then
										local dt: number? = (lastpos - currentpos);
										if ((dt.X == 0 and dt.Z ~= 0) or (dt.X ~= 0 and dt.Z == 0)) and ((lastpos - root.Position) * Vector3.new(1, 0, 1)).Magnitude < 2.5 then
											currentpos = lastpos;
										end;
									end;
								end;
	
								local block: Vector3?, blockpos: number? = getPlacedBlock(currentpos);
								if not block then
									blockpos = checkAdjacent(blockpos * 3) and blockpos * 3 or blockProximity(currentpos);
									if blockpos then 
										task.spawn(bedwars.placeBlock, blockpos, wool, false); 
									end;
								end;
								lastpos = currentpos;
							end;
						end;
					end;
					task.wait(0.03)
				until not Scaffold["Enabled"];
			end;
		end,
		["Tooltip"] = 'Helps you make bridges/scaffold walk.'
	})
	Expand = Scaffold:CreateSlider({
		["Name"] = 'Expand',
		["Min"] = 1,
		["Max"] = 6
	})
	Tower = Scaffold:CreateToggle({
		["Name"] = 'Tower',
		["Default"] = true
	})
	Downwards = Scaffold:CreateToggle({
		["Name"] = 'Downwards',
		["Default"] = true
	})
	Diagonal = Scaffold:CreateToggle({
		["Name"] = 'Diagonal',
		["Default"] = true
	})
	LimitItem = Scaffold:CreateToggle({["Name"] = 'Limit to items'})
	Mouse = Scaffold:CreateToggle({["Name"] = 'Require mouse down'})
end)
	
velo.run(function()
	local tiered: table, nexttier: table = {}, {}
	local ShopTierBypass: table = {["Enabled"] = false};
	ShopTierBypass = vape.Categories.Utility:CreateModule({
		["Name"] = 'ShopTierBypass',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat task.wait() until store.shopLoaded or not ShopTierBypass["Enabled"]
				if ShopTierBypass["Enabled"] then
					for _, v in bedwars.Shop.ShopItems do
						tiered[v] = v.tiered;
						nexttier[v] = v.nextTier;
						v.nextTier = nil;
						v.tiered = nil;
					end;
				end;
			else
				for i: any, v: any in tiered do 
					i.tiered = v; 
				end;
				for i: any, v: any in nexttier do 
					i.nextTier = v; 
				end;
				table.clear(nexttier);
				table.clear(tiered);
			end;
		end,
		["Tooltip"] = 'Lets you buy things like armor early.'
	})
end)

velo.run(function()
	local ArmorSwitch: table = {["Enabled"] = false};
	local Mode: table = {}
	local Targets: table = {};
	local Range: table = {}
	
	ArmorSwitch = vape.Categories.Inventory:CreateModule({
		["Name"] = 'ArmorSwitch',
		["Function"] = function(callback: boolean): void
			if callback then
				if Mode["Value"] == 'Toggle' then
					repeat
						local state: any = entitylib.EntityPosition({
							Part = 'RootPart',
							Range = Range["Value"],
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Wallcheck = Targets.Walls.Enabled
						}) and true or false
	
						for i = 0, 2 do
							if (store.inventory.inventory.armor[i + 1] ~= 'empty') ~= state and ArmorSwitch["Enabled"] then
								bedwars.Store:dispatch({
									type = 'InventorySetArmorItem',
									item = store.inventory.inventory.armor[i + 1] == 'empty' and state and getBestArmor(i) or nil,
									armorSlot = i
								});
								vapeEvents.InventoryChanged.Event:Wait();
							end;
						end;
						task.wait(0.1);
					until not ArmorSwitch["Enabled"];
				else
					ArmorSwitch:Toggle();
					for i = 0, 2 do
						bedwars.Store:dispatch({
							type = 'InventorySetArmorItem',
							item = store.inventory.inventory.armor[i + 1] == 'empty' and getBestArmor(i) or nil,
							armorSlot = i
						});
						vapeEvents.InventoryChanged.Event:Wait();
					end;
				end;
			end;
		end,
		["Tooltip"] = 'Puts on / takes off armor when toggled for baiting.'
	})
	Mode = ArmorSwitch:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Toggle', 'On Key'}
	})
	Targets = ArmorSwitch:CreateTargets({
		["Players"] = true,
		["NPCs"] = true
	})
	Range = ArmorSwitch:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 1,
		["Max"] = 30,
		["Default"] = 30,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs';
		end;
	})
end)

velo.run(function()
	local StaffDetector: table = {["Enabled"] = false}
	local Mode: table = {};
	local Clans: table = {};
	local Profile: table = {};
	local Users: table = {};
	local blacklistedclans: table? = {'gg', 'gg2', 'DV', 'DV2'}
	local blacklisteduserids: table? = {1502104539, 3826146717, 4531785383, 1049767300, 4926350670, 653085195, 184655415, 2752307430, 5087196317, 5744061325, 1536265275}
	local joined: table? = {}
	
	local function getRole(plr: Player?, id: string?): any
		local suc: boolean?, res: any = pcall(function() 
			return plr:GetRankInGroup(id);
		end);
		if not suc then 
			notif('StaffDetector', res, 30, 'alert');
		end;
		return suc and res or 0;
	end;
	
	local function staffFunction(plr: Player?, checktype: any): any
		if not vape.Loaded then repeat task.wait() until vape.Loaded end;
		notif('StaffDetector', 'Staff Detected ('..checktype..'): '..plr["Name"]..' ('..plr.UserId..')', 60, 'alert');
		whitelist.customtags[plr["Name"]] = {{text = 'GAME STAFF', color = Color3.new(1, 0, 0)}};
	
		if Mode["Value"]== 'Uninject' then
			task.spawn(function() 
				vape:Uninject();
			end);
			game:GetService('StarterGui'):SetCore('SendNotification', {
				Title = 'StaffDetector',
				Text = 'Staff Detected ('..checktype..')\n'..plr["Name"]..' ('..plr.UserId..')',
				Duration = 60,
			});
		elseif Mode["Value"]== 'Profile' then
			vape.Save = function() end;
			if vape.Profile ~= Profile["Value"]then
				vape:Load(true, Profile.Value);
			end;
		elseif Mode["Value"]== 'AutoConfig' then
			local safe: table? = {'AutoClicker', 'Reach', 'Sprint', 'HitFix', 'StaffDetector'};
			vape.Save = function() end;
			for i, v in vape.Modules do
				if not (table.find(safe, i) or v.Category == 'Render') then
					if v["Enabled"] then 
						v:Toggle();
					end;
					v:SetBind('');
				end;
			end;
		end;
	end;
	
	local function checkFriends(list: any): boolean?
		for _, v in list do
			if joined[v] then 
				return joined[v];
			end;
		end;
		return nil;
	end;
	
	local function checkJoin(plr: Player?, connection: any): any
		if not plr:GetAttribute('Team') and plr:GetAttribute('Spectator') and not bedwars.Store:getState().Game.customMatch then
			connection:Disconnect();
			local tab: table?, pages: any = {}, playersService:GetFriendsAsync(plr.UserId);
			for _ = 1, 4 do
				for _, v in pages:GetCurrentPage() do 
					table.insert(tab, v.Id);
				end;
				if pages.IsFinished then break; end;
				pages:AdvanceToNextPageAsync();
			end;
	
			local friend: any = checkFriends(tab)
			if not friend then
				staffFunction(plr, 'impossible_join');
				return true;
			else
				notif('StaffDetector', string.format('Spectator %s joined from %s', plr["Name"], friend), 20, 'warning');
			end;
		end;
	end;
	
	local function playerAdded(plr: player?): any
		joined[plr.UserId] = plr["Name"];
		if plr == lplr then return; end;
		if table.find(blacklisteduserids, plr.UserId) or table.find(Users.ListEnabled, tostring(plr.UserId)) then
			staffFunction(plr, 'blacklisted_user');
			return;
		end;
	
		if getRole(plr, 5774246) >= 100 then
			staffFunction(plr, 'staff_role');
		else
			local connection: any;
			connection = plr:GetAttributeChangedSignal('Spectator'):Connect(function() 
				checkJoin(plr, connection) 
			end);
			StaffDetector:Clean(connection);
			if checkJoin(plr, connection) then
				return;
			end;
			if not plr:GetAttribute('ClanTag') then
				plr:GetAttributeChangedSignal('ClanTag'):Wait();
			end;
			if table.find(blacklistedclans, plr:GetAttribute('ClanTag')) and vape.Loaded and Clans["Enabled"] then
				connection:Disconnect();
				staffFunction(plr, 'blacklisted_clan_'..plr:GetAttribute('ClanTag'):lower());
			end;
		end;
	end;
	
	StaffDetector = vape.Categories.Utility:CreateModule({
		["Name"] = 'StaffDetector',
		["Function"] = function(callback: boolean): void
			if callback then
				StaffDetector:Clean(playersService.PlayerAdded:Connect(playerAdded));
				for _, v in playersService:GetPlayers() do 
					task.spawn(playerAdded, v); 
				end;
			else
				table.clear(joined);
			end;
		end,
		["Tooltip"] = 'Detects people with a staff rank ingame'
	})
	Mode = StaffDetector:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Uninject', 'Profile', 'AutoConfig', 'Notify'},
		["Function"] = function(val)
			if Profile.Object then
				Profile.Object.Visible = val == 'Profile';
			end;
		end;
	})
	Clans = StaffDetector:CreateToggle({
		["Name"] = 'Blacklist clans',
		["Default"] = true
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
	task.spawn(function()
		repeat task.wait(1) until vape.Loaded or vape.Loaded == nil
		if vape.Loaded and not StaffDetector["Enabled"] then
			StaffDetector:Toggle();
		end;
	end);
end)

velo.run(function()
	StoreDamage = vape.Categories.Utility:CreateModule({
		["Name"] = 'StoreDamage',
		["Tooltip"] = 'Store damage knockback packets for certain modules.'
	})
end)
	
velo.run(function()
	TrapDisabler = vape.Categories.Utility:CreateModule({
		["Name"] = 'TrapDisabler',
		["Tooltip"] = 'Disables Snap Traps'
	})
end)

velo.run(function()
	vape.Categories.World:CreateModule({
		["Name"] = 'Anti-AFK',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v in getconnections(lplr.Idled) do
					v:Disconnect();
				end;
				for _, v in getconnections(runService.Heartbeat) do
					if type(v.Function) == 'function' and table.find(debug.getconstants(v.Function), remotes.AfkStatus) then
						v:Disconnect();
					end;
				end;
				bedwars.Client:Get(remotes.AfkStatus):SendToServer({
					afk = false
				});
			end;
		end,
		["Tooltip"] = 'Lets you stay ingame without getting kicked'
	})
end)

velo.run(function()
	local AutoTool: table = {["Enabled"] = false}
	local old: any, event: any;
	
	local function switchHotbarItem(block: any): boolean?
		if block and not block:GetAttribute('NoBreak') and not block:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') then
			local tool: any, slot: any = store.tools[bedwars.ItemMeta[block.Name].block.breakType], nil;
			if tool then
				for i, v in store.inventory.hotbar do
					if v.item and v.item.itemType == tool.itemType then slot = i - 1 break; end;
				end;
	
				if hotbarSwitch(slot) then
					if inputService:IsMouseButtonPressed(0) then 
						event:Fire(); 
					end;
					return true;
				end;
			end;
		end;
	end;
	
	AutoTool = vape.Categories.World:CreateModule({
		["Name"] = 'AutoTool',
		["Function"] = function(callback: boolean): void
			if callback then
				event = Instance.new('BindableEvent');
				AutoTool:Clean(event);
				AutoTool:Clean(event.Event:Connect(function()
					contextActionService:CallFunction('block-break', Enum.UserInputState.Begin, newproxy(true));
				end));
				old = bedwars.BlockBreaker.hitBlock;
				bedwars.BlockBreaker.hitBlock = function(self, maid, raycastparams, ...)
					local block: any = self.clientManager:getBlockSelector():getMouseInfo(1, {ray = raycastparams});
					if switchHotbarItem(block and block.target and block.target.blockInstance or nil) then return; end;
					return old(self, maid, raycastparams, ...);
				end;
			else
				bedwars.BlockBreaker.hitBlock = old;
				old = nil;
			end;
		end,
		["Tooltip"] = 'Automatically selects the correct tool'
	})
end)
	
velo.run(function()
	local BedProtector: table = {["Enabled"] = false}
	local function getBedNear(): (any, any)
		local localPosition: Vector3? = entitylib.isAlive and entitylib.character.RootPart.Position or Vector3.zero;
		for _, v in collectionService:GetTagged('bed') do
			if (localPosition - v.Position).Magnitude < 20 and v:GetAttribute('Team'..(lplr:GetAttribute('Team') or -1)..'NoBreak') then
				return v;
			end;
		end;
	end;
	
	local function getBlocks(): (any, any)
		local blocks: table? = {};
		for _, item in store.inventory.inventory.items do
			local block: any = bedwars.ItemMeta[item.itemType].block;
			if block then
				table.insert(blocks, {item.itemType, block.health});
			end;
		end;
		table.sort(blocks, function(a, b) 
			return a[2] > b[2];
		end);
		return blocks;
	end;
	
	local function getPyramid(size: number?, grid: number?): any
		local positions: table? = {}
		for h = size, 0, -1 do
			for w = h, 0, -1 do
				table.insert(positions, Vector3.new(w, (size - h), ((h + 1) - w)) * grid);
				table.insert(positions, Vector3.new(w * -1, (size - h), ((h + 1) - w)) * grid);
				table.insert(positions, Vector3.new(w, (size - h), (h - w) * -1) * grid);
				table.insert(positions, Vector3.new(w * -1, (size - h), (h - w) * -1) * grid);
			end;
		end;
		return positions;
	end;
	
	BedProtector = vape.Categories.World:CreateModule({
		["Name"] = 'BedProtector',
		["Function"] = function(callback: boolean): void
			if callback then
				local bed: any = getBedNear();
				bed = bed and bed.Position or nil;
				if bed then
					for i, block in getBlocks() do
						for _, pos in getPyramid(i, 3) do
							if not BedProtector["Enabled"] then break; end;
							if getPlacedBlock(bed + pos) then continue; end;
							bedwars.placeBlock(bed + pos, block[1], false);
						end;
					end;
					if BedProtector["Enabled"] then 
						BedProtector:Toggle();
					end;
				else
					notif('BedProtector', 'Unable to locate bed', 5);
					BedProtector:Toggle();
				end;
			end;
		end,
		["Tooltip"] = 'Automatically places strong blocks around the bed.'
	})
end)

velo.run(function()
	local ChestSteal: table = {["Enabled"] = false}
	local Range: table = {["Value"] = 22}
	local Open: table = {["Enabled"] = false}
	local Skywars: table = {["Enabled"] = false}
	local Delays: table? = {}
	
	local function lootChest(chest: any): any
		chest = chest and chest["Value"]or nil;
		local chestitems: table? = chest and chest:GetChildren() or {};
		if #chestitems > 1 and (Delays[chest] == nil or Delays[chest] < tick()) then
			Delays[chest] = tick() + 0.3;
			bedwars.Client:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(chest);
			for _, v in chestitems do
				if v:IsA('Accessory') then
					task.spawn(function()
						pcall(function()
							bedwars.Client:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(chest, v);
						end);
					end);
				end;
			end;
			bedwars.Client:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(nil);
		end;
	end;
	
	ChestSteal = vape.Categories.World:CreateModule({
		["Name"] = 'ChestSteal',
		["Function"] = function(callback: boolean): void
			if callback then
				local chests: Instance? = collection('chest', ChestSteal);
				repeat task.wait() until store.queueType ~= 'bedwars_test'
				if (not Skywars["Enabled"]) or store.queueType:find('skywars') then
					repeat
						if entitylib.isAlive and store.matchState ~= 2 then
							if Open["Enabled"] then
								if bedwars.AppController:isAppOpen('ChestApp') then
									lootChest(lplr.Character:FindFirstChild('ObservedChestFolder'));
								end;
							else
								local localPosition: Vector3 = entitylib.character.RootPart.Position;
								for _, v in chests do
									if (localPosition - v.Position).Magnitude <= Range["Value"]then
										lootChest(v:FindFirstChild('ChestFolderValue'));
									end;
								end;
							end;
						end;
						task.wait(0.1);
					until not ChestSteal["Enabled"];
				end;
			end;
		end,
		["Tooltip"] = 'Grabs items from near chests.'
	})
	Range = ChestSteal:CreateSlider({
		["Name"] = 'Range',
		["Min"] = 0,
		["Max"] = 22,
		["Default"] = 22,
		["Suffix"] = function(val) 
			return val == 1 and 'stud' or 'studs'; 
		end;
	})
	Open = ChestSteal:CreateToggle({Name = 'GUI Check'})
	Skywars = ChestSteal:CreateToggle({
		["Name"] = 'Only Skywars',
		["Function"] = function()
			if ChestSteal["Enabled"] then
				ChestSteal:Toggle();
				ChestSteal:Toggle();
			end;
		end,
		["Default"] = true
	})
end)

velo.run(function()
	local Schematica: table = {["Enabled"] = false}
	local File: table = {};
	local Mode: table = {};
	local Transparency: table = {};
	local parts: table?, guidata: table?, poschecklist: table? = {}, {}, {}
	local point1: any, point2: any;
	
	for x = -3, 3, 3 do
		for y = -3, 3, 3 do
			for z = -3, 3, 3 do
				if Vector3.new(x, y, z) ~= Vector3.zero then
					table.insert(poschecklist, Vector3.new(x, y, z));
				end;
			end;
		end;
	end;
	
	local function checkAdjacent(pos: Vector3?): boolean?
		for _, v in poschecklist do
			if getPlacedBlock(pos + v) then return true; end;
		end;
		return false;
	end;
	
	local function getPlacedBlocksInPoints(s: any, e: any): any
		local list: table?, blocks: any = {}, bedwars.BlockController:getStore();
		for x = (e.X > s.X and s.X or e.X), (e.X > s.X and e.X or s.X) do
			for y = (e.Y > s.Y and s.Y or e.Y), (e.Y > s.Y and e.Y or s.Y) do
				for z = (e.Z > s.Z and s.Z or e.Z), (e.Z > s.Z and e.Z or s.Z) do
					local vec: Vector3? = Vector3.new(x, y, z);
					local block: Vector3? = blocks:getBlockAt(vec);
					if block and block:GetAttribute('PlacedByUserId') == lplr.UserId then
						list[vec] = block;
					end;
				end;
			end;
		end;
		return list;
	end;
	
	local function loadMaterials(): (any, any)
		for _, v in guidata do 
			v:Destroy() ;
		end;
		local suc: boolean?, read: any = pcall(function() 
			return isfile(File["Value"]) and httpService:JSONDecode(readfile(File["Value"])); 
		end);
	
		if suc and read then
			local items: table = {};
			for _, v in read do 
				items[v[2]] = (items[v[2]] or 0) + 1;
			end;
			
			for i, v in items do
				local holder: Frame = Instance.new('Frame');
				holder.Size = UDim2.new(1, 0, 0, 32);
				holder.BackgroundTransparency = 1;
				holder.Parent = Schematica.Children;
				local icon: ImageLabel = Instance.new('ImageLabel');
				icon.Size = UDim2.fromOffset(24, 24);
				icon.Position = UDim2.fromOffset(4, 4);
				icon.BackgroundTransparency = 1;
				icon.Image = bedwars.getIcon({itemType = i}, true);
				icon.Parent = holder;
				local text: TextLabel = Instance.new('TextLabel');
				text.Size = UDim2.fromOffset(100, 32);
				text.Position = UDim2.fromOffset(32, 0);
				text.BackgroundTransparency = 1;
				text.Text = (bedwars.ItemMeta[i] and bedwars.ItemMeta[i].displayName or i)..': '..v;
				text.TextXAlignment = Enum.TextXAlignment.Left;
				text.TextColor3 = uipallet.Text;
				text.TextSize = 14;
				text.FontFace = uipallet.Font;
				text.Parent = holder;
				table.insert(guidata, holder);
			end;
			table.clear(read);
			table.clear(items);
		end;
	end;
	
	local function save(): (any, any) 
		if point1 and point2 then
			local tab: any = getPlacedBlocksInPoints(point1, point2);
			local savetab: table? = {};
			point1 = point1 * 3;
			for i, v in tab do
				i = bedwars.BlockController:getBlockPosition(CFrame.lookAlong(point1, entitylib.character.RootPart.CFrame.LookVector):PointToObjectSpace(i * 3)) * 3
				table.insert(savetab, {
					{
						x = i.X, 
						y = i.Y, 
						z = i.Z
					}, 
					v["Name"]
				});
			end;
			point1, point2 = nil, nil;
			writefile(File.Value, httpService:JSONEncode(savetab));
			notif('Schematica', 'Saved '..getTableSize(tab)..' blocks', 5);
			loadMaterials();
			table.clear(tab);
			table.clear(savetab);
		else
			local mouseinfo: any = bedwars.BlockBreaker.clientManager:getBlockSelector():getMouseInfo(0);
			if mouseinfo and mouseinfo.target then
				if point1 then
					point2 = mouseinfo.target.blockRef.blockPosition;
					notif('Schematica', 'Selected position 2, toggle again near position 1 to save it', 3);
				else
					point1 = mouseinfo.target.blockRef.blockPosition;
					notif('Schematica', 'Selected position 1', 3);
				end;
			end;
		end;
	end;
	
	local function load(read: any): any
		local mouseinfo: any = bedwars.BlockBreaker.clientManager:getBlockSelector():getMouseInfo(0);
		if mouseinfo and mouseinfo.target then
			local position: CFrame? = CFrame.new(mouseinfo.placementPosition * 3) * CFrame.Angles(0, math.rad(math.round(math.deg(math.atan2(-entitylib.character.RootPart.CFrame.LookVector.X, -entitylib.character.RootPart.CFrame.LookVector.Z)) / 45) * 45), 0);
	
			for _, v in read do
				local blockpos: Vector3? = bedwars.BlockController:getBlockPosition((position * CFrame.new(v[1].x, v[1].y, v[1].z)).p) * 3;
				if parts[blockpos] then continue; end;
				local handler: any = bedwars.BlockController:getHandlerRegistry():getHandler(v[2]:find('wool') and getWool() or v[2]);
				if handler then
					local part: any = handler:place(blockpos / 3, 0);
					part.Transparency = Transparency["Value"];
					part.CanCollide = false;
					part.Anchored = true;
					part.Parent = workspace;
					parts[blockpos] = part;
				end;
			end;
			table.clear(read);
			repeat
				if entitylib.isAlive then
					local localPosition: Vector3 = entitylib.character.RootPart.Position;
					for i, v in parts do
						if (i - localPosition).Magnitude < 60 and checkAdjacent(i) then
							if not Schematica["Enabled"] then break; end;
							if not getItem(v.Name) then continue; end;
							bedwars.placeBlock(i, v.Name, false)
							task.delay(0.1, function()
								local block: any = getPlacedBlock(i);
								if block then
									v:Destroy();
									parts[i] = nil;
								end;
							end);
						end;
					end;
				end;
				task.wait();
			until getTableSize(parts) <= 0
	
			if getTableSize(parts) <= 0 and Schematica["Enabled"] then
				notif('Schematica', 'Finished building', 5);
				Schematica:Toggle();
			end;
		end;
	end;
	
	Schematica = vape.Categories.World:CreateModule({
		["Name"] = 'Schematica',
		["Function"] = function(callback: boolean): void
			if callback then
				if not File.Value:find('.json') then
					notif('Schematica', 'Invalid file', 3);
					Schematica:Toggle();
					return;
				end;
	
				if Mode["Value"]== 'Save' then
					save();
					Schematica:Toggle();
				else
					local suc: any, read: any = pcall(function() 
						return isfile(File["Value"]) and httpService:JSONDecode(readfile(File["Value"])); 
					end);
	
					if suc and read then
						load(read);
					else
						notif('Schematica', 'Missing / corrupted file', 3);
						Schematica:Toggle();
					end;
				end;
			else
				for _, v in parts do 
					v:Destroy(); 
				end;
				table.clear(parts);
			end;
		end,
		["Tooltip"] = 'Save and load placements of buildings'
	})
	File = Schematica:CreateTextBox({
		["Name"] = 'File',
		["Function"] = function()
			loadMaterials();
			point1, point2 = nil, nil;
		end;
	})
	Mode = Schematica:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Load', 'Save'}
	})
	Transparency = Schematica:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.7,
		["Decimal"] = 10,
		["Function"] = function(val)
			for _, v in parts do 
				v.Transparency = val; 
			end;
		end;
	})
end)

velo.run(function()
	local AutoBuy: table = {["Enabled"] = false}
	local Sword: table = {["Enabled"] = false}
	local Armor: table = {["Enabled"] = false}
	local Upgrades: table = {["Enabled"] = false}
	local TierCheck: table = {["Enabled"] = false}
	local BedwarsCheck: table = {["Enabled"] = false}
	local GUI: any;
	local SmartCheck: table = {["Enabled"] = false}
	local Custom: table? = {}
	local CustomPost: table? = {}
	local UpgradeToggles: table? = {}
	local Functions: table?, id: table? = {}
	local Callbacks: any = {Custom, Functions, CustomPost}
	local npctick: number = tick()
	
	local swords: table = {
		'wood_sword',
		'stone_sword',
		'iron_sword',
		'diamond_sword',
		'emerald_sword'
	};
	
	local armors: table = {
		'none',
		'leather_chestplate',
		'iron_chestplate',
		'diamond_chestplate',
		'emerald_chestplate'
	};
	
	local axes: table = {
		'none',
		'wood_axe',
		'stone_axe',
		'iron_axe',
		'diamond_axe'
	};
	
	local pickaxes: table = {
		'none',
		'wood_pickaxe',
		'stone_pickaxe',
		'iron_pickaxe',
		'diamond_pickaxe'
	};
	
	local function getShopNPC(): (any, any) 
		local shop: any, items: boolean?, upgrades: boolean?, newid: any = nil, false, false, nil
		if entitylib.isAlive then
			local localPosition: Vector3 = entitylib.character.RootPart.Position
			for _, v in store.shop do
				if (v.RootPart.Position - localPosition).Magnitude <= 20 then
					shop = v.Upgrades or v.Shop or nil;
					upgrades = upgrades or v.Upgrades;
					items = items or v.Shop;
					newid = v.Shop and v.Id or newid;
				end;
			end;
		end;
		return shop, items, upgrades, newid;
	end;
	
	local function canBuy(item: any, currencytable: any, amount: number?): any
		amount = amount or 1;
		if not currencytable[item.currency] then
			local currency: any = getItem(item.currency);
			currencytable[item.currency] = currency and currency.amount or 0;
		end;
		if item.ignoredByKit and table.find(item.ignoredByKit, store.equippedKit or '') then return false; end;
		if item.lockedByForge or item.disabled then return false; end;
		if item.require and item.require.teamUpgrade then
			if (bedwars.Store:getState().Bedwars.teamUpgrades[item.require.teamUpgrade.upgradeId] or -1) < item.require.teamUpgrade.lowestTierIndex then
				return false;
			end;
		end;
		return currencytable[item.currency] >= (item.price * amount);
	end;
	
	local function buyItem(item: any, currencytable: any): any
		if not id then return; end;
		notif('AutoBuy', 'Bought '..bedwars.ItemMeta[item.itemType].displayName, 3)
		bedwars.Client:Get('BedwarsPurchaseItem'):CallServerAsync({
			shopItem = item,
			shopId = id
		}):andThen(function(suc)
			if suc then
				bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
				bedwars.Store:dispatch({
					type = 'BedwarsAddItemPurchased',
					itemType = item.itemType
				});
				bedwars.BedwarsShopController.alreadyPurchasedMap[item.itemType] = true;
			end;
		end);
		currencytable[item.currency] -= item.price;
	end;
	
	local function buyUpgrade(upgradeType: any, currencytable: any): any
		if not Upgrades["Enabled"] then return end
		local upgrade: any = bedwars.TeamUpgradeMeta[upgradeType]
		local currentUpgrades: any = bedwars.Store:getState().Bedwars.teamUpgrades[lplr:GetAttribute('Team')] or {};
		local currentTier: number? = (currentUpgrades[upgradeType] or 0) + 1;
		local bought: boolean = false;
		for i = currentTier, #upgrade.tiers do
			local tier: any = upgrade.tiers[i];
			if tier.availableOnlyInQueue and not table.find(tier.availableOnlyInQueue, store.queueType) then continue; end;
			if canBuy({currency = 'diamond', price = tier.cost}, currencytable) then
				notif('AutoBuy', 'Bought '..(upgrade.name == 'Armor' and 'Protection' or upgrade.name)..' '..i, 3);
				bedwars.Client:Get('RequestPurchaseTeamUpgrade'):CallServerAsync(upgradeType);
				currencytable.diamond -= tier.cost;
				bought = true;
			else
				break;
			end;
		end;
		return bought;
	end;
	
	local function buyTool(tool: any, tools: any, currencytable: any): any
		local bought: boolean?, buyable: boolean? = false;
		tool = tool and table.find(tools, tool.itemType) and table.find(tools, tool.itemType) + 1 or math.huge
		for i = tool, #tools do
			local v: any = bedwars.Shop.getShopItem(tools[i], lplr);
			if canBuy(v, currencytable) then
				if SmartCheck["Enabled"] and bedwars.ItemMeta[tools[i]].breakBlock and i > 2 then
					if Armor["Enabled"] then
						local currentarmor: any = store.inventory.inventory.armor[2];
						currentarmor = currentarmor and currentarmor ~= 'empty' and currentarmor.itemType or 'none';
						if (table.find(armors, currentarmor) or 3) < 3 then break; end;
					end
					if Sword["Enabled"] then
						if store.tools.sword and (table.find(swords, store.tools.sword.itemType) or 2) < 2 then break; end;
					end;
				end;
				bought = true;
				buyable = v;
			end;
			if TierCheck["Enabled"] and v.nextTier then break; end;
		end;
		if buyable then
			buyItem(buyable, currencytable);
		end;
		return bought;
	end;
	
	AutoBuy = vape.Categories.Inventory:CreateModule({
		["Name"] = 'AutoBuy',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat task.wait() until store.queueType ~= 'bedwars_test'
				if BedwarsCheck["Enabled"] and not store.queueType:find('bedwars') then return; end;
				local lastupgrades: any;
				AutoBuy:Clean(vapeEvents.InventoryAmountChanged.Event:Connect(function()
					if (npctick - tick()) > 1 then npctick = tick(); end;
				end));
				repeat
					local npc: any, shop: any, upgrades: any, newid: any = getShopNPC();
					id = newid;
					if GUI["Enabled"] then
						if not (bedwars.AppController:isAppOpen('BedwarsItemShopApp') or bedwars.AppController:isAppOpen('BedwarsTeamUpgradeApp')) then
							npc = nil;
						end;
					end;
	
					if npc and lastupgrades ~= upgrades then
						if (npctick - tick()) > 1 then npctick = tick(); end;
						lastupgrades = upgrades;
					end;
	
					if npc and npctick <= tick() and store.matchState ~= 2 and store.shopLoaded then
						local currencytable: table? = {};
						local waitcheck: boolean;
						for _, tab in Callbacks do
							for _, callback in tab do
								if callback(currencytable, shop, upgrades) then
									waitcheck = true;
								end;
							end;
						end;
						npctick = tick() + (waitcheck and 0.4 or math.huge);
					end;
					task.wait(0.1);
				until not AutoBuy["Enabled"];
			else
				npctick = tick();
			end;
		end,
		["Tooltip"] = 'Automatically buys items when you go near the shop'
	})
	Sword = AutoBuy:CreateToggle({
		["Name"] = 'Buy Sword',
		["Function"] = function(callback: boolean): void
			npctick = tick()
			Functions[2] = callback and function(currencytable, shop)
				if not shop then return; end;
				if store.equippedKit == 'dasher' then
					swords = {
						[1] = 'wood_dao',
						[2] = 'stone_dao',
						[3] = 'iron_dao',
						[4] = 'diamond_dao',
						[5] = 'emerald_dao'
					};
				elseif store.equippedKit == 'ice_queen' then
					swords[5] = 'ice_sword';
				elseif store.equippedKit == 'ember' then
					swords[5] = 'infernal_saber';
				elseif store.equippedKit == 'lumen' then
					swords[5] = 'light_sword';
				end;
	
				return buyTool(store.tools.sword, swords, currencytable);
			end or nil
		end;
	})
	Armor = AutoBuy:CreateToggle({
		["Name"] = 'Buy Armor',
		["Function"] = function(callback: boolean): void
			npctick = tick()
			Functions[1] = callback and function(currencytable, shop)
				if not shop then return; end;
				local currentarmor: any = store.inventory.inventory.armor[2] ~= 'empty' and store.inventory.inventory.armor[2] or getBestArmor(1);
				currentarmor = currentarmor and currentarmor.itemType or 'none';
				return buyTool({itemType = currentarmor}, armors, currencytable)
			end or nil
		end,
		["Default"] = true
	})
	AutoBuy:CreateToggle({
		["Name"] = 'Buy Axe',
		["Function"] = function(callback: boolean): void
			npctick = tick()
			Functions[3] = callback and function(currencytable, shop)
				if not shop then return; end;
				return buyTool(store.tools.wood or {itemType = 'none'}, axes, currencytable)
			end or nil
		end;
	})
	AutoBuy:CreateToggle({
		["Name"] = 'Buy Pickaxe',
		["Function"] = function(callback: boolean): void
			npctick = tick()
			Functions[4] = callback and function(currencytable, shop)
				if not shop then return; end;
				return buyTool(store.tools.stone, pickaxes, currencytable)
			end or nil
		end;
	})
	Upgrades = AutoBuy:CreateToggle({
		["Name"] = 'Buy Upgrades',
		["Function"] = function(callback)
			for _, v in UpgradeToggles do
				v.Object.Visible = callback;
			end;
		end,
		["Default"] = true
	})
	local count: number = 0;
	for i, v in bedwars.TeamUpgradeMeta do
		local toggleCount: number = count;
		table.insert(UpgradeToggles, AutoBuy:CreateToggle({
			["Name"] = 'Buy '..(v.name == 'Armor' and 'Protection' or v.name),
			["Function"] = function(callback)
				npctick = tick()
				Functions[5 + toggleCount + (v.name == 'Armor' and 20 or 0)] = callback and function(currencytable, shop, upgrades)
					if not upgrades then return; end;
					if v.disabledInQueue and table.find(v.disabledInQueue, store.queueType) then return end
					return buyUpgrade(i, currencytable)
				end or nil
			end,
			Darker = true,
			Default = (i == 'ARMOR' or i == 'DAMAGE')
		}));
		count += 1;
	end;
	TierCheck = AutoBuy:CreateToggle({["Name"] = 'Tier Check'})
	BedwarsCheck = AutoBuy:CreateToggle({
		["Name"] = 'Only Bedwars',
		["Function"] = function()
			if AutoBuy["Enabled"] then
				AutoBuy:Toggle()
				AutoBuy:Toggle()
			end
		end,
		["Default"] = true
	})
	GUI = AutoBuy:CreateToggle({["Name"] = 'GUI check'})
	SmartCheck = AutoBuy:CreateToggle({
		["Name"] = 'Smart check',
		["Default"] = true,
		["Tooltip"] = 'Buys iron armor before iron axe'
	})
	AutoBuy:CreateTextList({
		["Name"] = 'Item',
		["Placeholder"] = 'priority/item/amount/after',
		["Function"] = function(list)
			table.clear(Custom);
			table.clear(CustomPost);
			for _, entry in list do
				local tab: string? = entry:split('/');
				local ind: number? = tonumber(tab[1]);
				if ind then
					(tab[4] and CustomPost or Custom)[ind] = function(currencytable, shop)
						if not shop then return; end;
						local v: any = bedwars.Shop.getShopItem(tab[2], lplr);
						if v then
							local item: any = getItem(tab[2] == 'wool_white' and bedwars.Shop.getTeamWool(lplr:GetAttribute('Team')) or tab[2]);
							item = (item and tonumber(tab[3]) - item.amount or tonumber(tab[3])) // v.amount;
							if item > 0 and canBuy(v, currencytable, item) then
								for _ = 1, item do
									buyItem(v, currencytable);
								end;
								return true;
							end;
						end;
					end;
				end;
			end;
		end;
	})
end)

velo.run(function()
	local AutoConsume: table = {["Enabled"] = false}
	local Health: table = {}
	local SpeedPotion: table = {["Enabled"] = false}
	local Apple: table = {["Enabled"] = false}
	local ShieldPotion: table = {["Enabled"] = false}
	
	local function consumeCheck(attribute: any): any
		if entitylib.isAlive then
			if SpeedPotion["Enabled"] and (not attribute or attribute == 'StatusEffect_speed') then
				local speedpotion: any = getItem('speed_potion');
				if speedpotion and (not lplr.Character:GetAttribute('StatusEffect_speed')) then
					for _ = 1, 4 do
						if bedwars.Client:Get(remotes.ConsumeItem):CallServer({item = speedpotion.tool}) then break; end;
					end;
				end;
			end;
	
			if Apple["Enabled"] and (not attribute or attribute:find('Health')) then
				if (lplr.Character:GetAttribute('Health') / lplr.Character:GetAttribute('MaxHealth')) <= (Health["Value"]/ 100) then
					local apple: any = getItem('orange') or (not lplr.Character:GetAttribute('StatusEffect_golden_apple') and getItem('golden_apple')) or getItem('apple')
					if apple then
						bedwars.Client:Get(remotes.ConsumeItem):CallServerAsync({
							item = apple.tool
						});
					end;
				end;
			end;
	
			if ShieldPotion["Enabled"] and (not attribute or attribute:find('Shield')) then
				if (lplr.Character:GetAttribute('Shield_POTION') or 0) == 0 then
					local shield: any = getItem('big_shield') or getItem('mini_shield');
					if shield then
						bedwars.Client:Get(remotes.ConsumeItem):CallServerAsync({
							item = shield.tool
						});
					end;
				end;
			end;
		end;
	end;
	
	AutoConsume = vape.Categories.Inventory:CreateModule({
		["Name"] = 'AutoConsume',
		["Function"] = function(callback: boolean): void
			if callback then
				AutoConsume:Clean(vapeEvents.InventoryAmountChanged.Event:Connect(consumeCheck));
				AutoConsume:Clean(vapeEvents.AttributeChanged.Event:Connect(function(attribute)
					if attribute:find('Shield') or attribute:find('Health') or attribute == 'StatusEffect_speed' then
						consumeCheck(attribute);
					end;
				end));
				consumeCheck();
			end;
		end,
		["Tooltip"] = 'Automatically heals for you when health or shield is under threshold.'
	})
	Health = AutoConsume:CreateSlider({
		["Name"] = 'Health Percent',
		["Min"] = 1,
		["Max"] = 99,
		["Default"] = 70,
		["Suffix"] = '%'
	})
	SpeedPotion = AutoConsume:CreateToggle({
		["Name"] = 'Speed Potions',
		["Default"] = false
	})
	Apple = AutoConsume:CreateToggle({
		["Name"] = 'Apple',
		["Default"] = false
	})
	ShieldPotion = AutoConsume:CreateToggle({
		["Name"] = 'Shield Potions',
		["Default"] = false
	})
end)

velo.run(function()
	local Value: table = {}
	local oldclickhold: (...any) -> any
	local oldshowprogress: (...any) -> any
	local FastConsume = vape.Categories.Inventory:CreateModule({
		["Name"] = 'FastConsume',
		["Function"] = function(callback: boolean): void
			if callback then
				oldclickhold = bedwars.ClickHold.startClick;
				oldshowprogress = bedwars.ClickHold.showProgress;
				bedwars.ClickHold.startClick = function(self)
					self.startedClickTime = tick();
					local handle: any = self:showProgress();
					local clicktime: number? = self.startedClickTime;
					bedwars.RuntimeLib.Promise.defer(function()
						task.wait(self.durationSeconds * (Value["Value"]/ 40));
						if handle == self.handle and clicktime == self.startedClickTime and self.closeOnComplete then
							self:hideProgress();
							if self.onComplete then self.onComplete(); end;
							if self.onPartialComplete then self.onPartialComplete(1); end;
							self.startedClickTime = -1;
						end;
					end);
				end;
	
				bedwars.ClickHold.showProgress = function(self)
					local roact: any = debug.getupvalue(oldshowprogress, 1);
					local countdown: any = roact.mount(roact.createElement('ScreenGui', {}, { roact.createElement('Frame', {
						[roact.Ref] = self.wrapperRef,
						Size = UDim2.new(),
						Position = UDim2.fromScale(0.5, 0.55),
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 0.8
					}, { roact.createElement('Frame', {
						[roact.Ref] = self.progressRef,
						Size = UDim2.fromScale(0, 1),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 0.5
					}) }) }), lplr:FindFirstChild('PlayerGui'));
	
					self.handle = countdown;
					local sizetween: any = tweenService:Create(self.wrapperRef:getValue(), TweenInfo.new(0.1), {
						Size = UDim2.fromScale(0.11, 0.005)
					});
					local countdowntween: any = tweenService:Create(self.progressRef:getValue(), TweenInfo.new(self.durationSeconds * (Value["Value"]/ 100), Enum.EasingStyle.Linear), {
						Size = UDim2.fromScale(1, 1)
					});
					sizetween:Play();
					countdowntween:Play();
					table.insert(self.tweens, countdowntween);
					table.insert(self.tweens, sizetween);
					return countdown;
				end;
			else
				bedwars.ClickHold.startClick = oldclickhold;
				bedwars.ClickHold.showProgress = oldshowprogress;
				oldclickhold = nil;
				oldshowprogress = nil;
			end;
		end,
		["Tooltip"] = 'Use/Consume items quicker.'
	})
	Value = FastConsume:CreateSlider({
		["Name"] = 'Multiplier',
		["Min"] = 0,
		["Max"] = 100
	})
end)

velo.run(function()
	local AutoToxic: table = {["Enabled"] = false}
	local GG: table = {["Enabled"] = false}
	local Toggles: table?, Lists: table?, said: table?, dead: table? = {}, {}, {}, {}
	local justsaid: string = ''
	local leavesaid: boolean = false
	local alreadyreported: table = {}
	local AutoToxicRespond: table = {}
	local AutoToxicPhrases4: table = {}
	local AutoToxicPhrases5: table = {}
	local function removerepeat(str: string)
		local newstr: string = ''
		local lastlet: string = ''
		for i: any, v: string? in next, (str:split('')) do 
			if v ~= lastlet then
				newstr = newstr..v ;
				lastlet = v;
			end;
		end;
		return newstr;
	end;

	local reporttable: table = {
		gay = 'Bullying',
		gae = 'Bullying',
		gey = 'Bullying',
		hack = 'Scamming',
		exploit = 'Scamming',
		cheat = 'Scamming',
		hecker = 'Scamming',
		haxker = 'Scamming',
		hacer = 'Scamming',
		report = 'Bullying',
		fat = 'Bullying',
		black = 'Bullying',
		getalife = 'Bullying',
		fatherless = 'Bullying',
		disco = 'Offsite Links',
		yt = 'Offsite Links',
		dizcourde = 'Offsite Links',
		retard = 'Swearing',
		bad = 'Bullying',
		trash = 'Bullying',
		nolife = 'Bullying',
		loser = 'Bullying',
		killyour = 'Bullying',
		kys = 'Bullying',
		hacktowin = 'Bullying',
		bozo = 'Bullying',
		kid = 'Bullying',
		adopted = 'Bullying',
		linlife = 'Bullying',
		commitnotalive = 'Bullying',
		vape = 'Offsite Links',
		futureclient = 'Offsite Links',
		download = 'Offsite Links',
		youtube = 'Offsite Links',
		die = 'Bullying',
		lobby = 'Bullying',
		ban = 'Bullying',
		wizard = 'Bullying',
		wisard = 'Bullying',
		witch = 'Bullying',
		magic = 'Bullying',
	}
	local reporttableexact: table = {
		L = 'Bullying',
	};

	local function findreport(msg: string?)
		local checkstr: string? = removerepeat(msg:gsub('%W+', ''):lower());
		for i: any, v: string? in next, (reporttable) do 
			if checkstr:find(i) then 
				return v, i;
			end;
		end;
		for i: any, v: string? in next, (reporttableexact) do 
			if checkstr == i then 
				return v, i;
			end;
		end;
		for i: any, v: string? in next, (AutoToxicPhrases5["ListEnabled"]) do 
			if checkstr:find(v) then 
				return 'Bullying', v;
			end;
		end;
		return nil;
	end;

	local function sendMessage(name: string, obj: any, default: string?)
		local tab: {string}? = Lists[name].ListEnabled
		local custommsg: string? = #tab > 0 and tab[math.random(1, #tab)] or default;
		if not custommsg then return; end;
		if #tab > 1 and custommsg == said[name] then
			repeat 
				task.wait(); 
				custommsg = tab[math.random(1, #tab)]; 
			until custommsg ~= said[name];
		end;
		said[name] = custommsg;
	
		custommsg = custommsg and custommsg:gsub('<obj>', obj or '') or '';
		if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg);
		else
			replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(custommsg, 'All');
		end;
	end;

	AutoToxic = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoToxic',
		["Function"] = function(callback: boolean): void
			if callback then
				AutoToxic:Clean(vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if Toggles.BedDestroyed["Enabled"] and bedTable.brokenBedTeam.id == lplr:GetAttribute('Team') then
						sendMessage('BedDestroyed', (bedTable.player.DisplayName or bedTable.player["Name"]), 'how dare you >:( | <obj>');
					elseif Toggles.Bed["Enabled"] and bedTable.player.UserId == lplr.UserId then
						local team: any = bedwars.QueueMeta[store.queueType].teams[tonumber(bedTable.brokenBedTeam.id)];
						sendMessage('Bed', team and team.displayName:lower() or 'white', 'nice bed lul | <obj>');
					end;
				end));
				AutoToxic:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer: any = playersService:GetPlayerFromCharacter(deathTable.fromEntity);
						local killed: any = playersService:GetPlayerFromCharacter(deathTable.entityInstance);
						if not killed or not killer then return; end;
						if killed == lplr then
							if (not dead) and killer ~= lplr and Toggles.Death["Enabled"] then
								dead = true;
								sendMessage('Death', (killer.DisplayName or killer["Name"]), 'my gaming chair subscription expired :( | <obj>');
							end;
						elseif killer == lplr and Toggles.Kill["Enabled"] then
							sendMessage('Kill', (killed.DisplayName or killed["Name"]), 'vxp on top | <obj>');
						end;
					end;
				end));
				AutoToxic:Clean(vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					if GG["Enabled"] then
						if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync('gg');
						else
							replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('gg', 'All');
						end;
					end

					local myTeam: any = bedwars.Store:getState().Game.myTeam;
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if Toggles.Win["Enabled"] then 
							sendMessage('Win', nil, 'yall garbage');
						end;
					end;
				end));
				table.insert(AutoToxic.Connections, vapeStore.MessageReceived.Event:Connect(function(plr: Player, text: string?)
					if AutoToxicRespond["Enabled"] then
						if plr and plr ~= lplr and not alreadyreported[plr] then
							local reportreason: string?, reportedmatch: string? = findreport(text);
							if reportreason then 
								alreadyreported[plr] = true;
								local custommsg: string? = #AutoToxicPhrases4["ListEnabled"] > 0 and AutoToxicPhrases4["ListEnabled"][math.random(1, #AutoToxicPhrases4["ListEnabled"])];
								if custommsg then
									custommsg = custommsg:gsub('<obj>', (plr.DisplayName or plr.Name));
								end;
								local msg: string? = custommsg or ('What are you yapping about <obj>? | Velocity'):gsub('<obj>', plr.DisplayName);
								sendMessage('Respond', (plr.DisplayName or plr.Name), msg);
							end;
						end;
					end;
				end));
			end;
		end,
		["Tooltip"] = 'Says a message after a certain action'
	})
	GG = AutoToxic:CreateToggle({
		["Name"] = 'AutoGG',
		["Default"] = true;
	});
	for _, v in {'Kill', 'Death', 'Bed', 'BedDestroyed', 'Win'} do
		Toggles[v] = AutoToxic:CreateToggle({
			["Name"] = v..' ',
			["Function"] = function(callback: boolean): void
				if Lists[v] then
					Lists[v].Object.Visible = callback;
				end;
			end;
		})
		Lists[v] = AutoToxic:CreateTextList({
			["Name"] = v,
			["Darker"] = true,
			["Visible"] = false
		});
	end;
	AutoToxicRespond = AutoToxic:CreateToggle({
		["Name"] = 'Respond',
		["Function"] = function() end, 
		["Default"] = true
	})
	AutoToxicPhrases4 = AutoToxic:CreateTextList({
		["Name"] = 'Responses',
		["TempText"] = 'response (use <name> for player)',
	})
	AutoToxicPhrases5 = AutoToxic:CreateTextList({
		["Name"] = 'Triggers',
		["TempText"] = 'phrase (text to respond to)',
	})
end)
	
velo.run(function()
	local FastDrop: table = {["Enabled"] = false}
	FastDrop = vape.Categories.Inventory:CreateModule({
		["Name"] = 'FastDrop',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					if entitylib.isAlive and (not store.inventory.opened) and (inputService:IsKeyDown(Enum.KeyCode.H) or inputService:IsKeyDown(Enum.KeyCode.Backspace)) and inputService:GetFocusedTextBox() == nil then
						task.spawn(bedwars.ItemDropController.dropItemInHand);
						task.wait();
					else
						task.wait(0.1);
					end;
				until not FastDrop["Enabled"];
			end;
		end,
		["Tooltip"] = 'Drops items fast when you hold Q'
	})
end)

velo.run(function()
	local BedPlates: table = {["Enabled"] = false}
	local Background: table = {["Enabled"] = false}
	local Color: table = {}
	local Reference: table = {}
	local Folder: Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	
	local function scanSide(self: Instance, start: Vector3?, tab: { string } )
		for _, side: Vector3? in sides do
			for i = 1, 15 do
				local block: Instance? = getPlacedBlock(start + (side * i));
				if not block or block == self then break; end;
				if not block:GetAttribute('NoBreak') and not table.find(tab, block.Name) then
					table.insert(tab, block.Name);
				end;
			end;
		end;
	end;
	
	local function refreshAdornee(v: { Adornee: Instance, Frame: Instance, Enabled: boolean }): nil
		for _, obj in v.Frame:GetChildren() do
			if obj:IsA('ImageLabel') and obj.Name ~= 'Blur' then
				obj:Destroy();
			end;
		end;
	
		local start: any = v.Adornee.Position;
		local alreadygot: table = {}
		scanSide(v.Adornee, start, alreadygot);
		scanSide(v.Adornee, start + Vector3.new(0, 0, 3), alreadygot);
		table.sort(alreadygot, function(a, b)
			return (bedwars.ItemMeta[a].block and bedwars.ItemMeta[a].block.health or 0) > (bedwars.ItemMeta[b].block and bedwars.ItemMeta[b].block.health or 0);
		end);
		v.Enabled = #alreadygot > 0;
	
		for _, block in alreadygot do
			local blockimage: ImageLabel = Instance.new('ImageLabel')
			blockimage.Size = UDim2.fromOffset(32, 32);
			blockimage.BackgroundTransparency = 1;
			blockimage.Image = bedwars.getIcon({itemType = block}, true);
			blockimage.Parent = v.Frame;
		end;
	end;
	
	local function Added(v: any): any
		local billboard: BillboardGUI = Instance.new('BillboardGui');
		billboard.Parent = Folder;
		billboard.Name = 'bed';
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0);
		billboard.Size = UDim2.fromOffset(36, 36);
		billboard.AlwaysOnTop = true;
		billboard.ClipsDescendants = false;
		billboard.Adornee = v;
		local blur: any = addBlur(billboard);
		blur.Visible = Background["Enabled"];
		local frame: Frame = Instance.new('Frame');
		frame.Size = UDim2.fromScale(1, 1);
		frame.BackgroundColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value);
		frame.BackgroundTransparency = 1 - (Background["Enabled"] and Color.Opacity or 0);
		frame.Parent = billboard;
		local layout: UIListLayout = Instance.new('UIListLayout');
		layout.FillDirection = Enum.FillDirection.Horizontal;
		layout.Padding = UDim.new(0, 4);
		layout.VerticalAlignment = Enum.VerticalAlignment.Center;
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			billboard.Size = UDim2.fromOffset(math.max(layout.AbsoluteContentSize.X + 4, 36), 36);
		end);
		layout.Parent = frame;
		local corner: UICorner = Instance.new('UICorner');
		corner.CornerRadius = UDim.new(0, 4);
		corner.Parent = frame;
		Reference[v] = billboard;
		refreshAdornee(billboard);
	end;
	
	local function refreshNear(data: any): any?
		data = data.blockRef.blockPosition * 3;
		for i, v in Reference do
			if (data - i.Position).Magnitude <= 30 then
				refreshAdornee(v);
			end;
		end;
	end;
	
	BedPlates = vape.Categories.Minigames:CreateModule({
		["Name"] = 'BedPlates',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v in collectionService:GetTagged('bed') do 
					task.spawn(Added, v); 
				end;
				BedPlates:Clean(vapeEvents.PlaceBlockEvent.Event:Connect(refreshNear));
				BedPlates:Clean(vapeEvents.BreakBlockEvent.Event:Connect(refreshNear));
				BedPlates:Clean(collectionService:GetInstanceAddedSignal('bed'):Connect(Added));
				BedPlates:Clean(collectionService:GetInstanceRemovedSignal('bed'):Connect(function(v)
					if Reference[v] then
						Reference[v]:Destroy();
						Reference[v]:ClearAllChildren();
						Reference[v] = nil;
					end;
				end));
			else
				table.clear(Reference);
				Folder:ClearAllChildren();
			end;
		end,
		["Tooltip"] = 'Displays blocks over the bed'
	})
	Background = BedPlates:CreateToggle({
		["Name"] = 'Background',
		["Function"] = function(callback: boolean): void
			if Color.Object then 
				Color.Object.Visible = callback ;
			end;
			for _, v in Reference do
				v.Frame.BackgroundTransparency = 1 - (callback and Color.Opacity or 0);
				v.Blur.Visible = callback;
			end;
		end,
		["Default"] = true
	})
	Color = BedPlates:CreateColorSlider({
		["Name"] = 'Background Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			for _, v in Reference do
				v.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
				v.Frame.BackgroundTransparency = 1 - opacity;
			end;
		end,
		["Darker"] = true
	})
end)

velo.run(function()
	local Breaker: table = {["Enabled"] = false}
	local Range: table = {["Value"] = 40}
	local UpdateRate: table = {["Value"] = 540}
	local Custom: table = {};
	local Bed: table = {["Enabled"] = false}
	local LuckyBlock: table = {["Enabled"] = false}
	local IronOre: table = {["Enabled"] = false}
	local Effect: table = {["Enabled"] = false}
	local CustomHealth: table = {}
	local Animation: table = {["Enabled"] = false}
	local SelfBreak: table = {["Enabled"] = false}
	local InstantBreak: table = {["Enabled"] = false}
	local LimitItem: table = {["Enabled"] = false}
	local customlist: any, parts: any = {}, {}
	
	local function customHealthbar(
		self: { 
			healthbarPart: Part?,
			healthbarBlockRef: { blockPosition: Vector3 }?,
			healthbarMaid: Maid,
			healthbarProgressRef: Roact.Ref
		},
		blockRef: { blockPosition: Vector3 },
		health: number,
		maxHealth: number,
		changeHealth: number?,
		block: Instance
	)
		if block:GetAttribute('NoHealthbar') then return end
		if not self.healthbarPart or not self.healthbarBlockRef or self.healthbarBlockRef.blockPosition ~= blockRef.blockPosition then
			self.healthbarMaid:DoCleaning();
			self.healthbarBlockRef = blockRef;
			local create: any = bedwars.Roact.createElement;
			local percent: number = math.clamp(health / maxHealth, 0, 1);
			local cleanCheck: boolean = true;
			local part: Part = Instance.new('Part');
			part.Size = Vector3.one;
			part.CFrame = CFrame.new(bedwars.BlockController:getWorldPosition(blockRef.blockPosition));
			part.Transparency = 1;
			part.Anchored = true;
			part.CanCollide = false;
			part.Parent = workspace;
			self.healthbarPart = part;
			bedwars.QueryUtil:setQueryIgnored(self.healthbarPart, true);
	
			local mounted: any = bedwars.Roact.mount(create('BillboardGui', {
				Size = UDim2.fromOffset(249, 102),
				StudsOffset = Vector3.new(0, 2.5, 0),
				Adornee = part,
				MaxDistance = 40,
				AlwaysOnTop = true
			}, {
				create('Frame', {
					Size = UDim2.fromOffset(160, 50),
					Position = UDim2.fromOffset(44, 32),
					BackgroundColor3 = Color3.new(),
					BackgroundTransparency = 0.5
				}, {
					create('UICorner', {CornerRadius = UDim.new(0, 5)}),
					create('ImageLabel', {
						Size = UDim2.new(1, 89, 1, 52),
						Position = UDim2.fromOffset(-48, -31),
						BackgroundTransparency = 1,
						Image = getcustomasset('newvape/assets/new/blur.png'),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(52, 31, 261, 502)
					}),
					create('TextLabel', {
						Size = UDim2.fromOffset(145, 14),
						Position = UDim2.fromOffset(13, 12),
						BackgroundTransparency = 1,
						Text = bedwars.ItemMeta[block.Name].displayName or block.Name,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextColor3 = Color3.new(),
						TextScaled = true,
						Font = Enum.Font.Arial
					}),
					create('TextLabel', {
						Size = UDim2.fromOffset(145, 14),
						Position = UDim2.fromOffset(12, 11),
						BackgroundTransparency = 1,
						Text = bedwars.ItemMeta[block.Name].displayName or block.Name,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextColor3 = color.Dark(uipallet.Text, 0.16),
						TextScaled = true,
						Font = Enum.Font.Arial
					}),
					create('Frame', {
						Size = UDim2.fromOffset(138, 4),
						Position = UDim2.fromOffset(12, 32),
						BackgroundColor3 = uipallet.Main
					}, {
						create('UICorner', {CornerRadius = UDim.new(1, 0)}),
						create('Frame', {
							[bedwars.Roact.Ref] = self.healthbarProgressRef,
							Size = UDim2.fromScale(percent, 1),
							BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
						}, {create('UICorner', {CornerRadius = UDim.new(1, 0)})})
					})
				})
			}), part);
	
			self.healthbarMaid:GiveTask(function()
				cleanCheck = false;
				self.healthbarBlockRef = nil;
				bedwars.Roact.unmount(mounted);
				if self.healthbarPart then
					self.healthbarPart:Destroy();
				end;
				self.healthbarPart = nil;
			end);
	
			bedwars.RuntimeLib.Promise.delay(5):andThen(function()
				if cleanCheck then
					self.healthbarMaid:DoCleaning();
				end;
			end);
		end;
	
		local newpercent: number = math.clamp((health - changeHealth) / maxHealth, 0, 1);
		tweenService:Create(self.healthbarProgressRef:getValue(), TweenInfo.new(0.3), {
			Size = UDim2.fromScale(newpercent, 1), BackgroundColor3 = Color3.fromHSV(math.clamp(newpercent / 2.5, 0, 1), 0.89, 0.75)
		}):Play();
	end;
	
	local hit: number = 0;
	
	local function attemptBreak(tab: any, localPosition: Vector3?): boolean?
		if not tab then return; end;
		for _, v in tab do
			if (v.Position - localPosition).Magnitude < Range["Value"]and bedwars.BlockController:isBlockBreakable({blockPosition = v.Position / 3}, lplr) then
				if not SelfBreak["Enabled"] and v:GetAttribute('PlacedByUserId') == lplr.UserId then continue; end;
				if (v:GetAttribute('BedShieldEndTime') or 0) > workspace:GetServerTimeNow() then continue; end;
				if LimitItem["Enabled"] and not (store.hand.tool and bedwars.ItemMeta[store.hand.tool.Name].breakBlock) then continue; end;
				hit += 1
				local target: Vector3?, path: { [Vector3]: Vector3 }?, endpos: Vector3? = bedwars.breakBlock(v, Effect["Enabled"], Animation["Enabled"], CustomHealth["Enabled"] and customHealthbar or nil, InstantBreak["Enabled"])
				if path then
					local currentnode: Vector3? = target;
					for _, part: Instance? in parts do
						part.Position = currentnode or Vector3.zero;
						if currentnode then
							part.BoxHandleAdornment.Color3 = currentnode == endpos and Color3.new(1, 0.2, 0.2) or currentnode == target and Color3.new(0.2, 0.2, 1) or Color3.new(0.2, 1, 0.2);
						end;
						currentnode = path[currentnode];
					end;
				end;
				task.wait(InstantBreak["Enabled"] and (store.damageBlockFail > tick() and 4.5 or 0) or 0.25);
				return true;
			end;
		end;
		return false;
	end;
	
	Breaker = vape.Categories.Minigames:CreateModule({
		["Name"] = 'Breaker',
		["Function"] = function(callback: boolean): void
			if callback then
				for _ = 1, 30 do
					local part: Part = Instance.new('Part');
					part.Anchored = true;
					part.CanQuery = false;
					part.CanCollide = false;
					part.Transparency = 1;
					part.Parent = gameCamera;
					local highlight: BoxHandleAdornment = Instance.new('BoxHandleAdornment');
					highlight.Size = Vector3.one;
					highlight.AlwaysOnTop = true;
					highlight.ZIndex = 1;
					highlight.Transparency = 0.5;
					highlight.Adornee = part;
					highlight.Parent = part;
					table.insert(parts, part);
				end;
	
				local beds: {Instance} = collection('bed', Breaker);
				local luckyblock: {Instance} = collection('LuckyBlock', Breaker);
				local ironores: {Instance} = collection('iron-ore', Breaker);
				customlist = collection('block', Breaker, function(tab: {Instance}, obj: Instance)
					if table.find(Custom.ListEnabled, obj.Name) then
						table.insert(tab, obj);
					end;
				end);
	
				repeat
					task.wait(1 / UpdateRate["Value"]);
					if not Breaker["Enabled"] then break; end;
					if entitylib.isAlive then
						local localPosition: Vector3 = entitylib.character.RootPart.Position;
	
						if attemptBreak(Bed["Enabled"] and beds, localPosition) then continue; end;
						if attemptBreak(customlist, localPosition) then continue; end;
						if attemptBreak(LuckyBlock["Enabled"] and luckyblock, localPosition) then continue; end;
						if attemptBreak(IronOre["Enabled"] and ironores, localPosition) then continue; end;
	
						for _, v in parts do
							v.Position = Vector3.zero;
						end;
					end;
				until not Breaker["Enabled"];
			else
				for _, v in parts do
					v:ClearAllChildren();
					v:Destroy();
				end;
				table.clear(parts);
			end;
		end,
		["Tooltip"] = 'Break blocks around you automatically'
	})
	Range = Breaker:CreateSlider({
		["Name"] = 'Break range',
		["Min"] = 1,
		["Max"] = 40,
		["Default"] = 40,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs';
		end;
	})
	UpdateRate = Breaker:CreateSlider({
		["Name"] = 'Update rate',
		["Min"] = 1,
		["Max"] = 540,
		["Default"] = 60,
		["Suffix"] = 'hz'
	})
	Custom = Breaker:CreateTextList({
		["Name"] = 'Custom',
		["Function"] = function()
			if not customlist then return; end;
			table.clear(customlist);
			for _, obj in store.blocks do
				if table.find(Custom.ListEnabled, obj["Name"]) then
					table.insert(customlist, obj);
				end;
			end;
		end;
	})
	Bed = Breaker:CreateToggle({
		["Name"] = 'Break Bed',
		["Default"] = true
	})
	LuckyBlock = Breaker:CreateToggle({
		["Name"] = 'Break Lucky Block',
		["Default"] = true
	})
	IronOre = Breaker:CreateToggle({
		["Name"] = 'Break Iron Ore',
		["Default"] = true
	})
	Effect = Breaker:CreateToggle({
		["Name"] = 'Show Healthbar & Effects',
		["Function"] = function(callback)
			if CustomHealth.Object then
				CustomHealth.Object.Visible = callback;
			end;
		end,
		["Default"] = true
	})
	CustomHealth = Breaker:CreateToggle({
		["Name"] = 'Custom Healthbar',
		["Default"] = true,
		["Darker"] = true
	})
	Animation = Breaker:CreateToggle({Name = 'Animation'})
	SelfBreak = Breaker:CreateToggle({Name = 'Self Break'})
	InstantBreak = Breaker:CreateToggle({Name = 'Instant Break'})
	LimitItem = Breaker:CreateToggle({
		["Name"] = 'Limit to items',
		["Tooltip"] = 'Only breaks when tools are held'
	})
end)

 -- done
velo.run(function()
	vape.Legit:CreateModule({
		["Name"] = 'Clean Kit',
		["Function"] = function(callback: boolean): void
			if callback then
				bedwars.WindWalkerController.spawnOrb = function() end;
				local zephyreffect: any = lplr.PlayerGui:FindFirstChild('WindWalkerEffect', true);
				if zephyreffect then 
					zephyreffect.Visible = false; 
				end;
			end;
		end,
		["Tooltip"] = 'Removes zephyr status indicator'
	})
end)

velo.run(function()
	local FOV: table = {["Enabled"] = false};
	local Value: table = {["Value"] = 120};
	local old: any, old2: any;
	FOV = vape.Legit:CreateModule({
		["Name"] = 'FOV',
		["Function"] = function(callback: boolean): void
			if callback then
				old = bedwars.FovController.setFOV;
				old2 = bedwars.FovController.getFOV;
				bedwars.FovController.setFOV = function(self) 
					return old(self, Value.Value);
				end;
				bedwars.FovController.getFOV = function() 
					return Value["Value"];
				end;
			else
				bedwars.FovController.setFOV = old;
				bedwars.FovController.getFOV = old2;
			end;
			
			bedwars.FovController:setFOV(bedwars.Store:getState().Settings.fov);
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
	local KillEffect: table = {["Enabled"] = false}
	local Mode: table = {};
	local List: table = {};
	
	local killeffects: table = {
		Gravity = function(_, _, char: Model, _)
			char:BreakJoints()
			local highlight: Instance = char:FindFirstChildWhichIsA('Highlight');
			local nametag: Instance = char:FindFirstChild('Nametag', true);
			if highlight then 
				highlight:Destroy(); 
			end;
			if nametag then 
				nametag:Destroy(); 
			end;
	
			task.spawn(function()
				local partvelo: table = {}
				for _, v: Instance in char:GetDescendants() do
					if v:IsA('BasePart') then
						partvelo[v.Name] = v.Velocity;
					end;
				end;
				char.Archivable = true;
				local clone: Model = char:Clone();
				clone.Humanoid.Health = 100;
				clone.Parent = workspace;
				game:GetService('Debris'):AddItem(clone, 30);
				char:Destroy();
				task.wait(0.01);
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead);
				clone:BreakJoints();
				task.wait(0.01);
				for _, v: Instance in clone:GetDescendants() do
					if v:IsA('BasePart') then
						local bodyforce: BodyForce = Instance.new('BodyForce');
						bodyforce.Force = Vector3.new(0, (workspace.Gravity - 10) * v:GetMass(), 0);
						bodyforce.Parent = v;
						v.CanCollide = true;
						v.Velocity = partvelo[v.Name] or Vector3.zero;
					end;
				end;
			end)
		end,
		Lightning = function(_, _, char: Model, _)
			char:BreakJoints()
			local highlight: Instance? = char:FindFirstChildWhichIsA('Highlight');
			if highlight then 
				highlight:Destroy();
			end;
			local startpos: number = 1125
			local startcf: Vector3 = char.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0);
			local newpos: Vector3 = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2);
	
			for i = startpos - 75, 0, -75 do
				local newpos2: Vector3 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2);
				if i == 0 then
					newpos2 = Vector3.zero;
				end;
				local part: Part = Instance.new('Part');
				part.Size = Vector3.new(1.5, 1.5, 77);
				part.Material = Enum.Material.SmoothPlastic;
				part.Anchored = true;
				part.Material = Enum.Material.Neon;
				part.CanCollide = false;
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2);
				part.Parent = workspace;
				local part2 = part:Clone();
				part2.Size = Vector3.new(3, 3, 78);
				part2.Color = Color3.new(0.7, 0.7, 0.7);
				part2.Transparency = 0.7;
				part2.Material = Enum.Material.SmoothPlastic;
				part2.Parent = workspace;
				game:GetService('Debris'):AddItem(part, 0.5);
				game:GetService('Debris'):AddItem(part2, 0.5);
				bedwars.QueryUtil:setQueryIgnored(part, true);
				bedwars.QueryUtil:setQueryIgnored(part2, true);
				if i == 0 then
					local soundpart: Part = Instance.new('Part');
					soundpart.Transparency = 1;
					soundpart.Anchored = true;
					soundpart.Size = Vector3.zero;
					soundpart.Position = startcf;
					soundpart.Parent = workspace;
					bedwars.QueryUtil:setQueryIgnored(soundpart, true);
					local sound: Sound = Instance.new('Sound');
					sound.SoundId = 'rbxassetid://6993372814';
					sound.Volume = 2;
					sound.Pitch = 0.5 + (math.random(1, 3) / 10);
					sound.Parent = soundpart;
					sound:Play();
					sound.Ended:Connect(function() 
						soundpart:Destroy(); 
					end);
				end;
				newpos = newpos2;
			end;
		end,
		Delete = function(_, _, char: Model, _) 
			char:Destroy(); 
		end;
	};
	
	KillEffect = vape.Legit:CreateModule({
		["Name"] = 'Kill Effect',
		["Function"] = function(callback: boolean): void
			if callback then
				for i, v in killeffects do
					bedwars.KillEffectController.killEffects['Custom'..i] = {
						new = function() 
							return {
								onKill = v, 
								isPlayDefaultKillEffect = function() 
									return false; 
								end;
							} 
						end;
					}
				end;
				KillEffect:Clean(lplr:GetAttributeChangedSignal('KillEffectType'):Connect(function()
					lplr:SetAttribute('KillEffectType', Mode["Value"]== 'Bedwars' and List["Value"]or 'Custom'..Mode["Value"]);
				end));
				lplr:SetAttribute('KillEffectType', Mode["Value"]== 'Bedwars' and List["Value"]or 'Custom'..Mode["Value"]);
			else
				for i in killeffects do 
					bedwars.KillEffectController.killEffects['Custom'..i] = nil;
				end;
				lplr:SetAttribute('KillEffectType', 'default');
			end;
		end,
		["Tooltip"] = 'Custom final kill effects'
	})
	local modes: any = {'Bedwars'}
	for i in killeffects do 
		table.insert(modes, i); 
	end;
	Mode = KillEffect:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = modes,
		["Function"] = function(val)
			List.Object.Visible = val == 'Bedwars';
			if KillEffect["Enabled"] then
				lplr:SetAttribute('KillEffectType', val == 'Bedwars' and List["Value"]or 'Custom'..val);
			end;
		end;
	})
	local KillEffectName: {string} = {}
	for i: number, v: {name: string} in bedwars.KillEffectMeta do
		table.insert(KillEffectName, v.name);
		KillEffectName[v.name] = i;
	end;
	table.sort(KillEffectName);
	List = KillEffect:CreateDropdown({
		["Name"] = 'Bedwars',
		["List"] = KillEffectName,
		["Function"] = function(val)
			if KillEffect["Enabled"] then
				lplr:SetAttribute('KillEffectType', val);
			end;
		end,
		["Darker"] = true;
	})
end)

velo.run(function()
	local SoundChanger: table = {["Enabled"] = false}
	local List: table = {["Enabled"] = false}
	local soundlist: table = {}
	local old: (self: any, id: string, ...any) -> any = nil
	SoundChanger = vape.Legit:CreateModule({
		["Name"] = 'SoundChanger',
		["Function"] = function(callback: boolean): void
			if callback then 
				old = bedwars.SoundManager.playSound;
				bedwars.SoundManager.playSound = function(self, id, ...)
					if soundlist[id] then 
						id = soundlist[id];
					end;
					return old(self, id, ...);
				end;
			else
				bedwars.SoundManager.playSound = old;
				old = nil;
			end;
		end,
		Tooltip = 'Change ingame sounds to custom ones.'
	})
	List = SoundChanger:CreateTextList({
		["Name"] = 'Sounds',
		["Placeholder"] = '(DAMAGE_1/ben.mp3)',
		["Function"] = function()
			table.clear(soundlist)
			for _, entry in List.ListEnabled do
				local split: {string} = entry:split('/');
				local id: string? = bedwars.SoundList[split[1]];
				if id and #split > 1 then
					soundlist[id] = split[2]:find('rbxasset') and split[2] or assetfunction(split[2]); 
				end;
			end;
		end;
	})
end)

velo.run(function()
	local FPSBoost: table = {["Enabled"] = false}
	local Kill: table = {["Enabled"] = false}
	local Visualizer: table = {["Enabled"] = false}
	local effects: table, util: table = {}, {}
	FPSBoost = vape.Legit:CreateModule({
		["Name"] = 'FPS Boost',
		["Function"] = function(callback: boolean): void
			if callback then
				if Kill["Enabled"] then
					for i: any, v: any in bedwars.KillEffectController.killEffects do
						if not i:find('Custom') then
							effects[i] = v
							bedwars.KillEffectController.killEffects[i] = {
								new = function() 
									return {
										onKill = function() end, 
										isPlayDefaultKillEffect = function() 
											return true; 
										end;
									} 
								end;
							}
						end;
					end;
				end;
	
				if Visualizer["Enabled"] then
					for i, v in bedwars.VisualizerUtils do
						util[i] = v;
						bedwars.VisualizerUtils[i] = function() end;
					end;
				end;
	
				repeat task.wait() until store.matchState ~= 0
				if not bedwars.AppController then return; end;
				bedwars.NametagController.addGameNametag = function() end;
				for _, v in bedwars.AppController:getOpenApps() do
					if tostring(v):find('Nametag') then
						bedwars.AppController:closeApp(tostring(v));
					end;
				end;
			else
				for i, v in effects do 
					bedwars.KillEffectController.killEffects[i] = v; 
				end;
				for i, v in util do 
					bedwars.VisualizerUtils[i] = v; 
				end;
				table.clear(effects);
				table.clear(util);
			end;
		end,
		["Tooltip"] = 'Improves the framerate by turning off certain effects'
	})
	Kill = FPSBoost:CreateToggle({
		["Name"] = 'Kill Effects',
		["Function"] = function()
			if FPSBoost["Enabled"] then
				FPSBoost:Toggle();
				FPSBoost:Toggle();
			end;
		end,
		["Default"] = true
	})
	Visualizer = FPSBoost:CreateToggle({
		["Name"] = 'Visualizer',
		["Function"] = function()
			if FPSBoost["Enabled"] then
				FPSBoost:Toggle();
				FPSBoost:Toggle();
			end;
		end,
		["Default"] = true
	})
end)

velo.run(function()
	local old: any;
	local Image: any;
	local Crosshair = vape.Legit:CreateModule({
		["Name"] = 'Crosshair',
		["Function"] = function(callback: boolean): void
			if callback then 
				old = debug.getconstant(bedwars.ViewmodelController.show, 25);
				debug.setconstant(bedwars.ViewmodelController.show, 25, Image["Value"]);
				debug.setconstant(bedwars.ViewmodelController.show, 37, Image["Value"]);
			else
				debug.setconstant(bedwars.ViewmodelController.show, 25, old);
				debug.setconstant(bedwars.ViewmodelController.show, 37, old);
				old = nil;
			end;
			if bedwars.CameraPerspectiveController:getCameraPerspective() == 0 then
				bedwars.ViewmodelController:hide();
				bedwars.ViewmodelController:show();
			end;
		end,
		["Tooltip"] = 'Custom first person crosshair depending on the image choosen.'
	})
	Image = Crosshair:CreateTextBox({
		["Name"] = 'Image',
		["Placeholder"] = 'image id (roblox)',
		["Function"] = function(enter)
			if enter and Crosshair["Enabled"] then 
				Crosshair:Toggle()
				Crosshair:Toggle()
			end
		end
	})
end)

velo.run(function()
	local DamageIndicator: table = {};
	local colorTog: table = {}; 
	local color: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 0};
	local textTog: table = {}; 
	local text: table = {}; 
	local fontTog: table = {};
	local font: table = {["Value"] = "GothamBlack"}; 
	local mode: table = {["Value"] = "Rainbow"};
	local mode2: table = {["Value"] = "Gradient"}; 
	local mode1: table = {["Value"] = "Custom"};
	local messages: table = {
		"Pow!", "Pop!", "Hit!", "Smack!", "Bang!",
		"Boom!", "Whoop!", "Damage!", "-9e9!", "Whack!",
		"Crash!", "Slam!", "Zap!", "Snap!", "Thump!"
	};
	local colors: table = {
		Color3.fromRGB(255,0,0),Color3.fromRGB(255,127,0),Color3.fromRGB(255,255,0),
		Color3.fromRGB(0,255,0),Color3.fromRGB(0,0,255),Color3.fromRGB(75,0,130),Color3.fromRGB(148,0,211)
	};
	local i: number = 1; local mz: number = 5;
	local rand: (t: table?) -> string = function(t)
		if typeof(t) ~= "table" or #t == 0 then
			return "";
		end
		local result = t[math.random(1, #t)]
		return result;
	end;
	DamageIndicator = vape.Legit:CreateModule({
		["Name"] = "DamageIndicator", ["HoverText"] = "Customizes the damage indicators.",
		["Function"] = function(callback: boolean): void
			if not callback then return; end;
			task.spawn(function()
				table.insert(DamageIndicator["Connections"], workspace.DescendantAdded:Connect(function(v)
					if v.Name ~= "DamageIndicatorPart" then return end;
					local lbl: TextLabel? = v:FindFirstChildWhichIsA("BillboardGui"):FindFirstChildWhichIsA("Frame"):FindFirstChildWhichIsA("TextLabel");
					if not lbl then return; end;

					if colorTog["Enabled"] then
						if mode["Value"] == "Rainbow" then
							if mode2["Value"] == "Gradient" then
								lbl["TextColor3"] = Color3.fromHSV(tick() % mz / mz, 1, 1);
							else
								runService.Stepped:Connect(function()
									i = (i % #colors) + 1;
									lbl["TextColor3"] = colors[i];
								end);
							end;
						elseif mode["Value"] == "Custom" then
							lbl["TextColor3"] = Color3.fromHSV(color["Hue"], color["Sat"], color["Value"]);
						else
							lbl["TextColor3"] = Color3.fromRGB(127, 0, 255);
						end;
					end;

					if textTog["Enabled"] then
						lbl["Text"] = mode1["Value"] == "Custom" and rand(text["ListEnabled"])
							or mode1["Value"] == "Multiple" and rand(messages)
							or text["Value"] or "Velocity on top!";
					end;
					lbl["Font"] = fontTog["Enabled"] and Enum.Font[font["Value"]] or lbl["Font"];
				end));
			end);
		end;
	});
	mode = DamageIndicator:CreateDropdown({
		["Name"] = "Color Mode", ["List"] = {"Rainbow","Custom","Velocity"},
		["HoverText"] = "Mode to color the damage indicator.", ["Value"] = "Rainbow", ["Function"] = function() end
	});
	mode2 = DamageIndicator:CreateDropdown({
		["Name"] = "Rainbow Mode", ["List"] = {"Gradient","Paint"},
		["HoverText"] = "Gradient or solid rainbow.", ["Value"] = "Gradient", ["Function"] = function() end
	});
	mode1 = DamageIndicator:CreateDropdown({
		["Name"] = "Text Mode", ["List"] = {"Custom","Multiple","Velocity"},
		["HoverText"] = "Text customization mode.", ["Value"] = "Custom", ["Function"] = function() end
	});
	local fonts: table = {"GothamBlack"};
	for _, f: EnumItem in Enum.Font:GetEnumItems() do
		if f.Name ~= "GothamBlack" then table.insert(fonts, f.Name); end;
	end;
	font = DamageIndicator:CreateDropdown({
		["Name"] = "Font", ["HoverText"] = "Font of text indicator.",
		["List"] = fonts, ["Function"] = function() end
	});
	colorTog = DamageIndicator:CreateToggle({
		["Name"] = "Custom Color", ["HoverText"] = "Enable custom color.", ["Function"] = function() end
	});
	color = DamageIndicator:CreateColorSlider({
		["Name"] = "Text Color", ["HoverText"] = "HSV selector.", ["Function"] = function() end
	});
	textTog = DamageIndicator:CreateToggle({
		["Name"] = "Custom Text", ["HoverText"] = "Enable random messages.", ["Function"] = function() end
	});
	text = DamageIndicator:CreateTextList({
		["Name"] = "Text", ["TempText"] = "Text of the indicator"
	});
	fontTog = DamageIndicator:CreateToggle({
		["Name"] = "Custom Font", ["HoverText"] = "Enable custom font.", ["Function"] = function() end
	});
end);

velo.run(function()
	local HitColor: table = {["Enabled"] = false}
	local Color: any;
	local done: any = {}
	HitColor = vape.Legit:CreateModule({
		["Name"] = 'Hit Color',
		["Function"] = function(callback: boolean): void
			if callback then 
				repeat
					for i: any, v: any in entitylib.List do 
						local highlight: Instance? = v.Character and v.Character:FindFirstChild('_DamageHighlight_');
						if highlight then 
							if not table.find(done, highlight) then 
								table.insert(done, highlight); 
							end;
							highlight.FillColor = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value);
							highlight.FillTransparency = Color.Opacity;
						end;
					end;
					task.wait(0.1);
				until not HitColor["Enabled"];
			else
				for i: any, v: any in done do 
					v.FillColor = Color3.new(1, 0, 0);
					v.FillTransparency = 0.4;
				end;
				table.clear(done)
			end;
		end,
		["Tooltip"] = 'Customize the hit highlight options'
	})
	Color = HitColor:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultOpacity"] = 0.4
	})
end)

velo.run(function()
	local Interface: table = {["Enabled"] = false}
	local Health: table = {["Enabled"] = false}
	local HotBar: table = {["Enabled"] = false}
	local HotbarOpenInventory: Module = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-open-inventory']).HotbarOpenInventory;
	local HotbarHealthbar: Module = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar;
	local HotbarApp: Module = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-app']).HotbarApp;
	local old: {[Function]: {[number]: any}} = {}; 
	local new: {[Function]: {[number]: any}} = {}; 
	
	vape:Clean(function()
		for _, v in new do
			table.clear(v);
		end;
		for _, v in old do
			table.clear(v);
		end;
		table.clear(new)
		table.clear(old)
	end)
	
	local function modifyconstant(func: Function, ind: number, val: any)
		if not func then return; end;
		if not old[func] then old[func] = {}; end;
		if not new[func] then new[func] = {}; end;
		if not old[func][ind] then
			old[func][ind] = debug.getconstant(func, ind);
		end;
		if typeof(old[func][ind]) ~= typeof(val) then return; end;
		new[func][ind] = val;
	
		if Interface["Enabled"] then
			if val then
				debug.setconstant(func, ind, val);
			else
				debug.setconstant(func, ind, old[func][ind]);
				old[func][ind] = nil;
			end;
		end;
	end;
	
	Interface = vape.Legit:CreateModule({
		["Name"] = 'Interface',
		["Function"] = function(callback: boolean): void
			for i, v in (callback and new or old) do
				for i2, v2 in v do
					debug.setconstant(i, i2, v2);
				end;
			end;
		end,
		["Tooltip"] = 'Customize bedwars UI'
	})
	local fontitems: { string } = {'LuckiestGuy'}
	for _, v in Enum.Font:GetEnumItems() do
		if v.Name ~= 'LuckiestGuy' then
			table.insert(fontitems, v.Name);
		end;
	end;
	Interface:CreateDropdown({
		["Name"] = 'Health Font',
		["List"] = fontitems,
		["Function"] = function(val)
			modifyconstant(HotbarHealthbar.render, 77, val);
		end;
	})
	Health = Interface:CreateToggle({
		["Name"] = "Health Bar",
		["Function"] = function(callback) end,
		["Default"] = false
	})
	HotBar = Interface:CreateToggle({
		["Name"] = "HotBar",
		["Function"] = function(callback) end,
		["Default"] = false
	})
	Interface:CreateColorSlider({
		["Name"] = 'Health Color',
		["Function"] = function(hue, sat, val)
			modifyconstant(HotbarHealthbar.render, 16, tonumber(Color3.fromHSV(hue, sat, val):ToHex(), 16))
			if Interface["Enabled"] and Health["Enabled"] then
				local hotbar: Instance? = lplr.PlayerGui:FindFirstChild('hotbar');
				hotbar = hotbar and hotbar:FindFirstChild('HealthbarProgressWrapper', true);
				if hotbar then
					hotbar['1'].BackgroundColor3 = Color3.fromHSV(hue, sat, val);
				end;
			end;
		end;
	})
	Interface:CreateColorSlider({
		["Name"] = 'Hotbar Color',
		["DefaultOpacity"] = 0.8,
		["Function"] = function(hue, sat, val, opacity)
			if Interface["Enabled"] and HotBar["Enabled"] then
				local func: Function = oldinvrender or HotbarOpenInventory.render
				modifyconstant(debug.getupvalue(HotbarApp.render, 17).render, 51, tonumber(Color3.fromHSV(hue, sat, val):ToHex(), 16))
				modifyconstant(debug.getupvalue(HotbarApp.render, 17).render, 58, tonumber(Color3.fromHSV(hue, sat, math.clamp(val > 0.5 and val - 0.2 or val + 0.2, 0, 1)):ToHex(), 16))
				modifyconstant(debug.getupvalue(HotbarApp.render, 17).render, 54, 1 - opacity)
				modifyconstant(debug.getupvalue(HotbarApp.render, 17).render, 55, math.clamp(1.2 - opacity, 0, 1))
				modifyconstant(func, 31, tonumber(Color3.fromHSV(hue, sat, val):ToHex(), 16))
				modifyconstant(func, 32, math.clamp(1.2 - opacity, 0, 1))
				modifyconstant(func, 34, tonumber(Color3.fromHSV(hue, sat, math.clamp(val > 0.5 and val - 0.2 or val + 0.2, 0, 1)):ToHex(), 16))
			end
		end
	})
end)

velo.run(function()
	local ReachDisplay: table = {["Enabled"] = false}
	local label: any;
	ReachDisplay = vape.Legit:CreateModule({
		["Name"] = 'Reach Display',
		["Function"] = function(callback: boolean): void
			if callback then
				repeat
					label.Text = (store.attackReachUpdate > tick() and store.attackReach or '0.00')..' studs';
					task.wait(0.4);
				until not ReachDisplay["Enabled"];
			end;
		end,
		Size = UDim2.fromOffset(100, 41)
	})
	ReachDisplay:CreateFont({
		["Name"] = 'Font',
		["Blacklist"] = 'Gotham',
		["Function"] = function(val)
			label.FontFace = val;
		end;
	})
	ReachDisplay:CreateColorSlider({
		["Name"] = 'Color',
		["DefaultValue"] = 0,
		["DefaultOpacity"] = 0.5,
		["Function"] = function(hue, sat, val, opacity)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			label.BackgroundTransparency = 1 - opacity;
		end;
	})
	label = Instance.new('TextLabel');
	label.Size = UDim2.fromScale(1, 1);
	label.BackgroundTransparency = 0.5;
	label.TextSize = 15;
	label.Font = Enum.Font.Gotham;
	label.Text = '0.00 studs';
	label.TextColor3 = Color3.new(1, 1, 1);
	label.BackgroundColor3 = Color3.new();
	label.Parent = ReachDisplay.Children;
	local corner: UICorner = Instance.new('UICorner');
	corner.CornerRadius = UDim.new(0, 4);
	corner.Parent = label;
end)
	
velo.run(function()
	vape.Legit:CreateModule({
		["Name"] = 'HitFix',
		["Function"] = function(callback: boolean): void
			debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, callback and 'raycast' or 'Raycast');
			debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, callback and bedwars.QueryUtil or workspace);
		end,
		["Tooltip"] = 'Changes the raycast function to the correct one'
	})
end)

velo.run(function()
	local UICleanup: table = {["Enabled"] = false}
	local OpenInv: table = {["Enabled"] = false}
	local KillFeed: table = {["Enabled"] = false}
	local OldTabList: table = {["Enabled"] = false}
	local HotbarApp: any = getRoactRender(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-app']).HotbarApp.render);
	local HotbarOpenInventory: any = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-open-inventory']).HotbarOpenInventory;
	local old: any = {}
	local new: any = {}
	local oldkillfeed: any;
	
	vape:Clean(function()
		for _, v in new do 
			table.clear(v); 
		end;
		for _, v in old do 
			table.clear(v);
		end;
		table.clear(new);
		table.clear(old);
	end);
	
	local function modifyconstant(func: any?, ind: number?, val: any?)
		if not old[func] then old[func] = {}; end;
		if not new[func] then new[func] = {}; end;
		if not old[func][ind] then 
			local typing: any = type(old[func][ind]);
			if typing == 'function' or typing == 'userdata' then 
				return; 
			end;
			old[func][ind] = debug.getconstant(func, ind); 
		end;
		if typeof(old[func][ind]) ~= typeof(val) and val ~= nil then return; end;
		new[func][ind] = val;
		if UICleanup["Enabled"] then
			if val then
				debug.setconstant(func, ind, val);
			else
				debug.setconstant(func, ind, old[func][ind]);
				old[func][ind] = nil;
			end;
		end;
	end;
	
	UICleanup = vape.Legit:CreateModule({
		["Name"] = 'UI Cleanup',
		["Function"] = function(callback: boolean): void
			for i: any, v: any in (callback and new or old) do
				for i2: any, v2: any in v do 
					debug.setconstant(i, i2, v2); 
				end;
			end;
			if callback then
				if OpenInv["Enabled"] then
					oldinvrender = HotbarOpenInventory.render;
					HotbarOpenInventory.render = function()
						return bedwars.Roact.createElement('TextButton', {Visible = false}, {});
					end;
				end;
				if KillFeed["Enabled"] then
					oldkillfeed = bedwars.KillFeedController.addToKillFeed;
					bedwars.KillFeedController.addToKillFeed = function() end;
				end;
	
				if OldTabList["Enabled"] then 
					starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true); 
				end;
			else
				if oldinvrender then
					HotbarOpenInventory.render = oldinvrender;
					oldinvrender = nil;
				end;
				if KillFeed["Enabled"] then
					bedwars.KillFeedController.addToKillFeed = oldkillfeed;
					oldkillfeed = nil;
				end;
				if OldTabList["Enabled"] then 
					starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false); 
				end;
			end;
		end,
		["Tooltip"] = 'Cleans up the UI for kits & main';
	})
	UICleanup:CreateToggle({
		["Name"] = 'Resize Health',
		["Function"] = function(callback)
			modifyconstant(HotbarApp, 60, callback and 1 or nil);
			modifyconstant(debug.getupvalue(HotbarApp, 15).render, 30, callback and 1 or nil);
			modifyconstant(debug.getupvalue(HotbarApp, 23).tweenPosition, 16, callback and 0 or nil);
		end,
		["Default"] = true
	})
	UICleanup:CreateToggle({
		["Name"] = 'No Hotbar Numbers',
		["Function"] = function(callback)
			local func: any = oldinvrender or HotbarOpenInventory.render;
			modifyconstant(debug.getupvalue(HotbarApp, 23).render, 90, callback and 0 or nil);
			modifyconstant(func, 71, callback and 0 or nil);
		end,
		["Default"] = true
	})
	OpenInv = UICleanup:CreateToggle({
		["Name"] = 'No Inventory Button',
		["Function"] = function(callback)
			modifyconstant(HotbarApp, 78, callback and 0 or nil);
			if UICleanup["Enabled"] then
				if callback then
					oldinvrender = HotbarOpenInventory.render;
					HotbarOpenInventory.render = function()
						return bedwars.Roact.createElement('TextButton', {Visible = false}, {});
					end;
				else
					HotbarOpenInventory.render = oldinvrender;
					oldinvrender = nil;
				end;
			end;
		end,
		["Default"] = true
	})
	KillFeed = UICleanup:CreateToggle({
		["Name"] = 'No Kill Feed',
		["Function"] = function(callback)
			if UICleanup["Enabled"] then
				if callback then
					oldkillfeed = bedwars.KillFeedController.addToKillFeed;
					bedwars.KillFeedController.addToKillFeed = function() end;
				else
					bedwars.KillFeedController.addToKillFeed = oldkillfeed;
					oldkillfeed = nil;
				end
			end
		end,
		["Default"] = true
	})
	OldTabList = UICleanup:CreateToggle({
		["Name"] = 'Old Player List',
		["Function"] = function(callback)
			if UICleanup["Enabled"] then 
				starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, callback); 
			end;
		end,
		["Default"] = true
	})
	UICleanup:CreateToggle({
		["Name"] = 'Fix Queue Card',
		["Function"] = function(callback)
			modifyconstant(bedwars.QueueCard.render, 15, callback and 0.1 or nil);
		end,
		["Default"] = true
	})
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
		local list: any = List.ListEnabled;
		if #alreadypicked >= #list then 
			table.clear(alreadypicked); 
		end;
	
		if #list <= 0 then
			notif('SongBeats', 'no songs', 10);
			SongBeats:Toggle();
			return;
		end;
	
		local chosensong: string = list[math.random(1, #list)]
		if #list > 1 and table.find(alreadypicked, chosensong) then
			repeat 
				task.wait(); 
				chosensong = list[math.random(1, #list)]; 
			until not table.find(alreadypicked, chosensong) or not SongBeats["Enabled"];
		end;
		if not SongBeats["Enabled"] then return; end;
	
		local split: {string} = chosensong:split('/');
		if not isfile(split[1]) then
			notif('SongBeats', 'Missing song ('..split[1]..')', 10);
			SongBeats:Toggle();
			return;
		end;
	
		songobj.SoundId = assetfunction(split[1]);
		repeat task.wait() until songobj.IsLoaded or not SongBeats["Enabled"];
		if SongBeats["Enabled"] then
			beattick = tick() + (tonumber(split[3]) or 0);
			songbpm = 60 / (tonumber(split[2]) or 50);
			songobj:Play();
		end;
	end;
	
	SongBeats = vape.Legit:CreateModule({
		["Name"] = 'Song Beats',
		["Function"] = function(callback: boolean): void
			if callback then
				songobj = Instance.new('Sound');
				songobj.Volume = Volume["Value"] / 100;
				songobj.Parent = workspace;
				repeat
					if not songobj.Playing then choosesong(); end;
					if beattick < tick() and SongBeats["Enabled"] and FOV["Enabled"] then
						beattick = tick() + songbpm;
						oldfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120);
						gameCamera.FieldOfView = oldfov - FOVValue["Value"];
						songtween = tweenService:Create(gameCamera, TweenInfo.new(math.min(songbpm, 0.2), Enum.EasingStyle.Linear), {FieldOfView = oldfov});
						songtween:Play();
					end;
					task.wait();
				until not SongBeats["Enabled"]
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
	})
	List = SongBeats:CreateTextList({
		["Name"] = 'Songs',
		["Placeholder"] = 'filepath/bpm/start'
	})
	FOV = SongBeats:CreateToggle({
		["Name"] = 'Beat FOV',
		["Function"] = function(callback)
			if FOVValue.Object then
				FOVValue.Object.Visible = callback;
			end;
			if SongBeats["Enabled"] then
				SongBeats:Toggle();
				SongBeats:Toggle();
			end;
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
				songobj.Volume = val / 100; 
			end;
		end,
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 100,
		["Suffix"] = '%'
	})
end)

velo.run(function()
	local AutoHotbar: table = {["Enabled"] = false}
	local Mode: table = {};
	local Clear: table = {};
	local List: table = {};
	local Active: any;
	
	local function CreateWindow(self)
		local selectedslot: number = 1
		local window: Frame = Instance.new('Frame')
		window.Name = 'HotbarGUI'
		window.Size = UDim2.fromOffset(660, 465)
		window.Position = UDim2.fromScale(0.5, 0.5)
		window.BackgroundColor3 = uipallet.Main
		window.AnchorPoint = Vector2.new(0.5, 0.5)
		window.Visible = false
		window.Parent = vape.gui.ScaledGui
		local title: TextLabel = Instance.new('TextLabel')
		title.Name = 'Title'
		title.Size = UDim2.new(1, -10, 0, 20)
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 12)
		title.BackgroundTransparency = 1
		title.Text = 'AutoHotbar'
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = uipallet.Text
		title.TextSize = 13
		title.FontFace = uipallet.Font
		title.Parent = window
		local divider: Frame = Instance.new('Frame')
		divider.Name = 'Divider'
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Position = UDim2.fromOffset(0, 40)
		divider.BackgroundColor3 = color.Light(uipallet.Main, 0.04)
		divider.BorderSizePixel = 0
		divider.Parent = window
		addBlur(window)
		local modal: TextButton = Instance.new('TextButton')
		modal.Text = ''
		modal.BackgroundTransparency = 1
		modal.Modal = true
		modal.Parent = window
		local corner: UICorner = Instance.new('UICorner')
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = window
		local close: ImageButton = Instance.new('ImageButton')
		close.Name = 'Close'
		close.Size = UDim2.fromOffset(24, 24)
		close.Position = UDim2.new(1, -35, 0, 9)
		close.BackgroundColor3 = Color3.new(1, 1, 1)
		close.BackgroundTransparency = 1
		close.Image = getcustomasset('newvape/assets/new/close.png')
		close.ImageColor3 = color.Light(uipallet.Text, 0.2)
		close.ImageTransparency = 0.5
		close.AutoButtonColor = false
		close.Parent = window
		close.MouseEnter:Connect(function()
			close.ImageTransparency = 0.3
			tween:Tween(close, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.6
			})
		end)
		close.MouseLeave:Connect(function()
			close.ImageTransparency = 0.5
			tween:Tween(close, TweenInfo.new(0.2), {
				BackgroundTransparency = 1
			})
		end)
		close.MouseButton1Click:Connect(function()
			window.Visible = false
			vape.gui.ScaledGui.ClickGui.Visible = true
		end)
		local closecorner: UICorner = Instance.new('UICorner')
		closecorner.CornerRadius = UDim.new(1, 0)
		closecorner.Parent = close
		local bigslot: Frame = Instance.new('Frame')
		bigslot.Size = UDim2.fromOffset(110, 111)
		bigslot.Position = UDim2.fromOffset(11, 71)
		bigslot.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		bigslot.Parent = window
		local bigslotcorner: UICorner = Instance.new('UICorner')
		bigslotcorner.CornerRadius = UDim.new(0, 4)
		bigslotcorner.Parent = bigslot
		local bigslotstroke: UIStroke = Instance.new('UIStroke')
		bigslotstroke.Color = color.Light(uipallet.Main, 0.034)
		bigslotstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bigslotstroke.Parent = bigslot
		local slotnum: TextLabel = Instance.new('TextLabel')
		slotnum.Size = UDim2.fromOffset(80, 20)
		slotnum.Position = UDim2.fromOffset(25, 200)
		slotnum.BackgroundTransparency = 1
		slotnum.Text = 'SLOT 1'
		slotnum.TextColor3 = color.Dark(uipallet.Text, 0.1)
		slotnum.TextSize = 12
		slotnum.FontFace = uipallet.Font
		slotnum.Parent = window
		for i = 1, 9 do
			local slotbkg: TextButton = Instance.new('TextButton');
			slotbkg.Name = 'Slot'..i;
			slotbkg.Size = UDim2.fromOffset(51, 52);
			slotbkg.Position = UDim2.fromOffset(89 + (i * 55), 382);
			slotbkg.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
			slotbkg.Text = '';
			slotbkg.AutoButtonColor = false;
			slotbkg.Parent = window;
			local slotimage: ImageLabel = Instance.new('ImageLabel');
			slotimage.Size = UDim2.fromOffset(32, 32);
			slotimage.Position = UDim2.new(0.5, -16, 0.5, -16);
			slotimage.BackgroundTransparency = 1;
			slotimage.Image = '';
			slotimage.Parent = slotbkg;
			local slotcorner: UICorner = Instance.new('UICorner');
			slotcorner.CornerRadius = UDim.new(0, 4);
			slotcorner.Parent = slotbkg;
			local slotstroke: UIStroke = Instance.new('UIStroke');
			slotstroke.Color = color.Light(uipallet.Main, 0.04);
			slotstroke.Thickness = 2;
			slotstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			slotstroke.Enabled = i == selectedslot;
			slotstroke.Parent = slotbkg;
			slotbkg.MouseEnter:Connect(function()
				slotbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034);
			end);
			slotbkg.MouseLeave:Connect(function()
				slotbkg.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
			end);
			slotbkg.MouseButton1Click:Connect(function()
				window['Slot'..selectedslot].UIStroke["Enabled"] = false;
				selectedslot = i;
				slotstroke.Enabled = true;
				slotnum.Text = 'SLOT '..selectedslot;
			end);
			slotbkg.MouseButton2Click:Connect(function()
				local obj: any = self.Hotbars[self.Selected];
				if obj then
					window['Slot'..i].ImageLabel.Image = '';
					obj.Hotbar[tostring(i)] = nil;
					obj.Object['Slot'..i].Image = '	';
				end;
			end);
		end;
		local searchbkg: Frame = Instance.new('Frame');
		searchbkg.Size = UDim2.fromOffset(496, 31);
		searchbkg.Position = UDim2.fromOffset(142, 80);
		searchbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034);
		searchbkg.Parent = window;
		local search: TextBox = Instance.new('TextBox');
		search.Size = UDim2.new(1, -10, 0, 31);
		search.Position = UDim2.fromOffset(10, 0);
		search.BackgroundTransparency = 1;
		search.Text = '';
		search.PlaceholderText = '';
		search.TextXAlignment = Enum.TextXAlignment.Left;
		search.TextColor3 = uipallet.Text;
		search.TextSize = 12;
		search.FontFace = uipallet.Font;
		search.ClearTextOnFocus = false;
		search.Parent = searchbkg;
		local searchcorner: UICorner = Instance.new('UICorner')
		searchcorner.CornerRadius = UDim.new(0, 4)
		searchcorner.Parent = searchbkg
		local searchicon: ImageLabel = Instance.new('ImageLabel');
		searchicon.Size = UDim2.fromOffset(14, 14)
		searchicon.Position = UDim2.new(1, -26, 0, 8);
		searchicon.BackgroundTransparency = 1;
		searchicon.Image = getcustomasset('newvape/assets/new/search.png');
		searchicon.ImageColor3 = color.Light(uipallet.Main, 0.37);
		searchicon.Parent = searchbkg;
		local children: ScrollingFrame = Instance.new('ScrollingFrame');
		children.Name = 'Children';
		children.Size = UDim2.fromOffset(500, 240);
		children.Position = UDim2.fromOffset(144, 122);
		children.BackgroundTransparency = 1;
		children.BorderSizePixel = 0;
		children.ScrollBarThickness = 2;
		children.ScrollBarImageTransparency = 0.75;
		children.CanvasSize = UDim2.new();
		children.Parent = window;
		local windowlist: UIGridLayout = Instance.new('UIGridLayout');
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.FillDirectionMaxCells = 9;
		windowlist.CellSize = UDim2.fromOffset(51, 52);
		windowlist.CellPadding = UDim2.fromOffset(4, 3);
		windowlist.Parent = children;
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then 
				setthreadidentity(8);
			end;
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / vape.guiscale.Scale);
		end);
		table.insert(vape.Windows, window);
	
		local function createitem(id: any, image: any): any
			local slotbkg: TextButton = Instance.new('TextButton');
			slotbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
			slotbkg.Text = '';
			slotbkg.AutoButtonColor = false;
			slotbkg.Parent = children;
			local slotimage: ImageLabel = Instance.new('ImageLabel');
			slotimage.Size = UDim2.fromOffset(32, 32);
			slotimage.Position = UDim2.new(0.5, -16, 0.5, -16);
			slotimage.BackgroundTransparency = 1;
			slotimage.Image = image;
			slotimage.Parent = slotbkg;
			local slotcorner: UICorner = Instance.new('UICorner');
			slotcorner.CornerRadius = UDim.new(0, 4)
			slotcorner.Parent = slotbkg
			slotbkg.MouseEnter:Connect(function()
				slotbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.04);
			end);
			slotbkg.MouseLeave:Connect(function()
				slotbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
			end);
			slotbkg.MouseButton1Click:Connect(function()
				local obj: any = self.Hotbars[self.Selected];
				if obj then
					window['Slot'..selectedslot].ImageLabel.Image = image;
					obj.Hotbar[tostring(selectedslot)] = id;
					obj.Object['Slot'..selectedslot].Image = image;
				end;
			end);
		end;
	
		local function indexSearch(text: string): string?
			for _, v in children:GetChildren() do
				if v:IsA('TextButton') then
					v:ClearAllChildren();
					v:Destroy();
				end;
			end;
			if text == '' then
				for _, v in {'diamond_sword', 'diamond_pickaxe', 'diamond_axe', 'shears', 'wood_bow', 'wool_white', 'fireball', 'apple', 'iron', 'gold', 'diamond', 'emerald'} do
					createitem(v, bedwars.ItemMeta[v].image);
				end;
				return;
			end;
			for i, v in bedwars.ItemMeta do
				if text:lower() == i:lower():sub(1, text:len()) then
					if not v.image then continue; end;
					createitem(i, v.image);
				end;
			end;
		end;
		search:GetPropertyChangedSignal('Text'):Connect(function() 
			indexSearch(search.Text);
		end);
		indexSearch('');
		return window;
	end;
	
	vape.Components.HotbarList = function(optionsettings: {Darker: boolean}, children: {BackgroundColor3: Color3}, api: any)
		if vape.ThreadFix then 
			setthreadidentity(8);
		end;
		local optionapi: table = {
			Type = 'HotbarList', 
			Hotbars = {}, 
			Selected = 1
		};
		local hotbarlist: TextButton = Instance.new('TextButton');
		hotbarlist.Name = 'HotbarList';
		hotbarlist.Size = UDim2.fromOffset(220, 40);
		hotbarlist.BackgroundColor3 = optionsettings.Darker and (children.BackgroundColor3 == color.Dark(uipallet.Main, 0.02) and color.Dark(uipallet.Main, 0.04) or color.Dark(uipallet.Main, 0.02)) or children.BackgroundColor3;
		hotbarlist.Text = '';
		hotbarlist.BorderSizePixel = 0;
		hotbarlist.AutoButtonColor = false;
		hotbarlist.Parent = children;
		local textbkg: Frame = Instance.new('Frame');
		textbkg.Name = 'BKG';
		textbkg.Size = UDim2.new(1, -20, 0, 31);
		textbkg.Position = UDim2.fromOffset(10, 4);
		textbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034);
		textbkg.Parent = hotbarlist;
		local textbkgcorner: UICorner = Instance.new('UICorner');
		textbkgcorner.CornerRadius = UDim.new(0, 4);
		textbkgcorner.Parent = textbkg;
		local textbutton: TextButton = Instance.new('TextButton');
		textbutton.Name = 'HotbarList';
		textbutton.Size = UDim2.new(1, -2, 1, -2);
		textbutton.Position = UDim2.fromOffset(1, 1);
		textbutton.BackgroundColor3 = uipallet.Main;
		textbutton.Text = '';
		textbutton.AutoButtonColor = false;
		textbutton.Parent = textbkg;
		textbutton.MouseEnter:Connect(function()
			tween:Tween(textbkg, TweenInfo.new(0.2), {
				BackgroundColor3 = color.Light(uipallet.Main, 0.14)
			});
		end);
		textbutton.MouseLeave:Connect(function()
			tween:Tween(textbkg, TweenInfo.new(0.2), {
				BackgroundColor3 = color.Light(uipallet.Main, 0.034)
			});
		end);
		local textbuttoncorner: UICorner = Instance.new('UICorner');
		textbuttoncorner.CornerRadius = UDim.new(0, 4);
		textbuttoncorner.Parent = textbutton;
		local textbuttonicon: ImageLabel = Instance.new('ImageLabel');
		textbuttonicon.Size = UDim2.fromOffset(12, 12);
		textbuttonicon.Position = UDim2.fromScale(0.5, 0.5);
		textbuttonicon.AnchorPoint = Vector2.new(0.5, 0.5);
		textbuttonicon.BackgroundTransparency = 1;
		textbuttonicon.Image = getcustomasset('newvape/assets/new/add.png');
		textbuttonicon.ImageColor3 = Color3.fromHSV(0.46, 0.96, 0.52);
		textbuttonicon.Parent = textbutton;
		local childrenlist: Frame = Instance.new('Frame');
		childrenlist.Size = UDim2.new(1, 0, 1, -40);
		childrenlist.Position = UDim2.fromOffset(0, 40);
		childrenlist.BackgroundTransparency = 1;
		childrenlist.Parent = hotbarlist;
		local windowlist: UIListLayout = Instance.new('UIListLayout');
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlist.Padding = UDim.new(0, 3);
		windowlist.Parent = childrenlist;
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then 
				setthreadidentity(8); 
			end;
			hotbarlist.Size = UDim2.fromOffset(220, math.min(43 + windowlist.AbsoluteContentSize.Y / vape.guiscale.Scale, 603));
		end);
		textbutton.MouseButton1Click:Connect(function()
			optionapi:AddHotbar();
		end);
		optionapi.Window = CreateWindow(optionapi);
	
		function optionapi:Save(savetab: {Selected: number?, Hotbars: {Selected: number, Hotbars: {Hotbar: any}}})
			local hotbars: table = {};
			for _, v in self.Hotbars do
				table.insert(hotbars, v.Hotbar);
			end;
			savetab.HotbarList = {
				Selected = self.Selected, 
				Hotbars = hotbars
			};
		end;
	
		function optionapi:Load(savetab: {Selected: number?, Hotbars: {Selected: number, Hotbars: {Hotbar: any}}})
			for _, v in self.Hotbars do
				v.Object:ClearAllChildren();
				v.Object:Destroy();
				table.clear(v.Hotbar);
			end;
			table.clear(self.Hotbars);
			for _, v in savetab.Hotbars do
				self:AddHotbar(v);
			end;
			self.Selected = savetab.Selected or 1;
		end;
	
		function optionapi:AddHotbar(data: {[string]: any}?)
			local hotbardata: any = { Hotbar = data or {} }
			table.insert(self.Hotbars, hotbardata);
			local hotbar: TextButton = Instance.new('TextButton');
			hotbar.Size = UDim2.fromOffset(200, 27);
			hotbar.BackgroundColor3 = table.find(self.Hotbars, hotbardata) == self.Selected and color.Light(uipallet.Main, 0.034) or uipallet.Main;
			hotbar.Text = '';
			hotbar.AutoButtonColor = false;
			hotbar.Parent = childrenlist;
			hotbardata.Object = hotbar;
			local hotbarcorner: UICorner = Instance.new('UICorner');
			hotbarcorner.CornerRadius = UDim.new(0, 4);
			hotbarcorner.Parent = hotbar;
			for i = 1, 9 do
				local slot: ImageLabel = Instance.new('ImageLabel');
				slot.Name = 'Slot'..i;
				slot.Size = UDim2.fromOffset(17, 18);
				slot.Position = UDim2.fromOffset(-7 + (i * 18), 5);
				slot.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
				slot.Image = hotbardata.Hotbar[tostring(i)] and bedwars.getIcon({itemType = hotbardata.Hotbar[tostring(i)]}, true) or '';
				slot.BorderSizePixel = 0;
				slot.Parent = hotbar;
			end;
			hotbar.MouseButton1Click:Connect(function()
				local ind: any = table.find(optionapi.Hotbars, hotbardata);
				if ind == optionapi.Selected then
					vape.gui.ScaledGui.ClickGui.Visible = false;
					optionapi.Window.Visible = true;
					for i = 1, 9 do
						optionapi.Window['Slot'..i].ImageLabel.Image = hotbardata.Hotbar[tostring(i)] and bedwars.getIcon({itemType = hotbardata.Hotbar[tostring(i)]}, true) or '';
					end;
				else
					if optionapi.Hotbars[optionapi.Selected] then
						optionapi.Hotbars[optionapi.Selected].Object.BackgroundColor3 = uipallet.Main;
					end;
					hotbar.BackgroundColor3 = color.Light(uipallet.Main, 0.034);
					optionapi.Selected = ind;
				end;
			end);
			local close: ImageButton = Instance.new('ImageButton');
			close.Name = 'Close';
			close.Size = UDim2.fromOffset(16, 16);
			close.Position = UDim2.new(1, -23, 0, 6);
			close.BackgroundColor3 = Color3.new(1, 1, 1);
			close.BackgroundTransparency = 1;
			close.Image = getcustomasset('newvape/assets/new/closemini.png');
			close.ImageColor3 = color.Light(uipallet.Text, 0.2);
			close.ImageTransparency = 0.5;
			close.AutoButtonColor = false;
			close.Parent = hotbar;
			local closecorner: UICorner = Instance.new('UICorner');
			closecorner.CornerRadius = UDim.new(1, 0);
			closecorner.Parent = close;
			close.MouseEnter:Connect(function()
				close.ImageTransparency = 0.3;
				tween:Tween(close, TweenInfo.new(0.2), {
					BackgroundTransparency = 0.6
				});
			end);
			close.MouseLeave:Connect(function()
				close.ImageTransparency = 0.5;
				tween:Tween(close, TweenInfo.new(0.2), {
					BackgroundTransparency = 1
				});
			end);
			close.MouseButton1Click:Connect(function()
				local ind: any = table.find(self.Hotbars, hotbardata);
				local obj: any = self.Hotbars[self.Selected];
				local obj2: any = self.Hotbars[ind];
				if obj and obj2 then
					obj2.Object:ClearAllChildren();
					obj2.Object:Destroy();
					table.remove(self.Hotbars, ind);
					ind = table.find(self.Hotbars, obj);
					self.Selected = table.find(self.Hotbars, obj) or 1;
				end;
			end);
		end;
		api.Options.HotbarList = optionapi;
		return optionapi;
	end;
	
	local function getBlock(): any
		local clone: { any } = table.clone(store.inventory.inventory.items);
		table.sort(clone, function(a, b)
			return a.amount < b.amount;
		end);
	
		for _, item in clone do
			if bedwars.ItemMeta[item.itemType].block then
				return item;
			end;
		end;
	end;
	
	local function getCustomItem(v: string): string
		if v == 'diamond_sword' then
			local sword: any = store.tools.sword;
			v = sword and sword.itemType or 'wood_sword';
		elseif v == 'diamond_pickaxe' then
			local pickaxe: any = store.tools.stone;
			v = pickaxe and pickaxe.itemType or 'wood_pickaxe';
		elseif v == 'diamond_axe' then
			local axe: any = store.tools.wood;
			v = axe and axe.itemType or 'wood_axe'
		elseif v == 'wood_bow' then
			local bow: any = getBow();
			v = bow and bow.itemType or 'wood_bow'
		elseif v == 'wool_white' then
			local block: any = getBlock();
			v = block and block.itemType or 'wool_white';
		end;
		return v;
	end;
	
	local function findItemInTable(tab: { any }, item: any): number?
		for slot, v in tab do
			if item.itemType == getCustomItem(v) then
				return tonumber(slot);
			end;
		end;
	end;
	
	local function findInHotbar(item: any): number?
		for i, v in store.inventory.hotbar do
			if v.item and v.item.itemType == item.itemType then
				return i - 1, v.item;
			end;
		end;
	end;
	
	local function findInInventory(item: any): any
		for _, v in store.inventory.inventory.items do
			if v.itemType == item.itemType then
				return v;
			end;
		end;
	end;
	
	local function dispatch(...: any)
		bedwars.Store:dispatch(...);
		vapeEvents.InventoryChanged.Event:Wait();
	end;
	
	local function sortCallback(): (any, any)
		if Active then return; end;
		Active = true
		local items: any = (List.Hotbars[List.Selected] and List.Hotbars[List.Selected].Hotbar or {});
		for _, v in store.inventory.inventory.items do
			local slot: any = findItemInTable(items, v);
			if slot then
				local olditem: any = store.inventory.hotbar[slot];
				if olditem.item and olditem.item.itemType == v.itemType then continue; end;
				if olditem.item then
					dispatch({
						type = 'InventoryRemoveFromHotbar', 
						slot = slot - 1
					});
				end;
				local newslot: any = findInHotbar(v);
				if newslot then
					dispatch({
						type = 'InventoryRemoveFromHotbar', 
						slot = newslot
					});
					if olditem.item then
						dispatch({
							type = 'InventoryAddToHotbar',
							item = findInInventory(olditem.item),
							slot = newslot
						});
					end;
				end;
				dispatch({
					type = 'InventoryAddToHotbar',
					item = findInInventory(v),
					slot = slot - 1
				});
			elseif Clear["Enabled"] then
				local newslot: any = findInHotbar(v);
				if newslot then
				   	dispatch({
						type = 'InventoryRemoveFromHotbar', 
						slot = newslot
					});
				end;
			end;
		end;
		Active = false;
	end;
	
	AutoHotbar = vape.Categories.Inventory:CreateModule({
		["Name"] = 'AutoHotbar',
		["Function"] = function(callback: boolean): void
			if callback then
				task.spawn(sortCallback);
				if Mode["Value"]== 'On Key' then 
					AutoHotbar:Toggle(); 
					return;
				end;
				AutoHotbar:Clean(vapeEvents.InventoryAmountChanged.Event:Connect(sortCallback));
			end;
		end,
		["Tooltip"] = 'Automatically arranges hotbar to your liking.'
	})
	Mode = AutoHotbar:CreateDropdown({
		["Name"] = 'Activation',
		["List"] = {'Toggle', 'On Key'},
		["Function"] = function()
			if AutoHotbar["Enabled"] then
				AutoHotbar:Toggle();
				AutoHotbar:Toggle();
			end;
		end;
	})
	Clear = AutoHotbar:CreateToggle({["Name"] = 'Clear Hotbar'})
	List = AutoHotbar:CreateHotbarList({})
end)

velo.run(function()
    local anim: Animation?;
    local asset: Model?;
    local lastPos: Vector3?;
    local conn: RBXScriptConnection?;
    local NightmareEmote: table = {["Enabled"] = false};
    NightmareEmote = vape.Categories.World:CreateModule({
        ["Name"] = "NightmareEmote";
        ["Function"] = function(callback: boolean): nil
            if callback then
                local char: Model? = lplr.Character;
                if not char or not char.PrimaryPart then 
			NightmareEmote:Toggle(); 
			return; 
		end;
                local GQU: any = cheatengine and { setQueryIgnored = function() end } or require(replicatedStorage:WaitForChild("rbxts_include").node_modules["@easy-games"]["game-core"].out).GameQueryUtil;
                asset = replicatedStorage.Assets.Effects.NightmareEmote:Clone();
                asset.Parent = workspace;
                lastPos = char.PrimaryPart.Position;
                conn = runService.RenderStepped:Connect(function()
                    if not asset or not char or not char:FindFirstChild("LowerTorso") then return; end;
                    local pos: Vector3 = char.PrimaryPart.Position;
                    if (pos - lastPos).Magnitude > 0.1 then
                        if conn then conn:Disconnect(); conn = nil; end;
                        if asset then asset:Destroy(); asset = nil; end;
                        NightmareEmote:Toggle();
                        return;
                    end;
                    lastPos = pos;
                    asset:SetPrimaryPartCFrame(char.LowerTorso.CFrame + Vector3.new(0, -2, 0));
                end);

                for _, d: Instance in next, asset:GetDescendants() do
                    if d:IsA("BasePart") then
                        GQU:setQueryIgnored(d, true);
                        d.CanCollide = false;
                        d.Anchored = true;
                    end;
                end;

                for _, part: BasePart? in {asset:FindFirstChild("Outer"), asset:FindFirstChild("Middle")} do
                    if part then
                        local isOuter: boolean = part.Name == "Outer";
                        local rot: Vector3 = Vector3.new(0, isOuter and 360 or -360, 0);
                        local time: number = isOuter and 1.5 or 12.5;
                        tweenService:Create(part, TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
                            Orientation = part.Orientation + rot
                        }):Play();
                    end;
                end;
                local a: Animation = Instance.new("Animation");
                a.AnimationId = "rbxassetid://9191822700";
                local humanoid: Humanoid? = char:FindFirstChildWhichIsA("Humanoid");
                if humanoid then
                    anim = humanoid:LoadAnimation(a);
                    anim:Play();
                end;
            else
                if conn then conn:Disconnect(); conn = nil; end;
                if anim then anim:Stop(); anim = nil; end;
                if asset then asset:Destroy(); asset = nil; end;
            end;
            return;
        end;
    })
end)

velo.run(function()
    local Viewmodel: table = {["Enabled"] = false}
    local Depth: table = {["Value"] = 0.8}
    local Horizontal: table = {["Value"] = 0.8}
    local Vertical: table = {["Value"] = -0.2}
    local NoBob: table = {["Enabled"] = false}
    local Rots: table = {}
    local oldAnim: any, oldC1: any
    local ColorHSV: table = {["Hue"] = 0, ["Sat"] = 0, ["Val"] = 0}
    local MaterialDropdown: table = {["Value"] = "Neon"}
    local Mode: table = {["Value"] = "Normal"}
    local Old: table = {["Custom"] = {}, ["Cam"] = nil, ["Anim"] = nil, ["C1"] = nil}

    local function applyHighlight(part: BasePart, original: Highlight?)
        local highlight: Highlight = original or Instance.new("Highlight")
        highlight["FillColor"] = Color3.fromHSV(ColorHSV["Hue"], ColorHSV["Sat"], ColorHSV["Val"])
        highlight["FillTransparency"] = 0.5
        highlight["OutlineColor"] = Color3.fromHSV(ColorHSV["Hue"], ColorHSV["Sat"], ColorHSV["Val"])
        highlight["OutlineTransparency"] = 0.5
        highlight["DepthMode"] = Enum.HighlightDepthMode.AlwaysOnTop
        highlight["Parent"] = part
        table.insert(Old["Custom"], highlight)
    end

    local function applyClassic(part: BasePart)
	local mesh:SpecialMesh? = part:FindFirstChildOfClass("SpecialMesh");
	if mesh then
	    mesh["TextureId"] = "";
	end;
	part["Material"] = Enum.Material[MaterialDropdown["Value"] or "Neon"];
	part["Color"] = Color3.fromHSV(ColorHSV["Hue"], ColorHSV["Sat"], ColorHSV["Val"]);
    end;

    local function Main()
        local viewmodel: Viewmodel? = gameCamera:FindFirstChild("Viewmodel");
        if not viewmodel then return; end;

        for _, hl in next, Old["Custom"] do
            pcall(function() hl:Destroy() end);
        end;
        table.clear(Old["Custom"])

		for _, part in next, viewmodel:GetDescendants() do
			if part:IsA("BasePart") then
				if Mode["Value"] == "Normal" then
					applyHighlight(part);
					if ColorHSV["Val"] > 0 then
						if part:IsA("MeshPart") then
							part["TextureID"] = "";
							part["Material"] = Enum.Material[MaterialDropdown["Value"] or "Neon"];
						elseif part:IsA("Part") then
							local mesh: SpecialMesh? = part:FindFirstChildOfClass("SpecialMesh");
							if mesh then mesh["TextureId"] = ""; end;
							part["Material"] = Enum.Material[MaterialDropdown["Value"] or "Neon"];
						end;
					end;
				else
					applyClassic(part);
				end;
			end;
		end;
    end;

    Viewmodel = vape.Legit:CreateModule({
        ["Name"] = "Viewmodel",
        ["Function"] = function(callback: boolean)
            local viewmodel: Viewmodel? = gameCamera:FindFirstChild("Viewmodel");
            if callback then
                Old["Cam"] = viewmodel
                oldAnim = bedwars["ViewmodelController"]["playAnimation"]
                oldC1 = viewmodel and viewmodel["RightHand"]["RightWrist"]["C1"] or CFrame.identity

                if NoBob["Enabled"] then
                    bedwars["ViewmodelController"]["playAnimation"] = function(self, animtype, ...)
                        if bedwars["AnimationType"] and animtype == bedwars["AnimationType"]["FP_WALK"] then return; end;
                        return oldAnim(self, animtype, ...);
                    end;
                end;

                bedwars["InventoryViewmodelController"]:handleStore(bedwars["Store"]:getState());

                if viewmodel then
                    viewmodel["RightHand"]["RightWrist"]["C1"] = oldC1 * CFrame.Angles(
                        math.rad(Rots[1]["Value"]),
                        math.rad(Rots[2]["Value"]),
                        math.rad(Rots[3]["Value"])
                    );
                end;

                local vmCtrl: any = lplr["PlayerScripts"]["TS"]["controllers"]["global"]["viewmodel"]["viewmodel-controller"];
                vmCtrl:SetAttribute("ConstantManager_DEPTH_OFFSET", -Depth["Value"]);
                vmCtrl:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", Horizontal["Value"]);
                vmCtrl:SetAttribute("ConstantManager_VERTICAL_OFFSET", Vertical["Value"]);

                Main();
            else
                if oldAnim then
                    bedwars["ViewmodelController"]["playAnimation"] = oldAnim;
                    oldAnim = nil;
                end;
                if viewmodel then
                    viewmodel["RightHand"]["RightWrist"]["C1"] = oldC1;
                end;
                bedwars["InventoryViewmodelController"]:handleStore(bedwars["Store"]:getState());
                local vmCtrl: any = lplr["PlayerScripts"]["TS"]["controllers"]["global"]["viewmodel"]["viewmodel-controller"];
                vmCtrl:SetAttribute("ConstantManager_DEPTH_OFFSET", 0);
                vmCtrl:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0);
                vmCtrl:SetAttribute("ConstantManager_VERTICAL_OFFSET", 0);

                for _, hl in next, Old["Custom"] do
                    pcall(function() hl:Destroy() end);
                end;
                table.clear(Old["Custom"]);
                Old["Cam"] = nil;
            end;
        end,
        ["Tooltip"] = "Changes the viewmodel animations and color"
    })
    NoBob = Viewmodel:CreateToggle({
        ["Name"] = "No Bobbing",
        ["Default"] = true,
        ["Function"] = function()
            if Viewmodel["Enabled"] then
                Viewmodel["ToggleButton"]();
                Viewmodel["ToggleButton"]();
            end;
        end;
    })
    Depth = Viewmodel:CreateSlider({
        ["Name"] = "Depth",
        ["Min"] = 0,
        ["Max"] = 2,
        ["Default"] = 0.8,
        ["Decimal"] = 10,
        ["Function"] = function(val)
            if Viewmodel["Enabled"] then
                lplr["PlayerScripts"]["TS"]["controllers"]["global"]["viewmodel"]["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -val);
            end;
        end;
    })
    Horizontal = Viewmodel:CreateSlider({
        ["Name"] = "Horizontal",
        ["Min"] = 0,
        ["Max"] = 2,
        ["Default"] = 0.8,
        ["Decimal"] = 10,
        ["Function"] = function(val)
            if Viewmodel["Enabled"] then
                lplr["PlayerScripts"]["TS"]["controllers"]["global"]["viewmodel"]["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", val);
            end;
        end;
    })
    Vertical = Viewmodel:CreateSlider({
        ["Name"] = "Vertical",
        ["Min"] = -0.2,
        ["Max"] = 2,
        ["Default"] = -0.2,
        ["Decimal"] = 10,
        ["Function"] = function(val)
            if Viewmodel["Enabled"] then
                lplr["PlayerScripts"]["TS"]["controllers"]["global"]["viewmodel"]["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", val);
            end;
        end;
    })
    ColorHSV = Viewmodel:CreateColorSlider({
        ["Name"] = "Color",
        ["Darker"] = true,
        ["DefaultOpacity"] = 0.5,
        ["Function"] = function(h, s, v, o)
            ColorHSV["Hue"] = h
            ColorHSV["Sat"] = s
            ColorHSV["Val"] = v
            if Viewmodel["Enabled"] then
                Main();
            end;
        end;
    })
    MaterialDropdown = Viewmodel:CreateDropdown({
        ["Name"] = "Material",
        ["List"] = GetItems("Material"),
        ["Default"] = "Neon",
        ["HoverText"] = "Material to add to the viewmodel.",
        ["Function"] = function()
            if Viewmodel["Enabled"] then
                Main();
            end;
        end;
    })
    Mode = Viewmodel:CreateDropdown({
        ["Name"] = "Color Mode",
        ["List"] = {"Normal", "Classic"},
        ["Default"] = "Normal",
        ["HoverText"] = "Choose how color is applied to the viewmodel",
        ["Function"] = function()
            if Viewmodel["Enabled"] then
                Main();
            end;
        end;
    })
    for _, name in next, {"Rotation X", "Rotation Y", "Rotation Z"} do
        table.insert(Rots, Viewmodel:CreateSlider({
            ["Name"] = name,
            ["Min"] = 0,
            ["Max"] = 360,
            ["Function"] = function(val)
                if Viewmodel["Enabled"] then
                    local vm: Viewmodel? = gameCamera:FindFirstChild("Viewmodel");
                    if vm then
                        vm["RightHand"]["RightWrist"]["C1"] = oldC1 * CFrame.Angles(
                            math.rad(Rots[1]["Value"]),
                            math.rad(Rots[2]["Value"]),
                            math.rad(Rots[3]["Value"])
                        );
                    end;
                end;
            end;
        }));
    end;
end)

--[[


██╗░░░██╗███████╗██╗░░░░░░█████╗░░█████╗░██╗████████╗██╗░░░██╗
██║░░░██║██╔════╝██║░░░░░██╔══██╗██╔══██╗██║╚══██╔══╝╚██╗░██╔╝
╚██╗░██╔╝█████╗░░██║░░░░░██║░░██║██║░░╚═╝██║░░░██║░░░░╚████╔╝░
░╚████╔╝░██╔══╝░░██║░░░░░██║░░██║██║░░██╗██║░░░██║░░░░░╚██╔╝░░
░░╚██╔╝░░███████╗███████╗╚█████╔╝╚█████╔╝██║░░░██║░░░░░░██║░░░
░░░╚═╝░░░╚══════╝╚══════╝░╚════╝░░╚════╝░╚═╝░░░╚═╝░░░░░░╚═╝░░░

	- The Velocity Custom Modules starts here.
	- reformatted and fixed by: Copium
]]

velo.run(function()
        local custom_armour: table = {};
        local custom_armour_c: table = {};
        local custom_armour_b: table = {};
        local custom_armour_h: table = {};
        local custom_armour_p: table = {};
        hl = function(x)
                for _, v in next, x:GetDescendants() do
                        if v:IsA('Highlight') and v.Name == 'Rainbow' then
                                return true;
                        end;
                end;
                return false;
        end;
        custom_armour = vape.Categories.Velocity:CreateModule({
                ["Name"] ='CustomArmour',
                ["HoverText"] = 'Customizes the color of your armour.',
                ["Function"] = function(callback: boolean): void
                        if callback then
                                local ca = {};
                                ca.__index = ca;
                                function ca.n(a : Number, b : Number, c : Number, d : Number, e : Boolean, f : Boolean, g : Boolean)
                                        local self = setmetatable({}, ca);
                                        self.a = a;
                                        self.b = b;
                                        self.c = c;
                                        self.d = d;
                                        self.e = e;
                                        self.f = f;
                                        self.g = g;
                                        return self;
                                end;
                                function ca:s()
                                        local a = self.a;
                                        local b = self.b;
                                        local c = self.c;
                                        local d = self.d;
                                        local e = self.e;
                                        local f = self.f;
                                        local g = self.g;
                                        local ca_meta = {
                                                __index = function(self, x)
                                                        if x == 'on' then
                                                                return function()
                                                                        RunLoops:BindToRenderStep('CustomArmour', function()
                                                                                for _, v in next, lplr.Character:GetChildren() do
                                                                                        -- if not hl(v) then
                                                                                                local elelele = v:FindFirstChildOfClass('Highlight')
                                                                                                if not elelele then
                                                                                                        if v.Name:find('boot') and e then
                                                                                                                local h = Instance.new('Highlight');
                                                                                                                h.Parent = v;
                                                                                                                h.DepthMode = 'Occluded';
                                                                                                                h["Enabled"] = callback;
                                                                                                                h.FillColor = Color3.fromHSV(a, b, c);
                                                                                                                h.FillTransparency = d;
                                                                                                                h.Name ='velo_ca_boots';
                                                                                                                h.OutlineTransparency = 1;
                                                                                                                h.Adornee = v.Handle;
                                                                                                        end;
                                                                                                        if v.Name:find('helmet') and f then
                                                                                                                local h = Instance.new('Highlight');
                                                                                                                h.Parent = v;
                                                                                                                h.DepthMode = 'Occluded';
                                                                                                                h["Enabled"] = callback;
                                                                                                                h.FillColor = Color3.fromHSV(a, b, c);
                                                                                                                h.FillTransparency = d;
                                                                                                                h.Name ='velo_ca_helmet';
                                                                                                                h.OutlineTransparency = 1;
                                                                                                                h.Adornee = v.Handle;
                                                                                                        end;
                                                                                                        if v.Name:find('chestplate') and g then
                                                                                                                local h = Instance.new('Highlight');
                                                                                                                h.Parent = v;
                                                                                                                h.DepthMode = 'Occluded';
                                                                                                                h["Enabled"] = callback;
                                                                                                                h.FillColor = Color3.fromHSV(a, b, c);
                                                                                                                h.FillTransparency = d;
                                                                                                                h.Name ='velo_ca_chestplate';
                                                                                                                h.OutlineTransparency = 1;
                                                                                                                h.Adornee = v.Handle;
                                                                                                        end;
                                                                                                end
                                                                                        -- end;
                                                                                end;
                                                                        end);                                    
                                                                end;
                                                        end;
                                                end;
                                        };
                                        local ca_val = setmetatable({}, ca_meta);
                                        ca_val:on();
                                end;
                                local ca_vd = ca.n(
                                        custom_armour_c["Hue"],
                                        custom_armour_c["Sat"],
                                        custom_armour_c.Val,
                                        custom_armour_t["Value"],
                                        custom_armour_b["Enabled"],
                                        custom_armour_h["Enabled"],
                                        custom_armour_p["Enabled"]
                                );
                                ca_vd:s();
                        else
                                local ca = {};
                                ca.__index = ca;
                                function ca.n()
                                        local self = setmetatable({}, ca);
                                        return self;
                                end;
                                function ca:s()
                                        local ca_meta = {
                                                __index = function(self, x)
                                                        if x == 'on' then
                                                                return function()
                                                                        --RunLoops:UnbindFromRenderStep('CustomArmour')
                                                                        for _, v in next, lplr.Character:GetDescendants() do
                                                                                if v:IsA('Highlight') then
                                                                                        if v.Name == 'velo_ca_boots' then
                                                                                                v:Destroy();
                                                                                        end;
                                                                                        if v.Name == 'velo_ca_helmet' then
                                                                                                v:Destroy();
                                                                                        end;
                                                                                        if v.Name == 'velo_ca_chestplate' then
                                                                                                v:Destroy();
                                                                                        end;
                                                                                end;
                                                                        end;
                                                                end;
                                                        end;
                                                end;
                                        };
                                        local ca_val = setmetatable({}, ca_meta);
                                        ca_val:on();
                                end;
                                local ca_vd = ca.n();
                                ca_vd:s();
                        end;
                end;
        });
        custom_armour_c = custom_armour:CreateColorSlider({
                ["Name"] ='Color',
                ["Function"] = function(h, s, v)
                        custom_armour_c["Hue"] = h;
                        custom_armour_c["Sat"] = s;
                        custom_armour_c.Val = v;
                        if custom_armour["Enabled"] and lplr.Character then
                                for _, v in next, lplr.Character:GetDescendants() do
                                        if v.Name == 'velo_ca_boots' and v:IsA('Highlight') then
                                                v.FillColor = Color3.fromHSV(custom_armour_c["Hue"], custom_armour_c["Sat"], custom_armour_c.Val);
                                        end;
                                        if v.Name == 'velo_ca_helmet' and v:IsA('Highlight') then
                                                v.FillColor = Color3.fromHSV(custom_armour_c["Hue"], custom_armour_c["Sat"], custom_armour_c.Val);
                                        end;
                                        if v.Name == 'velo_ca_chestplate' and v:IsA('Highlight') then
                                                v.FillColor = Color3.fromHSV(custom_armour_c["Hue"], custom_armour_c["Sat"], custom_armour_c.Val);
                                        end;
                                end;
                        end;
                end;
        });
        custom_armour_t = custom_armour:CreateSlider({
                ["Name"] ='Transparency',
                ["Min"] =0,
                ["Max"] =100,
                ["HoverText"] = 'Transparency of the color.',
                ["Function"] = function() end,
                ["Double"] =100,
                ["Default"] =0;
        });
        custom_armour_b = custom_armour:CreateToggle({
                ["Name"] ='Boots',
                ["HoverText"] = 'Customizes the boots.',
                ["Function"] = function() end,
                ["Default"] =true;
        });
        custom_armour_h = custom_armour:CreateToggle({
                ["Name"] ='Helmet',
                ["HoverText"] = 'Customizes the helmet.',
                ["Function"] = function() end,
                ["Default"] =true;
        });
        custom_armour_p = custom_armour:CreateToggle({
                ["Name"] ='Chestplate',
                ["HoverText"] = 'Customizes the chestplate.',
                ["Function"] = function() end,
                ["Default"] =true;
        });
end);

velo.run(function()
	local RemotesConnect: table = {["Enabled"] = false}
	local RemotesConnectDelay: table = {["Value"] = 10}
	local RemotesConnectParty: table = {["Enabled"] = true}
	local RemotesConnectDragon: table = {["Enabled"] = true}
	local RemotesConnectParty1: table = {["Enabled"] = true}
	local RemotesConnectDragon1: table = {["Enabled"] = true}
	local RemoteConnectMelody: table = {["Enabled"] = true}
	local PartyConnection: any, DragonConnection: any;
	local MelodyExploit: table = {};
	local MelodyTick: number = tick();
	local getguitar = function()
		for i: any, v: any in replicatedStorage.Inventories:GetChildren() do 
			if v["Name"] == lplr["Name"] and v:FindFirstChild('guitar') then 
				return {tool = v.guitar, itemType = 'guitar'};
			end;
		end;
	end;
	RemotesConnect = vape.Categories.Velocity:CreateModule({
		["Name"] ='RemotesConnect',
        	["HoverText"] = 'Spams remotes.',
		["Function"] = function(callback: boolean): void
			if callback then
				task.spawn(function()
					pcall(function()
						repeat task.wait()
							if RemoteConnectMelody["Enabled"] then
								if isAlive(lplr, true) and tick() > MelodyTick and getguitar() and lplr.Character:GetAttribute('Health') < lplr.Character:GetAttribute('MaxHealth') then 
									bedwars.Client:Get('PlayGuitar'):SendToServer({healTarget = lplr});
									bedwars.Client:Get('StopPlayingGuitar'):SendToServer();
									melodytick = tick() + 0.45;
								end;
								task.wait();
							end;
							if RemotesConnectParty["Enabled"] then
								bedwars.AbilityController:useAbility('PARTY_POPPER');
							end;
							if RemotesConnectDragon["Enabled"] then
								if RemotesConnectDragon1["Enabled"] then
									DragonConnection = workspace.ChildAdded:Connect(function(x)
										if x:IsA'Model' and x.Name == 'DragonBreath' then
											x:Destroy();
										end;
									end);
								end;
								bedwars.Client:Get('DragonBreath'):SendToServer({player = lplr});
							end;
							task.wait(RemotesConnectDelay["Value"] / 10);
						until not RemotesConnect["Enabled"];
					end);
				end);
			else
				if PartyConnection then
					PartyConnection:Disconnect();
				end;
				if DragonConnection then
					DragonConnection:Disconnect();
				end;
			end
		end,
        	["Default"] =false
	})
	RemotesConnectDelay = RemotesConnect:CreateSlider({
		["Name"] ='Delay',
		["Min"] =0,
		["Max"] =50,
		["HoverText"] = 'Delay to Spam the Remotes',
		["Function"] = function() end,
		["Default"] =10
	})
	RemoteConnectMelody = RemotesConnect:CreateToggle({
		["Name"] ='Melody',
		["HoverText"] = 'Spams the Melody Remote',
		["Function"] = function() end,
		["Default"] =true
	})
	RemotesConnectParty = RemotesConnect:CreateToggle({
		["Name"] ='Party Popper',
		["HoverText"] = 'Spams the Party Popper Remote',
		["Function"] = function() end,
		["Default"] =true
	})
	RemotesConnectDragon = RemotesConnect:CreateToggle({
		["Name"] ='Dragon',
		["HoverText"] = 'Spams the Dragon Breath Remote',
		["Function"] = function() end,
		["Default"] =true
	})
	RemotesConnectDragon1 = RemotesConnect:CreateToggle({
		["Name"] ='Hide Dragon',
		["HoverText"] = 'Hides the Dragon Breath Effect (CS)',
		["Function"] = function() end,
		["Default"] =true
	})
end)

velo.run(function()
    	local shaders: table = {};
	local shaders_m: table = {};
	local shaders_l: table = {};
	local shaders_t: table = {};
	shaders = vape.Categories.Velocity:CreateModule({
		["Name"] ='Shaders',
        	["HoverText"] = 'Makes the game\'s shaders better.',
		["Function"] = function(callback: boolean): void
			if callback then
				local s: table = {};
				s.__index = s;
				function s.new(a : Number, b : Boolean, c : Boolean, d : Number)
					local self = setmetatable({}, s);
					self.a = a;
					self.b = b;
					self.c = c;
					self.d = d;
					return self;
				end;
				function s:start()
					local a = self.a;
					local b = self.b;
					local c = self.c;
					local d = self.d;
					local s_meta = {
						__index = function(self, x)
							self.r = workspace.Terrain;
							if x == 'on' then
								return function()
									task.spawn(function()
										if a == 'Realistic' then
											if b then
												local color_correction = Instance.new('ColorCorrectionEffect');
												local sunRays = Instance.new('SunRaysEffect');
												local blur = Instance.new('BlurEffect');
												local sky = Instance.new('Sky');
												local atmosphere = Instance.new('Atmosphere');
												local clouds = Instance.new('Clouds');
												for _, v in next, lightingService:GetChildren() do
													if v:IsA('PostEffect') then
														v:Destroy();
													elseif v:IsA('Sky') or v:IsA('Atmosphere') then
														v:Destroy();
													end;
												end;
												lightingService.Brightness = d + 1;
												lightingService.EnvironmentDiffuseScale = d + 0.2;
												lightingService.EnvironmentSpecularScale = d + 0.82;
												sunRays.Parent = lightingService;
												atmosphere.Parent = lightingService;
												sky.Parent = lightingService;
												blur.Size = d + 3.921;
												blur.Parent = lightingService;
												color_correction.Parent = lightingService;
												color_correction.Saturation = d + 0.092;
												clouds.Parent = self.r;
												clouds.Cover = d + 0.4;									
											end;
											if c then
												self.r.WaterTransparency = d + 1;
												self.r.WaterReflectance = d + 1;
											end;
										else
											if b then
												local blur: BlurEffect = Instance.new('BlurEffect', lightingService);
												local color: ColorCorrectionEffect = Instance.new('ColorCorrectionEffect', lightingService);
												local clouds: Clouds = Instance.new('Clouds', self.r);
												local sun: SunRaysEffect = Instance.new('SunRaysEffect', lightingService);
												local sky: Sky = Instance.new('Sky', lightingService);
												local atmosphere: Atmosphere = Instance.new('Atmosphere', lightingService);
												for _, v in next, lightingService:GetChildren() do
													if v:IsA('PostEffect') or v:IsA('Sky') or v:IsA('Atmosphere') then
														v:Destroy();
													end;
												end;
												blur.Size = d + 3.9;
												color.Saturation = d + 0.09;
												clouds.Cover = d + 0.4;
												lightingService.Brightness = d + 1;
												lightingService.EnvironmentDiffuseScale = d + 0.2;
												lightingService.EnvironmentSpecularScale = d + 0.8;
											end;
										end;
										if c then
											self.r.WaterTransparency = d + 1;
											self.r.WaterReflectance = d + 1;
										end;
									end);
								end;
							end;
						end;
					};
					local s_val = setmetatable({}, s_meta);
					s_val:on();
				end;
				local s_vd = s.new(
					shaders_m["Value"],
					shaders_l["Enabled"],
					shaders_t["Enabled"], 0
				);
				s_vd:start();
			end
		end,
        	["Default"] = false,
        	["ExtraText"] = function()
            		return shaders_m["Value"];
        	end;
	})
	shaders_m = shaders:CreateDropdown({
		["Name"] ='Mode',
		["List"] = {
			'Realistic',
			'Clean'
		},
		["Default"] ='Realistic',
		["HoverText"] = 'Mode to render the shaders.',
		["Function"] = function() end
	})
	shaders_l = shaders:CreateToggle({
		["Name"] ='Lighting',
		["HoverText"] = 'Applies changes to the lighting.',
		["Function"] = function() end,
		["Default"] =true
	})
	shaders_t = shaders:CreateToggle({
		["Name"] ='Terrain',
		["HoverText"] = 'Applies changes to the terrain.',
		["Function"] = function() end,
		["Default"] =true
	})
end)

velo.run(function()
	local CustomClouds: table = {["Enabled"] = false}
    	local Material: table = {["Value"] = "Neon"}
	local Color: table = {
		["Hue"] = 0,
		["Sat"] = 0,
		["Value"] = 0
	};
	local Trans: table = {["Value"] = 0}
    	local Old: table = {["Clouds"] = workspace:FindFirstChild("Clouds"):GetChildren()}
	CustomClouds = vape.Categories.Velocity:CreateModule({
		["Name"] = "CustomClouds",
        	["HoverText"] = HoverText("Customizes the clouds."),
		["Function"] = function(callback: boolean): void
			if callback then
				task.spawn(function()
					for _, v in next, Old["Clouds"] do
						if v:IsA("Part") then
							v["Transparency"] = Trans["Value"] / 100;
							v["Color"] = Color3["fromHSV"](Color["Hue"], Color["Sat"], Color["Value"]);
                            				v["Material"] = Enum["Material"][Material["Value"]];
						end;
					end;
				end);
			else
				task.spawn(function()
					for _, v in next, Old["Clouds"] do
						if v:IsA("Part") then
							v["Transparency"] = 0;
							v["Color"] = Color3["fromRGB"](255, 255, 255);
							v["Material"] = Enum["Material"]["SmoothPlastic"];
						end;
					end;
				end);
			end;
		end,
        	["Default"] = false,
        	["ExtraText"] = function()
            		return Material["Value"];
        	end;
	})
    	Material = CustomClouds:CreateDropdown({
		["Name"] = "Material",
		["List"] = GetItems("Material"),
        	["Default"] = "Neon",
		["HoverText"] = HoverText("Material of the clouds."),
		["Function"] = function(val)
			if CustomClouds["Enabled"] then
                		task.spawn(function()
					for _, v in next, Old["Clouds"] do
						if v:IsA("Part") then
				            		v["Material"] = Enum["Material"][val];
                        			end;
                    			end;
               		 	end);
			end;
		end;
	})
	Color = CustomClouds:CreateColorSlider({
		["Name"] = "Color",
        	["HoverText"] = HoverText("Color of the clouds."),
		["Function"] = function()
			if CustomClouds["Enabled"] then
                		task.spawn(function()
					for _, v in next, Old["Clouds"] do
						if v:IsA("Part") then
				            		v["Color"] = Color3["fromHSV"](Color["Hue"], Color["Sat"], Color["Value"]);
                        			end;
                    			end;
                		end);
			end;
		end;
	})
	Trans = CustomClouds:CreateSlider({
		["Name"] = "Transparency",
		["Min"] = 0,
		["Max"] = 100,
        	["HoverText"] = HoverText("Transparency of the clouds."),
		["Function"] = function(val)
			if CustomClouds["Enabled"] then
               			task.spawn(function()
					for _, v in next, Old["Clouds"] do
						if v:IsA("Part") then
				            		v["Transparency"] = val / 100;
                        			end;
                    			end;
                		end);
			end;
		end,
        	["Default"] = 0
	})
end)

velo.run(function()
	local NoNameTag: table = {["Enabled"] = false};
	NoNameTag = vape.Categories.Velocity:CreateModule({
		["Name"] ='NoNameTag',
        	["HoverText"] = 'Removes your NameTag.',
		["Function"] = function(callback: boolean): void
			if callback then
				RunLoops:BindToHeartbeat('NoNameTag', function()
					pcall(function()
						lplr.Character.Head.Nametag:Destroy();
					end);
				end);
			else
				RunLoops:UnbindFromHeartbeat('NoNameTag');
			end;
		end,
        	["Default"] =false
	})
end)

velo.run(function()
    	local FeedRemover: table = {["Enabled"] = false};
	local function SetFeed(Boolean: boolean): void
		local suc: boolean, res: string? = pcall(function()
			lplr["PlayerGui"]["KillFeedGui"]["Enabled"] = Boolean;
		end);
		if not suc then
			repeat task.wait(0) until lplr["PlayerGui"]["KillFeedGui"];
			lplr["PlayerGui"]["KillFeedGui"]["Enabled"] = Boolean;
		end;
	end;
	FeedRemover = vape.Categories.Velocity:CreateModule({
		["Name"] = "FeedRemover",
        	["HoverText"] = HoverText("Removes the kill feed interface."),
		["Function"] = function(callback: boolean): void
			if callback then
				SetFeed(false);
			else
				SetFeed(true);
			end;
		end,
        	["Default"] = false
	})
end)

velo.run(function()
	do
		nan = function(x)
			return x == x;
		end;
		local continue = nan(gameCamera:ScreenPointToRay(0, 0).Origin.x);
		while not continue do
			runService.RenderStepped:wait();
			continue = nan(gameCamera:ScreenPointToRay(0, 0).Origin.x);
		end;
	end;
	local binds: table = {};
	local root: Folder = Instance.new('Folder');
	root.Parent = gameCamera;
	root.Name ='neon';
	local gen_uid;
	do
		local id = 0;
		gen_uid = function()
			id += 1;
			return 'neon::' .. tostring(id);
		end;
	end;
	local draw_qd;
	do
		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt;
		local sz = 0.2;
		draw_tr = function(v1, v2, v3, p0, p1)
			local s1 = (v1 - v2).Magnitude;
			local s2 = (v2 - v3).Magnitude;
			local s3 = (v3 - v1).Magnitude;
			local smax =max(s1, s2, s3);
			local A, B, C;
			if s1 == smax then
				A, B, C = v1, v2, v3;
			elseif s2 == smax then
				A, B, C = v2, v3, v1;
			elseif s3 == smax then
				A, B, C = v3, v1, v2;
			end;
			local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z ) / (A - B).Magnitude;
			local perp = sqrt((C - A).Magnitude ^ 2 - para * para);
			local dif_para = (A - B).Magnitude - para;
			local st = CFrame.new(B, A);
			local za = CFrame.Angles(pi / 2, 0, 0);
			local cf0 = st;
			local Top_Look = (cf0 * za).LookVector;
			local Mid_Point = A + CFrame.new(A, B).LookVector * para;
			local Needed_Look = CFrame.new(Mid_Point, C).LookVector;
			local dot = Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z;
			local ac = CFrame.Angles(0, 0, acos(dot));
			cf0 *= ac;
			if ((cf0 * za).LookVector - Needed_Look).Magnitude > 0.01 then
				cf0 = cf0 * CFrame.Angles(0, 0, -2 * acos(dot));
			end;
			cf0 = cf0 * CFrame.Angles(0, perp / 2, -(dif_para + para / 2));
			local cf1 = st * ac * CFrame.Angles(0, pi, 0)
			if ((cf1 * za).LookVector - Needed_Look).Magnitude > 0.01 then
				cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
			end
			cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2);
			if not p0 then
				p0 = Instance.new('Part');
				p0.FormFactor = 'Custom';
				p0.TopSurface = 0;
				p0.BottomSurface = 0;
				p0.Anchored = true;
				p0.CanCollide = false;
				p0.Material = 'Glass';
				p0.Size = Vec3(sz, sz, sz);
				local mesh = Instance.new('SpecialMesh');
				mesh.Parent = p0;
				mesh.MeshType = 2;
				mesh.Name ='WedgeMesh';
			end;
			p0.WedgeMesh.Scale = Vec3(0, perp / sz, para / sz);
			p0.CFrame = cf0;
			if not p1 then
				p1 = p0:clone();
			end;
			p1.WedgeMesh.Scale = Vec3(0, perp / sz, dif_para / sz);
			p1.CFrame = cf1;
			return p0, p1;
		end;
		draw_qd = function(v1, v2, v3, v4, parts)
			parts[1], parts[2] = draw_tr(v1, v2, v3, parts[1], parts[2]);
			parts[3], parts[4] = draw_tr(v3, v2, v4, parts[3], parts[4]);
		end;
	end;
	bind_fr = function(frame, properties)
		if binds[frame] then
			return binds[frame].parts;
		end;
		local uid = gen_uid();
		local parts = {};
		local f = Instance.new('Folder');
		f.Parent = root;
		f.Name =frame.Name;
		local parents = {};
		do
			add = function(child)
				if child:IsA('GuiObject') then
					parents[#parents + 1] = child;
					add(child.Parent);
				end;
			end;
			add(frame);
		end;
		upd_ort = function(fetchProps)
			local zIndex = 1 - 0.05 * frame.ZIndex;
			local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize;
			local tr, bl = Vec2(br.x, tl.y), Vec2(tl.x, br.y);
			do
				local rot = 0;
				for _, v in next, parents do
					rot += v.Rotation;
				end;
				if rot ~= 0 and rot%180 ~= 0 then
					local mid = tl:lerp(br, 0.5);
					local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot));
					local vec = tl;
					tl = Vec2(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid;
					tr = Vec2(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid;
					bl = Vec22(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid;
					br = Vec2(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid;
				end;
			end;
			draw_qd(
				gameCamera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
				gameCamera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
				gameCamera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
				gameCamera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
				parts
			);
			if fetchProps then
				for _, pt in next, parts do
					pt.Parent = f;
				end;
				for propName, propValue in pairs(properties) do
					for _, pt in pairs(parts) do
						pt[propName] = propValue;
					end;
				end;
			end;
		end;
		upd_ort(true);
		runService:BindToRenderStep(uid, 2000, upd_ort);
		binds[frame] = {
			uid = uid;
			parts = parts;
		};
		return binds[frame].parts;
	end
	local fod: any;
	local ScreenGui2: any;
	local statsModule: table = {}
	statsModule = vape.Categories.Velocity:CreateModule({
		["Name"] ='Stats',
		["HoverText"] = 'An UI that shows your current stats.',
		["Function"] = function(callback: boolean): void
			if callback then
				if store.matchState == 0 then
				    notif('Velocity', 'Waiting for the game to load.', 5, "warn");
				end;
				repeat task.wait() until game:IsLoaded() and store.matchState ~= 0
				local deathCount: number = 0;
				task.spawn(function()
					local canAddDeath: boolean = true;
					repeat 
						if not isAlive(lplr, true) and canAddDeath then
							deathCount += 1
							canAddDeath = false
						elseif isAlive(lplr, true) then
							canAddDeath = true
						end
						task.wait()
					until not statsModule["Enabled"]
				end)
				lplr.PlayerGui.TopBarAppGui.TopBarApp["2"].Visible = false
				ScreenGui2 = Instance.new("ScreenGui")
				local Frame: Frame = Instance.new("Frame")
				local UICorner: UICorner = Instance.new("UICorner")
				local TextLabel: TextLabel = Instance.new("TextLabel")
				local ImageLabel: ImageLabel = Instance.new("ImageLabel")
				local blur: Frame = Instance.new("Frame")
				local Frame_2: Frame = Instance.new("Frame")
				local UICorner_2: UICorner = Instance.new("UICorner")
				local TextLabel_2: TextLabel = Instance.new("TextLabel")
				local TextLabel_3: TextLabel = Instance.new("TextLabel")
				local TextLabel_4: TextLabel = Instance.new("TextLabel")
				local Frame_3: Frame = Instance.new("Frame")
				local UICorner_3: UICorner = Instance.new("UICorner")
				local Frame_4: Frame = Instance.new("Frame")
				local UICorner_4: UICorner = Instance.new("UICorner")
				local TextLabel_5: TextLabel = Instance.new("TextLabel")
				local TextLabel_6: TextLabel = Instance.new("TextLabel")
				local blur_2: Frame = Instance.new("Frame")
				
				ScreenGui2.Parent = game:GetService("CoreGui")
				ScreenGui2.ResetOnSpawn = false
				
				Frame.Parent = ScreenGui2
				Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				Frame.BackgroundTransparency = 0.200
				-- Frame.Position = UDim2.new(0.00792682916, 0, 0.0160493832, 0)
				Frame.Position = UDim2.new(0.00792682916, 0, 0.3, 0)
				Frame.Size = UDim2.new(0, 256, 0, 45)
				
				UICorner.Parent = Frame
				
				TextLabel.Parent = Frame
				TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.Position = UDim2.new(0.19921875, 0, 0.355555564, 0)
				TextLabel.Size = UDim2.new(0, 139, 0, 13)
				TextLabel.Font = Enum.Font.GothamBlack
				TextLabel.Text = "Velocity"
				TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.TextScaled = true
				TextLabel.TextSize = 14.000
				TextLabel.TextWrapped = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				
				ImageLabel.Parent = Frame
				ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageLabel.BackgroundTransparency = 1.000
				ImageLabel.Position = UDim2.new(0.0625, 0, 0.266666681, 0)
				ImageLabel.Size = UDim2.new(0, 20, 0, 20)
				ImageLabel.Image = "rbxassetid://14314898887"
				
				blur.Name ="blur"
				blur.Parent = Frame
				blur.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				blur.BackgroundTransparency = 1.000
				blur.BorderColor3 = Color3.fromRGB(0, 0, 0)
				blur.BorderSizePixel = 0
				blur.Position = UDim2.new(0.03125, 0, 0.13333334, 0)
				blur.Size = UDim2.new(0, 240, 0, 33)
				
				Frame_2.Parent = ScreenGui2
				Frame_2.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				Frame_2.BackgroundTransparency = 0.200
				Frame_2.Position = UDim2.new(0.00792682916, 0, 0.37, 0)
				Frame_2.Size = UDim2.new(0, 256, 0, 132)
				
				UICorner_2.Parent = Frame_2
				
				TextLabel_2.Parent = Frame_2
				TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_2.BackgroundTransparency = 1.000
				TextLabel_2.Position = UDim2.new(0.0625, 0, 0.121802919, 0)
				TextLabel_2.Size = UDim2.new(0, 186, 0, 13)
				TextLabel_2.Font = Enum.Font.GothamBlack
				TextLabel_2.Text = "SESSION INFORMATION"
				TextLabel_2.TextColor3 = Color3.fromRGB(94, 94, 94)
				TextLabel_2.TextScaled = true
				TextLabel_2.TextSize = 14.000
				TextLabel_2.TextWrapped = true
				TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left
				
				TextLabel_3.Parent = Frame_2
				TextLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_3.BackgroundTransparency = 1.000
				TextLabel_3.Position = UDim2.new(0.0625, 0, 0.329350114, 0)
				TextLabel_3.Size = UDim2.new(0, 186, 0, 19)
				TextLabel_3.Font = Enum.Font.GothamBlack
				TextLabel_3.Text = lplr.PlayerGui.TopBarAppGui.TopBarApp["2"]["5"].ContentText
				TextLabel_3.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_3.TextScaled = true
				TextLabel_3.TextSize = 14.000
				TextLabel_3.TextWrapped = true
				TextLabel_3.TextXAlignment = Enum.TextXAlignment.Left
				
				TextLabel_4.Parent = Frame_2
				TextLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_4.BackgroundTransparency = 1.000
				TextLabel_4.Position = UDim2.new(0.111000001, 0, 0.470999986, 0)
				TextLabel_4.Size = UDim2.new(0, 186, 0, 12)
				TextLabel_4.Font = Enum.Font.GothamMedium
				TextLabel_4.Text = "TIME PLAYED"
				TextLabel_4.TextColor3 = Color3.fromRGB(106, 106, 106)
				TextLabel_4.TextScaled = true
				TextLabel_4.TextSize = 14.000
				TextLabel_4.TextWrapped = true
				TextLabel_4.TextXAlignment = Enum.TextXAlignment.Left
				
				Frame_3.Parent = Frame_2
				Frame_3.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
				Frame_3.Position = UDim2.new(0, 17, 0.497999996, 0)
				Frame_3.Size = UDim2.new(0, 5, 0, 5)
				
				UICorner_3.CornerRadius = UDim.new(1, 0)
				UICorner_3.Parent = Frame_3
				
				Frame_4.Parent = Frame_2
				Frame_4.BackgroundColor3 = Color3.fromRGB(255, 33, 33)
				Frame_4.Position = UDim2.new(0, 17, 0.814999998, 0)
				Frame_4.Size = UDim2.new(0, 5, 0, 5)
				
				UICorner_4.CornerRadius = UDim.new(1, 0)
				UICorner_4.Parent = Frame_4
				
				TextLabel_5.Parent = Frame_2
				TextLabel_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_5.BackgroundTransparency = 1.000
				TextLabel_5.Position = UDim2.new(0.111000001, 0, 0.788999975, 0)
				TextLabel_5.Size = UDim2.new(0, 186, 0, 12)
				TextLabel_5.Font = Enum.Font.GothamMedium
				TextLabel_5.Text = "DEATHS"
				TextLabel_5.TextColor3 = Color3.fromRGB(106, 106, 106)
				TextLabel_5.TextScaled = true
				TextLabel_5.TextSize = 14.000
				TextLabel_5.TextWrapped = true
				TextLabel_5.TextXAlignment = Enum.TextXAlignment.Left
				
				TextLabel_6.Parent = Frame_2
				TextLabel_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_6.BackgroundTransparency = 1.000
				TextLabel_6.Position = UDim2.new(0.0625, 0, 0.646102548, 0)
				TextLabel_6.Size = UDim2.new(0, 186, 0, 19)
				TextLabel_6.Font = Enum.Font.GothamBlack
				TextLabel_6.Text = deathCount
				TextLabel_6.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_6.TextScaled = true
				TextLabel_6.TextSize = 14.000
				TextLabel_6.TextWrapped = true
				TextLabel_6.TextXAlignment = Enum.TextXAlignment.Left
				
				blur_2.Name ="blur"
				blur_2.Parent = Frame_2
				blur_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				blur_2.BackgroundTransparency = 1.000
				blur_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
				blur_2.BorderSizePixel = 0
				blur_2.Position = UDim2.new(0.03125, 0, 0.0454545468, 0)
				blur_2.Size = UDim2.new(0, 241, 0, 120)
				
				fod = Instance.new("DepthOfFieldEffect", game:GetService("Lighting"))
				fod.Enabled = true
				fod.FarIntensity = 0
				fod.FocusDistance = 51.6
				fod.InFocusRadius = 50
				fod.NearIntensity = 1
				
				task.spawn(function()
					repeat
						task.wait()
						TextLabel_6.Text = deathCount
						TextLabel_3.Text = lplr.PlayerGui.TopBarAppGui.TopBarApp["2"]["5"].ContentText
					until not callback
				end)
				
				bind_fr(blur, {
					Transparency = 0.98;
					BrickColor = BrickColor.new("Institutional white");
				})
				bind_fr(blur_2, {
					Transparency = 0.98;
					BrickColor = BrickColor.new("Institutional white");
				}) 
			else
				ScreenGui2:Destroy()      
				lplr.PlayerGui.TopBarAppGui.TopBarApp["2"].Visible = true;      
			end
		end
	})
end)

velo.run(function()
	local Card: table = {["Enabled"] = false};
	local CardGradient: table = {["Enabled"] = false};
	local Highlight: table = {};
	local HighlightColor: table = {};
	local CardColor: table = {};
	local CardColor2: table = {};
	local Object: table = {};
	local Round: table = {};
	local Font: table = {};
	local FontSetting: table = {["Value"] = Enum.Font.SourceSans};
	local CardFunc: () -> () = function()
		if not lplr.PlayerGui:FindFirstChild('QueueApp') and Card["Enabled"] then 
			return;
		end;
		local card: Frame = lplr.PlayerGui.QueueApp:WaitForChild('1', math.huge);
		local corners: UICorner = card:FindFirstChildOfClass('UICorner') or Instance.new('UICorner', card);
		corners.CornerRadius = UDim.new(0, Round["Value"]);
		card.BackgroundColor3 = Color3.fromHSV(CardColor["Hue"], CardColor["Sat"], CardColor["Value"]);
        	if not table.find(Object, corners) then
            		table.insert(Object, corners);
        	end;

		if Font["Enabled"] then
			for i: any, v: any in next, card:GetDescendants() do
				if v:IsA("TextLabel") or v:IsA("TextButton") then
					v.Font = FontSetting["Value"];
				end;
			end;
		end;
		if Highlight["Enabled"] then 
			local stroke: UIStroke? = card:FindFirstChildOfClass('UIStroke') or Instance.new('UIStroke', card);
			stroke.Thickness = 1.7;
			stroke.Color = Color3.fromHSV(HighlightColor["Hue"], HighlightColor["Sat"], HighlightColor["Value"]);
			if not table.find(Object, stroke) then
				table.insert(Object, stroke);
			end;
		else
			local stroke: UIStroke? = card:FindFirstChildOfClass("UIStroke") or Instance.new('UIStroke', card);
            		if stroke then
                		stroke:Destroy();
            		end;
		end;
		if CardGradient["Enabled"] then
			card.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			local gradient: UIGradient = card:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', card);
			gradient.Color = ColorSequence.new({
				[1] = ColorSequenceKeypoint.new(0, Color3.fromHSV(CardColor["Hue"], CardColor["Sat"], CardColor["Value"])), 
				[2] = ColorSequenceKeypoint.new(1, Color3.fromHSV(CardColor2["Hue"], CardColor2["Sat"], CardColor2["Value"]))
			});
			if not table.find(Object, gradient) then
				table.insert(Object, gradient);
			end;
		end;
	end;
	Card = vape.Legit:CreateModule({
		["Name"] = 'QueueCardVisuals',
		["Function"] = function(callback: boolean): void
			if callback then 
				pcall(CardFunc);
				table.insert(Card.Connections, lplr.PlayerGui.ChildAdded:Connect(CardFunc));
			else
                		for _, x in next, Object do
                    			if x and x.Destroy then
                        			x:Destroy();
                    			end;
                		end;
                		Object = {}
                		for _, v in next, Card.Connections do
                    			if v.Disconnect then
                        			v:Disconnect();
                   			end;
                		end;
                		Card.Connections = {};
            		end;
		end;
	});
	CardGradient = Card:CreateToggle({
		["Name"] = 'Gradient',
		["Function"] = function(callback: boolean): void
			pcall(function() CardColor2.Object.Visible = callback end);
		end;
	});
	Round = Card:CreateSlider({
		["Name"] = 'Rounding',
		["Min"] = 0,
		["Max"] = 20,
		["Default"] = 4,
		["Function"] = function(value: number): ()
			for i: number, v: UICorner? in Object do 
				if v.ClassName == 'UICorner' then 
					v.CornerRadius = value;
				end;
			end;
		end;
	})
	CardColor = Card:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = function()
			task.spawn(pcall, CardFunc);
		end;
	});
	CardColor2 = Card:CreateColorSlider({
		["Name"] = 'Color 2',
		["Function"] = function()
			task.spawn(pcall, CardFunc);
		end;
	});
	Highlight = Card:CreateToggle({
		["Name"] = 'Highlight',
		["Function"] = function()
			task.spawn(pcall, CardFunc);
		end;
	});
	HighlightColor = Card:CreateColorSlider({
		["Name"] = 'Highlight Color',
		["Function"] = function()
			task.spawn(pcall, CardFunc);
		end;
	});
	Font = Card:CreateToggle({
		["Name"] ='Font',
		["HoverText"] = 'custom fonts.',
		["Function"] = function(callback: boolean): void 
			FontSetting.Object.Visible = callback;
		end;
	})
	FontSetting = Card:CreateDropdown({
		["Name"] ="Fonts",
		["List"] = GetItems("Font"),
		["HoverText"] = "Font of the text.",
		["Function"] = function()
			if Card["Enabled"] then
				Card:Toggle();
				Card:Toggle();
			end;
		end;
	});
end);


-- credits to catvape + render + snoopy + lunar + lunarvape
-- IF YOU WANT THEM REMOVED, TELL ME AND I WILL REMOVE
velo.run(function()
    local texture_pack: table = {["Enabled"] = false};
    local texture_pack_color: table = {["Hue"] = 0, ["Sat"] = 0, ["Value"] = 0};
    local texture_pack_m: table = {};
    texture_pack = vape.Categories.Velocity:CreateModule({
        ["Name"] ='TexturePack',
        ["HoverText"] = 'Customizes the texture pack.',
        ["Function"] = function(callback: boolean): void
            if callback then
                if texture_pack_m["Value"] == 'Velocity' then
					task.spawn(function()
						local Players: Players = game:GetService("Players")
						local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
						local Workspace: Workspace = game:GetService("Workspace")
						local objs: any = game:GetObjects("rbxassetid://13988978091")
						local import: any = objs[1]
						import.Parent = game:GetService("ReplicatedStorage")
						local index: table? = {
							{
								name = "wood_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Wood_Sword"),
							},
							{
								name = "stone_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Stone_Sword"),
							},
							{
								name = "iron_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Iron_Sword"),
							},
							{
								name = "diamond_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Diamond_Sword"),
							},
							{
								name = "emerald_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Emerald_Sword"),
							},
							{
								name = "wood_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
								model = import:WaitForChild("Wood_Pickaxe"),
							},
							{
								name = "stone_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
								model = import:WaitForChild("Stone_Pickaxe"),
							},
							{
								name = "iron_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
								model = import:WaitForChild("Iron_Pickaxe"),
							},
							{
								name = "diamond_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
								model = import:WaitForChild("Diamond_Pickaxe"),
							},
							{
								name = "wood_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
								model = import:WaitForChild("Wood_Axe"),
							},
							{
								name = "stone_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
								model = import:WaitForChild("Stone_Axe"),
							},
							{
								name = "iron_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
								model = import:WaitForChild("Iron_Axe"),
							},
							{
								name = "diamond_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-95)),
								model = import:WaitForChild("Diamond_Axe"),
							},
						}
						local func = Workspace.Camera.Viewmodel.ChildAdded:Connect(function(tool)
							if not tool:IsA("Accessory") then
								return
							end
							for _, v in next, index do
								if v.name == tool.Name then
									for _, part in next, tool:GetDescendants() do
										if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
											part.Transparency = 1
										end
									end
									local model = v.model:Clone()
									model.CFrame = tool.Handle.CFrame * v.offset
									model.CFrame = model.CFrame * CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
									model.Parent = tool
									local weld = Instance.new("WeldConstraint")
									weld.Part0 = model
									weld.Part1 = tool.Handle
									weld.Parent = model
									local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
									for _, part in ipairs(tool2:GetDescendants()) do
										if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
											part.Transparency = 1
											if part.Name == "Handle" then
												part.Transparency = 0
											end
										end
									end
								end
							end
						end)
					end)
                elseif texture_pack_m["Value"] == 'Aquarium' then
					task.spawn(function()
						local Players = game:GetService("Players")
						local ReplicatedStorage = game:GetService("ReplicatedStorage")
						local Workspace = game:GetService("Workspace")
						local objs = game:GetObjects("rbxassetid://14217388022")
						local import = objs[1]
						import.Parent = game:GetService("ReplicatedStorage")
						local index = {
						
							{
								name = "wood_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Wood_Sword"),
							},
							
							{
								name = "stone_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Stone_Sword"),
							},
							
							{
								name = "iron_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Iron_Sword"),
							},
							
							{
								name = "diamond_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Diamond_Sword"),
							},
							
							{
								name = "emerald_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Diamond_Sword"),
							},
							
							{
								name = "Rageblade",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Diamond_Sword"),
							},
						}
						local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
							if(not tool:IsA("Accessory")) then return end
							for i,v in pairs(index) do
								if(v.name == tool.Name) then
									for i,v in pairs(tool:GetDescendants()) do
										if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
											v.Transparency = 1
										end
									end
									local model = v.model:Clone()
									model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
									model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
									model.Parent = tool
									local weld = Instance.new("WeldConstraint",model)
									weld.Part0 = model
									weld.Part1 = tool:WaitForChild("Handle")
									local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
									for i,v in pairs(tool2:GetDescendants()) do
										if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
											v.Transparency = 1
										end
									end
									local model2 = v.model:Clone()
									model2.Anchored = false
									model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
									model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
									model2.CFrame *= CFrame.new(0.4,0,-.9)
									model2.Parent = tool2
									local weld2 = Instance.new("WeldConstraint",model)
									weld2.Part0 = model2
									weld2.Part1 = tool2:WaitForChild("Handle")
								end
							end
						end)
					end)
                elseif texture_pack_m["Value"] == 'Ocean' then
					task.spawn(function()
						local Players = game:GetService("Players")
						local ReplicatedStorage = game:GetService("ReplicatedStorage")
						local Workspace = game:GetService("Workspace")
						local objs = game:GetObjects("rbxassetid://14356045010")
						local import = objs[1]
						import.Parent = game:GetService("ReplicatedStorage")
						index = {
							{
								name = "wood_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Wood_Sword"),
							},
							{
								name = "stone_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Stone_Sword"),
							},
							{
								name = "iron_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Iron_Sword"),
							},
							{
								name = "diamond_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Diamond_Sword"),
							},
							{
								name = "emerald_sword",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
								model = import:WaitForChild("Emerald_Sword"),
							}, 
							{
								name = "rageblade",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
								model = import:WaitForChild("Rageblade"),
							}, 
							{
								name = "fireball",
										offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
								model = import:WaitForChild("Fireball"),
							}, 
							{
								name = "telepearl",
										offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
								model = import:WaitForChild("Telepearl"),
							}, 
							{
								name = "wood_bow",
								offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
								model = import:WaitForChild("Bow"),
							},
							{
								name = "wood_crossbow",
								offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
								model = import:WaitForChild("Crossbow"),
							},
							{
								name = "tactical_crossbow",
								offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
								model = import:WaitForChild("Crossbow"),
							},
								{
								name = "wood_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
								model = import:WaitForChild("Wood_Pickaxe"),
							},
							{
								name = "stone_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
								model = import:WaitForChild("Stone_Pickaxe"),
							},
							{
								name = "iron_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
								model = import:WaitForChild("Iron_Pickaxe"),
							},
							{
								name = "diamond_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
								model = import:WaitForChild("Diamond_Pickaxe"),
							},
						{
									
								name = "wood_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
								model = import:WaitForChild("Wood_Axe"),
							},
							{
								name = "stone_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
								model = import:WaitForChild("Stone_Axe"),
							},
							{
								name = "iron_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
								model = import:WaitForChild("Iron_Axe"),
							},
							{
								name = "diamond_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-95)),
								model = import:WaitForChild("Diamond_Axe"),
							},
						
						
						
						}
						local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
							if(not tool:IsA("Accessory")) then return end
							for i,v in pairs(index) do
								if(v.name == tool.Name) then
									for i,v in pairs(tool:GetDescendants()) do
										if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
											v.Transparency = 1
										end
									end
									local model = v.model:Clone()
									model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
									model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
									model.Parent = tool
									local weld = Instance.new("WeldConstraint",model)
									weld.Part0 = model
									weld.Part1 = tool:WaitForChild("Handle")
									local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
									for i,v in pairs(tool2:GetDescendants()) do
										if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
											v.Transparency = 1
										end
									end
									local model2 = v.model:Clone()
									model2.Anchored = false
									model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
									model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
									model2.CFrame *= CFrame.new(.7,0,-.8)
									model2.Parent = tool2
									local weld2 = Instance.new("WeldConstraint",model)
									weld2.Part0 = model2
									weld2.Part1 = tool2:WaitForChild("Handle")
								end
							end
						end)
					end)
                elseif texture_pack_m["Value"] == 'Animated' then
                    task.spawn(function()
                        workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
                            if not tool:IsA("Accessory") then 
                                return 
                            end
                            local handle: any = tool:FindFirstChild("Handle")
                            if handle then
                                if string.find(tool.Name:lower(), 'sword') then
                                    handle.Material = Enum.Material.ForceField
                                    handle.MeshId = "rbxassetid://13471207377"
                                    handle.BrickColor = BrickColor.new("Hot pink")
                                    local outline: Highlight = Instance.new('Highlight')
                                    outline.Adornee = handle 
                                    outline.FillTransparency = 0.5
                                    outline.FillColor = Color3.fromRGB(221, 193, 255) 
                                    outline.OutlineTransparency = 0.2
                                    outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    outline.Parent = handle
                                    local highlight: Highlight = Instance.new('Highlight')
                                    highlight.Adornee = handle 
                                    highlight.FillTransparency = 0.5
                                    highlight.FillColor = Color3.fromHSV(texture_pack_color["Hue"], texture_pack_color["Sat"], texture_pack_color["Value"])
                                    highlight.OutlineTransparency = 0.2
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    highlight.Parent = handle
                                end
                            end
                        end)
                    end)
				elseif texture_pack_m["Value"] == 'DemonSlayer' then
					task.spawn(function()
						local Players = game:GetService("Players")
						local ReplicatedStorage = game:GetService("ReplicatedStorage")
						local Workspace = game:GetService("Workspace")
						local objs = game:GetObjects("rbxassetid://14241215869")
						local import = objs[1]
						import.Parent = ReplicatedStorage
						local index = {
							{
								name = "wood_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Wood_Sword"),
							},	
							{
								name = "stone_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Stone_Sword"),
							},
							{
								name = "iron_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Iron_Sword"),
							},
							{
								name = "diamond_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Diamond_Sword"),
							},
							{
								name = "emerald_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Emerald_Sword"),
							},
							{
								name = "wood_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
								model = import:WaitForChild("Wood_Pickaxe"),
							},
							{
								name = "stone_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
								model = import:WaitForChild("Stone_Pickaxe"),
							},
							{
								name = "iron_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
								model = import:WaitForChild("Iron_Pickaxe"),
							},
							{
								name = "diamond_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(90), math.rad(-95)),
								model = import:WaitForChild("Diamond_Pickaxe"),
							},	
							{
								name = "fireball",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Fireball"),
							},	
							{
								name = "telepearl",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Telepearl"),
							},
							{
								name = "diamond",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
								model = import:WaitForChild("Diamond"),
							},
							{
								name = "iron",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Iron"),
							},
							{
								name = "gold",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Gold"),
							},
							{
								name = "emerald",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
								model = import:WaitForChild("Emerald"),
							},
							{
								name = "wood_bow",
								offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
								model = import:WaitForChild("Bow"),
							},
							{
								name = "wood_crossbow",
								offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
								model = import:WaitForChild("Bow"),
							},
							{
								name = "tactical_crossbow",
								offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
								model = import:WaitForChild("Bow"),
							},
							{
								name = "wood_dao",
								offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
								model = import:WaitForChild("Wood_Sword"),
							},
							{
								name = "stone_dao",
								offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
								model = import:WaitForChild("Stone_Sword"),
							},
							{
								name = "iron_dao",
								offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
								model = import:WaitForChild("Iron_Sword"),
							},
							{
								name = "diamond_dao",
								offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
								model = import:WaitForChild("Diamond_Sword"),
							},
						}
						local func = Workspace.Camera.Viewmodel.ChildAdded:Connect(function(tool)	
							if not tool:IsA("Accessory") then return end	
							for _, v in ipairs(index) do	
								if v.name == tool.Name then		
									for _, part in ipairs(tool:GetDescendants()) do
										if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
											part.Transparency = 1
										end			
									end		
									local model = v.model:Clone()
									model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
									model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
									model.Parent = tool			
									local weld = Instance.new("WeldConstraint", model)
									weld.Part0 = model
									weld.Part1 = tool:WaitForChild("Handle")			
									local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
									for _, part in ipairs(tool2:GetDescendants()) do
										if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
											part.Transparency = 1				
										end			
									end			
									local model2 = v.model:Clone()
									model2.Anchored = false
									model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
									model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
									if v.name:match("rageblade") then
										model2.CFrame *= CFrame.new(0.7, 0, -.7)                           
									elseif v.name:match("sword") or v.name:match("blade") then
										model2.CFrame *= CFrame.new(.2, 0, -.8)
									elseif v.name:match("dao") then
										model2.CFrame *= CFrame.new(.7, 0, -1.3)
									elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
										model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
									elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
										model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
									elseif v.name:match("diamond_pickaxe") then
										model2.CFrame *= CFrame.new(.2, 0, -.26)
									elseif v.name:match("iron") and not v.name:match("iron_pickaxe") then
										model2.CFrame *= CFrame.new(0, -.24, 0)
									elseif v.name:match("gold") then
										model2.CFrame *= CFrame.new(0, .03, 0)
									elseif v.name:match("diamond") or v.name:match("emerald") then
										model2.CFrame *= CFrame.new(0, -.03, 0)
									elseif v.name:match("telepearl") then
										model2.CFrame *= CFrame.new(.1, 0, .1)
									elseif v.name:match("fireball") then
										model2.CFrame *= CFrame.new(.28, .1, 0)
									elseif v.name:match("bow") and not v.name:match("crossbow") then
										model2.CFrame *= CFrame.new(-.2, .1, -.05)
									elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
										model2.CFrame *= CFrame.new(-.5, 0, .05)
									elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
										model2.CFrame *= CFrame.new(-.35, 0, -1.2)
									else
										model2.CFrame *= CFrame.new(.0, 0, -.06)
									end
									model2.Parent = tool2
									local weld2 = Instance.new("WeldConstraint", model)
									weld2.Part0 = model2
									weld2.Part1 = tool2:WaitForChild("Handle")
								end
							end
						end)
					end)
				elseif texture_pack_m["Value"] == 'Glizzy' then
					task.spawn(function()
						local Players = game:GetService("Players")
						local ReplicatedStorage = game:GetService("ReplicatedStorage")
						local Workspace = game:GetService("Workspace")
						local objs = game:GetObjects("rbxassetid://13804645310")
						local import = objs[1]
						import.Parent = game:GetService("ReplicatedStorage")
						
						local index = {
							{
								name = "wood_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Wood_Sword"),
							},
							{
								name = "stone_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Stone_Sword"),
							},
							{
								name = "iron_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Iron_Sword"),
							},
							{
								name = "diamond_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Diamond_Sword"),
							},
							{
								name = "emerald_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
								model = import:WaitForChild("Emerald_Sword"),
							},
							{
								name = "rageblade",
								offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-270)),
								model = import:WaitForChild("Rageblade"),
							},
						}
						
						local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
							if not tool:IsA("Accessory") then return end
							for _,v in pairs(index) do
								if v.name == tool.Name then
									for _,v in pairs(tool:GetDescendants()) do
										if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
											v.Transparency = 1
										end
									end
									local model = v.model:Clone()
									model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
									model.CFrame = model.CFrame * CFrame.Angles(math.rad(0), math.rad(100), math.rad(0))
									model.Parent = tool
									local weld = Instance.new("WeldConstraint", model)
									weld.Part0 = model
									weld.Part1 = tool:WaitForChild("Handle")
									
									local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
									for _,v in pairs(tool2:GetDescendants()) do
										if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
											v.Transparency = 1
										end
									end
									local model2 = v.model:Clone()
									model2.Anchored = false
									model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
									model2.CFrame = model2.CFrame * CFrame.Angles(math.rad(0), math.rad(-105), math.rad(0))
									model2.CFrame = model2.CFrame * CFrame.new(-0.4, 0, -0.10)
									model2.Parent = tool2
									local weld2 = Instance.new("WeldConstraint", model2)
									weld2.Part0 = model2
									weld2.Part1 = tool2:WaitForChild("Handle")
								end
							end
						end)					
					end)
				elseif texture_pack_m["Value"] == 'FirstPack' then
					task.spawn(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/Pack%231"))()  
					end)
				elseif texture_pack_m["Value"] == 'SecondPack' then
					task.spawn(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/Pack%232"))()  
					end)
				elseif texture_pack_m["Value"] == 'ThirdPack' then
					task.spawn(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/Modules/main/TexturePack"))()  
					end)
				elseif texture_pack_m["Value"] == 'FourthPack' then
					task.spawn(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/Pack%234"))()  
					end)
				elseif texture_pack_m["Value"] == 'FifthPack' then
					task.spawn(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/Pack%235"))()  
					end)
				elseif texture_pack_m["Value"] == 'SixthPack' then
					task.spawn(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/Pack%236"))()  
					end)
				elseif texture_pack_m["Value"] == 'SeventhPack' then
					task.spawn(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/Pack%237"))()  
					end)
				elseif texture_pack_m["Value"] == 'EighthPack' then
					task.spawn(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/1024xPack"))()  
					end)
				elseif texture_pack_m["Value"] == 'EgirlPack' then
					task.spawn(function() 	
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/E-Girl"))()  		             
					end)
				elseif texture_pack_m["Value"] == 'CottonCandy' then
					task.spawn(function() 
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/CottonCandy256x"))()           
					end)
				elseif texture_pack_m["Value"] == 'PrivatePack' then
					task.spawn(function()
						local Players = game:GetService("Players")
						local ReplicatedStorage = game:GetService("ReplicatedStorage")
						local Workspace = game:GetService("Workspace")
						local objs = game:GetObjects("rbxassetid://14161283331")
						local import = objs[1]
						import.Parent = ReplicatedStorage
						local index = {
							{
								name = "wood_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Wood_Sword"),
							},	
							{
								name = "stone_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Stone_Sword"),
							},
							{
								name = "iron_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Iron_Sword"),
							},
							{
								name = "diamond_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Diamond_Sword"),
							},
							{
								name = "emerald_sword",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
								model = import:WaitForChild("Emerald_Sword"),
							},
							{
								name = "rageblade",
								offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
								model = import:WaitForChild("Rageblade"),
							}, 
							{
								name = "wood_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
								model = import:WaitForChild("Wood_Pickaxe"),
							},
							{
								name = "stone_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
								model = import:WaitForChild("Stone_Pickaxe"),
							},
							{
								name = "iron_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(-18033), math.rad(-95)),
								model = import:WaitForChild("Iron_Pickaxe"),
							},
							{
								name = "diamond_pickaxe",
								offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
								model = import:WaitForChild("Diamond_Pickaxe"),
							},	
							{
								name = "wood_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
								model = import:WaitForChild("Wood_Axe"),
							},	
							{
								name = "stone_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
								model = import:WaitForChild("Stone_Axe"),
							},	
							{
								name = "iron_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
								model = import:WaitForChild("Iron_Axe"),
							},	
							{
								name = "diamond_axe",
								offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-95)),
								model = import:WaitForChild("Diamond_Axe"),
							},	
							{
								name = "fireball",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Fireball"),
							},	
							{
								name = "telepearl",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Telepearl"),
							},
							{
								name = "diamond",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Diamond"),
							},
							{
								name = "iron",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Iron"),
							},
							{
								name = "gold",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Gold"),
							},
							{
								name = "emerald",
								offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
								model = import:WaitForChild("Emerald"),
							},
							{
								name = "wood_bow",
								offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
								model = import:WaitForChild("Bow"),
							},
							{
								name = "wood_crossbow",
								offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
								model = import:WaitForChild("Bow"),
							},
							{
								name = "tactical_crossbow",
								offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
								model = import:WaitForChild("Bow"),
							},
						}
						local func = Workspace.Camera.Viewmodel.ChildAdded:Connect(function(tool)	
							if not tool:IsA("Accessory") then return end	
							for _, v in ipairs(index) do	
								if v.name == tool.Name then		
									for _, part in ipairs(tool:GetDescendants()) do
										if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
											part.Transparency = 1
										end			
									end		
									local model = v.model:Clone()
									model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
									model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
									model.Parent = tool			
									local weld = Instance.new("WeldConstraint", model)
									weld.Part0 = model
									weld.Part1 = tool:WaitForChild("Handle")			
									local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
									for _, part in ipairs(tool2:GetDescendants()) do
										if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
											part.Transparency = 1				
										end			
									end			
									local model2 = v.model:Clone()
									model2.Anchored = false
									model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
									model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
									if v.name:match("rageblade") then
										model2.CFrame *= CFrame.new(0.7, 0, -1)                           
									elseif v.name:match("sword") or v.name:match("blade") then
										model2.CFrame *= CFrame.new(.6, 0, -1.1) - Vector3.new(0, 0, -.3)
									elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
										model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
									elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
										model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
									elseif v.name:match("iron") then
										model2.CFrame *= CFrame.new(0, -.24, 0)
									elseif v.name:match("gold") then
										model2.CFrame *= CFrame.new(0, .03, 0)
									elseif v.name:match("diamond") then
										model2.CFrame *= CFrame.new(0, .027, 0)
									elseif v.name:match("emerald") then
										model2.CFrame *= CFrame.new(0, .001, 0)
									elseif v.name:match("telepearl") then
										model2.CFrame *= CFrame.new(.1, 0, .1)
									elseif v.name:match("fireball") then
										model2.CFrame *= CFrame.new(.28, .1, 0)
									elseif v.name:match("bow") and not v.name:match("crossbow") then
										model2.CFrame *= CFrame.new(-.29, .1, -.2)
									elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
										model2.CFrame *= CFrame.new(-.6, 0, 0)
									elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
										model2.CFrame *= CFrame.new(-.5, 0, -1.2)
									else
										model2.CFrame *= CFrame.new(.2, 0, -.2)
									end
									model2.Parent = tool2
									local weld2 = Instance.new("WeldConstraint", model)
									weld2.Part0 = model2
									weld2.Part1 = tool2:WaitForChild("Handle")
								end
							end
						end)            
					end)
				elseif texture_pack_m["Value"] == 'FirstHighResPack' then	
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/512xPack"))()   
					end)
				elseif texture_pack_m["Value"] == 'SecondHighResPack' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/SnoopyOwner/TexturePacks/main/1024xPack"))()   
					end)
				elseif texture_pack_m["Value"] == 'FatCat' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/"..Pack.Value..".lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Simply' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Simply.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'VioletsDreams' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/VioletsDreams.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Enlightened' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Enlightened.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Onyx' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Onyx.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Fury' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Fury.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Wichtiger' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Wichtiger.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Makima' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Makima.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Marin-Kitsawaba' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Marin-Kitsawaba.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Prime' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Prime.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Vile' then	
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Vile.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Devourer' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Devourer.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Acidic' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Acidic.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Moon4Real' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Moon4Real.lua"))()
					end)
				elseif texture_pack_m["Value"] == 'Nebula' then
					task.spawn(function()
						task.wait()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/TexturePacks/refs/heads/main/Nebula.lua"))()
					end)
				else
					local connect: any;
					local pack: any = game:GetObjects("rbxassetid://14027120450");
					local txtpack: any = unpack(pack)
					txtpack.Parent = game:GetService("ReplicatedStorage")
					connect = workspace.Camera.Viewmodel.DescendantAdded:Connect(function(d)
						for i,v in next, txtpack:GetChildren() do
							if v.Name == d.Name then
								for i1,v1 in next, d:GetDescendants() do
									if v1:IsA("Part") or v1:IsA("MeshPart") then
										v1.Transparency = 1
									end
								end
								for i1,v1 in next, lplr.Character:GetChildren() do
									if v1.Name == v.Name then
										for i2,v2 in next, v1:GetDescendants() do
											if v2.Name ~= d.Name then
												if v2:IsA("Part") or v2:IsA("MeshPart") then
													v2.Transparency = 1;
												end;
											end;
										end;
									end;
								end;
								local handle: Handle? = d:FindFirstChild("Handle");
								if handle and handle:IsA("BasePart") then
									local vmmodel: any = v:Clone();
									vmmodel.CFrame = handle.CFrame * CFrame.Angles(math.rad(90), math.rad(-130), 0);
									if d.Name == "rageblade" then
										vmmodel.CFrame = CFrame.Angles(math.rad(-80), math.rad(230), math.rad(10));
									end;
									vmmodel.Parent = d;
									local vmmodelweld: WeldConstraint = Instance.new("WeldConstraint", vmmodel);
									vmmodelweld.Part0 = vmmodel;
									vmmodelweld.Part1 = handle;
									local charPart: any = lplr.Character:FindFirstChild(d.Name);
									local charHandle: any = charPart and charPart:FindFirstChild("Handle");
									if charHandle and charHandle:IsA("BasePart") then
										local charmodel: any = v:Clone();
										charmodel.CFrame = charHandle.CFrame * CFrame.Angles(math.rad(90), math.rad(-130), 0);
										if d.Name == "rageblade" then
											charmodel.CFrame = CFrame.Angles(math.rad(-80), math.rad(230), math.rad(10));
										end;
										charmodel.Anchored = false;
										charmodel.CanCollide = false;
										charmodel.Parent = charPart;
										local charmodelweld: WeldConstraint = Instance.new("WeldConstraint", charmodel);
										charmodelweld.Part0 = charmodel;
										charmodelweld.Part1 = charHandle;
									end;
								end;
							end;
						end;
					end);
				end;
			end;
		end;
    })
    texture_pack_m = texture_pack:CreateDropdown({
        ["Name"] ='Mode',
        ["List"] = {
            'Velocity',
			"FirstPack", 
			"SecondPack", 
			"ThirdPack", 
			"FourthPack", 
			"FifthPack", 
			"SixthPack", 
			"SeventhPack",
			"EighthPack", 
			"EgirlPack", 
			"CottonCandy", 
			"Pack512x", 
			"Pack1056x",
	        "PrivatePack",
            'Aquarium',
            'Ocean',
            'Animated',
			'DemonSlayer',
			'Glizzy',
			'FatCat',
			'Simply',
			'VioletsDreams',
			'Enlightened',
			"Onyx", 
			"Fury", 
			"Wichtiger", 
			"Makima", 
			"Marin-Kitsawaba", 
			"Prime", 
			"Vile", 
			"Devourer", 
			"Acidic", 
			"Moon4Real", 
			"Nebula",
			'Lunar'
        },
        ["Default"] ='Velocity',
        ["HoverText"] = 'Mode to render the texture pack, credits to Snoopy and CatVape.',
        ["Function"] = function() end
    })
    texture_pack_color = texture_pack:CreateColorSlider({
        ["Name"] ="Animated Color",
        ["HoverText"] = "Color of the ANIMATED texturepack.",
        ["Function"] = function() end
    })
end)

