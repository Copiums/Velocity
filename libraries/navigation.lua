local navigation: table = {};
local cellSize: number = 3;
local halfCell: number = 1.5;
local keySpan: number = 8192;
local keyHalf: number = 4096;
local keyPlane: number = 67108864;
local faces: table = {
	{1, 0, 0},
	{-1, 0, 0},
	{0, 1, 0},
	{0, -1, 0},
	{0, 0, 1},
	{0, 0, -1}
};
local flats: table = {
	{1, 0, 0},
	{-1, 0, 0},
	{0, 0, 1},
	{0, 0, -1},
	{1, 0, 1},
	{1, 0, -1},
	{-1, 0, 1},
	{-1, 0, -1}
};
local saves: table = {
	{1, 0, 0},
	{-1, 0, 0},
	{0, 0, 1},
	{0, 0, -1},
	{1, 0, 1},
	{-1, 0, -1},
	{-1, 0, 1},
	{1, 0, -1},
	{0, -1, 0}
};
local leaps: table = {
	{2, 0, 1},
	{2, 0, -1},
	{-2, 0, 1},
	{-2, 0, -1},
	{1, 0, 2},
	{-1, 0, 2},
	{1, 0, -2},
	{-1, 0, -2}
};
local corners: table = {};

for x: number = -1, 1 do
	for y: number = -1, 1 do
		for z: number = -1, 1 do
			if math.abs(x) + math.abs(y) + math.abs(z) > 1 then
				table.insert(corners, {x, y, z});
			end;
		end;
	end;
end;

export type Grid = Vector3;
export type Placement = {
	Grid: Grid,
	Position: Vector3,
	Mode: string,
	PlacementType: string,
	SupportGrid: Grid?,
	Normal: Vector3?,
	AimPosition: Vector3?,
	AimDirection: Vector3?,
	Distance: number,
	Valid: boolean,
	Reason: string?
};
export type Action = {
	Type: string,
	Grid: Grid,
	Position: Vector3,
	Time: number,
	Duration: number,
	PlacementType: string?,
	Preconditions: {[string]: any}?
};
export type Result = {
	Success: boolean,
	Partial: boolean,
	Reason: string,
	Mode: string,
	WalkingPath: {Vector3},
	BridgePath: {Placement},
	Actions: {Action},
	Cost: number,
	Distance: number,
	BlocksUsed: number,
	Damage: number
};

navigation.GridSize = cellSize;
navigation.CellBounds = Vector3.new(cellSize - 0.1, cellSize - 0.1, cellSize - 0.1);
navigation.Contexts = {};
navigation.Requests = {};
navigation.World = nil;
navigation.DebugAdapter = nil;
navigation.Profiles = {
	["Default"] = {
		["Name"] = "block",
		["Solid"] = true,
		["Support"] = true,
		["Placeable"] = true,
		["Breakable"] = true,
		["Climbable"] = false,
		["Replaceable"] = false,
		["Temporary"] = false,
		["Cost"] = 0
	}
};
navigation.Config = {
	["Agent"] = {
		["Height"] = 5,
		["Radius"] = 1,
		["HipHeight"] = 3,
		["BodyOffset"] = 1,
		["HeadOffset"] = 2.2,
		["HeadRadius"] = 0.6,
		["WalkSpeed"] = 22,
		["JumpVelocity"] = 42.6,
		["Gravity"] = 196.2,
		["Reach"] = 18,
		["PlaceCps"] = 12,
		["Latency"] = 0.08,
		["MaxDrop"] = 27,
		["ImpactLimit"] = 86,
		["DamageScale"] = 0.75,
		["DamageAllowance"] = 0,
		["SafeMargin"] = 1,
		["BlocksAvailable"] = math.huge
	},
	["Costs"] = {
		["Block"] = 1,
		["Jump"] = 0.06,
		["Drop"] = 0.04,
		["Diagonal"] = 0.02,
		["Risk"] = 0.5,
		["Air"] = 0.25,
		["Scarce"] = 4,
		["Elevation"] = 0.25
	},
	["Traversal"] = {
		["Mover"] = "Jump",
		["MaxAirTime"] = 1.75,
		["Margin"] = 1,
		["Rise"] = 1,
		["Instant"] = false
	},
	["Retreat"] = {
		["MaxTime"] = 6,
		["MaxSteps"] = 6000,
		["SafeDistance"] = 40,
		["Weights"] = {
			["Distance"] = 10,
			["Passage"] = 4,
			["Escape"] = 2,
			["Edge"] = 4,
			["Exposure"] = 3,
			["Time"] = 0.5
		}
	},
	["Search"] = {
		["MaxSteps"] = 40000,
		["WalkSteps"] = 40000,
		["Budget"] = 0.012,
		["Weight"] = 1.3,
		["BridgeWeight"] = 2,
		["Fallback"] = false,
		["FieldMargin"] = 16,
		["Tolerance"] = 1,
		["GoalDrop"] = 3,
		["Free"] = true,
		["BridgeWidth"] = 1,
		["Segment"] = 12,
		["Yield"] = true,
		["Smooth"] = true,
		["Bridge"] = true,
		["Tower"] = true,
		["JumpGap"] = true
	},
	["Clutch"] = {
		["Reach"] = 14,
		["MaxFall"] = math.huge,
		["Void"] = true,
		["MaxBlocks"] = 4,
		["MaxChain"] = 3,
		["SampleTime"] = 0.05,
		["MinSurvival"] = 0.55,
		["ReachSteps"] = 16,
		["Scan"] = 90,
		["Width"] = 1,
		["Anchored"] = true,
		["Weights"] = {
			["Survival"] = 100,
			["Damage"] = 0.9,
			["Blocks"] = 4,
			["Escape"] = 6,
			["Distance"] = 0.35
		}
	},
	["Mind"] = {
		["ThinkInterval"] = 0.2,
		["ReactionTime"] = 0.18,
		["ObservationLifetime"] = 8,
		["EnemyLifetime"] = 12,
		["FailureLifetime"] = 60,
		["FailureCooldown"] = 4,
		["MemoryLimit"] = 64,
		["CommitTime"] = 1.5,
		["SwitchMargin"] = 12,
		["FlipWindow"] = 6,
		["GoalTimeout"] = 35,
		["CollectTimeout"] = 15,
		["FightTimeout"] = 8,
		["RecoveryLimit"] = 3,
		["RecoveryWait"] = 3,
		["RecoveryReset"] = 4,
		["PostKillWait"] = 0.8,
		["BasePreference"] = 12,
		["JumpCommitTime"] = 1.2,
		["RangedInterval"] = 1,
		["ArrivalRadius"] = 5,
		["BaseRadius"] = 16,
		["LowHealth"] = 0.4,
		["CriticalHealth"] = 0.22,
		["RecoverHealth"] = 0.7,
		["HighHealth"] = 0.8,
		["BlockReserve"] = 8,
		["TravelBlocks"] = 24,
		["IronReserve"] = 8,
		["DiamondTarget"] = 4,
		["EmeraldTarget"] = 2,
		["ValuableThreshold"] = 20,
		["ResourceWeights"] = {["iron"] = 0.08, ["diamond"] = 5, ["emerald"] = 15},
		["EarlyTime"] = 180,
		["LateTime"] = 600,
		["ThreatRadius"] = 60,
		["LethalRange"] = 18,
		["BedThreatRadius"] = 35,
		["SupportRadius"] = 24,
		["HighGround"] = 6,
		["ChaseSpeed"] = 3,
		["UnknownDamage"] = 30,
		["UnknownArmor"] = 0.25,
		["UnknownEnemyHealth"] = 100,
		["AttackInterval"] = 0.4,
		["ForecastTime"] = 1.2,
		["MaxThreat"] = 45,
		["FightThreshold"] = 12,
		["FinishSupport"] = 1,
		["RouteRiskLimit"] = 65,
		["SafeRouteRisk"] = 30,
		["RouteEnemyRadius"] = 25,
		["RouteSampleLimit"] = 80,
		["PlanTimeout"] = 4,
		["PlanSteps"] = 12000,
		["ReplanInterval"] = 0.5,
		["ReplanMargin"] = 0.15,
		["RepathWindow"] = 10,
		["TargetDrift"] = 0.25,
		["TargetMargin"] = 1,
		["VerifyInterval"] = 1,
		["StuckTime"] = 2.5,
		["ProgressDistance"] = 0.75,
		["OffRoute"] = 6,
		["BreakTimeout"] = 3,
		["PlacementTimeout"] = 0.8,
		["PlacementCooldown"] = 0.16,
		["BuildLimit"] = 8,
		["AvoidPenalty"] = 4,
		["AvoidLifetime"] = 30,
		["Segment"] = 12,
		["ScanInterval"] = 1,
		["DropInterval"] = 0.5,
		["SurfaceLifetime"] = 1,
		["FilterInterval"] = 0.5,
		["ProjectileLifetime"] = 2,
		["DebugLimit"] = 80,
		["DebugInterval"] = 1,
		["Priorities"] = {
			["WaitForSpawn"] = 1000, ["Recover"] = 1000, ["WaitForInformation"] = 120,
			["DefendBed"] = 245, ["ReturnToBase"] = 230, ["Escape"] = 230, ["BuildCover"] = 230,
			["BuildUp"] = 229, ["SurvivalCombat"] = 225, ["Hide"] = 220, ["Finish"] = 290,
			["Harass"] = 150, ["Reposition"] = 140, ["Fight"] = 120, ["CollectResources"] = 65,
			["AttackBed"] = 70, ["SupportTeam"] = 110, ["CollectDrops"] = 85, ["Reassess"] = 1
		},
		["Weights"] = {
			["Enemy"] = 28, ["ExtraEnemy"] = 16, ["Weapon"] = 0.5, ["Elevation"] = 12,
			["Projectile"] = 16, ["Void"] = 30, ["Narrow"] = 22, ["Uncertainty"] = 15,
			["Support"] = 14, ["Cover"] = 10, ["Escape"] = 12, ["Health"] = 35,
			["Equipment"] = 0.6, ["Isolation"] = 14, ["Resources"] = 0.35,
			["NoBed"] = 20, ["Travel"] = 0.12, ["Failure"] = 18, ["Turns"] = 1.5,
			["Jump"] = 6, ["Block"] = 2, ["Time"] = 0.8
		}
	}
};

local gridAxis: (value: number) -> number = function(value: number): number
	return math.round(value / cellSize);
end;

local cellKey: (x: number, y: number, z: number) -> number = function(x: number, y: number, z: number): number
	return (x + keyHalf) * keyPlane + (y + keyHalf) * keySpan + (z + keyHalf);
end;

navigation.CellKey = cellKey;

navigation.WorldToGrid = function(position: Vector3): Vector3
	return Vector3.new(math.round(position.X / cellSize), math.round(position.Y / cellSize), math.round(position.Z / cellSize));
end;

navigation.GridToWorld = function(grid: Vector3): Vector3
	return Vector3.new(grid.X * cellSize, grid.Y * cellSize, grid.Z * cellSize);
end;

navigation.SnapToGrid = function(position: Vector3): Vector3
	return Vector3.new(math.round(position.X / cellSize) * cellSize, math.round(position.Y / cellSize) * cellSize, math.round(position.Z / cellSize) * cellSize);
end;

navigation.SetGridSize = function(size: number): ()
	cellSize = size;
	halfCell = size / 2;
	navigation.GridSize = size;
	navigation.CellBounds = Vector3.new(size - 0.1, size - 0.1, size - 0.1);
end;

local worldClass: table = {};
worldClass.__index = worldClass;

worldClass.Solid = function(self: table, x: number, y: number, z: number): boolean
	local key: number = cellKey(x, y, z);
	if self.Overlay then
		local entry: any = self.Overlay[key];
		if entry ~= nil then
			return entry ~= false;
		end;
	end;

	local learned: number? = self.Learned[key];
	if learned then
		if learned > os.clock() then
			return true;
		end;
		self.Learned[key] = nil;
	end;

	local cached: boolean? = self.Cells[key];
	if cached ~= nil then
		return cached;
	end;

	local solid: boolean = self.Hooks.GetBlock and self.Hooks.GetBlock(x, y, z) and true or false;
	if not solid and self.Hooks.IsSolid then
		solid = self.Hooks.IsSolid(x, y, z) and true or false;
	end;

	self.Cells[key] = solid;
	return solid;
end;

worldClass.Block = function(self: table, x: number, y: number, z: number): any
	local key: number = cellKey(x, y, z);
	if self.Overlay then
		local entry: any = self.Overlay[key];
		if entry ~= nil then
			return entry ~= false and entry or nil;
		end;
	end;

	local cached: any = self.Blocks[key];
	if cached ~= nil then
		return cached ~= false and cached or nil;
	end;

	local block: any = self.Hooks.GetBlock and self.Hooks.GetBlock(x, y, z) or false;
	self.Blocks[key] = block;
	return block ~= false and block or nil;
end;

worldClass.Profile = function(self: table, block: any): any
	if not block then
		return nil;
	end;
	return self.Hooks.GetProfile and self.Hooks.GetProfile(block) or navigation.Profiles.Default;
end;

worldClass.Invalidate = function(self: table, x: number, y: number, z: number): ()
	if self.Land and #self.Pending >= 4096 then
		self.Land = nil;
	elseif self.Land then
		table.insert(self.Pending, Vector3.new(x, y, z));
	end;

	local key: number = cellKey(x, y, z);
	if self.Cells[key] == nil and self.Blocks[key] == nil then
		return;
	end;

	self.Cells[key] = nil;
	self.Blocks[key] = nil;
	self.Revision += 1;

	if self.DirtyIndex >= 512 then
		table.clear(self.Dirty);
		self.DirtyIndex = 0;
		self.Flush += 1;
		return;
	end;

	self.DirtyIndex += 1;
	self.Dirty[self.DirtyIndex] = key;
end;

worldClass.Learn = function(self: table, x: number, y: number, z: number, duration: number): ()
	self.Learned[cellKey(x, y, z)] = os.clock() + duration;
	self.Cells[cellKey(x, y, z)] = true;
	self:Invalidate(x, y, z);
end;

worldClass.Touch = function(self: table): ()
	table.clear(self.Cells);
	table.clear(self.Blocks);
	table.clear(self.Dirty);
	self.DirtyIndex = 0;
	self.Revision += 1;
	self.Flush += 1;
	self.Land = nil;
end;

worldClass.Columns = function(self: table, budget: number?): any
	if not self.Hooks.GetBlocks or not self.Hooks.GetBlock then
		return nil;
	end;

	local slice: any = budget and os.clock() + budget;
	if not self.Land then
		local land: table, minX: number, maxX: number, minZ: number, maxZ: number = {}, math.huge, -math.huge, math.huge, -math.huge;
		self.Land, self.Pending, self.Bounds = land, {}, {minX, maxX, minZ, maxZ};
		for _: any, v: any in self.Hooks.GetBlocks() do
			local key: number = cellKey(v.X, 0, v.Z);
			land[key] = math.max(land[key] or v.Y, v.Y);
			minX, maxX, minZ, maxZ = math.min(minX, v.X), math.max(maxX, v.X), math.min(minZ, v.Z), math.max(maxZ, v.Z);
			if slice and os.clock() >= slice then
				task.wait();
				slice = os.clock() + budget;
			end;
		end;
		self.Bounds = {minX, maxX, minZ, maxZ};
		self.LandVersion += 1;
	end;

	for _: any, v: Vector3 in self.Pending do
		local key: number = cellKey(v.X, 0, v.Z);
		local top: any = self.Land[key];
		if (top or -math.huge) < v.Y and self.Hooks.GetBlock(v.X, v.Y, v.Z) then
			self.LandVersion += top and 0 or 1;
			self.Land[key] = v.Y;
			self.Bounds[1], self.Bounds[2], self.Bounds[3], self.Bounds[4] = math.min(self.Bounds[1], v.X), math.max(self.Bounds[2], v.X), math.min(self.Bounds[3], v.Z), math.max(self.Bounds[4], v.Z);
		elseif top == v.Y and not self.Hooks.GetBlock(v.X, v.Y, v.Z) then
			local lower: number? = nil;
			for level: number = v.Y - 1, v.Y - 64, -1 do
				if self.Hooks.GetBlock(v.X, level, v.Z) then
					lower = level;
					break;
				end;
			end;
			self.Land[key] = lower;
			self.LandVersion += lower and 0 or 1;
		end;
	end;
	table.clear(self.Pending);
	return self.Land;
end;

worldClass.Surface = function(self: table, x: number, z: number, floor: number): number?
	local top: number? = self.Land and self.Land[cellKey(x, 0, z)];
	if not top or top <= floor + 1 then
		return top;
	end;

	for y: number = floor + 1, floor - 16, -1 do
		if self:Block(x, y, z) then
			local surface: number = y;
			while surface < top and self:Block(x, surface + 1, z) do
				surface += 1;
			end;
			return surface;
		end;
	end;

	return nil;
end;

worldClass.Field = function(self: table, from: any, goal: any, margin: number, mode: string, budget: number?): (any, any, any, any)
	if not self:Columns(budget) then
		return nil;
	end;

	local goalKey: number = cellKey(goal.x, 0, goal.z);
	local floor: number = goal.y - 1;
	local minX: number, maxX: number = math.min(self.Bounds[1], from.x, goal.x) - margin, math.max(self.Bounds[2], from.x, goal.x) + margin;
	local minZ: number, maxZ: number = math.min(self.Bounds[3], from.z, goal.z) - margin, math.max(self.Bounds[4], from.z, goal.z) + margin;
	for _: any, v: any in {self.FieldCache, self.FieldPrevious} do
		if v.Goal == goalKey and v.Floor == floor and v.Mode == mode and v.Version == self.LandVersion and v.Box[1] <= minX and v.Box[2] >= maxX and v.Box[3] <= minZ and v.Box[4] >= maxZ then
			return v.Costs, self.Land, v.Box, v.Tops;
		end;
	end;

	local slice: any = budget and os.clock() + budget;
	local costs: {[number]: number} = {[goalKey] = 0};
	local tops: {[number]: number} = {[goalKey] = floor};
	local surfaces: {[number]: number | boolean} = {};
	local buckets: {[number]: {number}} = {[0] = {goal.x, goal.z}};
	local level: number, last: number = 0, 0;

	while level <= last do
		local bucket: {number}? = buckets[level];
		local index: number = 1;
		while bucket and index < #bucket do
			local x: any, z: any = bucket[index], bucket[index + 1];
			index += 2;

			local column: number = cellKey(x, 0, z);
			if costs[column] == level then
				local land: {[number]: number} = self.Land;
				for _: any, v: {number} in flats do
					local neighborX: any, neighborZ: any = x + v[1], z + v[3];
					local key: number = cellKey(neighborX, 0, neighborZ);
					local known: number? = costs[key];
					if known and known <= level then
						continue;
					end;

					local top: number? = land[key];
					local cost: number = level + (top and 0 or (mode ~= "Blatant" and v[1] ~= 0 and v[3] ~= 0 and 2 or 1));
					if neighborX >= minX and neighborX <= maxX and neighborZ >= minZ and neighborZ <= maxZ and (known or math.huge) > cost then
						if not top and land[column] and surfaces[column] == nil then
							surfaces[column] = self:Surface(x, z, floor) or false;
						end;
						costs[key] = cost;
						tops[key] = not top and surfaces[column] or tops[column];

						local queue: {number}? = buckets[cost];
						if not queue then
							queue = {};
							buckets[cost] = queue;
						end;
						local size: number = #queue;
						queue[size + 1] = neighborX;
						queue[size + 2] = neighborZ;
						last = math.max(last, cost);
					end;
				end;
			end;

			if slice and os.clock() >= slice then
				task.wait();
				slice = os.clock() + budget;
			end;
		end;

		buckets[level] = nil;
		level += 1;
	end;

	self.FieldPrevious, self.FieldCache = self.FieldCache, {["Goal"] = goalKey, ["Floor"] = floor, ["Mode"] = mode, ["Version"] = self.LandVersion, ["Box"] = {minX, maxX, minZ, maxZ}, ["Costs"] = costs, ["Tops"] = tops};
	return costs, self.Land, self.FieldCache.Box, tops;
end;

worldClass.Begin = function(self: table, overlay: any): any
	self.Overlay = overlay or {};
	return self.Overlay;
end;

worldClass.Finish = function(self: table): ()
	self.Overlay = nil;
end;

worldClass.Write = function(self: table, x: number, y: number, z: number, block: any): ()
	if self.Overlay then
		self.Overlay[cellKey(x, y, z)] = block or false;
	end;
end;

navigation.newWorld = function(hooks: any): ...any
	return setmetatable({
		["Hooks"] = hooks or {},
		["Cells"] = {},
		["Blocks"] = {},
		["Learned"] = {},
		["Dirty"] = {},
		["DirtyIndex"] = 0,
		["Revision"] = 0,
		["Flush"] = 0,
		["Pending"] = {},
		["LandVersion"] = 0,
		["Overlay"] = nil
	}, worldClass);
end;

local fallTime: (drop: number, speed: number, gravity: number) -> number? = function(drop: number, speed: number, gravity: number): number?
	local inner: number = speed * speed + 2 * gravity * drop;
	if inner < 0 then
		return nil;
	end;
	return (speed + math.sqrt(inner)) / gravity;
end;

local impactSpeed: (drop: number, speed: number, gravity: number) -> number = function(drop: number, speed: number, gravity: number): number
	return math.sqrt(math.max(speed * speed + 2 * gravity * drop, 0));
end;

local fallDamage: (impact: number, agent: any) -> number = function(impact: number, agent: any): number
	return impact > agent.ImpactLimit and (impact - agent.ImpactLimit) * agent.DamageScale or 0;
end;

local safeDrop: (speed: number, agent: any) -> number = function(speed: number, agent: any): number
	local limit: number = agent.ImpactLimit + agent.DamageAllowance / agent.DamageScale;
	local budget: number = (limit * limit - speed * speed) / (2 * agent.Gravity);
	return budget > 0 and budget * agent.SafeMargin or 0;
end;

local jumpLand: (agent: any, rise: number) -> number? = function(agent: any, rise: number): number?
	local inner: number = agent.JumpVelocity * agent.JumpVelocity - 2 * agent.Gravity * rise;
	if inner < 0 then
		return nil;
	end;
	return (agent.JumpVelocity + math.sqrt(inner)) / agent.Gravity;
end;

local jumpHeight: (agent: any, elapsed: number) -> number = function(agent: any, elapsed: number): number
	return agent.JumpVelocity * elapsed - agent.Gravity * elapsed * elapsed * 0.5;
end;

local traverse: (agent: any, traversal: any, horizontal: number, vertical: number, speed: number) -> (any, any, any, any) = function(agent: any, traversal: any, horizontal: number, vertical: number, speed: number): (any, any, any, any)
	local needed: number = horizontal + traversal.Margin;
	if traversal.Mover == "Glide" then
		if vertical > traversal.Rise * cellSize then
			return false, 0, 0, "TooHigh";
		end;
		local climb: number = traversal.Instant and 0 or math.abs(vertical);
		local airTime: number = (needed + climb) / speed;
		return airTime <= traversal.MaxAirTime, airTime, speed * traversal.MaxAirTime - climb - traversal.Margin, airTime <= traversal.MaxAirTime and "Traversable" or "AirTime";
	end;

	local airTime: number? = jumpLand(agent, vertical);
	if not airTime then
		return false, 0, 0, "TooHigh";
	end;
	local reach: number = speed * math.min(airTime, traversal.MaxAirTime) - traversal.Margin;
	return reach >= horizontal, airTime, reach, reach >= horizontal and "Traversable" or (airTime > traversal.MaxAirTime and "AirTime" or "Distance");
end;

local newContext: (world: any, agent: any, mode: string) -> any = function(world: any, agent: any, mode: string): any
	return {
		["World"] = world,
		["Agent"] = agent,
		["Mode"] = mode,
		["Fits"] = {},
		["Stands"] = {},
		["Height"] = math.max(math.ceil(agent.Height / cellSize), 1),
		["Revision"] = world.Revision,
		["Dirty"] = world.DirtyIndex,
		["Flush"] = world.Flush
	};
end;

local refresh: (context: any) -> () = function(context: any): ()
	local world: any = context.World;
	if context.Revision == world.Revision then
		return;
	end;

	if context.Flush ~= world.Flush then
		table.clear(context.Fits);
		table.clear(context.Stands);
	else
		for i: number = context.Dirty + 1, world.DirtyIndex do
			for layer: number = -context.Height, 1 do
				local shifted: number = world.Dirty[i] + layer * keySpan;
				context.Fits[shifted] = nil;
				context.Stands[shifted] = nil;
			end;
		end;
	end;

	context.Revision = world.Revision;
	context.Dirty = world.DirtyIndex;
	context.Flush = world.Flush;
end;

local fits: (context: any, x: number, y: number, z: number) -> boolean = function(context: any, x: number, y: number, z: number): boolean
	local key: number = cellKey(x, y, z);
	local cached: boolean? = context.Fits[key];
	if cached ~= nil then
		return cached;
	end;

	local clear: boolean = true;
	for layer: number = 0, context.Height - 1 do
		if context.World:Solid(x, y + layer, z) then
			clear = false;
			break;
		end;
	end;

	context.Fits[key] = clear;
	return clear;
end;

local stands: (context: any, x: number, y: number, z: number) -> boolean = function(context: any, x: number, y: number, z: number): boolean
	local key: number = cellKey(x, y, z);
	local cached: boolean? = context.Stands[key];
	if cached ~= nil then
		return cached;
	end;

	local standing: any = context.World:Solid(x, y - 1, z) and fits(context, x, y, z);
	context.Stands[key] = standing;
	return standing;
end;

local canCutCorner: (context: any, x: number, y: number, z: number, directionX: number, directionZ: number) -> boolean = function(context: any, x: number, y: number, z: number, directionX: number, directionZ: number): boolean
	return fits(context, x + directionX, y, z) and fits(context, x, y, z + directionZ);
end;

local traceClear: (context: any, origin: Vector3, target: Vector3, skipA: number, skipB: number) -> boolean = function(context: any, origin: Vector3, target: Vector3, skipA: number, skipB: number): boolean
	local directionX: number, directionY: number, directionZ: number = target.X - origin.X, target.Y - origin.Y, target.Z - origin.Z;
	local x: any, y: any, z: any = gridAxis(origin.X), gridAxis(origin.Y), gridAxis(origin.Z);
	local stepX: number, nextX: number, deltaX: number = 0, math.huge, math.huge;
	local stepY: number, nextY: number, deltaY: number = 0, math.huge, math.huge;
	local stepZ: number, nextZ: number, deltaZ: number = 0, math.huge, math.huge;

	if directionX ~= 0 then
		stepX = directionX > 0 and 1 or -1;
		nextX = ((x + stepX * 0.5) * cellSize - origin.X) / directionX;
		deltaX = cellSize / math.abs(directionX);
	end;
	if directionY ~= 0 then
		stepY = directionY > 0 and 1 or -1;
		nextY = ((y + stepY * 0.5) * cellSize - origin.Y) / directionY;
		deltaY = cellSize / math.abs(directionY);
	end;
	if directionZ ~= 0 then
		stepZ = directionZ > 0 and 1 or -1;
		nextZ = ((z + stepZ * 0.5) * cellSize - origin.Z) / directionZ;
		deltaZ = cellSize / math.abs(directionZ);
	end;

	for _: number = 1, 64 do
		if nextX > 1 and nextY > 1 and nextZ > 1 then
			return true;
		end;

		if nextX <= nextY and nextX <= nextZ then
			x, nextX = x + stepX, nextX + deltaX;
		elseif nextY <= nextZ then
			y, nextY = y + stepY, nextY + deltaY;
		else
			z, nextZ = z + stepZ, nextZ + deltaZ;
		end;

		local key: number = cellKey(x, y, z);
		if key ~= skipA and key ~= skipB and context.World:Solid(x, y, z) then
			return false;
		end;
	end;

	return true;
end;

local bodyBlocked: (context: any, state: any, x: number, y: number, z: number) -> boolean = function(context: any, state: any, x: number, y: number, z: number): boolean
	local reach: number = halfCell + state.HeadRadius;
	if math.abs(state.Head.X - x * cellSize) < reach and math.abs(state.Head.Y - y * cellSize) < reach and math.abs(state.Head.Z - z * cellSize) < reach then
		return true;
	end;

	if state.BodyHeight > 1 and x == state.BodyX and z == state.BodyZ then
		local low: number = state.BodyY + (context.World:Block(state.BodyX, state.BodyY + state.BodyHeight, state.BodyZ) and 0 or 1);
		if y >= low and y <= state.BodyY + state.BodyHeight - 1 then
			return true;
		end;
	end;

	return false;
end;

