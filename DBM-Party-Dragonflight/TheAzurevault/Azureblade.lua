local mod	= DBM:NewMod(2505, "DBM-Party-Dragonflight", 6, 1203)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(186739)
mod:SetEncounterID(2585)
--mod:SetUsedIcons(1, 2, 3)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 372222 385578 384223 373932 384132",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 384132",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, number of images spawned for tracking
--TODO, change arcane orb to personal alert if target scanner works
--TODO, timers restart on overwhelming energy end? Does timer for next overwhelming start at cast of previous, or end of previous?
local warnSummonDraconicImage					= mod:NewSpellAnnounce(384223, 3)

local specWarnArcaneSlicer						= mod:NewSpecialWarningSpell(372222, nil, nil, nil, 1, 2)
local specWarnArcaneOrb							= mod:NewSpecialWarningDodge(385578, nil, nil, nil, 2, 2)
local yellArcaneOrb								= mod:NewYell(385578)
local specWarnIllusionaryBolt					= mod:NewSpecialWarningInterrupt(373932, "HasInterrupt", nil, nil, 1, 2)
local specWarnOverwhelmingEnergy				= mod:NewSpecialWarningSpell(384132, nil, nil, nil, 2, 2)
--local specWarnGTFO							= mod:NewSpecialWarningGTFO(340324, nil, nil, nil, 1, 8)

local timerArcaneSlicerCD						= mod:NewAITimer(35, 372222, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerArcaneOrbCD							= mod:NewAITimer(35, 385578, nil, nil, nil, 3)
local timerSummonDraconicImageCD				= mod:NewAITimer(35, 384223, nil, nil, nil, 1)
local timerOverwhelmingenergyCD					= mod:NewAITimer(35, 384132, nil, nil, nil, 6)

--local berserkTimer							= mod:NewBerserkTimer(600)

--mod:AddRangeFrameOption("8")
--mod:AddInfoFrameOption(361651, true)
--mod:AddSetIconOption("SetIconOnStaggeringBarrage", 361018, true, false, {1, 2, 3})

function mod:EruptionTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellArcaneOrb:Yell()
	end
end

function mod:OnCombatStart(delay)
	timerArcaneSlicerCD:Start(1-delay)
	timerArcaneOrbCD:Start(1-delay)
	timerSummonDraconicImageCD:Start(1-delay)
	timerOverwhelmingenergyCD:Start(1-delay)
end

--function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 372222 then
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnArcaneSlicer:Show()
			specWarnArcaneSlicer:Play("shockwave")
		end
		timerArcaneSlicerCD:Start()
	elseif spellId == 385578 then
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "EruptionTarget", 0.1, 8, true)
		specWarnArcaneOrb:Show()
		specWarnArcaneOrb:Play("watchorb")
		timerArcaneOrbCD:Start()
	elseif spellId == 384223 then
		warnSummonDraconicImage:Show()
		timerSummonDraconicImageCD:Start()
	elseif spellId == 373932 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnIllusionaryBolt:Show(args.sourceName)
		specWarnIllusionaryBolt:Play("kickcast")
	elseif spellId == 384132 then
		timerArcaneSlicerCD:Stop()
		timerArcaneOrbCD:Stop()
		timerSummonDraconicImageCD:Stop()
		specWarnOverwhelmingEnergy:Show()
		specWarnOverwhelmingEnergy:Play("phasechange")
		--timerOverwhelmingenergyCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 362805 then

	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 361966 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 384132 then
		timerArcaneSlicerCD:Start(2)
		timerArcaneOrbCD:Start(2)
		timerSummonDraconicImageCD:Start(2)
		timerOverwhelmingenergyCD:Start(2)
	end
end

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 190187 then--Draconic Image

	elseif cid == 192955 or cid == 190967 then--Draconic Illusion

	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 340324 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
