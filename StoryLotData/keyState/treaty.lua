-- This story event defines a war breaking out between two kingdoms.

local Character = sl.DataObjects.Character
local Attribute = sl.DataObjects.Attribute
local Relationship = sl.DataObjects.Relationship

-- Definition of the desired world state

local world = sl.DataObjects.World()

local k1, k2

k1 = Character(false)
k1:addAttribute(Attribute("Fairness", 3))	-- Fairness vs cheating
k1:addAttribute(Attribute("Loyalty", 2))	-- Loyalty 	vs betrayal

k2 = Character(false)
k2:addAttribute(Attribute("Fairness", 2))
k2:addAttribute(Attribute("Loyalty", 4))

world:addCharacter(k1)
world:addCharacter(k2)

-- Set up Relationships
local r12, r21

-- Set up relationships of Kingdom 1 to the other two.
r12 = Relationship(k2:getId())
r12:addAttributeModifier(Attribute("Fairness", 2))
r12:addAttributeModifier(Attribute("Loyalty", 4))

k1:addRelationship(r12)

-- Set up relationships of Kingdom 2 to the other two.
r21 = Relationship(k1:getId())
r21:addAttributeModifier(Attribute("Fairness", 1))
r21:addAttributeModifier(Attribute("Loyalty", 1))

-- Assign relationships
k2:addRelationship(r21)

-- Definition of the story edge

local edge = {}

return world, edge