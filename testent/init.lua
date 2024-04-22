AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("PhoneCallPannelActivator")
util.AddNetworkString("ClientSendsPhoneData")
util.AddNetworkString("RequestAllNums_Names")
util.AddNetworkString("SendAllNums_Names")
util.AddNetworkString("SetIsRinging")
util.AddNetworkString("SetIsGettingRingged")
util.AddNetworkString("SetPersonCalling")
util.AddNetworkString("SetPersonAcceptingCall")
util.AddNetworkString("SetRinggingPhone")
util.AddNetworkString("SetRinggedByPhone")
util.AddNetworkString("SetPhoneUser")
util.AddNetworkString("SetHasBeenNamed")
util.AddNetworkString("SetTalking")

net.Receive("SetTalking", function(len, ply)
    local ent = net.ReadEntity()
    local state = net.ReadBool()
    if IsValid(ent) and ent:GetTalking() != state then
        ent:SetTalking(state)
    end
end)

net.Receive("SetHasBeenNamed", function(len, ply)
    local ent = net.ReadEntity()
    local state = net.ReadBool()

    if IsValid(ent) and ent:GetHasBeenNamed() != state then
    end
end)

net.Receive("SetPhoneUser", function(len, ply)
    local ent = net.ReadEntity()
    local isValidUser = net.ReadBool()
    local user = isValidUser and net.ReadEntity() or nil

    
    ent:SetPhoneUser(user)
    
    
end)

net.Receive("SetRinggedByPhone", function(len, ply)
    local ent = net.ReadEntity()
    local isValidPhone = net.ReadBool()
    local phone = isValidPhone and net.ReadEntity() or nil

    if IsValid(ent) and (ent:GetRinggedByPhone() != phone) then
        ent:SetRinggedByPhone(phone)
    end
end)

net.Receive("SetRinggingPhone", function(len, ply)
    local ent = net.ReadEntity()
    local isValidPhone = net.ReadBool()
    local phone = isValidPhone and net.ReadEntity() or nil
    if IsValid(ent) and (ent:GetRinggingPhone() != phone) then
        ent:SetRinggingPhone(phone)
    end
end)

net.Receive("SetPersonAcceptingCall", function(len, ply)
    local ent = net.ReadEntity()
    local isValidPerson = net.ReadBool()
    local person = isValidPerson and net.ReadEntity() or nil
    if IsValid(ent) and (ent:GetPersonAcceptingCall() != person) then
        ent:SetPersonAcceptingCall(person)
    end
end)

net.Receive("SetPersonCalling", function(len, ply)
    local ent = net.ReadEntity()
    local isValidPerson = net.ReadBool()
    local person = isValidPerson and net.ReadEntity() or nil
    if IsValid(ent) and (ent:GetPersonCalling() != person) then
        ent:SetPersonCalling(person)
    end
end)


net.Receive("SetIsRinging", function(len, ply)
    local ent = net.ReadEntity()
    local state = net.ReadBool()
    if IsValid(ent) and ent:GetIsRingging() != state then
        ent:SetIsRingging(state)
    end
end)

net.Receive("SetIsGettingRingged", function(len, ply)
    local ent = net.ReadEntity()
    local state = net.ReadBool()
    if IsValid(ent) and ent:GetIsGettingRingged() != state then
        ent:SetIsGettingRingged(state)
    end
end)

-- Function to send AllNums_Names to a specific client
local function SendAllNums_Names(ply)
    net.Start("SendAllNums_Names")
    net.WriteTable(AllNums_Names)
    net.Send(ply)
end

-- Receiver for client's request
net.Receive("RequestAllNums_Names", function(len, ply)
    SendAllNums_Names(ply) -- Send the data to the client who requested it
end)

if not AllNums_Names then
    AllNums_Names = {}
end

net.Receive("ClientSendsPhoneData", function(len, ply)
    local phoneName = net.ReadString()
    local phoneID = net.ReadString()
    local self = net.ReadEntity()
    table.insert(AllNums_Names, {{self},{phoneID, phoneName}})

end)

