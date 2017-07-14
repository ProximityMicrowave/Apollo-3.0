local AW = apollo.warlock
local notDead = apollo.notDead
local inRange = apollo.inRange
local isUsable = apollo.isUsable
local missingHealth = apollo.missingHealth
local unitHealthPct = apollo.unitHealthPct
local hasThreat = apollo.hasThreat
local isFriend = apollo.isFriend
local offCooldown = apollo.offCooldown
local getEnergy = apollo.getEnergy
local getFury = apollo.getFury
local canInterupt = apollo.canInterupt
local lowMan = apollo.lowMana
local isMoving = apollo.isMoving
local affectingCombat = apollo.affectingCombat
local isTank = apollo.isTank

local function unitManaPct(target)
	local playerMana = UnitPower("player",0)
	local playerManaMax = UnitPowerMax("player",0)
	local playerPercentMana = playerMana / playerManaMax
	
	return playerPercentMana
end

local function attackBaseCondition(spellName, target)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (unitManaPct() > .2) and ((affectingCombat(target)) or not IsInInstance())
end

local function healBaseCondition(spellName, target)
	return (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (unitManaPct() > .2)
end

local function afflictionSoulstone(target)
	local spellName = "Soulstone"
	local spellCast = healBaseCondition(spellName, target) and UnitIsUnit(target,"player") and (not IsInInstance())

	return spellCast, spellName
end

local function afflictionManaTap(target)
	local spellName = "Mana Tap"
	local unitBuff = UnitBuff("Mana Tap", "player")
	AW.lastManaTap = AW.lastManaTap or 0
	if UnitCastingInfo("player") == "Create Healthstone" then AW.lastManaTap = GetTime(); end;
	local spellCast = (isUsable(spellName)) and (offCooldown(spellName)) and (unitManaPct() > .2) and (not isFriend(target)) and (not unitBuff) and (unitManaPct("player") > .75) and (AW.lastCreateHealthstone < GetTime() - .1)

	return spellCast, spellName
end

local function afflictionCreateHealthstone(target)
	local spellName = "Create Healthstone"
	AW.lastCreateHealthstone = AW.lastCreateHealthstone or 0
	if UnitCastingInfo("player") == "Create Healthstone" then AW.lastCreateHealthstone = GetTime(); end;
	
	local spellCast = (isUsable(spellName)) and (offCooldown(spellName)) and (unitManaPct() > .2) and (GetItemCount("Healthstone") == 0) and (AW.lastCreateHealthstone < GetTime() - .1)

	return spellCast, spellName
end

local function afflictionDrainLife(target)
	local spellName = "Drain Life"
	local spellCast = attackBaseCondition(spellName, target)

	return spellCast, spellName
end

local function afflictionHaunt(target)
	local spellName = "Haunt"
	local spellCast = attackBaseCondition(spellName, target)

	return spellCast, spellName
end

local function afflictionCorruption(target)
	local spellName = "Corruption"
	local unitDebuff,_,_,_,_,_,expireTime = UnitDebuff("target","Corruption",nil,"PLAYER")
	if expireTime == null then expireTime = 0
	elseif expireTime == 0 then expireTime = 20
	else expireTime = expireTime - GetTime(); end;
	
	local spellCast = attackBaseCondition(spellName, target) and (expireTime <= 4)
	
	return spellCast, spellName
end

local function afflictionAgony(target)
	local spellName = "Agony"
	local unitDebuff,_,_,_,_,_,expireTime = UnitDebuff("target","Agony",nil,"PLAYER")
	expireTime = expireTime or 0
	expireTime = expireTime - GetTime()
	
	local spellCast = attackBaseCondition(spellName, target) and (expireTime <= 4)

	return spellCast, spellName
end

local function afflictionUnstableAffliction(target)
	local spellName = "Unstable Affliction"
	local unitDebuff,_,_,_,_,_,expireTime = UnitDebuff("target","Unstable Affliction",nil,"PLAYER")
	expireTime = expireTime or 0
	expireTime = expireTime - GetTime()
	local soulShards = UnitPower("player",7)
	AW.lastUnstableAffliction = AW.lastUnstableAffliction or 0
	if UnitCastingInfo("player") == "Unstable Affliction" then AW.lastUnstableAffliction = GetTime(); end;
	
	local spellCast = attackBaseCondition(spellName, target) and ((expireTime <= 4 and AW.lastUnstableAffliction < GetTime() - .1) or (soulShards >= 5))

	return spellCast, spellName
end

function apollo.warlock.afflictionSkillRotation()
	local skillRotation = {
		apollo.healHealthstone,
		afflictionManaTap,
		afflictionHaunt,
		afflictionAgony,
		afflictionCorruption,
		afflictionUnstableAffliction,
		afflictionDrainLife,
		afflictionSoulstone,
		afflictionCreateHealthstone,
	}
	return skillRotation
end