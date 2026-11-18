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
local cloneref: (object: Instance) -> Instance = cloneref or function(object: Instance): Instance
	return object;
end;
local playersService: Players = cloneref(game:GetService('Players'));
local runService: RunService = cloneref(game:GetService('RunService'));
local replicatedStorage: ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'));
local inputService: UserInputService = cloneref(game:GetService('UserInputService'));
local tweenService: TweenService = cloneref(game:GetService('TweenService'));
local coreGui: CoreGui = cloneref(game:GetService('CoreGui'));
local lplr: Player = playersService.LocalPlayer;

local vape: table = shared.veloc;
local entitylib: table = vape.Libraries.entity;
local sessioninfo: table = vape.Libraries.sessioninfo;
local whitelist: table = vape.Libraries.whitelist;
local bedwars: table = {};

local notif: (...any) -> any = function(...: any): any
	return vape:CreateNotification(...);
end;

velo.run = function(callback: () -> (), essential: boolean?): ()
	if velo.halted then
		return;
	end;
	local existing: {[string]: boolean} = {};
	for name: string in vape.Modules do
		existing[name] = true;
	end;
	local failure: string = '';
	if xpcall(callback, function(message: any): ()
		failure = debug.traceback(tostring(message), 2);
	end) then
		return;
	end;
	local created: {string} = {};
	for name: string in vape.Modules do
		if not existing[name] then
			table.insert(created, name);
		end;
	end;
	warn('[velocity lobby] '..failure);
	notif('Velocity', (#created > 0 and table.concat(created, ', ') or 'A lobby module')..' failed to load: '..failure:match('^[^\n]*'), 15, 'alert');
	for _: number, name: string in created do
		vape:Remove(name);
	end;
	velo.halted = essential == true;
end;

velo.run(function(): ()
	local knit: table? = nil;
	repeat
		-- knit's module errors when required before the game finishes setting it up
		local found: boolean, result: any = pcall(function(): any
			return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 9);
		end);
		knit = found and result or nil;
		if not knit then
			task.wait();
		end;
	until knit;
	while not debug.getupvalue(knit.Start, 1) do
		task.wait();
	end;

	local ts: Instance = replicatedStorage.TS;
	local playerTs: Instance = lplr.PlayerScripts.TS;
	local flamework: table = require(replicatedStorage.rbxts_include.node_modules['@flamework'].core.out).Flamework;
	local controllers: table = knit.Controllers;
	bedwars = setmetatable({
		["Client"] = require(ts.remotes).default.Client,
		["CrateItemMeta"] = debug.getupvalue(flamework.resolveDependency('client/controllers/global/reward-crate/crate-controller@CrateController').onStart, 3),
		["EmoteDisplayMeta"] = require(ts.locker.emote['emote-display-meta']).EmoteDisplayMeta,
		["EmoteMeta"] = require(ts.locker.emote['emote-meta']).EmoteMeta,
		["EmoteType"] = require(ts.locker.emote['emote-type']).EmoteType,
		["Flamework"] = flamework,
		["GameAnimationUtil"] = require(ts.animation['animation-util']).GameAnimationUtil,
		["GamePlayerUtil"] = require(ts.player['player-util']).GamePlayerUtil,
		["MilestoneRewards"] = require(ts.milestones.milestones).MilestoneRewards,
		["ModerationApp"] = require(playerTs.controllers.global['match-history'].ui['match-history-moderation-app']).MatchHistoryModerationApp,
		["QueueMeta"] = require(ts.game['queue-meta']).QueueMeta,
		["Store"] = require(playerTs.ui.store).ClientStore
	}, {
		["__index"] = function(self: table, key: string): any
			rawset(self, key, controllers[key]);
			return rawget(self, key);
		end
	});

	for _: number, item: string in {'Kills', 'Beds', 'Wins', 'Games'} do
		sessioninfo:AddItem(item);
	end;

	vape:Clean(function(): ()
		table.clear(bedwars);
	end);
end, true);

velo.run(function(): ()
	local corruptLength: number = 1000;
	-- CallServer waits on the server; running it inline would hold up every module below and the profile load
	task.spawn(function(): ()
		local settings: any = bedwars.Client:Get('GetSettings'):CallServer();
		local corrupted: any = type(settings) == 'table' and rawget(settings, 'boolean') or nil;
		if type(corrupted) == 'string' and #corrupted > corruptLength then
			bedwars.Client:Get('SetSettings'):SendToServer({["mobile_block_break_button"] = true});
		end;
	end);
end);

for name: string, module: table in vape.Modules do
	if module.Category == 'Combat' or module.Category == 'Minigames' then
		vape:Remove(name);
	end;
end;

for _: number, name: string in {
	'AntiFall', 
	'Hitboxes', 
	'AntiRagoll', 
	'Jesus',
	'Phase',
	'Disabler', 
	'Invisible', 
	'MurderMystery', 
	'PlayerAttach', 
	'MouseTP'} do
	vape:Remove(name);
end;

velo.run(function(): ()
	local scanRate: number = 0.5;
	local watched: {[TextLabel]: table} = {};

	local nameFor: (plr: Player) -> string = function(plr: Player): string
		local tags: any = whitelist.get and select(3, whitelist:get(plr)) or nil;
		tags = tags or (whitelist.customtags and whitelist.customtags[plr.Name]);
		local tag: any = type(tags) == 'table' and tags[1] or nil;
		if not tag or not tag.color or not tag.text then
			return plr.DisplayName;
		end;
		return string.format('<font color="#%02X%02X%02X">[%s] </font>', math.floor(tag.color.R * 255), math.floor(tag.color.G * 255), math.floor(tag.color.B * 255), tag.text)..plr.DisplayName;
	end;

	local apply: (plr: Player, label: TextLabel) -> () = function(plr: Player, label: TextLabel): ()
		local text: string = nameFor(plr);
		if label.Text ~= text then
			label.Text = text;
		end;
	end;

	local labelOf: (plr: Player) -> TextLabel? = function(plr: Player): TextLabel?
		local head: Instance? = plr.Character and plr.Character:FindFirstChild('Head');
		local nametag: Instance? = head and head:FindFirstChild('Nametag');
		local container: Instance? = nametag and nametag:FindFirstChild('DisplayNameContainer');
		local label: Instance? = container and container:FindFirstChild('DisplayName');
		return label and label:IsA('TextLabel') and label or nil;
	end;

	vape:Clean(task.spawn(function(): ()
		repeat
			for _: number, plr: Player in playersService:GetPlayers() do
				local label: TextLabel? = labelOf(plr);
				if label then
					if not watched[label] then
						local entry: table = {["Player"] = plr};
						entry.Changed = label:GetPropertyChangedSignal('Text'):Connect(function(): ()
							apply(plr, label);
						end);
						entry.Gone = label.Destroying:Once(function(): ()
							entry.Changed:Disconnect();
							watched[label] = nil;
						end);
						watched[label] = entry;
					end;
					apply(plr, label);
				end;
			end;
			task.wait(scanRate);
		until vape.Loaded == nil;
	end));

	vape:Clean(function(): ()
		for label: TextLabel, entry: table in watched do
			entry.Changed:Disconnect();
			entry.Gone:Disconnect();
			if label.Parent then
				label.Text = entry.Player.DisplayName;
			end;
		end;
		table.clear(watched);
	end);
end);

velo.run(function(): ()
	local Sprint: table = {["Enabled"] = false};

	Sprint = vape.Categories.Combat:CreateModule({
		["Name"] = 'Sprint',
		["Function"] = function(callback: boolean): ()
			local controller: table = bedwars.SprintController;
			local mobileUi: Instance? = inputService.TouchEnabled and lplr.PlayerGui:FindFirstChild('MobileUI') or nil;
			local sprintButton: Instance? = mobileUi and mobileUi:FindFirstChild('2');
			if sprintButton and sprintButton:IsA('GuiObject') then
				sprintButton.Visible = not callback;
			end;
			if callback then
				local oldStop: (...any) -> ...any = controller.stopSprinting;
				controller.stopSprinting = function(...: any): any
					local result: any = oldStop(...);
					controller:startSprinting();
					return result;
				end;
				Sprint:Clean(function(): ()
					controller.stopSprinting = oldStop;
				end);
				Sprint:Clean(entitylib.Events.LocalAdded:Connect(function(): ()
					controller:stopSprinting();
				end));
			end;
			controller:stopSprinting();
		end,
		["Tooltip"] = 'Sets your sprinting to true.'
	});
end);

velo.run(function(): ()
	local AutoGamble: table = {["Enabled"] = false};
	local pickWait: number = 1.2;
	local scanWait: number = 1;

	AutoGamble = vape.Categories.World:CreateModule({
		["Name"] = 'AutoGamble',
		["Function"] = function(callback: boolean): ()
			if not callback then
				return;
			end;
			local crates: table = bedwars.Client:GetNamespace('RewardCrate');
			AutoGamble:Clean(crates:Get('CrateOpened'):Connect(function(data: table): ()
				if data.openingPlayer == lplr then
					local meta: table = bedwars.CrateItemMeta[data.reward.itemType] or {["displayName"] = data.reward.itemType or 'unknown'};
					notif('AutoGamble', 'Won '..meta.displayName, 5);
				end;
			end));
			AutoGamble:Clean(task.spawn(function(): ()
				local altar: table = bedwars.CrateAltarController;
				repeat
					if not altar.activeCrates[1] then
						for _: any, item: table in bedwars.Store:getState().Consumable.inventory do
							if item.consumable:find('crate') then
								altar:pickCrate(item.consumable, 1);
								task.wait(pickWait);
								local active: table? = altar.activeCrates[1];
								if active and active[2] then
									crates:Get('OpenRewardCrate'):SendToServer({["crateId"] = active[2].attributes.crateId});
								end;
								break;
							end;
						end;
					end;
					task.wait(scanWait);
				until not AutoGamble["Enabled"];
			end));
		end,
		["Tooltip"] = 'Automatically opens lucky crates, piston inspired!'
	});
end);

velo.run(function(): ()
	local AutoQueue: table = {["Enabled"] = false};
	local QueueType: table;
	local Delay: table;
	local Leave: table;
	local checkRate: number = 0.1;
	local leaveCooldown: number = 1;
	local joinCooldown: number = 5;
	local queueIds: {[string]: string} = {};
	local queueTitles: {string} = {};
	for queue: string, meta: table in bedwars.QueueMeta do
		if not meta.disabled and meta.title and not queueIds[meta.title] then
			queueIds[meta.title] = queue;
			table.insert(queueTitles, meta.title);
		end;
	end;
	table.sort(queueTitles);

	local lobbyEvent: (name: string) -> () = function(name: string): ()
		local events: Instance? = replicatedStorage:FindFirstChild('events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events');
		local remote: Instance? = events and events:FindFirstChild(name);
		if remote then
			remote:FireServer();
		end;
	end;

	AutoQueue = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoQueue',
		["Function"] = function(callback: boolean): ()
			if not callback then
				lobbyEvent('leaveQueue');
				return;
			end;
			AutoQueue:Clean(task.spawn(function(): ()
				local readySince: number? = nil;
				local nextAction: number = 0;
				repeat
					local party: table = bedwars.Store:getState().Party;
					local selected: string? = queueIds[QueueType["Value"]];
					if party.leader.userId ~= lplr.UserId then
						readySince = nil;
						if Leave["Enabled"] and os.clock() >= nextAction then
							lobbyEvent('leaveParty');
							nextAction = os.clock() + leaveCooldown;
						end;
					elseif party.queueState ~= 0 then
						readySince = nil;
						if selected and party.queueState == 2 and party.queueData and party.queueData.queueType ~= selected and os.clock() >= nextAction then
							lobbyEvent('leaveQueue');
							nextAction = os.clock() + leaveCooldown;
						end;
					elseif selected then
						readySince = readySince or os.clock();
						if os.clock() - readySince >= Delay["Value"] and os.clock() >= nextAction then
							bedwars.QueueController:joinQueue(selected);
							nextAction = os.clock() + joinCooldown;
						end;
					end;
					task.wait(checkRate);
				until not AutoQueue["Enabled"];
			end));
		end,
		["Tooltip"] = 'Joins the queue for the selected mode from the lobby, and joins again whenever you are out of a queue'
	});
	QueueType = AutoQueue:CreateDropdown({
		["Name"] = 'Queue Type',
		["List"] = queueTitles,
		["Default"] = 'Duels (2v2)'
	});
	Delay = AutoQueue:CreateSlider({
		["Name"] = 'Delay',
		["Min"] = 0,
		["Max"] = 10,
		["Decimal"] = 10,
		["Default"] = 0,
		["Suffix"] = function(value: number): string
			return value == 1 and 'second' or 'seconds';
		end,
		["Tooltip"] = 'How long to wait once you are free to queue before joining. Failed joins are retried every 5 seconds'
	});
	Leave = AutoQueue:CreateToggle({
		["Name"] = 'Leave Party',
		["Default"] = true
	});
