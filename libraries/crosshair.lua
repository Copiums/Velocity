--!nonstrict
--// Custom Crosshair - renderer
--
-- Standalone. Host this file and point the vape module's CROSSHAIR_URL at it.
-- Returns the API table and registers itself at getgenv().CROSSHAIR.
--
-- nonstrict rather than strict on purpose: executor globals (Drawing,
-- getgenv, gethui, syn, cleardrawcache) are not in Luau's type definitions,
-- so strict flags every one of them as an unknown global.

export type DrawingLine = {
        Visible: boolean,
        ZIndex: number,
        Transparency: number,
        Color: Color3,
        Thickness: number,
        From: Vector2,
        To: Vector2,
        Remove: (self: DrawingLine) -> (),
};

export type GlowLabel = {
        Label: TextLabel,
        Stroke: UIStroke,
};

export type TextSettings = {
        Enabled: boolean,
        Content: string,
        Font: string,    -- Enum.Font name, used only when FontFace is nil
        FontFace: Font?, -- a Font object, what vape's CreateFont gives you. Wins if set.
        Size: number,
        Offset: number,
        Color: Color3,
        Transparency: number,

        Outline: boolean,
        OutlineThickness: number,
        OutlineColor: Color3,
        OutlineTransparency: number,

        Glow: boolean,
        GlowSpread: number,
        GlowLayers: number,
        GlowIntensity: number,
        GlowFalloff: number,
        GlowColor: Color3,
};

export type CrosshairSettings = {
        Enabled: boolean,

        Radius: number,
        Length: number,
        Thickness: number,
        FillColor: Color3,
        FillTransparency: number,

        Outline: boolean,
        OutlineWidth: number,
        OutlineColor: Color3,
        OutlineTransparency: number,

        Glow: boolean,
        GlowSpread: number,
        GlowLayers: number,
        GlowIntensity: number,
        GlowFalloff: number,
        GlowColor: Color3,

        Rotate: boolean,
        RotationSpeed: number,
        RotationDirection: number,

        Pulse: boolean,
        PulseAmount: number,
        PulseSpeed: number,

        Text: TextSettings,

        YOffset: number,
};

export type CrosshairAPI = {
        Settings: CrosshairSettings,
        Refresh: () -> (),

        Toggle: (state: boolean?) -> (),
        SetGlow: (state: boolean?) -> (),
        SetGlowStrength: (intensity: number?, spread: number?, falloffCurve: number?) -> (),
        SetOutline: (state: boolean?) -> (),
        SetThickness: (n: number) -> (),
        SetSize: (radius: number?, length: number?) -> (),

        SetRotation: (state: boolean?) -> (),
        SetRotationSpeed: (n: number) -> (),
        SetRotationDirection: (dir: number | string) -> (),
        FlipRotation: () -> (),

        SetText: (content: string?) -> (),
        SetTextEnabled: (state: boolean?) -> (),
        SetFont: (fontName: string) -> (),
        SetFontFace: (face: Font?) -> (),
        SetTextSize: (n: number) -> (),
        SetTextOffset: (n: number) -> (),
        SetTextOutline: (thickness: number?, color: Color3?) -> (),
        SetTextGlow: (state: boolean?) -> (),
        SetTextGlowStrength: (intensity: number?, spread: number?, falloffCurve: number?) -> (),
        SetPulse: (state: boolean?, amount: number?) -> (),

        Destroy: () -> (),
};


--=========================================================
--  SERVICES
--=========================================================
local cloneref: (obj: any) -> any = cloneref or function(obj)
    	return obj;
end;

local UIS: UserInputService = cloneref(game:GetService("UserInputService"));
local RunService: RunService = cloneref(game:GetService("RunService"));
local Players: Players = cloneref(game:GetService("Players"));
local MAX_LAYERS: number = 16;
local GUI_NAME: string = "Crosshair_Gui";
local ENV_KEY: string = "CROSSHAIR";

