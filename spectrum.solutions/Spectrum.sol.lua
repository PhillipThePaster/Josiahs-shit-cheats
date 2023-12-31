--// Spectrum.solutions Paid \\--

local repo = 'https://raw.githubusercontent.com/Taskcc/smeth/main/'

local Username = game.Players.LocalPlayer.Name
 
game.StarterGui:SetCore("SendNotification", {
    Title = "Info Board",
    Text = "Hello," .. Username .. " welcome to spectrum.solutions v3",
    Duration = 10
})

   local varsglobal = {
        cursor = {
            Enabled = false,
            CustomPos = false,
            Position = Vector2.new(0,0),
            Speed = 5,
            Radius = 25,
            Color = Color3.fromRGB(180, 50, 255),
            Thickness = 1.7,
            Outline = false,
            Resize = false,
            Dot = false,
            Gap = 10,
            TheGap = false,
            Text = {
                Logo = false,
                LogoColor = Color3.new(1,1,1),
                Name = false,
                NameColor = Color3.new(1,1,1),
                LogoFadingOffset = 0,
            }
        },
    --[[    pdelta = {
            drawfov = false,
            aimfov = 0,
            silentaim = false,
            silentaimpart = "HumanoidRootPart",
            fovcheck = false,
            fovcolor = Color3.new(1,1,1),
            fovoutline = false,
            p2cmode = 0,
            instabullet = false,
            corpseesp = false,
            corpsecolor = Color3.new(1,1,1),
            AA = false,
            AAangle = 0,
            AIesp = false,
            AIcolor = Color3.new(1,1,1),
            npcsilentaim = false,
            hitlogs = false,
            hitsound = false,
            hittracers = false,
            hittracerscolor = Color3.new(1,1,1),
            hittracerslife = 5,
            hittracersdecal = "",
        },--]]
   }

--[[
local notifications = {}
local function hitmarker_update()
    for i = 1, #notifications do
        notifications[i].Position = Vector2.new((camera.ViewportSize / 2).X,((camera.ViewportSize / 2).Y + 150) + (i * 18))
    end
end

local function hitmarker(Username, duration)
    wrap(function()
        local hitlog = Drawing.new('Text')
        hitlog.Size = 13
        hitlog.Font = 2
        hitlog.Text = '[spectrum.solutions] damage hit to '..Username..' in; im too lazy to code the bone'
        hitlog.Visible = true
        hitlog.ZIndex = 3
        hitlog.Center = true
        hitlog.Color = Color3.fromRGB(212, 0, 255)
        hitlog.Outline = true

        table.insert(notifications, hitlog)
        hitmarker_update()

        wait(duration)
        table.remove(notifications, table.find(notifications, hitlog))
        hitmarker_update()
        hitlog:Remove()
    end)
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild('Humanoid').HealthChanged:Connect(function(health)
            if varsglobal.pdelta.hitlogs then
                hitmarker("Humanoid", player.Name, 3)
            end
        end)
    end)
end)
--]]

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'spectrum.solutions | v3 | Invite Only',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.3
})

local Tabs = {
    ['UI Settings'] = Window:AddTab(' Main '),
	Visuals = Window:AddTab(' Visuals '),
    Main = Window:AddTab(' Combat '),
    Player = Window:AddTab(' Player '),
    World = Window:AddTab(' World '),
    MiscShit = Window:AddTab(' Misc '),
}

local SilentStuff = Tabs.Main:AddLeftTabbox()

local VisualHolder = Tabs.Visuals:AddLeftTabbox('Humans')
local Visuals = VisualHolder:AddTab('Humans')

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local workspace = game.Workspace

local playerTags = {}
local healthBars = {}

local settings = {
    Enabled = true,
    ShowNames = true,
    ShowDistance = true,
    ShowCurrentGun = true, 
    ShowHealthBar = true,
    UseTeamColors = false,
    
    TextSize = 13,
    MaxDistance = 3500,
    ESPColor = Color3.fromRGB(252,160,255),
    HealthBarColor = Color3.fromRGB(252,160,255),
}

-- Gun function
local function getCurrentGun(player)
    local currentSelectedObject = tostring(player.CurrentSelectedObject.Value)
    local success, currentGun = pcall(function()
        return player.GunInventory[currentSelectedObject].Value
    end)

    if not success or not currentGun then
        for _, gun in pairs(player.GunInventory:GetChildren()) do
            if gun.Value == currentSelectedObject then
                currentGun = gun
                break
            end
        end
    end

    return currentGun
end

local function createHealthBar(player)
    local healthBarBackground = Drawing.new("Square")
    healthBarBackground.Visible = false
    healthBarBackground.Thickness = 3
    healthBarBackground.Color = Color3.new(0, 0, 0)
    healthBarBackground.Filled = true

    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Thickness = 1
    healthBar.Color = settings.HealthBarColor
    healthBar.Filled = true

    healthBars[player] = {
        background = healthBarBackground,
        bar = healthBar
    }

    return healthBars[player]
end

local function removeHealthBarFromPlayer(player)
    if healthBars[player] then
        healthBars[player].background:Remove()
        healthBars[player].bar:Remove()
        healthBars[player] = nil
    end
end

local function updateHealthBar(targetPlayer)
    local character = targetPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local healthBar = healthBars[targetPlayer]
            healthBar.bar.Color = Color3.fromHSV(humanoid.Health / humanoid.MaxHealth, 1, 1)
            healthBar.bar.Size = Vector2.new(humanoid.Health / humanoid.MaxHealth * 60, 6)
        else
            removeHealthBarFromPlayer(targetPlayer)
        end
    else
        removeHealthBarFromPlayer(targetPlayer)
    end
end

local function createPlayerTag(player)
    local nameTagInstance = Drawing.new("Text")
    nameTagInstance.Center = true
    nameTagInstance.Outline = true
    nameTagInstance.Visible = false
    nameTagInstance.Color = settings.ESPColor

    playerTags[player.Name] = {
        nameTag = nameTagInstance,
        healthBar = settings.ShowHealthBar and createHealthBar(player)
    }
end

local function removePlayerTagFromPlayer(player)
    if playerTags[player.Name] then
        playerTags[player.Name].nameTag:Remove()
        removeHealthBarFromPlayer(player)
        playerTags[player.Name] = nil
    end
end

-- Updated tag function
local function updateTag(targetPlayer)
    local character = targetPlayer.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            local headScreenPos, isVisible = camera:WorldToViewportPoint(head.Position)
            local nameTag = playerTags[targetPlayer.Name].nameTag
            if isVisible then
                nameTag.Position = Vector2.new(headScreenPos.X, headScreenPos.Y - nameTag.Size - 50)  -- Updated position
                nameTag.Text = ""
                nameTag.Size = settings.TextSize
                nameTag.Visible = settings.Enabled and settings.ShowNames
                
                if settings.UseTeamColors then
                    local teamColor = targetPlayer.TeamColor.Color
                    nameTag.Color = teamColor
                    if healthBars[targetPlayer] then
                        healthBars[targetPlayer].bar.Color = teamColor
                    end
                else
                    nameTag.Color = settings.ESPColor
                    if healthBars[targetPlayer] then
                        healthBars[targetPlayer].bar.Color = settings.HealthBarColor
                    end
                end
                
                if settings.ShowNames then
                    nameTag.Text = targetPlayer.Name
                end

                if settings.ShowDistance then
                    local distanceSuccess, distance = pcall(function() 
                        return (LocalPlayer.Character.Head.Position - head.Position).Magnitude
                    end)

                    if distanceSuccess then
                        nameTag.Text = nameTag.Text .. "\n[" .. math.floor(distance) .. " studs]"
                    end
                end
                
                if settings.ShowCurrentGun then
                    local gun = getCurrentGun(targetPlayer)
                    nameTag.Text = nameTag.Text .. "\n[" .. tostring(gun) .. "]"
                end
                
                if settings.ShowHealthBar and healthBars[targetPlayer] then
                    local healthBar = healthBars[targetPlayer]
                    healthBar.background.Visible = settings.Enabled
                    healthBar.background.Position = Vector2.new(headScreenPos.X - 30, headScreenPos.Y - 70)
                    healthBar.background.Size = Vector2.new(60, 6)
                    
                    healthBar.bar.Visible = settings.Enabled
                    healthBar.bar.Position = Vector2.new(headScreenPos.X - 30, headScreenPos.Y - 70)
                    local character = targetPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    healthBar.bar.Size = humanoid and Vector2.new(humanoid.Health / humanoid.MaxHealth * 60, 6) or Vector2.new(0, 6)
                end
            else
                nameTag.Visible = false
                if healthBars[targetPlayer] then
                    healthBars[targetPlayer].background.Visible = false
                    healthBars[targetPlayer].bar.Visible = false
                end
            end
        else
            removePlayerTagFromPlayer(targetPlayer)
        end
    else
        removePlayerTagFromPlayer(targetPlayer)
    end
end

local ESPSettings = Visuals:AddToggle('Enabled', {
    Text = 'ESP',
    Default = settings.Enabled,
    Callback = function(state)
        settings.Enabled = state
    end
})

ESPSettings:AddColorPicker('EnabledColor', {
    Default = settings.ESPColor,
    Title = 'ESP Color 2',
    Callback = function(color)
        settings.ESPColor = color
        settings.HealthBarColor = color
    end
})

Visuals:AddToggle('ShowNames', {
    Text = 'Names',
    Default = settings.ShowNames,
    Callback = function(state)
        settings.ShowNames = state
    end
})

Visuals:AddToggle('Boxes', {
    Text = 'Boxes',
    Default = false,

    Callback = function(state)
    end
})

Visuals:AddToggle('ShowDistance', {
    Text = 'Distance',
    Default = settings.ShowDistance,
    Callback = function(state)
        settings.ShowDistance = state
    end
})

Visuals:AddToggle('ShowCurrentGun', {
    Text = 'Current Gun',
    Default = settings.ShowCurrentGun,
    Callback = function(state)
        settings.ShowCurrentGun = state
    end
})

Visuals:AddToggle('ShowHealthBar', {
    Text = 'Health Bar',
    Default = settings.ShowHealthBar,
    Callback = function(state)
        settings.ShowHealthBar = state
    end
})

local highlightColor = Color3.fromRGB(252,160,255)
local highlightedPlayers = {}

local function addHighlightToPlayer(player)
    if player == LocalPlayer then return end
    
    local Highlight = Instance.new("Highlight")
    Highlight.FillColor = highlightColor
    Highlight.OutlineColor = highlightColor
    Highlight.FillTransparency = highlightFill
    Highlight.Parent = player.Character
    
    highlightedPlayers[player] = Highlight
end

local function removeHighlightFromPlayer(player)
    if highlightedPlayers[player] then
        highlightedPlayers[player]:Destroy()
        highlightedPlayers[player] = nil
    end
end

local renderConnection