end);

velo.run(function(): ()
	local ClaimRewards: table = {["Enabled"] = false};
	local CratesOnly: table;
	local Notify: table;
	local claimGap: number = 1;
	local checkRate: number = 5;
	local claimed: {[any]: boolean} = {};

	ClaimRewards = vape.Categories.Utility:CreateModule({
		["Name"] = 'ClaimRewards',
		["Function"] = function(callback: boolean): ()
			if not callback then
				return;
			end;
			ClaimRewards:Clean(task.spawn(function(): ()
				repeat
					local state: table = bedwars.Store:getState();
					local level: number = state.Bedwars.playerLevel or 0;
					local milestones: table? = bedwars.MilestonesController;
					local owned: {any} = milestones and milestones.milestoneRewardsClaimed or state.Bedwars.milestoneRewardsClaimed or {};
					for _: any, reward: table in bedwars.MilestoneRewards do
						if reward.levelRequirement <= level and not claimed[reward.id] and not table.find(owned, reward.id) and (not CratesOnly["Enabled"] or reward.instantClaim) then
							if bedwars.Client:Get('ClaimMilestoneReward'):CallServer(reward.id) then
								claimed[reward.id] = true;
								if Notify["Enabled"] then
									notif('ClaimRewards', 'Claimed '..tostring(reward.description or reward.id), 5);
								end;
							end;
							task.wait(claimGap);
							if not ClaimRewards["Enabled"] then
								break;
							end;
						end;
					end;
					task.wait(checkRate);
				until not ClaimRewards["Enabled"];
			end));
		end,
		["Tooltip"] = 'Automatically claims every level milestone reward as soon as you unlock it'
	});
	CratesOnly = ClaimRewards:CreateToggle({
		["Name"] = 'Crates only',
		["Tooltip"] = 'Only claims the instant rewards like the lucky and diamond crates, leaves kits and cosmetics alone'
	});
	Notify = ClaimRewards:CreateToggle({
		["Name"] = 'Notify',
		["Default"] = true,
		["Tooltip"] = 'Tells you what got claimed'
	});
end);

