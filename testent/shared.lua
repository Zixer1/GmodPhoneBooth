AddCSLuaFile("cl_init.lua")
AddCSLuaFile("init.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Phone Dial"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "PhoneName", {KeyName = "phonename", Edit = {type = "Generic", order = 1}})
    self:NetworkVar("String", 1, "PhoneID", {KeyName = "phoneid", Edit = {type = "Generic", order = 2}})
    self:NetworkVar("Bool", 2, "HasBeenNamed")
    self:NetworkVar("Bool", 3, "IsGettingRingged")
    self:NetworkVar("Bool", 4, "IsRingging")
    self:NetworkVar("Entity", 5, "PersonCalling")
    self:NetworkVar("Entity", 6, "PersonAcceptingCall")
    self:NetworkVar("Entity", 7, "RinggingPhone")
    self:NetworkVar("Entity", 8, "RinggedByPhone")
    self:NetworkVar("Entity", 9, "PhoneUser")
    self:NetworkVar("Bool", 10, "Talking")
    
    if SERVER then
        self:SetPhoneName("Placeholder Name")
        self:SetPhoneID("XXX XXXX XXXX")
        self:SetHasBeenNamed(false)                 
        self:SetIsGettingRingged(false)
        self:SetIsRingging(false)
        self:SetPersonCalling(nil)
        self:SetRinggingPhone(nil)
        self:SetRinggedByPhone(nil)
        self:SetPersonAcceptingCall(nil)
        self:SetPhoneUser(nil)
        self:SetTalking(false)
        
    end
end

