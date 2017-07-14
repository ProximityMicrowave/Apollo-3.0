local AR = apollo.rogue
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

local function attackBasicCondition(spellName, target)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and ((affectingCombat(target)) or not IsInInstance())
end

local function attackBuffCondition(spellName, target)
	return (not isFriend(target)) and (notDead(target)) and (inRange("shred",target)) and (isUsable(spellName))
end

local function attackSinisterStrike(target)
	local spellName = "Sinister Strike"
	local spellCast = (not IsStealthed()) and (getEnergy() >= 45) and (attackBasicCondition(spellName, target))
	
	return spellCast, spellName
end

local function attackAutoAttack(target)
	local spellName = "Auto Attack"
	local spellCast = (InCombatLockdown()) and (not IsStealthed()) and (not IsCurrentSpell(spellName)) and (not isFriend(target)) and (notDead(target))  and ((affectingCombat(target)) or not IsInInstance())
	
	return spellCast, spellName
end

local function attackPoisonedKnife(target)
	local spellName = "Poisoned Knife"
	local spellCast = (attackBasicCondition(spellName, target)) and (not IsStealthed()) and (getEnergy() >= UnitPowerMax("player",3) - 10)
	
	return spellCast, spellName
end

local function attackStealth(target)
	local spellName = "Stealth"
	local spellCast = (not IsStealthed()) and (inRange("Poisoned Knife",target)) and (isUsable(spellName))
	
	return spellCast, spellName
end

local function buffDeadlyPoison(target)
	local spellName = "Deadly Poison"
	local unitBuff = UnitBuff("player","Deadly Poison",nil,"PLAYER")
	
	AR.lastDeadlyPoison = AR.lastDeadlyPoison or 0
	if UnitCastingInfo("player") == "Deadly Poison" then AR.lastDeadlyPoison = GetTime(); end;
	
	local spellCast = (not unitBuff) and (not IsStealthed()) and (AR.lastDeadlyPoison < GetTime() - 1)
	
	return spellCast, spellName
end

local function buffCripplingPoison(target)
	local spellName = "Crippling Poison"
	local unitBuff = UnitBuff("player","Crippling Poison",nil,"PLAYER")
	
	AR.lastCripplingoison = AR.lastCripplingoison or 0
	if UnitCastingInfo("player") == "Crippling Poison" then AR.lastCripplingoison = GetTime(); end;
	
	local spellCast = (not unitBuff) and (not IsStealthed()) and (AR.lastCripplingoison < GetTime() - 1)
	
	return spellCast, spellName
end

local function attackGarrote(target)
	local spellName = "Garrote"
--	local unitDebuff = UnitDebuff("target","Garrote",nil,"PLAYER")
	local spellCast = (not IsStealthed()) and (attackBasicCondition(spellName, target))
	
	return spellCast, spellName
end

local function attackEviscerate(target)
	local spellName = "Eviscerate"
	local spellCast = (attackBasicCondition(spellName, target)) and (getComboPoints() >= 4) and (not IsStealthed())
	
	return spellCast, spellName
end

local function attackRupture(target)
	local spellName = "Rupture"
	local unitDebuff = UnitDebuff("target","Rupture",nil,"PLAYER")
	local spellCast = (not unitDebuff) and (attackBasicCondition(spellName, target)) and (getComboPoints() >= 4) and (not IsStealthed())
	
	return spellCast, spellName
end

local function attackCheapShot(target)
	local spellName = "Cheap Shot"
	local spellCast = (attackBasicCondition(spellName, target)) and (IsStealthed())
	
	return spellCast, spellName
end

local function buffCrimsonVial(target)
	local spellName = "Crimson Vial"
	local spellCast = (unitHealthPct("player") < .7) and (isUsable(spellName)) and (offCooldown(spellName))
	
	return spellCast, spellName
end

local function attackKick(target)
	local spellName = "Kick"
	local spellCast = (canInterupt(target)) and (attackBasicCondition(spellName, target))
	
	return spellCast, spellName
end

function apollo.rogue.assassinationSkillRotation()
	local skillRotation = {
		--DOESN'T MATTER--
		buffCrimsonVial,
		--IS STEALTHED--
		attackCheapShot,
		--NOT STEALTHED--
		buffDeadlyPoison,
		buffCripplingPoison,
		attackKick,
		attackRupture,
		attackEviscerate,
		attackGarrote,
		attackSinisterStrike,
		attackPoisonedKnife,
		attackStealth,
		attackAutoAttack,
		
	}
	
	return skillRotation
end