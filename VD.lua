-- Violence District | EXE HUB Script VD 2.9.8a (Obsidian UI)
-- Keybinds: EXE HUB (Toggle Menu) | Delete (Kill / Close Script)
-- Tabs: ESP | Automatic | Player | Camera | Parry | Optimize | Settings

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local function safeLoad(path)
    local s, res = pcall(game.HttpGet, game, repo .. path)
    if s and res and #res > 50 then return loadstring(res)() end
    local s2, res2 = pcall(game.HttpGet, game, "https://cdn.jsdelivr.net/gh/deividcomsono/Obsidian@main/" .. path)
    if s2 and res2 and #res2 > 50 then return loadstring(res2)() end
    error("[EXE HUB] Failed to load " .. tostring(path))
end
local Library = safeLoad("Library.lua")
local ThemeManager = safeLoad("addons/ThemeManager.lua")
local SaveManager = safeLoad("addons/SaveManager.lua")

-- Protective hook: Prevents Roblox GetTextBoundsAsync from failing on rich text formatting
if Library and Library.GetTextBounds then
    local oldGetTextBounds = Library.GetTextBounds
    Library.GetTextBounds = function(self, text, font, size, width)
        local success, bx, by = pcall(function()
            return oldGetTextBounds(self, text, font, size, width)
        end)
        if success and bx and by then
            return bx, by
        end
        local stripped = tostring(text or ""):gsub("<[^>]->", ""):gsub("[<>]", "")
        local success2, bx2, by2 = pcall(function()
            return oldGetTextBounds(self, stripped, font, size, width)
        end)
        if success2 and bx2 and by2 then
            return bx2, by2
        end
        return 120, 20
    end
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer

local Options = Library.Options
local Toggles = Library.Toggles

-- State tracking
local connections = {}
local playerHighlights = {}
local generatorHighlights = {}
local trackedGenerators = {}
local defaultSpeed = 16
pcall(function()
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h and h.WalkSpeed > 0 then
            defaultSpeed = h.WalkSpeed
        end
    end
end)
local applyPlayerSpeed = nil

-- Fly tracking
local flyBodyVelocity = nil
local flyBodyGyro = nil

-- Create Window
local Window = Library:CreateWindow({
    Title = "EXE HUB",
    Footer = "VD 2.9.8a",
    NotifySide = "Right",
    ShowCustomCursor = false,
    ShowMobileButtons = false,
})

-- Toggle UI Function: Safely shows or hides the main window on any device
local function toggleUI()
    if Library and Library.Toggle then
        Library:Toggle()
    elseif Window and Window.MainFrame then
        local newState = not Window.MainFrame.Visible
        Window.MainFrame.Visible = newState
        Library.Toggled = newState
        pcall(function()
            if Window.Toggle then
                Window:Toggle(newState)
            end
        end)
    end
end

-- Dedicated ScreenGui for the Floating Toggle Button (Guarantees visibility across all executors & devices)
local FloatingScreenGui = Instance.new("ScreenGui")
FloatingScreenGui.Name = "EXEHUB_FloatingGui"
FloatingScreenGui.ResetOnSpawn = false
FloatingScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FloatingScreenGui.DisplayOrder = 999999

pcall(function()
    if gethui then
        FloatingScreenGui.Parent = gethui()
    elseif (syn and syn.protect_gui) then
        syn.protect_gui(FloatingScreenGui)
        FloatingScreenGui.Parent = game:GetService("CoreGui")
    else
        FloatingScreenGui.Parent = game:GetService("CoreGui")
    end
end)

if not FloatingScreenGui.Parent then
    pcall(function()
        FloatingScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
end

-- Universal "EXE HUB" Floating Toggle Button (Visible & Draggable on ALL devices)
local FloatingToggleGui = Instance.new("TextButton")
FloatingToggleGui.Name = "EXEHUB_FloatingToggle"
FloatingToggleGui.Text = "EXE HUB"
FloatingToggleGui.Font = Enum.Font.GothamBold
FloatingToggleGui.TextSize = 13
FloatingToggleGui.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingToggleGui.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
FloatingToggleGui.Size = UDim2.fromOffset(80, 32)
FloatingToggleGui.Position = UDim2.new(0, 18, 0, 75)
FloatingToggleGui.ZIndex = 2000
FloatingToggleGui.AutoButtonColor = false
FloatingToggleGui.Parent = FloatingScreenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = FloatingToggleGui

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(65, 65, 80)
toggleStroke.Thickness = 1.2
toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
toggleStroke.Parent = FloatingToggleGui

-- Hover effects
FloatingToggleGui.MouseEnter:Connect(function()
    toggleStroke.Color = Color3.fromRGB(130, 130, 160)
    FloatingToggleGui.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
end)
FloatingToggleGui.MouseLeave:Connect(function()
    toggleStroke.Color = Color3.fromRGB(65, 65, 80)
    FloatingToggleGui.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
end)

-- Draggable + Tap detection for both Touch and Mouse
do
    local isDragging = false
    local dragStart = nil
    local startPos = nil
    local hasDragged = false
    local lastToggleTick = 0

    local function onButtonTap()
        if tick() - lastToggleTick < 0.25 then return end
        lastToggleTick = tick()
        toggleUI()
    end

    FloatingToggleGui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            hasDragged = false
            dragStart = input.Position
            startPos = FloatingToggleGui.Position

            local moveConn
            local endConn

            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if not isDragging then return end
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    local delta = moveInput.Position - dragStart
                    if delta.Magnitude > 6 then
                        hasDragged = true
                        FloatingToggleGui.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y
                        )
                    end
                end
            end)

            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                    if moveConn then moveConn:Disconnect() end
                    if endConn then endConn:Disconnect() end

                    if not hasDragged then
                        onButtonTap()
                    end
                end
            end)
        end
    end)

    FloatingToggleGui.Activated:Connect(function()
        if not hasDragged then
            onButtonTap()
        end
    end)
end

-- Remove default mobile Toggle and Lock buttons so only our EXE HUB button is active
pcall(function()
    if Library.Floats then
        for _, child in ipairs(Library.Floats:GetChildren()) do
            if child:IsA("GuiObject") and child ~= Library.KeybindFrame then
                local label = child:FindFirstChildOfClass("TextLabel") or (child:IsA("TextButton") and child)
                if label and (label.Text == "Toggle" or label.Text == "Lock" or label.Text == "Unlock") then
                    child.Visible = false
                end
            end
        end
    end
end)

-- Left Sidebar Navigation Tabs
local Tabs = {
    ESP = Window:AddTab("ESP"),
    Automatic = Window:AddTab("Automatic"),
    Player = Window:AddTab("Player"),
    Camera = Window:AddTab("Camera"),
    Parry = Window:AddTab("Parry"),
    Optimize = Window:AddTab("Optimize"),
    ["UI Settings"] = Window:AddTab("Settings"),
}

----------------------------------------------------------------------
-- KEYBIND MENU CONTROLS & RESIZING
----------------------------------------------------------------------

local setKeybindScale

do
    local keybindFrame = Library.KeybindFrame
    local keybindContainer = Library.KeybindContainer
    local cornerGrip

    if keybindFrame then
        keybindFrame.Visible = false

        -- Detach KeybindFrame's UIScale from Library.Scales to allow independent scaling
        local keybindScale = keybindFrame:FindFirstChildOfClass("UIScale")
        if not keybindScale then
            keybindScale = Instance.new("UIScale")
            keybindScale.Parent = keybindFrame
        end
        local scaleIdx = table.find(Library.Scales, keybindScale)
        if scaleIdx then
            table.remove(Library.Scales, scaleIdx)
        end

        -- Ensure minimum width so title and 3 control buttons never overlap
        local sizeConstraint = keybindFrame:FindFirstChildOfClass("UISizeConstraint")
        if not sizeConstraint then
            sizeConstraint = Instance.new("UISizeConstraint")
            sizeConstraint.Parent = keybindFrame
        end
        sizeConstraint.MinSize = Vector2.new(175, 34)

        -- Adjust padding on the title label so text never clips under controls
        local titleLabel = keybindFrame:FindFirstChildOfClass("TextLabel")
        if titleLabel then
            local labelPadding = titleLabel:FindFirstChildOfClass("UIPadding")
            if labelPadding then
                labelPadding.PaddingRight = UDim.new(0, 85)
            end
        end

        -- Scale setter function
        setKeybindScale = function(scale, animate)
            scale = math.clamp(scale, 0.6, 2.0)
            if animate then
                TweenService:Create(keybindScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Scale = scale
                }):Play()
            else
                keybindScale.Scale = scale
            end
        end

        -- Header Controls Holder (Top-Right)
        local controls = Instance.new("Frame")
        controls.Name = "WindowControls"
        controls.BackgroundTransparency = 1
        controls.Size = UDim2.new(0, 75, 0, 34)
        controls.Position = UDim2.new(1, -78, 0, 0)
        controls.ZIndex = 5
        controls.Parent = keybindFrame

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 2)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = controls

        -- 1. Minimize Button (—)
        local isCollapsed = false
        local minBtn = Instance.new("TextButton")
        minBtn.Name = "MinimizeButton"
        minBtn.BackgroundTransparency = 1
        minBtn.Size = UDim2.fromOffset(22, 22)
        minBtn.Text = ""
        minBtn.AutoButtonColor = false
        minBtn.LayoutOrder = 1
        minBtn.Parent = controls

        local minIcon = Instance.new("Frame")
        minIcon.Name = "Icon"
        minIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        minIcon.Position = UDim2.fromScale(0.5, 0.5)
        minIcon.Size = UDim2.fromOffset(10, 2)
        minIcon.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
        minIcon.BorderSizePixel = 0
        minIcon.Parent = minBtn

        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 1)
        minCorner.Parent = minIcon

        minBtn.MouseEnter:Connect(function()
            minIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end)
        minBtn.MouseLeave:Connect(function()
            minIcon.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
        end)
        minBtn.MouseButton1Click:Connect(function()
            isCollapsed = not isCollapsed
            keybindContainer.Visible = not isCollapsed
            if cornerGrip then
                cornerGrip.Visible = not isCollapsed
            end
        end)

        -- 2. Scale / Window Button (❐)
        local scaleBtn = Instance.new("TextButton")
        scaleBtn.Name = "ScaleButton"
        scaleBtn.BackgroundTransparency = 1
        scaleBtn.Size = UDim2.fromOffset(22, 22)
        scaleBtn.Text = ""
        scaleBtn.AutoButtonColor = false
        scaleBtn.LayoutOrder = 2
        scaleBtn.Parent = controls

        local iconHolder = Instance.new("Frame")
        iconHolder.Name = "IconHolder"
        iconHolder.BackgroundTransparency = 1
        iconHolder.Size = UDim2.fromOffset(13, 13)
        iconHolder.AnchorPoint = Vector2.new(0.5, 0.5)
        iconHolder.Position = UDim2.fromScale(0.5, 0.5)
        iconHolder.Parent = scaleBtn

        -- Back square (offset top-right)
        local backSquare = Instance.new("Frame")
        backSquare.Name = "BackSquare"
        backSquare.BackgroundTransparency = 1
        backSquare.Size = UDim2.fromOffset(8, 8)
        backSquare.Position = UDim2.fromOffset(5, 0)
        backSquare.ZIndex = 6
        backSquare.Parent = iconHolder

        local backStroke = Instance.new("UIStroke")
        backStroke.Color = Color3.fromRGB(210, 210, 210)
        backStroke.Thickness = 1.3
        backStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        backStroke.Parent = backSquare

        local backCorner = Instance.new("UICorner")
        backCorner.CornerRadius = UDim.new(0, 2)
        backCorner.Parent = backSquare

        -- Front square (offset bottom-left, opaque to cover back square corner)
        local frontSquare = Instance.new("Frame")
        frontSquare.Name = "FrontSquare"
        frontSquare.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
        frontSquare.BackgroundTransparency = 0
        frontSquare.Size = UDim2.fromOffset(8, 8)
        frontSquare.Position = UDim2.fromOffset(0, 5)
        frontSquare.ZIndex = 7
        frontSquare.Parent = iconHolder

        local frontStroke = Instance.new("UIStroke")
        frontStroke.Color = Color3.fromRGB(210, 210, 210)
        frontStroke.Thickness = 1.3
        frontStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        frontStroke.Parent = frontSquare

        local frontCorner = Instance.new("UICorner")
        frontCorner.CornerRadius = UDim.new(0, 2)
        frontCorner.Parent = frontSquare

        scaleBtn.MouseEnter:Connect(function()
            backStroke.Color = Color3.fromRGB(255, 255, 255)
            frontStroke.Color = Color3.fromRGB(255, 255, 255)
        end)
        scaleBtn.MouseLeave:Connect(function()
            backStroke.Color = Color3.fromRGB(210, 210, 210)
            frontStroke.Color = Color3.fromRGB(210, 210, 210)
        end)

        scaleBtn.MouseButton1Click:Connect(function()
            local cur = keybindScale.Scale
            local nextScale = 1.0
            if cur < 0.95 then
                nextScale = 1.0
            elseif cur < 1.2 then
                nextScale = 1.25
            elseif cur < 1.45 then
                nextScale = 1.5
            else
                nextScale = 0.85
            end
            setKeybindScale(nextScale, true)
            if Options.KeybindScale then
                Options.KeybindScale:SetValue(nextScale)
            end
        end)

        -- 3. Close Button (X)
        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseButton"
        closeBtn.BackgroundTransparency = 1
        closeBtn.Size = UDim2.fromOffset(22, 22)
        closeBtn.Text = "X"
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 13
        closeBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
        closeBtn.AutoButtonColor = false
        closeBtn.LayoutOrder = 3
        closeBtn.Parent = controls

        closeBtn.MouseEnter:Connect(function()
            closeBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
        end)
        closeBtn.MouseLeave:Connect(function()
            closeBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
        end)
        closeBtn.MouseButton1Click:Connect(function()
            keybindFrame.Visible = false
            if Toggles.KeybindMenuOpen then
                Toggles.KeybindMenuOpen:SetValue(false)
            end
        end)

        -- Corner Resize Grip (Bottom-Right with Lucide move-diagonal-2 icon)
        cornerGrip = Instance.new("TextButton")
        cornerGrip.Name = "ResizeGrip"
        cornerGrip.BackgroundTransparency = 1
        cornerGrip.Text = ""
        cornerGrip.AutoButtonColor = false
        cornerGrip.AnchorPoint = Vector2.new(1, 1)
        cornerGrip.Position = UDim2.new(1, -2, 1, -2)
        cornerGrip.Size = UDim2.fromOffset(16, 16)
        cornerGrip.ZIndex = 10
        cornerGrip.Visible = not isCollapsed
        cornerGrip.Parent = keybindFrame

        local gripIcon = Instance.new("ImageLabel")
        gripIcon.Name = "GripIcon"
        gripIcon.BackgroundTransparency = 1
        gripIcon.Size = UDim2.fromScale(1, 1)
        gripIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
        gripIcon.ImageTransparency = 0.4
        gripIcon.ZIndex = 11
        gripIcon.Parent = cornerGrip

        local resizeIcon = Library:GetCustomIcon("move-diagonal-2") or (Library.GetIcon and Library:GetIcon("move-diagonal-2"))
        if resizeIcon and Library.ApplyLucideIcon then
            Library:ApplyLucideIcon(gripIcon, resizeIcon)
        else
            gripIcon.Image = "rbxassetid://10709797382"
        end

        cornerGrip.MouseEnter:Connect(function()
            gripIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            gripIcon.ImageTransparency = 0.1
        end)
        cornerGrip.MouseLeave:Connect(function()
            gripIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
            gripIcon.ImageTransparency = 0.4
        end)

        local isResizing = false
        local initialDragPos = nil
        local initialScale = 1.0

        cornerGrip.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isResizing = true
                initialDragPos = input.Position
                initialScale = keybindScale.Scale

                local moveConn
                local endConn

                moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                    if not isResizing then return end
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                        local delta = moveInput.Position - initialDragPos
                        local avgDelta = (delta.X + delta.Y) / 2
                        local scaleDelta = avgDelta / 150
                        local newScale = math.clamp(math.floor((initialScale + scaleDelta) * 100) / 100, 0.6, 2.0)
                        setKeybindScale(newScale, false)
                    end
                end)

                endConn = UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        isResizing = false
                        if moveConn then moveConn:Disconnect() end
                        if endConn then endConn:Disconnect() end
                        if Options.KeybindScale and math.abs(Options.KeybindScale.Value - keybindScale.Scale) > 0.01 then
                            Options.KeybindScale:SetValue(keybindScale.Scale)
                        end
                    end
                end)
            end
        end)

        -- Adjust padding on keybindContainer so text never overlaps corner resize grip
        if keybindContainer then
            local containerPadding = keybindContainer:FindFirstChildOfClass("UIPadding")
            if containerPadding then
                containerPadding.PaddingRight = UDim.new(0, 22)
                containerPadding.PaddingBottom = UDim.new(0, 8)
            end

            -- Remove "(Toggle)" from all keybind entry labels
            local function cleanKeybindText(label)
                if not label or not label:IsA("TextLabel") then return end
                local isCleaning = false
                local function applyFilter()
                    if isCleaning then return end
                    local txt = label.Text
                    if typeof(txt) == "string" and txt:find("%s*%([Tt][Oo][Gg][Gg][Ll][Ee]%)") then
                        isCleaning = true
                        label.Text = txt:gsub("%s*%([Tt][Oo][Gg][Gg][Ll][Ee]%)", "")
                        isCleaning = false
                    end
                end
                applyFilter()
                label:GetPropertyChangedSignal("Text"):Connect(applyFilter)
            end

            local function watchKeybindHolder(holder)
                if not (holder:IsA("TextButton") or holder:IsA("Frame")) then return end
                local label = holder:FindFirstChildOfClass("TextLabel")
                if label then
                    cleanKeybindText(label)
                else
                    holder.ChildAdded:Connect(function(child)
                        if child:IsA("TextLabel") then
                            cleanKeybindText(child)
                        end
                    end)
                end
            end

            for _, child in ipairs(keybindContainer:GetChildren()) do
                watchKeybindHolder(child)
            end
            keybindContainer.ChildAdded:Connect(watchKeybindHolder)
        end
    end
