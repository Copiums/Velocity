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
				- engineer - the goat
				- Jorsan - Dalgona
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

local vape: table = shared.veloc;
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

for _: any, v: string? in {'ScriptHub', 'ChatBypass', 'Invisible', 'Timer', 'MurderMystery', 'SilentAim'} do
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

velo.run(function()
        local AttributeSpoofer: table = {["Enabled"] = false}
        local Title: table = {["Enabled"] = false}
        local Won: table = {["Enabled"] = false}
        local WonAmount: table = {["Value"] = 999999999}
        local Glass: table = {["Enabled"] = false}
        local TitleVal: table = {["Value"] = "Rich Millionaire"}
        local Wins: table = {["Enabled"] = false}
        local WinsAmount: table = {["Value"] = 999}
        local Level: table = {["Enabled"] = false}
        local LevelAmount: table = {["Value"] = 999}
        local PlayerTag: table = {["Enabled"] = false}
        local PlayerTagVal = {["Value"] = ""}
        AttributeSpoofer = vape.Categories.Utility:CreateModule({
                ["Name"] = "AttributeSpoofer",
                ["Function"] = function(callback: boolean): void
                        if callback then
                                task.spawn(function()
                                        while AttributeSpoofer["Enabled"] do
                                                if Title["Enabled"] and lplr:GetAttribute("_CurrentTitle") ~= TitleVal["Value"] then
                                                        lplr:SetAttribute("_CurrentTitle", TitleVal["Value"]);
                                                end;
                                                if Level["Enabled"] then
                                                        lplr:SetAttribute("_CurrentLevel", LevelAmount["Value"]);
                                                end;
                                                if Won["Enabled"] then
                                                        lplr:SetAttribute("_Won", WonAmount["Value"]);
                                                end;
                                                if Wins["Enabled"] and lplr:GetAttribute("_GameWins") ~= WinsAmount["Value"] then
                                                        lplr:SetAttribute("_GameWins", WinsAmount["Value"]);
                                                end;
                                                if Glass["Enabled"] then
                                                        lplr:SetAttribute("DisableGlassManufacturerGP", false)
                                                end;
										        if PlayerTag["Enabled"] then
														lplr:SetAttribute("__OwnsCustomPlayerTag", true);
														local playerTagValue: IntValue? = lplr:FindFirstChild("PlayerTagValue");
												        if playerTagValue then
														        local tagNumber: number = tonumber(PlayerTagVal["Value"]) or 0;
														        playerTagValue.Value = tagNumber;
														end;
										                local playerTagsFolder: Instance? = workspace.Live:FindFirstChild(lplr.Name):FindFirstChild("PlayerTags");
													    local content: any = lplr.PlayerGui.Leaderboard.Leaderboard.MainLeaderboard.Content;
													    local playerNumber: any = content[tostring(lplr.UserId)].PlayerNumber;
														playerNumber.Text = tostring(PlayerTagVal["Value"] or "")
														if playerTagsFolder then
															    for _, partName in next, {"Front", "Back"} do
																        local part: any = playerTagsFolder:FindFirstChild(partName)
																        if part then
																	            local gui: SurfaceGui? = part:FindFirstChild("SurfaceGui")
																	            if gui then
																	                	local label: TextLabel? = gui:FindFirstChildWhichIsA("TextLabel")
																		                if label then
																		                    	label.Text = tostring(PlayerTagVal["Value"] or "");
																		                end;
																	            end;
																        end;
															    end;
														end;
										        end;
                                                task.wait(0.2);
                                        end;
                                end);
                        end;
                end,
                ["Tooltip"] = "Spoofing your attributes to get stuff!"
        });
        Title = AttributeSpoofer:CreateToggle({
                ["Name"] = "Title",
                ["Default"] = true,
                ["Function"] = function(callback: boolean)
                        Title["Enabled"] = callback;
                end;
        });
        Glass = AttributeSpoofer:CreateToggle({
                ["Name"] = "Glass Manufacturer",
                ["Default"] = true,
                ["Function"] = function(callback: boolean)
                        Glass["Enabled"] = callback;
                end;
        });
        TitleVal = AttributeSpoofer:CreateDropdown({
                ["Name"] = "Titles",
                ["Default"] = "Rich Millionaire",
                ["List"] = {
                        "Manipulator",
                        "Rich Millionaire",
                        "The Recruiter",
                        "Tanos",
                        "The Glass Maker",
                        "Frontman",
                        "Squidder",
                        "Game VIP",
						"Sackboy",
                        "Him",
                        "Honeycomb Artist",
                        "The Chosen One",
                        "Content Creator",
						"Game VIP",
						"Game Developer",
                        "Game Administrator",
                        "Game Animator",
                        "Game Artist",
                        "Game Builder",
                        "Game Contributer",
                        "Game Modeller",
                        "Game Moderator",
                        "Game SFX Designer",
						"The Strongest",
						"The Perfect Lifeform",
						"Voice Actor",
						"SFX Designer"
                },
                ["Function"] = function(value: string)
                        TitleVal["Value"] = value
                end;
        });
        Won = AttributeSpoofer:CreateToggle({
                ["Name"] = "Won",
                ["Default"] = true,
                ["Function"] = function(callback: boolean)
                        Won["Enabled"] = callback;
                end;
        });
        WonAmount = AttributeSpoofer:CreateSlider({
                ["Name"] = "Won Amount",
                ["Min"] = 0,
                ["Max"] = 99999999999,
                ["Default"] = 999,
                ["Function"] = function(value: number)
                        WonAmount["Value"] = value
                end;
        });
        Wins = AttributeSpoofer:CreateToggle({
                ["Name"] = "Wins",
                ["Default"] = true,
                ["Function"] = function(callback: boolean)
                        Wins["Enabled"] = callback;
                end;
        });
        WinsAmount = AttributeSpoofer:CreateSlider({
                ["Name"] = "Wins Amount",
                ["Min"] = 0,
                ["Max"] = 9999,
                ["Default"] = 999,
                ["Function"] = function(value: number)
                        WinsAmount["Value"] = value
                end;
        });
        PlayerTag = AttributeSpoofer:CreateToggle({
                ["Name"] = "Player Tag",
                ["Default"] = true,
                ["Function"] = function(callback: boolean)
                        PlayerTag["Enabled"] = callback;
                end;
        });
	    PlayerTagVal = AttributeSpoofer:CreateTextBox({
		        ["Name"] = "Tag Text",
		        ["Placeholder"] = "Enter tag",
		       	["Function"] = function()
						if AttributeSpoofer["Enabled"] then
								AttributeSpoofer:Toggle();
								AttributeSpoofer:Toggle();
						end;
				end;
	    });
        Level = AttributeSpoofer:CreateToggle({
                ["Name"] = "Level",
                ["Default"] = true,
                ["Function"] = function(callback: boolean)
                        Level["Enabled"] = callback;
                end;
        });
        LevelAmount = AttributeSpoofer:CreateSlider({
                ["Name"] = "Level Amount",
                ["Min"] = 0,
                ["Max"] = 999999,
                ["Default"] = 999,
                ["Function"] = function(value: number)
                        LevelAmount["Value"] = value
                end;
        });
end)

