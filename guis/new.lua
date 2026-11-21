local vape: table = {
	["ActiveBinds"] = {},
	["Categories"] = {},
	["GUIColor"] = {
		["Hue"] = 0.46,
		["Sat"] = 0.96,
		["Value"] = 0.52
	},
	["HeldKeybinds"] = {},
	["Loaded"] = false,
	["Libraries"] = {},
	["Modules"] = {},
	["Place"] = game.PlaceId,
	["Profile"] = 'default',
	["RainbowSliders"] = {},
	["Settings"] = {},
	["SettingToggleNotifications"] = {},
	["ThreadFix"] = setthreadidentity and true or false,
	["ToggleNotifications"] = {},
	["Version"] = '4.24.0',
	["Windows"] = {}
};

local run: (func: any) -> () = function(func: any): ()
	func();
end;
local cloneref: (obj: any) -> any = cloneref or function(obj: any): any
	return obj;
end;
local tweenService: TweenService = cloneref(game:GetService('TweenService'));
local inputService: UserInputService = cloneref(game:GetService('UserInputService'));
local textService: TextService = cloneref(game:GetService('TextService'));
local guiService: GuiService = cloneref(game:GetService('GuiService'));
local runService: RunService = cloneref(game:GetService('RunService'));
local httpService: HttpService = cloneref(game:GetService('HttpService'));
local playersService: Players = cloneref(game:GetService('Players'));

local fontsize: GetTextBoundsParams = Instance.new('GetTextBoundsParams');
fontsize.Width = math.huge;
local notifications: Folder;
local getvapeasset: (path: string) -> any;
local components: table;
local clickgui: Frame;
local scaledgui: Frame;
local toolblur: Instance;
local tooltip: TextLabel;
local TextGUI: table;
local scale: any = {["Scale"] = 1};
local gui: ScreenGui;

local isfile: (file: string) -> boolean = isfile or function(file: string): boolean
	local success: boolean, data: any = pcall(function(): string
		return readfile(file);
	end);

	return success and data ~= nil and data ~= '';
end;

local loadJson: (path: string) -> any = function(path: string): any
	local success: boolean, data: any = pcall(function(): ...any
		return httpService:JSONDecode(readfile(path));
	end);

	return success and type(data) == 'table' and data or nil;
end;

local globalPrefix: string = 'global/';
local globalListPath: string = 'velo/profiles/global/list.json';

local isGlobalProfile: (name: string?) -> boolean = function(name: string?): boolean
	return type(name) == 'string' and name:sub(1, #globalPrefix) == globalPrefix;
end;

local profileId: (profile: table) -> string = function(profile: table): string
	return profile.Global and globalPrefix .. profile.Name or profile.Name;
end;

local profileDisplay: (name: string) -> string = function(name: string): string
	return isGlobalProfile(name) and name:sub(#globalPrefix + 1) or name;
end;

local profilePath: (name: string) -> string = function(name: string): string
	if isGlobalProfile(name) then
		return 'velo/profiles/' .. name .. '.txt';
	end;
	return 'velo/profiles/' .. name .. vape.Place .. '.txt';
end;

local ensureGlobalFolder: () -> () = function(): ()
	if isfolder and makefolder and not isfolder('velo/profiles/global') then
		makefolder('velo/profiles/global');
	end;
end;

local mergeProfileData: (old: table?, new: table) -> table = function(old: table?, new: table): table
	if type(old) ~= 'table' then
		return new;
	end;
	for _: number, section: string in {'Modules', 'Legit', 'Categories'} do
		local merged: table = type(old[section]) == 'table' and old[section] or {};
		for name: string, entry: any in new[section] or {} do
			local previous: any = merged[name];
			if type(previous) == 'table' and type(previous.Options) == 'table' and type(entry) == 'table' and type(entry.Options) == 'table' then
				for key: string, value: any in previous.Options do
					if entry.Options[key] == nil then
						entry.Options[key] = value;
					end;
				end;
			end;
			merged[name] = entry;
		end;
		new[section] = merged;
	end;
	if type(old.Gui) == 'table' then
		if type(new.Gui) ~= 'table' then
			new.Gui = old.Gui;
		elseif type(old.Gui.Settings) == 'table' and type(new.Gui.Settings) == 'table' then
			for name: string, paneData: any in old.Gui.Settings do
				if new.Gui.Settings[name] == nil then
					new.Gui.Settings[name] = paneData;
				end;
			end;
		end;
	end;
	return new;
end;

local color: table = {};
local uipallet: table = {};
do
	color.Dark = function(col: Color3, num: number): Color3
		local h: number, s: number, v: number = col:ToHSV();
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v + num or v - num, 0, 1));
	end;

	color.Light = function(col: Color3, num: number): Color3
		local h: number, s: number, v: number = col:ToHSV();
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v - num or v + num, 0, 1));
	end;

	vape.Color = function(self: table, h: number): (number, number, number)
		local s: number = 0.74 + (0.26 * math.min(h / 0.045, 1));

		if h > 0.577 then
			s = 1 - (0.48 * math.min((h - 0.577) / 0.088, 1));
		end;

		if h > 0.674 then
			s = 0.52 + (0.48 * math.min((h - 0.674) / 0.149, 1));
		end;

		if h > 0.869 then
			s = 1 - (0.26 * math.min((h - 0.869) / 0.131, 1));
		end;

		return h, s, 1;
	end;

	vape.TextColor = function(self: table, h: number, s: number, v: number): Color3
		if v >= 0.7 and (s < 0.6 or h > 0.04 and h < 0.56) then
			return Color3.new(0.19, 0.19, 0.19);
		end;

		return Color3.new(1, 1, 1);
	end;
end;

local getfontbounds: (text: string, size: number, font: Font?) -> Vector2 = function(text: string, size: number, font: Font?): Vector2
	fontsize.Text = text;
	fontsize.Size = size;
	if typeof(font) == 'Font' then
		fontsize.Font = font;
	end;

	return textService:GetTextBoundsAsync(fontsize);
end;

do
	local vapeAssets: table = {
		['velo/assets/new/add.png'] = 'rbxassetid://121642387707174',
		['velo/assets/new/aim.png'] = 'rbxassetid://122207028123421',
		['velo/assets/new/allowedicon.png'] = 'rbxassetid://112336790299036',
		['velo/assets/new/allowediconmini.png'] = 'rbxassetid://90142384730147',
		['velo/assets/new/arrowmodule.png'] = 'rbxassetid://14473354880',
		['velo/assets/new/back.png'] = 'rbxassetid://80523803497740',
		['velo/assets/new/backmini.png'] = 'rbxassetid://85859225495272',
		['velo/assets/new/bind.png'] = 'rbxassetid://81399857677684',
		['velo/assets/new/bindbkg.png'] = 'rbxassetid://101996225428926',
		['velo/assets/new/blatant.png'] = 'rbxassetid://126929923309265',
		['velo/assets/new/blur.png'] = 'rbxassetid://79246816170155',
		['velo/assets/new/blurnoti.png'] = 'rbxassetid://124705876663719',
		['velo/assets/new/close.png'] = 'rbxassetid://121816018671466',
		['velo/assets/new/closemini.png'] = 'rbxassetid://108320409341289',
		['velo/assets/new/closetiny.png'] = 'rbxassetid://71393233149714',
		['velo/assets/new/colorpreview.png'] = 'rbxassetid://140438628568318',
		['velo/assets/new/combat.png'] = 'rbxassetid://94762732349053',
		['velo/assets/new/customtheme.png'] = 'rbxassetid://91756736022800',
		['velo/assets/new/discord.png'] = 'rbxassetid://99871463341003',
		['velo/assets/new/downexpand.png'] = 'rbxassetid://94197751291504',
		['velo/assets/new/downexpandslider.png'] = 'rbxassetid://90289944682645',
		['velo/assets/new/edit.png'] = 'rbxassetid://105801951237137',
		['velo/assets/new/editlarge.png'] = 'rbxassetid://119233876755282',
		['velo/assets/new/expandarrow.png'] = 'rbxassetid://86360332526471',
		['velo/assets/new/friends.png'] = 'rbxassetid://92957214042038',
		['velo/assets/new/inventory.png'] = 'rbxassetid://93264756888499',
		['velo/assets/new/legit_mode_icon.png'] = 'rbxassetid://102858626075156',
		['velo/assets/new/legit_switch.png'] = 'rbxassetid://127508881124779',
		['velo/assets/new/min.png'] = 'rbxassetid://82175054487146',
		['velo/assets/new/noti_alert.png'] = 'rbxassetid://82356478726846',
		['velo/assets/new/noti_info.png'] = 'rbxassetid://102614825645099',
		['velo/assets/new/noti_warning.png'] = 'rbxassetid://128664271265613', -- Velocity's warning.png
		['velo/assets/new/notification.png'] = 'rbxassetid://90300780458781',
		['velo/assets/new/npcs.png'] = 'rbxassetid://104434365485227',
		['velo/assets/new/overlaydots.png'] = 'rbxassetid://78012624671930',
		['velo/assets/new/overlays.png'] = 'rbxassetid://136535637407545',
		['velo/assets/new/overlayslarge.png'] = 'rbxassetid://127574141208160',
		['velo/assets/new/pin.png'] = 'rbxassetid://92459145800579',
		['velo/assets/new/players.png'] = 'rbxassetid://105137446428129',
		['velo/assets/new/profiles.png'] = 'rbxassetid://126051451865127',
		['velo/assets/new/radar.png'] = 'rbxassetid://97983828696086',
		['velo/assets/new/radaricon.png'] = 'rbxassetid://14338041181',
		['velo/assets/new/rainbow_1.png'] = 'rbxassetid://101329996188554',
		['velo/assets/new/rainbow_2.png'] = 'rbxassetid://72739074644654',
		['velo/assets/new/rainbow_3.png'] = 'rbxassetid://100716555253397',
		['velo/assets/new/rainbow_4.png'] = 'rbxassetid://133424174227092',
		['velo/assets/new/range.png'] = 'rbxassetid://107794917650053',
		['velo/assets/new/rangeindicator.png'] = 'rbxassetid://107038094175283',
		['velo/assets/new/render.png'] = 'rbxassetid://125472576898654',
		['velo/assets/new/spotify.png'] = 'rbxassetid://13956951038630',
		['velo/assets/new/search.png'] = 'rbxassetid://115611852955611',
		['velo/assets/new/settingdots.png'] = 'rbxassetid://130896840048276',
		['velo/assets/new/settings.png'] = 'rbxassetid://73820177347303',
		['velo/assets/new/settingsmini.png'] = 'rbxassetid://115732118290997',
		['velo/assets/new/targetinfo.png'] = 'rbxassetid://121604266095276',
		['velo/assets/new/textgui.png'] = 'rbxassetid://99438663817412',
		['velo/assets/new/textguiicon.png'] = 'rbxassetid://14368355456',
		['velo/assets/new/theme.png'] = 'rbxassetid://111525258317113',
		['velo/assets/new/utility.png'] = 'rbxassetid://108303206513893',
		['velo/assets/new/vape.png'] = 'rbxassetid://92153855792786',
		['velo/assets/new/vapelogo.png'] = 'rbxassetid://126205920310261',
		['velo/assets/new/vapelogomini.png'] = 'rbxassetid://109041903452149',
		['velo/assets/new/v4.png'] = 'rbxassetid://102549752760489',
		['velo/assets/new/v4mini.png'] = 'rbxassetid://115213099001611',
		['velo/assets/new/world.png'] = 'rbxassetid://118917453153459'
	};

	local veloAssets: table = {
		['velo/assets/new/noti_warning.png'] = 'warning.png',
		['velo/assets/new/radaricon.png'] = 'radaricon.png',
		['velo/assets/new/warn.png'] = 'warn.png'
	};

	local vapeAssetCommit: any;
	local getVapeAssetCommit: () -> any = function(): any
		if not vapeAssetCommit then
			local _: boolean, page: any = pcall(function(): string
				return game:HttpGet('https://github.com/7GrandDadPGN/VapeCompiled');
			end);

			local commit: any = type(page) == 'string' and page:match('"currentOid":"(%x+)"');
			vapeAssetCommit = commit and #commit == 40 and commit or 'main';
		end;

		return vapeAssetCommit;
	end;

	local createDownloader: (text: string) -> () = function(text: string): ()
		if vape.Loaded ~= true then
			local downloader: TextLabel = vape.Downloader;
			if not downloader then
				downloader = Instance.new('TextLabel');
				downloader.BackgroundTransparency = 1;
				downloader.FontFace = uipallet.Font;
				downloader.Size = UDim2.new(1, 0, 0, 40);
				downloader.TextColor3 = Color3.new(1, 1, 1);
				downloader.TextSize = 20;
				downloader.TextStrokeTransparency = 0;
				downloader.Parent = vape.gui;
				vape.Downloader = downloader;
			end;

			downloader.Text = 'Downloading '..text;
		end;
	end;

	local downloadFile: (path: string, callback: ((path: string) -> any)?) -> ...any = function(path: string, callback: ((path: string) -> any)?): ...any
		local custom: any = veloAssets[path];
		if custom then
			path = 'velo/assets/new/'..custom;
		end;

		if not isfile(path) then
			createDownloader(path);

			local success: boolean, data: string = pcall(function(): string
				local repo: string = custom and 'Copiums/Velocity/'..readfile('velo/profiles/commit.txt') or '7GrandDadPGN/VapeCompiled/'..getVapeAssetCommit();
				return game:HttpGet('https://raw.githubusercontent.com/'..repo..'/'..select(1, path:gsub('velo/', '')), true);
			end);

			if not success or data == '404: Not Found' then
				error(data);
			end;

			if path:find('.lua') then
				data = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..data;
			end;

			writefile(path, data);
		end;

		return (callback or readfile)(path);
	end;

	getvapeasset = not inputService.TouchEnabled and getcustomasset and function(path: string): ...any
		return downloadFile(path, getcustomasset);
	end or function(path: string): any
		return vapeAssets[path] or '';
	end;
end;

local tween: table = setmetatable({}, {
	["__index"] = function(): table
		return {};
	end
});

do
	tween.Tween = function(self: table, obj: Instance, info: TweenInfo, goal: table, index: any): ()
		index = self[index or 'tweens'];
		if index[obj] then
			index[obj]:Cancel();
			index[obj] = nil;
		end;

		if obj.Parent and (obj:IsA('UIStroke') or obj.Visible) then
			index[obj] = tweenService:Create(obj, info, goal);
			index[obj].Completed:Once(function(): ()
				if index then
					index[obj] = nil;
					index = nil;
				end;
			end);

			index[obj]:Play();
		else
			for prop: any, value: any in goal do
				obj[prop] = value;
			end;
		end;
	end;

	tween.Cancel = function(self: table, obj: Instance, index: any): ()
		index = self[index or 'tweens'];

		if index[obj] then
			index[obj]:Cancel();
			index[obj] = nil;
		end;
	end;
end;

uipallet = {
	["Main"] = Color3.fromRGB(3, 3, 3),
	["Text"] = Color3.fromRGB(200, 200, 200),
	["Font"] = Font.fromEnum(Enum.Font.Gotham),
	["FontSemiBold"] = Font.fromEnum(Enum.Font.Gotham, Enum.FontWeight.SemiBold),
	["Tween"] = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
};

do
	local data: any = isfile('velo/profiles/color.txt') and loadJson('velo/profiles/color.txt');
	if data then
		uipallet.Main = data.Main and Color3.fromRGB(unpack(data.Main)) or uipallet.Main;
		uipallet.Text = data.Text and Color3.fromRGB(unpack(data.Text)) or uipallet.Text;
		uipallet.Font = data.Font and Font.new(
			data.Font:find('rbxasset') and data.Font
			or string.format('rbxasset://fonts/families/%s.json', data.Font)
		) or uipallet.Font;
		uipallet.FontSemiBold = Font.new(uipallet.Font.Family, Enum.FontWeight.SemiBold);
	end;

	fontsize.Font = uipallet.Font;
end;

local hairFont: any = Font.fromEnum(Enum.Font.Arial).Family;
local indent: (count: number) -> string = function(count: number): string
	return '<font family="'..hairFont..'">'..string.rep('\u{200A}', count)..'</font>';
end;

local richEscape: (text: any) -> any = function(text: any): any
	return (tostring(text):gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'));
end;

vape.Libraries = {
	["color"] = color,
	["getcustomasset"] = getvapeasset, 
	["getfontbounds"] = getfontbounds,
	["getfontsize"] = getfontbounds,
	["getvapeasset"] = getvapeasset,
	["tween"] = tween,
	["uipallet"] = uipallet,
};

local addBlur: (parent: Instance, notif: boolean?, old: boolean?) -> Instance = function(parent: Instance, notif: boolean?, old: boolean?): Instance
	local blur: Instance;
	if old then
		blur = Instance.new('ImageLabel');
		blur.Name = 'Blur';
		blur.Size = UDim2.new(1, 89, 1, 52);
		blur.Position = UDim2.fromOffset(-48, -31);
		blur.BackgroundTransparency = 1;
		blur.Image = getvapeasset('velo/assets/new/'..(notif and 'blurnoti' or 'blur')..'.png');
		blur.ScaleType = Enum.ScaleType.Slice;
		blur.SliceCenter = Rect.new(52, 31, 261, 502);
		blur.Parent = parent;
	else
		blur = Instance.new('UIShadow');
		blur.BlurRadius = UDim.new(0, 13);
		blur.Transparency = 0.25;
		blur.Parent = parent;
	end;

	return blur;
end;

local addCorner: (parent: Instance, radius: UDim?) -> UICorner = function(parent: Instance, radius: UDim?): UICorner
	local corner: UICorner = Instance.new('UICorner');
	corner.CornerRadius = radius or UDim.new(0, 5);
	corner.Parent = parent;

	return corner;
end;

local addCloseButton: (parent: Instance, mini: boolean?, offset: UDim2?) -> ImageButton = function(parent: Instance, mini: boolean?, offset: UDim2?): ImageButton
	local close: ImageButton = Instance.new('ImageButton');
	close.AutoButtonColor = false;
	close.BackgroundColor3 = Color3.new(1, 1, 1);
	close.BackgroundTransparency = 1;
	close.Image = getvapeasset('velo/assets/new/'..(mini and 'closemini' or 'close')..'.png');
	close.ImageColor3 = color.Light(uipallet.Text, 0.2);
	close.ImageTransparency = 0.5;
	close.Name = 'Close';
	close.Position = offset or (mini and UDim2.new(1, -28, 0, 11) or UDim2.new(1, -35, 0, 9));
	close.Size = mini and UDim2.fromOffset(20, 20) or UDim2.fromOffset(24, 24);
	close.Parent = parent;
	addCorner(close, UDim.new(1, 0));

	close.MouseEnter:Connect(function(): ()
		close.ImageTransparency = 0.3;
		tween:Tween(close, uipallet.Tween, {
			["BackgroundTransparency"] = 0.6
		});
	end);

	close.MouseLeave:Connect(function(): ()
		close.ImageTransparency = 0.5;
		tween:Tween(close, uipallet.Tween, {
			["BackgroundTransparency"] = 1
		});
	end);

	return close;
end;

local addDragHandler: (gui: GuiObject, window: GuiObject?) -> () = function(gui: GuiObject, window: GuiObject?): ()
	gui.InputBegan:Connect(function(input: InputObject): ()
		if window and not window.Visible then return; end;

		if
			(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and (input.Position.Y - gui.AbsolutePosition.Y < 40 or window)
		then
			local dragPosition: any = Vector2.new(
				gui.AbsolutePosition.X - input.Position.X,
				gui.AbsolutePosition.Y - input.Position.Y + guiService:GetGuiInset().Y
			) / scale.Scale;

			local releaseConnection: RBXScriptConnection;
			local moveConnection: RBXScriptConnection = inputService.InputChanged:Connect(function(newInput: InputObject): ()
				if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local position: any = newInput.Position;
					if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3;
						position = (position // 3) * 3;
					end;

					gui.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y);
				end;
			end);

			releaseConnection = input.Changed:Connect(function(): ()
				if input.UserInputState == Enum.UserInputState.End then
					moveConnection:Disconnect();
					releaseConnection:Disconnect();
				end;
			end);
		end;
	end);
end;

local addMaid: (obj: table) -> () = function(obj: table): ()
	obj.Connections = {};

	obj.Clean = function(self: table, callback: any): ()
		if typeof(callback) == 'Instance' then
			table.insert(self.Connections, {
				["Disconnect"] = function(): ()
					callback:ClearAllChildren();
					callback:Destroy();
				end
			});
		elseif type(callback) == 'thread' then
			table.insert(self.Connections, {
				["Disconnect"] = function(): ()
					if coroutine.status(callback) ~= 'dead' then
						task.cancel(callback);
					end;
				end
			});
		elseif type(callback) == 'function' then
			table.insert(self.Connections, {
				["Disconnect"] = callback
			});
		else
			table.insert(self.Connections, callback);
		end;
	end;
end;

local addTooltip: (gui: GuiObject, text: string?, customText: (() -> string)?, visCheck: (() -> boolean)?) -> () = function(gui: GuiObject, text: string?, customText: (() -> string)?, visCheck: (() -> boolean)?): ()
	if not text then return; end;

	local tooltipMoved: (x: number, y: number) -> () = function(x: number, y: number): ()
		if visCheck and visCheck() then
			return;
		end;

		local isRight: boolean = x + 16 + tooltip.Size.X.Offset > (scale.Scale * 1920);
		tooltip.Position = UDim2.fromOffset(
			(isRight and x - (tooltip.Size.X.Offset * scale.Scale) - 16 or x + 16) / scale.Scale,
			((y + 11) - (tooltip.Size.Y.Offset / 2)) / scale.Scale
		);

		tooltip.Visible = toolblur.Enabled;
	end;

	local callback: () -> () = function(): ()
		local newText: any = customText();
		tooltip.Text = newText;
		local tooltipSize: Vector2 = getfontbounds(tooltip.ContentText, tooltip.TextSize, uipallet.Font);
		tooltip.Size = UDim2.fromOffset(tooltipSize.X + 10, tooltipSize.Y + 10);
	end;

	gui.MouseEnter:Connect(function(x: number, y: number): ()
		if visCheck and visCheck() then
			return;
		end;

		tooltip.Text = text;
		local tooltipSize: Vector2 = getfontbounds(tooltip.ContentText, tooltip.TextSize, uipallet.Font);
		tooltip.Size = UDim2.fromOffset(tooltipSize.X + 10, tooltipSize.Y + 10);
		tooltipMoved(x, y);

		if customText then
			vape.CurrentTooltip = callback;
			callback();
		end;
	end);
	gui.MouseMoved:Connect(tooltipMoved);
	gui.MouseLeave:Connect(function(): ()
		if visCheck and visCheck() then
			return;
		end;

		tooltip.Visible = false;
		vape.CurrentTooltip = nil;
	end);
end;

local createSignal: () -> table = function(): table
	local signal: table = {
		["Connections"] = {}
	};

	signal.Connect = function(self: table, callback: (...any) -> ()): table
		table.insert(self.Connections, callback);

		return {
			["Disconnect"] = function(): ()
				local index: number? = table.find(signal.Connections, callback);
				if index then
					table.remove(signal.Connections, index);
				end;
			end
		};
	end;

	signal.Fire = function(self: table, ...: any): ()
		for _: any, callback: any in self.Connections do
			task.spawn(callback, ...);
		end;
	end;

	return signal;
end;

local checkKeybinds: (compare: {any}, target: any, key: any) -> boolean = function(compare: {any}, target: any, key: any): boolean
	if type(target) == 'table' then
		if table.find(target, key) then
			for _: any, key: any in target do
				if not table.find(compare, key) then
					return false;
				end;
			end;

			return true;
		end;
	end;

	return false;
end;

local getPlayerFromText: (text: string) -> any = function(text: string): any
	if text ~= '' then
		for _: number, plr: Player in playersService:GetPlayers() do
			if plr.Name:sub(1, #text):lower() == text:lower() then
				return plr.Name;
			end;
		end;
	end;
end;

local getTableSize: (dict: table) -> number = function(dict: table): number
	local size: number = 0;
	for _: any in dict do
		size += 1;
	end;

	return size;
end;

local loopClean: (obj: table) -> ();
loopClean = function(obj: table): ()
	for index: any, value: any in obj do
		if type(value) == 'table' then
			loopClean(value);
		end;

		obj[index] = nil;
	end;
end;

local randomString: () -> string = function(): string
	local array: table = {};
	for i: number = 1, math.random(10, 100) do
		array[i] = string.char(math.random(32, 126));
	end;

	return table.concat(array);
end;

local removeTags: (text: string) -> ...any = function(text: string): ...any
	text = text:gsub('<br%s*/>', '\n');
	return text:gsub('<[^<>]->', '');
end;

vape.BlurCheck = function(self: table): ()
	if self.ThreadFix then
		setthreadidentity(8);
		runService:SetRobloxGuiFocused((clickgui.Visible or guiService:GetErrorType() ~= Enum.ConnectionError.OK) and self.Blur.Enabled);
	end;
end;

vape.CreateCategory = function(self: table, props: table): table
	return components.Category(props);
end;

vape.CreateCategoryList = function(self: table, props: table): table
	return components.CategoryList(props);
end;

local colorAnim: table = {
	["Palette"] = 'Rainbow',
	["Effect"] = 'Smooth',
	["Spread"] = 1,
	["Speed"] = 1,
	["Count"] = 3,
	["Phase"] = 0,
	["Custom"] = {
		Color3.fromRGB(255, 0, 128),
		Color3.fromRGB(128, 0, 255),
		Color3.fromRGB(0, 200, 255),
		Color3.fromRGB(0, 255, 150),
		Color3.fromRGB(255, 200, 0)
	}
};

local colorPalettes: table = {
	["Sunset"] = {Color3.fromRGB(255, 94, 77), Color3.fromRGB(255, 154, 0), Color3.fromRGB(255, 206, 84), Color3.fromRGB(237, 85, 147)},
	["Ocean"] = {Color3.fromRGB(0, 90, 200), Color3.fromRGB(0, 180, 216), Color3.fromRGB(72, 202, 228), Color3.fromRGB(0, 119, 182)},
	["Aurora"] = {Color3.fromRGB(0, 255, 163), Color3.fromRGB(0, 210, 255), Color3.fromRGB(128, 90, 255)},
	["Fire"] = {Color3.fromRGB(255, 40, 0), Color3.fromRGB(255, 120, 0), Color3.fromRGB(255, 200, 0)},
	["Vaporwave"] = {Color3.fromRGB(255, 113, 206), Color3.fromRGB(1, 205, 254), Color3.fromRGB(185, 103, 255)},
	["Toxic"] = {Color3.fromRGB(57, 255, 20), Color3.fromRGB(180, 255, 0), Color3.fromRGB(0, 255, 140)},
	["Candy"] = {Color3.fromRGB(255, 92, 168), Color3.fromRGB(255, 190, 230), Color3.fromRGB(140, 200, 255)},
	["Ice"] = {Color3.fromRGB(180, 240, 255), Color3.fromRGB(100, 200, 255), Color3.fromRGB(230, 250, 255)},
	["Blood"] = {Color3.fromRGB(180, 0, 20), Color3.fromRGB(255, 30, 60), Color3.fromRGB(120, 0, 10)},
	["Galaxy"] = {Color3.fromRGB(100, 40, 255), Color3.fromRGB(200, 60, 255), Color3.fromRGB(40, 120, 255), Color3.fromRGB(255, 80, 200)},
	["Mint"] = {Color3.fromRGB(62, 255, 190), Color3.fromRGB(160, 255, 220), Color3.fromRGB(0, 200, 150)},
	["Gold"] = {Color3.fromRGB(255, 190, 40), Color3.fromRGB(255, 230, 130), Color3.fromRGB(200, 140, 20)},
	["Mono"] = {Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 120, 120)}
};

local paletteNames: {string} = {'Rainbow', 'Sunset', 'Ocean', 'Aurora', 'Fire', 'Vaporwave', 'Toxic', 'Candy', 'Ice', 'Blood', 'Galaxy', 'Mint', 'Gold', 'Mono', 'Custom'};

local samplePalette: (t: number, smooth: boolean) -> Color3 = function(t: number, smooth: boolean): Color3
	if colorAnim["Palette"] == 'Rainbow' then
		return Color3.fromHSV(vape:Color(smooth and t or math.floor(t * 8) / 8));
	end;
	local isCustom: boolean = colorAnim["Palette"] == 'Custom';
	local list: {Color3} = isCustom and colorAnim["Custom"] or colorPalettes[colorAnim["Palette"]] or colorPalettes["Sunset"];
	local count: number = isCustom and math.clamp(colorAnim["Count"], 1, #list) or #list;
	local position: number = t * count;
	local index: number = math.floor(position);
	local first: Color3 = list[index % count + 1];
	if not smooth then
		return first;
	end;
	return first:Lerp(list[(index + 1) % count + 1], position - index);
end;

vape.SampleColor = function(self: table, offset: number): Color3
	if not self.GUIColor.Rainbow then
		return Color3.fromHSV(self:Color((self.GUIColor.Hue - offset) % 1));
	end;
	local position: number = (colorAnim["Phase"] - offset) * colorAnim["Spread"];
	local effect: string = colorAnim["Effect"];
	local result: Color3 = samplePalette(position % 1, effect ~= 'Step');
	if effect == 'Pulse' then
		local wave: number = 0.5 + 0.5 * math.cos(position * math.pi * 6);
		result = result:Lerp(Color3.new(), (1 - wave) * 0.55);
	elseif effect == 'Shine' then
		local sweep: number = (position * 2) % 1;
		result = result:Lerp(Color3.new(1, 1, 1), math.max(0, 1 - math.abs(sweep - 0.5) * 8) * 0.75);
	end;
	return result;
end;

vape.AnimatedTextColor = function(self: table, fill: Color3): Color3
	if colorAnim["Palette"] == 'Rainbow' and colorAnim["Effect"] ~= 'Pulse' then
		return Color3.new(0.19, 0.19, 0.19);
	end;
	local luminance: number = fill.R * 0.299 + fill.G * 0.587 + fill.B * 0.114;
	return luminance > 0.5 and Color3.new(0.19, 0.19, 0.19) or Color3.new(1, 1, 1);
end;

local notifStyle: table = {
	["Background"] = 'Default',
	["Color"] = Color3.fromHSV(0, 0, 0.06),
	["Opacity"] = 0.8,
	["Image"] = '',
	["Transparency"] = 0,
	["Corner"] = 6,
	["Icons"] = {["info"] = '', ["warning"] = '', ["alert"] = ''},
	["IconSize"] = 20,
	["TextSize"] = 14
};

local parseAsset: (value: any) -> string? = function(value: any): string?
	if type(value) ~= 'string' then
		return nil;
	end;
	local text: string = value:match('^%s*(.-)%s*$') or '';
	if text == '' then
		return nil;
	end;
	if text:match('^%d+$') then
		return 'rbxassetid://' .. text;
	end;
	if text:match('^rbx') then
		return text;
	end;
	if getcustomasset then
		local success: boolean, asset: any = pcall(function(): any
			return isfile(text) and getcustomasset(text) or nil;
		end);
		if success and type(asset) == 'string' and asset ~= '' then
			return asset;
		end;
	end;
	local id: string? = text:match('%d+');
	return id and 'rbxassetid://' .. id or nil;
end;

local sameFont: (a: Font, b: Font) -> boolean = function(a: Font, b: Font): boolean
	return a.Family == b.Family and a.Weight == b.Weight and a.Style == b.Style;
end;

vape.CreateNotification = function(self: table, title: string, text: string, duration: number, kind: string?): ()
	if not self.Notifications.Enabled then
		return;
	end;

	task.delay(0, function(): ()
		if self.Loaded == nil then
			return;
		end;

		if self.ThreadFix then
			setthreadidentity(8);
		end;

		local style: table = notifStyle;
		local kindName: string = kind or 'info';
		local mode: string = style["Background"];
		local textSize: number = style["TextSize"];
		local iconSize: number = style["IconSize"];
		local regularFont: Font = style["Font"] or uipallet.Font;
		local boldFont: Font = style["Font"] and Font.new(style["Font"].Family, Enum.FontWeight.SemiBold, style["Font"].Style) or uipallet.FontSemiBold;
		local textX: number = math.max(46, math.floor(36 + iconSize / 2));
		local bodyY: number = 16 + math.floor(textSize * 2);
		local height: number = bodyY + textSize + 17;
		local plainText: string = removeTags(text);
		local customImage: string? = mode == 'Image' and parseAsset(style["Image"]) or nil;
		local customIcon: string? = parseAsset(style["Icons"][kindName]);
		local rounded: boolean = mode == 'Color' or customImage ~= nil;
		local light: boolean = mode == 'Color' and style["Opacity"] > 0.5 and vape:TextColor(style["Color"]:ToHSV()).R < 0.5;

		local offset: number = 29 + height + 3;
		for _: number, child: any in notifications:GetChildren() do
			offset += child.Size.Y.Offset + 3;
		end;

		local notification: ImageLabel = Instance.new('ImageLabel');
		notification.BackgroundTransparency = 1;
		notification.Position = UDim2.new(1, 0, 1, -offset);
		notification.Size = UDim2.fromOffset(266, height);
		notification.ZIndex = 5;
		if mode == 'Color' then
			notification.BackgroundColor3 = style["Color"];
			notification.BackgroundTransparency = 1 - style["Opacity"];
		elseif customImage then
			notification.Image = customImage;
			notification.ImageTransparency = style["Transparency"];
			notification.ScaleType = Enum.ScaleType.Crop;
		else
			notification.Image = getvapeasset('velo/assets/new/notification.png');
			notification.ImageTransparency = style["Transparency"];
			notification.ScaleType = Enum.ScaleType.Slice;
			notification.SliceCenter = Rect.new(7, 7, 9, 9);
		end;
		if rounded then
			addCorner(notification, UDim.new(0, style["Corner"]));
		end;
		notification.Parent = notifications;
		local blur: ImageLabel = addBlur(notification, true, true);
		blur.ImageTransparency = mode == 'Color' and 1 - style["Opacity"] or style["Transparency"];

		local iconBox: number = customIcon and iconSize or iconSize * 3;
		local iconY: number = 15 + math.floor(textSize / 2);
		local iconshadow: ImageLabel = Instance.new('ImageLabel');
		iconshadow.BackgroundTransparency = 1;
		iconshadow.Image = customIcon or getvapeasset('velo/assets/new/noti_' .. kindName .. '.png');
		iconshadow.ImageColor3 = Color3.new();
		iconshadow.ImageTransparency = 0.5;
		iconshadow.Position = UDim2.fromOffset(25 - math.floor(iconBox / 2), iconY - math.floor(iconBox / 2));
		iconshadow.Size = UDim2.fromOffset(iconBox, iconBox);
		iconshadow.ZIndex = 5;
		iconshadow.Parent = notification;
		local icon: ImageLabel = iconshadow:Clone();
		icon.ImageColor3 = Color3.new(1, 1, 1);
		icon.ImageTransparency = 0;
		icon.Position = UDim2.fromOffset(-1, -1);
		icon.Parent = iconshadow;

		local label: TextLabel = Instance.new('TextLabel');
		label.BackgroundTransparency = 1;
		label.FontFace = boldFont;
		label.Position = UDim2.fromOffset(textX, 16);
		label.RichText = true;
		label.Size = UDim2.new(1, -(textX + 10), 0, textSize + 6);
		label.Text = "<stroke joins='round' thickness='0.3' transparency='0.5'>" .. title .. '</stroke>';
		label.TextColor3 = kindName == 'alert' and Color3.fromRGB(250, 50, 56) or light and Color3.fromRGB(30, 30, 30) or Color3.new(1, 1, 1);
		label.TextSize = textSize;
		label.TextXAlignment = Enum.TextXAlignment.Left;
		label.TextYAlignment = Enum.TextYAlignment.Top;
		label.ZIndex = 5;
		label.Parent = notification;
		local textshadow: TextLabel = label:Clone();
		textshadow.FontFace = regularFont;
		textshadow.Position = UDim2.fromOffset(textX + 1, bodyY);
		textshadow.RichText = false;
		textshadow.Text = plainText;
		textshadow.TextColor3 = Color3.new();
		textshadow.TextTransparency = light and 0.85 or 0.5;
		textshadow.Parent = notification;
		local textlabel: TextLabel = textshadow:Clone();
		textlabel.Position = UDim2.fromOffset(-1, -1);
		textlabel.RichText = true;
		textlabel.Text = text;
		textlabel.TextColor3 = light and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(170, 170, 170);
		textlabel.TextTransparency = 0;
		textlabel.Parent = textshadow;

		local progress: Frame = Instance.new('Frame');
		progress.BackgroundColor3 = kindName == 'alert' and Color3.fromRGB(250, 50, 56)
			or kindName == 'warning' and Color3.fromRGB(108, 110, 237)
			or light and Color3.fromRGB(40, 40, 40)
			or Color3.new(1, 1, 1);
		progress.BorderSizePixel = 0;
		progress.Position = UDim2.new(0, 3, 1, -4);
		progress.Size = UDim2.new(1, -13, 0, 1);
		progress.ZIndex = 5;
		if rounded then
			local radius: number = math.min(style["Corner"], height / 2);
			local inset: number = radius > 4 and math.max(3, math.ceil(radius - math.sqrt(radius * radius - (radius - 4) ^ 2))) or 3;
			progress.Position = UDim2.new(0, inset, 1, -4);
			progress.Size = UDim2.new(1, -inset * 2, 0, 1);
		end;
		progress.Parent = notification;

		local bodyWidth: number = getfontbounds(plainText, textSize, regularFont).X;
		local titleWidth: number = getfontbounds(removeTags(tostring(title)), textSize, boldFont).X;
		notification.Size = UDim2.fromOffset(math.max(bodyWidth + textX + 34, titleWidth + textX + 16, 266), height);

		if tween.Tween then
			tween:Tween(notification, TweenInfo.new(0.326, Enum.EasingStyle.Exponential), {
				["AnchorPoint"] = Vector2.new(1, 0)
			}, 'tweenstwo');

			tween:Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				["Size"] = UDim2.fromOffset(0, 1)
			});
		end;

		task.delay(duration, function(): ()
			if tween.Tween then
				tween:Tween(notification, TweenInfo.new(0.326, Enum.EasingStyle.Exponential), {
					["AnchorPoint"] = Vector2.new(0, 0)
				}, 'tweenstwo');
			end;

			task.wait(0.2);
			notification:ClearAllChildren();
			notification:Destroy();
		end);
	end);
end;

vape.SetFont = function(self: table, font: Font): ()
	local oldRegular: Font = uipallet.Font;
	local oldBold: Font = uipallet.FontSemiBold;
	local heavy: boolean = font.Weight.Value >= Enum.FontWeight.SemiBold.Value;
	local newRegular: Font = Font.new(font.Family, font.Weight, font.Style);
	local newBold: Font = Font.new(font.Family, heavy and font.Weight or Enum.FontWeight.SemiBold, font.Style);
	if sameFont(oldRegular, newRegular) and sameFont(oldBold, newBold) then
		return;
	end;
	uipallet.Font = newRegular;
	uipallet.FontSemiBold = newBold;
	fontsize.Font = newRegular;
	if not gui then
		return;
	end;

	local skipped: {Instance} = {};
	for _: any, category: table in self.Categories do
		if category.Type == 'Overlay' and typeof(category.Children) == 'Instance' then
			table.insert(skipped, category.Children);
		end;
	end;
	if self.Legit then
		for _: any, module: table in self.Legit.Modules do
			if typeof(module.Children) == 'Instance' then
				table.insert(skipped, module.Children);
			end;
		end;
	end;

	for _: number, obj: any in gui:GetDescendants() do
		if obj:IsA('TextLabel') or obj:IsA('TextButton') or obj:IsA('TextBox') then
			local face: Font = obj.FontFace;
			local target: Font? = sameFont(face, oldRegular) and newRegular or sameFont(face, oldBold) and newBold or nil;
			if target then
				local inside: boolean = false;
				for _: any, root: Instance in skipped do
					if obj:IsDescendantOf(root) then
						inside = true;
						break;
					end;
				end;
				if not inside then
					obj.FontFace = target;
				end;
			end;
		end;
	end;

	if self.ProfileLabel then
		self.ProfileLabel.Size = UDim2.fromOffset(getfontbounds(self.ProfileLabel.Text, self.ProfileLabel.TextSize, newRegular).X + 16, 24);
	end;
end;

vape.CreateOverlay = function(self: table, props: table): table
	return components.Overlay(props);
end;

vape.Load = function(self: table, skipgui: boolean?, profile: string?): any
	local guiData: table = {["Categories"] = {}};
	local oldProfile: any = self.Profile;
	local canSave: boolean = true;
	local toggleCount: number = 0;

	if isfile('velo/profiles/'..game.GameId..'.gui.txt') then
		guiData = loadJson('velo/profiles/'..game.GameId..'.gui.txt');
		if not guiData then
			guiData = {["Categories"] = {}};
			self:CreateNotification('Vape', 'Failed to load GUI settings.', 10, 'alert');
			canSave = false;
		end;

		if guiData.v ~= 1 then
			guiData.Categories.Main = nil;
		end;

		self.Profile = profile or guiData.Profile or 'default';
		if self.ProfileLabel then
			local shown: string = profileDisplay(self.Profile);
			self.ProfileLabel.Text = #shown > 10 and shown:sub(1, 10)..'...' or shown;
			self.ProfileLabel.Size = UDim2.fromOffset(getfontbounds(self.ProfileLabel.Text, self.ProfileLabel.TextSize, self.ProfileLabel.Font).X + 16, 24);
		end;

		if not skipgui then
			for name: any, data: any in guiData.Categories do
				local category: any = self.Categories[name];
				if category then
					category:Load(data);
				end;
			end;
		end;
	end;

	self.Categories.Profiles:LoadGlobal();
	if not self.Categories.Profiles:GetValue('default') then
		self.Categories.Profiles:ChangeValue('default', true, false);
	end;

	if isfile(profilePath(self.Profile)) then
		local mainData: table = loadJson(profilePath(self.Profile));
		if not mainData then
			mainData = {["Categories"] = {}, ["Modules"] = {}, ["Legit"] = {}};
			self:CreateNotification('Vape', 'Failed to load '..profileDisplay(self.Profile)..' profile.', 10, 'alert');
			canSave = false;
		end;

		if mainData.v ~= 1 then
			for _: any, data: any in mainData.Modules do
				data.Bind = {["Keys"] = data.Bind};
				data.Visible = true;
			end;
		end;

		for name: any, data: any in mainData.Categories do
			local category: any = self.Categories[name];
			if category then
				category:Load(data);
			end;
		end;

		for name: any, data: any in mainData.Modules do
			local module: any = self.Modules[name];
			if module then
				module:Load(data);
				toggleCount += module.Enabled and 1 or 0;
			end;
		end;

		for name: any, data: any in mainData.Legit do
			local module: any = self.Legit.Modules[name];
			if module then
				module:Load(data);
			end;
		end;

		if isGlobalProfile(self.Profile) then
			self:LoadGuiSettings(mainData.Gui);
		end;

		self:UpdateTextGUI(true);
	else
		self:Save();
	end;

	if self.Profile ~= oldProfile and skipgui then
		self:CreateNotification('Profile swap to <font color="#FFAA00">'..profileDisplay(self.Profile)..(isGlobalProfile(self.Profile) and ' (All Games)' or '')..'</font>', toggleCount..' modules enabled', 3);
	end;

	if self.Downloader then
		self.Downloader:Destroy();
		self.Downloader = nil;
	end;

	self.Loaded = canSave;

	if not skipgui then
		self:createVapeButton();
	end;

	return toggleData;
end;

vape.createVapeButton = function(self: table): ()
	if self.VapeButton then
		self.VapeButton:Destroy();
		self.VapeButton = nil;
	end;

	local keys: any = self.GUIBind.Keys;
	if inputService.TouchEnabled or #keys == 1 or keys[1] == 'RightShift' then
		local button: TextButton = Instance.new('TextButton');
		button.BackgroundColor3 = Color3.new();
		button.BackgroundTransparency = 0.5;
		button.Position = UDim2.new(1, -90, 0, 4);
		button.Size = UDim2.fromOffset(32, 32);
		button.Text = '';
		button.Parent = gui;
		local image: ImageLabel = Instance.new('ImageLabel');
		image.BackgroundTransparency = 1;
		image.Image = getvapeasset('velo/assets/new/radaricon.png');
		image.Position = UDim2.fromOffset(3, 3);
		image.Size = UDim2.fromOffset(26, 26);
		image.Parent = button;
		addCorner(button, UDim.new(0, 8));
		self.VapeButton = button;

		local buttonPath: string = 'velo/profiles/vapebutton.txt';
		local setPosition: (x: number, y: number) -> () = function(x: number, y: number): ()
			local screen: Vector2 = gui.AbsoluteSize;
			button.Position = UDim2.new(1, math.clamp(x, -math.max(screen.X, 32), -32), 0, math.clamp(y, 0, math.max(screen.Y - 32, 0)));
		end;

		local saved: any = isfile(buttonPath) and loadJson(buttonPath);
		if type(saved) == 'table' and type(saved.X) == 'number' and type(saved.Y) == 'number' then
			setPosition(saved.X, saved.Y);
		end;

		local dragInput: InputObject? = nil;
		local dragStart: Vector3 = Vector3.zero;
		local startOffset: Vector2 = Vector2.zero;
		local dragged: boolean = false;

		button.InputBegan:Connect(function(input: InputObject): ()
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input;
				dragStart = input.Position;
				startOffset = Vector2.new(button.Position.X.Offset, button.Position.Y.Offset);
				dragged = false;
			end;
		end);

		local moveConnection: RBXScriptConnection = inputService.InputChanged:Connect(function(input: InputObject): ()
			if not dragInput then
				return;
			end;
			if input == dragInput or dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta: Vector3 = input.Position - dragStart;
				if not dragged and delta.Magnitude < 6 then
					return;
				end;
				dragged = true;
				setPosition(startOffset.X + delta.X, startOffset.Y + delta.Y);
			end;
		end);

		local endConnection: RBXScriptConnection = inputService.InputEnded:Connect(function(input: InputObject): ()
			if not dragInput then
				return;
			end;
			if input == dragInput or dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragInput = nil;
				if dragged then
					writefile(buttonPath, httpService:JSONEncode({["X"] = button.Position.X.Offset, ["Y"] = button.Position.Y.Offset}));
				end;
			end;
		end);

		button.Destroying:Connect(function(): ()
			moveConnection:Disconnect();
			endConnection:Disconnect();
		end);

		button.MouseButton1Click:Connect(function(): ()
			if dragged then
				return;
			end;
			self.GUIBind.Triggered:Fire(true);
		end);
	end;
end;

vape.LoadOptions = function(self: table, obj: table, data: table): ()
	for name: any, componentData: any in data do
		local component: any = obj.Options[name];

		if component then
			component:Load(componentData);
		end;
	end;
end;

vape.LoadGUI = function(self: table): ()
	addMaid(vape);
	gui = Instance.new('ScreenGui');
	gui.Name = randomString();
	gui.DisplayOrder = 9999999;
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
	gui.IgnoreGuiInset = true;
	
	if vape.ThreadFix then
		local holder: Folder = Instance.new('Folder');
		holder.Parent = cloneref(game:GetService('CoreGui'));
		gui.OnTopOfCoreBlur = true;
		gui.Parent = (gethui and gethui()) or cloneref(game:GetService('CoreGui'));
		vape.holder = holder;
	else
		gui.Parent = cloneref(game:GetService('Players')).LocalPlayer.PlayerGui;
		gui.ResetOnSpawn = false;
		vape.holder = gui;
	end;
	vape.gui = gui;
	
	scaledgui = Instance.new('Frame');
	scaledgui.BackgroundTransparency = 1;
	scaledgui.Name = 'ScaledGui';
	scaledgui.Size = UDim2.fromScale(1, 1);
	scaledgui.Parent = gui;
	clickgui = Instance.new('Frame');
	clickgui.BackgroundTransparency = 1;
	clickgui.Name = 'ClickGui';
	clickgui.Size = UDim2.fromScale(1, 1);
	clickgui.Visible = false;
	clickgui.Parent = scaledgui;
	local scarcitybanner: TextLabel = Instance.new('TextLabel');
	scarcitybanner.BackgroundTransparency = 1;
	scarcitybanner.FontFace = uipallet.Font;
	scarcitybanner.Position = UDim2.fromScale(0, 0.97);
	scarcitybanner.Size = UDim2.fromScale(1, 0.018);
	scarcitybanner.Text = 'All update logs and game support are found in the discord, click the discord icon to join.';
	scarcitybanner.TextColor3 = Color3.new(1, 1, 1);
	scarcitybanner.TextScaled = true;
	scarcitybanner.TextStrokeTransparency = 0.5;
	scarcitybanner.Parent = clickgui;
	local modal: TextButton = Instance.new('TextButton');
	modal.BackgroundTransparency = 1;
	modal.Modal = true;
	modal.Text = '';
	modal.Parent = clickgui;
	local cursor: ImageLabel = Instance.new('ImageLabel');
	cursor.BackgroundTransparency = 1;
	cursor.Image = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png';
	cursor.Size = UDim2.fromOffset(64, 64);
	cursor.Visible = false;
	cursor.Parent = gui;
	notifications = Instance.new('Folder');
	notifications.Name = 'Notifications';
	notifications.Parent = scaledgui;
	tooltip = Instance.new('TextLabel');
	tooltip.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
	tooltip.FontFace = uipallet.Font;
	tooltip.Position = UDim2.fromScale(-1, -1);
	tooltip.RichText = true;
	tooltip.Text = '';
	tooltip.TextColor3 = color.Dark(uipallet.Text, 0.16);
	tooltip.TextSize = 12;
	tooltip.Visible = false;
	tooltip.ZIndex = 5;
	tooltip.Parent = scaledgui;
	toolblur = addBlur(tooltip);
	addCorner(tooltip);
	scale = Instance.new('UIScale');
	scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6);
	scale.Parent = scaledgui;
	scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale);
	components.GUI({});
	
	vape:CreateCategory({
		["Name"] = 'Combat',
		["Icon"] = getvapeasset('velo/assets/new/combat.png'),
		["Size"] = UDim2.fromOffset(13, 14)
	});
	vape:CreateCategory({
		["Name"] = 'Blatant',
		["Icon"] = getvapeasset('velo/assets/new/blatant.png'),
		["Size"] = UDim2.fromOffset(14, 14)
	});
	vape:CreateCategory({
		["Name"] = 'Render',
		["Icon"] = getvapeasset('velo/assets/new/render.png'),
		["Size"] = UDim2.fromOffset(15, 14)
	});
	vape:CreateCategory({
		["Name"] = 'Utility',
		["Icon"] = getvapeasset('velo/assets/new/utility.png'),
		["Size"] = UDim2.fromOffset(15, 14)
	});
	vape:CreateCategory({
		["Name"] = 'World',
		["Icon"] = getvapeasset('velo/assets/new/world.png'),
		["Size"] = UDim2.fromOffset(14, 14)
	});
	vape:CreateCategory({
		["Name"] = 'Inventory',
		["Icon"] = getvapeasset('velo/assets/new/inventory.png'),
		["Size"] = UDim2.fromOffset(15, 14)
	});
	vape.Categories.Main:CreateDivider({
		["Text"] = 'velocity'
	});
	vape:CreateCategory({ 
		["Name"] = 'Velocity',
		["Icon"] = getvapeasset('velo/assets/new/radaricon.png'),
		["Size"] = UDim2.fromOffset(14, 14)
	});
	vape.Categories.Main:CreateDivider({
		["Text"] = 'misc'
	});

	--[[
		Friends
	]]
	do
		local friends: table;
		local friendscolor: table = {
			["Hue"] = 1,
			["Sat"] = 1,
			["Value"] = 1
		};
	
		friends = vape:CreateCategoryList({
			["Name"] = 'Friends',
			["Icon"] = getvapeasset('velo/assets/new/friends.png'),
			["Size"] = UDim2.fromOffset(17, 16),
			["Placeholder"] = 'Roblox username',
			["Color"] = Color3.fromRGB(5, 134, 105),
			["Player"] = true,
			["Function"] = function(): ()
				friends.Update:Fire();
				friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value);
			end
		});
		friends.Update = Instance.new('BindableEvent');
		friends.ColorUpdate = Instance.new('BindableEvent');
		friends:CreateToggle({
			["Name"] = 'Recolor visuals',
			["Darker"] = true,
			["Default"] = true,
			["Function"] = function(): ()
				friends.Update:Fire();
				friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value);
			end
		});
		friendscolor = friends:CreateColorSlider({
			["Name"] = 'Friends color',
			["Darker"] = true,
			["Function"] = function(hue: number, sat: number, val: number): ()
				for _: number, v: Instance in friends.Object.Children:GetChildren() do
					local dot: Instance? = v:FindFirstChild('Dot');
					if dot and dot.BackgroundColor3 ~= color.Light(uipallet.Main, 0.37) then
						dot.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
						dot.Dot.BackgroundColor3 = dot.BackgroundColor3;
					end;
				end;
	
				friends.ColorUpdate:Fire(hue, sat, val);
			end
		});
		friends:CreateToggle({
			["Name"] = 'Use friends',
			["Darker"] = true,
			["Default"] = true,
			["Function"] = function(): ()
				friends.Update:Fire();
				friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value);
			end
		});
		vape:Clean(friends.Update);
		vape:Clean(friends.ColorUpdate);
	end;
	
	--[[
		Profiles
	]]
	vape:CreateCategoryList({
		["Name"] = 'Profiles',
		["Icon"] = getvapeasset('velo/assets/new/profiles.png'),
		["Size"] = UDim2.fromOffset(17, 10),
		["Position"] = UDim2.fromOffset(12, 16),
		["Placeholder"] = 'Type name',
		["Profiles"] = true
	});
	
	--[[
		Targets
	]]
	local targets: table;
	targets = vape:CreateCategoryList({
		["Name"] = 'Targets',
		["Icon"] = getvapeasset('velo/assets/new/friends.png'),
		["Size"] = UDim2.fromOffset(17, 16),
		["Placeholder"] = 'Roblox username',
		["Player"] = true,
		["Function"] = function(): ()
			targets.Update:Fire();
		end
	});
	targets.Update = Instance.new('BindableEvent');
	vape:Clean(targets.Update);
	
	components.LegitWindow();
	vape.SearchBar = components.SearchBar();
	vape.Categories.Main:CreateOverlayBar();
	
	--[[
		General Settings
	]]
	
	local general: table = vape.Categories.Main.Settings:CreateSettingsPane({["Name"] = 'General'});
	local settingConnections: table = {};
	vape.MultiKeybind = general:CreateToggle({
		["Name"] = 'Enable Multi-Keybinding',
		["Tooltip"] = 'Allows multiple keys to be bound to a module (eg. G + H)'
	});
	general:CreateToggle({
		["Name"] = 'Allow setting keybinds',
		["Function"] = function(callback: boolean): ()
			if callback then
				for _: number, container: any in {vape.Modules, vape.Legit.Modules} do
					for _: any, module: any in container do
						for _: any, component: any in module.Options do
							if component.Type == 'Toggle' then
								local bind: table = components.Bind({
									["Module"] = true
								}, nil, component);
								bind.Object.Position = UDim2.new(1, -40, 0, 5);
	
								table.insert(settingConnections, bind.Triggered:Connect(function(isDown: boolean): ()
									if bind.Hold then
										if component.Enabled ~= isDown then
											if vape.SettingToggleNotifications.Enabled then
												vape:CreateNotification(module.Name, component.Name..' '..(not component.Enabled and "<font color='#00AA00'>ON</font>" or "<font color='#FF5A5A'>OFF</font>"), 1.5);
											end;
	
											component:Toggle();
										end;
									else
										if vape.SettingToggleNotifications.Enabled then
											vape:CreateNotification(module.Name, component.Name..' '..(not component.Enabled and "<font color='#00AA00'>ON</font>" or "<font color='#FF5A5A'>OFF</font>"), 1.5);
										end;
	
										component:Toggle();
									end;
								end));
	
								table.insert(settingConnections, component.Object.MouseEnter:Connect(function(): ()
									bind:SetVisible(true);
								end));
	
								table.insert(settingConnections, component.Object.MouseLeave:Connect(function(): ()
									bind:SetVisible(false);
								end));
							end;
						end;
					end;
				end;
			else
				for _: number, container: any in {vape.Modules, vape.Legit.Modules} do
					for _: any, module: any in container do
						for _: any, component: any in module.Options do
							if component.Bind then
								component.Bind:Destroy();
							end;
						end;
					end;
				end;
	
				for _: any, connection: any in settingConnections do
					connection:Disconnect();
				end;
				table.clear(settingConnections);
			end;
		end,
		["Tooltip"] = 'Hover a toggle setting to bind it to a key'
	});
	
	general:CreateButton({
		["Name"] = 'Reset current profile',
		["Function"] = function(): ()
		vape.Save = function(): () end;
			if isfile(profilePath(vape.Profile)) and delfile then
				delfile(profilePath(vape.Profile));
			end;
	
			shared.veloreload = true;
			if shared.VeloDeveloper then
				loadstring(readfile('velo/loader.lua'), 'loader')();
			else
				loadstring(game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/loader.lua', true))();
			end;
		end,
		["Tooltip"] = 'This will set your profile to the default settings of Vape'
	});
	
	general:CreateButton({
		["Name"] = 'Self destruct',
		["Function"] = function(): ()
			vape:Uninject();
		end,
		["Tooltip"] = 'Removes vape from the current game'
	});
	
	general:CreateButton({
		["Name"] = 'Reinject',
		["Function"] = function(): ()
			shared.veloreload = true;
			if shared.VeloDeveloper then
				loadstring(readfile('velo/loader.lua'), 'loader')();
			else
				loadstring(game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/loader.lua', true))();
			end;
		end,
		["Tooltip"] = 'Reloads vape for debugging purposes'
	});
	
	--[[
		Module Settings
	]]
	
	local modules: table = vape.Categories.Main.Settings:CreateSettingsPane({["Name"] = 'Modules'});
	modules:CreateToggle({
		["Name"] = 'Teams by server',
		["Tooltip"] = 'Ignore players on your team designated by the server',
		["Default"] = true,
		["Function"] = function(): ()
			if vape.Libraries.entity and vape.Libraries.entity.Running then
				vape.Libraries.entity.refresh();
			end;
		end
	});
	
	modules:CreateToggle({
		["Name"] = 'Use team color',
		["Tooltip"] = 'Uses the TeamColor property on players for render modules',
		["Default"] = true,
		["Function"] = function(): ()
			if vape.Libraries.entity and vape.Libraries.entity.Running then
				vape.Libraries.entity.refresh();
			end;
		end
	});
	
	--[[
		GUI Settings
	]]
	
	local guipane: table = vape.Categories.Main.Settings:CreateSettingsPane({["Name"] = 'GUI'});
	vape.Blur = guipane:CreateToggle({
		["Name"] = 'Blur background',
		["Function"] = function(): ()
			vape:BlurCheck();
		end,
		["Default"] = true,
		["Tooltip"] = 'Blur the background of the GUI'
	});
	
	guipane:CreateToggle({
		["Name"] = 'GUI bind indicator',
		["Default"] = true,
		["Tooltip"] = "Displays a message indicating your GUI upon injecting.\nI.E. 'Press RSHIFT to open GUI'"
	});
	
	guipane:CreateToggle({
		["Name"] = 'Show tooltips',
		["Function"] = function(enabled: boolean): ()
			tooltip.Visible = false;
			toolblur.Enabled = enabled;
		end,
		["Default"] = true,
		["Tooltip"] = 'Toggles visibility of these'
	});
	
	guipane:CreateToggle({
		["Name"] = 'Show legit mode',
		["Function"] = function(enabled: boolean): ()
			clickgui.Search.Legit.Visible = enabled;
			clickgui.Search.LegitDivider.Visible = enabled;
			clickgui.Search.TextBox.Size = UDim2.new(1, enabled and -50 or -10, 0, 37);
			clickgui.Search.TextBox.Position = UDim2.fromOffset(enabled and 50 or 10, 0);
		end,
		["Default"] = true,
		["Tooltip"] = 'Shows the button to switch to the legit mod menu'
	});
	
	local ScaleSlider: table = {["Object"] = {}, ["Value"] = 1};
	vape.Scale = guipane:CreateToggle({
		["Name"] = 'Auto rescale',
		["Default"] = true,
		["Function"] = function(callback: boolean): ()
			ScaleSlider.Object.Visible = not callback;
			if callback then
				--scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
			else
				scale.Scale = ScaleSlider.Value;
			end;
		end,
		["Tooltip"] = 'Automatically rescales the gui using the screens resolution'
	});
	
	ScaleSlider = guipane:CreateSlider({
		["Name"] = 'Scale',
		["Min"] = 0.1,
		["Max"] = 2,
		["Decimal"] = 10,
		["Function"] = function(val: number, final: boolean): ()
			if final and not vape.Scale.Enabled then
				scale.Scale = val;
			end;
		end,
		["Default"] = 1,
		["Darker"] = true,
		["Visible"] = false
	});
	
	vape.RainbowSpeed = guipane:CreateSlider({
		["Name"] = 'Rainbow speed',
		["Min"] = 0.1,
		["Max"] = 10,
		["Decimal"] = 10,
		["Default"] = 1,
		["Tooltip"] = 'Adjusts the speed of rainbow values and GUI color animations'
	});
	
	vape.RainbowUpdateSpeed = guipane:CreateSlider({
		["Name"] = 'Rainbow update rate',
		["Min"] = 1,
		["Max"] = 144,
		["Default"] = 60,
		["Tooltip"] = 'Adjusts the update rate of rainbow values',
		["Suffix"] = 'hz'
	});
	
	--[[guipane:CreateDropdown({
		Name = 'GUI Theme',
		List = inputService.TouchEnabled and {'new', 'old'} or {'new', 'old', 'rise'},
		Function = function(val, mouse)
			if mouse then
				writefile('velo/profiles/gui.txt', val)
				shared.veloreload = true
				if shared.VeloDeveloper then
					loadstring(readfile('velo/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/Copiums/Velocity/'..readfile('velo/profiles/commit.txt')..'/loader.lua', true))()
				end
			end
		end,
		Tooltip = 'new - The newest vape theme to since v4.05\nold - The vape theme pre v4.05\nrise - Rise 6.0'
	})]]
	
	guipane:CreateDropdown({
		["Name"] = 'Search bar style',
		["List"] = {'Floating', 'None'},
		["Default"] = 'Floating',
		["Function"] = function(value: string): ()
			vape.SearchBar.Object.Visible = value == 'Floating';
		end,
		["Tooltip"] = 'Switch between search bar styles'
	});
	
	vape.RainbowMode = guipane:CreateDropdown({
		["Name"] = 'Rainbow Mode',
		["List"] = {'Normal', 'Gradient', 'Retro'},
		["Tooltip"] = 'Normal - Colors wave down the GUI\nGradient - Modules get a gradient fill\nRetro - The whole GUI shares one color\nApplies to every Color Animation'
	});

	local colorpane: table = guipane:CreateSettingsPane({["Name"] = 'Color Animation'});
	local CustomCount: table;
	local customSliders: {table} = {};
	local refreshAnimOptions: () -> () = function(): ()
		local isCustom: boolean = colorAnim["Palette"] == 'Custom';
		if CustomCount then
			CustomCount["Object"].Visible = isCustom;
		end;
		for index: number, slider: table in customSliders do
			slider["Object"].Visible = isCustom and index <= colorAnim["Count"];
		end;
	end;
	colorpane:CreateDropdown({
		["Name"] = 'Animation',
		["List"] = table.clone(paletteNames),
		["MaxRows"] = 8,
		["Function"] = function(value: string, isClick: boolean?): ()
			colorAnim["Palette"] = value;
			refreshAnimOptions();
			if isClick and not vape.GUIColor.Rainbow then
				vape.GUIColor:Toggle();
			end;
			vape:UpdateGUI();
		end,
		["Tooltip"] = 'The colors the GUI cycles through while the GUI Theme rainbow button is on.\nPicking one turns the animation on.'
	});
	colorpane:CreateDropdown({
		["Name"] = 'Effect',
		["List"] = {'Smooth', 'Step', 'Pulse', 'Shine'},
		["Function"] = function(value: string): ()
			colorAnim["Effect"] = value;
			vape:UpdateGUI();
		end,
		["Tooltip"] = 'Smooth - Colors blend into each other\nStep - Hard switches between colors\nPulse - Colors flow while the brightness breathes\nShine - A white shine sweeps across the colors'
	});
	colorpane:CreateSlider({
		["Name"] = 'Speed',
		["Min"] = 0.1,
		["Max"] = 5,
		["Decimal"] = 10,
		["Default"] = 1,
		["Function"] = function(value: number): ()
			colorAnim["Speed"] = value;
		end,
		["Suffix"] = 'x',
		["Tooltip"] = 'How fast the animation moves (stacks with Rainbow speed)'
	});
	colorpane:CreateSlider({
		["Name"] = 'Spread',
		["Min"] = 1,
		["Max"] = 6,
		["Default"] = 1,
		["Function"] = function(value: number): ()
			colorAnim["Spread"] = math.max(1, math.floor(value));
			vape:UpdateGUI();
		end,
		["Tooltip"] = 'How many times the colors repeat down the GUI, higher gives tighter color bands'
	});
	CustomCount = colorpane:CreateSlider({
		["Name"] = 'Custom colors',
		["Min"] = 2,
		["Max"] = 5,
		["Default"] = 3,
		["Function"] = function(value: number): ()
			colorAnim["Count"] = value;
			refreshAnimOptions();
		end,
		["Tooltip"] = 'How many of the colors below the Custom animation uses',
		["Darker"] = true,
		["Visible"] = false
	});
	for index: number, default: Color3 in table.clone(colorAnim["Custom"]) do
		local h: number, s: number, v: number = default:ToHSV();
		local ColorOption: table = colorpane:CreateColorSlider({
			["Name"] = 'Color ' .. index,
			["DefaultHue"] = h,
			["DefaultSat"] = s,
			["DefaultValue"] = v,
			["Function"] = function(hue: number, sat: number, val: number): ()
				colorAnim["Custom"][index] = Color3.fromHSV(hue, sat, val);
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		table.insert(customSliders, ColorOption);
	end;
	colorpane:CreateButton({
		["Name"] = 'Start / stop animation',
		["Function"] = function(): ()
			vape.GUIColor:Toggle();
		end,
		["Tooltip"] = 'Same as the rainbow button on GUI Theme'
	});

	vape.GUIFont = guipane:CreateFont({
		["Name"] = 'GUI font',
		["Default"] = 'Gotham',
		["Function"] = function(value: Font?): ()
			if value then
				vape:SetFont(value);
			end;
		end
	});

	guipane:CreateButton({
		["Name"] = 'Reset GUI positions',
		["Function"] = function(): ()
			for _: any, category: any in vape.Categories do
				category.Object.Position = UDim2.fromOffset(6, 42);
			end;
		end,
		["Tooltip"] = 'This will reset your GUI back to the default'
	});
	
	guipane:CreateButton({
		["Name"] = 'Sort GUI',
		["Function"] = function(): ()
			local priority: table = {
				["GUICategory"] = 1,
				["CombatCategory"] = 2,
				["BlatantCategory"] = 3,
				["RenderCategory"] = 4,
				["UtilityCategory"] = 5,
				["WorldCategory"] = 6,
				["InventoryCategory"] = 7,
				["FriendsCategory"] = 8,
				["ProfilesCategory"] = 9
			};
	
			local categories: table = {};
			for _: any, category: any in vape.Categories do
				if category.Type ~= 'Overlay' then
					table.insert(categories, category);
				end;
			end;
	
			table.sort(categories, function(a: any, b: any): boolean
				return (priority[a.Object.Name] or 99) < (priority[b.Object.Name] or 99);
			end);
	
			local index: number = 0;
			for _: any, category: any in categories do
				if category.Object.Visible then
					category.Object.Position = UDim2.fromOffset(6 + (index % 8 * 230), 60 + (index > 7 and 360 or 0));
					index += 1;
				end;
			end;
		end,
		["Tooltip"] = 'Sorts GUI by category order'
	});

	local notifpanestyle: table = guipane:CreateSettingsPane({["Name"] = 'Notification Style'});
	local NotifColor: table;
	local NotifImage: table;
	local NotifTransparency: table;
	local NotifCorner: table;
	local refreshNotifOptions: (mode: string) -> () = function(mode: string): ()
		NotifColor["Object"].Visible = mode == 'Color';
		NotifImage["Object"].Visible = mode == 'Image';
		NotifTransparency["Object"].Visible = mode ~= 'Color';
		NotifCorner["Object"].Visible = mode ~= 'Default';
	end;
	notifpanestyle:CreateDropdown({
		["Name"] = 'Background',
		["List"] = {'Default', 'Color', 'Image'},
		["Function"] = function(value: string): ()
			notifStyle["Background"] = value;
			refreshNotifOptions(value);
		end,
		["Tooltip"] = 'Default - Vape notification background\nColor - Solid color background\nImage - Your own image as the background'
	});
	NotifColor = notifpanestyle:CreateColorSlider({
		["Name"] = 'Background color',
		["DefaultHue"] = 0,
		["DefaultSat"] = 0,
		["DefaultValue"] = 0.06,
		["DefaultOpacity"] = 0.8,
		["Function"] = function(hue: number, sat: number, val: number, opacity: number): ()
			notifStyle["Color"] = Color3.fromHSV(hue, sat, val);
			notifStyle["Opacity"] = opacity;
		end,
		["Tooltip"] = 'Background color of notifications, opacity controls how see-through it is',
		["Darker"] = true,
		["Visible"] = false
	});
	NotifImage = notifpanestyle:CreateTextBox({
		["Name"] = 'Background image',
		["Placeholder"] = 'image id',
		["Function"] = function(): ()
			notifStyle["Image"] = NotifImage["Value"];
		end,
		["Tooltip"] = 'Image asset id (not a decal id), an rbxassetid:// link or a file path in your workspace folder',
		["Darker"] = true,
		["Visible"] = false
	});
	NotifTransparency = notifpanestyle:CreateSlider({
		["Name"] = 'Transparency',
		["Min"] = 0,
		["Max"] = 1,
		["Decimal"] = 100,
		["Default"] = 0,
		["Function"] = function(value: number): ()
			notifStyle["Transparency"] = value;
		end,
		["Tooltip"] = 'How see-through the notification background is',
		["Darker"] = true
	});
	NotifCorner = notifpanestyle:CreateSlider({
		["Name"] = 'Corner radius',
		["Min"] = 0,
		["Max"] = 30,
		["Default"] = 6,
		["Function"] = function(value: number): ()
			notifStyle["Corner"] = value;
		end,
		["Suffix"] = 'px',
		["Tooltip"] = 'Corner radius of Color and Image notifications',
		["Darker"] = true,
		["Visible"] = false
	});
	for _: number, kind: string in {'info', 'warning', 'alert'} do
		local IconBox: table;
		IconBox = notifpanestyle:CreateTextBox({
			["Name"] = (kind:gsub('^%l', string.upper)) .. ' icon',
			["Placeholder"] = 'default',
			["Function"] = function(): ()
				notifStyle["Icons"][kind] = IconBox["Value"];
			end,
			["Tooltip"] = 'Image id for the ' .. kind .. ' notification icon, leave empty for the default icon'
		});
	end;
	notifpanestyle:CreateSlider({
		["Name"] = 'Icon size',
		["Min"] = 8,
		["Max"] = 40,
		["Default"] = 20,
		["Function"] = function(value: number): ()
			notifStyle["IconSize"] = value;
		end,
		["Suffix"] = 'px',
		["Tooltip"] = 'Size of the notification icon'
	});
	notifpanestyle:CreateFont({
		["Name"] = 'Font',
		["Default"] = 'GUI font',
		["Function"] = function(value: Font?): ()
			notifStyle["Font"] = value;
		end
	});
	notifpanestyle:CreateSlider({
		["Name"] = 'Text size',
		["Min"] = 8,
		["Max"] = 24,
		["Default"] = 14,
		["Function"] = function(value: number): ()
			notifStyle["TextSize"] = value;
		end,
		["Tooltip"] = 'Text size of the notification title and message'
	});
	local testKinds: {string} = {'info', 'warning', 'alert'};
	local testIndex: number = 0;
	notifpanestyle:CreateButton({
		["Name"] = 'Test notification',
		["Function"] = function(): ()
			testIndex = testIndex % #testKinds + 1;
			local kind: string = testKinds[testIndex];
			vape:CreateNotification('Velocity', 'This is a test ' .. kind .. ' notification.', 3, kind);
		end,
		["Tooltip"] = 'Shows a notification with your current settings (cycles info, warning, alert)'
	});

	--[[
		Notification Settings
	]]
	
	local notifpane: table = vape.Categories.Main.Settings:CreateSettingsPane({["Name"] = 'Notifications'});
	vape.Notifications = notifpane:CreateToggle({
		["Name"] = 'Notifications',
		["Function"] = function(enabled: boolean): ()
			if vape.ToggleNotifications.Object then
				vape.ToggleNotifications.Object.Visible = enabled;
			end;
	
			if vape.SettingToggleNotifications.Object then
				vape.SettingToggleNotifications.Object.Visible = enabled;
			end;
		end,
		["Tooltip"] = 'Shows notifications',
		["Default"] = true
	});
	
	vape.ToggleNotifications = notifpane:CreateToggle({
		["Name"] = 'Toggle alert',
		["Tooltip"] = 'Notifies you if a module is enabled/disabled.',
		["Default"] = true,
		["Darker"] = true
	});
	vape.SettingToggleNotifications = notifpane:CreateToggle({
		["Name"] = 'Setting toggle alert',
		["Tooltip"] = 'Notifies you when a bound setting is toggled.',
		["Default"] = true,
		["Darker"] = true
	});
	
	vape.GUIColor = vape.Categories.Main.Settings:CreateGUISlider({
		["Name"] = 'GUI Theme',
		["Function"] = function(h: number, s: number, v: number): ()
			vape:UpdateGUI();
		end
	});
	
	vape.GUIBind = vape.Categories.Main.Settings:CreateBind({
		["Name"] = 'Rebind GUI',
		["Default"] = {'RightShift'},
		["NoRemove"] = true,
		["Tooltip"] = 'Change the bind of the GUI'
	});

	vape.guiscale = scale;
	vape.Keybind = vape.GUIBind.Keys;
	do
		local setGUIBind: any = vape.GUIBind.SetBind;
		vape.GUIBind.SetBind = function(self: table, keys: table, mouse: boolean?): ()
			setGUIBind(self, keys, mouse);
			vape.Keybind = self.Keys;
		end;
	end;
	vape.Categories.Main.Options = setmetatable({}, {
		["__index"] = function(_: any, name: string): any
			for _: any, pane: any in vape.Settings do
				if pane.Options[name] then
					return pane.Options[name];
				end;
			end;
		end
	});

	run(function(): ()
		local Sort: table;
		local FontOption: table;
		local ColorSlider: table;
		local ColorMode: table;
		local uiScale: UIScale;
		local Shadow: table;
		local Gradient: table;
		local GradientV4: table;
		local Animations: table;
		local Watermark: table;
		local Background: table;
		local BackgroundTransparency: table;
		local BackgroundTint: table;
		local HideModules: table;
		local HideModulesList: table;
		local HideRender: table;
		local CustomText: table;
		local CustomTextBox: table;
		local CustomTextFont: table;
		local CustomTextColor: table;
		local CustomTextColorSlider: table;
		local labelList: table = {};
		local info: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential);
		
		local findValidLabel: (labels: table, index: number, dir: number) -> ...any;
		findValidLabel = function(labels: table, index: number, dir: number): ...any
			local label: any = labels[index + dir];
			if label then
				if label.Size ~= UDim2.fromOffset() then
					return label;
				else
					return findValidLabel(labels, index + dir, dir);
				end;
			end;
		end;
		
		TextGUI = vape:CreateOverlay({
			["Name"] = 'Text GUI',
			["Icon"] = getvapeasset('velo/assets/new/textgui.png'),
			["Size"] = UDim2.fromOffset(16, 12),
			["Position"] = UDim2.fromOffset(12, 14),
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end
		});
		Sort = TextGUI:CreateDropdown({
			["Name"] = 'Sort',
			["List"] = {'Alphabetical', 'Length'},
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end
		});
		FontOption = TextGUI:CreateFont({
			["Name"] = 'Font',
			["Default"] = 'Arial',
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end
		});
		ColorMode = TextGUI:CreateDropdown({
			["Name"] = 'Color Mode',
			["List"] = {'Match GUI color', 'Custom color'},
			["Function"] = function(value: string): ()
				ColorSlider.Object.Visible = value == 'Custom color';
				vape:UpdateTextGUI();
			end
		});
		ColorSlider = TextGUI:CreateColorSlider({
			["Name"] = 'Text GUI color',
			["Function"] = function(): ()
				vape:UpdateGUI();
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		TextGUI:CreateSlider({
			["Name"] = 'Scale',
			["Min"] = 0,
			["Max"] = 2,
			["Decimal"] = 10,
			["Default"] = 1,
			["Function"] = function(val: number): ()
				uiScale.Scale = val;
				vape:UpdateTextGUI();
			end
		});
		Shadow = TextGUI:CreateToggle({
			["Name"] = 'Shadow',
			["Tooltip"] = 'Renders shadowed text.',
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end
		});
		Gradient = TextGUI:CreateToggle({
			["Name"] = 'Gradient',
			["Tooltip"] = 'Renders a gradient',
			["Function"] = function(callback: boolean): ()
				GradientV4.Object.Visible = callback;
				vape:UpdateTextGUI();
			end
		});
		GradientV4 = TextGUI:CreateToggle({
			["Name"] = 'V4 Gradient',
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		Animations = TextGUI:CreateToggle({
			["Name"] = 'Animations',
			["Tooltip"] = 'Use animations on text gui',
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end
		});
		Watermark = TextGUI:CreateToggle({
			["Name"] = 'Watermark',
			["Tooltip"] = 'Renders a vape watermark',
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end
		});
		Background = TextGUI:CreateToggle({
			["Name"] = 'Render background',
			["Function"] = function(callback: boolean): ()
				BackgroundTransparency.Object.Visible = callback;
				BackgroundTint.Object.Visible = callback;
				vape:UpdateTextGUI();
			end
		});
		BackgroundTransparency = TextGUI:CreateSlider({
			["Name"] = 'Transparency',
			["Min"] = 0,
			["Max"] = 1,
			["Default"] = 0.5,
			["Decimal"] = 10,
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		BackgroundTint = TextGUI:CreateToggle({
			["Name"] = 'Tint',
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		HideModules = TextGUI:CreateToggle({
			["Name"] = 'Hide modules',
			["Tooltip"] = 'Allows you to blacklist certain modules from being shown.',
			["Function"] = function(enabled: boolean): ()
				HideModulesList.Object.Visible = enabled;
				vape:UpdateTextGUI();
			end
		});
		HideModulesList = TextGUI:CreateTextList({
			["Name"] = 'Blacklist',
			["Tooltip"] = 'Name of module to hide.',
			["Color"] = Color3.fromRGB(250, 50, 56),
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end,
			["Visible"] = false,
			["Darker"] = true
		});
		HideRender = TextGUI:CreateToggle({
			["Name"] = 'Hide render',
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end
		});
		CustomText = TextGUI:CreateToggle({
			["Name"] = 'Add custom text',
			["Function"] = function(enabled: boolean): ()
				CustomTextBox.Object.Visible = enabled;
				CustomTextFont.Object.Visible = enabled;
				CustomTextColor.Object.Visible = enabled;
				CustomTextColorSlider.Object.Visible = CustomTextColor.Enabled and enabled;
				vape:UpdateTextGUI();
			end
		});
		CustomTextBox = TextGUI:CreateTextBox({
			["Name"] = 'Custom text',
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		CustomTextFont = TextGUI:CreateFont({
			["Name"] = 'Custom Font',
			["Default"] = 'Arial',
			["Function"] = function(): ()
				vape:UpdateTextGUI();
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		CustomTextColor = TextGUI:CreateToggle({
			["Name"] = 'Set custom text color',
			["Function"] = function(enabled: boolean): ()
				CustomTextColorSlider.Object.Visible = enabled;
				vape:UpdateGUI();
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		CustomTextColorSlider = TextGUI:CreateColorSlider({
			["Name"] = 'Color of custom text',
			["Function"] = function(afterload: number): ()
				vape:UpdateGUI();
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		
		
		--[[
			Text GUI Objects
		]]
		
		uiScale = Instance.new('UIScale');
		uiScale.Parent = TextGUI.Children;
		local logo: ImageLabel = Instance.new('ImageLabel');
		logo.BackgroundColor3 = Color3.new();
		logo.BackgroundTransparency = 1;
		logo.BorderSizePixel = 0;
		logo.Image = getvapeasset('velo/assets/new/vapelogo.png');
		logo.Name = 'Logo';
		logo.Position = UDim2.new(1, -142, 0, 3);
		logo.Size = UDim2.fromOffset(81, 24);
		logo.Visible = false;
		logo.Parent = TextGUI.Children;
		local logoV4: ImageLabel = Instance.new('ImageLabel');
		logoV4.BackgroundColor3 = Color3.new();
		logoV4.BackgroundTransparency = 1;
		logoV4.BorderSizePixel = 0;
		logoV4.Image = getvapeasset('velo/assets/new/v4.png');
		logoV4.Name = 'Logo2';
		logoV4.Position = UDim2.new(1, -1, 0, 0);
		logoV4.Size = UDim2.fromOffset(35, 24);
		logoV4.Parent = logo;
		local logoShadow: ImageLabel = logo:Clone();
		logoShadow.ImageColor3 = Color3.new();
		logoShadow.ImageTransparency = 0.65;
		logoShadow.Position = UDim2.fromOffset(1, 1);
		logoShadow.Visible = true;
		logoShadow.ZIndex = 0;
		logoShadow.Parent = logo;
		logoShadow.Logo2.ImageColor3 = Color3.new();
		logoShadow.Logo2.ImageTransparency = 0.65;
		logoShadow.Logo2.ZIndex = 0;
		local logoGradient: UIGradient = Instance.new('UIGradient');
		logoGradient.Rotation = 90;
		logoGradient.Parent = logo;
		local logoGradient2: UIGradient = Instance.new('UIGradient');
		logoGradient2.Rotation = 90;
		logoGradient2.Parent = logoV4;
		local labelCustom: TextLabel = Instance.new('TextLabel');
		labelCustom.BackgroundTransparency = 1;
		labelCustom.BorderSizePixel = 0;
		labelCustom.FontFace = CustomTextFont.Value;
		labelCustom.Position = UDim2.fromOffset(5, 2);
		labelCustom.Text = '';
		labelCustom.TextSize = 25;
		labelCustom.Visible = false;
		labelCustom.RichText = true;
		local labelCustomShadow: TextLabel = labelCustom:Clone();
		labelCustomShadow.TextColor3 = Color3.new();
		labelCustomShadow.TextTransparency = 0.65;
		labelCustomShadow.Parent = TextGUI.Children;
		labelCustom.Parent = TextGUI.Children;
		local labelHolder: Frame = Instance.new('Frame');
		labelHolder.Name = 'Holder';
		labelHolder.Size = UDim2.fromScale(1, 1);
		labelHolder.Position = UDim2.fromOffset(5, 37);
		labelHolder.BackgroundTransparency = 1;
		labelHolder.Parent = TextGUI.Children;
		local listLayout: UIListLayout = Instance.new('UIListLayout');
		listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right;
		listLayout.VerticalAlignment = Enum.VerticalAlignment.Top;
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder;
		listLayout.Parent = labelHolder;
		
		labelCustom:GetPropertyChangedSignal('Position'):Connect(function(): ()
			labelCustomShadow.Position = UDim2.new(
				labelCustom.Position.X.Scale,
				labelCustom.Position.X.Offset + 1,
				0,
				labelCustom.Position.Y.Offset + 1
			);
		end);
		
		labelCustom:GetPropertyChangedSignal('FontFace'):Connect(function(): ()
			labelCustomShadow.FontFace = labelCustom.FontFace;
		end);
		
		labelCustom:GetPropertyChangedSignal('Text'):Connect(function(): ()
			labelCustomShadow.Text = labelCustom.ContentText;
		end);
		
		labelCustom:GetPropertyChangedSignal('Size'):Connect(function(): ()
			labelCustomShadow.Size = labelCustom.Size;
		end);
		
		local oldRight: boolean = TextGUI.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2);
		vape:Clean(TextGUI.Children:GetPropertyChangedSignal('AbsolutePosition'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			local isRight: boolean = TextGUI.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2);
			if oldRight ~= isRight then
				vape:UpdateTextGUI();
				oldRight = isRight;
			end;
		end));
		
		vape.UpdateTextGUI = function(self: table, afterload: boolean?): ()
			if not afterload and not vape.Loaded then return; end;
			if TextGUI.Button.Enabled then
				local isRight: boolean = TextGUI.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2);
		
				logo.Visible = Watermark.Enabled;
				logo.Position = isRight and UDim2.new(1 / uiScale.Scale, -113, 0, 6) or UDim2.fromOffset(0, 6);
				logoShadow.Visible = Shadow.Enabled;
				labelCustom.Text = CustomTextBox.Value;
				labelCustom.FontFace = CustomTextFont.Value;
				labelCustom.Visible = labelCustom.Text ~= '' and CustomText.Enabled;
				labelCustomShadow.Visible = labelCustom.Visible and Shadow.Enabled;
				listLayout.HorizontalAlignment = isRight and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left;
				labelHolder.Size = UDim2.fromScale(1 / uiScale.Scale, 1);
				labelHolder.Position = UDim2.fromOffset(isRight and 3 or 0, 11 + (logo.Visible and logo.Size.Y.Offset or 0) + (labelCustom.Visible and 28 or 0) + (Background.Enabled and 3 or 0));
		
				if labelCustom.Visible then
					local size: Vector2 = getfontbounds(labelCustom.ContentText, labelCustom.TextSize, labelCustom.FontFace);
					labelCustom.Size = UDim2.fromOffset(size.X, size.Y);
					labelCustom.Position = UDim2.new(isRight and 1 / uiScale.Scale or 0, isRight and -size.X or 0, 0, (logo.Visible and 32 or 8));
				end;
		
				local previous: table = {};
				for _: any, label: any in labelList do
					if label.Enabled then
						table.insert(previous, label.Object.Name);
					end;
		
					label.Object:Destroy();
				end;
				table.clear(labelList);
		
				for name: any, module: any in vape.Modules do
					if HideModules.Enabled and table.find(HideModulesList.ListEnabled, name) then
						continue;
					end;
		
					if HideRender.Enabled and module.Category == 'Render' then
						continue;
					end;
		
					if module.Enabled or table.find(previous, name) then
						local bkg: Frame, colorline: Frame;
						local holder: Frame = Instance.new('Frame');
						holder.BackgroundTransparency = 1;
						holder.ClipsDescendants = true;
						holder.Name = name;
						holder.Size = UDim2.fromOffset();
						holder.Parent = labelHolder;
		
						if Background.Enabled then
							bkg = Instance.new('Frame');
							bkg.BackgroundColor3 = color.Dark(uipallet.Main, 0.15);
							bkg.BackgroundTransparency = BackgroundTransparency.Value;
							bkg.BorderSizePixel = 0;
							bkg.Size = UDim2.new(1, 0, 1, 0);
							bkg.Parent = holder;
							local corner: UICorner = Instance.new('UICorner');
							corner.Parent = bkg;
							local line: Frame = Instance.new('Frame');
							line.BackgroundColor3 = Color3.new();
							line.BackgroundTransparency = 0.928 + (0.072 * math.clamp((BackgroundTransparency.Value - 0.5) / 0.5, 0, 1));
							line.BorderSizePixel = 0;
							line.Position = UDim2.new(0, 0, 1, -1);
							line.Size = UDim2.new(1, 0, 0, 1);
							line.Parent = bkg;
							local line2: Frame = line:Clone();
							line2.Position = UDim2.new();
							line2.Name = 'Line';
							line2.Parent = bkg;
							colorline = Instance.new('Frame');
							colorline.BorderSizePixel = 0;
							colorline.Position = isRight and UDim2.new(1, -4, 0, 0) or UDim2.new();
							colorline.Size = UDim2.new(0, 4, 1, 0);
							colorline.Parent = bkg;
							local colorcorner: UICorner = Instance.new('UICorner');
							colorcorner.CornerRadius = UDim.new();
							colorcorner.Parent = colorline;
						end;
		
						local label: TextLabel = Instance.new('TextLabel');
						label.BackgroundTransparency = 1;
						label.BorderSizePixel = 0;
						label.FontFace = FontOption.Value;
						label.Position = UDim2.fromOffset(isRight and 5 or 9, 2);
						label.Text = name..(module.ExtraText and " <font color='#A8A8A8'>"..module.ExtraText()..'</font>' or '');
						label.TextSize = 18;
						label.RichText = true;
		
						local size: Vector2 = getfontbounds(label.ContentText, label.TextSize, label.FontFace);
						label.Size = UDim2.fromOffset(size.X, size.Y);
		
						if Shadow.Enabled then
							local shadowlabel: TextLabel = label:Clone();
							shadowlabel.Position = UDim2.fromOffset(label.Position.X.Offset + 1, label.Position.Y.Offset + 1);
							shadowlabel.Text = label.ContentText;
							shadowlabel.TextColor3 = Color3.new();
							shadowlabel.Parent = holder;
						end;
		
						label.Parent = holder;
		
						local tweenSize: UDim2 = UDim2.fromOffset(size.X + 16, size.Y + 6);
						if Animations.Enabled then
							if not table.find(previous, name) then
								tween:Tween(holder, info, {
									["Size"] = tweenSize
								});
							else
								holder.Size = tweenSize;
								if not module.Enabled then
									tween:Tween(holder, info, {
										["Size"] = UDim2.fromOffset()
									});
								end;
							end;
						else
							holder.Size = module.Enabled and tweenSize or UDim2.fromOffset();
						end;
		
						table.insert(labelList, {
							["Background"] = bkg,
							["Color"] = colorline,
							["Enabled"] = module.Enabled,
							["Object"] = holder,
							["Text"] = label,
							["Size"] = module.Enabled and tweenSize or UDim2.fromOffset()
						});
					end;
				end;
		
				if Sort.Value == 'Alphabetical' then
					table.sort(labelList, function(a: any, b: any): boolean
						return a.Text.Text < b.Text.Text;
					end);
				else
					table.sort(labelList, function(a: any, b: any): boolean
						return a.Text.Size.X.Offset > b.Text.Size.X.Offset;
					end);
				end;
		
				local firstIndex: any;
				local lastIndex: any;
		
				for index: any, label: any in labelList do
					if label.Enabled then
						firstIndex = firstIndex or index;
						lastIndex = index;
					end;
				end;
		
				for index: any, label: any in labelList do
					if label.Color then
						local topLabel: any = findValidLabel(labelList, index, -1);
						local bottomLabel: any = findValidLabel(labelList, index, 1);
						local top: number = (not topLabel or (topLabel.Size.X.Offset < label.Size.X.Offset)) and 4 or 0;
						local bottom: number = (not bottomLabel or (bottomLabel.Size.X.Offset < label.Size.X.Offset)) and 4 or 0;
		
						label.Color.Parent.Line.Visible = index ~= firstIndex;
						label.Color.UICorner.TopLeftRadius = isRight and UDim.new() or UDim.new(0, index == firstIndex and 4 or 0);
						label.Color.UICorner.TopRightRadius = isRight and UDim.new(0, index == firstIndex and 4 or 0) or UDim.new();
						label.Color.UICorner.BottomLeftRadius = isRight and UDim.new() or UDim.new(0, index == lastIndex and 4 or 0);
						label.Color.UICorner.BottomRightRadius = isRight and UDim.new(0, index == lastIndex and 4 or 0) or UDim.new();
		
						label.Background.UICorner.TopLeftRadius = UDim.new(0, top);
						label.Background.UICorner.TopRightRadius = UDim.new(0, top);
						label.Background.UICorner.BottomLeftRadius = UDim.new(0, bottom);
						label.Background.UICorner.BottomRightRadius = UDim.new(0, bottom);
					end;
		
					label.Object.LayoutOrder = index;
				end;
			end;
		
			self:UpdateGUI();
		end;
		
		TextGUI.UpdateColor = function(self: table, hue: number, sat: number, val: number, default: boolean?): ()
			logoGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)),
				ColorSequenceKeypoint.new(1, Gradient.Enabled and vape:SampleColor(0.075) or Color3.fromHSV(hue, sat, val))
			});
			logoGradient2.Color = Gradient.Enabled and GradientV4.Enabled and logoGradient.Color or ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
			});
			labelCustom.TextColor3 = CustomTextColor.Enabled and Color3.fromHSV(CustomTextColorSlider.Hue, CustomTextColorSlider.Sat, CustomTextColorSlider.Value) or logoGradient.Color.Keypoints[2].Value;
		
			local isCustom: Color3? = ColorMode.Value == 'Custom color' and Color3.fromHSV(ColorSlider.Hue, ColorSlider.Sat, ColorSlider.Value) or nil;
			for index: any, label: any in labelList do
				label.Text.TextColor3 = isCustom or (vape.GUIColor.Rainbow and vape:SampleColor((Gradient.Enabled and index + 2 or index) * 0.025) or logoGradient.Color.Keypoints[2].Value);
		
				if label.Color then
					label.Color.BackgroundColor3 = label.Text.TextColor3;
				end;
		
				if BackgroundTint.Enabled and label.Background then
					label.Background.BackgroundColor3 = color.Dark(label.Text.TextColor3, 0.75);
				end;
			end;
		end;
	end);
	
	run(function(): ()
		local targetinfo: table = {
			["Targets"] = {},
			["Object"] = Holder,
			["Health"] = 0,
			["MaxHealth"] = 0
		};
		local TargetInfoOverlay: table;
		local BackgroundTransparency: table = {
			["Value"] = 0.5,
			["Object"] = {["Visible"] = {}}
		};
		local BorderColor: table;
		local BKGColor: table;
		local CustomColor: table;
		local DisplayName: table;
		
		TargetInfoOverlay = vape:CreateOverlay({
			["Name"] = 'Target Info',
			["Icon"] = getvapeasset('velo/assets/new/targetinfo.png'),
			["Size"] = UDim2.fromOffset(14, 14),
			["Position"] = UDim2.fromOffset(12, 14),
			["CategorySize"] = 240,
			["Function"] = function(callback: boolean): ()
				if callback then
					TargetInfoOverlay:Clean(runService.RenderStepped:Connect(function(): ()
						targetinfo:Update();
					end));
				end;
			end
		});
		
		local holder: Frame = Instance.new('Frame');
		holder.Size = UDim2.fromOffset(240, 89);
		holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.1);
		holder.BackgroundTransparency = 0.5;
		holder.Parent = TargetInfoOverlay.Children;
		local blurHolder: Instance = addBlur(holder, nil, true);
		blurHolder.Visible = false;
		addCorner(holder);
		local headshot: ImageLabel = Instance.new('ImageLabel');
		headshot.Size = UDim2.fromOffset(26, 27);
		headshot.Position = UDim2.fromOffset(19, 17);
		headshot.BackgroundColor3 = uipallet.Main;
		headshot.Image = 'rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420';
		headshot.Parent = holder;
		addCorner(headshot);
		local hurtFlash: Frame = Instance.new('Frame');
		hurtFlash.Size = UDim2.fromScale(1, 1);
		hurtFlash.BackgroundTransparency = 1;
		hurtFlash.BackgroundColor3 = Color3.new(1, 0, 0);
		hurtFlash.Parent = headshot;
		addCorner(hurtFlash);
		local headshotBlur: Instance = addBlur(headshot);
		headshotBlur.Enabled = false;
		local nameLabel: TextLabel = Instance.new('TextLabel');
		nameLabel.Size = UDim2.fromOffset(145, 20);
		nameLabel.Position = UDim2.fromOffset(54, 20);
		nameLabel.BackgroundTransparency = 1;
		nameLabel.Text = 'Target name';
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left;
		nameLabel.TextYAlignment = Enum.TextYAlignment.Top;
		nameLabel.TextScaled = true;
		nameLabel.TextColor3 = color.Light(uipallet.Text, 0.4);
		nameLabel.TextStrokeTransparency = 1;
		nameLabel.FontFace = uipallet.Font;
		local nameShadow: TextLabel = nameLabel:Clone();
		nameShadow.Position = UDim2.fromOffset(55, 21);
		nameShadow.TextColor3 = Color3.new();
		nameShadow.TextTransparency = 0.65;
		nameShadow.Visible = false;
		nameShadow.Parent = holder;
		for _: number, prop: string in {'Size', 'Text', 'FontFace'} do
			nameLabel:GetPropertyChangedSignal(prop):Connect(function(): ()
				nameShadow[prop] = nameLabel[prop];
			end);
		end;
		nameLabel.Parent = holder;
		local healthBKG: Frame = Instance.new('Frame');
		healthBKG.Name = 'HealthBKG';
		healthBKG.Size = UDim2.fromOffset(200, 9);
		healthBKG.Position = UDim2.fromOffset(20, 56);
		healthBKG.BackgroundColor3 = uipallet.Main;
		healthBKG.BorderSizePixel = 0;
		healthBKG.Parent = holder;
		addCorner(healthBKG, UDim.new(1, 0));
		local healthBar: Frame = healthBKG:Clone();
		healthBar.Size = UDim2.fromScale(0.8, 1);
		healthBar.Position = UDim2.new();
		healthBar.BackgroundColor3 = Color3.fromHSV(1 / 2.5, 0.89, 0.75);
		healthBar.Parent = healthBKG;
		healthBar:GetPropertyChangedSignal('Size'):Connect(function(): ()
			healthBar.Visible = healthBar.Size.X.Scale > 0.01;
		end);
		local armor: Frame = healthBar:Clone();
		armor.Size = UDim2.new();
		armor.Position = UDim2.fromScale(1, 0);
		armor.AnchorPoint = Vector2.new(1, 0);
		armor.BackgroundColor3 = Color3.fromRGB(255, 170, 0);
		armor.Visible = false;
		armor.Parent = healthBKG;
		armor:GetPropertyChangedSignal('Size'):Connect(function(): ()
			armor.Visible = armor.Size.X.Scale > 0.01;
		end);
		local healthBlur: Instance = addBlur(healthBKG);
		healthBlur.Enabled = false;
		local stroke: UIStroke = Instance.new('UIStroke');
		stroke.Enabled = false;
		stroke.Color = Color3.fromHSV(0.44, 1, 1);
		stroke.Parent = holder;

		local hsv: (value: Color3) -> table = function(value: Color3): table
			local h: number, s: number, v: number = value:ToHSV();
			return {["Hue"] = h, ["Sat"] = s, ["Value"] = v, ["Object"] = {["Visible"] = true}};
		end;
		local placeholder: (key: string, value: any) -> table = function(key: string, value: any): table
			return {[key] = value, ["Object"] = {["Visible"] = true}};
		end;
		local HudStyle: table = placeholder('Value', 'Velo');
		local HudFont: table = placeholder('Value', Font.fromEnum(Enum.Font.GothamBlack));
		local HudTextColor: table = hsv(Color3.new(1, 1, 1));
		local HudBackgroundStart: table = hsv(Color3.fromRGB(255, 0, 0));
		local HudBackgroundEnd: table = hsv(Color3.fromRGB(40, 0, 74));
		local HudBackgroundRotation: table = placeholder('Value', 90);
		local HudGlow: table = placeholder('Enabled', true);
		local HudGlowStart: table = hsv(Color3.fromRGB(108, 0, 255));
		local HudGlowEnd: table = hsv(Color3.fromRGB(40, 0, 74));
		local HudGlowTransparency: table = placeholder('Value', 0);
		local HudShadow: table = placeholder('Enabled', true);
		local HudShadowTransparency: table = placeholder('Value', 0.5);
		local HudShadowSpread: table = placeholder('Value', 30);
		local HudShadowOffsetX: table = placeholder('Value', 0);
		local HudShadowOffsetY: table = placeholder('Value', 0);
		local HudOutlineStart: table = hsv(Color3.fromRGB(255, 0, 251));
		local HudOutlineEnd: table = hsv(Color3.fromRGB(0, 255, 238));
		local HudOutlineThickness: table = placeholder('Value', 2);
		local HudSpinSpeed: table = placeholder('Value', 120);
		local HudCornerRadius: table = placeholder('Value', 20);
		local HudAvatar: table = placeholder('Enabled', true);
		local HudHealthText: table = placeholder('Enabled', true);
		local HudStatus: table = placeholder('Enabled', true);
		local HudHealthColor: table = hsv(Color3.new(1, 1, 1));
		local HudMidColor: table = hsv(Color3.fromRGB(255, 165, 0));
		local HudLowColor: table = hsv(Color3.fromRGB(255, 0, 0));
		local HudTween: table = placeholder('Value', 0.2);
		local hudShadowImage: string = 'rbxassetid://8992230677';
		local hudTarget: any = nil;
		local hudHealthValue: number? = nil;
		local hudPercent: number = 1;
		local hudFillWidth: number = 187;
		local hudLastTick: number = os.clock();

		local getColor: (option: table) -> Color3 = function(option: table): Color3
			return Color3.fromHSV(option["Hue"], option["Sat"], option["Value"]);
		end;
		local makeHudGradient: (parent: Instance) -> UIGradient = function(parent: Instance): UIGradient
			local gradient: UIGradient = Instance.new('UIGradient');
			gradient.Parent = parent;
			return gradient;
		end;
		local makeHudLabel: (size: UDim2) -> TextLabel = function(size: UDim2): TextLabel
			local label: TextLabel = Instance.new('TextLabel');
			label.BackgroundTransparency = 1;
			label.BorderSizePixel = 0;
			label.TextSize = 10;
			label.TextWrapped = true;
			label.TextXAlignment = Enum.TextXAlignment.Left;
			label.Size = size;
			label.ZIndex = 4;
			return label;
		end;

		local customHolder: Frame = Instance.new('Frame');
		customHolder.Size = UDim2.fromOffset(308, 93);
		customHolder.BackgroundTransparency = 1;
		customHolder.BorderSizePixel = 0;
		customHolder.Visible = false;
		customHolder.ZIndex = 1;
		customHolder.Parent = TargetInfoOverlay.Children;
		local hudCorner: UICorner = Instance.new('UICorner');
		hudCorner.Parent = customHolder;
		local hudStroke: UIStroke = Instance.new('UIStroke');
		hudStroke.Color = Color3.new(1, 1, 1);
		hudStroke.Parent = customHolder;
		local hudStrokeGradient: UIGradient = makeHudGradient(hudStroke);

		local hudBackground: Frame = Instance.new('Frame');
		hudBackground.Size = UDim2.fromScale(1, 1);
		hudBackground.BackgroundColor3 = Color3.new(1, 1, 1);
		hudBackground.BorderSizePixel = 0;
		hudBackground.ZIndex = 1;
		hudBackground.Parent = customHolder;
		local hudBackgroundGradient: UIGradient = makeHudGradient(hudBackground);
		local hudBackgroundCorner: UICorner = Instance.new('UICorner');
		hudBackgroundCorner.Parent = hudBackground;

		local hudShadow: ImageLabel = Instance.new('ImageLabel');
		hudShadow.Image = hudShadowImage;
		hudShadow.ImageColor3 = Color3.new(1, 1, 1);
		hudShadow.ScaleType = Enum.ScaleType.Slice;
		hudShadow.SliceCenter = Rect.new(49, 49, 450, 450);
		hudShadow.AnchorPoint = Vector2.new(0.5, 0.5);
		hudShadow.BackgroundTransparency = 1;
		hudShadow.BorderSizePixel = 0;
		hudShadow.Position = UDim2.fromScale(0.5, 0.5);
		hudShadow.Size = UDim2.new(1, 60, 1, 60);
		hudShadow.ZIndex = 2;
		hudShadow.Parent = hudBackground;
		local hudShadowGradient: UIGradient = makeHudGradient(hudShadow);

		local hudGlowHolder: Frame = Instance.new('Frame');
		hudGlowHolder.BackgroundTransparency = 1;
		hudGlowHolder.Size = UDim2.new(1, 0, 1.5, 0);
		hudGlowHolder.Position = UDim2.new(0, 0, -0.25, 0.2);
		hudGlowHolder.ZIndex = 3;
		hudGlowHolder.Parent = customHolder;
		local hudGlow: ImageLabel = Instance.new('ImageLabel');
		hudGlow.Image = hudShadowImage;
		hudGlow.BackgroundTransparency = 1;
		hudGlow.Position = UDim2.new(0, -130, 0, -50);
		hudGlow.Size = UDim2.new(-1.25, 1009, -0.5, 336);
		hudGlow.ZIndex = 3;
		hudGlow.Parent = hudGlowHolder;
		local hudGlowGradient: UIGradient = makeHudGradient(hudGlow);

		local hudAvatar: ImageLabel = Instance.new('ImageLabel');
		hudAvatar.Image = 'rbxthumb://type=AvatarHeadShot&w=420&h=420&id=1';
		hudAvatar.BackgroundTransparency = 1;
		hudAvatar.Position = UDim2.new(0.0519480519, 0, 0.139784947, 0);
		hudAvatar.Size = UDim2.fromOffset(65, 65);
		hudAvatar.ZIndex = 4;
		hudAvatar.Parent = customHolder;
		Instance.new('UICorner').Parent = hudAvatar;
		local hudAvatarStroke: UIStroke = Instance.new('UIStroke');
		hudAvatarStroke.Color = Color3.new(1, 1, 1);
		hudAvatarStroke.Parent = hudAvatar;
		local hudAvatarGradient: UIGradient = makeHudGradient(hudAvatarStroke);
		local hudHurt: Frame = Instance.new('Frame');
		hudHurt.BackgroundColor3 = Color3.new(1, 0, 0);
		hudHurt.BackgroundTransparency = 1;
		hudHurt.BorderSizePixel = 0;
		hudHurt.Size = UDim2.fromScale(1, 1);
		hudHurt.ZIndex = 5;
		hudHurt.Parent = hudAvatar;
		Instance.new('UICorner').Parent = hudHurt;

		local hudFill: Frame = Instance.new('Frame');
		hudFill.BorderSizePixel = 0;
		hudFill.Size = UDim2.fromOffset(187, 5.5);
		hudFill.ZIndex = 4;
		hudFill.Parent = customHolder;
		local hudFillCorner: UICorner = Instance.new('UICorner');
		hudFillCorner.CornerRadius = UDim.new(0, 20);
		hudFillCorner.Parent = hudFill;
		local hudHealth: TextLabel = makeHudLabel(UDim2.fromOffset(57, 10));
		hudHealth.Text = '100%';
		hudHealth.Parent = customHolder;
		local hudName: TextLabel = makeHudLabel(UDim2.fromOffset(195, 24));
		hudName.TextScaled = true;
		hudName.TextSize = 14;
		hudName.Text = 'Target name';
		hudName.Parent = customHolder;
		local hudStatus: TextLabel = makeHudLabel(UDim2.fromOffset(103, 26));
		hudStatus.Text = '- Winning';
		hudStatus.Parent = customHolder;

		local applyHudStyle: () -> () = function(): ()
			local rotation: number = HudBackgroundRotation["Value"];
			local background: ColorSequence = ColorSequence.new(getColor(HudBackgroundStart), getColor(HudBackgroundEnd));
			local outline: ColorSequence = ColorSequence.new(getColor(HudOutlineStart), getColor(HudOutlineEnd));
			hudBackgroundGradient.Color = background;
			hudBackgroundGradient.Rotation = rotation;
			hudShadowGradient.Color = background;
			hudShadowGradient.Rotation = rotation;
			hudShadow.Visible = HudShadow["Enabled"];
			hudShadow.ImageTransparency = HudShadowTransparency["Value"];
			hudShadow.Position = UDim2.new(0.5, HudShadowOffsetX["Value"], 0.5, HudShadowOffsetY["Value"]);
			hudShadow.Size = UDim2.new(1, HudShadowSpread["Value"] * 2, 1, HudShadowSpread["Value"] * 2);
			hudGlowGradient.Color = ColorSequence.new(getColor(HudGlowStart), getColor(HudGlowEnd));
			hudGlowGradient.Rotation = rotation;
			hudGlow.Visible = HudGlow["Enabled"];
			hudGlow.ImageTransparency = HudGlowTransparency["Value"];
			hudCorner.CornerRadius = UDim.new(0, HudCornerRadius["Value"]);
			hudBackgroundCorner.CornerRadius = UDim.new(0, HudCornerRadius["Value"]);
			hudStrokeGradient.Color = outline;
			hudAvatarGradient.Color = outline;
			hudStroke.Thickness = HudOutlineThickness["Value"];
			hudAvatarStroke.Thickness = HudOutlineThickness["Value"];
			hudAvatar.Visible = HudAvatar["Enabled"];
			local shift: number = HudAvatar["Enabled"] and 0 or -79;
			hudFillWidth = 187 - shift;
			hudName.Position = UDim2.new(0.30844155, shift, 0.258064568, 0);
			hudName.Size = UDim2.fromOffset(195 - shift, 24);
			hudFill.Position = UDim2.new(0.308526317, shift, 0.52, 0);
			hudFill.Size = UDim2.fromOffset(hudFillWidth * hudPercent, 5.5);
			hudHealth.Position = UDim2.new(0.311688304, shift, 0.634408593, 0);
			hudHealth.Visible = HudHealthText["Enabled"];
			hudStatus.Position = UDim2.new(0.401688304, shift, 0.547408593, 0);
			hudStatus.Visible = HudStatus["Enabled"];
			for _: number, label: TextLabel in {hudName, hudHealth, hudStatus} do
				label.FontFace = HudFont["Value"];
			end;
			hudName.TextColor3 = getColor(HudTextColor);
			hudHealth.TextColor3 = getColor(HudTextColor);
			hudHealthValue = nil;
		end;

		local showCustom: (entity: table) -> () = function(entity: table): ()
			local player: Player? = entity.Player;
			if player then
				hudName.Text = DisplayName["Enabled"] and player.DisplayName or player.Name;
			elseif entity.Character then
				hudName.Text = entity.Character.Name;
			end;
			hudAvatar.Image = 'rbxthumb://type=AvatarHeadShot&w=420&h=420&id=' .. (player and player.UserId or 1);
			local health: number = entity.Health or 0;
			local maxHealth: number = entity.MaxHealth or 100;
			if entity ~= hudTarget or health ~= hudHealthValue then
				local percent: number = math.clamp(maxHealth > 0 and health / maxHealth or 0, 0, 1);
				local duration: number = math.max(math.abs(percent - hudPercent) * 1.5, HudTween["Value"]);
				if entity == hudTarget and hudHealthValue and health < hudHealthValue then
					tween:Cancel(hudHurt);
					hudHurt.BackgroundTransparency = 0.3;
					tween:Tween(hudHurt, TweenInfo.new(0.5), {["BackgroundTransparency"] = 1});
				end;
				hudTarget = entity;
				hudHealthValue = health;
				hudPercent = percent;
				tween:Tween(hudFill, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["Size"] = UDim2.fromOffset(hudFillWidth * percent, 5.5)});
				hudFill.BackgroundColor3 = getColor(percent < 0.2 and HudLowColor or percent < 0.5 and HudMidColor or HudHealthColor);
				hudHealth.Text = math.floor(percent * 100 + 0.5) .. '%';
			end;
			local entitylib: table? = vape.Libraries.entity;
			local mine: number = entitylib and entitylib.isAlive and entitylib.character.Humanoid.Health or 0;
			if mine > health then
				hudStatus.Text = '- Winning';
				hudStatus.TextColor3 = Color3.fromRGB(0, 255, 0);
			elseif mine == health then
				hudStatus.Text = '- Tie';
				hudStatus.TextColor3 = Color3.new(1, 1, 1);
			else
				hudStatus.Text = '- Losing';
				hudStatus.TextColor3 = Color3.fromRGB(255, 0, 0);
			end;
		end;

		local updateCustom: (entity: table?) -> () = function(entity: table?): ()
			local now: number = os.clock();
			local delta: number = now - hudLastTick;
			hudLastTick = now;
			customHolder.Visible = entity ~= nil or clickgui.Visible;
			if not customHolder.Visible then
				return;
			end;
			if entity then
				showCustom(entity);
			end;
			hudStrokeGradient.Rotation = (hudStrokeGradient.Rotation + delta * HudSpinSpeed["Value"]) % 360;
		end;
		
		TargetInfoOverlay:CreateFont({
			["Name"] = 'Font',
			["Default"] = 'Arial',
			["Function"] = function(val: number): ()
				nameLabel.FontFace = val;
			end
		});
		DisplayName = TargetInfoOverlay:CreateToggle({
			["Name"] = 'Use Displayname',
			["Default"] = true
		});
		TargetInfoOverlay:CreateToggle({
			["Name"] = 'Render Background',
			["Function"] = function(callback: boolean): ()
				holder.BackgroundTransparency = callback and BackgroundTransparency.Value or 1;
				nameShadow.Visible = not callback;
				blurHolder.Visible = callback;
				healthBlur.Enabled = not callback;
				headshotBlur.Enabled = not callback;
				BackgroundTransparency.Object.Visible = callback;
			end,
			["Default"] = true
		});
		BackgroundTransparency = TargetInfoOverlay:CreateSlider({
			["Name"] = 'Transparency',
			["Min"] = 0,
			["Max"] = 1,
			["Default"] = 0.5,
			["Decimal"] = 10,
			["Function"] = function(val: number): ()
				holder.BackgroundTransparency = val;
			end,
			["Darker"] = true
		});
		CustomColor = TargetInfoOverlay:CreateToggle({
			["Name"] = 'Custom Color',
			["Function"] = function(callback: boolean): ()
				BKGColor.Object.Visible = callback;
				if callback then
					holder.BackgroundColor3 = Color3.fromHSV(BKGColor.Hue, BKGColor.Sat, BKGColor.Value);
					headshot.BackgroundColor3 = Color3.fromHSV(BKGColor.Hue, BKGColor.Sat, math.max(BKGColor.Value - 0.1, 0.075));
					healthBKG.BackgroundColor3 = headshot.BackgroundColor3;
				else
					holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.1);
					headshot.BackgroundColor3 = uipallet.Main;
					healthBKG.BackgroundColor3 = uipallet.Main;
				end;
			end
		});
		BKGColor = TargetInfoOverlay:CreateColorSlider({
			["Name"] = 'Color',
			["Function"] = function(hue: number, sat: number, val: number): ()
				if CustomColor.Enabled then
					holder.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
					headshot.BackgroundColor3 = Color3.fromHSV(hue, sat, math.max(val - 0.1, 0));
					healthBKG.BackgroundColor3 = headshot.BackgroundColor3;
				end;
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		TargetInfoOverlay:CreateToggle({
			["Name"] = 'Border',
			["Function"] = function(callback: boolean): ()
				stroke.Enabled = callback;
				BorderColor.Object.Visible = callback;
			end
		});
		BorderColor = TargetInfoOverlay:CreateColorSlider({
			["Name"] = 'Border Color',
			["Function"] = function(hue: number, sat: number, val: number, opacity: number): ()
				stroke.Color = Color3.fromHSV(hue, sat, val);
				stroke.Transparency = 1 - opacity;
			end,
			["Darker"] = true,
			["Visible"] = false
		});
		
		local hudOptions: {table} = {};
		local hudOption: (option: table) -> table = function(option: table): table
			table.insert(hudOptions, option);
			return option;
		end;
		local hudColor: (name: string, default: table) -> table = function(name: string, default: table): table
			return hudOption(TargetInfoOverlay:CreateColorSlider({
				["Name"] = name,
				["DefaultHue"] = default["Hue"],
				["DefaultSat"] = default["Sat"],
				["DefaultValue"] = default["Value"],
				["Function"] = applyHudStyle,
				["Darker"] = true
			}));
		end;
		local hudSlider: (name: string, min: number, max: number, default: number, decimal: number?, suffix: string?) -> table = function(name: string, min: number, max: number, default: number, decimal: number?, suffix: string?): table
			return hudOption(TargetInfoOverlay:CreateSlider({
				["Name"] = name,
				["Min"] = min,
				["Max"] = max,
				["Default"] = default,
				["Decimal"] = decimal,
				["Suffix"] = suffix,
				["Function"] = applyHudStyle,
				["Darker"] = true
			}));
		end;
		local hudToggle: (name: string, default: boolean, tooltip: string?) -> table = function(name: string, default: boolean, tooltip: string?): table
			return hudOption(TargetInfoOverlay:CreateToggle({
				["Name"] = name,
				["Default"] = default,
				["Tooltip"] = tooltip,
				["Function"] = applyHudStyle,
				["Darker"] = true
			}));
		end;
		HudStyle = TargetInfoOverlay:CreateDropdown({
			["Name"] = 'Style',
			["List"] = {'Velo', 'Vape'},
			["Default"] = 'Velo',
			["Tooltip"] = "Velo: Velocity's target HUD look (its settings show below). Vape: the original vape look.\nBoth only show while a module is targeting someone or while the GUI is open.",
			["Function"] = function(value: string): ()
				for _: any, option: table in hudOptions do
					option.Object.Visible = value == 'Velo';
				end;
				if value ~= 'Velo' then
					customHolder.Visible = false;
					hudTarget = nil;
				end;
			end
		});
		HudFont = hudOption(TargetInfoOverlay:CreateFont({
			["Name"] = 'HUD Font',
			["Default"] = 'GothamBlack',
			["Function"] = applyHudStyle,
			["Darker"] = true
		}));
		HudTextColor = hudColor('Text Color', HudTextColor);
		HudBackgroundStart = hudColor('Background Start', HudBackgroundStart);
		HudBackgroundEnd = hudColor('Background End', HudBackgroundEnd);
		HudBackgroundRotation = hudSlider('Background Rotation', 0, 360, 90);
		HudGlow = hudToggle('Glow', true, 'The big purple glow behind the HUD.');
		HudGlowStart = hudColor('Glow Start', HudGlowStart);
		HudGlowEnd = hudColor('Glow End', HudGlowEnd);
		HudGlowTransparency = hudSlider('Glow Transparency', 0, 1, 0, 10);
		HudShadow = hudToggle('Shadow', true);
		HudShadowTransparency = hudSlider('Shadow Transparency', 0, 1, 0.5, 10);
		HudShadowSpread = hudSlider('Shadow Spread', 0, 150, 30, nil, 'px');
		HudShadowOffsetX = hudSlider('Shadow Offset X', -100, 100, 0, nil, 'px');
		HudShadowOffsetY = hudSlider('Shadow Offset Y', -100, 100, 0, nil, 'px');
		HudOutlineStart = hudColor('Outline Start', HudOutlineStart);
		HudOutlineEnd = hudColor('Outline End', HudOutlineEnd);
		HudOutlineThickness = hudSlider('Outline Thickness', 0, 6, 2);
		HudSpinSpeed = hudSlider('Spin Speed', 0, 720, 120, nil, 'deg/s');
		HudCornerRadius = hudSlider('Corner Radius', 0, 40, 20);
		HudAvatar = hudToggle('Show Avatar', true);
		HudHealthText = hudToggle('Show Health %', true);
		HudStatus = hudToggle('Show Winning/Losing', true);
		HudHealthColor = hudColor('Health Color', HudHealthColor);
		HudMidColor = hudColor('Mid Health Color', HudMidColor);
		HudLowColor = hudColor('Low Health Color', HudLowColor);
		HudTween = hudSlider('Health Tween', 0, 1, 0.2, 100, 's');
		applyHudStyle();

		targetinfo.Update = function(self: table): ()
			local now: number = os.clock();
			local stamp: number = tick();
			local entity: any = nil;
			local highest: number = 0;
			for index: any, expire: any in table.clone(self.Targets) do
				local remaining: number = type(expire) == 'number' and (expire > 1e8 and expire - stamp or expire - now) or 0;
				if remaining <= 0 then
					self.Targets[index] = nil;
				elseif remaining > highest then
					entity = index;
					highest = remaining;
				end;
			end;

			if HudStyle["Value"] == 'Velo' then
				holder.Visible = false;
				updateCustom(entity);
				if entity and not entity.Character then
					table.clear(entity);
				end;
				return;
			end;
			customHolder.Visible = false;

			holder.Visible = entity ~= nil or clickgui.Visible;
			if entity then
				nameLabel.Text = entity.Player and (DisplayName.Enabled and entity.Player.DisplayName or entity.Player.Name) or entity.Character and entity.Character.Name or nameLabel.Text;
				headshot.Image = 'rbxthumb://type=AvatarHeadShot&id='..(entity.Player and entity.Player.UserId or 1)..'&w=420&h=420';
		
				if not entity.Character then
					entity.Health = entity.Health or 0;
					entity.MaxHealth = entity.MaxHealth or 100;
				end;
		
				if entity.Health ~= self.Health or entity.MaxHealth ~= self.MaxHealth then
					local percent: number = math.max(entity.Health / entity.MaxHealth, 0);
		
					tween:Tween(healthBar, TweenInfo.new(0.3), {
						["Size"] = UDim2.fromScale(math.min(percent, 1), 1), ["BackgroundColor3"] = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
					});
		
					tween:Tween(armor, TweenInfo.new(0.3), {
						["Size"] = UDim2.fromScale(math.clamp(percent - 1, 0, 0.8), 1)
					});
		
					if self.Health > entity.Health and self.LastTarget == entity then
						tween:Cancel(hurtFlash);
						hurtFlash.BackgroundTransparency = 0.3;
						tween:Tween(hurtFlash, TweenInfo.new(0.5), {
							["BackgroundTransparency"] = 1
						});
					end;
		
					self.Health = entity.Health;
					self.MaxHealth = entity.MaxHealth;
				end;
		
				if not entity.Character then
					table.clear(entity);
				end;
		
				self.LastTarget = entity;
			end;
		end;
		
		vape.Libraries.targetinfo = targetinfo;
	end);
	
	vape:Clean(task.spawn(function(): ()
		local hue: number = 0;
		repeat
			for _: any, component: table in vape.RainbowSliders do
				if component.Type == 'GUISlider' then
					component:SetValue(vape:SampleColor(0):ToHSV());
				else
					component:SetValue(hue);
				end;
			end;

			local delta: number = task.wait(1 / vape.RainbowUpdateSpeed.Value);
			local step: number = delta * 0.2 * vape.RainbowSpeed.Value;
			hue = (hue + step) % 1;
			colorAnim["Phase"] = (colorAnim["Phase"] + step * colorAnim["Speed"] / colorAnim["Spread"]) % 1;
		until false;
	end));
	
	local cursorConnection: RBXScriptConnection?;
	vape:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function(): ()
		vape:UpdateGUI();
	
		if clickgui.Visible and inputService.MouseEnabled then
			if cursorConnection then
				cursorConnection:Disconnect();
			end;
	
			cursorConnection = runService.RenderStepped:Connect(function(): ()
				local isVisible: any = clickgui.Visible;
				for _: any, window: any in vape.Windows do
					isVisible = isVisible or window.Visible;
				end;
	
				if not isVisible then
					cursor.Visible = false;
					cursorConnection:Disconnect();
					cursorConnection = nil;
					return;
				end;
	
				cursor.Visible = not inputService.MouseIconEnabled;
				if cursor.Visible then
					local mouseLocation: Vector2 = inputService:GetMouseLocation();
					cursor.Position = UDim2.fromOffset(mouseLocation.X - 31, mouseLocation.Y - 32);
				end;
			end);
		end;
	end));
	
	vape:Clean(function(): ()
		if cursorConnection then
			cursorConnection:Disconnect();
		end;
	end);
	
	vape:Clean(gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function(): ()
		if vape.Scale.Enabled then
			scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6);
		end;
	end));
	
	vape:Clean(notifications.ChildRemoved:Connect(function(): ()
		local offset: number = 29;
		for _: number, notif: any in notifications:GetChildren() do
			offset += notif.Size.Y.Offset + 3;
			if tween.Tween then
				tween:Tween(notif, TweenInfo.new(0.326, Enum.EasingStyle.Exponential), {
					["Position"] = UDim2.new(1, 0, 1, -offset)
				});
			end;
		end;
	end));
	
	vape:Clean(scale:GetPropertyChangedSignal('Scale'):Connect(function(): ()
		scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale);
	
		for _: any, obj: any in scaledgui:QueryDescendants('GuiObject >> [Visible = true]') do
			obj.Visible = false;
			obj.Visible = true;
		end;
	end));
	
	vape:Clean(vape.GUIBind.Triggered:Connect(function(): ()
		if vape.ThreadFix then
			setthreadidentity(8);
		end;
	
		for _: any, window: any in self.Windows do
			window.Visible = false;
		end;
	
		for _: any, module: any in self.Modules do
			if module.Bind.Mobile then
				module.Bind.Mobile.Visible = clickgui.Visible;
			end;
		end;
	
		clickgui.Visible = not clickgui.Visible;
		vape:BlurCheck();
	end));
	
	vape:Clean(inputService.InputBegan:Connect(function(input: InputObject): ()
		if vape.CurrentTooltip and input.KeyCode == Enum.KeyCode.LeftShift then
			vape.CurrentTooltip();
		end;
	
		if vape.Autocomplete and input.KeyCode == Enum.KeyCode.Tab then
			vape.Autocomplete();
		end;
	
		if not inputService:GetFocusedTextBox() and input.KeyCode ~= Enum.KeyCode.Unknown then
			table.insert(vape.HeldKeybinds, input.KeyCode.Name);
			if vape.Binding then return; end;
	
			for _: any, bind: any in vape.ActiveBinds do
				if checkKeybinds(vape.HeldKeybinds, bind.Keys, input.KeyCode.Name) then
					bind.Triggered:Fire(true);
				end;
			end;
		end;
	end));
	
	vape:Clean(inputService.InputEnded:Connect(function(input: InputObject): ()
		if vape.CurrentTooltip and input.KeyCode == Enum.KeyCode.LeftShift then
			vape.CurrentTooltip();
		end;
	
		if not inputService:GetFocusedTextBox() and input.KeyCode ~= Enum.KeyCode.Unknown then
			if vape.Binding then
				if not vape.MultiKeybind.Enabled then
					vape.HeldKeybinds = {input.KeyCode.Name};
				end;
	
				vape.Binding:SetBind(vape.HeldKeybinds, true);
				vape.Binding = nil;
			else
				for _: any, bind: any in vape.ActiveBinds do
					if bind.Hold and checkKeybinds(vape.HeldKeybinds, bind.Keys, input.KeyCode.Name) then
						bind.Triggered:Fire(false);
					end;
				end;
			end;
		end;
	
		local index: number? = table.find(vape.HeldKeybinds, input.KeyCode.Name);
		if index then
			table.remove(vape.HeldKeybinds, index);
		end;
	end));
end;

vape.Remove = function(self: table, obj: string): ()
	local container: any = (self.Modules[obj] and self.Modules or self.Legit.Modules[obj] and self.Legit.Modules or self.Categories);
	if container and container[obj] then
		local component: any = container[obj];
		local isModule: boolean = component.Type == 'Module';
		if self.ThreadFix then
			setthreadidentity(8);
		end;

		if component.Destroy then
			component:Destroy();
		end;

		for _: number, child: string in {'Object', 'Children', 'Toggle', 'Button'} do
			child = typeof(component[child]) == 'table' and component[child].Object or component[child];

			if typeof(child) == 'Instance' then
				child:Destroy();
				child:ClearAllChildren();
			end;
		end;

		loopClean(component);
		container[obj] = nil;

		if isModule then
			self:SortCategories();
		end;
	end;
end;

vape.SaveGuiSettings = function(self: table): table
	local settings: table = {};
	for _: any, pane: table in self.Settings do
		pane:Save(settings);
	end;
	local lists: table = {};
	for _: number, name: string in {'Friends', 'Targets'} do
		local category: table? = self.Categories[name];
		if category then
			lists[name] = {
				["List"] = table.clone(category.List),
				["ListEnabled"] = table.clone(category.ListEnabled),
				["Options"] = self:SaveOptions(category)
			};
		end;
	end;
	return {["Settings"] = settings, ["Lists"] = lists};
end;

vape.LoadGuiSettings = function(self: table, data: table?): ()
	if type(data) ~= 'table' then
		return;
	end;
	if type(data.Settings) == 'table' then
		for name: string, paneData: any in data.Settings do
			local pane: table? = self.Settings[name];
			if pane and type(paneData) == 'table' then
				pane:Load(paneData);
			end;
		end;
	end;
	if type(data.Lists) == 'table' then
		for name: string, listData: any in data.Lists do
			local category: table? = self.Categories[name];
			if category and type(listData) == 'table' then
				category.List = type(listData.List) == 'table' and table.clone(listData.List) or {};
				category.ListEnabled = type(listData.ListEnabled) == 'table' and table.clone(listData.ListEnabled) or {};
				if type(listData.Options) == 'table' then
					self:LoadOptions(category, listData.Options);
				end;
				category:ChangeValue(nil, true);
			end;
		end;
	end;
end;

vape.SnapshotProfile = function(self: table, id: string): ()
	local mainData: table = {
		["Modules"] = {},
		["Categories"] = {},
		["Legit"] = {},
		["v"] = 1
	};

	for _: any, category: table in self.Categories do
		if category.Type == 'Overlay' then
			category:Save(mainData.Categories);
		end;
	end;

	for _: any, module: table in self.Modules do
		module:Save(mainData.Modules);
	end;

	for _: any, module: table in self.Legit.Modules do
		module:Save(mainData.Legit);
	end;

	local path: string = profilePath(id);
	if isGlobalProfile(id) then
		mainData.Gui = self:SaveGuiSettings();
		ensureGlobalFolder();
		if isfile(path) then
			mainData = mergeProfileData(loadJson(path), mainData);
		end;
	end;

	writefile(path, httpService:JSONEncode(mainData));
end;

vape.Save = function(self: table, newProfile: string?): ()
	if not self.Loaded then
		return;
	end;

	local guiData: table = {
		["Categories"] = {},
		["Profile"] = newProfile or self.Profile,
		["v"] = 1
	};

	for _: any, category: any in self.Categories do
		if category.Type ~= 'Overlay' then
			category:Save(guiData.Categories);
		end;
	end;

	writefile('velo/profiles/'..game.GameId..'.gui.txt', httpService:JSONEncode(guiData));
	self:SnapshotProfile(self.Profile);
end;

vape.SaveOptions = function(self: table, obj: table): table
	local data: table = {};
	for _: any, component: any in obj.Options do
		if not component.Save then
			continue;
		end;

		component:Save(data);
	end;

	return data;
end;

vape.SortCategories = function(self: table): ()
	local sorting: table = {};
	for _: any, module: any in self.Modules do
		sorting[module.Category] = sorting[module.Category] or {};
		table.insert(sorting[module.Category], module.Name);
	end;

	for _: any, sort: any in sorting do
		table.sort(sort);

		local index: number = 2;
		for _: any, name: any in sort do
			self.Modules[name].Index = index / 2;
			self.Modules[name].Object.LayoutOrder = index;
			self.Modules[name].Children.LayoutOrder = index + 1;
			index += 2;
		end;
	end;
end;

vape.Uninject = function(self: table): ()
	self:Save();
	self.Loaded = nil;

	for _: any, module: any in self.Modules do
		if module.Enabled then
			pcall(function(): ()
				module:Toggle();
			end);
		end;
	end;

	for _: any, module: any in self.Legit.Modules do
		if module.Enabled then
			pcall(function(): ()
				module:Toggle();
			end);
		end;
	end;

	for _: any, category: any in self.Categories do
		if category.Type == 'Overlay' and category.Button.Enabled then
			pcall(function(): ()
				category.Button:Toggle();
			end);
		end;
	end;

	for _: any, connection: any in self.Connections do
		pcall(function(): ()
			connection:Disconnect();
		end);
	end;

	if self.ThreadFix then
		setthreadidentity(8);
		clickgui.Visible = false;
		self:BlurCheck();
	end;

	gui:ClearAllChildren();
	gui:Destroy();
	table.clear(self.Connections);
	table.clear(self.Libraries);
	loopClean(self);

	shared.veloc = nil;
	shared.veloreload = nil;
	shared.VeloIndependent = nil;
end;

local guiUpdatePending: boolean = false;
vape.UpdateGUI = function(self: table): ()
	guiUpdatePending = true;
end;

task.spawn(function(): ()
	repeat
		runService.RenderStepped:Wait();
		if guiUpdatePending and vape.Loaded ~= nil and vape.GUIColor then
			guiUpdatePending = false;
			task.spawn(vape.UpdateGUIQueue, vape, vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value);
		end;
	until vape.Loaded == nil;
end);

vape.UpdateGUIQueue = function(self: table, hue: number, sat: number, val: number): ()
	if TextGUI.Button.Enabled then
		TextGUI:UpdateColor(hue, sat, val, default);
	end;

	if not clickgui.Visible and not vape.Legit.Window.Visible then return; end;
	local isRainbow: any = vape.GUIColor.Rainbow and vape.RainbowMode.Value ~= 'Retro';

	for name: any, component: any in vape.Categories do
		component:Color(hue, sat, val, isRainbow);
	end;

	for _: any, component: any in vape.Modules do
		component:Color(hue, sat, val, isRainbow);
	end;

	for _: any, component: any in vape.Overlays.Options do
		if component.Color then
			component:Color(hue, sat, val, isRainbow);
		end;
	end;

	for _: any, pane: any in vape.Settings do
		for _: any, component: any in pane.Options do
			if component.Color then
				component:Color(hue, sat, val, isRainbow);
			end;
		end;
	end;

	if vape.Legit.Window.Visible then
		for _: any, component: any in vape.Legit.Modules do
			component:Color(hue, sat, val, isRainbow);
		end;
	end;
end;

components = {
	["Bind"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Hold"] = props.Hold or false,
			["Keys"] = {},
			["Triggered"] = createSignal(),
			["Type"] = 'Bind'
		};
		
		local bind: TextButton = Instance.new('TextButton');
		bind.AnchorPoint = Vector2.new(1, 0);
		bind.AutoButtonColor = false;
		bind.BackgroundColor3 = Color3.new(1, 1, 1);
		bind.BackgroundTransparency = 0.92;
		bind.BorderSizePixel = 0;
		bind.Name = 'Bind';
		bind.Size = UDim2.fromOffset(20, 20);
		bind.Visible = false;
		bind.Text = '';
		addCorner(bind, UDim.new(0, 4));
		addTooltip(bind, '', function(): string
			local holdText: string = 'Bind functionality = '..(component.Hold and 'Enable while held' or 'Toggle');
			if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				holdText = "<font color='#FF5A5A'>"..holdText.."</font>";
			end;
		
			return 'Click to bind\nShift click to modify bind functionality\n'..holdText;
		end);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = getvapeasset('velo/assets/new/bind.png');
		icon.ImageColor3 = color.Dark(uipallet.Text, 0.43);
		icon.Name = 'Icon';
		icon.Position = UDim2.new(0.5, -5, 0, 5);
		icon.Size = UDim2.fromOffset(10, 10);
		icon.Parent = bind;
		local label: TextLabel = Instance.new('TextLabel');
		label.BackgroundTransparency = 1;
		label.FontFace = uipallet.Font;
		label.Position = UDim2.fromOffset(-1, 0);
		label.Size = UDim2.fromScale(1, 1);
		label.Text = '';
		label.TextColor3 = color.Dark(uipallet.Text, 0.43);
		label.TextSize = 12;
		label.Visible = false;
		label.Parent = bind;
		local cover: ImageLabel;
		local coverlabel: TextLabel;
		
		if props.Module then
			if props.Cover then
				cover = Instance.new('ImageLabel');
				cover.BackgroundTransparency = 1;
				cover.Image = getvapeasset('velo/assets/new/bindbkg.png');
				cover.Name = 'Cover';
				cover.ScaleType = Enum.ScaleType.Slice;
				cover.SliceCenter = Rect.new(0, 0, 141, 40);
				cover.Size = UDim2.fromOffset(154, 40);
				cover.Visible = false;
				cover.Parent = api.Object;
				coverlabel = Instance.new('TextLabel');
				coverlabel.BackgroundTransparency = 1;
				coverlabel.FontFace = uipallet.Font;
				coverlabel.Name = 'Text';
				coverlabel.Size = UDim2.new(1, -10, 1, -3);
				coverlabel.Text = 'PRESS A KEY TO BIND';
				coverlabel.TextColor3 = uipallet.Text;
				coverlabel.TextSize = 11;
				coverlabel.Parent = cover;
			end;
		
			bind.Position = UDim2.new(1, -36, 0, 10);
			bind.Parent = api.Object;
			component.Object = bind;
		else
			local holder: TextButton = Instance.new('TextButton');
			holder.AutoButtonColor = false;
			holder.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
			holder.BorderSizePixel = 0;
			holder.FontFace = uipallet.Font;
			holder.Size = UDim2.new(1, 0, 0, 40);
			holder.RichText = true;
			holder.Text = indent(10)..richEscape(props.Name);
			holder.TextColor3 = color.Dark(uipallet.Text, 0.16);
			holder.TextSize = 14;
			holder.TextXAlignment = Enum.TextXAlignment.Left;
			holder.Visible = props.Visible == nil or props.Visible;
			holder.Parent = children;
			addTooltip(holder, props.Tooltip);
			bind.Position = UDim2.new(1, -10, 0, 10);
			bind.Visible = true;
			bind.Parent = holder;
			component.Object = holder;
		end;
		
		component.CreateMobileButton = function(self: table, position: any): ()
			self:DestroyMobileButton();
		
			local isHeld: boolean = false;
			local button: TextButton = Instance.new('TextButton');
			button.AnchorPoint = Vector2.new(0.5, 0.5);
			button.BackgroundColor3 = api.Enabled and Color3.new(0, 0.7, 0) or Color3.new();
			button.BackgroundTransparency = 0.5;
			button.Font = Enum.Font.Gotham;
			button.Position = UDim2.fromOffset(position.X, position.Y);
			button.Size = UDim2.fromOffset(40, 40);
			button.Text = api.Name or 'Button';
			button.TextColor3 = Color3.new(1, 1, 1);
			button.TextScaled = true;
			button.Parent = gui;
			local constraint: UITextSizeConstraint = Instance.new('UITextSizeConstraint');
			constraint.MaxTextSize = 16;
			constraint.Parent = button;
			addCorner(button, UDim.new(1, 0));
		
			button.MouseButton1Down:Connect(function(): ()
				isHeld = true;
		
				local holdtime: number, holdPos: Vector2 = os.clock(), inputService:GetMouseLocation();
				repeat
					isHeld = (inputService:GetMouseLocation() - holdPos).Magnitude < 6;
		
					task.wait();
				until (os.clock() - holdtime) > 1 or not isHeld;
		
				if isHeld then
					self:DestroyMobileButton();
				end;
			end);
		
			button.MouseButton1Up:Connect(function(): ()
				isHeld = false;
			end);
		
			button.MouseButton1Click:Connect(function(): ()
				self.Triggered:Fire(true);
				button.BackgroundColor3 = api.Enabled and Color3.new(0, 0.7, 0) or Color3.new();
			end);
		
			self.Mobile = button;
		end;
		
		component.Destroy = function(self: table): ()
			bind:Destroy();
			bind:ClearAllChildren();
		
			if self.Object then
				self.Object:Destroy();
				self.Object:ClearAllChildren();
			end;
		
			if self.Mobile then
				self.Mobile:Destroy();
				self.Mobile = nil;
			end;
		
			local index: number? = table.find(vape.ActiveBinds, self);
			if index then
				table.remove(vape.ActiveBinds, index);
			end;
		end;
		
		component.DestroyMobileButton = function(self: table): ()
			if self.Mobile then
				self.Mobile:Destroy();
				self.Mobile = nil;
			end;
		end;
		
		component.Load = function(self: table, data: table): ()
			self.Hold = data.Hold;
			self:SetBind(data.Keys);
		
			if data.Mobile then
				self:CreateMobileButton(Vector2.new(data.Mobile.X, data.Mobile.Y));
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props and props.Name or 'Bind'] = {
				["Keys"] = self.Keys,
				["Mobile"] = self.Mobile and {
					["X"] = self.Mobile.Position.X.Offset,
					["Y"] = self.Mobile.Position.Y.Offset
				},
				["Hold"] = self.Hold
			};
		end;
		
		component.SetBind = function(self: table, keys: table, mouse: boolean?): ()
			if props and props.NoRemove and #keys <= 0 then
				keys = props.Default;
			end;
		
			self.Binding = nil;
			self.Keys = table.clone(keys);
		
			if mouse then
				icon.Image = getvapeasset('velo/assets/new/edit.png');
		
				if cover then
					coverlabel.Text = #keys <= 0 and 'BIND REMOVED' or 'BOUND TO';
					cover.Size = UDim2.fromOffset(getfontbounds(coverlabel.Text, coverlabel.TextSize, coverlabel.FontFace).X + 20, 40);
		
					task.delay(1, function(): ()
						cover.Visible = false;
					end);
				end;
			end;
		
			if #keys <= 0 then
				label.Visible = false;
				icon.Visible = true;
				bind.Size = UDim2.fromOffset(20, 20);
		
				local index: number? = table.find(vape.ActiveBinds, component);
				if index then
					table.remove(vape.ActiveBinds, index);
				end;
			else
				bind.Visible = true;
				label.Visible = true;
				icon.Visible = false;
				label.Text = table.concat(keys, ' + '):upper();
				bind.Size = UDim2.fromOffset(math.max(getfontbounds(label.Text, label.TextSize, label.FontFace).X + 10, 20), 20);
		
				if not table.find(vape.ActiveBinds, component) then
					table.insert(vape.ActiveBinds, component);
				end;
			end;
		end;
		
		component.SetColor = function(self: table, newColor: Color3): ()
			icon.ImageColor3 = newColor;
			label.TextColor3 = newColor;
		end;
		
		component.SetParent = function(self: table, parent: Instance): ()
			bind.Parent = parent;
		
			if cover then
				cover.Parent = parent;
			end;
		end;
		
		component.SetVisible = function(self: table, visible: boolean): ()
			bind.Visible = #self.Keys > 0 or visible;
		end;
		
		bind.MouseEnter:Connect(function(): ()
			label.Visible = false;
			icon.Visible = not label.Visible;
			icon.Image = getvapeasset(component.Binding and 'velo/assets/new/close.png' or 'velo/assets/new/edit.png');
		
			if not props.Cover or not api.Enabled then
				icon.ImageColor3 = color.Dark(uipallet.Text, 0.16);
			end;
		end);
		
		bind.MouseLeave:Connect(function(): ()
			label.Visible = #component.Keys > 0;
			icon.Visible = not label.Visible;
			icon.Image = getvapeasset(component.Binding and 'velo/assets/new/close.png' or 'velo/assets/new/bind.png');
		
			if not props.Cover or not api.Enabled then
				icon.ImageColor3 = color.Dark(uipallet.Text, 0.43);
			end;
		end);
		
		bind.MouseButton1Click:Connect(function(): ()
			if vape.Binding then
				if vape.Binding == component then
					component:SetBind({}, true);
					vape.Binding = nil;
				end;
		
				return;
			end;
		
			if props.Module and inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				component.Hold = not component.Hold;
				if vape.CurrentTooltip then
					vape.CurrentTooltip();
				end;
		
				return;
			end;
		
			if cover then
				coverlabel.Text = 'PRESS A KEY TO BIND';
				cover.Size = UDim2.fromOffset(getfontbounds(coverlabel.Text, coverlabel.TextSize, coverlabel.FontFace).X + 20, 40);
				cover.Visible = true;
			end;
		
			component.Binding = true;
			icon.Image = getvapeasset('velo/assets/new/close.png');
			vape.Binding = component;
		end);
		
		if props.Module then
			api.Bind = component;
		else
			if props.Default then
				component:SetBind(props.Default);
			end;
		
			api.Options[props.Name] = component;
		end;
		
		return component;
	end,
	["Button"] = function(props: table, children: GuiObject, api: table): ()
		local button: TextButton = Instance.new('TextButton');
		button.AutoButtonColor = false;
		button.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		button.BorderSizePixel = 0;
		button.Size = UDim2.new(1, 0, 0, 31);
		button.Text = '';
		button.Parent = children;
		addTooltip(button, props.Tooltip);
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.05);
		holder.Position = UDim2.fromOffset(10, 2);
		holder.Size = UDim2.fromOffset(200, 27);
		holder.Parent = button;
		addCorner(holder);
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundColor3 = uipallet.Main;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(2, 2);
		title.Size = UDim2.new(1, -4, 1, -4);
		title.Text = props.Name;
		title.TextColor3 = color.Dark(uipallet.Text, 0.16);
		title.TextSize = 14;
		title.Parent = holder;
		addCorner(title, UDim.new(0, 4));
		props.Function = props.Function or function(): () end;
		
		button.MouseEnter:Connect(function(): ()
			tween:Tween(holder, uipallet.Tween, {
				["BackgroundColor3"] = color.Light(uipallet.Main, 0.0875)
			});
		end);
		
		button.MouseLeave:Connect(function(): ()
			tween:Tween(holder, uipallet.Tween, {
				["BackgroundColor3"] = color.Light(uipallet.Main, 0.05)
			});
		end);
		
		button.MouseButton1Click:Connect(props.Function);
	end,
	["Category"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Expanded"] = false,
			["Name"] = props.Name,
			["Type"] = 'Category'
		};
		
		local window: TextButton = Instance.new('TextButton');
		window.AutoButtonColor = false;
		window.BackgroundColor3 = uipallet.Main;
		window.Name = props.Name..'Category';
		window.Position = UDim2.fromOffset(236, 60);
		window.Size = UDim2.fromOffset(220, 41);
		window.Text = '';
		window.Visible = false;
		window.Parent = clickgui;
		addBlur(window);
		addCorner(window);
		addDragHandler(window);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = props.Icon;
		icon.ImageColor3 = uipallet.Text;
		icon.Position = UDim2.fromOffset(12, (icon.Size.X.Offset > 20 and 14 or 13));
		icon.Size = props.Size;
		icon.Parent = window;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Size = UDim2.new(1, -(props.Size.X.Offset > 18 and 40 or 33), 0, 41);
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 0);
		title.Text = props.Name;
		title.TextColor3 = uipallet.Text;
		title.TextSize = 13;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = window;
		local pencilbutton: TextButton = Instance.new('TextButton');
		pencilbutton.BackgroundTransparency = 1;
		pencilbutton.Position = UDim2.new(1, -49, 0, 0);
		pencilbutton.Size = UDim2.fromOffset(20, 40);
		pencilbutton.Text = '';
		pencilbutton.Visible = false;
		pencilbutton.Parent = window;
		addTooltip(pencilbutton, 'Edit hidden modules');
		local pencil: ImageLabel = Instance.new('ImageLabel');
		pencil.BackgroundTransparency = 1;
		pencil.Image = getvapeasset('velo/assets/new/editlarge.png');
		pencil.ImageColor3 = Color3.fromRGB(140, 140, 140);
		pencil.Size = UDim2.fromOffset(12, 12);
		pencil.Position = UDim2.fromOffset(4, 14);
		pencil.Parent = pencilbutton;
		local arrowbutton: TextButton = Instance.new('TextButton');
		arrowbutton.BackgroundTransparency = 1;
		arrowbutton.Position = UDim2.new(1, -29, 0, 0);
		arrowbutton.Size = UDim2.fromOffset(27, 40);
		arrowbutton.Text = '';
		arrowbutton.Parent = window;
		local arrow: ImageLabel = Instance.new('ImageLabel');
		arrow.BackgroundTransparency = 1;
		arrow.Image = getvapeasset('velo/assets/new/downexpand.png');
		arrow.ImageColor3 = Color3.fromRGB(140, 140, 140);
		arrow.Size = UDim2.fromOffset(9, 4);
		arrow.Position = UDim2.fromOffset(9, 18);
		arrow.Rotation = 180;
		arrow.Parent = arrowbutton;
		local done: TextButton = Instance.new('TextButton');
		done.BackgroundTransparency = 1;
		done.FontFace = uipallet.Font;
		done.Position = UDim2.new(1, -73, 0, 0);
		done.Size = UDim2.fromOffset(42, 40);
		done.Text = 'DONE';
		done.TextColor3 = Color3.fromRGB(140, 140, 140);
		done.TextSize = 12;
		done.Visible = false;
		done.Parent = window;
		component.Done = done;
		local children: ScrollingFrame = Instance.new('ScrollingFrame');
		children.BackgroundTransparency = 1;
		children.BorderSizePixel = 0;
		children.CanvasSize = UDim2.new();
		children.Name = 'Children';
		children.Position = UDim2.fromOffset(0, 37);
		children.ScrollBarThickness = 2;
		children.ScrollBarImageTransparency = 0.75;
		children.Size = UDim2.new(1, 0, 1, -41);
		children.Visible = false;
		children.Parent = window;
		local divider: Frame = Instance.new('Frame');
		divider.BackgroundColor3 = Color3.new(1, 1, 1);
		divider.BackgroundTransparency = 0.928;
		divider.BorderSizePixel = 0;
		divider.Position = UDim2.fromOffset(0, 37);
		divider.Size = UDim2.new(1, 0, 0, 1);
		divider.Visible = false;
		divider.Parent = window;
		local stroke: UIStroke = Instance.new('UIStroke');
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		stroke.Color = Color3.fromRGB(85, 85, 85);
		stroke.Transparency = 0.8;
		stroke.Parent = window;
		local windowlist: UIListLayout = Instance.new('UIListLayout');
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.Parent = children;
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): () end;
		
		component.Expand = function(self: table): ()
			self.Expanded = not self.Expanded;
			arrow.Rotation = self.Expanded and 0 or 180;

			if self.Expanded then
				if not children.Visible then
					children.Size = UDim2.new(1, 0, 0, 0);
					children.Visible = true;
				end;

				divider.Visible = children.CanvasPosition.Y > 10;
			else
				divider.Visible = false;
				task.delay(0.3, function(): ()
					if not self.Expanded then
						children.Visible = false;
					end;
				end);
			end;

			tween:Tween(children, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				["Size"] = self.Expanded and UDim2.new(1, 0, 1, -41) or UDim2.new(1, 0, 0, 0)
			});
			tween:Tween(window, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				["Size"] = UDim2.fromOffset(220, self.Expanded and math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601) or 41)
			});
		end;
		
		component.Load = function(self: table, data: table): ()
			if data.Enabled then
				self.Button:Toggle();
			end;
		
			if data.Expanded then
				self:Expand();
			end;
		
			if data.Position then
				window.Position = UDim2.fromOffset(data.Position.X, data.Position.Y);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Enabled"] = self.Button.Enabled,
				["Expanded"] = self.Expanded,
				["Position"] = {
					["X"] = window.Position.X.Offset,
					["Y"] = window.Position.Y.Offset
				}
			};
		end;
		
		for index: any, comp: any in components do
			component['Create'..index] = function(_: any, props: table): ...any
				return comp(props, children, component);
			end;
		end;
		
		arrowbutton.MouseButton1Click:Connect(function(): ()
			component:Expand();
		end);
		
		arrowbutton.MouseButton2Click:Connect(function(): ()
			component:Expand();
		end);
		
		arrowbutton.MouseEnter:Connect(function(): ()
			arrow.ImageColor3 = Color3.fromRGB(220, 220, 220);
		end);
		
		arrowbutton.MouseLeave:Connect(function(): ()
			arrow.ImageColor3 = Color3.fromRGB(140, 140, 140);
		end);
		
		done.MouseButton1Click:Connect(function(): ()
			vape.EditGUI = false;
			pencilbutton.Visible = true;
		
			for _: any, category: any in vape.Categories do
				if category.Type == 'Category' then
					category.Done.Visible = false;
				end;
			end;
		
			for _: any, module: any in vape.Modules do
				module.Object.Visible = module.Visible;
				module.Object.Text = indent(12)..richEscape(module.Name);
				module.Edit.Visible = false;
			end;
		end);
		
		done.MouseEnter:Connect(function(): ()
			done.TextColor3 = Color3.fromRGB(220, 220, 220);
		end);
		
		done.MouseLeave:Connect(function(): ()
			done.TextColor3 = Color3.fromRGB(140, 140, 140);
		end);
		
		pencilbutton.MouseButton1Click:Connect(function(): ()
			vape.EditGUI = true;
			pencilbutton.Visible = false;
		
			for _: any, category: any in vape.Categories do
				if category.Type == 'Category' then
					category.Done.Visible = true;
				end;
			end;
		
			for _: any, module: any in vape.Modules do
				module.Object.Visible = true;
				module.Object.Text = indent(50)..richEscape(module.Name);
				module.Edit.Visible = true;
			end;
		end);
		
		pencilbutton.MouseButton2Click:Connect(function(): ()
			component:Expand();
		end);
		
		pencilbutton.MouseEnter:Connect(function(): ()
			pencil.ImageColor3 = Color3.fromRGB(220, 220, 220);
		end);
		
		pencilbutton.MouseLeave:Connect(function(): ()
			pencil.ImageColor3 = Color3.fromRGB(140, 140, 140);
		end);
		
		window.MouseEnter:Connect(function(): ()
			pencilbutton.Visible = not vape.EditGUI;
		end);
		
		window.MouseLeave:Connect(function(): ()
			pencilbutton.Visible = false;
		end);
		
		window.InputBegan:Connect(function(input: InputObject): ()
			if input.Position.Y < window.AbsolutePosition.Y + 41 and input.UserInputType == Enum.UserInputType.MouseButton2 then
				component:Expand();
			end;
		end);
		
		children:GetPropertyChangedSignal('CanvasPosition'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			divider.Visible = children.CanvasPosition.Y > 10 and children.Visible;
		end);
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale);
			if component.Expanded then
				window.Size = UDim2.fromOffset(220, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601));
			end;
		end);
		
		component.Button = vape.Categories.Main:CreateGUIButton({
			["Name"] = props.Name,
			["Icon"] = props.Icon,
			["Size"] = props.Size,
			["Window"] = window
		});
		
		component.Object = window;
		vape.Categories[props.Name] = component;
		
		return component;
	end,
	["CategoryList"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Expanded"] = false,
			["List"] = {},
			["ListEnabled"] = {},
			["Objects"] = {},
			["Options"] = {},
			["Type"] = 'CategoryList'
		};
		props.Color = props.Color or Color3.fromRGB(5, 134, 105);
		
		local window: TextButton = Instance.new('TextButton');
		window.AutoButtonColor = false;
		window.BackgroundColor3 = uipallet.Main;
		window.Name = props.Name..'CategoryList';
		window.Position = UDim2.fromOffset(240, 46);
		window.Size = UDim2.fromOffset(220, 45);
		window.Text = '';
		window.Visible = false;
		window.Parent = clickgui;
		addBlur(window);
		addCorner(window);
		addDragHandler(window);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = props.Icon;
		icon.ImageColor3 = uipallet.Text;
		icon.Name = 'Icon';
		icon.Size = props.Size;
		icon.Position = props.Position or UDim2.fromOffset(12, (props.Size.X.Offset > 20 and 13 or 12));
		icon.Parent = window;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Name = 'Title';
		title.Size = UDim2.new(1, -(props.Size.X.Offset > 20 and 44 or 36), 0, 20);
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 12);
		title.Text = props.Name;
		title.TextColor3 = uipallet.Text;
		title.TextSize = 13;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = window;
		local arrowbutton: TextButton = Instance.new('TextButton');
		arrowbutton.BackgroundTransparency = 1;
		arrowbutton.Name = 'Arrow';
		arrowbutton.Position = UDim2.new(1, -40, 0, 0);
		arrowbutton.Size = UDim2.fromOffset(40, 40);
		arrowbutton.Text = '';
		arrowbutton.Parent = window;
		local arrow: ImageLabel = Instance.new('ImageLabel');
		arrow.Name = 'Arrow';
		arrow.Size = UDim2.fromOffset(9, 4);
		arrow.Position = UDim2.fromOffset(15, 20);
		arrow.BackgroundTransparency = 1;
		arrow.Image = getvapeasset('velo/assets/new/downexpand.png');
		arrow.ImageColor3 = Color3.fromRGB(140, 140, 140);
		arrow.Rotation = 180;
		arrow.Parent = arrowbutton;
		local children: ScrollingFrame = Instance.new('ScrollingFrame');
		children.Name = 'Children';
		children.Size = UDim2.new(1, 0, 1, -45);
		children.Position = UDim2.fromOffset(0, 45);
		children.BackgroundTransparency = 1;
		children.BorderSizePixel = 0;
		children.Visible = false;
		children.ScrollBarThickness = 2;
		children.ScrollBarImageTransparency = 0.75;
		children.CanvasSize = UDim2.new();
		children.Parent = window;
		local childrentwo: Frame = Instance.new('Frame');
		childrentwo.BackgroundTransparency = 1;
		childrentwo.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
		childrentwo.Visible = false;
		childrentwo.Parent = children;
		local settings: ImageButton = Instance.new('ImageButton');
		settings.AutoButtonColor = false;
		settings.BackgroundTransparency = 1;
		settings.Image = getvapeasset('velo/assets/new/settings.png');
		settings.ImageColor3 = color.Dark(uipallet.Text, 0.43);
		settings.Name = 'Settings';
		settings.Position = UDim2.new(1, -56, 0, 15);
		settings.Size = UDim2.fromOffset(14, 14);
		settings.Parent = window;
		local divider: Frame = Instance.new('Frame');
		divider.BackgroundColor3 = Color3.new(1, 1, 1);
		divider.BackgroundTransparency = 0.928;
		divider.BorderSizePixel = 0;
		divider.Name = 'Divider';
		divider.Position = UDim2.fromOffset(0, 41);
		divider.Size = UDim2.new(1, 0, 0, 1);
		divider.Visible = false;
		divider.Parent = window;
		local stroke: UIStroke = Instance.new('UIStroke');
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		stroke.Color = Color3.fromRGB(85, 85, 85);
		stroke.Transparency = 0.8;
		stroke.Parent = window;
		local windowlist: UIListLayout = Instance.new('UIListLayout');
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlist.Padding = UDim.new(0, 4);
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.Parent = children;
		local windowlisttwo: UIListLayout = Instance.new('UIListLayout');
		windowlisttwo.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlisttwo.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlisttwo.Parent = childrentwo;
		local addbkg: Frame = Instance.new('Frame');
		addbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
		addbkg.Position = UDim2.fromOffset(10, 45);
		addbkg.Size = UDim2.fromOffset(200, 31);
		addbkg.Parent = children;
		addCorner(addbkg);
		local addbox: Frame = addbkg:Clone();
		addbox.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
		addbox.Position = UDim2.fromOffset(1, 1);
		addbox.Size = UDim2.new(1, -2, 1, -2);
		addbox.Parent = addbkg;
		local addvalue: TextBox = Instance.new('TextBox');
		addvalue.BackgroundTransparency = 1;
		addvalue.ClearTextOnFocus = false;
		addvalue.FontFace = uipallet.Font;
		addvalue.PlaceholderText = props.Placeholder or 'Add entry...';
		addvalue.PlaceholderColor3 = Color3.new(0.8, 0.8, 0.8);
		addvalue.Position = UDim2.fromOffset(10, 0);
		addvalue.Size = UDim2.new(1, -35, 1, 0);
		addvalue.Text = '';
		addvalue.TextColor3 = Color3.new(1, 1, 1);
		addvalue.TextSize = 13;
		addvalue.TextXAlignment = Enum.TextXAlignment.Left;
		addvalue.Parent = addbkg;
		local autocomplete: TextLabel;
		if props.Player then
			addvalue.ZIndex = 2;
			autocomplete = Instance.new('TextLabel');
			autocomplete.BackgroundTransparency = 1;
			autocomplete.FontFace = uipallet.Font;
			autocomplete.Position = UDim2.fromOffset(10, 0);
			autocomplete.Size = UDim2.new(1, -35, 1, 0);
			autocomplete.Text = '';
			autocomplete.TextColor3 = Color3.new(0.6, 0.6, 0.6);
			autocomplete.TextSize = 13;
			autocomplete.TextXAlignment = Enum.TextXAlignment.Left;
			autocomplete.Parent = addbkg;
		end;
		local addbutton: ImageButton = Instance.new('ImageButton');
		addbutton.BackgroundTransparency = 1;
		addbutton.Image = getvapeasset('velo/assets/new/add.png');
		addbutton.ImageColor3 = props.Color;
		addbutton.ImageTransparency = 0.3;
		addbutton.Position = UDim2.new(1, -26, 0, 8);
		addbutton.Size = UDim2.fromOffset(16, 16);
		addbutton.Parent = addbkg;
		local cursedpadding: Frame = Instance.new('Frame');
		cursedpadding.BackgroundTransparency = 1;
		cursedpadding.Size = UDim2.fromOffset();
		cursedpadding.Parent = children;
		props.Function = props.Function or function(): () end;
		
		local scopeButtons: {[string]: TextButton} = {};
		if props.Profiles then
			component.Scope = 'Game';
			local scopebar: Frame = Instance.new('Frame');
			scopebar.BackgroundTransparency = 1;
			scopebar.LayoutOrder = -1;
			scopebar.Size = UDim2.fromOffset(200, 26);
			scopebar.Parent = children;
			for index: number, scope: string in {'Game', 'Global'} do
				local button: TextButton = Instance.new('TextButton');
				button.AutoButtonColor = false;
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
				button.FontFace = uipallet.Font;
				button.Text = scope == 'Game' and 'This Game' or 'All Games';
				button.TextSize = 13;
				button.TextColor3 = color.Dark(uipallet.Text, 0.4);
				button.Position = UDim2.fromOffset((index - 1) * 102, 0);
				button.Size = UDim2.fromOffset(98, 26);
				button.Parent = scopebar;
				addCorner(button);
				scopeButtons[scope] = button;
				button.MouseButton1Click:Connect(function(): ()
					if component.Scope ~= scope then
						component.Scope = scope;
						component:ChangeValue();
					end;
				end);
			end;
		end;
		local updateScopeButtons: () -> () = function(): ()
			for scope: string, button: TextButton in scopeButtons do
				local active: boolean = component.Scope == scope;
				button.BackgroundColor3 = active and color.Light(uipallet.Main, 0.14) or color.Light(uipallet.Main, 0.02);
				button.TextColor3 = active and uipallet.Text or color.Dark(uipallet.Text, 0.4);
			end;
		end;

		component.CreateProfile = function(self: table, value: string, data: table?, global: boolean?): ()
			local profile: table = {
				["Name"] = value,
				["Global"] = global == true
			};
		
			profile.Bind = components.Bind({
				["Module"] = true,
				["Cover"] = true
			}, nil, profile);
			profile.Bind.Object.Position = UDim2.new(1, -30, 0, 7);
			profile.Bind.Triggered:Connect(function(isPressed: boolean): ()
				if isPressed and vape.Profile ~= profileId(profile) then
					vape:Save(profileId(profile));
					vape:Load(true);
					self:ChangeValue();
				end;
			end);
		
			if data then
				profile.Bind:Load(data);
			end;
		
			table.insert(self.List, profile);
		end;
		
		component.ChangeValue = function(self: table, value: string?, skipGUI: boolean?, forceGlobal: boolean?): ()
			if value then
				if props.Profiles then
					local global: boolean? = if forceGlobal ~= nil then forceGlobal else self.Scope == 'Global';
					local index: any, profile: any = self:GetValue(value, global);
					if index then
						if global or value ~= 'default' then
							profile.Bind:Destroy();
							table.remove(self.List, index);
		
							if isfile(profilePath(profileId(profile))) and delfile then
								delfile(profilePath(profileId(profile)));
							end;
						end;
					elseif value ~= '' and not value:find('/') then
						self:CreateProfile(value, nil, global);
						if global and vape.Loaded then
							vape:SnapshotProfile(globalPrefix .. value);
						end;
					end;
				else
					local index: number? = table.find(self.List, value);
					if index then
						table.remove(self.List, index);
		
						index = table.find(self.ListEnabled, value);
						if index then
							table.remove(self.ListEnabled, index);
						end;
					else
						table.insert(self.List, value);
						table.insert(self.ListEnabled, value);
					end;
				end;
			end;
		
			props.Function();
			for _: any, obj: any in self.Objects do
				obj:Destroy();
			end;
			table.clear(self.Objects);
			self.Selected = nil;
		
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			if props.Profiles then
				updateScopeButtons();
			end;

			for _: any, name: any in self.List do
				if props.Profiles then
					if (name.Global == true) ~= (self.Scope == 'Global') then
						continue;
					end;
					local obj: TextButton = Instance.new('TextButton');
					obj.Name = name.Name;
					obj.Size = UDim2.fromOffset(200, 32);
					obj.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
					obj.AutoButtonColor = false;
					obj.Text = '';
					obj.Parent = children;
					addCorner(obj);
					local stroke: UIStroke = Instance.new('UIStroke');
					stroke.Color = color.Light(uipallet.Main, 0.1);
					stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					stroke.Enabled = false;
					stroke.Parent = obj;
					local label: TextLabel = Instance.new('TextLabel');
					label.Name = 'Title';
					label.Size = UDim2.new(1, -10, 1, 0);
					label.Position = UDim2.fromOffset(10, 0);
					label.BackgroundTransparency = 1;
					label.Text = name.Name;
					label.TextXAlignment = Enum.TextXAlignment.Left;
					label.TextColor3 = color.Dark(uipallet.Text, 0.4);
					label.TextSize = 15;
					label.FontFace = uipallet.Font;
					label.Parent = obj;
					local dotsbutton: TextButton = Instance.new('TextButton');
					dotsbutton.BackgroundTransparency = 1;
					dotsbutton.Name = 'Dots';
					dotsbutton.Position = UDim2.new(1, -25, 0, 0);
					dotsbutton.Size = UDim2.fromOffset(25, 32);
					dotsbutton.Text = '';
					dotsbutton.Parent = obj;
					local dots: ImageLabel = Instance.new('ImageLabel');
					dots.BackgroundTransparency = 1;
					dots.Image = getvapeasset('velo/assets/new/settingdots.png');
					dots.ImageColor3 = color.Light(uipallet.Main, 0.37);
					dots.Name = 'Dots';
					dots.Position = UDim2.fromOffset(11, 9);
					dots.Size = UDim2.fromOffset(3, 16);
					dots.Parent = dotsbutton;
					name.Bind:SetParent(obj);
					name.Enabled = profileId(name) == vape.Profile;
		
					dotsbutton.MouseButton1Click:Connect(function(): ()
						if not name.Enabled then
							component:ChangeValue(name.Name);
						end;
					end);
		
					dotsbutton.MouseEnter:Connect(function(): ()
						if not name.Enabled then
							dots.ImageColor3 = uipallet.Text;
						end;
					end);
		
					dotsbutton.MouseLeave:Connect(function(): ()
						if not name.Enabled then
							dots.ImageColor3 = color.Light(uipallet.Main, 0.37);
						end;
					end);
		
		
					obj.MouseButton1Click:Connect(function(): ()
						vape:Save(profileId(name));
						vape:Load(true);
						self:ChangeValue();
					end);
		
					obj.MouseEnter:Connect(function(): ()
						name.Bind:SetVisible(true);
					end);
		
					obj.MouseLeave:Connect(function(): ()
						name.Bind:SetVisible(false);
					end);
		
					if name.Enabled then
						self.Selected = obj;
					else
						name.Bind:SetColor(color.Dark(uipallet.Text, 0.43));
					end;
		
					table.insert(self.Objects, {
						["Destroy"] = function(): ()
							name.Bind:SetParent(nil);
							obj:Destroy();
						end
					});
				else
					local isEnabled: number? = table.find(self.ListEnabled, name);
					local obj: TextButton = Instance.new('TextButton');
					obj.Name = name;
					obj.Size = UDim2.fromOffset(200, 31);
					obj.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
					obj.AutoButtonColor = false;
					obj.Text = '';
					obj.Parent = children;
					addCorner(obj);
					local bkg: Frame = Instance.new('Frame');
					bkg.BackgroundColor3 = uipallet.Main;
					bkg.Position = UDim2.fromOffset(1, 1);
					bkg.Size = UDim2.new(1, -2, 1, -2);
					bkg.Visible = false;
					bkg.Parent = obj;
					addCorner(bkg);
					local dot: Frame = Instance.new('Frame');
					dot.BackgroundColor3 = isEnabled and props.Color or color.Light(uipallet.Main, 0.37);
					dot.Position = UDim2.fromOffset(10, 12);
					dot.Size = UDim2.fromOffset(10, 11);
					dot.Parent = obj;
					addCorner(dot, UDim.new(1, 0));
					local dotin: Frame = dot:Clone();
					dotin.BackgroundColor3 = isEnabled and props.Color or color.Light(uipallet.Main, 0.02);
					dotin.Position = UDim2.fromOffset(1, 1);
					dotin.Size = UDim2.fromOffset(8, 9);
					dotin.Parent = dot;
					local label: TextLabel = Instance.new('TextLabel');
					label.BackgroundTransparency = 1;
					label.FontFace = uipallet.Font;
					label.Position = UDim2.fromOffset(30, 0);
					label.Size = UDim2.new(1, -30, 1, 0);
					label.Text = name;
					label.TextColor3 = color.Dark(uipallet.Text, 0.16);
					label.TextSize = 15;
					label.TextXAlignment = Enum.TextXAlignment.Left;
					label.Parent = obj;
					local close: ImageButton = Instance.new('ImageButton');
					close.AutoButtonColor = false;
					close.BackgroundColor3 = Color3.new(1, 1, 1);
					close.BackgroundTransparency = 1;
					close.Image = getvapeasset('velo/assets/new/closetiny.png');
					close.ImageColor3 = color.Light(uipallet.Text, 0.2);
					close.ImageTransparency = 0.5;
					close.Position = UDim2.new(1, -27, 0, 8);
					close.Size = UDim2.fromOffset(18, 17);
					close.Parent = obj;
					addCorner(close, UDim.new(1, 0));
		
					close.MouseEnter:Connect(function(): ()
						close.ImageTransparency = 0.3;
						tween:Tween(close, uipallet.Tween, {
							["BackgroundTransparency"] = 0.6
						});
					end);
		
					close.MouseLeave:Connect(function(): ()
						close.ImageTransparency = 0.5;
						tween:Tween(close, uipallet.Tween, {
							["BackgroundTransparency"] = 1
						});
					end);
		
					close.MouseButton1Click:Connect(function(): ()
						component:ChangeValue(name);
					end);
		
					obj.MouseEnter:Connect(function(): ()
						bkg.Visible = true;
					end);
		
					obj.MouseLeave:Connect(function(): ()
						bkg.Visible = false;
					end);
		
					obj.MouseButton1Click:Connect(function(): ()
						local index: number? = table.find(self.ListEnabled, name);
						if index then
							table.remove(self.ListEnabled, index);
							dot.BackgroundColor3 = color.Light(uipallet.Main, 0.37);
							dotin.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
						else
							table.insert(self.ListEnabled, name);
							dot.BackgroundColor3 = props.Color;
							dotin.BackgroundColor3 = props.Color;
						end;
		
						props.Function();
					end);
		
					table.insert(self.Objects, obj);
				end;
			end;
		
			if not skipGUI then
				vape:UpdateGUI();
			end;
		end;
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			for _: any, component: any in self.Options do
				if component.Color then
					component:Color(hue, sat, val, isRainbow);
				end;
			end;
		
			addbutton.ImageColor3 = isRainbow and vape:SampleColor(0) or Color3.fromHSV(hue, sat, val);
		
			if self.Selected then
				self.Selected.BackgroundColor3 = isRainbow and vape:SampleColor(0) or Color3.fromHSV(hue, sat, val);
				self.Selected.Title.TextColor3 = vape.GUIColor.Rainbow and vape:AnimatedTextColor(self.Selected.BackgroundColor3) or vape:TextColor(hue, sat, val);
				self.Selected.Dots.Dots.ImageColor3 = self.Selected.Title.TextColor3;
				self.Selected.Bind.Icon.ImageColor3 = self.Selected.Title.TextColor3;
				self.Selected.Bind.TextLabel.TextColor3 = self.Selected.Title.TextColor3;
			end;
		end;
		
		component.Expand = function(self: table): ()
			self.Expanded = not self.Expanded;
			children.Visible = self.Expanded;
			arrow.Rotation = self.Expanded and 0 or 180;
			window.Size = UDim2.fromOffset(220, self.Expanded and math.min(51 + windowlist.AbsoluteContentSize.Y / scale.Scale, 611) or 45);
			divider.Visible = children.CanvasPosition.Y > 10 and children.Visible;
		end;
		
		component.GetValue = function(self: table, name: string, global: boolean?): (any, any)
			for index: any, profile: any in self.List do
				if profile.Name == name and (not props.Profiles or (profile.Global == true) == (global == true)) then
					return index, profile;
				end;
			end;
		end;

		component.LoadGlobal = function(self: table): ()
			if not props.Profiles or self.GlobalLoaded then
				return;
			end;
			self.GlobalLoaded = true;
			local data: any = isfile(globalListPath) and loadJson(globalListPath) or nil;
			if data and type(data.List) == 'table' then
				for _: any, profile: any in data.List do
					if type(profile.Name) == 'string' and not self:GetValue(profile.Name, true) then
						self:CreateProfile(profile.Name, profile.Bind, true);
					end;
				end;
			end;
			self:ChangeValue(nil, true);
		end;
		
		component.Load = function(self: table, data: table): ()
			vape:LoadOptions(self, data.Options);
		
			if data.Enabled then
				self.Button:Toggle();
			end;
		
			if data.Expanded then
				self:Expand();
			end;
		
			if props.Profiles then
				self.Scope = data.Scope == 'Global' and 'Global' or 'Game';
				for _: any, profile: any in data.List do
					if not profile.Global and not self:GetValue(profile.Name, false) then
						self:CreateProfile(profile.Name, profile.Bind);
					end;
				end;
				self:LoadGlobal();
		
				self:ChangeValue(nil, true);
			else
				if data.List and (#self.List > 0 or #data.List > 0) then
					self.List = data.List or {};
					self.ListEnabled = data.ListEnabled or {};
					self:ChangeValue(nil, true);
				end;
			end;
		
			if data.Position then
				window.Position = UDim2.fromOffset(data.Position.X, data.Position.Y);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Enabled"] = self.Button.Enabled,
				["Expanded"] = self.Expanded,
				["List"] = self.List,
				["ListEnabled"] = self.ListEnabled,
				["Options"] = vape:SaveOptions(self),
				["Position"] = {
					["X"] = window.Position.X.Offset,
					["Y"] = window.Position.Y.Offset
				}
			};
		
			if props.Profiles then
				local newList: table, globalList: table = {}, {};
		
				for _: any, profile: any in self.List do
					local entry: table = {
						["Name"] = profile.Name
					};
		
					profile.Bind:Save(entry);
					table.insert(profile.Global and globalList or newList, entry);
				end;
		
				data[props.Name].List = newList;
				data[props.Name].Scope = self.Scope;

				if self.GlobalLoaded then
					ensureGlobalFolder();
					writefile(globalListPath, httpService:JSONEncode({["List"] = globalList}));
				end;
			end;
		end;
		
		for index: any, comp: any in components do
			component['Create'..index] = function(_: any, props: table): ...any
				return comp(props, childrentwo, component);
			end;
		end;
		
		addbutton.MouseEnter:Connect(function(): ()
			addbutton.ImageTransparency = 0;
		end);
		
		addbutton.MouseLeave:Connect(function(): ()
			addbutton.ImageTransparency = 0.3;
		end);
		
		addbutton.MouseButton1Click:Connect(function(): ()
			if not table.find(component.List, addvalue.Text) then
				component:ChangeValue(addvalue.Text);
				addvalue.Text = '';
			end;
		end);
		
		arrowbutton.MouseEnter:Connect(function(): ()
			arrow.ImageColor3 = Color3.fromRGB(220, 220, 220);
		end);
		
		arrowbutton.MouseLeave:Connect(function(): ()
			arrow.ImageColor3 = Color3.fromRGB(140, 140, 140);
		end);
		
		arrowbutton.MouseButton1Click:Connect(function(): ()
			component:Expand();
		end);
		
		arrowbutton.MouseButton2Click:Connect(function(): ()
			component:Expand();
		end);
		
		if autocomplete then
			addvalue:GetPropertyChangedSignal('Text'):Connect(function(): ()
				local plr: any = getPlayerFromText(addvalue.Text);
				autocomplete.Text = plr and addvalue.Text..(plr:sub(#addvalue.Text + 1, #plr)) or '';
			end);
		
			addvalue.Focused:Connect(function(): ()
				vape.Autocomplete = function(): ()
					local newText: any = getPlayerFromText(addvalue.Text) or addvalue.Text;
					task.spawn(function(): ()
						addvalue:GetPropertyChangedSignal('Text'):Wait();
						addvalue.Text = newText;
						addvalue.CursorPosition = #newText + 1;
					end);
				end;
			end);
		end;
		
		addvalue.FocusLost:Connect(function(enter: boolean): ()
			if enter and not table.find(component.List, addvalue.Text) then
				component:ChangeValue(addvalue.Text);
				addvalue.Text = '';
			end;
		
			vape.Autocomplete = nil;
		end);
		
		addvalue.MouseEnter:Connect(function(): ()
			tween:Tween(addbkg, uipallet.Tween, {
				["BackgroundColor3"] = color.Light(uipallet.Main, 0.14)
			});
		end);
		
		addvalue.MouseLeave:Connect(function(): ()
			tween:Tween(addbkg, uipallet.Tween, {
				["BackgroundColor3"] = color.Light(uipallet.Main, 0.02)
			});
		end);
		
		children:GetPropertyChangedSignal('CanvasPosition'):Connect(function(): ()
			divider.Visible = children.CanvasPosition.Y > 10 and children.Visible;
		end);
		
		settings.MouseEnter:Connect(function(): ()
			settings.ImageColor3 = uipallet.Text;
		end);
		
		settings.MouseLeave:Connect(function(): ()
			settings.ImageColor3 = color.Light(uipallet.Main, 0.37);
		end);
		
		settings.MouseButton1Click:Connect(function(): ()
			childrentwo.Visible = not childrentwo.Visible;
		end);
		
		window.InputBegan:Connect(function(input: InputObject): ()
			if input.Position.Y < window.AbsolutePosition.Y + 41 and input.UserInputType == Enum.UserInputType.MouseButton2 then
				component:Expand();
			end;
		end);
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale);
			if component.Expanded then
				window.Size = UDim2.fromOffset(220, math.min(51 + windowlist.AbsoluteContentSize.Y / scale.Scale, 611));
			end;
		end);
		
		windowlisttwo:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			childrentwo.Size = UDim2.fromOffset(220, windowlisttwo.AbsoluteContentSize.Y / scale.Scale);
		end);
		
		component.Button = vape.Categories.Main:CreateGUIButton({
			["Name"] = props.Name,
			["Icon"] = props.CategoryIcon,
			["Size"] = props.CategorySize,
			["Window"] = window
		});
		
		component.Object = window;
		vape.Categories[props.Name] = component;
		
		return component;
	end,
	["ColorSlider"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Type"] = 'ColorSlider',
			["Hue"] = props.DefaultHue or 0.44,
			["Sat"] = props.DefaultSat or 1,
			["Value"] = props.DefaultValue or 1,
			["Opacity"] = props.DefaultOpacity or 1,
			["Rainbow"] = false,
			["Index"] = 0
		};
		
		local createExtraSlider: (name: string, gradientColor: ColorSequence) -> TextButton = function(name: string, gradientColor: ColorSequence): TextButton
			local colorslidercustom: TextButton = Instance.new('TextButton');
			colorslidercustom.AutoButtonColor = false;
			colorslidercustom.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
			colorslidercustom.BorderSizePixel = 0;
			colorslidercustom.Size = UDim2.new(1, 0, 0, 50);
			colorslidercustom.Text = '';
			colorslidercustom.Visible = false;
			colorslidercustom.Parent = children;
			local title: TextLabel = Instance.new('TextLabel');
			title.BackgroundTransparency = 1;
			title.FontFace = uipallet.Font;
			title.Position = UDim2.fromOffset(10, 2);
			title.Size = UDim2.fromOffset(60, 30);
			title.Text = name;
			title.TextColor3 = color.Dark(uipallet.Text, 0.16);
			title.TextSize = 11;
			title.TextXAlignment = Enum.TextXAlignment.Left;
			title.Parent = colorslidercustom;
			local holder: Frame = Instance.new('Frame');
			holder.BackgroundColor3 = Color3.new(1, 1, 1);
			holder.BorderSizePixel = 0;
			holder.Name = 'Holder';
			holder.Position = UDim2.fromOffset(10, 37);
			holder.Size = UDim2.new(1, -20, 0, 2);
			holder.Parent = colorslidercustom;
			local uigradient: UIGradient = Instance.new('UIGradient');
			uigradient.Color = gradientColor;
			uigradient.Parent = holder;
			local fill: Frame = Instance.new('Frame');
			fill.BackgroundTransparency = 1;
			fill.Name = 'Fill';
			fill.Size = UDim2.fromScale(math.clamp(name == 'Saturation' and component.Sat or name == 'Vibrance' and component.Value or component.Opacity, 0.04, 0.96), 1);
			fill.Parent = holder;
			local knobholder: Frame = Instance.new('Frame');
			knobholder.AnchorPoint = Vector2.new(0.5, 0.5);
			knobholder.BackgroundColor3 = colorslidercustom.BackgroundColor3;
			knobholder.BorderSizePixel = 0;
			knobholder.Position = UDim2.fromScale(1, 0.5);
			knobholder.Size = UDim2.fromOffset(24, 4);
			knobholder.Parent = fill;
			local knob: Frame = Instance.new('Frame');
			knob.AnchorPoint = Vector2.new(0.5, 0.5);
			knob.BackgroundColor3 = uipallet.Text;
			knob.Position = UDim2.fromScale(0.5, 0.5);
			knob.Size = UDim2.fromOffset(14, 14);
			knob.Parent = knobholder;
			addCorner(knob, UDim.new(1, 0));
		
			colorslidercustom.InputBegan:Connect(function(input: InputObject): ()
				if
					(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
					and (input.Position.Y - colorslidercustom.AbsolutePosition.Y) > (20 * scale.Scale)
				then
					local releaseConnection: RBXScriptConnection;
					local moveConnection: RBXScriptConnection = inputService.InputChanged:Connect(function(newInput: InputObject): ()
						if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
							local newValue: number = math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1);
							component:SetValue(nil, name == 'Saturation' and newValue or nil, name == 'Vibrance' and newValue or nil, name == 'Opacity' and newValue or nil);
						end;
					end);
		
					releaseConnection = input.Changed:Connect(function(): ()
						if input.UserInputState == Enum.UserInputState.End then
							moveConnection:Disconnect();
							releaseConnection:Disconnect();
						end;
					end);
				end;
			end);
		
			colorslidercustom.MouseEnter:Connect(function(): ()
				tween:Tween(knob, uipallet.Tween, {
					["Size"] = UDim2.fromOffset(16, 16)
				});
			end);
		
			colorslidercustom.MouseLeave:Connect(function(): ()
				tween:Tween(knob, uipallet.Tween, {
					["Size"] = UDim2.fromOffset(14, 14)
				});
			end);
		
			return colorslidercustom;
		end;
		
		local colorslider: TextButton = Instance.new('TextButton');
		colorslider.AutoButtonColor = false;
		colorslider.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		colorslider.BorderSizePixel = 0;
		colorslider.Size = UDim2.new(1, 0, 0, 50);
		colorslider.Text = '';
		colorslider.Visible = props.Visible == nil or props.Visible;
		colorslider.Parent = children;
		component.Object = colorslider;
		addTooltip(colorslider, props.Tooltip);
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(10, 2);
		title.Size = UDim2.fromOffset(60, 30);
		title.Text = props.Name;
		title.TextColor3 = color.Dark(uipallet.Text, 0.16);
		title.TextSize = 11;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = colorslider;
		local custombox: TextBox = Instance.new('TextBox');
		custombox.BackgroundTransparency = 1;
		custombox.FontFace = uipallet.Font;
		custombox.Position = UDim2.new(1, -69, 0, 9);
		custombox.Size = UDim2.fromOffset(60, 15);
		custombox.Text = '';
		custombox.TextColor3 = color.Dark(uipallet.Text, 0.16);
		custombox.TextSize = 11;
		custombox.TextXAlignment = Enum.TextXAlignment.Right;
		custombox.Visible = false;
		custombox.Parent = colorslider;
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = Color3.new(1, 1, 1);
		holder.BorderSizePixel = 0;
		holder.Position = UDim2.fromOffset(10, 39);
		holder.Size = UDim2.new(1, -20, 0, 2);
		holder.Parent = colorslider;
		local rainbowTable: table = {};
		for i: number = 0, 1, 0.1 do
			table.insert(rainbowTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)));
		end;
		local uigradient: UIGradient = Instance.new('UIGradient');
		uigradient.Color = ColorSequence.new(rainbowTable);
		uigradient.Parent = holder;
		local fill: Frame = Instance.new('Frame');
		fill.BackgroundTransparency = 1;
		fill.Size = UDim2.fromScale(math.clamp(component.Hue, 0.04, 0.96), 1);
		fill.Parent = holder;
		local knobholder: Frame = Instance.new('Frame');
		knobholder.AnchorPoint = Vector2.new(0.5, 0.5);
		knobholder.BackgroundColor3 = colorslider.BackgroundColor3;
		knobholder.BorderSizePixel = 0;
		knobholder.Position = UDim2.fromScale(1, 0.5);
		knobholder.Size = UDim2.fromOffset(24, 4);
		knobholder.Parent = fill;
		local knob: Frame = Instance.new('Frame');
		knob.AnchorPoint = Vector2.new(0.5, 0.5);
		knob.BackgroundColor3 = uipallet.Text;
		knob.Position = UDim2.fromScale(0.5, 0.5);
		knob.Size = UDim2.fromOffset(14, 14);
		knob.Parent = knobholder;
		addCorner(knob, UDim.new(1, 0));
		local preview: ImageButton = Instance.new('ImageButton');
		preview.BackgroundTransparency = 1;
		preview.Image = getvapeasset('velo/assets/new/colorpreview.png');
		preview.ImageColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value);
		preview.ImageTransparency = 1 - component.Opacity;
		preview.Position = UDim2.new(1, -22, 0, 10);
		preview.Size = UDim2.fromOffset(12, 12);
		preview.Parent = colorslider;
		local expand: TextButton = Instance.new('TextButton');
		expand.BackgroundTransparency = 1;
		expand.Position = UDim2.fromOffset(getfontbounds(title.Text, title.TextSize, title.FontFace).X + 11, 7);
		expand.Size = UDim2.fromOffset(17, 13);
		expand.Text = '';
		expand.Parent = colorslider;
		title:GetPropertyChangedSignal('FontFace'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			expand.Position = UDim2.fromOffset(getfontbounds(title.Text, title.TextSize, title.FontFace).X + 11, 7);
		end);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = getvapeasset('velo/assets/new/downexpandslider.png');
		icon.ImageColor3 = color.Dark(uipallet.Text, 0.43);
		icon.Position = UDim2.fromOffset(4, 4);
		icon.Size = UDim2.fromOffset(10, 5);
		icon.Parent = expand;
		local rainbow: TextButton = Instance.new('TextButton');
		rainbow.BackgroundTransparency = 1;
		rainbow.Position = UDim2.new(1, -42, 0, 10);
		rainbow.Size = UDim2.fromOffset(12, 12);
		rainbow.Text = '';
		rainbow.Parent = colorslider;
		local ring1: ImageLabel = Instance.new('ImageLabel');
		ring1.BackgroundTransparency = 1;
		ring1.Image = getvapeasset('velo/assets/new/rainbow_1.png');
		ring1.ImageColor3 = color.Light(uipallet.Main, 0.37);
		ring1.Size = UDim2.fromOffset(12, 12);
		ring1.Parent = rainbow;
		local ring2: any = Instance.fromExisting(ring1);
		ring2.Image = getvapeasset('velo/assets/new/rainbow_2.png');
		ring2.Parent = rainbow;
		local ring3: any = Instance.fromExisting(ring1);
		ring3.Image = getvapeasset('velo/assets/new/rainbow_3.png');
		ring3.Parent = rainbow;
		local ring4: any = Instance.fromExisting(ring1);
		ring4.Image = getvapeasset('velo/assets/new/rainbow_4.png');
		ring4.Parent = rainbow;
		props.Function = props.Function or function(): () end;
		
		local satSlider: TextButton = createExtraSlider('Saturation', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, component.Value)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, 1, component.Value))
		}));
		
		local vibSlider: TextButton = createExtraSlider('Vibrance', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, component.Sat, 1))
		}));
		
		local opSlider: TextButton = createExtraSlider('Opacity', ColorSequence.new({
			ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, component.Sat, component.Value))
		}));
		
		component.Load = function(self: table, data: table): ()
			if data.Rainbow ~= self.Rainbow then
				self:Toggle();
			end;
		
			if self.Hue ~= data.Hue or self.Sat ~= data.Sat or self.Value ~= data.Value or self.Opacity ~= data.Opacity then
				self:SetValue(data.Hue, data.Sat, data.Value, data.Opacity);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Hue"] = self.Hue,
				["Sat"] = self.Sat,
				["Value"] = self.Value,
				["Opacity"] = self.Opacity,
				["Rainbow"] = self.Rainbow
			};
		end;
		
		component.SetValue = function(self: table, h: number, s: number, v: number, o: number): ()
			self.Hue = h or self.Hue;
			self.Sat = s or self.Sat;
			self.Value = v or self.Value;
			self.Opacity = o or self.Opacity;
			preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value);
			preview.ImageTransparency = 1 - self.Opacity;
		
			satSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, self.Value)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, self.Value))
			});
		
			vibSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, 1))
			});
		
			opSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, self.Value))
			});
		
			if self.Rainbow then
				fill.Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1);
			else
				tween:Tween(fill, uipallet.Tween, {
					["Size"] = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
				});
			end;
		
			if s then
				tween:Tween(satSlider.Holder.Fill, uipallet.Tween, {
					["Size"] = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)
				});
			end;
		
			if v then
				tween:Tween(vibSlider.Holder.Fill, uipallet.Tween, {
					["Size"] = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)
				});
			end;
		
			if o then
				tween:Tween(opSlider.Holder.Fill, uipallet.Tween, {
					["Size"] = UDim2.fromScale(math.clamp(self.Opacity, 0.04, 0.96), 1)
				});
			end;
		
			props.Function(self.Hue, self.Sat, self.Value, self.Opacity);
		end;
		
		component.Toggle = function(self: table): ()
			self.Rainbow = not self.Rainbow;
		
			if self.Rainbow then
				table.insert(vape.RainbowSliders, self);
		
				ring1.ImageColor3 = Color3.fromRGB(5, 127, 100);
				task.delay(0.1, function(): ()
					if not self.Rainbow then return; end;
					ring2.ImageColor3 = Color3.fromRGB(228, 125, 43);
					task.delay(0.1, function(): ()
						if not self.Rainbow then return; end;
						ring3.ImageColor3 = Color3.fromRGB(225, 46, 52);
					end);
				end);
			else
				local index: number? = table.find(vape.RainbowSliders, self);
				if index then
					table.remove(vape.RainbowSliders, index);
				end;
		
				ring3.ImageColor3 = color.Light(uipallet.Main, 0.37);
				task.delay(0.1, function(): ()
					if self.Rainbow then return; end;
					ring2.ImageColor3 = color.Light(uipallet.Main, 0.37);
					task.delay(0.1, function(): ()
						if self.Rainbow then return; end;
						ring1.ImageColor3 = color.Light(uipallet.Main, 0.37);
					end);
				end);
			end;
		end;
		
		preview.MouseButton1Click:Connect(function(): ()
			preview.Visible = false;
			custombox.Visible = true;
			custombox:CaptureFocus();
		
			local text: Color3 = Color3.fromHSV(component.Hue, component.Sat, component.Value);
			custombox.Text = math.round(text.R * 255)..', '..math.round(text.G * 255)..', '..math.round(text.B * 255);
		end);
		
		local doubleClick: number = os.clock();
		colorslider.InputBegan:Connect(function(input: InputObject): ()
			if
				(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (input.Position.Y - colorslider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				local releaseConnection: RBXScriptConnection;
				local moveConnection: RBXScriptConnection = inputService.InputChanged:Connect(function(newInput: InputObject): ()
					if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						component:SetValue(math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1));
					end;
				end);
		
				releaseConnection = input.Changed:Connect(function(): ()
					if input.UserInputState == Enum.UserInputState.End then
						moveConnection:Disconnect();
						releaseConnection:Disconnect();
					end;
				end);
		
				if doubleClick > os.clock() then
					component:Toggle();
				else
					component:SetValue(math.clamp((input.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1));
				end;
		
				doubleClick = os.clock() + 0.3;
			end;
		end);
		
		colorslider.MouseEnter:Connect(function(): ()
			tween:Tween(knob, uipallet.Tween, {
				["Size"] = UDim2.fromOffset(16, 16)
			});
		end);
		
		colorslider.MouseLeave:Connect(function(): ()
			tween:Tween(knob, uipallet.Tween, {
				["Size"] = UDim2.fromOffset(14, 14)
			});
		end);
		
		colorslider:GetPropertyChangedSignal('Visible'):Connect(function(): ()
			satSlider.Visible = icon.Rotation == 180 and colorslider.Visible;
			vibSlider.Visible = satSlider.Visible;
			opSlider.Visible = satSlider.Visible;
		end);
		
		expand.MouseEnter:Connect(function(): ()
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.16);
		end);
		
		expand.MouseLeave:Connect(function(): ()
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.43);
		end);
		
		expand.MouseButton1Click:Connect(function(): ()
			satSlider.Visible = not satSlider.Visible;
			vibSlider.Visible = satSlider.Visible;
			opSlider.Visible = satSlider.Visible;
			icon.Rotation = satSlider.Visible and 180 or 0;
		end);
		
		rainbow.MouseButton1Click:Connect(function(): ()
			component:Toggle();
		end);
		
		custombox.FocusLost:Connect(function(enter: boolean): ()
			preview.Visible = true;
			custombox.Visible = false;
		
			if enter then
				local success: boolean, parsed: any = pcall(function(): Color3
					local commas: any = custombox.Text:split(',');
					return tonumber(commas[1]) and Color3.fromRGB(tonumber(commas[1]), tonumber(commas[2]), tonumber(commas[3])) or Color3.fromHex(valuebox.Text);
				end);
		
				if success then
					if component.Rainbow then
						component:Toggle();
					end;
		
					component:SetValue(parsed:ToHSV());
				end;
			end;
		end);
		
		api.Options[props.Name] = component;
		
		return component;
	end,
	["Divider"] = function(props: table, children: GuiObject, api: table): ()
		local divider: Frame = Instance.new('Frame');
		divider.Size = UDim2.new(1, 0, 0, 1);
		divider.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
		divider.BorderSizePixel = 0;
		divider.Parent = children;
		
		if props and props.Text then
			local label: TextLabel = Instance.new('TextLabel');
			label.Size = UDim2.fromOffset(218, 27);
			label.BackgroundTransparency = 1;
			label.RichText = true;
			label.Text = indent(10)..richEscape(props.Text:upper());
			label.TextXAlignment = Enum.TextXAlignment.Left;
			label.TextColor3 = color.Dark(uipallet.Text, 0.43);
			label.TextSize = 9;
			label.FontFace = uipallet.Font;
			label.Parent = children;
			divider.BackgroundTransparency = 1;
			--divider.Position = UDim2.fromOffset(0, 26)
			divider.Parent = label;
		end;
	end,
	["Dropdown"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Index"] = 0,
			["Type"] = 'Dropdown',
			["Value"] = props.List[1] or 'None'
		};
		
		local dropdown: TextButton = Instance.new('TextButton');
		dropdown.AutoButtonColor = false;
		dropdown.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		dropdown.BorderSizePixel = 0;
		dropdown.Size = UDim2.new(1, 0, 0, 40);
		dropdown.Text = '';
		dropdown.Visible = props.Visible == nil or props.Visible;
		dropdown.Parent = children;
		component.Object = dropdown;
		addTooltip(dropdown, props.Tooltip or props.Name);
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034);
		holder.Position = UDim2.fromOffset(10, 4);
		holder.Size = UDim2.new(1, -20, 1, -11);
		holder.Parent = dropdown;
		addCorner(holder, UDim.new(0, 6));
		local button: TextButton = Instance.new('TextButton');
		button.AutoButtonColor = false;
		button.BackgroundColor3 = uipallet.Main;
		button.Position = UDim2.fromOffset(1, 1);
		button.Size = UDim2.new(1, -2, 1, -2);
		button.Text = '';
		button.Parent = holder;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Size = UDim2.new(1, 0, 0, 29);
		title.RichText = true;
		title.Text = indent(9)..richEscape(props.Name..' - '..component.Value);
		title.TextColor3 = color.Dark(uipallet.Text, 0.16);
		title.TextSize = 13;
		title.TextTruncate = Enum.TextTruncate.AtEnd;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = button;
		addCorner(button, UDim.new(0, 6));
		local arrow: ImageLabel = Instance.new('ImageLabel');
		arrow.BackgroundTransparency = 1;
		arrow.Image = getvapeasset('velo/assets/new/expandarrow.png');
		arrow.ImageColor3 = Color3.fromRGB(140, 140, 140);
		arrow.Position = UDim2.new(1, -17, 0, 11);
		arrow.Rotation = 90;
		arrow.Size = UDim2.fromOffset(4, 8);
		arrow.Parent = button;
		props.Function = props.Function or function(): () end;
		local dropdownchildren: Instance?;
		
		component.Change = function(self: table, list: table): ()
			props.List = list or {};
			if not table.find(props.List, self.Value) then
				self:SetValue(self.Value);
			end;
		end;
		
		component.Load = function(self: table, data: table): ()
			if self.Value ~= data.Value then
				self:SetValue(data.Value);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Value"] = self.Value
			};
		end;
		
		component.SetValue = function(self: table, value: string, isClick: boolean?): ()
			self.Value = table.find(props.List, value) and value or props.List[1] or 'None';
			title.Text = indent(9)..richEscape(props.Name..' - '..self.Value);
		
			if dropdownchildren then
				arrow.Rotation = 90;
				dropdownchildren:Destroy();
				dropdownchildren = nil;
				dropdown.Size = UDim2.new(1, 0, 0, 40);
			end;
		
			props.Function(self.Value, isClick);
		end;
		
		button.MouseButton1Click:Connect(function(): ()
			if not dropdownchildren then
				arrow.Rotation = 270;
				local rows: number = #props.List - 1;
				local shown: number = props.MaxRows and math.min(rows, props.MaxRows) or rows;
				dropdown.Size = UDim2.new(1, 0, 0, 43 + shown * 26);
				if shown < rows then
					dropdownchildren = Instance.new('ScrollingFrame');
					dropdownchildren.BorderSizePixel = 0;
					dropdownchildren.CanvasSize = UDim2.fromOffset(0, rows * 26);
					dropdownchildren.ScrollBarImageTransparency = 0.75;
					dropdownchildren.ScrollBarThickness = 2;
					dropdownchildren.ScrollingDirection = Enum.ScrollingDirection.Y;
				else
					dropdownchildren = Instance.new('Frame');
				end;
				dropdownchildren.BackgroundTransparency = 1;
				dropdownchildren.Position = UDim2.fromOffset(0, 27);
				dropdownchildren.Size = UDim2.new(1, 0, 0, shown * 26);
				dropdownchildren.Parent = button;
		
				local index: number = 0;
				for _: any, v: any in props.List do
					if v == component.Value then continue; end;
					local entry: TextButton = Instance.new('TextButton');
					entry.AutoButtonColor = false;
					entry.BackgroundColor3 = uipallet.Main;
					entry.BorderSizePixel = 0;
					entry.FontFace = uipallet.Font;
					entry.Position = UDim2.fromOffset(0, index * 26);
					entry.Size = UDim2.new(1, 0, 0, 26);
					entry.RichText = true;
					entry.Text = indent(9)..richEscape(v);
					entry.TextColor3 = color.Dark(uipallet.Text, 0.16);
					entry.TextSize = 13;
					entry.TextTruncate = Enum.TextTruncate.AtEnd;
					entry.TextXAlignment = Enum.TextXAlignment.Left;
					entry.Parent = dropdownchildren;
		
					entry.MouseEnter:Connect(function(): ()
						entry.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
						entry.TextColor3 = uipallet.Text;
					end);
		
					entry.MouseLeave:Connect(function(): ()
						entry.BackgroundColor3 = uipallet.Main;
						entry.TextColor3 = color.Dark(uipallet.Text, 0.16);
					end);
		
					entry.MouseButton1Click:Connect(function(): ()
						component:SetValue(v, true);
					end);
		
					index += 1;
				end;
			else
				component:SetValue(component.Value, true);
			end;
		end);
		
		dropdown.MouseEnter:Connect(function(): ()
			tween:Tween(holder, uipallet.Tween, {
				["BackgroundColor3"] = color.Light(uipallet.Main, 0.0875)
			});
		end);
		
		dropdown.MouseLeave:Connect(function(): ()
			tween:Tween(holder, uipallet.Tween, {
				["BackgroundColor3"] = color.Light(uipallet.Main, 0.034)
			});
		end);
		
		api.Options[props.Name] = component;
		
		return component;
	end,
	["Font"] = function(props: table, children: GuiObject, api: table): table
		local fonts: table = {
			props.Default,
			'Custom'
		};
		
		for _: number, v: EnumItem in Enum.Font:GetEnumItems() do
			if not table.find(fonts, v.Name) then
				table.insert(fonts, v.Name);
			end;
		end;

		local fromName: (name: string) -> Font? = function(name: string): Font?
			local success: boolean, font: any = pcall(function(): Font
				return Font.fromEnum(Enum.Font[name]);
			end);
			return success and font or nil;
		end;

		local component: table = {
			["Value"] = fromName(fonts[1])
		};
		local fontdropdown: table;
		local fontbox: table;
		props.Function = props.Function or function(): () end;
		
		fontdropdown = components.Dropdown({
			["Name"] = props.Name,
			["List"] = fonts,
			["Function"] = function(val: string): ()
				fontbox.Object.Visible = val == 'Custom' and fontdropdown.Object.Visible;
				if val ~= 'Custom' then
					component.Value = fromName(val);
					props.Function(component.Value);
				else
					pcall(function(): ()
						component.Value = Font.fromId(tonumber(fontbox.Value));
					end);
		
					props.Function(component.Value);
				end;
			end,
			["Darker"] = props.Darker,
			["Visible"] = props.Visible,
			["MaxRows"] = 10
		}, children, api);
		component.Object = fontdropdown.Object;
		
		fontbox = components.TextBox({
			["Name"] = props.Name..' Asset',
			["Placeholder"] = 'font (rbxasset)',
			["Function"] = function(): ()
				if fontdropdown.Value == 'Custom' then
					pcall(function(): ()
						component.Value = Font.fromId(tonumber(fontbox.Value));
					end);
		
					props.Function(component.Value);
				end;
			end,
			["Visible"] = false,
			["Darker"] = true
		}, children, api);
		
		fontdropdown.Object:GetPropertyChangedSignal('Visible'):Connect(function(): ()
			fontbox.Object.Visible = fontdropdown.Object.Visible and fontdropdown.Value == 'Custom';
		end);
		
		return component;
	end,
	["GUI"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Buttons"] = {},
			["Type"] = 'MainWindow'
		};
		
		local window: TextButton = Instance.new('TextButton');
		window.AutoButtonColor = false;
		window.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
		window.Name = 'GUICategory';
		window.Position = UDim2.fromOffset(6, 60);
		window.Text = '';
		window.Parent = clickgui;
		component.Object = window;
		addBlur(window);
		addCorner(window);
		addDragHandler(window);
		local logo: ImageLabel = Instance.new('ImageLabel');
		logo.BackgroundTransparency = 1;
		logo.Image = getvapeasset('velo/assets/new/vapelogomini.png');
		logo.ImageColor3 = select(3, uipallet.Main:ToHSV()) > 0.5 and uipallet.Text or Color3.new(1, 1, 1);
		logo.Name = 'VapeLogo';
		logo.Position = UDim2.fromOffset(12, 11);
		logo.Size = UDim2.fromOffset(55, 16);
		logo.Parent = window;
		local v4logo: ImageLabel = Instance.new('ImageLabel');
		v4logo.BackgroundTransparency = 1;
		v4logo.Image = getvapeasset('velo/assets/new/v4mini.png');
		v4logo.Name = 'V4Logo';
		v4logo.Position = UDim2.new(1, -1, 0, 0);
		v4logo.Size = UDim2.fromOffset(23, 16);
		v4logo.Parent = logo;
		local children: Frame = Instance.new('Frame');
		children.BackgroundTransparency = 1;
		children.Position = UDim2.fromOffset(0, 37);
		children.Size = UDim2.new(1, 0, 1, -33);
		children.Parent = window;
		local windowlist: UIListLayout = Instance.new('UIListLayout');
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.Parent = children;
		local settingsbutton: TextButton = Instance.new('TextButton');
		settingsbutton.BackgroundTransparency = 1;
		settingsbutton.Position = UDim2.new(1, -40, 0, 0);
		settingsbutton.Size = UDim2.fromOffset(40, 40);
		settingsbutton.Text = '';
		settingsbutton.Parent = window;
		addTooltip(settingsbutton, 'Open settings');
		local settingsicon: ImageLabel = Instance.new('ImageLabel');
		settingsicon.BackgroundTransparency = 1;
		settingsicon.Image = getvapeasset('velo/assets/new/settings.png');
		settingsicon.ImageColor3 = color.Light(uipallet.Main, 0.37);
		settingsicon.Position = UDim2.fromOffset(15, 12);
		settingsicon.Size = UDim2.fromOffset(14, 14);
		settingsicon.Parent = settingsbutton;
		local discord: ImageButton = Instance.new('ImageButton');
		discord.BackgroundTransparency = 1;
		discord.Image = getvapeasset('velo/assets/new/discord.png');
		discord.Position = UDim2.new(1, -56, 0, 11);
		discord.Size = UDim2.fromOffset(16, 16);
		discord.Parent = window;
		addTooltip(discord, 'Join discord');
		local stroke: UIStroke = Instance.new('UIStroke');
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		stroke.Color = Color3.fromRGB(85, 85, 85);
		stroke.Transparency = 0.8;
		stroke.Parent = window;
		local settingspane: table = components.SettingsPane({
			["Name"] = 'Settings',
			["Main"] = true
		}, window, component);
		component.Settings = settingspane;
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			v4logo.ImageColor3 = Color3.fromHSV(hue, sat, val);
		
			for _: any, button: any in self.Buttons do
				if button.Enabled then
					button.Object.TextColor3 = isRainbow and vape:SampleColor(button.Index * 0.025) or Color3.fromHSV(hue, sat, val);
		
					if button.Icon then
						button.Icon.ImageColor3 = button.Object.TextColor3;
					end;
				end;
			end;
		end;
		
		component.Load = function(self: table, data: table): ()
			for name: any, paneData: any in data.Settings do
				local pane: any = vape.Settings[name];
				if pane then
					pane:Load(paneData);
				end;
			end;
		
			if data.Position then
				window.Position = UDim2.fromOffset(data.Position.X, data.Position.Y);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data.Main = {
				["Position"] = {
					["X"] = window.Position.X.Offset,
					["Y"] = window.Position.Y.Offset
				},
				["Settings"] = {}
			};
		
			for name: any, pane: any in vape.Settings do
				pane:Save(data.Main.Settings);
			end;
		end;
		
		for index: any, comp: any in components do
			component['Create'..index] = function(_: any, props: table): ...any
				return comp(props, children, component);
			end;
		end;
		
		discord.MouseButton1Click:Connect(function(): ()
			task.spawn(function(): ()
				local body: string = httpService:JSONEncode({
					["nonce"] = httpService:GenerateGUID(false),
					["args"] = {
						["invite"] = {["code"] = '2ShzQkrtbb'},
						["code"] = '2ShzQkrtbb'
					},
					["cmd"] = 'INVITE_BROWSER'
				});
		
				for i: number = 1, 14 do
					task.spawn(function(): ()
						pcall(function(): ()
							request({
								["Method"] = 'POST',
								["Url"] = 'http://127.0.0.1:64'..(53 + i)..'/rpc?v=1',
								["Headers"] = {
									['Content-Type'] = 'application/json',
									["Origin"] = 'https://discord.com'
								},
								["Body"] = body
							});
						end);
					end);
				end;
			end);
		
			task.spawn(function(): ()
				tooltip.Text = 'Copied!';
				setclipboard('https://discord.gg/2ShzQkrtbb');
			end);
		end);
		
		settingsbutton.MouseEnter:Connect(function(): ()
			settingsicon.ImageColor3 = uipallet.Text;
		end);
		
		settingsbutton.MouseLeave:Connect(function(): ()
			settingsicon.ImageColor3 = color.Light(uipallet.Main, 0.37);
		end);
		
		settingsbutton.MouseButton1Click:Connect(function(): ()
			settingspane.Object.Visible = true;
		end);
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			window.Size = UDim2.fromOffset(220, 42 + windowlist.AbsoluteContentSize.Y / scale.Scale);
			for _: any, button: any in component.Buttons do
				if button.Icon then
					button.Object.Text = indent(39 * scale.Scale)..richEscape(button.Name);
				end;
			end;
		end);
		
		vape.Categories.Main = component;
		
		return component;
	end,
	["GUIButton"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Enabled"] = false,
			["Index"] = getTableSize(api.Buttons),
			["Name"] = props.Name
		};
		
		local button: TextButton = Instance.new('TextButton');
		button.AutoButtonColor = false;
		button.BackgroundColor3 = uipallet.Main;
		button.BorderSizePixel = 0;
		button.FontFace = uipallet.Font;
		button.Name = props.Name;
		button.Size = UDim2.fromOffset(220, 40);
		button.RichText = true;
		button.Text = indent(props.Icon and 39 or props.Window and 17 or 10)..richEscape(props.Name);
		button.TextColor3 = color.Dark(uipallet.Text, 0.16);
		button.TextSize = 14;
		button.TextXAlignment = Enum.TextXAlignment.Left;
		button.Parent = children;
		component.Object = button;
		
		local icon: ImageLabel;
		if props.Icon then
			icon = Instance.new('ImageLabel');
			icon.BackgroundTransparency = 1;
			icon.Image = props.Icon;
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.16);
			icon.Position = UDim2.fromOffset(16, 13);
			icon.Size = props.Size;
			icon.Parent = button;
			component.Icon = icon;
		end;
		
		if props.Name == 'Profiles' then
			local label: TextLabel = Instance.new('TextLabel');
			label.AnchorPoint = Vector2.new(1, 0);
			label.BackgroundColor3 = color.Light(uipallet.Main, 0.04);
			label.FontFace = uipallet.Font;
			label.Position = UDim2.new(1, -36, 0, 8);
			label.Size = UDim2.fromOffset(53, 24);
			label.Text = 'default';
			label.TextColor3 = color.Dark(uipallet.Text, 0.29);
			label.TextSize = 12;
			label.Parent = button;
			addCorner(label);
			vape.ProfileLabel = label;
		end;
		
		local arrow: ImageLabel = Instance.new('ImageLabel');
		arrow.BackgroundTransparency = 1;
		arrow.Image = getvapeasset('velo/assets/new/expandarrow.png');
		arrow.ImageColor3 = color.Light(uipallet.Main, 0.37);
		arrow.Name = 'Arrow';
		arrow.Position = UDim2.new(1, -20, 0, 16);
		arrow.Size = UDim2.fromOffset(4, 8);
		arrow.Parent = button;
		
		component.Destroy = function(self: table): ()
			button:Destroy();
			button:ClearAllChildren();
		end;
		
		component.Toggle = function(self: table): ()
			if props.Window then
				self.Enabled = not self.Enabled;
				tween:Tween(arrow, uipallet.Tween, {
					["Position"] = UDim2.new(1, self.Enabled and -14 or -20, 0, 16)
				});
		
				button.TextColor3 = self.Enabled and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or uipallet.Text;
				if icon then
					icon.ImageColor3 = button.TextColor3;
				end;
		
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
				props.Window.Visible = self.Enabled;
			else
				props.Function();
			end;
		end;
		
		button.MouseEnter:Connect(function(): ()
			if not component.Enabled then
				button.TextColor3 = uipallet.Text;
				if buttonicon then
					buttonicon.ImageColor3 = uipallet.Text;
				end;
		
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
			end;
		end);
		
		button.MouseLeave:Connect(function(): ()
			if not component.Enabled then
				button.TextColor3 = color.Dark(uipallet.Text, 0.16);
				if buttonicon then
					buttonicon.ImageColor3 = color.Dark(uipallet.Text, 0.16);
				end;
		
				button.BackgroundColor3 = uipallet.Main;
			end;
		end);
		
		button.MouseButton1Click:Connect(function(): ()
			component:Toggle();
		end);
		
		api.Buttons[props.Name] = component;
		
		return component;
	end,
	["GUISlider"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["CustomColor"] = false,
			["Hue"] = 0.46,
			["Notch"] = 4,
			["Rainbow"] = false,
			["Sat"] = 0.96,
			["Type"] = 'GUISlider',
			["Value"] = 0.52
		};
		local colors: table = {
			Color3.fromRGB(250, 50, 56),
			Color3.fromRGB(242, 99, 33),
			Color3.fromRGB(252, 179, 22),
			Color3.fromRGB(5, 133, 104),
			Color3.fromRGB(47, 122, 229),
			Color3.fromRGB(126, 84, 217),
			Color3.fromRGB(232, 96, 152)
		};
		local colorPositions: table = {
			4,
			33,
			62,
			90,
			119,
			148,
			177
		};
		
		local createSlider: (name: string, gradientColor: ColorSequence) -> TextButton = function(name: string, gradientColor: ColorSequence): TextButton
			local slider: TextButton = Instance.new('TextButton');
			slider.Name = props.Name..'Slider'..name;
			slider.Size = UDim2.fromOffset(220, 50);
			slider.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
			slider.BorderSizePixel = 0;
			slider.AutoButtonColor = false;
			slider.Visible = false;
			slider.Text = '';
			slider.Parent = children;
			local title: TextLabel = Instance.new('TextLabel');
			title.BackgroundTransparency = 1;
			title.FontFace = uipallet.Font;
			title.Position = UDim2.fromOffset(10, 2);
			title.Size = UDim2.fromOffset(60, 30);
			title.Text = name;
			title.TextColor3 = color.Dark(uipallet.Text, 0.16);
			title.TextSize = 11;
			title.TextXAlignment = Enum.TextXAlignment.Left;
			title.Parent = slider;
			local holder: Frame = Instance.new('Frame');
			holder.BackgroundColor3 = Color3.new(1, 1, 1);
			holder.BorderSizePixel = 0;
			holder.Name = 'Holder';
			holder.Position = UDim2.fromOffset(10, 37);
			holder.Size = UDim2.new(1, -20, 0, 2);
			holder.Parent = slider;
			local uigradient: UIGradient = Instance.new('UIGradient');
			uigradient.Color = gradientColor;
			uigradient.Parent = holder;
			local fill: Frame = Instance.new('Frame');
			fill.BackgroundTransparency = 1;
			fill.Name = 'Fill';
			fill.Size = UDim2.fromScale(math.clamp(1, 0.04, 0.96), 1);
			fill.Parent = holder;
			local knobholder: Frame = Instance.new('Frame');
			knobholder.AnchorPoint = Vector2.new(0.5, 0.5);
			knobholder.BackgroundColor3 = slider.BackgroundColor3;
			knobholder.BorderSizePixel = 0;
			knobholder.Position = UDim2.fromScale(1, 0.5);
			knobholder.Size = UDim2.fromOffset(24, 4);
			knobholder.Parent = fill;
			local knob: Frame = Instance.new('Frame');
			knob.AnchorPoint = Vector2.new(0.5, 0.5);
			knob.BackgroundColor3 = uipallet.Text;
			knob.Position = UDim2.fromScale(0.5, 0.5);
			knob.Size = UDim2.fromOffset(14, 14);
			knob.Parent = knobholder;
			addCorner(knob, UDim.new(1, 0));
		
			if name == 'Custom color' then
				local reset: TextButton = Instance.new('TextButton');
				reset.BackgroundTransparency = 1;
				reset.FontFace = uipallet.Font;
				reset.Position = UDim2.new(1, -52, 0, 5);
				reset.Size = UDim2.fromOffset(45, 20);
				reset.Text = 'RESET';
				reset.TextColor3 = color.Dark(uipallet.Text, 0.16);
				reset.TextSize = 11;
				reset.Parent = slider;
		
				reset.MouseButton1Click:Connect(function(): ()
					component:SetValue(nil, nil, nil, 4);
				end);
			end;
		
			slider.InputBegan:Connect(function(input: InputObject): ()
				if
					(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
					and (input.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
				then
					local releaseConnection: RBXScriptConnection;
					local moveConnection: RBXScriptConnection = inputService.InputChanged:Connect(function(newInput: InputObject): ()
						if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
							local value: number = math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1);
							component:SetValue(
								name == 'Custom color' and value or nil,
								name == 'Saturation' and value or nil,
								name == 'Vibrance' and value or nil,
								name == 'Opacity' and value or nil
							);
						end;
					end);
		
					releaseConnection = input.Changed:Connect(function(): ()
						if input.UserInputState == Enum.UserInputState.End then
							moveConnection:Disconnect();
							releaseConnection:Disconnect();
						end;
					end);
				end;
			end);
		
			slider.MouseEnter:Connect(function(): ()
				tween:Tween(knob, uipallet.Tween, {
					["Size"] = UDim2.fromOffset(16, 16)
				});
			end);
		
			slider.MouseLeave:Connect(function(): ()
				tween:Tween(knob, uipallet.Tween, {
					["Size"] = UDim2.fromOffset(14, 14)
				});
			end);
		
			return slider;
		end;
		
		local slider: TextButton = Instance.new('TextButton');
		slider.AutoButtonColor = false;
		slider.BackgroundTransparency = 1;
		slider.Name = props.Name..'Slider';
		slider.Size = UDim2.fromOffset(220, 50);
		slider.Text = '';
		slider.Parent = children;
		component.Object = slider;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Name = 'Title';
		title.Position = UDim2.fromOffset(10, 2);
		title.Size = UDim2.fromOffset(60, 30);
		title.Text = props.Name;
		title.TextColor3 = color.Dark(uipallet.Text, 0.16);
		title.TextSize = 11;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = slider;
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundTransparency = 1;
		holder.BorderSizePixel = 0;
		holder.Name = 'Slider';
		holder.Position = UDim2.fromOffset(10, 37);
		holder.Size = UDim2.fromOffset(200, 2);
		holder.Parent = slider;
		local colorXPos: number = 0;
		for index: any, colorValue: any in colors do
			local colorframe: Frame = Instance.new('Frame');
			colorframe.BackgroundColor3 = colorValue;
			colorframe.BorderSizePixel = 0;
			colorframe.Position = UDim2.fromOffset(colorXPos, 0);
			colorframe.Size = UDim2.fromOffset(27 + (((index + 1) % 2) == 0 and 1 or 0), 2);
			colorframe.Parent = holder;
			colorXPos += (colorframe.Size.X.Offset + 1);
		end;
		local preview: ImageButton = Instance.new('ImageButton');
		preview.BackgroundTransparency = 1;
		preview.Image = getvapeasset('velo/assets/new/colorpreview.png');
		preview.ImageColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value);
		preview.Position = UDim2.new(1, -22, 0, 10);
		preview.Size = UDim2.fromOffset(12, 12);
		preview.Parent = slider;
		local custombox: TextBox = Instance.new('TextBox');
		custombox.BackgroundTransparency = 1;
		custombox.FontFace = uipallet.Font;
		custombox.Position = UDim2.new(1, -69, 0, 9);
		custombox.Size = UDim2.fromOffset(60, 15);
		custombox.Text = '';
		custombox.TextColor3 = color.Dark(uipallet.Text, 0.16);
		custombox.TextSize = 11;
		custombox.TextXAlignment = Enum.TextXAlignment.Right;
		custombox.Visible = false;
		custombox.Parent = slider;
		local expand: TextButton = Instance.new('TextButton');
		expand.BackgroundTransparency = 1;
		expand.Position = UDim2.new(0, getfontbounds(title.Text, title.TextSize, title.Font).X + 11, 0, 7);
		expand.Size = UDim2.fromOffset(17, 13);
		expand.Text = '';
		expand.Parent = slider;
		title:GetPropertyChangedSignal('FontFace'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
			expand.Position = UDim2.new(0, getfontbounds(title.Text, title.TextSize, title.FontFace).X + 11, 0, 7);
		end);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = getvapeasset('velo/assets/new/downexpandslider.png');
		icon.ImageColor3 = color.Dark(uipallet.Text, 0.43);
		icon.Position = UDim2.fromOffset(4, 4);
		icon.Size = UDim2.fromOffset(10, 5);
		icon.Parent = expand;
		local rainbow: TextButton = Instance.new('TextButton');
		rainbow.BackgroundTransparency = 1;
		rainbow.Position = UDim2.new(1, -42, 0, 10);
		rainbow.Size = UDim2.fromOffset(12, 12);
		rainbow.Text = '';
		rainbow.Parent = slider;
		local ring1: ImageLabel = Instance.new('ImageLabel');
		ring1.BackgroundTransparency = 1;
		ring1.Image = getvapeasset('velo/assets/new/rainbow_1.png');
		ring1.ImageColor3 = color.Light(uipallet.Main, 0.37);
		ring1.Size = UDim2.fromOffset(12, 12);
		ring1.Parent = rainbow;
		local ring2: any = Instance.fromExisting(ring1);
		ring2.Image = getvapeasset('velo/assets/new/rainbow_2.png');
		ring2.Parent = rainbow;
		local ring3: any = Instance.fromExisting(ring1);
		ring3.Image = getvapeasset('velo/assets/new/rainbow_3.png');
		ring3.Parent = rainbow;
		local ring4: any = Instance.fromExisting(ring1);
		ring4.Image = getvapeasset('velo/assets/new/rainbow_4.png');
		ring4.Parent = rainbow;
		local knob: ImageLabel = Instance.new('ImageLabel');
		knob.BackgroundTransparency = 1;
		knob.Image = getvapeasset('velo/assets/new/theme.png');
		knob.ImageColor3 = colors[4];
		knob.Name = 'Knob';
		knob.Position = UDim2.fromOffset(colorPositions[4] - 3, -5);
		knob.Size = UDim2.fromOffset(26, 12);
		knob.Parent = holder;
		props.Function = props.Function or function(): () end;
		local rainbowTable: table = {};
		for i: number = 0, 1, 0.1 do
			table.insert(rainbowTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)));
		end;
		
		local colorSlider: TextButton = createSlider('Custom color', ColorSequence.new(rainbowTable));
		local satSlider: TextButton = createSlider('Saturation', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, component.Value)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, 1, component.Value))
		}));
		
		local vibSlider: TextButton = createSlider('Vibrance', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, component.Sat, 1))
		}));
		
		local normalknob: any = getvapeasset('velo/assets/new/theme.png');
		local rainbowknob: any = getvapeasset('velo/assets/new/customtheme.png');
		local rainbowthread: thread?;
		local currentNotch: any;
		
		component.Load = function(self: table, data: table): ()
			if (data.Rainbow == true) ~= (self.Rainbow == true) then
				self:Toggle();
			end;
		
			if self.Rainbow or data.CustomColor then
				self:SetValue(data.Hue, data.Sat, data.Value);
			else
				self:SetValue(nil, nil, nil, data.Notch);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Hue"] = self.Hue,
				["Sat"] = self.Sat,
				["Value"] = self.Value,
				["Notch"] = self.Notch,
				["CustomColor"] = self.CustomColor,
				["Rainbow"] = self.Rainbow
			};
		end;
		
		component.SetValue = function(self: table, h: number, s: number, v: number, n: number): ()
			if n then
				if self.Rainbow then
					self:Toggle();
				end;
		
				self.CustomColor = false;
				h, s, v = colors[n]:ToHSV();
			else
				self.CustomColor = true;
			end;
		
			self.Hue = h or self.Hue;
			self.Sat = s or self.Sat;
			self.Value = v or self.Value;
			self.Notch = n;
			preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value);
		
			satSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, self.Value)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, self.Value))
			});
		
			vibSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, 1))
			});
		
			local newNotch: any = (self.Rainbow or self.CustomColor) and 4 or n or currentNotch;
			if self.Rainbow or self.CustomColor then
				knob.Image = rainbowknob;
				knob.ImageColor3 = Color3.new(1, 1, 1);
		
				if newNotch ~= currentNotch then
					tween:Tween(knob, uipallet.Tween, {
						["Position"] = UDim2.fromOffset(colorPositions[4] - 3, -5)
					});
				end;
			else
				knob.Image = normalknob;
				knob.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value);
		
				if newNotch ~= currentNotch then
					tween:Tween(knob, uipallet.Tween, {
						["Position"] = UDim2.fromOffset(colorPositions[n or 4] - 3, -5)
					});
				end;
			end;
		
			currentNotch = newNotch;
			if self.Rainbow then
				if h then
					colorSlider.Holder.Fill.Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1);
				end;
		
				if s then
					satSlider.Holder.Fill.Size = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1);
				end;
		
				if v then
					vibSlider.Holder.Fill.Size = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1);
				end;
			else
				if h then
					tween:Tween(colorSlider.Holder.Fill, uipallet.Tween, {
						["Size"] = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
					});
				end;
		
				if s then
					tween:Tween(satSlider.Holder.Fill, uipallet.Tween, {
						["Size"] = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)
					});
				end;
		
				if v then
					tween:Tween(vibSlider.Holder.Fill, uipallet.Tween, {
						["Size"] = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)
					});
				end;
			end;
		
			props.Function(self.Hue, self.Sat, self.Value);
		end;
		
		component.Toggle = function(self: table): ()
			self.Rainbow = not self.Rainbow;
			if rainbowthread then
				task.cancel(rainbowthread);
			end;
		
			if self.Rainbow then
				knob.Image = rainbowknob;
				table.insert(vape.RainbowSliders, self);
		
				ring1.ImageColor3 = Color3.fromRGB(5, 127, 100);
				rainbowthread = task.delay(0.1, function(): ()
					ring2.ImageColor3 = Color3.fromRGB(228, 125, 43);
					rainbowthread = task.delay(0.1, function(): ()
						ring3.ImageColor3 = Color3.fromRGB(225, 46, 52);
						rainbowthread = nil;
					end);
				end);
			else
				self:SetValue(nil, nil, nil, 4);
				knob.Image = normalknob;
				local index: number? = table.find(vape.RainbowSliders, self);
				if index then
					table.remove(vape.RainbowSliders, index);
				end;
		
				ring3.ImageColor3 = color.Light(uipallet.Main, 0.37);
				rainbowthread = task.delay(0.1, function(): ()
					ring2.ImageColor3 = color.Light(uipallet.Main, 0.37);
					rainbowthread = task.delay(0.1, function(): ()
						ring1.ImageColor3 = color.Light(uipallet.Main, 0.37);
						rainbowthread = nil;
					end);
				end);
			end;
		end;
		
		expand.MouseEnter:Connect(function(): ()
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.16);
		end);
		
		expand.MouseLeave:Connect(function(): ()
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.43);
		end);
		
		expand.MouseButton1Click:Connect(function(): ()
			colorSlider.Visible = not colorSlider.Visible;
			satSlider.Visible = colorSlider.Visible;
			vibSlider.Visible = satSlider.Visible;
			icon.Rotation = satSlider.Visible and 180 or 0;
		end);
		
		preview.MouseButton1Click:Connect(function(): ()
			preview.Visible = false;
			custombox.Visible = true;
			custombox:CaptureFocus();
			local text: Color3 = Color3.fromHSV(component.Hue, component.Sat, component.Value);
			custombox.Text = math.round(text.R * 255)..', '..math.round(text.G * 255)..', '..math.round(text.B * 255);
		end);
		
		slider.InputBegan:Connect(function(input: InputObject): ()
			if
				(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (input.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				local releaseConnection: RBXScriptConnection;
				local moveConnection: RBXScriptConnection = inputService.InputChanged:Connect(function(newInput: InputObject): ()
					if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						component:SetValue(nil, nil, nil, math.clamp(math.round((newInput.Position.X - holder.AbsolutePosition.X) / scale.Scale / 27), 1, 7));
					end;
				end);
		
				releaseConnection = input.Changed:Connect(function(): ()
					if input.UserInputState == Enum.UserInputState.End then
						moveConnection:Disconnect();
						releaseConnection:Disconnect();
					end;
				end);
		
				component:SetValue(nil, nil, nil, math.clamp(math.round((input.Position.X - holder.AbsolutePosition.X) / scale.Scale / 27), 1, 7));
			end;
		end);
		
		rainbow.MouseButton1Click:Connect(function(): ()
			component:Toggle();
		end);
		
		custombox.FocusLost:Connect(function(enter: boolean): ()
			preview.Visible = true;
			custombox.Visible = false;
		
			if enter then
				local success: boolean, parsed: any = pcall(function(): Color3
					local commas: any = custombox.Text:split(',');
					return tonumber(commas[1]) and Color3.fromRGB(tonumber(commas[1]), tonumber(commas[2]), tonumber(commas[3])) or Color3.fromHex(custombox.Text);
				end);
		
				if success then
					if component.Rainbow then
						component:Toggle();
					end;
		
					component:SetValue(parsed:ToHSV());
				end;
			end;
		end);
		
		api.Options[props.Name] = component;
		
		return component;
	end,
	["ImageToggle"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Enabled"] = false,
			["Index"] = getTableSize(api.Options),
			["Type"] = 'ImageToggle'
		};
		
		local isHover: boolean = false;
		local toggle: TextButton = Instance.new('TextButton');
		toggle.AutoButtonColor = false;
		toggle.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		toggle.BorderSizePixel = 0;
		toggle.FontFace = uipallet.Font;
		toggle.Size = UDim2.new(1, 0, 0, 40);
		toggle.RichText = true;
		toggle.Text = indent(33 * scale.Scale)..richEscape(props.Name);
		toggle.TextColor3 = color.Dark(uipallet.Text, 0.16);
		toggle.TextSize = 14;
		toggle.TextXAlignment = Enum.TextXAlignment.Left;
		toggle.Visible = props.Visible == nil or props.Visible;
		toggle.Parent = children;
		component.Object = toggle;
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = props.Icon;
		icon.ImageColor3 = uipallet.Text;
		icon.Name = 'Icon';
		icon.Position = props.Position;
		icon.Size = props.Size;
		icon.Parent = toggle;
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.14);
		holder.Name = 'Knob';
		holder.Position = UDim2.new(1, -30, 0, 14);
		holder.Size = UDim2.fromOffset(22, 12);
		holder.Parent = toggle;
		addCorner(holder, UDim.new(1, 0));
		local knob: Frame = Instance.new('Frame');
		knob.BackgroundColor3 = uipallet.Main;
		knob.Position = UDim2.fromOffset(2, 2);
		knob.Size = UDim2.fromOffset(8, 8);
		knob.Parent = holder;
		addCorner(knob, UDim.new(1, 0));
		props.Function = props.Function or function(): () end;
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			if self.Enabled then
				tween:Cancel(holder);
				holder.BackgroundColor3 = isRainbow and vape:SampleColor(self.Index * 0.075) or Color3.fromHSV(hue, sat, val);
			end;
		end;
		
		component.Toggle = function(self: table): ()
			local isRainbow: any = vape.GUIColor.Rainbow and vape.RainbowMode.Value ~= 'Retro';
			self.Enabled = not self.Enabled;
		
			tween:Tween(holder, uipallet.Tween, {
				["BackgroundColor3"] = self.Enabled and (isRainbow and vape:SampleColor(self.Index * 0.075) or Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)) or (isHover and color.Light(uipallet.Main, 0.37) or color.Light(uipallet.Main, 0.14))
			});
		
			tween:Tween(knob, uipallet.Tween, {
				["Position"] = UDim2.fromOffset(self.Enabled and 12 or 2, 2)
			});
		
			props.Function(self.Enabled);
		end;
		
		scale:GetPropertyChangedSignal('Scale'):Connect(function(): ()
			toggle.Text = indent(33 * scale.Scale)..richEscape(props.Name);
		end);
		
		toggle.MouseEnter:Connect(function(): ()
			isHover = true;
		
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = color.Light(uipallet.Main, 0.37)
				});
			end;
		end);
		
		toggle.MouseLeave:Connect(function(): ()
			isHover = false;
		
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = color.Light(uipallet.Main, 0.14)
				});
			end;
		end);
		
		toggle.MouseButton1Click:Connect(function(): ()
			component:Toggle();
		end);
		
		if props.Default then
			component:Toggle();
		end;
		
		api.Options[props.Name] = component;
		
		return component;
	end,
	["LegitModule"] = function(props: table, children: GuiObject, api: table): table
		vape:Remove(props.Name);
		local component: table = {
			["Enabled"] = false,
			["Legit"] = true,
			["Name"] = props.Name,
			["Options"] = {},
			["Type"] = 'LegitModule'
		};
		
		local button: TextButton = Instance.new('TextButton');
		button.AutoButtonColor = false;
		button.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
		button.Name = props.Name;
		button.Text = '';
		button.Parent = children;
		component.Object = button;
		addTooltip(button, props.Tooltip, nil, function(): any
			return vape.LegitVisible;
		end);
		addCorner(button);
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(16, 81);
		title.Size = UDim2.new(1, -16, 0, 20);
		title.Text = props.Name;
		title.TextColor3 = color.Dark(uipallet.Text, 0.31);
		title.TextSize = 13;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = button;
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.14);
		holder.Position = UDim2.new(1, -57, 0, 15);
		holder.Size = UDim2.fromOffset(22, 12);
		holder.Parent = button;
		addCorner(holder, UDim.new(1, 0));
		local knob: Frame = Instance.new('Frame');
		knob.BackgroundColor3 = uipallet.Main;
		knob.Position = UDim2.fromOffset(2, 2);
		knob.Size = UDim2.fromOffset(8, 8);
		knob.Parent = holder;
		addCorner(knob, UDim.new(1, 0));
		local dotsbutton: TextButton = Instance.new('TextButton');
		dotsbutton.BackgroundTransparency = 1;
		dotsbutton.Name = 'Dots';
		dotsbutton.Position = UDim2.new(1, -27, 0, 9);
		dotsbutton.Size = UDim2.fromOffset(14, 24);
		dotsbutton.Text = '';
		dotsbutton.Parent = button;
		local dots: ImageLabel = Instance.new('ImageLabel');
		dots.BackgroundTransparency = 1;
		dots.Image = getvapeasset('velo/assets/new/overlaydots.png');
		dots.ImageColor3 = color.Light(uipallet.Main, 0.37);
		dots.Name = 'Dots';
		dots.Position = UDim2.fromOffset(6, 6);
		dots.Size = UDim2.fromOffset(2, 12);
		dots.Parent = dotsbutton;
		local shadow: TextButton = Instance.new('TextButton');
		shadow.Name = 'Shadow';
		shadow.Size = UDim2.new(1, 0, 1, -5);
		shadow.BackgroundColor3 = Color3.new();
		shadow.BackgroundTransparency = 1;
		shadow.AutoButtonColor = false;
		shadow.ClipsDescendants = true;
		shadow.Visible = false;
		shadow.Text = '';
		shadow.Parent = api.Window;
		addCorner(shadow);
		local settingspane: TextButton = Instance.new('TextButton');
		settingspane.Size = UDim2.new(0, 220, 1, 0);
		settingspane.Position = UDim2.fromScale(1, 0);
		settingspane.BackgroundColor3 = uipallet.Main;
		settingspane.AutoButtonColor = false;
		settingspane.Text = '';
		settingspane.Parent = shadow;
		local settingstitle: TextLabel = Instance.new('TextLabel');
		settingstitle.Name = 'Title';
		settingstitle.Size = UDim2.new(1, -36, 0, 20);
		settingstitle.Position = UDim2.fromOffset(36, 12);
		settingstitle.BackgroundTransparency = 1;
		settingstitle.Text = props.Name;
		settingstitle.TextXAlignment = Enum.TextXAlignment.Left;
		settingstitle.TextColor3 = color.Dark(uipallet.Text, 0.16);
		settingstitle.TextSize = 13;
		settingstitle.FontFace = uipallet.Font;
		settingstitle.Parent = settingspane;
		local back: ImageButton = Instance.new('ImageButton');
		back.Name = 'Back';
		back.Size = UDim2.fromOffset(16, 16);
		back.Position = UDim2.fromOffset(11, 13);
		back.BackgroundTransparency = 1;
		back.Image = getvapeasset('velo/assets/new/back.png');
		back.ImageColor3 = color.Light(uipallet.Main, 0.37);
		back.Parent = settingspane;
		addCorner(settingspane);
		local settingschildren: ScrollingFrame = Instance.new('ScrollingFrame');
		settingschildren.BackgroundColor3 = uipallet.Main;
		settingschildren.BorderSizePixel = 0;
		settingschildren.CanvasSize = UDim2.new();
		settingschildren.Name = 'Children';
		settingschildren.Position = UDim2.fromOffset(0, 41);
		settingschildren.ScrollBarThickness = 2;
		settingschildren.ScrollBarImageTransparency = 0.75;
		settingschildren.Size = UDim2.new(1, 0, 1, -45);
		settingschildren.Parent = settingspane;
		local windowlist: UIListLayout = Instance.new('UIListLayout');
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlist.Parent = settingschildren;
		if props.Size then
			local modulechildren: Frame = Instance.new('Frame');
			modulechildren.Size = props.Size;
			modulechildren.BackgroundTransparency = 1;
			modulechildren.Visible = false;
			modulechildren.Parent = scaledgui;
			addDragHandler(modulechildren, api.Window);
			local objectstroke: UIStroke = Instance.new('UIStroke');
			objectstroke.Color = Color3.fromRGB(5, 134, 105);
			objectstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			objectstroke.Thickness = 0;
			objectstroke.Parent = modulechildren;
			component.Children = modulechildren;
		end;
		props.Function = props.Function or function(): () end;
		addMaid(component);
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			if self.Enabled then
				tween:Cancel(holder);
				holder.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			end;
		
			for _: any, component: any in self.Options do
				if component.Color then
					component:Color(hue, sat, val, isRainbow);
				end;
			end;
		end;
		
		component.Load = function(self: table, data: table): ()
			vape:LoadOptions(self, data.Options);
		
			if self.Enabled ~= data.Enabled then
				self:Toggle();
			end;
		
			if data.Position and self.Children then
				self.Children.Position = UDim2.fromOffset(data.Position.X, data.Position.Y);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Enabled"] = self.Enabled,
				["Options"] = vape:SaveOptions(self),
				["Position"] = self.Children and {
					["X"] = self.Children.Position.X.Offset,
					["Y"] = self.Children.Position.Y.Offset
				} or nil
			};
		end;
		
		component.Toggle = function(self: table): ()
			self.Enabled = not self.Enabled;
			if self.Children then
				self.Children.Visible = self.Enabled;
			end;
		
			title.TextColor3 = self.Enabled and color.Light(uipallet.Text, 0.2) or color.Dark(uipallet.Text, 0.31);
			button.BackgroundColor3 = self.Enabled and color.Light(uipallet.Main, 0.05) or button.BackgroundColor3;
		
			tween:Tween(holder, uipallet.Tween, {
				["BackgroundColor3"] = self.Enabled and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or color.Light(uipallet.Main, 0.14)
			});
		
			tween:Tween(knob, uipallet.Tween, {
				["Position"] = UDim2.fromOffset(self.Enabled and 12 or 2, 2)
			});
		
			if not self.Enabled then
				for _: any, v: any in self.Connections do
					pcall(function(): ()
						v:Disconnect();
					end);
				end;
				table.clear(self.Connections);
			end;
		
			task.spawn(props.Function, self.Enabled);
		end;
		
		for index: any, comp: any in components do
			component['Create'..index] = function(_: any, props: table): ...any
				return comp(props, settingschildren, component);
			end;
		end;
		
		back.MouseEnter:Connect(function(): ()
			back.ImageColor3 = uipallet.Text;
		end);
		
		back.MouseLeave:Connect(function(): ()
			back.ImageColor3 = color.Light(uipallet.Main, 0.37);
		end);
		
		back.MouseButton1Click:Connect(function(): ()
			tween:Tween(shadow, uipallet.Tween, {
				["BackgroundTransparency"] = 1
			});
		
			tween:Tween(settingspane, uipallet.Tween, {
				["Position"] = UDim2.fromScale(1, 0)
			});
		
			task.delay(0.2, function(): ()
				shadow.Visible = false;
			end);
		end);
		
		button.MouseEnter:Connect(function(): ()
			if not component.Enabled then
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.05);
			end;
		end);
		
		button.MouseLeave:Connect(function(): ()
			if not component.Enabled then
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
			end;
		end);
		
		button.MouseButton1Click:Connect(function(): ()
			component:Toggle();
		end);
		
		button.MouseButton2Click:Connect(function(): ()
			shadow.Visible = true;
		
			tween:Tween(shadow, uipallet.Tween, {
				["BackgroundTransparency"] = 0.5
			});
		
			tween:Tween(settingspane, uipallet.Tween, {
				["Position"] = UDim2.new(1, -220, 0, 0)
			});
		end);
		
		dotsbutton.MouseButton1Click:Connect(function(): ()
			shadow.Visible = true;
		
			tween:Tween(shadow, uipallet.Tween, {
				["BackgroundTransparency"] = 0.5
			});
		
			tween:Tween(settingspane, uipallet.Tween, {
				["Position"] = UDim2.new(1, -220, 0, 0)
			});
		end);
		
		dotsbutton.MouseEnter:Connect(function(): ()
			dots.ImageColor3 = uipallet.Text;
		end);
		
		dotsbutton.MouseLeave:Connect(function(): ()
			dots.ImageColor3 = color.Light(uipallet.Main, 0.37);
		end);
		
		shadow.MouseButton1Click:Connect(function(): ()
			tween:Tween(shadow, uipallet.Tween, {
				["BackgroundTransparency"] = 1
			});
		
			tween:Tween(settingspane, uipallet.Tween, {
				["Position"] = UDim2.fromScale(1, 0)
			});
		
			task.delay(0.2, function(): ()
				shadow.Visible = false;
			end);
		end);
		
		shadow:GetPropertyChangedSignal('Visible'):Connect(function(): ()
			tooltip.Visible = false;
			vape.LegitVisible = shadow.Visible;
		end);
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			settingschildren.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale);
		end);
		
		api.Modules[props.Name] = component;
		
		local sorting: table = {};
		for _: any, mod: any in api.Modules do
			table.insert(sorting, mod.Name);
		end;
		table.sort(sorting);
		
		for index: any, name: any in sorting do
			api.Modules[name].Object.LayoutOrder = index;
		end;
		
		return component;
	end,
	["LegitWindow"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Modules"] = {}
		};
		
		local window: Frame = Instance.new('Frame');
		window.BackgroundColor3 = uipallet.Main;
		window.Position = UDim2.new(0.5, -350, 0.5, -190);
		window.Size = UDim2.fromOffset(700, 380);
		window.Name = 'LegitGUI';
		window.Visible = false;
		window.Parent = scaledgui;
		table.insert(vape.Windows, window);
		component.Window = window;
		addBlur(window);
		addCorner(window);
		addDragHandler(window);
		local modal: TextButton = Instance.new('TextButton');
		modal.BackgroundTransparency = 1;
		modal.Modal = true;
		modal.Text = '';
		modal.Parent = window;
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = getvapeasset('velo/assets/new/legit_mode_icon.png');
		icon.ImageColor3 = uipallet.Text;
		icon.Position = UDim2.fromOffset(18, 11);
		icon.Size = UDim2.fromOffset(16, 16);
		icon.Parent = window;
		local close: ImageButton = Instance.new('ImageButton');
		close.BackgroundTransparency = 1;
		close.Image = getvapeasset('velo/assets/new/min.png');
		close.ImageColor3 = color.Light(uipallet.Main, 0.24);
		close.Position = UDim2.new(1, -31, 0, 11);
		close.Size = UDim2.fromOffset(16, 16);
		close.Parent = window;
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
		holder.Position = UDim2.new(1, -253, 0, 42);
		holder.Size = UDim2.fromOffset(242, 29);
		holder.Parent = window;
		addCorner(holder, UDim.new(0, 4));
		local stroke: UIStroke = Instance.new('UIStroke');
		stroke.Color = color.Light(uipallet.Main, 0.02);
		stroke.Parent = holder;
		local searchicon: ImageLabel = Instance.new('ImageLabel');
		searchicon.BackgroundTransparency = 1;
		searchicon.Image = getvapeasset('velo/assets/new/search.png');
		searchicon.ImageColor3 = color.Light(uipallet.Main, 0.42);
		searchicon.Position = UDim2.new(1, -25, 0, 9);
		searchicon.Size = UDim2.fromOffset(12, 12);
		searchicon.Parent = holder;
		local box: TextBox = Instance.new('TextBox');
		box.BackgroundTransparency = 1;
		box.ClearTextOnFocus = false;
		box.FontFace = uipallet.Font;
		box.PlaceholderColor3 = color.Dark(uipallet.Text, 0.16);
		box.PlaceholderText = 'Search mods';
		box.Position = UDim2.fromOffset(8, 0);
		box.Size = UDim2.new(1, -8, 1, 0);
		box.Text = '';
		box.TextColor3 = color.Dark(uipallet.Text, 0.16);
		box.TextSize = 14;
		box.TextXAlignment = Enum.TextXAlignment.Left;
		box.Parent = holder;
		local children: ScrollingFrame = Instance.new('ScrollingFrame');
		children.BackgroundTransparency = 1;
		children.BorderSizePixel = 0;
		children.CanvasSize = UDim2.new();
		children.Position = UDim2.fromOffset(14, 76);
		children.ScrollBarThickness = 2;
		children.ScrollBarImageTransparency = 0.75;
		children.Size = UDim2.fromOffset(684, 301);
		children.Parent = window;
		local windowlist: UIGridLayout = Instance.new('UIGridLayout');
		windowlist.CellSize = UDim2.fromOffset(163, 114);
		windowlist.CellPadding = UDim2.fromOffset(6, 6);
		windowlist.FillDirectionMaxCells = 4;
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.Parent = children;
		
		for index: any, comp: any in components do
			component['Create'..index] = function(_: any, props: table): ...any
				return comp(props, children, component);
			end;
		end;
		
		component.CreateModule = function(self: table, props: table): table
			return components.LegitModule(props, children, component);
		end;
		
		local visibleCheck: () -> () = function(): ()
			for _: any, module: any in component.Modules do
				if module.Children then
					local visible: any = clickgui.Visible;
					--[[for _, v2 in self.Windows do
						visible = visible or v2.Visible
					end]]
		
					module.Children.Visible = (not visible or window.Visible) and module.Enabled;
				end;
			end;
		end;
		
		box:GetPropertyChangedSignal('Text'):Connect(function(): ()
			for name: any, module: any in component.Modules do
				module.Object.Visible = (box.Text == '' or name:lower():find(box.Text:lower())) and true or false;
			end;
		end);
		
		close.MouseButton1Click:Connect(function(): ()
			window.Visible = false;
			clickgui.Visible = true;
		end);
		
		close.MouseEnter:Connect(function(): ()
			close.ImageColor3 = color.Light(uipallet.Main, 0.37);
		end);
		
		close.MouseLeave:Connect(function(): ()
			close.ImageColor3 = color.Light(uipallet.Main, 0.24);
		end);
		
		vape:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(visibleCheck));
		
		holder.MouseEnter:Connect(function(): ()
			tween:Tween(stroke, uipallet.Tween, {
				["Color"] = color.Light(uipallet.Main, 0.0875)
			});
		end);
		
		holder.MouseLeave:Connect(function(): ()
			tween:Tween(stroke, uipallet.Tween, {
				["Color"] = color.Light(uipallet.Main, 0.02)
			});
		end);
		
		window:GetPropertyChangedSignal('Visible'):Connect(function(): ()
			vape:UpdateGUI();
			visibleCheck();
		end);
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale);
		end);
		
		vape.Legit = component;
		
		return component;
	end,
	["Module"] = function(props: table, children: GuiObject, api: table): table
		vape:Remove(props.Name);
		local component: table = {
			["Category"] = api.Name,
			["Enabled"] = false,
			["ExtraText"] = props.ExtraText,
			["Index"] = getTableSize(vape.Modules),
			["Name"] = props.Name,
			["Options"] = {},
			["Visible"] = true
		};
		
		local isHover: boolean = false;
		local button: TextButton = Instance.new('TextButton');
		button.AutoButtonColor = false;
		button.BackgroundColor3 = uipallet.Main;
		button.BorderSizePixel = 0;
		button.FontFace = uipallet.Font;
		button.Name = props.Name;
		button.Size = UDim2.fromOffset(220, 40);
		button.RichText = true;
		button.Text = indent(12)..richEscape(props.Name);
		button.TextColor3 = color.Dark(uipallet.Text, 0.16);
		button.TextSize = 14;
		button.TextXAlignment = Enum.TextXAlignment.Left;
		button.Parent = children;
		component.Object = button;
		addTooltip(button, props.Tooltip);
		local gradient: UIGradient = Instance.new('UIGradient');
		gradient.Enabled = false;
		gradient.Rotation = 90;
		gradient.Parent = button;
		local modulechildren: Frame = Instance.new('Frame');
		modulechildren.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
		modulechildren.BorderSizePixel = 0;
		modulechildren.ClipsDescendants = true;
		modulechildren.Name = props.Name..'Children';
		modulechildren.Size = UDim2.new(1, 0, 0, 0);
		modulechildren.Visible = false;
		modulechildren.Parent = children;
		local windowlist: UIListLayout = Instance.new('UIListLayout');
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.Parent = modulechildren;
		local dotsbutton: TextButton = Instance.new('TextButton');
		dotsbutton.BackgroundTransparency = 1;
		dotsbutton.Name = 'Dots';
		dotsbutton.Position = UDim2.new(1, -25, 0, 0);
		dotsbutton.Size = UDim2.fromOffset(25, 40);
		dotsbutton.Text = '';
		dotsbutton.Parent = button;
		local dots: ImageLabel = Instance.new('ImageLabel');
		dots.BackgroundTransparency = 1;
		dots.Image = getvapeasset('velo/assets/new/settingdots.png');
		dots.ImageColor3 = color.Light(uipallet.Main, 0.37);
		dots.Name = 'Dots';
		dots.Position = UDim2.fromOffset(4, 12);
		dots.Size = UDim2.fromOffset(3, 16);
		dots.Parent = dotsbutton;
		local divider: Frame = Instance.new('Frame');
		divider.BackgroundColor3 = Color3.new(0.19, 0.19, 0.19);
		divider.BackgroundTransparency = 0.52;
		divider.BorderSizePixel = 0;
		divider.Name = 'Divider';
		divider.Position = UDim2.new(0, 0, 1, -1);
		divider.Size = UDim2.new(1, 0, 0, 1);
		divider.Visible = false;
		divider.Parent = button;
		local edit: TextButton = Instance.new('TextButton');
		edit.AutoButtonColor = false;
		edit.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
		edit.BorderSizePixel = 0;
		edit.Size = UDim2.fromOffset(40, 40);
		edit.Text = '';
		edit.Visible = false;
		edit.Parent = button;
		local editbox: Frame = Instance.new('Frame');
		editbox.BorderSizePixel = 0;
		editbox.Position = UDim2.fromOffset(16, 16);
		editbox.Size = UDim2.fromOffset(8, 8);
		editbox.Parent = edit;
		local editborder: UIStroke = Instance.new('UIStroke');
		editborder.BorderOffset = UDim.new(0, 1);
		editborder.LineJoinMode = Enum.LineJoinMode.Miter;
		editborder.Parent = editbox;
		props.Function = props.Function or function(): () end;
		component.Edit = edit;
		component.Children = modulechildren;
		addMaid(component);
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			if self.Enabled then
				button.BackgroundColor3 = isRainbow and vape:SampleColor(self.Index * 0.025) or Color3.fromHSV(hue, sat, val);
				button.TextColor3 = vape.GUIColor.Rainbow and vape:AnimatedTextColor(button.BackgroundColor3) or vape:TextColor(hue, sat, val);
				button.UIGradient.Enabled = isRainbow and vape.RainbowMode.Value == 'Gradient';
		
				if button.UIGradient.Enabled then
					button.BackgroundColor3 = Color3.new(1, 1, 1);
					button.UIGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, vape:SampleColor(self.Index * 0.025)),
						ColorSequenceKeypoint.new(1, vape:SampleColor((self.Index + 1) * 0.025))
					});
				end;
		
				self.Bind:SetColor(self.Object.TextColor3);
				dots.ImageColor3 = self.Object.TextColor3;
			end;
		
			if self.Visible then
				editbox.BackgroundColor3 = isRainbow and vape:SampleColor(self.Index * 0.025) or Color3.fromHSV(hue, sat, val);
				editborder.Color = editbox.BackgroundColor3;
			end;
		
			for _: any, component: any in self.Options do
				if component.Color then
					component:Color(hue, sat, val, isRainbow);
				end;
			end;
		end;
		
		component.Destroy = function(self: table): ()
			self.Bind:Destroy();
		
			for _: any, option: any in self.Options do
				if option.Type == 'Bind' then
					option:Destroy();
				end;
			end;
		end;
		
		component.Load = function(self: table, data: table): ()
			vape:LoadOptions(self, data.Options);
			self.Bind:Load(data.Bind);
		
			if self.Enabled ~= (data.Enabled and not self.Bind.Hold) then
				self:Toggle(true);
		
				if self.Bind.Mobile then
					self.Bind.Mobile.BackgroundColor3 = self.Enabled and Color3.new(0, 0.7, 0) or Color3.new();
				end;
			end;
		
			if self.Visible ~= data.Visible then
				self:SetVisible(data.Visible, true);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Enabled"] = self.Enabled,
				["Options"] = vape:SaveOptions(self),
				["Visible"] = self.Visible
			};
		
			self.Bind:Save(data[props.Name]);
		end;
		
		component.Share = function(self: table, name: string): ()
			local path: string = 'velo/profiles/'..name..'.share.json';
			local last: string? = isfile(path) and readfile(path) or nil;
			task.spawn(function(): ()
				repeat
					task.wait();
				until vape.Loaded or vape.Loaded == nil;
				if vape.Loaded and last then
					local decoded: boolean, result: any = pcall(httpService.JSONDecode, httpService, last);
					if decoded and type(result) == 'table' and type(result.Options) == 'table' then
						result.Visible = self.Visible;
						self:Load(result);
					end;
				end;
				while vape.Loaded ~= nil do
					if vape.Loaded then
						local saved: table = {};
						self:Save(saved);
						local data: table = saved[props.Name];
						data.Visible = nil;
						local encoded: string = httpService:JSONEncode(data);
						if encoded ~= last then
							last = encoded;
							writefile(path, encoded);
						end;
					end;
					task.wait(1);
				end;
			end);
		end;
		
		component.SetVisible = function(self: table, isVisible: boolean, isLoad: boolean?): ()
			self.Visible = isVisible;
			editbox.BackgroundTransparency = isVisible and 0 or 1;
			editborder.Color = isVisible and editbox.BackgroundColor3 or color.Light(uipallet.Main, 0.37);
		
			if isLoad and not vape.EditGUI then
				button.Visible = isVisible;
			end;
		end;
		
		component.Toggle = function(self: table, multiple: boolean?): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			self.Enabled = not self.Enabled;
			divider.Visible = self.Enabled;
			gradient.Enabled = self.Enabled;
			button.TextColor3 = (isHover or modulechildren.Visible) and uipallet.Text or color.Dark(uipallet.Text, 0.16);
			button.BackgroundColor3 = (isHover or modulechildren.Visible) and color.Light(uipallet.Main, 0.02) or uipallet.Main;
			dots.ImageColor3 = self.Enabled and Color3.fromRGB(50, 50, 50) or color.Light(uipallet.Main, 0.37);
			component.Bind:SetColor(color.Dark(uipallet.Text, 0.43));
		
			if not self.Enabled then
				for _: any, v: any in self.Connections do
					pcall(function(): ()
						v:Disconnect();
					end);
				end;
				table.clear(self.Connections);
			end;
		
			if multiple then
				if not vape.TextGUIThread then
					vape.TextGUIThread = task.defer(function(): ()
						if vape.Loaded ~= nil then
							vape:UpdateTextGUI();
						end;
		
						vape.TextGUIThread = nil;
					end);
				end;
			else
				vape:UpdateTextGUI();
			end;
		
			task.spawn(props.Function, self.Enabled);
		end;
		
		for index: any, comp: any in components do
			component['Create'..index] = function(_: any, props: table): ...any
				return comp(props, modulechildren, component);
			end;
		end;
		
		button.MouseEnter:Connect(function(): ()
			isHover = true;
			if not component.Enabled and not modulechildren.Visible then
				button.TextColor3 = uipallet.Text;
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
			end;
		
			component.Bind:SetVisible(isHover or modulechildren.Visible);
		end);
		
		button.MouseLeave:Connect(function(): ()
			isHover = false;
			if not component.Enabled and not modulechildren.Visible then
				button.TextColor3 = color.Dark(uipallet.Text, 0.16);
				button.BackgroundColor3 = uipallet.Main;
			end;
		
			component.Bind:SetVisible(isHover or modulechildren.Visible);
		end);
		
		button.MouseButton1Click:Connect(function(): ()
			if vape.EditGUI then
				return;
			end;
		
			component:Toggle();
		end);
	
		local settingsOpen: boolean = false;
		local settingsTween: Tween;
		local toggleSettings: () -> () = function(): ()
			settingsOpen = not settingsOpen;
			if settingsTween then
				settingsTween:Cancel();
			end;

			if settingsOpen and not modulechildren.Visible then
				modulechildren.Size = UDim2.new(1, 0, 0, 0);
				modulechildren.Visible = true;
			end;

			settingsTween = tweenService:Create(modulechildren, TweenInfo.new(settingsOpen and 0.5 or 0.4, Enum.EasingStyle.Exponential), {
				["Size"] = UDim2.new(1, 0, 0, settingsOpen and windowlist.AbsoluteContentSize.Y / scale.Scale or 0)
			});
			settingsTween.Completed:Once(function(state: Enum.PlaybackState): ()
				if state ~= Enum.PlaybackState.Completed then
					return;
				end;

				if vape.ThreadFix then
					setthreadidentity(8);
				end;

				if not settingsOpen then
					modulechildren.Visible = false;
				end;

				modulechildren.Size = UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y / scale.Scale);
			end);
			settingsTween:Play();
		end;

		button.MouseButton2Click:Connect(toggleSettings);
		
		dotsbutton.MouseButton1Click:Connect(toggleSettings);
		
		dotsbutton.MouseButton2Click:Connect(toggleSettings);
		
		dotsbutton.MouseEnter:Connect(function(): ()
			if not component.Enabled then
				dots.ImageColor3 = uipallet.Text;
			end;
		end);
		
		dotsbutton.MouseLeave:Connect(function(): ()
			if not component.Enabled then
				dots.ImageColor3 = color.Light(uipallet.Main, 0.37);
			end;
		end);
		
		edit.MouseButton1Click:Connect(function(): ()
			component:SetVisible(not component.Visible);
		end);
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			modulechildren.Size = UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y / scale.Scale);
		end);
		
		local bind: table = component:CreateBind({
			["Module"] = true,
			["Cover"] = true
		});
		
		bind.Triggered:Connect(function(isDown: boolean): ()
			if bind.Hold then
				if component.Enabled ~= isDown then
					if vape.ToggleNotifications.Enabled then
						vape:CreateNotification(props.Name, (not component.Enabled and "<font color='#00AA00'>Enabled</font>" or "<font color='#FF5A5A'>Disabled</font>"), 1.5);
					end;
		
					component:Toggle(true);
				end;
			else
				if vape.ToggleNotifications.Enabled then
					vape:CreateNotification(props.Name, (not component.Enabled and "<font color='#00AA00'>Enabled</font>" or "<font color='#FF5A5A'>Disabled</font>"), 1.5);
				end;
		
				component:Toggle(true);
			end;
		end);
		
		if inputService.TouchEnabled then
			local isHeld: boolean = false;
		
			button.MouseButton1Down:Connect(function(): ()
				isHeld = true;
				local holdtime: number, holdPos: Vector2 = os.clock(), inputService:GetMouseLocation();
				repeat
					isHeld = (inputService:GetMouseLocation() - holdPos).Magnitude < 3;
					task.wait();
				until (os.clock() - holdtime) > 1 or not isHeld or not clickgui.Visible;
		
				if isHeld and clickgui.Visible then
					if vape.ThreadFix then
						setthreadidentity(8);
					end;
		
					clickgui.Visible = false;
					tooltip.Visible = false;
					vape:BlurCheck();
					for _: any, module: any in vape.Modules do
						if module.Bind.Mobile then
							module.Bind.Mobile.Visible = true;
						end;
					end;
		
					local connection: RBXScriptConnection;
					connection = inputService.InputBegan:Connect(function(input: InputObject): ()
						if input.UserInputType == Enum.UserInputType.Touch then
							if vape.ThreadFix then
								setthreadidentity(8);
							end;
		
							bind:CreateMobileButton(input.Position + Vector3.new(0, guiService:GetGuiInset().Y, 0));
							clickgui.Visible = true;
							vape:BlurCheck();
		
							for _: any, module: any in vape.Modules do
								if module.Bind.Mobile then
									module.Bind.Mobile.Visible = false;
								end;
							end;
		
							connection:Disconnect();
						end;
					end);
				end;
			end);
		
			button.MouseButton1Up:Connect(function(): ()
				isHeld = false;
			end);
		end;
		
		vape.Modules[props.Name] = component;
		vape:SortCategories();
		
		return component;
	end,
	["Overlay"] = function(props: table, children: GuiObject, api: table): table
		local window: TextButton;
		local component: table;
		component = {
			["Button"] = vape.Overlays:CreateImageToggle({
				["Name"] = props.Name,
				["Function"] = function(callback: boolean): ()
					window.Visible = callback and (clickgui.Visible or component.Pinned);
		
					if not callback then
						for _: any, v: any in component.Connections do
							v:Disconnect();
						end;
						table.clear(component.Connections);
					end;
		
					if props.Function then
						task.spawn(props.Function, callback);
					end;
				end,
				["Icon"] = props.Icon,
				["Size"] = props.Size,
				["Position"] = props.Position
			}),
			["Expanded"] = false,
			["Pinned"] = false,
			["Options"] = {},
			["Type"] = 'Overlay'
		};
		
		window = Instance.new('TextButton');
		window.AutoButtonColor = false;
		window.BackgroundColor3 = uipallet.Main;
		window.Name = props.Name..'Overlay';
		window.Position = UDim2.fromOffset(240, 46);
		window.Size = UDim2.fromOffset(props.CategorySize or 220, 41);
		window.Text = '';
		window.Visible = false;
		window.Parent = scaledgui;
		component.Object = window;
		local blur: Instance = addBlur(window);
		addCorner(window);
		addDragHandler(window);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = props.Icon;
		icon.ImageColor3 = uipallet.Text;
		icon.Position = UDim2.fromOffset(12, (icon.Size.X.Offset > 14 and 14 or 13));
		icon.Size = props.Size;
		icon.Parent = window;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Size = UDim2.new(1, -32, 0, 41);
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 0);
		title.Text = props.Name;
		title.TextColor3 = uipallet.Text;
		title.TextSize = 13;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = window;
		local pin: ImageButton = Instance.new('ImageButton');
		pin.Name = 'Pin';
		pin.Size = UDim2.fromOffset(14, 14);
		pin.Position = UDim2.new(1, -37, 0, 14);
		pin.BackgroundTransparency = 1;
		pin.AutoButtonColor = false;
		pin.Image = getvapeasset('velo/assets/new/pin.png');
		pin.ImageColor3 = color.Dark(uipallet.Text, 0.43);
		pin.Parent = window;
		local dotsbutton: TextButton = Instance.new('TextButton');
		dotsbutton.Name = 'Dots';
		dotsbutton.Size = UDim2.fromOffset(17, 40);
		dotsbutton.Position = UDim2.new(1, -17, 0, 0);
		dotsbutton.BackgroundTransparency = 1;
		dotsbutton.Text = '';
		dotsbutton.Parent = window;
		local dots: ImageLabel = Instance.new('ImageLabel');
		dots.BackgroundTransparency = 1;
		dots.Image = getvapeasset('velo/assets/new/overlaydots.png');
		dots.ImageColor3 = color.Light(uipallet.Main, 0.37);
		dots.Position = UDim2.fromOffset(5, 15);
		dots.Size = UDim2.fromOffset(2, 12);
		dots.Parent = dotsbutton;
		local customchildren: Frame = Instance.new('Frame');
		customchildren.BackgroundTransparency = 1;
		customchildren.Position = UDim2.fromScale(0, 1);
		customchildren.Size = UDim2.new(1, 0, 0, 200);
		customchildren.Parent = window;
		local children: ScrollingFrame = Instance.new('ScrollingFrame');
		children.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
		children.BorderSizePixel = 0;
		children.CanvasSize = UDim2.new();
		children.Position = UDim2.fromOffset(0, 37);
		children.Size = UDim2.new(1, 0, 1, -41);
		children.ScrollBarThickness = 2;
		children.ScrollBarImageTransparency = 0.75;
		children.Visible = false;
		children.Parent = window;
		local stroke: UIStroke = Instance.new('UIStroke');
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		stroke.Color = Color3.fromRGB(85, 85, 85);
		stroke.Transparency = 0.8;
		stroke.Parent = window;
		local windowlist: UIListLayout = Instance.new('UIListLayout');
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.Parent = children;
		addMaid(component);
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			for _: any, component: any in self.Options do
				if component.Color then
					component:Color(hue, sat, val, isRainbow);
				end;
			end;
		end;
		
		component.Expand = function(self: table, visCheck: boolean?): ()
			if visCheck and not blur.Enabled then return; end;
		
			self.Expanded = not self.Expanded;
			children.Visible = self.Expanded;
			dots.ImageColor3 = self.Expanded and uipallet.Text or color.Light(uipallet.Main, 0.37);
		
			if self.Expanded then
				window.Size = UDim2.fromOffset(window.Size.X.Offset, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601));
			else
				window.Size = UDim2.fromOffset(window.Size.X.Offset, 41);
			end;
		end;
		
		component.Load = function(self: table, data: table): ()
			vape:LoadOptions(self, data.Options);
		
			if self.Button.Enabled ~= data.Enabled then
				self.Button:Toggle();
			end;
		
			if self.Pinned ~= data.Pinned then
				self:Pin();
				self:Update();
			end;
		
			if data.Position then
				window.Position = UDim2.fromOffset(data.Position.X, data.Position.Y);
			end;
		end;
		
		component.Pin = function(self: table): ()
			self.Pinned = not self.Pinned;
			pin.ImageColor3 = self.Pinned and uipallet.Text or color.Dark(uipallet.Text, 0.43);
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Enabled"] = self.Button.Enabled,
				["Options"] = vape:SaveOptions(self),
				["Pinned"] = self.Pinned,
				["Position"] = {
					["X"] = window.Position.X.Offset,
					["Y"] = window.Position.Y.Offset
				}
			};
		end;
		
		component.Update = function(self: table): ()
			window.Visible = self.Button.Enabled and (clickgui.Visible or self.Pinned);
			if self.Expanded then
				self:Expand();
			end;
		
			if clickgui.Visible then
				window.Size = UDim2.fromOffset(window.Size.X.Offset, 41);
				window.BackgroundTransparency = 0;
				blur.Enabled = true;
				stroke.Enabled = true;
				icon.Visible = true;
				title.Visible = true;
				pin.Visible = true;
				dotsbutton.Visible = true;
			else
				window.Size = UDim2.fromOffset(window.Size.X.Offset, 0);
				window.BackgroundTransparency = 1;
				blur.Enabled = false;
				stroke.Enabled = false;
				icon.Visible = false;
				title.Visible = false;
				pin.Visible = false;
				dotsbutton.Visible = false;
			end;
		end;
		
		for index: any, comp: any in components do
			component['Create'..index] = function(_: any, props: table): ...any
				return comp(props, children, component);
			end;
		end;
		
		vape:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function(): ()
			component:Update();
		end));
		
		dotsbutton.MouseEnter:Connect(function(): ()
			if not children.Visible then
				dots.ImageColor3 = uipallet.Text;
			end;
		end);
		
		dotsbutton.MouseLeave:Connect(function(): ()
			if not children.Visible then
				dots.ImageColor3 = color.Light(uipallet.Main, 0.37);
			end;
		end);
		
		dotsbutton.MouseButton1Click:Connect(function(): ()
			component:Expand(true);
		end);
		
		dotsbutton.MouseButton2Click:Connect(function(): ()
			component:Expand(true);
		end);
		
		pin.MouseButton1Click:Connect(function(): ()
			component:Pin();
		end);
		
		window.MouseButton2Click:Connect(function(): ()
			component:Expand(true);
		end);
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale);
			if component.Expanded then
				window.Size = UDim2.fromOffset(window.Size.X.Offset, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601));
			end;
		end);
		
		component.Children = customchildren;
		vape.Categories[props.Name] = component;
		
		return component;
	end,
	["OverlayBar"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Options"] = {},
			["Type"] = 'OverlayBar'
		};
		
		local bar: Frame = Instance.new('Frame');
		bar.Name = 'Overlays';
		bar.Size = UDim2.fromOffset(220, 36);
		bar.BackgroundColor3 = uipallet.Main;
		bar.BorderSizePixel = 0;
		bar.Parent = children;
		components.Divider(nil, bar);
		local button: ImageButton = Instance.new('ImageButton');
		button.AutoButtonColor = false;
		button.BackgroundTransparency = 1;
		button.Image = getvapeasset('velo/assets/new/overlays.png');
		button.ImageColor3 = color.Light(uipallet.Main, 0.37);
		button.Position = UDim2.new(1, -34, 0, 7);
		button.Size = UDim2.fromOffset(24, 24);
		button.Parent = bar;
		addCorner(button, UDim.new(1, 0));
		addTooltip(button, 'Open overlays menu');
		local shadow: TextButton = Instance.new('TextButton');
		shadow.AutoButtonColor = false;
		shadow.BackgroundColor3 = Color3.new();
		shadow.BackgroundTransparency = 1;
		shadow.ClipsDescendants = true;
		shadow.Name = 'Shadow';
		shadow.Size = UDim2.new(1, 0, 1, -5);
		shadow.Text = '';
		shadow.Visible = false;
		shadow.Parent = api.Object;
		addCorner(shadow);
		local window: Frame = Instance.new('Frame');
		window.BackgroundColor3 = uipallet.Main;
		window.Position = UDim2.fromScale(0, 1);
		window.Size = UDim2.fromOffset(220, 42);
		window.Parent = shadow;
		addCorner(window);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = getvapeasset('velo/assets/new/overlayslarge.png');
		icon.ImageColor3 = uipallet.Text;
		icon.Position = UDim2.fromOffset(10, 13);
		icon.Size = UDim2.fromOffset(14, 12);
		icon.Parent = window;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(36, 0);
		title.Size = UDim2.new(1, -36, 0, 38);
		title.Text = 'Overlays';
		title.TextColor3 = uipallet.Text;
		title.TextSize = 15;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = window;
		local close: ImageButton = addCloseButton(window, false, UDim2.new(1, -35, 0, 7));
		local divider: Frame = Instance.new('Frame');
		divider.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
		divider.BorderSizePixel = 0;
		divider.Position = UDim2.fromOffset(0, 37);
		divider.Size = UDim2.new(1, 0, 0, 1);
		divider.Parent = window;
		local childrentoggle: Frame = Instance.new('Frame');
		childrentoggle.BackgroundColor3 = uipallet.Main;
		childrentoggle.BackgroundTransparency = 1;
		childrentoggle.Position = UDim2.fromOffset(0, 38);
		childrentoggle.Parent = window;
		local windowlist: UIListLayout = Instance.new('UIListLayout');
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.Parent = childrentoggle;
		
		for index: any, comp: any in components do
			component['Create'..index] = function(_: any, props: table): ...any
				return comp(props, childrentoggle, component);
			end;
		end;
		
		button.MouseEnter:Connect(function(): ()
			button.ImageColor3 = uipallet.Text;
			tween:Tween(button, uipallet.Tween, {
				["BackgroundTransparency"] = 0.9
			});
		end);
		
		button.MouseLeave:Connect(function(): ()
			button.ImageColor3 = color.Light(uipallet.Main, 0.37);
			tween:Tween(button, uipallet.Tween, {
				["BackgroundTransparency"] = 1
			});
		end);
		
		button.MouseButton1Click:Connect(function(): ()
			shadow.Visible = true;
			tween:Tween(shadow, uipallet.Tween, {
				["BackgroundTransparency"] = 0.5
			});
		
			tween:Tween(window, uipallet.Tween, {
				["Position"] = UDim2.new(0, 0, 1, -(window.Size.Y.Offset))
			});
		end);
		
		close.MouseButton1Click:Connect(function(): ()
			tween:Tween(shadow, uipallet.Tween, {
				["BackgroundTransparency"] = 1
			});
		
			tween:Tween(window, uipallet.Tween, {
				["Position"] = UDim2.fromScale(0, 1)
			});
		
			task.delay(0.2, function(): ()
				shadow.Visible = false;
			end);
		end);
		
		shadow.MouseButton1Click:Connect(function(): ()
			tween:Tween(shadow, uipallet.Tween, {
				["BackgroundTransparency"] = 1
			});
		
			tween:Tween(window, uipallet.Tween, {
				["Position"] = UDim2.fromScale(0, 1)
			});
		
			task.delay(0.2, function(): ()
				shadow.Visible = false;
			end);
		end);
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			window.Size = UDim2.fromOffset(220, math.min(37 + windowlist.AbsoluteContentSize.Y / scale.Scale, 605));
			childrentoggle.Size = UDim2.fromOffset(220, window.Size.Y.Offset - 5);
		end);
		
		vape.Overlays = component;
		
		return component;
	end,
	["SearchBar"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Type"] = 'SearchBar'
		};
		
		local listenProperty: (src: Instance, dest: Instance, prop: string, obj: any) -> () = function(src: Instance, dest: Instance, prop: string, obj: any): ()
			dest[prop] = src[prop];
			local connection: RBXScriptConnection = src:GetPropertyChangedSignal(prop):Connect(function(): ()
				dest[prop] = src[prop];
			end);
		
			obj.Destroying:Once(function(): ()
				connection:Disconnect();
			end);
		end;
		
		local search: Frame = Instance.new('Frame');
		search.AnchorPoint = Vector2.new(0.5, 0);
		search.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
		search.Name = 'Search';
		search.Position = UDim2.new(0.5, 0, 0, 13);
		search.Size = UDim2.fromOffset(220, 37);
		search.Parent = clickgui;
		component.Object = search;
		addBlur(search);
		addCorner(search);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = getvapeasset('velo/assets/new/search.png');
		icon.ImageColor3 = color.Light(uipallet.Main, 0.37);
		icon.Position = UDim2.new(1, -25, 0, 11);
		icon.Size = UDim2.fromOffset(14, 14);
		icon.Parent = search;
		local legiticon: ImageButton = Instance.new('ImageButton');
		legiticon.BackgroundTransparency = 1;
		legiticon.Image = getvapeasset('velo/assets/new/legit_switch.png');
		legiticon.Name = 'Legit';
		legiticon.Position = UDim2.fromOffset(8, 11);
		legiticon.Size = UDim2.fromOffset(29, 16);
		legiticon.Parent = search;
		listenProperty(vape.Categories.Main.Object.VapeLogo.V4Logo, legiticon, 'ImageColor3', legiticon);
		local legitdivider: Frame = Instance.new('Frame');
		legitdivider.BackgroundColor3 = color.Light(uipallet.Main, 0.14);
		legitdivider.BorderSizePixel = 0;
		legitdivider.Name = 'LegitDivider';
		legitdivider.Position = UDim2.fromOffset(43, 13);
		legitdivider.Size = UDim2.fromOffset(2, 12);
		legitdivider.Parent = search;
		local box: TextBox = Instance.new('TextBox');
		box.BackgroundTransparency = 1;
		box.ClearTextOnFocus = false;
		box.FontFace = uipallet.Font;
		box.PlaceholderText = '';
		box.Position = UDim2.fromOffset(50, 0);
		box.Size = UDim2.new(1, -50, 0, 37);
		box.Text = '';
		box.TextColor3 = uipallet.Text;
		box.TextSize = 12;
		box.TextXAlignment = Enum.TextXAlignment.Left;
		box.Parent = search;
		local children: ScrollingFrame = Instance.new('ScrollingFrame');
		children.BackgroundTransparency = 1;
		children.BorderSizePixel = 0;
		children.CanvasSize = UDim2.new();
		children.Position = UDim2.fromOffset(0, 34);
		children.ScrollBarThickness = 2;
		children.ScrollBarImageTransparency = 0.75;
		children.Size = UDim2.new(1, 0, 1, -37);
		children.Parent = search;
		local divider: Frame = Instance.new('Frame');
		divider.BackgroundColor3 = Color3.new(1, 1, 1);
		divider.BackgroundTransparency = 0.928;
		divider.BorderSizePixel = 0;
		divider.Position = UDim2.fromOffset(0, 33);
		divider.Size = UDim2.new(1, 0, 0, 1);
		divider.Visible = false;
		divider.Parent = search;
		local stroke: UIStroke = Instance.new('UIStroke');
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		stroke.Color = Color3.fromRGB(85, 85, 85);
		stroke.Transparency = 0.8;
		stroke.Parent = search;
		local windowlist: UIListLayout = Instance.new('UIListLayout');
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder;
		windowlist.Parent = children;
		
		box:GetPropertyChangedSignal('Text'):Connect(function(): ()
			for _: number, obj: Instance in children:GetChildren() do
				if obj:IsA('TextButton') then
					obj:Destroy();
				end;
			end;
		
			if box.Text == '' then return; end;
		
			for name: any, module: any in vape.Modules do
				if name:lower():find(box.Text:lower()) then
					local button: any = module.Object:Clone();
					button.Bind:Destroy();
		
					button.MouseButton1Click:Connect(function(): ()
						module:Toggle();
					end);
		
					button.MouseButton2Click:Connect(function(): ()
						module.Object.Parent.Parent.Visible = true;
						local frame: any = module.Object.Parent;
						local highlight: Frame = Instance.new('Frame');
						highlight.Size = UDim2.fromScale(1, 1);
						highlight.BackgroundColor3 = Color3.new(1, 1, 1);
						highlight.BackgroundTransparency = 0.6;
						highlight.BorderSizePixel = 0;
						highlight.Parent = module.Object;
		
						tween:Tween(highlight, TweenInfo.new(0.5), {
							["BackgroundTransparency"] = 1
						});
						task.delay(0.5, highlight.Destroy, highlight);
						frame.CanvasPosition = Vector2.new(0, (module.Object.LayoutOrder * 40) - (math.min(frame.CanvasSize.Y.Offset, 600) / 2));
					end);
		
					for _: number, prop: string in {'Text', 'TextColor3', 'BackgroundColor3'} do
						listenProperty(module.Object, button, prop, button);
					end;
		
					listenProperty(module.Object.UIGradient, button.UIGradient, 'Color', button);
					listenProperty(module.Object.UIGradient, button.UIGradient, 'Enabled', button);
					listenProperty(module.Object.Dots.Dots, button.Dots.Dots, 'ImageColor3', button);
		
					button.Parent = children;
				end;
			end;
		end);
		
		children:GetPropertyChangedSignal('CanvasPosition'):Connect(function(): ()
			divider.Visible = children.CanvasPosition.Y > 10 and children.Visible;
		end);
		
		legiticon.MouseButton1Click:Connect(function(): ()
			clickgui.Visible = false;
			vape.Legit.Window.Visible = true;
			vape.Legit.Window.Position = UDim2.new(0.5, -350, 0.5, -194);
		end);
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale);
			search.Size = UDim2.fromOffset(220, math.min(37 + windowlist.AbsoluteContentSize.Y / scale.Scale, 437));
		end);
		
		return component;
	end,
	["SettingsPane"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Buttons"] = {},
			["Options"] = {},
			["Parent"] = api.Parent or children,
			["Type"] = 'SettingsPane'
		};
		
		local pane: TextButton = Instance.new('TextButton');
		pane.AutoButtonColor = false;
		pane.BackgroundColor3 = props.Main and color.Dark(uipallet.Main, 0.02) or uipallet.Main;
		pane.Size = UDim2.fromScale(1, 1);
		pane.Text = '';
		pane.Visible = false;
		pane.Parent = component.Parent;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Name = 'Title';
		title.Size = UDim2.new(1, -36, 0, 20);
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 11);
		title.Text = props.Name;
		title.TextColor3 = uipallet.Text;
		title.TextSize = 13;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = pane;
		local close: ImageButton = addCloseButton(pane, true);
		local back: ImageButton = Instance.new('ImageButton');
		back.BackgroundTransparency = 1;
		back.Image = getvapeasset('velo/assets/new/backmini.png');
		back.ImageColor3 = color.Light(uipallet.Main, 0.37);
		back.Position = UDim2.fromOffset(12, 14);
		back.Size = UDim2.fromOffset(14, 14);
		back.Parent = pane;
		addCorner(pane);
		local settingschildren: Frame = Instance.new('Frame');
		settingschildren.BackgroundColor3 = uipallet.Main;
		settingschildren.BorderSizePixel = 0;
		settingschildren.Name = 'Children';
		settingschildren.Position = UDim2.fromOffset(0, 41);
		settingschildren.Size = UDim2.new(1, 0, 1, -57);
		settingschildren.Parent = pane;
		local divider: Frame = Instance.new('Frame');
		divider.BackgroundColor3 = Color3.new(1, 1, 1);
		divider.BackgroundTransparency = 0.928;
		divider.BorderSizePixel = 0;
		divider.Name = 'Divider';
		divider.Size = UDim2.new(1, 0, 0, 1);
		divider.Parent = settingschildren;
		local listlayout: UIListLayout = Instance.new('UIListLayout');
		listlayout.SortOrder = Enum.SortOrder.LayoutOrder;
		listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		listlayout.Parent = settingschildren;
		if props.Main then
			local versionlabel: TextLabel = Instance.new('TextLabel');
			versionlabel.BackgroundTransparency = 1;
			versionlabel.FontFace = uipallet.Font;
			versionlabel.Name = 'Version';
			versionlabel.Position = UDim2.new(0, 0, 1, -16);
			versionlabel.Size = UDim2.new(1, 0, 0, 16);
			versionlabel.Text = 'Vape '..vape.Version..' '..(
				isfile('velo/profiles/commit.txt') and readfile('velo/profiles/commit.txt'):sub(1, 6) or ''
			)..' ';
			versionlabel.TextColor3 = color.Dark(uipallet.Text, 0.43);
			versionlabel.TextSize = 10;
			versionlabel.TextXAlignment = Enum.TextXAlignment.Right;
			versionlabel.Parent = pane;
		else
			api:CreateGUIButton({
				["Name"] = props.Name,
				["Function"] = function(): ()
					pane.Visible = true;
				end
			});
		end;
		
		component.Load = function(self: table, data: table): ()
			vape:LoadOptions(self, data);
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = vape:SaveOptions(self);
		end;
		
		for index: any, comp: any in components do
			component['Create'..index] = function(_: any, props: table): ...any
				return comp(props, settingschildren, component);
			end;
		end;
		
		back.MouseEnter:Connect(function(): ()
			back.ImageColor3 = uipallet.Text;
		end);
		
		back.MouseLeave:Connect(function(): ()
			back.ImageColor3 = color.Light(uipallet.Main, 0.37);
		end);
		
		back.MouseButton1Click:Connect(function(): ()
			pane.Visible = false;
		end);
		
		close.MouseButton1Click:Connect(function(): ()
			pane.Visible = false;
		end);
		
		listlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			pane.Size = UDim2.new(1, 0, 0, math.max(45 + listlayout.AbsoluteContentSize.Y, component.Parent.AbsoluteSize.Y) / scale.Scale);
		end);
		
		component.Object = pane;
		vape.Settings[props.Name] = component;
		
		return component;
	end,
	["Slider"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Index"] = getTableSize(api.Options),
			["Max"] = props.Max,
			["Type"] = 'Slider',
			["Value"] = props.Default or props.Min,
		};
		
		local slider: TextButton = Instance.new('TextButton');
		slider.AutoButtonColor = false;
		slider.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		slider.BorderSizePixel = 0;
		slider.Size = UDim2.new(1, 0, 0, 50);
		slider.Text = '';
		slider.Visible = props.Visible == nil or props.Visible;
		slider.Parent = children;
		component.Object = slider;
		addTooltip(slider, props.Tooltip);
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(10, 2);
		title.Size = UDim2.fromOffset(60, 30);
		title.Text = props.Name;
		title.TextColor3 = color.Dark(uipallet.Text, 0.16);
		title.TextSize = 11;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = slider;
		local valuelabel: TextButton = Instance.new('TextButton');
		valuelabel.BackgroundTransparency = 1;
		valuelabel.FontFace = uipallet.Font;
		valuelabel.Position = UDim2.new(1, -69, 0, 9);
		valuelabel.Size = UDim2.fromOffset(60, 15);
		valuelabel.Text = component.Value..(props.Suffix and ' '..(type(props.Suffix) == 'function' and props.Suffix(component.Value) or props.Suffix) or '');
		valuelabel.TextColor3 = color.Dark(uipallet.Text, 0.16);
		valuelabel.TextSize = 11;
		valuelabel.TextXAlignment = Enum.TextXAlignment.Right;
		valuelabel.Parent = slider;
		local custombox: TextBox = Instance.new('TextBox');
		custombox.BackgroundTransparency = 1;
		custombox.ClearTextOnFocus = false;
		custombox.FontFace = uipallet.Font;
		custombox.Position = valuelabel.Position;
		custombox.Size = valuelabel.Size;
		custombox.Text = component.Value;
		custombox.TextColor3 = color.Dark(uipallet.Text, 0.16);
		custombox.TextSize = 11;
		custombox.TextXAlignment = Enum.TextXAlignment.Right;
		custombox.Visible = false;
		custombox.Parent = slider;
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034);
		holder.BorderSizePixel = 0;
		holder.Position = UDim2.fromOffset(10, 37);
		holder.Size = UDim2.new(1, -20, 0, 2);
		holder.Parent = slider;
		local fill: Frame = Instance.new('Frame');
		fill.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value);
		fill.BorderSizePixel = 0;
		fill.Size = UDim2.fromScale(math.clamp((component.Value - props.Min) / (props.Max - props.Min), 0.04, 0.96), 1);
		fill.Parent = holder;
		local knobholder: Frame = Instance.new('Frame');
		knobholder.AnchorPoint = Vector2.new(0.5, 0.5);
		knobholder.BackgroundColor3 = slider.BackgroundColor3;
		knobholder.BorderSizePixel = 0;
		knobholder.Position = UDim2.fromScale(1, 0.5);
		knobholder.Size = UDim2.fromOffset(24, 4);
		knobholder.Parent = fill;
		local knob: Frame = Instance.new('Frame');
		knob.AnchorPoint = Vector2.new(0.5, 0.5);
		knob.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value);
		knob.Position = UDim2.fromScale(0.5, 0.5);
		knob.Size = UDim2.fromOffset(14, 14);
		knob.Parent = knobholder;
		addCorner(knob, UDim.new(1, 0));
		props.Function = props.Function or function(): () end;
		props.Decimal = props.Decimal or 1;
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			fill.BackgroundColor3 = isRainbow and vape:SampleColor(self.Index * 0.075) or Color3.fromHSV(hue, sat, val);
			knob.BackgroundColor3 = fill.BackgroundColor3;
		end;
		
		component.Load = function(self: table, data: table): ()
			local newValue: any = data.Value == data.Max and data.Max ~= self.Max and self.Max or data.Value;
			if self.Value ~= newValue then
				self:SetValue(newValue, nil, true);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Value"] = self.Value,
				["Max"] = self.Max
			};
		end;
		
		component.SetValue = function(self: table, value: number, position: number?, wasReleased: boolean?): ()
			if not math.isfinite(value) then
				return;
			end;
		
			tween:Tween(fill, uipallet.Tween, {
				["Size"] = UDim2.fromScale(math.clamp(position or math.clamp((value - props.Min) / (props.Max - props.Min), 0, 1), 0.04, 0.96), 1)
			});
		
			if self.Value ~= value or wasReleased then
				self.Value = value;
				valuelabel.Text = self.Value..(props.Suffix and ' '..(type(props.Suffix) == 'function' and props.Suffix(self.Value) or props.Suffix) or '');
				props.Function(value, wasReleased);
			end;
		end;
		
		slider.InputBegan:Connect(function(input: InputObject): ()
			if
				(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (input.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				local newPosition: number = math.clamp((input.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1);
				local lastPosition: number = newPosition;
		
				local releaseConnection: RBXScriptConnection;
				local moveConnection: RBXScriptConnection = inputService.InputChanged:Connect(function(newInput: InputObject): ()
					if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						local newPosition: number = math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1);
						component:SetValue(math.floor((props.Min + (props.Max - props.Min) * newPosition) * props.Decimal) / props.Decimal, newPosition);
						lastPosition = newPosition;
					end;
				end);
		
				releaseConnection = input.Changed:Connect(function(): ()
					if input.UserInputState == Enum.UserInputState.End then
						moveConnection:Disconnect();
						releaseConnection:Disconnect();
						component:SetValue(component.Value, lastPosition, true);
					end;
				end);
		
				component:SetValue(math.floor((props.Min + (props.Max - props.Min) * newPosition) * props.Decimal) / props.Decimal, newPosition);
			end;
		end);
		
		slider.MouseEnter:Connect(function(): ()
			tween:Tween(knob, uipallet.Tween, {
				["Size"] = UDim2.fromOffset(16, 16)
			});
		end);
		
		slider.MouseLeave:Connect(function(): ()
			tween:Tween(knob, uipallet.Tween, {
				["Size"] = UDim2.fromOffset(14, 14)
			});
		end);
		
		valuelabel.MouseButton1Click:Connect(function(): ()
			valuelabel.Visible = false;
			custombox.Visible = true;
			custombox.Text = component.Value;
			custombox:CaptureFocus();
		end);
		
		custombox.FocusLost:Connect(function(enter: boolean): ()
			valuelabel.Visible = true;
			custombox.Visible = false;
		
			if enter and tonumber(custombox.Text) then
				component:SetValue(tonumber(custombox.Text), nil, true);
			end;
		end);
		
		api.Options[props.Name] = component;
		
		return component;
	end,
	["Targets"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Index"] = getTableSize(api.Options),
			["Type"] = 'Targets'
		};
		
		local targets: TextButton = Instance.new('TextButton');
		targets.AutoButtonColor = false;
		targets.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		targets.BorderSizePixel = 0;
		targets.Size = UDim2.new(1, 0, 0, 50);
		targets.Text = '';
		targets.Visible = props.Visible == nil or props.Visible;
		targets.Parent = children;
		component.Object = targets;
		addTooltip(targets, props.Tooltip);
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034);
		holder.Position = UDim2.fromOffset(10, 4);
		holder.Size = UDim2.new(1, -20, 1, -9);
		holder.Parent = targets;
		addCorner(holder, UDim.new(0, 4));
		local button: TextButton = Instance.new('TextButton');
		button.AutoButtonColor = false;
		button.BackgroundColor3 = uipallet.Main;
		button.Position = UDim2.fromOffset(1, 1);
		button.Size = UDim2.new(1, -2, 1, -2);
		button.Text = '';
		button.Parent = holder;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(5, 6);
		title.Size = UDim2.new(1, -5, 0, 15);
		title.Text = 'Target:';
		title.TextColor3 = color.Dark(uipallet.Text, 0.16);
		title.TextSize = 15;
		title.TextTruncate = Enum.TextTruncate.AtEnd;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = button;
		local items: TextLabel = Instance.new('TextLabel');
		items.BackgroundTransparency = 1;
		items.FontFace = uipallet.Font;
		items.Position = UDim2.fromOffset(5, 21);
		items.Size = UDim2.new(1, -5, 0, 15);
		items.Text = 'Ignore none';
		items.TextColor3 = color.Dark(uipallet.Text, 0.16);
		items.TextSize = 11;
		items.TextTruncate = Enum.TextTruncate.AtEnd;
		items.TextXAlignment = Enum.TextXAlignment.Left;
		items.Parent = button;
		addCorner(button, UDim.new(0, 4));
		local iconholder: Frame = Instance.new('Frame');
		iconholder.BackgroundTransparency = 1;
		iconholder.Position = UDim2.fromOffset(52, 8);
		iconholder.Size = UDim2.fromOffset(65, 12);
		iconholder.Parent = button;
		local layout: UIListLayout = Instance.new('UIListLayout');
		layout.FillDirection = Enum.FillDirection.Horizontal;
		layout.Padding = UDim.new(0, 6);
		layout.Parent = iconholder;
		local targetswindow: TextButton = Instance.new('TextButton');
		targetswindow.AutoButtonColor = false;
		targetswindow.BackgroundColor3 = uipallet.Main;
		targetswindow.BorderSizePixel = 0;
		targetswindow.Position = UDim2.fromOffset(456, 139);
		targetswindow.Size = UDim2.fromOffset(220, 145);
		targetswindow.Text = '';
		targetswindow.Visible = false;
		targetswindow.Parent = clickgui;
		component.Window = targetswindow;
		addBlur(targetswindow);
		addCorner(targetswindow);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = getvapeasset('velo/assets/new/aim.png');
		icon.Position = UDim2.fromOffset(10, 15);
		icon.Size = UDim2.fromOffset(18, 12);
		icon.Parent = targetswindow;
		local windowtitle: TextLabel = Instance.new('TextLabel');
		windowtitle.BackgroundTransparency = 1;
		windowtitle.FontFace = uipallet.Font;
		windowtitle.Size = UDim2.new(1, -36, 0, 20);
		windowtitle.Position = UDim2.fromOffset(math.abs(windowtitle.Size.X.Offset), 11);
		windowtitle.Text = 'Target settings';
		windowtitle.TextColor3 = uipallet.Text;
		windowtitle.TextSize = 13;
		windowtitle.TextXAlignment = Enum.TextXAlignment.Left;
		windowtitle.Parent = targetswindow;
		local close: ImageButton = addCloseButton(targetswindow);
		props.Function = props.Function or function(): () end;
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			if targetswindow.Visible then
				holder.BackgroundColor3 = isRainbow and vape:SampleColor(self.Index * 0.075) or Color3.fromHSV(hue, sat, val);
			end;
		
			if self.Players.Enabled then
				tween:Cancel(self.Players.Object.Frame);
				self.Players.Object.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			end;
		
			if self.NPCs.Enabled then
				tween:Cancel(self.NPCs.Object.Frame);
				self.NPCs.Object.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			end;
		
			if self.Invisible.Enabled then
				tween:Cancel(self.Invisible.Object.Holder);
				self.Invisible.Object.Holder.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			end;
		
			if self.Walls.Enabled then
				tween:Cancel(self.Walls.Object.Holder);
				self.Walls.Object.Holder.BackgroundColor3 = Color3.fromHSV(hue, sat, val);
			end;
		end;
		
		component.Load = function(self: table, data: table): ()
			if self.Players.Enabled ~= data.Players then
				self.Players:Toggle();
			end;
		
			if self.NPCs.Enabled ~= data.NPCs then
				self.NPCs:Toggle();
			end;
		
			if self.Invisible.Enabled ~= data.Invisible then
				self.Invisible:Toggle();
			end;
		
			if self.Walls.Enabled ~= data.Walls then
				self.Walls:Toggle();
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data.Targets = {
				["Players"] = self.Players.Enabled,
				["NPCs"] = self.NPCs.Enabled,
				["Invisible"] = self.Invisible.Enabled,
				["Walls"] = self.Walls.Enabled
			};
		end;
		
		component.UpdateText = function(self: table): ()
			local newText: table = {};
		
			if self.Players.Enabled then
				table.insert(newText, 'Players');
			end;
		
			if self.NPCs.Enabled then
				table.insert(newText, 'NPCs');
			end;
		
			title.Text = 'Target: '..(#newText > 0 and table.concat(newText, ', ') or 'Nothing');
			title.TextColor3 = #newText > 0 and uipallet.Text or Color3.fromRGB(255, 90, 90);
		end;
		
		component.Players = components.TargetsButton({
			["Position"] = UDim2.fromOffset(11, 45),
			["Icon"] = getvapeasset('velo/assets/new/players.png'),
			["IconSize"] = UDim2.fromOffset(16, 16),
			["IconParent"] = iconholder,
			["Targets"] = component,
			["Tooltip"] = 'Target players',
			["Function"] = props.Function
		}, targetswindow, iconholder);
		
		component.NPCs = components.TargetsButton({
			["Position"] = UDim2.fromOffset(112, 45),
			["Icon"] = getvapeasset('velo/assets/new/npcs.png'),
			["IconSize"] = UDim2.fromOffset(12, 16),
			["IconParent"] = iconholder,
			["Targets"] = component,
			["Tooltip"] = 'Target NPCs',
			["Function"] = props.Function
		}, targetswindow, iconholder);
		
		component.Invisible = components.Toggle({
			["Name"] = 'Ignore invisible',
			["Function"] = function(): ()
				local newText: table = {};
		
				if component.Invisible.Enabled then
					table.insert(newText, 'invisible');
				end;
		
				if component.Walls.Enabled then
					table.insert(newText, 'behind walls');
				end;
		
				items.Text = 'Ignore '..(#newText > 0 and table.concat(newText, ', ') or 'none');
				props.Function();
			end
		}, targetswindow, {["Options"] = {}});
		component.Invisible.Object.Position = UDim2.fromOffset(0, 81);
		
		component.Walls = components.Toggle({
			["Name"] = 'Ignore behind walls',
			["Function"] = function(): ()
				local newText: table = {};
		
				if component.Invisible.Enabled then
					table.insert(newText, 'invisible');
				end;
		
				if component.Walls.Enabled then
					table.insert(newText, 'behind walls');
				end;
		
				items.Text = 'Ignore '..(#newText > 0 and table.concat(newText, ', ') or 'none');
				props.Function();
			end
		}, targetswindow, {["Options"] = {}});
		component.Walls.Object.Position = UDim2.fromOffset(0, 111);
		
		if props.Players then
			component.Players:Toggle();
		end;
		
		if props.NPCs then
			component.NPCs:Toggle();
		end;
		
		if props.Invisible then
			component.Invisible:Toggle();
		end;
		
		if props.Walls then
			component.Walls:Toggle();
		end;
		
		close.MouseButton1Click:Connect(function(): ()
			targetswindow.Visible = false;
		end);
		
		button.MouseButton1Click:Connect(function(): ()
			targetswindow.Visible = not targetswindow.Visible;
			tween:Cancel(holder);
		
			holder.BackgroundColor3 = targetswindow.Visible and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or color.Light(uipallet.Main, 0.37);
		end);
		
		targets.MouseEnter:Connect(function(): ()
			if not targetswindow.Visible then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = color.Light(uipallet.Main, 0.37)
				});
			end;
		end);
		
		targets.MouseLeave:Connect(function(): ()
			if not targetswindow.Visible then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = color.Light(uipallet.Main, 0.034)
				});
			end;
		end);
		
		targets:GetPropertyChangedSignal('AbsolutePosition'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			local actualPosition: any = (targets.AbsolutePosition + Vector2.new(0, 60)) / scale.Scale;
			targetswindow.Position = UDim2.fromOffset(actualPosition.X + 223, actualPosition.Y);
		end);
		
		api.Options.Targets = component;
		
		return component;
	end,
	["TargetsButton"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Enabled"] = false,
			["Type"] = 'TargetsButton'
		};
		
		local targetsbutton: TextButton = Instance.new('TextButton');
		targetsbutton.AutoButtonColor = false;
		targetsbutton.BackgroundColor3 = color.Light(uipallet.Main, 0.05);
		targetsbutton.Position = props.Position;
		targetsbutton.Size = UDim2.fromOffset(98, 31);
		targetsbutton.Text = '';
		targetsbutton.Visible = props.Visible == nil or props.Visible;
		targetsbutton.Parent = children;
		component.Object = targetsbutton;
		addCorner(targetsbutton);
		addTooltip(targetsbutton, props.Tooltip);
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = uipallet.Main;
		holder.Position = UDim2.fromOffset(1, 1);
		holder.Size = UDim2.new(1, -2, 1, -2);
		holder.Parent = targetsbutton;
		addCorner(holder);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.AnchorPoint = Vector2.new(0.5, 0.5);
		icon.BackgroundTransparency = 1;
		icon.Image = props.Icon;
		icon.ImageColor3 = color.Light(uipallet.Main, 0.37);
		icon.Position = UDim2.fromScale(0.5, 0.5);
		icon.Size = props.IconSize;
		icon.Parent = holder;
		props.Function = props.Function or function(): () end;
		
		component.Toggle = function(self: table): ()
			self.Enabled = not self.Enabled;
		
			tween:Tween(holder, uipallet.Tween, {
				["BackgroundColor3"] = self.Enabled and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or uipallet.Main
			});
		
			tween:Tween(icon, uipallet.Tween, {
				["ImageColor3"] = self.Enabled and Color3.new(1, 1, 1) or color.Light(uipallet.Main, 0.37)
			});
		
			props.Targets:UpdateText();
			props.Function(self.Enabled);
		end;
		
		targetsbutton.MouseEnter:Connect(function(): ()
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value - 0.25)
				});
		
				tween:Tween(icon, uipallet.Tween, {
					["ImageColor3"] = Color3.new(1, 1, 1)
				});
			end;
		end);
		
		targetsbutton.MouseLeave:Connect(function(): ()
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = uipallet.Main
				});
		
				tween:Tween(icon, uipallet.Tween, {
					["ImageColor3"] = color.Light(uipallet.Main, 0.37)
				});
			end;
		end);
		
		targetsbutton.MouseButton1Click:Connect(function(): ()
			component:Toggle();
		end);
		
		return component;
	end,
	["TextBox"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Index"] = 0,
			["Type"] = 'TextBox',
			["Value"] = props.Default or ''
		};
		
		local textbox: TextButton = Instance.new('TextButton');
		textbox.AutoButtonColor = false;
		textbox.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		textbox.BorderSizePixel = 0;
		textbox.Size = UDim2.new(1, 0, 0, 58);
		textbox.Text = '';
		textbox.Visible = props.Visible == nil or props.Visible;
		textbox.Parent = children;
		component.Object = textbox;
		addTooltip(textbox, props.Tooltip);
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(10, 3);
		title.Size = UDim2.new(1, -10, 0, 20);
		title.Text = props.Name;
		title.TextColor3 = uipallet.Text;
		title.TextSize = 12;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = textbox;
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
		holder.Position = UDim2.fromOffset(10, 23);
		holder.Size = UDim2.new(1, -20, 0, 29);
		holder.Parent = textbox;
		addCorner(holder, UDim.new(0, 4));
		local inputbox: TextBox = Instance.new('TextBox');
		inputbox.BackgroundTransparency = 1;
		inputbox.ClearTextOnFocus = false;
		inputbox.FontFace = uipallet.Font;
		inputbox.PlaceholderColor3 = color.Dark(uipallet.Text, 0.31);
		inputbox.PlaceholderText = props.Placeholder or 'Click to set';
		inputbox.Position = UDim2.fromOffset(8, 0);
		inputbox.Size = UDim2.new(1, -8, 1, 0);
		inputbox.Text = props.Default or '';
		inputbox.TextColor3 = color.Dark(uipallet.Text, 0.16);
		inputbox.TextSize = 12;
		inputbox.TextXAlignment = Enum.TextXAlignment.Left;
		inputbox.Parent = holder;
		local autocomplete: TextLabel;
		if props.Player then
			inputbox.ZIndex = 2;
			autocomplete = Instance.new('TextLabel');
			autocomplete.BackgroundTransparency = 1;
			autocomplete.FontFace = uipallet.Font;
			autocomplete.Position = UDim2.fromOffset(8, 0);
			autocomplete.Size = UDim2.new(1, -8, 1, 0);
			autocomplete.Text = '';
			autocomplete.TextColor3 = Color3.new(0.6, 0.6, 0.6);
			autocomplete.TextSize = 12;
			autocomplete.TextXAlignment = Enum.TextXAlignment.Left;
			autocomplete.Parent = holder;
		end;
		props.Function = props.Function or function(): () end;
		
		component.Load = function(self: table, data: table): ()
			if self.Value ~= data.Value then
				self:SetValue(data.Value);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Value"] = self.Value
			};
		end;
		
		component.SetValue = function(self: table, val: string, enter: boolean?): ()
			self.Value = val;
			inputbox.Text = val;
			props.Function(enter);
		end;
		
		textbox.MouseButton1Click:Connect(function(): ()
			inputbox:CaptureFocus();
		end);
		
		if autocomplete then
			inputbox:GetPropertyChangedSignal('Text'):Connect(function(): ()
				local plr: any = getPlayerFromText(inputbox.Text);
				autocomplete.Text = plr and inputbox.Text..(plr:sub(#inputbox.Text + 1, #plr)) or '';
			end);
		
			inputbox.Focused:Connect(function(): ()
				vape.Autocomplete = function(): ()
					local newText: any = getPlayerFromText(inputbox.Text) or inputbox.Text;
					task.spawn(function(): ()
						inputbox:GetPropertyChangedSignal('Text'):Wait();
						inputbox.Text = newText;
						inputbox.CursorPosition = #newText + 1;
					end);
				end;
			end);
		end;
		
		inputbox.FocusLost:Connect(function(enter: boolean): ()
			component:SetValue(inputbox.Text, enter);
		end);
		
		inputbox:GetPropertyChangedSignal('Text'):Connect(function(): ()
			component:SetValue(inputbox.Text);
		end);
		
		api.Options[props.Name] = component;
		
		return component;
	end,
	["TextList"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Index"] = getTableSize(api.Options),
			["List"] = props.Default and table.clone(props.Default) or {},
			["ListEnabled"] = props.Default and table.clone(props.Default) or {},
			["Objects"] = {},
			["Type"] = 'TextList',
			["Window"] = {["Visible"] = false}
		};
		
		props.Color = props.Color or Color3.fromRGB(5, 134, 105);
		local textlist: TextButton = Instance.new('TextButton');
		textlist.AutoButtonColor = false;
		textlist.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		textlist.BorderSizePixel = 0;
		textlist.Size = UDim2.new(1, 0, 0, 50);
		textlist.Text = '';
		textlist.Visible = props.Visible == nil or props.Visible;
		textlist.Parent = children;
		component.Object = textlist;
		addTooltip(textlist, props.Tooltip);
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034);
		holder.Position = UDim2.fromOffset(10, 4);
		holder.Size = UDim2.new(1, -20, 1, -9);
		holder.Parent = textlist;
		addCorner(holder, UDim.new(0, 4));
		local button: TextButton = Instance.new('TextButton');
		button.AutoButtonColor = false;
		button.BackgroundColor3 = uipallet.Main;
		button.Position = UDim2.fromOffset(1, 1);
		button.Size = UDim2.new(1, -2, 1, -2);
		button.Text = '';
		button.Parent = holder;
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = getvapeasset('velo/assets/new/allowediconmini.png');
		icon.Position = UDim2.fromOffset(10, 14);
		icon.Size = UDim2.fromOffset(14, 12);
		icon.Parent = button;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(35, 6);
		title.Size = UDim2.new(1, -35, 0, 15);
		title.Text = props.Name;
		title.TextColor3 = color.Dark(uipallet.Text, 0.16);
		title.TextSize = 15;
		title.TextTruncate = Enum.TextTruncate.AtEnd;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = button;
		local amount: any = Instance.fromExisting(title);
		amount.Position = UDim2.fromOffset(0, 6);
		amount.Size = UDim2.new(1, -13, 0, 15);
		amount.Text = '0';
		amount.TextXAlignment = Enum.TextXAlignment.Right;
		amount.Parent = button;
		local items: any = Instance.fromExisting(title);
		items.Position = UDim2.fromOffset(35, 21);
		items.Text = 'None';
		items.TextColor3 = color.Dark(uipallet.Text, 0.43);
		items.TextSize = 11;
		items.Parent = button;
		addCorner(button, UDim.new(0, 4));
		local textlistwindow: TextButton = Instance.new('TextButton');
		textlistwindow.AutoButtonColor = false;
		textlistwindow.BackgroundColor3 = uipallet.Main;
		textlistwindow.BorderSizePixel = 0;
		textlistwindow.Position = UDim2.fromOffset(456, 227);
		textlistwindow.Size = UDim2.fromOffset(220, 85);
		textlistwindow.Text = '';
		textlistwindow.Visible = false;
		textlistwindow.Parent = api.Legit and vape.Legit.Window or clickgui;
		component.Window = textlistwindow;
		addBlur(textlistwindow);
		addCorner(textlistwindow);
		local icon: ImageLabel = Instance.new('ImageLabel');
		icon.BackgroundTransparency = 1;
		icon.Image = getvapeasset('velo/assets/new/allowedicon.png');
		icon.Position = UDim2.fromOffset(10, 13);
		icon.Size = UDim2.fromOffset(19, 16);
		icon.Parent = textlistwindow;
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(36, 11);
		title.Size = UDim2.new(1, -36, 0, 20);
		title.Text = props.Name;
		title.TextColor3 = uipallet.Text;
		title.TextSize = 13;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = textlistwindow;
		local close: ImageButton = addCloseButton(textlistwindow);
		local boxholder: Frame = Instance.new('Frame');
		boxholder.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
		boxholder.Position = UDim2.fromOffset(10, 45);
		boxholder.Size = UDim2.fromOffset(200, 31);
		boxholder.Parent = textlistwindow;
		addCorner(boxholder);
		local boxinner: Frame = Instance.new('Frame');
		boxinner.BackgroundColor3 = color.Dark(uipallet.Main, 0.02);
		boxinner.Position = UDim2.fromOffset(1, 1);
		boxinner.Size = UDim2.new(1, -2, 1, -2);
		boxinner.Parent = boxholder;
		addCorner(boxinner);
		local textbox: TextBox = Instance.new('TextBox');
		textbox.BackgroundTransparency = 1;
		textbox.ClearTextOnFocus = false;
		textbox.FontFace = uipallet.Font;
		textbox.PlaceholderText = props.Placeholder or 'Add entry...';
		textbox.PlaceholderColor3 = Color3.new(0.8, 0.8, 0.8);
		textbox.Position = UDim2.fromOffset(10, 0);
		textbox.Size = UDim2.new(1, -35, 1, 0);
		textbox.Text = '';
		textbox.TextColor3 = Color3.new(1, 1, 1);
		textbox.TextSize = 13;
		textbox.TextXAlignment = Enum.TextXAlignment.Left;
		textbox.Parent = boxholder;
		local autocomplete: TextLabel;
		if props.Player then
			textbox.ZIndex = 2;
			autocomplete = Instance.new('TextLabel');
			autocomplete.BackgroundTransparency = 1;
			autocomplete.FontFace = uipallet.Font;
			autocomplete.Position = UDim2.fromOffset(10, 0);
			autocomplete.Size = UDim2.new(1, -35, 1, 0);
			autocomplete.Text = '';
			autocomplete.TextColor3 = Color3.new(0.6, 0.6, 0.6);
			autocomplete.TextSize = 13;
			autocomplete.TextXAlignment = Enum.TextXAlignment.Left;
			autocomplete.Parent = boxholder;
		end;
		local add: ImageButton = Instance.new('ImageButton');
		add.BackgroundTransparency = 1;
		add.Image = getvapeasset('velo/assets/new/add.png');
		add.ImageColor3 = props.Color;
		add.ImageTransparency = 0.3;
		add.Position = UDim2.new(1, -26, 0, 8);
		add.Size = UDim2.fromOffset(16, 16);
		add.Parent = boxholder;
		props.Function = props.Function or function(): () end;
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			if textlistwindow.Visible then
				holder.BackgroundColor3 = isRainbow and vape:SampleColor(self.Index * 0.075) or Color3.fromHSV(hue, sat, val);
			end;
		end;
		
		component.ChangeValue = function(self: table, value: string?): ()
			if value then
				local index: number? = table.find(self.List, value);
				if index then
					table.remove(self.List, index);
		
					index = table.find(self.ListEnabled, value);
					if index then
						table.remove(self.ListEnabled, index);
					end;
				else
					table.insert(self.List, value);
					table.insert(self.ListEnabled, value);
				end;
			end;
		
			props.Function(self.List);
			for _: any, v: any in self.Objects do
				v:Destroy();
			end;
			table.clear(self.Objects);
			textlistwindow.Size = UDim2.fromOffset(220, 85 + (#self.List * 35));
			amount.Text = #self.List;
			items.Text = #self.ListEnabled > 0 and table.concat(self.ListEnabled, ', ') or 'None';
		
			for index: any, value: any in self.List do
				local isEnabled: number? = table.find(self.ListEnabled, value);
				local obj: TextButton = Instance.new('TextButton');
				obj.AutoButtonColor = false;
				obj.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
				obj.Position = UDim2.fromOffset(10, 47 + (index * 35));
				obj.Size = UDim2.fromOffset(200, 31);
				obj.Text = '';
				obj.Parent = textlistwindow;
				addCorner(obj);
				local bkg: Frame = Instance.new('Frame');
				bkg.BackgroundColor3 = uipallet.Main;
				bkg.Position = UDim2.fromOffset(1, 1);
				bkg.Size = UDim2.new(1, -2, 1, -2);
				bkg.Visible = false;
				bkg.Parent = obj;
				addCorner(bkg);
				local dot: Frame = Instance.new('Frame');
				dot.BackgroundColor3 = isEnabled and props.Color or color.Light(uipallet.Main, 0.37);
				dot.Position = UDim2.fromOffset(10, 12);
				dot.Size = UDim2.fromOffset(10, 11);
				dot.Parent = obj;
				addCorner(dot, UDim.new(1, 0));
				local dotin: Frame = dot:Clone();
				dotin.BackgroundColor3 = isEnabled and props.Color or color.Light(uipallet.Main, 0.02);
				dotin.Position = UDim2.fromOffset(1, 1);
				dotin.Size = UDim2.fromOffset(8, 9);
				dotin.Parent = dot;
				local label: TextLabel = Instance.new('TextLabel');
				label.BackgroundTransparency = 1;
				label.FontFace = uipallet.Font;
				label.Position = UDim2.fromOffset(30, 0);
				label.Size = UDim2.new(1, -30, 1, 0);
				label.Text = value;
				label.TextColor3 = color.Dark(uipallet.Text, 0.16);
				label.TextSize = 15;
				label.TextXAlignment = Enum.TextXAlignment.Left;
				label.Parent = obj;
				local close: ImageButton = Instance.new('ImageButton');
				close.AutoButtonColor = false;
				close.BackgroundColor3 = Color3.new(1, 1, 1);
				close.BackgroundTransparency = 1;
				close.Image = getvapeasset('velo/assets/new/closetiny.png');
				close.ImageColor3 = color.Light(uipallet.Text, 0.2);
				close.ImageTransparency = 0.5;
				close.Position = UDim2.new(1, -27, 0, 8);
				close.Size = UDim2.fromOffset(18, 17);
				close.Parent = obj;
				addCorner(close, UDim.new(1, 0));
		
				close.MouseEnter:Connect(function(): ()
					close.ImageTransparency = 0.3;
					tween:Tween(close, uipallet.Tween, {
						["BackgroundTransparency"] = 0.6
					});
				end);
		
				close.MouseLeave:Connect(function(): ()
					close.ImageTransparency = 0.5;
					tween:Tween(close, uipallet.Tween, {
						["BackgroundTransparency"] = 1
					});
				end);
		
				close.MouseButton1Click:Connect(function(): ()
					self:ChangeValue(value);
				end);
		
				obj.MouseEnter:Connect(function(): ()
					bkg.Visible = true;
				end);
		
				obj.MouseLeave:Connect(function(): ()
					bkg.Visible = false;
				end);
		
				obj.MouseButton1Click:Connect(function(): ()
					local index: number? = table.find(self.ListEnabled, value);
					if index then
						table.remove(self.ListEnabled, index);
						dot.BackgroundColor3 = color.Light(uipallet.Main, 0.37);
						dotin.BackgroundColor3 = color.Light(uipallet.Main, 0.02);
					else
						table.insert(self.ListEnabled, value);
						dot.BackgroundColor3 = props.Color;
						dotin.BackgroundColor3 = props.Color;
					end;
		
					items.Text = #self.ListEnabled > 0 and table.concat(self.ListEnabled, ', ') or 'None';
					props.Function(self.List);
				end);
		
				table.insert(self.Objects, obj);
			end;
		end;
		
		component.Load = function(self: table, data: table): ()
			self.List = data.List or {};
			self.ListEnabled = data.ListEnabled or {};
			self:ChangeValue();
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["List"] = self.List,
				["ListEnabled"] = self.ListEnabled
			};
		end;
		
		add.MouseEnter:Connect(function(): ()
			add.ImageTransparency = 0;
		end);
		
		add.MouseLeave:Connect(function(): ()
			add.ImageTransparency = 0.3;
		end);
		
		add.MouseButton1Click:Connect(function(): ()
			local newText: any = props.TextFunction and props.TextFunction(textbox.Text) or textbox.Text;
			if not table.find(component.List, newText) then
				component:ChangeValue(newText);
				textbox.Text = '';
			end;
		end);
		
		if autocomplete then
			textbox:GetPropertyChangedSignal('Text'):Connect(function(): ()
				local plr: any = getPlayerFromText(textbox.Text);
				autocomplete.Text = plr and textbox.Text..(plr:sub(#textbox.Text + 1, #plr)) or '';
			end);
		
			textbox.Focused:Connect(function(): ()
				vape.Autocomplete = function(): ()
					local newText: any = getPlayerFromText(textbox.Text) or textbox.Text;
					task.spawn(function(): ()
						textbox:GetPropertyChangedSignal('Text'):Wait();
						textbox.Text = newText;
						textbox.CursorPosition = #newText + 1;
					end);
				end;
			end);
		end;
		
		textbox.FocusLost:Connect(function(enter: boolean): ()
			local newText: any = props.TextFunction and props.TextFunction(textbox.Text) or textbox.Text;
			if enter and not table.find(component.List, newText) then
				component:ChangeValue(newText);
				textbox.Text = '';
			end;
		
			vape.Autocomplete = nil;
		end);
		
		textbox.MouseEnter:Connect(function(): ()
			tween:Tween(boxholder, uipallet.Tween, {
				["BackgroundColor3"] = color.Light(uipallet.Main, 0.14)
			});
		end);
		
		textbox.MouseLeave:Connect(function(): ()
			tween:Tween(boxholder, uipallet.Tween, {
				["BackgroundColor3"] = color.Light(uipallet.Main, 0.02)
			});
		end);
		
		close.MouseButton1Click:Connect(function(): ()
			textlistwindow.Visible = false;
		end);
		
		button.MouseButton1Click:Connect(function(): ()
			textlistwindow.Visible = not textlistwindow.Visible;
		
			tween:Cancel(holder);
			holder.BackgroundColor3 = textlistwindow.Visible and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or color.Light(uipallet.Main, 0.37);
		end);
		
		textlist.MouseEnter:Connect(function(): ()
			if not textlistwindow.Visible then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = color.Light(uipallet.Main, 0.37)
				});
			end;
		end);
		
		textlist.MouseLeave:Connect(function(): ()
			if not textlistwindow.Visible then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = color.Light(uipallet.Main, 0.034)
				});
			end;
		end);
		
		textlist:GetPropertyChangedSignal('AbsolutePosition'):Connect(function(): ()
			if vape.ThreadFix then
				setthreadidentity(8);
			end;
		
			local actualPosition: any = (textlist.AbsolutePosition - (api.Legit and vape.Legit.Window.AbsolutePosition or -guiService:GetGuiInset())) / scale.Scale;
			textlistwindow.Position = UDim2.fromOffset(actualPosition.X + 223, actualPosition.Y);
		end);
		
		if props.Default then
			component:ChangeValue();
		end;
		
		api.Options[props.Name] = component;
		
		return component;
	end,
	["Toggle"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Enabled"] = false,
			["Index"] = getTableSize(api.Options),
			["Name"] = props.Name,
			["Type"] = 'Toggle'
		};
		
		local isHover: boolean = false;
		local toggle: TextButton = Instance.new('TextButton');
		toggle.AutoButtonColor = false;
		toggle.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		toggle.BorderSizePixel = 0;
		toggle.FontFace = uipallet.Font;
		toggle.Size = UDim2.new(1, 0, 0, 30);
		toggle.RichText = true;
		toggle.Text = indent(10)..richEscape(props.Name);
		toggle.TextColor3 = color.Dark(uipallet.Text, 0.16);
		toggle.TextSize = 14;
		toggle.TextXAlignment = Enum.TextXAlignment.Left;
		toggle.Visible = props.Visible == nil or props.Visible;
		toggle.Parent = children;
		component.Object = toggle;
		addTooltip(toggle, props.Tooltip);
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.14);
		holder.Name = 'Holder';
		holder.Position = UDim2.new(1, -30, 0, 9);
		holder.Size = UDim2.fromOffset(22, 12);
		holder.Parent = toggle;
		addCorner(holder, UDim.new(1, 0));
		local knob: Frame = Instance.new('Frame');
		knob.BackgroundColor3 = uipallet.Main;
		knob.Position = UDim2.fromOffset(2, 2);
		knob.Size = UDim2.fromOffset(8, 8);
		knob.Parent = holder;
		addCorner(knob, UDim.new(1, 0));
		props.Function = props.Function or function(): () end;
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			if self.Enabled then
				tween:Cancel(holder);
				holder.BackgroundColor3 = isRainbow and vape:SampleColor(self.Index * 0.075) or Color3.fromHSV(hue, sat, val);
			end;
		end;
		
		component.Load = function(self: table, data: table): ()
			if self.Enabled ~= data.Enabled then
				self:Toggle();
			end;
		
			if self.Bind and data.Bind then
				self.Bind:Load(data.Bind);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["Enabled"] = self.Enabled
			};
		
			if self.Bind then
				self.Bind:Save(data[props.Name]);
			end;
		end;
		
		component.Toggle = function(self: table): ()
			local isRainbow: any = vape.GUIColor.Rainbow and vape.RainbowMode.Value ~= 'Retro';
			self.Enabled = not self.Enabled;
		
			tween:Tween(holder, uipallet.Tween, {
				["BackgroundColor3"] = self.Enabled and (isRainbow and vape:SampleColor(self.Index * 0.075) or Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)) or (isHover and color.Light(uipallet.Main, 0.37) or color.Light(uipallet.Main, 0.14))
			});
		
			tween:Tween(knob, uipallet.Tween, {
				["Position"] = UDim2.fromOffset(self.Enabled and 12 or 2, 2)
			});
		
			props.Function(self.Enabled);
		end;
		
		toggle.MouseEnter:Connect(function(): ()
			isHover = true;
		
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = color.Light(uipallet.Main, 0.37)
				});
			end;
		end);
		
		toggle.MouseLeave:Connect(function(): ()
			isHover = false;
		
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					["BackgroundColor3"] = color.Light(uipallet.Main, 0.14)
				});
			end;
		end);
		
		toggle.MouseButton1Click:Connect(function(): ()
			component:Toggle();
		end);
		
		if props.Default then
			component:Toggle();
		end;
		
		api.Options[props.Name] = component;
		
		return component;
	end,
	["TwoSlider"] = function(props: table, children: GuiObject, api: table): table
		local component: table = {
			["Index"] = getTableSize(api.Options),
			["Max"] = props.Max,
			["Type"] = 'TwoSlider',
			["ValueMin"] = props.DefaultMin or props.Min,
			["ValueMax"] = props.DefaultMax or 10
		};
		
		local twoslider: TextButton = Instance.new('TextButton');
		twoslider.AutoButtonColor = false;
		twoslider.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0);
		twoslider.BorderSizePixel = 0;
		twoslider.Size = UDim2.new(1, 0, 0, 50);
		twoslider.Text = '';
		twoslider.Visible = props.Visible == nil or props.Visible;
		twoslider.Parent = children;
		component.Object = twoslider;
		addTooltip(twoslider, props.Tooltip);
		local title: TextLabel = Instance.new('TextLabel');
		title.BackgroundTransparency = 1;
		title.FontFace = uipallet.Font;
		title.Position = UDim2.fromOffset(10, 2);
		title.Size = UDim2.fromOffset(60, 30);
		title.Text = props.Name;
		title.TextColor3 = color.Dark(uipallet.Text, 0.16);
		title.TextSize = 11;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = twoslider;
		local maxvalue: TextButton = Instance.new('TextButton');
		maxvalue.BackgroundTransparency = 1;
		maxvalue.FontFace = uipallet.Font;
		maxvalue.Position = UDim2.new(1, -69, 0, 9);
		maxvalue.Size = UDim2.fromOffset(60, 15);
		maxvalue.Text = component.ValueMax;
		maxvalue.TextColor3 = color.Dark(uipallet.Text, 0.16);
		maxvalue.TextSize = 11;
		maxvalue.TextXAlignment = Enum.TextXAlignment.Right;
		maxvalue.Parent = twoslider;
		local minvalue: TextButton = maxvalue:Clone();
		minvalue.Position = UDim2.new(1, -125, 0, 9);
		minvalue.Text = component.ValueMin;
		minvalue.Parent = twoslider;
		local custommax: TextBox = Instance.new('TextBox');
		custommax.BackgroundTransparency = 1;
		custommax.ClearTextOnFocus = false;
		custommax.FontFace = uipallet.Font;
		custommax.Position = maxvalue.Position;
		custommax.Size = UDim2.fromOffset(60, 15);
		custommax.Text = component.ValueMax;
		custommax.TextColor3 = color.Dark(uipallet.Text, 0.16);
		custommax.TextSize = 11;
		custommax.TextXAlignment = Enum.TextXAlignment.Right;
		custommax.Visible = false;
		custommax.Parent = twoslider;
		local custommin: TextBox = custommax:Clone();
		custommin.Position = minvalue.Position;
		custommin.Parent = twoslider;
		local holder: Frame = Instance.new('Frame');
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034);
		holder.BorderSizePixel = 0;
		holder.Position = UDim2.fromOffset(10, 37);
		holder.Size = UDim2.new(1, -20, 0, 2);
		holder.Parent = twoslider;
		local fill: Frame = Instance.new('Frame');
		fill.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value);
		fill.BorderSizePixel = 0;
		fill.Position = UDim2.fromScale(math.clamp((component.ValueMin - props.Min) / (props.Max - props.Min), 0.04, 0.96), 0);
		fill.Size = UDim2.fromScale(math.clamp(math.clamp((component.ValueMax - props.Min) / (props.Max - props.Min), 0, 1), 0.04, 0.96) - fill.Position.X.Scale, 1);
		fill.Parent = holder;
		local knob: Frame = Instance.new('Frame');
		knob.AnchorPoint = Vector2.new(0.5, 0.5);
		knob.BackgroundColor3 = twoslider.BackgroundColor3;
		knob.BorderSizePixel = 0;
		knob.Position = UDim2.fromScale(0, 0.5);
		knob.Size = UDim2.fromOffset(16, 4);
		knob.Parent = fill;
		local knobknob: ImageLabel = Instance.new('ImageLabel');
		knobknob.AnchorPoint = Vector2.new(0.5, 0.5);
		knobknob.BackgroundTransparency = 1;
		knobknob.Image = getvapeasset('velo/assets/new/range.png');
		knobknob.ImageColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value);
		knobknob.Position = UDim2.fromScale(0.5, 0.5);
		knobknob.Size = UDim2.fromOffset(9, 16);
		knobknob.Parent = knob;
		local knobmax: Frame = knob:Clone();
		knobmax.Position = UDim2.fromScale(1, 0.5);
		knobmax.Parent = fill;
		local knobmaxknob: any = knobmax.ImageLabel;
		knobmaxknob.Rotation = 180;
		local arrow: ImageLabel = Instance.new('ImageLabel');
		arrow.BackgroundTransparency = 1;
		arrow.Image = getvapeasset('velo/assets/new/rangeindicator.png');
		arrow.ImageColor3 = color.Light(uipallet.Main, 0.14);
		arrow.Position = UDim2.new(1, -56, 0, 10);
		arrow.Size = UDim2.fromOffset(12, 6);
		arrow.Parent = twoslider;
		props.Function = props.Function or function(): () end;
		props.Decimal = props.Decimal or 1;
		local random: Random = Random.new();
		
		component.Color = function(self: table, hue: number, sat: number, val: number, isRainbow: boolean): ()
			fill.BackgroundColor3 = isRainbow and vape:SampleColor(self.Index * 0.075) or Color3.fromHSV(hue, sat, val);
			knobknob.ImageColor3 = fill.BackgroundColor3;
			knobmaxknob.ImageColor3 = fill.BackgroundColor3;
		end;
		
		component.GetRandomValue = function(self: table): ...any
			return random:NextNumber(component.ValueMin, component.ValueMax);
		end;
		
		component.Load = function(self: table, data: table): ()
			if self.ValueMin ~= data.ValueMin then
				self:SetValue(false, data.ValueMin);
			end;
		
			if self.ValueMax ~= data.ValueMax then
				self:SetValue(true, data.ValueMax);
			end;
		end;
		
		component.Save = function(self: table, data: table): ()
			data[props.Name] = {
				["ValueMin"] = self.ValueMin,
				["ValueMax"] = self.ValueMax
			};
		end;
		
		component.SetValue = function(self: table, isMax: boolean, value: number): ()
			if not math.isfinite(value) then
				return;
			end;
		
			self[isMax and 'ValueMax' or 'ValueMin'] = value;
			maxvalue.Text = self.ValueMax;
			minvalue.Text = self.ValueMin;
		
			local size: number = math.clamp(math.clamp((self.ValueMin - props.Min) / (props.Max - props.Min), 0, 1), 0.04, 0.96);
			tween:Tween(fill, TweenInfo.new(0.1), {
				["Position"] = UDim2.fromScale(size, 0),
				["Size"] = UDim2.fromScale(math.clamp(math.clamp((self.ValueMax - props.Min) / (props.Max - props.Min), 0.04, 0.96) - size, 0, 1), 1)
			});
		end;
		
		knob.MouseEnter:Connect(function(): ()
			tween:Tween(knobknob, uipallet.Tween, {
				["Size"] = UDim2.fromOffset(11, 18)
			});
		end);
		
		knob.MouseLeave:Connect(function(): ()
			tween:Tween(knobknob, uipallet.Tween, {
				["Size"] = UDim2.fromOffset(9, 16)
			});
		end);
		
		knobmax.MouseEnter:Connect(function(): ()
			tween:Tween(knobmaxknob, uipallet.Tween, {
				["Size"] = UDim2.fromOffset(11, 18)
			});
		end);
		
		knobmax.MouseLeave:Connect(function(): ()
			tween:Tween(knobmaxknob, uipallet.Tween, {
				["Size"] = UDim2.fromOffset(9, 16)
			});
		end);
		
		twoslider.InputBegan:Connect(function(input: InputObject): ()
			if
				(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (input.Position.Y - twoslider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				local maxCheck: boolean = (input.Position.X - knobmax.AbsolutePosition.X) > -10;
				local newPosition: number = math.clamp((input.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1);
		
				local releaseConnection: RBXScriptConnection;
				local moveConnection: RBXScriptConnection = inputService.InputChanged:Connect(function(newInput: InputObject): ()
					if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						local newPosition: number = math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1);
						component:SetValue(maxCheck, math.floor((props.Min + (props.Max - props.Min) * newPosition) * props.Decimal) / props.Decimal, newPosition);
					end;
				end);
		
				releaseConnection = input.Changed:Connect(function(): ()
					if input.UserInputState == Enum.UserInputState.End then
						moveConnection:Disconnect();
						releaseConnection:Disconnect();
					end;
				end);
		
				component:SetValue(maxCheck, math.floor((props.Min + (props.Max - props.Min) * newPosition) * props.Decimal) / props.Decimal, newPosition);
			end;
		end);
		
		maxvalue.MouseButton1Click:Connect(function(): ()
			maxvalue.Visible = false;
			custommax.Visible = true;
			custommax.Text = component.ValueMax;
			custommax:CaptureFocus();
		end);
		
		minvalue.MouseButton1Click:Connect(function(): ()
			minvalue.Visible = false;
			custommin.Visible = true;
			custommin.Text = component.ValueMin;
			custommin:CaptureFocus();
		end);
		
		custommax.FocusLost:Connect(function(enter: boolean): ()
			maxvalue.Visible = true;
			custommax.Visible = false;
		
			if enter and tonumber(custommax.Text) then
				component:SetValue(true, tonumber(custommax.Text));
			end;
		end);
		
		custommin.FocusLost:Connect(function(enter: boolean): ()
			minvalue.Visible = true;
			custommin.Visible = false;
		
			if enter and tonumber(custommin.Text) then
				component:SetValue(false, tonumber(custommin.Text));
			end;
		end);
		
		api.Options[props.Name] = component;
		
		return component;
	end,
};

vape.Components = setmetatable(components, {
	["__newindex"] = function(_: any, index: any, callback: any): ()
		for _: any, module: any in vape.Modules do
			rawset(module, 'Create'..index, function(_: any, props: table): ...any
				return callback(props, module.Children, module);
			end);
		end;

		if vape.Legit then
			for _: any, module: any in vape.Legit.Modules do
				rawset(module, 'Create'..index, function(_: any, props: table): ...any
					return callback(props, module.Children, module);
				end);
			end;
		end;

		rawset(components, index, callback);
	end
});

vape:LoadGUI();

return vape;