local PlayerHighlightToggle = Visuals:AddToggle('PlayerHighlight', {
    Text = 'Player Highlight',
    Default = false,
    Callback = function(value)
        if value then
            for _, player in ipairs(Players:GetPlayers()) do
                addHighlightToPlayer(player)
            end
            
            Players.PlayerAdded:Connect(addHighlightToPlayer)
            Players.PlayerRemoving:Connect(removeHighlightFromPlayer)
            
            renderConnection = RunService.RenderStepped:Connect(function()
                for player, highlight in pairs(highlightedPlayers) do
                    pcall(function()
                        if player.Character then
                            highlight.Parent = player.Character
                        else
                            highlightedPlayers[player] = nil
                        end
                    end)
                end
            end)
        else
            for _, player in ipairs(Players:GetPlayers()) do
                removeHighlightFromPlayer(player)
            end
            
            if renderConnection then
                renderConnection:Disconnect()
            end
        end
    end
})

PlayerHighlightToggle:AddColorPicker('HighlightColorPicker', {
    Default = highlightColor,
    Title = 'Highlight Color',
    Callback = function(value)
        highlightColor = value
        for _, highlight in pairs(highlightedPlayers) do
            highlight.FillColor = value
            highlight.OutlineColor = value
        end
    end
})

Visuals:AddToggle('PlayerHighlightFill', {
    Text = 'Fill Highlights',
    Default = false,
    Callback = function(value)
        local transparency = value and 0 or 1
        for _, highlight in pairs(highlightedPlayers) do
            highlight.FillTransparency = transparency
        end
    end
})

Visuals:AddToggle('UseTeamColors', {
    Text = 'Team Colors',
    Default = false,
    Callback = function(state)
        settings.UseTeamColors = state
    end
})

Visuals:AddSlider("Size", {
    Text = "Size",
    Default = 13,
    Min = 8,
    Max = 32,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
        settings.TextSize = value
    end
})

Visuals:AddSlider("Max Distance", {
    Text = "Max Distance",
    Default = 2500,
    Min = 10,
    Max = 4000,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
        settings.MaxDistance = value
    end
})

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createPlayerTag(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerTagFromPlayer(player)
end)

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if playerTags[player.Name] then
                updateTag(player)
            else
                createPlayerTag(player)
                updateTag(player)
            end
        end
    end
end)

local Visual2Holder = Tabs.Visuals:AddLeftTabbox('Dead Bodies')
local Visuals2 = Visual2Holder:AddTab('Dead Bodies')

local player = game.Players.LocalPlayer
local workspace = game.Workspace
local camera = workspace.CurrentCamera

local nameTags = {}

local settings = {
    Enabled = true,
    ShowNames = true,
    ShowDistance = true,
    TextSize = 13,
    MaxDistance = 3000,
    Color = Color3.new(1, 1, 1)
}

local enabledToggle = Visuals2:AddToggle("Enabled", {
    Text = "Enabled",
    Default = true,
    Callback = function(state)
    settings.Enabled = state
    end
})

enabledToggle:AddColorPicker("NameTagColorPicker", {
    Default = settings.Color,
    Title = "NameTag Color",
    Callback = function(value)
    settings.Color = value
    end
})

Visuals2:AddToggle("Names", {
    Text = "Names",
    Default = true,
    Callback = function(state)
    settings.ShowNames = state
    end
})

Visuals2:AddToggle("Distance", {
    Text = "Distance",
    Default = true,
    Callback = function(state)
    settings.ShowDistance = state
    end
})

Visuals2:AddSlider("Size", {
    Text = "Size",
    Default = 13,
    Min = 8,
    Max = 32,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
    settings.TextSize = value
    end
})

Visuals2:AddSlider("Max Distance", {
    Text = "Max Distance",
    Default = 1000,
    Min = 10,
    Max = 3000,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
    settings.MaxDistance = value
    end
})

local function updateTag(ragdoll, headScreenPos, distance)
    local status, err = pcall(function()
        if ragdoll:IsA("Model") and ragdoll:FindFirstChild("display_name") then
            local name = ragdoll.display_name.Value
            if not nameTags[name] then
                local nameTagInstance = Drawing.new("Text")
                nameTagInstance.Center = true
                nameTagInstance.Outline = true
                nameTags[name] = nameTagInstance
            end
            
            local tntag = nameTags[name]
            tntag.Size = settings.TextSize
            tntag.Color = settings.Color
            tntag.Text = ""
            if settings.ShowNames then
                tntag.Text = name
            end
            if settings.ShowDistance and distance <= settings.MaxDistance then
                tntag.Text = tntag.Text .. " [" .. math.floor(distance) .. " studs]"
            end
            tntag.Position = Vector2.new(headScreenPos.X, headScreenPos.Y - 10)
            tntag.Visible = settings.Enabled and distance <= settings.MaxDistance
        end
    end)
    if not status then
        warn("Error updating tag: " .. err)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    local status, err = pcall(function()
        if settings.Enabled then
            for _, ragdoll in pairs(workspace:GetChildren()) do
                if ragdoll.Name == "RagDoll" and ragdoll:FindFirstChild("Head") then
                    local head = ragdoll.Head
                    local distance = (head.Position - player.Character.Head.Position).Magnitude
                    local headScreenPos, onScreen = camera:WorldToViewportPoint(head.Position)

                    if onScreen and ragdoll:IsDescendantOf(workspace) then
                        updateTag(ragdoll, headScreenPos, distance)
                    else
                        if ragdoll:FindFirstChild("display_name") and nameTags[ragdoll.display_name.Value] then
                            nameTags[ragdoll.display_name.Value].Visible = false
                        end
                    end
                end
            end
        else
            for _, tntag in pairs(nameTags) do
                tntag.Visible = false
            end
        end
    end)
    if not status then
        warn("Error in RenderStepped: " .. err)
    end
end)

workspace.ChildRemoved:Connect(function(child)
    local status, err = pcall(function()
            local name = child.display_name.Value
            if nameTags[name] then
                nameTags[name]:Remove()
                nameTags[name] = nil
        end
    end)
    if not status then
        warn("Error in ChildRemoved: " .. err)
    end
end)

local Visual4Holder = Tabs.Visuals:AddRightTabbox('LandMines')
local Visuals4 = Visual4Holder:AddTab('LandMines')

local player = game.Players.LocalPlayer
local workspace = game.Workspace
local camera = workspace.CurrentCamera

local landmineTags = {}

local landmineSettings = {
    Enabled = true,
    ShowNames = true,
    ShowDistance = true,
    TextSize = 13,
    MaxDistance = 3000,
    Color = Color3.new(1, 1, 1)
}

local enabledToggle = Visuals4:AddToggle("Enabled", {
    Text = "Enabled",
    Default = true,
    Callback = function(state)
    landmineSettings.Enabled = state
    end
})

-- Adding the color picker
enabledToggle:AddColorPicker("LandmineColorPicker", {
    Default = landmineSettings.Color,
    Title = "Landmine Tag Color",
    Callback = function(value)
    landmineSettings.Color = value
    end
})

Visuals4:AddToggle("Names", {
    Text = "Names",
    Default = true,
    Callback = function(state)
    landmineSettings.ShowNames = state
    end
})

Visuals4:AddToggle("Distance", {
    Text = "Distance",
    Default = true,
    Callback = function(state)
    landmineSettings.ShowDistance = state
    end
})

Visuals4:AddSlider("Size", {
    Text = "Size",
    Default = 13,
    Min = 8,
    Max = 32,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
    landmineSettings.TextSize = value
    end
})

Visuals4:AddSlider("Max Distance", {
    Text = "Max Distance",
    Default = 1000,
    Min = 10,
    Max = 3000,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
    landmineSettings.MaxDistance = value
    end
})

local function createTagForLandmine(landmine)
    if landmine:IsA("Model") and landmine.Name == "PLACEABLE_LANDMINE" then
        local tagInstance = Drawing.new("Text")
        tagInstance.Center = true
        tagInstance.Outline = true
        landmineTags[landmine] = tagInstance
    end
end

local function updateTag(landmine, cframeScreenPos, distance)
    local status, err = pcall(function()
        local tltag = landmineTags[landmine]
        tltag.Size = landmineSettings.TextSize
        tltag.Color = landmineSettings.Color
        tltag.Text = "Landmine"
        if landmineSettings.ShowDistance and distance <= landmineSettings.MaxDistance then
            tltag.Text = tltag.Text .. " [" .. math.floor(distance) .. " studs]"
        end
        tltag.Position = Vector2.new(cframeScreenPos.X, cframeScreenPos.Y - 10)
        tltag.Visible = landmineSettings.Enabled and distance <= landmineSettings.MaxDistance
    end)
    if not status then
        warn("Error updating tag: " .. err)
    end
end


local BulletHolder = Tabs.MiscShit:AddLeftTabbox('Bullet Trail')
local BulletTrail = BulletHolder:AddTab('Bullet Trail')

BulletTrail:AddToggle('NoTrail', {
    Text = 'No Trail',
    Default = false,

    Callback = function(state)
    if state then
    game.ReplicatedStorage.Assets.DefaultBullet.Trail.Enabled = false
    else
    game.ReplicatedStorage.Assets.DefaultBullet.Trail.Enabled = true
    end
    end
})

BulletTrail:AddLabel('Bullet Color'):AddColorPicker('ColorPicker', {
    Default = Color3.fromRGB(125.332759, 125.332759, 125.332759),
    Title = 'Bullet Color',
    Transparency = 0, 

    Callback = function(Value)
        game.ReplicatedStorage.Assets.DefaultBullet.Trail.Color = ColorSequence.new(Value)
    end
})

BulletTrail:AddSlider('Lifetime', {
    Text = 'Lifetime',
    Default = 0.5,
    Min = 0,
    Max = 20,
    Rounding = 1,
    Compact = true,
})

local Number = Options.Lifetime.Value
Options.Lifetime:OnChanged(function(s)
    game.ReplicatedStorage.Assets.DefaultBullet.Trail.Lifetime = s
end)

BulletTrail:AddSlider('MaxLength', {
    Text = 'Max Length',
    Default = 5000,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = true,
})

local Number = Options.MaxLength.Value
Options.MaxLength:OnChanged(function(s)
    game.ReplicatedStorage.Assets.DefaultBullet.Trail.MaxLength = s
end)

BulletTrail:AddSlider('BrightnessBullet', {
    Text = 'Bullet Brightness',
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Compact = true,
})

local Number = Options.BrightnessBullet.Value
Options.BrightnessBullet:OnChanged(function(s)
    game.ReplicatedStorage.Assets.DefaultBullet.Light.Brightness = s
end)

BulletTrail:AddSlider('TransparencyBT', {
    Text = 'Transparency',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = true,
})

Options.TransparencyBT:OnChanged(function(s)
    game.ReplicatedStorage.Assets.DefaultBullet.Trail.Transparency = NumberSequence.new(s)
end)

BulletTrail:AddSlider('WidthScale', {
    Text = 'Width Scale',
    Default = 0.25,
    Min = 0,
    Max = 10,
    Rounding = 2,
    Compact = true,
})

Options.WidthScale:OnChanged(function(s)
    game.ReplicatedStorage.Assets.DefaultBullet.Trail.WidthScale = NumberSequence.new(s)
end)

BulletTrail:AddDropdown('TextureMode', {
  Values = { 'Stretch', 'Wrap', 'Static' },
  Default = 1,
  Multi = false,
  Text = 'Texture Mode',
  Tooltip = 'Changes the texture of bullets',
})