local supportAt: (context: any, x: number, y: number, z: number, mode: string, extra: number?) -> (any, any, any, any, any, any, any) = function(context: any, x: number, y: number, z: number, mode: string, extra: number?): (any, any, any, any, any, any, any)
	local world: any = context.World;
	local best: any, score: number = nil, -1;

	for _: any, v: {number} in faces do
		local supportX: any, supportY: any, supportZ: any = x + v[1], y + v[2], z + v[3];
		if world:Solid(supportX, supportY, supportZ) or cellKey(supportX, supportY, supportZ) == extra then
			local block: any = world:Block(supportX, supportY, supportZ);
			if not block or world:Profile(block).Support then
				local rank: number = v[2] == 0 and 2 or (v[2] < 0 and 1 or 0);
				if rank > score then
					best, score = v, rank;
				end;
			end;
		end;
	end;

	if best then
		return x + best[1], y + best[2], z + best[3], -best[1], -best[2], -best[3], "Face";
	end;

	if mode ~= "Blatant" then
		return nil;
	end;

	for _: any, v: {number} in corners do
		local supportX: any, supportY: any, supportZ: any = x + v[1], y + v[2], z + v[3];
		if world:Solid(supportX, supportY, supportZ) or cellKey(supportX, supportY, supportZ) == extra then
			local block: any = world:Block(supportX, supportY, supportZ);
			if not block or world:Profile(block).Support then
				local rank: number = v[2] == 0 and 2 or (v[2] < 0 and 1 or 0);
				if rank > score then
					best, score = v, rank;
				end;
			end;
		end;
	end;

	if best then
		return x + best[1], y + best[2], z + best[3], -best[1], -best[2], -best[3], "Diagonal";
	end;

	return nil;
end;

local placementAt: (context: any, state: any, x: number, y: number, z: number, mode: string, extra: number?, quick: boolean?) -> (any, any) = function(context: any, state: any, x: number, y: number, z: number, mode: string, extra: number?, quick: boolean?): (any, any)
	local block: any = context.World:Block(x, y, z);
	if block and not context.World:Profile(block).Replaceable then
		return nil, "Occupied";
	elseif not block and context.World:Solid(x, y, z) then
		return nil, "Occupied";
	end;

	if bodyBlocked(context, state, x, y, z) then
		return nil, "Body";
	end;

	local supportX: any, supportY: any, supportZ: any, normalX: any, normalY: any, normalZ: any, kind: any = supportAt(context, x, y, z, mode, extra);
	if not supportX and not context.Floating then
		return nil, "Support";
	end;

	local aim: Vector3 = Vector3.new(x * cellSize, y * cellSize - halfCell, z * cellSize);
	if supportX and math.abs(normalX) + math.abs(normalY) + math.abs(normalZ) == 1 then
		aim = Vector3.new(supportX * cellSize + normalX * halfCell, supportY * cellSize + normalY * halfCell, supportZ * cellSize + normalZ * halfCell);
	elseif supportX then
		aim = Vector3.new(math.clamp(x * cellSize, supportX * cellSize - halfCell, supportX * cellSize + halfCell), math.clamp(y * cellSize, supportY * cellSize - halfCell, supportY * cellSize + halfCell), math.clamp(z * cellSize, supportZ * cellSize - halfCell, supportZ * cellSize + halfCell));
	end;

	local distance: number = (aim - state.Position).Magnitude;
	if distance > context.Reach then
		return nil, "Reach";
	end;

	if not quick and not traceClear(context, state.Eye, aim, supportX and cellKey(supportX, supportY, supportZ) or 0, cellKey(x, y, z)) then
		return nil, "Sight";
	end;

	local direction: Vector3 = aim - state.Eye;
	return {
		["Grid"] = Vector3.new(x, y, z),
		["Position"] = Vector3.new(x * cellSize, y * cellSize, z * cellSize),
		["Mode"] = mode,
		["PlacementType"] = supportX and kind or "Float",
		["SupportGrid"] = supportX and Vector3.new(supportX, supportY, supportZ) or nil,
		["Normal"] = supportX and Vector3.new(-normalX, -normalY, -normalZ) or nil,
		["AimPosition"] = aim,
		["AimDirection"] = direction.Magnitude > 0 and direction.Unit or Vector3.new(0, -1, 0),
		["AimCFrame"] = direction.Magnitude > 0 and CFrame.lookAt(state.Eye, aim) or nil,
		["Distance"] = distance,
		["Valid"] = true
	};
end;

local voidSave: (context: any, state: any) -> (any, any, any) = function(context: any, state: any): (any, any, any)
	for depth: number = 1, 3 do
		local y: number = gridAxis(state.Position.Y - depth * cellSize);
		for _: any, v: {number} in saves do
			if context.World:Solid(state.CellX + v[1], y + v[2], state.CellZ + v[3]) then
				return state.CellX, y, state.CellZ;
			end;
		end;
	end;

	return nil;
end;

local heapPush: (heap: any, node: any) -> () = function(heap: any, node: any): ()
	local index: number = #heap + 1;
	heap[index] = node;

	while index > 1 do
		local parent: number = index // 2;
		if heap[parent].f <= heap[index].f then
			break;
		end;
		heap[parent], heap[index] = heap[index], heap[parent];
		index = parent;
	end;
end;

local heapPop: (heap: any) -> any = function(heap: any): any
	local size: number = #heap;
	if size == 0 then
		return nil;
	end;

	local top: any = heap[1];
	heap[1] = heap[size];
	heap[size] = nil;
	size -= 1;

	local index: number = 1;
	while true do
		local left: number = index * 2;
		local right: number = left + 1;
		local best: number = index;
		if left <= size and heap[left].f < heap[best].f then
			best = left;
		end;
		if right <= size and heap[right].f < heap[best].f then
			best = right;
		end;
		if best == index then
			break;
		end;
		heap[index], heap[best] = heap[best], heap[index];
		index = best;
	end;

	return top;
end;

local heuristic: (context: any, x: number, y: number, z: number, goalX: number, goalY: number, goalZ: number) -> number = function(context: any, x: number, y: number, z: number, goalX: number, goalY: number, goalZ: number): number
	local deltaX: number, deltaY: number, deltaZ: number = math.abs(goalX - x), (goalY - y) * cellSize, math.abs(goalZ - z);
	return (math.max(deltaX, deltaZ) + math.min(deltaX, deltaZ) * 0.4142) * cellSize * context.FlatCost + (deltaY > 0 and deltaY * context.ClimbCost or -deltaY / cellSize * context.DropCost);
end;

local level: (pack: any, column: number) -> number = function(pack: any, column: number): number
	local top: number? = pack.field and not pack.land[column] and pack.tops[column] or nil;
	return top and math.min(top + 1, pack.gy + 1) or pack.gy;
end;

local detour: (from: number, to: number, reference: number) -> number = function(from: number, to: number, reference: number): number
	if to > from then
		return math.max(to - math.max(from, reference), 0);
	end;
	return math.max(math.min(from, reference) - to, 0);
end;

local walled: (context: any, x: number, y: number, z: number) -> boolean = function(context: any, x: number, y: number, z: number): boolean
	for i: number = 1, 4 do
		local direction: {number} = flats[i];
		if not fits(context, x + direction[1], y, z + direction[3]) and not fits(context, x + direction[1], y + 1, z + direction[3]) then
			return true;
		end;
	end;
	return false;
end;

local estimate: (pack: any, x: number, y: number, z: number) -> number = function(pack: any, x: number, y: number, z: number): number
	local column: number = cellKey(x, 0, z);
	return heuristic(pack.ctx, x, y, z, pack.gx, level(pack, column), pack.gz) + (pack.field and math.max((pack.field[column] or math.max(pack.box[1] - x, x - pack.box[2], pack.box[3] - z, z - pack.box[4])) - (pack.land[column] and 0 or 1) - pack.span, 0) * pack.ctx.PlaceCost or 0);
end;

local relax: (pack: any, parent: any, key: number, x: number, y: number, z: number, cost: number, blocks: number, kind: string, damage: number, air: number?) -> () = function(pack: any, parent: any, key: number, x: number, y: number, z: number, cost: number, blocks: number, kind: string, damage: number, air: number?): ()
	if pack.closed[key] then
		return;
	end;

	if pack.avoid then
		cost += pack.avoid[key] or 0;
	end;

	local penalty: number = pack.elevation and y ~= parent.y and detour(parent.y, y, level(pack, cellKey(x, 0, z))) * pack.elevation or 0;
	cost += penalty;

	local existing: any = pack.nodes[key];
	if existing and existing.g <= cost then
		return;
	end;

	local node: table = {["x"] = x, ["y"] = y, ["z"] = z, ["g"] = cost, ["b"] = blocks, ["pr"] = parent, ["mt"] = kind, ["dmg"] = damage, ["air"] = air, ["ex"] = (parent.ex or 0) + penalty};
	node.f = cost + estimate(pack, x, y, z) * pack.weight;
	pack.nodes[key] = node;
	heapPush(pack.heap, node);
end;

local dropTo: (context: any, x: number, y: number, z: number) -> (any, any, any) = function(context: any, x: number, y: number, z: number): (any, any, any)
	local agent: any = context.Agent;

	for depth: number = 1, math.ceil(agent.MaxDrop / cellSize) do
		if context.World:Solid(x, y - depth - 1, z) then
			local drop: number = depth * cellSize;
			return y - depth, drop, context.Traversal.Instant and 0 or fallDamage(impactSpeed(drop, 0, agent.Gravity), agent);
		end;
		if not fits(context, x, y - depth, z) then
			return nil;
		end;
	end;

	return nil;
end;

local gapLand: (context: any, x: number, y: number, z: number, directionX: number, directionZ: number, span: number, level: number) -> boolean = function(context: any, x: number, y: number, z: number, directionX: number, directionZ: number, span: number, level: number): boolean
	local agent: any = context.Agent;
	local stride: number = cellSize * (directionX ~= 0 and directionZ ~= 0 and 1.4142 or 1);

	if context.Traversal.Mover == "Glide" then
		local height: number = math.max(level, y);
		for layer: number = y + 1, height do
			if not fits(context, x, layer, z) then
				return false;
			end;
		end;
		local length: number = math.sqrt(directionX * directionX + directionZ * directionZ) * span * cellSize;
		for sample: number = 0, math.ceil(length) do
			local pointX: number, pointZ: number = (x + directionX * span * math.min(sample / length, 1)) * cellSize, (z + directionZ * span * math.min(sample / length, 1)) * cellSize;
			if not fits(context, gridAxis(pointX - agent.Radius), height, gridAxis(pointZ - agent.Radius)) or not fits(context, gridAxis(pointX + agent.Radius), height, gridAxis(pointZ - agent.Radius)) or not fits(context, gridAxis(pointX - agent.Radius), height, gridAxis(pointZ + agent.Radius)) or not fits(context, gridAxis(pointX + agent.Radius), height, gridAxis(pointZ + agent.Radius)) then
				return false;
			end;
		end;
		for layer: number = level + 1, y do
			if not fits(context, x + directionX * span, layer, z + directionZ * span) then
				return false;
			end;
		end;
		return true;
	end;

	for step: number = 1, span do
		local height: number = y + math.max(math.round(jumpHeight(agent, step * stride / agent.WalkSpeed) / cellSize), step == span and level - y or -math.huge);
		if not fits(context, x + directionX * step, height, z + directionZ * step) then
			return false;
		end;
	end;

	return true;
end;

local expand: (pack: any, node: any) -> () = function(pack: any, node: any): ()
	local context: any = pack.ctx;
	local agent: any = context.Agent;
	local x: any, y: any, z: any = node.x, node.y, node.z;
	local head: boolean = context.World:Solid(x, y + context.Height, z);
	local placed: boolean = node.mt == "Bridge" or node.mt == "Tower";
	local extra: number? = placed and cellKey(x, y - 1, z) or nil;
	local column: number = cellKey(x, 0, z);
	local top: number = level(pack, column);
	local near: boolean = math.max(math.abs(pack.gx - x), math.abs(pack.gz - z)) <= pack.gy - y + 1;
	local rise: any = pack.bridge and (top > y and (placed or near) and not (pack.field and pack.land[column] and (pack.field[column] or 0) > 0) or walled(context, x, y, z));
	local launch: boolean = placed and y <= top and pack.field ~= nil and (pack.field[column] or math.huge) <= pack.span + 1;
	local lift: number = cellSize * context.ClimbCost;
	local walkable: boolean = false;

	for _: any, v: {number} in flats do
		local directionX: any, directionZ: any = v[1], v[3];
		local diagonal: boolean = directionX ~= 0 and directionZ ~= 0;
		if diagonal and not canCutCorner(context, x, y, z, directionX, directionZ) then
			continue;
		end;

		local step: number = diagonal and context.DiagCost or context.StepCost;
		local targetX: any, targetZ: any = x + directionX, z + directionZ;
		local level: boolean = stands(context, targetX, y, targetZ);

		for deltaY: number = -1, 1 do
			local targetY: number = y + deltaY;
			if deltaY == 1 and (head or level or (diagonal and not canCutCorner(context, x, targetY, z, directionX, directionZ))) then
				continue;
			end;
			if deltaY == -1 and (diagonal or node.mt ~= "Bridge" or level or top >= y) then
				continue;
			end;
			if not fits(context, targetX, targetY, targetZ) then
				continue;
			end;

			local key: number = cellKey(targetX, targetY, targetZ);
			local cost: number = step + (deltaY == 1 and context.JumpCost + lift or deltaY == -1 and context.DropCost or 0);

			if stands(context, targetX, targetY, targetZ) then
				if deltaY ~= -1 then
					relax(pack, node, key, targetX, targetY, targetZ, node.g + cost, node.b, deltaY == 1 and "Jump" or "Walk", 0);
					walkable = true;
				end;
				continue;
			end;

			if deltaY == 0 then
				local landing: any, drop: any, damage: any = dropTo(context, targetX, targetY, targetZ);
				if landing and damage <= agent.DamageAllowance then
					relax(pack, node, cellKey(targetX, landing, targetZ), targetX, landing, targetZ, node.g + cost + context.DropCost + math.sqrt(2 * drop / agent.Gravity) + damage * context.RiskCost, node.b, "Drop", damage);
					walkable = true;
					if pack.field and pack.land[cellKey(targetX, 0, targetZ)] then
						continue;
					end;
				end;
			end;

			if pack.bridge and node.b < pack.limit and (deltaY ~= 1 or rise or launch) and supportAt(context, targetX, targetY - 1, targetZ, context.Mode, extra) then
				relax(pack, node, key, targetX, targetY, targetZ, node.g + cost + context.PlaceCost + (node.b >= context.Budgeted and context.ScarceCost or 0) + (node.mt == "Bridge" and node.pr and (directionX ~= x - node.pr.x or directionZ ~= z - node.pr.z) and context.TurnCost or 0), node.b + 1, "Bridge", 0);
				walkable = true;
			end;
		end;

		if pack.gap and not level and (not head or context.Traversal.Mover == "Glide") and (node.mt ~= "Bridge" or directionX == x - node.pr.x and directionZ == z - node.pr.z) and not context.World:Solid(targetX, y - 1, targetZ) and not context.World:Solid(targetX, y - 2, targetZ) then
			local stride: number = cellSize * (diagonal and 1.4142 or 1);
			local land: any = context.World.Land;
			for span: number = 2, math.floor(context.Leap / stride) + 1 do
				local landX: any, landZ: any = x + directionX * span, z + directionZ * span;
				local surface: any = land and land[cellKey(landX, 0, landZ)];
				local landed: boolean = false;
				if surface or not land then
					for landY: number = math.min(y + context.Rise, surface and surface + 1 or math.huge), y - context.Dive, -1 do
						if stands(context, landX, landY, landZ) then
							local crossable: any, airTime: any = traverse(agent, context.Traversal, (span - 1) * stride, (landY - y) * cellSize, agent.WalkSpeed);
							local damage: number = landY < y and not context.Traversal.Instant and fallDamage(impactSpeed((y - landY) * cellSize, context.Traversal.Mover == "Glide" and 0 or agent.JumpVelocity, agent.Gravity), agent) or 0;
							if crossable and (node.air or 0) + airTime <= context.Traversal.MaxAirTime and damage <= agent.DamageAllowance and gapLand(context, x, y, z, directionX, directionZ, span, landY) then
								relax(pack, node, cellKey(landX, landY, landZ), landX, landY, landZ, node.g + step * span + context.JumpCost + context.AirCost * airTime + math.max(landY - y, 0) * lift + damage * context.RiskCost, node.b, "Jump", damage, (node.air or 0) + airTime);
								walkable = true;
							end;
							if landY <= y + 1 then
								landed = true;
								break;
							end;
						end;
					end;
				end;
				if landed or not fits(context, x + directionX * (span - 1), y, z + directionZ * (span - 1)) or not fits(context, landX, y, landZ) then
					break;
				end;
			end;
		end;

		if context.Traversal.Instant and not level then
			for height: number = 2, context.Rise do
				if not fits(context, x, y + height, z) then
					break;
				end;
				if stands(context, targetX, y + height, targetZ) and (not diagonal or canCutCorner(context, x, y + height, z, directionX, directionZ)) then
					relax(pack, node, cellKey(targetX, y + height, targetZ), targetX, y + height, targetZ, node.g + step + context.JumpCost + height * lift, node.b, "Jump", 0);
					walkable = true;
					break;
				end;
			end;
		end;
	end;

	if pack.gap and context.Traversal.Mover == "Glide" and node.mt ~= "Bridge" then
		local land: any = context.World.Land;
		for _: any, v: {number} in leaps do
			local directionX: any, directionZ: any = v[1], v[3];
			local firstX: any, firstZ: any, secondX: any, secondZ: any = x + (math.abs(directionX) == 2 and directionX // 2 or 0), z + (math.abs(directionZ) == 2 and directionZ // 2 or 0), x + math.sign(directionX), z + math.sign(directionZ);
			if stands(context, firstX, y, firstZ) or stands(context, secondX, y, secondZ) or context.World:Solid(firstX, y - 1, firstZ) or context.World:Solid(secondX, y - 1, secondZ) then
				continue;
			end;

			local stride: number = cellSize * math.sqrt(directionX * directionX + directionZ * directionZ);
			local edge: number = stride / math.max(math.abs(directionX), math.abs(directionZ));
			for span: number = 1, math.floor((context.Leap + edge) / stride) do
				local landX: any, landZ: any = x + directionX * span, z + directionZ * span;
				local surface: any = land and land[cellKey(landX, 0, landZ)];
				local landed: boolean = false;
				if surface or not land then
					for landY: number = math.min(y + context.Rise, surface and surface + 1 or math.huge), y - context.Dive, -1 do
						if stands(context, landX, landY, landZ) then
							local crossable: any, airTime: any = traverse(agent, context.Traversal, span * stride - edge, (landY - y) * cellSize, agent.WalkSpeed);
							local damage: number = landY < y and not context.Traversal.Instant and fallDamage(impactSpeed((y - landY) * cellSize, 0, agent.Gravity), agent) or 0;
							if crossable and (node.air or 0) + airTime <= context.Traversal.MaxAirTime and damage <= agent.DamageAllowance and gapLand(context, x, y, z, directionX, directionZ, span, landY) then
								relax(pack, node, cellKey(landX, landY, landZ), landX, landY, landZ, node.g + context.StepCost * span * stride / cellSize + context.JumpCost + context.AirCost * airTime + math.max(landY - y, 0) * lift + damage * context.RiskCost, node.b, "Jump", damage, (node.air or 0) + airTime);
								walkable = true;
							end;
							if landY <= y + 1 then
								landed = true;
								break;
							end;
						end;
					end;
				end;
				if landed then
					break;
				end;
			end;
		end;
	end;

	if pack.tower and node.b < pack.limit and not head and (rise or not walkable) and fits(context, x, y + 1, z) then
		relax(pack, node, cellKey(x, y + 1, z), x, y + 1, z, node.g + context.PlaceCost + context.JumpCost + lift + (node.b >= context.Budgeted and context.ScarceCost or 0), node.b + 1, "Tower", 0);
	end;

	local climb: any = context.World:Profile(context.World:Block(x, y, z));
	if climb and climb.Climbable then
		for deltaY: number = -1, 1, 2 do
			local target: any = context.World:Profile(context.World:Block(x, y + deltaY, z));
			if not context.World:Solid(x, y + deltaY, z) or (target and target.Climbable) then
				relax(pack, node, cellKey(x, y + deltaY, z), x, y + deltaY, z, node.g + context.ClimbStep, node.b, "Climb", 0);
			end;
		end;
	end;
end;

local search: (context: any, blocks: number, from: any, goal: any, weight: number, options: any, request: any, stage: string, seed: any) -> any = function(context: any, blocks: number, from: any, goal: any, weight: number, options: any, request: any, stage: string, seed: any): any
	local pack: table = {
		["ctx"] = context,
		["heap"] = {},
		["nodes"] = {},
		["closed"] = {},
		["weight"] = weight,
		["gx"] = goal.x,
		["gy"] = goal.y,
		["gz"] = goal.z,
		["limit"] = blocks,
		["bridge"] = stage ~= "Walk" and options.Bridge ~= false,
		["tower"] = stage ~= "Walk" and options.Tower ~= false,
		["gap"] = options.JumpGap ~= false,
		["span"] = options.JumpGap ~= false and context.Span or 0,
		["avoid"] = context.Avoid,
		["elevation"] = context.ElevationCost > 0 and context.ElevationCost or nil,
		["reached"] = false,
		["steps"] = 0
	};

	if stage == "Bridge" then
		pack.field, pack.land, pack.box, pack.tops = context.World:Field(from, goal, options.FieldMargin, context.Mode, options.Yield and task and options.Budget);
	elseif pack.gap then
		context.World:Columns(options.Yield and task and options.Budget);
	end;

	local budget: number = stage == "Walk" and options.WalkSteps or options.MaxSteps;
	if seed then
		for key: number, v: any in seed.nodes do
			if seed.closed[key] then
				v.f = v.g + estimate(pack, v.x, v.y, v.z) * weight;
				pack.nodes[key] = v;
				heapPush(pack.heap, v);
				budget += 1;
			end;
		end;
	else
		local start: table = {["x"] = from.x, ["y"] = from.y, ["z"] = from.z, ["g"] = 0, ["b"] = 0, ["mt"] = "Start", ["dmg"] = 0};
		start.f = estimate(pack, from.x, from.y, from.z) * weight;
		pack.nodes[cellKey(from.x, from.y, from.z)] = start;
		heapPush(pack.heap, start);
	end;

	local tolerance: number = options.Tolerance * cellSize;
	local score: number = math.huge;
	local slice: number = os.clock() + options.Budget;

	while #pack.heap > 0 and pack.steps < budget do
		pack.steps += 1;

		if os.clock() >= slice then
			if request and request.Cancelled then
				return pack;
			end;
			if options.Yield and task then
				task.wait();
			end;
			slice = os.clock() + options.Budget;
		end;

		local node: any = heapPop(pack.heap);
		local key: number = cellKey(node.x, node.y, node.z);
		if pack.closed[key] then
			continue;
		end;
		pack.closed[key] = true;

		local deltaX: any, deltaY: any, deltaZ: any = (goal.x - node.x) * cellSize, (goal.y - node.y) * cellSize, (goal.z - node.z) * cellSize;
		local distance: number = math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
		if distance < score then
			pack.node, score = node, distance;
		end;

		if distance <= tolerance then
			pack.node, pack.reached = node, true;
			return pack;
		end;

		expand(pack, node);
	end;

	return pack;
end;

local standPosition: (agent: any, x: number, y: number, z: number) -> Vector3 = function(agent: any, x: number, y: number, z: number): Vector3
	return Vector3.new(x * cellSize, y * cellSize - halfCell + agent.HipHeight, z * cellSize);
end;

local buildState: (input: any, agent: any, world: any) -> any = function(input: any, agent: any, world: any): any
	if typeof(input) == "Vector3" then
		input = {["Position"] = input};
	end;

	local position: Vector3 = input.Position;
	local head: Vector3 = position + Vector3.new(0, agent.HeadOffset, 0);
	local state: table = {
		["Position"] = position,
		["Velocity"] = input.Velocity or Vector3.zero,
		["Head"] = head,
		["Eye"] = input.Eye or (input.Camera and input.Camera.Position) or head,
		["Aim"] = input.Aim or (input.Camera and input.Camera.LookVector) or nil,
		["HeadRadius"] = agent.HeadRadius,
		["BodyHeight"] = input.BodyHeight or 2,
		["Feet"] = position.Y - agent.HipHeight,
		["Grounded"] = input.Grounded,
		["Blocks"] = input.BlocksAvailable or agent.BlocksAvailable,
		["CellX"] = gridAxis(position.X),
		["CellY"] = gridAxis(position.Y - agent.HipHeight + halfCell),
		["CellZ"] = gridAxis(position.Z),
		["BodyX"] = gridAxis(position.X),
		["BodyY"] = gridAxis(position.Y - agent.BodyOffset),
		["BodyZ"] = gridAxis(position.Z)
	};

	if state.Grounded == nil and world then
		state.Grounded = world:Solid(state.CellX, state.CellY - 1, state.CellZ);
	end;

	return state;
end;

local writeCell: (context: any, x: number, y: number, z: number, block: any) -> () = function(context: any, x: number, y: number, z: number, block: any): ()
	context.World:Write(x, y, z, block);
	local base: number = cellKey(x, y, z);
	for offset: number = -context.Height, 1 do
		context.Fits[base + offset * keySpan] = nil;
		context.Stands[base + offset * keySpan] = nil;
	end;
end;

local walkLine: (context: any, y: number, startX: number, startZ: number, endX: number, endZ: number) -> boolean = function(context: any, y: number, startX: number, startZ: number, endX: number, endZ: number): boolean
	local deltaX: number, deltaZ: number = endX - startX, endZ - startZ;
	local span: number = math.max(math.abs(deltaX), math.abs(deltaZ));
	if span == 0 then
		return true;
	end;

	local lastX: number, lastZ: number = startX, startZ;
	for step: number = 1, span do
		local cellX: number, cellZ: number = startX + math.round(deltaX * step / span), startZ + math.round(deltaZ * step / span);
		if not stands(context, cellX, y, cellZ) then
			return false;
		end;
		if cellX ~= lastX and cellZ ~= lastZ and not canCutCorner(context, lastX, y, lastZ, cellX - lastX, cellZ - lastZ) then
			return false;
		end;
		lastX, lastZ = cellX, cellZ;
	end;

	return true;
end;

local compile: (context: any, node: any, options: any) -> any = function(context: any, node: any, options: any): any
	local agent: any = context.Agent;
	local nodes: table = {};
	local current: any = node;

	while current do
		table.insert(nodes, 1, current);
		current = current.pr;
	end;

	local actions: table, bridge: table, walking: table, depends: table, planned: table = {}, {}, {}, {}, {};
	local blocks: number, damage: number, failure: any = 0, 0, nil;
	local lastBridge: any, priorBridge: any = nil, nil;

	context.World:Begin();

	for i: number, v: any in nodes do
		for offset: number = -1, context.Height - 1 do
			depends[cellKey(v.x, v.y + offset, v.z)] = true;
		end;

		if v.air then
			local previous: any = nodes[i - 1];
			local length: number = math.sqrt((v.x - previous.x) ^ 2 + (v.z - previous.z) ^ 2) * cellSize;
			for step: number = 1, math.ceil(length) do
				for layer: number = 0, context.Height - 1 do
					depends[cellKey(gridAxis((previous.x + (v.x - previous.x) * step / length * cellSize) * cellSize), math.max(previous.y, v.y) + layer, gridAxis((previous.z + (v.z - previous.z) * step / length * cellSize) * cellSize))] = true;
				end;
			end;
		end;

		if v.mt == "Bridge" or v.mt == "Tower" then
			local previous: any = nodes[i - 1];
			local lift: number = v.mt == "Tower" and agent.HipHeight or 0;
			local from: any = buildState({["Position"] = standPosition(agent, previous.x, previous.y, previous.z) + Vector3.new(0, lift, 0)}, agent);

			if options.BridgeWidth > 1 and lastBridge and priorBridge and v.mt == "Bridge" and (v.x - lastBridge.X ~= lastBridge.X - priorBridge.X or v.z - lastBridge.Z ~= lastBridge.Z - priorBridge.Z) then
				local fill: any = placementAt(context, from, priorBridge.X + v.x - lastBridge.X, v.y - 1, priorBridge.Z + v.z - lastBridge.Z, context.Mode, nil, true);
				if fill and blocks < options.BlocksAvailable then
					fill.Type = "PlaceBlock";
					fill.Duration = 1 / agent.PlaceCps;
					fill.ExpectedPosition = from.Position;
					fill.Lead = math.max((context.Reach - fill.Distance) / agent.WalkSpeed, 0);
					fill.Preconditions = {["MaxDistance"] = context.Reach, ["RequiredSupport"] = fill.SupportGrid, ["RequiredMode"] = context.Mode};
					table.insert(actions, fill);
					table.insert(bridge, fill);
					writeCell(context, fill.Grid.X, fill.Grid.Y, fill.Grid.Z, fill);
					planned[cellKey(fill.Grid.X, fill.Grid.Y, fill.Grid.Z)] = true;
					blocks += 1;
				end;
			end;

			local placement: any = placementAt(context, from, v.x, v.y - 1, v.z, context.Mode, nil, options.Quick);
			if not placement then
				failure = {["Reason"] = "Placement", ["Index"] = #actions + 1, ["Grid"] = Vector3.new(v.x, v.y - 1, v.z)};
				break;
			end;

			placement.Type = "PlaceBlock";
			placement.Duration = 1 / agent.PlaceCps;
			placement.ExpectedPosition = from.Position;
			placement.Lead = math.max((context.Reach - placement.Distance) / agent.WalkSpeed, 0);
			placement.Preconditions = {
				["MaxDistance"] = context.Reach,
				["RequiredSupport"] = placement.SupportGrid,
				["RequiredMode"] = context.Mode,
				["Airborne"] = v.mt == "Tower" or nil,
				["MinHeight"] = v.mt == "Tower" and v.y * cellSize - halfCell or nil
			};

			table.insert(actions, placement);
			table.insert(bridge, placement);
			writeCell(context, v.x, v.y - 1, v.z, placement);
			planned[cellKey(v.x, v.y - 1, v.z)] = true;
			priorBridge, lastBridge = lastBridge, {["X"] = v.x, ["Z"] = v.z};
			blocks += 1;
		elseif v.mt ~= "Start" then
			priorBridge, lastBridge = nil, nil;
		end;

		if v.mt ~= "Start" then
			local previous: any = nodes[i - 1];
			damage += v.dmg;
			table.insert(actions, {
				["Type"] = v.mt == "Bridge" and "Walk" or (v.mt == "Tower" and "Jump" or v.mt),
				["Grid"] = Vector3.new(v.x, v.y, v.z),
				["Position"] = standPosition(agent, v.x, v.y, v.z),
				["Duration"] = math.max(v.g - previous.g - ((v.mt == "Bridge" or v.mt == "Tower") and context.PlaceCost + (previous.b >= context.Budgeted and context.ScarceCost or 0) or 0) - (v.air and context.JumpCost + context.AirCost * (v.air - (previous.air or 0)) + math.max(v.y - previous.y, 0) * cellSize * context.ClimbCost + v.dmg * context.RiskCost or 0) - ((v.ex or 0) - (previous.ex or 0)), 0),
				["Damage"] = v.dmg,
				["Cost"] = v.g,
				["AirTime"] = v.air,
				["Gap"] = v.air and math.sqrt((v.x - previous.x) ^ 2 + (v.z - previous.z) ^ 2) * cellSize * (1 - 1 / math.max(math.abs(v.x - previous.x), math.abs(v.z - previous.z))) or nil,
				["Rise"] = v.air and v.y - previous.y or nil,
				["From"] = v.air and Vector3.new(previous.x, previous.y, previous.z) or nil
			});
		end;
	end;

	context.World:Finish();
	table.clear(context.Fits);
	table.clear(context.Stands);

	if options.Smooth then
		local index: number = 2;
		while index <= #actions do
			local previous: any, move: any = actions[index - 1], actions[index];
			local from: Vector3 = previous.From or previous.Grid;
			if previous.Type == "Walk" and move.Type == "Walk" and previous.Grid.Y == move.Grid.Y and walkLine(context, move.Grid.Y, from.X, from.Z, move.Grid.X, move.Grid.Z) then
				move.From = from;
				move.Duration += previous.Duration;
				table.remove(actions, index - 1);
			else
				index += 1;
			end;
		end;
	end;

	local elapsed: number, lastPlace: number = 0, -math.huge;
	local interval: number = 1 / agent.PlaceCps;

	for _: any, v: any in actions do
		if v.Type == "PlaceBlock" then
			elapsed = math.max(elapsed, lastPlace + interval);
			lastPlace = elapsed;
		else
			table.insert(walking, v.Position);
		end;
		v.Time = elapsed;
		elapsed += v.Duration;
	end;

	local decisions: any = nil;
	if options.Debug then
		decisions = {};
		local segment: any = nil;
		for i: number, v: any in nodes do
			if v.mt == "Bridge" or v.mt == "Tower" then
				if not segment or segment.Kind ~= v.mt then
					segment = {["Kind"] = v.mt, ["From"] = nodes[i - 1], ["Count"] = 0};
					table.insert(decisions, segment);
				end;
				segment.Count += 1;
				segment.To, segment.Next = v, nodes[i + 1];
			else
				segment = nil;
				if v.air then
					table.insert(decisions, {["Kind"] = "Jump", ["From"] = nodes[i - 1], ["To"] = v, ["Count"] = 0});
				end;
			end;
		end;

		for i: number, v: any in decisions do
			local from: any, to: any = v.From, v.Next and v.Next.mt ~= "Bridge" and v.Next.mt ~= "Tower" and v.Next or v.To;
			local span: number = math.max(math.abs(to.x - from.x), math.abs(to.z - from.z));
			local gap: number = span > 0 and math.sqrt((to.x - from.x) ^ 2 + (to.z - from.z) ^ 2) * cellSize * (1 - 1 / span) or 0;
			local crossable: any, airTime: any, _: any, reason: any = traverse(agent, context.Traversal, gap, (to.y - from.y) * cellSize, agent.WalkSpeed);
			local explanation: string = v.Kind == "Jump" and "gap safely traversable" or v.Kind == "Tower" and (to.y > from.y and "destination requires useful elevation before horizontal traversal" or "no walkable route") or (crossable and "landing not standable or a detour, placing is cheaper" or reason == "TooHigh" and "landing too high to cross without blocks" or string.format("crossing needs %.2fs, above the %.2fs limit", airTime, context.Traversal.MaxAirTime));
			decisions[i] = {
				["Decision"] = v.Kind,
				["Reason"] = explanation,
				["CurrentGrid"] = Vector3.new(from.x, from.y, from.z),
				["TargetGrid"] = Vector3.new(to.x, to.y, to.z),
				["CurrentY"] = from.y,
				["TargetY"] = to.y,
				["Gap"] = gap,
				["AirTime"] = airTime,
				["MaxAirTime"] = context.Traversal.MaxAirTime,
				["RequiredBlocks"] = v.Count,
				["AvailableBlocks"] = context.Budgeted,
				["AlternativeJump"] = crossable,
				["Summary"] = string.format("Decision: %s | Reason: %s | CurrentGrid: %d,%d,%d | TargetGrid: %d,%d,%d | CurrentY: %d | TargetY: %d | Gap: %.1f studs | PredictedAirTime: %.2f | MaxAllowedAirTime: %.2f | RequiredBlocks: %d | AvailableBlocks: %s | AlternativeJump: %s", v.Kind, explanation, from.x, from.y, from.z, to.x, to.y, to.z, from.y, to.y, gap, airTime, context.Traversal.MaxAirTime, v.Count, tostring(context.Budgeted), tostring(crossable))
			};
		end;
	end;

	return {
		["Actions"] = actions,
		["BridgePath"] = bridge,
		["WalkingPath"] = walking,
		["Blocks"] = blocks,
		["Damage"] = damage,
		["Duration"] = elapsed,
		["Depends"] = depends,
		["Planned"] = planned,
		["Decisions"] = decisions,
		["Failure"] = failure
	};
end;

local standable: (context: any, x: number, y: number, z: number, depth: number) -> (any, any, any) = function(context: any, x: number, y: number, z: number, depth: number): (any, any, any)
	for offset: number = 0, 2 do
		if stands(context, x, y + offset, z) then
			return x, y + offset, z;
		end;
	end;

	for drop: number = 1, depth do
		if stands(context, x, y - drop, z) then
			return x, y - drop, z;
		end;
	end;

	for radius: number = 1, 2 do
		for deltaX: number = -radius, radius do
			for deltaZ: number = -radius, radius do
				if math.abs(deltaX) == radius or math.abs(deltaZ) == radius then
					for deltaY: number = 0, radius do
						if stands(context, x + deltaX, y + deltaY, z + deltaZ) then
							return x + deltaX, y + deltaY, z + deltaZ;
						end;
						if stands(context, x + deltaX, y - deltaY, z + deltaZ) then
							return x + deltaX, y - deltaY, z + deltaZ;
						end;
					end;
				end;
			end;
		end;
	end;

	return x, y, z;
end;

local resolveTarget: (goal: any) -> (any, any) = function(goal: any): (any, any)
	if typeof(goal) == "Vector3" then
		return goal, nil;
	end;
	if typeof(goal) == "Instance" then
		return goal:IsA("Model") and goal:GetPivot().Position or goal.Position, nil;
	end;
	if goal.Grid then
		return Vector3.new(goal.Grid.X * cellSize, goal.Grid.Y * cellSize, goal.Grid.Z * cellSize), goal.Grid;
	end;
	if goal.RootPart then
		return goal.RootPart.Position, nil;
	end;
	if goal.Character then
		return goal.Character:GetPivot().Position, nil;
	end;
	return goal.Position, nil;
end;

local arcPosition: (state: any, agent: any, elapsed: number) -> Vector3 = function(state: any, agent: any, elapsed: number): Vector3
	return state.Position + state.Velocity * elapsed - Vector3.new(0, agent.Gravity * elapsed * elapsed * 0.5, 0);
end;

local fallLine: (state: any, agent: any, height: number) -> (any, any, any, any, any) = function(state: any, agent: any, height: number): (any, any, any, any, any)
	local drop: number = state.Feet - height;
	local elapsed: number? = fallTime(drop, state.Velocity.Y, agent.Gravity);
	if not elapsed or elapsed <= 0 then
		return nil;
	end;

	local point: Vector3 = arcPosition(state, agent, elapsed);
	return gridAxis(point.X), gridAxis(point.Z), elapsed, impactSpeed(drop, -state.Velocity.Y, agent.Gravity), point;
end;

local footprint: table = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}};