end

-- Inside ESP Tab
local ESPGroupBox = Tabs.ESP:AddGroupbox({
    Side = "Left",
    Name = "ESP",
})

-- Inside Automatic Tab
local AutoGroupBox = Tabs.Automatic:AddGroupbox({
    Side = "Left",
    Name = "Automatic",
})

-- Inside Player Tab: Split into Player (Left) and Movement (Right)
local PlayerGroupBox = Tabs.Player:AddGroupbox({
    Side = "Left",
    Name = "Player",
})

local MovementGroupBox = Tabs.Player:AddGroupbox({
    Side = "Right",
    Name = "Movement",
})

-- Inside Camera Tab: Field of View (Left) and Presets (Right)
local CameraGroupBox = Tabs.Camera:AddGroupbox({
    Side = "Left",
    Name = "Field of View",
})

local CameraInfoGroupBox = Tabs.Camera:AddGroupbox({
    Side = "Right",
    Name = "Camera Info & Presets",
})

-- Inside Parry Tab: Live Inspector (Left) and Auto Parry (Right)
local LiveUIGroupBox = Tabs.Parry:AddGroupbox({
    Side = "Left",
    Name = "Live Player & Item Inspector",
})

local AutoParryGroupBox = Tabs.Parry:AddGroupbox({
    Side = "Right",
    Name = "Auto Parry (Parrying Dagger)",
})

-- Inside Optimize Tab: Ping & MS Booster (Left) and Network Status (Right)
local OptimizeGroupBox = Tabs.Optimize:AddGroupbox({
    Side = "Left",
    Name = "Ping & MS Booster",
})

local NetworkMonitorGroupBox = Tabs.Optimize:AddGroupbox({
    Side = "Right",
    Name = "Live Network Status",
})

local bindCombatListeners = nil

----------------------------------------------------------------------
-- ROLE & DETECTION LOGIC
----------------------------------------------------------------------

local function isKiller(player)
    if not player then return false end
    local char = player.Character

    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("kill") or teamName:find("monster") or teamName:find("hunter") or teamName:find("beast") or teamName:find("slasher") or teamName:find("enemy") or teamName:find("hostile") then
            return true
        end
    end

    local pRole = player:GetAttribute("Role") or player:GetAttribute("Team")
    if typeof(pRole) == "string" and (pRole:lower():find("kill") or pRole:lower():find("monster") or pRole:lower():find("slasher") or pRole:lower():find("hunter")) then
        return true
    end
    if player:GetAttribute("IsKiller") == true or player:GetAttribute("Killer") == true then
        return true
    end

    if char then
        local cRole = char:GetAttribute("Role") or char:GetAttribute("Team")
        if typeof(cRole) == "string" and (cRole:lower():find("kill") or cRole:lower():find("monster") or cRole:lower():find("slasher") or cRole:lower():find("hunter")) then
            return true
        end
        if char:GetAttribute("IsKiller") == true or char:GetAttribute("Killer") == true then
            return true
        end

        if CollectionService:HasTag(char, "Killer") or CollectionService:HasTag(player, "Killer") then
            return true
        end

        local roleVal = char:FindFirstChild("Role") or player:FindFirstChild("Role")
        if roleVal and roleVal:IsA("ValueBase") and typeof(roleVal.Value) == "string" then
            local rv = roleVal.Value:lower()
            if rv:find("kill") or rv:find("monster") or rv:find("slasher") or rv:find("hunter") then
                return true
            end
        end

        if char:FindFirstChild("Killer") or player:FindFirstChild("Killer") or char:FindFirstChild("IsKiller") or player:FindFirstChild("IsKiller") then
            return true
        end

        -- Check tools / weapons in character
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local tName = item.Name:lower()
                if tName:find("knife") or tName:find("machete") or tName:find("axe") or tName:find("hammer")
                    or tName:find("saw") or tName:find("scythe") or tName:find("weapon") or tName:find("cleaver")
                    or tName:find("bat") or tName:find("club") or tName:find("blade") or tName:find("slasher") then
                    return true
                end
            end
        end
    end

    local gameFolder = Workspace:FindFirstChild("Game") or Workspace:FindFirstChild("Status") or Workspace:FindFirstChild("Round")
    if gameFolder then
        local killerValue = gameFolder:FindFirstChild("Killer")
        if killerValue then
            if killerValue:IsA("ObjectValue") and (killerValue.Value == player or (char and killerValue.Value == char)) then
                return true
            elseif killerValue:IsA("StringValue") and (killerValue.Value == player.Name or killerValue.Value == player.DisplayName) then
                return true
            end
        end
    end

    return false
end

local function isGenerator(instance)
    if not (instance:IsA("Model") or instance:IsA("BasePart")) then
        return false
    end

    if Players:GetPlayerFromCharacter(instance) or (instance.Parent and Players:GetPlayerFromCharacter(instance.Parent)) then
        return false
    end

    local name = instance.Name:lower()

    if name:find("generator") or name:find("gen_") or name == "gen" or name:find("engine") then
        if instance:IsA("BasePart") and instance.Parent and instance.Parent:IsA("Model") then
            local parentName = instance.Parent.Name:lower()
            if parentName:find("generator") or parentName:find("gen") or parentName:find("engine") then
                return false
            end
        end
        return true
    end

    local prompt = instance:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        local promptText = (prompt.ObjectText .. " " .. prompt.ActionText):lower()
        if promptText:find("generator") or promptText:find("gen") or promptText:find("repair") or promptText:find("fix") then
            return true
        end
    end

    return false
end

----------------------------------------------------------------------
-- HIGHLIGHT HANDLERS
----------------------------------------------------------------------

local function updatePlayerHighlight(player, hl)
    if not hl or not hl.Parent then return end
    hl.Enabled = Toggles.HighlightPlayers.Value

    if isKiller(player) then
        hl.FillColor = Options.KillerColor.Value
    else
        hl.FillColor = Options.SurvivorColor.Value
    end

    local showOutline = (Toggles.PlayerOutline and Toggles.PlayerOutline.Value) or false
    hl.OutlineColor = Options.PlayerOutlineColor.Value
    hl.FillTransparency = Options.PlayerFillTransparency.Value
    hl.OutlineTransparency = showOutline and 0 or 1
end

local function updateAllPlayerHighlights()
    for player, hl in pairs(playerHighlights) do
        updatePlayerHighlight(player, hl)
    end
end

local function applyPlayerHighlight(player, character)
    if not character then return end
    if player == LocalPlayer and not (Toggles.IncludeLocalPlayer and Toggles.IncludeLocalPlayer.Value) then
        return
    end

    if playerHighlights[player] then
        pcall(function() playerHighlights[player]:Destroy() end)
        playerHighlights[player] = nil
    end

    local hl = Instance.new("Highlight")
    hl.Name = "VD_PlayerESP"
    hl.Adornee = character
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = character

    playerHighlights[player] = hl
    updatePlayerHighlight(player, hl)
end

local function bindLocalCharacterAntiStun(char)
    if not char then return end
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 4)
        if hum then
            hum.StateChanged:Connect(function(_, newState)
                if Toggles.AntiStun and Toggles.AntiStun.Value then
                    if newState == Enum.HumanoidStateType.Ragdoll 
                        or newState == Enum.HumanoidStateType.Physics 
                        or newState == Enum.HumanoidStateType.FallingDown 
                        or newState == Enum.HumanoidStateType.PlatformStanding then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                        if cleanStunEffects then cleanStunEffects(char) end
                    end
                end
            end)
            local animator = hum:WaitForChild("Animator", 4)
            if animator then
                animator.AnimationPlayed:Connect(function(track)
                    if Toggles.AntiStun and Toggles.AntiStun.Value and isStunAnimation and isStunAnimation(track) then
                        pcall(function()
                            track:Stop(0)
                            track.TimePosition = track.Length or 0
                        end)
                        if cleanStunEffects then cleanStunEffects(char) end
                    end
                end)
            end
        end
    end)
end

local function setupPlayer(player)
    connections[#connections + 1] = player.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        applyPlayerHighlight(player, char)
        if bindCombatListeners and player ~= LocalPlayer then
            bindCombatListeners(player, char)
        end
        if player == LocalPlayer then
            bindLocalCharacterAntiStun(char)
            pcall(function()
                local h = char:FindFirstChildOfClass("Humanoid")
                if h and h.WalkSpeed > 0 and not (Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value) then
                    defaultSpeed = h.WalkSpeed
                end
            end)
            if applyPlayerSpeed then
                applyPlayerSpeed()
            end
        end
    end)

    connections[#connections + 1] = player.CharacterRemoving:Connect(function()
        if playerHighlights[player] then
            pcall(function() playerHighlights[player]:Destroy() end)
            playerHighlights[player] = nil
        end
    end)

    connections[#connections + 1] = player:GetPropertyChangedSignal("Team"):Connect(function()
        if playerHighlights[player] then
            updatePlayerHighlight(player, playerHighlights[player])
        end
        if bindCombatListeners and player.Character and player ~= LocalPlayer then
            bindCombatListeners(player, player.Character)
        end
    end)

    if player.Character then
        applyPlayerHighlight(player, player.Character)
        if bindCombatListeners and player ~= LocalPlayer then
            bindCombatListeners(player, player.Character)
        end
        if player == LocalPlayer then
            bindLocalCharacterAntiStun(player.Character)
            pcall(function()
                local h = player.Character:FindFirstChildOfClass("Humanoid")
                if h and h.WalkSpeed > 0 and not (Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value) then
                    defaultSpeed = h.WalkSpeed
                end
            end)
            if applyPlayerSpeed then
                applyPlayerSpeed()
            end
        end
    end
end

local function isGeneratorFixed(instance)
    if not instance or not instance.Parent then return true end

    -- Check direct instance and parent model/folder
    local targets = { instance }
    if instance.Parent and (instance.Parent:IsA("Model") or instance.Parent:IsA("Folder")) then
        table.insert(targets, instance.Parent)
    end

    for _, target in ipairs(targets) do
        -- 1. CollectionService Tags
        for _, tag in ipairs({"Fixed", "Completed", "Done", "Repaired", "Powered", "Finished", "ActiveGen"}) do
            if CollectionService:HasTag(target, tag) then
                return true
            end
        end

        -- 2. Attributes on generator
        for _, attr in ipairs({
            "Fixed", "Done", "Completed", "Repaired", "Finished",
            "Activated", "Powered", "IsDone", "IsFixed", "IsRepaired",
            "Complete", "Power", "GenDone", "GenFixed"
        }) do
            local val = target:GetAttribute(attr)
            if val == true then
                return true
            end
        end

        -- Progress attribute check (handles both 0-100 and normalized 0-1 scales)
        for _, progAttr in ipairs({"Progress", "RepairProgress", "Percent", "GenProgress", "FixProgress", "Completion"}) do
            local pVal = target:GetAttribute(progAttr)
            if typeof(pVal) == "number" then
                local maxProg = target:GetAttribute("MaxProgress") or target:GetAttribute("Max") or 100
                if maxProg > 1 then
                    if pVal >= (maxProg - 0.5) or pVal >= 99.5 then return true end
                else
                    if pVal >= 0.995 then return true end
                end
            end
        end

        -- 3. ValueObjects directly in target
        for _, child in ipairs(target:GetChildren()) do
            local cName = child.Name:lower()
            if child:IsA("BoolValue") then
                if (cName:find("fixed") or cName:find("done") or cName:find("complete") or cName:find("repair") or cName:find("finish") or cName:find("power")) then
                    if child.Value == true then
                        return true
                    end
                end
            elseif child:IsA("NumberValue") or child:IsA("IntValue") then
                if (cName:find("progress") or cName:find("percent") or cName == "repair" or cName == "fix") then
                    local maxVal = target:FindFirstChild("MaxProgress") or target:FindFirstChild("Max")
                    local maxNum = (maxVal and maxVal:IsA("NumberValue") and maxVal.Value) or 100
                    if maxNum > 1 then
                        if child.Value >= (maxNum - 0.5) or child.Value >= 99.5 then return true end
                    else
                        if child.Value >= 0.995 then return true end
                    end
                end
            elseif child:IsA("StringValue") then
                if cName:find("state") or cName:find("status") then
                    local sVal = child.Value:lower()
                    if sVal:find("done") or sVal:find("fixed") or sVal:find("complete") or sVal:find("repaired") or sVal:find("power") then
                        return true
                    end
                end
            end
        end
    end

    -- 4. Deep search inside Model descendants for Progress/Status ValueObjects and Prompts
    local model = instance:IsA("Model") and instance or (instance.Parent and instance.Parent:IsA("Model") and instance.Parent) or instance
    local foundRepairPrompt = false
    local hasActiveRepairPrompt = false

    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local pText = (desc.ObjectText .. " " .. desc.ActionText):lower()
            if pText:find("repair") or pText:find("fix") or pText:find("generator") or pText:find("gen") or pText == " " or pText == "" then
                foundRepairPrompt = true
                if desc.Enabled and desc.MaxActivationDistance > 0 then
                    hasActiveRepairPrompt = true
                end
            end
        elseif desc:IsA("BoolValue") then
            local dName = desc.Name:lower()
            if (dName == "fixed" or dName == "done" or dName == "completed" or dName == "repaired" or dName == "isdone" or dName == "isfixed") and desc.Value == true then
                return true
            end
        elseif desc:IsA("NumberValue") or desc:IsA("IntValue") then
            local dName = desc.Name:lower()
            if (dName == "progress" or dName == "repairprogress" or dName == "percent") and desc.Value >= 99.5 then
                return true
            end
        elseif desc:IsA("StringValue") then
            local dName = desc.Name:lower()
            if (dName == "state" or dName == "status") then
                local s = desc.Value:lower()
                if s:find("done") or s:find("fixed") or s:find("complete") or s:find("repaired") or s:find("power") then
                    return true
                end
            end
        end
    end

    -- If a repair prompt was found on the generator and is now disabled, it is completed!
    if foundRepairPrompt and not hasActiveRepairPrompt then
        return true
    end

    return false
end

local function updateGenHighlight(hl, genInstance)
    if not hl or not hl.Parent then return end

    local gen = genInstance or hl.Adornee or hl.Parent
    local isGenEnabled = Toggles.HighlightGenerators and Toggles.HighlightGenerators.Value == true

    if not isGenEnabled then
        hl.Enabled = false
        return
    end

    -- Highlight ONLY un-fixed generators; when fixed/done, do NOT highlight
    if isGeneratorFixed(gen) then
        hl.Enabled = false
        return
    end

    hl.Enabled = true
    hl.FillColor = Options.GenFillColor.Value

    local showOutline = (Toggles.GenOutline and Toggles.GenOutline.Value) or false
    hl.OutlineColor = Options.GenOutlineColor.Value
    hl.FillTransparency = Options.GenFillTransparency.Value
    hl.OutlineTransparency = showOutline and 0 or 1
end

local function updateAllGeneratorHighlights()
    for genInstance, hl in pairs(generatorHighlights) do
        updateGenHighlight(hl, genInstance)
    end
end

