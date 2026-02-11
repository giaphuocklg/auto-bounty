--[[ 
    BOUNTY HUNTER LOGIC SCRIPT
    Custom UI Implementation - Professional & Clean
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

-- Main Frame
local MainFrame = UI:Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
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
    BackgroundColor3 = Color3.fromRGB(30, 30, 35),
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 40)
})
UI:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Header })
-- Fix bottom corners of header
local HeaderCover = UI:Create("Frame", {
    Parent = Header,
    BackgroundColor3 = Color3.fromRGB(30, 30, 35),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, -10),
    Size = UDim2.new(1, 0, 0, 10)
})

local Title = UI:Create("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 15, 0, 0),
    Size = UDim2.new(0, 200, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "BOUNTY <font color=\"rgb(85, 170, 255)\">HUNTER</font>",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    RichText = true
})

UI:MakeDraggable(MainFrame, Header)

-- Tabs Container
local TabContainer = UI:Create("Frame", {
    Name = "TabContainer",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 40),
    Size = UDim2.new(0, 130, 1, -40)
})
UI:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TabContainer })
local TabCover = UI:Create("Frame", {
    Parent = TabContainer,
    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
    BorderSizePixel = 0,
    Position = UDim2.new(1, -10, 0, 0),
    Size = UDim2.new(0, 10, 1, 0)
})
local TabCoverTop = UI:Create("Frame", {
    Parent = TabContainer,
    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 10)
})

local TabHolder = UI:Create("ScrollingFrame", {
    Parent = TabContainer,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 10),
    Size = UDim2.new(1, 0, 1, -20),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 0
})
UI:Create("UIListLayout", {
    Parent = TabHolder,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 5)
})
UI:Create("UIPadding", { Parent = TabHolder, PaddingLeft = UDim.new(0, 10) })

-- Pages Container
local PageContainer = UI:Create("Frame", {
    Name = "PageContainer",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 140, 0, 50),
    Size = UDim2.new(1, -150, 1, -60)
})

local Tabs = {}
local CurrentTab = nil