local landingOf: (context: any, state: any, agent: any, config: any) -> any = function(context: any, state: any, agent: any, config: any): any
	local top: number = gridAxis(state.Feet + halfCell) - 1;

	for step: number = 0, math.ceil(config.Scan / cellSize) do
		local level: number = top - step;
		local x: any, z: any, elapsed: any, impact: any, point: any = fallLine(state, agent, level * cellSize + halfCell);
		if x then
			local solid: boolean = context.World:Solid(x, level, z);
			if not solid then
				for _: any, v: {number} in footprint do
					local footX: any, footZ: any = gridAxis(point.X + v[1] * agent.Radius), gridAxis(point.Z + v[2] * agent.Radius);
					if context.World:Solid(footX, level, footZ) then
						solid, x, z = true, footX, footZ;
						break;
					end;
				end;
			end;
			if solid then
				return {["Level"] = level, ["X"] = x, ["Z"] = z, ["Time"] = elapsed, ["Impact"] = impact, ["Damage"] = fallDamage(impact, agent), ["Point"] = point};
			end;
		end;
	end;

	return nil;
end;

local escapeScore: (context: any, x: number, y: number, z: number) -> number = function(context: any, x: number, y: number, z: number): number
	local count: number = 0;

	for _: any, v: {number} in flats do
		if context.World:Solid(x + v[1], y, z + v[3]) then
			count += 1;
		end;
	end;

	return count;
end;

local clutchCandidate: (context: any, state: any, agent: any, config: any, level: number, offset: {number}) -> (any, any) = function(context: any, state: any, agent: any, config: any, level: number, offset: {number}): (any, any)
	local x: any, z: any, elapsed: any, impact: any, point: any = fallLine(state, agent, level * cellSize + halfCell);
	if not x then
		return nil;
	end;

	x, z = x + offset[1], z + offset[3];
	if context.World:Solid(x, level, z) then
		return nil;
	end;

	local latency: number = agent.Latency + 1 / agent.PlaceCps;
	if elapsed <= latency then
		return nil;
	end;

	local drift: number = math.sqrt((point.X - x * cellSize) ^ 2 + (point.Z - z * cellSize) ^ 2);
	if drift > halfCell + agent.Radius then
		return nil;
	end;

	local placeDelay: number = 0;
	local predicted: any = buildState({["Position"] = arcPosition(state, agent, latency), ["Velocity"] = state.Velocity - Vector3.new(0, agent.Gravity * latency, 0)}, agent);
	local placement: any, reason: any = placementAt(context, predicted, x, level, z, context.Mode, nil, false);

	if not placement and reason == "Reach" then
		for step: number = 1, math.min(math.floor((elapsed - latency) / config.SampleTime), config.ReachSteps) do
			placeDelay = step * config.SampleTime;
			predicted = buildState({["Position"] = arcPosition(state, agent, latency + placeDelay), ["Velocity"] = state.Velocity - Vector3.new(0, agent.Gravity * (latency + placeDelay), 0)}, agent);
			placement, reason = placementAt(context, predicted, x, level, z, context.Mode, nil, false);
			if placement or reason ~= "Reach" then
				break;
			end;
		end;
	end;

	if not placement then
		return nil, reason;
	end;

	local damage: number = fallDamage(impact, agent);
	local escape: number = escapeScore(context, x, level, z);
	local reliability: number = placement.PlacementType == "Face" and 1 or (placement.PlacementType == "Diagonal" and 0.75 or 0.35);
	local margin: number = math.clamp((elapsed - latency - placeDelay) / math.max(latency, 0.05), 0, 1);
	local reach: number = math.clamp(1.2 - placement.Distance / context.Reach, 0, 1);
	local survival: number = math.min(reliability * margin * reach * math.clamp(1 - drift / (halfCell + agent.Radius), 0.25, 1) * (escape > 0 and 1 or 0.85), 0.99);

	return {
		["Type"] = (offset[1] ~= 0 or offset[3] ~= 0) and "Side" or (placement.Normal and placement.Normal.Y == 0 and "Wall" or "Direct"),
		["Grid"] = Vector3.new(x, level, z),
		["Placement"] = placement,
		["Time"] = latency + placeDelay,
		["Impact"] = impact,
		["Damage"] = damage,
		["Drift"] = drift,
		["Escape"] = escape,
		["Blocks"] = 1,
		["Survival"] = survival,
		["Score"] = config.Weights.Survival * survival - config.Weights.Damage * damage - config.Weights.Blocks + config.Weights.Escape * math.min(escape, 2) - config.Weights.Distance * placement.Distance
	};
end;

local clutchColumn: (context: any, state: any, agent: any, config: any, level: number) -> any = function(context: any, state: any, agent: any, config: any, level: number): any
	local anchor: any = nil;

	for step: number = 1, config.MaxChain do
		anchor = clutchCandidate(context, state, agent, config, level - step, {0, 0, 0}) or clutchCandidate(context, state, agent, config, level + step, {0, 0, 0});
		if anchor then
			break;
		end;
	end;

	if not anchor then
		return nil;
	end;

	context.World:Begin();
	writeCell(context, anchor.Grid.X, anchor.Grid.Y, anchor.Grid.Z, anchor.Placement);
	local deep: any = clutchCandidate(context, state, agent, config, level, {0, 0, 0});
	context.World:Finish();
	table.clear(context.Fits);
	table.clear(context.Stands);

	if not deep then
		return nil;
	end;

	local _: any, _: any, elapsed: any = fallLine(state, agent, level * cellSize + halfCell);
	local ready: number = math.max(anchor.Time, deep.Time) + 1 / agent.PlaceCps;
	if not elapsed or ready > elapsed then
		return nil;
	end;

	deep.Time = ready;
	deep.Type = "Column";
	deep.Chain = {anchor.Placement, deep.Placement};
	deep.Blocks = 2;
	deep.Survival *= anchor.Survival;
	deep.Score = config.Weights.Survival * deep.Survival - config.Weights.Damage * deep.Damage - config.Weights.Blocks * 2 + config.Weights.Escape * math.min(deep.Escape, 2) - config.Weights.Distance * deep.Placement.Distance;
	return deep;
end;

local clutchPlan: (context: any, state: any, agent: any, config: any, options: any) -> any = function(context: any, state: any, agent: any, config: any, options: any): any
	local landing: any = landingOf(context, state, agent, config);
	if landing and landing.Damage <= agent.DamageAllowance and not options.Force then
		return {["Reason"] = "Safe", ["Landing"] = landing};
	end;
	if not landing and not config.Void then
		return {["Reason"] = "Safe"};
	end;

	local deepest: number = math.ceil((state.Feet - math.min(safeDrop(state.Velocity.Y, agent), config.MaxFall) - halfCell) / cellSize);
	local top: number = gridAxis(state.Feet + halfCell) - 1;
	if landing and landing.Level >= deepest then
		return {["Reason"] = "Safe", ["Landing"] = landing};
	end;

	local best: any, settled: any, partial: boolean = nil, nil, false;
	for level: number = deepest, top do
		local candidate: any = clutchCandidate(context, state, agent, config, level, {0, 0, 0});

		for _: any, v: {number} in flats do
			local side: any = clutchCandidate(context, state, agent, config, level, v);
			if side and (not candidate or side.Score > candidate.Score) then
				candidate = side;
			end;
		end;

		if not candidate and config.MaxBlocks > 1 then
			candidate = clutchColumn(context, state, agent, config, level);
		end;

		if candidate and (not best or candidate.Score > best.Score) then
			best = candidate;
		end;

		if candidate and candidate.Survival >= config.MinSurvival then
			settled = candidate;
			break;
		end;
	end;

	best = settled or best;

	if not best then
		for level: number = deepest - 1, math.max(deepest - config.MaxChain * 2, landing and landing.Level + 1 or deepest - config.MaxChain * 2), -1 do
			local candidate: any = clutchCandidate(context, state, agent, config, level, {0, 0, 0});
			if candidate and (not best or candidate.Damage < best.Damage) then
				best, partial = candidate, true;
			end;
		end;
	end;

	if not best or (landing and partial and best.Damage >= landing.Damage) then
		return {["Reason"] = landing and "Unreachable" or "Void", ["Landing"] = landing};
	end;

	if config.Width > 1 and best.Blocks < config.MaxBlocks and best.Drift > halfCell * 0.5 then
		local directionX: number = math.abs(state.Velocity.X) > math.abs(state.Velocity.Z) and (state.Velocity.X > 0 and 1 or -1) or 0;
		local directionZ: number = directionX == 0 and (state.Velocity.Z > 0 and 1 or -1) or 0;

		context.World:Begin();
		writeCell(context, best.Grid.X, best.Grid.Y, best.Grid.Z, best.Placement);
		local extra: any = placementAt(context, buildState({["Position"] = arcPosition(state, agent, best.Time)}, agent), best.Grid.X + directionX, best.Grid.Y, best.Grid.Z + directionZ, context.Mode, nil, false);
		context.World:Finish();
		table.clear(context.Fits);
		table.clear(context.Stands);

		if extra then
			best.Chain = {best.Placement, extra};
			best.Blocks += 1;
			best.Type = "Platform";
		end;
	end;

	return {["Best"] = best, ["Landing"] = landing, ["Partial"] = partial};
end;

local merge: (base: any, override: any) -> any = function(base: any, override: any): any
	local merged: table = table.clone(base);
	if override then
		for key: string, v: any in override do
			merged[key] = v;
		end;
	end;
	return merged;
end;

local contextFor: (self: table, world: any, agent: any, costs: any, mode: string, options: any) -> any = function(self: table, world: any, agent: any, costs: any, mode: string, options: any): any
	local channel: string = options.Channel or "default";
	local context: any = self.Contexts[channel];

	if not context or context.World ~= world or context.Mode ~= mode or context.Height ~= math.max(math.ceil(agent.Height / cellSize), 1) then
		context = newContext(world, agent, mode);
		self.Contexts[channel] = context;
	else
		refresh(context);
	end;

	context.Agent = agent;
	context.Avoid = options.Avoid;
	context.Reach = options.Reach or agent.Reach;
	context.Floating = options.Floating == true;
	context.StepCost = cellSize / agent.WalkSpeed;
	context.DiagCost = context.StepCost * 1.4142 + costs.Diagonal;
	context.PlaceCost = 1 / agent.PlaceCps + costs.Block + (options.BlockProfile and options.BlockProfile.Cost or 0);
	context.JumpCost = costs.Jump;
	context.DropCost = costs.Drop;
	context.RiskCost = costs.Risk;
	context.FlatCost = 1 / agent.WalkSpeed;
	context.ClimbCost = (jumpLand(agent, cellSize) or 0.35) / cellSize;
	context.ClimbStep = cellSize / math.max(agent.WalkSpeed * 0.5, 1);
	context.TurnCost = costs.Diagonal;
	context.AirCost = costs.Air;
	context.ScarceCost = costs.Scarce;
	context.ElevationCost = costs.Elevation or 0;
	context.Budgeted = options.BlocksBudget or math.huge;
	context.Traversal = merge(self.Config.Traversal, options.Traversal);
	context.Dive = math.floor(agent.MaxDrop / cellSize);
	context.Rise = context.Traversal.Mover == "Glide" and context.Traversal.Rise or math.floor(agent.JumpVelocity * agent.JumpVelocity / (2 * agent.Gravity) / cellSize);
	context.Leap = select(3, traverse(agent, context.Traversal, 0, context.Traversal.Mover == "Glide" and 0 or -context.Dive * cellSize, agent.WalkSpeed));
	context.Span = math.max(math.floor(select(3, traverse(agent, context.Traversal, 0, 0, agent.WalkSpeed)) / cellSize), 0);
	return context;
end;

local route: (context: any, blocks: number, from: any, goal: any, options: any, request: any) -> (any, any, any) = function(context: any, blocks: number, from: any, goal: any, options: any, request: any): (any, any, any)
	local walk: any = options.Free and search(context, blocks, from, goal, options.Weight, options, request, "Walk") or nil;
	local node: any, reached: any, steps: any = walk and walk.node, walk ~= nil and walk.reached, walk and walk.steps or 0;

	if not reached and (not walk or options.Bridge ~= false and blocks > 0) then
		local ratio: number = (context.StepCost + context.PlaceCost) / context.StepCost;
		local stages: table = {{"Bridge", options.BridgeWeight}, {"Greedy", ratio + 0.5}, {"Greedy", ratio + 3}};
		if options.Fallback then
			table.insert(stages, 2, {"Bridge", options.Fallback});
		end;
		for _: any, v: {string | number} in stages do
			if request and request.Cancelled or v[1] == "Greedy" and (options.Bridge == false or blocks <= 0 or node and heuristic(context, node.x, node.y, node.z, goal.x, goal.y, goal.z) <= options.Tolerance * context.StepCost) then
				break;
			end;

			local pack: any = search(context, blocks, from, goal, v[2], options, request, v[1], walk);
			steps += pack.steps;

			if pack.node and (not node or heuristic(context, pack.node.x, pack.node.y, pack.node.z, goal.x, goal.y, goal.z) < heuristic(context, node.x, node.y, node.z, goal.x, goal.y, goal.z)) then
				node = pack.node;
			end;

			if pack.reached then
				node, reached = pack.node, true;
				break;
			end;
		end;
	end;

	if request and request.Cancelled or not reached and node and node.mt == "Start" then
		return nil, false, steps;
	end;

	return node, reached, steps;
end;

local requestClass: table = {};
requestClass.__index = requestClass;

requestClass.Cancel = function(self: table): ()
	self.Cancelled = true;
end;

requestClass.OnComplete = function(self: table, callback: any): ()
	if self.Done then
		callback(self.Result);
	else
		table.insert(self.Callbacks, callback);
	end;
end;

local dispatch: (self: table, channel: string, worker: any) -> any = function(self: table, channel: string, worker: any): any
	local request: table = setmetatable({["Cancelled"] = false, ["Done"] = false, ["Result"] = nil, ["Callbacks"] = {}, ["Channel"] = channel}, requestClass);
	local previous: any = self.Requests[channel];
	if previous then
		previous.Cancelled = true;
	end;
	self.Requests[channel] = request;

	task.spawn(function(): ()
		local result: any = worker(request);
		if request.Cancelled then
			return;
		end;

		request.Result = result;
		request.Done = true;
		if self.Requests[channel] == request then
			self.Requests[channel] = nil;
		end;

		for _: any, v: (...any) -> ...any in request.Callbacks do
			task.spawn(v, result);
		end;
	end);

	return request;
end;

local planClass: table = {};
planClass.__index = planClass;

local segmentDistance: (a: Vector3, b: Vector3, point: Vector3) -> (any, any, any) = function(a: Vector3, b: Vector3, point: Vector3): (any, any, any)
	local segment: Vector3 = b - a;
	local length: number = segment:Dot(segment);
	local raw: number = length > 0 and (point - a):Dot(segment) / length or 1;
	local t: number = math.clamp(raw, 0, 1);
	return (a + segment * t - point).Magnitude, t, raw;
end;

local corridor: (context: any, y: number, startX: number, startZ: number, endX: number, endZ: number, depends: any) -> boolean = function(context: any, y: number, startX: number, startZ: number, endX: number, endZ: number, depends: any): boolean
	local deltaX: number, deltaZ: number = endX - startX, endZ - startZ;
	local length: number = math.sqrt(deltaX * deltaX + deltaZ * deltaZ);
	if length == 0 then
		return true;
	end;

	local radius: number = context.Agent.Radius / cellSize;
	local samples: number = math.ceil(length * 2);
	for sample: number = 1, samples do
		local pointX: number, pointZ: number = startX + deltaX * sample / samples, startZ + deltaZ * sample / samples;
		local cellX: number, cellZ: number = math.round(pointX), math.round(pointZ);
		if (cellX ~= startX or cellZ ~= startZ) and (not stands(context, cellX, y, cellZ) or context.Avoid and context.Avoid[cellKey(cellX, y, cellZ)]) then
			return false;
		end;
		for _: any, v: {number} in footprint do
			if not fits(context, math.round(pointX + v[1] * radius), y, math.round(pointZ + v[2] * radius)) then
				return false;
			end;
		end;
		if depends then
			for offset: number = -1, context.Height - 1 do
				depends[cellKey(cellX, y + offset, cellZ)] = true;
			end;
		end;
	end;

	return true;
end;