Options.TextureMode:OnChanged(function()
  if Options.TextureMode.Value == "Stretch" then
	game.ReplicatedStorage.Assets.DefaultBullet.Trail.TextureMode = Enum.TextureMode.Stretch
  elseif Options.TextureMode.Value == "Wrap" then
	game.ReplicatedStorage.Assets.DefaultBullet.Trail.TextureMode = Enum.TextureMode.Wrap
  elseif Options.TextureMode.Value == "Static" then
	game.ReplicatedStorage.Assets.DefaultBullet.Trail.TextureMode = Enum.TextureMode.Static
  end
end)

--[[
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local BeamPart = Instance.new("Part", workspace)

BeamPart.Name = "BeamPart"
BeamPart.Transparency = 1

local Settings = {
    enabled = false,
    Color = Color3.fromRGB(255, 0, 0),
	Texture = "Stretch",
    Time = 5,
}

local BulletLine = Instance.new("Beam")
BulletLine.Brightness = 10
BulletLine.LightInfluence = 0.75
BulletLine.LightEmission = 0.1
BulletLine.Texture = "rbxassetid://7216850022"
BulletLine.TextureLength = 7
BulletLine.TextureMode = Settings["Texture"]
BulletLine.TextureSpeed = 6.21
BulletLine.Color = ColorSequence.new(Settings.Color)
BulletLine.Transparency = NumberSequence.new(0)
BulletLine.CurveSize0 = 0
BulletLine.CurveSize1 = 0
BulletLine.FaceCamera = true
BulletLine.Segments = 10
BulletLine.Width0 = 2
BulletLine.Width1 = 2
BulletLine.ZOffset = 0

local funcs = {}
local Silent = false

function funcs:Beam(v1, v2)
    local Part = Instance.new("Part", BeamPart)
    Part.Size = Vector3.new(1, 1, 1)
    Part.Transparency = 1
    Part.CanCollide = false
    Part.CFrame = CFrame.new(v1)
    Part.Anchored = true
    local Attachment = Instance.new("Attachment", Part)
    local Part2 = Instance.new("Part", BeamPart)
    Part2.Size = Vector3.new(1, 1, 1)
    Part2.Transparency = 1
    Part2.CanCollide = false
    Part2.CFrame = CFrame.new(v2)
    Part2.Anchored = true
    local Attachment2 = Instance.new("Attachment", Part2)
    local Beam = BulletLine:Clone()
    Beam.Parent = Part
    Beam.Color = ColorSequence.new(Settings.Color)
    Beam.Attachment0 = Attachment
    Beam.Attachment1 = Attachment2
    delay(Settings.Time, function()
        for i = 0.5, 1, 0.02 do
            wait()
            Beam.Transparency = NumberSequence.new(i)
        end
        Part:Destroy()
        Part2:Destroy()
    end)
end

function funcs:getclosest()
    local target
    local closest = math.huge
    for i, v in pairs(Players:GetPlayers()) do
        if v and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v ~= LocalPlayer then
            local pos, vis = v.Character.HumanoidRootPart.Position, true
            pos = Vector2.new(pos.X, pos.Y)
            local mousepos = Vector2.new(Mouse.X, Mouse.Y)
            local newdist = (pos - mousepos).magnitude
            if newdist < closest then
                closest = newdist
                target = v
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Settings.enabled and UserInputService:IsMouseButtonPressed(0) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if Silent then
                local closest = funcs:getclosest()
                if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                    funcs:Beam(LocalPlayer.Character.HumanoidRootPart.Position, closest.Character.HumanoidRootPart.Position)
                end
            else
                funcs:Beam(LocalPlayer.Character.HumanoidRootPart.Position, Mouse.Hit.Position)
            end
        end
    end
end)

local BulletHolder2 = Tabs.MiscShit:AddLeftTabbox('BulletTracer')
local BulletTrail1 = BulletHolder2:AddTab('Bullet Tracer')

BulletTrail1:AddToggle('Bullet_Trail_Enabled', {
    Text = 'Enabled',
    Default = false,

    Callback = function(Value)
        Settings["enabled"] = Value
    end
}):AddColorPicker('Color', {
    Default = Color3.new(0, 1, 0),
    Callback = function(Value)
        Settings["Color"] = Value
    end
})
BulletTrail1:AddSlider('Bullet_Lifetime', {
    Text = 'Lifetime',
    Default = 0,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        Settings["Time"] = Value
    end
})
BulletTrail1:AddDropdown('TextureMode', {
	Values = { 'Stretch', 'Wrap', 'Static' },
	Default = 1,
	Multi = false,
	Text = 'Texture',
	
	Callback = function(Value)
		Settings["Texture"] = Value
	end
})
--]]

local Players = game:GetService("Players")
local camera = workspace.CurrentCamera

--* Field of View *--
local FieldOfViewTabBox = Tabs.MiscShit:AddLeftTabbox('Field of View')
local FieldOfViewTab = FieldOfViewTabBox:AddTab('Field of View')

--Camera Tab
do
    FieldOfViewTab:AddToggle('Camera_FOVToggle', {Text = 'Field of View', Default = false})
    FieldOfViewTab:AddSlider('Camera_FOVValue', {Text = 'FOV', Default = 70, Min = 0, Max = 120, Rounding = 0, Compact = true})

    Toggles.Camera_FOVToggle:OnChanged(function()
    if Toggles.Camera_FOVToggle.Value then
        camera.FieldOfView = Options.Camera_FOVValue.Value
    else
        camera.FieldOfView = 65
    end
    end)

    Options.Camera_FOVValue:OnChanged(function()
    if Toggles.Camera_FOVToggle.Value then
        camera.FieldOfView = Options.Camera_FOVValue.Value
    end
    end)

    FieldOfViewTab:AddToggle('Camera_ZoomToggle', {Text = 'Enable Zoom', Default = false}):AddKeyPicker('Camera_ZoomHolding', {Default = 'Z', SyncToggleState = false, Mode = 'Hold', Text = 'Zoom Keybind', NoUI = false,})
    FieldOfViewTab:AddSlider('Camera_ZoomValue', {Text = 'Zoom FOV', Default = 30, Min = 0, Max = 120, Rounding = 0, Compact = true})
end

    camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
    if Toggles.Camera_FOVToggle.Value then
        camera.FieldOfView = Options.Camera_FOVValue.Value
    end

    if Toggles.Camera_ZoomToggle.Value and Options.Camera_ZoomHolding:GetState() then
        camera.FieldOfView = Options.Camera_ZoomValue.Value
    end
    end)

local AntiHolder = Tabs.Player:AddRightTabbox('Anti Aim')
local AntiStuffs = AntiHolder:AddTab('Anti Aim')

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local SpinSpeed = 50
local SpinEnabled = false

AntiStuffs:AddToggle('Spin', {
    Text = 'Spinbot',
    Default = false,

    Callback = function(state)
        SpinEnabled = state
    end
})

AntiStuffs:AddSlider('SpinSpeed', {
    Text = 'Spin Speed',
    Default = 50,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Compact = false,

    Callback = function(value)
        SpinSpeed = value
    end
})

RunService.RenderStepped:Connect(function(dt)
    if SpinEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = LocalPlayer.Character.HumanoidRootPart
        local rotation = CFrame.Angles(0, SpinSpeed * dt, 0)
        rootPart.CFrame = rootPart.CFrame * rotation
    end
end)