local ENV: { [string]: any } = _G;
pcall(function(): ()
        if typeof(getgenv) == "function" then
                ENV = getgenv();
        end;
end);

local previous: any = ENV[ENV_KEY];
if type(previous) == "table" and type(previous.Destroy) == "function" then
        pcall(previous.Destroy);
end;
ENV[ENV_KEY] = nil;

pcall(function(): ()
        local roots: { Instance } = {};

        if typeof(gethui) == "function" then
                table.insert(roots, gethui());
        end;
        table.insert(roots, game:GetService("CoreGui"));

        local lplr: Player? = Players.LocalPlayer;
        if lplr and lplr:FindFirstChild("PlayerGui") then
                table.insert(roots, lplr.PlayerGui);
        end;

        for _: number, root: Instance in roots do
                for _: number, child: Instance in root:GetChildren() do
                        if child.Name == GUI_NAME then
                                child:Destroy();
                        end;
                end;
        end;
end);

local HARD_RESET: boolean = false;
if HARD_RESET then
        pcall(function(): ()
                if typeof(cleardrawcache) == "function" then
                        cleardrawcache();
                end;
        end);
end;

pcall(function(): ()
        UIS.MouseIconEnabled = false;
end);

--=========================================================
--  SETTINGS
--=========================================================
local Settings: CrosshairSettings = {
        Enabled = true,

        -- shape
        Radius = 15,
        Length = 5,
        Thickness = 1,
        FillColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 1, -- Drawing convention: 1 = opaque, 0 = invisible

        -- outline
        Outline = true,
        OutlineWidth = 0, -- border thickness PER SIDE
        OutlineColor = Color3.fromRGB(240, 240, 240),
        OutlineTransparency = 1,

        -- glow (stacked layers with falloff, not a single band)
        Glow = true,
        GlowSpread = 7,
        GlowLayers = 5,
        GlowIntensity = 0.35,
        GlowFalloff = 2.2,
        GlowColor = Color3.fromRGB(255, 255, 255),

        -- rotation
        Rotate = true,
        RotationSpeed = 180,
        RotationDirection = 1, -- 1 = clockwise, -1 = counter-clockwise

        -- pulse
        Pulse = true,
        PulseAmount = 2.5,
        PulseSpeed = 8,

        -- text
        Text = {
                Enabled = true,
                Content = "veloc",
                Font = "GothamBold", -- see FONTS list at the bottom of this file
                FontFace = nil,      -- set to a Font object to override Font
                Size = 12,
                Offset = 7, -- gap in px between the crosshair's outer tip and the text
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = 0, -- 0 = solid (Roblox convention, opposite of Drawing)

                Outline = false,
                OutlineThickness = 2,
                OutlineColor = Color3.fromRGB(240, 240, 240),
                OutlineTransparency = 0,

                Glow = true,
                GlowSpread = 4, -- how far the halo bleeds off the glyphs
                GlowLayers = 4,
                GlowIntensity = 0.4,
                GlowFalloff = 2.0,
                GlowColor = Color3.fromRGB(255, 255, 255),
        },

        -- Vertical nudge for BOTH crosshair and text. Leave at 0 unless the
        -- whole thing drifts off the cursor together.
        YOffset = 0,
};

--=========================================================
--  BUILD  -  crosshair (Drawing)
--=========================================================
local newLine: (zindex: number) -> DrawingLine = function(zindex: number): DrawingLine
        local l: DrawingLine = Drawing.new("Line") :: DrawingLine;
        l.Thickness = 1;
        l.Transparency = 1;
        l.ZIndex = zindex;
        l.Visible = false;
        return l;
end;

local Glows: { { DrawingLine } } = {};
local Outlines: { DrawingLine } = {};
local Fills: { DrawingLine } = {};

