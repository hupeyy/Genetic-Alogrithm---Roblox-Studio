-- Huge help from BRicey763 Parkour AI project!

local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local numRays = 9
local rayAngle = math.pi / (numRays - 1)
local rayLength = 100


-- Neural Network Hyperparameters
local numInputs = numRays -- Number of input nodes (same as the number of rays)
local numOutputs = 1 -- Number of output nodes (rotation angle)
local mutationRate = .1
local DUMMY_MODEL = ServerStorage.Car
local START = workspace.Start
local FINISH = workspace.Finish
local GEN_SIZE = 24

-- Random number generator
local rng = Random.new()

-- Function to perform raycast
local function getInputs(vehicle: Model)
	local raycastDistances = {}
	local raycastHits = {}  -- Store the hit objects
	
	local vehicleReference = vehicle.Chassis
	local forwardVector = vehicleReference.CFrame

	for i = 1, numRays do
		local currentAngle = rayAngle * i
		local cosAngle = math.cos(currentAngle)
		local sinAngle = math.sin(currentAngle)

		local rayDirection = Vector3.new(
			forwardVector.x * cosAngle + forwardVector.z * sinAngle, -- X Direction
			0, -- Y Direction (keep it at 0 as we don't need vertical rays)
			forwardVector.x * sinAngle - forwardVector.z * cosAngle -- Z Direction
		)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = {workspace.Track} -- Only scan for track parts

		local raycastResult = workspace:Raycast(vehicleReference.Position, rayDirection * rayLength, raycastParams)

		if raycastResult then
			raycastDistances[i] = ((raycastResult.Position - vehicleReference.Position).magnitude / rayLength)
		else
			raycastDistances[i] = 1.0 -- Set a default distance if no hit (normalized to 1)
		end
	end

	return raycastDistances
end

local function getWeights(inputs, genes)
	local weights = {}
	
	for i = 1, numRays do
		table.insert(weights, inputs[i] * genes[i])
	end
	
	return weights
end

local function getAction(weights)
	local sum = 0
	for i in weights do
		sum += weights[i]
	end

	return sum
end


local function randomGenes()
	local genes = {}
	for i = 1, numInputs do
		table.insert(genes, rng:NextNumber(-1,1))
	end
	return genes
end


local function simulateVehicle(genes)
	local dummy = DUMMY_MODEL:Clone()
	dummy.Parent = workspace
	dummy:PivotTo(START.CFrame)
	local connection
	connection = RunService.Stepped:Connect(function()
		if not dummy.Parent then
			connection:Disconnect()
			return
		end
		local inputs = getInputs(dummy)
		local weights = getWeights(inputs, genes)
		local orientation = getAction(weights)
		
		dummy.VehicleSeat.Steer = orientation
		dummy.VehicleSeat.Throttle = 2
		
	end)
	return dummy
end

local function calculateFitness(dummy: Model)
	-- Calculate distance between the model and FINISH
	local distance = (dummy.Chassis.Position - FINISH.Position).Magnitude
	return distance
end

local function crossover(p1, p2)
	-- Pick a random index
	local crossoverPt = rng:NextInteger(1, #p1)
	-- We have to use two moves: one for the first slice, one for the second
	local child1 = table.move(p1, 1, crossoverPt, 1, {})
	table.move(p1, crossoverPt + 1, #p2, crossoverPt + 1, child1)
	-- We repeat this process again for the other child, creating two unqiue genomes 
	local child2 = table.move(p2, 1, crossoverPt, 1, {})
	table.move(p2, crossoverPt + 1, #p2, crossoverPt + 1, child2)
	return child1, child2
end

local function mutate(gene)
	local idx = rng:NextInteger(1, numRays)
	gene[idx] = rng:NextNumber(-1, 1)
end

local function evolve()
	local genes = {}
	
	-- First generation
	for i = 1, GEN_SIZE do
		table.insert(genes, randomGenes())
	end
	
	local bestScore = math.huge
	local scores = {}
	
	
	for gen = 1, math.huge do
		print(string.format("Generation %i; Best Fitness Score: %f", gen, bestScore))
		
		local dummies = {}
		PhysicsService:RegisterCollisionGroup("Car")
		
		
		-- Simulate each vehicle in generation
		for i = 1, GEN_SIZE do
			dummies[i] = simulateVehicle(genes[i])
			
			-- Prevents each vehicle with colliding with each other
			for i, v in ipairs(dummies[i]:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CollisionGroup = "Car"
				end
			end
		end
		
		PhysicsService:CollisionGroupSetCollidable("Car", "Car", false)
		
		wait(15)
		
		for i = 1, #dummies do
			table.insert(scores, {calculateFitness(dummies[i]), genes[i]})
			dummies[i]:Destroy()
		end
		
		table.clear(dummies)
		table.clear(genes)
		
		-- Sort scores
		table.sort(scores, function(a,b)
			return a[1] < b[1]
		end)
		
		if bestScore > scores[1][1] then
			bestScore = scores[1][1]
		end
		
		for i = 1, GEN_SIZE / 2 - 1, 2 do
			local g1 = scores[i][2]
			local g2 = scores[i + 1][2]
			local c1, c2 = crossover(g1, g2)
			table.insert(genes, c1)
			table.insert(genes, c2)
			table.insert(genes, g1)
			table.insert(genes, g2)
		end
		
		for _, gene in genes do
			if rng:NextNumber(0,1) < mutationRate then
				mutate(gene)
			end
		end
		
		table.clear(scores)
	end
end

evolve()