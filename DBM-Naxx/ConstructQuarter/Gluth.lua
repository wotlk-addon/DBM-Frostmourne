local mod	= DBM:NewMod("Gluth", "DBM-Naxx", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2869 $"):sub(12, -3))
mod:SetCreatureID(15932)

mod:RegisterCombat("combat")

mod:EnableModel()

mod:RegisterEvents(
	"SPELL_DAMAGE",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS"
)


local warnDecimateSoon	= mod:NewSoonAnnounce(54426, 2)
local warnDecimateNow	= mod:NewSpellAnnounce(54426, 3)
local warnEnraged		= mod:NewSpellAnnounce(54427, 3)

local enrageTimer		= mod:NewBerserkTimer(420)
local timerDecimate		= mod:NewCDTimer(110, 54426)
local timerEnraged		= mod:NewTimer(8, "Enraged", 54427, mod:CanRemoveEnrage() or mod:IsTank() or mod:IsHealer())
local timerWound		= mod:NewCDTimer(6, 25646, nil, mod:IsTank())

function mod:OnCombatStart(delay)
	enrageTimer:Start(420 - delay)
	timerDecimate:Start(110 - delay)
	warnDecimateSoon:Schedule(100 - delay)
end

local decimateSpam = 0
function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(28375) and (GetTime() - decimateSpam) > 20 then
		decimateSpam = GetTime()
		warnDecimateNow:Show()
		timerDecimate:Start()
		warnDecimateSoon:Schedule(100)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(54427, 28371) then
		warnEnraged:Show()
		timerEnraged:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(54427, 28371) then
		timerEnraged:Stop()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(25646) then
		timerWound:Start()
	end
end