velo.run(function(): ()
	local originalLevels: {[table]: number} = {};

	vape.Categories.Utility:CreateModule({
		["Name"] = 'LevelBypass',
		["Function"] = function(callback: boolean): ()
			if callback then
				for _: any, meta: table in bedwars.QueueMeta do
					if type(meta.playerLevelReq) == 'number' and meta.playerLevelReq > 0 then
						originalLevels[meta] = meta.playerLevelReq;
						meta.playerLevelReq = 0;
					end;
				end;
				return;
			end;
			for meta: table, level: number in originalLevels do
				if meta.playerLevelReq == 0 then
					meta.playerLevelReq = level;
				end;
			end;
			table.clear(originalLevels);
		end,
		["Tooltip"] = 'Removes local level locks on lobby queues. Reopen the play menu after toggling. Server level restrictions still apply'
	});
end);

velo.run(function(): ()
	local AutoMatchDodge: table = {["Enabled"] = false};
	local Mode: table;
	local Timeout: table;
	local SkillCheck: table;
	local RankCheck: table;
	local PlayerCheck: table;
	local Teammates: table;
	local RegionLock: table;
	local Regions: table;
	local flagPath: string = 'velo/profiles/matchdodge.txt';

	AutoMatchDodge = vape.Categories.Utility:CreateModule({
		["Name"] = 'AutoMatchDodge',
		["Function"] = function(callback: boolean): ()
			writefile(flagPath, tostring(callback));
		end,
		["Tooltip"] = 'Holds you in the loading screen of your next match so you can dodge it. These settings carry over into the match.'
	});
	Mode = AutoMatchDodge:CreateDropdown({
		["Name"] = 'Mode',
		["List"] = {'Auto', 'Manual', 'Region only'},
		["Function"] = function(value: string): ()
			for _: number, option: table? in {Timeout, SkillCheck, RankCheck, PlayerCheck} do
				if option then
					option.Object.Visible = value == 'Auto';
				end;
			end;
			if Regions and RegionLock then
				Regions.Object.Visible = RegionLock["Enabled"] or value == 'Region only';
			end;
		end,
		["Tooltip"] = 'Auto loads after the timeout unless a check dodges, Manual waits for Load, Region only loads as soon as the server region is accepted'
	});
	Timeout = AutoMatchDodge:CreateSlider({
		["Name"] = 'Load timeout',
		["Min"] = 1,
		["Max"] = 90,
		["Default"] = 45,
		["Darker"] = true,
		["Suffix"] = function(value: number): string
			return value <= 1 and 'sec' or 'secs';
		end,
		["Tooltip"] = 'Loads into the game after this long'
	});
	SkillCheck = AutoMatchDodge:CreateToggle({
		["Name"] = 'Skill check',
		["Default"] = true,
		["Darker"] = true,
		["Tooltip"] = 'Dodges when more than one opponent looks "better" than you (not 100% accurate)'
	});
	RankCheck = AutoMatchDodge:CreateToggle({
		["Name"] = 'Rank check',
		["Default"] = true,
		["Darker"] = true,
		["Tooltip"] = 'Only dodges in ranked queues, any other match just loads'
	});
	PlayerCheck = AutoMatchDodge:CreateToggle({
		["Name"] = 'Player check',
		["Darker"] = true,
		["Function"] = function(callback: boolean): ()
			if Teammates then
				Teammates.Object.Visible = callback;
			end;
		end,
		["Tooltip"] = 'Dodges when your team has fewer players than the biggest enemy team'
	});
	Teammates = AutoMatchDodge:CreateTextList({
		["Name"] = 'Players Whitelist',
		["Darker"] = true,
		["Visible"] = false,
		["Tooltip"] = 'Players that will always be on your team if they are in the server'
	});
	RegionLock = AutoMatchDodge:CreateToggle({
		["Name"] = 'Region lock',
		["Function"] = function(callback: boolean): ()
			if Regions then
				Regions.Object.Visible = callback or Mode["Value"] == 'Region only';
			end;
		end,
		["Tooltip"] = 'Dodges servers outside your selected regions'
	});
	Regions = AutoMatchDodge:CreateTextList({
		["Name"] = 'Regions',
		["Placeholder"] = 'NA / EU / AS / OCEANIA',
		["Default"] = {'NA', 'EU', 'AS', 'OCEANIA'},
		["Darker"] = true,
		["Visible"] = false,
		["Function"] = function(): ()
			for _: number, list: {string} in (Regions and {Regions.List, Regions.ListEnabled} or {}) do
				for index: number, entry: string in list do
					list[index] = entry:gsub('%s+', ''):upper();
				end;
			end;
		end,
		["Tooltip"] = 'Turn off the regions you do not want. SG-03 counts as AS, AU/NZ as OCEANIA, US-CA as NA. Leaving every region on accepts anything'
	});
	if AutoMatchDodge.Share then
		AutoMatchDodge:Share('matchdodge');
	end;
end);

