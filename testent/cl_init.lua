include("shared.lua")
AddCSLuaFile("shared.lua")

surface.CreateFont("IDFont", {
    font = "Arial",
    size = 131,
    weight = 1000,
    antialias = true,
    shadow = false
})
surface.CreateFont("TextFont", {
    font = "Arial",
    size = 70,
    weight = 4000,
    antialias = true,
    shadow = false,
    bold = true
})
surface.CreateFont("PhoneBook", {
    font = "Arial",
    size = 23,
    weight = 1000,
    antialias = true,
    shadow = true,
    bold = true
})
surface.CreateFont("SearchBarFont", {
    font = "Arial",
    size = 19,
    weight = 1000,
    antialias = true,
    shadow = true,
    bold = true
})

surface.CreateFont("AlertMessageIsInCallFont", {
    font = "Arial",
    size = 15,
    weight = 1000,
    antialias = true,
    shadow = true,
    bold = true
})
if not Client_AllNums_Names then
    Client_AllNums_Names = {}
end

-- Function to request AllNums_Names from the server
function RequestAllNums_NamesFromServer()
    net.Start("RequestAllNums_Names")
    net.SendToServer()
end

-- Receiver for the data sent from the server
net.Receive("SendAllNums_Names", function()
    Client_AllNums_Names = net.ReadTable()
    -- Now Client_AllNums_Names contains the data from the server
    -- You can process or display it as needed
end)

function SetTalking(entity, state)
    if IsValid(entity) then
        net.Start("SetTalking")
        net.WriteEntity(entity)
        net.WriteBool(state)
        net.SendToServer()
    end
end


function SetIsRinging(entity, state)
    if IsValid(entity) then
        net.Start("SetIsRinging")
        net.WriteEntity(entity)
        net.WriteBool(state)
        net.SendToServer()
    end
end

function SetIsGettingRingged(entity, state)
    if IsValid(entity) then
        net.Start("SetIsGettingRingged")
        net.WriteEntity(entity)
        net.WriteBool(state)
        net.SendToServer()
    end
end

function SetHasBeenNamed(entity, state)
    if IsValid(entity) then
        net.Start("SetHasBeenNamed")
        net.WriteEntity(entity)
        net.WriteBool(state)
        net.SendToServer()
    end
end

-- Modified functions
function SendEntityWithNilCheck(netMsg, entity, otherEntity)
    if IsValid(entity) then
        net.Start(netMsg)
        net.WriteEntity(entity)
        local isValidOtherEntity = IsValid(otherEntity)
        net.WriteBool(isValidOtherEntity)
        if isValidOtherEntity then
            net.WriteEntity(otherEntity)
        end
        net.SendToServer()
    end
end

function SetPhoneUser(entity, otherEntity)

    SendEntityWithNilCheck("SetPhoneUser", entity, otherEntity)
end

function SetPersonCalling(entity, otherEntity)
    SendEntityWithNilCheck("SetPersonCalling", entity, otherEntity)
end

function SetPersonAcceptingCall(entity, otherEntity)
    SendEntityWithNilCheck("SetPersonAcceptingCall", entity, otherEntity)
end

function SetRinggedByPhone(entity, otherEntity)
    SendEntityWithNilCheck("SetRinggedByPhone", entity, otherEntity)
end

function SetRinggingPhone(entity, otherEntity)
    SendEntityWithNilCheck("SetRinggingPhone", entity, otherEntity)
end


