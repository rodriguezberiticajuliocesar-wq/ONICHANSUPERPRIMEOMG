-- =====================================================
-- SLK VORTEX - MUSCLE LEGENDS (Version 3.0)
-- Enfoque: Pasar Anticheat (Velocidad Humana)
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

local Window = Rayfield:CreateWindow({
   Name = "SLK VORTEX",
   LoadingTitle = "Cargando SLK VORTEX...",
   LoadingSubtitle = "by SLK Team | Stealth Mode",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SLK_VORTEX",
      FileName = "Config"
   },
   KeySystem = false
})

-- =====================================================
-- PESTAÑA: FARM
-- =====================================================
local FarmTab = Window:CreateTab("Farm", 4483362458)

-- Auto Farm con velocidad controlada (Anti-Kick)
FarmTab:CreateToggle({
   Name = "Auto Farm (Stealth)",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       _G.AutoFarm = Value
       if Value then
           task.spawn(function()
               while _G.AutoFarm do
                   pcall(function()
                       -- Buscamos el evento en la ruta correcta (ReplicatedStorage)
                       local event = RS:FindFirstChild("MuscleEvent") or LP:FindFirstChild("MuscleEvent")
                       if event then
                           -- Se usa una velocidad de 20 reps por segundo aprox.
                           event:FireServer("punch", "leftHand")
                           event:FireServer("punch", "rightHand")
                       end
                   end)
                   task.wait(0.05) -- Velocidad humana sostenible
               end
           end)
       end
   end,
})

-- Fast Reps (Controlado por Slider)
local RepSpeed = 0.05 -- Valor por defecto
FarmTab:CreateSlider({
   Name = "Rep Speed (Menor = Más Rápido)",
   Range = [0.01, 0.5],
   Increment = 0.01,
   Suffix = "s",
   CurrentValue = 0.05,
   Flag = "RepSpeedSlider",
   Callback = function(Value)
       RepSpeed = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Fast Reps ⚡ (Stealth)",
   CurrentValue = false,
   Flag = "FastRepsToggle",
   Callback = function(Value)
       _G.FastRep = Value
       if Value then
           task.spawn(function()
               while _G.FastRep do
                   pcall(function()
                       local event = RS:FindFirstChild("MuscleEvent") or LP:FindFirstChild("MuscleEvent")
                       if event then
                           event:FireServer("punch", "leftHand")
                           event:FireServer("punch", "rightHand")
                       end
                   end)
                   task.wait(RepSpeed) -- Usa la velocidad del slider
               end
           end)
       end
   end,
})

-- =====================================================
-- PESTAÑA: REBIRTH
-- =====================================================
local RebirthTab = Window:CreateTab("Rebirth", 4483362458)

-- Auto Rebirth (Ruta Correcta)
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
                       -- Ruta exacta usada por scripts funcionales
                       local rebirthRemote = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("rebirthRemote")
                       if rebirthRemote then
                           if rebirthRemote:IsA("RemoteFunction") then
                               rebirthRemote:InvokeServer("rebirthRequest")
                           else
                               rebirthRemote:FireServer("rebirthRequest")
                           end
                       end
                   end)
                   task.wait(5) -- Espera larga para no ser detectado
               end
           end)
       end
   end,
})

-- Fast Rebirth (Sin Desequipar Pets)
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
                   task.wait(1.5) -- Más rápido que el auto normal, pero seguro
               end
           end)
       end
   end,
})

-- =====================================================
-- PESTAÑA: PETS
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
InfoTab:CreateParagraph({ Title = "SLK VORTEX", Content = "Versión: 3.0 | Estado: Activo\nModo: Stealth (Anti-Kick)." })

Rayfield:LoadConfiguration()

Rayfield:Notify({
   Title = "SLK VORTEX",
   Content = "Script cargado en Modo Stealth.",
   Duration = 5,
   Image = 4483362458
})
