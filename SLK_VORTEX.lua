-- =====================================================
-- SLK VORTEX - MUSCLE LEGENDS (Version 8.1 FINAL)
-- Interfaz: Elerium V2 (desde tu repo)
-- Técnicas: Basadas en SilenceScripts
-- Fast Rebirth Simple (sin tocar mascotas)
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

-- Obtener muscleEvent de forma segura (con espera)
function utils.getMuscleEvent()
    local player = services.Players.LocalPlayer
    local event = player:FindFirstChild("muscleEvent")
    if not event then
        local tries = 0
        repeat
            task.wait(0.1)
            event = player:FindFirstChild("muscleEvent")
            tries = tries + 1
        until event or tries > 100
    end
    return event
end

-- Esperar al evento principal
utils.remotes = {}
utils.remotes.MuscleEvent = utils.getMuscleEvent()

-- Otros remotes con espera segura
function utils.getRemote(parent, name)
    if not parent then return nil end
    local remote = parent:FindFirstChild(name)
    if not remote then
        local tries = 0
        repeat
            task.wait(0.1)
            remote = parent:FindFirstChild(name)
            tries = tries + 1
        until remote or tries > 50
    end
    return remote
end

local rEvents = services.ReplicatedStorage:WaitForChild("rEvents", 30)
utils.remotes.ChangeSpeedSize = rEvents and utils.getRemote(rEvents, "changeSpeedSizeRemote")
utils.remotes.RebirthRemote = rEvents and utils.getRemote(rEvents, "rebirthRemote")
utils.remotes.EquipPetEvent = rEvents and utils.getRemote(rEvents, "equipPetEvent")
utils.remotes.PetEvolveEvent = rEvents and utils.getRemote(rEvents, "petEvolveEvent")
utils.remotes.ShowPetsEvent = rEvents and utils.getRemote(rEvents, "showPetsEvent")
utils.remotes.SavePlayerSizeEvent = rEvents and utils.getRemote(rEvents, "savePlayerSizeEvent")
utils.remotes.GiftRemote = rEvents and utils.getRemote(rEvents, "giftRemote")
utils.remotes.OpenFortuneWheelRemote = rEvents and utils.getRemote(rEvents, "openFortuneWheelRemote")
utils.remotes.PetShopRemote = rEvents and utils.getRemote(rEvents, "cPetShopRemote")

-- Esperar leaderstats
local leaderstats = services.Players.LocalPlayer:WaitForChild("leaderstats", 30)
utils.playerData.Strength = leaderstats and leaderstats:WaitForChild("Strength", 15)
utils.playerData.Rebirths = leaderstats and leaderstats:WaitForChild("Rebirths", 15)
utils.playerData.Durability = services.Players.LocalPlayer:WaitForChild("Durability", 15)

-- =====================================================
-- FUNCIONES DE FORMATO
-- =====================================================
function utils.formatNumber(n)
    if not n or n ~= n then return "0" end
    local absN = math.abs(n)
    local sign = n < 0 and "-" or ""
    if absN >= 1e18 then return sign .. string.format("%.1fqi", absN / 1e18)
    elseif absN >= 1e15 then return sign .. string.format("%.1fqa", absN / 1e15)
    elseif absN >= 1e12 then return sign .. string.format("%.1ft", absN / 1e12)
    elseif absN >= 1e9 then return sign .. string.format("%.1fb", absN / 1e9)
    elseif absN >= 1e6 then return sign .. string.format("%.1fm", absN / 1e6)
    elseif absN >= 1e3 then return sign .. string.format("%.1fk", absN / 1e3)
    else return sign .. tostring(math.floor(absN)) end
end

function utils.formatWithCommas(n)
    n = math.floor(n or 0)
    local formatted = tostring(n)
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
-- CARGAR LIBRERÍA (Elerium V2 desde tu repo)
-- =====================================================
local library_url = "https://raw.githubusercontent.com/rodriguezberiticajuliocesar-wq/SilenceScripts/refs/heads/main/libraries/eleriumv2.luau?cache=" .. tostring(os.time())
local librarySuccess, library = pcall(function()
    return loadstring(game:HttpGet(library_url, true))()
end)

if not librarySuccess or not library then
    game.StarterGui:SetCore("SendNotification", {
        Title = "SLK VORTEX",
        Text = "❌ Error al cargar la interfaz. Verifica tu conexión.",
        Duration = 5
    })
    return
