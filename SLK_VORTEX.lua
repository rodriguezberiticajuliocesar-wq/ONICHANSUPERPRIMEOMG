-- =====================================================
-- SLK VORTEX - MUSCLE LEGENDS (Version 8.0)
-- Interfaz: Elerium V2 (desde tu repo)
-- Técnicas: Basadas en SilenceScripts (HonenxWhite)
-- =====================================================

-- =====================================================
-- SERVICIOS
-- =====================================================
local services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualUser = game:GetService("VirtualUser"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    Workspace = workspace,
    Lighting = game:GetService("Lighting"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    CollectionService = game:GetService("CollectionService"),
    HttpService = game:GetService("HttpService"),
    Stats = game:GetService("Stats")
}

-- =====================================================
-- UTILS
-- =====================================================
local utils = {}
utils.runtime = {}

utils.playerData = {
    Player = services.Players.LocalPlayer,
    DisplayName = services.Players.LocalPlayer.DisplayName,
    Character = services.Players.LocalPlayer.Character,
    Humanoid = nil,
    Camera = services.Workspace.CurrentCamera,
    Backpack = services.Players.LocalPlayer:WaitForChild("Backpack")
}

utils.playerData.Humanoid = utils.playerData.Character and utils.playerData.Character:FindFirstChildOfClass("Humanoid")

-- Los eventos correctos (como en el script de referencia)
utils.remotes = {
    ChangeSpeedSize = services.ReplicatedStorage.rEvents.changeSpeedSizeRemote,
    MuscleEvent = utils.playerData.Player.muscleEvent,
    RebirthRemote = services.ReplicatedStorage.rEvents.rebirthRemote,
    EquipPetEvent = services.ReplicatedStorage.rEvents.equipPetEvent,
    PetEvolveEvent = services.ReplicatedStorage.rEvents.petEvolveEvent,
    GiftRemote = services.ReplicatedStorage.rEvents.giftRemote,
    ShowPetsEvent = services.ReplicatedStorage.rEvents.showPetsEvent,
    SavePlayerSizeEvent = services.ReplicatedStorage.rEvents.savePlayerSizeEvent
}

function utils.formatNumber(n)
    if not n then return "0" end
    if n >= 1e18 then return string.format("%.1fqi", n / 1e18)
    elseif n >= 1e15 then return string.format("%.1fqa", n / 1e15)
    elseif n >= 1e12 then return string.format("%.1ft", n / 1e12)
    elseif n >= 1e9 then return string.format("%.1fb", n / 1e9)
    elseif n >= 1e6 then return string.format("%.1fm", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fk", n / 1e3)
    else return tostring(math.floor(n)) end
end

function utils.formatWithCommas(n)
    local formatted = tostring(math.floor(n or 0))
    while true do
        local k
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        if k == 0 then break end
    end
    return formatted
end

function utils.connect(signal, callback)
    return signal:Connect(callback)
end

-- =====================================================
-- CREAR VENTANA CON ELERIUM V2 (desde tu repo)
-- =====================================================
utils.library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rodriguezberiticajuliocesar-wq/SilenceScripts/refs/heads/main/libraries/eleriumv2.luau?cache=" .. tostring(os.time()), true))()

local Window = utils.library:AddWindow("SLK VORTEX", {
    main_color = Color3.fromRGB(120, 0, 255),
    min_size = Vector2.new(800, 600),
    can_resize = true,
    toggle_key = Enum.KeyCode.RightShift
})

-- =====================================================
-- PESTAÑAS
-- =====================================================
local tabs = {
    main = Window:AddTab("Main"),
    farming = Window:AddTab("Farming"),
    fast = Window:AddTab("⚡ Fast"),
    killing = Window:AddTab("Killing"),
    stats = Window:AddTab("Stats"),
    info = Window:AddTab("Info")
}

for _, tab in pairs(tabs) do
    tab.runtime = {}
end

-- =====================================================
-- TAB MAIN
-- =====================================================
tabs.main:AddLabel("⚙️ User Settings:")

tabs.main.Settings = {
    Size = {Value = 2, Enabled = false},
    Speed = {Value = 120, Enabled = false},
    FOV = {Value = 70, Enabled = false}
}

tabs.main:AddTextBox("Size:", function(text)
    text = string.gsub(text, "%s+", "")
    if tonumber(text) and tonumber(text) > 0 then
        tabs.main.Settings.Size.Value = tonumber(text)
    end
end, {clear = false})

tabs.main:AddSwitch("Set Size", function(bool)
    tabs.main.Settings.Size.Enabled = bool
end)

task.spawn(function()
    while true do
        if tabs.main.Settings.Size.Enabled and utils.playerData.Character and utils.playerData.Humanoid then
            pcall(function()
                utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", tabs.main.Settings.Size.Value)
            end)
        end
        task.wait(0.15)
    end
end)

tabs.main:AddTextBox("Speed:", function(text)
    text = string.gsub(text, "%s+", "")
    if tonumber(text) and tonumber(text) > 0 then
        tabs.main.Settings.Speed.Value = tonumber(text)
    end
end, {clear = false})

tabs.main:AddSwitch("Set Speed", function(bool)
    tabs.main.Settings.Speed.Enabled = bool
end)

task.spawn(function()
    while true do
        if tabs.main.Settings.Speed.Enabled and utils.playerData.Character and utils.playerData.Humanoid then
            pcall(function()
                utils.remotes.ChangeSpeedSize:InvokeServer("changeSpeed", tabs.main.Settings.Speed.Value)
            end)
        end
        task.wait(0.15)
    end
end)

tabs.main:AddTextBox("FOV:", function(text)
    text = string.gsub(text, "%s+", "")
    if tonumber(text) and tonumber(text) >= 1 and tonumber(text) <= 120 then
        tabs.main.Settings.FOV.Value = tonumber(text)
    end
end, {clear = false})

tabs.main:AddSwitch("Set FOV", function(bool)
    tabs.main.Settings.FOV.Enabled = bool
    if utils.playerData.Camera then
        utils.playerData.Camera.FieldOfView = bool and tabs.main.Settings.FOV.Value or 70
    end
end)

tabs.main:AddLabel("🛡️ Protection:")

tabs.main.Protection = {
    AntiFling = {Enabled = false},
    PositionLock = {Enabled = false, Position = nil}
}

tabs.main.enableAntiFling = function()
    if not utils.playerData.Player.Character then return end
    if not utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
    if utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("SLK_AntiFling") then
        utils.playerData.Player.Character.HumanoidRootPart.SLK_AntiFling:Destroy()
    end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "SLK_AntiFling"
    bv.MaxForce = Vector3.new(100000, 0, 100000)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 1250
    bv.Parent = utils.playerData.Player.Character.HumanoidRootPart
end

tabs.main.disableAntiFling = function()
    if not utils.playerData.Player.Character then return end
    if not utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local bv = utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("SLK_AntiFling")
    if bv then bv:Destroy() end
end

tabs.main:AddSwitch("Anti Fling", function(bool)
    tabs.main.Protection.AntiFling.Enabled = bool
    if bool then tabs.main.enableAntiFling() else tabs.main.disableAntiFling() end
end)

utils.connect(utils.playerData.Player.CharacterAdded, function(newChar)
    newChar:WaitForChild("HumanoidRootPart", 5)
    if tabs.main.Protection.AntiFling.Enabled then tabs.main.enableAntiFling() end
end)

tabs.main:AddLabel("🎮 Other:")

tabs.main:AddSwitch("Infinite Jump", function(bool)
    _G.SLKInfiniteJump = bool
end)

services.UserInputService.JumpRequest:Connect(function()
    if _G.SLKInfiniteJump then
        local char = utils.playerData.Player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

tabs.main:AddSwitch("Hide Pets", function(state)
    pcall(function()
        utils.remotes.ShowPetsEvent:FireServer(state and "hidePets" or "showPets")
    end)
end)

tabs.main.TimeDropdown = tabs.main:AddDropdown("Change Time", function(selection)
    services.Lighting.ClockTime = selection == "Night" and 0 or 9
end)
tabs.main.TimeDropdown:Add("Night")
tabs.main.TimeDropdown:Add("Day")

tabs.main.FortuneWheelData = {
    Running = false,
    Generation = 0,
    Remote = services.ReplicatedStorage.rEvents:WaitForChild("openFortuneWheelRemote"),
    Chances = services.ReplicatedStorage
        :WaitForChild("shared")
        :WaitForChild("catalogs")
        :WaitForChild("fortuneWheelChances")
        :WaitForChild("Fortune Wheel")
}

tabs.main:AddSwitch("Spin Fortune Wheel", function(state)
    tabs.main.FortuneWheelData.Running = state
    tabs.main.FortuneWheelData.Generation += 1
    tabs.main.runtime.fwGen = tabs.main.FortuneWheelData.Generation

    if not state then return end

    task.spawn(function()
        while tabs.main.FortuneWheelData.Running and tabs.main.FortuneWheelData.Generation == tabs.main.runtime.fwGen do
            pcall(function()
                tabs.main.FortuneWheelData.Remote:InvokeServer("openFortuneWheel", tabs.main.FortuneWheelData.Chances)
            end)
            task.wait(1)
        end
    end)
end)

-- =====================================================
-- TAB FARMING
-- =====================================================
tabs.farming:AddLabel("🔄 Rebirths:")

tabs.farming.RebirthData = {
    Label = tabs.farming:AddLabel("Rebirths: 0"),
    TargetLabel = tabs.farming:AddLabel("Target: None"),
    Rebirths = utils.playerData.Player.leaderstats:WaitForChild("Rebirths"),
    TargetRebirths = 0,
    IsAutoRebirthing = false
}

tabs.farming:AddTextBox("Set Rebirth Target:", function(text)
    if tonumber(text) and tonumber(text) >= 0 then
        tabs.farming.RebirthData.TargetRebirths = tonumber(text)
    end
end)

tabs.farming.RebirthData.Switch = tabs.farming:AddSwitch("Auto Rebirth", function(enabled)
    if enabled and tabs.farming.RebirthData.TargetRebirths > 0 and tabs.farming.RebirthData.Rebirths.Value < tabs.farming.RebirthData.TargetRebirths then
        tabs.farming.RebirthData.IsAutoRebirthing = true
        task.spawn(function()
            while tabs.farming.RebirthData.IsAutoRebirthing and tabs.farming.RebirthData.Rebirths.Value < tabs.farming.RebirthData.TargetRebirths do
                pcall(function()
                    utils.remotes.RebirthRemote:InvokeServer("rebirthRequest")
                end)
                task.wait(0.05)
            end
            tabs.farming.RebirthData.IsAutoRebirthing = false
            tabs.farming.RebirthData.Switch:Set(false)
        end)
    else
        tabs.farming.RebirthData.IsAutoRebirthing = false
    end
end)

task.spawn(function()
    while true do
        tabs.farming.RebirthData.Label.Text = "Rebirths: " .. utils.formatWithCommas(tabs.farming.RebirthData.Rebirths.Value)
        tabs.farming.RebirthData.TargetLabel.Text = "Target: " .. utils.formatWithCommas(tabs.farming.RebirthData.TargetRebirths)
        task.wait(0.1)
    end
end)

tabs.farming.SizeData = {Active = false}
tabs.farming.SizeSwitch = tabs.farming:AddSwitch("Auto Size 1", function(bool) tabs.farming.SizeData.Active = bool end)

task.spawn(function()
    while true do
        if tabs.farming.SizeData.Active and utils.playerData.Character and utils.playerData.Humanoid then
            pcall(function()
                utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", 1)
            end)
        end
        task.wait(0.01)
    end
end)

tabs.farming.KingData = {TargetPosition = CFrame.new(-8665.4, 17.21, -5792.9), TeleportActive = false}
tabs.farming.KingSwitch = tabs.farming:AddSwitch("Auto King", function(enabled)
    tabs.farming.KingData.TeleportActive = enabled
end)

task.spawn(function()
    while true do
        if tabs.farming.KingData.TeleportActive then
            local char = utils.playerData.Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if (char.HumanoidRootPart.Position - tabs.farming.KingData.TargetPosition.Position).Magnitude > 5 then
                    pcall(function()
                        char.HumanoidRootPart.CFrame = tabs.farming.KingData.TargetPosition
                    end)
                end
            end
        end
        task.wait(0.05)
    end
end)

tabs.farming:AddLabel("💪 Auto Exercises:")

tabs.farming.ExerciseData = {
    SelectedTool = nil,
    AutoFarm = false
}

tabs.farming.ToolDropdown = tabs.farming:AddDropdown("Select Exercise", function(selection)
    tabs.farming.ExerciseData.SelectedTool = selection
end)
for _, tool in ipairs({"Weight", "Pushups", "Situps", "Handstands"}) do
    tabs.farming.ToolDropdown:Add(tool)
end

tabs.farming.ToolExerciseSwitch = tabs.farming:AddSwitch("Start Exercising", function(enabled)
    tabs.farming.ExerciseData.AutoFarm = enabled

    if enabled then
        task.spawn(function()
            while tabs.farming.ExerciseData.AutoFarm do
                local char = utils.playerData.Player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local backpack = utils.playerData.Player:FindFirstChild("Backpack")

                if not char or not hum or hum.Health <= 0 then
                    utils.playerData.Player.CharacterAdded:Wait()
                    char = utils.playerData.Player.Character
                    hum = char:WaitForChild("Humanoid")
                    task.wait(2)
                end

                if char and backpack and tabs.farming.ExerciseData.SelectedTool then
                    local toolName = tabs.farming.ExerciseData.SelectedTool
                    if not char:FindFirstChild(toolName) then
                        local tool = backpack:FindFirstChild(toolName)
                        if tool then
                            hum:EquipTool(tool)
                            task.wait(0.2)
                        end
                    end

                    if char:FindFirstChild(toolName) then
                        pcall(function()
                            utils.remotes.MuscleEvent:FireServer("rep")
                        end)
                    end

                    if toolName == "Handstands" and tick() % 6 < 0.1 then
                        pcall(function()
                            services.VirtualUser:CaptureController()
                            services.VirtualUser:ClickButton1(Vector2.new(500, 500))
                        end)
                    end
                end

                task.wait()
            end
        end)
    end
end)

tabs.farming.AutoRepRunning = false
tabs.farming.AutoRepSwitch = tabs.farming:AddSwitch("Auto Rep", function(state)
    tabs.farming.AutoRepRunning = state
    if not state then return end
    task.spawn(function()
        while tabs.farming.AutoRepRunning do
            pcall(function()
                utils.remotes.MuscleEvent:FireServer("rep")
            end)
            task.wait(0.1)
        end
    end)
end)

tabs.farming:AddLabel("🪨 Auto Rock:")

tabs.farming.RockData = {
    Data = {["Tiny Rock - 0 Dura"] = 0, ["Large Rock - 100 Dura"] = 100, ["Punching Rock - 10 Dura"] = 10,
        ["Golden Rock - 5k Dura"] = 5000, ["Frost Rock - 150k Dura"] = 150000, ["Mythical Rock - 400k Dura"] = 400000,
        ["Eternal Rock - 750k Dura"] = 750000, ["Legend Rock - 1m Dura"] = 1000000, ["Muscle King Rock - 5m Dura"] = 5000000,
        ["Jungle Rock - 10m Dura"] = 10000000, ["Industrial Rock - 25m Dura"] = 25000000},
    SelectedRock = nil
}

tabs.farming.RockDropdown = tabs.farming:AddDropdown("Select Rock", function(selection)
    tabs.farming.RockData.SelectedRock = selection
end)
for rockName in pairs(tabs.farming.RockData.Data) do tabs.farming.RockDropdown:Add(rockName) end

tabs.farming.MachinesFolder = services.Workspace:WaitForChild("machinesFolder")

tabs.farming.RockSwitch = tabs.farming:AddSwitch("Auto Rock", function(enabled)
    _G.SLKRockFarm = enabled
    if enabled and tabs.farming.RockData.SelectedRock then
        task.spawn(function()
            while _G.SLKRockFarm do
                task.wait(0.12)
                local durability = utils.playerData.Player:FindFirstChild("Durability")
                if durability and durability.Value >= tabs.farming.RockData.Data[tabs.farming.RockData.SelectedRock] then
                    local char = utils.playerData.Player.Character
                    if char and char:FindFirstChild("LeftHand") then
                        for _, v in pairs(tabs.farming.MachinesFolder:GetDescendants()) do
                            if v.Name == "neededDurability" and v.Value == tabs.farming.RockData.Data[tabs.farming.RockData.SelectedRock] and v.Parent:FindFirstChild("Rock") then
                                pcall(function()
                                    firetouchinterest(v.Parent.Rock, char.RightHand, 0)
                                    firetouchinterest(v.Parent.Rock, char.RightHand, 1)
                                    firetouchinterest(v.Parent.Rock, char.LeftHand, 0)
                                    firetouchinterest(v.Parent.Rock, char.LeftHand, 1)
                                    utils.remotes.MuscleEvent:FireServer("punch", "leftHand")
                                    utils.remotes.MuscleEvent:FireServer("punch", "rightHand")
                                end)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- =====================================================
-- TAB FAST (Fast Rep + Fast Rebirth - Técnica exacta)
-- =====================================================
tabs.fast:AddLabel("⚡ Fast Rep (Ping Control):")

tabs.fast.FastRepData = {
    Running = false,
    SendRate = 800,
    CurrentPing = 0,
    LastPingCheck = 0,
    PingControl = true
}

local networkStats = services.Stats.Network.ServerStatsItem["Data Ping"]

tabs.fast.FastRepStatus = tabs.fast:AddLabel("Status: Inactive")
tabs.fast.FastRepStatus.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.fast.FastRepWorkerLoop = function()
    while tabs.fast.FastRepData.Running do
        -- Actualizar ping cada 0.5s
        if tick() - tabs.fast.FastRepData.LastPingCheck > 0.5 then
            pcall(function()
                tabs.fast.FastRepData.CurrentPing = networkStats:GetValue()
            end)
            tabs.fast.FastRepData.LastPingCheck = tick()

            if tabs.fast.FastRepData.PingControl then
                local ping = tabs.fast.FastRepData.CurrentPing
                if ping < 80 then
                    tabs.fast.FastRepData.SendRate = 1000
                elseif ping < 150 then
                    tabs.fast.FastRepData.SendRate = 700
                elseif ping < 250 then
                    tabs.fast.FastRepData.SendRate = 450
                elseif ping < 400 then
                    tabs.fast.FastRepData.SendRate = 250
                else
                    tabs.fast.FastRepData.SendRate = 120
                end
            end
        end

        -- Enviar reps (un lote por frame)
        local repsToSend = math.floor(tabs.fast.FastRepData.SendRate / 60)
        if repsToSend < 1 then repsToSend = 1 end
        if repsToSend > 12 then repsToSend = 12 end

        for i = 1, repsToSend do
            pcall(function()
                utils.remotes.MuscleEvent:FireServer("rep")
            end)
        end

        -- Actualizar status
        tabs.fast.FastRepStatus.Text = "Status: " .. tabs.fast.FastRepData.SendRate
            .. " reps/s | " .. math.floor(tabs.fast.FastRepData.CurrentPing) .. " ms"
        tabs.fast.FastRepStatus.TextColor3 = Color3.fromRGB(80, 255, 120)

        services.RunService.Heartbeat:Wait()
    end
end

tabs.fast:AddSwitch("Ping Control (Auto Speed)", function(state)
    tabs.fast.FastRepData.PingControl = state
end):Set(true)

tabs.fast.FastRepToggle = tabs.fast:AddSwitch("Fast Rep (No Lag)", function(state)
    tabs.fast.FastRepData.Running = state
    if state then
        tabs.fast.FastRepData.SendRate = 800
        tabs.fast.FastRepData.LastPingCheck = tick()
        tabs.fast.FastRepStatus.Text = "Status: Activando..."
        tabs.fast.FastRepStatus.TextColor3 = Color3.fromRGB(255, 200, 80)
        task.spawn(tabs.fast.FastRepWorkerLoop)
    else
        tabs.fast.FastRepStatus.Text = "Status: Inactive"
        tabs.fast.FastRepStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

tabs.fast:AddLabel("🔧 400-1000 reps/s | Ping auto-ajustado")

-- =====================================================
-- FAST REBIRTH (Técnica exacta de SilenceScripts)
-- =====================================================
tabs.fast:AddLabel("🔄 Fast Rebirth (Pet Swap):")

tabs.fast.FastRebirthData = {
    Running = false,
    Rebirths = utils.playerData.Player.leaderstats:WaitForChild("Rebirths"),
    Strength = utils.playerData.Player.leaderstats:WaitForChild("Strength"),
    TargetRebirths = 0,
    TotalRebirths = 0,
    RepPets = {"Omega Overlord", "Swift Samurai", "Inferno Drake"},
    RebirthPets = {"Titanium Hydra", "Tribal Overlord"}
}

tabs.fast.FastRebirthStatus = tabs.fast:AddLabel("Status: Inactive")
tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.fast.FastRebirthStats = tabs.fast:AddLabel("Rebirths: 0 | Gained: 0")

-- Desequipar todas las mascotas
tabs.fast.desequipAll = function()
    local player = utils.playerData.Player
    local petsFolder = player.petsFolder

    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                pcall(function()
                    utils.remotes.EquipPetEvent:FireServer("unequipPet", pet)
                end)
            end
        end
    end
    task.wait(0.3)
end

-- Equipar mascotas específicas
tabs.fast.equipPets = function(petNames)
    local petsFolder = utils.playerData.Player.petsFolder
    local uniquePets = petsFolder.Unique

    tabs.fast.desequipAll()
    task.wait(0.2)

    local equipped = 0
    for _, petName in ipairs(petNames) do
        for _, pet in pairs(uniquePets:GetChildren()) do
            if pet.Name == petName then
                pcall(function()
                    utils.remotes.EquipPetEvent:FireServer("equipPet", pet)
                end)
                equipped = equipped + 1
                task.wait(0.05)
            end
        end
    end
    task.wait(0.3)
    return equipped
end

tabs.fast.FastRebirthWorker = function()
    local startRebirths = tabs.fast.FastRebirthData.Rebirths.Value

    while tabs.fast.FastRebirthData.Running do
        if tabs.fast.FastRebirthData.TargetRebirths > 0
            and tabs.fast.FastRebirthData.Rebirths.Value >= tabs.fast.FastRebirthData.TargetRebirths then
            tabs.fast.FastRebirthStatus.Text = "Status: ✅ Target alcanzado"
            tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
            tabs.fast.FastRebirthData.Running = false
            break
        end

        -- PASO 1: Equipar mascotas de Rep
        tabs.fast.FastRebirthStatus.Text = "Status: Equipando Rep Pets..."
        tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 200, 80)

        local equippedRep = 0
        pcall(function()
            equippedRep = tabs.fast.equipPets(tabs.fast.FastRebirthData.RepPets)
        end)

        tabs.fast.FastRebirthStatus.Text = "Status: " .. equippedRep .. " Rep Pets"

        -- PASO 2: Farmear hasta el target
        local currentRebirths = tabs.fast.FastRebirthData.Rebirths.Value
        local targetStrength = 5000 + currentRebirths * 2550
        local repsPerBurst = utils.playerData.Player.MembershipType == Enum.MembershipType.Premium and 6 or 12

        tabs.fast.FastRebirthStatus.Text = "Status: Farmeando..."
        tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(80, 255, 120)

        while tabs.fast.FastRebirthData.Running
            and tabs.fast.FastRebirthData.Strength.Value < targetStrength do
            pcall(function()
                for i = 1, repsPerBurst do
                    utils.remotes.MuscleEvent:FireServer("rep")
                end
            end)
            task.wait(0.05)
            tabs.fast.FastRebirthStats.Text = "Rebirths: "
                .. utils.formatWithCommas(tabs.fast.FastRebirthData.Rebirths.Value)
                .. " | Gained: "
                .. utils.formatWithCommas(tabs.fast.FastRebirthData.Rebirths.Value - startRebirths)
        end

        -- PASO 3: Equipar mascotas de Rebirth
        if tabs.fast.FastRebirthData.Running
            and tabs.fast.FastRebirthData.Strength.Value >= targetStrength then

            tabs.fast.FastRebirthStatus.Text = "Status: Equipando Rebirth Pets..."
            tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 150, 255)

            local equippedReb = 0
            pcall(function()
                equippedReb = tabs.fast.equipPets(tabs.fast.FastRebirthData.RebirthPets)
            end)

            tabs.fast.FastRebirthStatus.Text = "Status: " .. equippedReb .. " Rebirth Pets"
            task.wait(0.5)

            -- PASO 4: Rebirth
            tabs.fast.FastRebirthStatus.Text = "Status: Haciendo Rebirth..."
            tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 200, 80)

            local rebirthBefore = tabs.fast.FastRebirthData.Rebirths.Value
            local attempts = 0

            repeat
                pcall(function()
                    utils.remotes.RebirthRemote:InvokeServer("rebirthRequest")
                end)
                task.wait(0.05)
                attempts = attempts + 1
            until not tabs.fast.FastRebirthData.Running
                or tabs.fast.FastRebirthData.Rebirths.Value > rebirthBefore
                or attempts >= 50

            if tabs.fast.FastRebirthData.Rebirths.Value > rebirthBefore then
                tabs.fast.FastRebirthData.TotalRebirths = tabs.fast.FastRebirthData.TotalRebirths +
                    (tabs.fast.FastRebirthData.Rebirths.Value - rebirthBefore)
            end

            task.wait(0.5)
        end
        task.wait(0.1)
    end
end

tabs.fast:AddTextBox("Target rebirths (0 = inf):", function(text)
    local num = tonumber(text)
    if num and num >= 0 then
        tabs.fast.FastRebirthData.TargetRebirths = math.floor(num)
    end
end, {clear = false})

tabs.fast.FastRebirthToggle = tabs.fast:AddSwitch("Fast Rebirth 🔄", function(state)
    tabs.fast.FastRebirthData.Running = state
    if state then
        tabs.fast.FastRebirthStatus.Text = "Status: 🔄 Iniciando..."
        tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
        task.spawn(tabs.fast.FastRebirthWorker)
    else
        tabs.fast.FastRebirthStatus.Text = "Status: Inactive"
        tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

tabs.fast:AddLabel("Omega Overlord > Farm > Titanium Hydra > Rebirth")

-- =====================================================
-- TAB KILLING (Kill Aura + Kill All)
-- =====================================================
tabs.killing:AddLabel("⚔️ Kill Aura:")

_G.SLKWhitelisted = _G.SLKWhitelisted or {}

tabs.killing.isWhitelisted = function(player)
    for _, name in ipairs(_G.SLKWhitelisted) do
        if name:lower() == player.Name:lower() then return true end
    end
    return false
end

tabs.killing.isPlayerAlive = function(player)
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
        player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

tabs.killing.getTool = function()
    local char = utils.playerData.Player.Character
    local backpack = utils.playerData.Player.Backpack
    if not char or not backpack then return end

    for _, v in pairs(backpack:GetChildren()) do
        if v.Name == "Punch" and char:FindFirstChild("Humanoid") then
            char.Humanoid:EquipTool(v)
        end
    end
    pcall(function()
        utils.remotes.MuscleEvent:FireServer("punch", "leftHand")
        utils.remotes.MuscleEvent:FireServer("punch", "rightHand")
    end)
end

tabs.killing.attackPlayer = function(target)
    if not tabs.killing.isPlayerAlive(target) or tabs.killing.isWhitelisted(target) then return end

    local char = utils.playerData.Player.Character
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not char or not targetRoot then return end

    local localRoot = char:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3.5, 0)
    localRoot.AssemblyLinearVelocity = Vector3.zero
    localRoot.AssemblyAngularVelocity = Vector3.zero

    services.RunService.Heartbeat:Wait()

    local hand = char:FindFirstChild("LeftHand") or char:FindFirstChild("RightHand")
    if not hand then return end

    pcall(function()
        firetouchinterest(targetRoot, hand, 0)
        firetouchinterest(targetRoot, hand, 1)
        utils.remotes.MuscleEvent:FireServer("punch", hand.Name == "LeftHand" and "leftHand" or "rightHand")
    end)
end

tabs.killing.KillAuraRunning = false

tabs.killing:AddSwitch("Kill Aura (Auto Attack)", function(state)
    tabs.killing.KillAuraRunning = state
    if not state then return end

    task.spawn(function()
        while tabs.killing.KillAuraRunning do
            for _, player in ipairs(services.Players:GetPlayers()) do
                if player ~= utils.playerData.Player and tabs.killing.isPlayerAlive(player) and not tabs.killing.isWhitelisted(player) then
                    tabs.killing.attackPlayer(player)
                end
            end
            task.wait(0.1)
        end
    end)
end)

tabs.killing:AddSwitch("Kill Everyone", function(state)
    _G.SLKKillAll = state
    if not state then return end

    task.spawn(function()
        while _G.SLKKillAll do
            for _, player in ipairs(services.Players:GetPlayers()) do
                if player ~= utils.playerData.Player and not tabs.killing.isWhitelisted(player) and tabs.killing.isPlayerAlive(player) then
                    for _ = 1, 4 do
                        tabs.killing.attackPlayer(player)
                        task.wait(0.05)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

tabs.killing:AddLabel("📝 Whitelist:")

tabs.killing.WhitelistLabel = tabs.killing:AddLabel("Whitelist: None")

tabs.killing.updateWhitelistLabel = function()
    if #_G.SLKWhitelisted == 0 then
        tabs.killing.WhitelistLabel.Text = "Whitelist: None"
    else
        tabs.killing.WhitelistLabel.Text = "Whitelist: " .. table.concat(_G.SLKWhitelisted, ", ")
    end
end

tabs.killing.WhitelistDropdown = tabs.killing:AddDropdown("Add to Whitelist", function(selectedText)
    local playerName = selectedText:match("| (.+)$")
    if playerName then
        playerName = playerName:gsub("^%s*(.-)%s*$", "%1")
        for _, name in ipairs(_G.SLKWhitelisted) do
            if name:lower() == playerName:lower() then return end
        end
        table.insert(_G.SLKWhitelisted, playerName)
        tabs.killing.updateWhitelistLabel()
    end
end)

for _, player in ipairs(services.Players:GetPlayers()) do
    if player ~= utils.playerData.Player then
        tabs.killing.WhitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end

utils.connect(services.Players.PlayerAdded, function(player)
    if player ~= utils.playerData.Player then
        tabs.killing.WhitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end)

tabs.killing:AddButton("Clear Whitelist", function()
    _G.SLKWhitelisted = {}
    tabs.killing.updateWhitelistLabel()
end)

-- =====================================================
-- TAB STATS
-- =====================================================
tabs.stats.Data = {
    StartTime = tick(),
    StartStrength = utils.playerData.Player:WaitForChild("leaderstats"):WaitForChild("Strength").Value,
    StartRebirths = utils.playerData.Player:WaitForChild("leaderstats"):WaitForChild("Rebirths").Value,
    Labels = {}
}

local function formatTiempo(segundos)
    if segundos < 60 then return string.format("%ds", math.floor(segundos))
    elseif segundos < 3600 then return string.format("%dm %ds", math.floor(segundos / 60), math.floor(segundos % 60))
    elseif segundos < 86400 then return string.format("%dh %dm", math.floor(segundos / 3600), math.floor((segundos % 3600) / 60))
    else return string.format("%dd %dh", math.floor(segundos / 86400), math.floor((segundos % 86400) / 3600)) end
end

tabs.stats:AddLabel("========================================")
tabs.stats:AddLabel("        📊 REAL-TIME METRICS")
tabs.stats:AddLabel("========================================")

tabs.stats:AddLabel("💪 STRENGTH")
tabs.stats.Data.Labels.StrengthGained = tabs.stats:AddLabel("   Gained: 0")
tabs.stats.Data.Labels.StrengthHour = tabs.stats:AddLabel("   x 1 Hour: 0")
tabs.stats.Data.Labels.StrengthDay = tabs.stats:AddLabel("   x 1 Day: 0")
tabs.stats.Data.Labels.StrengthWeek = tabs.stats:AddLabel("   x 1 Week: 0")

tabs.stats:AddLabel("🔄 REBIRTHS")
tabs.stats.Data.Labels.RebirthsGained = tabs.stats:AddLabel("   Gained: 0")
tabs.stats.Data.Labels.RebirthsHour = tabs.stats:AddLabel("   x 1 Hour: 0")
tabs.stats.Data.Labels.RebirthsDay = tabs.stats:AddLabel("   x 1 Day: 0")

tabs.stats.Data.Labels.TiempoSesion = tabs.stats:AddLabel("⏱️ Session: 0s")
tabs.stats:AddLabel("========================================")

task.spawn(function()
    while true do
        local now = tick()
        local elapsed = now - tabs.stats.Data.StartTime

        if elapsed > 0.5 then
            local currentStrength = utils.playerData.Player.leaderstats.Strength.Value
            local currentRebirths = utils.playerData.Player.leaderstats.Rebirths.Value

            local gainStrength = currentStrength - tabs.stats.Data.StartStrength
            local gainRebirths = currentRebirths - tabs.stats.Data.StartRebirths

            local sHour = (gainStrength / elapsed) * 3600
            local sDay = sHour * 24
            local sWeek = sDay * 7
            local rHour = (gainRebirths / elapsed) * 3600
            local rDay = rHour * 24

            tabs.stats.Data.Labels.StrengthGained.Text = "   Gained: " .. utils.formatNumber(gainStrength)
            tabs.stats.Data.Labels.StrengthHour.Text = "   x 1 Hour: " .. utils.formatNumber(sHour)
            tabs.stats.Data.Labels.StrengthDay.Text = "   x 1 Day: " .. utils.formatNumber(sDay)
            tabs.stats.Data.Labels.StrengthWeek.Text = "   x 1 Week: " .. utils.formatNumber(sWeek)

            tabs.stats.Data.Labels.RebirthsGained.Text = "   Gained: " .. utils.formatWithCommas(gainRebirths)
            tabs.stats.Data.Labels.RebirthsHour.Text = "   x 1 Hour: " .. utils.formatWithCommas(rHour)
            tabs.stats.Data.Labels.RebirthsDay.Text = "   x 1 Day: " .. utils.formatWithCommas(rDay)

            tabs.stats.Data.Labels.TiempoSesion.Text = "⏱️ Session: " .. formatTiempo(elapsed)
        end

        task.wait(0.5)
    end
end)

-- =====================================================
-- TAB INFO
-- =====================================================
tabs.info:AddLabel("SLK VORTEX")
tabs.info:AddLabel("Version 8.0")
tabs.info:AddLabel("")
tabs.info:AddLabel("Credits:")
tabs.info:AddLabel("- SLK Team - Owner")
tabs.info:AddLabel("- Based on SilenceScripts")
tabs.info:AddLabel("")
tabs.info:AddLabel("Features:")
tabs.info:AddLabel("✓ Fast Rep (Ping Control)")
tabs.info:AddLabel("✓ Fast Rebirth (Pet Swap)")
tabs.info:AddLabel("✓ Auto Farm / Auto Rep")
tabs.info:AddLabel("✓ Auto Rock / Auto King")
tabs.info:AddLabel("✓ Kill Aura / Kill Everyone")
tabs.info:AddLabel("✓ Size / Speed / FOV")
tabs.info:AddLabel("✓ Anti-Fling / Infinite Jump")
tabs.info:AddLabel("✓ Real-time Stats")

-- =====================================================
-- ANTI-AFK
-- =====================================================
utils.connect(utils.playerData.Player.Idled, function()
    pcall(function()
        services.VirtualUser:CaptureController()
        services.VirtualUser:ClickButton2(Vector2.new(0, 0))
        services.VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
end)

-- =====================================================
-- RESPAWN HANDLER
-- =====================================================
utils.connect(utils.playerData.Player.CharacterAdded, function(character)
    utils.playerData.Character = character
    utils.playerData.Humanoid = character:WaitForChild("Humanoid", 10)
    utils.playerData.Backpack = utils.playerData.Player:WaitForChild("Backpack")
end)

-- =====================================================
-- FINAL
-- =====================================================
tabs.main:Show()

game.StarterGui:SetCore("SendNotification", {
    Title = "SLK VORTEX",
    Text = "✅ Script cargado correctamente",
    Duration = 5
})

print("[SLK VORTEX] Script cargado. Usa RightShift para ocultar el menú.")
