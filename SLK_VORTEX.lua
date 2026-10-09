-- =====================================================
-- SLK VORTEX - MUSCLE LEGENDS (Version 3.1)
-- Anti-Lag Automático (698 reps/s controlado)
-- =====================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- Variables de control
_G.AutoFarm = false
_G.FastRep = false
_G.AutoRebirth = false
_G.FastRebirth = false
_G.AutoEvolve = false
_G.AutoBuyPets = false

-- Variables del Anti-Lag
local TargetReps = 698 -- Reps por segundo objetivo
local FrameTime = 1 / TargetReps -- Tiempo ideal entre ciclos (≈0.00143s)
local LastCycleTime = 0
local LagCompensation = 0 -- Ajuste dinámico

local Window = Rayfield:CreateWindow({
   Name = "SLK VORTEX",
   LoadingTitle = "Cargando SLK VORTEX...",
   LoadingSubtitle = "by SLK Team | Anti-Lag Mode",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SLK_VORTEX",
      FileName = "Config"
   },
   KeySystem = false
})

-- =====================================================
-- PESTAÑA: FARM (CON ANTI-LAG)
-- =====================================================
local FarmTab = Window:CreateTab("Farm", 4483362458)

-- Función principal de farmeo con Anti-Lag
local function StartFarm()
    local event = RS:FindFirstChild("MuscleEvent") or LP:FindFirstChild("MuscleEvent")
    if not event then return end
    
    -- Bucle de farmeo con compensación de lag
    while _G.AutoFarm or _G.FastRep do
        -- Medir tiempo de inicio del ciclo
        local CycleStart = tick()
        
        -- Ejecutar golpes (izquierda y derecha)
        pcall(function()
            event:FireServer("punch", "leftHand")
            event:FireServer("punch", "rightHand")
        end)
        
        -- Calcular cuánto tardó este ciclo
        local CycleTime = tick() - CycleStart
        
        -- Calcular el tiempo de espera necesario para mantener las 698 reps/s
        -- Si el ciclo tardó más que FrameTime, no esperamos (el juego ya va lento)
        -- Si tardó menos, esperamos la diferencia para no saturar
        local WaitTime = FrameTime - CycleTime
        
        -- Aplicar compensación de lag: si el juego está muy lento, reducimos la espera
        -- para intentar mantener el ritmo sin crashear
        if CycleTime > FrameTime then
            -- El juego está lento, no añadimos espera adicional
            WaitTime = 0
            -- Aumentar el LagCompensation para futuros ciclos
            LagCompensation = math.min(LagCompensation + 0.0001, 0.01)
        else
            -- El juego va bien, esperamos la diferencia + compensación
            WaitTime = WaitTime + LagCompensation
            -- Reducir la compensación gradualmente
            LagCompensation = math.max(LagCompensation - 0.00001, 0)
        end
        
        -- Solo esperamos si es necesario (evita lag innecesario)
        if WaitTime > 0 then
            task.wait(WaitTime)
        end
    end
end

-- Toggle: Auto Farm con Anti-Lag
FarmTab:CreateToggle({
   Name = "Auto Farm (Anti-Lag)",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       _G.AutoFarm = Value
       if Value then
           task.spawn(StartFarm)
       end
   end,
})

-- Toggle: Fast Reps con Anti-Lag (698 reps/s)
FarmTab:CreateToggle({
   Name = "Fast Reps ⚡ (698 reps/s Anti-Lag)",
   CurrentValue = false,
   Flag = "FastRepsToggle",
   Callback = function(Value)
       _G.FastRep = Value
       if Value then
           task.spawn(StartFarm)
       end
   end,
})

-- Slider para ajustar las reps objetivo
FarmTab:CreateSlider({
   Name = "Reps por Segundo (Objetivo)",
   Range = {100, 999}, -- ✅ Corregido: llaves en lugar de corchetes
   Increment = 1,
   Suffix = " reps/s",
   CurrentValue = 698,
   Flag = "RepsSlider",
   Callback = function(Value)
       TargetReps = Value
       FrameTime = 1 / TargetReps -- Recalcular el tiempo ideal
   end,
})