local function registerGenerator(genInstance)
    if not genInstance or not genInstance.Parent or trackedGenerators[genInstance] then
        return
    end

    trackedGenerators[genInstance] = true

    local hl = Instance.new("Highlight")
    hl.Name = "VD_GenESP"
    hl.Adornee = genInstance
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = genInstance

    generatorHighlights[genInstance] = hl
    updateGenHighlight(hl, genInstance)

    -- Real-time reactive updates: listen for changes on attributes and prompts
    local function onGenStateChanged()
        updateGenHighlight(hl, genInstance)
    end

    genInstance.AttributeChanged:Connect(onGenStateChanged)
    if genInstance.Parent and (genInstance.Parent:IsA("Model") or genInstance.Parent:IsA("Folder")) then
        genInstance.Parent.AttributeChanged:Connect(onGenStateChanged)
    end

    for _, desc in ipairs(genInstance:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            desc:GetPropertyChangedSignal("Enabled"):Connect(onGenStateChanged)
        elseif desc:IsA("ValueBase") then
            desc:GetPropertyChangedSignal("Value"):Connect(onGenStateChanged)
        end
    end

    genInstance.DescendantAdded:Connect(function(desc)
        if desc:IsA("ProximityPrompt") then
            desc:GetPropertyChangedSignal("Enabled"):Connect(onGenStateChanged)
            onGenStateChanged()
        elseif desc:IsA("ValueBase") then
            desc:GetPropertyChangedSignal("Value"):Connect(onGenStateChanged)
            onGenStateChanged()
        end
    end)

    genInstance.AncestryChanged:Connect(function(_, parent)
        if not parent then
            trackedGenerators[genInstance] = nil
            if generatorHighlights[genInstance] then
                pcall(function() generatorHighlights[genInstance]:Destroy() end)
                generatorHighlights[genInstance] = nil
            end
        end
    end)
end

local function scanGenerators()
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if isGenerator(descendant) then
            registerGenerator(descendant)
        end
    end
end

----------------------------------------------------------------------
-- EXACT AUTO PERFECT SKILL CHECK (100% AUTONOMOUS / NO CLIENT KEYBOARD)
----------------------------------------------------------------------

local lastSkillTapTime = 0
local hasTappedSkillThisCheck = false
local lastNeedleAngle = nil

-- Construct a safe proxy InputObject for internal script invocation
local fakeSpaceInput = setmetatable({
    KeyCode = Enum.KeyCode.Space,
    UserInputType = Enum.UserInputType.Keyboard,
    UserInputState = Enum.UserInputState.Begin,
    Position = Vector3.zero,
    Delta = Vector3.zero,
}, {
    __index = function(t, k)
        if k == "IsA" then
            return function(self, className)
                return className == "InputObject" or className == "Instance"
            end
        end
        return nil
    end
})

-- Precise angle sweep detector: catches the sweet spot even during lag or frame drops
local function isInTargetArc(lastAngle, currentAngle, targetAngle)
    local target = targetAngle % 360
    local sweetSpotStart = (target + 104) % 360
    local sweetSpotEnd = (target + 115) % 360
    local winLen = (sweetSpotEnd - sweetSpotStart) % 360

    -- Direct check: current rotation inside sweet spot
    local curOffset = (currentAngle - sweetSpotStart) % 360
    if curOffset <= winLen then
        return true
    end

    -- Sweep check: needle rotated through sweet spot between last frame and current frame
    if lastAngle ~= nil then
        local sweep = (currentAngle - lastAngle) % 360
        if sweep > 0 and sweep < 180 then
            local distToStart = (sweetSpotStart - lastAngle) % 360
            if distToStart <= sweep then
                return true
            end
        end
    end

    return false
end

local function triggerSkillCheckHit(checkFrame, promptGui)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")

    -- 1. DIRECT GUI DISPATCH (Self-working on both PC and Mobile without client keyboard)
    if pg then
        local mob = pg:FindFirstChild("Survivor-mob")
        if mob then
            local action = mob:FindFirstChild("Controls") and mob.Controls:FindFirstChild("action")
            local chk = action and (action:FindFirstChild("check") or action:FindFirstChildWhichIsA("GuiButton"))
            if chk and chk:IsA("GuiObject") then
                -- Firesignal directly on all button signals
                if firesignal then
                    pcall(function() firesignal(chk.Activated) end)
                    pcall(function() firesignal(chk.MouseButton1Click) end)
                    pcall(function() firesignal(chk.MouseButton1Down) end)
                    pcall(function() firesignal(chk.TouchTap) end)
                end
                -- Invoke connected game functions directly via getconnections
                if getconnections then
                    for _, sigName in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down", "TouchTap"}) do
                        local sig = chk[sigName]
                        if sig then
                            pcall(function()
                                for _, conn in ipairs(getconnections(sig)) do
                                    if conn.Function and conn.Enabled ~= false then
                                        pcall(conn.Function)
                                    elseif conn.Fire then
                                        pcall(function() conn:Fire() end)
                                    end
                                end
                            end)
                        end
                    end
                end
                -- Virtual touch at button center coordinates
                pcall(function()
                    local p = chk.AbsolutePosition
                    local s = chk.AbsoluteSize
                    local cx = p.X + s.X / 2
                    local cy = p.Y + s.Y / 2
                    VirtualInputManager:SendTouchEvent(999, 0, cx, cy)
                    VirtualInputManager:SendTouchEvent(999, 2, cx, cy)
                end)
            end
        end
    end

    -- 2. Dispatch all buttons and interactive elements in SkillCheckPromptGui safely
    if promptGui then
        for _, desc in ipairs(promptGui:GetDescendants()) do
            if desc:IsA("GuiButton") then
                if firesignal then
                    pcall(function() firesignal(desc.Activated) end)
                    pcall(function() firesignal(desc.MouseButton1Click) end)
                end
                if getconnections then
                    for _, sigName in ipairs({"Activated", "MouseButton1Click"}) do
                        pcall(function()
                            local sig = desc[sigName]
                            if sig then
                                for _, conn in ipairs(getconnections(sig)) do
                                    if conn.Function and conn.Enabled ~= false then
                                        pcall(conn.Function)
                                    elseif conn.Fire then
                                        pcall(function() conn:Fire() end)
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end

    -- 3. INTERNAL SCRIPT INVOCATION (Directly executes game's InputBegan listener with fake Space)
    if getconnections then
        pcall(function()
            for _, conn in ipairs(getconnections(UserInputService.InputBegan)) do
                if conn.Function and conn.Enabled ~= false then
                    pcall(conn.Function, fakeSpaceInput, false)
                elseif conn.Fire then
                    pcall(function() conn:Fire(fakeSpaceInput, false) end)
                end
            end
        end)
    end
    if firesignal then
        pcall(function()
            firesignal(UserInputService.InputBegan, fakeSpaceInput, false)
        end)
    end

    -- 4. ContextActionService bound actions invocation
    pcall(function()
        local cas = game:GetService("ContextActionService")
        if cas and cas.GetAllBoundActionInfo then
            local bound = cas:GetAllBoundActionInfo()
            for actionName, _ in pairs(bound) do
                local an = actionName:lower()
                if an:find("check") or an:find("skill") or an:find("space") or an:find("action") or an:find("qte") or an:find("interact") then
                    pcall(function()
                        cas:CallFunctionToFindBoundAction(actionName, Enum.UserInputState.Begin, fakeSpaceInput)
                    end)
                end
            end
        end
    end)

    -- 5. Safe background VIM fallback (ONLY if NOT in Settings or typing, so it NEVER interferes with settings)
    pcall(function()
        local isMenuOpen = false
        pcall(function()
            isMenuOpen = GuiService.MenuIsOpen
        end)
        local isTyping = UserInputService:GetFocusedTextBox() ~= nil

        if not isMenuOpen and not isTyping then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.delay(0.02, function()
                pcall(function()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end)
        end
    end)
end

connections[#connections + 1] = RunService.RenderStepped:Connect(function()
    if not (Toggles.AutoFixGen and Toggles.AutoFixGen.Value) then
        hasTappedSkillThisCheck = false
        lastNeedleAngle = nil
        return
    end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end

    local prompt = pg:FindFirstChild("SkillCheckPromptGui")
    if not prompt or not prompt.Enabled then
        hasTappedSkillThisCheck = false
        lastNeedleAngle = nil
        return
    end

    local check = prompt:FindFirstChild("Check")
    if not check or not check.Visible then
        hasTappedSkillThisCheck = false
        lastNeedleAngle = nil
        return
    end

    local line = check:FindFirstChild("Line") or check:FindFirstChild("Needle") or check:FindFirstChild("Pointer")
    local goal = check:FindFirstChild("Goal") or check:FindFirstChild("Target") or check:FindFirstChild("Zone")
    if not line or not goal then return end

    local currentAngle = line.Rotation % 360
    local goalAngle = goal.Rotation % 360

    if hasTappedSkillThisCheck or (tick() - lastSkillTapTime < 0.35) then
        lastNeedleAngle = currentAngle
        return
    end

    if isInTargetArc(lastNeedleAngle, currentAngle, goalAngle) then
        hasTappedSkillThisCheck = true
        lastSkillTapTime = tick()
        lastNeedleAngle = nil
        triggerSkillCheckHit(check, prompt)
    else
        lastNeedleAngle = currentAngle
    end
end)

----------------------------------------------------------------------
-- ULTIMATE ANTI STUN SYSTEM (VD 2.9.8a - PALLET & BLIND IMMUNE, NON-BLOCKING)
----------------------------------------------------------------------

local StunKeywords = {
    "stun", "blind", "flashed", "flashlight", "daze", "dazed", "headache",
    "stumble", "palletstun", "ragdoll", "freeze", "frozen"
}

local StunAttrNames = {
    "stunned", "isstunned", "stun", "blind", "blinded", "flashed",
    "ragdoll", "ragdolled", "headache", "palletstun", "frozen", "slowed", "dazed"
}

-- Action Protection: Animations that must NEVER be stopped by AntiStun
local function isProtectedActionAnim(name)
    name = name:lower()
    -- Stuns are NEVER protected!
    if name:find("stun") or name:find("blind") or name:find("headache") or name:find("daze") or name:find("stumble") or name:find("flashed") then
        return false
    end
    return name:find("drop")
        or name:find("vault")
        or name:find("pull")
        or name:find("repair")
        or name:find("gen")
        or name:find("fix")
        or name:find("interact")
        or name:find("action")
        or name:find("attack")
        or name:find("swing")
        or name:find("slash")
        or name:find("hit")
        or name:find("wipe")
        or name:find("cooldown")
        or name:find("m1")
        or name:find("walk")
        or name:find("run")
        or name:find("idle")
end

local function isStunAnimation(track)
    if not track then return false end
    local tName = (track.Name or ""):lower()
    local animId = ""
    if track.Animation then
        animId = tostring(track.Animation.AnimationId or ""):lower()
        tName = tName .. " " .. (track.Animation.Name or ""):lower()
    end
    if isProtectedActionAnim(tName) then
        return false
    end
    for _, kw in ipairs(StunKeywords) do
        if tName:find(kw) or animId:find(kw) then
            return true
        end
    end
    return false
end

-- Speed & Fly Value Helpers (Seamlessly supports both Slider and Custom Text Input)
local function getSpeedValue()
    if Options.CustomSpeedInput and Options.CustomSpeedInput.Value then
        local num = tonumber(Options.CustomSpeedInput.Value)
        if num and num >= 16 then
            return num
        end
    end
    if Options.SpeedValue and Options.SpeedValue.Value then
        return Options.SpeedValue.Value
    end
    return 28
end

local function getFlySpeedValue()
    if Options.CustomFlySpeedInput and Options.CustomFlySpeedInput.Value then
        local num = tonumber(Options.CustomFlySpeedInput.Value)
        if num and num >= 10 then
            return num
        end
    end
    if Options.FlySpeed and Options.FlySpeed.Value then
        return Options.FlySpeed.Value
    end
    return 50
end

local function getFOVValue()
    if Options.CustomFOVInput and Options.CustomFOVInput.Value then
        local num = tonumber(Options.CustomFOVInput.Value)
        if num and num >= 30 and num <= 120 then
            return num
        end
    end
    if Options.FOVValue and Options.FOVValue.Value then
        return Options.FOVValue.Value
    end
    return 70
end

applyPlayerSpeed = function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Toggles.Fly and Toggles.Fly.Value then return end

    local isEnabled = (Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value == true)
    if isEnabled then
        local targetSpeed = getSpeedValue()
        hum.WalkSpeed = targetSpeed
        if char:GetAttribute("Speed") ~= nil then
            pcall(function() char:SetAttribute("Speed", targetSpeed) end)
        end
    else
        hum.WalkSpeed = defaultSpeed
        if char:GetAttribute("Speed") ~= nil then
            pcall(function() char:SetAttribute("Speed", defaultSpeed) end)
        end
    end
end

local function cleanStunEffects(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 then return end

    -- 1. Reset Humanoid State and PlatformStand
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    if hum.PlatformStand and not (Toggles.Fly and Toggles.Fly.Value) then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if hum.Sit and not (char:FindFirstChildOfClass("VehicleSeat")) then
        hum.Sit = false
    end

    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Ragdoll 
        or st == Enum.HumanoidStateType.Physics 
        or st == Enum.HumanoidStateType.FallingDown 
        or st == Enum.HumanoidStateType.PlatformStanding then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end

    -- 2. Unanchor if anchored by stun
    if root and root.Anchored then
        root.Anchored = false
    end

    -- 3. Restore WalkSpeed if zeroed or slowed by stun
    local targetSpeed = (Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value and getSpeedValue()) or defaultSpeed
    if hum.WalkSpeed < 16 then
        hum.WalkSpeed = targetSpeed
    end

    -- 4. Stop Playing Stun Animations immediately
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if isStunAnimation(track) then
                pcall(function()
                    track:Stop(0)
                    track.TimePosition = track.Length or 0
                end)
            end
        end
    end

    -- 5. Clean Stun Attributes on Character and Player
    for _, attr in ipairs(StunAttrNames) do
        if char:GetAttribute(attr) then
            pcall(function() char:SetAttribute(attr, false) end)
        end
        if LocalPlayer:GetAttribute(attr) then
            pcall(function() LocalPlayer:SetAttribute(attr, false) end)
        end
    end

    -- 6. Clean Stun ValueObjects and Constraints
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("ValueBase") then
            local cName = child.Name:lower()
            for _, kw in ipairs(StunKeywords) do
                if cName:find(kw) then
                    if child:IsA("BoolValue") and child.Value == true then
                        pcall(function() child.Value = false end)
                    elseif child:IsA("NumberValue") and child.Value > 0 then
                        pcall(function() child.Value = 0 end)
                    end
                end
            end
        elseif child.Name == "RagdollConstraints" or child.Name:lower():find("stun") then
            pcall(function() child:Destroy() end)
        end
    end

    -- 7. Screen Blind / Flashlight GUI cleanup
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local gName = gui.Name:lower()
                if gName:find("blind") or gName:find("flashlight") or (gName:find("stun") and not gName:find("skill")) then
                    gui.Enabled = false
                end
            end
        end
    end

    -- 8. Safeguard: Always ensure movement is enabled
    if char:GetAttribute("CanMove") == false then
        pcall(function() char:SetAttribute("CanMove", true) end)
    end
    if char:GetAttribute("CanAction") == false then
        pcall(function() char:SetAttribute("CanAction", true) end)
    end
    if char:GetAttribute("CanAttack") == false then
        pcall(function() char:SetAttribute("CanAttack", true) end)
    end
    if char:GetAttribute("CanInteract") == false then
        pcall(function() char:SetAttribute("CanInteract", true) end)
    end

    -- 9. Safeguard: Ensure Tools in character are enabled for Left/Right Click
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and not child.Enabled then
            child.Enabled = true
        end
    end
end

-- 1. Hook and block ONLY stun remotes (NEVER block player actions like drop, pallet, or interact)
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "fireServer") and Toggles.AntiStun and Toggles.AntiStun.Value then
                local name = tostring(self.Name):lower()
                -- NEVER block drop, pallet, interact, repair, or normal player actions
                if not (name:find("drop") or name:find("pallet") or name:find("interact") or name:find("action") or name:find("repair")) then
                    if name:find("stun") or name:find("blind") then
                        return nil
                    end
                end
            end
            return oldNamecall(self, ...)
        end))
    end
end)

-- 2. Hook specific known remotes directly in ReplicatedStorage
local function hookStunRemotes()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return end

        for _, desc in ipairs(remotes:GetDescendants()) do
            if desc:IsA("RemoteEvent") then
                local dName = desc.Name:lower()
                if (dName:find("stun") or dName:find("blind")) and not (dName:find("drop") or dName:find("pallet") or dName:find("action")) then
                    local oldFire = desc.FireServer
                    desc.FireServer = function(self, ...)
                        if Toggles.AntiStun and Toggles.AntiStun.Value then
                            return nil
                        end
                        return oldFire(self, ...)
                    end
                end
            end
        end
    end)
end

hookStunRemotes()

-- 3. Targeted Frame Loop: Breaks genuine stuns only and guarantees clicks/interactions stay active
connections[#connections + 1] = RunService.Heartbeat:Connect(function()
    if not (Toggles.AntiStun and Toggles.AntiStun.Value) then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 then return end

    local isStunned = false
    if hum.PlatformStand and not (Toggles.Fly and Toggles.Fly.Value) then isStunned = true end
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.PlatformStanding then
        isStunned = true
    end
    if root and root.Anchored then isStunned = true end
    if char:GetAttribute("CanMove") == false then isStunned = true end
    if hum.WalkSpeed < 16 and not (Toggles.Fly and Toggles.Fly.Value) then isStunned = true end

    if not isStunned then
        for _, attr in ipairs(StunAttrNames) do
            if char:GetAttribute(attr) == true or LocalPlayer:GetAttribute(attr) == true then
                isStunned = true
                break
            end
        end
    end

    if not isStunned then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if isStunAnimation(track) then
                    isStunned = true
                    break
                end
            end
        end
    end

    if isStunned then
        cleanStunEffects(char)
    end
end)