for layer: number = 1, MAX_LAYERS do
        local set: { DrawingLine } = {};
        for i: number = 1, 4 do
                set[i] = newLine(MAX_LAYERS - layer + 1);
        end;
        Glows[layer] = set;
end;
for i: number = 1, 4 do
        Outlines[i] = newLine(MAX_LAYERS + 1);
end;
for i: number = 1, 4 do
        Fills[i] = newLine(MAX_LAYERS + 2);
end;

local parentGui: Instance? = nil;
pcall(function(): ()
        parentGui = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui");
end);
if not parentGui then
        parentGui = Players.LocalPlayer:WaitForChild("PlayerGui");
end;

local Screen: ScreenGui = Instance.new("ScreenGui");
Screen.Name = GUI_NAME;
Screen.IgnoreGuiInset = true; 
Screen.ResetOnSpawn = false;
Screen.DisplayOrder = 2147483647;
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
pcall(function(): ()
        if syn and syn.protect_gui then
                syn.protect_gui(Screen);
        end;
end);
Screen.Parent = parentGui;

local newLabel: (zindex: number) -> (TextLabel, UIStroke) = function(zindex: number): (TextLabel, UIStroke)
        local lbl: TextLabel = Instance.new("TextLabel");
        lbl.AnchorPoint = Vector2.new(0.5, 0);
        lbl.BackgroundTransparency = 1;
        lbl.AutomaticSize = Enum.AutomaticSize.XY; 
        lbl.Size = UDim2.fromOffset(0, 0);
        lbl.TextXAlignment = Enum.TextXAlignment.Center;
        lbl.TextYAlignment = Enum.TextYAlignment.Top;
        lbl.ZIndex = zindex;
        lbl.Visible = false;
        lbl.Parent = Screen;

        local stroke: UIStroke = Instance.new("UIStroke");
        stroke.LineJoinMode = Enum.LineJoinMode.Round;
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
        stroke.Parent = lbl;

        return lbl, stroke;
end;

local TextGlows: { GlowLabel } = {};
for layer: number = 1, MAX_LAYERS do
        local lbl: TextLabel, stroke: UIStroke = newLabel(MAX_LAYERS - layer + 1);
        TextGlows[layer] = { Label = lbl, Stroke = stroke };
end;

local Label: TextLabel, Stroke: UIStroke = newLabel(MAX_LAYERS + 1);

local fillHalf: number = 0;
local outlineHalf: number = 0;
local outerTip: number = 0;
local glowHalf: { number } = {};

local falloff: (layer: number, count: number, intensity: number, curve: number) -> number = function(layer: number, count: number, intensity: number, curve: number): number
        local frac: number = layer / count;
        return math.clamp(intensity * (1 - frac + (1 / count)) ^ curve, 0, 1);
end;

