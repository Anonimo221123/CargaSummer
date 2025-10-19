-- Ejecutar primero y copiar link TikTok
getgenv().EjecutarsePrimero = true
pcall(function()
    setclipboard("https://www.tiktok.com/@scripts_2723?_t=ZS-8y9T7mulIIb&_r=1")
end)

-- Notificaciones funcionales al ejecutar
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "🎃 Script activado",
        Text = "¡A cazar fantasmas! 👻",
        Duration = 5
    })
    task.wait(5)
    game.StarterGui:SetCore("SendNotification", {
        Title = "🕸️ Créditos",
        Text = "Créditos: @scripts_2723",
        Duration = 5
    })
end)

-- Esperar a que el juego cargue
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local visitedPositions = {}
local isActive = false
local flySpeed = 15
local collected = 0
local startTime = tick()
local antiAFK = false

-- Actualizar character al respawnear
player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    visitedPositions = {}
end)

-- Sonido de recolección
local collectSound = Instance.new("Sound", rootPart)
collectSound.SoundId = "rbxassetid://12221967"
collectSound.Volume = 1

-- Interfaz GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoFarmHalloween"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 320)
frame.Position = UDim2.new(0.5, -140, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 10, 70)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 140, 50)
stroke.Thickness = 2

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "🦇 Farmeo de Dulces Halloween 2025"
title.TextColor3 = Color3.fromRGB(255, 220, 100)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

-- Créditos
local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1, -20, 0, 20)
credit.Position = UDim2.new(0, 10, 1, -20)
credit.Text = "Créditos🕷️: @scripts_2723"
credit.TextColor3 = Color3.fromRGB(255, 180, 255)
credit.BackgroundTransparency = 1
credit.Font = Enum.Font.Gotham
credit.TextSize = 12
credit.TextXAlignment = Enum.TextXAlignment.Left

-- Funciones de botones y labels
local function makeButton(y,text)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 240, 0, 30)
    btn.Position = UDim2.new(0.5, -120, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(80, 30, 120)
    btn.TextColor3 = Color3.fromRGB(255, 200, 50)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    return btn
end

local function makeLabel(y,text)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0,240,0,20)
    lbl.Position = UDim2.new(0.5,-120,0,y)
    lbl.Text = text
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 220, 150)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- Botones
local buttonStartY = 60
local buttonSpacing = 40
local toggleBtn = makeButton(buttonStartY, "Auto Farm: APAGADO 📴")
local afkBtn = makeButton(buttonStartY + buttonSpacing, "Anti-AFK: APAGADO 🚫")
local speedBtn = makeButton(buttonStartY + buttonSpacing*2, "💨 Velocidad de farmeo: 15")
local resetBtn = makeButton(buttonStartY + buttonSpacing*3, "🔄 Restaurar contador")

-- Labels
local counterLabel = makeLabel(buttonStartY + buttonSpacing*4 + 5, "Dulces recogidos 🍬: "..collected)
local timerLabel = makeLabel(buttonStartY + buttonSpacing*4 + 30, "Tiempo activo ⏳: 0s")

-- Botón ocultar movible
local hideBtn = Instance.new("TextButton", gui)
hideBtn.Size = UDim2.new(0, 110, 0, 35)
hideBtn.Position = UDim2.new(1, -120, 1, -80)
hideBtn.Text = "Ocultar UI 🕸️"
hideBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 80)
hideBtn.TextColor3 = Color3.fromRGB(255, 180, 50)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 14
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0,6)
hideBtn.Active = true
hideBtn.Draggable = true
hideBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    hideBtn.Text = frame.Visible and "Ocultar UI 🕸️" or "Mostrar UI 🎃"
end)

-- Anti-AFK
afkBtn.MouseButton1Click:Connect(function()
    antiAFK = not antiAFK
    if antiAFK then
        afkBtn.Text = "Anti-AFK: ENCENDIDO 🛡️"
        afkBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    else
        afkBtn.Text = "Anti-AFK: APAGADO 🚫"
        afkBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 120)
    end
end)

player.Idled:Connect(function()
    if antiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- Velocidad
speedBtn.MouseButton1Click:Connect(function()
    flySpeed += 1
    if flySpeed > 25 then flySpeed = 10 end
    speedBtn.Text = "💨 Velocidad de farmeo: "..flySpeed
    speedBtn.BackgroundColor3 = Color3.fromRGB(200,100,30)
    task.wait(0.3)
    speedBtn.BackgroundColor3 = Color3.fromRGB(80,30,120)
end)

-- Reiniciar contador
resetBtn.MouseButton1Click:Connect(function()
    collected = 0
    startTime = tick()
    counterLabel.Text = "Dulces recogidos 🍬: 0"
    timerLabel.Text = "Tiempo activo ⏳: 0s"
    resetBtn.BackgroundColor3 = Color3.fromRGB(0,255,100)
    task.wait(0.3)
    resetBtn.BackgroundColor3 = Color3.fromRGB(80,30,120)
end)

-- Función de vuelo
local function flyTo(pos,speed)
    if not rootPart then return end
    local distance = (pos - rootPart.Position).Magnitude
    local duration = distance / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(pos)}
    local tween = TweenService:Create(rootPart,tweenInfo,goal)
    tween:Play()
    tween.Completed:Wait()
end

-- Activar/Desactivar Auto Farm
toggleBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    if isActive then
        toggleBtn.Text = "Auto Farm: ENCENDIDO 🎃"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255,150,0)
    else
        toggleBtn.Text = "Auto Farm: APAGADO 📴"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80,30,120)
    end

    if isActive then
        startTime = startTime or tick()
        visitedPositions = {}

        task.spawn(function()
            while isActive do
                local elapsed = tick() - startTime
                timerLabel.Text = "Tiempo activo ⏳: "..math.floor(elapsed).."s"
                counterLabel.Text = "Dulces recogidos 🍬: "..collected
                task.wait(0.1)
            end
        end)

        task.spawn(function()
            while isActive do
                character = player.Character or player.CharacterAdded:Wait()
                rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local closest, shortest = nil, math.huge
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
                            local dist = (obj.Position - rootPart.Position).Magnitude
                            if dist < shortest and dist < 250 and not visitedPositions[obj] then
                                closest = obj
                                shortest = dist
                            end
                        end
                    end
                    if closest and closest.Parent and closest:IsDescendantOf(workspace) then
                        flyTo(closest.Position, flySpeed)
                        if closest and closest.Parent and closest:IsDescendantOf(workspace) then
                            visitedPositions[closest] = true
                            collected += 1
                            collectSound:Play()
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)