end

utils.library = library

local Window = utils.library:AddWindow("SLK VORTEX", {
    main_color = Color3.fromRGB(120, 0, 255),
    min_size = Vector2.new(800, 600),
    can_resize = true,
    toggle_key = Enum.KeyCode.RightShift
})

-- =====================================================
-- CREAR PESTAÑAS
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
-- TAB MAIN: Ajustes del Jugador
-- =====================================================
tabs.main:AddLabel("⚙️ User Settings:")

tabs.main.Settings = {
    Size = {Value = 2, Enabled = false},
    Speed = {Value = 120, Enabled = false},
    FOV = {Value = 70, Enabled = false}
}

-- SIZE
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
            if utils.remotes.ChangeSpeedSize then
                pcall(function()
                    utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", tabs.main.Settings.Size.Value)
                end)
            end
        end
        task.wait(0.15)
    end
end)

-- SPEED
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
            if utils.remotes.ChangeSpeedSize then
                pcall(function()
                    utils.remotes.ChangeSpeedSize:InvokeServer("changeSpeed", tabs.main.Settings.Speed.Value)
                end)
            end
        end
        task.wait(0.15)
    end
end)

-- FOV
tabs.main:AddTextBox("FOV (1-120):", function(text)
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

function tabs.main.enableAntiFling()
    local char = services.Players.LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local old = root:FindFirstChild("SLK_AntiFling")
    if old then old:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "SLK_AntiFling"
    bv.MaxForce = Vector3.new(100000, 0, 100000)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 1250
    bv.Parent = root
end

function tabs.main.disableAntiFling()
    local char = services.Players.LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bv = root:FindFirstChild("SLK_AntiFling")
    if bv then bv:Destroy() end
end

tabs.main:AddSwitch("Anti Fling", function(bool)
    tabs.main.Protection.AntiFling.Enabled = bool
    if bool then tabs.main.enableAntiFling() else tabs.main.disableAntiFling() end
end)

-- Infinite Jump
_G.SLKInfiniteJump = false
tabs.main:AddSwitch("Infinite Jump", function(bool)
    _G.SLKInfiniteJump = bool
end)

services.UserInputService.JumpRequest:Connect(function()
    if _G.SLKInfiniteJump then
        local char = services.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end
    end
end)

-- Hide Pets
tabs.main:AddSwitch("Hide Pets", function(state)
    if utils.remotes.ShowPetsEvent then
        pcall(function()
            utils.remotes.ShowPetsEvent:FireServer(state and "hidePets" or "showPets")
        end)
    end
end)

-- Change Time
tabs.main.TimeDropdown = tabs.main:AddDropdown("Change Time", function(selection)
    services.Lighting.ClockTime = selection == "Night" and 0 or 9
end)
tabs.main.TimeDropdown:Add("Night")
tabs.main.TimeDropdown:Add("Day")

-- Fortune Wheel
tabs.main.FortuneWheelData = {
    Running = false,
    Generation = 0
}

tabs.main:AddSwitch("Spin Fortune Wheel", function(state)
    tabs.main.FortuneWheelData.Running = state
    tabs.main.FortuneWheelData.Generation += 1
    local gen = tabs.main.FortuneWheelData.Generation

    if not state then return end

    task.spawn(function()
        while tabs.main.FortuneWheelData.Running and tabs.main.FortuneWheelData.Generation == gen do
            local remote = utils.remotes.OpenFortuneWheelRemote
            local shared = services.ReplicatedStorage:FindFirstChild("shared")
            local catalogs = shared and shared:FindFirstChild("catalogs")
            local chances = catalogs and catalogs:FindFirstChild("fortuneWheelChances")
            local wheelChances = chances and chances:FindFirstChild("Fortune Wheel")

            if remote and wheelChances then
                pcall(function()
                    remote:InvokeServer("openFortuneWheel", wheelChances)
                end)
            end
            task.wait(1)
        end
    end)
end)

-- =====================================================
-- TAB FARMING: Auto Rebirth Simple + Auto Rep
-- =====================================================
tabs.farming:AddLabel("🔄 Auto Rebirth (Simple):")

tabs.farming.RebirthData = {
    Label = tabs.farming:AddLabel("Rebirths: 0"),
    TargetLabel = tabs.farming:AddLabel("Target: None"),
    TargetRebirths = 0,
    IsAutoRebirthing = false
}

tabs.farming:AddTextBox("Set Rebirth Target:", function(text)
    if tonumber(text) and tonumber(text) >= 0 then
        tabs.farming.RebirthData.TargetRebirths = tonumber(text)
    end
end)

tabs.farming.RebirthData.Switch = tabs.farming:AddSwitch("Auto Rebirth", function(enabled)
    if enabled and tabs.farming.RebirthData.TargetRebirths > 0 then
        tabs.farming.RebirthData.IsAutoRebirthing = true
        task.spawn(function()
            while tabs.farming.RebirthData.IsAutoRebirthing do
                local currentReb = utils.playerData.Rebirths and utils.playerData.Rebirths.Value or 0
                if currentReb >= tabs.farming.RebirthData.TargetRebirths then
                    tabs.farming.RebirthData.IsAutoRebirthing = false
                    tabs.farming.RebirthData.Switch:Set(false)
                    break
                end
                if utils.remotes.RebirthRemote then
                    pcall(function()
                        utils.remotes.RebirthRemote:InvokeServer("rebirthRequest")
                    end)
                end
                task.wait(0.1)
            end
        end)
    else
        tabs.farming.RebirthData.IsAutoRebirthing = false
    end
end)

task.spawn(function()
    while true do
        if utils.playerData.Rebirths then
            tabs.farming.RebirthData.Label.Text = "Rebirths: " .. utils.formatWithCommas(utils.playerData.Rebirths.Value)
        end
        tabs.farming.RebirthData.TargetLabel.Text = "Target: " .. utils.formatWithCommas(tabs.farming.RebirthData.TargetRebirths)
        task.wait(0.5)
    end
end)

-- Auto Size 1
tabs.farming.SizeData = {Active = false}
tabs.farming.SizeSwitch = tabs.farming:AddSwitch("Auto Size 1", function(bool) tabs.farming.SizeData.Active = bool end)

task.spawn(function()
    while true do
        if tabs.farming.SizeData.Active and utils.playerData.Character and utils.playerData.Humanoid then
            if utils.remotes.ChangeSpeedSize then
                pcall(function()
                    utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", 1)
                end)
            end
        end
        task.wait(0.1)
    end
end)

-- Auto King
tabs.farming.KingData = {TargetPosition = CFrame.new(-8665.4, 17.21, -5792.9), TeleportActive = false}
tabs.farming.KingSwitch = tabs.farming:AddSwitch("Auto King", function(enabled)
    tabs.farming.KingData.TeleportActive = enabled
end)

task.spawn(function()
    while true do
        if tabs.farming.KingData.TeleportActive then
            local char = services.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if (char.HumanoidRootPart.Position - tabs.farming.KingData.TargetPosition.Position).Magnitude > 5 then
                    pcall(function()
                        char.HumanoidRootPart.CFrame = tabs.farming.KingData.TargetPosition
                    end)
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Auto Exercises
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
                local char = services.Players.LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local backpack = services.Players.LocalPlayer:FindFirstChild("Backpack")

                if not char or not hum or hum.Health <= 0 then
                    task.wait(1)
                    continue
                end

                if tabs.farming.ExerciseData.SelectedTool then
                    local toolName = tabs.farming.ExerciseData.SelectedTool
                    if not char:FindFirstChild(toolName) and backpack then
                        local tool = backpack:FindFirstChild(toolName)
                        if tool then
                            pcall(function() hum:EquipTool(tool) end)
                            task.wait(0.2)
                        end
                    end

                    if char:FindFirstChild(toolName) then
                        local muscleEvent = utils.getMuscleEvent()
                        if muscleEvent then
                            pcall(function()
                                muscleEvent:FireServer("rep")
                            end)
                        end
                    end

                    if toolName == "Handstands" and tick() % 6 < 0.1 then
                        pcall(function()
                            services.VirtualUser:CaptureController()
                            services.VirtualUser:ClickButton1(Vector2.new(500, 500))
                        end)
                    end
                end

                task.wait(0.1)
            end
        end)
    end
end)