velo.run(function(): ()
	local ViewMatchHistory: table = {["Enabled"] = false};

	ViewMatchHistory = vape.Categories.Utility:CreateModule({
		["Name"] = 'ViewMatchHistory',
		["Function"] = function(callback: boolean): ()
			if not callback then
				return;
			end;
			bedwars.Flamework.resolveDependency('@easy-games/game-core:client/controllers/app-controller@AppController'):openApp({["appId"] = 'MatchHistoryApp', ["app"] = bedwars.ModerationApp}, {["player"] = lplr, ["matchHistory"] = {}});
			ViewMatchHistory:Toggle();
		end,
		["Tooltip"] = 'Opens your match history.'
	});
end);

velo.run(function(): ()
	local NickHider: table = {["Enabled"] = false};
	local Replacement: table;
	local HideOthers: table;
	local ChatTags: table;
	local Level: table;
	local Kit: table;
	local Device: table;
	local refreshDelay: number = 0.35;
	local scanBudget: number = 0.002;
	local textClasses: {[string]: boolean} = {["TextLabel"] = true, ["TextButton"] = true, ["TextBox"] = true};
	local patterns: {string} = {};
	local plainNames: {string} = {};
	local shortest: number = math.huge;
	local fakeName: string = 'hidden';
	local fakeReplacement: string = 'hidden';
	local writing: Instance? = nil;
	local swapped: {[Instance]: string} = {};
	local watched: {[Instance]: {RBXScriptConnection}} = {};
	local hiddenKits: {[Instance]: boolean} = {};
	local playerHooks: table? = nil;
	local deviceHook: table? = nil;
	local refreshQueued: boolean = false;
	local refreshing: boolean = false;
	local guiHolder: Instance? = vape.gui and vape.gui.Parent;
	local hiddenUi: Instance? = guiHolder and guiHolder.ClassName ~= 'CoreGui' and guiHolder or nil;

	local refresh: () -> () = function(): ()
		if refreshQueued or not NickHider["Enabled"] then
			return;
		end;
		refreshQueued = true;
		task.delay(refreshDelay, function(): ()
			refreshQueued = false;
			if NickHider["Enabled"] then
				refreshing = true;
				NickHider:Toggle();
				NickHider:Toggle();
				refreshing = false;
			end;
		end);
	end;

	local spoofDevice: () -> () = function(): ()
		local controller: table = bedwars.UserInputController;
		deviceHook = {["Original"] = rawget(controller, 'getUserInputType'), ["Previous"] = controller:getUserInputType()};
		controller.getUserInputType = function(): string
			return Device["Value"]:upper();
		end;
		bedwars.Client:Get('SendUserInputType'):SendToServer({["userInputType"] = Device["Value"]:upper()});
	end;

	local restoreDevice: () -> () = function(): ()
		if deviceHook then
			bedwars.UserInputController.getUserInputType = deviceHook.Original;
			bedwars.Client:Get('SendUserInputType'):SendToServer({["userInputType"] = deviceHook.Previous});
			deviceHook = nil;
		end;
	end;

	local forget: (object: Instance) -> () = function(object: Instance): ()
		for _: number, connection: RBXScriptConnection in watched[object] or {} do
			connection:Disconnect();
		end;
		watched[object] = nil;
		swapped[object] = nil;
		hiddenKits[object] = nil;
	end;

	local replaceText: (object: Instance) -> ();
	replaceText = function(object: Instance): ()
		local text: any = object.Text;
		if writing == object or type(text) ~= 'string' or #text < shortest then
			return;
		end;
		local lowered: string = text:lower();
		local found: boolean = false;
		for _: number, name: string in plainNames do
			found = found or lowered:find(name, 1, true) ~= nil;
		end;
		if not found then
			return;
		end;
		local replaced: string = text;
		for _: number, pattern: string in patterns do
			replaced = replaced:gsub(pattern, fakeReplacement);
		end;
		if replaced == text then
			return;
		end;
		swapped[object] = text;
		object:SetAttribute('NickHiderOriginalText', text);
		writing = object;
		object.Text = replaced;
		writing = nil;
		if not watched[object] then
			watched[object] = {
				object:GetPropertyChangedSignal('Text'):Connect(function(): ()
					replaceText(object);
				end),
				object.Destroying:Once(function(): ()
					forget(object);
				end)
			};
		end;
	end;

	local inspect: (object: Instance) -> () = function(object: Instance): ()
		if textClasses[object.ClassName] then
			replaceText(object);
		elseif Kit["Enabled"] and object.Name == 'PlayerKitFrame' and hiddenKits[object] == nil then
			task.defer(function(): ()
				local label: Instance? = object.Parent and object.Parent:FindFirstChild('PlayerName', true);
				if NickHider["Enabled"] and label and label.Text:find(fakeName, 1, true) then
					hiddenKits[object] = object.Visible;
					object.Visible = false;
					watched[object] = {object.Destroying:Once(function(): ()
						forget(object);
					end)};
				end;
			end);
		end;
	end;

	local scan: (root: Instance) -> () = function(root: Instance): ()
		if vape.ThreadFix then
			setthreadidentity(8);
		end;
		NickHider:Clean(root.DescendantAdded:Connect(inspect));
		local started: number = os.clock();
		for _: number, object: Instance in root:GetDescendants() do
			inspect(object);
			if os.clock() - started > scanBudget then
				task.wait();
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				started = os.clock();
			end;
		end;
	end;

	NickHider = vape.Categories.Utility:CreateModule({
		["Name"] = 'NickHider',
		["Function"] = function(callback: boolean): ()
			if not callback then
				if playerHooks then
					for name: string, original: any in playerHooks.Originals do
						playerHooks.Class[name] = original;
					end;
					playerHooks = nil;
				end;
				if not refreshing then
					restoreDevice();
				end;
				if vape.ThreadFix then
					setthreadidentity(8);
				end;
				for _: Instance, connections: {RBXScriptConnection} in watched do
					for _: number, connection: RBXScriptConnection in connections do
						connection:Disconnect();
					end;
				end;
				table.clear(watched);
				for object: Instance, visible: boolean in hiddenKits do
					if object.Parent then
						object.Visible = visible;
					end;
				end;
				table.clear(hiddenKits);
				for object: Instance, original: string in swapped do
					if object.Parent then
						writing = object;
						object.Text = original;
						object:SetAttribute('NickHiderOriginalText', nil);
					end;
				end;
				writing = nil;
				table.clear(swapped);
				return;
			end;

			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			table.clear(patterns);
			table.clear(plainNames);
			shortest = math.huge;
			for _: number, plr: Player in playersService:GetPlayers() do
				if plr == lplr or HideOthers["Enabled"] then
					for _: number, name: string in {plr.Name, plr.DisplayName} do
						local lowered: string = name:lower();
						if name ~= '' and not table.find(plainNames, lowered) then
							table.insert(plainNames, lowered);
							shortest = math.min(shortest, #lowered);
						end;
						for _: number, variant: string in {name, lowered, name:upper()} do
							local pattern: string = variant:gsub('%W', '%%%0');
							if variant ~= '' and not table.find(patterns, pattern) then
								table.insert(patterns, pattern);
							end;
						end;
					end;
				end;
			end;
			fakeName = Replacement["Value"] ~= '' and Replacement["Value"] or 'hidden';
			for _: number, pattern: string in patterns do
				fakeName = fakeName:find(pattern) and 'hidden' or fakeName;
			end;
			fakeReplacement = fakeName:gsub('%%', '%%%%');

			local gamePlayer: any = bedwars.GamePlayerUtil.getGamePlayer(lplr);
			local meta: any = gamePlayer and getmetatable(gamePlayer);
			local class: any = type(meta) == 'table' and rawget(meta, '__index');
			if type(class) == 'table' then
				local originals: table = {["getUsername"] = class.getUsername, ["getDisplayName"] = class.getDisplayName, ["getClanTag"] = class.getClanTag, ["getLevel"] = class.getLevel};
				playerHooks = {["Class"] = class, ["Originals"] = originals};
				local concealed: (self: table) -> boolean = function(self: table): boolean
					local plr: Player? = self:getPlayer();
					return plr ~= nil and (plr == lplr or HideOthers["Enabled"]);
				end;
				class.getUsername = function(self: table, ...: any): any
					return concealed(self) and fakeName or originals.getUsername(self, ...);
				end;
				class.getDisplayName = function(self: table, ...: any): any
					return concealed(self) and fakeName or originals.getDisplayName(self, ...);
				end;
				class.getClanTag = function(self: table, ...: any): any
					return self:getPlayer() == lplr and ChatTags["Enabled"] and '' or originals.getClanTag(self, ...);
				end;
				class.getLevel = function(self: table, ...: any): any
					local plr: Player? = self:getPlayer();
					if plr and (HideOthers["Enabled"] or plr == lplr and Level["Enabled"]) then
						return -1;
					end;
					return originals.getLevel(self, ...);
				end;
			end;

			if Device["Value"] ~= 'Off' and not deviceHook then
				spoofDevice();
			end;

			local roots: {Instance} = {coreGui};
			table.insert(roots, lplr:FindFirstChildOfClass('PlayerGui'));
			if hiddenUi then
				table.insert(roots, hiddenUi);
			end;
			if lplr.Character then
				table.insert(roots, lplr.Character);
			end;
			NickHider:Clean(task.spawn(function(): ()
				for _: number, root: Instance in roots do
					scan(root);
				end;
			end));
			NickHider:Clean(lplr.CharacterAdded:Connect(function(character: Model): ()
				NickHider:Clean(task.spawn(scan, character));
			end));
			NickHider:Clean(playersService.PlayerAdded:Connect(function(): ()
				if HideOthers["Enabled"] then
					refresh();
				end;
			end));
			NickHider:Clean(playersService.PlayerRemoving:Connect(function(): ()
				if HideOthers["Enabled"] then
					refresh();
				end;
			end));
		end,
		["Tooltip"] = 'Replaces your username and display name everywhere it shows up on your screen, and can spoof your device.',
		["ExtraText"] = function(): string
			return Replacement["Value"] ~= '' and Replacement["Value"] or 'hidden';
		end
	});
	Replacement = NickHider:CreateTextBox({
		["Name"] = 'Name',
		["Default"] = 'hidden',
		["Function"] = refresh
	});
	HideOthers = NickHider:CreateToggle({
		["Name"] = 'Hide others',
		["Function"] = refresh,
		["Tooltip"] = 'Hides every player\'s username and level.'
	});
	ChatTags = NickHider:CreateToggle({
		["Name"] = 'Hide chat tags',
		["Tooltip"] = 'Hides your clan tag wherever it renders.'
	});
	Level = NickHider:CreateToggle({
		["Name"] = 'Hide level',
		["Function"] = refresh,
		["Tooltip"] = 'Hides your level wherever it renders.'
	});
	Kit = NickHider:CreateToggle({
		["Name"] = 'Hide kit',
		["Function"] = refresh,
		["Tooltip"] = 'Hides your kit icon in the tab list.'
	});
	Device = NickHider:CreateDropdown({
		["Name"] = 'Device',
		["List"] = {'Off', 'Mobile', 'PC', 'Gamepad'},
		["Function"] = function(value: string): ()
			if not NickHider["Enabled"] then
				return;
			end;
			if value == 'Off' then
				restoreDevice();
			elseif deviceHook then
				bedwars.Client:Get('SendUserInputType'):SendToServer({["userInputType"] = value:upper()});
			else
				spoofDevice();
			end;
		end,
		["Tooltip"] = 'Spoofs the device you show up as to the server.'
	});
end);

velo.run(function(): ()
	local SetEmote: table = {["Enabled"] = false};
	local Emote: table;
	local Nightmare: table;
	local movingEmoteTime: number = 6;
	local nightmareAnimation: string = 'rbxassetid://9191822700';
	local queryUtil: table = require(replicatedStorage.rbxts_include.node_modules['@easy-games']['game-core'].out).GameQueryUtil;
	local emoteTypes: {[string]: any} = {};
	local emoteNames: {string} = {};
	local playing: table = {};
	for emoteType: any, meta: table in bedwars.EmoteMeta do
		if emoteType ~= bedwars.EmoteType.NONE and meta.name and not emoteTypes[meta.name] then
			emoteTypes[meta.name] = emoteType;
			table.insert(emoteNames, meta.name);
		end;
	end;
	table.sort(emoteNames);

	local stopEmote: () -> () = function(): ()
		if playing.Track then
			playing.Track:Stop();
			playing.Track:Destroy();
		end;
		for _: number, key: string in {'Billboard', 'Effect'} do
			if playing[key] then
				playing[key]:Destroy();
			end;
		end;
		for _: number, key: string in {'Follow', 'Moved'} do
			if playing[key] then
				playing[key]:Disconnect();
			end;
		end;
		table.clear(playing);
		local controller: table? = bedwars.EmoteController;
		local audio: any = controller and controller.emoteAudioMaids and controller.emoteAudioMaids[lplr.UserId];
		if audio then
			audio:DoCleaning();
		end;
		if lplr.Character and lplr.Character:GetAttribute('PlayingEmote') then
			lplr.Character:SetAttribute('PlayingEmote', nil);
		end;
	end;
	vape:Clean(stopEmote);

	SetEmote = vape.Categories.Utility:CreateModule({
		["Name"] = 'SetEmote',
		["Function"] = function(callback: boolean): ()
			if not callback then
				return;
			end;
			SetEmote:Toggle();
			local emoteType: any = emoteTypes[Emote["Value"]];
			local meta: table? = bedwars.EmoteMeta[emoteType];
			if not entitylib.isAlive or not meta then
				return;
			end;
			stopEmote();
			local character: Model = entitylib.character.Character;
			local humanoid: Humanoid = entitylib.character.Humanoid;
			character:SetAttribute('PlayingEmote', emoteType);
			local controller: table? = bedwars.EmoteController;
			local playBegin: any = controller and (controller.createEmoteBeginAudioPlayers or controller.playEmoteBeginSounds);
			if playBegin then
				playBegin(controller, emoteType, lplr);
			end;
			local animation: table? = meta.animation or meta.emoteDisplayType and bedwars.EmoteDisplayMeta[meta.emoteDisplayType] and bedwars.EmoteDisplayMeta[meta.emoteDisplayType].animation;
			local effectTemplate: Instance? = Nightmare["Enabled"] and replicatedStorage:FindFirstChild('Assets') and replicatedStorage.Assets:FindFirstChild('Effects') and replicatedStorage.Assets.Effects:FindFirstChild('NightmareEmote');
			if effectTemplate then
				local effect: Model = effectTemplate:Clone();
				for _: number, part: Instance in effect:GetDescendants() do
					if part:IsA('BasePart') then
						queryUtil:setQueryIgnored(part, true);
						part.CanCollide = false;
						part.Anchored = true;
					end;
				end;
				for _: number, ring: Instance? in {effect:FindFirstChild('Outer'), effect:FindFirstChild('Middle')} do
					if ring and ring:IsA('BasePart') then
						tweenService:Create(ring, TweenInfo.new(ring.Name == 'Outer' and 1.5 or 12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {["Orientation"] = ring.Orientation + Vector3.new(0, ring.Name == 'Outer' and 360 or -360, 0)}):Play();
					end;
				end;
				effect.Parent = workspace;
				playing.Effect = effect;
				playing.Follow = runService.RenderStepped:Connect(function(): ()
					local torso: BasePart? = character:FindFirstChild('LowerTorso');
					if torso and effect.PrimaryPart then
						effect:SetPrimaryPartCFrame(torso.CFrame + Vector3.new(0, -2, 0));
					end;
				end);
				local custom: Animation = Instance.new('Animation');
				custom.AnimationId = nightmareAnimation;
				playing.Track = humanoid:LoadAnimation(custom);
				playing.Track:Play();
			elseif animation then
				playing.Track = humanoid:LoadAnimation(bedwars.GameAnimationUtil:getAnimation(animation.type));
				playing.Track.Looped = animation.looped or false;
				playing.Track:Play(nil, nil, animation.speed or 1);
			end;
			if not meta.animation and character:FindFirstChild('Head') then
				local billboard: BillboardGui = Instance.new('BillboardGui');
				billboard.Size = UDim2.fromScale(6, 2.5);
				billboard.StudsOffset = Vector3.new(0, 2, 0);
				billboard.AlwaysOnTop = true;
				billboard.Adornee = character.Head;
				local image: ImageLabel = Instance.new('ImageLabel');
				image.AnchorPoint = Vector2.new(0.5, 1);
				image.Position = UDim2.fromScale(0.5, 1);
				image.Size = UDim2.fromScale(0, 0);
				image.Image = meta.image;
				image.BackgroundTransparency = 1;
				image.ImageTransparency = 1;
				image.ScaleType = Enum.ScaleType.Fit;
				image.Parent = billboard;
				billboard.Parent = character.Head;
				playing.Billboard = billboard;
				tweenService:Create(image, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {["Position"] = UDim2.fromScale(0.5, 0.5), ["Size"] = UDim2.fromScale(1, 1), ["ImageTransparency"] = 0}):Play();
			end;
			if meta.allowMovement then
				local token: table = {};
				playing.Token = token;
				task.delay(movingEmoteTime, function(): ()
					if playing.Token == token then
						stopEmote();
					end;
				end);
			else
				playing.Moved = humanoid:GetPropertyChangedSignal('MoveDirection'):Once(stopEmote);
			end;
		end,
		["Tooltip"] = 'Plays the selected emote on your character, other players can see it too.'
	});
	Emote = SetEmote:CreateDropdown({
		["Name"] = 'Emote',
		["List"] = emoteNames,
		["Default"] = 'nightmare'
	});
	Nightmare = SetEmote:CreateToggle({
		["Name"] = 'Nightmare effect',
		["Tooltip"] = 'Also spawns the nightmare ring effect and animation around you (client side).'
	});
end);

velo.run(function(): ()
	local QueueCardVisuals: table = {["Enabled"] = false};
	local Gradient: table;
	local Rounding: table;
	local CardColor: table;
	local SecondColor: table;
	local Highlight: table;
	local HighlightColor: table;
	local CustomFont: table;
	local FontName: table;
	local changed: {table} = {};
	local created: {Instance} = {};
	local appWatch: RBXScriptConnection? = nil;
	local fonts: {string} = {};
	for _: number, font: EnumItem in Enum.Font:GetEnumItems() do
		table.insert(fonts, font.Name);
	end;

	local hsv: (option: table) -> Color3 = function(option: table): Color3
		return Color3.fromHSV(option["Hue"], option["Sat"], option["Value"]);
	end;

	local assign: (object: Instance, property: string, value: any) -> () = function(object: Instance, property: string, value: any): ()
		table.insert(changed, {["Object"] = object, ["Property"] = property, ["Original"] = object[property]});
		object[property] = value;
	end;

	local unstyle: () -> () = function(): ()
		for index: number = #changed, 1, -1 do
			local entry: table = changed[index];
			if entry.Object.Parent then
				entry.Object[entry.Property] = entry.Original;
			end;
		end;
		for _: number, object: Instance in created do
			object:Destroy();
		end;
		table.clear(changed);
		table.clear(created);
	end;

	local style: (card: GuiObject) -> () = function(card: GuiObject): ()
		local primary: Color3 = hsv(CardColor);
		assign(card, 'BackgroundColor3', Gradient["Enabled"] and Color3.new(1, 1, 1) or primary);
		local corner: UICorner? = card:FindFirstChildOfClass('UICorner');
		if corner then
			assign(corner, 'CornerRadius', UDim.new(0, Rounding["Value"]));
		else
			corner = Instance.new('UICorner');
			corner.CornerRadius = UDim.new(0, Rounding["Value"]);
			corner.Parent = card;
			table.insert(created, corner);
		end;
		if CustomFont["Enabled"] then
			for _: number, text: Instance in card:GetDescendants() do
				if text:IsA('TextLabel') or text:IsA('TextButton') then
					assign(text, 'Font', Enum.Font[FontName["Value"]]);
				end;
			end;
		end;
		local stroke: UIStroke? = card:FindFirstChildOfClass('UIStroke');
		if Highlight["Enabled"] then
			if not stroke then
				stroke = Instance.new('UIStroke');
				stroke.Parent = card;
				table.insert(created, stroke);
			end;
			assign(stroke, 'Thickness', 1.7);
			assign(stroke, 'Color', hsv(HighlightColor));
		elseif stroke then
			assign(stroke, 'Enabled', false);
		end;
		if Gradient["Enabled"] then
			local gradient: UIGradient? = card:FindFirstChildWhichIsA('UIGradient');
			if not gradient then
				gradient = Instance.new('UIGradient');
				gradient.Parent = card;
				table.insert(created, gradient);
			end;
			assign(gradient, 'Color', ColorSequence.new(primary, hsv(SecondColor)));
		end;
	end;

	local restyle: () -> () = function(): ()
		if not QueueCardVisuals["Enabled"] then
			return;
		end;
		unstyle();
		local queueApp: Instance? = lplr.PlayerGui:FindFirstChild('QueueApp');
		local card: Instance? = queueApp and queueApp:FindFirstChild('1');
		if card and card:IsA('GuiObject') then
			style(card);
		end;
	end;

	local follow: (queueApp: Instance) -> () = function(queueApp: Instance): ()
		if appWatch then
			appWatch:Disconnect();
		end;
		appWatch = queueApp.ChildAdded:Connect(function(child: Instance): ()
			if child.Name == '1' then
				restyle();
			end;
		end);
		restyle();
	end;

	QueueCardVisuals = vape.Legit:CreateModule({
		["Name"] = 'QueueCardVisuals',
		["Function"] = function(callback: boolean): ()
			if not callback then
				if appWatch then
					appWatch:Disconnect();
					appWatch = nil;
				end;
				unstyle();
				return;
			end;
			local queueApp: Instance? = lplr.PlayerGui:FindFirstChild('QueueApp');
			if queueApp then
				follow(queueApp);
			end;
			QueueCardVisuals:Clean(lplr.PlayerGui.ChildAdded:Connect(function(child: Instance): ()
				if child.Name == 'QueueApp' then
					follow(child);
				end;
			end));
		end,
		["Tooltip"] = 'Customizes the queue card.'
	});
	Gradient = QueueCardVisuals:CreateToggle({
		["Name"] = 'Gradient',
		["Function"] = function(callback: boolean): ()
			if SecondColor then
				SecondColor.Object.Visible = callback;
			end;
			restyle();
		end
	});
	Rounding = QueueCardVisuals:CreateSlider({
		["Name"] = 'Rounding',
		["Min"] = 0,
		["Max"] = 20,
		["Default"] = 4,
		["Function"] = restyle
	});
	CardColor = QueueCardVisuals:CreateColorSlider({
		["Name"] = 'Color',
		["Function"] = restyle
	});
	SecondColor = QueueCardVisuals:CreateColorSlider({
		["Name"] = 'Color 2',
		["Function"] = restyle
	});
	Highlight = QueueCardVisuals:CreateToggle({
		["Name"] = 'Highlight',
		["Function"] = restyle
	});
	HighlightColor = QueueCardVisuals:CreateColorSlider({
		["Name"] = 'Highlight Color',
		["Function"] = restyle
	});
	CustomFont = QueueCardVisuals:CreateToggle({
		["Name"] = 'Font',
		["Function"] = function(callback: boolean): ()
			if FontName then
				FontName.Object.Visible = callback;
			end;
			restyle();
		end,
		["Tooltip"] = 'Custom fonts.'
	});
	FontName = QueueCardVisuals:CreateDropdown({
		["Name"] = 'Fonts',
		["List"] = fonts,
		["Default"] = 'SourceSans',
		["Function"] = restyle,
		["Tooltip"] = 'Font of the text.'
	});
	SecondColor.Object.Visible = false;
	FontName.Object.Visible = false;
end);

velo.run(function(): ()
	local HotbarVisuals: table = {["Enabled"] = false};
	local CustomColor: table;
	local Gradient: table;
	local GradientColor: table;
	local GradientColor2: table;
	local SlotColor: table;
	local Rounding: table;
	local CornerRadius: table;
	local Highlight: table;
	local HighlightColor: table;
	local HideNumbers: table;
	local Invisibility: table;
	local Spacing: table;
	local hotbarWait: number = 5;
	local slots: {[Instance]: table} = {};
	local layout: table? = nil;
	local itemsWatch: RBXScriptConnection? = nil;

	local hsv: (option: table) -> Color3 = function(option: table): Color3
		return Color3.fromHSV(option["Hue"], option["Sat"], option["Value"]);
	end;

	local decoration: (entry: table, key: string, class: string, wanted: boolean) -> Instance? = function(entry: table, key: string, class: string, wanted: boolean): Instance?
		local object: Instance? = entry[key];
		if wanted and not object then
			object = Instance.new(class);
			object.Parent = entry.Slot;
			entry[key] = object;
		elseif not wanted and object then
			object:Destroy();
			entry[key] = nil;
			return nil;
		end;
		return object;
	end;

	local style: (entry: table) -> () = function(entry: table): ()
		local slot: Instance = entry.Slot;
		local transparency: number = 0.1 * Invisibility["Value"];
		if slot.BackgroundTransparency ~= transparency then
			slot.BackgroundTransparency = transparency;
		end;
		local gradient: Instance? = decoration(entry, 'Gradient', 'UIGradient', Gradient["Enabled"]);
		if gradient then
			gradient.Color = ColorSequence.new(hsv(GradientColor), hsv(GradientColor2));
		end;
		local wanted: Color3? = gradient and Color3.new(1, 1, 1) or CustomColor["Enabled"] and hsv(SlotColor) or nil;
		if wanted then
			if slot.BackgroundColor3 ~= wanted then
				slot.BackgroundColor3 = wanted;
			end;
		elseif entry.Recolored then
			slot.BackgroundColor3 = entry.Color;
		end;
		entry.Recolored = wanted ~= nil;
		local corner: Instance? = decoration(entry, 'Corner', 'UICorner', Rounding["Enabled"]);
		if corner then
			corner.CornerRadius = UDim.new(0, CornerRadius["Value"]);
		end;
		local stroke: Instance? = decoration(entry, 'Stroke', 'UIStroke', Highlight["Enabled"]);
		if stroke then
			stroke.Color = hsv(HighlightColor);
			stroke.Thickness = 1.3;
		end;
		local showNumber: boolean = entry.NumberVisible and not HideNumbers["Enabled"];
		if entry.Number.Visible ~= showNumber then
			entry.Number.Visible = showNumber;
		end;
	end;

	local release: (entry: table) -> () = function(entry: table): ()
		for _: number, connection: RBXScriptConnection in entry.Watch do
			connection:Disconnect();
		end;
		for _: number, key: string in {'Gradient', 'Corner', 'Stroke'} do
			if entry[key] then
				entry[key]:Destroy();
			end;
		end;
		local slot: Instance = entry.Slot;
		if slot.Parent then
			slot.BackgroundTransparency = entry.Transparency;
			if entry.Recolored then
				slot.BackgroundColor3 = entry.Color;
			end;
			entry.Number.Visible = entry.NumberVisible;
		end;
		slots[slot] = nil;
	end;

	local track: (child: Instance) -> () = function(child: Instance): ()
		local slot: Instance? = child:FindFirstChildWhichIsA('ImageButton');
		local number: Instance? = slot and slot:FindFirstChildWhichIsA('TextLabel');
		if not number or slots[slot] then
			return;
		end;
		local entry: table = {["Slot"] = slot, ["Number"] = number, ["NumberVisible"] = number.Visible, ["Color"] = slot.BackgroundColor3, ["Transparency"] = slot.BackgroundTransparency, ["Recolored"] = false};
		entry.Watch = {
			slot:GetPropertyChangedSignal('BackgroundTransparency'):Connect(function(): ()
				style(entry);
			end),
			slot:GetPropertyChangedSignal('BackgroundColor3'):Connect(function(): ()
				if entry.Recolored then
					style(entry);
				else
					entry.Color = slot.BackgroundColor3;
				end;
			end),
			slot.Destroying:Once(function(): ()
				release(entry);
			end)
		};
		slots[slot] = entry;
		style(entry);
	end;

	local attach: (items: Instance) -> () = function(items: Instance): ()
		if itemsWatch then
			itemsWatch:Disconnect();
		end;
		itemsWatch = items.ChildAdded:Connect(track);
		for _: number, child: Instance in items:GetChildren() do
			track(child);
		end;
		local list: UIListLayout? = items:FindFirstChildOfClass('UIListLayout');
		if list then
			if not layout or layout.Layout ~= list then
				layout = {["Layout"] = list, ["Padding"] = list.Padding};
			end;
			list.Padding = UDim.new(0, Spacing["Value"]);
		end;
	end;

	local restyleAll: () -> () = function(): ()
		if not HotbarVisuals["Enabled"] then
			return;
		end;
		for _: Instance, entry: table in slots do
			style(entry);
		end;
		if layout and layout.Layout.Parent then
			layout.Layout.Padding = UDim.new(0, Spacing["Value"]);
		end;
	end;

	local reveal: (callback: boolean, options: {table?}) -> () = function(callback: boolean, options: {table?}): ()
		for _: number, option: table? in options do
			if option then
				option.Object.Visible = callback;
			end;
		end;
		restyleAll();
	end;

	HotbarVisuals = vape.Categories.Render:CreateModule({
		["Name"] = 'HotbarVisuals',
		["Function"] = function(callback: boolean): ()
			if not callback then
				if itemsWatch then
					itemsWatch:Disconnect();
					itemsWatch = nil;
				end;
				for _: Instance, entry: table in slots do
					release(entry);
				end;
				table.clear(slots);
				if layout and layout.Layout.Parent then
					layout.Layout.Padding = layout.Padding;
				end;
				layout = nil;
				return;
			end;
			local hotbar: Instance? = lplr.PlayerGui:FindFirstChild('hotbar');
			local frame: Instance? = hotbar and hotbar:FindFirstChild('1');
			local items: Instance? = frame and frame:FindFirstChild('ItemsHotbar');
			if items then
				attach(items);
			end;
			HotbarVisuals:Clean(lplr.PlayerGui.ChildAdded:Connect(function(child: Instance): ()
				if child.Name ~= 'hotbar' then
					return;
				end;
				local added: Instance? = child:WaitForChild('1', hotbarWait);
				local addedItems: Instance? = added and added:WaitForChild('ItemsHotbar', hotbarWait);
				if addedItems and HotbarVisuals["Enabled"] then
					attach(addedItems);
				end;
			end));
		end,
		["Tooltip"] = 'Add customization to your hotbar.'
	});
	CustomColor = HotbarVisuals:CreateToggle({
		["Name"] = 'Custom slot color',
		["Function"] = function(callback: boolean): ()
			reveal(callback, {SlotColor});
		end
	});
	Gradient = HotbarVisuals:CreateToggle({
		["Name"] = 'Gradient Slot Color',
		["Function"] = function(callback: boolean): ()
			reveal(callback, {GradientColor, GradientColor2});
		end
	});
	GradientColor = HotbarVisuals:CreateColorSlider({
		["Name"] = 'Gradient Color',
		["Function"] = restyleAll
	});
	GradientColor2 = HotbarVisuals:CreateColorSlider({
		["Name"] = 'Gradient Color 2',
		["Function"] = restyleAll
	});
	SlotColor = HotbarVisuals:CreateColorSlider({
		["Name"] = 'Slot Color',
		["Function"] = restyleAll
	});
	Rounding = HotbarVisuals:CreateToggle({
		["Name"] = 'Rounding',
		["Function"] = function(callback: boolean): ()
			reveal(callback, {CornerRadius});
		end
	});
	CornerRadius = HotbarVisuals:CreateSlider({
		["Name"] = 'Corner Radius',
		["Min"] = 1,
		["Max"] = 20,
		["Default"] = 8,
		["Function"] = restyleAll
	});
	Highlight = HotbarVisuals:CreateToggle({
		["Name"] = 'Outline Highlight',
		["Function"] = function(callback: boolean): ()
			reveal(callback, {HighlightColor});
		end
	});
	HighlightColor = HotbarVisuals:CreateColorSlider({
		["Name"] = 'Highlight Color',
		["Function"] = restyleAll
	});
	HideNumbers = HotbarVisuals:CreateToggle({
		["Name"] = 'No Slot Numbers',
		["Function"] = restyleAll
	});
	Invisibility = HotbarVisuals:CreateSlider({
		["Name"] = 'Invisibility',
		["Min"] = 0,
		["Max"] = 10,
		["Default"] = 4,
		["Function"] = restyleAll
	});
	Spacing = HotbarVisuals:CreateSlider({
		["Name"] = 'Spacing',
		["Min"] = 0,
		["Max"] = 5,
		["Function"] = restyleAll
	});
	for _: number, option: table in {SlotColor, GradientColor, GradientColor2, CornerRadius, HighlightColor} do
		option.Object.Visible = false;
	end;
end);
