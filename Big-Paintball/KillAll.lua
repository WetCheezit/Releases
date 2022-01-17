-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Character
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

-- Modules
local Library = require(game.ReplicatedStorage.Framework.Library)

local function GetClosest(MaxDistance)
    local Target, TargetCharacter, Closest = nil, nil, MaxDistance or math.huge

    for i,v in pairs(game.Players:GetPlayers()) do
        if (v.Team ~= LocalPlayer.Team or v.Team == nil and v ~= LocalPlayer) then
            if (v.Character and v.Character:FindFirstChild("Head") and Character and Character.HumanoidRootPart and v.Character:FindFirstChild("Humanoid")) then
                if (not v.Character:FindFirstChild("ForceField") and v.Character:WaitForChild("Humanoid") and v.Character.Humanoid.Health > 0) then
                    local Distance = (Character.HumanoidRootPart.Position - v.Character.Head.Position).Magnitude

                    if (Distance < MaxDistance and Distance < Closest) then
                        Target = v
                        TargetCharacter = v.Character
                        Closest = Distance
                    end
                end
            end
        end
    end

    return Target, TargetCharacter
end

local function FireBullet(BulletOrigin)
    -- Generate bullet ID
    local BulletID = Library.Functions.GenerateUID()
    
    if (Character:WaitForChild("Humanoid")) then
        Library.Projectiles.Fire(LocalPlayer, BulletOrigin, BulletID, {}, math.floor(workspace.DistributedGameTime), true)
        Library.Network.Fire("New Projectile", BulletOrigin, BulletID, math.floor(workspace.DistributedGameTime))
    end
end

while task.wait() do
    local Target, TargetCharacter = GetClosest(500)
    Character = LocalPlayer.Character
    
    if (Target and TargetCharacter) then
        if (TargetCharacter.Head) then
            local Hitbox = TargetCharacter.Head
            local BulletTarget = Hitbox.CFrame
            
            for i,v in pairs(Character:GetChildren()) do
                if (v.Name == "HumanoidRootPart" and not v:FindFirstChild("BodyVelocity")) then
                    local BodyVelocity = Instance.new("BodyVelocity", v)
                    
                    BodyVelocity.Velocity = Vector3.new()
                    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    BodyVelocity.P = 1250
                end
                
                if (v.Name == "LowerTorso") then
                    v:Destroy()
                end
                
                if (v:IsA("BasePart") and v.Velocity ~= Vector3.new()) then
                    v.Velocity = Vector3.new()
                end
                
                if (v:IsA("BasePart") and v.CanCollide) then
                    v.CanCollide = false
                end
            end
            
            Character.HumanoidRootPart.CFrame = BulletTarget + Vector3.new(0,5,0)
            FireBullet(BulletTarget)
            task.wait(0.1)
        end
    end
end
