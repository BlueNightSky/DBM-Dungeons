local mod	= DBM:NewMod(600, "DBM-Party-WotLK", 6, 275)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(28923)
mod:SetEncounterID(1986)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52960 59835"
)

local warningNova	= mod:NewSpellAnnounce(52960, 3)

local specWarnNova	= mod:NewSpecialWarningRun(52960, false, nil, nil, 4, 2)

--local timerNovaCD	= mod:NewCDTimer(30, 52960, nil, nil, nil, 2)
local timerAchieve	= mod:NewAchievementTimer(120, 1867)

function mod:OnCombatStart(delay)
	if not self:IsDifficulty("normal5") then
		timerAchieve:Start(-delay)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(52960, 59835) then
		if self.Options.SpecWarn52960run then
			specWarnNova:Show()
			specWarnNova:Play("justrun")
		else
			warningNova:Show()
		end
--		timerNovaCD:Start()
	end
end
