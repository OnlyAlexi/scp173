-- supper hacky implementation of an enemy that only moves whilst not being observed/looked at
-- creates a transparent clone of the players head and makes it always face the SCP, compares that to the rotation of the actual players head
-- to figure out of the SCP is in view

-- there are definitely way better ways to go about implementing this but I had a lot of fun making this :')))

local Players = game.Players
local SCP173 = script.Parent
local PathfindingService = game:GetService("PathfindingService")
local RStorage = game:GetService("ReplicatedStorage")
local Remotes = RStorage.Remotes
local PeopleLooking = 0

function lookAtScp(head)
	if(head and head.Parent.Head) then
	while(head.Parent.Head) do
		wait(0.01)
		head.CFrame = CFrame.new(head.Parent.Head.Position, SCP173.Position)
		end
	end
end

function SetupVisibility(player) -- this is fired whenever a player spawns, unless they're in the menu in which no head is created, so
	-- that player is not targetted
	local SecondHead = player.Character:FindFirstChild("Head"):Clone()
	SecondHead.Transparency = 1
	SecondHead.Parent = player.Character
	SecondHead:ClearAllChildren()
	SecondHead.Name = "SCPHEAD"
	SecondHead.CanCollide = false
	SecondHead.Anchored = true
	coroutine.resume(coroutine.create(lookAtScp), SecondHead)
end

function GetTorso() -- function used to find the closest player
local CurrentClosest = script.Parent
local TempDistance = 9999
	for i,v in pairs (game.Players:GetChildren()) do
		for p,q in pairs(v.Character:GetChildren()) do	
			if(q.Name == "HumanoidRootPart" and q.Parent.Humanoid.Health ~= 0 and q.Parent:FindFirstChild("SCPHEAD")) then
		if((q.Position - SCP173.Position).Magnitude < TempDistance) then
			CurrentClosest = q
			TempDistance = (q.Position - SCP173.Position).Magnitude 
				end
			end
		end
	end
	return CurrentClosest
end

function CheckForPeople() -- used to check if anyone is looking at the SCP, SCP will only move if "PeopleLooking" is 0
	while wait(0.01) do
		for i,v in pairs(game.Players:GetChildren()) do
			local Player = workspace:FindFirstChild(v.Name)
			if Player then
				local Hum = Player:FindFirstChild("Humanoid")
				if(Hum) then
				for q,p in pairs(Player:GetChildren()) do
						if(Player:FindFirstChild("Humanoid").Health > 0) then
							if(Player:FindFirstChild("Head") ~= nil) then
								if(Player:FindFirstChild("SCPHEAD") ~= nil) then
					if(Player:FindFirstChild("Head").Orientation.Y > Player:FindFirstChild("SCPHEAD").Orientation.Y - 68 and Player:FindFirstChild("Head").Orientation.Y < Player:FindFirstChild("SCPHEAD").Orientation.Y + 68) then
									PeopleLooking = PeopleLooking + 1
									script.Parent.Slide:Stop()
								else 
									PeopleLooking = 0
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function MoveMain()
	spawn(CheckForPeople)
	while wait(0.01) do
		if(PeopleLooking == 0) then
			local ClosestTorso = GetTorso()
			local Hum = ClosestTorso.Parent:FindFirstChild("Humanoid")
			if(Hum) then
		if(ClosestTorso.Parent:FindFirstChild("SCPHEAD") and PeopleLooking == 0 and ClosestTorso.Parent:FindFirstChild("Humanoid").Health > 0) then
					local Path = PathfindingService:CreatePath({
						AgentCanJump = false,
						Costs = {
							WaypointSpacing = 0.01, -- move in very small increments, impression that it slides across the ground
						}
					})
			Path:ComputeAsync(script.Parent.Position, ClosestTorso.Position)
			for i,v in pairs(Path:GetWaypoints()) do
				if(PeopleLooking == 0) then
							wait(0.05)
							if(script.Parent.Slide.Playing == false) then
								script.Parent.Slide:Play()
							end
					if((ClosestTorso.Position - script.Parent.Position).magnitude < 5) then
								script.Parent.Kill:Play()
						end
					script.Parent.Position = Vector3.new(v.Position.x, 4.948, v.Position.z)
							script.Parent.CFrame = CFrame.new(script.Parent.Position, Vector3.new(ClosestTorso.Position.X, 4.948, ClosestTorso.Position.Z))
							-- its supposed to always stand up straight
						end
					end
				end
			end
		end
	end
end

Remotes.SetupVisibility.OnServerEvent:Connect(SetupVisibility)


MoveMain()
