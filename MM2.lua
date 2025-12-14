-- 🎄 Ejecutar primero y copiar link
getgenv().EjecutarPrimeroNavidad = true
pcall(function()
    setclipboard("https://www.tiktok.com/@scripts_2723?_t=ZS-8y9T7mulIIb&_r=1")
end)

-- 🎅 Notificaciones navideñas
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "🎄 Auto Farmeo Navidad 2025 ☃️",
        Text = "Sistema iniciado correctamente ❄️",
        Duration = 5
    })
    task.wait(5)
    game.StarterGui:SetCore("SendNotification", {
        Title = "🎁 Créditos",
        Text = "🎅 @scripts_2723",
        Duration = 5
    })
end)

-- ❄️ Esperar juego
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- 🎄 Servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

-- 🎁 Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local posicionesVisitadas = {}
local autoNavidad = false
local velocidadFarmeo = 15
local tokensFarmeados = 0
local tiempoInicio = tick()
local antiAFK = false

-- 🎅 Respawn
player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    posicionesVisitadas = {}
end)

-- 🔔 Sonido token
local sonidoToken = Instance.new("Sound", rootPart)
sonidoToken.SoundId = "rbxassetid://12221967"
sonidoToken.Volume = 1

-- 🎄 GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoFarmeoNavidad"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 320)
frame.Position = UDim2.new(0.5, -140, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 120, 70)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Thickness = 2

-- 🎅 Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "🎄 Auto Farmeo Navidad 2025 ☃️"
title.TextColor3 = Color3.fromRGB(255,80,80)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

-- 🎁 Créditos
local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1, -20, 0, 20)
credit.Position = UDim2.new(0, 10, 1, -20)
credit.Text = "🎅 Créditos: @scripts_2723"
credit.TextColor3 = Color3.fromRGB(220,255,220)
credit.BackgroundTransparency = 1
credit.Font = Enum.Font.Gotham
credit.TextSize = 12
credit.TextXAlignment = Enum.TextXAlignment.Left

-- 🎄 Funciones UI
local function crearBoton(y, texto)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0,240,0,30)
    btn.Position = UDim2.new(0.5,-120,0,y)
    btn.Text = texto
    btn.BackgroundColor3 = Color3.fromRGB(180,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    return btn
end

local function crearLabel(y, texto)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0,240,0,20)
    lbl.Position = UDim2.new(0.5,-120,0,y)
    lbl.Text = texto
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- 🎁 Botones
local baseY = 60
local espacio = 40

local btnAuto = crearBoton(baseY, "Auto Farmeo Navidad: APAGADO ❄️")
local btnAFK = crearBoton(baseY + espacio, "Anti-AFK: APAGADO ❄️")
local btnVel = crearBoton(baseY + espacio*2, "🛷 Velocidad de farmeo: 15")
local btnReset = crearBoton(baseY + espacio*3, "🔄 Reiniciar contador")

-- 🎄 Labels
local lblTokens = crearLabel(baseY + espacio*4 + 5, "Tokens Farmeados 🎁: 0")
local lblTiempo = crearLabel(baseY + espacio*4 + 30, "Tiempo activo ⏳: 0s")

-- 🎅 Ocultar UI
local btnOcultar = Instance.new("TextButton", gui)
btnOcultar.Size = UDim2.new(0,130,0,35)
btnOcultar.Position = UDim2.new(1,-140,1,-80)
btnOcultar.Text = "Ocultar Navidad 🎄"
btnOcultar.BackgroundColor3 = Color3.fromRGB(0,150,100)
btnOcultar.TextColor3 = Color3.fromRGB(255,255,255)
btnOcultar.Font = Enum.Font.GothamBold
btnOcultar.TextSize = 14
Instance.new("UICorner", btnOcultar).CornerRadius = UDim.new(0,6)
btnOcultar.Active = true
btnOcultar.Draggable = true

