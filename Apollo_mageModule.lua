local AD = apollo.druid
local notDead = apollo.notDead
local inRange = apollo.inRange
local isUsable = apollo.isUsable
local missingHealth = apollo.missingHealth
local unitHealthPct = apollo.unitHealthPct
local hasThreat = apollo.hasThreat
local isFriend = apollo.isFriend
local offCooldown = apollo.offCooldown
local getEnergy = apollo.getEnergy
local getComboPoints = apollo.getComboPoints
local canInterupt = apollo.canInterupt
local lowMana = apollo.lowMana
local isMoving = apollo.isMoving
local affectingCombat = apollo.affectingCombat
local isTank = apollo.isTank

local function attackBaseCondition(spellName, target)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and ((affectingCombat(target)) or not IsInInstance())
end

local function healBaseCondition(spellName, target)
	return (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (not lowMana()) and (offCooldown(spellName))
end

local function healIceBarrier(target)
	local spellName = "Ice Barrier"
	local iceBarrier = UnitBuff("player","Ice Barrier")
	local spellCast = (isFriend(target)) and (notDead(target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (UnitIsUnit("player",target)) and (not iceBarrier) and (InCombatLockdown())
	
	return spellCast, spellName
end

local function attackFireball(target)
	local spellName = "Fireball"
	local iceFloes = UnitBuff("player","Ice Floes")
	local spellCast = attackBaseCondition(spellName, target) and ((not isMoving("player")) or iceFloes)
	
	return spellCast, spellName
end

local function attackScorch(target)
	local spellName = "Scorch"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackFireBlast(target)
	local spellName = "Fire Blast"
	local heatingUp = UnitBuff("player","Heating Up")
	local spellCast = attackBaseCondition(spellName, target) and heatingUp
	
	return spellCast, spellName
end

local function attackFlameOn(target)
	local spellName = "Flame On"
	local heatingUp = UnitBuff("player","Heating Up")
	local spellCast = (isFriend(target)) and (notDead(target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (UnitIsUnit("player",target)) and heatingUp
	
	return spellCast, spellName
end

local function attackPyroblast(target)
	local spellName = "Pyroblast"
	local hotStreak = UnitBuff("player","Hot Streak!")
	local spellCast = attackBaseCondition(spellName, target) and hotStreak
	
	return spellCast, spellName
end

function apollo.mage.fireSkillRotation()
	local skillRotation = {
		healIceBarrier,
		attackPyroblast,
		attackFireBlast,
		attackFlameOn,
		attackFireball,
		attackScorch,
	}

	return skillRotation
end