getgenv().Settings = {
    Fov = 150,
    Hitbox = "Head",
    FovCircle = true,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local function GetClosest(Fov)
    local Target, Closest = nil, math.huge
    
    for i,v in pairs(Players:GetPlayers()) do
        if (v.Name ~= LocalPlayer.Name and v.Character and v.Character.HumanoidRootPart) then
            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            
            if (Distance < Closest) then
                Closest = Distance
                Target = v
            end
        end
    end
    
    return Target
end

local Target
local CircleInline = Drawing.new("Circle")
local CircleOutline = Drawing.new("Circle")
RunService.Stepped:Connect(function()
    CircleInline.Radius = getgenv().Settings.Fov
    CircleInline.Thickness = 2
    CircleInline.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    CircleInline.Transparency = 1
    CircleInline.Color = Color3.fromRGB(255, 255, 255)
    CircleInline.Visible = getgenv().Settings.FovCircle
    CircleInline.ZIndex = 2

    CircleOutline.Radius = getgenv().Settings.Fov
    CircleOutline.Thickness = 4
    CircleOutline.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    CircleOutline.Transparency = 1
    CircleOutline.Color = Color3.new()
    CircleOutline.Visible = getgenv().Settings.FovCircle
    CircleOutline.ZIndex = 1
    
    Target = GetClosest(getgenv().Settings.Fov)
end)

local Old; Old = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if (not checkcaller() and Method == "FireServer") then
        if (Self.Name == "0+.") then
            Args[1].MessageWarning = {}
            Args[1].MessageError = {}
            Args[1].MessageOutput = {}
            Args[1].MessageInfo = {}
        elseif (Self.Name == "RemoteEvent" and Args[2] == "Bullet" and Method == "FireServer") then
            if (Target and Target.Character and Target.Character.Humanoid and Target.Character.Humanoid.Health ~= 0) then
                local Hitbox = Target.Character[getgenv().Settings.Hitbox]
                
                if (Hitbox) then
                    Args[3] = Target.Character
                    Args[4] = Hitbox
                    Args[5] = Hitbox.Position
                end
            end
        end
    end
    
    return Old(Self, unpack(Args))
end)