local Apply: () -> () = function(): ()
        local t: number = Settings.Thickness;
        local outlineT: number = t + Settings.OutlineWidth * 2;

        fillHalf = Settings.Length / 2;
        outlineHalf = fillHalf + Settings.OutlineWidth;
        outerTip = Settings.Radius + fillHalf + Settings.OutlineWidth;
        if Settings.Glow then
                outerTip += Settings.GlowSpread;
        end;
        for i: number = 1, 4 do
                local fill: DrawingLine = Fills[i];
                fill.Thickness = t;
                fill.Color = Settings.FillColor;
                fill.Transparency = Settings.FillTransparency;
                fill.Visible = Settings.Enabled;

                local outline: DrawingLine = Outlines[i];
                outline.Thickness = outlineT;
                outline.Color = Settings.OutlineColor;
                outline.Transparency = Settings.OutlineTransparency;
                outline.Visible = Settings.Enabled and Settings.Outline;
        end;
        local n: number = math.clamp(Settings.GlowLayers, 1, MAX_LAYERS);
        for layer: number = 1, MAX_LAYERS do
                local active: boolean = Settings.Enabled and Settings.Glow and layer <= n;
                local spread: number = Settings.GlowSpread * (layer / n);
                glowHalf[layer] = outlineHalf + spread;
                for i: number = 1, 4 do
                        local g: DrawingLine = Glows[layer][i];
                        g.Visible = active;
                        if active then
                                g.Thickness = outlineT + spread * 2;
                                g.Color = Settings.GlowColor;
                                g.Transparency = falloff(layer, n, Settings.GlowIntensity, Settings.GlowFalloff);
                        end;
                end;
        end;
        local T: TextSettings = Settings.Text;
        local face: Font? = if typeof(T.FontFace) == "Font" then T.FontFace else nil;
        local font: Enum.Font = Enum.Font.GothamBold;
        if not face then
                local ok: boolean, resolved: any = pcall(function(): any
                        return (Enum.Font :: any)[T.Font];
                end);
                if ok and resolved then
                        font = resolved :: Enum.Font;
                else
                        warn("[Crosshair] unknown font: " .. tostring(T.Font) .. " - using GothamBold");
                end;
        end;
        local applyFont: (lbl: TextLabel) -> () = function(lbl: TextLabel): ()
                if face then
                        lbl.FontFace = face;
                else
                        lbl.Font = font;
                end;
        end;
        Label.Text = T.Content;
        applyFont(Label);
        Label.TextSize = T.Size;
        Label.TextColor3 = T.Color;
        Label.TextTransparency = T.Transparency;
        Label.Visible = Settings.Enabled and T.Enabled;
        Stroke.Thickness = if T.Outline then T.OutlineThickness else 0;
        Stroke.Color = T.OutlineColor;
        Stroke.Transparency = T.OutlineTransparency;
        local tn: number = math.clamp(T.GlowLayers, 1, MAX_LAYERS);
        for layer: number = 1, MAX_LAYERS do
                local g: GlowLabel = TextGlows[layer];
                local active: boolean = Settings.Enabled and T.Enabled and T.Glow and layer <= tn;
                g.Label.Visible = active;

                if active then
                        local alpha: number = falloff(layer, tn, T.GlowIntensity, T.GlowFalloff);
                        local baseStroke: number = if T.Outline then T.OutlineThickness else 0;

                        g.Label.Text = T.Content;
                        applyFont(g.Label);
                        g.Label.TextSize = T.Size;
                        g.Label.TextColor3 = T.GlowColor;
                        g.Label.TextTransparency = 1 - alpha;
                        g.Stroke.Color = T.GlowColor;
                        g.Stroke.Thickness = baseStroke + T.GlowSpread * (layer / tn);
                        g.Stroke.Transparency = 1 - alpha;
                end;
        end;
end;

Apply();

local angle: number = 0;
local clock: number = 0;
local conn: RBXScriptConnection? = nil;

