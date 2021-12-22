-- Player
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character

-- Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Get all zones
local Zones = {}; do
    for i,v in pairs(workspace.Zones:GetChildren()) do
        if (not table.find(Zones, v.Name)) then
            table.insert(Zones, v.Name)
        end
    end
end

-- Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/WetCheezit/UI-Libs/main/uwuware.lua"))()

-- UI
local MainWindow = Library:CreateWindow("Loot Quest")
local AutoFarm = MainWindow:AddFolder("Auto Farm")
local Misc = MainWindow:AddFolder("Miscellaneous")
local Settings = MainWindow:AddFolder("Settings")

AutoFarm:AddToggle({text = "Enabled", flag = "autofarm"})
AutoFarm:AddBox({text = "Target", flag = "target", value = "Bandit"})
AutoFarm:AddList({text = "Zone", flag = "zone", values = Zones})
AutoFarm:AddSlider({text = "Tween speed", flag = "tweenspeed", value = 15, min = 10, max = 17.5, float = 0.1})

Misc:AddToggle({text = "Auto sell", flag = "autosell"})
Misc:AddToggle({text = "Auto fuse swords", flag = "fuseswords"})
Misc:AddToggle({text = "Auto equip best sword", flag = "equipbest"})

Settings:AddBind({text = "Open / Close", key = "RightShift", callback = function() Library:Close() end})
Settings:AddButton({text = "Copy discord invite", callback = function() setclipboard("https://discord.gg/VCSAgMp7bS") end})
Settings:AddLabel({text = "WetCheezit#4345"})

Library:Init()

-- Check alive
local function IsAlive(Player)
    for i,v in pairs(game.Players:GetPlayers()) do
        if (Player == v and v.Character) then
            if (v.Character:FindFirstChildOfClass("Humanoid")) then
                if (v.Character:FindFirstChildOfClass("Humanoid").Health ~= 0 and v.Character:FindFirstChild("HumanoidRootPart")) then
                    return true
                end
            end
        end
    end

    return false
end

-- Get closest enemy
local function GetClosest(Zone, Enemy)
    local Target, Closest = nil, math.huge
    
    for i,v in pairs(workspace.Zones[Zone].Enemies:GetChildren()) do
        if (v.Name == Enemy) then
            if (v:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("HumanoidRootPart") ~= nil and IsAlive(LocalPlayer)) then
                local Distance = (v:FindFirstChild("HumanoidRootPart").Position - Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
                    
                if (Distance < Closest) then
                    Closest = Distance
                    Target = v 
                end
            end
        end
    end
    
    return Target, Closest
end

-- Auto farm
RunService.Stepped:Connect(function()
    Character = LocalPlayer.Character
    
    if (Library.flags.autofarm and Character and IsAlive(LocalPlayer)) then
        local Target, Distance = GetClosest(Library.flags.zone, Library.flags.target)
            
        if (Target and Target.HumanoidRootPart) then
            if (Character.HumanoidRootPart) then
                local TargetPosition = Target.HumanoidRootPart.Position
                local TweenInfo = TweenInfo.new(Distance / Library.flags.tweenspeed, Enum.EasingStyle.Linear)
                    
                if (Character.HumanoidRootPart) then
                    for i,v in pairs(LocalPlayer.Backpack:GetChildren()) do
                        if (v:IsA("Tool")) then
                            if (Character.Humanoid) then
                                Character.Humanoid:EquipTool(v)
                            end
                        end
                    end
                                
                    for i,v in pairs(Character:GetChildren()) do
                        if (v:IsA("Tool")) then
                            v:Activate()
                        end
                    end

                    if (Character.HumanoidRootPart) then
                        local Tween = TweenService:Create(Character:WaitForChild("HumanoidRootPart"), TweenInfo, {
                            CFrame = CFrame.new(TargetPosition.X, TargetPosition.Y, TargetPosition.Z) * CFrame.new(0, 0, 5)
                        })
                        
                        Tween:Play()
                    end
                end
            end
        end
    end
end)

-- Body velocity
RunService.Stepped:Connect(function()
    if (Library.flags.autofarm) then
        if (Character and Character:FindFirstChild("HumanoidRootPart") and IsAlive(LocalPlayer)) then
            local BodyVelocity = Instance.new("BodyVelocity", Character:WaitForChild("HumanoidRootPart"))

            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BodyVelocity.P = 1250
        end
    elseif (Character and not Library.flags.autofarm and Character:FindFirstChild("HumanoidRootPart") and IsAlive(LocalPlayer)) then
        Character:FindFirstChild("HumanoidRootPart"):WaitForChild("BodyVelocity"):Destroy()
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if (Character ~= nil and IsAlive(LocalPlayer)) then
        for i,v in pairs(Character:GetChildren()) do
            if (v:IsA("MeshPart") or v:IsA("BasePart")) then
                if (v) then
                    v.CanCollide = not Library.flags.autofarm
                end
            end
        end
    end
end)

-- Misc
do
    local Values, Swords = {}, {}
    local SwordUtility = require(game.ReplicatedStorage.Utility.SwordUtil)

    while wait(0.1) do
        if (Library.flags.autosell and Character and Character.HumanoidRootPart) then
            firetouchinterest(game:GetService("Workspace").Zones.Forest.Sell, Character.HumanoidRootPart, 0)
            firetouchinterest(game:GetService("Workspace").Zones.Forest.Sell, Character.HumanoidRootPart, 1)
        end

        if (Library.flags.fuseswords) then
            for i,v in pairs(LocalPlayer.PlayerFolder.Swords:GetChildren()) do
                game:GetService("ReplicatedStorage").Remotes.FuseSword:FireServer(v)
            end
        end

        if (Library.flags.equipbest) then
            for i,v in pairs(game.Players.LocalPlayer.PlayerFolder.Swords:GetChildren()) do
                table.insert(Swords, #Values + 1, v)
                table.insert(Values, #Values + 1, SwordUtility.CalculateDamage(v:GetAttributes()))
            end
            
            table.sort(Values, function(a, b)
                return a > b
            end)
            
            for i,v in pairs(game.Players.LocalPlayer.PlayerFolder.Swords:GetChildren()) do
                if (v.Name == tostring(Swords[1])) then
                    game:GetService("ReplicatedStorage").Remotes.EquipSword:InvokeServer(v)
                end
            end
        end
    end
end
