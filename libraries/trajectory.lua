local prediction: table = {};
local epsilon: number = 1e-9;
local cloneref: (reference: Instance) -> Instance = cloneref or function(reference: Instance): Instance
	return reference;
end;
local players: Players = cloneref(game:GetService('Players'));
local tweenService: TweenService = cloneref(game:GetService('TweenService'));
local stats: Stats = cloneref(game:GetService('Stats'));

local responseTime: number?;

local sampleRoundTrip: () -> any = function(): any
	local success: boolean, ping: any = pcall(function(): number
		return stats.Network.ServerStatsItem['Data Ping']:GetValue();
	end);
	if success and type(ping) == 'number' and ping > 0 then
		return ping / 1000;
	end;
	return 0;
end;

prediction.setLatency = function(value: any): ()
	if value == nil then
		responseTime = nil;
	elseif type(value) == 'number' and value == value and value >= 0 and value < math.huge then
		responseTime = value;
	end;
end;

local latencyBias: number = 0;

local getBaseLatency: () -> ...any = function(): ...any
	if responseTime ~= nil then
		return responseTime;
	end;

	local store: any = prediction.Store;
	if store and store.ping and store.ping.total then
		return store.ping.total;
	end;

	local success: boolean, ping: any = pcall(players.LocalPlayer.GetNetworkPing, players.LocalPlayer);
	if success and type(ping) == 'number' and ping >= 0 then
		return ping * 2;
	end;
	return sampleRoundTrip();
end;

prediction.getLatency = function(): number
	return math.max(getBaseLatency() + latencyBias, 0);
end;

prediction.getRawLatency = function(): number
	return getBaseLatency();
end;

prediction.Raycast = function(origin: Vector3, direction: Vector3, params: RaycastParams?): RaycastResult?
	return workspace:Raycast(origin, direction, params);
end;

prediction.IsTrajectoryClear = function(origin: Vector3, velocity: Vector3, gravity: number, travelTime: number, params: RaycastParams, target: Instance?, ignored: ((Instance) -> boolean)?): (boolean, RaycastResult?)
	local rayParams: RaycastParams = RaycastParams.new();
	rayParams.FilterType = params.FilterType;
	rayParams.FilterDescendantsInstances = params.FilterDescendantsInstances;
	rayParams.IgnoreWater = params.IgnoreWater;
	rayParams.CollisionGroup = params.CollisionGroup;
	rayParams.RespectCanCollide = params.RespectCanCollide;
	local lastPosition: Vector3 = origin;
	for step: number = 1, 10 do
		local time: number = travelTime * (step / 10);
		local position: Vector3 = origin + velocity * time + Vector3.new(0, -gravity * 0.5 * time * time, 0);
		local direction: Vector3 = position - lastPosition;
		local hit: RaycastResult? = prediction.Raycast(lastPosition, direction, rayParams);
		local ignoredHits: number = 0;
		while hit do
			ignoredHits += 1;
			if ignoredHits > 64 then
				return false, hit;
			end;
			if target and hit.Instance:IsDescendantOf(target) then
				return true;
			end;
			if not ignored or not ignored(hit.Instance) then
				return false, hit;
			end;
			rayParams:AddToFilter(hit.Instance);
			hit = prediction.Raycast(lastPosition, direction, rayParams);
		end;
		lastPosition = position;
	end;
	return true;
end;

local tracer: Part = Instance.new('Part');
tracer.Anchored = true;
tracer.CanCollide = false;
tracer.CanQuery = false;
tracer.CanTouch = false;
tracer.CastShadow = false;

local isZero: (value: number) -> any = function(value: number): any
	return (value > -epsilon and value < epsilon);
end;
local cubeRoot: (value: number) -> any = function(value: number): any
	return (value > 0) and math.pow(value, (1 / 3)) or -math.pow(math.abs(value), (1 / 3));
end;
local solveQuadric: (c0: number, c1: number, c2: number) -> ...any = function(c0: number, c1: number, c2: number): ...any
	local s0: number, s1: number;
	if isZero(c0) then
		return not isZero(c1) and -c2 / c1 or nil;
	end;

	local p: number, q: number, d: number;

	p = c1 / (2 * c0);
	q = c2 / c0;
	d = p * p - q;

	if isZero(d) then
		s0 = -p;
		return s0;
	elseif (d < 0) then
		return;
	else
		local sqrtD: number = math.sqrt(d);

		s0 = sqrtD - p;
		s1 = -sqrtD - p;
		return s0, s1;
	end;
end;
local solveCubic: (c0: number, c1: number, c2: number, c3: number) -> ...any = function(c0: number, c1: number, c2: number, c3: number): ...any
	local s0: number, s1: number, s2: number;
	if isZero(c0) then
		return solveQuadric(c1, c2, c3);
	end;

	local count: number, offset: number;
	local a: number, b: number, c: number;
	local squareA: number, p: number, q: number;
	local cubeP: number, d: number;

	a = c1 / c0;
	b = c2 / c0;
	c = c3 / c0;

	squareA = a * a;
	p = (1 / 3) * (-(1 / 3) * squareA + b);
	q = 0.5 * ((2 / 27) * a * squareA - (1 / 3) * a * b + c);

	cubeP = p * p * p;
	d = q * q + cubeP;

	if isZero(d) then
		if isZero(q) then
			s0 = 0;
			count = 1;
		else
			local u: number = cubeRoot(-q);
			s0 = 2 * u;
			s1 = -u;
			count = 2;
		end;
	elseif (d < 0) then
		local phi: number = (1 / 3) * math.acos(math.clamp(-q / math.sqrt(-cubeP), -1, 1));
		local t: number = 2 * math.sqrt(-p);

		s0 = t * math.cos(phi);
		s1 = -t * math.cos(phi + math.pi / 3);
		s2 = -t * math.cos(phi - math.pi / 3);
		count = 3;
	else
		local sqrtD: number = math.sqrt(d);
		local u: number = cubeRoot(sqrtD - q);
		local v: number = -cubeRoot(sqrtD + q);

		s0 = u + v;
		count = 1;
	end;

	offset = (1 / 3) * a;

	if (count > 0) then
		s0 = s0 - offset;
	end;
	if (count > 1) then
		s1 = s1 - offset;
	end;
	if (count > 2) then
		s2 = s2 - offset;
	end;

	return s0, s1, s2;
end;
prediction.solveQuartic = function(c0: number, c1: number, c2: number, c3: number, c4: number): {number}
	local s0: any, s1: any, s2: any, s3: any;
	if isZero(c0) then
		local root0: any, root1: any, root2: any = solveCubic(c1, c2, c3, c4);
		local cubic: {number} = {};
		if root0 then
			table.insert(cubic, root0);
		end;
		if root1 then
			table.insert(cubic, root1);
		end;
		if root2 then
			table.insert(cubic, root2);
		end;
		return cubic;
	end;

	local coefficients: {[number]: number} = {};
	local z: any, u: any, v: any, offset: number;
	local a: number, b: number, c: number, d: number;
	local squareA: number, p: number, q: number, r: number;
	local count: number;

	a = c1 / c0;
	b = c2 / c0;
	c = c3 / c0;
	d = c4 / c0;

	squareA = a * a;
	p = -0.375 * squareA + b;
	q = 0.125 * squareA * a - 0.5 * a * b + c;
	r = -(3 / 256) * squareA * squareA + 0.0625 * squareA * b - 0.25 * a * c + d;

	if isZero(r) then
		coefficients[3] = q;
		coefficients[2] = p;
		coefficients[1] = 0;
		coefficients[0] = 1;

		s0, s1, s2 = solveCubic(coefficients[0], coefficients[1], coefficients[2], coefficients[3]);
		count = (s0 and 1 or 0) + (s1 and 1 or 0) + (s2 and 1 or 0);
	else
		coefficients[3] = 0.5 * r * p - 0.125 * q * q;
		coefficients[2] = -r;
		coefficients[1] = -0.5 * p;
		coefficients[0] = 1;

		s0, s1, s2 = solveCubic(coefficients[0], coefficients[1], coefficients[2], coefficients[3]);
		z = s0;

		u = z * z - r;
		v = 2 * z - p;

		if isZero(u) then
			u = 0;
		elseif (u > 0) then
			u = math.sqrt(u);
		else
			return;
		end;
		if isZero(v) then
			v = 0;
		elseif (v > 0) then
			v = math.sqrt(v);
		else
			return;
		end;

		coefficients[2] = z - u;
		coefficients[1] = q < 0 and -v or v;
		coefficients[0] = 1;

		s0, s1 = solveQuadric(coefficients[0], coefficients[1], coefficients[2]);
		count = (s0 and 1 or 0) + (s1 and 1 or 0);

		coefficients[2] = z + u;
		coefficients[1] = q < 0 and v or -v;
		coefficients[0] = 1;

		if (count == 0) then
			local root0: any, root1: any = solveQuadric(coefficients[0], coefficients[1], coefficients[2]);
			count = count + (root0 and 1 or 0) + (root1 and 1 or 0);
			s0, s1 = root0, root1;
		end;
		if (count == 1) then
			local root0: any, root1: any = solveQuadric(coefficients[0], coefficients[1], coefficients[2]);
			count = count + (root0 and 1 or 0) + (root1 and 1 or 0);
			s1, s2 = root0, root1;
		end;
		if (count == 2) then
			local root0: any, root1: any = solveQuadric(coefficients[0], coefficients[1], coefficients[2]);
			count = count + (root0 and 1 or 0) + (root1 and 1 or 0);
			s2, s3 = root0, root1;
		end;
	end;

	offset = 0.25 * a;

	local roots: {number} = {};
	if (count > 3) then
		table.insert(roots, s3 - offset);
	end;
	if (count > 2) then
		table.insert(roots, s2 - offset);
	end;
	if (count > 1) then
		table.insert(roots, s1 - offset);
	end;
	if (count > 0) then
		table.insert(roots, s0 - offset);
	end;

	return roots;
end;

prediction.SpawnTracer = function(from: Vector3, to: Vector3, custom: any): Part?
	local distance: number = (to - from).Magnitude;
	if distance < 0.01 then
		return;
	end;

	local segment: Part = tracer:Clone();
	segment.Color = custom.Color;
	segment.Size = vector.create(custom.Thick, custom.Thick, distance);
	segment.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -distance / 2);
	segment.Material = custom.Material;
	segment.Transparency = custom['Opacity'] or 0;

	if custom.Fade then
		tweenService:Create(segment, TweenInfo.new(custom.Lifetime), {
			['Transparency'] = 1
		}):Play();
	end;
	return segment;
