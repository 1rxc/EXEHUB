-- Violence District | EXE HUB Script VD 1.9 (Obsidian UI)
-- Keybinds: EXE HUB (Toggle Menu) | Delete (Kill / Close Script)
-- Tabs: ESP | Automatic | Player | Settings

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

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

-- Fly tracking
local flyBodyVelocity = nil
local flyBodyGyro = nil

-- Create Window
local Window = Library:CreateWindow({
    Title = "EXE HUB",
    Footer = "VD 1.9",
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

----------------------------------------------------------------------
-- ROLE & DETECTION LOGIC
----------------------------------------------------------------------

local function isKiller(player)
    if not player then return false end
    local char = player.Character

    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("kill") or teamName:find("monster") or teamName:find("hunter") or teamName:find("beast") then
            return true
        end
    end

    local pRole = player:GetAttribute("Role") or player:GetAttribute("Team")
    if typeof(pRole) == "string" and (pRole:lower():find("kill") or pRole:lower():find("monster")) then
        return true
    end
    if player:GetAttribute("IsKiller") == true or player:GetAttribute("Killer") == true then
        return true
    end

    if char then
        local cRole = char:GetAttribute("Role") or char:GetAttribute("Team")
        if typeof(cRole) == "string" and (cRole:lower():find("kill") or cRole:lower():find("monster")) then
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
            if roleVal.Value:lower():find("kill") or roleVal.Value:lower():find("monster") then
                return true
            end
        end

        if char:FindFirstChild("Killer") or player:FindFirstChild("Killer") or char:FindFirstChild("IsKiller") or player:FindFirstChild("IsKiller") then
            return true
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

local function setupPlayer(player)
    connections[#connections + 1] = player.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        applyPlayerHighlight(player, char)
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
    end)

    if player.Character then
        applyPlayerHighlight(player, player.Character)
    end
end

local function updateGenHighlight(hl)
    if not hl or not hl.Parent then return end
    hl.Enabled = Toggles.HighlightGenerators.Value
    hl.FillColor = Options.GenFillColor.Value

    local showOutline = (Toggles.GenOutline and Toggles.GenOutline.Value) or false
    hl.OutlineColor = Options.GenOutlineColor.Value
    hl.FillTransparency = Options.GenFillTransparency.Value
    hl.OutlineTransparency = showOutline and 0 or 1
end

local function updateAllGeneratorHighlights()
    for _, hl in pairs(generatorHighlights) do
        updateGenHighlight(hl)
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
    updateGenHighlight(hl)

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

    -- 2. Dispatch all buttons and interactive elements in SkillCheckPromptGui
    if promptGui then
        for _, desc in ipairs(promptGui:GetDescendants()) do
            if desc:IsA("GuiButton") or (desc:IsA("GuiObject") and desc.Name:lower():find("check")) then
                if firesignal then
                    pcall(function() firesignal(desc.Activated) end)
                    pcall(function() firesignal(desc.MouseButton1Click) end)
                end
                if getconnections then
                    for _, sigName in ipairs({"Activated", "MouseButton1Click"}) do
                        local sig = desc[sigName]
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
-- ULTIMATE ANTI STUN SYSTEM (VD 1.9 - NON-BLOCKING & BULLETPROOF)
----------------------------------------------------------------------

-- Action Protection: Animations that must NEVER be stopped by AntiStun
local function isProtectedActionAnim(name)
    name = name:lower()
    return name:find("drop")
        or name:find("pallet")
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
        or name:find("m1")
        or name:find("walk")
        or name:find("run")
        or name:find("idle")
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

-- 3. Targeted Frame Loop: Breaks genuine stuns only and guarantees clicks/interactions stay active
connections[#connections + 1] = RunService.Heartbeat:Connect(function()
    if not (Toggles.AntiStun and Toggles.AntiStun.Value) then return end

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    -- Check if character is genuinely afflicted by a stun or ragdoll
    local hasStunAttr = (char:GetAttribute("Stunned") == true)
        or (char:GetAttribute("IsStunned") == true)
        or (char:GetAttribute("Headache") == true)
        or (char:GetAttribute("Blinded") == true)
        or (char:GetAttribute("Slowed") == true)
        or (char:GetAttribute("Frozen") == true)

    local isRagdolled = (hum.PlatformStand == true and not (Toggles.Fly and Toggles.Fly.Value))
        or (hum:GetState() == Enum.HumanoidStateType.Ragdoll)
        or (hum:GetState() == Enum.HumanoidStateType.Physics)
        or (hum:GetState() == Enum.HumanoidStateType.FallingDown)
        or (hum.Sit == true and not (char:FindFirstChildOfClass("VehicleSeat")))

    -- Break stun immediately only if genuinely stunned
    if hasStunAttr or isRagdolled then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

        if hum.PlatformStand and not (Toggles.Fly and Toggles.Fly.Value) then
            hum.PlatformStand = false
        end
        if hum.Sit then
            hum.Sit = false
        end

        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum:ChangeState(Enum.HumanoidStateType.Running)

        -- Unanchor if anchored by stun
        if root and root.Anchored then
            root.Anchored = false
        end

        -- Restore WalkSpeed if zeroed by stun
        local targetSpeed = (Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value and getSpeedValue()) or defaultSpeed
        if hum.WalkSpeed < 16 then
            hum.WalkSpeed = targetSpeed
        end

        -- Stop ONLY genuine stun / blind animations (NEVER touch pallet, drop, repair, attack)
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local animName = track.Name:lower()
                if not isProtectedActionAnim(animName) then
                    if animName:find("stun") or animName:find("blind") or animName:find("headache") then
                        pcall(function() track:Stop(0) end)
                    end
                end
            end
        end

        -- Clear stun attributes
        for _, attr in ipairs({"Stunned", "Stun", "Slowed", "Frozen", "Blinded", "IsStunned", "Headache"}) do
            if char:GetAttribute(attr) then
                char:SetAttribute(attr, false)
            end
        end
    end

    -- Safeguard: Always ensure movement is enabled
    if char:GetAttribute("CanMove") == false then
        char:SetAttribute("CanMove", true)
    end

    -- Safeguard: Ensure Tools in character are always enabled for Left/Right Click
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and not child.Enabled then
            child.Enabled = true
        end
        if child:IsA("ValueBase") then
            local cName = child.Name:lower()
            if cName:find("stun") or cName:find("blind") or cName:find("freeze") then
                if child:IsA("BoolValue") and child.Value == true then
                    child.Value = false
                end
            end
        end
    end
end)

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
    if Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value and not (Toggles.Fly and Toggles.Fly.Value) then
        local targetSpeed = getSpeedValue()
        if hum then
            hum.WalkSpeed = targetSpeed
            if hum.MoveDirection.Magnitude > 0 and root and targetSpeed > 16 then
                local extraSpeed = (targetSpeed - 16)
                root.CFrame = root.CFrame + (hum.MoveDirection * (extraSpeed * dt))
            end
        end
        if char:GetAttribute("Speed") then
            pcall(function() char:SetAttribute("Speed", targetSpeed) end)
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

-- Highlight Generators
ESPGroupBox:AddToggle("HighlightGenerators", {
    Text = "Highlight Generator",
    Default = false,
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
    Callback = function(val)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and not val then
            hum.WalkSpeed = defaultSpeed
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
    Tooltip = "Type exact speed amount (e.g. 28, 45, 80, 150)",
    Placeholder = "Enter speed (e.g. 28)",
    Callback = function(val)
        local num = tonumber(val)
        if num and num >= 16 then
            if Options.SpeedValue and num <= 120 and Options.SpeedValue.Value ~= num then
                pcall(function() Options.SpeedValue:SetValue(num) end)
            end
            if Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = num
                end
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
    Callback = function(val)
        if Options.CustomSpeedInput and Options.CustomSpeedInput.Value ~= tostring(val) then
            pcall(function() Options.CustomSpeedInput:SetValue(tostring(val)) end)
        end
        if Toggles.SpeedAdjust and Toggles.SpeedAdjust.Value then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = val
            end
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

scanGenerators()

connections[#connections + 1] = Workspace.DescendantAdded:Connect(function(descendant)
    if isGenerator(descendant) then
        registerGenerator(descendant)
    end
end)

-- Role update heartbeat
task.spawn(function()
    while task.wait(1) do
        if Library.Unloaded then break end
        if Toggles.HighlightPlayers and Toggles.HighlightPlayers.Value then
            updateAllPlayerHighlights()
        end
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
end)

----------------------------------------------------------------------
-- THEME & SAVE MANAGERS (WITH PERSISTENT AUTO-SAVE)
----------------------------------------------------------------------

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "KeybindMenuOpen", "FloatingButtonOpen" })

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
        Description = "VD 1.9 Loaded Successfully!",
        Time = 6,
    })
    print("[EXE HUB] VD 1.9 Loaded Successfully! Enjoy!")
end)
