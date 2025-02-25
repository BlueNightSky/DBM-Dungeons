local mod	= DBM:NewMod(663, "DBM-Party-MoP", 7, 246)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(59184)--59220 seem to be her mirror images
mod:SetEncounterID(1427)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_REMOVED 114062",
	"SPELL_CAST_START 114062",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnWondrousRapidity		= mod:NewSpellAnnounce(114062, 3)
local warnGravityFlux			= mod:NewTargetAnnounce(114059, 2)
local warnWhirlofIllusion		= mod:NewSpellAnnounce(113808, 4)

local specWarnWondrousRapdity	= mod:NewSpecialWarningDodge(114062, "Tank", nil, nil, 1, 2)--Frontal cone fixate attack, easily dodged (in fact if you don't, i imagine it'll wreck you on heroic)

local timerWondrousRapidity		= mod:NewBuffFadesTimer(7.5, 114062)
local timerWondrousRapidityCD	= mod:NewCDTimer(14, 114062, nil, "Tank", 2, 5)
local timerGravityFlux			= mod:NewCDTimer(12, 114059) -- needs more review.

function mod:GravityFluxTarget()
	local targetname = self:GetBossTarget(59184)
	if not targetname then return end
	warnGravityFlux:Show(targetname)
end

function mod:OnCombatStart(delay)
	timerWondrousRapidityCD:Start(6-delay)
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 114062 then
		timerWondrousRapidityCD:Start()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 114062 then
		if self.Options.SpecWarn114062dodge then
			specWarnWondrousRapdity:Show()
			specWarnWondrousRapdity:Play("shockwave")
		else
			warnWondrousRapidity:Show()
		end
		timerWondrousRapidity:Start()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if (spellId == 114059 or spellId == 114047) and self:AntiSpam(2, 1) then -- found 2 spellids on first cast, 4 spellids total (114035, 114038, 114047, 114059). needs more logs to confirm whether spellid is correct.
		self:ScheduleMethod(0.1, "GravityFluxTarget")
		timerGravityFlux:Start()
	elseif spellId == 113808 and self:AntiSpam(2, 2) then
		warnWhirlofIllusion:Show()
		timerGravityFlux:Cancel()
	end
end