function ENT:Initialize()
    self:SetModel("models/props_trainstation/payphone001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self.IsGettingRinggedSoundPlaying = false
    self.IsRinggingSoundPlaying = false
    self.HasBeenUsed = false
    self.isCalling = false
    self.actionPerformed = false
    self.voiceHookAdded = false
end

function ENT:Use(activator, caller)
    if self.HasBeenUsed then
        return
    end

    self.HasBeenUsed = true

    if IsValid(activator) and activator:IsPlayer() then
        net.Start("PhoneCallPannelActivator")
        net.WriteEntity(self)
        net.WriteEntity(activator)  -- Include the player who activated the entity
        net.Send(activator)
    end

    timer.Simple(0.3, function()
        if IsValid(self) then
            self.HasBeenUsed = false
        end
    end)
end


function ENT:OnRemove()
    -- Iterate through the AllNums_Names table
    for i, pair in ipairs(AllNums_Names) do
        -- Check if the first sub-table's first element (the entity) matches self
        if pair[1][1] == self then
            -- Remove the entry from AllNums_Names
            table.remove(AllNums_Names, i)
            break
        end
    end
end

function ENT:GetConnectedPhone()
    return IsValid(self:GetRinggedByPhone()) and self:GetRinggedByPhone() or self:GetRinggingPhone()
end

function ENT:Think()
    if self:GetIsGettingRingged() then
        if not self.IsGettingRinggedSoundPlaying then
            self:EmitSound("ringing.wav", 75, 100, 1, CHAN_AUTO)
            self.IsGettingRinggedSoundPlaying = true

            timer.Create(self:EntIndex() .. ":RinggedSoundTimer", 2, 1, function()
                if IsValid(self) and self:GetIsGettingRingged() then
                    self.IsGettingRinggedSoundPlaying = false
                end
            end)
        end
    elseif self.IsGettingRinggedSoundPlaying then
        self:StopSound("ringing.wav")
        timer.Remove(self:EntIndex() .. ":RinggedSoundTimer")
        self.IsGettingRinggedSoundPlaying = false
    end

    if self:GetIsRingging() then
        if not self.IsRinggingSoundPlaying then
            self:EmitSound("toneing.wav", 75, 100, 1, CHAN_AUTO)
            self.IsRinggingSoundPlaying = true

            timer.Create(self:EntIndex() .. ":RingingSoundTimer", 9, 1, function()
                if IsValid(self) and self:GetIsRingging() then
                    self.IsRinggingSoundPlaying = false
                end
            end)
        end
    elseif self.IsRinggingSoundPlaying then
        self:StopSound("toneing.wav")
        timer.Remove(self:EntIndex() .. ":RingingSoundTimer")
        self.IsRinggingSoundPlaying = false
    end
    self.actionPerformed = self.actionPerformed or false

    local phoneUser = self:GetPhoneUser()
    local ringgedByPhone = self:GetRinggedByPhone()
    local IsRinging = self:GetIsRingging()  -- Replace with the correct method or variable

    if IsValid(phoneUser) and IsValid(ringgedByPhone) then
        if not self.actionPerformed then
            ringgedByPhone:SetPersonAcceptingCall(phoneUser)
            self.actionPerformed = true  -- Action performed
        end
    elseif not IsValid(phoneUser) and IsValid(ringgedByPhone) then
        ringgedByPhone:SetPersonAcceptingCall(nil)
        self.actionPerformed = false  -- Reset action flag
    elseif not IsRinging then
        self:SetPersonAcceptingCall(nil)
        self.actionPerformed = false  -- Reset action flag if not ringing
    end
    
    local hookIdentifier = self

    if self:GetTalking() then
        if IsValid(self:GetRinggingPhone()) or IsValid(self:GetRinggedByPhone()) then
            if not self.talkingHookAdded then
                -- Remove the default hook and add the talking hook
                hook.Remove("PlayerCanHearPlayersVoice", hookIdentifier)
                hook.Add("PlayerCanHearPlayersVoice", hookIdentifier, function(listener, talker)
                    local personcalling = IsValid(self:GetRinggingPhone()) and self:GetPhoneUser() or self:GetRinggedByPhone():GetPhoneUser()
                    local personaccepting = IsValid(self:GetRinggingPhone()) and self:GetRinggingPhone():GetPhoneUser() or self:GetPhoneUser()

                    if (listener == personcalling and talker == personaccepting) or
                       (listener == personaccepting and talker == personcalling) then
                        return true, false
                    end
                end)
                self.talkingHookAdded = true
                self.defaultHookAdded = false
            end
        end
    else
        if self.talkingHookAdded or not self.defaultHookAdded then
            -- Remove the talking hook and add the default hook
            hook.Remove("PlayerCanHearPlayersVoice", hookIdentifier)
            hook.Add("PlayerCanHearPlayersVoice", hookIdentifier, function(listener, talker)
                return listener:GetPos():Distance(talker:GetPos()) < 500, true
            end)
            self.talkingHookAdded = false
            self.defaultHookAdded = true
        end
    end

    

    self:NextThink(CurTime())
    return true
end