function ENT:Draw()
    self:DrawModel()
    local PhoneName = self:GetPhoneName()
    local PhoneID = self:GetPhoneID()
    RequestAllNums_NamesFromServer()
    -- Iterate through Client_AllNums_Names
    for _, entry in ipairs(Client_AllNums_Names or {}) do
        local entity = entry[1][1]   -- The entity is the first element of the first sub-table
        local phoneData = entry[2]   -- Phone data (number and name) is the second sub-table

        if self == entity then
            PhoneName = phoneData[2]  -- Assuming the second item is the phone name
            PhoneID = phoneData[1]    -- Assuming the first item is the phone ID
            self:SetHasBeenNamed(true)
            break  -- Found the match, no need to continue the loop
        end
    end

    local ang = self:GetAngles()
    -- Adjust these angles if necessary to align the text correctly
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    -- Get the forward vector and scale it to move the text in front of the prop
    local forward = ang:Up() * 5.5

    -- Adjust the position using the forward vector
    local pos = self:GetPos() + forward

    cam.Start3D2D(pos, ang, 0.01)
        draw.SimpleText(PhoneID, "IDFont", 0, -1380, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(PhoneName, "TextFont", 0, -1280, Color(150,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end


function InsideACall(self, ply, entity)
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 800)  -- Frame size
    frame:Center()
    frame:SetTitle("")  -- Hide the title
    frame:ShowCloseButton(false)  -- Hide the close button
    frame:SetDraggable(false)  -- Make the frame non-draggable
    frame:SetVisible(true)

    frame.Paint = function(self, w, h)
        -- Make the frame background invisible
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
    end
    local function GetPhoneNameForEntity(targetEntity, clientAllNumsNames)
        for _, entry in ipairs(clientAllNumsNames) do
            local entity = entry[1][1]  -- Entity is the first element of the first nested table
            local phoneDetails = entry[2]  -- Phone details are in the second nested table
    
            if entity == targetEntity and phoneDetails then
                local phoneName = phoneDetails[2]  -- Phone name is the second element of the phone details
                return phoneName
            end
        end
    
        return nil  -- Return nil if no matching entity is found
    end
    -- Function to draw the "Connected to:" text
    local function DrawTextConnectedTo(input)
        local label = vgui.Create("DLabel", frame)
        RequestAllNums_NamesFromServer()
        local phonename = GetPhoneNameForEntity(input, Client_AllNums_Names)

        label:SetFont("DermaLarge")
        label:SetText("Connected to: " .. phonename)
        label:SetTextColor(Color(255, 165, 0))  -- Orange color
        label:SizeToContents()

        local textWidth = math.max(label:GetWide(), 100)  -- Ensure a minimum width of 100
        local bgHeight = 52  -- Fixed height for the background
        local bgWidth = textWidth + 20  -- Width based on text width plus padding
        local bgX = (frame:GetWide() - bgWidth) / 2
        local bgY = 686 - bgHeight / 2  -- Position adjusted to be above the existing label
        local labelX = bgX + (bgWidth - label:GetWide()) / 2
        local labelY = bgY + (bgHeight - label:GetTall()) / 2

        label:SetPos(labelX, labelY)
    end

    -- Internal function to draw text with background
    local function DrawTextWithBackground(text)
        local label = vgui.Create("DLabel", frame)
        label:SetFont("DermaLarge")
        label:SetText(text)
        label:SetTextColor(Color(255, 165, 0))  -- Orange color
        label:SizeToContents()

        local textWidth = math.max(label:GetWide(), 100)  -- Ensure a minimum width of 100
        local bgHeight = 52  -- Fixed height for the background
        local bgWidth = textWidth + 20  -- Width based on text width plus padding
        local bgX = (frame:GetWide() - bgWidth) / 2
        local bgY = 748 - bgHeight / 2
        local labelX = bgX + (bgWidth - label:GetWide()) / 2
        local labelY = bgY + (bgHeight - label:GetTall()) / 2

        label:SetPos(labelX, labelY)

        frame.PaintOver = function()
            draw.RoundedBox(0, bgX-(175/2), bgY, bgWidth+175, bgHeight, Color(24, 24, 32, 255))  -- Rounded corners
            label:PaintManual()
        end
    end


    -- Function to execute end code
    local function executeEndCode()
        self.isCalling = false
        SetIsGettingRingged(entity, false)
        SetIsRinging(self, false)
        SetPersonCalling(entity, nil)
        SetRinggingPhone(self, nil)
        SetRinggedByPhone(entity, nil)
        frame:Close()

    end

    if IsValid(self:GetPersonAcceptingCall()) then
        DrawTextWithBackground("Inside a call with: " .. self:GetPersonAcceptingCall():Nick() .. "!")
        DrawTextConnectedTo(self:GetRinggingPhone())
        SetPersonAcceptingCall(self, self:GetPersonAcceptingCall())
        SetRinggingPhone(self, self:GetRinggingPhone())
    elseif IsValid(self:GetPersonCalling()) then
        DrawTextWithBackground("Inside a call with: " .. self:GetPersonCalling():Nick() .. "!")
        DrawTextConnectedTo(self:GetRinggedByPhone())
        SetPersonCalling(self, self:GetPersonCalling())
        SetRinggedByPhone(self, self:GetRinggedByPhone())
    end
    
    
    frame.Think = function()
        if input.IsKeyDown(KEY_G) then
            executeEndCode()
            SetPhoneUser(self, nil)
            SetPhoneUser(entity, nil)
            SetTalking(self, false)
            SetTalking(entity, false)
        end
        timer.Simple(0.5, function()
            if not entity:GetTalking() then
                executeEndCode()
                SetPhoneUser(self, nil)
                SetPhoneUser(entity, nil)
                SetTalking(self, false)
                SetTalking(entity, false)
            end
        end)
    end
end


function ShowCallPanel(self, ply, entity)
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 800)  -- Frame size
    frame:Center()
    frame:SetTitle("")  -- Hide the title
    frame:ShowCloseButton(false)  -- Hide the close button
    frame:SetDraggable(false)  -- Make the frame non-draggable
    frame:SetVisible(true)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        -- Make the frame background invisible
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
    end

    -- Internal function to draw text with background
    local function DrawTextWithBackground(text)
        local label = vgui.Create("DLabel", frame)
        label:SetFont("DermaLarge")
        label:SetText(text)
        label:SetTextColor(Color(255, 165, 0))  -- Orange color
        label:SizeToContents()

        local textWidth = math.max(label:GetWide(), 100)  -- Ensure a minimum width of 100
        local bgHeight = 52  -- Fixed height for the background
        local bgWidth = textWidth + 20  -- Width based on text width plus padding
        local bgX = (frame:GetWide() - bgWidth) / 2
        local bgY = 748 - bgHeight / 2
        local labelX = bgX + (bgWidth - label:GetWide()) / 2
        local labelY = bgY + (bgHeight - label:GetTall()) / 2

        label:SetPos(labelX, labelY)

        frame.PaintOver = function()
            draw.RoundedBox(0, bgX-(175/2), bgY, bgWidth+175, bgHeight, Color(24, 24, 32, 255))  -- Rounded corners
            label:PaintManual()
        end
    end

    -- Use the internal function to draw "Calling..." with background
    -- Unique identifier for the timer
    local timerID = "Timer"

    -- Total duration and interval
    local totalDuration = 20   -- 30 seconds
    local interval = 0.3       -- 0.4-second interval
    local repetitions = totalDuration / interval  -- Calculate number of repetitions

    -- Boolean variable to control the timer
    local stopTimer = false

    -- Function to execute end code
    local function executeEndCode()
        self.isCalling = false
        SetIsGettingRingged(entity, false)
        SetIsRinging(self, false)
        SetPersonCalling(entity, nil)
        SetRinggingPhone(self, nil)
        SetRinggedByPhone(entity, nil)
        frame:Close()

    end
    DrawTextWithBackground("Ringing")
    -- Create the timer
    local callTexts = {"Ringing.", "Ringing..", "Ringing..."}
    local currentTextIndex = 1
    timer.Create(timerID, interval, repetitions, function()
        -- Check if self:GetPersonAcceptingCall() has become a valid entity
        if IsValid(entity:GetPhoneUser()) then
            print("Call accepted by: " .. entity:GetPhoneUser():Nick())
            timer.Remove(timerID)  -- Stop the timer
            executeEndCode()
            SetPersonAcceptingCall(self, entity:GetPhoneUser())
            InsideACall(self, ply, entity)
            SetTalking(self, true)
            return
        end
        DrawTextWithBackground(callTexts[currentTextIndex])
        currentTextIndex = currentTextIndex % #callTexts + 1
    
    end)                                

    -- Schedule the end code to execute after the total duration
    -- Only if the timer has not been stopped prematurely
    timer.Simple(totalDuration, function()
        if not stopTimer then
            executeEndCode()
        end
        
    end)


    -- Stop Button
    local stopButton = vgui.Create("DButton", frame)
    stopButton:SetText("Stop")
    stopButton:SetTextColor(Color(255, 0, 0))
    stopButton:SetPos(400, 702)  -- Position near the label
    stopButton:SetSize(20, 20)  -- Button size
    stopButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0, 255))  -- Red button
    end
    stopButton.DoClick = function()
        frame:Close()  -- Close the frame
        SetPhoneUser(self, nil)
        self.isCalling = false
        SetIsGettingRingged(entity, false)
        SetIsRinging(self, false)
        SetPersonCalling(entity, nil)
        SetRinggingPhone(self, nil)
        SetRinggedByPhone(entity, nil)
    end