end;
prediction.SpawnArcTracer = function(origin: Vector3, aimDirection: Vector3, projectileSpeed: number, gravity: number, travelTime: number, steps: number?, custom: any): ()
	steps = steps or 20;
	local stepTime: number = travelTime / steps;
	local gravityVector: Vector3 = Vector3.new(0, -gravity, 0);
	local velocity: Vector3 = aimDirection * projectileSpeed;

	local previousPosition: Vector3 = origin;
	local model: Model = Instance.new('Model');
	if custom.Material == Enum.Material.Glass then
		Instance.new('Highlight', model).Enabled = false;
	end;
	for step: number = 1, steps do
		local time: number = step * stepTime;
		local nextPosition: Vector3 = origin + velocity * time + 0.5 * gravityVector * time * time;
		local segment: Part? = prediction.SpawnTracer(previousPosition, nextPosition, custom);
		if segment then
			segment.Parent = model;
		end;
		previousPosition = nextPosition;
	end;

	model.Parent = workspace.Terrain;
	task.delay(custom.Lifetime, model.Destroy, model);
end;

local updatePattern: (State: any, Position: Vector3, Time: number, Knockback: any) -> (), updateInputs: (State: any, Humanoid: Humanoid?, Time: number, Velocity: Vector3, Knockback: any) -> ();
local validNumber: (value: any) -> any = function(value: any): any
	return type(value) == 'number' and value == value and math.abs(value) < math.huge;
end;

local horizontalMask: Vector3 = Vector3.new(1, 0, 1);
local targetMotion: {[Instance]: table} = {};
local rememberMotion: (root: Instance, state: table) -> () = function(root: Instance, state: table): ()
	if targetMotion[root] == nil and typeof(root) == 'Instance' then
		root.Destroying:Once(function(): ()
			targetMotion[root] = nil;
		end);
	end;
	targetMotion[root] = state;
end;
local validVector: (value: any) -> any = function(value: any): any
	return typeof(value) == 'Vector3'
		and validNumber(value.X)
		and validNumber(value.Y)
		and validNumber(value.Z);
end;

local getAttribute: (root: Instance?, attribute: string) -> ...any = function(root: Instance?, attribute: string): ...any
	local character: Instance? = root and root.Parent;
	if character and character:IsA('Model') then
		return character:GetAttribute(attribute);
	end;
end;

local resetMotion: (root: BasePart, state: any, position: Vector3, velocity: Vector3, time: number, spawnTime: any) -> any = function(root: BasePart, state: any, position: Vector3, velocity: Vector3, time: number, spawnTime: any): any
	local knockbackMark: any = state.knockbackMark;
	local knockbackMultiplier: any = state.knockbackMultiplier;
	local jumpVelocity: any = state.jumpVelocity;
	table.clear(state);
	state.jumpVelocity = jumpVelocity;
	state.assembly = velocity;
	state.damageTime = getAttribute(root, 'LastDamageTakenTime');
	state.knockbackMark = knockbackMark;
	state.knockbackMultiplier = knockbackMultiplier;
	state.position = position;
	state.samples = {{['position'] = position, ['time'] = time}};
	state.spawnTime = spawnTime;
	state.stableVelocity = velocity;
	state.time = time;
	state.velocity = velocity;
	rememberMotion(root, state);
	return state;
end;

prediction.markKnockback = function(target: any, multiplier: any, impulse: any): ()
	if typeof(target) ~= 'Instance' then
		return;
	end;

	local root: any = target:IsA('BasePart') and target or target:IsA('Model') and target.PrimaryPart;
	if not root then
		return;
	end;

	local state: any = targetMotion[root] or {};
	state.knockbackMark = workspace:GetServerTimeNow();
	state.knockbackMultiplier = multiplier;
	if validVector(impulse) then
		local horizontal: Vector3 = impulse * horizontalMask;
		state.knockbackHint = horizontal.Magnitude > epsilon and horizontal or nil;
		state.knockbackHintTime = state.knockbackMark;
	end;
	state.expectedImpulse = nil;
	state.expectedLift = nil;
	state.expectedTime = nil;
	rememberMotion(root, state);
end;

prediction.expectKnockback = function(target: any, arrival: any, impulse: any, multiplier: any): ()
	if typeof(target) ~= 'Instance' then
		return;
	end;

	local root: any = target:IsA('BasePart') and target or target:IsA('Model') and target.PrimaryPart;
	if not root or not validNumber(arrival) or not validVector(impulse) then
		return;
	end;

	local horizontal: Vector3 = impulse * horizontalMask;
	if horizontal.Magnitude <= epsilon and math.abs(impulse.Y) <= epsilon then
		return;
	end;

	local state: any = targetMotion[root] or {};
	state.expectedImpulse = horizontal;
	state.expectedLift = impulse.Y;
	state.expectedTime = arrival;
	state.expectedMultiplier = multiplier;
	rememberMotion(root, state);
end;

local pendingShots: table = {};
local residualSpread: number, residualSamples: number = 0, 0;
local epochHits: number, epochShots: number, epochRate: any = 0, 0, nil;
local stepDirection: number, stepSize: number = 1, 0.008;

local applyEpoch: () -> () = function(): ()
	if epochShots < 12 then
		return;
	end;

	local rate: number = epochHits / epochShots;
	epochHits, epochShots = 0, 0;
	if epochRate and rate + 0.02 < epochRate then
		stepDirection = -stepDirection;
		stepSize = math.max(stepSize * 0.7, 0.002);
	end;
	epochRate = rate;
	if rate >= 0.95 then
		return;
	end;
	latencyBias = math.clamp(latencyBias + stepDirection * stepSize, -0.12, 0.12);
end;

local measureSpread: (shot: any) -> () = function(shot: any): ()
	local root: any = shot.root;
	if typeof(root) ~= 'Instance' or not root.Parent then
		return;
	end;

	local state: any = targetMotion[root];
	if not state or state.spawnTime ~= shot.spawnTime then
		return;
	end;
	if state.knockbackUntil and state.knockbackUntil > shot.fireTime then
		return;
	end;

	local residual: Vector3 = (root.Position - shot.impact) * horizontalMask;
	if not validVector(residual) or residual.Magnitude > 30 then
		return;
	end;

	local cross: number = (residual - shot.direction * residual:Dot(shot.direction)).Magnitude;
	residualSpread = residualSpread + (cross - residualSpread) * 0.2;
	residualSamples = math.min(residualSamples + 1, 400);
end;

local resolveShots: () -> () = function(): ()
	if #pendingShots == 0 then
		return;
	end;
	local now: number = workspace:GetServerTimeNow();

	for i: number = #pendingShots, 1, -1 do
		local shot: any = pendingShots[i];
		if not shot.measured and now >= shot.dueTime then
			shot.measured = true;
			measureSpread(shot);
		end;
		if now > shot.dueTime + 0.35 then
			table.remove(pendingShots, i);
			epochShots += 1;
			applyEpoch();
		end;
	end;
end;

prediction.trackShot = function(targetRoot: any): ()
	if typeof(targetRoot) ~= 'Instance' then
		return;
	end;

	local state: any = targetMotion[targetRoot];
	local solution: any = state and state.lastSolution;
	if not solution or not validNumber(solution.travelTime) or not validVector(solution.impact) then
		return;
	end;

	local velocity: Vector3 = (state.velocity or Vector3.zero) * horizontalMask;
	if velocity.Magnitude < 8 then
		return;
	end;

	if #pendingShots >= 24 then
		table.remove(pendingShots, 1);
	end;
	table.insert(pendingShots, {
		['direction'] = velocity.Unit,
		['dueTime'] = solution.time + solution.travelTime,
		['fireTime'] = solution.time,
		['impact'] = solution.impact,
		['root'] = targetRoot,
		['spawnTime'] = state.spawnTime,
		['speed'] = velocity.Magnitude
	});
end;

prediction.reportHit = function(targetRoot: any): ()
	if typeof(targetRoot) ~= 'Instance' then
		return;
	end;

	local now: number = workspace:GetServerTimeNow();
	for i: number = #pendingShots, 1, -1 do
		local shot: any = pendingShots[i];
		if shot.root == targetRoot and now >= shot.dueTime - 0.35 and now <= shot.dueTime + 0.35 then
			if not shot.measured then
				shot.measured = true;
				measureSpread(shot);
			end;
			table.remove(pendingShots, i);
			epochHits += 1;
			epochShots += 1;
			applyEpoch();
			return;
		end;
	end;
end;

prediction.getResidualSpread = function(): (number, number)
	return residualSpread, residualSamples;
end;

prediction.getLatencyBias = function(): (number, number?)
	return latencyBias, epochRate;
end;

local worldFilter: any;
local learnedParams: RaycastParams = RaycastParams.new();
learnedParams.FilterType = Enum.RaycastFilterType.Include;
local excludeParams: RaycastParams = RaycastParams.new();
excludeParams.FilterType = Enum.RaycastFilterType.Exclude;
excludeParams.IgnoreWater = true;
excludeParams.RespectCanCollide = true;
local excludeList: table, excludeTime: number = {}, 0;

local castFloor: (position: Vector3, params: RaycastParams) -> ...any = function(position: Vector3, params: RaycastParams): ...any
	return prediction.Raycast(position, Vector3.new(0, workspace.FallenPartsDestroyHeight - position.Y, 0), params);
end;

local refreshExcludeList: (root: Instance?) -> any = function(root: Instance?): any
	local time: number = os.clock();
	if time - excludeTime > 1 then
		excludeTime = time;
		table.clear(excludeList);
		for _: number, player: Player in players:GetPlayers() do
			if player.Character then
				table.insert(excludeList, player.Character);
			end;
		end;
	end;

	local character: Instance? = root and root.Parent;
	if character and not table.find(excludeList, character) then
		table.insert(excludeList, character);
	end;
	return excludeList;
end;

local traceFloor: (position: Vector3, params: RaycastParams?, root: Instance?) -> any = function(position: Vector3, params: RaycastParams?, root: Instance?): any
	local character: Instance? = root and root.Parent;
	if params then
		local result: RaycastResult? = castFloor(position, params);
		if result and not (character and result.Instance:IsDescendantOf(character)) then
			if params.FilterType == Enum.RaycastFilterType.Include then
				worldFilter = params.FilterDescendantsInstances;
			end;
			return result.Position.Y;
		end;
	end;

	if worldFilter and #worldFilter > 0 then
		learnedParams.FilterDescendantsInstances = worldFilter;
		local result: RaycastResult? = castFloor(position, learnedParams);
		if result then
			return result.Position.Y;
		end;
	end;

	excludeParams.FilterDescendantsInstances = refreshExcludeList(root);
	local result: RaycastResult? = castFloor(position, excludeParams);
	return result and result.Position.Y or nil;