function UI:AddTab(name, icon)
    local TabButton = UI:Create("TextButton", {
        Name = name .. "Tab",
        Parent = TabHolder,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 30),
        Font = Enum.Font.GothamMedium,
        Text = "      " .. name,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    })
    
    -- Icon Integration (Simplified shapes for "Clean" look if no asset id)
    local IconFrame = UI:Create("ImageLabel", {
        Parent = TabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0.5, -8),
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
    
    local PageLayout = UI:Create("UIListLayout", {
        Parent = Page,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    local function Activate()
        if CurrentTab then
            TweenService:Create(CurrentTab.Button, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            if CurrentTab.Icon then TweenService:Create(CurrentTab.Icon, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play() end
            CurrentTab.Page.Visible = false
        end
        CurrentTab = {Button = TabButton, Page = Page, Icon = IconFrame}
        TweenService:Create(TabButton, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        if icon then TweenService:Create(IconFrame, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play() end
        Page.Visible = true
    end

    TabButton.MouseButton1Click:Connect(Activate)
    if #Tabs == 0 then Activate() end -- Select first tab
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
        BackgroundColor3 = Color3.fromRGB(40, 40, 45),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ToggleFrame })

    local Label = UI:Create("TextLabel", {
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

    -- Resolve config value
    local currentVal = CFG
    for i=1, #configPath-1 do currentVal = currentVal[configPath[i]] end
    local key = configPath[#configPath]
    local state = currentVal[key]

    local Switch = UI:Create("TextButton", {
        Parent = ToggleFrame,
        BackgroundColor3 = state and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(60, 60, 65),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -50, 0.5, -8),
        Size = UDim2.new(0, 36, 0, 16),
        Text = "",
        AutoButtonColor = false
    })
    local SwitchCorner = UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Switch })
    local Circle = UI:Create("Frame", {
        Parent = Switch,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 12, 0, 12),
        Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Circle })

    Switch.MouseButton1Click:Connect(function()
        state = not state
        currentVal[key] = state
        
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(60, 60, 65)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
        
        if callback then callback(state) end
    end)
end

function UI:AddInput(page, text, configPath, numeric)
    local InputFrame = UI:Create("Frame", {
        Parent = page,
        BackgroundColor3 = Color3.fromRGB(40, 40, 45),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
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
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        Position = UDim2.new(1, -110, 0.5, -10),
        Size = UDim2.new(0, 100, 0, 20)
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TextBoxBg })

    local TextBox = UI:Create("TextBox", {
        Parent = TextBoxBg,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = tostring(currentVal[key]),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 11,
        ClearTextOnFocus = false
    })

    TextBox.FocusLost:Connect(function()
        local val = TextBox.Text
        if numeric then
            val = tonumber(val) or currentVal[key]
        end
        currentVal[key] = val
        TextBox.Text = tostring(val)
    end)
end

-- // CREATE UI PAGES // --
local GeneralTab = UI:AddTab("General", "rbxassetid://10888331510") -- Home Icon
local CombatTab = UI:AddTab("Combat", "rbxassetid://10888335436") -- Sword Icon
local SettingsTab = UI:AddTab("Settings", "rbxassetid://10888339056") -- Settings Icon

-- General Page
UI:AddSection(GeneralTab, "Main Settings")
UI:AddToggle(GeneralTab, "Auto Enable V3", {"Auto Enable V3"})
UI:AddToggle(GeneralTab, "Auto Enable V4", {"Auto Enable V4"})
UI:AddToggle(GeneralTab, "Skip Race V4", {"Skip Race V4"})
UI:AddToggle(GeneralTab, "White Screen", {"White Screen"}, function(v) 
    RunService:Set3dRenderingEnabled(not v) 
end)

UI:AddSection(GeneralTab, "Teams")
-- Simple Team Toggle (Optimized for space, could be dropdown)
UI:AddToggle(GeneralTab, "Pirates Team (Off = Marines)", {"Team"}, function(v)
    local team = v and "Pirates" or "Marines"
    CFG.Team = team
    ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", team)
end)

-- Combat Page
UI:AddSection(CombatTab, "Weapons")
UI:AddToggle(CombatTab, "Use Melee", {"Melee", "Enable"})
UI:AddToggle(CombatTab, "Use Sword", {"Sword", "Enable"})
UI:AddToggle(CombatTab, "Use Fruit", {"Fruit", "Enable"})
UI:AddToggle(CombatTab, "Use Gun", {"Gun", "Enable"})
UI:AddToggle(CombatTab, "Gun Mode (Snipe)", {"Gun", "GunMode"})

UI:AddSection(CombatTab, "Safety")
UI:AddToggle(CombatTab, "Safe Health", {"SafeHealth", "Enable"})
UI:AddInput(CombatTab, "Safe Health %", {"SafeHealth", "Health"}, true)

-- Settings Page
UI:AddSection(SettingsTab, "Bounty Hunt")
UI:AddInput(SettingsTab, "Min Bounty", {"Hunt", "Min"}, true)
UI:AddInput(SettingsTab, "Max Bounty", {"Hunt", "Max"}, true)

UI:AddSection(SettingsTab, "Skip Options")
UI:AddToggle(SettingsTab, "Skip Fruit Users", {"Skip", "Fruit"})
UI:AddToggle(SettingsTab, "Skip Safe SafeZone", {"Skip", "SafeZone"})

UI:AddSection(SettingsTab, "Webhook")
UI:AddToggle(SettingsTab, "Enable Webhook", {"Webhook", "Enabled"})
UI:AddInput(SettingsTab, "Webhook URL", {"Webhook", "Url"}, false)

--------------------------------------------------------------------------------
-- // LOGIC IMPLEMENTATION // --
--------------------------------------------------------------------------------

-- Helper Functions
local function VerifyConfig()
     -- Ensure deep nested tables exist if config was partial
     if not CFG.Melee then CFG.Melee = {Enable=true, Z={Enable=true, HoldTime=0.1}, X={Enable=true, HoldTime=0.1}, C={Enable=true, HoldTime=0.1}} end
end
VerifyConfig()

getgenv().weapon = nil
getgenv().targ = nil 
getgenv().checked = {}
_G.FastAttack = true

-- Ported FastAttack
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
    
    local v43 = {Distance=60, attackMobs=true, attackPlayers=true}; -- Optimized
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
         v43:Process(v72.attackMobs, workspace.Enemies, v76, v75, v74)
         v43:Process(v72.attackPlayers, workspace.Characters, v76, v75, v74)
         return v76
    end

    v43.Attack = function(v105)
         if not v29.IsAlive(v8.Character) then return end
         local tool = v8.Character:FindFirstChildOfClass("Tool")
         if not tool or (tool.ToolTip ~= "Melee" and tool.ToolTip ~= "Blox Fruit" and tool.ToolTip ~= "Sword") then return end
         
         if (tick() - v29.AttackCooldown) > 0.1 then -- Simple rate limit
             local hits = v43:GetAllBladeHits(v8.Character, v43.Distance)
             if #hits > 0 then
                 v44:FireServer(0.1) -- Simple register attack
                 -- Ideally call RegisterHit here if we have the args correct, simplified for stability
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

-- Teleport & Bypass Logic
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

function buso()
    if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

function Ken()
    if LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") and LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("ImageLabel") then
        return true
    else
        VirtualUser:CaptureController()
        VirtualUser:SetKeyDown("0x65")
        VirtualUser:SetKeyUp("0x65")
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

function EquipWeapon(toolName)
    pcall(function()
        local bp = LocalPlayer.Backpack:FindFirstChild(toolName)
        if bp then LocalPlayer.Character.Humanoid:EquipTool(bp) end
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

-- Utils
function hasValue(tab, val) for _, v in pairs(tab) do if v == val then return true end end return false end
local hopserver = false

function HopServer()
    -- Standard Hop Logic placeholder
    -- In a real scenario, this queries Roblox game API for servers
    -- Since we can't make external HTTP requests easily without proper perms in all executors, 
    -- we simulate or use a simple loop if avail. 
    -- Re-using a common public method:
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local validCursor = ""
    local Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    
    for i,v in pairs(Site.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
            break
        end
    end
end

function KillWebhook(target, bounty)
    if not CFG.Webhook.Enabled or CFG.Webhook.Url == "" then return end
    
    local data = {
        embeds = {{
            title = "Bounty Hunter Execution",
            color = 65280,
            fields = {
                {name = "Target", value = target, inline = true},
                {name = "Bounty", value = tostring(bounty), inline = true}
            }
        }}
    }
    
    pcall(function()
        (syn and syn.request or http_request or request)({
            Url = CFG.Webhook.Url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- Main Loop
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- Auto Enable PvP if disabled
            if LocalPlayer.PlayerGui.Main.PvpDisabled.Visible then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("EnablePvp")
            end
            
            -- Find Target
            if not getgenv().targ or not getgenv().targ.Parent then
                local bestTarget = nil
                local minDist = math.huge
                
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Team ~= LocalPlayer.Team then
                        -- Config Checks
                        local skip = false
                        if CFG.Skip.Fruit and v.Data.DevilFruit.Value ~= "" then 
                             if not hasValue(CFG.Skip.FruitList, v.Data.DevilFruit.Value) then skip = false else skip = true end -- Simplified logic based on list
                        end
                        -- SafeZone Check
                        
                        if not skip and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                bestTarget = v
                            end
                        end
                    end
                end
                
                if bestTarget then 
                    getgenv().targ = bestTarget
                    -- Notification
                else
                    if hopserver then HopServer() end
                end
            end
            
            -- Combat Logic
            if getgenv().targ and getgenv().targ.Character then
                local tChar = getgenv().targ.Character
                if tChar.Humanoid.Health <= 0 then
                    -- Target dead
                    KillWebhook(getgenv().targ.Name, "???")
                    getgenv().targ = nil
                    return
                end
                
                -- Move to Target
                to(tChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5))
                
                -- Attack
                if (tChar.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 40 then
                    buso()
                    -- Weapon Switching
                    if CFG.Melee.Enable then 
                        getgenv().weapon = "Melee" 
                        EquipWeapon("Electric Claw") -- Example, should detect current melee
                    elseif CFG.Sword.Enable then 
                        getgenv().weapon = "Sword" 
                        equip("Sword")
                    end
                    
                    -- Use Skills (Simplified for logic)
                    if CFG.Melee.Enable then 
                         down("Z", 0.1); down("X", 0.1); down("C", 0.1) 
                    end
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

print("Logic Loaded")
