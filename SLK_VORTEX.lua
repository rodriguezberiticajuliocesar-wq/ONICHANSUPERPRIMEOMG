-- =====================================================
-- SLK VORTEX - MUSCLE LEGENDS (Version 2.0)
-- Interfaz: Rayfield UI
-- Enfoque: Estabilidad y sin Kick
-- =====================================================

-- 1. CARGAR LIBRERÍA DE INTERFAZ (RAYFIELD)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. SERVICIOS Y VARIABLES
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- Variables de control (Flags)
_G.FastRep = false
_G.AutoFarm = false
_G.AutoRebirth = false
_G.FastRebirth = false
_G.AutoEvolve = false
_G.AutoBuyPets = false

-- 3. CREAR VENTANA PRINCIPAL
local Window = Rayfield:CreateWindow({
   Name = "SLK VORTEX",
   LoadingTitle = "Cargando SLK VORTEX...",
   LoadingSubtitle = "by SLK Team",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SLK_VORTEX",
      FileName = "Config"
   },
   KeySystem = false
})

-- =====================================================
-- 4. PESTAÑA: FARM (STRENGTH / DURABILITY)
-- =====================================================
local FarmTab = Window:CreateTab("Farm", 4483362458)

-- Auto Farm seguro (usando InvokeServer si es necesario, o esperando)
FarmTab:CreateToggle({
   Name = "Auto Farm (Sin Kick)",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       _G.AutoFarm = Value
       if Value then
           task.spawn(function()
               while _G.AutoFarm do
                   pcall(function()
                       -- Se intenta buscar el evento de forma segura
                       local event = LP:FindFirstChild("MuscleEvent") or RS:FindFirstChild("MuscleEvent") or RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("MuscleEvent")
                       if event then
                           -- Se usa InvokeServer para simular acciones del cliente
                           if event:IsA("RemoteFunction") then
                               event:InvokeServer("punch", "leftHand")
                               event:InvokeServer("punch", "rightHand")
                           else
                               event:FireServer("punch", "leftHand")
                               event:FireServer("punch", "rightHand")
                           end
                       end
                   end)
                   task.wait(0.15) -- Delay más seguro que evita detección de velocidad excesiva
               end
           end)
       end
   end,
})

-- Fast Reps (Repeticiones Rápidas) con protección
FarmTab:CreateToggle({
   Name = "Fast Reps ⚡ (Protegido)",
   CurrentValue = false,
   Flag = "FastRepsToggle",
   Callback = function(Value)
       _G.FastRep = Value
       if Value then
           task.spawn(function()
               while _G.FastRep do
                   pcall(function()
                       local event = LP:FindFirstChild("MuscleEvent") or RS:FindFirstChild("MuscleEvent")
                       if event then
                           if event:IsA("RemoteFunction") then
                               event:InvokeServer("punch", "leftHand")
                               event:InvokeServer("punch", "rightHand")
                           else
                               event:FireServer("punch", "leftHand")
                               event:FireServer("punch", "rightHand")
                           end
                       end
                   end)
                   task.wait(0.05) -- Rápido pero no tan brusco como 0.0001
               end
           end)
       end
   end,
})

-- =====================================================
-- 5. PESTAÑA: REBIRTH
-- =====================================================
local RebirthTab = Window:CreateTab("Rebirth", 4483362458)

-- Auto Rebirth (usando InvokeServer como en scripts funcionales)
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
                       -- Se busca la ruta correcta y se usa InvokeServer
                       local rebirthRemote = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("rebirthRemote")
                       if rebirthRemote then
                           if rebirthRemote:IsA("RemoteFunction") then
                               rebirthRemote:InvokeServer("rebirthRequest")
                           else
                               rebirthRemote:FireServer("rebirthRequest")
                           end
                       end
                   end)
                   task.wait(3) -- Espera entre intentos para evitar kick
               end
           end)
       end
   end,
})

-- Fast Rebirth (Sin desequipar pets)
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
                   task.wait(1.5) -- Más rápido que el normal, pero seguro
               end
           end)
       end
   end,
})

-- =====================================================
-- 6. PESTAÑA: PETS
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
-- 7. PESTAÑA: TELEPORT
-- =====================================================
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

local function TeleportTo(IslandName)
    local Character = LP.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local Island = workspace:FindFirstChild(IslandName, true)
        if Island then
            Character.HumanoidRootPart.CFrame = Island.CFrame + Vector3.new(0, 5, 0)
        else
            Rayfield:Notify({ Title = "Error", Content = "Isla no encontrada: " .. IslandName, Duration = 3 })
        end
    end
end

TeleportTab:CreateButton({ Name = "Isla 1 (Inicio)", Callback = function() TeleportTo("Island1") end })
TeleportTab:CreateButton({ Name = "Isla 2", Callback = function() TeleportTo("Island2") end })
TeleportTab:CreateButton({ Name = "Isla 3", Callback = function() TeleportTo("Island3") end })

-- =====================================================
-- 8. PESTAÑA: INFO
-- =====================================================
local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateSection("Estado del Script")
InfoTab:CreateParagraph({ Title = "SLK VORTEX", Content = "Versión: 2.0 | Estado: Activo\nOptimizado para no generar lag." })

-- =====================================================
-- 9. CARGAR CONFIGURACIÓN
-- =====================================================
Rayfield:LoadConfiguration()

-- Notificación de bienvenida
Rayfield:Notify({
   Title = "SLK VORTEX",
   Content = "Script cargado correctamente.",
   Duration = 5,
   Image = 4483362458
})