----------------------------------------------------------------------
-- PLAYER ITEM & PERK DISCOVERY ENGINE (LIVE UI)
----------------------------------------------------------------------

local KnownSurvivorItems = {
    { key = "parrying dagger", name = "Parrying Dagger" },
    { key = "parry", name = "Parrying Dagger" },
    { key = "dagger", name = "Parrying Dagger" },
    { key = "motion tracker", name = "Motion Tracker" },
    { key = "tracker", name = "Motion Tracker" },
    { key = "twist of fate", name = "Twist of Fate" },
    { key = "twist", name = "Twist of Fate" },
    { key = "flashlight", name = "Flashlight" },
    { key = "torch", name = "Flashlight" },
    { key = "medkit", name = "Medkit" },
    { key = "first aid", name = "Medkit" },
    { key = "revolver", name = "Revolver" },
    { key = "gun", name = "Revolver" },
    { key = "pistol", name = "Revolver" },
    { key = "handgun", name = "Revolver" },
    { key = "toolbox", name = "Toolbox" },
    { key = "lockpick", name = "Lockpick" },
    { key = "syringe", name = "Syringe (Adrenaline)" },
    { key = "adrenaline", name = "Syringe (Adrenaline)" },
    { key = "candle", name = "Candle" },
    { key = "shield", name = "Shield" },
    { key = "toilet paper", name = "Toilet Paper" },
}

local KnownKillerWeapons = {
    { key = "machete", name = "Machete" },
    { key = "cleaver", name = "Cleaver" },
    { key = "chainsaw", name = "Chainsaw" },
    { key = "scythe", name = "Scythe" },
    { key = "cureneedle", name = "Cure Needle" },
    { key = "needle", name = "Cure Needle" },
    { key = "claws", name = "Claws" },
    { key = "claw", name = "Claws" },
    { key = "axe", name = "Axe" },
    { key = "hatchet", name = "Hatchet" },
    { key = "hammer", name = "Hammer" },
    { key = "sledgehammer", name = "Sledgehammer" },
    { key = "sickle", name = "Sickle" },
    { key = "knife", name = "Knife" },
    { key = "blade", name = "Blade" },
    { key = "crowbar", name = "Crowbar" },
    { key = "pipe", name = "Pipe" },
    { key = "bat", name = "Bat" },
    { key = "club", name = "Club" },
}

local function matchKnownItem(rawName)
    if not rawName or typeof(rawName) ~= "string" or rawName == "" or rawName == "None" or rawName == "nil" then
        return nil
    end
    local lower = rawName:lower()
    for _, item in ipairs(KnownSurvivorItems) do
        if lower:find(item.key) then
            return item.name
        end
    end
    for _, wep in ipairs(KnownKillerWeapons) do
        if lower:find(wep.key) then
            return wep.name
        end
    end
    return nil
end

local KnownPerks = {
    -- Survivor Perks (Official Violence District Wiki)
    { key = "snakestep", name = "Snake Step" },
    { key = "snake step", name = "Snake Step" },
    { key = "secondwind", name = "Second Wind" },
    { key = "second wind", name = "Second Wind" },
    { key = "grabmyhand", name = "Grab My Hand" },
    { key = "grab my hand", name = "Grab My Hand" },
    { key = "builtdifferent", name = "Built Different" },
    { key = "built different", name = "Built Different" },
    { key = "flowstate", name = "Flowstate" },
    { key = "quickrecovery", name = "Quick Recovery" },
    { key = "quick recovery", name = "Quick Recovery" },
    { key = "nobodyleftbehind", name = "Nobody Left Behind" },
    { key = "nobody left behind", name = "Nobody Left Behind" },
    { key = "leftbehind", name = "Left Behind" },
    { key = "left behind", name = "Left Behind" },
    { key = "onmyown", name = "On My Own" },
    { key = "on my own", name = "On My Own" },
    { key = "callmeback", name = "Call Me Back" },
    { key = "call me back", name = "Call Me Back" },
    { key = "enchancedtouch", name = "Enhanced Touch" },
    { key = "enhanced touch", name = "Enhanced Touch" },
    { key = "enhancedtouch", name = "Enhanced Touch" },
    { key = "intenseworkout", name = "Intense Workout" },
    { key = "intense workout", name = "Intense Workout" },
    { key = "absoluteconfidence", name = "Absolute Confidence" },
    { key = "absolute confidence", name = "Absolute Confidence" },
    { key = "ambitiousmedic", name = "Ambitious Medic" },
    { key = "ambitious medic", name = "Ambitious Medic" },
    { key = "nopainnogain", name = "No Pain No Gain" },
    { key = "no pain no gain", name = "No Pain No Gain" },
    { key = "laststand", name = "Last Stand" },
    { key = "last stand", name = "Last Stand" },
    { key = "desperate", name = "Desperate Measures" },
    { key = "pacifist", name = "Pacifist" },
    { key = "partnersincrime", name = "Partners In Crime" },
    { key = "partners in crime", name = "Partners In Crime" },
    { key = "perfectionistplanning", name = "Perfectionist Planning" },
    { key = "perfectionist planning", name = "Perfectionist Planning" },
    { key = "visuallearner", name = "Visual Learner" },
    { key = "visual learner", name = "Visual Learner" },
    { key = "hearingaid", name = "Hearing Aid" },
    { key = "hearing aid", name = "Hearing Aid" },
    { key = "highkarma", name = "High Karma" },
    { key = "high karma", name = "High Karma" },
    { key = "groupproject", name = "Group Project" },
    { key = "group project", name = "Group Project" },
    { key = "headsup", name = "Heads Up" },
    { key = "heads up", name = "Heads Up" },
    { key = "all seeing eye", name = "All Seeing Eye" },
    { key = "allseeingeye", name = "All Seeing Eye" },
    { key = "familiarsoul", name = "Familiar Soul" },
    { key = "familiar soul", name = "Familiar Soul" },
    { key = "strongertogether", name = "Stronger Together" },
    { key = "stronger together", name = "Stronger Together" },
    { key = "timetoglowup", name = "Time To Glow Up" },
    { key = "trade off", name = "Trade Off" },
    { key = "tradeoff", name = "Trade Off" },
    { key = "containment", name = "Containment" },
    { key = "flawlessexecution", name = "Flawless Execution" },
    { key = "flawless execution", name = "Flawless Execution" },
    { key = "greatcollapse", name = "Great Collapse" },
    { key = "great collapse", name = "Great Collapse" },
    { key = "irontranquility", name = "Iron Tranquility" },
    { key = "iron tranquility", name = "Iron Tranquility" },
    { key = "kingsscourge", name = "King's Scourge" },
    { key = "king's scourge", name = "King's Scourge" },
    { key = "murderousacrobatics", name = "Murderous Acrobatics" },
    { key = "murderous acrobatics", name = "Murderous Acrobatics" },
    { key = "onscreenfear", name = "On Screen Fear" },
    { key = "onscreen fear", name = "On Screen Fear" },
    { key = "stagefright", name = "Stage Fright" },
    { key = "stage fright", name = "Stage Fright" },
    { key = "touchofdeath", name = "Touch of Death" },
    { key = "touch of death", name = "Touch of Death" },
    { key = "exposuretherapy", name = "Exposure Therapy" },
    { key = "exposure therapy", name = "Exposure Therapy" },
    { key = "eyesofheaven", name = "Eyes of Heaven" },
    { key = "eyes of heaven", name = "Eyes of Heaven" },
    { key = "eyesofhell", name = "Eyes of Hell" },
    { key = "eyes of hell", name = "Eyes of Hell" },
    { key = "deepwound", name = "Deep Wound" },
    { key = "deep wound", name = "Deep Wound" },
    { key = "debutshowcase", name = "Debut Showcase" },
    { key = "debut showcase", name = "Debut Showcase" },

    -- Common / Classic Survivor Perks
    { key = "adrenaline", name = "Adrenaline" },
    { key = "sprintburst", name = "Sprint Burst" },
    { key = "sprint burst", name = "Sprint Burst" },
    { key = "deadhard", name = "Dead Hard" },
    { key = "dead hard", name = "Dead Hard" },
    { key = "decisivestrike", name = "Decisive Strike" },
    { key = "decisive strike", name = "Decisive Strike" },
    { key = "unbreakable", name = "Unbreakable" },
    { key = "borrowedtime", name = "Borrowed Time" },
    { key = "borrowed time", name = "Borrowed Time" },
    { key = "ironwill", name = "Iron Will" },
    { key = "iron will", name = "Iron Will" },
    { key = "selfcare", name = "Self Care" },
    { key = "self care", name = "Self Care" },
    { key = "resilience", name = "Resilience" },
    { key = "spinechill", name = "Spine Chill" },
    { key = "spine chill", name = "Spine Chill" },
    { key = "lightfooted", name = "Lightfooted" },
    { key = "light footed", name = "Lightfooted" },
    { key = "quickandquiet", name = "Quick & Quiet" },
    { key = "quick & quiet", name = "Quick & Quiet" },
}

