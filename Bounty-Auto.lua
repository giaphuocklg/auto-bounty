--[[ 
    BOUNTY HUNTER LOGIC SCRIPT - KAITUN EDITION
    Custom UI Implementation - Professional & Clean
    Fully Automated Logic Ported from Original
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CFG = getgenv().Setting

-- Ensure Config Integrity
if not CFG.Melee then CFG.Melee = {Enable=true, Z={Enable=true, HoldTime=0.1}, X={Enable=true, HoldTime=0.1}, C={Enable=true, HoldTime=0.1}} end
if not CFG.SafeHealth then CFG.SafeHealth = {Health=4000, Enable=true} end

--------------------------------------------------------------------------------
-- // CUSTOM UI LIBRARY // --
--------------------------------------------------------------------------------
local UI = {}
local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end)

function UI:Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

function UI:MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.1), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
end

-- ScreenGui
local ScreenGui = UI:Create("ScreenGui", {
    Name = "BountyHunterUI",
    Parent = CoreGui,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})
ProtectGui(ScreenGui)

-- Main Frame (Dark Theme, Rounded)
local MainFrame = UI:Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(20, 20, 25),
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -275, 0.5, -175),
    Size = UDim2.new(0, 550, 0, 350),
    ClipsDescendants = true
})
UI:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainFrame })

-- Header
local Header = UI:Create("Frame", {
    Name = "Header",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 45)
})
-- Gradient Line
local GradientLine = UI:Create("Frame", {
    Parent = Header,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, -2),
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = Color3.fromRGB(85, 170, 255)
})
UI:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Header })

local Title = UI:Create("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 0),
    Size = UDim2.new(0, 200, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "BOUNTY <font color=\"rgb(85, 170, 255)\">HUNTER</font> PRO",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    RichText = true
})

-- Status Label
local StatusLabel = UI:Create("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.new(0.45, 0, 1, 0),
    Font = Enum.Font.Gotham,
    Text = "Status: Idle",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right
})

UI:MakeDraggable(MainFrame, Header)