--[[
local bhop = false
local bhopwait = 1
local charactr = game:GetService("Players").LocalPlayer.Character
local humanoid = charactr.Humanoid

AntiStuffs:AddToggle('BunnyHop', {
    Text = 'Bunny Hop',
    Default = false,

    Callback = function(state)
        bhop = state
    end
})

AntiStuffs:AddSlider('BunnyHopSpeed', {
    Text = 'Hop Speed',
    Default = 0.7,
    Min = 0,
    Max = 2,
    Rounding = 1,
    Compact = false,

    Callback = function(value)
        bhopwait = value
    end
})

task.spawn(function()
    while task.wait(bhopwait) do
        if bhop then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
--]]

--// Nedded shit \\--

local GunController = game.Players.LocalPlayer:FindFirstChild("PlayerScripts").GunController

local CustomHitsoundsTabBox = Tabs.Main:AddRightTabbox('Custom Hitsounds')
local CustomHitsoundsTab = CustomHitsoundsTabBox:AddTab('Custom Hitsounds')

GunController.Data.Headshot.Volume = 5
GunController.Data.Headshot.Pitch = 1

CustomHitsoundsTab:AddToggle('Enabled_Toggle', {Text = 'Enabled', Default = false})

CustomHitsoundsTab:AddDropdown('HeadshotHit', {
  Values = { 'Default' },
  Default = 1,
  Multi = false,
  Text = 'Custom Head Hitsound',
  Tooltip = 'Changes player hit headshot sound',
})

Options.HeadshotHit:OnChanged(function()
  if Options.HeadshotHit.Value == "Default" then
    GunController.Data.Headshot.SoundId = "rbxassetid://9119561046"
    GunController.Data.Headshot.Playing = true
  end
end)

CustomHitsoundsTab:AddSlider('Volume_Slider', {Text = 'Volume', Default = 5, Min = 0, Max = 10, Rounding = 1, Compact = true}):OnChanged(function(vol)
    GunController.Data.Headshot.Volume = vol
end)

CustomHitsoundsTab:AddSlider('Pitch_Slider', {Text = 'Pitch', Default = 1, Min = 0, Max = 2, Rounding = 1, Compact = true}):OnChanged(function(pitch)
    GunController.Data.Headshot.Pitch = pitch
end)

CustomHitsoundsTab:AddToggle('Enabled_Toggle', {Text = 'Enabled', Default = false})

CustomHitsoundsTab:AddDropdown('Hit', {
  Values = { 'Default', 'Gamesense', 'CS:GO', 'Among Us', 'Neverlose', 'TF2 Critical', 'Mario', 'Rust', 'Call of Duty', 'Steve', 'Bamboo', 'Minecraft', 'TF2', },
  Default = 1,
  Multi = false,
  Text = 'Custom Body Hitsound',
  Tooltip = 'Changes player hit sound',
})

Options.Hit:OnChanged(function()
  if Options.Hit.Value == "Default" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://9114487369"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "Gamesense" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://4817809188"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "CS:GO" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://6937353691"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "Among Us" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://5700183626"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "Neverlose" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://8726881116"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "TF2 Critical" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://296102734"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "Mario" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://2815207981"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "Rust" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://1255040462"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "Call of Duty" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://5952120301"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "Steve" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://4965083997"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "Bamboo" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://3769434519"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "Minecraft" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://4018616850"
    GunController.Data.Hitmarker.Playing = true
  elseif Options.Hit.Value == "TF2" then
    GunController.Data.Hitmarker.SoundId = "rbxassetid://2868331684"
    GunController.Data.Hitmarker.Playing = true
  end
end)

CustomHitsoundsTab:AddSlider('Volume_Slider', {Text = 'Volume', Default = 5, Min = 0, Max = 10, Rounding = 1, Compact = true}):OnChanged(function(vol)
   GunController.Data.Hitmarker.Volume = vol
end)

CustomHitsoundsTab:AddSlider('Pitch_Slider', {Text = 'Pitch', Default = 1, Min = 0, Max = 2, Rounding = 1, Compact = true}):OnChanged(function(pitch)
    GunController.Data.Hitmarker.Pitch = pitch
end)

local MiscMainBox = Tabs.World:AddRightTabbox('Map Visuals')
local MiscMain = MiscMainBox:AddTab('Map Visuals')

--[[
local NoVRecoil = MiscMain:AddButton({
    Text = 'No Vis Recoil',
    Func = function()
		local replicatedStorage = game:GetService("ReplicatedStorage")
		local gunData = replicatedStorage.GunData
		
		local function removeShootAnimations(folder)
		    for _, child in ipairs(folder:GetChildren()) do
		        if child:IsA("Animation") and child.Name == "Shoot" then
		            child:Destroy()
		        elseif child:IsA("Folder") then
		            removeShootAnimations(child)
		        end
		    end
		end
		
		removeShootAnimations(gunData)
    end,
    DoubleClick = false,
})
--]]

local atmosphereConnection

MiscMain:AddToggle('NoFog', {
    Text = 'No Fog',
    Default = false,
    Callback = function(state)
        if state then    
            atmosphereConnection = game:GetService("Lighting").Atmosphere.Changed:Connect(function(prop)
                if prop == "Density" then
                    game:GetService("Lighting").Atmosphere.Density = 0
                end
            end)
        else
            if atmosphereConnection then
                atmosphereConnection:Disconnect()
            end
        end
    end
})

local Light = game:GetService("Lighting")

function dofullbright()
  Light.Ambient = Color3.new(1,1,1)
  Light.ColorShift_Bottom = Color3.new(1, 1, 1)
  Light.ColorShift_Top = Color3.new(1, 1, 1)
  Light.Brightness = 10
end

function resetLighting()
  Light.Ambient = Color3.new(0,0,0)
  Light.ColorShift_Bottom = Color3.new(0,0,0)
  Light.ColorShift_Top = Color3.new(0,0,0)
  Light.Brightness = 3
end

local connection

MiscMain:AddToggle('Fullbright', {
    Text = 'Fullbright',
    Default = false,
    Callback = function(state)
        if state then
            dofullbright()
            connection = Light:GetPropertyChangedSignal("Brightness"):Connect(dofullbright)
        else
            if connection then
                connection:Disconnect()
                resetLighting()
            end
        end
    end
})

local LightingService = game:GetService("Lighting")
local color69 = Color3.new(1,1,1)
local ColorPickerToggle = MiscMain:AddToggle('ColorPicker', {
    Text = 'Ambient',
    Default = false,
    Callback = function(state)
        toggleState = state
        if toggleState then
            LightingService.OutdoorAmbient = color69
        end
    end
})

ColorPickerToggle:AddColorPicker('OutdoorAmbientColorPicker', {
    Default = color69,
    Title = 'Ambient Color',
    Callback = function(Value)
        color69 = Value
        if toggleState then
            LightingService.OutdoorAmbient = color69
        end
    end
})

LightingService:GetPropertyChangedSignal("OutdoorAmbient"):Connect(function()
    if toggleState then
        LightingService.OutdoorAmbient = color69
    end
end)

local toggleState = false
local clockTime = 12

MiscMain:AddToggle('TimeChanger', {
    Text = 'Time Changer',
    Default = false,
    Callback = function(state)
        toggleState = state
    end
})

MiscMain:AddSlider('ClockTimeSlider', {
    Text = 'Clock Time',
    Default = clockTime,
    Min = 1,
    Max = 24,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        clockTime = value
        if toggleState then
            game:GetService("Lighting").ClockTime = clockTime
        end
    end
})

game:GetService("Lighting"):GetPropertyChangedSignal("ClockTime"):Connect(function()
    if toggleState then
        game:GetService("Lighting").ClockTime = clockTime
    end
end)

local Socolo = Instance.new("Sky",game:GetService("Lighting"))

getgenv().Enabled1 = nil

MiscMain:AddToggle('AWASZnfh', {
Text = "Enabled",
Default = false,
Tooltip = "Enables SkyTab",
}):OnChanged(function(SKYB)
Enabled1 = SKYB
end)

Socolo.Name = "Custom Skybox"
MiscMain:AddDropdown('SkyC', {
Values = { 'Default', 'Sponge Bob', 'Vaporwave', 'Clouds', 'Twilight', 'Chill', 'Minecraft', 'Among Us', 'Redshift', 'Aesthetic Night', 'Neptune', 'Galaxy'},
Default = 1,
Multi = false,
Text = 'Custom Skybox',
Tooltip = 'Sky Changer',
})

Options.SkyC:OnChanged(function(HOMO)
if Enabled1 then
if HOMO == "Default" then
Socolo.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
Socolo.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
Socolo.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
Socolo.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
Socolo.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
Socolo.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
elseif HOMO == "Sponge Bob" then
Socolo.SkyboxBk = "http://www.roblox.com/asset/?id=7633178166"
Socolo.SkyboxDn = "http://www.roblox.com/asset/?id=7633178166"
Socolo.SkyboxFt = "http://www.roblox.com/asset/?id=7633178166"
Socolo.SkyboxLf = "http://www.roblox.com/asset/?id=7633178166"
Socolo.SkyboxRt = "http://www.roblox.com/asset/?id=7633178166"
Socolo.SkyboxUp = "http://www.roblox.com/asset/?id=7633178166"
elseif HOMO == "Vaporwave" then
Socolo.SkyboxBk = "rbxassetid://1417494030"
Socolo.SkyboxDn = "rbxassetid://1417494146"
Socolo.SkyboxFt = "rbxassetid://1417494253"
Socolo.SkyboxLf = "rbxassetid://1417494402"
Socolo.SkyboxRt = "rbxassetid://1417494499"
Socolo.SkyboxUp = "rbxassetid://1417494643"
elseif HOMO == "Clouds" then
Socolo.SkyboxBk = "rbxassetid://570557514"
Socolo.SkyboxDn = "rbxassetid://570557775"
Socolo.SkyboxFt = "rbxassetid://570557559"
Socolo.SkyboxLf = "rbxassetid://570557620"
Socolo.SkyboxRt = "rbxassetid://570557672"
Socolo.SkyboxUp = "rbxassetid://570557727"
elseif HOMO == "Twilight" then
Socolo.SkyboxBk = "rbxassetid://264908339"
Socolo.SkyboxDn = "rbxassetid://264907909"
Socolo.SkyboxFt = "rbxassetid://264909420"
Socolo.SkyboxLf = "rbxassetid://264909758"
Socolo.SkyboxRt = "rbxassetid://264908886"
Socolo.SkyboxUp = "rbxassetid://264907379"
elseif HOMO == "Chill" then
Socolo.SkyboxBk = "rbxassetid://5084575798"
Socolo.SkyboxDn = "rbxassetid://5084575916"
Socolo.SkyboxFt = "rbxassetid://5103949679"
Socolo.SkyboxLf = "rbxassetid://5103948542"
Socolo.SkyboxRt = "rbxassetid://5103948784"
Socolo.SkyboxUp = "rbxassetid://5084576400"
elseif HOMO == "Minecraft" then
Socolo.SkyboxBk = "rbxassetid://1876545003"
Socolo.SkyboxDn = "rbxassetid://1876544331"
Socolo.SkyboxFt = "rbxassetid://1876542941"
Socolo.SkyboxLf = "rbxassetid://1876543392"
Socolo.SkyboxRt = "rbxassetid://1876543764"
Socolo.SkyboxUp = "rbxassetid://1876544642"
elseif HOMO == "Among Us" then
Socolo.SkyboxBk = "rbxassetid://5752463190"
Socolo.SkyboxDn = "rbxassetid://5872485020"
Socolo.SkyboxFt = "rbxassetid://5752463190"
Socolo.SkyboxLf = "rbxassetid://5752463190"
Socolo.SkyboxRt = "rbxassetid://5752463190"
Socolo.SkyboxUp = "rbxassetid://5752463190"
elseif HOMO == "Redshift" then
Socolo.SkyboxBk = "rbxassetid://401664839"
Socolo.SkyboxDn = "rbxassetid://401664862"
Socolo.SkyboxFt = "rbxassetid://401664960"
Socolo.SkyboxLf = "rbxassetid://401664881"
Socolo.SkyboxRt = "rbxassetid://401664901"
Socolo.SkyboxUp = "rbxassetid://401664936"
elseif HOMO == "Aesthetic Night" then
Socolo.SkyboxBk = "rbxassetid://1045964490"
Socolo.SkyboxDn = "rbxassetid://1045964368"
Socolo.SkyboxFt = "rbxassetid://1045964655"
Socolo.SkyboxLf = "rbxassetid://1045964655"
Socolo.SkyboxRt = "rbxassetid://1045964655"
Socolo.SkyboxUp = "rbxassetid://1045962969"
elseif HOMO == "Neptune" then
Socolo.SkyboxBk = "rbxassetid://218955819"
Socolo.SkyboxDn = "rbxassetid://218953419"
Socolo.SkyboxFt = "rbxassetid://218954524"
Socolo.SkyboxLf = "rbxassetid://218958493"
Socolo.SkyboxRt = "rbxassetid://218957134"
Socolo.SkyboxUp = "rbxassetid://218950090"
Socolo.StarCount = 5000
elseif HOMO == "Galaxy" then
Socolo.SkyboxBk = "http://www.roblox.com/asset/?id=159454299"
Socolo.SkyboxDn = "http://www.roblox.com/asset/?id=159454296"
Socolo.SkyboxFt = "http://www.roblox.com/asset/?id=159454293"
Socolo.SkyboxLf = "http://www.roblox.com/asset/?id=159454286"
Socolo.SkyboxRt = "http://www.roblox.com/asset/?id=159454300"
Socolo.SkyboxUp = "http://www.roblox.com/asset/?id=159454288"
Socolo.StarCount = 5000
end
end
end)

local MiscRemovalsBox = Tabs.World:AddLeftTabbox('Removals')
local MiscRemovals = MiscRemovalsBox:AddTab('Removals')

local LightingService = game:GetService("Lighting")

local runService = game:GetService("RunService")

MiscRemovals:AddToggle('Bloom', {
    Text = 'Bloom',
    Default = true,

    Callback = function(state)
    if state then
    game:GetService"Lighting".Bloom.Enabled = true
    else
    game:GetService"Lighting".Bloom.Enabled = false
    end
    end
})

Toggles.Bloom:OnChanged(function()
end)

MiscRemovals:AddToggle('SunRays', {
    Text = 'SunRays',
    Default = true,

    Callback = function(state)
    if state then
    game:GetService"Lighting".SunRays.Enabled = true
    else
    game:GetService"Lighting".SunRays.Enabled = false
    end
    end
})

Toggles.SunRays:OnChanged(function()
end)

MiscRemovals:AddToggle('Shadows', {
    Text = 'Shadows',
    Default = true,

    Callback = function(state)
    if state then
    LightingService.GlobalShadows = true
    else
    LightingService.GlobalShadows = false
    end
    end
})

Toggles.SunRays:OnChanged(function()
end)

-- Define replicatedStorage
local replicatedStorage = game:GetService("ReplicatedStorage")

MiscRemovals:AddToggle('Clouds', {
    Text = 'Clouds',
    Default = true,
    Callback = function(state)
        if state then
            if replicatedStorage:FindFirstChild("Clouds") then
                replicatedStorage.Clouds.Parent = game.Workspace.Terrain
            end
        else
            if game.Workspace.Terrain:FindFirstChild("Clouds") then
                game.Workspace.Terrain.Clouds.Parent = replicatedStorage
            end
        end
    end
})

MiscRemovals:AddToggle('Fences', {
    Text = 'Fences',
    Default = true,
    Callback = function(state)
        if state then
            if replicatedStorage:FindFirstChild("Fences") then
                replicatedStorage.Fences.Parent = game.Workspace.world_assets.StaticObjects
            end
        else
            if game.Workspace.world_assets.StaticObjects:FindFirstChild("Fences") then
                game.Workspace.world_assets.StaticObjects.Fences.Parent = replicatedStorage
            end
        end
    end
})

MiscRemovals:AddToggle('Trees', {
    Text = 'Trees',
    Default = true,
    Callback = function(state)
        pcall(function()
            local trees = game.Workspace.world_assets.StaticObjects.Foliage
            if state then
                for _, tree in ipairs(replicatedStorage:FindFirstChild("Trees"):GetChildren()) do
                    tree.Parent = trees
                end
            else
                local storedTrees = Instance.new("Folder")
                storedTrees.Name = "Trees"
                storedTrees.Parent = replicatedStorage
                for _, tree in ipairs(trees:GetChildren()) do
                    if tree.Name == "Tree" then
                        tree.Parent = storedTrees
                    end
                end
            end
        end)
    end
})

MiscRemovals:AddToggle('Grass', {
    Text = 'Grass',
    Default = true,
    Callback = function(state)
        if state then
        local showDecorations = true
        sethiddenproperty(game:GetService("Workspace").Terrain, "Decoration", showDecorations)
        else
		local showDecorations = false
		sethiddenproperty(game:GetService("Workspace").Terrain, "Decoration", showDecorations)
        end
    end
})

local World3Box = Tabs.World:AddLeftTabbox('ColorCorrection')
local World3 = World3Box:AddTab('ColorCorrection')

World3:AddToggle('CC', {
    Text = 'ColorCorrection',
    Default = false, -- Default value (true / false)
})

Toggles.CC:OnChanged(function(state)
    if state then
        game:GetService("Lighting").ColorCorrection.Enabled = true
    else
        game:GetService("Lighting").ColorCorrection.Enabled = false
    end
end)

World3:AddSlider('CC2', {
    Text = 'Brightness',
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 2,
    Compact = true,
})

local Number = Options.CC2.Value
Options.CC2:OnChanged(function(s)
    game:GetService("Lighting").ColorCorrection.Brightness = s
end)

World3:AddSlider('CC3', {
    Text = 'Contrast',
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 2,
    Compact = true, -- If set to true, then it will hide the label
})

local Number = Options.CC3.Value
Options.CC3:OnChanged(function(s)
    game:GetService("Lighting").ColorCorrection.Contrast = s
end)

World3:AddSlider('CCSaturation', {
    Text = 'Saturation',
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 2,
    Compact = true,
})

Options.CCSaturation:OnChanged(function(s)
    game:GetService("Lighting").ColorCorrection.Saturation = s
end)

local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Replicated = game:GetService("ReplicatedStorage")
local Collection = game:GetService("CollectionService")
local UserInput = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Run = game:GetService("RunService")

local Color, SimpleColor = Color3.new, BrickColor.new

local MouseLocation = function()
    return UserInput.GetMouseLocation(UserInput)
end

local Circle = Drawing.new("Circle")
Circle.Filled = false; Circle.Thickness = 1; Circle.Radius = 0
Circle.NumSides = 60; Circle.Color = Color(1,1,1); Circle.Visible = true
task.spawn(function() Run.RenderStepped:Connect(function() Circle.Position = MouseLocation() end) end)

local function GetNearestPlayerToMouse(MaxDistance)
    local Character = nil
    MaxDistance = MaxDistance or 5000
    local mouseScreenPos = MouseLocation()
    local localPlayer = Players.LocalPlayer

    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        local character = targetPlayer.Character

        if targetPlayer ~= localPlayer and character then
            local humanoid = character:FindFirstChild("Humanoid")
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoidRootPart and humanoid.Health > 0 then
                local enemyScreenPos = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                local screenDistance = (Vector2.new(enemyScreenPos.X, enemyScreenPos.Y) - mouseScreenPos).Magnitude
                if screenDistance <= Circle.Radius and screenDistance < MaxDistance then
                    MaxDistance = screenDistance
                    Character = targetPlayer.Character
                end
            end
        end
    end
    return Character
end

local Testerz = 1.052
local Testerz2 = 1.054

local ScriptEnvironment = getsenv(GunController)
local getDirection = ScriptEnvironment.getDirection
local silentAimEnabled = false
local BulletModule = require(game:GetService('ReplicatedStorage').Library.BulletModule)
local gravity = game:GetService("ReplicatedStorage").GunConfiguration.Server.sv_default_bullet_gravity.Value
local sv_default_bullet_speed = game:GetService("ReplicatedStorage").GunConfiguration.Server.sv_default_bullet_speed.Value

local function getBulletSpeed(gunName)
    local gunDataFolder = game:GetService("ReplicatedStorage"):FindFirstChild("GunData")
    if gunDataFolder then
        local gunData = gunDataFolder:FindFirstChild(gunName)
        if gunData and gunData.Stats and gunData.Stats.BulletSettings and gunData.Stats.BulletSettings:FindFirstChild("BulletSpeed") then
            return gunData.Stats.BulletSettings.BulletSpeed.Value
        else
            return sv_default_bullet_speed
        end
    else
        warn("GunData folder not found in ReplicatedStorage.")
        return sv_default_bullet_speed
    end
end

local function updateSAEnabledState()
    if silentAimEnabled then

ScriptEnvironment.getDirection = function(...)
    local nearestEnemy = GetNearestPlayerToMouse(2000)
    
    if nearestEnemy then
        local enemyPos = nearestEnemy.Head.Position
        local myPos = Camera.CFrame.Position -- game:GetService("Players").LocalPlayer.Character.WorldModel.Main.Position
        local distance = (enemyPos - myPos).Magnitude

        local currentSelectedObject = game:GetService("Players").LocalPlayer.CurrentSelectedObject.Value
        local currentGun = currentSelectedObject.Value.Name
        local bulletSpeed = getBulletSpeed(currentGun)
        local timeToTarget = distance / bulletSpeed

        local movePrediction = Vector3.new(0, 0, 0)
        
        movePrediction = nearestEnemy.HumanoidRootPart.Velocity * timeToTarget * Testerz2

        local predictedPos = enemyPos + movePrediction
        
        local gunDataFolder = game:GetService("ReplicatedStorage"):FindFirstChild("GunData")
        local gunData = gunDataFolder:FindFirstChild(currentGun)
        local compensatedPos = predictedPos + Vector3.new(0, (gravity * timeToTarget ^ 2 * Testerz), 0)
        local aimDirection = (compensatedPos - myPos).Unit

        return aimDirection
    end

    return getDirection(...)
end
    else
        ScriptEnvironment.getDirection = getDirection
    end
end

local MainPrivate = SilentStuff:AddTab('Magic Bullets')

MainPrivate:AddToggle('SilentAim', {
    Text = 'Silent Aim',
    Default = false,

    Callback = function(state)
        silentAimEnabled = state
        updateSAEnabledState()
    end
})

local FovThingyToggle = MainPrivate:AddToggle('FovThingy', {
    Text = 'Show Fov',
    Default = false,
    Callback = function(state)
        Circle.Visible = state
    end
})

FovThingyToggle:AddColorPicker('FovThingyColorPicker', {
    Default = Circle.Color,
    Title = 'Fov Color',
    Callback = function(Value, Transparency)
        Circle.Color = Value
    end
})

local SnaplineMain = MainPrivate:AddToggle('Snapline', {
    Text = 'Show Snapline',
    Default = false,
    Callback = function(state)
        if Snapline then
            Snapline.Visible = state
        end
    end
})

local currentColor = Color3.new(1, 1, 1)

local SnaplineColorPicker = SnaplineMain:AddColorPicker('SnaplineColorPicker', {
    Default = Color3.new(1, 1, 1),
    Title = 'Snapline Color',
    Callback = function(Value)
        currentColor = Value
        if Snapline then
            Snapline.Color = currentColor
        end
    end
})

local Snapline

Run.RenderStepped:Connect(function()
    if not Snapline then
        Snapline = Drawing.new('Line')
        Snapline.Visible = false
        Snapline.Thickness = 1
    end

    local source = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetCharacter = GetNearestPlayerToMouse()
                        
    if targetCharacter and SnaplineMain.Value then
        local target = Camera:WorldToViewportPoint(targetCharacter.Head.Position)
        Snapline.From = source
        Snapline.To = Vector2.new(target.X, target.Y)
        Snapline.Color = currentColor
        Snapline.Visible = true
    else
        Snapline.Visible = false
    end
end)

MainPrivate:AddToggle('FilledFovSa', {
    Text = 'Filled Fov',
    Default = false,

    Callback = function(state)
    Circle.Filled = state
    end
})

MainPrivate:AddSlider('MySilentFovSlider', {
    Text = 'Fov Size',
    Default = 0,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false,
    Callback = function(state)
        Circle.Radius = state
    end
})

MainPrivate:AddSlider('MySilentNumSides', {
    Text = 'Num Sides',
    Default = 64,
    Min = 3,
    Max = 64,
    Rounding = 0,
    Compact = false,
    Callback = function(state)
        Circle.NumSides = state
    end
})

MainPrivate:AddSlider('MySilentFovSlider2', {
    Text = 'Bullet Drop Prediction',
    Default = 1.052,
    Min = 0.7,
    Max = 1.2,
    Rounding = 3,
    Compact = false,
    Tooltip = 'This is only for ping adjustment',
    Callback = function(state)
        Testerz = state
    end
})

MainPrivate:AddSlider('MySilentFovSlider3', {
    Text = 'Movement Prediction',
    Default = 1.054,
    Min = 0.7,
    Max = 1.2,
    Rounding = 3,
    Compact = false,
    Tooltip = 'This is only for ping adjustment',
    Callback = function(state)
        Testerz2 = state
    end
})

local MiscPrivateHolder = Tabs.Player:AddLeftTabbox('Exploits')
local MiscPrivate = MiscPrivateHolder:AddTab('Exploits')

local UserInputService = game:GetService("UserInputService")
local isToggleOn = false

local function onKeyPress(input)
    if isToggleOn and input.KeyCode == Enum.KeyCode.Space then
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end

UserInputService.InputBegan:Connect(onKeyPress)

MiscPrivate:AddToggle('InfiniteJump', {
    Text = 'Infinite Jump',
    Default = isToggleOn,
    Callback = function(value)
        isToggleOn = value
    end
})

local Noclip = nil
local Clip = nil

function noclip()
    Clip = false
    local function Nocl()
        if Clip == false and game.Players.LocalPlayer.Character ~= nil then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA('BasePart') and v.CanCollide and v.Name ~= floatName then
                    v.CanCollide = false
                end
            end
        end
        wait(0.21)
    end
    Noclip = game:GetService('RunService').Stepped:Connect(Nocl)
end

function clip()
    if Noclip then Noclip:Disconnect() end
    Clip = true
end

MiscPrivate:AddToggle('Noclip123', {
    Text = 'Noclip',
    Default = false,

    Callback = function(state)
        if state then
            pcall(function()
                noclip()
            end)
        else
            pcall(function()
                clip()
            end)
        end
    end
})

--* SpeedHack *--

local walkSpeed = 20
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local W, A, S, D
local xVelo, yVelo
local walkSpeedEnabled = false

local AlwaysRunToggle = MiscPrivate:AddToggle('AlwaysRunToggle', {
    Text = 'SpeedHack',
    Default = false,
    Callback = function(Value)
        walkSpeedEnabled = Value
    end
})

local SpeedHackSlider = MiscPrivate:AddSlider('SpeedHackSpeed', {
    Text = 'Speed',
    Default = 22.5,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        walkSpeed = value
    end
})

RS.RenderStepped:Connect(function()
    if not walkSpeedEnabled then
        return
    end

    local HRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP or not HRP.Velocity then
        return 
    end

    local C = game.Workspace.CurrentCamera
    local LV = C.CFrame.LookVector

    for i,v in pairs(UIS:GetKeysPressed()) do
        if v.KeyCode == Enum.KeyCode.W then
            W = true
        end
        if v.KeyCode == Enum.KeyCode.A then
            A = true
        end
        if v.KeyCode == Enum.KeyCode.S then
            S = true
        end
        if v.KeyCode == Enum.KeyCode.D then
            D = true
        end
    end

    if W == true and S == true then
        yVelo = false
        W,S = nil, nil
    end

    if A == true and D == true then
        xVelo = false
        A,D = nil, nil
    end

    if yVelo ~= false then
        if W == true then
            if xVelo ~= false then
                if A == true then
                    local LeftLV = (C.CFrame * CFrame.Angles(0, math.rad(45), 0)).LookVector
                    HRP.Velocity = Vector3.new((LeftLV.X * walkSpeed), HRP.Velocity.Y, (LeftLV.Z * walkSpeed))
                    W,A = nil, nil
                else
                    if D == true then
                        local RightLV = (C.CFrame * CFrame.Angles(0, math.rad(-45), 0)).LookVector
                        HRP.Velocity = Vector3.new((RightLV.X * walkSpeed), HRP.Velocity.Y, (RightLV.Z * walkSpeed))
                        W,D = nil, nil
                    end
                end
            end
        else
            if S == true then
                if xVelo ~= false then
                    if A == true then
                        local LeftLV = (C.CFrame * CFrame.Angles(0, math.rad(135), 0)).LookVector
                        HRP.Velocity = Vector3.new((LeftLV.X * walkSpeed), HRP.Velocity.Y, (LeftLV.Z * walkSpeed))
                        S,A = nil, nil
                    else
                        if D == true then
                            local RightLV = (C.CFrame * CFrame.Angles(0, math.rad(-135), 0)).LookVector
                            HRP.Velocity = Vector3.new((RightLV.X * walkSpeed), HRP.Velocity.Y, (RightLV.Z * walkSpeed))
                            S,D = nil, nil
                        end
                    end
                end
            end
        end
    end

    if W == true then
        HRP.Velocity = Vector3.new((LV.X * walkSpeed), HRP.Velocity.Y, (LV.Z * walkSpeed))
    end
    if S == true then
        HRP.Velocity = Vector3.new(-(LV.X * walkSpeed), HRP.Velocity.Y, -(LV.Z * walkSpeed))
    end
    if A == true then
        local LeftLV = (C.CFrame * CFrame.Angles(0, math.rad(90), 0)).LookVector
        HRP.Velocity = Vector3.new((LeftLV.X * walkSpeed), HRP.Velocity.Y, (LeftLV.Z * walkSpeed))
    end
    if D == true then
        local RightLV = (C.CFrame * CFrame.Angles(0, math.rad(-90), 0)).LookVector
        HRP.Velocity = Vector3.new((RightLV.X * walkSpeed), HRP.Velocity.Y, (RightLV.Z * walkSpeed))
    end

    xVelo, yVelo, W, A, S, D = nil, nil, nil, nil, nil, nil
end)

--[[
local TeleportWalkingPrivateHolder = Tabs.Player:AddLeftTabbox('CFrame Speed')
local TeleportWalkingPrivate = TeleportWalkingPrivateHolder:AddTab('CFrame Speed')

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local humanoidRootPart
local lastCFrame
local moveDirection = Vector3.new(0, 0, 0)
local teleportSpeed = 0.18
local teleportWalkingEnabled = false
local teleportToCurrentPositionEnabled = false

local movingDirections = {
    [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
    [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
    [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
    [Enum.KeyCode.D] = Vector3.new(1, 0, 0),
}

UserInputService.InputBegan:Connect(function(input)
    if movingDirections[input.KeyCode] then
        moveDirection = moveDirection + movingDirections[input.KeyCode]
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if movingDirections[input.KeyCode] then
        moveDirection = moveDirection - movingDirections[input.KeyCode]
    end
end)

TeleportWalkingPrivate:AddToggle('TeleportWalking', {
    Text = 'Enabled',
    Default = false,
    Callback = function(state)
        teleportWalkingEnabled = state
    end
})

TeleportWalkingPrivate:AddSlider('TeleportWalkingSlider', {
    Text = 'Speed',
    Default = teleportSpeed,
    Min = 0,
    Max = 3,
    Rounding = 2,
    Compact = false,
    Callback = function(value)
        teleportSpeed = value
    end
})

local function teleportAhead()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if teleportWalkingEnabled then
            lastCFrame = humanoidRootPart.CFrame * CFrame.new(moveDirection * teleportSpeed)
            humanoidRootPart.CFrame = lastCFrame
        end
        if teleportToCurrentPositionEnabled then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame
        end
    end
end

RunService.RenderStepped:Connect(teleportAhead)
--]]

local AntiTeleportHolder = Tabs.Player:AddLeftTabbox('Anti Teleport')
local AntiTeleport = AntiTeleportHolder:AddTab('Anti Teleport')

local antiWarpEnabled = false
local lerpValue = 1
local maxTeleportDistance = 20
local previousCFrame = nil
local WaitEnabled = true

local function antiWarpLogic()
    while antiWarpEnabled do
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                if previousCFrame then
                    local currentCFrame = humanoidRootPart.CFrame
                    if (currentCFrame.Position - previousCFrame.Position).Magnitude > maxTeleportDistance then
                        humanoidRootPart.CFrame = currentCFrame:Lerp(previousCFrame, lerpValue)
                    else
                        previousCFrame = currentCFrame
                    end
                else
                    previousCFrame = humanoidRootPart.CFrame
                end
            end
        end
        if WaitEnabled then
        wait()
        else
        end
    end
end

AntiTeleport:AddToggle('AntiWarpToggle', {
    Text = 'Enabled',
    Default = false,
    Callback = function(state)
        antiWarpEnabled = state
        if antiWarpEnabled then
            antiWarpLogic()
        end
    end
})

AntiTeleport:AddToggle('AntiWarpWaitRemove', {
    Text = 'Use Wait',
    Default = true,
    Callback = function(state)
        WaitEnabled = state
    end
})

AntiTeleport:AddSlider('LerpValueSlider', {
    Text = 'Anti Value',
    Default = lerpValue,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(value)
        lerpValue = value
    end
})

AntiTeleport:AddSlider('MaxDistanceSlider', {
    Text = 'Max Distance',
    Default = maxTeleportDistance,
    Min = 1,
    Max = 150,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        maxTeleportDistance = value
    end
})

local FreezeStuffs = Tabs.Player:AddLeftTabbox('Map Exploit')
local FreezeStuffs1 = FreezeStuffs:AddTab('Map Exploit')

local function freezeCharacter(character)
    for i, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
end

local function unFreezeCharacter(character)
    for i, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
end

local function performAction()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    character.HumanoidRootPart.Velocity = Vector3.new(0, -2300, 0)
    wait(0)
    freezeCharacter(character)
    wait(3)
    unFreezeCharacter(character)
    character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
end

local keyBindEnabled = false

FreezeStuffs1:AddToggle('UnderMap', {
    Text = 'Enabled (Z)',
    Default = false,
    Callback = function(newState)
    keyBindEnabled = newState
    end
})

game:GetService('UserInputService').InputBegan:Connect(function(input)
    if keyBindEnabled and input.KeyCode == Enum.KeyCode.Z then
        performAction()
    end
end)

--[[
local GravityHolder = Tabs.Player:AddRightTabbox('Gravity')
local GravityThingy = GravityHolder:AddTab('Gravity')

local gravityToggleEnabled = false
local gravityValue = 196.2

GravityThingy:AddToggle('GravityToggle', {
    Text = 'Enabled',
    Default = false,
    Callback = function(state)
        gravityToggleEnabled = state
        if gravityToggleEnabled then
        else
            game.Workspace.Gravity = tonumber(196.2)
        end
    end
})

GravityThingy:AddSlider('GravitySlider', {
    Text = 'Gravity Value',
    Default = gravityValue,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        gravityValue = value
        if gravityToggleEnabled then
            game.Workspace.Gravity = tonumber(gravityValue)
        end
    end
})

--]]

local VisualPrivateHolder = Tabs.MiscShit:AddRightTabbox('Local Chams')
local VisualPrivate = VisualPrivateHolder:AddTab('Local Chams')

local chamsData = {
    armChams = {
        enabled = false,
        material = Enum.Material.ForceField,
        color = Color3.fromRGB(141, 115, 245),
        transparency = 0,
    },
    gunChams = {
        enabled = false,
        material = Enum.Material.Plastic,
        color = Color3.fromRGB(177, 156, 217),
        transparency = 0,
    },
    bodyChams = {
        enabled = false,
        material = Enum.Material.Plastic,
        color = Color3.fromRGB(0,239,255),
        transparency = 0,
    },
}

local armChamsToggle = VisualPrivate:AddToggle('ArmChams', {
    Text = 'Arm Chams',
    Default = chamsData.armChams.enabled,
    Callback = function(value)
        chamsData.armChams.enabled = value
    end
})

armChamsToggle:AddColorPicker('ArmChamsColorPicker', {
    Default = chamsData.armChams.color,
    Transparency = chamsData.armChams.transparency,
    Title = 'Arm Chams Color',
    Callback = function(Value, Transparency)
        chamsData.armChams.color = Value
        chamsData.armChams.transparency = Transparency
    end
})

local gunChamsToggle = VisualPrivate:AddToggle('GunChams', {
    Text = 'Gun Chams',
    Default = chamsData.gunChams.enabled,
    Callback = function(value)
        chamsData.gunChams.enabled = value
    end
})

gunChamsToggle:AddColorPicker('GunChamsColorPicker', {
    Default = chamsData.gunChams.color,
    Transparency = chamsData.gunChams.transparency,
    Title = 'Gun Chams Color',
    Callback = function(Value, Transparency)
        chamsData.gunChams.color = Value
        chamsData.gunChams.transparency = Transparency
    end
})

local bodyChamsToggle = VisualPrivate:AddToggle('BodyChams', {
    Text = 'Body Chams',
    Default = chamsData.bodyChams.enabled,
    Callback = function(value)
        chamsData.bodyChams.enabled = value
    end
})

bodyChamsToggle:AddColorPicker('BodyChamsColorPicker', {
    Default = chamsData.bodyChams.color,
    Transparency = chamsData.bodyChams.transparency,
    Title = 'Body Chams Color',
    Callback = function(Value, Transparency)
        chamsData.bodyChams.color = Value
        chamsData.bodyChams.transparency = Transparency
    end
})

local materialOptions = { 'Neon', 'ForceField', 'Plastic', 'Glass', 'CrackedLava' }

VisualPrivate:AddDropdown('ArmMaterial', {
    Values = materialOptions,
    Default = 2, -- index 2 is ForceField
    Multi = false,
    Text = 'Arm Material',
    Callback = function(value)
        chamsData.armChams.material = Enum.Material[value]
    end
})

VisualPrivate:AddDropdown('GunMaterial', {
    Values = materialOptions,
    Default = 3, -- index 2 is ForceField
    Multi = false,
    Text = 'Gun Material',
    Callback = function(value)
        chamsData.gunChams.material = Enum.Material[value]
    end
})

VisualPrivate:AddDropdown('BodyMaterial', {
    Values = materialOptions,
    Default = 3, -- index 1 is Neon
    Multi = false,
    Text = 'Body Material',
    Callback = function(value)
        chamsData.bodyChams.material = Enum.Material[value]
    end
})

game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    local ok, err = pcall(function()
        if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
            if chamsData.bodyChams.enabled then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Color = chamsData.bodyChams.color
                        part.Material = chamsData.bodyChams.material
                    end
                end
            end
            
            for _, item in pairs(character:GetChildren()) do
                if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                    item:Destroy()
                end
            end
            
            if chamsData.gunChams.enabled then
                local currentWeapon = Workspace.game_assets.Camera.CurrentWeapon
                if currentWeapon then
                    for _, v in pairs(currentWeapon:GetDescendants()) do
                        if v:IsA("BasePart") and v.Parent.Name ~= "Left Arm" and v.Parent.Name ~= "Right Arm" then
                            v.Color = chamsData.gunChams.color
                            v.Material = chamsData.gunChams.material
                        end
                    end
                end
            end
            
            if chamsData.armChams.enabled then
                local leftArm = game:GetService("Players").LocalPlayer.PlayerScripts.SkinArms.MeshPart:WaitForChild("Left Arm")
                local rightArm = game:GetService("Players").LocalPlayer.PlayerScripts.SkinArms.MeshPart:WaitForChild("Right Arm")
                if leftArm and leftArm:IsA("BasePart") then
                    leftArm.Color = chamsData.armChams.color
                    leftArm.Material = chamsData.armChams.material
                end
                if rightArm and rightArm:IsA("BasePart") then
                    rightArm.Color = chamsData.armChams.color
                    rightArm.Material = chamsData.armChams.material
                end
            end
        end
    end)
    
    if not ok then
        warn("Error in heartbeat function: ", err)
    end
end)
--[[
local RunService = game:GetService("RunService")
local lp = game:GetService("Players").LocalPlayer

local highlightColor = Color3.new(1, 1, 1)

local Poosay = nil
local Highlight = Instance.new("Highlight")
Highlight.FillTransparency = 1
Highlight.Parent = lp.Character

local RainbowHighlightToggle = VisualPrivate:AddToggle('RainbowHighlight', {
    Text = 'LocalPlayer Highlight',
    Default = false,
    Callback = function(value)
        if value then
            Poosay = RunService.RenderStepped:Connect(function(v)
                pcall(function()
                    Highlight.FillColor = highlightColor
                    Highlight.OutlineColor = highlightColor
                end)
            end)
        else
            if Poosay then
                Poosay:Disconnect()
                Poosay = nil
            end
        end
    end
})

RainbowHighlightToggle:AddColorPicker('HighlightColorPicker', {
    Default = highlightColor,
    Title = 'Highlight Color',
    Callback = function(value)
        highlightColor = value
    end
})
--]]
--* Mod Detector *--
local ModTabBox = Tabs.MiscShit:AddRightTabbox('Mod Detection')
local ModDetector = ModTabBox:AddTab('Mod Detection')

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Moderators = {
    [3635736475] = true,
    [80790979] = true,
    [563034370] = true,
    [1813779439] = true,
    [409417337] = true,
    [89314074] = true,
    [879403144] = true,
    [526965889] = true,
    [408529185] = true,
    [2266387661] = true,
    [75094576] = true,
    [719139774] = true,
    [490614574] = true,
    [177792426] = true,
    [28576791] = true,
    [71268275] = true,
    [16889233] = true,
    [219248598] = true,
    [78629725] = true,
    [5669407] = true,
    [5629873] = true,
    [329958284] = true,
    [962938899] = true,
    [170757292] = true,
    [410665474] = true,
    [190610998] = true,
    [151544987] = true,
    [497528022] = true,
    [43165483] = true,
    [2882755487] = true,
    [1866] = true,
    [688488720] = true,
    [172340661] = true,
    [104415244] = true,
    [1939816] = true,
    [15115185] = true,
    [116573739] = true,
    [275129] = true,
    [22067450] = true,
    [898157] = true,
}

local Sender = {
    Enabled = false,
    Action = "Alert"
}

ModDetector:AddToggle('Enabled', {
    Text = 'Enabled',
    Default = false,

    Callback = function(state)
        Sender.Enabled = state
    end
})

ModDetector:AddDropdown('Action', {
    Values = { 'Alert', 'Kick' },
    Default = 1,
    Multi = false,

    Text = 'Choose Action',

    Callback = function(value)
        Sender.Action = value
    end
})

local function sendNotification(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration;
    })
end

local function checkPlayer(player)
    if Sender.Enabled and Moderators[player.UserId] then
        local modName = player.Name

        if Sender.Action == "Alert" then
            sendNotification("Moderator Detected", modName, 5)
        elseif Sender.Action == "Kick" then
            Players.LocalPlayer:Kick("Moderator Detected")
        end
    end
end

local function OnPlayerAdded(player)
    if Sender.Enabled then
        checkPlayer(player)
    end
end

if Sender.Enabled then
  for _, player in pairs(Players:GetPlayers()) do
   		checkPlayer(player)
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)

--* Extra *--
local ExtraTabBox = Tabs.MiscShit:AddRightTabbox('Extra')
local ExtraStuffs = ExtraTabBox:AddTab('Extra')

ExtraStuffs:AddToggle('ViewBob', {
    Text = 'View Bob',
    Default = false,

    Callback = function(state)
		game:GetService("Players").LocalPlayer.PlayerScripts.GunController.ViewBobEnabled.Value = state
    end
})

ExtraStuffs:AddToggle('RotateCharacter', {
    Text = 'Rotate Character',
    Default = true,

    Callback = function(state)
		game:GetService("Players").LocalPlayer.PlayerScripts.GunController.RotateCharacter.Value = state
    end
})

ExtraStuffs:AddToggle('ModifyText', {
    Text = 'Modify Text',
    Default = false,

    Callback = function(state)
    	if state then
    	game:GetService("Players").LocalPlayer.PlayerGui.GameUI.ServerNameLabel.Text = "Server Name: <b><font color='#ffc0cb'>Spectrum.solutions</font></b>"
    	game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Character.Header.Header.Text = "discord.gg/m63EA8pw5d"
    	else
		game:GetService("Players").LocalPlayer.PlayerGui.GameUI.ServerNameLabel.Text = "Server Name: <b><font color='#4CAF50'>Connect Timeout</font></b>"
    	game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Character.Header.Header.Text = "CHARACTER"
    end
end
})

-- Fetch services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local velocityThreshold = 22.2
local airTimeThreshold = 6.8
local timeInAir = 0
local airTimeToggle = false
local velocityToggle = false

local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.IgnoreGuiInset = true

local airTimeFrame = Instance.new("Frame", screenGui)
airTimeFrame.Position = UDim2.new(0.35, 0, 0.01, 0)
airTimeFrame.Size = UDim2.new(0.3, 0, 0.01, 0)
airTimeFrame.BackgroundColor3 = Color3.new(0, 0, 0)
airTimeFrame.BackgroundTransparency = 0
airTimeFrame.BorderSizePixel = 0
airTimeFrame.Visible = false

local airTimeBar = Instance.new("Frame", airTimeFrame)
airTimeBar.Size = UDim2.new(0, 0, 1, 0)
airTimeBar.BorderSizePixel = 0

local velocityFrame = Instance.new("Frame", screenGui)
velocityFrame.Position = UDim2.new(0.35, 0, 0.03, 0)
velocityFrame.Size = UDim2.new(0.3, 0, 0.01, 0)
velocityFrame.BackgroundColor3 = Color3.new(0, 0, 0)
velocityFrame.BackgroundTransparency = 0
velocityFrame.BorderSizePixel = 0
velocityFrame.Visible = false

local velocityBar = Instance.new("Frame", velocityFrame)
velocityBar.Size = UDim2.new(0, 0, 1, 0)
velocityBar.BorderSizePixel = 0

ExtraStuffs:AddToggle('ShowAirTimeBar', {
    Text = 'Show Air Time Bar',
    Default = false,
    Callback = function(state)
        airTimeToggle = state
    end
})

ExtraStuffs:AddToggle('ShowVelocityBar', {
    Text = 'Show Velocity Bar',
    Default = false,
    Callback = function(state)
        velocityToggle = state
    end
})

-- Update Function
local function updateBars(deltaTime)
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        if humanoid.FloorMaterial == Enum.Material.Air then
            timeInAir = timeInAir + deltaTime
        else
            timeInAir = 0
        end
        if airTimeToggle then
            airTimeFrame.Visible = true
            local airTimeRatio = math.min(timeInAir / airTimeThreshold, 1) 
            airTimeBar.Size = UDim2.new(airTimeRatio, 0, 1, 0)
            airTimeBar.BackgroundColor3 = Color3.fromHSV(0.33 * (1 - airTimeRatio), 1, 1)
        else
            airTimeFrame.Visible = false
        end
        
        if velocityToggle then
            velocityFrame.Visible = true
            local velocityMagnitude = humanoid.RootPart.Velocity.Magnitude
            local velocityRatio = math.min(velocityMagnitude / velocityThreshold, 1)
            velocityBar.Size = UDim2.new(velocityRatio, 0, 1, 0)
            velocityBar.BackgroundColor3 = Color3.fromHSV(0.33 * (1 - velocityRatio), 1, 1)
        else
            velocityFrame.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function(deltaTime)
    pcall(updateBars, deltaTime)
end)