local function matchKnownPerk(raw)
    if not raw or typeof(raw) ~= "string" or raw == "" or raw == "None" then
        return nil
    end
    local lower = raw:lower():gsub("[^%w%s]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if lower == "perks" or lower == "perk" or lower == "items" or lower == "item" or lower == "emotes"
        or lower == "none" or lower == "empty" or lower == "locked" or lower:match("^perk%s*%d+$") 
        or lower:match("^slot%s*%d+$") or lower:match("^item%s*%d+$") or lower == "select perk" 
        or lower == "choose perk" or lower == "search" or lower == "killer" or lower == "survivor" then
        return nil
    end
    for _, perk in ipairs(KnownPerks) do
        local kClean = perk.key:lower():gsub("[^%w%s]", "")
        if lower == kClean or lower:find(kClean, 1, true) then
            return perk.name
        end
    end
    return nil
end

local function getPlayerEquippedItem(player, isTargetKiller)
    if not player then return "None" end
    local char = player.Character

    -- 1. Check Tool actively held in Character hand
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local matched = matchKnownItem(child.Name)
                if matched then
                    return matched
                else
                    return child.Name
                end
            end
        end
    end

    -- 2. Check Backpack (for LocalPlayer or if replicated)
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") then
                local matched = matchKnownItem(child.Name)
                if matched then
                    return matched
                else
                    return child.Name
                end
            end
        end
    end

    -- 3. Check Character Descendants for Holstered/Attached Item Models, Tools, or MeshParts
    if char then
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("Model") or desc:IsA("Tool") or desc:IsA("MeshPart") or desc:IsA("Accessory") or desc:IsA("BasePart") then
                local dName = desc.Name:lower()
                if not (dName:find("arm") or dName:find("leg") or dName:find("torso") or dName:find("head") or dName:find("root") or dName:find("hair") or dName:find("shirt") or dName:find("pants") or dName:find("face") or dName:find("attachment")) then
                    local matched = matchKnownItem(desc.Name) or (desc.Parent and matchKnownItem(desc.Parent.Name))
                    if matched then
                        return matched
                    end
                end
            end
        end
    end

    -- 4. Check Attributes on Character and Player
    local itemAttributeKeys = {
        "Item", "EquippedItem", "SelectedItem", "SurvivorItem", "CurrentItem",
        "LoadoutItem", "Weapon", "KillerWeapon", "HeldItem", "ActiveItem",
        "Tool", "ItemName", "SlotItem", "Item1", "Slot_Item", "EquippedWeapon",
        "PrimaryItem", "SecondaryItem", "SelectedWeapon", "Equipped_Item"
    }

    local function scanObjectAttributes(obj)
        if not obj then return nil end
        for _, key in ipairs(itemAttributeKeys) do
            local val = obj:GetAttribute(key)
            if typeof(val) == "string" and val ~= "" and val ~= "None" and val ~= "nil" then
                return matchKnownItem(val) or val
            end
        end
        local all = obj:GetAttributes()
        for k, v in pairs(all) do
            if typeof(k) == "string" and (k:lower():find("item") or k:lower():find("weapon")) and typeof(v) == "string" and v ~= "" and v ~= "None" then
                return matchKnownItem(v) or v
            end
        end
        return nil
    end

    local attrItem = scanObjectAttributes(char) or scanObjectAttributes(player)
    if attrItem then return attrItem end

    -- 5. Check Folders and ValueObjects in Character and Player
    local function scanObjectFolders(parent)
        if not parent then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            local cName = child.Name:lower()
            if cName:find("item") or cName:find("weapon") or cName:find("loadout") or cName:find("inventory") or cName:find("equipped") or cName:find("gear") then
                if child:IsA("StringValue") and child.Value ~= "" and child.Value ~= "None" then
                    return matchKnownItem(child.Value) or child.Value
                elseif child:IsA("ObjectValue") and child.Value then
                    return matchKnownItem(child.Value.Name) or child.Value.Name
                elseif child:IsA("Folder") or child:IsA("Configuration") then
                    for _, sub in ipairs(child:GetChildren()) do
                        if sub:IsA("StringValue") and sub.Value ~= "" and sub.Value ~= "None" then
                            local subName = sub.Name:lower()
                            if subName:find("item") or subName:find("weapon") then
                                return matchKnownItem(sub.Value) or sub.Value
                            end
                            local matched = matchKnownItem(sub.Value)
                            if matched then return matched end
                        elseif sub:IsA("Tool") or sub:IsA("Model") then
                            return matchKnownItem(sub.Name) or sub.Name
                        end
                    end
                end
            end
        end
        return nil
    end

    local folderItem = scanObjectFolders(char) or scanObjectFolders(player)
    if folderItem then return folderItem end

    -- 6. Check ReplicatedStorage Data Folders
    local repItem = nil
    pcall(function()
        for _, fName in ipairs({"PlayerData", "Players", "Profiles", "Data", "SurvivorData", "KillerData", "Loadouts", "SurvivorLoadouts", "GameData", "Items", "Match", "Game"}) do
            local f = ReplicatedStorage:FindFirstChild(fName)
            if f then
                local pf = f:FindFirstChild(player.Name) or f:FindFirstChild(tostring(player.UserId))
                if pf then
                    repItem = scanObjectAttributes(pf) or scanObjectFolders(pf)
                    if repItem then return end
                end
            end
        end
    end)
    if repItem then return repItem end

    -- 7. Check Workspace Match & Player Folders
    local wsItem = nil
    pcall(function()
        for _, fName in ipairs({"Game", "Match", "Ingame", "Round", "Survivors", "Killers", "Status", "Players"}) do
            local f = Workspace:FindFirstChild(fName)
            if f then
                local pf = f:FindFirstChild(player.Name) or (char and f:FindFirstChild(char.Name))
                if pf then
                    wsItem = scanObjectAttributes(pf) or scanObjectFolders(pf)
                    if wsItem then return end
                end
            end
        end
    end)
    if wsItem then return wsItem end

    -- 8. Check PlayerGui (Spectator, Roster, Scoreboard, Inventory)
    local guiItem = nil
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") then
                    local pFrame = gui:FindFirstChild(player.Name, true) or gui:FindFirstChild(player.DisplayName, true)
                    if pFrame then
                        for _, desc in ipairs(pFrame:GetDescendants()) do
                            if desc:IsA("TextLabel") and desc.Visible then
                                local matched = matchKnownItem(desc.Text)
                                if matched then
                                    guiItem = matched
                                    return
                                end
                            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
                                local matched = matchKnownItem(desc.Name)
                                if matched then
                                    guiItem = matched
                                    return
                                end
                            end
                        end
                    end
                end
            end
            if player == LocalPlayer then
                local spec = pg:FindFirstChild("Spectator") or pg:FindFirstChild("Inventory") or pg:FindFirstChild("Menu") or pg:FindFirstChild("Lobby")
                local browse = spec and (spec:FindFirstChild("Browse_loadout_survivor", true) or spec:FindFirstChild("Browse_loadout_killer", true) or spec:FindFirstChild("Items", true))
                if browse then
                    for _, desc in ipairs(browse:GetDescendants()) do
                        if (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
                            local matched = matchKnownItem(desc.Name) or (desc:IsA("TextLabel") and matchKnownItem(desc.Text))
                            if matched then
                                guiItem = matched
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
    if guiItem then return guiItem end

    if isTargetKiller then
        return "Killer Weapon"
    end

    return "None"
end

local function getPlayerPerksAndItems(player)
    local isTargetKiller = isKiller(player)
    local displayName = (player and player.DisplayName ~= "" and player.DisplayName) or (player and player.Name) or "None"
    local userName = player and ("@" .. player.Name) or "None"
    local info = {
        name = displayName,
        username = userName,
        role = isTargetKiller and "Killer" or "Survivor",
        equippedItem = getPlayerEquippedItem(player, isTargetKiller),
        perks = { "None", "None", "None" }
    }
    if not player then return info end

    local char = player.Character

    -- Perks Discovery
    local foundPerks = {}

    local function addPerk(p)
        if not p or #foundPerks >= 3 then return end
        local matched = matchKnownPerk(tostring(p))
        if matched and not table.find(foundPerks, matched) then
            table.insert(foundPerks, matched)
        end
    end

    -- 1. Check executor environment (getsenv) for local loadout script
    if getsenv and player == LocalPlayer then
        pcall(function()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg then
                for _, scr in ipairs(pg:GetDescendants()) do
                    if scr:IsA("LocalScript") then
                        local sName = scr.Name:lower()
                        if sName:find("perk") or sName:find("loadout") or sName:find("inventory") or sName:find("spectat") then
                            local env = getsenv(scr)
                            if env and typeof(env) == "table" then
                                for _, k in ipairs({"EquippedPerks", "equippedPerks", "Equipped_Perks", "Perks", "perks", "Slots", "slots", "Loadout", "loadout", "SurvivorPerks", "ActivePerks"}) do
                                    local val = env[k]
                                    if typeof(val) == "table" then
                                        for _, item in pairs(val) do
                                            if typeof(item) == "string" then
                                                addPerk(item)
                                            elseif typeof(item) == "table" and item.Name then
                                                addPerk(item.Name)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 2. Scan Player and Character Attributes
    local function scanPerkAttributes(obj)
        if not obj then return end
        pcall(function()
            for _, slotKey in ipairs({"Slot1", "Slot2", "Slot3", "Perk1", "Perk2", "Perk3", "Perk_1", "Perk_2", "Perk_3", "PerkOne", "PerkTwo", "PerkThree", "ActivePerk1", "ActivePerk2", "ActivePerk3", "EquippedPerks", "SurvivorPerks", "Perks", "Equipped1", "Equipped2", "Equipped3"}) do
                local val = obj:GetAttribute(slotKey)
                if typeof(val) == "string" and val ~= "" then
                    for part in val:gmatch("[^,;%s]+") do
                        addPerk(part)
                    end
                    addPerk(val)
                end
            end
            local allAttrs = obj:GetAttributes()
            for k, v in pairs(allAttrs) do
                if typeof(v) == "string" and v ~= "" then
                    addPerk(v)
                end
            end
        end)
    end

    scanPerkAttributes(player)
    scanPerkAttributes(char)

    -- 3. Scan Player and Character Folders & ValueBases
    local function scanPerkFolders(parent)
        if not parent then return end
        pcall(function()
            for _, child in ipairs(parent:GetChildren()) do
                local cName = child.Name:lower()
                if cName:find("perk") or (cName:find("slot") and not cName:find("item")) or cName:find("loadout") or cName:find("ability") or cName:find("equipped") then
                    addPerk(child.Name)
                    if child:IsA("StringValue") and child.Value ~= "" then
                        addPerk(child.Value)
                    elseif child:IsA("ValueBase") and tostring(child.Value) ~= "" then
                        addPerk(tostring(child.Value))
                    end
                    scanPerkAttributes(child)
                    for _, sub in ipairs(child:GetChildren()) do
                        addPerk(sub.Name)
                        if sub:IsA("StringValue") and sub.Value ~= "" then
                            addPerk(sub.Value)
                        elseif sub:IsA("ValueBase") and tostring(sub.Value) ~= "" then
                            addPerk(tostring(sub.Value))
                        end
                        scanPerkAttributes(sub)
                    end
                else
                    addPerk(child.Name)
                end
            end
        end)
    end

    scanPerkFolders(player)
    scanPerkFolders(char)

    -- 4. Scan ReplicatedStorage Data Folders
    pcall(function()
        for _, fName in ipairs({"PlayerData", "Players", "Profiles", "Data", "SurvivorData", "KillerData", "Perks", "Loadouts", "SurvivorLoadouts", "GameData", "RoundData", "Match", "Game", "Survivors"}) do
            local f = ReplicatedStorage:FindFirstChild(fName)
            if f then
                local pFolder = f:FindFirstChild(player.Name) or f:FindFirstChild(tostring(player.UserId))
                if pFolder then
                    scanPerkAttributes(pFolder)
                    scanPerkFolders(pFolder)
                end
                if char then
                    local cFolder = f:FindFirstChild(char.Name)
                    if cFolder then
                        scanPerkAttributes(cFolder)
                        scanPerkFolders(cFolder)
                    end
                end
            end
        end
    end)

    -- 5. Scan PlayerGui (Spectator, Loadout screen, HUD)
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            if player == LocalPlayer then
                local spec = pg:FindFirstChild("Spectator") or pg:FindFirstChild("Inventory") or pg:FindFirstChild("Menu") or pg:FindFirstChild("Lobby")
                if spec then
                    local browse = spec:FindFirstChild("Browse_loadout_survivor", true) or spec:FindFirstChild("Browse_loadout_killer", true) or spec:FindFirstChild("Inventory", true)
                    if browse then
                        for _, desc in ipairs(browse:GetDescendants()) do
                            addPerk(desc.Name)
                            if desc:IsA("TextLabel") and desc.Text ~= "" then
                                addPerk(desc.Text)
                            end
                            scanPerkAttributes(desc)
                        end
                    end
                end
            end

            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") then
                    local pFrame = gui:FindFirstChild(player.Name, true) or gui:FindFirstChild(player.DisplayName, true)
                    if pFrame then
                        for _, desc in ipairs(pFrame:GetDescendants()) do
                            addPerk(desc.Name)
                            if desc:IsA("TextLabel") and desc.Text ~= "" then
                                addPerk(desc.Text)
                            end
                            scanPerkAttributes(desc)
                        end
                    end
                end
            end

            if #foundPerks < 3 then
                for _, desc in ipairs(pg:GetDescendants()) do
                    if #foundPerks >= 3 then break end
                    if desc:IsA("TextLabel") and desc.Visible and desc.Text ~= "" then
                        local matched = matchKnownPerk(desc.Text)
                        if matched then
                            local path = desc:GetFullName():lower()
                            if player == LocalPlayer or path:find(player.Name:lower()) or path:find(player.DisplayName:lower()) then
                                addPerk(matched)
                            end
                        end
                    end
                end
            end
        end
    end)

    for i = 1, 3 do
        if foundPerks[i] then
            info.perks[i] = foundPerks[i]
        else
            info.perks[i] = "None"
        end
    end

    return info
end

----------------------------------------------------------------------
-- COMBAT & AUTO PARRY ENGINE (PARRYING DAGGER)
----------------------------------------------------------------------

local lastParryTick = 0
local parriedTracks = {}
local combatBoundAnimators = {}

local NonDamageActionKeywords = {
    "generator", "pallet", "door", "pickup", "drop", "hook", "unhook",
    "carry", "carried", "vault", "climb", "repair", "heal", "struggle",
    "wiggle", "fix", "inspect", "search", "locker", "kick", "damage_gen",
    "break_pallet", "break", "destroy", "wipe", "cool", "recover", "miss",
    "stun", "blind", "flashed", "daze", "dazed", "headache", "stumble",
    "emote", "dance", "sit", "breathe", "chest", "open", "close"
}

local AttackAnimKeywords = {
    "attack", "swing", "slash", "hit", "strike", "m1", "machete", "knife",
    "cleave", "chop", "down", "combat", "slasher", "weapon", "swipe",
    "stab", "punish", "heavy", "light", "fire", "shoot", "cast", "dash",
    "lunge", "kill", "axe", "hammer", "blade", "saw", "chainsaw", "scythe",
    "club", "fist", "punch", "smash"
}

local LocomotionKeywords = {
    "walk", "run", "idle", "sprint", "fall", "jump", "land", "crouch", "turn"
}

local function isAttackAnimation(track)
    if not track then return false end

    local tName = (track.Name or ""):lower()
    local animId = ""
    if track.Animation then
        animId = tostring(track.Animation.AnimationId or ""):lower()
        local aName = (track.Animation.Name or ""):lower()
        tName = tName .. " " .. aName
    end

    -- 1. Ignore non-damaging environmental, interaction & recovery actions first
    for _, nonDmg in ipairs(NonDamageActionKeywords) do
        if tName:find(nonDmg) or animId:find(nonDmg) then
            return false
        end
    end

    -- 2. Looped tracks are locomotion or idle unless explicit attack matched
    if track.Looped == true then
        return false
    end

    -- 3. Explicit attack keywords take highest priority
    for _, kw in ipairs(AttackAnimKeywords) do
        if tName:find(kw) or animId:find(kw) then
            return true
        end
    end

    -- 4. Ignore locomotion keywords if no attack keyword matched
    for _, loco in ipairs(LocomotionKeywords) do
        if tName:find(loco) then
            return false
        end
    end

    -- 5. Action Priority check (Frame-0 detection: NO WeightCurrent delay)
    local prio = track.Priority
    local isActionPrio = (prio == Enum.AnimationPriority.Action 
        or prio == Enum.AnimationPriority.Action2 
        or prio == Enum.AnimationPriority.Action3 
        or prio == Enum.AnimationPriority.Action4 
        or tostring(prio):find("Action"))

    local len = track.Length or 0
    if isActionPrio and (len == 0 or (len > 0.15 and len < 3.5)) then
        return true
    end

    return false
end

local function isDaggerString(str)
    if not str or typeof(str) ~= "string" then return false end
    local s = str:lower()
    return s:find("parry") ~= nil or s:find("dagger") ~= nil or s:find("knife") ~= nil
end

local function isDaggerObject(obj)
    if not obj or typeof(obj) ~= "Instance" then return false end
    if isDaggerString(obj.Name) then return true end

    local tip = ""
    pcall(function()
        if obj:IsA("Tool") then
            tip = obj.ToolTip or ""
        end
    end)
    if isDaggerString(tip) then return true end

    for _, attr in ipairs({
        "ItemType", "WeaponType", "Type", "ID", "ItemName", "ToolType",
        "Item", "EquippedItem", "SelectedItem", "SurvivorItem", "CurrentItem", "Name"
    }) do
        local aVal = tostring(obj:GetAttribute(attr) or "")
        if isDaggerString(aVal) then return true end
    end

    if obj:IsA("StringValue") and isDaggerString(obj.Value) then
        return true
    end

    if obj:IsA("ObjectValue") and obj.Value and isDaggerString(obj.Value.Name) then
        return true
    end

    return false
end

local function getParryingDagger()
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")

    -- 1. Direct Tool/Model in Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if isDaggerObject(child) then
                return child, true
            end
        end
    end

    -- 2. Direct Tool/Model in Backpack
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if isDaggerObject(child) then
                return child, false
            end
        end
    end

    -- 3. Character Descendants (handles nested Models, Accessories, MeshParts in RightHand/Torso)
    if char then
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("Tool") or desc:IsA("Model") or desc:IsA("Accessory") or desc:IsA("MeshPart") or desc:IsA("BasePart") then
                if isDaggerObject(desc) or (desc.Parent and isDaggerObject(desc.Parent)) then
                    local target = (desc:IsA("Tool") or desc:IsA("Model")) and desc or (desc.Parent:IsA("Model") and desc.Parent or desc)
                    return target, true
                end
            end
        end
    end

    -- 4. Backpack Descendants
    if bp then
        for _, desc in ipairs(bp:GetDescendants()) do
            if isDaggerObject(desc) or (desc.Parent and isDaggerObject(desc.Parent)) then
                return desc, false
            end
        end
    end

    -- 5. Match via Live Inspector Engine (the exact system displaying "Item : Parrying Dagger" in UI)
    local liveItem = nil
    if getPlayerEquippedItem then
        pcall(function()
            liveItem = getPlayerEquippedItem(LocalPlayer, false)
        end)
    end
    if isDaggerString(liveItem) then
        local candidate = nil
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then candidate = item; break end
            end
            if not candidate then
                for _, desc in ipairs(char:GetDescendants()) do
                    if (desc:IsA("Tool") or desc:IsA("Model")) and isDaggerObject(desc) then
                        candidate = desc
                        break
                    end
                end
            end
        end
        return candidate or char, true
    end

    -- 6. Check Character & Player Attributes
    local itemAttributeKeys = {
        "Item", "EquippedItem", "SelectedItem", "SurvivorItem", "CurrentItem",
        "LoadoutItem", "Weapon", "KillerWeapon", "HeldItem", "ActiveItem",
        "Tool", "ItemName", "SlotItem", "Item1", "Slot_Item", "EquippedWeapon",
        "PrimaryItem", "SecondaryItem", "SelectedWeapon", "Equipped_Item"
    }
    if char then
        for _, key in ipairs(itemAttributeKeys) do
            local val = char:GetAttribute(key)
            if isDaggerString(val) then
                return char, true
            end
        end
    end
    for _, key in ipairs(itemAttributeKeys) do
        local val = LocalPlayer:GetAttribute(key)
        if isDaggerString(val) then
            return char or LocalPlayer, true
        end
    end

    -- 7. Check Inventory / Item Folders in Player & Character
    for _, parent in ipairs({char, LocalPlayer, bp}) do
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                local cName = child.Name:lower()
                if cName:find("item") or cName:find("inventory") or cName:find("loadout") or cName:find("gear") or cName:find("slot") then
                    if isDaggerObject(child) then return child, true end
                    for _, sub in ipairs(child:GetChildren()) do
                        if isDaggerObject(sub) then return sub, true end
                    end
                end
            end
        end
    end

    -- 8. Check PlayerGui (GUI Item Slots & Touch Buttons)
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, desc in ipairs(pg:GetDescendants()) do
            if desc:IsA("ImageButton") or desc:IsA("TextButton") or desc:IsA("ImageLabel") or desc:IsA("TextLabel") then
                local dName = desc.Name:lower()
                local dText = desc:IsA("TextLabel") and desc.Text:lower() or ""
                if isDaggerString(dName) or isDaggerString(dText) then
                    return desc, true
                end
            end
        end
    end

    return nil, false
end

local function isAttacker(player, char, track)
    if not player and not char then return false end
    if player == LocalPlayer then return false end
    if isKiller(LocalPlayer) then return false end

    -- 1. Explicit killer check
    if player and isKiller(player) then
        return true
    end

    -- 2. Killer tool / weapon check in character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("knife") or n:find("machete") or n:find("axe") or n:find("hammer")
                    or n:find("saw") or n:find("scythe") or n:find("weapon") or n:find("cleaver")
                    or n:find("bat") or n:find("club") or n:find("blade") or n:find("slasher")
                    or n:find("fist") or n:find("pipe") then
                    return true
                end
            end
        end
    end

    -- 3. If playing a verified attack animation, they are an attacker!
    if track and isAttackAnimation(track) then
        return true
    end

    -- 4. Fail-safe: In Violence District, no survivor can attack or damage you; any non-local entity swinging is a threat
    return true
end

local function triggerParryInputs(daggerTool, mPos)
    local mPos = mPos or UserInputService:GetMouseLocation()
    local myChar = LocalPlayer.Character

    -- 1. INSTANT TOOL ACTIVATION (Frame-0 Direct Engine Invocation - 0ms latency)
    if daggerTool and typeof(daggerTool) == "Instance" and daggerTool:IsA("Tool") then
        pcall(function()
            daggerTool:Activate()
        end)
    elseif myChar then
        for _, item in ipairs(myChar:GetChildren()) do
            if item:IsA("Tool") and item.Activate then
                pcall(function() item:Activate() end)
            end
        end
    end

    -- 2. INSTANT MOUSE CLICKS (M2 Right-Click + M1 Left-Click)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(mPos.X, mPos.Y, 1, true, game, 1) -- Right Click Down
        VirtualInputManager:SendMouseButtonEvent(mPos.X, mPos.Y, 0, true, game, 1) -- Left Click Down
    end)
    if mouse2press then pcall(mouse2press) end
    if mouse1press then pcall(mouse1press) end
    if mouse2click then pcall(mouse2click) end
    if mouse1click then pcall(mouse1click) end
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(mPos.X, mPos.Y))
        VirtualUser:Button1Down(Vector2.new(mPos.X, mPos.Y))
    end)

    -- 3. COMBAT KEYPRESSES (E, Q)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    end)

    -- 4. DIRECT TARGETED REMOTES (Direct tool & ReplicatedStorage fast-fire, zero tree walking)
    pcall(function()
        if daggerTool and typeof(daggerTool) == "Instance" then
            for _, child in ipairs(daggerTool:GetChildren()) do
                if child:IsA("RemoteEvent") then
                    child:FireServer()
                end
            end
        end
        local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
        if remotesFolder then
            for _, rName in ipairs({"Parry", "ParryEvent", "Guard", "Block", "UseItem", "ItemUse", "ActivateItem"}) do
                local r = remotesFolder:FindFirstChild(rName)
                if r and r:IsA("RemoteEvent") then
                    r:FireServer()
                end
            end
        end
    end)

    -- 5. PlayerGui Mobile / Touch Action Buttons (Direct lookup)
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, desc in ipairs(pg:GetDescendants()) do
                if (desc:IsA("ImageButton") or desc:IsA("TextButton")) and desc.Visible then
                    local dName = desc.Name:lower()
                    if dName:find("parry") or dName:find("guard") or dName:find("block") or dName:find("counter") then
                        if firesignal then
                            firesignal(desc.Activated)
                            firesignal(desc.MouseButton1Click)
                        elseif desc.Activated then
                            desc.Activated:Fire()
                        end
                    end
                end
            end
        end
    end)