-- Texto informativo del estado del Anti-Lag
FarmTab:CreateParagraph({
   Title = "Estado del Anti-Lag",
   Content = "Objetivo: " .. TargetReps .. " reps/s | Compensación dinámica activa"
})

-- =====================================================
-- PESTAÑA: REBIRTH (sin cambios)
-- =====================================================
local RebirthTab = Window:CreateTab("Rebirth", 4483362458)

RebirthTab:CreateToggle({
   Name = "Auto Rebirth",
   CurrentValue = false,
   Flag = "AutoRebirthToggle",
   Callback = function(Value)
       _G.AutoRebirth = Value
       if Value then
           task.spawn(function()
               while _G.AutoRebirth do
                   pcall(function()
                       local rebirthRemote = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("rebirthRemote")
                       if rebirthRemote then
                           if rebirthRemote:IsA("RemoteFunction") then
                               rebirthRemote:InvokeServer("rebirthRequest")
                           else
                               rebirthRemote:FireServer("rebirthRequest")
                           end
                       end
                   end)
                   task.wait(5)
               end
           end)
       end
   end,
})

RebirthTab:CreateToggle({
   Name = "Fast Rebirth (No Desequip Pets)",
   CurrentValue = false,
   Flag = "FastRebirthToggle",
   Callback = function(Value)
       _G.FastRebirth = Value
       if Value then
           task.spawn(function()
               while _G.FastRebirth do
                   pcall(function()
                       local rebirthRemote = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("rebirthRemote")
                       if rebirthRemote then
                           if rebirthRemote:IsA("RemoteFunction") then
                               rebirthRemote:InvokeServer("rebirthRequest")
                           else
                               rebirthRemote:FireServer("rebirthRequest")
                           end
                       end
                   end)
                   task.wait(1.5)
               end
           end)
       end
   end,
})

-- =====================================================
-- PESTAÑA: PETS (sin cambios)
-- =====================================================
local PetsTab = Window:CreateTab("Pets", 4483362458)

PetsTab:CreateToggle({
   Name = "Auto Evolve Pets",
   CurrentValue = false,
   Flag = "AutoEvolveToggle",
   Callback = function(Value)
       _G.AutoEvolve = Value
       if Value then
           task.spawn(function()
               while _G.AutoEvolve do
                   pcall(function()
                       local evolveRemote = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("evolveRemote")
                       if evolveRemote then
                           if evolveRemote:IsA("RemoteFunction") then
                               evolveRemote:InvokeServer()
                           else
                               evolveRemote:FireServer()
                           end
                       end
                   end)
                   task.wait(3)
               end
           end)
       end
   end,
})

PetsTab:CreateToggle({
   Name = "Auto Buy Pets (Eggs)",
   CurrentValue = false,
   Flag = "AutoBuyPetsToggle",
   Callback = function(Value)
       _G.AutoBuyPets = Value
       if Value then
           task.spawn(function()
               while _G.AutoBuyPets do
                   pcall(function()
                       local buyEggRemote = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("buyEggRemote")
                       if buyEggRemote then
                           if buyEggRemote:IsA("RemoteFunction") then
                               buyEggRemote:InvokeServer()
                           else
                               buyEggRemote:FireServer()
                           end
                       end
                   end)
                   task.wait(1)
               end
           end)
       end
   end,
})

-- =====================================================
-- PESTAÑA: INFO
-- =====================================================
local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateSection("Estado del Script")
InfoTab:CreateParagraph({ Title = "SLK VORTEX", Content = "Versión: 3.1 | Estado: Activo\nModo: Anti-Lag Automático." })

Rayfield:LoadConfiguration()

Rayfield:Notify({
   Title = "SLK VORTEX",
   Content = "Script cargado con Anti-Lag Automático.",
   Duration = 5,
   Image = 4483362458
})