conn = RunService.RenderStepped:Connect(function(dt: number): ()
        if not Settings.Enabled then
                return;
        end;
        if Settings.Rotate then
                local dir: number = if Settings.RotationDirection >= 0 then 1 else -1;
                angle = (angle + Settings.RotationSpeed * dir * dt) % 360;
        end;
        clock += dt;
        local mouse: Vector2 = UIS:GetMouseLocation();
        local mx: number = mouse.X;
        local my: number = mouse.Y + Settings.YOffset;
        local radius: number = Settings.Radius;
        if Settings.Pulse then
                radius += math.sin(clock * Settings.PulseSpeed) * Settings.PulseAmount;
        end;
        local n: number = math.clamp(Settings.GlowLayers, 1, MAX_LAYERS);
        for i: number = 1, 4 do
                local base: number = math.rad(angle + 45 + ((i - 1) * 90));
                local dirX: number = math.cos(base);
                local dirY: number = math.sin(base);
                local cx: number = mx + dirX * radius;
                local cy: number = my + dirY * radius;
                if Settings.Glow then
                        for layer: number = 1, n do
                                local h: number = glowHalf[layer];
                                local g: DrawingLine = Glows[layer][i];
                                g.From = Vector2.new(cx - dirX * h, cy - dirY * h);
                                g.To = Vector2.new(cx + dirX * h, cy + dirY * h);
                        end;
                end;

                if Settings.Outline then
                        local o: DrawingLine = Outlines[i];
                        o.From = Vector2.new(cx - dirX * outlineHalf, cy - dirY * outlineHalf);
                        o.To = Vector2.new(cx + dirX * outlineHalf, cy + dirY * outlineHalf);
                end;

                local f: DrawingLine = Fills[i];
                f.From = Vector2.new(cx - dirX * fillHalf, cy - dirY * fillHalf);
                f.To = Vector2.new(cx + dirX * fillHalf, cy + dirY * fillHalf);
        end;
        local T: TextSettings = Settings.Text;
        if T.Enabled then
                local reach: number = outerTip + (radius - Settings.Radius);
                local pos: UDim2 = UDim2.fromOffset(mx, my + reach + T.Offset);
                Label.Position = pos;

                if T.Glow then
                        local tn: number = math.clamp(T.GlowLayers, 1, MAX_LAYERS);
                        for layer: number = 1, tn do
                                TextGlows[layer].Label.Position = pos;
                        end;
                end;
        end;
end);

--=========================================================
--  API
--=========================================================
local Crosshair = {} :: CrosshairAPI;
Crosshair.Settings = Settings;
Crosshair.Refresh = Apply;

Crosshair.Toggle = function(state: boolean?): ()
        local value: boolean = if state == nil then not Settings.Enabled else state :: boolean;
        Settings.Enabled = value;
        pcall(function(): ()
                UIS.MouseIconEnabled = not value;
        end);
        Apply();
end;

Crosshair.SetGlow = function(state: boolean?): ()
        Settings.Glow = if state == nil then not Settings.Glow else state :: boolean;
        Apply();
end;

Crosshair.SetGlowStrength = function(intensity: number?, spread: number?, falloffCurve: number?): ()
        Settings.GlowIntensity = intensity or Settings.GlowIntensity;
        Settings.GlowSpread = spread or Settings.GlowSpread;
        Settings.GlowFalloff = falloffCurve or Settings.GlowFalloff;
        Apply();
end;

Crosshair.SetOutline = function(state: boolean?): ()
        Settings.Outline = if state == nil then not Settings.Outline else state :: boolean;
        Apply();
end;

Crosshair.SetThickness = function(n: number): ()
        Settings.Thickness = math.max(1, n);
        Apply();
end;

Crosshair.SetSize = function(radius: number?, length: number?): ()
        Settings.Radius = radius or Settings.Radius;
        Settings.Length = length or Settings.Length;
        Apply();
end;

Crosshair.SetRotation = function(state: boolean?): ()
        Settings.Rotate = if state == nil then not Settings.Rotate else state :: boolean;
end;

Crosshair.SetRotationSpeed = function(n: number): ()
        Settings.RotationSpeed = n;
end;

Crosshair.SetRotationDirection = function(dir: number | string): ()
        local value: number;
        if dir == "cw" then
                value = 1;
        elseif dir == "ccw" then
                value = -1;
        else
                value = dir :: number;
        end;
        Settings.RotationDirection = if value >= 0 then 1 else -1;
end;

Crosshair.FlipRotation = function(): ()
        Settings.RotationDirection = -Settings.RotationDirection;
end;

Crosshair.SetText = function(content: string?): ()
        Settings.Text.Content = content or "";
        Settings.Text.Enabled = (content ~= nil and content ~= "");
        Apply();
end;

Crosshair.SetTextEnabled = function(state: boolean?): ()
        Settings.Text.Enabled = if state == nil then not Settings.Text.Enabled else state :: boolean;
        Apply();
end;

Crosshair.SetFont = function(fontName: string): ()
        Settings.Text.Font = fontName;
        Settings.Text.FontFace = nil;
        Apply();