velo.run(function()
        local VIP: table = { ["Enabled"] = false };
        local VIPChattag: table = { ["Enabled"] = false };
        local VIPClothes: table = { ["Enabled"] = false };
        local VIPClothesColor: table = { ["Enabled"] = false };
        local Color: table = { ["Hue"] = 0, ["Sat"] = 1, ["Value"] = 1 };
        local ApplyClothingColor = function(v: Player)
                local character: Model? = v.Character;
                if not character then return end;
                for _, part in next, character:GetChildren() do
                        if part:IsA("Shirt") then
                                part.Color3 = v:GetAttribute("ClothingColor") or Color3.new(1,1,1);
                                part.ShirtTemplate = "rbxassetid://94276245685443";
                        elseif part:IsA("Pants") then
                                part.Color3 = v:GetAttribute("ClothingColor") or Color3.new(1,1,1);
                                part.PantsTemplate = "rbxassetid://79912511323571";
                        end;
                end;
        end;
        VIP = vape.Categories.Utility:CreateModule({
                ["Name"] = "VIPSpoofer",
                ["Function"] = function(callback: boolean)
                        if callback then
                                task.spawn(function()
                                        lplr:SetAttribute("__OwnsVIPGamepass", true);
                                        if VIPClothes["Enabled"] then
                                                lplr:SetAttribute("ClothingColorToggle", true);
                                        end;
                                        if VIPClothesColor["Enabled"] then
                                                lplr:SetAttribute("ClothingColor", Color3.fromHSV(Color["Hue"], Color["Sat"], Color["Value"]))
                                                ApplyClothingColor(lplr);
                                                lplr.CharacterAdded:Connect(function(char: Model)
                                                        task.wait(1);
                                                        ApplyClothingColor(lplr);
                                                end);
                                                lplr:GetAttributeChangedSignal("ClothingColor"):Connect(function()
                                                        ApplyClothingColor(lplr);
                                                end);
                                                lplr:GetAttributeChangedSignal("ClothingColorToggle"):Connect(function()
                                                        ApplyClothingColor(lplr);
                                                end);
                                        end;
                                        if VIPChattag["Enabled"] then
                                                lplr:SetAttribute("VIPChatTag", true);
                                        end;
                                end);
                        end;
                end,
                ["Tooltip"] = "Spoofing your VIP attributes to get stuff!"
        });
        VIPClothes = VIP:CreateToggle({
                ["Name"] = "Clothes",
                ["Default"] = true,
                ["Function"] = function(callback: boolean)
                        VIPClothes["Enabled"] = callback;
                end;
        });
        VIPClothesColor = VIP:CreateToggle({
                ["Name"] = "Clothes Color",
                ["Default"] = true,
                ["Function"] = function(callback: boolean)
                        VIPClothesColor["Enabled"] = callback;
                end;
        });
        VIPChattag = VIP:CreateToggle({
                ["Name"] = "Chat Tag",
                ["Default"] = true,
                ["Function"] = function(callback: boolean)
                        VIPChattag["Enabled"] = callback;
                end;
        });
        Color = VIP:CreateColorSlider({
                ["Name"] = "Color",
                ["Function"] = function(hue: number, sat: number, val: number)
                        Color["Hue"] = hue
                        Color["Sat"] = sat
                        Color["Value"] = val
                        if VIPClothesColor["Enabled"] then
                                lplr:SetAttribute("ClothingColor", Color3.fromHSV(hue, sat, val));
                        end;
                end;
        });
end)
