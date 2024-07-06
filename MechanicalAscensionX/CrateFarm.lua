local inf = 1 / 0
local globalEnv = getgenv()

local workspace = game:GetService("Workspace");
local players = game:GetService("Players");
local runService = game:GetService("RunService");
local tweenService = game:GetService("TweenService");

local localPlayer = players.LocalPlayer;
local character = localPlayer.Character;
local humanoidRootPart = character.HumanoidRootPart

local gameDefault = workspace:WaitForChild("Game");
local crates = gameDefault:WaitForChild("Crates");

local function getClosestCrate()
    local target, closest = nil, globalEnv.maxDistance

    for _, crate in next, crates:GetChildren() do
        if (crate) then
            local distance = (humanoidRootPart.Position - crate.Position).Magnitude;

            if (distance < closest) then
                target = crate;
                closest = distance;
            end
        end
    end

    return target, closest;
end

runService.Stepped:Connect(function()
    if (globalEnv.enabled) then
        local crate, distance = getClosestCrate();

        if (crate) then
            local tweenInfo = TweenInfo.new(distance / globalEnv.teleportSpeed, Enum.EasingStyle.Linear);
            local tween = tweenService:Create(humanoidRootPart, tweenInfo, { CFrame = CFrame.new(crate.Position) });

            if (not humanoidRootPart:FindFirstChild("BodyVelocity")) then
                local bodyVelocity = Instance.new("BodyVelocity", humanoidRootPart);

                bodyVelocity.MaxForce = Vector3.new(inf, inf, inf);
                bodyVelocity.Velocity = Vector3.new();
                bodyVelocity.P = 1250
            end

            tween:Play();
        end
    elseif (humanoidRootPart:FindFirstChild("BodyVelocity")) then
        humanoidRootPart:FindFirstChild("BodyVelocity"):Destroy();
    end

    for _, part in next, character:GetChildren() do
        if (part:IsA("BasePart")) then
            part.CanCollide = not globalEnv.enabled;
        end
    end
end)