end;

-- Takes a Font object, e.g. what vape's CreateFont option gives you in .Value
Crosshair.SetFontFace = function(face: Font?): ()
        Settings.Text.FontFace = face;
        Apply();
end;

Crosshair.SetTextSize = function(n: number): ()
        Settings.Text.Size = n;
        Apply();
end;

Crosshair.SetTextOffset = function(n: number): ()
        Settings.Text.Offset = n;
end;

Crosshair.SetTextOutline = function(thickness: number?, color: Color3?): ()
        local T: TextSettings = Settings.Text;
        T.OutlineThickness = thickness or T.OutlineThickness;
        T.Outline = (T.OutlineThickness > 0);
        if color then
                T.OutlineColor = color;
        end;
        Apply();
end;

Crosshair.SetTextGlow = function(state: boolean?): ()
        Settings.Text.Glow = if state == nil then not Settings.Text.Glow else state :: boolean;
        Apply();
end;

Crosshair.SetTextGlowStrength = function(intensity: number?, spread: number?, falloffCurve: number?): ()
        local T: TextSettings = Settings.Text;
        T.GlowIntensity = intensity or T.GlowIntensity;
        T.GlowSpread = spread or T.GlowSpread;
        T.GlowFalloff = falloffCurve or T.GlowFalloff;
        Apply();
end;

Crosshair.SetPulse = function(state: boolean?, amount: number?): ()
        Settings.Pulse = if state == nil then not Settings.Pulse else state :: boolean;
        if amount then
                Settings.PulseAmount = amount;
        end;
end;

local destroyed: boolean = false;
Crosshair.Destroy = function(): ()
        if destroyed then
                return;
        end;
        destroyed = true;

        if conn then
                conn:Disconnect();
                conn = nil;
        end;

        for layer: number = 1, MAX_LAYERS do
                for _: number, l: DrawingLine in Glows[layer] do
                        pcall(function(): ()
                                l:Remove();
                        end);
                end;
        end;

        local sets: { { DrawingLine } } = { Outlines, Fills };
        for _: number, set: { DrawingLine } in sets do
                for _: number, l: DrawingLine in set do
                        pcall(function(): ()
                                l:Remove();
                        end);
                end;
        end;

        pcall(function(): ()
                Screen:Destroy();
        end);
        pcall(function(): ()
                UIS.MouseIconEnabled = true;
        end);

        if ENV[ENV_KEY] == Crosshair then
                ENV[ENV_KEY] = nil;
        end;
end;

--[[
     FONTS: pass any of these as a string to SetFont()

     Gotham family (clean, matches most cheat UIs):
       Gotham, GothamMedium, GothamBold, GothamBlack

     Source Sans (Roblox default family):
       SourceSans, SourceSansLight, SourceSansSemibold,
       SourceSansBold, SourceSansBlack, SourceSansItalic

     Neutral / UI:
       Arial, ArialBold, Roboto, RobotoCondensed, Ubuntu,
       Nunito, JosefinSans, TitilliumWeb, Jura, Merriweather

     Techy / gamer-looking:
       Code, RobotoMono, SciFi, Michroma, Sarpanch,
       DenkOne, Highway, Arcade

     Display / stylized:
       Bangers, LuckiestGuy, PermanentMarker, Creepster,
       IndieFlower, PatrickHand, Kalam, Cartoon, Fantasy,
       Antique, Bodoni, Garamond, Oswald, SpecialElite,
       Fondamento, GrenzeGotisch, Legacy

     Full list: Enum.Font on the Roblox docs. Anything valid
     there works here. An invalid name warns and falls back.

     The vape module uses SetFontFace / Settings.Text.FontFace instead,
     since CreateFont hands back a Font object rather than a name.
]]

-- hand ourselves to the next execution so it can clean us up
ENV[ENV_KEY] = Crosshair;

return Crosshair;
