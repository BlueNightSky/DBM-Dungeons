local mod	= DBM:NewMod(579, "DBM-Party-BC", 5, 262)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(17882)
mod:SetEncounterID(1948)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 31704 31715"
)

local warnStaticCharge		= mod:NewTargetAnnounce(31715, 3)
local warnLevitate			= mod:NewTargetNoFilterAnnounce(31704, 2, nil, "RemoveMagic|Healer")

local specWarnStaticCharge	= mod:NewSpecialWarningMoveAway(31715, nil, nil, nil, 1, 2)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 31704 then
		warnLevitate:Show(args.destName)
	elseif args.spellId == 31715 then
		if args:IsPlayer() then
			specWarnStaticCharge:Show()
			specWarnStaticCharge:Play("runout")
		else
			warnStaticCharge:Show(args.destName)
		end
	end
end
