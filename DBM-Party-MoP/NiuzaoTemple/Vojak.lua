local mod	= DBM:NewMod(738, "DBM-Party-MoP", 6, 324)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(61634)
mod:SetEncounterID(1502)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_REMOVED 120402 120759",
--	"CHAT_MSG_MONSTER_YELL",
	"RAID_BOSS_EMOTE"
)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 120759",
	"SPELL_CAST_START 120789"
)

local warnCausticTar			= mod:NewSpellAnnounce("ej6278", 2)--Announce a tar is ready to be used. (may be spammy and turned off by default if it is)
local warnBombard				= mod:NewSpellAnnounce(120200, 3)
local warnDashingStrike			= mod:NewSpellAnnounce(120789, 3)
local warnThousandBlades		= mod:NewSpellAnnounce(120759, 4)

local specWarnThousandBlades	= mod:NewSpecialWarningRun(120759, "Melee", nil, 2, 4, 2)

--local timerWaveCD				= mod:NewTimer(12, "TimerWave", 69076)--Not wave timers in traditional sense. They are non stop, this is for when he activates certain mob types.
local timerBombard				= mod:NewBuffActiveTimer(15, 120200, nil, nil, 6)
local timerBombardCD			= mod:NewCDTimer(42, 120200, nil, nil, nil, 3)
local timerDashingStrikeCD		= mod:NewCDTimer(13.5, 120789, nil, nil, nil, 3)--14-16 second variation
--local timerThousandBladesCD		= mod:NewCDTimer(15, 120759, nil, nil, nil, 2)
local timerThousandBlades		= mod:NewBuffActiveTimer(4, 120759, nil, nil, nil, 2)

--local Swarmers 		= DBM:EJ_GetSectionInfo(6280)
--local Demolishers 	= DBM:EJ_GetSectionInfo(6282)
--local Warriors	 	= DBM:EJ_GetSectionInfo(6283)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 120759 then
		warnThousandBlades:Show()
		if self.Options.SpecWarn120759run then
			specWarnThousandBlades:Show()
			specWarnThousandBlades:Play("justrun")
		else
			warnThousandBlades:Show()
		end
		timerThousandBlades:Start()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 120789 then
		warnDashingStrike:Show()
		timerDashingStrikeCD:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 120402 then-- NPC only buff, player's buff is 123032
		warnCausticTar:Show()
	elseif args.spellId == 120759 then
		--timerThousandBladesCD:Start()
	end
end

--[[
function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.WaveStart or msg:find(L.WaveStart) then -- all timer and mob not confirmed, maybe useless.
		timerWaveCD:Start(8, Swarmers)
		timerWaveCD:Start(65, Demolishers)
		timerWaveCD:Start(102, Swarmers..", "..Warriors)
		timerWaveCD:Start(160, Demolishers..", "..Warriors)
	end
end--]]

function mod:RAID_BOSS_EMOTE(msg)
	if msg:find("spell:120559") then -- Bombard seems to be not related with wave status.
		warnBombard:Show()
		timerBombard:Start()
		timerBombardCD:Start()
	end
end
