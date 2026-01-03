--[[
    MaterialPickup System
    Server Script
    Parent: BasePart or Model

    Description:
    Handles material pickup when a player touches the object.
    Grants materials based on a set value and enforces dynamic
    inventory limits based on the player's BagLevel.
]]

local Players = game:GetService("Players")
local part = script.Parent

-- Ensure debounce attribute exists
if part:GetAttribute("Collected") == nil then
	part:SetAttribute("Collected", false)
end

-- Safely get material value (Attribute -> IntValue fallback)
local function getMaterialValue()
	local value = part:GetAttribute("MaterialValue")
	if value == nil then
		local child = part:FindFirstChild("MaterialValue")
		if child and child:IsA("IntValue") then
			value = child.Value
		end
	end
	return tonumber(value) or 1
end

-- Find player from touched instance
local function findPlayerFromHit(hit)
	local current = hit.Parent
	while current do
		local player = Players:GetPlayerFromCharacter(current)
		if player then
			return player
		end
		current = current.Parent
	end
	return nil
end

-- Get max materials based on BagLevel
local function getMaxMaterials(player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return 10 end

	local bagLevel = stats:FindFirstChild("BagLevel")
	local level = bagLevel and bagLevel.Value or 0

	return 10 + (level * 5) -- Base + scaling
end

-- Handle touch event
local function onTouched(hit)
	-- Debounce check
	if part:GetAttribute("Collected") then return end

	local player = findPlayerFromHit(hit)
	if not player then return end

	local stats = player:FindFirstChild("leaderstats")
	if not stats then return end

	local materials = stats:FindFirstChild("Materials")
	if not materials then return end

	local maxMaterials = getMaxMaterials(player)

	-- Inventory full check (does NOT lock pickup)
	if materials.Value >= maxMaterials then
		print(("[Material] %s inventory full (%d/%d)"):format(
			player.Name, materials.Value, maxMaterials
			))
		return
	end

	-- Lock pickup
	part:SetAttribute("Collected", true)

	local amount = getMaterialValue()
	materials.Value = math.min(materials.Value + amount, maxMaterials)

	print(("[Material] %s picked up %s (+%d) | %d/%d"):format(
		player.Name,
		part.Name,
		amount,
		materials.Value,
		maxMaterials
		))

	-- Hide & disable collision before destroy
	if part:IsA("BasePart") then
		part.CanTouch = false
		part.Transparency = 1
	elseif part:IsA("Model") then
		for _, obj in ipairs(part:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.CanTouch = false
				obj.Transparency = 1
			end
		end
	end

	task.wait(0.05)

	if part and part.Parent then
		part:Destroy()
	end
end

-- Connect touch events
if part:IsA("BasePart") then
	part.Touched:Connect(onTouched)

elseif part:IsA("Model") then
	if part.PrimaryPart then
		part.PrimaryPart.Touched:Connect(onTouched)
	else
		for _, obj in ipairs(part:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.Touched:Connect(onTouched)
			end
		end
		warn("MaterialPickup: Model has no PrimaryPart, connected all BaseParts -> " .. part.Name)
	end

else
	warn("MaterialPickup: Unsupported parent type -> " .. tostring(part))
end