-- Tabs
local TabContainer = UI:Create("Frame", {
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 45),
    Size = UDim2.new(0, 140, 1, -45)
})
local TabHolder = UI:Create("ScrollingFrame", {
    Parent = TabContainer,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 10),
    Size = UDim2.new(1, 0, 1, -20),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 0
})
UI:Create("UIListLayout", { Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
UI:Create("UIPadding", { Parent = TabHolder, PaddingLeft = UDim.new(0, 10) })

-- Pages
local PageContainer = UI:Create("Frame", {
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 150, 0, 55),
    Size = UDim2.new(1, -160, 1, -65)
})

local Tabs = {}
local CurrentTab = nil

function UI:AddTab(name, icon)
    local TabButton = UI:Create("TextButton", {
        Name = name .. "Tab",
        Parent = TabHolder,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 32),
        Font = Enum.Font.GothamMedium,
        Text = "      " .. name,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabButton })
    
    local IconFrame = UI:Create("ImageLabel", {
        Parent = TabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = icon or "",
        ImageColor3 = Color3.fromRGB(150, 150, 150)
    })

    local Page = UI:Create("ScrollingFrame", {
        Name = name .. "Page",
        Parent = PageContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65),
        Visible = false
    })
    UI:Create("UIListLayout", { Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
    
    Page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    local function Activate()
        if CurrentTab then
            TweenService:Create(CurrentTab.Button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            if CurrentTab.Icon then TweenService:Create(CurrentTab.Icon, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play() end
            CurrentTab.Page.Visible = false
        end
        CurrentTab = {Button = TabButton, Page = Page, Icon = IconFrame}
        TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 40), BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        if icon then TweenService:Create(IconFrame, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play() end
        Page.Visible = true
    end

    TabButton.MouseButton1Click:Connect(Activate)
    if #Tabs == 0 then Activate() end
    table.insert(Tabs, {Button = TabButton, Page = Page, Icon = IconFrame})
    return Page
end

function UI:AddSection(page, text)
    local SectionLabel = UI:Create("TextLabel", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = Color3.fromRGB(85, 170, 255),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    UI:Create("UIPadding", { Parent = SectionLabel, PaddingLeft = UDim.new(0, 5) })
end

function UI:AddToggle(page, text, configPath, callback)
    local ToggleFrame = UI:Create("Frame", {
        Parent = page,
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38)
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ToggleFrame })

    UI:Create("TextLabel", {
        Parent = ToggleFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local currentVal = CFG
    for i=1, #configPath-1 do currentVal = currentVal[configPath[i]] end
    local key = configPath[#configPath]
    local state = currentVal[key]

    local Switch = UI:Create("TextButton", {
        Parent = ToggleFrame,
        BackgroundColor3 = state and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(45, 45, 50),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -50, 0.5, -10),
        Size = UDim2.new(0, 40, 0, 20),
        Text = "",
        AutoButtonColor = false
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Switch })
    local Circle = UI:Create("Frame", {
        Parent = Switch,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Circle })

    Switch.MouseButton1Click:Connect(function()
        state = not state
        currentVal[key] = state
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(45, 45, 50)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        if callback then callback(state) end
    end)
end

function UI:AddInput(page, text, configPath, numeric)
    local InputFrame = UI:Create("Frame", {
        Parent = page,
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38)
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = InputFrame })

    UI:Create("TextLabel", {
        Parent = InputFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local currentVal = CFG
    for i=1, #configPath-1 do currentVal = currentVal[configPath[i]] end
    local key = configPath[#configPath]

    local TextBoxBg = UI:Create("Frame", {
        Parent = InputFrame,
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        Position = UDim2.new(1, -110, 0.5, -12),
        Size = UDim2.new(0, 100, 0, 24)
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TextBoxBg })

    local TextBox = UI:Create("TextBox", {
        Parent = TextBoxBg,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = tostring(currentVal[key]),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        ClearTextOnFocus = false
    })
    
    TextBox.FocusLost:Connect(function()
        local val = TextBox.Text
        if numeric then val = tonumber(val) or currentVal[key] end
        currentVal[key] = val
        TextBox.Text = tostring(val)
    end)
end

-- // PAGES // --
local GeneralTab = UI:AddTab("General", "rbxassetid://10888331510") 
local CombatTab = UI:AddTab("Combat", "rbxassetid://10888335436") 
local SettingsTab = UI:AddTab("Settings", "rbxassetid://10888339056") 

-- General
UI:AddSection(GeneralTab, "Main Settings")
UI:AddToggle(GeneralTab, "Auto Enable V3", {"Auto Enable V3"})
UI:AddToggle(GeneralTab, "Auto Enable V4", {"Auto Enable V4"})
UI:AddToggle(GeneralTab, "Skip Race V4", {"Skip Race V4"})
UI:AddToggle(GeneralTab, "White Screen", {"White Screen"}, function(v) RunService:Set3dRenderingEnabled(not v) end)

UI:AddSection(GeneralTab, "Teams")
UI:AddToggle(GeneralTab, "Pirates Team", {"Team"}, function(v)
    local team = v and "Pirates" or "Marines"
    if not v and getgenv().Setting.Team == "Pirates" then team = "Marines" elseif v and getgenv().Setting.Team == "Marines" then team = "Pirates" end
    team = v and "Pirates" or "Marines"
    CFG.Team = team
    ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", team)
end)

-- Combat
UI:AddSection(CombatTab, "Weapons")
UI:AddToggle(CombatTab, "Use Melee", {"Melee", "Enable"})
UI:AddToggle(CombatTab, "Use Sword", {"Sword", "Enable"})
UI:AddToggle(CombatTab, "Use Fruit", {"Fruit", "Enable"})
UI:AddToggle(CombatTab, "Use Gun", {"Gun", "Enable"})
UI:AddToggle(CombatTab, "Gun Mode (Snipe)", {"Gun", "GunMode"})

UI:AddSection(CombatTab, "Safety")
UI:AddToggle(CombatTab, "Safe Health", {"SafeHealth", "Enable"})
UI:AddInput(CombatTab, "Safe Health", {"SafeHealth", "Health"}, true)

-- Settings
UI:AddSection(SettingsTab, "Bounty Hunt")
UI:AddInput(SettingsTab, "Min Bounty", {"Hunt", "Min"}, true)
UI:AddInput(SettingsTab, "Max Bounty", {"Hunt", "Max"}, true)
UI:AddSection(SettingsTab, "Skip Options")
UI:AddToggle(SettingsTab, "Skip Fruit Users", {"Skip", "Fruit"})
UI:AddToggle(SettingsTab, "Skip SafeZones", {"Skip", "SafeZone"})
UI:AddSection(SettingsTab, "Webhook")
UI:AddToggle(SettingsTab, "Enable Webhook", {"Webhook", "Enabled"})
UI:AddInput(SettingsTab, "Webhook URL", {"Webhook", "Url"}, false)

--------------------------------------------------------------------------------
-- // LOGIC IMPLEMENTATION // --
--------------------------------------------------------------------------------

getgenv().weapon = nil
getgenv().targ = nil 
getgenv().checked = {}
_G.FastAttack = true
local hopserver = false

-- Island Data
local placeId = game.PlaceId
local worldMap = {[2753915549] = "World1",[85211729168715] = "World1",[4442272183] = "World2",[79091703265657] = "World2",[7449423635] = "World3",[100117331123089] = "World3"}
local World1, World2, World3 = false, false, false
if worldMap[placeId] then
    local world = worldMap[placeId]
    if world == "World1" then World1 = true
    elseif world == "World2" then World2 = true
    elseif world == "World3" then World3 = true
    end
end
local distbyp, island
if World3 then 
    distbyp = 5000
    island = {
        ["Port Town"] = CFrame.new(-290, 6, 5343),
        ["Hydra Island"] = CFrame.new(5749 + 50, 611, -276),
        ["Mansion"] = CFrame.new(-12471 + 50, 374, -7551),
        ["Castle On The Sea"] = CFrame.new(-5085 + 50, 316, -3156),
        ["Haunted Island"] = CFrame.new(-9547, 141, 5535),
        ["Great Tree"] = CFrame.new(2681, 1682, -7190),
        ["Candy Island"] = CFrame.new(-1106, 13, -14231),
        ["Cake Island"] = CFrame.new(-1903, 36, -11857),
        ["Loaf Island"] = CFrame.new(-889, 64, -10895),
        ["Peanut Island"] = CFrame.new(-1943, 37, -10288),
        ["Cocoa Island"] = CFrame.new(147, 23, -12030),
        ["Tiki Outpost"] = CFrame.new(-16234,9,416)
    } 
elseif World2 then 
    distbyp = 3500
    island = { 
        a = CFrame.new(753, 408, -5274), b = CFrame.new(-5622, 492, -781), c = CFrame.new(-11, 29, 2771),
        d = CFrame.new(-2448, 73, -3210), e = CFrame.new(-380, 77, 255), f = CFrame.new(-3032, 317, -10075),
        g = CFrame.new(6148, 294, -6741), h = CFrame.new(923, 125, 32885), i = CFrame.new(-6127, 15, -5040)
    }
elseif World1 then 
    distbyp = 1500
    island = { 
        a = CFrame.new(979, 16, 1429), b = CFrame.new(-2566, 6, 2045), c = CFrame.new(944, 20, 4373),
        d = CFrame.new(-1181, 4, 3803), e = CFrame.new(-1612, 36, 149), f = CFrame.new(-690, 15, 1582)
    } 
end

-- Teleport Logic
local tween = nil
function to(Pos)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.Humanoid.Health > 0 then
            local root = LocalPlayer.Character.HumanoidRootPart
            local dist = (Pos.Position - root.Position).Magnitude
            if not LocalPlayer.Character.PrimaryPart:FindFirstChild("Hold") then
                local Hold = Instance.new("BodyVelocity", LocalPlayer.Character.PrimaryPart)
                Hold.Name = "Hold"
                Hold.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                Hold.Velocity = Vector3.zero
            end
            local speed = (dist < 1000) and 340 or 320
            if tween then tween:Cancel() end
            tween = TweenService:Create(root, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = Pos})
            tween:Play()
            root.CFrame = CFrame.new(root.CFrame.X, Pos.Y, root.CFrame.Z)
        end
    end)
end

function CheckSafeZone(targetChar)
    if not CFG.Skip.SafeZone then return false end
    if not workspace:FindFirstChild("_WorldOrigin") then return false end
    for _, v in pairs(workspace._WorldOrigin.SafeZones:GetChildren()) do
        if v:IsA("Part") and (v.Position - targetChar.Position).Magnitude <= 400 then
            return true
        end
    end
    return false
end

-- Combat
if _G.FastAttack then
    local _ENV = (getgenv or getrenv or getfenv)();
    local function v0(v35, v36) local v37, v38 = pcall(function() return v35:WaitForChild(v36) end); return v38; end
    local v2 = game:GetService("VirtualInputManager");
    local v6 = game:GetService("RunService");
    local v7 = game:GetService("Players");
    local v8 = v7.LocalPlayer;
    local v22 = v6.Stepped;
    local v4 = game:GetService("ReplicatedStorage");
    local v23 = v0(v4, "Modules");
    local v24 = v0(v23, "Net");
    local v28 = {AutoClick=true, ClickDelay=0};
    local v29 = {AttackCooldown = 0, Connections = {}};
    v29.IsAlive = function(v41) return v41 and v41:FindFirstChild("Humanoid") and (v41.Humanoid.Health > 0); end;
    
    local v43 = {Distance=60, attackMobs=true, attackPlayers=true};
    local v16 = v0(workspace, "Enemies");
    local v15 = v0(workspace, "Characters");
    
    local v44 = v0(v24, "RE/RegisterAttack");
    local v45 = v0(v24, "RE/RegisterHit");

    v43.Process = function(v64, v65, v66, v67, v68, v69)
         if not v65 then return end
         for _, v115 in pairs(v66:GetChildren()) do
             local v116 = v115:FindFirstChild("HumanoidRootPart")
             if v116 and (v115 ~= v8.Character) and v29.IsAlive(v115) and (v68 - v116.Position).Magnitude <= v69 then
                  if not v64.EnemyRootPart then v64.EnemyRootPart = v116 else table.insert(v67, {v115, v116}) end
             end
         end
    end
    
    v43.GetAllBladeHits = function(v72, v73, v74)
         local v75 = v73:GetPivot().Position
         local v76 = {}
         v43:Process(v72.attackMobs, v16, v76, v75, v74)
         v43:Process(v72.attackPlayers, v15, v76, v75, v74)
         return v76
    end

    v43.Attack = function(v105)
         if not v29.IsAlive(v8.Character) then return end
         local tool = v8.Character:FindFirstChildOfClass("Tool")
         if not tool or (tool.ToolTip ~= "Melee" and tool.ToolTip ~= "Blox Fruit" and tool.ToolTip ~= "Sword") then return end
         
         if (tick() - v29.AttackCooldown) > 0.1 then 
             local hits = v43:GetAllBladeHits(v8.Character, v43.Distance)
             if #hits > 0 then
                 v44:FireServer(0.1) 
                 v45:FireServer(hits[1][2], hits) 
             end
             v2:SendMouseButtonEvent(0, 0, 0, true, game, 1)
             task.wait(0.01)
             v2:SendMouseButtonEvent(0, 0, 0, false, game, 1)
             v29.AttackCooldown = tick()
         end
    end

    task.spawn(function()
         while task.wait(v28.ClickDelay) do if v28.AutoClick then v43:Attack() end end
    end)
    table.insert(v29.Connections, v22:Connect(function() v43:Attack() end))
end

function buso()
    if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

function Ken()
    if LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") and LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("ImageLabel") then return true else
        VirtualUser:CaptureController()
        VirtualUser:SetKeyDown("0x65"); VirtualUser:SetKeyUp("0x65")
        return false
    end
end

function down(key, holdTime)
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
        task.wait(holdTime or 0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
    end)
end

function equip(tooltip)
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.ToolTip == tooltip then
             LocalPlayer.Character.Humanoid:EquipTool(item)
             return true
        end
    end
    return false
end

function hasValue(tab, val) for _, v in pairs(tab) do if v == val then return true end end return false end

function HopServer()
    StatusLabel.Text = "Status: Hopping Server..."
    local PlaceID = game.PlaceId
    local Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    for i,v in pairs(Site.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
            break
        end
    end
end

function SkipPlayer()
    getgenv().killed = getgenv().targ 
    if getgenv().targ then table.insert(getgenv().checked, getgenv().targ) end
    getgenv().targ = nil
    hopserver = false -- Reset hop flag to retry finding target in same server once before hopping again if empty
    -- Logic next target in main loop
end

function KillWebhook(target, bounty)
    if not CFG.Webhook.Enabled or CFG.Webhook.Url == "" then return end
    local data = { embeds = {{ title = "Bounty Hunter Execution", color = 65280, fields = {{name = "Target", value = target, inline = true}, {name = "Bounty", value = tostring(bounty), inline = true}} }} }
    pcall(function()
        (syn and syn.request or http_request or request)({ Url = CFG.Webhook.Url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data) })
    end)
end

function target() 
    pcall(function()
        local d = math.huge
        local p = nil
        getgenv().targ = nil        
        for _, v in pairs(game.Players:GetPlayers()) do 
            if v.Team ~= nil and (tostring(LocalPlayer.Team) == CFG.Team or (tostring(v.Team) == CFG.Team and tostring(LocalPlayer.Team) ~= CFG.Team)) then
                if v and v:FindFirstChild("Data") and ((CFG.Skip.Fruit and hasValue(CFG.Skip.FruitList, v.Data.DevilFruit.Value) == false) or not CFG.Skip.Fruit) then
                    if v ~= LocalPlayer and v ~= getgenv().targ and 
                       v.Character and v.Character:FindFirstChild("HumanoidRootPart") and
                       v.Character.HumanoidRootPart.CFrame.Y <= 12000 and
                       (v.Character.HumanoidRootPart.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.CFrame.Position).Magnitude < d and 
                       not hasValue(getgenv().checked, v) then

                        -- Safety Check
                        if not CheckSafeZone(v.Character.HumanoidRootPart) then
                            local bounty = v.leaderstats["Bounty/Honor"] and v.leaderstats["Bounty/Honor"].Value or 0
                            if bounty >= CFG.Hunt.Min and bounty <= CFG.Hunt.Max then
                                 p = v 
                                 d = (v.Character.HumanoidRootPart.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.CFrame.Position).Magnitude
                            end
                        end
                    end 
                end
            end
        end         
        
        if p == nil then 
             if #game.Players:GetPlayers() <= 1 then
                hopserver = true -- Hop if only me
             else
                -- If Checked all, maybe clear checked or hop
                 if #getgenv().checked >= (#game.Players:GetPlayers() - 1) then
                    hopserver = true
                 end
             end
        else
            hopserver = false
            StatusLabel.Text = "Status: Target Found - " .. p.Name
        end        
        getgenv().targ = p
    end)
end

-- Main Loop
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- Auto Enable PvP
            if LocalPlayer.PlayerGui.Main:FindFirstChild("PvpDisabled") and LocalPlayer.PlayerGui.Main.PvpDisabled.Visible then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("EnablePvp")
            end
            
            -- Find Target
            if not getgenv().targ or not getgenv().targ.Parent then
                StatusLabel.Text = "Status: Scanning..."
                target()
                if hopserver then 
                    StatusLabel.Text = "Status: No Targets. Hopping..."
                    HopServer()
                end
            end
            
            if getgenv().targ and getgenv().targ.Character then
                local tChar = getgenv().targ.Character
                if tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health <= 0 then
                    KillWebhook(getgenv().targ.Name, "???")
                    SkipPlayer()
                    return
                end
                
                -- Check Safe Health to Retreat
                if CFG.SafeHealth.Enable and LocalPlayer.Character.Humanoid.Health < CFG.SafeHealth.Health then
                    StatusLabel.Text = "Status: Low Health! Retreating..."
                    to(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 100, 0)) 
                else
                    if tChar:FindFirstChild("HumanoidRootPart") then
                        StatusLabel.Text = "Status: Attacking " .. getgenv().targ.Name
                        to(tChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5))
                        if (tChar.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 40 then
                            buso()
                            Ken()
                            if not CFG.Gun.GunMode then
                                if CFG.Melee.Enable then getgenv().weapon = "Melee" 
                                elseif CFG.Sword.Enable then getgenv().weapon = "Sword"; equip("Sword") end
                            end
                            if CFG.Melee.Enable and tChar.Humanoid.Health > 0 then
                                 down("Z", CFG.Melee.Z.HoldTime or 0.1)
                                 down("X", CFG.Melee.X.HoldTime or 0.1)
                                 down("C", CFG.Melee.C.HoldTime or 0.1)
                            end
                        end
                    else SkipPlayer() end
                end
            end
        end)
    end
end)

Fullscreen = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Fullscreen = not Fullscreen
        MainFrame.Visible = Fullscreen
    end
end)
print("Logic Loaded Final - Kaitun Mode Active")