player.CharacterAdded:Connect(function(character)
    timeInAir = 0
end)

--[[
ExtraStuffs:AddToggle('fo1v11outline', {
    Text = 'Hitlogs',
    Default = false,
    Callback = function(state)
        varsglobal.pdelta.hitlogs = state
    end
})
--]]

--* Cursor *--
local CrosshairTab1 = Tabs.MiscShit:AddLeftTabbox('Crosshair')
local CrosshairTab = CrosshairTab1:AddTab('Crosshair')

   do
        local utility = {}
        -- // Functions
        function utility:new(type, properties)
            local object = Drawing.new(type)
            
            for i, v in pairs(properties) do
                object[i] = v
            end
            return object
        end
        -- // Initilisation
        local lines = {}
        -- // Drawings
        local dot = utility:new("Square",{
            Visible =  true,
            Size = Vector2.new(2, 2),
            Color = varsglobal.cursor.Color,
            Filled = true,
            ZIndex = 2,
            Transparency = 1
        })
        --
        local outline = utility:new("Square",{
            Visible =  true,
            Size = Vector2.new(4, 4),
            Color = Color3.fromRGB(0, 0, 0),
            Filled = true,
            ZIndex = 1,
            Transparency = 1
        })
        local logotext = utility:new("Text", {
            Visible = false,
            Font = 2,
            Size = 15,
            Color = Color3.fromRGB(138, 128, 255),
            ZIndex = 3,
            Transparency = 1,
            Text = "spectrum.solutions",
            Center = true,
            Outline = true,
        })
        local text = utility:new("Text", {
            Visible = false,
            Font = 2,
            Size = 13,
            Color = Color3.new(1,1,1),
            ZIndex = 3,
            Transparency = 1,
            Text = Username,
            Center = true,
            Outline = true,
        })
        --
        for i=1 , 4 do
            local line = utility:new("Line",{
                Visible =  true,
                From = Vector2.new(200,500),
                To = Vector2.new(200,500),
                Color = varsglobal.cursor.Color,
                Thickness = varsglobal.cursor.Thickness,
                ZIndex = 2,
                Transparency = 1
            })
            --
            local line_outline = utility:new("Line",{
                Visible =  true,
                From = Vector2.new(200,500),
                To = Vector2.new(200,500),
                Color = Color3.fromRGB(0, 0, 0),
                Thickness = varsglobal.cursor.Thickness + 2.5,
                ZIndex = 1,
                Transparency = 1
            })
            --
            lines[i] = {line, line_outline}
        end
        -- // Main
        local angle = 0
        local transp = 0
        local reverse = false
        local function setreverse(value)
            if reverse ~= value then
                reverse = value
            end
        end
        --
        RunService.RenderStepped:connect(function()
            if varsglobal.cursor.Enabled then
                local pos
                if varsglobal.cursor.CustomPos then
                    pos = varsglobal.cursor.Position
                else
                    pos = Vector2.new(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y + game:GetService("GuiService"):GetGuiInset().Y)
                end
                angle = angle + (1 / (varsglobal.cursor.Speed * 10))
                if transp <= 1.5+varsglobal.cursor.Text.LogoFadingOffset and not reverse then 
                    transp = transp + (1 / (varsglobal.cursor.Speed * 10))
                    if transp >= 1.5+varsglobal.cursor.Text.LogoFadingOffset then setreverse(true) end
                elseif reverse then
                    transp = transp - (1 / (varsglobal.cursor.Speed * 10))
                    if transp <= 0-varsglobal.cursor.Text.LogoFadingOffset then setreverse(false) end
                end
                if angle >= 360 then
                    angle = 0
                end
                --
                dot.Visible = varsglobal.cursor.Dot
                dot.Color = varsglobal.cursor.Color
                dot.Position = Vector2.new(pos.X - 1, pos.Y - 1)
                --
                outline.Visible = varsglobal.cursor.Outline and varsglobal.cursor.Dot
                outline.Position = Vector2.new(pos.X - 2, pos.Y - 2)
                --
                logotext.Position = Vector2.new(pos.X, (pos + Vector2.new(0, varsglobal.cursor.Radius + 5)).Y)
                logotext.Transparency = transp
                logotext.Visible = varsglobal.cursor.Text.Logo
                logotext.Color = varsglobal.cursor.Text.LogoColor
                --
                text.Position = Vector2.new(pos.X, (pos + Vector2.new(0, varsglobal.cursor.Radius + (varsglobal.cursor.Text.Logo and 19 or 5))).Y)
                text.Visible = varsglobal.cursor.Text.Name
                text.Color = varsglobal.cursor.Text.NameColor
                --
                for index, line in pairs(lines) do
                    index = index
                    if varsglobal.cursor.Resize then
                        x = {pos.X + (math.cos(angle + (index * (math.pi / 2))) * (varsglobal.cursor.Radius + ((varsglobal.cursor.Radius * math.sin(angle)) / 9))), pos.X + (math.cos(angle + (index * (math.pi / 2))) * ( (varsglobal.cursor.Radius - 20) - (varsglobal.cursor.TheGap and (((varsglobal.cursor.Radius - 20) * math.cos(angle)) / 4) or (((varsglobal.cursor.Radius - 20) * math.cos(angle)) - 4))))}
                        y = {pos.Y + (math.sin(angle + (index * (math.pi / 2))) * (varsglobal.cursor.Radius + ((varsglobal.cursor.Radius * math.sin(angle)) / 9))), pos.Y + (math.sin(angle + (index * (math.pi / 2))) * ( (varsglobal.cursor.Radius - 20) - (varsglobal.cursor.TheGap and (((varsglobal.cursor.Radius - 20) * math.cos(angle)) / 4) or (((varsglobal.cursor.Radius - 20) * math.cos(angle)) - 4))))}
                    else
                        x = {pos.X + (math.cos(angle + (index * (math.pi / 2))) * (varsglobal.cursor.Radius)), pos.X + (math.cos(angle + (index * (math.pi / 2))) * ( ( varsglobal.cursor.Radius - 20 ) - (varsglobal.cursor.TheGap and((varsglobal.cursor.Radius-20)/varsglobal.cursor.Gap)or((varsglobal.cursor.Radius-20)-varsglobal.cursor.Gap)) ))}
                        y = {pos.Y + (math.sin(angle + (index * (math.pi / 2))) * (varsglobal.cursor.Radius)), pos.Y + (math.sin(angle + (index * (math.pi / 2))) * ( ( varsglobal.cursor.Radius - 20 ) - (varsglobal.cursor.TheGap and((varsglobal.cursor.Radius-20)/varsglobal.cursor.Gap)or((varsglobal.cursor.Radius-20)-varsglobal.cursor.Gap)) ))}
                    end
                    --
                    line[1].Visible = true
                    line[1].Color = varsglobal.cursor.Color
                    line[1].From = Vector2.new(x[2], y[2])
                    line[1].To = Vector2.new(x[1], y[1])
                    line[1].Thickness = varsglobal.cursor.Thickness
                    --
                    line[2].Visible = varsglobal.cursor.Outline
                    line[2].From = Vector2.new(x[2], y[2])
                    line[2].To = Vector2.new(x[1], y[1])
                    line[2].Thickness = varsglobal.cursor.Thickness + 2.5
                end
            else
                dot.Visible = false
                outline.Visible = false
                --
                for index, line in pairs(lines) do
                    line[1].Visible = false
                    line[2].Visible = false
                end
            end
        end)
    end
    CrosshairTab:AddToggle('crosshairenable', {
        Text = 'Enabled',
        Default = false,  
    
        Callback = function(first)
            varsglobal.cursor.Enabled = first  
        end
    }):AddColorPicker('crosshaircolor', {
        Default = Color3.new(1, 1, 1),
        Title = 'crosshair color',
        Transparency = 0,
        Callback = function(Value)
            varsglobal.cursor.Color = Value
        end
    })
    CrosshairTab:AddSlider('crosshairspeed', {
        Text = 'speed',
        Default = 3,
        Min = 0.1,
        Max = 10,
        Rounding = 1,
        Compact = true,  
    }):OnChanged(function(State)
        varsglobal.cursor.Speed = State
    end)
    CrosshairTab:AddSlider('crosshairradius', {
        Text = 'radius',
        Default = 25,
        Min = 0.1,
        Max = 100,
        Rounding = 1,
        Compact = true,  
    }):OnChanged(function(State)
        varsglobal.cursor.Radius = State
    end)
    CrosshairTab:AddSlider('crosshairthickness', {
        Text = 'thickness',
        Default = 1.5,
        Min = 0.1,
        Max = 10,
        Rounding = 1,
        Compact = true,  
    }):OnChanged(function(State)
        varsglobal.cursor.Thickness = State
    end)
    CrosshairTab:AddSlider('crosshairgapsize', {
        Text = 'gap',
        Default = 5,
        Min = 0,
        Max = 50,
        Rounding = 1,
        Compact = true,  
    }):OnChanged(function(State)
        varsglobal.cursor.Gap = State
    end)
    CrosshairTab:AddToggle('crosshairenablegap', {
        Text = 'math divide gap',
        Default = false,  
    
        Callback = function(first)
            varsglobal.cursor.TheGap = first  
        end
    })
    CrosshairTab:AddToggle('crosshairenableoutline', {
        Text = 'outline',
        Default = false,  
    
        Callback = function(first)
            varsglobal.cursor.Outline = first  
        end
    })
    CrosshairTab:AddToggle('crosshairenableresize', {
        Text = 'resize animation',
        Default = false,  
    
        Callback = function(first)
            varsglobal.cursor.Resize = first  
        end
    })
    CrosshairTab:AddToggle('crosshairenabledot', {
        Text = 'dot',
        Default = false,  
    
        Callback = function(first)
            varsglobal.cursor.Dot = first  
        end
    })
    CrosshairTab:AddToggle('crosshairtextLogo', {
        Text = 'text logo',
        Default = false,  
    
        Callback = function(first)
            varsglobal.cursor.Text.Logo = first  
        end
    }):AddColorPicker('crosshairlogocolor', {
        Default = Color3.new(1, 1, 1),
        Title = 'logo color',
        Transparency = 0,
        Callback = function(Value)
            varsglobal.cursor.Text.LogoColor = Value
        end
    })
    CrosshairTab:AddToggle('crosshairtextName', {
        Text = 'text name',
        Default = false,  
    
        Callback = function(first)
            varsglobal.cursor.Text.Name = first  
        end
    }):AddColorPicker('crosshairtextcolor', {
        Default = Color3.new(1, 1, 1),
        Title = 'text color',
        Transparency = 0,
        Callback = function(Value)
            varsglobal.cursor.Text.NameColor = Value
        end
    })
    CrosshairTab:AddSlider('crosshairlogooffset', {
        Text = 'logo fade offset',
        Default = 0,
        Min = 0,
        Max = 5,
        Rounding = 1,
        Compact = true,  
    }):OnChanged(function(State)
        varsglobal.cursor.Text.LogoFadingOffset = State
    end)

-- Library functions
-- Sets the watermark visibility
Library:SetWatermarkVisibility(true)

-- Example of dynamically-updating watermark with common traits (fps and ping)
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('spectrum.solutions | v3'):format(
        math.floor(FPS)
    ));
end);

Library.KeybindFrame.Visible = false; -- todo: add a function for this

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
MenuGroup:AddToggle('Watermark2', {
    Text = 'Watermark',
    Default = true,

    Callback = function(state)
        if state then
        Library:SetWatermarkVisibility(true)
    else
        Library:SetWatermarkVisibility(false)
	 end
    end
})

MenuGroup:AddToggle('Keybind2', {
    Text = 'Keybinds',
    Default = false,

    Callback = function(state)
    if state then
    Library.KeybindFrame.Visible = true
    else
    Library.KeybindFrame.Visible = false
    end
    end
})

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('SpectrumSolutions')
SaveManager:SetFolder('SpectrumSolutions/QuarantineZ')

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()

local Credits = Tabs['UI Settings']:AddRightGroupbox('Credits')

Credits:AddLabel('Developer ~ Austri V3#7963')
Credits:AddLabel('Emotional Support ~ .peaci')