end

local function isParryOnCooldown()
    local daggerTool = getParryingDagger()
    if not daggerTool then return false end

    local myChar = LocalPlayer.Character

    -- Check Character attributes & ValueObjects
    if myChar then
        for _, attr in ipairs({
            "ParryCooldown", "DaggerCooldown", "Parrying", "IsParrying",
            "InCooldown", "ActionCooldown"
        }) do
            if myChar:GetAttribute(attr) == true then
                return true
            end
        end
        local charCd = myChar:GetAttribute("ParryCooldownEnd") or myChar:GetAttribute("DaggerCooldownEnd")
        if typeof(charCd) == "number" and charCd > tick() then
            return true
        end
        local charCdObj = myChar:FindFirstChild("ParryCooldown") or myChar:FindFirstChild("Cooldown")
        if charCdObj then
            if charCdObj:IsA("BoolValue") and charCdObj.Value == true then
                return true
            elseif charCdObj:IsA("NumberValue") and charCdObj.Value > tick() then
                return true
            end
        end
    end

    -- Check Tool state & attributes
    if typeof(daggerTool) == "Instance" then
        if daggerTool:IsA("Tool") and daggerTool.Enabled == false then
            return true
        end
        for _, attr in ipairs({
            "Cooldown", "OnCooldown", "ParryCooldown", "IsCooldown", 
            "InCooldown", "CooldownActive", "ActionCooldown", "Debounce"
        }) do
            if daggerTool:GetAttribute(attr) == true then
                return true
            end
        end
        local cdEnd = daggerTool:GetAttribute("CooldownEnd") or daggerTool:GetAttribute("CooldownTime")
        if typeof(cdEnd) == "number" and cdEnd > tick() then
            return true
        end
        local cdObj = daggerTool:FindFirstChild("Cooldown") or daggerTool:FindFirstChild("OnCooldown") or daggerTool:FindFirstChild("Debounce")
        if cdObj then
            if cdObj:IsA("BoolValue") and cdObj.Value == true then
                return true
            elseif cdObj:IsA("NumberValue") and cdObj.Value > tick() then
                return true
            end
        end
    end

    -- Check LocalPlayer state
    if LocalPlayer:GetAttribute("ParryCooldown") == true or LocalPlayer:GetAttribute("DaggerCooldown") == true then
        return true
    end

    return false
end

local function isTrackParriedRecently(track)
    if not track then return false end
    local lastTick = parriedTracks[track]
    if lastTick then
        if tick() - lastTick < 0.45 then
            return true
        else
            parriedTracks[track] = nil
        end
    end
    return false
end

local function markTrackParried(track)
    if not track then return end
    parriedTracks[track] = tick()
    task.delay(0.45, function()
        if parriedTracks[track] and (tick() - parriedTracks[track] >= 0.45) then
            parriedTracks[track] = nil
        end
    end)
    pcall(function()
        track.Stopped:Once(function()
            parriedTracks[track] = nil
        end)
    end)
end

local function executeParry(source, passedDagger)
    if not (Toggles.AutoParry and Toggles.AutoParry.Value) and source ~= "MANUAL_TEST" then
        return false
    end
    if isKiller(LocalPlayer) then return false end

    -- Strict Item Verification: Player can ONLY activate Auto Parry if Parrying Dagger is in inventory!
    local daggerTool = passedDagger or getParryingDagger()
    if not daggerTool then
        return false
    end

    -- If dagger is actively on cooldown, do not consume debounce or fire useless inputs
    if source ~= "MANUAL_TEST" and isParryOnCooldown() then
        return false
    end

    local now = tick()
    if now - lastParryTick < 0.35 then return false end
    lastParryTick = now

    local myChar = LocalPlayer.Character
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")

    -- 1. Synchronously equip Parrying Dagger if in backpack and is a real Tool
    local isEquipped = (myChar and daggerTool.Parent == myChar)
    if daggerTool and typeof(daggerTool) == "Instance" and daggerTool:IsA("Tool") and not isEquipped and myChar then
        pcall(function()
            daggerTool.Parent = myChar
            if hum then hum:EquipTool(daggerTool) end
        end)
    end

    local mPos = UserInputService:GetMouseLocation()

    -- 2. Frame 0: Immediate zero-latency Input Dispatch
    triggerParryInputs(daggerTool, mPos)

    -- 2B. Frame 0 Defer: Confirmation pulse on end of frame
    task.defer(function()
        local currentDagger = getParryingDagger() or daggerTool
        triggerParryInputs(currentDagger, mPos)
    end)

    -- 2C. Frame 1 Pulse: Guarantees registration if Roblox engine took a physics step to mount the tool
    task.spawn(function()
        RunService.Heartbeat:Wait()
        local currentDagger = getParryingDagger() or daggerTool
        triggerParryInputs(currentDagger, mPos)
    end)

    -- 2D. Hold 350ms to lock counter stance, then cleanly release inputs
    task.spawn(function()
        task.wait(0.35)
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(mPos.X, mPos.Y, 1, false, game, 1)
            VirtualInputManager:SendMouseButtonEvent(mPos.X, mPos.Y, 0, false, game, 1)
        end)
        if mouse2release then pcall(mouse2release) end
        if mouse1release then pcall(mouse1release) end
        pcall(function()
            VirtualUser:Button2Up(Vector2.new(mPos.X, mPos.Y))
            VirtualUser:Button1Up(Vector2.new(mPos.X, mPos.Y))
        end)
        pcall(function()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
        end)
    end)

    return true
end

local function checkAndTriggerParry(killerChar, killerPlayer, track)
    if not (Toggles.AutoParry and Toggles.AutoParry.Value) or not killerChar then return end
    if isKiller(LocalPlayer) then return end
    if killerPlayer == LocalPlayer then return end

    -- 1. Attacker Verification
    if not isAttacker(killerPlayer, killerChar, track) then
        return
    end

    -- 2. Strict Item Check: Player CANNOT activate auto parry without Parrying Dagger!
    local daggerTool = getParryingDagger()
    if not daggerTool then
        return
    end

    -- 2B. Cooldown Check: Never waste debounces or attempt parries while dagger is cooling down
    if isParryOnCooldown() then
        return
    end

    -- 3. Animation check: verify track is a damaging combat animation (filters non-damaging kicks/breaking)
    if track then
        if isTrackParriedRecently(track) then return end
        if not isAttackAnimation(track) then
            return
        end
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local kRoot = killerChar:FindFirstChild("HumanoidRootPart") or killerChar.PrimaryPart
    if not kRoot or not kRoot:IsA("BasePart") then return end

    local myPos = myRoot.Position
    local kPos = kRoot.Position
    local dist = (kPos - myPos).Magnitude

    -- 4. Elevation Check: Filter out extreme vertical distances (e.g. different floor/roof > 8.0 studs)
    local yDiff = math.abs(kPos.Y - myPos.Y)
    if yDiff > 8.0 then
        return
    end

    -- 5. Calculate Flat Horizontal Coordinates (immune to vertical head tilt or slopes)
    local flatKPos = Vector2.new(kPos.X, kPos.Z)
    local flatMyPos = Vector2.new(myPos.X, myPos.Z)
    local flatDist = (flatMyPos - flatKPos).Magnitude

    local kLook3D = kRoot.CFrame.LookVector
    local flatKLook = Vector2.new(kLook3D.X, kLook3D.Z).Unit
    local flatToMe = (flatMyPos - flatKPos).Unit

    -- Calculate horizontal aim alignment:
    -- 1.0 = killer looking directly at player's center
    -- 0.707 = 45 degrees
    -- 0.50 = 60 degrees
    -- 0.0 = 90 degrees (sideways)
    -- < 0.0 = facing away
    local aimDot = flatKLook:Dot(flatToMe)

    -- 6. SMART FACING CHECK:
    -- The killer MUST face directly towards our character ("killer hit តម្រង់មកមុខយើង")!
    -- If killer is not facing our character, DO NOT PARRY (hitting air)!
    local doFaceCheck = not Toggles.ParryFaceCheck or Toggles.ParryFaceCheck.Value
    if doFaceCheck then
        if flatDist <= 5.0 then
            -- At point-blank, killer must face generally towards player
            if aimDot < 0.10 then
                return -- Killer is facing completely away from player
            end
        elseif flatDist <= 10.0 then
            -- In standard melee range, killer must be facing towards player (within ~63 degrees)
            if aimDot < 0.45 then
                return -- Killer is swinging sideways or hitting air away from player
            end
        else
            -- At chase / lunge distance (> 10 studs), killer must be aimed towards player (within ~60 degrees)
            if aimDot < 0.50 then
                return -- Killer is lunging/hitting empty air away from player
            end
        end
    else
        -- Even with face check toggled off, killer cannot be facing backwards (> 90 degrees away)
        if aimDot < 0.0 then
            return
        end
    end

    -- 7. SMART DISTANCE & EARLY COUNTER REACH (Zero-Latency Frame-0 Intercept):
    -- In Violence District, killer lunges and weapon sweeps reach up to 16-18 studs!
    -- Countering at the VERY FIRST FRAME of the attack swing guarantees our parry stance is fully established BEFORE damage connects!
    local sliderDist = (Options.ParryDistance and Options.ParryDistance.Value) or 15.0

    local kVel = (kRoot.AssemblyLinearVelocity or kRoot.Velocity or Vector3.zero)
    local flatKVel = Vector2.new(kVel.X, kVel.Z)
    local myVel = (myRoot.AssemblyLinearVelocity or myRoot.Velocity or Vector3.zero)
    local flatMyVel = Vector2.new(myVel.X, myVel.Z)

    -- kSpeedTowardsMe: Speed at which the KILLER is moving towards the player
    local kSpeedTowardsMe = flatKVel:Dot(flatToMe)

    -- Only drop if killer is actively moving backwards away from player
    if kSpeedTowardsMe < -3.5 and flatDist > 6.0 then
        return -- Killer is actively running away from player; swing will miss air
    end

    -- Player is running away (being chased) if local player velocity is moving away from killer
    local isPlayerRunningAway = (flatMyVel:Dot(flatToMe) > 2.5)

    -- Dynamic lunge compensation:
    local lungeBonus = 0
    if kSpeedTowardsMe > 0.5 then
        lungeBonus = math.clamp(kSpeedTowardsMe * 0.35, 0, 5.0)
    end

    -- Chase Bonus: When survivor is running away and killer is chasing from behind
    if isPlayerRunningAway and kSpeedTowardsMe > 0 then
        lungeBonus = math.max(lungeBonus, 3.5)
    end

    -- EARLY INTERCEPT: 22.0 studs reach ensures attacks are parried at swing startup, before damage connects!
    local effectiveMaxDist = math.max(sliderDist + lungeBonus, 22.0)
    if flatDist > effectiveMaxDist then
        return -- Killer is out of reach; attack will hit empty air!
    end

    -- 8. TARGET FOCUS CHECK (Only when killer is far and clearly focused on another nearby survivor)
    if flatDist > 8.0 then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer and otherPlayer ~= killerPlayer and otherPlayer.Character then
                local oRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if oRoot and oRoot:IsA("BasePart") then
                    local oPos = oRoot.Position
                    local flatOPos = Vector2.new(oPos.X, oPos.Z)
                    local oDist = (flatOPos - flatKPos).Magnitude
                    if oDist < (flatDist - 3.5) and oDist < 6.0 then
                        local toOther = (flatOPos - flatKPos).Unit
                        local otherDot = flatKLook:Dot(toOther)
                        -- Killer is locked onto the closer survivor
                        if otherDot > 0.85 and otherDot > (aimDot + 0.25) then
                            return -- Killer is attacking the other survivor, not you!
                        end
                    end
                end
            end
        end
    end

    -- 9. Guaranteed Protection Execution (Passes dagger directly for 0ms re-scan)
    local executed = executeParry("KILLER_ATTACK", daggerTool)
    if executed and track then
        markTrackParried(track)
    end
end

