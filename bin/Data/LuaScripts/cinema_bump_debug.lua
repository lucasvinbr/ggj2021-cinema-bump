--    - Handle Esc key down to hide Console or exit application

function DebugSetup()

    -- Create console and debug HUD
    CreateConsoleAndDebugHud()

    -- Subscribe key down event
    SubscribeToEvent("KeyDown", "HandleKeyDown")

    -- Subscribe key up event
    SubscribeToEvent("KeyUp", "HandleKeyUp")

end

function CreateConsoleAndDebugHud()
    -- Get default style
    local uiStyle = cache:GetResource("XMLFile", "UI/DefaultStyle.xml")
    if uiStyle == nil then
        return
    end

    -- Create console
    engine:CreateConsole()
    console.defaultStyle = uiStyle
    console.background.opacity = 0.8

    -- Create debug HUD
    engine:CreateDebugHud()
    debugHud.defaultStyle = uiStyle
end

function HandleKeyUp(eventType, eventData)
    local key = eventData["Key"]:GetInt()
    -- Close console (if open) or exit when ESC is pressed
    if key == KEY_ESCAPE then
        if console:IsVisible() then
            console:SetVisible(false)
        else
            engine:Exit()
        end
    end
end

function HandleKeyDown(eventType, eventData)
    local key = eventData["Key"]:GetInt()

    if key == KEY_F1 then
        console:Toggle()

    elseif key == KEY_F2 then
        debugHud:ToggleAll()
    end
end