local waypointsOf: (actions: any, level: number?) -> any = function(actions: any, level: number?): any
	local points: table, blocks: any = {}, nil;

	for _: any, v: any in actions do
		if v.Type == "PlaceBlock" then
			blocks = blocks or {};
			table.insert(blocks, v);
		elseif v.Grid then
			table.insert(points, {
				["Type"] = v.Type == "Walk" and level and v.Grid.Y > level and "Jump" or v.Type,
				["Grid"] = v.Grid,
				["Position"] = v.Position,
				["Center"] = v.Grid * cellSize,
				["Blocks"] = blocks,
				["Gap"] = v.Gap,
				["Rise"] = v.Rise,
				["AirTime"] = v.AirTime,
				["From"] = v.From,
				["Duration"] = v.Duration,
				["Damage"] = v.Damage,
				["Cost"] = v.Cost
			});
			blocks, level = nil, v.Grid.Y;
		elseif v.Position then
			table.insert(points, {["Type"] = v.Type or "Walk", ["Position"] = v.Position, ["Center"] = v.Position, ["Blocks"] = blocks});
			blocks = nil;
		end;
	end;

	if blocks then
		local last: any = points[#points];
		local position: any = last and last.Position or blocks[#blocks].ExpectedPosition or blocks[#blocks].Position;
		table.insert(points, {["Type"] = "Wait", ["Position"] = position, ["Center"] = position, ["Blocks"] = blocks});
	end;

	return points;
end;

local plain: (point: any, y: number) -> boolean = function(point: any, y: number): boolean
	return point.Type == "Walk" and point.Grid ~= nil and point.Blocks == nil and point.AirTime == nil and point.Grid.Y == y;
end;

local refine: (context: any, actions: any, start: Vector3, settingsValue: any, depends: any) -> any = function(context: any, actions: any, start: Vector3, settingsValue: any, depends: any): any
	local points: any = waypointsOf(actions, start.Y);
	local limit: number = math.max((settingsValue.Segment or 12) / cellSize, 1);
	local refined: table = {};
	local anchor: Vector3, anchorCost: number = start, 0;
	local index: number = 1;

	while index <= #points do
		local point: any = points[index];
		local reach: number = index;

		if anchor and plain(point, anchor.Y) then
			for ahead: number = index + 1, #points do
				local candidate: any = points[ahead];
				if not plain(candidate, anchor.Y) or not corridor(context, anchor.Y, anchor.X, anchor.Z, candidate.Grid.X, candidate.Grid.Z) then
					break;
				end;
				reach = ahead;
			end;
		end;

		if reach > index then
			local target: any = points[reach];
			local deltaX: number, deltaZ: number = target.Grid.X - anchor.X, target.Grid.Z - anchor.Z;
			local pieces: number = math.max(math.ceil(math.sqrt(deltaX * deltaX + deltaZ * deltaZ) / limit), 1);
			local duration: number, cost: any = 0, target.Cost or anchorCost;
			corridor(context, anchor.Y, anchor.X, anchor.Z, target.Grid.X, target.Grid.Z, depends);

			for step: number = index, reach do
				duration += points[step].Duration or 0;
			end;

			for piece: number = 1, pieces - 1 do
				local pieceX: number, pieceZ: number = anchor.X + deltaX * piece / pieces, anchor.Z + deltaZ * piece / pieces;
				table.insert(refined, {
					["Type"] = "Walk",
					["Grid"] = Vector3.new(math.round(pieceX), anchor.Y, math.round(pieceZ)),
					["Position"] = standPosition(context.Agent, pieceX, anchor.Y, pieceZ),
					["Center"] = Vector3.new(pieceX * cellSize, anchor.Y * cellSize, pieceZ * cellSize),
					["Duration"] = duration / pieces,
					["Cost"] = anchorCost + (cost - anchorCost) * piece / pieces,
					["Merged"] = true
				});
			end;

			target.Duration, target.Merged, target.From = duration / pieces, true, anchor;
			table.insert(refined, target);
			index = reach + 1;
		else
			table.insert(refined, point);
			index += 1;
		end;

		anchor, anchorCost = refined[#refined].Grid, refined[#refined].Cost or anchorCost;
	end;

	return refined;
end;

navigation.newPlan = function(result: any, options: any): ...any
	options = options or {};

	local points: any = result.Waypoints or waypointsOf(result.Actions or {});
	return setmetatable({
		["Revision"] = 0,
		["Kind"] = options.Kind or "Path",
		["TargetId"] = options.TargetId,
		["Target"] = options.Target,
		["Created"] = options.Now or os.clock(),
		["Result"] = result,
		["Waypoints"] = points,
		["Cursor"] = 1,
		["Origin"] = options.Origin or (points[1] and points[1].Position),
		["Cost"] = result.Cost or 0,
		["Blocks"] = result.BlocksUsed or 0,
		["World"] = options.World or result.World,
		["Checked"] = result.DirtyIndex or 0,
		["Flush"] = result.Flush,
		["Expired"] = false
	}, planClass);
end;

planClass.Point = function(self: table): any
	return self.Waypoints[self.Cursor];
end;

planClass.Solid = function(self: table, grid: Vector3?): boolean
	return self.World ~= nil and grid ~= nil and self.World:Solid(grid.X, grid.Y, grid.Z);
end;

planClass.Placed = function(self: table, point: any): boolean
	if not point.Blocks then
		return true;
	end;

	for _: any, v: any in point.Blocks do
		if not self:Solid(v.Grid) then
			return false;
		end;
	end;

	return true;
end;

planClass.Stale = function(self: table): boolean
	if self.Dirty then
		return true;
	end;

	local world: any, result: any = self.World, self.Result;
	if not world or not result.Depends then
		return false;
	end;
	if world.Flush ~= self.Flush then
		self.Dirty = true;
		return true;
	end;

	for i: number = self.Checked + 1, world.DirtyIndex do
		local key: number = world.Dirty[i];
		if result.Depends[key] and not (result.Planned and result.Planned[key]) then
			self.Dirty = true;
			return true;
		end;
	end;

	self.Checked = world.DirtyIndex;
	return false;
end;

planClass.Resume = function(self: table, position: Vector3, velocity: Vector3?, airborne: boolean?): (any, any)
	local points: any = self.Waypoints;
	if #points == 0 then
		self.Cursor = 1;
		return 1, 0;
	end;

	local flat: any = velocity and velocity * Vector3.new(1, 0, 1);
	local heading: Vector3? = airborne and flat and flat.Magnitude > 4 and flat.Unit or nil;
	local previous: Vector3 = self.Origin or points[1].Position;
	local best: number, score: number = 1, math.huge;

	for i: number, v: any in points do
		local distance: number = segmentDistance(previous, v.Position, position);
		if heading then
			local ahead: Vector3 = (v.Position - position) * Vector3.new(1, 0, 1);
			if ahead.Magnitude > 1 and ahead.Unit:Dot(heading) < -0.2 then
				distance += ahead.Magnitude;
			end;
		end;
		if distance <= score then
			best, score = i, distance;
		end;
		if not self:Placed(v) then
			break;
		end;
		previous = v.Position;
	end;

	self.Cursor = best;
	return best, score;
end;

planClass.Remaining = function(self: table): number
	local points: any = self.Waypoints;
	local last: any, before: any = points[#points], points[self.Cursor - 1];
	if not last or self.Cursor > #points then
		return 0;
	end;
	if last.Cost then
		return math.max(last.Cost - (before and before.Cost or 0), 0);
	end;
	return self.Cost * (#points - self.Cursor + 1) / #points;
end;

planClass.Left = function(self: table, position: Vector3?): number
	local total: number, previous: Vector3? = 0, position;
	for i: number = self.Cursor, #self.Waypoints do
		local point: Vector3 = self.Waypoints[i].Position;
		if previous then
			total += (point - previous).Magnitude;
		end;
		previous = point;
	end;
	return total;
end;

planClass.Pending = function(self: table): number
	local count: number = 0;
	for i: number = self.Cursor, #self.Waypoints do
		local blocks: any = self.Waypoints[i].Blocks;
		if blocks then
			for _: any, v: any in blocks do
				if not self:Solid(v.Grid) then
					count += 1;
				end;
			end;
		end;
	end;
	return count;
end;

planClass.NextBlock = function(self: table, index: number?): (any, any)
	for cursor: number = index or self.Cursor, #self.Waypoints do
		local blocks: any = self.Waypoints[cursor].Blocks;
		if blocks then
			for _: any, v: any in blocks do
				if not self:Solid(v.Grid) then
					return v, cursor;
				end;
			end;
		end;
	end;
	return nil;
end;

planClass.Profile = function(self: table, position: Vector3?): any
	local land: any = self.World and self.World.Land;
	local profile: table = {["Length"] = 0, ["Blocks"] = self:Pending(), ["Gaps"] = 0, ["Air"] = 0, ["Void"] = 0, ["Rise"] = 0, ["Turns"] = 0, ["Partial"] = self.Result.Partial == true};
	local previous: any, heading: any = position or self.Origin, nil;

	for i: number = self.Cursor, #self.Waypoints do
		local point: any = self.Waypoints[i];
		local step: Vector3 = previous and point.Position - previous or Vector3.zero;
		local flat: Vector3 = step * Vector3.new(1, 0, 1);
		local grid: Vector3 = point.Grid or navigation.WorldToGrid(point.Position);
		profile.Length += step.Magnitude;
		profile.Rise += math.max(step.Y, 0);
		if point.AirTime then
			profile.Gaps += 1;
			profile.Air = math.max(profile.Air, point.AirTime);
		end;
		if point.Blocks or point.AirTime or point.Ground == false or land and not land[cellKey(grid.X, 0, grid.Z)] then
			profile.Void += flat.Magnitude;
		end;
		if flat.Magnitude > 0.1 then
			profile.Turns += heading and heading:Dot(flat.Unit) < 0.5 and 1 or 0;
			heading = flat.Unit;
		end;
		previous = point.Position;
	end;

	return profile;
end;

planClass.Deviation = function(self: table, other: any): number
	local mine: any, theirs: any = self.Waypoints, other.Waypoints;
	if #mine == 0 or #theirs == 0 or self.Cursor > #mine then
		return math.huge;
	end;

	local worst: number = (mine[#mine].Position - theirs[#theirs].Position).Magnitude;
	for i: number = other.Cursor, math.min(other.Cursor + 5, #theirs) do
		local point: any, nearest: number = theirs[i].Position, math.huge;
		local previous: any = mine[self.Cursor - 1] and mine[self.Cursor - 1].Position or self.Origin or mine[1].Position;
		for cursor: number = self.Cursor, #mine do
			nearest = math.min(nearest, (segmentDistance(previous, mine[cursor].Position, point)));
			previous = mine[cursor].Position;
		end;
		worst = math.max(worst, nearest);
	end;

	return worst;
end;

navigation.SetWorld = function(self: table, world: any): ()
	self.World = world;
	table.clear(self.Contexts);
end;

navigation.FindPath = function(self: table, from: any, goal: any, options: any, request: any): any
	local started: number = os.clock();
	options = options or {};

	local world: any = options.World or self.World;
	local mode: string = options.Mode or "Legit";
	local agent: any = merge(self.Config.Agent, options.Agent);
	local costs: any = merge(self.Config.Costs, options.Costs);
	local settingsValue: any = merge(self.Config.Search, options.Search);

	if options.BlocksAvailable then
		agent.BlocksAvailable = options.BlocksAvailable;
	end;
	if options.Reach then
		agent.Reach = options.Reach;
	end;
	if options.Budget then
		settingsValue.Budget = options.Budget;
	end;
	if options.Yield ~= nil then
		settingsValue.Yield = options.Yield;
	end;
	settingsValue.BlocksAvailable = agent.BlocksAvailable;
	settingsValue.Debug = options.Debug;

	local context: any = contextFor(self, world, agent, costs, mode, options);
	local state: any = buildState(from, agent, world);
	local target: any, override: any = resolveTarget(goal);
	local revision: any, dirty: any, flush: any = world.Revision, world.DirtyIndex, world.Flush;

	if options.TargetVelocity then
		target += options.TargetVelocity * math.min((target - state.Position).Magnitude / agent.WalkSpeed, options.MaxLead or 1.5);
	end;

	local goalCell: Vector3 = override or Vector3.new(gridAxis(target.X), gridAxis(target.Y - agent.HipHeight + halfCell), gridAxis(target.Z));
	local startX: any, startY: any, startZ: any = standable(context, state.CellX, state.CellY, state.CellZ, math.ceil(agent.MaxDrop / cellSize));
	local goalX: any, goalY: any, goalZ: any = standable(context, goalCell.X, goalCell.Y, goalCell.Z, settingsValue.GoalDrop);
	local node: any, reached: any, steps: any = route(context, state.Blocks, {["x"] = startX, ["y"] = startY, ["z"] = startZ}, {["x"] = goalX, ["y"] = goalY, ["z"] = goalZ}, settingsValue, request);

	if not node then
		return {
			["Success"] = false,
			["Partial"] = false,
			["Reason"] = request and request.Cancelled and "Cancelled" or "NoPath",
			["Mode"] = mode,
			["WalkingPath"] = {},
			["BridgePath"] = {},
			["Actions"] = {},
			["Cost"] = 0,
			["Distance"] = 0,
			["BlocksUsed"] = 0,
			["Damage"] = 0,
			["Steps"] = steps,
			["Elapsed"] = os.clock() - started
		};
	end;

	local plan: any = compile(context, node, settingsValue);
	local waypoints: any = refine(context, plan.Actions, Vector3.new(startX, startY, startZ), settingsValue, plan.Depends);
	local continuous: boolean = true;
	for _: any, v: any in plan.BridgePath do
		if v.Lead <= 0 then
			continuous = false;
		end;
	end;

	return {
		["Success"] = reached and plan.Failure == nil,
		["Continuous"] = continuous,
		["Partial"] = not reached or plan.Failure ~= nil,
		["Reason"] = plan.Failure and plan.Failure.Reason or (reached and "Reached" or "Budget"),
		["Mode"] = mode,
		["WalkingPath"] = plan.WalkingPath,
		["BridgePath"] = plan.BridgePath,
		["Actions"] = plan.Actions,
		["Waypoints"] = waypoints,
		["Cost"] = node.g,
		["Distance"] = (standPosition(agent, node.x, node.y, node.z) - state.Position).Magnitude,
		["Duration"] = plan.Duration,
		["BlocksUsed"] = plan.Blocks,
		["Damage"] = plan.Damage,
		["Start"] = Vector3.new(startX, startY, startZ),
		["Goal"] = Vector3.new(goalX, goalY, goalZ),
		["Steps"] = steps,
		["Elapsed"] = os.clock() - started,
		["World"] = world,
		["Revision"] = revision,
		["DirtyIndex"] = dirty,
		["Flush"] = flush,
		["Depends"] = plan.Depends,
		["Planned"] = plan.Planned,
		["Decisions"] = plan.Decisions,
		["Failure"] = plan.Failure
	};
end;

navigation.EvaluateGap = function(self: table, horizontal: number, vertical: number, options: any): any
	options = options or {};

	local agent: any = merge(self.Config.Agent, options.Agent);
	local traversal: any = merge(self.Config.Traversal, options.Traversal);
	local crossable: any, airTime: any, reach: any, reason: any = traverse(agent, traversal, horizontal, vertical, options.Speed or agent.WalkSpeed);
	return {
		["Crossable"] = crossable,
		["AirTime"] = airTime,
		["MaxAirTime"] = traversal.MaxAirTime,
		["HorizontalDistance"] = horizontal,
		["VerticalDistance"] = vertical,
		["Reach"] = reach,
		["Confidence"] = crossable and math.clamp((reach - horizontal) / cellSize, 0, 1) or 0,
		["Reason"] = reason
	};
end;

navigation.FindPathAsync = function(self: table, from: any, goal: any, options: any): ...any
	options = options or {};
	return dispatch(self, options.Channel or "default", function(request: any): ...any
		return self:FindPath(from, goal, options, request);
	end);
end;

navigation.GetBlockCosts = function(self: table, from: any, goals: any, options: any): any
	options = options or {};

	local world: any = options.World or self.World;
	local settingsValue: any = merge(self.Config.Search, options.Search);
	if options.Yield ~= nil then
		settingsValue.Yield = options.Yield;
	end;

	local position: Vector3 = typeof(from) == "Vector3" and from or from.Position;
	local origin: table = {["x"] = gridAxis(position.X), ["y"] = gridAxis(position.Y - self.Config.Agent.HipHeight + halfCell), ["z"] = gridAxis(position.Z)};
	local field: any, _: any, box: any = world:Field(origin, origin, settingsValue.FieldMargin, options.Mode or "Legit", settingsValue.Yield and task and settingsValue.Budget);
	local costs: table = {};

	for key: any, v: any in goals do
		local target: Vector3 = resolveTarget(v);
		local x: any, z: any = gridAxis(target.X), gridAxis(target.Z);
		costs[key] = field and (field[cellKey(x, 0, z)] or math.max(box[1] - x, x - box[2], box[3] - z, z - box[4])) or 0;
	end;

	return costs;
end;

navigation.FindRetreat = function(self: table, from: any, threats: {Vector3}, options: any, request: any): any
	local started: number = os.clock();
	options = options or {};

	local world: any = options.World or self.World;
	local mode: string = options.Mode or "Legit";
	local agent: any = merge(self.Config.Agent, options.Agent);
	local settingsValue: any = merge(self.Config.Search, options.Search);
	local config: any = merge(self.Config.Retreat, options.Retreat);
	local weights: any = config.Weights;

	if options.Budget then
		settingsValue.Budget = options.Budget;
	end;
	if options.Yield ~= nil then
		settingsValue.Yield = options.Yield;
	end;
	settingsValue.BlocksAvailable = 0;
	settingsValue.Debug = options.Debug;

	local context: any = contextFor(self, world, agent, merge(self.Config.Costs, options.Costs), mode, options);
	local state: any = buildState(from, agent, world);
	local revision: any, dirty: any, flush: any = world.Revision, world.DirtyIndex, world.Flush;
	local startX: any, startY: any, startZ: any = standable(context, state.CellX, state.CellY, state.CellZ, math.ceil(agent.MaxDrop / cellSize));
	local pack: table = {["ctx"] = context, ["heap"] = {}, ["nodes"] = {}, ["closed"] = {}, ["weight"] = 0, ["gx"] = startX, ["gy"] = startY, ["gz"] = startZ, ["limit"] = 0, ["bridge"] = false, ["tower"] = false, ["gap"] = settingsValue.JumpGap ~= false, ["avoid"] = context.Avoid, ["reached"] = false, ["steps"] = 0};
	local start: table = {["x"] = startX, ["y"] = startY, ["z"] = startZ, ["g"] = 0, ["b"] = 0, ["mt"] = "Start", ["dmg"] = 0, ["f"] = 0};
	local best: any, score: number, nearest: number = nil, -math.huge, math.huge;
	local slice: number = os.clock() + settingsValue.Budget;

	if pack.gap then
		world:Columns(settingsValue.Yield and task and settingsValue.Budget);
	end;
	pack.nodes[cellKey(startX, startY, startZ)] = start;
	heapPush(pack.heap, start);

	while #pack.heap > 0 and pack.steps < config.MaxSteps do
		pack.steps += 1;

		if os.clock() >= slice then
			if request and request.Cancelled then
				break;
			end;
			if settingsValue.Yield and task then
				task.wait();
			end;
			slice = os.clock() + settingsValue.Budget;
		end;

		local node: any = heapPop(pack.heap);
		local key: number = cellKey(node.x, node.y, node.z);
		if pack.closed[key] then
			continue;
		end;
		pack.closed[key] = true;
		if node.g > config.MaxTime then
			break;
		end;

		local position: Vector3 = standPosition(agent, node.x, node.y, node.z);
		local closest: number = math.huge;
		for _: any, v: Vector3 in threats do
			closest = math.min(closest, (v - position).Magnitude);
		end;
		node.near = math.min(node.pr and node.pr.near or closest, closest);

		local openings: number, edges: number = 0, 0;
		for _: any, v: {number} in flats do
			if stands(context, node.x + v[1], node.y, node.z + v[3]) then
				openings += 1;
			elseif not context.World:Solid(node.x + v[1], node.y - 1, node.z + v[3]) and not dropTo(context, node.x + v[1], node.y, node.z + v[3]) then
				edges += 1;
			end;
		end;

		local value: number = weights.Distance * math.min(closest, config.SafeDistance) / config.SafeDistance + weights.Passage * math.min(node.near, config.SafeDistance / 2) / (config.SafeDistance / 2) + weights.Escape * openings / #flats - weights.Edge * edges / #flats - weights.Time * node.g;
		if value > score then
			local exposed: number = 0;
			for _: any, v: Vector3 in threats do
				if (v - position).Magnitude < config.SafeDistance * 1.5 and traceClear(context, v + Vector3.new(0, agent.HeadOffset, 0), position + Vector3.new(0, agent.HeadOffset, 0)) then
					exposed += 1;
				end;
			end;
			value -= #threats > 0 and weights.Exposure * exposed / #threats or 0;
			if value > score then
				best, score, nearest = node, value, closest;
			end;
		end;

		expand(pack, node);
	end;

	if not best or request and request.Cancelled then
		return {
			["Success"] = false,
			["Partial"] = false,
			["Reason"] = request and request.Cancelled and "Cancelled" or "NoPath",
			["Mode"] = mode,
			["WalkingPath"] = {},
			["BridgePath"] = {},
			["Actions"] = {},
			["Cost"] = 0,
			["Distance"] = 0,
			["BlocksUsed"] = 0,
			["Damage"] = 0,
			["Steps"] = pack.steps,
			["Elapsed"] = os.clock() - started
		};
	end;

	local plan: any = compile(context, best, settingsValue);
	return {
		["Success"] = plan.Failure == nil,
		["Partial"] = plan.Failure ~= nil,
		["Reason"] = plan.Failure and plan.Failure.Reason or "Retreat",
		["Mode"] = mode,
		["WalkingPath"] = plan.WalkingPath,
		["BridgePath"] = plan.BridgePath,
		["Actions"] = plan.Actions,
		["Waypoints"] = refine(context, plan.Actions, Vector3.new(startX, startY, startZ), settingsValue, plan.Depends),
		["Cost"] = best.g,
		["Score"] = score,
		["Nearest"] = nearest,
		["Distance"] = (standPosition(agent, best.x, best.y, best.z) - state.Position).Magnitude,
		["Duration"] = plan.Duration,
		["BlocksUsed"] = plan.Blocks,
		["Damage"] = plan.Damage,
		["Start"] = Vector3.new(startX, startY, startZ),
		["Goal"] = Vector3.new(best.x, best.y, best.z),
		["Steps"] = pack.steps,
		["Elapsed"] = os.clock() - started,
		["World"] = world,
		["Revision"] = revision,
		["DirtyIndex"] = dirty,
		["Flush"] = flush,
		["Depends"] = plan.Depends,
		["Planned"] = plan.Planned,
		["Decisions"] = plan.Decisions,
		["Failure"] = plan.Failure
	};
end;

navigation.FindClutch = function(self: table, from: any, options: any): any
	local started: number = os.clock();
	options = options or {};

	local world: any = options.World or self.World;
	local mode: string = options.Mode or "Legit";
	local agent: any = merge(self.Config.Agent, options.Agent);
	local costs: any = merge(self.Config.Costs, options.Costs);
	local config: any = merge(self.Config.Clutch, options.Clutch);

	if options.BlocksAvailable then
		agent.BlocksAvailable = options.BlocksAvailable;
		config.MaxBlocks = math.min(config.MaxBlocks, options.BlocksAvailable);
	end;
	if options.DamageAllowance then
		agent.DamageAllowance = options.DamageAllowance;
	end;

	local context: any = contextFor(self, world, agent, costs, mode, options);
	context.Reach = options.Reach or config.Reach;
	context.Floating = config.Anchored == false;

	local state: any = buildState(from, agent, world);
	local plan: any = clutchPlan(context, state, agent, config, options);

	if not plan.Best then
		return {
			["Success"] = false,
			["Partial"] = false,
			["Reason"] = plan.Reason,
			["Mode"] = mode,
			["Actions"] = {},
			["BridgePath"] = {},
			["WalkingPath"] = {},
			["BlocksUsed"] = 0,
			["Damage"] = plan.Landing and plan.Landing.Damage or 0,
			["TimeToImpact"] = plan.Landing and plan.Landing.Time or math.huge,
			["Survival"] = plan.Reason == "Safe" and 1 or 0,
			["Elapsed"] = os.clock() - started
		};
	end;

	local best: any = plan.Best;
	local placements: any = best.Chain or {best.Placement};
	local interval: number = 1 / agent.PlaceCps;
	local elapsed: number = math.max(best.Time - (#placements - 1) * interval, 0);
	local actions: table = {};

	for _: any, v: any in placements do
		v.Type = "PlaceBlock";
		v.Time = elapsed;
		v.Duration = interval;
		v.ExpectedPosition = arcPosition(state, agent, elapsed);
		v.Preconditions = {
			["MaxDistance"] = context.Reach,
			["RequiredSupport"] = v.SupportGrid,
			["RequiredMode"] = mode,
			["Airborne"] = true
		};
		table.insert(actions, v);
		elapsed += interval;
	end;

	local _: any, _: any, impactTime: any = fallLine(state, agent, best.Grid.Y * cellSize + halfCell);
	table.insert(actions, {
		["Type"] = "Land",
		["Grid"] = best.Grid,
		["Position"] = standPosition(agent, best.Grid.X, best.Grid.Y + 1, best.Grid.Z),
		["Time"] = impactTime or best.Time,
		["Duration"] = 0,
		["Damage"] = best.Damage
	});

	return {
		["Success"] = true,
		["Partial"] = plan.Partial == true,
		["Reason"] = best.Type,
		["Mode"] = mode,
		["ClutchType"] = best.Type,
		["Actions"] = actions,
		["BridgePath"] = placements,
		["WalkingPath"] = {},
		["BlocksUsed"] = best.Blocks,
		["Damage"] = best.Damage,
		["Impact"] = best.Impact,
		["Drift"] = best.Drift,
		["Survival"] = best.Survival,
		["Score"] = best.Score,
		["Grid"] = best.Grid,
		["TimeToImpact"] = plan.Landing and plan.Landing.Time or math.huge,
		["Elapsed"] = os.clock() - started,
		["World"] = world,
		["Revision"] = world.Revision,
		["DirtyIndex"] = world.DirtyIndex,
		["Flush"] = world.Flush,
		["Depends"] = {[cellKey(best.Grid.X, best.Grid.Y, best.Grid.Z)] = true}
	};
end;

navigation.FindClutchAsync = function(self: table, from: any, options: any): ...any
	options = options or {};
	return dispatch(self, options.Channel or "clutch", function(): ...any
		return self:FindClutch(from, options);
	end);
end;

navigation.SolvePlacement = function(self: table, from: any, grid: Vector3, options: any): any
	options = options or {};

	local world: any = options.World or self.World;
	local mode: string = options.Mode or "Legit";
	local agent: any = merge(self.Config.Agent, options.Agent);
	local context: any = contextFor(self, world, agent, merge(self.Config.Costs, options.Costs), mode, options);
	local placement: any, reason: any = placementAt(context, buildState(from, agent, world), grid.X, grid.Y, grid.Z, mode, nil, options.Quick);

	if placement then
		return placement;
	end;

	return {
		["Grid"] = grid,
		["Position"] = Vector3.new(grid.X * cellSize, grid.Y * cellSize, grid.Z * cellSize),
		["Mode"] = mode,
		["PlacementType"] = "None",
		["Distance"] = (Vector3.new(grid.X * cellSize, grid.Y * cellSize, grid.Z * cellSize) - (from.Position or from)).Magnitude,
		["Valid"] = false,
		["Reason"] = reason
	};
end;

navigation.SolveVoid = function(self: table, from: any, options: any): any
	options = options or {};

	local world: any = options.World or self.World;
	local mode: string = options.Mode or "Legit";
	local agent: any = merge(self.Config.Agent, options.Agent);
	local context: any = contextFor(self, world, agent, merge(self.Config.Costs, options.Costs), mode, options);
	local state: any = buildState(from, agent, world);
	local aim: Vector3 = state.Aim or (state.Velocity.Magnitude > 1 and Vector3.new(state.Velocity.X, 0, state.Velocity.Z).Unit or Vector3.new(0, -1, 0));

	for depth: number = 1, 3 do
		local level: number = gridAxis(state.Position.Y - depth * cellSize);
		if world:Block(state.CellX, level, state.CellZ) then
			local plane: number = level * cellSize + halfCell;
			local drop: number = state.Eye.Y - plane;
			local span: number = aim.Y < -0.05 and drop / -aim.Y or math.huge;
			local x: any, z: any = state.CellX, state.CellZ;

			if span < math.huge then
				x, z = gridAxis(state.Eye.X + aim.X * span), gridAxis(state.Eye.Z + aim.Z * span);
			end;

			local deltaX: any, deltaZ: any = x - state.CellX, z - state.CellZ;
			local steps: number = math.max(math.abs(deltaX), math.abs(deltaZ));
			for step: number = 0, steps do
				local cellX: number = state.CellX + (steps > 0 and math.round(deltaX * step / steps) or 0);
				local cellZ: number = state.CellZ + (steps > 0 and math.round(deltaZ * step / steps) or 0);
				if not world:Solid(cellX, level, cellZ) then
					local placement: any = placementAt(context, state, cellX, level, cellZ, mode, nil, options.Quick);
					if placement then
						placement.PlacementType = placement.PlacementType == "Face" and "Plane" or placement.PlacementType;
						return placement;
					end;
					break;
				end;
			end;
		end;
	end;

	local saveX: any, saveY: any, saveZ: any = voidSave(context, state);
	if saveX then
		local placement: any = placementAt(context, state, saveX, saveY, saveZ, mode, nil, options.Quick);
		if placement then
			placement.PlacementType = "Void";
			return placement;
		end;
	end;

	return nil;
end;

navigation.ValidatePath = function(self: table, result: any, options: any): (any, any, any)
	options = options or {};

	local world: any = options.World or result.World or self.World;
	local agent: any = merge(self.Config.Agent, options.Agent);
	local mode: string = result.Mode or "Legit";
	local context: any = contextFor(self, world, agent, merge(self.Config.Costs, options.Costs), mode, options);
	local blocks: number = options.BlocksAvailable or agent.BlocksAvailable;
	local used: number = 0;

	context.World:Begin();

	for i: number, v: any in result.Actions do
		if v.Type == "PlaceBlock" then
			used += 1;
			if used > blocks then
				context.World:Finish();
				return false, "Inventory", i;
			end;

			local placement: any, reason: any = placementAt(context, buildState({["Position"] = v.ExpectedPosition}, agent), v.Grid.X, v.Grid.Y, v.Grid.Z, mode, nil, options.Quick);
			if not placement then
				context.World:Finish();
				table.clear(context.Fits);
				table.clear(context.Stands);
				return false, reason, i;
			end;

			writeCell(context, v.Grid.X, v.Grid.Y, v.Grid.Z, placement);
		elseif v.Type ~= "Land" and v.Type ~= "Wait" and not stands(context, v.Grid.X, v.Grid.Y, v.Grid.Z) then
			context.World:Finish();
			table.clear(context.Fits);
			table.clear(context.Stands);
			return false, "Support", i;
		end;
	end;

	context.World:Finish();
	table.clear(context.Fits);
	table.clear(context.Stands);
	return true, "Valid", #result.Actions;
end;

navigation.GetState = function(self: table, from: any, options: any): (any, any)
	options = options or {};

	local world: any = options.World or self.World;
	local agent: any = merge(self.Config.Agent, options.Agent);
	local config: any = merge(self.Config.Clutch, options.Clutch);
	local context: any = contextFor(self, world, agent, merge(self.Config.Costs, options.Costs), options.Mode or "Legit", options);
	local state: any = buildState(from, agent, world);
	local landing: any = landingOf(context, state, agent, config);

	if state.Grounded and state.Velocity.Y >= 0 then
		return "Normal", landing;
	end;
	if not landing then
		return "Falling", nil;
	end;
	if landing.Damage > agent.DamageAllowance then
		return state.Velocity.Y < -agent.JumpVelocity and "Falling" or "Danger", landing;
	end;

	return "Normal", landing;
end;

navigation.IsStale = function(self: table, result: any): boolean
	local world: any = result.World or self.World;
	if not world or world.Revision == result.Revision then
		return false;
	end;
	if world.Flush ~= result.Flush then
		return true;
	end;

	for i: number = result.DirtyIndex + 1, world.DirtyIndex do
		local key: number = world.Dirty[i];
		if result.Depends[key] and not (result.Planned and result.Planned[key]) then
			return true;
		end;
	end;

	return false;
end;

local surfaceKey: (position: Vector3) -> number = function(position: Vector3): number
	return (math.round(position.X) * 131071 + math.round(position.Y)) * 131071 + math.round(position.Z);
end;

local gearOf: (itemMeta: any, inventory: any) -> (any, any) = function(itemMeta: any, inventory: any): (any, any)
	local sword: number, armor: table = 0, {};

	for _: any, v: any in {inventory.items, inventory.armor} do
		for _: any, stack: any in v or {} do
			local meta: any = itemMeta[type(stack) == "table" and stack.itemType or stack];
			if meta and meta.sword then
				sword = math.max(sword, meta.sword.damage or 0);
			end;
			if meta and meta.armor then
				armor[meta.armor.slot] = math.max(armor[meta.armor.slot] or 0, meta.armor.damageReductionMultiplier or 0);
			end;
		end;
	end;

	return sword, armor;
end;

navigation.newObserver = function(context: any, config: any): any
	local observer: table = {};
	local params: RaycastParams = RaycastParams.new();
	params.RespectCanCollide = true;
	local overlap: OverlapParams = OverlapParams.new();
	overlap.RespectCanCollide = true;
	local offsets: {Vector3} = {Vector3.new(3, 0, 0), Vector3.new(-3, 0, 0), Vector3.new(0, 0, 3), Vector3.new(0, 0, -3)};
	local lift: Vector3 = Vector3.new(0, 1, 0);
	local planar: Vector3 = Vector3.new(1, 0, 1);
	local excluded: table, surfaces: table, projectiles: table, obstacles: table = {}, {}, {}, {};
	local destinations: table, beds: table, drops: table = {}, {}, {};
	local roster: table, rosterPool: table, bedList: table, sites: table = {}, {}, {}, {["Generators"] = {}, ["Shops"] = {}, ["Upgrades"] = {}};
	local cached: number, tracked: number = 0, 0;
	local nextScan: number, nextDrops: number, nextFilter: number, nextUpper: number, nextSites: number = 0, 0, 0, 0, 0;
	local ownBed: any, base: any, lastCharacter: any, upperExit: any, upperOrigin: any;

	observer.Params, observer.Overlap, observer.Projectiles, observer.Obstacles = params, overlap, projectiles, obstacles;

	observer.Filter = function(force: boolean?): ()
		local now: number = os.clock();
		if not force and now < nextFilter then
			return;
		end;

		nextFilter = now + config.FilterInterval;
		table.clear(excluded);
		for _: any, v: Player in context.Players:GetPlayers() do
			if v.Character then
				table.insert(excluded, v.Character);
			end;
		end;
		if context.PathModel then
			table.insert(excluded, context.PathModel);
		end;
		if workspace.CurrentCamera then
			table.insert(excluded, workspace.CurrentCamera);
		end;
		params.FilterDescendantsInstances = excluded;
		overlap.FilterDescendantsInstances = excluded;
	end;

	observer.Mark = function(kind: string): ()
		if kind == "beds" then
			nextScan = 0;
		elseif kind == "drops" then
			nextDrops = 0;
		elseif kind == "filter" then
			nextFilter = 0;
		end;
	end;

	observer.Surface = function(position: Vector3, fresh: boolean?): any
		local key: any, now: number = surfaceKey(position), os.clock();
		local entry: any = surfaces[key];
		if entry and not fresh and now - entry.at < config.SurfaceLifetime then
			return entry;
		end;

		local depth: Vector3 = Vector3.new(0, -(context.Entity.character and context.Entity.character.HipHeight or 3) - 2, 0);
		local hit: RaycastResult? = workspace:Raycast(position + lift, depth, params);
		local sides: number = 0;
		if hit and hit.Normal.Y > 0.65 then
			for _: any, v: Vector3 in offsets do
				local side: RaycastResult? = workspace:Raycast(position + v + lift, depth, params);
				if side and side.Normal.Y > 0.65 and math.abs(side.Position.Y - hit.Position.Y) < 1 then
					sides += 1;
				end;
			end;
		end;

		if not entry then
			cached += 1;
			if cached > 512 then
				table.clear(surfaces);
				cached = 1;
			end;
		end;
		entry = {["at"] = now, ["safe"] = hit ~= nil and hit.Normal.Y > 0.65, ["narrow"] = sides <= 2, ["nearVoid"] = sides < 2, ["hit"] = hit};
		surfaces[key] = entry;
		return entry;
	end;

	observer.Ground = function(position: Vector3): (any, any)
		local hit: RaycastResult? = workspace:Raycast(position + lift, Vector3.new(0, -(context.Entity.character and context.Entity.character.HipHeight or 3) - 2, 0), params);
		return hit ~= nil and hit.Normal.Y > 0.65, hit;
	end;

	observer.Label = function(position: Vector3): boolean
		return workspace:Raycast(position, Vector3.new(0, -4, 0), params) ~= nil;
	end;

	observer.Footing = function(entity: any): boolean
		return workspace:Raycast(entity.RootPart.Position, Vector3.new(0, -70, 0), params) ~= nil or entity.RootPart.AssemblyLinearVelocity.Y > -10;
	end;

	observer.Drop = function(root: BasePart, humanoid: Humanoid): (any, any)
		local airborne: boolean = humanoid.FloorMaterial == Enum.Material.Air and not workspace:Raycast(root.Position, Vector3.new(0, -14, 0), params);
		return airborne, airborne and root.AssemblyLinearVelocity.Y < -12;
	end;

	observer.Gear = function(inventory: any): ...any
		if context.Gear then
			return context.Gear(inventory);
		end;
		return gearOf(context.bedwars.ItemMeta, inventory);
	end;

	observer.GearNeeded = function(team: any): ...any
		if context.GearNeeded then
			return context.GearNeeded(team);
		end;

		local itemMeta: any = context.bedwars.ItemMeta;
		local localTeam: any = context.Player:GetAttribute("Team") or -1;
		local needSword: number, needArmor: table = 0, {};
		for _: any, v: Player in context.Players:GetPlayers() do
			local playerTeam: any = v:GetAttribute("Team");
			local enemy: any = v ~= context.Player and (team and playerTeam == team or not team and playerTeam ~= localTeam);
			if enemy and v.Team and v.Team.Name ~= "Spectators" and context.Store.inventories[v] then
				local sword: any, armor: any = observer.Gear(context.Store.inventories[v]);
				needSword = math.max(needSword, sword);
				for slot: number, reduction: number in armor do
					needArmor[slot] = math.max(needArmor[slot] or 0, reduction);
				end;
			end;
		end;

		local sword: any, armor: any = observer.Gear(context.Store.inventory.inventory);
		if sword < math.min(needSword, itemMeta.stone_sword.sword.damage) then
			for _: any, v: string in {"wood_sword", "stone_sword"} do
				if itemMeta[v].sword.damage > sword then
					return false, v;
				end;
			end;
		end;

		local cap: any = itemMeta.iron_chestplate.armor;
		if (armor[cap.slot] or 0) < math.min(needArmor[cap.slot] or 0, cap.damageReductionMultiplier) then
			for _: any, v: string in {"leather_chestplate", "iron_chestplate"} do
				if itemMeta[v].armor.damageReductionMultiplier > (armor[cap.slot] or 0) then
					return false, v;
				end;
			end;
		end;

		if sword < needSword or (armor[cap.slot] or 0) < (needArmor[cap.slot] or 0) then
			if not context.Item("wood_bow") then
				return false, "wood_bow";
			end;
			if (context.Item("arrow") or {["amount"] = 0}).amount < 8 then
				return false, "arrow";
			end;
		end;

		return true;
	end;

	observer.Member = function(team: any): any
		for _: any, v: Player in context.Players:GetPlayers() do
			if v:GetAttribute("Team") == team and v.Team and v.Team.Name ~= "Spectators" then
				return v;
			end;
		end;
		return nil;
	end;

	local occupied: (position: Vector3, owner: any) -> boolean = function(position: Vector3, owner: any): boolean
		local team: any = context.Player:GetAttribute("Team") or -1;
		for _: any, v: Player in context.Players:GetPlayers() do
			local root: any = v.Character and (v.Character:GetAttribute("Health") or 0) > 0 and v.Character:FindFirstChild("HumanoidRootPart");
			if v:GetAttribute("Team") ~= team and v.Team and v.Team.Name ~= "Spectators" and (root and (root.Position - position).Magnitude <= 30 or not root and v:GetAttribute("Team") == owner) then
				return true;
			end;
		end;
		return false;
	end;

	observer.Bed = function(team: any): any
		if (context.Store.queueType or ""):find("skywars") then
			return nil;
		end;

		local localTeam: any = context.Player:GetAttribute("Team") or -1;
		local bed: any, distance: number = nil, math.huge;
		for _: any, v: BasePart in context.Collection:GetTagged("bed") do
			local teamId: any = v:GetAttribute("TeamId");
			if teamId ~= localTeam and (not team or teamId == team) and not v:GetAttribute(`Team{localTeam}NoBreak`) and observer.Member(teamId) then
				local magnitude: number = context.Player:DistanceFromCharacter(v.Position);
				if magnitude < distance then
					bed, distance = v, magnitude;
				end;
			end;
		end;
		return bed;
	end;

	observer.Enemy = function(range: number, origin: Vector3?): any
		observer.Filter();
		for _: any, v: any in context.Entity.AllPosition({["Range"] = range, ["Part"] = "RootPart", ["Players"] = true, ["Origin"] = origin}) do
			if observer.Footing(v) then
				return v;
			end;
		end;
		return nil;
	end;

	observer.Threat = function(range: number, origin: Vector3): (any, any, any)
		local entity: any = observer.Enemy(range, origin);
		if not entity then
			return nil;
		end;

		local offset: Vector3 = (entity.RootPart.Position - origin) * planar;
		local away: number = offset.Magnitude > 0 and (entity.RootPart.AssemblyLinearVelocity * planar):Dot(offset.Unit) or 0;
		return entity, (entity.RootPart.Position - origin).Magnitude, away;
	end;

	observer.Threats = function(range: number): any
		local threats: {Vector3} = {};
		for _: any, v: any in context.Entity.AllPosition({["Range"] = range, ["Part"] = "RootPart", ["Players"] = true}) do
			table.insert(threats, v.RootPart.Position);
		end;
		return threats;
	end;

	observer.Targets = function(): any
		local localTeam: any = context.Player:GetAttribute("Team") or -1;
		local targets: table = {};

		if not (context.Store.queueType or ""):find("skywars") then
			for _: any, v: BasePart in context.Collection:GetTagged("bed") do
				local teamId: any = v:GetAttribute("TeamId");
				if teamId and teamId ~= localTeam and not v:GetAttribute(`Team{localTeam}NoBreak`) and observer.Member(teamId) then
					table.insert(targets, {["Id"] = `bed:{teamId}`, ["Kind"] = "bed", ["Part"] = v, ["Team"] = teamId, ["Position"] = v.Position});
				end;
			end;
		end;

		observer.Filter();
		for _: any, v: any in context.Entity.AllPosition({["Range"] = 9e9, ["Part"] = "RootPart", ["Players"] = true}) do
			if observer.Footing(v) then
				table.insert(targets, {["Id"] = v.RootPart, ["Kind"] = "player", ["Part"] = v.RootPart, ["Entity"] = v, ["Position"] = v.RootPart.Position});
			end;
		end;

		return targets;
	end;

	observer.Beatable = function(team: any): (any, any)
		local sword: any, armor: any = observer.Gear(context.Store.inventory.inventory);
		local target: any, distance: number = nil, math.huge;

		for _: any, v: Player in context.Players:GetPlayers() do
			if v:GetAttribute("Team") == team and v.Team and v.Team.Name ~= "Spectators" then
				local character: Model? = v.Character;
				local root: any = character and character:FindFirstChild("HumanoidRootPart");
				local theirSword: any, theirArmor: any = observer.Gear(context.Store.inventories[v] or {});
				if root and (character:GetAttribute("Health") or 0) > 0 and not character:FindFirstChildWhichIsA("ForceField") and theirSword <= sword and (theirArmor[1] or 0) <= (armor[1] or 0) then
					local magnitude: number = context.Player:DistanceFromCharacter(root.Position);
					if magnitude < distance then
						target, distance = root, magnitude;
					end;
				end;
			end;
		end;

		return target, distance;
	end;

	observer.Generator = function(team: any, origin: Vector3): any
		local generator: any, distance: number = nil, math.huge;
		for _: any, v: Instance in context.Collection:GetTagged("Generator") do
			local id: string = v:GetAttribute("Id") or "";
			if id:find("generator") then
				local magnitude: number = team and id == `{team}_generator` and 0 or (origin - v.Position).Magnitude;
				if magnitude <= distance and not occupied(v.Position, id:match("^(.-)_generator")) then
					generator, distance = v, magnitude;
				end;
			end;
		end;
		return generator;
	end;

	observer.Shop = function(team: any, origin: Vector3): (any, any)
		local npc: any, shopId: any, distance: number = nil, nil, math.huge;
		for _: any, v: Instance in context.Collection:GetTagged("BedwarsItemShop") do
			local id: string = v:GetAttribute("Id") or "";
			local merchant: any = v:FindFirstChild("desertMerchant");
			local magnitude: number = team and id:find(`^{team}_`) and 0 or (origin - v.Position).Magnitude;
			if merchant and magnitude < distance and not occupied(v.Position, id:match("^(.-)_item_shop")) then
				npc, shopId, distance = merchant, id, magnitude;
			end;
		end;
		return npc, shopId;
	end;

	observer.Roster = function(): any
		table.clear(roster);
		for plr: Player in rosterPool do
			if plr.Parent == nil then
				rosterPool[plr] = nil;
			end;
		end;
		local team: string = tostring(context.Player:GetAttribute("Team"));
		local itemMeta: any = context.bedwars.ItemMeta;
		for _: any, v: Player in context.Players:GetPlayers() do
			if v == context.Player or not v.Team or v.Team.Name == "Spectators" then
				continue;
			end;

			local entry: any = rosterPool[v];
			if not entry then
				entry = {["player"] = v, ["id"] = tostring(v.UserId)};
				rosterPool[v] = entry;
			end;
			local character: Model? = v.Character;
			local root: any = character and character:FindFirstChild("HumanoidRootPart");
			local inventory: any = context.Store.inventories[v];
			entry.team = tostring(v:GetAttribute("Team"));
			entry.enemy = entry.team ~= team;
			entry.health = character and character:GetAttribute("Health") or 0;
			entry.maxHealth = character and character:GetAttribute("MaxHealth") or 100;
			entry.alive = root ~= nil and entry.health > 0;
			entry.root = root;
			entry.position = root and root.Position or nil;
			entry.velocity = root and root.AssemblyLinearVelocity or nil;
			entry.protected = character ~= nil and character:FindFirstChildOfClass("ForceField") ~= nil;
			entry.gearKnown = inventory ~= nil;
			entry.sword, entry.armor, entry.ranged, entry.emeralds, entry.diamonds = 0, 0, false, 0, 0;
			if inventory then
				local sword: any, armor: any = observer.Gear(inventory);
				entry.sword = sword;
				for _: any, reduction: number in armor do
					entry.armor += reduction;
				end;
				entry.armor = math.clamp(entry.armor, 0, 0.9);
				for _: any, stack: any in inventory.items or {} do
					local meta: any = itemMeta[stack.itemType];
					if meta and meta.projectileSource then
						entry.ranged = true;
					elseif stack.itemType == "emerald" then
						entry.emeralds += stack.amount or 1;
					elseif stack.itemType == "diamond" then
						entry.diamonds += stack.amount or 1;
					end;
				end;
			end;
			table.insert(roster, entry);
		end;
		return roster;
	end;

	observer.Beds = function(): any
		table.clear(bedList);
		if (context.Store.queueType or ""):find("skywars") then
			return bedList;
		end;

		local team: string = tostring(context.Player:GetAttribute("Team"));
		for _: any, v: BasePart in context.Collection:GetTagged("bed") do
			local owner: string = tostring(v:GetAttribute("TeamId"));
			table.insert(bedList, {["team"] = owner, ["part"] = v, ["position"] = v.Position, ["own"] = owner == team, ["locked"] = v:GetAttribute(`Team{team}NoBreak`) and true or false, ["shield"] = v:GetAttribute("BedShieldEndTime") or 0});
		end;
		return bedList;
	end;

	observer.Sites = function(force: boolean?): any
		local now: number = os.clock();
		if not force and now < nextSites then
			return sites;
		end;

		nextSites = now + config.ScanInterval;
		table.clear(sites.Generators);
		table.clear(sites.Shops);
		table.clear(sites.Upgrades);
		for _: any, v: Instance in context.Collection:GetTagged("Generator") do
			local id: string = v:GetAttribute("Id") or "";
			local owner: string? = id:match("^(.-)_generator$");
			local resource: string? = owner and "iron" or id:match("^(diamond)_") or id:match("^(emerald)_");
			if resource then
				table.insert(sites.Generators, {["id"] = id, ["target"] = v, ["position"] = v.Position, ["resource"] = resource, ["owner"] = owner});
			end;
		end;
		for _: any, v: Instance in context.Collection:GetTagged("BedwarsItemShop") do
			local merchant: any = v:FindFirstChild("desertMerchant");
			local part: any = merchant and merchant.PrimaryPart;
			if part then
				local id: string = v:GetAttribute("Id") or "";
				table.insert(sites.Shops, {["id"] = id, ["shopId"] = id, ["target"] = v, ["position"] = part.Position + part.CFrame.LookVector * 7, ["owner"] = id:match("^(.-)_item_shop")});
			end;
		end;
		for _: any, v: Instance in context.Collection:GetTagged("TeamUpgradeShopkeeper") do
			table.insert(sites.Upgrades, {["id"] = `upgrade:{tostring(v.Position)}`, ["target"] = v, ["position"] = v.Position + v.CFrame.LookVector * 5});
		end;
		return sites;
	end;

	observer.Stock = function(into: {[string]: number}): any
		table.clear(into);
		for _: any, v: Instance in context.Collection:GetTagged("ItemDrop") do
			for _: any, site: any in sites.Generators do
				if v.Name == site.resource and (v.Position - site.position).Magnitude <= 10 then
					into[site.id] = (into[site.id] or 0) + (v:GetAttribute("Amount") or 1);
					break;
				end;
			end;
		end;
		return into;
	end;

	observer.Cover = function(position: Vector3): number
		local grid: Vector3 = navigation.WorldToGrid(position);
		local count: number = 0;
		for x: number = -1, 1 do
			for y: number = 0, 1 do
				for z: number = -1, 1 do
					if x ~= 0 or y ~= 0 or z ~= 0 then
						local block: any = context.PlacedBlock((grid + Vector3.new(x, y, z)) * cellSize);
						if block and block.Name ~= "bed" then
							count += 1;
						end;
					end;
				end;
			end;
		end;
		return count;
	end;

	observer.Track = function(event: any): ()
		local shooter: any = event.shooter and context.Players:GetPlayerFromCharacter(event.shooter);
		if not shooter or shooter == context.Player or shooter:GetAttribute("Team") == context.Player:GetAttribute("Team") or typeof(event.origin) ~= "Vector3" or typeof(event.launchVelocity) ~= "Vector3" then
			return;
		end;

		local now: number = workspace:GetServerTimeNow();
		if tracked >= 64 then
			tracked = 0;
			for key: any, v: {origin: Vector3, velocity: Vector3, gravity: number, time: number} in projectiles do
				if now - v.time > config.ProjectileLifetime then
					projectiles[key] = nil;
				else
					tracked += 1;
				end;
			end;
		end;

		local projectileMeta: any = context.bedwars.ProjectileMeta[event.projectileType];
		projectiles[event] = {
			["origin"] = event.origin,
			["velocity"] = event.launchVelocity,
			["gravity"] = projectileMeta and projectileMeta.gravitationalAcceleration or 196.2,
			["time"] = now - math.clamp(context.Store.ping and context.Store.ping.total or 0, 0, 0.4) / 2
		};
		tracked += 1;
	end;

	observer.Projectile = function(position: Vector3, velocity: Vector3): any
		local now: number = workspace:GetServerTimeNow();
		for key: any, v: {origin: Vector3, velocity: Vector3, gravity: number, time: number} in projectiles do
			local elapsed: number = now - v.time;
			if elapsed > config.ProjectileLifetime then
				projectiles[key] = nil;
				tracked = math.max(tracked - 1, 0);
			else
				for step: number = -5, 30 do
					local flight: number = elapsed + step * 0.02;
					local offset: Vector3 = v.origin + v.velocity * flight - Vector3.new(0, v.gravity * 0.5 * flight * flight, 0) - position - velocity * (step * 0.02);
					if flight >= 0 and math.abs(offset.Y) <= 4.5 and (offset * planar).Magnitude <= 4 then
						return v;
					end;
				end;
			end;
		end;
		return nil;
	end;

	observer.Obstacle = function(position: Vector3): ()
		obstacles[tostring(position)] = true;
	end;

	observer.Obstructed = function(from: Vector3, to: Vector3, size: Vector3): any
		if not next(obstacles) or (to - from).Magnitude <= 0.1 then
			return false;
		end;
		local hit: RaycastResult? = workspace:Blockcast(CFrame.new(from), size, to - from, params);
		return hit and obstacles[tostring(hit.Instance.Position)] or false;
	end;

	observer.Clear = function(): ()
		table.clear(obstacles);
	end;

	local ranked: (candidates: any, valid: any, limit: number) -> any = function(candidates: any, valid: any, limit: number): any
		table.sort(candidates, function(a: any, b: any): any
			return a.score > b.score;
		end);
		local checked: number = 0;
		for _: any, v: any in candidates do
			if not valid then
				return v.top;
			end;
			checked += 1;
			if valid(v.top) then
				return v.top;
			end;
			if checked >= limit then
				break;
			end;
		end;
		return nil;
	end;

	observer.Perch = function(root: BasePart, hipHeight: number, enemies: any, valid: any): (any, any)
		local feet: RaycastResult? = workspace:Raycast(root.Position, Vector3.new(0, -12, 0), params);
		local feetY: number = feet and feet.Position.Y or root.Position.Y - hipHeight;
		local candidates: table = {};

		for offsetX: number = -30, 30, 3 do
			for offsetZ: number = -30, 30, 3 do
				local top: RaycastResult? = workspace:Raycast(Vector3.new(root.Position.X + offsetX, feetY + 60, root.Position.Z + offsetZ), Vector3.new(0, -90, 0), params);
				local distance: number = math.sqrt(offsetX * offsetX + offsetZ * offsetZ);
				if top and distance <= 30 and top.Position.Y - feetY >= 15 and not workspace:Raycast(top.Position + Vector3.new(0, 0.1, 0), Vector3.new(0, 6, 0), params) then
					local raised: Vector3 = Vector3.new(root.Position.X, top.Position.Y + hipHeight + 0.5, root.Position.Z);
					local across: Vector3 = Vector3.new(top.Position.X, raised.Y, top.Position.Z) - raised;
					local safe: boolean = not workspace:Raycast(root.Position, raised - root.Position, params) and (across.Magnitude < 0.1 or not workspace:Blockcast(CFrame.new(raised), Vector3.new(2, 4, 2), across, params));
					for _: any, v: any in enemies do
						if not safe then
							break;
						end;
						safe = (v.RootPart.Position - (top.Position + Vector3.new(0, hipHeight, 0))).Magnitude >= 18;
					end;
					if safe then
						table.insert(candidates, {["top"] = top.Position, ["score"] = top.Position.Y - feetY - distance * 0.3});
					end;
				end;
			end;
		end;

		return ranked(candidates, valid, config.PerchChecks or 12), feetY;
	end;

	observer.Landing = function(root: BasePart, hipHeight: number, valid: any): ...any
		local candidates: table = {};

		for offsetX: number = -30, 30, 3 do
			for offsetZ: number = -30, 30, 3 do
				local top: RaycastResult? = workspace:Raycast(Vector3.new(root.Position.X + offsetX, root.Position.Y + 15, root.Position.Z + offsetZ), Vector3.new(0, -75, 0), params);
				if top and not workspace:Raycast(top.Position + Vector3.new(0, 0.1, 0), Vector3.new(0, 6, 0), params) then
					local height: number = math.max(root.Position.Y, top.Position.Y + hipHeight + 0.5);
					local across: Vector3 = Vector3.new(top.Position.X, height, top.Position.Z) - Vector3.new(root.Position.X, height, root.Position.Z);
					if across.Magnitude < 0.1 or not workspace:Blockcast(CFrame.new(root.Position.X, height, root.Position.Z), Vector3.new(2, 4, 2), across, params) then
						table.insert(candidates, {["top"] = top.Position, ["score"] = -(top.Position - root.Position).Magnitude});
					end;
				end;
			end;
		end;

		return ranked(candidates, valid, config.PerchChecks or 12);
	end;

	observer.Valid = function(destination: any): any
		if destination.target and not destination.target.Parent then
			return false;
		end;
		if destination.player then
			return destination.player.Character == destination.target.Parent and (destination.target.Parent:GetAttribute("Health") or 0) > 0
				and tostring(destination.player:GetAttribute("Team")) == destination.owner and not destination.target.Parent:FindFirstChildOfClass("ForceField");
		end;
		return true;
	end;

	observer.Observe = function(now: number): any
		local character: Model? = context.Player.Character;
		local root: any = character and character:FindFirstChild("HumanoidRootPart");
		local humanoid: Humanoid? = character and character:FindFirstChildOfClass("Humanoid");
		local inventory: any = context.Store.inventory.inventory;
		local bedwars: any = context.bedwars;
		observer.Filter(character ~= lastCharacter);

		local snapshot: table = {
			["self"] = {
				["alive"] = context.Entity.isAlive and root ~= nil and humanoid ~= nil and humanoid.Health > 0 and (character:GetAttribute("Health") or humanoid.Health) > 0,
				["position"] = root and root.Position or Vector3.zero, ["velocity"] = root and root.AssemblyLinearVelocity or Vector3.zero,
				["health"] = character and character:GetAttribute("Health") or humanoid and humanoid.Health,
				["maxHealth"] = character and character:GetAttribute("MaxHealth") or humanoid and humanoid.MaxHealth,
				["grounded"] = humanoid and humanoid.FloorMaterial ~= Enum.Material.Air or false,
				["speed"] = humanoid and humanoid.WalkSpeed or 16, ["hipHeight"] = context.Entity.character and context.Entity.character.HipHeight or 3,
				["jumpVelocity"] = humanoid and (humanoid.UseJumpPower and humanoid.JumpPower or math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight)) or 42.6,
				["gravity"] = workspace.Gravity, ["placeInterval"] = 1 / (bedwars.SharedConstants.BLOCK_PLACE_CPS or 12),
				["resources"] = {}, ["blocks"] = 0, ["projectiles"] = 0, ["utilities"] = {}, ["armor"] = 0, ["swordDamage"] = 0, ["tools"] = {},
				["hotbar"] = context.Store.inventory.hotbar, ["selectedItem"] = context.Store.hand.tool and context.Store.hand.tool.Name,
				["inventoryCount"] = #inventory.items, ["reservedResources"] = {["iron"] = config.IronReserve},
				["blockReserve"] = config.BlockReserve, ["inventorySpace"] = context.InventorySpace and context.InventorySpace(),
				["canBuildUp"] = false
			},
			["environment"] = {["ownBed"] = ownBed, ["matchEnded"] = context.Store.matchState == 2, ["matchTime"] = 0, ["bedThreat"] = false, ["revision"] = navigation.World and navigation.World.Revision},
			["enemies"] = {}, ["teammates"] = {}, ["destinations"] = {}, ["hazards"] = {}, ["canBreakBed"] = context.BreakEnabled(),
			["sources"] = {["resources"] = "inventory", ["blocks"] = "inventory", ["armor"] = "inventory", ["swordDamage"] = "inventory", ["tools"] = "inventory", ["safeSurface"] = "raycast", ["nearVoid"] = "raycast", ["narrowBridge"] = "raycast", ["ownBed"] = "event"},
			["confidence"] = {["inventorySpace"] = context.InventorySpace and 1 or 0}
		};
		local armor: table = {};

		for _: any, v: any in {inventory.items, inventory.armor} do
			for _: any, stack: any in v or {} do
				local itemType: string = type(stack) == "table" and stack.itemType or stack;
				local meta: any = bedwars.ItemMeta[itemType];
				if meta and meta.armor then
					armor[meta.armor.slot] = math.max(armor[meta.armor.slot] or 0, meta.armor.damageReductionMultiplier or 0);
				end;
				if meta and meta.sword and (meta.sword.damage or 0) > snapshot.self.swordDamage then
					snapshot.self.swordDamage, snapshot.self.weapon = meta.sword.damage, itemType;
					snapshot.self.attackRange = math.min(meta.sword.attackRange or 10, config.LethalRange) * 0.8;
				end;
			end;
		end;
		for _: any, v: number in armor do
			snapshot.self.armor += v;
		end;
		snapshot.self.armor = math.clamp(snapshot.self.armor, 0, 0.9);

		for _: any, v: any in inventory.items do
			snapshot.self.resources[v.itemType] = (snapshot.self.resources[v.itemType] or 0) + v.amount;
			local meta: any = bedwars.ItemMeta[v.itemType];
			if meta and meta.block and v.itemType:find("wool") then
				snapshot.self.blocks += v.amount;
			end;
			if meta and meta.breakBlock then
				snapshot.self.tools[v.itemType] = meta.breakBlock;
			end;
			if meta and not meta.block and not meta.sword then
				table.insert(snapshot.self.utilities, v.itemType);
			end;
		end;
		snapshot.self.projectiles = #context.Projectiles({"arrow", "snowball"});
		if not snapshot.self.alive then
			return snapshot;
		end;

		if character ~= lastCharacter then
			lastCharacter, nextScan, nextDrops, upperExit = character, 0, 0, nil;
		end;

		local surface: any = observer.Surface(root.Position, true);
		snapshot.self.safeSurface, snapshot.self.nearVoid, snapshot.self.narrowBridge = surface.safe, surface.nearVoid, surface.narrow;
		snapshot.self.airborne = not snapshot.self.grounded;
		snapshot.self.falling = snapshot.self.airborne and root.AssemblyLinearVelocity.Y < -12 and not workspace:Raycast(root.Position, Vector3.new(0, -14, 0), params);
		snapshot.self.fallRisk = snapshot.self.falling or surface.nearVoid;

		local team: string = tostring(context.Player:GetAttribute("Team"));
		if now >= nextScan then
			nextScan, destinations, beds = now + config.ScanInterval, {}, {};
			local foundBed: any;
			for _: any, v: BasePart in context.Collection:GetTagged("bed") do
				local owner: string = tostring(v:GetAttribute("TeamId"));
				beds[owner] = {["value"] = true, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "event"};
				if owner == team then
					foundBed, ownBed, base = v, true, v.Position;
				elseif not v:GetAttribute(`Team{team}NoBreak`) then
					table.insert(destinations, {["id"] = `bed:{owner}`, ["kind"] = "enemybed", ["position"] = v.Position, ["target"] = v, ["owner"] = owner});
				end;
			end;
			if not foundBed and ownBed == true then
				ownBed = false;
			end;
			for _: any, v: Instance in context.Collection:GetTagged("Generator") do
				local id: string = v:GetAttribute("Id") or "";
				local owner: string? = id:match("^(.-)_generator$");
				local resource: string? = owner and "iron" or id:match("^(diamond)_") or id:match("^(emerald)_");
				if owner == team then
					base = base or v.Position;
				end;
				if resource and (not owner or owner == team) then
					table.insert(destinations, {["id"] = id, ["kind"] = "generator", ["position"] = v.Position, ["target"] = v, ["resource"] = resource, ["owner"] = owner});
				end;
			end;
			for _: any, v: Instance in context.Collection:GetTagged("BedwarsItemShop") do
				local id: string = v:GetAttribute("Id") or "";
				if id:match("^(.-)_item_shop") == team then
					local merchant: any = v:FindFirstChild("desertMerchant");
					local part: any = merchant and merchant.PrimaryPart;
					if part then
						table.insert(destinations, {["id"] = id, ["kind"] = "shop", ["position"] = part.Position + part.CFrame.LookVector * 7, ["target"] = v, ["shopId"] = id});
					end;
				end;
			end;
			for _: any, v: Instance in context.Collection:GetTagged("TeamUpgradeShopkeeper") do
				if base and (v.Position - base).Magnitude <= config.BedThreatRadius then
					table.insert(destinations, {["id"] = `upgrade:{tostring(v.Position)}`, ["kind"] = "upgrade", ["position"] = v.Position, ["target"] = v});
				end;
			end;
		end;

		snapshot.environment.ownBed, snapshot.environment.beds, snapshot.environment.base = ownBed, beds, base;
		if workspace.StreamingEnabled and ownBed == false then
			snapshot.environment.ownBed, snapshot.confidence.ownBed = nil, 0;
		end;
		for _: any, v: any in destinations do
			table.insert(snapshot.destinations, v);
		end;

		if now >= nextDrops then
			nextDrops = now + config.DropInterval;
			table.clear(drops);
			for _: any, v: Instance in context.Collection:GetTagged("ItemDrop") do
				if config.ResourceWeights[v.Name] and (v.Position - root.Position).Magnitude <= config.SupportRadius and not workspace:Raycast(root.Position, v.Position - root.Position, params) then
					table.insert(drops, {["id"] = `drop:{tostring(v.Position)}`, ["kind"] = "drop", ["position"] = v.Position, ["target"] = v, ["resource"] = v.Name});
				end;
			end;
		end;
		for _: any, v: any in drops do
			if v.target.Parent then
				table.insert(snapshot.destinations, v);
			end;
		end;

		if base then
			table.insert(snapshot.destinations, {["id"] = "base", ["kind"] = "base", ["position"] = base});
			snapshot.self.insideBase = (root.Position - base).Magnitude <= config.BaseRadius;
		end;

		for _: any, v: Player in context.Players:GetPlayers() do
			if v == context.Player or not v.Team or v.Team.Name == "Spectators" then
				continue;
			end;
			local other: Model? = v.Character;
			local part: any = other and other:FindFirstChild("HumanoidRootPart");
			local enemy: boolean = tostring(v:GetAttribute("Team")) ~= team;
			local visible: any = part and (part.Position - root.Position).Magnitude <= config.ThreatRadius and not workspace:Raycast(root.Position, part.Position - root.Position, params);
			local baseVisible: any = part and base and (part.Position - base).Magnitude <= config.BedThreatRadius and not workspace:Raycast(base + Vector3.new(0, 4, 0), part.Position - base - Vector3.new(0, 4, 0), params);
			visible = visible or baseVisible;
			if enemy and not visible then
				table.insert(snapshot.enemies, {["id"] = tostring(v.UserId), ["visible"] = false});
			elseif part and (other:GetAttribute("Health") or 0) > 0 then
				local entry: table = {
					["id"] = tostring(v.UserId), ["kind"] = enemy and "enemy" or "teammate", ["position"] = part.Position,
					["velocity"] = part.AssemblyLinearVelocity, ["health"] = other:GetAttribute("Health"),
					["visible"] = visible, ["target"] = part, ["player"] = v, ["owner"] = tostring(v:GetAttribute("Team")),
					["protected"] = other:FindFirstChildOfClass("ForceField") ~= nil
				};
				entry.threatensBed, entry.confidence = baseVisible, baseVisible and 0.75 or 1;
				if visible and context.Store.inventories[v] then
					local damage: any, protection: any = observer.Gear(context.Store.inventories[v]);
					entry.damage, entry.armor, entry.projectiles = damage, 0, false;
					for _: any, reduction: number in protection do
						entry.armor += reduction;
					end;
					entry.armor = math.clamp(entry.armor, 0, 0.9);
					for _: any, stack: any in context.Store.inventories[v].items or {} do
						local meta: any = bedwars.ItemMeta[stack.itemType];
						entry.projectiles = entry.projectiles or meta and meta.projectileSource ~= nil;
					end;
				end;
				table.insert(enemy and snapshot.enemies or snapshot.teammates, entry);
				if enemy and base and (part.Position - base).Magnitude <= config.BedThreatRadius then
					snapshot.environment.bedThreat = true;
				end;
				if not enemy then
					table.insert(snapshot.destinations, entry);
				end;
			end;
		end;

		for _: any, v: any in snapshot.teammates do
			for _: any, enemy: any in snapshot.enemies do
				if enemy.position and (enemy.position - v.position).Magnitude <= config.LethalRange then
					v.underPressure = true;
				end;
			end;
		end;

		snapshot.self.distanceToSafety = math.huge;
		for _: any, v: any in snapshot.destinations do
			if v.kind ~= "enemybed" then
				local distance: number, safe: boolean = (v.position - root.Position).Magnitude, true;
				for _: any, enemy: any in snapshot.enemies do
					if enemy.position and (v.position - enemy.position).Magnitude <= config.RouteEnemyRadius then
						safe = false;
					end;
				end;
				if safe and distance < snapshot.self.distanceToSafety and observer.Surface(v.position).safe then
					snapshot.self.distanceToSafety = distance;
				end;
			end;
		end;
		snapshot.self.escapeAvailable = snapshot.self.distanceToSafety < math.huge;
		snapshot.self.canBuildCover = surface.safe and snapshot.self.blocks > config.BlockReserve and not surface.nearVoid;
		snapshot.self.buildAvailable = snapshot.self.blocks > config.BlockReserve and (not context.CanPlace or context.CanPlace());
		snapshot.self.cover = false;

		local ranged: boolean, nearest: number = false, math.huge;
		for _: any, v: any in snapshot.enemies do
			if v.position then
				nearest = math.min(nearest, (v.position - root.Position).Magnitude);
				ranged = ranged or v.projectiles;
				snapshot.self.cover = snapshot.self.cover or workspace:Raycast(root.Position - Vector3.new(0, 2, 0), v.position - root.Position, params) ~= nil;
			end;
		end;
		snapshot.self.underPressure = nearest <= config.LethalRange;

		if surface.safe and not surface.nearVoid and not ranged and nearest > config.LethalRange * 0.5 and snapshot.self.blocks >= config.BlockReserve + 4 then
			if now >= nextUpper or not upperExit or (upperOrigin - root.Position).Magnitude > 3 then
				nextUpper, upperExit, upperOrigin = now + 0.3, {}, root.Position;
				for _: any, v: Vector3 in offsets do
					local upper: RaycastResult? = workspace:Raycast(root.Position + v * 2 + Vector3.new(0, 8, 0), Vector3.new(0, -8, 0), params);
					if upper and upper.Normal.Y > 0.65 and upper.Position.Y - surface.hit.Position.Y >= 3 and upper.Position.Y - surface.hit.Position.Y <= 6
						and not workspace:Raycast(upper.Position + Vector3.new(0, 0.1, 0), Vector3.new(0, 6, 0), params) then
						table.insert(upperExit, {["id"] = `upper:{tostring(upper.Position)}`, ["kind"] = "surface", ["position"] = upper.Position + Vector3.new(0, snapshot.self.hipHeight, 0)});
					end;
				end;
			end;
			for _: any, v: any in upperExit do
				local safe: boolean = true;
				for _: any, enemy: any in snapshot.enemies do
					if enemy.position and (v.position - enemy.position).Magnitude <= config.LethalRange then
						safe = false;
					end;
				end;
				if safe then
					snapshot.upperExit = v;
					snapshot.self.canBuildUp = true;
					break;
				end;
			end;
		end;

		if next(projectiles) then
			local projectile: any = observer.Projectile(root.Position, root.AssemblyLinearVelocity);
			if projectile then
				table.insert(snapshot.hazards, {["kind"] = "projectile", ["position"] = projectile.origin, ["velocity"] = projectile.velocity});
			end;
		end;
		if snapshot.self.nearVoid then
			table.insert(snapshot.hazards, {["kind"] = "void", ["position"] = root.Position});
		end;

		local started: any = bedwars.Store:getState().Game.startTime;
		snapshot.environment.matchTime = started and started > 0 and math.max(0, workspace:GetServerTimeNow() - started) or 0;
		local geared: any, missing: any = observer.GearNeeded();
		local item: any = snapshot.self.blocks < config.TravelBlocks and "wool_white" or not geared and missing;
		if not item and context.Store.shopLoaded and snapshot.environment.matchTime >= config.EarlyTime and snapshot.self.armor < 0.9 then
			for _: any, v: string in {"diamond_chestplate", "diamond_sword"} do
				local meta: any = bedwars.ItemMeta[v];
				if meta and not context.Item(v) and (meta.sword and meta.sword.damage > snapshot.self.swordDamage or meta.armor and (armor[meta.armor.slot] or 0) < meta.armor.damageReductionMultiplier) then
					item = v;
					break;
				end;
			end;
		end;
		if item and context.Store.shopLoaded then
			local purchase: any = bedwars.Shop.getShopItem(item, context.Player);
			if purchase and not purchase.disabled and not purchase.lockedByForge and (not purchase.ignoredByKit or not table.find(purchase.ignoredByKit, context.Store.equippedKit)) then
				local upgrade: any = purchase.require and purchase.require.teamUpgrade;
				local upgrades: any = bedwars.Store:getState().Bedwars.teamUpgrades;
				if not upgrade or (upgrades[upgrade.upgradeId] or -1) >= upgrade.lowestTierIndex then
					snapshot.purchase = {["item"] = item, ["currency"] = purchase.currency, ["cost"] = purchase.price + (item == "wool_white" and 0 or purchase.currency == "iron" and config.IronReserve or 0), ["price"] = purchase.price, ["data"] = purchase};
					snapshot.self.plannedPurchase = snapshot.purchase;
				end;
			end;
		end;
		if bedwars.TeamUpgradeMeta and snapshot.self.blocks >= config.TravelBlocks and (not snapshot.purchase or (snapshot.self.resources.diamond or 0) >= config.DiamondTarget) then
			local upgrades: any = bedwars.Store:getState().Bedwars.teamUpgrades[context.Player:GetAttribute("Team")] or {};
			for _: any, v: string in {"ARMOR", "DAMAGE"} do
				local meta: any = bedwars.TeamUpgradeMeta[v];
				local tier: any = meta and meta.tiers[(upgrades[v] or 0) + 1];
				if tier and (not meta.disabledInQueue or not table.find(meta.disabledInQueue, context.Store.queueType)) and (not tier.availableOnlyInQueue or table.find(tier.availableOnlyInQueue, context.Store.queueType)) then
					snapshot.purchase = {["item"] = v, ["upgrade"] = true, ["currency"] = "diamond", ["cost"] = tier.cost, ["price"] = tier.cost, ["tier"] = (upgrades[v] or 0) + 1};
					break;
				end;
			end;
		end;

		return snapshot;
	end;

	return observer;
end;

navigation.newActuator = function(context: any, config: any, observer: any): any
	local actuator: table = {};
	local params: any, overlap: any = observer.Params, observer.Overlap;
	local body: Vector3 = Vector3.new(1.8, 3.5, 1.8);
	local planar: Vector3 = Vector3.new(1, 0, 1);
	local logged: {[string]: number} = {};
	local nextShot: number = 0;
	local movement: any, jumpUntil: any;

	actuator.Stop = function(): ()
		movement, jumpUntil = nil, nil;
		if context.Entity.isAlive then
			context.Entity.character.Humanoid:Move(Vector3.zero, false);
		end;
	end;

	actuator.Move = function(position: Vector3, jump: boolean?, kind: string?): ()
		movement = {["position"] = position, ["jump"] = jump, ["kind"] = kind};
		if jump then
			jumpUntil = os.clock() + config.JumpCommitTime;
		end;
	end;

	actuator.Update = function(): ()
		if not context.Entity.isAlive or not context.Entity.character.RootPart.Parent then
			return;
		end;

		local root: BasePart = context.Entity.character.RootPart;
		local direction: Vector3 = movement and (movement.position - root.Position) * planar or Vector3.zero;
		if direction.Magnitude > 0.1 then
			local jump: any = jumpUntil and os.clock() <= jumpUntil;
			local step: Vector3 = direction.Unit * math.min(direction.Magnitude, 1);
			if not jump and (not observer.Ground(root.Position + step) and movement.kind ~= "Drop" or workspace:Blockcast(CFrame.new(root.Position), body, step, params)) then
				direction = Vector3.zero;
				observer.Blocked = (observer.Blocked or 0) + 1;
			end;
		end;

		context.Entity.character.Humanoid:Move(direction.Magnitude > 0.1 and direction.Unit or Vector3.zero, false);
		if movement and movement.jump then
			context.Entity.character.Humanoid.Jump = true;
			movement.jump = false;
		end;
	end;

	actuator.Look = function(position: Vector3): ()
		if not context.Entity.isAlive then
			return;
		end;

		local root: BasePart = context.Entity.character.RootPart;
		local direction: Vector3 = (position - root.Position) * planar;
		if direction.Magnitude > 0.1 then
			root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, root.Position + direction), 0.25);
		end;
	end;

	actuator.ValidateMove = function(action: any, airborne: boolean?): any
		local root: BasePart = context.Entity.character.RootPart;
		local direction: Vector3 = action.Position - root.Position;
		if direction.Magnitude < 0.1 then
			return true;
		end;
		if not observer.Surface(action.Position).safe then
			return false;
		end;

		local step: Vector3 = direction.Unit * math.min(direction.Magnitude, 2);
		if action.Type == "Jump" then
			return airborne or context.Entity.character.Humanoid.FloorMaterial ~= Enum.Material.Air and not workspace:Blockcast(CFrame.new(root.Position), body, Vector3.new(0, 4, 0), params);
		end;
		if action.Type == "Drop" then
			return root.Position.Y - action.Position.Y <= 12 and not workspace:Blockcast(CFrame.new(root.Position), body, step, params);
		end;
		return observer.Ground(root.Position + step) and not workspace:Blockcast(CFrame.new(root.Position), body, step, params);
	end;

	actuator.Block = function(grid: Vector3): boolean
		local block: any = context.PlacedBlock(grid * cellSize);
		return block ~= nil and workspace:Raycast(grid * cellSize + Vector3.new(0, 2, 0), Vector3.new(0, -3, 0), params) ~= nil;
	end;

	actuator.ValidatePlacement = function(placement: any, nextAction: any): boolean
		if not context.Entity.isAlive or not context.CanPlace() then
			return false;
		end;

		local root: BasePart = context.Entity.character.RootPart;
		if (root.Position - placement.Position).Magnitude > 18 then
			return false;
		end;
		if #workspace:GetPartBoundsInBox(CFrame.new(placement.Position), Vector3.new(2.8, 2.8, 2.8), overlap) > 0 then
			return false;
		end;
		if nextAction and nextAction.Type ~= "PlaceBlock" and math.abs(nextAction.Position.Y - placement.Position.Y) < 2 and ((nextAction.Position - placement.Position) * planar).Magnitude < 2 then
			return false;
		end;
		return true;
	end;

	actuator.Place = function(position: Vector3): ()
		local wool: any = context.Wool();
		if wool then
			context.bedwars.placeBlock(position, wool);
		end;
	end;

	actuator.Break = function(grid: Vector3): boolean
		local block: any = context.PlacedBlock(grid * cellSize);
		if block and context.bedwars.breakBlock then
			context.bedwars.breakBlock(block, true, true, nil, true);
			return true;
		end;
		return false;
	end;

	actuator.Build = function(kind: string, assessment: any, limit: number): any
		local root: BasePart = context.Entity.character.RootPart;
		local direction: Vector3 = assessment.target and assessment.target.position - root.Position or root.CFrame.LookVector;
		local grid: Vector3 = navigation.WorldToGrid(root.Position - Vector3.new(0, context.Entity.character.HipHeight + halfCell, 0));
		local name: string = kind == "BuildCover" and (assessment.highGround and assessment.ranged and "Roof" or assessment.chased and "RetreatBlocker" or "Cover") or kind;
		local pattern: any = navigation.Pattern(name, grid, name == "RetreatBlocker" and -direction or direction);
		local result: {Vector3} = {};

		for _: any, v: Vector3 in pattern or {} do
			if #result >= limit then
				break;
			end;
			if not actuator.Block(v) then
				table.insert(result, v);
			end;
		end;

		return result;
	end;

	actuator.Attack = function(destination: any): ()
		if not observer.Valid(destination) or not context.Entity.isAlive then
			return;
		end;

		local root: BasePart = context.Entity.character.RootPart;
		local sword: any = context.Store.tools.sword;
		if not sword or not sword.tool or (root.Position - destination.target.Position).Magnitude > config.LethalRange then
			return;
		end;
		if workspace:Raycast(root.Position, destination.target.Position - root.Position, params) then
			return;
		end;

		local slot: any = context.Hotbar(sword.tool);
		if slot and context.Store.inventory.hotbarSlot ~= slot then
			context.bedwars.Store:dispatch({["type"] = "InventorySelectHotbarSlot", ["slot"] = slot});
			return;
		end;
		if context.Store.hand.tool ~= sword.tool or not context.CanSwing() then
			return;
		end;

		actuator.Look(destination.target.Position);
		context.bedwars.SwordController:swingSwordAtMouse(0.39);
	end;

	actuator.Ranged = function(destination: any): ()
		if not destination or not observer.Valid(destination) or not context.Entity.isAlive or os.clock() < nextShot then
			return;
		end;

		local root: BasePart = context.Entity.character.RootPart;
		if workspace:Raycast(root.Position, destination.target.Position - root.Position, params) then
			return;
		end;

		local target: any;
		for _: any, v: any in context.Entity.List do
			if v.Player == destination.player then
				target = v;
				break;
			end;
		end;
		if not target then
			return;
		end;

		for _: any, v: any in context.Projectiles({"arrow", "snowball"}) do
			local item: any, ammo: any, projectile: any, meta: any = unpack(v);
			local slot: any = context.Hotbar(item.tool);
			if slot and context.Store.inventory.hotbarSlot ~= slot then
				context.bedwars.Store:dispatch({["type"] = "InventorySelectHotbarSlot", ["slot"] = slot});
				return;
			end;
			if context.Store.hand.tool == item.tool then
				nextShot = os.clock() + math.max(meta.fireDelaySec or 0, config.RangedInterval);
				context.FireProjectile(item, ammo, projectile, target);
			end;
			break;
		end;
	end;

	actuator.Pickup = function(destination: any): ()
		if observer.Valid(destination) and context.Entity.isAlive and (context.Entity.character.RootPart.Position - destination.target.Position).Magnitude <= config.ArrivalRadius then
			context.bedwars.Handler:Get("PickupItemDrop"):Fire("CallServerAsync", {["itemDrop"] = destination.target});
		end;
	end;

	actuator.Buy = function(destination: any, purchase: any, callback: any): ()
		if not observer.Valid(destination) or not context.Entity.isAlive or (context.Entity.character.RootPart.Position - destination.position).Magnitude > config.ArrivalRadius then
			callback(false);
			return;
		end;

		local bedwars: any = context.bedwars;
		local currency: any = context.Item(purchase.currency);
		if purchase.upgrade then
			local meta: any = bedwars.TeamUpgradeMeta[purchase.item];
			local upgrades: any = bedwars.Store:getState().Bedwars.teamUpgrades[context.Player:GetAttribute("Team")] or {};
			local tier: any = meta and meta.tiers[(upgrades[purchase.item] or 0) + 1];
			if currency and currency.amount >= purchase.cost and tier and tier.cost == purchase.price and (upgrades[purchase.item] or 0) + 1 == purchase.tier then
				bedwars.Handler:Get("RequestPurchaseTeamUpgrade"):Fire("CallServerAsync", purchase.item):andThen(function(success: any): ()
					callback(success == true);
				end);
			else
				callback(false);
			end;
			return;
		end;

		local current: any = bedwars.Shop.getShopItem(purchase.item, context.Player);
		if not currency or currency.amount < purchase.cost or not current or current.price ~= purchase.price or current.disabled or current.lockedByForge then
			callback(false);
			return;
		end;

		local promise: any = bedwars.Handler:Get("BedwarsPurchaseItem"):Fire("CallServerAsync", {["shopItem"] = current, ["shopId"] = destination.shopId});
		promise:andThen(function(success: any): ()
			callback(success == true);
		end);
		if promise.catch then
			promise:catch(function(): ()
				callback(false);
			end);
		end;
	end;

	actuator.BreakBed = function(destination: any): ()
		if observer.Valid(destination) and (destination.target:GetAttribute("BedShieldEndTime") or 0) <= workspace:GetServerTimeNow() then
			context.bedwars.breakBlock(destination.target, true, true, nil, true);
		end;
	end;

	actuator.Log = function(name: string, reason: string): ()
		if not context.DebugEnabled or not context.DebugEnabled() then
			return;
		end;

		local now: number = os.clock();
		if (logged[name] or 0) > now then
			return;
		end;
		logged[name] = now + config.DebugInterval;
		warn(`[catvape] brain {name} | {reason}`);
	end;

	return actuator;
end;

navigation.newInterface = function(context: any, config: any): any
	local interface: any = navigation.newObserver(context, config);
	for key: string, v: (...any) -> ...any in navigation.newActuator(context, config, interface) do
		interface[key] = v;
	end;
	return interface;
end;

local memoryClass: table = {};
memoryClass.__index = memoryClass;

local bound: (map: any, limit: number) -> () = function(map: any, limit: number): ()
	local count: number, oldest: any = 0, nil;
	for key: any, v: any in map do
		count += 1;
		if not oldest or v.timestamp < map[oldest].timestamp then
			oldest = key;
		end;
	end;
	if count > limit then
		map[oldest] = nil;
	end;
end;

navigation.newMemory = function(config: any): ...any
	return setmetatable({
		["Config"] = config,
		["failures"] = {},
		["successes"] = {},
		["routes"] = {},
		["surfaces"] = {},
		["events"] = {},
		["Version"] = 0
	}, memoryClass);
end;

memoryClass.Event = function(self: table, entry: any): any
	table.insert(self.events, entry);
	if #self.events > self.Config.MemoryLimit then
		table.remove(self.events, 1);
	end;
	return entry;
end;

memoryClass.Failure = function(self: table, key: any, reason: string, now: number, position: Vector3?): any
	local previous: any = self.failures[key];
	local entry: any = self:Event({["kind"] = "failure", ["key"] = key, ["reason"] = reason, ["timestamp"] = now, ["position"] = position});
	entry.count = previous and now - previous.timestamp < self.Config.FailureLifetime and previous.count + 1 or 1;
	self.failures[key] = entry;
	bound(self.failures, self.Config.MemoryLimit);
	return entry;
end;

memoryClass.Success = function(self: table, key: any, now: number): ()
	local previous: any = self.successes[key];
	self.failures[key] = nil;
	self.successes[key] = {["timestamp"] = now, ["count"] = previous and previous.count + 1 or 1};
	bound(self.successes, self.Config.MemoryLimit);
end;

memoryClass.Route = function(self: table, grid: Vector3, reason: string, now: number): ()
	local key: number = cellKey(grid.X, grid.Y, grid.Z);
	local previous: any = self.routes[key];
	self.routes[key] = {["grid"] = grid, ["reason"] = reason, ["timestamp"] = now, ["count"] = previous and now - previous.timestamp < self.Config.AvoidLifetime and previous.count + 1 or 1};
	bound(self.routes, self.Config.MemoryLimit);
	self.Version += 1;
	self:Event({["kind"] = "route", ["key"] = key, ["reason"] = reason, ["timestamp"] = now, ["position"] = grid * cellSize});
end;

memoryClass.Avoid = function(self: table, now: number): any
	if self.AvoidVersion == self.Version and now - (self.AvoidAt or -math.huge) < 1 then
		return self.Avoided;
	end;

	local avoid: {[number]: number}? = nil;
	for key: number, v: {grid: Vector3, reason: string, timestamp: number, count: number} in self.routes do
		if now - v.timestamp < self.Config.AvoidLifetime then
			avoid = avoid or {};
			avoid[key] = v.count * self.Config.AvoidPenalty;
		end;
	end;

	self.Avoided, self.AvoidVersion, self.AvoidAt = avoid, self.Version, now;
	return avoid;
end;

memoryClass.Surface = function(self: table, position: Vector3, now: number): ()
	local previous: any = self.surfaces[#self.surfaces];
	if not previous or (previous.position - position).Magnitude > self.Config.BaseRadius then
		table.insert(self.surfaces, {["id"] = `surface:{now}`, ["kind"] = "surface", ["position"] = position, ["timestamp"] = now, ["confidence"] = 1});
		if #self.surfaces > self.Config.MemoryLimit then
			table.remove(self.surfaces, 1);
		end;
	end;
end;

memoryClass.Expire = function(self: table, now: number): ()
	for key: string, v: any in self.failures do
		if now - v.timestamp > self.Config.FailureLifetime then
			self.failures[key] = nil;
		end;
	end;
	for key: number, v: {grid: Vector3, reason: string, timestamp: number, count: number} in self.routes do
		if now - v.timestamp > self.Config.AvoidLifetime then
			self.routes[key] = nil;
			self.Version += 1;
		end;
	end;
end;

local mindClass: table = {};
mindClass.__index = mindClass;

local deepMerge: (base: any, override: any) -> any;
deepMerge = function(base: any, override: any): any
	local result: table = {};
	for key: string, v: any in base do
		result[key] = type(v) == "table" and deepMerge(v, override and override[key]) or v;
	end;
	for key: string, v: any in override or {} do
		if type(v) ~= "table" then
			result[key] = v;
		end;
	end;
	return result;
end;

navigation.newMind = function(config: any): ...any
	local merged: any = deepMerge(navigation.Config.Mind, config);
	return setmetatable({
		["Config"] = merged,
		["WorldState"] = {["self"] = {}, ["environment"] = {}, ["enemies"] = {}, ["teammates"] = {}},
		["Memory"] = navigation.newMemory(merged),
		["GoalStack"] = {},
		["Debug"] = {},
		["Revision"] = 0,
		["Retreating"] = false,
		["Recovery"] = 0,
		["NextAction"] = 0
	}, mindClass);
end;

mindClass.Observe = function(self: table, snapshot: any, now: number): ()
	if self.Snapshot and self.Snapshot.environment.ownBed == true and snapshot.environment.ownBed == false then
		self:Record("bedlost", "base", "Bed lost; switch to survival risk limits", now);
	end;

	self.Snapshot = snapshot;
	for _: any, v: string in {"self", "environment"} do
		for key: string, value: any in snapshot[v] or {} do
			local source: any = snapshot.sources and snapshot.sources[key] or (v == "self" and "character" or "cache");
			self.WorldState[v][key] = {["value"] = value, ["timestamp"] = now, ["confidence"] = snapshot.confidence and snapshot.confidence[key] or 1, ["source"] = source};
		end;
		for key: string, entry: any in self.WorldState[v] do
			if (snapshot[v] or {})[key] == nil then
				entry.confidence = math.max(0, 1 - (now - entry.timestamp) / self.Config.ObservationLifetime);
			end;
		end;
	end;

	for _: any, v: string in {"enemies", "teammates"} do
		for _: any, member: any in snapshot[v] or {} do
			if member.visible or v == "teammates" then
				self.WorldState[v][member.id] = {["value"] = member, ["timestamp"] = now, ["confidence"] = member.confidence or 1, ["source"] = "raycast"};
			elseif not self.WorldState[v][member.id] then
				self.WorldState[v][member.id] = {["value"] = {["id"] = member.id}, ["timestamp"] = now, ["confidence"] = 0, ["source"] = "cache"};
			end;
		end;
		for key: any, entry: any in self.WorldState[v] do
			entry.confidence = entry.value.position and math.max(0, 1 - (now - entry.timestamp) / self.Config.EnemyLifetime) * (entry.value.confidence or 1) or 0;
			if now - entry.timestamp > self.Config.EnemyLifetime then
				self.WorldState[v][key] = nil;
			end;
		end;
	end;

	self.Memory:Expire(now);
	if snapshot.self.safeSurface and snapshot.self.position then
		self.Memory:Surface(snapshot.self.position, now);
	end;

	self.ObservedAt = now;
	self.WorldState.environment.destinations = {["value"] = snapshot.destinations, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "cache"};
	self.WorldState.environment.bedThreat = {["value"] = snapshot.environment.bedThreat, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "character"};
	for _: any, v: string in {"inventorySpace", "healing", "storage", "canBuildUp", "escapeAvailable", "currentTarget", "currentSubgoal", "currentRoute", "currentEscapeRoute"} do
		if not self.WorldState.self[v] then
			self.WorldState.self[v] = {["timestamp"] = now, ["confidence"] = 0, ["source"] = "cache"};
		end;
	end;
end;

mindClass.Gate = function(self: table, ratio: number, danger: boolean?, pressure: boolean?): boolean
	if ratio <= self.Config.LowHealth or danger then
		self.Retreating = true;
	elseif self.Retreating and ratio >= self.Config.RecoverHealth and not pressure then
		self.Retreating = false;
	end;
	return self.Retreating;
end;

mindClass.Assess = function(self: table, now: number): any
	local state: any, environment: any = self.Snapshot.self, self.Snapshot.environment;
	local config: any = self.Config;
	local ratio: number = state.health and state.maxHealth and state.maxHealth > 0 and math.clamp(state.health / state.maxHealth, 0, 1) or 0;
	local result: table = {["ratio"] = ratio, ["count"] = 0, ["pressure"] = 0, ["damage"] = 0, ["support"] = 0, ["valuable"] = 0, ["nearest"] = math.huge, ["ranged"] = false, ["chased"] = false, ["uncertainty"] = 0};

	for resource: string, v: number in config.ResourceWeights do
		result.valuable += ((state.resources or {})[resource] or 0) * v;
	end;
	result.carrying = result.valuable >= config.ValuableThreshold;

	for _: any, v: any in self.WorldState.teammates do
		if v.value.position and (v.value.position - state.position).Magnitude <= config.SupportRadius and v.confidence > 0.5 then
			result.support += 1;
		end;
	end;

	for _: any, v: any in self.WorldState.enemies do
		local enemy: any = v.value;
		if not enemy.position or v.confidence <= 0 then
			result.uncertainty += 1;
			continue;
		end;

		local distance: number = (enemy.position - state.position).Magnitude;
		local current: any = now - v.timestamp <= config.ThinkInterval * 2 and enemy.visible;
		if distance < config.ThreatRadius then
			local proximity: number = 1 - distance / config.ThreatRadius;
			local damage: number = (enemy.damage or config.UnknownDamage) * (1 - (state.armor or 0));
			result.pressure += proximity * config.Weights.Enemy * (current and 1 or math.max(v.confidence, 0.25));
			if current then
				if distance <= config.LethalRange then
					result.count += 1;
				end;
				result.damage = math.max(result.damage, damage);
				result.ranged = result.ranged or enemy.projectiles == true;
				if distance < result.nearest then
					result.nearest, result.target = distance, enemy;
				end;
				local direction: Vector3 = state.position - enemy.position;
				result.chased = result.chased or direction.Magnitude > 0.1 and (enemy.velocity or Vector3.zero):Dot(direction.Unit) > config.ChaseSpeed;
			else
				result.uncertainty += proximity * v.confidence;
			end;
		end;
	end;

	result.highGround = result.target and result.target.position.Y - state.position.Y > config.HighGround or false;
	result.oneHit = result.damage > 0 and (state.health or 0) <= result.damage;
	result.twoHits = result.damage > 0 and (state.health or 0) <= result.damage * 2;
	result.incoming = result.damage * math.max(result.count, 1) * config.ForecastTime / config.AttackInterval;
	result.escapeTime = state.distanceToSafety and state.distanceToSafety / math.max(state.speed or 1, 1) or math.huge;
	result.canEscape = state.escapeAvailable == true and (result.nearest > config.LethalRange or result.escapeTime < (state.health or 0) / math.max(result.incoming, 1) * config.ForecastTime);
	result.score = result.pressure + math.max(result.count - 1, 0) * config.Weights.ExtraEnemy
		+ (result.highGround and config.Weights.Elevation or 0)
		+ (result.ranged and config.Weights.Projectile or 0)
		+ (state.nearVoid and config.Weights.Void or 0)
		+ (state.narrowBridge and config.Weights.Narrow or 0)
		+ math.min(result.uncertainty, 1) * config.Weights.Uncertainty
		+ (1 - ratio) * config.Weights.Health
		+ (environment.ownBed ~= true and config.Weights.NoBed or 0)
		- result.support * config.Weights.Support
		- (state.cover and config.Weights.Cover or 0)
		- (state.escapeAvailable and config.Weights.Escape or 0);
	result.healthState = (ratio <= config.CriticalHealth or result.oneHit and result.nearest <= config.LethalRange and (state.nearVoid or result.carrying or result.count > 1)) and "Critical" or nil;
	result.healthState = result.healthState or (ratio <= config.LowHealth and "Low" or ratio < config.HighHealth and "Medium" or "High");
	result.phase = environment.ownBed == false and "Late" or (environment.matchTime or 0) >= config.LateTime and "Late" or (environment.matchTime or 0) >= config.EarlyTime and "Mid" or "Early";

	local enemyHealth: number = result.target and result.target.health or config.UnknownEnemyHealth;
	local dealt: number = (state.swordDamage or 0) * (1 - (result.target and result.target.armor or config.UnknownArmor));
	result.fightScore = (ratio - enemyHealth / config.UnknownEnemyHealth) * config.Weights.Health
		+ (dealt - result.damage) * config.Weights.Equipment
		+ result.support * config.Weights.Support + (result.count <= 1 and config.Weights.Isolation or 0)
		- result.score - result.valuable * config.Weights.Resources;
	result.finish = result.target and enemyHealth <= dealt and result.nearest <= config.LethalRange and result.count == 1
		and not state.nearVoid and not state.narrowBridge and not result.highGround and state.escapeAvailable == true
		and (not result.oneHit or result.support >= config.FinishSupport) and not result.carrying;

	self:Gate(ratio, result.healthState == "Critical" or result.count > 1 and result.score >= config.MaxThreat, result.count > 0 or result.score >= config.MaxThreat);
	self.Assessment = result;
	return result;
end;

mindClass.RouteRisk = function(self: table, positions: {Vector3}, now: number): (any, any)
	local risk: number, nearest: number, unknown: boolean = 0, math.huge, false;

	for _: any, v: any in self.WorldState.enemies do
		if not v.value.position then
			unknown = true;
			continue;
		end;
		local distance: number = math.huge;
		for _: any, position: Vector3 in positions do
			distance = math.min(distance, (position - v.value.position).Magnitude);
		end;
		nearest = math.min(nearest, distance);
		if distance < self.Config.RouteEnemyRadius then
			risk += (1 - distance / self.Config.RouteEnemyRadius) * self.Config.Weights.Enemy * math.max(v.confidence, 0.25);
		end;
	end;

	for _: any, v: any in self.Memory.failures do
		if v.position and now - v.timestamp < self.Config.FailureLifetime then
			for _: any, position: Vector3 in positions do
				if (position - v.position).Magnitude < self.Config.ArrivalRadius then
					risk += self.Config.Weights.Failure * v.count;
					break;
				end;
			end;
		end;
	end;

	return risk + (unknown and self.Config.Weights.Uncertainty or 0), nearest;
end;

mindClass.Clear = function(self: table, now: number?): ()
	if self.Goal then
		self.Previous = {["id"] = self.Goal.id, ["ended"] = now or self.ObservedAt or 0};
	end;
	self.Goal, self.Decision = nil, nil;
	self.Revision += 1;
end;

mindClass.Record = function(self: table, kind: string, key: string, reason: string, now: number, position: Vector3?): ()
	if kind == "failure" then
		self.Memory:Failure(key, reason, now, position);
		self.Recovery = math.min(self.Recovery + 1, self.Config.RecoveryLimit);
		self.NextAction = now + (self.Recovery >= self.Config.RecoveryLimit and self.Config.RecoveryWait or self.Config.ReactionTime);
		self:Clear(now);
		return;
	end;

	self.Memory:Event({["kind"] = kind, ["key"] = key, ["reason"] = reason, ["timestamp"] = now, ["position"] = position});
	if kind == "kill" then
		self.NextAction = now + self.Config.PostKillWait;
		self:Clear(now);
	elseif kind == "bedlost" then
		self.Retreating = true;
		self:Clear(now);
	elseif kind == "success" then
		self.Memory:Success(key, now);
		self.Recovery = 0;
	end;
end;

mindClass.Complete = function(self: table, goal: any, now: number): ()
	self.Memory:Success(goal.id, now);
	if self.Goal == goal then
		self.Previous = {["id"] = goal.id, ["ended"] = now};
		self.Goal, self.Decision = nil, nil;
	end;
end;

mindClass.Decide = function(self: table, now: number): ...any
	local state: any, environment: any, config: any = self.Snapshot.self, self.Snapshot.environment, self.Config;
	local assessment: any = self:Assess(now);
	local candidates: table = {};
	local danger: any = self.Retreating or assessment.score >= config.MaxThreat or state.narrowBridge and assessment.target ~= nil;

	local add: (name: string, priority: number, reason: string, destination: any, action: string, emergency: boolean?, category: string?) -> () = function(name: string, priority: number, reason: string, destination: any, action: string, emergency: boolean?, category: string?): ()
		local id: string = `{name}:{destination and destination.id or ""}`;
		local failed: any = self.Memory.failures[id];
		if failed and name ~= "Recover" and (action ~= "Wait" or destination) and now - failed.timestamp < (failed.count >= config.RecoveryLimit and config.FailureLifetime or config.FailureCooldown * failed.count) then
			return;
		end;

		priority = (config.Priorities[name] or priority) + (name == "ReturnToBase" and config.BasePreference or 0);
		local risk: number = destination and self:RouteRisk({destination.position}, now) or 0;
		local distance: number = destination and (destination.position - state.position).Magnitude or 0;
		category = category or "Valuable";
		table.insert(candidates, {
			["id"] = id, ["name"] = name, ["goal"] = name, ["priority"] = priority, ["reason"] = reason,
			["destination"] = destination, ["target"] = destination, ["action"] = action, ["subgoal"] = action,
			["emergency"] = emergency == true, ["interruptible"] = not emergency, ["category"] = category, ["risk"] = risk,
			["urgency"] = emergency and "Emergency" or category == "Essential" and "High" or category == "Optional" and "Low" or "Normal",
			["score"] = priority - risk - distance * config.Weights.Travel - (failed and failed.count * config.Weights.Failure or 0),
			["timeout"] = action == "Collect" and config.CollectTimeout or action == "Fight" and config.FightTimeout or config.GoalTimeout
		});
	end;

	if not state.alive or environment.matchEnded then
		add("WaitForSpawn", 1000, "Character unavailable or match finished", nil, "Wait", true, "Essential");
	elseif state.falling then
		add("Recover", 1000, "Falling without a verified landing", nil, "Recover", true, "Essential");
	elseif now - self.ObservedAt > config.ObservationLifetime or not state.health or not state.maxHealth then
		add("WaitForInformation", 950, "Health or perception is uncertain", nil, "Wait", true, "Essential");
	else
		local threatened: boolean = environment.bedThreat == true;
		local purchase: any = self.Snapshot.purchase;
		local saving: any = purchase and purchase.currency ~= "iron" and (state.resources[purchase.currency] or 0) < purchase.cost and assessment.ratio >= config.HighHealth and assessment.count == 0 and not assessment.chased and assessment.score < config.SafeRouteRisk;
		local returning: any = assessment.carrying and not state.insideBase and not saving;
		local escape: table = {};

		for _: any, v: any in self.Snapshot.destinations or {} do
			if v.kind == "base" or v.kind == "teammate" or v.kind == "surface" or v.kind == "cover" or v.kind == "shop" then
				table.insert(escape, v);
			end;
		end;
		for _: any, v: {id: string, kind: string, position: Vector3, timestamp: number, confidence: number} in self.Memory.surfaces do
			if now - v.timestamp < config.ObservationLifetime then
				table.insert(escape, v);
			end;
		end;

		if danger or returning or threatened then
			for _: any, v: any in escape do
				local risk: number = self:RouteRisk({v.position}, now);
				if risk <= (threatened and not danger and config.RouteRiskLimit or config.SafeRouteRisk) and (not danger or not assessment.target or (v.position - assessment.target.position).Magnitude > assessment.nearest + config.ArrivalRadius) then
					local home: boolean = v.kind == "base";
					local defend: boolean = threatened and home and not self.Retreating;
					add(defend and "DefendBed" or home and "ReturnToBase" or "Escape", (defend and 220 or danger and 230 or 160) + (home and config.BasePreference or 0),
						defend and "Enemy entered the base" or returning and "Secure valuable resources" or "Reach verified safety before continuing", v,
						"Wait", danger or threatened, "Essential");
				end;
			end;
			if #candidates == 0 and danger then
				if state.canBuildCover and state.blocks > config.BlockReserve then
					add("BuildCover", 230, "No safe horizontal route; block pursuit or line of sight", nil, "BuildCover", true, "Essential");
				end;
				if state.canBuildUp and self.Snapshot.upperExit and not assessment.ranged and not state.nearVoid and not state.falling then
					add("BuildUp", 229, "Verified upper exit and descent are safer than remaining here", self.Snapshot.upperExit, "Wait", true, "Essential");
				end;
				if assessment.target and assessment.nearest <= config.LethalRange and state.swordDamage > 0 then
					add("SurvivalCombat", 225, "No safe escape; resist immediate lethal pressure", assessment.target, "Fight", true, "Essential");
				end;
				add("Hide", 220, "Wait for a verified escape without stepping into danger", nil, "Wait", true, "Essential");
			end;
		end;

		if threatened and not self.Retreating and not assessment.carrying and assessment.target and not state.nearVoid and not state.narrowBridge and assessment.count <= 1 then
			add("DefendBed", 245, "Remove an isolated intruder before resuming collection", assessment.target, "Fight", true, "Essential");
		end;

		if assessment.finish then
			add("Finish", 260, "Isolated one-hit enemy on safe ground with a supported escape", assessment.target, "Fight", true);
		elseif not danger and not returning and not threatened and now >= self.NextAction and assessment.target then
			if assessment.highGround then
				if (state.projectiles or 0) > 0 and state.safeSurface and state.cover and assessment.nearest > config.LethalRange and state.escapeAvailable then
					add("Harass", 150, "Use cover and a ranged weapon against high ground", assessment.target, "Harass");
				end;
				if state.canBuildCover then
					add("BuildCover", 145, "Enemy controls high ground", nil, "BuildCover", true);
				end;
				for _: any, v: any in escape do
					if (v.position - assessment.target.position).Magnitude > assessment.nearest then
						add("Reposition", 140, "Change approach instead of charging high ground", v, "Wait", true);
					end;
				end;
				add("WaitForInformation", 120, "High ground cannot be challenged safely", nil, "Wait", true);
			elseif assessment.fightScore >= config.FightThreshold and state.escapeAvailable and not state.nearVoid and not state.narrowBridge and state.swordDamage > 0 then
				add("Fight", 120, "Isolated opponent; health, equipment and escape justify engagement", assessment.target, "Fight");
			end;
		end;

		if not danger and not returning and not threatened and now >= self.NextAction then
			if purchase and state.inventorySpace ~= false then
				local missing: number = math.max(purchase.cost - ((state.resources or {})[purchase.currency] or 0), 0);
				for _: any, v: any in self.Snapshot.destinations or {} do
					if missing > 0 and v.kind == "generator" and v.resource == purchase.currency then
						add("CollectForPurchase", state.blocks <= config.BlockReserve and 115 or 90, `Need {missing} {purchase.currency} for {purchase.item}`, v, "Collect");
					elseif missing == 0 and v.kind == (purchase.upgrade and "upgrade" or "shop") then
						add("BuyEquipment", state.blocks <= config.BlockReserve and 116 or 95, `Purchase {purchase.item}; preserve survival reserves`, v, "Buy");
					end;
				end;
			end;
			if state.blocks >= config.TravelBlocks and assessment.ratio > config.LowHealth then
				for _: any, v: any in self.Snapshot.destinations or {} do
					if v.kind == "generator" and v.resource ~= "iron" and not assessment.carrying and state.inventorySpace ~= false and assessment.phase ~= "Early" then
						if v.resource == "diamond" and (state.resources.diamond or 0) < config.DiamondTarget or v.resource == "emerald" and (state.resources.emerald or 0) < config.EmeraldTarget and assessment.ratio >= config.HighHealth and (assessment.support > 0 or assessment.score < config.SafeRouteRisk / 2) then
							add("CollectResources", v.resource == "emerald" and 55 or 65, `Collect a useful amount of {v.resource} with an escape`, v, "Collect", false, "Optional");
						end;
					elseif v.kind == "enemybed" and self.Snapshot.canBreakBed and not assessment.carrying and assessment.ratio >= config.HighHealth and environment.ownBed == true and state.escapeAvailable then
						add("AttackBed", 70, "Healthy, equipped and able to withdraw", v, "BreakBed", false, "Optional");
					elseif v.kind == "teammate" and v.underPressure and assessment.fightScore >= config.FightThreshold then
						add("SupportTeam", 110, "Nearby teammate can be supported without a second death", v, "Wait");
					elseif v.kind == "drop" and not assessment.carrying and assessment.count == 0 and state.inventorySpace ~= false then
						add("CollectDrops", 85, "Collect visible useful resources after checking reinforcements", v, "Collect", false, "Optional");
					end;
				end;
			end;
		end;

		add("Reassess", 1, now < self.NextAction and "Recovering or checking for reinforcements" or "No useful action has a verified safety advantage", nil, "Wait");
	end;

	table.sort(candidates, function(a: any, b: any): any
		if a.emergency ~= b.emergency then
			return a.emergency;
		end;
		if a.score ~= b.score then
			return a.score > b.score;
		end;
		return a.id < b.id;
	end);

	local selected: any = candidates[1];
	if self.Goal and now - self.Goal.started > self.Goal.timeout and self.Goal.action ~= "Wait" then
		self:Record("failure", self.Goal.id, "Objective timed out without useful progress", now, state.position);
		return self:Decide(now);
	end;

	local flipping: any = self.Previous and selected.id == self.Previous.id and now - self.Previous.ended < config.FlipWindow;
	local margin: number = config.SwitchMargin * (flipping and 2 or 1);
	for _: any, v: any in candidates do
		if self.Goal and v.id == self.Goal.id and (not selected.emergency or v.emergency and selected.priority <= v.priority) and (now - self.Goal.started < config.CommitTime or selected.score < v.score + margin) then
			selected = v;
			break;
		end;
	end;

	selected.started = self.Goal and selected.id == self.Goal.id and self.Goal.started or now;
	if not self.Goal or selected.id ~= self.Goal.id then
		if self.Goal then
			self.Previous = {["id"] = self.Goal.id, ["ended"] = now};
		end;
		self.Revision += 1;
		table.insert(self.Debug, {["timestamp"] = now, ["goal"] = selected.name, ["reason"] = selected.reason, ["threat"] = assessment.score, ["health"] = assessment.healthState, ["resources"] = assessment.valuable, ["combat"] = selected.action == "Fight" and (selected.name == "Finish" and "FINISH" or "FIGHT") or danger and "RETREAT" or "ABORT"});
		if #self.Debug > config.DebugLimit then
			table.remove(self.Debug, 1);
		end;
	end;

	selected.revision, selected.expiresAt = self.Revision, selected.started + selected.timeout;
	self.Goal, self.Decision, self.GoalStack = selected, selected, candidates;
	self.WorldState.self.currentGoal = {["value"] = selected.name, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "cache"};
	self.WorldState.self.currentTarget = {["value"] = selected.destination or false, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "cache"};
	self.WorldState.self.currentSubgoal = {["value"] = selected.action, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "cache"};
	self.WorldState.self.currentThreat = {["value"] = assessment, ["timestamp"] = now, ["confidence"] = math.max(0, 1 - assessment.uncertainty / 4), ["source"] = "cache"};
	return selected;
end;

navigation.Pattern = function(name: string, grid: Vector3, direction: Vector3): {Vector3}?
	local forward: Vector3 = math.abs(direction.X) > math.abs(direction.Z) and Vector3.new(math.sign(direction.X), 0, 0) or Vector3.new(0, 0, math.sign(direction.Z));
	if forward.Magnitude == 0 then
		forward = Vector3.new(1, 0, 0);
	end;

	local side: Vector3 = Vector3.new(-forward.Z, 0, forward.X);
	local up: Vector3 = Vector3.new(0, 1, 0);
	local patterns: {[string]: {Vector3}} = {
		["Tower"] = {grid + up, grid + up * 2},
		["Staircase"] = {grid + forward, grid + forward * 2 + up, grid + forward * 3 + up * 2},
		["SideWall"] = {grid + side + up, grid + side + up * 2},
		["Roof"] = {grid + forward + up, grid + forward + up * 2, grid + forward + up * 3, grid + up * 3},
		["Cover"] = {grid + forward + up, grid + forward + up * 2},
		["EmergencyPlatform"] = {grid + forward, grid + forward + side, grid + forward - side},
		["Bridge"] = {grid + forward, grid + forward * 2, grid + forward * 3},
		["Barrier"] = {grid + forward + up, grid + forward + side + up, grid + forward - side + up},
		["RetreatBlocker"] = {grid - forward + up, grid - forward + up * 2},
		["Landing"] = {grid + forward, grid + forward + side, grid + forward - side}
	};
	return patterns[name];
end;

local agentClass: table = {};
agentClass.__index = agentClass;

local planar: Vector3 = Vector3.new(1, 0, 1);

navigation.newAgent = function(options: any): ...any
	options = options or {};

	local mind: any = options.Mind or navigation.newMind(options.Config);
	local planner: any = options.Planner or navigation;
	local interface: any = options.Interface or options.Context and navigation.newInterface(options.Context, mind.Config);
	return setmetatable({
		["Mind"] = mind,
		["Brain"] = mind,
		["Memory"] = mind.Memory,
		["Planner"] = planner,
		["Navigation"] = planner,
		["Interface"] = interface,
		["Adapter"] = interface,
		["Fallback"] = options.Fallback,
		["Running"] = true,
		["Generation"] = 0,
		["PlanRevision"] = 0,
		["TargetRevision"] = 0,
		["NextThink"] = 0,
		["NextPlace"] = 0,
		["NextAttack"] = 0,
		["NextVerify"] = 0,
		["Index"] = 1,
		["Stage"] = 0,
		["Stalls"] = 0,
		["Breakouts"] = 0,
		["Repaths"] = {},
		["RecoveryState"] = "REASSESS",
		["DebugState"] = {},
		["Throttled"] = {}
	}, agentClass);
end;

agentClass.Log = function(self: table, key: string, text: string): ()
	if self.Interface and self.Interface.Log then
		self.Interface.Log(key, text);
	end;
end;

agentClass.Throttle = function(self: table, key: string, interval: number?): boolean
	local now: number = os.clock();
	if (self.Throttled[key] or 0) > now then
		return false;
	end;
	self.Throttled[key] = now + (interval or self.Mind.Config.DebugInterval);
	return true;
end;

agentClass.Note = function(self: table, goal: any, subgoal: any, reason: any): ()
	self.Objective, self.Subgoal, self.Reason = goal, subgoal, reason;
end;

agentClass.Drop = function(self: table): ()
	if self.Request then
		self.Request:Cancel();
	end;
	self.Request, self.Route, self.Index = nil, nil, 1;
	self.PlanRevision += 1;
end;

agentClass.Cancel = function(self: table): ()
	self.Generation += 1;
	self:Drop();
	self.Pending, self.Build, self.TowerJump, self.Breaking = nil, nil, nil, nil;
	self.Jumping, self.RouteGoal, self.ActiveGoal = nil, nil, nil;
	if self.Interface then
		self.Interface.Stop();
	end;
end;

agentClass.Destroy = function(self: table): ()
	self.Running = false;
	self:Cancel();
	self.Purchase = nil;
	self.RecoveryState = "RESET_GOAL";
end;

agentClass.Fail = function(self: table, reason: string, now: number): ()
	local mind: any = self.Mind;
	local goal: any = mind.Goal;
	mind:Record("failure", goal and goal.id or "action", reason, now, mind.Snapshot and mind.Snapshot.self.position);
	self.LastFailure = reason;
	self:Cancel();
	if self.Purchase and self.Purchase.done then
		self.Purchase = nil;
	end;
	self.NextThink = 0;
	self.Stalls, self.Stage, self.Approach = 0, 0, nil;
	self.RecoveryState = mind.Recovery >= mind.Config.RecoveryLimit and "WAIT_FOR_INFORMATION" or "REPATH";
	self:Log("failure", reason);
end;

agentClass.Options = function(self: table, state: any, emergency: boolean?): any
	local mind: any = self.Mind;
	local config: any = mind.Config;
	local assessment: any = mind.Assessment or {};
	local cautious: any = mind.Retreating or assessment.carrying or assessment.ranged;
	local approach: any = self.Approach;
	return {
		["Channel"] = "bedwarsai",
		["Mode"] = "Legit",
		["BlocksAvailable"] = math.max(0, state.blocks - (emergency and 0 or config.BlockReserve)),
		["Avoid"] = self.Memory:Avoid(self.Now or 0),
		["Agent"] = {
			["WalkSpeed"] = state.speed,
			["HipHeight"] = state.hipHeight,
			["JumpVelocity"] = state.jumpVelocity,
			["Gravity"] = state.gravity,
			["MaxDrop"] = cautious and 6 or 12,
			["DamageAllowance"] = 0
		},
		["Search"] = {
			["MaxSteps"] = config.PlanSteps,
			["WalkSteps"] = config.PlanSteps,
			["Fallback"] = false,
			["Smooth"] = false,
			["Segment"] = config.Segment,
			["Bridge"] = (approach == "Build" or not cautious) and state.blocks > config.BlockReserve,
			["Tower"] = approach == "Build" or mind.Goal and mind.Goal.name == "BuildUp",
			["JumpGap"] = approach ~= "Careful" and not cautious,
			["GoalDrop"] = 4
		}
	};
end;

agentClass.Place = function(self: table, grid: Vector3, now: number, emergency: boolean?): string
	if not self.Running then
		return "failed";
	end;

	local mind: any = self.Mind;
	local state: any, config: any = mind.Snapshot.self, mind.Config;
	if self.Interface.Block(grid) then
		self.Pending = nil;
		return "complete";
	end;
	if self.Pending then
		if now - self.Pending.started > config.PlacementTimeout then
			self.Memory:Route(grid, "placement", now);
			self:Fail("Placement was not confirmed by collision geometry", now);
			return "failed";
		end;
		return "pending";
	end;
	if now < self.NextPlace then
		return "pending";
	end;
	if state.blocks <= (emergency and 0 or config.BlockReserve) then
		self:Fail("Emergency block reserve would be spent", now);
		return "failed";
	end;

	local placement: any = self.Planner:SolvePlacement({["Position"] = state.position, ["Velocity"] = state.velocity, ["Grounded"] = state.grounded}, grid, {["Mode"] = "Legit"});
	local goal: any, route: any = mind.Goal, self.Route;
	mind.WorldState.environment.lastPlacement = {["value"] = placement, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "cache"};
	if not placement.Valid and placement.Reason == "Body" and (goal and goal.name == "BuildUp" or self.Approach == "Build") and state.grounded and not self.TowerJump then
		self.TowerJump = now;
		self.Interface.Move(state.position, true);
		return "pending";
	end;
	if not placement.Valid and self.TowerJump and now - self.TowerJump < config.JumpCommitTime then
		return "pending";
	end;
	if not placement.Valid or not self.Interface.ValidatePlacement(placement, route and route.Waypoints[route.Cursor]) then
		self.Memory:Route(grid, "placement", now);
		self:Fail(`Invalid placement: {placement.Reason or "collision, movement or escape corridor"}`, now);
		return "failed";
	end;

	self.NextPlace = now + math.max(config.PlacementCooldown, state.placeInterval or 0);
	self.Pending = {["grid"] = grid, ["started"] = now};
	self.TowerJump = nil;
	self.Interface.Place(placement.Position);
	return "pending";
end;

agentClass.Stale = function(self: table, route: any): ...any
	if self.Planner ~= navigation then
		return self.Planner:IsStale(route.Result);
	end;
	return route:Stale();
end;

agentClass.Drifted = function(self: table, route: any, target: Vector3?, position: Vector3): boolean
	if not route.Target or not target then
		return false;
	end;
	local config: any = self.Mind.Config;
	return (target - route.Target).Magnitude > math.clamp((target - position).Magnitude * config.TargetDrift, config.ArrivalRadius, 30);
end;

agentClass.Adopt = function(self: table, plan: any, state: any, now: number): (any, any)
	local current: any, config: any = self.Route, self.Mind.Config;
	plan:Resume(state.position, state.velocity, state.airborne);

	if current and not current.Expired and current.Kind == plan.Kind and current.TargetId == plan.TargetId and current.Cursor <= #current.Waypoints and #plan.Waypoints > 0 and not self:Stale(current) then
		if current:Deviation(plan) <= cellSize * 1.1 then
			current.Target = plan.Target or current.Target;
			return current, false;
		end;
		local mine: any, theirs: any = current.Waypoints[#current.Waypoints], plan.Waypoints[#plan.Waypoints];
		if (mine.Position - theirs.Position).Magnitude <= cellSize and plan:Remaining() >= current:Remaining() * (1 - config.ReplanMargin) then
			return current, false;
		end;
	end;

	self.PlanRevision += 1;
	plan.Revision = self.PlanRevision;
	self.Route, self.Index, self.Breakouts = plan, plan.Cursor, 0;
	self.ProgressAt, self.ProgressPosition, self.ProgressDistance, self.Nudged = now, state.position, math.huge, nil;
	return plan, true;
end;

agentClass.Hold = function(self: table, state: any): ()
	if self.Jumping and state.airborne then
		return;
	end;
	self.Interface.Stop();
end;

agentClass.Dispatch = function(self: table, destination: any, state: any, now: number): any
	if self.Planner == navigation and not navigation.World then
		return false;
	end;
	if self.Request then
		self.Request:Cancel();
	end;

	local request: any = self.Planner:FindPathAsync({["Position"] = state.position, ["Velocity"] = state.velocity, ["Grounded"] = state.grounded}, destination.position, self:Options(state));
	request.Generation, request.TargetId, request.Target, request.Origin = self.Generation, destination.id, destination.position, state.position;
	self.Request, self.RequestedAt, self.RouteGoal = request, now, destination.position;
	return true;
end;

agentClass.Receive = function(self: table, goal: any, destination: any, state: any, now: number): ()
	local mind: any, request: any = self.Mind, self.Request;
	local config: any = mind.Config;
	if not request.Done then
		if now - self.RequestedAt > config.PlanTimeout then
			if self.Route then
				request:Cancel();
				self.Request = nil;
			else
				self:Fail("Navigation exceeded its planning deadline", now);
			end;
		end;
		return;
	end;

	self.Request = nil;
	local result: any = request.Result;
	if request.Generation ~= self.Generation or request.TargetId ~= destination.id then
		return;
	end;
	if not result or not result.Success or result.Partial then
		if self.Route and not self:Stale(self.Route) then
			return;
		end;
		if result and result.Reason == "NoPath" and self:Breakout(state, destination.position, now) then
			return;
		end;
		self:Fail(result and result.Reason or "Path computation failed", now);
		return;
	end;

	local actions: any = result.Actions or {};
	local samples: table, jumps: number, turns: number, narrow: boolean, previous: any, lastDirection: any = {}, 0, 0, false, state.position, nil;
	local stride: number = math.max(1, math.ceil(#actions / config.RouteSampleLimit));
	for i: number, v: any in actions do
		if v.Type ~= "PlaceBlock" then
			if i % stride == 0 or i == #actions then
				table.insert(samples, v.Position);
				narrow = narrow or self.Interface.Surface(v.Position).narrow;
			end;
			jumps += v.Type == "Jump" and 1 or 0;
			local direction: Vector3 = (v.Position - previous) * planar;
			if direction.Magnitude > 0.1 then
				turns += lastDirection and lastDirection:Dot(direction.Unit) < 0.5 and 1 or 0;
				lastDirection = direction.Unit;
			end;
			previous = v.Position;
		end;
	end;

	local assessment: any = mind.Assessment;
	local blocks: number = result.BlocksUsed or 0;
	local risk: any, nearest: any = mind:RouteRisk(samples, now);
	local danger: number = risk + jumps * config.Weights.Jump + turns * config.Weights.Turns + blocks * config.Weights.Block + (narrow and config.Weights.Narrow or 0);
	local limit: number = (mind.Retreating or assessment.carrying) and config.SafeRouteRisk or config.RouteRiskLimit;
	local destinationRisk: number = mind:RouteRisk({destination.position}, now);
	if danger > limit or goal.emergency and assessment.target and nearest + config.ArrivalRadius < assessment.nearest
		or goal.name ~= "BuildUp" and (mind.Retreating or assessment.carrying) and (blocks > 0 or jumps > 0 or destinationRisk > config.SafeRouteRisk) then
		self:Fail("Route exposes health or cargo to unacceptable risk", now);
		return;
	end;

	local plan: any = self:Adopt(navigation.newPlan(result, {["Kind"] = "Path", ["TargetId"] = destination.id, ["Target"] = request.Target, ["Origin"] = request.Origin, ["Now"] = now}), state, now);
	mind.WorldState.self.currentRoute = {["value"] = plan.Result, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "cache"};
	mind.WorldState.self.currentEscapeRoute = {["value"] = goal.emergency and plan.Result or false, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "cache"};
	mind.WorldState.environment.bridgeQuality = {["value"] = {["narrow"] = narrow, ["jumps"] = jumps, ["turns"] = turns, ["blocks"] = blocks, ["risk"] = danger}, ["timestamp"] = now, ["confidence"] = 1, ["source"] = "raycast"};
end;

agentClass.Follow = function(self: table, route: any, state: any, now: number): ()
	local config: any = self.Mind.Config;
	local points: any, position: any = route.Waypoints, state.position;
	local point: any, distance: any;

	for _: number = 1, 4 do
		point = points[route.Cursor];
		if not point then
			self:Fail("Route ended outside interaction range", now);
			return;
		end;

		if point.Blocks and not point.Built then
			for _: any, v: any in point.Blocks do
				local status: string = self:Place(v.Grid, now);
				if status ~= "complete" then
					if status == "pending" then
						self.Interface.Stop();
					end;
					return;
				end;
			end;
			point.Built, self.ProgressAt = true, now;
		end;

		local previous: any = points[route.Cursor - 1];
		local lateral: any, _: any, raw: any = segmentDistance(previous and previous.Position or route.Origin or position, point.Position, position);
		distance = (point.Position - position).Magnitude;
		if distance > config.ArrivalRadius * 0.35 and not (raw >= 1 and lateral <= 1.5 and math.abs(point.Position.Y - position.Y) <= 2.5) then
			break;
		end;

		route.Cursor += 1;
		self.Index = route.Cursor;
		self.ProgressAt, self.ProgressDistance, self.Jumping, self.Nudged = now, math.huge, nil, nil;
		self:Settled(now);
		point = nil;
	end;

	if not point then
		return;
	end;

	if distance < self.ProgressDistance - config.ProgressDistance then
		self.ProgressAt, self.ProgressDistance = now, distance;
	elseif self.ProgressDistance < math.huge and distance > self.ProgressDistance + cellSize * 2 and now >= self.NextVerify then
		self.NextVerify = now + config.VerifyInterval;
		local _: any, gap: any = route:Resume(position, state.velocity, state.airborne);
		self.Index, self.ProgressDistance = route.Cursor, math.huge;
		if gap > config.OffRoute then
			self:Repath("Displaced from the route", now);
			self:Hold(state);
		end;
		return;
	end;

	local stalled: number = now - (self.ProgressAt or now);
	if stalled > config.StuckTime then
		self:Recover(point, state, now);
		return;
	end;

	if stalled > config.StuckTime * 0.5 and not self.Nudged and state.grounded and self.Interface.ValidateMove(point, false) then
		self.Nudged = now;
		self.RecoveryState = "NUDGE";
		self.Interface.Move(point.Position, true, "Nudge");
		return;
	end;

	local jump: any = point.Type == "Jump" and not self.Jumping and state.grounded;
	if not self.Interface.ValidateMove(point, self.Jumping ~= nil) then
		self:Repath("Next movement lacks collision support or clearance", now, self:Ahead(state, point));
		self:Hold(state);
		return;
	end;
	if jump then
		self.Jumping = now;
	end;
	self.Interface.Move(point.Position, jump, point.Type);
	if self.Stage == 0 then
		self.RecoveryState = "REASSESS";
	end;
end;

agentClass.Navigate = function(self: table, goal: any, now: number): boolean
	local mind: any = self.Mind;
	local state: any, config: any = mind.Snapshot.self, mind.Config;
	local destination: any = goal.destination;
	if not destination or not self.Interface.Valid(destination) then
		self:Fail("Destination disappeared or changed team", now);
		return false;
	end;

	if (destination.position - state.position).Magnitude <= (goal.action == "Fight" and (state.attackRange or config.LethalRange * 0.65) or config.ArrivalRadius) then
		self.Interface.Stop();
		if self.Route or self.Request then
			self:Drop();
		end;
		return true;
	end;

	if self.Request then
		self:Receive(goal, destination, state, now);
		if self.ActiveGoal ~= goal.id then
			return false;
		end;
	end;

	if self.Breaking then
		self:Unblock(now);
		return false;
	end;

	local route: any = self.Route;
	if route and self:Stale(route) then
		self:Repath("Route support changed", now);
		route = nil;
	end;

	if not route then
		if not self.Request and not self:Dispatch(destination, state, now) then
			self:Fail("Navigation world is unavailable", now);
			return false;
		end;
		self:Hold(state);
		return false;
	end;

	if not self.Request and now - (self.RequestedAt or -math.huge) >= config.ReplanInterval and self:Drifted(route, destination.position, state.position) then
		self:Dispatch(destination, state, now);
	end;

	self:Follow(route, state, now);
	return false;
end;

agentClass.Step = function(self: table, snapshot: any, now: number): ()
	if not self.Running then
		return;
	end;

	now = now or os.clock();
	self.Now = now;
	snapshot = snapshot or self.Interface.Observe(now);

	local mind: any = self.Mind;
	local route: any = self.Route;
	local landing: any = route and route.Waypoints[route.Cursor];
	if self.Jumping and landing and now - self.Jumping < mind.Config.JumpCommitTime then
		if self.Interface.ValidateMove(landing, true) and (landing.Position - snapshot.self.position):Dot(snapshot.self.velocity) > 0 then
			snapshot.self.falling = false;
		end;
	end;

	snapshot.self.currentlyBuilding = self.Pending ~= nil;
	snapshot.self.currentlyAttacking = mind.Goal and mind.Goal.action == "Fight" or false;
	snapshot.self.currentlyRetreating = mind.Retreating;
	mind:Observe(snapshot, now);

	local previous: any = mind.Goal;
	if now >= self.NextThink or snapshot.self.falling or snapshot.self.underPressure or not snapshot.self.alive or snapshot.environment.bedThreat or previous and previous.destination and not self.Interface.Valid(previous.destination) then
		mind:Decide(now);
		self.NextThink = now + mind.Config.ThinkInterval;
	end;

	local goal: any, config: any = mind.Goal, mind.Config;
	if not goal then
		self:Describe();
		return;
	end;

	if self.ActiveGoal ~= goal.id then
		if self.Jumping and landing and not snapshot.self.grounded and not snapshot.self.falling and now - self.Jumping < config.JumpCommitTime then
			if self.Interface.ValidateMove(landing, true) then
				self.Interface.Move(landing.Position, false);
				return;
			end;
		end;
		self:Cancel();
		self.ActiveGoal = goal.id;
		self.Stalls, self.Stage, self.Approach = 0, 0, nil;
		self.ReadyAt = now + (goal.emergency and 0 or config.ReactionTime);
		self:Log(goal.name, goal.reason);
	end;

	if now < (self.ReadyAt or 0) then
		return;
	end;
	if not snapshot.self.alive or snapshot.environment.matchEnded then
		self.Interface.Stop();
		return;
	end;

	local state: any, assessment: any = snapshot.self, mind.Assessment;
	if self.Purchase and now - self.Purchase.started > config.PlanTimeout then
		self.Purchase = nil;
		self.BuyUntil = now + config.FailureCooldown;
	end;

	if goal.action == "Recover" then
		self.Interface.Stop();
		if now < mind.NextAction then
			return;
		end;
		self.RecoveryState = "BUILD_RECOVERY_PLATFORM";
		local result: any = self.Planner:FindClutch({["Position"] = state.position, ["Velocity"] = state.velocity, ["Grounded"] = false}, {
			["Mode"] = "Legit", ["BlocksAvailable"] = state.blocks, ["Clutch"] = {["Void"] = true, ["MaxBlocks"] = config.BuildLimit}
		});
		if result.Success and result.BridgePath[1] then
			self:Place(result.BridgePath[1].Grid, now, true);
		elseif not self.RecoveryReported then
			self.RecoveryReported = true;
			self:Log("FIND_SAFE_SURFACE", "No physically valid clutch placement is available");
		end;
		return;
	end;
	self.RecoveryReported = nil;

	if goal.action == "BuildCover" or goal.action == "BuildUp" then
		self.Interface.Stop();
		if not self.Build then
			self.Build = self.Interface.Build(goal.action, assessment, config.BuildLimit);
		end;
		if not self.Build or not self.Build[1] then
			self:Fail("No useful legal building continuation", now);
			return;
		end;
		if self:Place(self.Build[1], now) == "complete" then
			table.remove(self.Build, 1);
			if #self.Build == 0 then
				self.Build = nil;
				mind:Complete(goal, now);
				mind.NextAction = now + config.ReactionTime;
				self.NextThink = 0;
			end;
		end;
		return;
	end;

	if goal.action == "Harass" then
		self.Interface.Stop();
		if now >= self.NextAttack and assessment.count == 0 and state.safeSurface and not state.nearVoid then
			self.NextAttack = now + config.RangedInterval;
			self.Interface.Ranged(goal.destination);
		end;
		return;
	end;

	if goal.destination and not self:Navigate(goal, now) then
		if assessment.chased and state.safeSurface and state.cover and assessment.nearest > config.LethalRange and state.projectiles > 0 and now >= self.NextAttack then
			self.NextAttack = now + config.RangedInterval;
			self.Interface.Ranged(assessment.target);
		end;
		self:Describe();
		return;
	end;

	self.Interface.Stop();
	if goal.action == "Fight" then
		local current: any = mind:Assess(now);
		if not goal.destination or not self.Interface.Valid(goal.destination) or current.target and current.target.id ~= goal.destination.id
			or goal.name ~= "SurvivalCombat" and goal.name ~= "Finish" and goal.name ~= "DefendBed" and (current.fightScore < config.FightThreshold or current.highGround or state.nearVoid or state.narrowBridge or mind.Retreating) then
			self:Fail("Fight conditions changed; disengaging", now);
			return;
		end;
		if now >= self.NextAttack then
			self.NextAttack = now + config.AttackInterval;
			self.Interface.Attack(goal.destination);
		end;
	elseif goal.action == "Buy" then
		if self.Purchase then
			if self.Purchase.done then
				if self.Purchase.success then
					mind:Complete(goal, now);
					self.Purchase = nil;
					mind.Recovery, self.NextThink = 0, 0;
					self.BuyUntil = now + config.PlacementTimeout;
				else
					self:Fail("Shop rejected purchase", now);
				end;
			elseif now - self.Purchase.started > config.PlanTimeout then
				self:Fail("Purchase acknowledgement timed out", now);
			end;
		elseif snapshot.purchase and now >= (self.BuyUntil or 0) and assessment.count == 0 and not mind.Retreating and state.inventorySpace ~= false then
			local pending: table = {["started"] = now};
			self.Purchase = pending;
			self.Interface.Buy(goal.destination, snapshot.purchase, function(success: any): ()
				if self.Running and self.Purchase == pending then
					pending.done, pending.success = true, success;
				end;
			end);
		end;
	elseif goal.action == "BreakBed" then
		if now >= self.NextAttack and snapshot.canBreakBed and assessment.count == 0 and not mind.Retreating then
			self.NextAttack = now + config.AttackInterval;
			self.Interface.BreakBed(goal.destination);
		end;
	elseif goal.action == "Collect" then
		self.RecoveryState = "REASSESS";
		local amount: number = (state.resources or {})[goal.destination.resource] or 0;
		if self.Collected ~= amount then
			self.Collected = amount;
			self.NextThink = 0;
			mind.Recovery = 0;
		end;
		if goal.destination.kind == "drop" and now >= self.NextAttack then
			self.NextAttack = now + config.RangedInterval;
			self.Interface.Pickup(goal.destination);
		end;
	elseif assessment.target then
		self.Interface.Look(assessment.target.position);
	end;
	self:Describe();
end;

agentClass.Draft = function(self: table, from: any, target: Vector3?, options: any, threats: any, targetId: any, request: any): (any, any)
	local now: number = os.clock();
	self.Now = now;
	if self.Planner == navigation and not navigation.World then
		return nil, nil;
	end;

	options = options or {};
	options.Avoid = options.Avoid or self.Memory:Avoid(now);
	local state: any = typeof(from) == "Vector3" and {["Position"] = from} or from;
	local result: any = threats and self.Planner:FindRetreat(state, threats, options, request) or self.Planner:FindPath(state, target, options, request);
	if request and request.Cancelled then
		return nil, result;
	end;
	local plan: any = navigation.newPlan(result, {
		["Kind"] = threats and "Retreat" or "Path",
		["TargetId"] = targetId,
		["Target"] = threats and result.Goal and result.Goal * cellSize or target,
		["Origin"] = state.Position,
		["Now"] = now
	});

	if #plan.Waypoints == 0 and result.Success and result.Goal then
		table.insert(plan.Waypoints, {["Type"] = "Walk", ["Grid"] = result.Goal, ["Position"] = result.Goal * cellSize, ["Center"] = result.Goal * cellSize});
	elseif #plan.Waypoints == 0 then
		plan = nil;
		local points: any = target and not threats and self.Fallback and self.Fallback(state.Position, target);
		if points and #points > 0 and (points[#points] - target).Magnitude <= 6 then
			plan = navigation.newPlan({}, {["Kind"] = "Fallback", ["TargetId"] = targetId, ["Target"] = target, ["Origin"] = state.Position, ["Now"] = now, ["World"] = navigation.World});
			for _: any, v: Vector3 in points do
				table.insert(plan.Waypoints, {["Type"] = "Walk", ["Position"] = v, ["Center"] = v});
			end;
		end;
	end;

	if not plan then
		self.LastFailure = result.Reason;
		return nil, result;
	end;
	if options.Label and self.Interface then
		for _: any, v: any in plan.Waypoints do
			v.Ground = self.Interface.Label(v.Center);
		end;
	end;

	return plan, result;
end;

agentClass.Plan = function(self: table, from: any, target: Vector3?, options: any, threats: any, targetId: any): (any, any, any)
	local plan: any, result: any = self:Draft(from, target, options, threats, targetId);
	if not plan then
		return nil, false, result;
	end;

	local state: any = typeof(from) == "Vector3" and {["Position"] = from} or from;
	local current: any, adopted: any = self:Adopt(plan, {["position"] = state.Position, ["velocity"] = state.Velocity, ["airborne"] = state.Airborne}, self.Now);
	return current, adopted, result;
end;

agentClass.Current = function(self: table): any
	return self.Route;
end;

agentClass.IsCurrent = function(self: table, plan: any): boolean
	return plan ~= nil and self.Route == plan;
end;

agentClass.Invalidate = function(self: table, reason: string?): ()
	if self.Route then
		self.Route.Expired = true;
	end;
	if reason then
		self.LastFailure = reason;
	end;
end;

agentClass.Cheapest = function(self: table, targets: any, origin: Vector3, options: any): (any, any)
	if #targets == 0 then
		return nil;
	end;

	local positions: {Vector3} = {};
	for i: number, v: any in targets do
		positions[i] = v.Position;
	end;

	local costs: any = (self.Planner ~= navigation or navigation.World) and self.Planner:GetBlockCosts(origin, positions, options) or {};
	local margin: number = self.Mind.Config.TargetMargin;
	local best: any, cost: number, distance: number = nil, math.huge, math.huge;
	for i: number, v: any in targets do
		local value: number = (costs[i] or 0) - (v.Id == self.Target and margin or 0);
		local magnitude: number = (origin - v.Position).Magnitude;
		if value < cost or value == cost and magnitude < distance then
			best, cost, distance = v, value, magnitude;
		end;
	end;

	if best and best.Id ~= self.Target then
		self.Target = best.Id;
		self.TargetRevision += 1;
	end;
	return best, cost;
end;

agentClass.Event = function(self: table, kind: string, now: number, data: any): ()
	local mind: any = self.Mind;
	if kind == "death" then
		local snapshot: any = mind.Snapshot;
		if snapshot then
			mind:Record("failure", mind.Goal and mind.Goal.id or "death", mind.Assessment and mind.Assessment.carrying and "Died carrying resources" or "Died during objective", now, snapshot.self.position);
			self.Memory:Route(navigation.WorldToGrid(snapshot.self.position - Vector3.new(0, (snapshot.self.hipHeight or 3) - halfCell, 0)), "death", now);
		end;
		self:Cancel();
	elseif kind == "kill" then
		mind:Record("kill", "combat", "Check health, cargo and reinforcements after a kill", now);
		self:Cancel();
	elseif kind == "forget" then
		mind.WorldState.enemies[data] = nil;
	elseif kind == "inventory" then
		self.NextThink = 0;
	elseif kind == "bed" then
		self.NextThink = 0;
		if self.Interface and self.Interface.Mark then
			self.Interface.Mark("beds");
		end;
	end;
end;

agentClass.Describe = function(self: table): any
	local mind: any, route: any, state: any = self.Mind, self.Route, self.DebugState;
	local goal: any, assessment: any = mind.Goal, mind.Assessment;
	state.Goal = goal and goal.name or self.Objective;
	state.Target = goal and goal.destination and goal.destination.id or self.Target;
	state.Subgoal = goal and goal.action or self.Subgoal;
	state.Reason = goal and goal.reason or self.Reason;
	state.Route = route and #route.Waypoints or 0;
	state.Cursor = route and route.Cursor or 0;
	state.RouteCost = route and route.Cost or 0;
	state.Blocks = route and route:Pending() or 0;
	state.Threat = assessment and assessment.score or 0;
	state.Health = assessment and assessment.healthState or nil;
	state.Replanning = self.Request ~= nil;
	state.LastFailure = self.LastFailure;
	state.PlanRevision = self.PlanRevision;
	state.GoalRevision = mind.Revision;
	state.Recovery = self.RecoveryState;
	state.Stage = self.Stage;
	return state;
end;

agentClass.Summary = function(self: table): ...any
	local state: any = self:Describe();
	return string.format("goal=%s target=%s subgoal=%s reason=%s route=%d/%d cost=%.1f blocks=%d threat=%.0f health=%s replanning=%s revision=%d/%d recovery=%s stage=%d failure=%s",
		tostring(state.Goal), tostring(state.Target), tostring(state.Subgoal), tostring(state.Reason), state.Cursor, state.Route, state.RouteCost, state.Blocks,
		state.Threat, tostring(state.Health), tostring(state.Replanning), state.PlanRevision, state.GoalRevision, tostring(state.Recovery), state.Stage, tostring(state.LastFailure));
end;

agentClass.Repath = function(self: table, reason: string, now: number, grid: Vector3?, stage: string?): ()
	local config: any = self.Mind.Config;
	local repaths: {number} = self.Repaths;
	if grid then
		self.Memory:Route(grid, reason, now);
	end;

	table.insert(repaths, now);
	while repaths[1] and now - repaths[1] > config.RepathWindow do
		table.remove(repaths, 1);
	end;

	self.LastFailure = reason;
	if #repaths > config.RecoveryLimit * 2 then
		table.clear(repaths);
		self:Fail(`Repeated route failures: {reason}`, now);
		return;
	end;

	self.RecoveryState = stage or "REPATH";
	self:Log("repath", reason);
	self:Drop();
end;

agentClass.Ahead = function(self: table, state: any, point: any): Vector3
	local flat: Vector3 = (point.Position - state.position) * planar;
	local step: Vector3 = flat.Magnitude > 0.1 and flat.Unit * cellSize or Vector3.zero;
	return navigation.WorldToGrid(state.position + step - Vector3.new(0, (state.hipHeight or navigation.Config.Agent.HipHeight) - halfCell, 0));
end;

agentClass.Obstruction = function(self: table, state: any, point: any, now: number): any
	if not self.Interface.Break then
		return nil;
	end;

	local feet: Vector3 = self:Ahead(state, point);
	for height: number = 0, 1 do
		local grid: Vector3 = feet + Vector3.new(0, height, 0);
		if self.Interface.Block(grid) then
			self.Breaking = {["grid"] = grid, ["started"] = now};
			return grid;
		end;
	end;
	return nil;
end;

agentClass.Breakout = function(self: table, state: any, target: Vector3, now: number): boolean
	if not self.Interface.Break or self.Breakouts >= 4 then
		return false;
	end;

	local world: any = self.Planner.World;
	local flat: Vector3 = (target - state.position) * planar;
	local feet: Vector3 = navigation.WorldToGrid(state.position - Vector3.new(0, (state.hipHeight or navigation.Config.Agent.HipHeight) - halfCell, 0));
	local best: any, score: number = nil, -math.huge;
	for i: number = 1, 4 do
		local direction: {number} = flats[i];
		local open: boolean = true;
		for height: number = 0, 1 do
			local grid: Vector3 = feet + Vector3.new(direction[1], height, direction[3]);
			local placed: any = self.Interface.Block(grid);
			if placed or world and world:Solid(grid.X, grid.Y, grid.Z) then
				open = false;
			end;
			if placed then
				local value: number = flat.Magnitude > 0.1 and flat.Unit:Dot(Vector3.new(direction[1], 0, direction[3])) or 0;
				if value > score then
					best, score = grid, value;
				end;
			end;
		end;
		if open then
			return false;
		end;
	end;

	if not best then
		return false;
	end;
	self.Breakouts += 1;
	self.Breaking = {["grid"] = best, ["started"] = now};
	self.RecoveryState = "BREAK_OBSTRUCTION";
	self:Log("breakout", "Enclosed by placed blocks; breaking toward the destination");
	return true;
end;

agentClass.Recover = function(self: table, point: any, state: any, now: number): ()
	self.Stalls += 1;
	self.StalledAt = now;
	self.Stage = math.min(self.Stalls + 1, 6);
	self.ProgressAt, self.ProgressDistance, self.Nudged = now, math.huge, nil;

	local cell: Vector3 = self:Ahead(state, point);
	if self.Stage == 2 then
		self:Repath("Movement stalled; re-evaluating the local route", now, cell, "REPATH");
	elseif self.Stage == 3 then
		self.Approach = "Careful";
		self:Repath("Stalled again; changing the movement approach", now, cell, "CHANGE_APPROACH");
	elseif self.Stage == 4 then
		self.Approach = "Build";
		self:Repath("Stalled repeatedly; allowing build-up and alternate routes", now, cell, "ALTERNATE_ROUTE");
	elseif self.Stage == 5 and self:Obstruction(state, point, now) then
		self.RecoveryState = "BREAK_OBSTRUCTION";
		self.Interface.Stop();
	else
		self:Fail("Movement stalled or building has no continuation", now);
	end;
end;

agentClass.Unblock = function(self: table, now: number): ()
	local breaking: any, config: any = self.Breaking, self.Mind.Config;
	if not self.Interface.Block(breaking.grid) then
		self.Breaking = nil;
		self:Repath("Obstruction cleared", now, nil, "REPATH");
	elseif now - breaking.started > config.BreakTimeout then
		self.Breaking = nil;
		self:Fail("Obstruction could not be broken", now);
	elseif now >= self.NextAttack then
		self.NextAttack = now + config.AttackInterval;
		self.Interface.Break(breaking.grid);
	end;
end;

agentClass.Settled = function(self: table, now: number): ()
	if self.Stalls > 0 and now - (self.StalledAt or 0) > self.Mind.Config.RecoveryReset then
		self.Stalls, self.Stage, self.Approach = 0, 0, nil;
		self.RecoveryState = "REASSESS";
	end;
end;

navigation.Brain = {
	["Config"] = navigation.Config.Mind,
	["new"] = navigation.newMind
};

navigation.Adapter = {
	["new"] = navigation.newInterface
};

navigation.Controller = {
	["Pattern"] = navigation.Pattern,
	["new"] = function(brain: any, planner: any, adapter: any): ...any
		return navigation.newAgent({["Mind"] = brain, ["Planner"] = planner, ["Interface"] = adapter});
	end
};

navigation.newDebugAdapter = function(parent: Instance?, limit: number?): any
	local pool: {Part} = {};
	local index: number = 0;
	local model: Model = Instance.new("Model");
	model.Name = "navigation";
	model.Parent = parent or workspace.Terrain;

	return {
		["Model"] = model,
		["Point"] = function(position: Vector3, color: Color3, size: number?): ()
			if index >= (limit or 600) then
				return;
			end;

			index += 1;
			local part: Part? = pool[index];
			if not part then
				part = Instance.new("Part");
				part.Anchored = true;
				part.CanCollide = false;
				part.CanQuery = false;
				part.CanTouch = false;
				part.Material = Enum.Material.Neon;
				part.Parent = model;
				pool[index] = part;
			end;

			part.Size = Vector3.new(size or 1, size or 1, size or 1);
			part.Color = color;
			part.Transparency = 0.55;
			part.Position = position;
		end,
		["Clear"] = function(): ()
			for slot: number = 1, index do
				pool[slot].Transparency = 1;
				pool[slot].Position = Vector3.new(9e9, 9e9, 9e9);
			end;
			index = 0;
		end
	};
end;

navigation.Visualize = function(self: table, result: any): any
	if not self.DebugAdapter then
		self.DebugAdapter = self.newDebugAdapter();
	end;

	self.DebugAdapter.Clear();

	for _: any, v: any in result.Actions do
		if v.Type == "PlaceBlock" then
			self.DebugAdapter.Point(v.Position, v.PlacementType == "Diagonal" and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(70, 140, 255), cellSize - 0.4);
			self.DebugAdapter.Point(v.AimPosition, Color3.fromRGB(255, 255, 255), 0.5);
		elseif v.Type == "Land" then
			self.DebugAdapter.Point(v.Position, Color3.fromRGB(255, 60, 60), 1.4);
		else
			self.DebugAdapter.Point(v.Position, v.Type == "Jump" and Color3.fromRGB(255, 230, 90) or Color3.fromRGB(90, 255, 120), 1);
		end;
	end;

	return self.DebugAdapter;
end;

return navigation;