-- Auto Rep
tabs.farming.AutoRepRunning = false
tabs.farming.AutoRepSwitch = tabs.farming:AddSwitch("Auto Rep", function(state)
    tabs.farming.AutoRepRunning = state
    if not state then return end
    task.spawn(function()
        while tabs.farming.AutoRepRunning do
            local muscleEvent = utils.getMuscleEvent()
            if muscleEvent then
                pcall(function()
                    muscleEvent:FireServer("rep")
                end)
            end
            task.wait(0.1)
        end
    end)
end)

-- Auto Rock
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

tabs.farming.MachinesFolder = services.Workspace:WaitForChild("machinesFolder", 30)

tabs.farming.RockSwitch = tabs.farming:AddSwitch("Auto Rock", function(enabled)
    _G.SLKRockFarm = enabled
    if enabled and tabs.farming.RockData.SelectedRock and tabs.farming.MachinesFolder then
        task.spawn(function()
            while _G.SLKRockFarm do
                task.wait(0.12)
                local durability = utils.playerData.Durability
                if durability and durability.Value >= tabs.farming.RockData.Data[tabs.farming.RockData.SelectedRock] then
                    local char = services.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("LeftHand") then
                        for _, v in pairs(tabs.farming.MachinesFolder:GetDescendants()) do
                            if v.Name == "neededDurability" and v.Value == tabs.farming.RockData.Data[tabs.farming.RockData.SelectedRock] and v.Parent:FindFirstChild("Rock") then
                                pcall(function()
                                    firetouchinterest(v.Parent.Rock, char.RightHand, 0)
                                    firetouchinterest(v.Parent.Rock, char.RightHand, 1)
                                    firetouchinterest(v.Parent.Rock, char.LeftHand, 0)
                                    firetouchinterest(v.Parent.Rock, char.LeftHand, 1)
                                end)
                                local muscleEvent = utils.getMuscleEvent()
                                if muscleEvent then
                                    pcall(function()
                                        muscleEvent:FireServer("punch", "leftHand")
                                        muscleEvent:FireServer("punch", "rightHand")
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- =====================================================
-- TAB FAST: Fast Rep + Fast Rebirth Simple
-- =====================================================
tabs.fast:AddLabel("⚡ Fast Rep (Ping Control):")

tabs.fast.FastRepData = {
    Running = false,
    SendRate = 800,
    CurrentPing = 0,
    LastPingCheck = 0,
    PingControl = true
}

-- Ping con protección por si Stats no está
local networkStats
pcall(function()
    networkStats = services.Stats.Network.ServerStatsItem["Data Ping"]
end)

tabs.fast.FastRepStatus = tabs.fast:AddLabel("Status: Inactive")
tabs.fast.FastRepStatus.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.fast.FastRepWorkerLoop = function()
    while tabs.fast.FastRepData.Running do
        -- Actualizar ping cada 0.5s
        if tick() - tabs.fast.FastRepData.LastPingCheck > 0.5 then
            if networkStats then
                pcall(function()
                    tabs.fast.FastRepData.CurrentPing = networkStats:GetValue()
                end)
            end
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

        -- Enviar reps (batch por frame)
        local repsToSend = math.floor(tabs.fast.FastRepData.SendRate / 60)
        if repsToSend < 1 then repsToSend = 1 end
        if repsToSend > 12 then repsToSend = 12 end

        local muscleEvent = utils.getMuscleEvent()
        if muscleEvent then
            for i = 1, repsToSend do
                pcall(function()
                    muscleEvent:FireServer("rep")
                end)
            end
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
-- FAST REBIRTH SIMPLE (Sin tocar mascotas)
-- =====================================================
tabs.fast:AddLabel("🔄 Fast Rebirth (Simple):")

tabs.fast.FastRebirthData = {
    Running = false,
    TargetRebirths = 0,
    TotalRebirths = 0,
    RepsPerBurst = 12,
    RepDelay = 0.05
}

tabs.fast.FastRebirthStatus = tabs.fast:AddLabel("Status: Inactive")
tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.fast.FastRebirthStats = tabs.fast:AddLabel("Rebirths: 0 | Gained: 0")

tabs.fast.FastRebirthWorker = function()
    local startRebirths = utils.playerData.Rebirths and utils.playerData.Rebirths.Value or 0

    while tabs.fast.FastRebirthData.Running do
        local currentReb = utils.playerData.Rebirths and utils.playerData.Rebirths.Value or 0

        -- Verificar target alcanzado
        if tabs.fast.FastRebirthData.TargetRebirths > 0
            and currentReb >= tabs.fast.FastRebirthData.TargetRebirths then
            tabs.fast.FastRebirthStatus.Text = "Status: ✅ Target alcanzado"
            tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
            tabs.fast.FastRebirthData.Running = false
            break
        end

        -- Calcular fuerza necesaria para el próximo rebirth
        local targetStrength = 5000 + currentReb * 2550
        local currentStrength = utils.playerData.Strength and utils.playerData.Strength.Value or 0

        -- Si ya tenemos la fuerza, hacer rebirth
        if currentStrength >= targetStrength then
            tabs.fast.FastRebirthStatus.Text = "Status: 🔄 Haciendo Rebirth..."
            tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 200, 80)

            local rebirthBefore = utils.playerData.Rebirths and utils.playerData.Rebirths.Value or 0
            local attempts = 0

            repeat
                if utils.remotes.RebirthRemote then
                    pcall(function()
                        utils.remotes.RebirthRemote:InvokeServer("rebirthRequest")
                    end)
                end
                task.wait(0.05)
                attempts = attempts + 1
            until not tabs.fast.FastRebirthData.Running
                or (utils.playerData.Rebirths and utils.playerData.Rebirths.Value > rebirthBefore)
                or attempts >= 30

            if utils.playerData.Rebirths and utils.playerData.Rebirths.Value > rebirthBefore then
                tabs.fast.FastRebirthData.TotalRebirths = tabs.fast.FastRebirthData.TotalRebirths +
                    (utils.playerData.Rebirths.Value - rebirthBefore)
            end

            task.wait(0.5)
        else
            -- Farmear fuerza (sin tocar mascotas)
            tabs.fast.FastRebirthStatus.Text = "Status: 💪 Farmeando... "
                .. utils.formatNumber(currentStrength)
                .. " / " .. utils.formatNumber(targetStrength)
            tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(80, 255, 120)

            local muscleEvent = utils.getMuscleEvent()
            if muscleEvent then
                for i = 1, tabs.fast.FastRebirthData.RepsPerBurst do
                    pcall(function()
                        muscleEvent:FireServer("rep")
                    end)
                end
            end

            task.wait(tabs.fast.FastRebirthData.RepDelay)
        end

        -- Actualizar stats
        tabs.fast.FastRebirthStats.Text = "Rebirths: "
            .. utils.formatWithCommas(utils.playerData.Rebirths and utils.playerData.Rebirths.Value or 0)
            .. " | Gained: "
            .. utils.formatWithCommas((utils.playerData.Rebirths and utils.playerData.Rebirths.Value or 0) - startRebirths)
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

tabs.fast:AddLabel("Farmea + Rebirth sin tocar tus mascotas")

-- =====================================================
-- TAB KILLING: Kill Aura + Kill Everyone
-- =====================================================
tabs.killing:AddLabel("⚔️ Kill Aura:")

_G.SLKWhitelisted = _G.SLKWhitelisted or {}

function tabs.killing.isWhitelisted(player)
    for _, name in ipairs(_G.SLKWhitelisted) do
        if name:lower() == player.Name:lower() then return true end
    end
    return false
end

function tabs.killing.isPlayerAlive(player)
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
        player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

function tabs.killing.attackPlayer(target)
    if not tabs.killing.isPlayerAlive(target) or tabs.killing.isWhitelisted(target) then return end

    local char = services.Players.LocalPlayer.Character
    if not char then return end

    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = char:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then return end

    localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3.5, 0)
    localRoot.AssemblyLinearVelocity = Vector3.zero
    localRoot.AssemblyAngularVelocity = Vector3.zero

    services.RunService.Heartbeat:Wait()

    local hand = char:FindFirstChild("LeftHand") or char:FindFirstChild("RightHand")
    if not hand then return end

    pcall(function()
        firetouchinterest(targetRoot, hand, 0)
        firetouchinterest(targetRoot, hand, 1)
    end)

    local muscleEvent = utils.getMuscleEvent()
    if muscleEvent then
        pcall(function()
            muscleEvent:FireServer("punch", hand.Name == "LeftHand" and "leftHand" or "rightHand")
        end)
    end
end

tabs.killing.KillAuraRunning = false

tabs.killing:AddSwitch("Kill Aura (Auto Attack)", function(state)
    tabs.killing.KillAuraRunning = state
    if not state then return end

    task.spawn(function()
        while tabs.killing.KillAuraRunning do
            for _, player in ipairs(services.Players:GetPlayers()) do
                if player ~= services.Players.LocalPlayer and tabs.killing.isPlayerAlive(player) and not tabs.killing.isWhitelisted(player) then
                    pcall(function()
                        tabs.killing.attackPlayer(player)
                    end)
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
                if player ~= services.Players.LocalPlayer and not tabs.killing.isWhitelisted(player) and tabs.killing.isPlayerAlive(player) then
                    for _ = 1, 4 do
                        pcall(function()
                            tabs.killing.attackPlayer(player)
                        end)
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

function tabs.killing.updateWhitelistLabel()
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
    if player ~= services.Players.LocalPlayer then
        tabs.killing.WhitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end

utils.connect(services.Players.PlayerAdded, function(player)
    if player ~= services.Players.LocalPlayer then
        tabs.killing.WhitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end)

tabs.killing:AddButton("Clear Whitelist", function()
    _G.SLKWhitelisted = {}
    tabs.killing.updateWhitelistLabel()
end)

-- =====================================================
-- TAB STATS: Métricas en Tiempo Real
-- =====================================================
tabs.stats.Data = {
    StartTime = tick(),
    StartStrength = utils.playerData.Strength and utils.playerData.Strength.Value or 0,
    StartRebirths = utils.playerData.Rebirths and utils.playerData.Rebirths.Value or 0,
    Labels = {}
}

function tabs.stats.formatTiempo(segundos)
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

        if elapsed > 0.5 and utils.playerData.Strength and utils.playerData.Rebirths then
            local currentStrength = utils.playerData.Strength.Value
            local currentRebirths = utils.playerData.Rebirths.Value

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

            tabs.stats.Data.Labels.TiempoSesion.Text = "⏱️ Session: " .. tabs.stats.formatTiempo(elapsed)
        end

        task.wait(0.5)
    end
end)

-- =====================================================
-- TAB INFO
-- =====================================================
tabs.info:AddLabel("SLK VORTEX")
tabs.info:AddLabel("Version 8.1 FINAL")
tabs.info:AddLabel("")
tabs.info:AddLabel("Features:")
tabs.info:AddLabel("✓ Fast Rep (Ping Control)")
tabs.info:AddLabel("✓ Fast Rebirth (Simple - No Pet Swap)")
tabs.info:AddLabel("✓ Auto Rebirth / Auto Rep")
tabs.info:AddLabel("✓ Auto Rock / Auto King / Auto Exercises")
tabs.info:AddLabel("✓ Kill Aura / Kill Everyone")
tabs.info:AddLabel("✓ Size / Speed / FOV")
tabs.info:AddLabel("✓ Anti-Fling / Infinite Jump")
tabs.info:AddLabel("✓ Real-time Stats")
tabs.info:AddLabel("")
tabs.info:AddLabel("Credits:")
tabs.info:AddLabel("- SLK Team - Owner")
tabs.info:AddLabel("- Based on SilenceScripts")

-- =====================================================
-- ANTI-AFK
-- =====================================================
utils.connect(services.Players.LocalPlayer.Idled, function()
    pcall(function()
        services.VirtualUser:CaptureController()
        services.VirtualUser:ClickButton2(Vector2.new(0, 0))
        services.VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
end)

-- =====================================================
-- RESPAWN HANDLER
-- =====================================================
utils.connect(services.Players.LocalPlayer.CharacterAdded, function(character)
    utils.playerData.Character = character
    utils.playerData.Humanoid = character:WaitForChild("Humanoid", 10)
    utils.playerData.Backpack = services.Players.LocalPlayer:WaitForChild("Backpack")

    -- Re-obtener muscleEvent por si acaso
    task.wait(1)
    utils.remotes.MuscleEvent = utils.getMuscleEvent()

    -- Reactivar Anti-Fling si estaba activo
    if tabs.main and tabs.main.Protection and tabs.main.Protection.AntiFling.Enabled then
        task.wait(1)
        tabs.main.enableAntiFling()
    end
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

print("[SLK VORTEX] Cargado. RightShift para ocultar el menú.")