end






function Draw_Pannel(self, ply)
        -- Extend the height of the frame to create space for the additional label
        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 750)  -- Increased height
        frame:Center()
        frame:SetVisible(true)
        frame:MakePopup()
        frame:SetTitle("")
        frame:SetSizable(false)
        frame:ShowCloseButton(false)
        frame.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, 700, Color(29, 30, 38, 250))  -- Original area
            draw.RoundedBox(0, 100, 700, w-200, 50, Color(29, 30, 38, 250))  -- Additional area
            draw.RoundedBox(0, 0, 0, w, h-726.5, Color(29, 30, 38, 250))
            draw.RoundedBox(0, 0, 0, w-495, h-726.5, Color(255, 255, 255, 250))
        end

        -- Hide the default close button
        frame.btnClose:SetVisible(false)
    
        -- Create a custom close button
        local customCloseButton = vgui.Create("DButton", frame)
        customCloseButton:SetText("")
        customCloseButton:SetSize(30, 23) -- Set the size of the custom close button
        customCloseButton:SetPos(frame:GetWide() - 30, 0) -- Position it at the top right
    
        customCloseButton.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 150, 150)) -- Change color when hovered
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 100, 100)) -- Normal color
            end
            draw.SimpleText("X", "DermaLarge", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        customCloseButton.DoClick = function()
            frame:Close()
            SetPhoneUser(self, nil)
            self.isCalling = false
            SetIsGettingRingged(entity, false)
            SetIsRinging(self, false)
            SetPersonCalling(entity, nil)
            SetRinggingPhone(self, nil)
            SetRinggedByPhone(entity, nil)
            
        end
    


        local searchBar = vgui.Create("DTextEntry", frame)
        searchBar:SetPos(10, 25)
        searchBar:SetSize(480, 20)
        searchBar:SetFont("SearchBarFont")
    
        searchBar.Paint = function(self, w, h)
            self:DrawTextEntryText(Color(255, 255, 255, 100), Color(30, 130, 255), Color(255, 255, 255))
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
        end

        -- Create a label for the Seach placeholder message
        local SearchBarPlaceHolder = vgui.Create("DLabel", frame)
        SearchBarPlaceHolder:SetPos(15, 27)
        SearchBarPlaceHolder:SetText("Search..")
        SearchBarPlaceHolder:SetFont("SearchBarFont")
        SearchBarPlaceHolder:SetTextColor(Color(255, 255, 255, 100))  -- Grey Search
        SearchBarPlaceHolder:SetVisible(true)

        local AlertMessageIsInCall = vgui.Create("DLabel", frame)
        AlertMessageIsInCall:SetPos(180, 725)
        AlertMessageIsInCall:SetSize(230, 30)
        AlertMessageIsInCall:SetText("Already calling someone!")
        AlertMessageIsInCall:SetFont("AlertMessageIsInCallFont")
        AlertMessageIsInCall:SetTextColor(Color(255, 0, 0, 100))  -- 
        AlertMessageIsInCall:SetVisible(false)


        local AppList = vgui.Create("DListView", frame)
        AppList:SetPos(10, 47)
        AppList:SetSize(480, 650)  -- Width increased to give space for the scrollbar
        AppList:SetHideHeaders(true)
        
        -- Adjust the column width here
        local col = AppList:AddColumn("Application")
        col:SetFixedWidth(400)  -- Width decreased to allow more space on the right
        
        AppList:SetMultiSelect(false)
        AppList:SetDataHeight(53) -- Adjusted for spacing
        AppList.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(29, 30, 38, 0))
        end

        -- Create a label for the "dead line" message
        local deadLineLabel = vgui.Create("DLabel", frame)
        deadLineLabel:SetPos(10, 705)  -- Positioned in the extended area
        deadLineLabel:SetSize(480, 30)  -- Adjusted width
        deadLineLabel:SetText("This line is dead...")
        deadLineLabel:SetFont("DermaLarge")
        deadLineLabel:SetTextColor(Color(255, 165, 0))  -- Orange color
        deadLineLabel:SetContentAlignment(5)
        deadLineLabel:SetVisible(true)
        
        local CallingRing = vgui.Create("DLabel", frame)
        CallingRing:SetPos(10, 705)  -- Positioned in the extended area
        CallingRing:SetSize(480, 30)  -- Adjusted width
        CallingRing:SetText("Calling...")
        CallingRing:SetFont("DermaLarge")
        CallingRing:SetTextColor(Color(255, 165, 0))  -- Orange color
        CallingRing:SetContentAlignment(5)
        CallingRing:SetVisible(false)

        -- Create a label for the "You can't call yourself!" message
        local selfCallLabel = vgui.Create("DLabel", frame)
        selfCallLabel:SetPos(10, 705)
        selfCallLabel:SetSize(480, 30)
        selfCallLabel:SetText("You can't call yourself!")
        selfCallLabel:SetFont("DermaLarge")
        selfCallLabel:SetTextColor(Color(255, 0, 0))  -- Red color
        selfCallLabel:SetContentAlignment(5)
        selfCallLabel:SetVisible(false)


        local TittleA = vgui.Create("DLabel", frame)
        TittleA:SetPos(10, -3) -- Position the label at the bottom of the frame
        TittleA:SetSize(frame:GetWide() - 20, 30) -- Adjust width and height as needed
        TittleA:SetText("Phone Dial")
        TittleA:SetTextColor(Color(255, 255, 255)) -- Adjust text color as needed
        
        local function PaintRow(line)
            line.Paint = function(self, w, h)
                local bgColor = self:IsLineSelected() and Color(100, 100, 100) or Color(60, 60, 60)
                draw.RoundedBox(0, 0, 0, w, h - 3, Color(28,29,36)) -- Reduced height for spacing
            end
            for k, v in pairs(line.Columns) do
                v:SetFont("PhoneBook")
                v:SetTextColor(Color(255, 255, 255))
            end
        end

        RequestAllNums_NamesFromServer()

        local function TransformData(input)
            local data = {}
            for _, entry in ipairs(input) do
                local phoneInfo = entry[2]  -- Assuming the phone info is in the second sub-table
                local phoneNum = phoneInfo[1]
                local name = phoneInfo[2]
                table.insert(data, name .. "\n" .. phoneNum)
            end
            return data
        end
        local data = TransformData(Client_AllNums_Names)
    
        local function PopulateList(filter)
            AppList:Clear()
            for _, app in ipairs(data) do
                if not filter or string.find(string.lower(app), string.lower(filter), 1, true) then
                    local line = AppList:AddLine(app)
                    PaintRow(line)
                    local callButton = vgui.Create("DButton", line)
                    callButton:Dock(RIGHT)
                    callButton:SetWide(100)
                    callButton:SetText("Call")
                    callButton:SetFont("DermaLarge")
                    callButton.Paint = function(self, w, h)
                        -- Draw button background
                        draw.RoundedBox(0, 0, 0, w, h - 3, self:IsDown() and Color(100, 100, 100) or Color(28,29,36))
                        
                        -- Draw orange outline
                        surface.SetDrawColor(255, 165, 0)  -- Orange color
                        surface.DrawOutlinedRect(0, 0, w, h - 3)
                        
                        -- Draw button text
                        self:SetTextColor(Color(255, 165, 0))
                        self:SetContentAlignment(5)
                    end
                    self.isCalling = false
                    callButton.DoClick = function()
                        -- Fetch and print the text from the first column of the associated line
                        if self.isCalling then
                            AlertMessageIsInCall:SetVisible(true)
                            return  -- Exit the function to prevent starting a new call
                        end

                        local text = line:GetColumnText(1)
                        local function FindEntityByPhoneNumber(text)
                            -- Extract the last 13 characters (phone number) from the text
                            local phoneNumber = string.sub(text, -13)
                        
                            -- Search through Client_AllNums_Names to find the corresponding entity
                            for _, entry in ipairs(Client_AllNums_Names) do
                                local phoneInfo = entry[2]  -- Assuming the phone info is in the second sub-table
                                local phoneNum = phoneInfo[1]
                        
                                if phoneNum == phoneNumber then
                                    local entity = entry[1][1]  -- Assuming the entity is the first element of the first sub-table
                                    return entity
                                end
                            end
                        
                            return nil  -- Return nil if no matching entity is found
                        end

                        local entity = FindEntityByPhoneNumber(text)
                        if entity == self then
                            deadLineLabel:SetVisible(false)
                            selfCallLabel:SetVisible(true)
                            CallingRing:SetVisible(false)
                            timer.Simple(0.5, function()
                                deadLineLabel:SetVisible(true)
                                selfCallLabel:SetVisible(false)
                                CallingRing:SetVisible(false)
                            end)
                            
                        else
                            deadLineLabel:SetVisible(false)
                            selfCallLabel:SetVisible(false)
                            CallingRing:SetVisible(true)
                            -- Additional actions for a successful call
                            if IsValid(entity) then
                                self.isCalling = true
                                SetIsGettingRingged(entity, true)
                                SetIsRinging(self, true)
                                SetPersonCalling(entity, ply)
                                SetRinggingPhone(self, entity)
                                SetRinggedByPhone(entity, self)
                                frame:Close()
                                ShowCallPanel(self, ply, entity)

                            end
                        end
                    end
                end
            end
        end
        
        
        
    
        PopulateList()
    
        searchBar.OnChange = function(self)
            PopulateList(self:GetValue())
            if self:GetValue() == "" or self:GetValue() == nil then
                SearchBarPlaceHolder:SetVisible(true)
            else
                print(self:GetValue())
                SearchBarPlaceHolder:SetVisible(false)
            end
        end
    
        AppList.OnRowSelected = function(lst, index, pnl)
            print("Selected " .. pnl:GetColumnText(1) .. " at index " .. index)
        end
        
