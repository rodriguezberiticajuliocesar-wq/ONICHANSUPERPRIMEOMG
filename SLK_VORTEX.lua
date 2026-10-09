-- =====================================================
-- SLK VORTEX - MUSCLE LEGENDS (Version 3.1)
-- Enfoque: Modo Seguro (Anti-Detección) + Anti-Lag
-- =====================================================

-- ✅ MODO SEGURO ACTIVADO (Lo más importante para no ser detectado)
getgenv().RAYFIELD_SECURE = true

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
local TargetReps = 698
local FrameTime = 1 / TargetReps
local LagCompensation = 0

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
-- PESTAÑA: FARM (CON ANTI-LAG)
-- =====================================================
local FarmTab = Window:CreateTab("Farm", 4483362458)

local function StartFarm()
    local event = RS:FindFirstChild("MuscleEvent") or LP:FindFirstChild("MuscleEvent")
    if not event then return end
    
    while _G.AutoFarm or _G.FastRep do
        local CycleStart = tick()
        
        pcall(function()
            event:FireServer("punch", "leftHand")
            event:FireServer("punch", "rightHand")
        end)
        
        local CycleTime = tick() - CycleStart
        local WaitTime = FrameTime - CycleTime
        
        if CycleTime > FrameTime then
            WaitTime = 0
            LagCompensation = math.min(LagCompensation + 0.0001, 0.01)
        else
            WaitTime = WaitTime + LagCompensation
            LagCompensation = math.max(LagCompensation - 0.00001, 0)
        end
        
        if WaitTime > 0 then
            task.wait(WaitTime)
        end
    end
end

FarmTab:CreateToggle({
   Name = "Auto Farm (Anti-Lag)",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       _G.AutoFarm = Value
       if Value then task.spawn(StartFarm) end
   end,
})

FarmTab:CreateToggle({
   Name = "Fast Reps ⚡ (698 reps/s Anti-Lag)",
   CurrentValue = false,
   Flag = "FastRepsToggle",
   Callback = function(Value)
       _G.FastRep = Value
       if Value then task.spawn(StartFarm) end
   end,
})

FarmTab:CreateSlider({
   Name = "Reps por Segundo (Objetivo)",
   Range = {100, 999},
   Increment = 1,
   Suffix = " reps/s",
   CurrentValue = 698,
   Flag = "RepsSlider",
   Callback = function(Value)
       TargetReps = Value
       FrameTime = 1 / TargetReps
   end,
})

-- =====================================================
-- PESTAÑA: REBIRTH
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
InfoTab:CreateParagraph({ Title = "SLK VORTEX", Content = "Versión: 3.1 | Estado: Activo\nModo: Secure + Anti-Lag." })

Rayfield:LoadConfiguration()

Rayfield:Notify({
   Title = "SLK VORTEX",
   Content = "Script cargado en Modo Seguro.",
   Duration = 5,
   Image = 4483362458
})