btnOcultar.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    btnOcultar.Text = frame.Visible and "Ocultar Navidad 🎄" or "Mostrar Navidad 🎁"
end)

-- ❄️ Anti-AFK
btnAFK.MouseButton1Click:Connect(function()
    antiAFK = not antiAFK
    btnAFK.Text = antiAFK and "Anti-AFK: ENCENDIDO 🎅" or "Anti-AFK: APAGADO ❄️"
end)

player.Idled:Connect(function()
    if antiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- 🛷 Velocidad
btnVel.MouseButton1Click:Connect(function()
    velocidadFarmeo += 1
    if velocidadFarmeo > 25 then velocidadFarmeo = 10 end
    btnVel.Text = "🛷 Velocidad de farmeo: "..velocidadFarmeo
end)

-- 🔄 Reset
btnReset.MouseButton1Click:Connect(function()
    tokensFarmeados = 0
    tiempoInicio = tick()
    lblTokens.Text = "Tokens Farmeados 🎁: 0"
    lblTiempo.Text = "Tiempo activo ⏳: 0s"
end)

-- 🛷 Movimiento
local function flyTo(pos, speed)
    if not rootPart then return end
    local dist = (pos - rootPart.Position).Magnitude
    local tween = TweenService:Create(
        rootPart,
        TweenInfo.new(dist / speed, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(pos)}
    )
    tween:Play()
    tween.Completed:Wait()
end

-- 🎄 Auto Farmeo
btnAuto.MouseButton1Click:Connect(function()
    autoNavidad = not autoNavidad

    if autoNavidad then
        btnAuto.Text = "Auto Farmeo Navidad: ENCENDIDO 🎄"
        btnAuto.BackgroundColor3 = Color3.fromRGB(0,200,120)
        tiempoInicio = tick()
        posicionesVisitadas = {}

        -- ⏱️ Contador
        task.spawn(function()
            while autoNavidad do
                lblTiempo.Text = "Tiempo activo ⏳: "..math.floor(tick()-tiempoInicio).."s"
                lblTokens.Text = "Tokens Farmeados 🎁: "..tokensFarmeados
                task.wait(0.1)
            end
        end)

        -- 🎁 Farmeo
        task.spawn(function()
            while autoNavidad do
                character = player.Character or player.CharacterAdded:Wait()
                rootPart = character:FindFirstChild("HumanoidRootPart")

                if rootPart then
                    local objetivo, menor = nil, math.huge
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
                            local d = (obj.Position - rootPart.Position).Magnitude
                            if d < menor and d < 250 and not posicionesVisitadas[obj] then
                                objetivo = obj
                                menor = d
                            end
                        end
                    end

                    if objetivo then
                        flyTo(objetivo.Position, velocidadFarmeo)
                        posicionesVisitadas[objetivo] = true
                        tokensFarmeados += 1
                        sonidoToken:Play()
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        btnAuto.Text = "Auto Farmeo Navidad: APAGADO ❄️"
        btnAuto.BackgroundColor3 = Color3.fromRGB(180,40,40)
    end
end)

-- ❄️ COPOS DE NIEVE (referencia exacta del script erróneo)
task.spawn(function()
    while frame and frame.Parent do
        local copo = Instance.new("TextLabel")
        copo.Parent = frame
        copo.Text = "❄"
        copo.BackgroundTransparency = 1
        copo.TextColor3 = Color3.fromRGB(255,255,255)
        copo.TextSize = math.random(14,22)
        copo.ZIndex = 1
        copo.Size = UDim2.new(0,20,0,20)
        copo.Position = UDim2.new(math.random(), 0, -0.1, 0)

        local duracion = math.random(4,7)
        TweenService:Create(
            copo,
            TweenInfo.new(duracion, Enum.EasingStyle.Linear),
            {Position = UDim2.new(copo.Position.X.Scale, 0, 1.1, 0)}
        ):Play()

        task.delay(duracion, function()
            if copo then copo:Destroy() end
        end)

        task.wait(0.25)
    end
end)