end       

function SetName_ID(self, ply)
    local frame = vgui.Create("DFrame")
    frame:SetSize(350, 150)
    frame:Center()
    frame:SetVisible(true)
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(29, 30, 38, 250))
    end

    local errorLabel = vgui.Create("DLabel", frame)
    errorLabel:SetTextColor(Color(255, 0, 0))
    errorLabel:SetFont("DermaDefault")
    errorLabel:SetText("")
    errorLabel:SizeToContents()
    errorLabel:SetPos(25, 93)
    errorLabel:SetVisible(false)

    local titleLabel = vgui.Create("DLabel", frame)
    titleLabel:SetText("Set Name and ID")
    titleLabel:SetTextColor(Color(255, 255, 255))
    titleLabel:SetFont("DermaLarge")
    titleLabel:SizeToContents()
    titleLabel:SetPos(frame:GetWide() / 2 - titleLabel:GetWide() / 2, 5)

    -- Custom close button
    frame.btnClose:SetVisible(false)
    local customCloseButton = vgui.Create("DButton", frame)
    customCloseButton:SetText("")
    customCloseButton:SetSize(30, 23)
    customCloseButton:SetPos(frame:GetWide() - 30, 0)
    customCloseButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 150, 150))
        else
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 100, 100))
        end
        draw.SimpleText("X", "DermaLarge", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    customCloseButton.DoClick = function()
        frame:Close()
        SetPhoneUser(self, nil)
    end

    local nameEntry = vgui.Create("DTextEntry", frame)
    nameEntry:SetPos(25, 70)
    nameEntry:SetSize(300, 20)
    nameEntry:SetFont("DermaDefault")
    nameEntry:SetPlaceholderText("Enter Phone Name here")

    local idEntry = vgui.Create("DTextEntry", frame)
    idEntry:SetPos(25, 40)
    idEntry:SetSize(300, 20)
    idEntry:SetFont("DermaDefault")
    idEntry:SetPlaceholderText("Phone ID: XXX XXXX XXXX")

    local submitButton = vgui.Create("DButton", frame)
    submitButton:SetPos(125, 110)
    submitButton:SetSize(100, 30)
    submitButton:SetText("")
    submitButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 90, 255))
        else
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 70, 255))
        end
        draw.SimpleText("Submit", "DermaDefault", w / 2, h / 2, Color(255, 165, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)  -- Orange text
    end
    submitButton.DoClick = function()
        local phoneName = nameEntry:GetValue()
        local phoneID = idEntry:GetValue()

        -- Validate Phone Name length
        if #phoneName > 28 then
            errorLabel:SetText("Phone Name is too long (max 28 characters)")
            errorLabel:SetVisible(true)
            errorLabel:SizeToContents()
            return
        end

        if #phoneName < 6 then
            errorLabel:SetText("Phone Name is too short (min 6 characters)")
            errorLabel:SetVisible(true)
            errorLabel:SizeToContents()
            return
        end

        -- Validate Phone ID format
        if not string.match(phoneID, "^%d%d%d %d%d%d%d %d%d%d%d$") then
            errorLabel:SetText("Invalid Phone ID, Ex: 000 0000 0000")
            errorLabel:SetVisible(true)
            errorLabel:SizeToContents()
            return
        end

        local Existing_ID = {}
        local Existing_Name = {}
        RequestAllNums_NamesFromServer()
        for _, entry in ipairs(Client_AllNums_Names) do
            local id = entry[2][1]  -- Assuming the ID is the first element in the second sub-table
            local name = entry[2][2]  -- Assuming the name is the second element in the second sub-table
            table.insert(Existing_ID, id)
            table.insert(Existing_Name, name)

        end

        -- Check if the Phone ID already exists
        for _, existingID in ipairs(Existing_ID) do
            if phoneID == existingID then
                errorLabel:SetText("This Phone ID already exists")
                errorLabel:SetVisible(true)
                errorLabel:SizeToContents()
                return
            end
        end

        -- Check if the Phone Name already exists
        for _, existingName in ipairs(Existing_Name) do
            if phoneName == existingName then
                errorLabel:SetText("This Phone Name already exists")
                errorLabel:SetVisible(true)
                errorLabel:SizeToContents()
                return
            end
        end

        -- If validations pass, set the phone name and ID
        self:SetPhoneName(phoneName)
        self:SetPhoneID(phoneID)
        self:SetHasBeenNamed(true)
        
        -- Prepare to send the phone name and ID to the server
        net.Start("ClientSendsPhoneData")
        net.WriteString(phoneName)
        net.WriteString(phoneID)
        net.WriteEntity(self)
        net.SendToServer()
        -- Close the frame or do other actions as needed
        frame:Close()
    end
end


net.Receive("PhoneCallPannelActivator", function(len)
    local self = net.ReadEntity()
    local ply = net.ReadEntity()
    RequestAllNums_NamesFromServer()

    SetPhoneUser(self, ply)

    if IsValid(self) and self:GetHasBeenNamed() == false then
        SetName_ID(self, ply)
        
    else
        if(self:GetIsGettingRingged() == true) then
            InsideACall(self, ply, self:GetRinggedByPhone())
            SetTalking(self, true)
        else
            Draw_Pannel(self, ply)
           
        end
    end

end)


