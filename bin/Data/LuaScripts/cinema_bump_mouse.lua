-- handles mouse
useMouseMode_ = MM_ABSOLUTE

function SetMouseMode(mode)
    useMouseMode_ = mode
    if GetPlatform() ~= "Web" then
        if useMouseMode_ == MM_FREE then
            input.mouseVisible = true
        end

        if useMouseMode_ ~= MM_ABSOLUTE then
            input.mouseMode = useMouseMode_

            if console ~= nil and console.visible then
                input:SetMouseMode(MM_ABSOLUTE, true)
            end
        end
    else
        input.mouseVisible = true
        SubscribeToEvent("MouseButtonDown", "HandleMouseModeRequest")
        SubscribeToEvent("MouseModeChanged", "HandleMouseModeChange")
    end
end


-- If the user clicks the canvas, attempt to switch to relative mouse mode on web platform
function HandleMouseModeRequest(eventType, eventData)
    if console ~= nil and console.visible then
        return
    end

    if input.mouseMode == MM_ABSOLUTE then
        input.mouseVisible = false
    elseif useMouseMode_ == MM_FREE then
        input.mouseVisible = true
    end

    input.mouseMode = useMouseMode_
end

-- If the user clicks the canvas, attempt to switch to relative mouse mode on web platform
function HandleMouseModeChange(eventType, eventData)
    mouseLocked = eventData["MouseLocked"]:GetBool()
    input.mouseVisible = not mouseLocked
end

