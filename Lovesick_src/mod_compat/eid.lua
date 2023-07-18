local EIDRegistry = {}
local rickId = Isaac.GetPlayerTypeByName("Rick")
local rickbId = Isaac.GetPlayerTypeByName("Rick_b",true)

---register items to EID
function EIDRegistry.register()
	if EID then
		-- EID function calls here ...
		EID:addCollectible(Isaac.GetItemIdByName("Locked Heart"), "Charges based on your stress, higher means faster. #On use, spend a key to gain 7.5 charges of shielding and enter Adrenaline rush.#Shield gain is doubled in Womb or deeper. #Shield is depleted by co-op players and you.", "Locked Heart", en_us)
		EID:addCollectible(Isaac.GetItemIdByName("Painting Kit"), "{{ArrowUp}}Tears Up. #{{ArrowUp}}ShotSpeed Up. #Your tears now rotate from various effects: Brain worm, Flat Stone, Rubber Cement and Toxic Splash.", "Painting Kit", en_us)
		EID:addCollectible(Isaac.GetItemIdByName("Box of Leftovers"), "Adds one key and bomb on pickup. #Spawns a trinket every time you kill a boss. #You smelts your current trinkets when changing stage", "Box of Leftovers", en_us)
		EID:addCollectible(Isaac.GetItemIdByName("Morphine"), "On use, you wont take DMG from any source in the room for 1 minute. #If you get hit your tears are reduced temporary.", "Morphine", en_us)
		EID:addCollectible(Isaac.GetItemIdByName("Arrest Warrant"), "Adds 3 coins on pickup. #Bosses and champions now drop a bounty. #Getting hit removes some pickups from your highest amount respectively.", "Arrest Warrant", en_us)
		EID:addCollectible(Isaac.GetItemIdByName("Sunset Clock"), "After the first 90 seconds of the stage, trigger the Sun card effect and spawn a soul heart. #Lowers some stats till you wake. #Also heals when first pickup.", "Sunset Clock", en_us)
		EID:addCollectible(Isaac.GetItemIdByName("Birthday Cake"), "{{ArrowUp}}HP up. #Clearing a room  give a mini Isaac depending with is size.", "Birthday Cake", en_us)
		EID:addCollectible(Isaac.GetItemIdByName("Kind Soul"), "Adds a familiar that has hp and can die. #Can convert a golden chest into a eternal chest once per floor while pressing drop button.", "Kind Soul", en_us)
		EID:addCollectible(Isaac.GetItemIdByName("Neck Gaiter"), "{{ArrowUp}}Damage Up. #{{ArrowUp}}Speed Up. #Grants a blck heart on pickup. #You are a ninja now.", "Kind Soul", en_us)
		EID:addCollectible(Isaac.GetItemIdByName("Love Letter"), "{{ArrowUp}}Insane tears up that vanish over time. #{{ArrowUp}}Love Up.", "Love Letter", en_us)
		EID:addBirthright(rickId, "Doubles your max stress cap. #Significantly more dmg output, but also more stress dmg. #Locked heart grants more shield as it scales with max stress. #On low shield, enemies killed with stress drop temporary hearts, use them to charge and trigger heart effects")
		EID:addTrinket(Isaac.GetTrinketIdByName("Paper Rose"), "{{ArrowDown}}-0.25% DMG Down. #{{ArrowUp}}{{ArrowDown}}Luck-1 * 1.25 and . #Also some dmg turns into luck.", "Paper Rose", en_us)
	end
	
end
return EIDRegistry