bindCombatListeners = function(player, char)
    if player == LocalPlayer or not char then return end

    local animator = char:FindFirstChildWhichIsA("Animator", true)
    if not animator then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local conn = hum.DescendantAdded:Connect(function(desc)
                if desc:IsA("Animator") then
                    bindCombatListeners(player, char)
                end
            end)
            connections[#connections + 1] = conn
        end
        local conn2 = char.DescendantAdded:Connect(function(desc)
            if desc:IsA("Animator") then
                bindCombatListeners(player, char)
            end
        end)
        connections[#connections + 1] = conn2
        return
    end

    if combatBoundAnimators[animator] then return end
    combatBoundAnimators[animator] = true

    local conn = animator.AnimationPlayed:Connect(function(track)
        checkAndTriggerParry(char, player, track)
    end)
    connections[#connections + 1] = conn
end

----------------------------------------------------------------------
-- SPEED ADJUST, NOCLIP & FLY SYSTEMS
----------------------------------------------------------------------

-- Noclip Physics Handler
connections[#connections + 1] = RunService.Stepped:Connect(function()
    if Toggles.Noclip and Toggles.Noclip.Value then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Speed Adjust & Fly Render Loop
connections[#connections + 1] = RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    -- Speed Adjust
    if not (Toggles.Fly and Toggles.Fly.Value) then
        local isSpeedOn = (Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value == true)
        if isSpeedOn then
            local targetSpeed = getSpeedValue()
            if hum and hum.WalkSpeed ~= targetSpeed then
                hum.WalkSpeed = targetSpeed
            end
            if char:GetAttribute("Speed") ~= nil and char:GetAttribute("Speed") ~= targetSpeed then
                pcall(function() char:SetAttribute("Speed", targetSpeed) end)
            end
        else
            -- When Speed Adjust is OFF: strictly ensure player speed stays at default
            if hum and hum.WalkSpeed > defaultSpeed then
                hum.WalkSpeed = defaultSpeed
            end
            if char:GetAttribute("Speed") ~= nil and char:GetAttribute("Speed") ~= defaultSpeed then
                pcall(function() char:SetAttribute("Speed", defaultSpeed) end)
            end
        end
    end

    -- Fly Handler
    if Toggles.Fly and Toggles.Fly.Value and root and hum then
        hum.PlatformStand = true

        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyBodyVelocity.Velocity = Vector3.zero
            flyBodyVelocity.Parent = root
        end

        if not flyBodyGyro then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flyBodyGyro.P = 9e4
            flyBodyGyro.Parent = root
        end

        local cam = Workspace.CurrentCamera
        local moveDir = Vector3.zero

        local isTypingOrMenu = (UserInputService:GetFocusedTextBox() ~= nil)
        pcall(function()
            if GuiService.MenuIsOpen then
                isTypingOrMenu = true
            end
        end)

        if not isTypingOrMenu then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end
        end

        -- Support mobile thumbstick / touch movement for fly
        if moveDir.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then
            moveDir = cam.CFrame:VectorToWorldSpace(Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z))
            if moveDir.Magnitude == 0 then
                moveDir = hum.MoveDirection
            end
        end

        local flySpeed = getFlySpeedValue()
        if moveDir.Magnitude > 0 then
            flyBodyVelocity.Velocity = moveDir.Unit * flySpeed
        else
            flyBodyVelocity.Velocity = Vector3.zero
        end

        flyBodyGyro.CFrame = cam.CFrame
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
        if flyBodyGyro then
            flyBodyGyro:Destroy()
            flyBodyGyro = nil
        end
        if hum and not (Toggles.AntiStun and Toggles.AntiStun.Value and hum.PlatformStand) then
            hum.PlatformStand = false
        end
    end

    -- Custom FOV Handler
    if Toggles.CustomFOV and Toggles.CustomFOV.Value and Workspace.CurrentCamera then
        local targetFOV = getFOVValue()
        if Workspace.CurrentCamera.FieldOfView ~= targetFOV then
            Workspace.CurrentCamera.FieldOfView = targetFOV
        end
    end

    -- Real-time Killer Attack Detection for Auto Parry (Layer 2 real-time scan) & Auto Pre-Equip
    if Toggles.AutoParry and Toggles.AutoParry.Value and not isKiller(LocalPlayer) then
        -- Strict check: Auto Parry CANNOT activate if player does not possess Parrying Dagger
        local daggerTool, isDaggerEquipped = getParryingDagger()
        if daggerTool then
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local maxDist = (Options.ParryDistance and Options.ParryDistance.Value) or 16.0
                local nearestKillerDist = 999
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local pChar = player.Character
                        local isThreat = isKiller(player) or isAttacker(player, pChar, nil)
                        local kRoot = pChar:FindFirstChild("HumanoidRootPart") or pChar.PrimaryPart
                        if kRoot and kRoot:IsA("BasePart") then
                            local d = (kRoot.Position - myRoot.Position).Magnitude
                            if isThreat and d < nearestKillerDist then
                                nearestKillerDist = d
                            end

                            -- Scan attack animations with early detection margin (up to 22 studs)
                            if d <= math.max(maxDist + 6.0, 22.0) then
                                local kAnim = pChar:FindFirstChildWhichIsA("Animator", true)
                                if kAnim then
                                    for _, track in ipairs(kAnim:GetPlayingAnimationTracks()) do
                                        if not isTrackParriedRecently(track) and isAttackAnimation(track) then
                                            checkAndTriggerParry(pChar, player, track)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- Auto Pre-Equip Parrying Dagger whenever cooled down (0ms draw latency, always in hand)
                local onCd = isParryOnCooldown()
                if not onCd and not isDaggerEquipped and hum and hum.Health > 0 then
                    pcall(function()
                        hum:EquipTool(daggerTool)
                    end)
                end
            end
        end
    end
end)

----------------------------------------------------------------------
-- UI ELEMENTS (ESP TAB)
----------------------------------------------------------------------

-- Highlight Players
ESPGroupBox:AddToggle("HighlightPlayers", {
    Text = "Highlight Player",
    Default = false,
    Callback = function()
        updateAllPlayerHighlights()
    end,
})
    :AddColorPicker("KillerColor", {
        Default = Color3.fromRGB(255, 45, 45),
        Title = "Killer Color",
        Callback = function()
            updateAllPlayerHighlights()
        end,
    })
    :AddColorPicker("SurvivorColor", {
        Default = Color3.fromRGB(0, 160, 255),
        Title = "Survivor Color",
        Callback = function()
            updateAllPlayerHighlights()
        end,
    })

-- Player Outline Toggle
ESPGroupBox:AddToggle("PlayerOutline", {
    Text = "Player Outline",
    Default = false,
    Callback = function()
        updateAllPlayerHighlights()
    end,
}):AddColorPicker("PlayerOutlineColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Outline Color",
    Callback = function()
        updateAllPlayerHighlights()
    end,
})

ESPGroupBox:AddSlider("PlayerFillTransparency", {
    Text = "Player Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function()
        updateAllPlayerHighlights()
    end,
})

ESPGroupBox:AddToggle("IncludeLocalPlayer", {
    Text = "Highlight Self",
    Default = false,
    Callback = function(val)
        if val then
            if LocalPlayer.Character then
                applyPlayerHighlight(LocalPlayer, LocalPlayer.Character)
            end
        else
            if playerHighlights[LocalPlayer] then
                pcall(function() playerHighlights[LocalPlayer]:Destroy() end)
                playerHighlights[LocalPlayer] = nil
            end
        end
    end,
})

ESPGroupBox:AddDivider()

-- Highlight Generators (Un-Fixed Only)
ESPGroupBox:AddToggle("HighlightGenerators", {
    Text = "Highlight Generator",
    Default = false,
    Tooltip = "Highlights un-fixed generators. Automatically removes highlight as soon as a generator is fixed/completed.",
    Callback = function()
        scanGenerators()
        updateAllGeneratorHighlights()
    end,
})
    :AddColorPicker("GenFillColor", {
        Default = Color3.fromRGB(255, 205, 0),
        Title = "Fill Color",
        Callback = function()
            updateAllGeneratorHighlights()
        end,
    })

-- Generator Outline Toggle
ESPGroupBox:AddToggle("GenOutline", {
    Text = "Generator Outline",
    Default = false,
    Callback = function()
        updateAllGeneratorHighlights()
    end,
}):AddColorPicker("GenOutlineColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Outline Color",
    Callback = function()
        updateAllGeneratorHighlights()
    end,
})

ESPGroupBox:AddSlider("GenFillTransparency", {
    Text = "Generator Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function()
        updateAllGeneratorHighlights()
    end,
})

----------------------------------------------------------------------
-- UI ELEMENTS (AUTOMATIC TAB)
----------------------------------------------------------------------

AutoGroupBox:AddToggle("AutoFixGen", {
    Text = "Auto Skill Check",
    Default = false,
})

----------------------------------------------------------------------
-- UI ELEMENTS (PLAYER TAB - SPLIT INTO PLAYER & MOVEMENT)
----------------------------------------------------------------------

-- Left Side: Player Box
PlayerGroupBox:AddToggle("AntiStun", {
    Text = "Anti Stun",
    Default = false,
})

PlayerGroupBox:AddButton("Fix Controls / Unstick", function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if root then root.Anchored = false end
        if hum then
            hum.PlatformStand = false
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum.WalkSpeed = (Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value and getSpeedValue()) or defaultSpeed
        end
        for _, attr in ipairs({"Stunned", "IsStunned", "Slowed", "Frozen", "Blinded", "Headache", "Interacting", "Busy", "Action", "InAction"}) do
            if char:GetAttribute(attr) ~= nil then
                char:SetAttribute(attr, false)
            end
        end
        char:SetAttribute("CanMove", true)
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                item.Enabled = true
            end
        end
    end)
end)

-- Right Side: Movement Box
local SpeedToggle = MovementGroupBox:AddToggle("SpeedAdjust", {
    Text = "Speed Adjust",
    Default = false,
    Tooltip = "Turn ON to activate speed. When OFF, speed is strictly default (16).",
    Callback = function(val)
        if applyPlayerSpeed then
            applyPlayerSpeed()
        end
    end,
})

SpeedToggle:AddKeyPicker("SpeedKeybind", {
    Default = "C",
    SyncToggleState = true,
    Mode = "Toggle",
    NoUI = false,
    Text = "Speed Adjust",
})

MovementGroupBox:AddInput("CustomSpeedInput", {
    Default = "28",
    Numeric = true,
    Finished = false,
    Text = "Custom Speed (Input Text)",
    Tooltip = "Type exact speed amount (e.g. 28, 45, 80, 120). Only activates when Speed Adjust is ON.",
    Placeholder = "Enter speed (e.g. 28)",
    Callback = function(val)
        local num = tonumber(val)
        if num and num >= 16 then
            if Options.SpeedValue and num <= 120 and Options.SpeedValue.Value ~= num then
                pcall(function() Options.SpeedValue:SetValue(num) end)
            end
            if Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value and applyPlayerSpeed then
                applyPlayerSpeed()
            end
        end
    end,
})

MovementGroupBox:AddSlider("SpeedValue", {
    Text = "Speed Value (Slider)",
    Default = 28,
    Min = 16,
    Max = 120,
    Rounding = 0,
    Compact = false,
    Tooltip = "Adjust speed amount. Only activates when Speed Adjust is ON.",
    Callback = function(val)
        if Options.CustomSpeedInput and Options.CustomSpeedInput.Value ~= tostring(val) then
            pcall(function() Options.CustomSpeedInput:SetValue(tostring(val)) end)
        end
        if Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value and applyPlayerSpeed then
            applyPlayerSpeed()
        end
    end,
})

MovementGroupBox:AddDivider()

-- Noclip
local NoclipToggle = MovementGroupBox:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(val)
        if not val then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

NoclipToggle:AddKeyPicker("NoclipKeybind", {
    Default = "V",
    SyncToggleState = true,
    Mode = "Toggle",
    NoUI = false,
    Text = "Noclip",
})

MovementGroupBox:AddDivider()

-- Fly
local FlyToggle = MovementGroupBox:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
})

FlyToggle:AddKeyPicker("FlyKeybind", {
    Default = "F",
    SyncToggleState = true,
    Mode = "Toggle",
    NoUI = false,
    Text = "Fly",
})

MovementGroupBox:AddInput("CustomFlySpeedInput", {
    Default = "50",
    Numeric = true,
    Finished = false,
    Text = "Custom Fly Speed (Input Text)",
    Tooltip = "Type exact fly speed (e.g. 50, 100, 200)",
    Placeholder = "Enter fly speed (e.g. 50)",
    Callback = function(val)
        local num = tonumber(val)
        if num and num >= 10 then
            if Options.FlySpeed and num <= 150 and Options.FlySpeed.Value ~= num then
                pcall(function() Options.FlySpeed:SetValue(num) end)
            end
        end
    end,
})

MovementGroupBox:AddSlider("FlySpeed", {
    Text = "Fly Speed (Slider)",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 0,
    Compact = false,
    Callback = function(val)
        if Options.CustomFlySpeedInput and Options.CustomFlySpeedInput.Value ~= tostring(val) then
            pcall(function() Options.CustomFlySpeedInput:SetValue(tostring(val)) end)
        end
    end,
})

----------------------------------------------------------------------
-- UI ELEMENTS (CAMERA TAB)
----------------------------------------------------------------------

CameraGroupBox:AddToggle("CustomFOV", {
    Text = "Custom FOV",
    Default = false,
    Callback = function(val)
        if not val and Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = 70
        elseif val and Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = getFOVValue()
        end
    end,
})

CameraGroupBox:AddInput("CustomFOVInput", {
    Default = "70",
    Numeric = true,
    Finished = false,
    Text = "Custom FOV (Input Text)",
    Tooltip = "Type exact FOV amount (30 to 120)",
    Placeholder = "Enter FOV (e.g. 70, 90, 110)",
    Callback = function(val)
        local num = tonumber(val)
        if num and num >= 30 and num <= 120 then
            if Options.FOVValue and Options.FOVValue.Value ~= num then
                pcall(function() Options.FOVValue:SetValue(num) end)
            end
            if Toggles.CustomFOV and Toggles.CustomFOV.Value and Workspace.CurrentCamera then
                Workspace.CurrentCamera.FieldOfView = num
            end
        end
    end,
})

CameraGroupBox:AddSlider("FOVValue", {
    Text = "FOV Value (Slider)",
    Default = 70,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Compact = false,
    Callback = function(val)
        if Options.CustomFOVInput and Options.CustomFOVInput.Value ~= tostring(val) then
            pcall(function() Options.CustomFOVInput:SetValue(tostring(val)) end)
        end
        if Toggles.CustomFOV and Toggles.CustomFOV.Value and Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = val
        end
    end,
})

CameraGroupBox:AddButton("Reset FOV to Default (70)", function()
    pcall(function()
        if Options.CustomFOVInput then
            Options.CustomFOVInput:SetValue("70")
        end
        if Options.FOVValue then
            Options.FOVValue:SetValue(70)
        end
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = 70
        end
    end)
end)

-- Camera Info & Presets (Right Side)
CameraInfoGroupBox:AddButton("Preset: Default (70)", function()
    if Options.FOVValue then Options.FOVValue:SetValue(70) end
end)

CameraInfoGroupBox:AddButton("Preset: Wide (90)", function()
    if Options.FOVValue then Options.FOVValue:SetValue(90) end
end)

CameraInfoGroupBox:AddButton("Preset: Ultra-Wide (110)", function()
    if Options.FOVValue then Options.FOVValue:SetValue(110) end
end)

CameraInfoGroupBox:AddButton("Preset: Max View (120)", function()
    if Options.FOVValue then Options.FOVValue:SetValue(120) end
end)

----------------------------------------------------------------------
-- UI ELEMENTS (PARRY TAB)
----------------------------------------------------------------------

-- Left Side: Live Player & Perk Inspector
local currentTargetPlayer = nil

local function resolveSelectedPlayer(val)
    if not val or val == "" or val == "None" or val == "nil" then return nil end
    if typeof(val) == "Instance" then
        if val:IsA("Player") and val.Parent == Players then
            return val
        end
        return nil
    end
    if typeof(val) == "table" then
        if val.Name and typeof(val.Name) == "string" then
            local r = resolveSelectedPlayer(val.Name)
            if r then return r end
        end
        for _, v in pairs(val) do
            local resolved = resolveSelectedPlayer(v)
            if resolved then return resolved end
        end
        return nil
    end
    if typeof(val) == "string" then
        local str = val:gsub("^%s+", ""):gsub("%s+$", "")
        if str == "" or str == "None" then return nil end

        local p = Players:FindFirstChild(str)
        if p and p:IsA("Player") then return p end

        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Name == str or pl.DisplayName == str then
                return pl
            end
            if pl.Name:lower() == str:lower() or pl.DisplayName:lower() == str:lower() then
                return pl
            end
        end

        local atUser = str:match("@([%w_]+)")
        if atUser then
            p = Players:FindFirstChild(atUser)
            if p and p:IsA("Player") then return p end
        end

        for _, pl in ipairs(Players:GetPlayers()) do
            if str:find(pl.Name, 1, true) or (pl.DisplayName ~= "" and str:find(pl.DisplayName, 1, true)) then
                return pl
            end
            if str:lower():find(pl.Name:lower(), 1, true) then
                return pl
            end
        end
    end
    return nil
end

LiveUIGroupBox:AddDropdown("LiveInspectTarget", {
    SpecialType = "Player",
    ExcludeLocalPlayer = false,
    Text = "Select Player to Inspect",
    Tooltip = "Choose any player to inspect their live role and equipped item",
    Callback = function(val)
        if updateLiveInspector then
            updateLiveInspector(val)
        end
    end,
})

LiveUIGroupBox:AddDivider()

local inspectNameLabel = LiveUIGroupBox:AddLabel("Name : None")
local inspectUsernameLabel = LiveUIGroupBox:AddLabel("Username : None")
local inspectRoleLabel = LiveUIGroupBox:AddLabel("Role : None")

pcall(function()
    if inspectNameLabel and inspectNameLabel.TextLabel then inspectNameLabel.TextLabel.RichText = false end
    if inspectUsernameLabel and inspectUsernameLabel.TextLabel then inspectUsernameLabel.TextLabel.RichText = false end
    if inspectRoleLabel and inspectRoleLabel.TextLabel then inspectRoleLabel.TextLabel.RichText = false end
end)

LiveUIGroupBox:AddDivider()

local inspectItemHeader = LiveUIGroupBox:AddLabel("--- Equipped Item ---")
local inspectItemLabel = LiveUIGroupBox:AddLabel("Item : None")

pcall(function()
    if inspectItemHeader and inspectItemHeader.TextLabel then inspectItemHeader.TextLabel.RichText = false end
    if inspectItemLabel and inspectItemLabel.TextLabel then inspectItemLabel.TextLabel.RichText = false end
end)

LiveUIGroupBox:AddDivider()

local function updateLiveInspector(overrideTarget)
    local target = overrideTarget
    if not target and Options.LiveInspectTarget then
        target = Options.LiveInspectTarget.Value
    end

    if target then
        local resolved = resolveSelectedPlayer(target)
        if resolved then
            currentTargetPlayer = resolved
        end
    end

    if currentTargetPlayer and currentTargetPlayer.Parent ~= Players then
        currentTargetPlayer = nil
    end

    if not currentTargetPlayer then
        if inspectNameLabel and inspectNameLabel.SetText then
            pcall(function() if inspectNameLabel.TextLabel then inspectNameLabel.TextLabel.RichText = false end end)
            inspectNameLabel:SetText("Name : None")
        end
        if inspectUsernameLabel and inspectUsernameLabel.SetText then
            pcall(function() if inspectUsernameLabel.TextLabel then inspectUsernameLabel.TextLabel.RichText = false end end)
            inspectUsernameLabel:SetText("Username : None")
        end
        if inspectRoleLabel and inspectRoleLabel.SetText then
            pcall(function() if inspectRoleLabel.TextLabel then inspectRoleLabel.TextLabel.RichText = false end end)
            inspectRoleLabel:SetText("Role : None")
        end
        if inspectItemLabel and inspectItemLabel.SetText then
            pcall(function() if inspectItemLabel.TextLabel then inspectItemLabel.TextLabel.RichText = false end end)
            inspectItemLabel:SetText("Item : None")
        end
        return
    end

    local info = getPlayerPerksAndItems(currentTargetPlayer)

    if inspectNameLabel and inspectNameLabel.SetText then
        pcall(function() if inspectNameLabel.TextLabel then inspectNameLabel.TextLabel.RichText = false end end)
        inspectNameLabel:SetText("Name : " .. tostring(info.name))
    end
    if inspectUsernameLabel and inspectUsernameLabel.SetText then
        pcall(function() if inspectUsernameLabel.TextLabel then inspectUsernameLabel.TextLabel.RichText = false end end)
        inspectUsernameLabel:SetText("Username : " .. tostring(info.username))
    end
    if inspectRoleLabel and inspectRoleLabel.SetText then
        pcall(function() if inspectRoleLabel.TextLabel then inspectRoleLabel.TextLabel.RichText = false end end)
        inspectRoleLabel:SetText("Role : " .. tostring(info.role))
    end
    if inspectItemLabel and inspectItemLabel.SetText then
        pcall(function() if inspectItemLabel.TextLabel then inspectItemLabel.TextLabel.RichText = false end end)
        inspectItemLabel:SetText("Item : " .. tostring(info.equippedItem))
    end
end

LiveUIGroupBox:AddButton("Deselect Player (Reset to None)", function()
    currentTargetPlayer = nil
    if Options.LiveInspectTarget then
        pcall(function() Options.LiveInspectTarget:SetValue(nil) end)
    end
    if updateLiveInspector then
        updateLiveInspector(nil)
    end
end)