end;

local getTargetMotion: (root: BasePart?, position: Vector3, velocity: Vector3, airborne: boolean?, playerGravity: number?) -> any = function(root: BasePart?, position: Vector3, velocity: Vector3, airborne: boolean?, playerGravity: number?): any
	if not root or not validVector(position) or not validVector(velocity) then
		return {
			['acceleration'] = Vector3.zero,
			['position'] = position,
			['velocity'] = velocity
		};
	end;

	local time: number = workspace:GetServerTimeNow();
	local spawnTime: any = getAttribute(root, 'SpawnTime');
	local state: any = targetMotion[root] or {};
	if state.time and time - state.time < 1 / 240 then
		local knockback: any = state.knockbackUntil and time < state.knockbackUntil;
		return {
			['acceleration'] = state.acceleration or Vector3.zero,
			['decay'] = state.knockbackDecay,
			['flying'] = state.flying,
			['invalid'] = state.pendingPosition ~= nil,
			['impulse'] = knockback and state.knockbackImpulse,
			['knockback'] = knockback,
			['knockbackBase'] = knockback and state.knockbackBase,
			['expectedImpulse'] = state.expectedImpulse,
			['expectedLift'] = state.expectedLift,
			['expectedTime'] = state.expectedTime,
			['missRate'] = state.missRate,
			['position'] = state.position,
			['state'] = state,
			['stale'] = state.updateTime and math.clamp(time - state.updateTime, 0, 0.2) or nil,
			['strafeElapsed'] = state.strafeReversal and time - state.strafeReversal or nil,
			['strafeHalf'] = state.strafeHalf,
			['strafeSeen'] = state.strafeSeen,
			['strafeSpeed'] = state.strafeSpeed,
			['strafeDirection'] = state.strafeDirection,
			['turnRate'] = state.turnRate,
			['turnSeen'] = state.turnSeen,
			['velocity'] = state.velocity
		};
	end;
	if not state.time or time - state.time > 0.75 or state.spawnTime ~= spawnTime then
		state = resetMotion(root, state, position, velocity, time, spawnTime);
		return {
			['acceleration'] = Vector3.zero,
			['position'] = position,
			['state'] = state,
			['velocity'] = velocity
		};
	end;

	local delta: number = time - state.time;
	if delta <= epsilon then
		return {
			['acceleration'] = Vector3.zero,
			['flying'] = state.flying,
			['position'] = state.position,
			['state'] = state,
			['velocity'] = state.velocity
		};
	end;
	local displacement: Vector3 = position - state.position;
	local instantVelocity: Vector3 = displacement / delta;
	local assemblyAgreement: boolean = velocity.Magnitude > 5
		and instantVelocity.Magnitude > 5
		and velocity.Unit:Dot(instantVelocity.Unit) > 0.75
		and math.abs(velocity.Magnitude - instantVelocity.Magnitude) < math.max(40, velocity.Magnitude * 0.75);
	if state.pendingPosition then
		if (position - state.position).Magnitude < 2 then
			state.pendingPosition = nil;
			state.pendingTime = nil;
		elseif (position - state.pendingPosition).Magnitude < 2 then
			state = resetMotion(root, state, position, velocity, time, spawnTime);
			return {
				['acceleration'] = Vector3.zero,
				['changed'] = true,
				['position'] = position,
				['state'] = state,
				['velocity'] = velocity
			};
		else
			state.pendingPosition = nil;
			state.pendingTime = nil;
		end;
	end;

	local displacementLimit: number = math.max(12, (math.max(state.velocity.Magnitude, velocity.Magnitude) + 30) * delta * 1.5);
	if (displacement.Magnitude > displacementLimit or instantVelocity.Magnitude > 260) and not assemblyAgreement then
		state.pendingPosition = position;
		state.pendingTime = time;
		state.time = time;
		return {
			['acceleration'] = Vector3.zero,
			['flying'] = state.flying,
			['invalid'] = true,
			['position'] = state.position,
			['state'] = state,
			['velocity'] = state.velocity
		};
	end;

	local samples: any = state.samples;
	table.insert(samples, {['position'] = position, ['time'] = time});
	while #samples > 6 or (#samples > 2 and time - samples[1].time > 0.14) do
		table.remove(samples, 1);
	end;

	local measuredVelocity: Vector3?;
	local oldest: any = samples[1];
	if oldest and time - oldest.time > 0.02 then
		measuredVelocity = (position - oldest.position) / (time - oldest.time);
		if not validVector(measuredVelocity) or measuredVelocity.Magnitude > 260 then
			measuredVelocity = nil;
		end;
	end;

	local recentVelocity: Vector3?;
	local previousSample: any = samples[#samples - 1];
	if previousSample and time - previousSample.time > epsilon then
		recentVelocity = (position - previousSample.position) / (time - previousSample.time);
		if not validVector(recentVelocity) or recentVelocity.Magnitude > 260 then
			recentVelocity = nil;
		end;
	end;

	local damageTime: any = getAttribute(root, 'LastDamageTakenTime');
	local damageChanged: boolean = validNumber(damageTime) and damageTime > 0 and damageTime ~= state.damageTime;
	local marked: boolean = time - (state.knockbackMark or -math.huge) < 0.25;
	local velocityChange: Vector3 = velocity - state.assembly;
	local measuredAgreement: any = measuredVelocity
		and measuredVelocity.Magnitude > 5
		and velocity.Magnitude > 5
		and measuredVelocity.Unit:Dot(velocity.Unit) > 0.7
		and (measuredVelocity - velocity).Magnitude < math.max(35, velocity.Magnitude * 0.6);
	local velocityInvalid: boolean = (velocityChange.Magnitude > math.max(70, state.velocity.Magnitude * 2 + 35) or velocity.Magnitude > 260)
		and not marked
		and not damageChanged
		and not measuredAgreement;
	if velocityInvalid then
		local candidate: any = state.velocityCandidate;
		if candidate and time - state.velocityCandidateTime < 0.12 and (candidate - velocity).Magnitude < math.max(12, velocity.Magnitude * 0.2) then
			state.velocityCandidate = nil;
			state.velocityCandidateTime = nil;
		else
			state.velocityCandidate = velocity;
			state.velocityCandidateTime = time;
			velocity = state.assembly;
		end;
	else
		state.velocityCandidate = nil;
		state.velocityCandidateTime = nil;
	end;

	local assemblyHorizontal: Vector3 = velocity * horizontalMask;
	local measuredHorizontal: Vector3? = measuredVelocity and measuredVelocity * horizontalMask;
	local horizontalVelocity: Vector3 = assemblyHorizontal;
	local measuredAccepted: boolean?;
	if measuredHorizontal then
		local difference: number = (measuredHorizontal - assemblyHorizontal).Magnitude;
		if difference < math.max(6, assemblyHorizontal.Magnitude * 0.35) then
			horizontalVelocity = assemblyHorizontal:Lerp(measuredHorizontal, 0.15);
			measuredAccepted = true;
		elseif assemblyHorizontal.Magnitude < 2 and measuredHorizontal.Magnitude > 2 then
			local candidate: any = state.measuredCandidate;
			local consistent: any = candidate
				and time - state.measuredCandidateTime < 0.15
				and candidate.Magnitude > epsilon
				and measuredHorizontal.Magnitude > epsilon
				and candidate.Unit:Dot(measuredHorizontal.Unit) > 0.8
				and math.abs(candidate.Magnitude - measuredHorizontal.Magnitude) < math.max(12, measuredHorizontal.Magnitude * 0.35);
			if measuredHorizontal.Magnitude < 45 or consistent then
				horizontalVelocity = measuredHorizontal;
				measuredAccepted = true;
				state.measuredCandidate = nil;
				state.measuredCandidateTime = nil;
			else
				state.measuredCandidate = measuredHorizontal;
				state.measuredCandidateTime = time;
				horizontalVelocity = state.velocity * horizontalMask;
			end;
		else
			state.measuredCandidate = nil;
			state.measuredCandidateTime = nil;
		end;
	end;

	local verticalVelocity: number = velocity.Y;
	if measuredAccepted and measuredVelocity then
		if math.abs(verticalVelocity - measuredVelocity.Y) < 8 then
			verticalVelocity = verticalVelocity + (measuredVelocity.Y - verticalVelocity) * 0.15;
		elseif recentVelocity and math.abs(verticalVelocity) < 1 and (state.flying or math.abs(recentVelocity.Y) < 45) then
			verticalVelocity = recentVelocity.Y;
		end;
	end;
	if not airborne and math.abs(verticalVelocity) < 2 then
		verticalVelocity = 0;
	end;

	local combinedVelocity: Vector3 = Vector3.new(horizontalVelocity.X, verticalVelocity, horizontalVelocity.Z);
	local previousVelocity: Vector3 = state.velocity;
	local difference: number = (combinedVelocity - previousVelocity).Magnitude;
	local previousHorizontal: Vector3 = previousVelocity * horizontalMask;
	local directionChanged: boolean = horizontalVelocity.Magnitude > 2
		and previousHorizontal.Magnitude > 2
		and horizontalVelocity.Unit:Dot(previousHorizontal.Unit) < 0.65;
	local shift: number = difference / math.max(previousVelocity.Magnitude * 0.35, 7);
	local changed: boolean = shift >= 1 or directionChanged;
	local currentVelocity: Vector3;
	if changed then
		currentVelocity = combinedVelocity;
	else
		local alpha: number = math.clamp(delta * 20, 0.2, 1);
		currentVelocity = previousVelocity:Lerp(combinedVelocity, alpha + (1 - alpha) * shift * shift);
	end;

	local humanoid: Humanoid? = root.Parent and root.Parent:FindFirstChildWhichIsA('Humanoid');
	local humanoidState: any = humanoid and humanoid:GetState();
	state.leaping = humanoidState == Enum.HumanoidStateType.Jumping or humanoidState == Enum.HumanoidStateType.Freefall;
	local impulseChange: Vector3 = (currentVelocity - previousVelocity) * horizontalMask;
	local knockbackStarted: boolean = (marked or damageChanged)
		and (impulseChange.Magnitude > 1.5 or math.abs(currentVelocity.Y - previousVelocity.Y) > 1.5);
	if not knockbackStarted and humanoid and humanoid.PlatformStand then
		knockbackStarted = impulseChange.Magnitude > 5 or math.abs(currentVelocity.Y - previousVelocity.Y) > 5;
	end;

	if state.expectedTime then
		if knockbackStarted or time > state.expectedTime + 0.35 then
			state.expectedImpulse, state.expectedTime, state.expectedMultiplier, state.expectedLift = nil, nil, nil, nil;
		elseif time >= state.expectedTime then
			state.knockbackHint = state.expectedImpulse;
			state.knockbackHintTime = time;
			state.knockbackMark = time;
			state.knockbackMultiplier = state.expectedMultiplier;
			state.expectedImpulse, state.expectedTime, state.expectedMultiplier, state.expectedLift = nil, nil, nil, nil;
		end;
	end;

	local hint: any = state.knockbackHint;
	if hint and time - (state.knockbackHintTime or -math.huge) > 0.25 then
		hint, state.knockbackHint, state.knockbackHintTime = nil, nil, nil;
	end;
	if hint and not knockbackStarted and not state.knockbackUntil then
		knockbackStarted = true;
	end;
	if knockbackStarted then
		state.knockbackBase = state.stableVelocity * horizontalMask;
		state.knockbackDecay = airborne and 1.8 or 3.5;
		state.knockbackSeed = hint;
		state.knockbackStart = time;
		state.knockbackUntil = time + 0.6;
	end;

	local knockback: any = state.knockbackUntil and time < state.knockbackUntil;
	local knockbackImpulse: Vector3?;
	if knockback then
		knockbackImpulse = currentVelocity * horizontalMask - state.knockbackBase;
		local seed: any = state.knockbackSeed;
		if seed and time - state.knockbackStart < 0.12 and seed.Magnitude > knockbackImpulse.Magnitude then
			knockbackImpulse = seed;
		end;
		local previousImpulse: any = state.knockbackImpulse;
		if previousImpulse
			and previousImpulse.Magnitude > 4
			and knockbackImpulse.Magnitude > 4
			and previousImpulse.Unit:Dot(knockbackImpulse.Unit) < 0.35
		then
			state.knockbackUntil = nil;
			knockback = false;
		end;
		if previousImpulse
			and knockback
			and previousImpulse.Magnitude > 3
			and knockbackImpulse.Magnitude > 3
			and previousImpulse.Unit:Dot(knockbackImpulse.Unit) > 0.8
			and knockbackImpulse.Magnitude < previousImpulse.Magnitude
		then
			local decay: number = -math.log(knockbackImpulse.Magnitude / previousImpulse.Magnitude) / delta;
			if validNumber(decay) and decay > 0 then
				state.knockbackDecay = state.knockbackDecay + (math.clamp(decay, 0.75, 8) - state.knockbackDecay) * 0.35;
			end;
		end;
		if knockbackImpulse.Magnitude < 3 and time - state.knockbackStart > 0.1 then
			state.knockbackSeed = nil;
			state.knockbackUntil = nil;
			knockback = false;
		else
			state.knockbackImpulse = knockbackImpulse;
		end;
	end;

	if airborne then
		local verticalChange: number = (currentVelocity.Y - previousVelocity.Y) / delta;
		if validNumber(verticalChange) then
			state.verticalAcceleration = state.verticalAcceleration
				and state.verticalAcceleration + (verticalChange - state.verticalAcceleration) * 0.25
				or verticalChange;
		end;
		state.airTime = (state.airTime or 0) + delta;
		if state.airTime > 0.6 and state.verticalAcceleration and validNumber(playerGravity) and playerGravity > 0 then
			if state.verticalAcceleration > -playerGravity * 0.4 then
				local floorY: number? = traceFloor(position, nil, root);
				state.flying = floorY and position.Y - floorY > 12 or false;
			else
				state.flying = false;
			end;
		end;
	else
		state.airTime = nil;
		state.verticalAcceleration = nil;
		state.flying = nil;
	end;

	local takeoffBase: number = state.position.Y;
	local missedLanding: boolean?;
	if airborne and state.airborne and previousVelocity.Y <= 0 and currentVelocity.Y > 8 and not knockback then
		local floorY: number? = traceFloor(position, nil, root);
		local height: number = humanoid and humanoid.HipHeight + root.Size.Y * 0.5 or 3;
		if floorY and position.Y - floorY <= height + 3 then
			missedLanding = true;
			takeoffBase = floorY + height;
		end;
	end;
	if airborne and (not state.airborne or missedLanding) and currentVelocity.Y > 5 and not knockback then
		local takeoff: number = currentVelocity.Y;
		local reference: number = state.jumpVelocity or takeoff;
		if takeoff < reference * 1.5 and takeoff > reference * 0.5 then
			state.jumpVelocity = state.jumpVelocity and (state.jumpVelocity + (takeoff - state.jumpVelocity) * 0.35) or takeoff;
			if state.jumpStart then
				local period: number = time - state.jumpStart;
				local rise: number? = state.jumpBase and takeoffBase - state.jumpBase;
				if period > 0.15 and period < 1.5 then
					if state.jumpPeriod then
						local drift: number = math.abs(period - state.jumpPeriod) / state.jumpPeriod;
						state.jumpDrift = state.jumpDrift and (state.jumpDrift + (drift - state.jumpDrift) * 0.35) or drift;
					end;
					state.jumpPeriod = state.jumpPeriod and (state.jumpPeriod + (period - state.jumpPeriod) * 0.35) or period;
					state.jumpSeen = math.min((state.jumpSeen or 0) + 1, 6);
				else
					state.jumpSeen, state.jumpPeriod = nil, nil;
				end;
				if period > 0.15 and period < 1.5 and rise and rise > 1 and rise < 8 then
					state.climbStep = state.climbStep and (state.climbStep + (rise - state.climbStep) * 0.35) or rise;
					state.climbSeen = math.min((state.climbSeen or 0) + 1, 6);
				else
					state.climbStep, state.climbSeen = nil, nil;
				end;
			end;
			state.jumpStart = time;
			state.jumpBase = takeoffBase;
		elseif not state.jumpVelocity then
			state.jumpVelocity = takeoff;
			state.jumpStart = time;
			state.jumpBase = takeoffBase;
		end;
	end;
	state.airborne = airborne;
	if state.jumpPeriod and time - (state.jumpStart or 0) > state.jumpPeriod + math.max(0.1, state.jumpPeriod * (state.jumpDrift or 0) * 2) then
		state.jumpPeriod, state.jumpSeen, state.climbStep, state.climbSeen = nil, nil, nil, nil;
	end;

	local strafeHorizontal: Vector3 = currentVelocity * horizontalMask;
	if strafeHorizontal.Magnitude > 4 and not knockback then
		state.strafeSlow = nil;
		state.strafeSpeed = state.strafeSpeed and (state.strafeSpeed + (strafeHorizontal.Magnitude - state.strafeSpeed) * 0.2) or strafeHorizontal.Magnitude;
		local unit: Vector3 = strafeHorizontal.Unit;
		local previous: Vector3? = state.strafeDirection;
		if previous and math.abs(unit:Dot(previous)) < 0.65 then
			state.strafeHalf, state.strafeReversal, state.strafeSeen = nil, nil, nil;
			state.strafeDirection = unit;
		elseif previous and unit:Dot(previous) < -0.5 then
			local lastReversal: number? = state.strafeReversal;
			if lastReversal then
				local half: number = time - lastReversal;
				if half > 0.08 and half < 1.2 then
					state.strafeHalf = state.strafeHalf and (state.strafeHalf + (half - state.strafeHalf) * 0.35) or half;
					state.strafeSeen = math.min((state.strafeSeen or 0) + 1, 6);
				end;
			end;
			state.strafeDirection = unit;
			state.strafeReversal = time;
		elseif not previous or unit:Dot(previous) > 0.5 then
			state.strafeDirection = unit;
		end;
	elseif strafeHorizontal.Magnitude < 1 then
		state.strafeSlow = state.strafeSlow or time;
		if time - state.strafeSlow > 0.2 then
			state.strafeDirection, state.strafeHalf, state.strafeSeen, state.strafeSpeed = nil, nil, nil, nil;
		end;
	end;
	if state.strafeReversal and time - state.strafeReversal > (state.strafeHalf and state.strafeHalf * 1.5 or 2.5) then
		state.strafeHalf, state.strafeReversal, state.strafeSeen, state.strafeSpeed = nil, nil, nil, nil;
	end;

	local previousTurn: Vector3? = state.turnUnit;
	if strafeHorizontal.Magnitude > 5 and not knockback then
		local unit: Vector3 = strafeHorizontal.Unit;
		if previousTurn and delta > epsilon then
			local cross: number = previousTurn.X * unit.Z - previousTurn.Z * unit.X;
			local angle: number = math.atan2(cross, math.clamp(previousTurn:Dot(unit), -1, 1));
			if math.abs(angle) < 1.4 then
				local rate: number = angle / delta;
				local settled: number? = state.turnRate;
				if settled and settled * rate > 0 and math.abs(rate) > 0.25 then
					state.turnSeen = math.min((state.turnSeen or 0) + 1, 12);
				elseif math.abs(rate) < 0.25 then
					state.turnSeen = math.max((state.turnSeen or 0) - 1, 0);
				else
					state.turnSeen = 0;
				end;
				state.turnRate = settled and settled + (rate - settled) * 0.3 or rate;
			else
				state.turnRate, state.turnSeen = nil, 0;
			end;
		end;
		state.turnUnit = unit;
	else
		state.turnRate, state.turnSeen, state.turnUnit = nil, 0, nil;
	end;
	if state.strafeReversal and time - state.strafeReversal < delta * 1.5 then
		state.turnRate, state.turnSeen = nil, 0;
	end;

	if strafeHorizontal.Magnitude > 4 then
		if displacement.Magnitude > epsilon then
			state.updateTime = time;
		end;
	else
		state.updateTime = nil;
	end;

	local pending: any = state.pending;
	if pending then
		while pending[1] and pending[1].arrival <= time do
			local entry: any = table.remove(pending, 1);
			local observed: Vector3 = state.position:Lerp(position, math.clamp((entry.arrival - state.time) / delta, 0, 1));
			local miss: number = ((observed - entry.position) * horizontalMask).Magnitude / entry.horizon;
			if entry.candidates then
				state.scores = state.scores or {};
				local scores: any = state.scores[entry.bucket] or {['count'] = 0};
				for i: number, v: Vector3 in entry.candidates do
					local difference: Vector3 = (observed - v) * horizontalMask;
					local loss: number = math.min(difference:Dot(difference) / 9, 4);
					scores[i] = scores[i] and scores[i] + (loss - scores[i]) * 0.2 or loss;
				end;
				scores.count += 1;
				state.scores[entry.bucket] = scores;
			end;
			if state.missRate then
				miss = math.min(miss, state.missRate * 1.5);
			end;
			state.missRate = state.missRate and (state.missRate + (miss - state.missRate) * 0.3) or miss;
		end;
	end;

	local acceleration: Vector3 = Vector3.zero;
	if not knockback and horizontalVelocity.Magnitude > 1 then
		local change: Vector3 = (currentVelocity - previousVelocity) * horizontalMask / delta;
		local parallel: number = change:Dot(horizontalVelocity.Unit);
		local perpendicular: number = (change - horizontalVelocity.Unit * parallel).Magnitude;
		if parallel < -8 and perpendicular < math.abs(parallel) * 0.6 then
			acceleration = horizontalVelocity.Unit * math.max(parallel, -400);
		end;
	end;

	if not knockback then
		state.stableVelocity = currentVelocity;
		state.knockbackImpulse = nil;
	end;
	state.assembly = velocity;
	state.acceleration = acceleration;
	state.damageTime = damageTime;
	state.position = position;
	state.time = time;
	state.velocity = currentVelocity;
	updatePattern(state, position, time, knockback);
	updateInputs(state, humanoid, time, currentVelocity * horizontalMask, knockback);
	return {
		['acceleration'] = acceleration,
		['changed'] = changed or knockbackStarted,
		['decay'] = state.knockbackDecay,
		['flying'] = state.flying,
		['impulse'] = knockback and knockbackImpulse,
		['knockback'] = knockback,
		['knockbackBase'] = knockback and state.knockbackBase,
		['expectedImpulse'] = state.expectedImpulse,
		['expectedLift'] = state.expectedLift,
		['expectedTime'] = state.expectedTime,
		['missRate'] = state.missRate,
		['position'] = position,
		['state'] = state,
		['stale'] = state.updateTime and math.clamp(time - state.updateTime, 0, 0.2) or nil,
		['strafeElapsed'] = state.strafeReversal and time - state.strafeReversal or nil,
		['strafeHalf'] = state.strafeHalf,
		['strafeSeen'] = state.strafeSeen,
		['strafeSpeed'] = state.strafeSpeed,
		['strafeDirection'] = state.strafeDirection,
		['turnRate'] = state.turnRate,
		['turnSeen'] = state.turnSeen,
		['velocity'] = currentVelocity
	};
end;

local gradeSpeed: number, gradeGravity: number, gradeInterval: number = 240, 35, 0.1;

prediction.Observe = function(root: any, position: any, velocity: any, airborne: any, playerGravity: any, origin: any, playerHeight: any, playerJump: any): ()
	if typeof(root) ~= 'Instance' then
		return;
	end;

	local motion: any = getTargetMotion(root, position, velocity, airborne, playerGravity);
	local state: any = motion.state;
	if not state or not validVector(origin) then
		return;
	end;

	local now: number = workspace:GetServerTimeNow();
	if now - (state.gradeTime or -math.huge) < gradeInterval then
		return;
	end;

	prediction.SolveTrajectory(origin, gradeSpeed, gradeGravity, position, velocity, playerGravity, playerHeight, playerJump, nil, airborne, position, root, nil, true);
end;

local patternInterval: number = 1 / 30;
local patternVelocities: {Vector3} = {};

updatePattern = function(state: any, position: Vector3, time: number, knockback: any): ()
	if knockback then
		state.pattern = nil;
		return;
	end;

	local pattern: any = state.pattern;
	if not pattern or time - pattern.observed > 0.25 then
		state.pattern = {['samples'] = {position * horizontalMask}, ['time'] = time, ['observed'] = time, ['position'] = position};
		return;
	end;

	local samples: {Vector3} = pattern.samples;
	local elapsed: number = time - pattern.observed;
	while time - pattern.time >= patternInterval do
		pattern.time += patternInterval;
		local alpha: number = math.clamp((pattern.time - pattern.observed) / math.max(elapsed, epsilon), 0, 1);
		table.insert(samples, pattern.position:Lerp(position, alpha) * horizontalMask);
		if #samples > 128 then
			table.remove(samples, 1);
		end;
	end;
	pattern.observed, pattern.position = time, position;
	if time - (pattern.checked or 0) < 0.1 then
		return;
	end;
	pattern.checked = time;

	local count: number = #samples;
	for i: number = 3, count do
		patternVelocities[i] = (samples[i] - samples[i - 2]) / (patternInterval * 2);
	end;

	local best: number, bestError: number, bestVariance: number;
	for period: number = 9, math.min(66, math.floor((count - 3) / 2)) do
		local span: number = math.min(period, 30);
		local error: number, energy: number, average: Vector3 = 0, 0, Vector3.zero;
		for i: number = count - span + 1, count do
			local current: Vector3 = patternVelocities[i];
			local previous: Vector3 = patternVelocities[i - period];
			local difference: Vector3 = current - previous;
			error += difference:Dot(difference);
			energy += current:Dot(current);
			average += current;
		end;
		average /= span;
		local variance: number = energy / span - average:Dot(average);
		error /= span;
		if variance > 16 and error < variance * 0.12 and (not bestError or error < bestError * 0.85) then
			best, bestError, bestVariance = period, error, variance;
		end;
	end;

	if best then
		local current: Vector3 = (samples[count] - samples[count - 3]) / (patternInterval * 3);
		local previous: Vector3 = (samples[count - best] - samples[count - best - 3]) / (patternInterval * 3);
		local difference: Vector3 = current - previous;
		if difference:Dot(difference) < math.max(9, bestVariance * 0.2) then
			pattern.seen = pattern.period and math.abs(pattern.period - best) <= 2 and (pattern.seen or 0) + 1 or 1;
			pattern.period = best;
			pattern.error = bestError / bestVariance;
			return;
		end;
	end;
	pattern.period, pattern.seen = nil, nil;
end;

local patternDisplacement: (pattern: any, elapsed: number) -> any = function(pattern: any, elapsed: number): any
	local samples: {Vector3} = pattern.samples;
	local count: number, period: any = #samples, pattern.period;
	local phase: number = elapsed / patternInterval;
	local cycles: number = math.floor(phase / period);
	phase -= cycles * period;
	local index: number = math.floor(phase);
	local position: Vector3 = samples[count - period + index]:Lerp(samples[count - period + index + 1], phase - index);
	local drift: Vector3 = samples[count] - samples[count - period];
	return position - samples[count - period] + drift * cycles;
end;

local inputDelay: number = 0.18;
local inputDelaySeen: number = 0;
local inputHistory: number = 1;
local inputFresh: number = 0.25;

updateInputs = function(state: any, humanoid: Humanoid?, time: number, velocity: Vector3, knockback: any): ()
	local move: any = humanoid and humanoid.MoveDirection;
	if not validVector(move) then
		state.inputs = nil;
		return;
	end;

	move = move * horizontalMask;
	local inputs: any = state.inputs;
	if not inputs then
		inputs = {};
		state.inputs = inputs;
	end;

	local last: any = inputs[#inputs];
	if not last or (last.move - move).Magnitude > 1e-3 then
		table.insert(inputs, {['move'] = move, ['time'] = time});
	end;
	while #inputs > 2 and inputs[2].time < time - inputHistory do
		table.remove(inputs, 1);
	end;
	state.inputTime = time;

	local speed: number = velocity.Magnitude;
	if not knockback and speed > 8 and speed < 60 and move.Magnitude > 0.5 then
		state.cruise = state.cruise and state.cruise + (speed - state.cruise) * 0.1 or speed;
	end;

	local change: any = state.inputChange;
	if change then
		if knockback or time - change.time > 0.5 then
			state.inputChange = nil;
		elseif speed > 4 and velocity.Unit:Dot(change.direction) > 0.8 then
			local delay: number = time - change.time;
			if delay > 0.03 and delay < 0.45 then
				inputDelay += (delay - inputDelay) * 0.1;
				inputDelaySeen += 1;
			end;
			state.inputChange = nil;
		end;
	end;

	if last and last.move ~= move and last.move.Magnitude > 0.5 and move.Magnitude > 0.5 and last.move.Unit:Dot(move.Unit) < 0.3 then
		if speed < 4 or velocity.Unit:Dot(move.Unit) < 0.3 then
			state.inputChange = {['direction'] = move.Unit, ['time'] = time};
		end;
	end;
end;

local getInputPath: (state: any, now: number) -> any = function(state: any, now: number): any
	local inputs: any = state and state.inputs;
	if not inputs or #inputs == 0 or now - (state.inputTime or -math.huge) > inputFresh then
		return nil;
	end;

	local speed: number = math.clamp(state.cruise or 20, 8, 60);
	local start: number = now - inputDelay;
	local first: number = 1;
	for i: number = #inputs, 1, -1 do
		if inputs[i].time <= start then
			first = i;
			break;
		end;
	end;

	local path: table = {{0, inputs[first].move * speed}};
	for i: number = first + 1, #inputs do
		table.insert(path, {inputs[i].time - start, inputs[i].move * speed});
	end;
	return path;
end;

local inputDisplacement: (path: any, elapsed: number) -> any = function(path: any, elapsed: number): any
	local offset: Vector3 = Vector3.zero;
	for i: number, v: any in path do
		local from: number = v[1];
		if elapsed <= from then
			break;
		end;
		local following: any = path[i + 1];
		local to: number = following and math.min(following[1], elapsed) or elapsed;
		offset += v[2] * (to - from);
	end;
	return offset;
end;

prediction.getInputDelay = function(): (number, number)
	return inputDelay, inputDelaySeen;
end;

local solveMotionTime: (origin: Vector3, speed: number, projectileAcceleration: Vector3, positionAtTime: (number) -> Vector3, Minimum: number?) -> any = function(origin: Vector3, speed: number, projectileAcceleration: Vector3, positionAtTime: (number) -> Vector3, minimum: number?): any
	local evaluate: (time: number) -> any = function(time: number): any
		local offset: Vector3 = positionAtTime(time) - origin - projectileAcceleration * (0.5 * time * time);
		return offset:Dot(offset) - speed * speed * time * time;
	end;

	local low: number = minimum or 0;
	local lowValue: number = evaluate(low);
	if not validNumber(lowValue) then
		return;
	end;
	local distance: number = (positionAtTime(low) - origin).Magnitude;
	local start: number = low;
	local maximum: number = math.min(math.max(distance / speed * 4 + 1, low + 2), 12);
	for step: number = 1, 72 do
		local alpha: number = step / 72;
		local high: number = start + (maximum - start) * math.pow(alpha, 1.35);
		local highValue: number = evaluate(high);
		if not validNumber(highValue) then
			return;
		end;
		if math.abs(highValue) < math.max(1e-7, speed * speed * high * high * 1e-7) then
			return high;
		end;
		if (highValue > 0) ~= (lowValue > 0) then
			for _: number = 1, 60 do
				local middle: number = (low + high) * 0.5;
				if (evaluate(middle) > 0) == (lowValue > 0) then
					low = middle;
				else
					high = middle;
				end;
			end;
			return high;
		end;
		low = high;
		lowValue = highValue;
	end;
end;

local solveInterceptTime: (displacement: Vector3, velocity: Vector3, acceleration: Vector3, speed: number, minimum: number?) -> ...any = function(displacement: Vector3, velocity: Vector3, acceleration: Vector3, speed: number, minimum: number?): ...any
	minimum = minimum or 0;
	local halfAcceleration: Vector3 = acceleration * 0.5;
	if halfAcceleration:Dot(halfAcceleration) < epsilon then
		local a: number = velocity:Dot(velocity) - speed * speed;
		local b: number = 2 * velocity:Dot(displacement);
		local c: number = displacement:Dot(displacement);
		if math.abs(a) < epsilon then
			local time: number? = math.abs(b) > epsilon and -c / b or nil;
			return time and time > math.max(epsilon, minimum) and time or nil;
		end;

		local discriminant: number = b * b - 4 * a * c;
		local tolerance: number = epsilon * (b * b + math.abs(4 * a * c) + 1);
		if discriminant < -tolerance then
			return;
		end;

		local root: number = math.sqrt(math.max(discriminant, 0));
		local q: number = -0.5 * (b + (b >= 0 and root or -root));
		local first: number? = q / a;
		local second: number? = math.abs(q) > epsilon and c / q or nil;
		first = first and first > math.max(epsilon, minimum) and first or nil;
		second = second and second > math.max(epsilon, minimum) and second or nil;
		if first and second then
			return math.min(first, second);
		end;
		return first or second;
	end;

	local c4: number = halfAcceleration:Dot(halfAcceleration);
	local c3: number = 2 * halfAcceleration:Dot(velocity);
	local c2: number = 2 * halfAcceleration:Dot(displacement) + velocity:Dot(velocity) - speed * speed;
	local c1: number = 2 * velocity:Dot(displacement);
	local c0: number = displacement:Dot(displacement);
	local root0: any, root1: any, root2: any = solveCubic(4 * c4, 3 * c3, 2 * c2, c1);
	local critical: {number} = {};
	if validNumber(root0) and root0 > minimum then
		table.insert(critical, root0);
	end;
	if validNumber(root1) and root1 > minimum then
		table.insert(critical, root1);
	end;
	if validNumber(root2) and root2 > minimum then
		table.insert(critical, root2);
	end;
	table.sort(critical);

	local evaluate: (time: number) -> any = function(time: number): any
		return ((((c4 * time + c3) * time + c2) * time + c1) * time + c0);
	end;

	local tolerance: (time: number) -> ...any = function(time: number): ...any
		return math.max(1e-7, speed * speed * time * time * 1e-7);
	end;

	local bisect: (low: number, high: number, lowValue: number) -> any = function(low: number, high: number, lowValue: number): any
		for _: number = 1, 60 do
			local middle: number = (low + high) * 0.5;
			local value: number = evaluate(middle);
			if (value > 0) == (lowValue > 0) then
				low = middle;
				lowValue = value;
			else
				high = middle;
			end;
		end;
		return high;
	end;

	local previous: number = minimum;
	local previousValue: number = evaluate(previous);
	for _: number, time: number in critical do
		local value: number = evaluate(time);
		if previousValue * value < 0 then
			return bisect(previous, time, previousValue);
		end;
		if math.abs(value) <= tolerance(time) then
			return time;
		end;
		previous = time;
		previousValue = value;
	end;

	if previousValue < 0 then
		local high: number = math.max(previous * 2, previous + 1);
		local highValue: number = evaluate(high);
		while highValue < 0 do
			high *= 2;
			highValue = evaluate(high);
		end;
		return bisect(previous, high, previousValue);
	end;
	return;
end;

local strafeDisplacement: (elapsed: number, remaining: number, half: number) -> any = function(elapsed: number, remaining: number, half: number): any
	local phase: number = half - remaining;
	local future: number = (phase + elapsed) % (half * 2);
	return (future <= half and future or half * 2 - future) - phase;
end;

local solveLandingTime: (startY: number, floorY: number, verticalVelocity: number, playerGravity: number) -> ...any = function(startY: number, floorY: number, verticalVelocity: number, playerGravity: number): ...any
	local height: number = startY - floorY;
	if height <= epsilon and verticalVelocity <= 0 then
		return nil, true;
	end;

	local discriminant: number = verticalVelocity * verticalVelocity + 2 * playerGravity * height;
	if discriminant < 0 then
		return nil;
	end;

	local landing: number = (verticalVelocity + math.sqrt(discriminant)) / playerGravity;
	return validNumber(landing) and landing > epsilon and landing or nil;
end;

local solveStaticLaunch: (origin: Vector3, target: Vector3, speed: number, acceleration: Vector3) -> ...any = function(origin: Vector3, target: Vector3, speed: number, acceleration: Vector3): ...any
	local delta: Vector3 = target - origin;
	if speed <= epsilon then
		return;
	end;

	local pull: number = -acceleration.Y;
	if math.abs(pull) <= epsilon then
		local distance: number = delta.Magnitude;
		if distance <= epsilon then
			return;
		end;
		local time: number = distance / speed;
		return delta / time, time;
	end;

	local a: number = 0.25 * pull * pull;
	local b: number = (pull * delta.Y) - (speed * speed);
	local c: number = delta:Dot(delta);
	local discriminant: number = (b * b) - (4 * a * c);
	if discriminant < 0 then
		return;
	end;

	local root: number = math.sqrt(discriminant);
	local first: number, second: number = (-b - root) / (2 * a), (-b + root) / (2 * a);
	local squared: number? = first > epsilon and first or (second > epsilon and second or nil);
	if not squared then
		return;
	end;

	local time: number = math.sqrt(squared);
	if not validNumber(time) or time <= epsilon then
		return;
	end;

	local velocity: Vector3 = (delta + Vector3.new(0, 0.5 * pull * time * time, 0)) / time;
	if not validVector(velocity) then
		return;
	end;

	return velocity, time;
end;

local coverLift: number = 2;
local aimLift: number = 0.5;

prediction.SolveTrajectory = function(origin: any, projectileSpeed: any, gravity: any, targetPosition: any, targetVelocity: any, playerGravity: any, playerHeight: any, playerJump: any, params: any, targetAirborne: any, targetRootPosition: any, targetRoot: any, minimumTime: any, strict: any): (Vector3?, Vector3?, number?)
	resolveShots();
	targetVelocity = targetVelocity or Vector3.zero;
	projectileSpeed = tonumber(projectileSpeed) or 0;
	gravity = tonumber(gravity) or 0;
	playerGravity = tonumber(playerGravity) or 0;
	playerHeight = tonumber(playerHeight) or 0;
	if typeof(targetRootPosition) == 'Instance' and targetRootPosition:IsA('BasePart') then
		targetRoot = targetRootPosition;
		targetRootPosition = targetRoot.Position;
	end;
	if not validVector(origin)
		or not validVector(targetPosition)
		or not validVector(targetVelocity)
		or not validNumber(projectileSpeed)
		or projectileSpeed <= epsilon
		or not validNumber(gravity)
		or not validNumber(playerGravity)
		or not validNumber(playerHeight)
	then
		local state: any = targetRoot and targetMotion[targetRoot];
		local lastSolution: any = state and state.lastSolution;
		local currentPosition: any = typeof(targetRoot) == 'Instance' and targetRoot:IsA('BasePart') and targetRoot.Position;
		if lastSolution
			and validVector(origin)
			and validVector(currentPosition)
			and workspace:GetServerTimeNow() - lastSolution.time < 0.08
			and math.abs(lastSolution.projectileSpeed - projectileSpeed) < 0.01
			and math.abs(lastSolution.gravity - gravity) < 0.01
			and (lastSolution.origin - origin).Magnitude < 4
			and (lastSolution.targetPosition - currentPosition).Magnitude < 6
		then
			return origin + lastSolution.velocity, lastSolution.impact, lastSolution.travelTime;
		end;
		if strict then
			return nil;
		end;
		return targetPosition, targetPosition;
	end;
	if not validVector(targetRootPosition) then
		targetRootPosition = targetPosition;
	end;
	if (targetPosition - targetRootPosition).Magnitude < 0.1 then
		targetPosition += Vector3.new(0, aimLift, 0);
	end;
	local targetOffset: Vector3 = targetPosition - targetRootPosition;
	if type(targetAirborne) ~= 'boolean' then
		targetAirborne = nil;
	end;
	if targetAirborne == nil then
		targetAirborne = math.abs(targetVelocity.Y) > 0.01;
	end;

	local motion: any = getTargetMotion(targetRoot, targetRootPosition, targetVelocity, targetAirborne, playerGravity);
	if motion.invalid and strict then
		return nil;
	end;
	targetRootPosition = motion.position;
	targetPosition = targetRootPosition + targetOffset;
	targetVelocity = motion.velocity;
	local solutionTargetPosition: Vector3 = targetRootPosition;
	local observedPosition: any, observedVelocity: any = targetPosition, targetVelocity;
	if residualSamples >= 8 then
		local lead: Vector3 = targetVelocity * horizontalMask;
		if lead.Magnitude > 6 then
			targetPosition -= lead.Unit * math.clamp(residualSpread * 0.5, 0, 2);
		end;
	end;
	local leadConfidence: number = 1;
	local missRate: any = motion.missRate;
	if missRate and missRate > epsilon and not motion.knockback then
		local speed: number = (targetVelocity * horizontalMask).Magnitude;
		if speed > epsilon then
			leadConfidence = (speed * speed) / (speed * speed + missRate * missRate);
		end;
	end;
	local targetAcceleration: Vector3 = Vector3.zero;
	if playerGravity > 0 and (targetAirborne or targetVelocity.Y < -1) and not motion.flying then
		targetAcceleration = Vector3.new(0, -playerGravity, 0);
	end;
	local horizontalAcceleration: Vector3 = motion.acceleration;
	local horizontalVelocity: Vector3 = targetVelocity * horizontalMask;
	local stopTime: number?;
	if horizontalAcceleration.Magnitude > epsilon and horizontalVelocity.Magnitude > epsilon then
		local slowdown: number = horizontalAcceleration:Dot(horizontalVelocity.Unit);
		stopTime = math.abs(slowdown) > epsilon and -horizontalVelocity.Magnitude / slowdown or nil;
		if not validNumber(stopTime) or stopTime <= epsilon or stopTime > 0.35 then
			horizontalAcceleration = Vector3.zero;
			stopTime = nil;
		end;
	end;

	local strafeHalf: any, strafeRemaining: number, strafeVelocity: Vector3;
	if motion.strafeHalf and (motion.strafeSeen or 0) >= 2 then
		if horizontalVelocity.Magnitude > 4 then
			strafeHalf, strafeVelocity = motion.strafeHalf, horizontalVelocity;
		elseif motion.strafeDirection and (motion.strafeSpeed or 0) > 4 then
			strafeHalf, strafeVelocity = motion.strafeHalf, motion.strafeDirection * motion.strafeSpeed;
		end;
		if strafeHalf then
			strafeRemaining = math.clamp(strafeHalf - (motion.strafeElapsed or 0), 0, strafeHalf);
		end;
	end;

	local turnRate: number?;
	if not strafeHalf
		and (motion.turnSeen or 0) >= 4
		and validNumber(motion.turnRate)
		and horizontalVelocity.Magnitude > 5
		and horizontalAcceleration.Magnitude <= epsilon
	then
		turnRate = math.clamp(motion.turnRate, -5, 5);
		if math.abs(turnRate) < 0.25 then
			turnRate = nil;
		end;
	end;

	local jumpVelocity: any, jumpPeriod: any, climbStep: any;
	if not playerJump and motion.state and (motion.state.jumpSeen or 0) >= 2 and motion.state.jumpPeriod and workspace:GetServerTimeNow() - (motion.state.jumpStart or 0) < motion.state.jumpPeriod * 1.5 then
		playerJump = motion.state.jumpVelocity;
	end;
	if not playerJump and (targetVelocity * horizontalMask).Magnitude > 8 then
		playerJump = 42.6;
	end;
	if not playerJump and motion.state and motion.state.leaping then
		playerJump = motion.state.jumpVelocity or 42.6;
	end;
	if validNumber(playerJump) and playerJump > 0 and playerGravity > 0 and not motion.flying then
		jumpVelocity = playerJump;
		local observed: any = motion.state and motion.state.jumpVelocity;
		if validNumber(observed) and observed > 0 then
			jumpVelocity = math.clamp(observed, playerJump * 0.6, playerJump * 1.6);
		end;
		local period: any = motion.state and motion.state.jumpPeriod;
		if validNumber(period) and period > 0 then
			jumpPeriod = period;
		end;
		local climb: any = motion.state and motion.state.climbStep;
		if jumpPeriod
			and validNumber(climb)
			and (motion.state.climbSeen or 0) >= 2
			and climb < jumpVelocity * jumpVelocity / (2 * playerGravity)
			and workspace:GetServerTimeNow() - (motion.state.jumpStart or -math.huge) < jumpPeriod * 2
		then
			climbStep = climb;
		end;
	end;

	local groundY: any, landingTime: number, floorLimit: any;
	if playerHeight > 0 then
		local floorY: number? = traceFloor(targetRootPosition, params, targetRoot);
		if floorY then
			floorLimit = floorY + playerHeight + targetOffset.Y;
		end;
		if floorY and (targetAcceleration.Y < 0 or jumpVelocity) and not motion.flying then
			local landing: any, grounded: any = solveLandingTime(targetRootPosition.Y, floorY + playerHeight, targetVelocity.Y, playerGravity);
			local horizontal: Vector3 = targetVelocity * horizontalMask;
			local floorPath: any = not motion.knockback and not motion.flying and getInputPath(motion.state, workspace:GetServerTimeNow());
			if landing and horizontal.Magnitude * landing > 2 then
				local settled: boolean?;
				for step: number = 1, 4 do
					local sampleTime: number = landing * (step / 4);
					local sampleFloor: number? = traceFloor(targetRootPosition + (floorPath and inputDisplacement(floorPath, sampleTime) or horizontal * sampleTime), params, targetRoot);
					if sampleFloor then
						local height: number = targetRootPosition.Y + targetVelocity.Y * sampleTime - playerGravity * (0.5 * sampleTime * sampleTime);
						if height <= sampleFloor + playerHeight then
							local solved: number? = solveLandingTime(targetRootPosition.Y, sampleFloor + playerHeight, targetVelocity.Y, playerGravity);
							if solved then
								floorY = sampleFloor;
								landing = solved;
								settled = true;
								break;
							end;
						end;
					end;
				end;

				if not settled then
					local drifted: number? = traceFloor(targetRootPosition + (floorPath and inputDisplacement(floorPath, landing) or horizontal * landing), params, targetRoot);
					if drifted and math.abs(drifted - floorY) > epsilon then
						floorY = drifted;
						landing, grounded = solveLandingTime(targetRootPosition.Y, floorY + playerHeight, targetVelocity.Y, playerGravity);
					end;
				end;
			end;

			if climbStep and targetAirborne and motion.state.jumpBase then
				local raised: number = motion.state.jumpBase + climbStep - playerHeight;
				local rising: number = math.max(targetVelocity.Y, 0);
				if floorY < raised - climbStep * 0.5 and targetRootPosition.Y + rising * rising / (2 * playerGravity) >= raised + playerHeight then
					floorY = raised;
					landing, grounded = solveLandingTime(targetRootPosition.Y, floorY + playerHeight, targetVelocity.Y, playerGravity);
				end;
			end;

			if grounded then
				targetRootPosition = Vector3.new(targetRootPosition.X, floorY + playerHeight, targetRootPosition.Z);
				targetPosition = targetRootPosition + targetOffset;
				targetVelocity = Vector3.new(targetVelocity.X, 0, targetVelocity.Z);
				targetAcceleration = Vector3.zero;
				if jumpVelocity then
					groundY = floorY + playerHeight + targetOffset.Y;
					landingTime = 0;
				end;
			else
				groundY = floorY + playerHeight + targetOffset.Y;
				landingTime = landing;
			end;
		end;
	end;

	if groundY and (jumpVelocity or targetAirborne) and not motion.flying then
		groundY += coverLift - targetOffset.Y;
		jumpVelocity = nil;
	end;

	local latency: number = prediction.getLatency() + (motion.stale or 0);
	local projectileAcceleration: Vector3 = Vector3.new(0, -gravity, 0);
	local positionAtTime: ((number) -> Vector3)?;
	local time: number?;
	local pattern: any = motion.state and motion.state.pattern;
	local inputPath: any = not motion.knockback and not motion.flying and getInputPath(motion.state, workspace:GetServerTimeNow());
	if motion.knockback and motion.impulse and motion.knockbackBase then
		local basePosition: Vector3 = targetPosition;
		local baseVelocity: Vector3 = motion.knockbackBase;
		local impulse: Vector3 = motion.impulse;
		local decay: number = math.max(motion.decay or 1.8, epsilon);
		positionAtTime = function(value: number): Vector3
			local total: number = latency + value;
			local horizontalOffset: Vector3 = baseVelocity * total + impulse * ((1 - math.exp(-decay * total)) / decay);
			local vertical: number = landingTime and total >= landingTime
				and groundY
				or basePosition.Y + targetVelocity.Y * total + targetAcceleration.Y * (0.5 * total * total);
			return Vector3.new(basePosition.X + horizontalOffset.X, vertical, basePosition.Z + horizontalOffset.Z);
		end;
		time = solveMotionTime(origin, projectileSpeed, projectileAcceleration, positionAtTime, minimumTime);
	elseif motion.expectedImpulse and motion.expectedTime then
		local basePosition: Vector3 = targetPosition;
		local baseVelocity: Vector3 = horizontalVelocity;
		local impulse: Vector3 = motion.expectedImpulse;
		local decay: number = math.max(motion.decay or (targetAirborne and 1.8 or 3.5), epsilon);
		local impulseDelay: number = math.max(motion.expectedTime - workspace:GetServerTimeNow(), 0) + latency;
		local lift: number? = validNumber(motion.expectedLift) and motion.expectedLift > epsilon and motion.expectedLift or nil;
		positionAtTime = function(value: number): Vector3
			local total: number = latency + value;
			local horizontalOffset: Vector3 = baseVelocity * total;
			if total > impulseDelay then
				local since: number = total - impulseDelay;
				horizontalOffset += impulse * ((1 - math.exp(-decay * since)) / decay);
			end;
			local vertical: number = landingTime and total >= landingTime
				and groundY
				or basePosition.Y + targetVelocity.Y * total + targetAcceleration.Y * (0.5 * total * total);
			if lift and total > impulseDelay then
				local since: number = total - impulseDelay;
				vertical += math.max(lift * since - playerGravity * (0.5 * since * since), 0);
			end;
			return Vector3.new(basePosition.X + horizontalOffset.X, vertical, basePosition.Z + horizontalOffset.Z);
		end;
		time = solveMotionTime(origin, projectileSpeed, projectileAcceleration, positionAtTime, minimumTime);
	elseif inputPath then
		positionAtTime = function(value: number): Vector3
			local total: number = latency + value;
			local offset: Vector3 = inputDisplacement(inputPath, total);
			local vertical: number;
			if landingTime and groundY and total >= landingTime then
				vertical = groundY;
			else
				vertical = targetPosition.Y + targetVelocity.Y * total + targetAcceleration.Y * (0.5 * total * total);
				if groundY then
					vertical = math.max(vertical, groundY - 1);
				end;
			end;
			return Vector3.new(targetPosition.X + offset.X, vertical, targetPosition.Z + offset.Z);
		end;
		leadConfidence = 1;
		time = solveMotionTime(origin, projectileSpeed, projectileAcceleration, positionAtTime, minimumTime);
	elseif pattern and pattern.period and (pattern.seen or 0) >= 2 then
		local phase: number = math.max(workspace:GetServerTimeNow() - pattern.time, 0);
		local previous: Vector3 = patternDisplacement(pattern, phase);
		positionAtTime = function(value: number): Vector3
			local total: number = latency + value;
			local offset: Vector3 = patternDisplacement(pattern, phase + total) - previous;
			local vertical: number;
			if landingTime and groundY and total >= landingTime then
				vertical = groundY;
			else
				vertical = targetPosition.Y + targetVelocity.Y * total + targetAcceleration.Y * (0.5 * total * total);
			end;
			return Vector3.new(targetPosition.X + offset.X, vertical, targetPosition.Z + offset.Z);
		end;
		leadConfidence = 1;
		time = solveMotionTime(origin, projectileSpeed, projectileAcceleration, positionAtTime, minimumTime);
	elseif strafeHalf then
		local basePosition: Vector3 = targetPosition;
		local baseVertical: number = targetVelocity.Y;
		local horizontal: Vector3 = strafeVelocity;
		local half: any, remaining: number = strafeHalf, strafeRemaining;
		positionAtTime = function(value: number): Vector3
			local total: number = latency + value;
			local offset: Vector3 = horizontal * strafeDisplacement(total, remaining, half);
			local vertical: number;
			if landingTime and groundY and total >= landingTime then
				vertical = groundY;
			else
				vertical = basePosition.Y + baseVertical * total + targetAcceleration.Y * (0.5 * total * total);
			end;
			return Vector3.new(basePosition.X + offset.X, vertical, basePosition.Z + offset.Z);
		end;
		time = solveMotionTime(origin, projectileSpeed, projectileAcceleration, positionAtTime, minimumTime);
	elseif turnRate then
		local basePosition: Vector3 = targetPosition;
		local baseVertical: number = targetVelocity.Y;
		local speedAlong: number = horizontalVelocity.Magnitude;
		local unit: Vector3 = horizontalVelocity.Unit;
		local normal: Vector3 = Vector3.new(-unit.Z, 0, unit.X);
		local radius: number = speedAlong / turnRate;
		local sweepLimit: number = math.min(2.6 / math.abs(turnRate), 0.1 * (motion.turnSeen or 4));
		positionAtTime = function(value: number): Vector3
			local total: number = latency + value;
			local swept: number = math.min(total, sweepLimit) * turnRate;
			local offset: Vector3 = unit * (radius * math.sin(swept)) + normal * (radius * (1 - math.cos(swept)));
			if total > sweepLimit then
				local heading: Vector3 = unit * math.cos(swept) + normal * math.sin(swept);
				offset += heading * (speedAlong * (total - sweepLimit));
			end;
			local vertical: number;
			if landingTime and groundY and total >= landingTime then
				vertical = groundY;
			else
				vertical = basePosition.Y + baseVertical * total + targetAcceleration.Y * (0.5 * total * total);
			end;
			return Vector3.new(basePosition.X + offset.X, vertical, basePosition.Z + offset.Z);
		end;
		time = solveMotionTime(origin, projectileSpeed, projectileAcceleration, positionAtTime, minimumTime);
	else
		if latency > epsilon then
			local horizontalTime: number = stopTime and math.min(latency, stopTime) or latency;
			local horizontalOffset: Vector3 = horizontalVelocity * horizontalTime + horizontalAcceleration * (0.5 * horizontalTime * horizontalTime);
			targetRootPosition += horizontalOffset;
			targetPosition += horizontalOffset;
			if stopTime and latency >= stopTime then
				targetVelocity = Vector3.new(0, targetVelocity.Y, 0);
				horizontalVelocity = Vector3.zero;
				horizontalAcceleration = Vector3.zero;
				stopTime = nil;
			else
				horizontalVelocity += horizontalAcceleration * latency;
				targetVelocity = Vector3.new(horizontalVelocity.X, targetVelocity.Y, horizontalVelocity.Z);
				if stopTime then
					stopTime -= latency;
				end;
			end;

			if landingTime and latency >= landingTime then
				targetPosition = Vector3.new(targetPosition.X, groundY, targetPosition.Z);
				targetVelocity = Vector3.new(targetVelocity.X, 0, targetVelocity.Z);
				targetAcceleration = Vector3.zero;
				landingTime = nil;
			else
				local verticalOffset: Vector3 = Vector3.new(0, targetVelocity.Y * latency + targetAcceleration.Y * (0.5 * latency * latency), 0);
				targetRootPosition += verticalOffset;
				targetPosition += verticalOffset;
				targetVelocity += Vector3.new(0, targetAcceleration.Y * latency, 0);
				if landingTime then
					landingTime -= latency;
				end;
			end;
		end;

		local displacement: Vector3 = targetPosition - origin;
		if displacement:Dot(displacement) <= epsilon then
			return targetPosition, targetPosition, 0;
		end;

		local relativeAcceleration: Vector3 = targetAcceleration - projectileAcceleration;
		if stopTime then
			positionAtTime = function(value: number): Vector3
				local horizontalTime: number = math.min(value, stopTime);
				local horizontalOffset: Vector3 = horizontalVelocity * horizontalTime + horizontalAcceleration * (0.5 * horizontalTime * horizontalTime);
				local vertical: number = landingTime and value >= landingTime
					and groundY
					or targetPosition.Y + targetVelocity.Y * value + targetAcceleration.Y * (0.5 * value * value);
				return Vector3.new(targetPosition.X + horizontalOffset.X, vertical, targetPosition.Z + horizontalOffset.Z);
			end;
			time = solveMotionTime(origin, projectileSpeed, projectileAcceleration, positionAtTime, minimumTime);
		else
			time = solveInterceptTime(displacement, targetVelocity, relativeAcceleration, projectileSpeed, minimumTime);
		end;
		if not positionAtTime and landingTime and (not time or time > landingTime) then
			local landedPosition: Vector3 = Vector3.new(targetPosition.X, groundY, targetPosition.Z);
			local landedVelocity: Vector3 = Vector3.new(targetVelocity.X, 0, targetVelocity.Z);
			time = solveInterceptTime(landedPosition - origin, landedVelocity, -projectileAcceleration, projectileSpeed, math.max(landingTime, minimumTime or 0));
		end;
	end;

	if time and validNumber(time) and time > epsilon then
		local futureTarget: Vector3;
		if positionAtTime then
			futureTarget = positionAtTime(time);
		elseif landingTime and time > landingTime then
			futureTarget = Vector3.new(
				targetPosition.X + targetVelocity.X * time,
				groundY,
				targetPosition.Z + targetVelocity.Z * time
			);
		else
			futureTarget = targetPosition + targetVelocity * time + targetAcceleration * (0.5 * time * time);
		end;
		local launchVelocity: Vector3 = (futureTarget - origin - projectileAcceleration * (0.5 * time * time)) / time;
		if floorLimit and validVector(futureTarget) and futureTarget.Y < floorLimit then
			futureTarget = Vector3.new(futureTarget.X, floorLimit, futureTarget.Z);
			local floorVelocity: any, floorTime: any = solveStaticLaunch(origin, futureTarget, projectileSpeed, projectileAcceleration);
			if floorVelocity and floorTime then
				launchVelocity, time = floorVelocity, floorTime;
			end;
		end;

		local confidence: number = leadConfidence;
		if confidence < 1 and validVector(futureTarget) then
			local present: Vector3 = positionAtTime and positionAtTime(0) or targetPosition;
			if not validVector(present) then
				present = targetPosition;
			end;
			local damped: Vector3 = Vector3.new(
				present.X + (futureTarget.X - present.X) * confidence,
				futureTarget.Y,
				present.Z + (futureTarget.Z - present.Z) * confidence
			);
			local dampedVelocity: any, dampedTime: any = solveStaticLaunch(origin, damped, projectileSpeed, projectileAcceleration);
			if dampedVelocity and dampedTime then
				futureTarget, launchVelocity, time = damped, dampedVelocity, dampedTime;
			end;
		end;
		local forecastTime: number = time;
		local bucket: number = time + latency < 0.3 and 1 or time + latency < 0.7 and 2 or 3;
		local candidates: {Vector3} = {
			futureTarget - targetOffset,
			observedPosition + observedVelocity * (latency + time) - targetOffset,
			observedPosition + observedVelocity * latency - targetOffset
		};
		local scores: any = motion.state and motion.state.scores and motion.state.scores[bucket];
		if scores and scores.count >= 5 and scores[1] > 1 and not strafeHalf and not inputPath and not motion.knockback and not motion.expectedImpulse and not (pattern and pattern.period and (pattern.seen or 0) >= 2) then
			local selected: number, loss: any = 1, scores[1] * 0.8;
			for i: number = 2, 3 do
				if scores[i] < loss then
					selected, loss = i, scores[i];
				end;
			end;
			if selected ~= 1 then
				local velocity: Vector3 = selected == 2 and observedVelocity * horizontalMask or Vector3.zero;
				local present: Vector3 = observedPosition + observedVelocity * latency;
				local alternative: (value: number) -> ...any = function(value: number): ...any
					local vertical: number;
					if positionAtTime then
						vertical = positionAtTime(value).Y;
					elseif landingTime and value >= landingTime then
						vertical = groundY;
					else
						vertical = targetPosition.Y + targetVelocity.Y * value + targetAcceleration.Y * (0.5 * value * value);
					end;
					local point: Vector3 = present + velocity * value;
					return Vector3.new(point.X, vertical, point.Z);
				end;
				local solved: number? = solveMotionTime(origin, projectileSpeed, projectileAcceleration, alternative, minimumTime);
				if solved then
					time = solved;
					futureTarget = alternative(time);
					launchVelocity = (futureTarget - origin - projectileAcceleration * (0.5 * time * time)) / time;
				end;
			end;
		end;
		if validVector(futureTarget)
			and validVector(launchVelocity)
			and math.abs(launchVelocity.Magnitude - projectileSpeed) < math.max(0.05, projectileSpeed * 0.002)
		then
			local state: any = motion.state;
			if state then
				local now: number = workspace:GetServerTimeNow();
				state.lastSolution = {
					['gravity'] = gravity,
					['impact'] = futureTarget,
					['origin'] = origin,
					['projectileSpeed'] = projectileSpeed,
					['targetPosition'] = solutionTargetPosition,
					['time'] = now,
					['travelTime'] = time,
					['velocity'] = launchVelocity
				};
				if now - (state.gradeTime or -math.huge) >= 0.1 then
					state.gradeTime = now;
					state.pending = state.pending or {};
					if #state.pending >= 16 then
						table.remove(state.pending, 1);
					end;
					table.insert(state.pending, {
						['arrival'] = now + forecastTime + latency,
						['horizon'] = forecastTime + latency,
						['position'] = candidates[1],
						['candidates'] = candidates,
						['bucket'] = bucket
					});
				end;
			end;
			return origin + launchVelocity, futureTarget, time;
		end;
	end;

	local lastSolution: any = motion.state and motion.state.lastSolution;
	if lastSolution
		and not motion.changed
		and not motion.knockback
		and workspace:GetServerTimeNow() - lastSolution.time < 0.08
		and math.abs(lastSolution.projectileSpeed - projectileSpeed) < 0.01
		and math.abs(lastSolution.gravity - gravity) < 0.01
		and (lastSolution.origin - origin).Magnitude < 4
		and (lastSolution.targetPosition - solutionTargetPosition).Magnitude < 6
	then
		return origin + lastSolution.velocity, lastSolution.impact, lastSolution.travelTime;
	end;

	if strict then
		return nil;
	end;
	return targetPosition, targetPosition;
end;

return prediction;