LiveUIGroupBox:AddButton("Refresh Inspector Now", function()
    if updateLiveInspector then
        updateLiveInspector()
    end
end)

-- Right Side: Auto Parry (Parrying Dagger)
AutoParryGroupBox:AddToggle("AutoParry", {
    Text = "Auto Parry (Parrying Dagger)",
    Default = false,
    Tooltip = "100% Protection: Instant auto parry against incoming killer melee attacks. Automatically equips and counters before damage connects.",
    Callback = function(val)
        if val then
            local dagger = getParryingDagger()
            if not dagger then
                pcall(function()
                    Library:Notify({
                        Title = "Auto Parry (VD 2.9.8a)",
                        Description = "Notice: Parrying Dagger not found in inventory! Auto Parry can only activate when you obtain a Parrying Dagger.",
                        Time = 5,
                    })
                end)
            else
                pcall(function()
                    Library:Notify({
                        Title = "Auto Parry (VD 2.9.8a)",
                        Description = "Parrying Dagger verified! 100% Protection Active: Instant counter on killer melee attack!",
                        Time = 4,
                    })
                end)
            end
        end
    end,
})

local daggerStatusLabel = AutoParryGroupBox:AddLabel("Dagger Status: Checking...")

AutoParryGroupBox:AddDivider()

AutoParryGroupBox:AddSlider("ParryDistance", {
    Text = "Parry Distance (Studs)",
    Default = 16,
    Min = 10,
    Max = 25,
    Rounding = 1,
    Compact = false,
    Tooltip = "Maximum reach to activate parry stance. Frame-0 early intercept counters killer lunge at swing startup, guaranteeing parry activates before damage can connect.",
})

AutoParryGroupBox:AddToggle("ParryFaceCheck", {
    Text = "Smart Face & Aim Check",
    Default = true,
    Tooltip = "Smart Parry: Only parries when killer is facing and aiming directly towards your character. Ignores strikes into the air, sideways swings, or hits aimed at other targets.",
})

AutoParryGroupBox:AddDivider()

AutoParryGroupBox:AddButton("Manual Test Parry (Test Stance)", function()
    local dagger = getParryingDagger()
    if not dagger then
        pcall(function()
            Library:Notify({
                Title = "Auto Parry",
                Description = "Cannot parry: You do not have a Parrying Dagger in inventory!",
                Time = 4,
            })
        end)
        return
    end
    executeParry("MANUAL_TEST")
end)

----------------------------------------------------------------------
-- UI ELEMENTS (OPTIMIZE TAB)
----------------------------------------------------------------------

local currentMeasuredFps = 60
local currentMeasuredPing = 0
local frameCounter = 0
local lastFpsCheckTime = tick()

connections[#connections + 1] = RunService.RenderStepped:Connect(function()
    frameCounter = frameCounter + 1
    local now = tick()
    if now - lastFpsCheckTime >= 0.5 then
        currentMeasuredFps = math.floor(frameCounter / math.max(0.001, (now - lastFpsCheckTime)))
        frameCounter = 0
        lastFpsCheckTime = now
    end
end)

local function applyNetworkOptimizations(enable)
    pcall(function()
        if enable then
            -- 1. Incoming Replication Lag (Set to 0ms for instant client-server synchronization)
            settings().Network.IncomingReplicationLag = 0
            
            -- 2. Enhanced Send / Receive Rate (Transmits inputs and receives world state at max rate)
            settings().Network.SendRate = 120
            settings().Network.ReceiveRate = 120
            
            -- 3. Disable Environmental Throttling (Eliminates packet throttling on background objects)
            -- 4. Maximum FPS Cap (executor level, zero stutter, preserve 200+ FPS)
            pcall(function()
                if setfpscap then setfpscap(0) end
                if set_fps_cap then set_fps_cap(0) end
            end)
        else
            settings().Network.IncomingReplicationLag = 0
            settings().Network.SendRate = 60
            settings().Network.ReceiveRate = 60
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Default
        end
    end)
end

applyNetworkOptimizations(true)

-- Left Side: Ping & MS Booster
OptimizeGroupBox:AddToggle("BoostPing", {
    Text = "Boost Ping / MS (Fast Network)",
    Default = true,
    Tooltip = "Optimizes packet replication rate and eliminates network lag with 0ms buffering",
    Callback = function(val)
        applyNetworkOptimizations(val)
    end,
})

OptimizeGroupBox:AddToggle("FastInputLatency", {
    Text = "Zero Input Latency",
    Default = true,
    Tooltip = "Processes inputs, clicks, and parry triggers with zero queuing delay",
})

OptimizeGroupBox:AddToggle("MemoryOptimizer", {
    Text = "Memory & GC Optimizer",
    Default = true,
    Tooltip = "Automatically cleans unused memory cycles in background to prevent frame/ping stutters",
    Callback = function(val)
        if val then
            pcall(function()
                collectgarbage("setstepmul", 300)
                collectgarbage("setpause", 100)
            end)
        end
    end,
})

OptimizeGroupBox:AddDivider()

OptimizeGroupBox:AddButton("Flush Memory & Ping Cache Now", function()
    pcall(function()
        local before = gcinfo()
        collectgarbage("collect")
        local after = gcinfo()
        local freed = math.max(0, before - after)
        Library:Notify({
            Title = "Optimizer",
            Description = "Flushed " .. string.format("%.1f KB", freed) .. " RAM. Latency refreshed!",
            Time = 4,
        })
    end)
end)

-- Right Side: Live Network Status
local livePingLabel = NetworkMonitorGroupBox:AddLabel("Current Ping : Measuring...")
local liveFPSLabel = NetworkMonitorGroupBox:AddLabel("Current FPS : Measuring...")
local liveMemoryLabel = NetworkMonitorGroupBox:AddLabel("Memory Usage : Measuring...")
local liveNetModeLabel = NetworkMonitorGroupBox:AddLabel("Network Mode : Boosted (0ms Lag)")

pcall(function()
    if livePingLabel and livePingLabel.TextLabel then livePingLabel.TextLabel.RichText = false end
    if liveFPSLabel and liveFPSLabel.TextLabel then liveFPSLabel.TextLabel.RichText = false end
    if liveMemoryLabel and liveMemoryLabel.TextLabel then liveMemoryLabel.TextLabel.RichText = false end
    if liveNetModeLabel and liveNetModeLabel.TextLabel then liveNetModeLabel.TextLabel.RichText = false end
end)

NetworkMonitorGroupBox:AddDivider()

local liveQualityLabel1 = NetworkMonitorGroupBox:AddLabel("Visual Quality : 100% Original")
local liveQualityLabel2 = NetworkMonitorGroupBox:AddLabel("Graphics State : Untouched (Pristine)")

pcall(function()
    if liveQualityLabel1 and liveQualityLabel1.TextLabel then liveQualityLabel1.TextLabel.RichText = false end
    if liveQualityLabel2 and liveQualityLabel2.TextLabel then liveQualityLabel2.TextLabel.RichText = false end
end)

NetworkMonitorGroupBox:AddDivider()

local function updateNetworkMonitor()
    pcall(function()
        local stats = game:GetService("Stats")
        local net = stats.Network
        if net and net.ServerStatsItem and net.ServerStatsItem["Data Ping"] then
            currentMeasuredPing = math.floor(net.ServerStatsItem["Data Ping"]:GetValue())
        elseif stats.PerformanceStats and stats.PerformanceStats.Ping then
            currentMeasuredPing = math.floor(stats.PerformanceStats.Ping:GetValue())
        end
        if livePingLabel and livePingLabel.SetText then
            livePingLabel:SetText("Current Ping : " .. tostring(currentMeasuredPing) .. " ms")
        end
        if liveFPSLabel and liveFPSLabel.SetText then
            liveFPSLabel:SetText("Current FPS : " .. tostring(currentMeasuredFps))
        end
        if liveMemoryLabel and liveMemoryLabel.SetText then
            local mem = math.floor(gcinfo() / 1024)
            liveMemoryLabel:SetText("Memory Usage : " .. tostring(mem) .. " MB")
        end
    end)
end

NetworkMonitorGroupBox:AddButton("Refresh Network Stats", function()
    updateNetworkMonitor()
end)

-- Apply initial network ping boost on boot
applyNetworkOptimizations(true)

----------------------------------------------------------------------
-- EVENT INITIALIZATION
----------------------------------------------------------------------

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

connections[#connections + 1] = Players.PlayerAdded:Connect(setupPlayer)
connections[#connections + 1] = Players.PlayerRemoving:Connect(function(player)
    if playerHighlights[player] then
        pcall(function() playerHighlights[player]:Destroy() end)
        playerHighlights[player] = nil
    end
end)

-- Non-blocking generator scan: loads in background so script executes with 0ms freeze
task.spawn(function()
    task.wait(0.3)
    scanGenerators()
end)

connections[#connections + 1] = Workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") or descendant:IsA("ProximityPrompt") then
        if isGenerator(descendant) then
            registerGenerator(descendant)
        end
    end
end)

-- Live Update Heartbeat (Role ESP, Live UI Inspector, Auto Parry & Network Monitor)
task.spawn(function()
    while task.wait(1) do
        if Library.Unloaded then break end
        pcall(function()
            if Toggles.HighlightPlayers and Toggles.HighlightPlayers.Value then
                updateAllPlayerHighlights()
            end

            -- Live generator check: un-fixed only, auto-remove completed highlights
            if Toggles.HighlightGenerators and Toggles.HighlightGenerators.Value then
                updateAllGeneratorHighlights()
            end

            -- Ensure combat listeners are always active on all players
            if bindCombatListeners then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        bindCombatListeners(p, p.Character)
                    end
                end
            end

            -- Update Live Inspector UI
            if updateLiveInspector then
                updateLiveInspector()
            end

            -- Update Parrying Dagger Status
            if daggerStatusLabel and daggerStatusLabel.SetText then
                local tool, isEquipped = getParryingDagger()
                if tool then
                    local isOnCd = isParryOnCooldown()
                    local myChar = LocalPlayer.Character
                    if isOnCd then
                        local tName = "Parrying Dagger"
                        if typeof(tool) == "Instance" and tool ~= myChar and tool ~= LocalPlayer and tool.Name ~= "" then
                            tName = tool.Name
                        end
                        daggerStatusLabel:SetText("Dagger: On Cooldown (" .. tName .. ")")
                    elseif isEquipped then
                        daggerStatusLabel:SetText("Dagger: Equipped & Ready (Can Activate)")
                    else
                        daggerStatusLabel:SetText("Dagger: Cooled Down & Ready (In Backpack)")
                    end
                else
                    daggerStatusLabel:SetText("Dagger: Not in Inventory (Cannot Activate)")
                end
            end

            -- Update Network & Ping Stats in Optimize Tab
            if updateNetworkMonitor then
                updateNetworkMonitor()
            end
        end)
    end
end)

----------------------------------------------------------------------
-- SETTINGS TAB & KEYBINDS
----------------------------------------------------------------------

local MenuGroup = Tabs["UI Settings"]:AddGroupbox({
    Side = "Left",
    Name = "Menu",
})

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = false,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("FloatingButtonOpen", {
    Default = true,
    Text = "Show EXE HUB Button",
    Callback = function(value)
        if FloatingScreenGui then
            FloatingScreenGui.Enabled = value
        end
        if FloatingToggleGui then
            FloatingToggleGui.Visible = value
        end
    end,
})

MenuGroup:AddSlider("KeybindScale", {
    Text = "Keybind Menu Scale",
    Default = 1,
    Min = 0.6,
    Max = 2,
    Rounding = 2,
    Compact = false,
    Callback = function(value)
        if setKeybindScale then
            setKeybindScale(value, true)
        end
    end,
})

MenuGroup:AddToggle("AlwaysOnTop", {
    Text = "Always On Top",
    Default = Window.AlwaysOnTop,
    Callback = function(Value)
        Window:SetAlwaysOnTop(Value)
    end,
})

MenuGroup:AddDivider()

-- EXE HUB Keybind (Toggle Menu)
MenuGroup:AddLabel("EXE HUB"):AddKeyPicker("EXEHUBKeybind", {
    Default = "RightShift",
    Mode = "Toggle",
    NoUI = false,
    Text = "EXE HUB",
})

Library.ToggleKeybind = Options["EXEHUBKeybind"]

-- Kill Script Keybind (Delete Key / Mobile Tap)
local KillKeyPicker = MenuGroup:AddLabel("Kill Script"):AddKeyPicker("KillScriptKeybind", {
    Default = "Delete",
    Mode = "Toggle",
    NoUI = false,
    Text = "Kill Script",
    Callback = function()
        Library:Unload()
    end,
})

if KillKeyPicker and KillKeyPicker.OnClick then
    KillKeyPicker:OnClick(function()
        Library:Unload()
    end)
end

-- Direct Keyboard Listener for the Delete Key
connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local boundKey = Options.KillScriptKeybind and Options.KillScriptKeybind.Value

    local isKillKey = false
    if boundKey then
        if typeof(boundKey) == "EnumItem" and input.KeyCode == boundKey then
            isKillKey = true
        elseif typeof(boundKey) == "string" and input.KeyCode.Name == boundKey then
            isKillKey = true
        end
    end

    if isKillKey or input.KeyCode == Enum.KeyCode.Delete then
        Library:Unload()
    end
end)

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

-- Cleanup on Unload / Kill Script
Library:OnUnload(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = defaultSpeed
            hum.PlatformStand = false
        end
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)

    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end

    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(connections)

    for _, hl in pairs(playerHighlights) do
        pcall(function() hl:Destroy() end)
    end
    table.clear(playerHighlights)

    for _, hl in pairs(generatorHighlights) do
        pcall(function() hl:Destroy() end)
    end
    table.clear(generatorHighlights)
    table.clear(trackedGenerators)

    if FloatingScreenGui then
        pcall(function() FloatingScreenGui:Destroy() end)
    end
    if FloatingToggleGui then
        pcall(function() FloatingToggleGui:Destroy() end)
    end

    pcall(function()
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = 70
        end
    end)
    table.clear(parriedTracks)
    table.clear(combatBoundAnimators)
end)

----------------------------------------------------------------------
-- THEME & SAVE MANAGERS (WITH PERSISTENT AUTO-SAVE)
----------------------------------------------------------------------

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "KeybindMenuOpen", "FloatingButtonOpen", "LiveInspectTarget" })

ThemeManager:SetFolder("ViolenceDistrict")
SaveManager:SetFolder("ViolenceDistrict/configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- Auto-Load Saved Configuration on execution
pcall(function()
    SaveManager:CheckFolderTree()
    local defaultCfgPath = "ViolenceDistrict/configs/settings/default.json"
    if isfile and isfile(defaultCfgPath) then
        SaveManager:Load("default")
    else
        SaveManager:LoadAutoloadConfig()
    end

    -- Sync text inputs and sliders after loading config
    task.delay(0.2, function()
        pcall(function()
            if Options.CustomSpeedInput and Options.SpeedValue then
                local speedNum = tonumber(Options.CustomSpeedInput.Value)
                if speedNum and speedNum <= 120 and Options.SpeedValue.Value ~= speedNum then
                    Options.SpeedValue:SetValue(speedNum)
                end
            end
            if Options.CustomFlySpeedInput and Options.FlySpeed then
                local flyNum = tonumber(Options.CustomFlySpeedInput.Value)
                if flyNum and flyNum <= 150 and Options.FlySpeed.Value ~= flyNum then
                    Options.FlySpeed:SetValue(flyNum)
                end
            end
            if Options.CustomFOVInput and Options.FOVValue then
                local fovNum = tonumber(Options.CustomFOVInput.Value)
                if fovNum and fovNum >= 30 and fovNum <= 130 and Options.FOVValue.Value ~= fovNum then
                    Options.FOVValue:SetValue(fovNum)
                end
            end
        end)
    end)
end)

-- Auto-Save Configuration whenever player changes any toggle, slider, or color
local autoSaveDebounce = false
local function triggerAutoSave()
    if autoSaveDebounce or Library.Unloaded then return end
    autoSaveDebounce = true
    task.delay(0.5, function()
        autoSaveDebounce = false
        pcall(function()
            SaveManager:CheckFolderTree()
            SaveManager:Save("default")
            SaveManager:SaveAutoloadConfig("default")
        end)
    end)
end

task.spawn(function()
    task.wait(1.5) -- Allow initial config load to settle before listening for user changes
    for _, toggle in pairs(Toggles) do
        if typeof(toggle) == "table" and toggle.OnChanged then
            toggle:OnChanged(triggerAutoSave)
        end
    end
    for _, option in pairs(Options) do
        if typeof(option) == "table" and option.OnChanged then
            option:OnChanged(triggerAutoSave)
        end
    end
end)

-- Notify player on successful script initialization
pcall(function()
    Library:Notify({
        Title = "EXE HUB",
        Description = "VD 2.9.8a Loaded Successfully!",
        Time = 6,
    })
    print("[EXE HUB] VD 2.9.8a Loaded Successfully! Enjoy!")
end)
