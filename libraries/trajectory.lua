local Prediction = {}
local Epsilon: number = 1e-9
local cloneref = cloneref or function(Reference: Instance)
    return Reference
end
local Players: Players = cloneref(game:GetService("Players"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))
local Stats: Stats = cloneref(game:GetService("Stats"))

local ResponseTime: number?

local function SampleRoundTrip()
    local Success, Ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if Success and type(Ping) == "number" and Ping > 0 then
        return Ping / 1000
    end
    return 0
end

function Prediction.setLatency(Value)
    if Value == nil then
        ResponseTime = nil
    elseif type(Value) == "number" and Value == Value and Value >= 0 and Value < math.huge then
        ResponseTime = Value
    end
end

local LatencyBias: number = 0

local function GetBaseLatency()
    if ResponseTime ~= nil then
        return ResponseTime
    end

    local Store = Prediction.Store
    if Store and Store.ping and Store.ping.total then
        return Store.ping.total
    end

    local Success, Ping = pcall(Players.LocalPlayer.GetNetworkPing, Players.LocalPlayer)
    if Success and type(Ping) == "number" and Ping >= 0 then
        return Ping * 2
    end
    return SampleRoundTrip()
end

function Prediction.getLatency()
    return math.max(GetBaseLatency() + LatencyBias, 0)
end

function Prediction.getRawLatency()
    return GetBaseLatency()
end

function Prediction.Raycast(Origin: Vector3, Direction: Vector3, Params: RaycastParams?)
    return workspace:Raycast(Origin, Direction, Params)
end

Prediction.IsTrajectoryClear = function(Origin: Vector3, Velocity: Vector3, Gravity: number, TravelTime: number, Params: RaycastParams, Target: Instance?, Ignored: ((Instance) -> boolean)?)
    local RayParams: RaycastParams = RaycastParams.new()
    RayParams.FilterType = Params.FilterType
    RayParams.FilterDescendantsInstances = Params.FilterDescendantsInstances
    RayParams.IgnoreWater = Params.IgnoreWater
    RayParams.CollisionGroup = Params.CollisionGroup
    RayParams.RespectCanCollide = Params.RespectCanCollide
    local LastPosition: Vector3 = Origin
    for Step: number = 1, 10 do
        local Time: number = TravelTime * (Step / 10)
        local Position: Vector3 = Origin + Velocity * Time + Vector3.new(0, -Gravity * 0.5 * Time * Time, 0)
        local Direction: Vector3 = Position - LastPosition
        local Hit: RaycastResult? = Prediction.Raycast(LastPosition, Direction, RayParams)
        local IgnoredHits: number = 0
        while Hit do
            IgnoredHits += 1
            if IgnoredHits > 64 then
                return false, Hit
            end
            if Target and Hit.Instance:IsDescendantOf(Target) then
                return true
            end
            if not Ignored or not Ignored(Hit.Instance) then
                return false, Hit
            end
            RayParams:AddToFilter(Hit.Instance)
            Hit = Prediction.Raycast(LastPosition, Direction, RayParams)
        end
        LastPosition = Position
    end
    return true
end

local Tracer: Part = Instance.new("Part")
Tracer.Anchored = true
Tracer.CanCollide = false
Tracer.CanQuery = false
Tracer.CanTouch = false
Tracer.CastShadow = false

local IsZero = function(Value: number)
    return (Value > -Epsilon and Value < Epsilon)
end
local CubeRoot = function(Value: number)
    return (Value > 0) and math.pow(Value, (1 / 3)) or -math.pow(math.abs(Value), (1 / 3))
end
local SolveQuadric = function(C0: number, C1: number, C2: number)
    local S0, S1
    if IsZero(C0) then
        return not IsZero(C1) and -C2 / C1 or nil
    end

    local P, Q, D

    P = C1 / (2 * C0)
    Q = C2 / C0
    D = P * P - Q

    if IsZero(D) then
        S0 = -P
        return S0
    elseif (D < 0) then
        return
    else
        local SqrtD: number = math.sqrt(D)

        S0 = SqrtD - P
        S1 = -SqrtD - P
        return S0, S1
    end
end
local SolveCubic = function(C0: number, C1: number, C2: number, C3: number)
    local S0, S1, S2
    if IsZero(C0) then
        return SolveQuadric(C1, C2, C3)
    end

    local Count, Offset
    local A, B, C
    local SquareA, P, Q
    local CubeP, D

    A = C1 / C0
    B = C2 / C0
    C = C3 / C0

    SquareA = A * A
    P = (1 / 3) * (-(1 / 3) * SquareA + B)
    Q = 0.5 * ((2 / 27) * A * SquareA - (1 / 3) * A * B + C)

    CubeP = P * P * P
    D = Q * Q + CubeP

    if IsZero(D) then
        if IsZero(Q) then
            S0 = 0
            Count = 1
        else
            local U: number = CubeRoot(-Q)
            S0 = 2 * U
            S1 = -U
            Count = 2
        end
    elseif (D < 0) then
        local Phi: number = (1 / 3) * math.acos(math.clamp(-Q / math.sqrt(-CubeP), -1, 1))
        local T: number = 2 * math.sqrt(-P)

        S0 = T * math.cos(Phi)
        S1 = -T * math.cos(Phi + math.pi / 3)
        S2 = -T * math.cos(Phi - math.pi / 3)
        Count = 3
    else
        local SqrtD: number = math.sqrt(D)
        local U: number = CubeRoot(SqrtD - Q)
        local V: number = -CubeRoot(SqrtD + Q)

        S0 = U + V
        Count = 1
    end

    Offset = (1 / 3) * A

    if (Count > 0) then
        S0 = S0 - Offset
    end
    if (Count > 1) then
        S1 = S1 - Offset
    end
    if (Count > 2) then
        S2 = S2 - Offset
    end

    return S0, S1, S2
end
function Prediction.solveQuartic(C0: number, C1: number, C2: number, C3: number, C4: number)
    local S0, S1, S2, S3
    if IsZero(C0) then
        local Root0, Root1, Root2 = SolveCubic(C1, C2, C3, C4)
        local Cubic: {number} = {}
        if Root0 then
            table.insert(Cubic, Root0)
        end
        if Root1 then
            table.insert(Cubic, Root1)
        end
        if Root2 then
            table.insert(Cubic, Root2)
        end
        return Cubic
    end

    local Coefficients: {[number]: number} = {}
    local Z, U, V, Offset
    local A, B, C, D
    local SquareA, P, Q, R
    local Count: number

    A = C1 / C0
    B = C2 / C0
    C = C3 / C0
    D = C4 / C0

    SquareA = A * A
    P = -0.375 * SquareA + B
    Q = 0.125 * SquareA * A - 0.5 * A * B + C
    R = -(3 / 256) * SquareA * SquareA + 0.0625 * SquareA * B - 0.25 * A * C + D

    if IsZero(R) then
        Coefficients[3] = Q
        Coefficients[2] = P
        Coefficients[1] = 0
        Coefficients[0] = 1

        S0, S1, S2 = SolveCubic(Coefficients[0], Coefficients[1], Coefficients[2], Coefficients[3])
        Count = (S0 and 1 or 0) + (S1 and 1 or 0) + (S2 and 1 or 0)
    else
        Coefficients[3] = 0.5 * R * P - 0.125 * Q * Q
        Coefficients[2] = -R
        Coefficients[1] = -0.5 * P
        Coefficients[0] = 1

        S0, S1, S2 = SolveCubic(Coefficients[0], Coefficients[1], Coefficients[2], Coefficients[3])
        Z = S0

        U = Z * Z - R
        V = 2 * Z - P

        if IsZero(U) then
            U = 0
        elseif (U > 0) then
            U = math.sqrt(U)
        else
            return
        end
        if IsZero(V) then
            V = 0
        elseif (V > 0) then
            V = math.sqrt(V)
        else
            return
        end

        Coefficients[2] = Z - U
        Coefficients[1] = Q < 0 and -V or V
        Coefficients[0] = 1

        S0, S1 = SolveQuadric(Coefficients[0], Coefficients[1], Coefficients[2])
        Count = (S0 and 1 or 0) + (S1 and 1 or 0)

        Coefficients[2] = Z + U
        Coefficients[1] = Q < 0 and V or -V
        Coefficients[0] = 1

        if (Count == 0) then
            local Root0, Root1 = SolveQuadric(Coefficients[0], Coefficients[1], Coefficients[2])
            Count = Count + (Root0 and 1 or 0) + (Root1 and 1 or 0)
            S0, S1 = Root0, Root1
        end
        if (Count == 1) then
            local Root0, Root1 = SolveQuadric(Coefficients[0], Coefficients[1], Coefficients[2])
            Count = Count + (Root0 and 1 or 0) + (Root1 and 1 or 0)
            S1, S2 = Root0, Root1
        end
        if (Count == 2) then
            local Root0, Root1 = SolveQuadric(Coefficients[0], Coefficients[1], Coefficients[2])
            Count = Count + (Root0 and 1 or 0) + (Root1 and 1 or 0)
            S2, S3 = Root0, Root1
        end
    end

    Offset = 0.25 * A

    local Roots: {number} = {}
    if (Count > 3) then
        table.insert(Roots, S3 - Offset)
    end
    if (Count > 2) then
        table.insert(Roots, S2 - Offset)
    end
    if (Count > 1) then
        table.insert(Roots, S1 - Offset)
    end
    if (Count > 0) then
        table.insert(Roots, S0 - Offset)
    end

    return Roots
end

Prediction.SpawnTracer = function(From: Vector3, To: Vector3, Custom)
    local Distance: number = (To - From).Magnitude
    if Distance < 0.01 then
        return
    end

    local Segment: Part = Tracer:Clone()
    Segment.Color = Custom.Color
    Segment.Size = vector.create(Custom.Thick, Custom.Thick, Distance)
    Segment.CFrame = CFrame.lookAt(From, To) * CFrame.new(0, 0, -Distance / 2)
    Segment.Material = Custom.Material
    Segment.Transparency = Custom.Opacity or 0

    if Custom.Fade then
        TweenService:Create(Segment, TweenInfo.new(Custom.Lifetime), {
            Transparency = 1
        }):Play()
    end
    return Segment
end
Prediction.SpawnArcTracer = function(Origin: Vector3, AimDirection: Vector3, ProjectileSpeed: number, Gravity: number, TravelTime: number, Steps: number?, Custom)
    Steps = Steps or 20
    local StepTime: number = TravelTime / Steps
    local GravityVector: Vector3 = Vector3.new(0, -Gravity, 0)
    local Velocity: Vector3 = AimDirection * ProjectileSpeed

    local PreviousPosition: Vector3 = Origin
    local Model: Model = Instance.new("Model")
    if Custom.Material == Enum.Material.Glass then
        Instance.new("Highlight", Model).Enabled = false
    end
    for Step: number = 1, Steps do
        local Time: number = Step * StepTime
        local NextPosition: Vector3 = Origin + Velocity * Time + 0.5 * GravityVector * Time * Time
        local Segment: Part? = Prediction.SpawnTracer(PreviousPosition, NextPosition, Custom)
        if Segment then
            Segment.Parent = Model
        end
        PreviousPosition = NextPosition
    end

    Model.Parent = workspace.Terrain
    task.delay(Custom.Lifetime, Model.Destroy, Model)
end

local UpdatePattern, UpdateInputs
local ValidNumber = function(Value)
    return type(Value) == "number" and Value == Value and math.abs(Value) < math.huge
end

local HorizontalMask: Vector3 = Vector3.new(1, 0, 1)
local TargetMotion = setmetatable({}, {__mode = "k"})
local ValidVector = function(Value)
    return typeof(Value) == "Vector3"
        and ValidNumber(Value.X)
        and ValidNumber(Value.Y)
        and ValidNumber(Value.Z)
end

local function GetAttribute(Root: Instance?, Attribute: string)
    local Character: Instance? = Root and Root.Parent
    if Character and Character:IsA("Model") then
        return Character:GetAttribute(Attribute)
    end
end

local function ResetMotion(Root: BasePart, State, Position: Vector3, Velocity: Vector3, Time: number, SpawnTime)
    local KnockbackMark = State.knockbackMark
    local KnockbackMultiplier = State.knockbackMultiplier
    local JumpVelocity = State.jumpVelocity
    table.clear(State)
    State.jumpVelocity = JumpVelocity
    State.assembly = Velocity
    State.damageTime = GetAttribute(Root, "LastDamageTakenTime")
    State.knockbackMark = KnockbackMark
    State.knockbackMultiplier = KnockbackMultiplier
    State.position = Position
    State.samples = {{position = Position, time = Time}}
    State.spawnTime = SpawnTime
    State.stableVelocity = Velocity
    State.time = Time
    State.velocity = Velocity
    TargetMotion[Root] = State
    return State
end

function Prediction.markKnockback(Target, Multiplier, Impulse)
    if typeof(Target) ~= "Instance" then
        return
    end

    local Root = Target:IsA("BasePart") and Target or Target:IsA("Model") and Target.PrimaryPart
    if not Root then
        return
    end

    local State = TargetMotion[Root] or {}
    State.knockbackMark = workspace:GetServerTimeNow()
    State.knockbackMultiplier = Multiplier
    if ValidVector(Impulse) then
        local Horizontal: Vector3 = Impulse * HorizontalMask
        State.knockbackHint = Horizontal.Magnitude > Epsilon and Horizontal or nil
        State.knockbackHintTime = State.knockbackMark
    end
    State.expectedImpulse = nil
    State.expectedLift = nil
    State.expectedTime = nil
    TargetMotion[Root] = State
end

function Prediction.expectKnockback(Target, Arrival, Impulse, Multiplier)
    if typeof(Target) ~= "Instance" then
        return
    end

    local Root = Target:IsA("BasePart") and Target or Target:IsA("Model") and Target.PrimaryPart
    if not Root or not ValidNumber(Arrival) or not ValidVector(Impulse) then
        return
    end

    local Horizontal: Vector3 = Impulse * HorizontalMask
    if Horizontal.Magnitude <= Epsilon and math.abs(Impulse.Y) <= Epsilon then
        return
    end

    local State = TargetMotion[Root] or {}
    State.expectedImpulse = Horizontal
    State.expectedLift = Impulse.Y
    State.expectedTime = Arrival
    State.expectedMultiplier = Multiplier
    TargetMotion[Root] = State
end

local PendingShots = {}
local ResidualSpread, ResidualSamples = 0, 0
local EpochHits, EpochShots, EpochRate = 0, 0, nil
local StepDirection, StepSize = 1, 0.008

local function ApplyEpoch()
    if EpochShots < 12 then
        return
    end

    local Rate: number = EpochHits / EpochShots
    EpochHits, EpochShots = 0, 0
    if EpochRate and Rate + 0.02 < EpochRate then
        StepDirection = -StepDirection
        StepSize = math.max(StepSize * 0.7, 0.002)
    end
    EpochRate = Rate
    if Rate >= 0.95 then
        return
    end
    LatencyBias = math.clamp(LatencyBias + StepDirection * StepSize, -0.12, 0.12)
end

local function MeasureSpread(Shot)
    local Root = Shot.root
    if typeof(Root) ~= "Instance" or not Root.Parent then
        return
    end

    local State = TargetMotion[Root]
    if not State or State.spawnTime ~= Shot.spawnTime then
        return
    end
    if State.knockbackUntil and State.knockbackUntil > Shot.fireTime then
        return
    end

    local Residual: Vector3 = (Root.Position - Shot.impact) * HorizontalMask
    if not ValidVector(Residual) or Residual.Magnitude > 30 then
        return
    end

    local Cross: number = (Residual - Shot.direction * Residual:Dot(Shot.direction)).Magnitude
    ResidualSpread = ResidualSpread + (Cross - ResidualSpread) * 0.2
    ResidualSamples = math.min(ResidualSamples + 1, 400)
end

local function ResolveShots()
    if #PendingShots == 0 then
        return
    end
    local Now: number = workspace:GetServerTimeNow()

    for i: number = #PendingShots, 1, -1 do
        local Shot = PendingShots[i]
        if not Shot.measured and Now >= Shot.dueTime then
            Shot.measured = true
            MeasureSpread(Shot)
        end
        if Now > Shot.dueTime + 0.35 then
            table.remove(PendingShots, i)
            EpochShots += 1
            ApplyEpoch()
        end
    end
end

function Prediction.trackShot(TargetRoot)
    if typeof(TargetRoot) ~= "Instance" then
        return
    end

    local State = TargetMotion[TargetRoot]
    local Solution = State and State.lastSolution
    if not Solution or not ValidNumber(Solution.travelTime) or not ValidVector(Solution.impact) then
        return
    end

    local Velocity: Vector3 = (State.velocity or Vector3.zero) * HorizontalMask
    if Velocity.Magnitude < 8 then
        return
    end

    if #PendingShots >= 24 then
        table.remove(PendingShots, 1)
    end
    table.insert(PendingShots, {
        direction = Velocity.Unit,
        dueTime = Solution.time + Solution.travelTime,
        fireTime = Solution.time,
        impact = Solution.impact,
        root = TargetRoot,
        spawnTime = State.spawnTime,
        speed = Velocity.Magnitude
    })
end

function Prediction.reportHit(TargetRoot)
    if typeof(TargetRoot) ~= "Instance" then
        return
    end

    local Now: number = workspace:GetServerTimeNow()
    for i: number = #PendingShots, 1, -1 do
        local Shot = PendingShots[i]
        if Shot.root == TargetRoot and Now >= Shot.dueTime - 0.35 and Now <= Shot.dueTime + 0.35 then
            if not Shot.measured then
                Shot.measured = true
                MeasureSpread(Shot)
            end
            table.remove(PendingShots, i)
            EpochHits += 1
            EpochShots += 1
            ApplyEpoch()
            return
        end
    end
end

function Prediction.getResidualSpread()
    return ResidualSpread, ResidualSamples
end

function Prediction.getLatencyBias()
    return LatencyBias, EpochRate
end

local WorldFilter
local LearnedParams: RaycastParams = RaycastParams.new()
LearnedParams.FilterType = Enum.RaycastFilterType.Include
local ExcludeParams: RaycastParams = RaycastParams.new()
ExcludeParams.FilterType = Enum.RaycastFilterType.Exclude
ExcludeParams.IgnoreWater = true
ExcludeParams.RespectCanCollide = true
local ExcludeList, ExcludeTime = {}, 0

local CastFloor = function(Position: Vector3, Params: RaycastParams)
    return Prediction.Raycast(Position, Vector3.new(0, workspace.FallenPartsDestroyHeight - Position.Y, 0), Params)
end

local function RefreshExcludeList(Root: Instance?)
    local Time: number = os.clock()
    if Time - ExcludeTime > 1 then
        ExcludeTime = Time
        table.clear(ExcludeList)
        for _, Player: Player in Players:GetPlayers() do
            if Player.Character then
                table.insert(ExcludeList, Player.Character)
            end
        end
    end

    local Character: Instance? = Root and Root.Parent
    if Character and not table.find(ExcludeList, Character) then
        table.insert(ExcludeList, Character)
    end
    return ExcludeList
end

local TraceFloor = function(Position: Vector3, Params: RaycastParams?, Root: Instance?)
    local Character: Instance? = Root and Root.Parent
    if Params then
        local Result: RaycastResult? = CastFloor(Position, Params)
        if Result and not (Character and Result.Instance:IsDescendantOf(Character)) then
            if Params.FilterType == Enum.RaycastFilterType.Include then
                WorldFilter = Params.FilterDescendantsInstances
            end
            return Result.Position.Y
        end
    end

    if WorldFilter and #WorldFilter > 0 then
        LearnedParams.FilterDescendantsInstances = WorldFilter
        local Result: RaycastResult? = CastFloor(Position, LearnedParams)
        if Result then
            return Result.Position.Y
        end
    end

    ExcludeParams.FilterDescendantsInstances = RefreshExcludeList(Root)
    local Result: RaycastResult? = CastFloor(Position, ExcludeParams)
    return Result and Result.Position.Y or nil
end

local GetTargetMotion = function(Root: BasePart?, Position: Vector3, Velocity: Vector3, Airborne: boolean?, PlayerGravity: number?)
    if not Root or not ValidVector(Position) or not ValidVector(Velocity) then
        return {
            acceleration = Vector3.zero,
            position = Position,
            velocity = Velocity
        }
    end

    local Time: number = workspace:GetServerTimeNow()
    local SpawnTime = GetAttribute(Root, "SpawnTime")
    local State = TargetMotion[Root] or {}
    if State.time and Time - State.time < 1 / 240 then
        local Knockback = State.knockbackUntil and Time < State.knockbackUntil
        return {
            acceleration = State.acceleration or Vector3.zero,
            decay = State.knockbackDecay,
            flying = State.flying,
            invalid = State.pendingPosition ~= nil,
            impulse = Knockback and State.knockbackImpulse,
            knockback = Knockback,
            knockbackBase = Knockback and State.knockbackBase,
            expectedImpulse = State.expectedImpulse,
            expectedLift = State.expectedLift,
            expectedTime = State.expectedTime,
            missRate = State.missRate,
            position = State.position,
            state = State,
            stale = State.updateTime and math.clamp(Time - State.updateTime, 0, 0.2) or nil,
            strafeElapsed = State.strafeReversal and Time - State.strafeReversal or nil,
            strafeHalf = State.strafeHalf,
            strafeSeen = State.strafeSeen,
            strafeSpeed = State.strafeSpeed,
            strafeDirection = State.strafeDirection,
            turnRate = State.turnRate,
            turnSeen = State.turnSeen,
            velocity = State.velocity
        }
    end
    if not State.time or Time - State.time > 0.75 or State.spawnTime ~= SpawnTime then
        State = ResetMotion(Root, State, Position, Velocity, Time, SpawnTime)
        return {
            acceleration = Vector3.zero,
            position = Position,
            state = State,
            velocity = Velocity
        }
    end

    local Delta: number = Time - State.time
    if Delta <= Epsilon then
        return {
            acceleration = Vector3.zero,
            flying = State.flying,
            position = State.position,
            state = State,
            velocity = State.velocity
        }
    end
    local Displacement: Vector3 = Position - State.position
    local InstantVelocity: Vector3 = Displacement / Delta
    local AssemblyAgreement: boolean = Velocity.Magnitude > 5
        and InstantVelocity.Magnitude > 5
        and Velocity.Unit:Dot(InstantVelocity.Unit) > 0.75
        and math.abs(Velocity.Magnitude - InstantVelocity.Magnitude) < math.max(40, Velocity.Magnitude * 0.75)
    if State.pendingPosition then
        if (Position - State.position).Magnitude < 2 then
            State.pendingPosition = nil
            State.pendingTime = nil
        elseif (Position - State.pendingPosition).Magnitude < 2 then
            State = ResetMotion(Root, State, Position, Velocity, Time, SpawnTime)
            return {
                acceleration = Vector3.zero,
                changed = true,
                position = Position,
                state = State,
                velocity = Velocity
            }
        else
            State.pendingPosition = nil
            State.pendingTime = nil
        end
    end

    local DisplacementLimit: number = math.max(12, (math.max(State.velocity.Magnitude, Velocity.Magnitude) + 30) * Delta * 1.5)
    if (Displacement.Magnitude > DisplacementLimit or InstantVelocity.Magnitude > 260) and not AssemblyAgreement then
        State.pendingPosition = Position
        State.pendingTime = Time
        State.time = Time
        return {
            acceleration = Vector3.zero,
            flying = State.flying,
            invalid = true,
            position = State.position,
            state = State,
            velocity = State.velocity
        }
    end

    local Samples = State.samples
    table.insert(Samples, {position = Position, time = Time})
    while #Samples > 6 or (#Samples > 2 and Time - Samples[1].time > 0.14) do
        table.remove(Samples, 1)
    end

    local MeasuredVelocity: Vector3?
    local Oldest = Samples[1]
    if Oldest and Time - Oldest.time > 0.02 then
        MeasuredVelocity = (Position - Oldest.position) / (Time - Oldest.time)
        if not ValidVector(MeasuredVelocity) or MeasuredVelocity.Magnitude > 260 then
            MeasuredVelocity = nil
        end
    end

    local RecentVelocity: Vector3?
    local PreviousSample = Samples[#Samples - 1]
    if PreviousSample and Time - PreviousSample.time > Epsilon then
        RecentVelocity = (Position - PreviousSample.position) / (Time - PreviousSample.time)
        if not ValidVector(RecentVelocity) or RecentVelocity.Magnitude > 260 then
            RecentVelocity = nil
        end
    end

    local DamageTime = GetAttribute(Root, "LastDamageTakenTime")
    local DamageChanged: boolean = ValidNumber(DamageTime) and DamageTime > 0 and DamageTime ~= State.damageTime
    local Marked: boolean = Time - (State.knockbackMark or -math.huge) < 0.25
    local VelocityChange: Vector3 = Velocity - State.assembly
    local MeasuredAgreement = MeasuredVelocity
        and MeasuredVelocity.Magnitude > 5
        and Velocity.Magnitude > 5
        and MeasuredVelocity.Unit:Dot(Velocity.Unit) > 0.7
        and (MeasuredVelocity - Velocity).Magnitude < math.max(35, Velocity.Magnitude * 0.6)
    local VelocityInvalid: boolean = (VelocityChange.Magnitude > math.max(70, State.velocity.Magnitude * 2 + 35) or Velocity.Magnitude > 260)
        and not Marked
        and not DamageChanged
        and not MeasuredAgreement
    if VelocityInvalid then
        local Candidate = State.velocityCandidate
        if Candidate and Time - State.velocityCandidateTime < 0.12 and (Candidate - Velocity).Magnitude < math.max(12, Velocity.Magnitude * 0.2) then
            State.velocityCandidate = nil
            State.velocityCandidateTime = nil
        else
            State.velocityCandidate = Velocity
            State.velocityCandidateTime = Time
            Velocity = State.assembly
        end
    else
        State.velocityCandidate = nil
        State.velocityCandidateTime = nil
    end

    local AssemblyHorizontal: Vector3 = Velocity * HorizontalMask
    local MeasuredHorizontal: Vector3? = MeasuredVelocity and MeasuredVelocity * HorizontalMask
    local HorizontalVelocity: Vector3 = AssemblyHorizontal
    local MeasuredAccepted: boolean?
    if MeasuredHorizontal then
        local Difference: number = (MeasuredHorizontal - AssemblyHorizontal).Magnitude
        if Difference < math.max(6, AssemblyHorizontal.Magnitude * 0.35) then
            HorizontalVelocity = AssemblyHorizontal:Lerp(MeasuredHorizontal, 0.15)
            MeasuredAccepted = true
        elseif AssemblyHorizontal.Magnitude < 2 and MeasuredHorizontal.Magnitude > 2 then
            local Candidate = State.measuredCandidate
            local Consistent = Candidate
                and Time - State.measuredCandidateTime < 0.15
                and Candidate.Magnitude > Epsilon
                and MeasuredHorizontal.Magnitude > Epsilon
                and Candidate.Unit:Dot(MeasuredHorizontal.Unit) > 0.8
                and math.abs(Candidate.Magnitude - MeasuredHorizontal.Magnitude) < math.max(12, MeasuredHorizontal.Magnitude * 0.35)
            if MeasuredHorizontal.Magnitude < 45 or Consistent then
                HorizontalVelocity = MeasuredHorizontal
                MeasuredAccepted = true
                State.measuredCandidate = nil
                State.measuredCandidateTime = nil
            else
                State.measuredCandidate = MeasuredHorizontal
                State.measuredCandidateTime = Time
                HorizontalVelocity = State.velocity * HorizontalMask
            end
        else
            State.measuredCandidate = nil
            State.measuredCandidateTime = nil
        end
    end

    local VerticalVelocity: number = Velocity.Y
    if MeasuredAccepted and MeasuredVelocity then
        if math.abs(VerticalVelocity - MeasuredVelocity.Y) < 8 then
            VerticalVelocity = VerticalVelocity + (MeasuredVelocity.Y - VerticalVelocity) * 0.15
        elseif RecentVelocity and math.abs(VerticalVelocity) < 1 and (State.flying or math.abs(RecentVelocity.Y) < 45) then
            VerticalVelocity = RecentVelocity.Y
        end
    end
    if not Airborne and math.abs(VerticalVelocity) < 2 then
        VerticalVelocity = 0
    end

    local CombinedVelocity: Vector3 = Vector3.new(HorizontalVelocity.X, VerticalVelocity, HorizontalVelocity.Z)
    local PreviousVelocity: Vector3 = State.velocity
    local Difference: number = (CombinedVelocity - PreviousVelocity).Magnitude
    local PreviousHorizontal: Vector3 = PreviousVelocity * HorizontalMask
    local DirectionChanged: boolean = HorizontalVelocity.Magnitude > 2
        and PreviousHorizontal.Magnitude > 2
        and HorizontalVelocity.Unit:Dot(PreviousHorizontal.Unit) < 0.65
    local Shift: number = Difference / math.max(PreviousVelocity.Magnitude * 0.35, 7)
    local Changed: boolean = Shift >= 1 or DirectionChanged
    local CurrentVelocity: Vector3
    if Changed then
        CurrentVelocity = CombinedVelocity
    else
        local Alpha: number = math.clamp(Delta * 20, 0.2, 1)
        CurrentVelocity = PreviousVelocity:Lerp(CombinedVelocity, Alpha + (1 - Alpha) * Shift * Shift)
    end

    local Humanoid: Humanoid? = Root.Parent and Root.Parent:FindFirstChildWhichIsA("Humanoid")
    local HumanoidState = Humanoid and Humanoid:GetState()
    State.leaping = HumanoidState == Enum.HumanoidStateType.Jumping or HumanoidState == Enum.HumanoidStateType.Freefall
    local ImpulseChange: Vector3 = (CurrentVelocity - PreviousVelocity) * HorizontalMask
    local KnockbackStarted: boolean = (Marked or DamageChanged)
        and (ImpulseChange.Magnitude > 1.5 or math.abs(CurrentVelocity.Y - PreviousVelocity.Y) > 1.5)
    if not KnockbackStarted and Humanoid and Humanoid.PlatformStand then
        KnockbackStarted = ImpulseChange.Magnitude > 5 or math.abs(CurrentVelocity.Y - PreviousVelocity.Y) > 5
    end

    if State.expectedTime then
        if KnockbackStarted or Time > State.expectedTime + 0.35 then
            State.expectedImpulse, State.expectedTime, State.expectedMultiplier, State.expectedLift = nil, nil, nil, nil
        elseif Time >= State.expectedTime then
            State.knockbackHint = State.expectedImpulse
            State.knockbackHintTime = Time
            State.knockbackMark = Time
            State.knockbackMultiplier = State.expectedMultiplier
            State.expectedImpulse, State.expectedTime, State.expectedMultiplier, State.expectedLift = nil, nil, nil, nil
        end
    end

    local Hint = State.knockbackHint
    if Hint and Time - (State.knockbackHintTime or -math.huge) > 0.25 then
        Hint, State.knockbackHint, State.knockbackHintTime = nil, nil, nil
    end
    if Hint and not KnockbackStarted and not State.knockbackUntil then
        KnockbackStarted = true
    end
    if KnockbackStarted then
        State.knockbackBase = State.stableVelocity * HorizontalMask
        State.knockbackDecay = Airborne and 1.8 or 3.5
        State.knockbackSeed = Hint
        State.knockbackStart = Time
        State.knockbackUntil = Time + 0.6
    end

    local Knockback = State.knockbackUntil and Time < State.knockbackUntil
    local KnockbackImpulse: Vector3?
    if Knockback then
        KnockbackImpulse = CurrentVelocity * HorizontalMask - State.knockbackBase
        local Seed = State.knockbackSeed
        if Seed and Time - State.knockbackStart < 0.12 and Seed.Magnitude > KnockbackImpulse.Magnitude then
            KnockbackImpulse = Seed
        end
        local PreviousImpulse = State.knockbackImpulse
        if PreviousImpulse
            and PreviousImpulse.Magnitude > 4
            and KnockbackImpulse.Magnitude > 4
            and PreviousImpulse.Unit:Dot(KnockbackImpulse.Unit) < 0.35
        then
            State.knockbackUntil = nil
            Knockback = false
        end
        if PreviousImpulse
            and Knockback
            and PreviousImpulse.Magnitude > 3
            and KnockbackImpulse.Magnitude > 3
            and PreviousImpulse.Unit:Dot(KnockbackImpulse.Unit) > 0.8
            and KnockbackImpulse.Magnitude < PreviousImpulse.Magnitude
        then
            local Decay: number = -math.log(KnockbackImpulse.Magnitude / PreviousImpulse.Magnitude) / Delta
            if ValidNumber(Decay) and Decay > 0 then
                State.knockbackDecay = State.knockbackDecay + (math.clamp(Decay, 0.75, 8) - State.knockbackDecay) * 0.35
            end
        end
        if KnockbackImpulse.Magnitude < 3 and Time - State.knockbackStart > 0.1 then
            State.knockbackSeed = nil
            State.knockbackUntil = nil
            Knockback = false
        else
            State.knockbackImpulse = KnockbackImpulse
        end
    end

    if Airborne then
        local VerticalChange: number = (CurrentVelocity.Y - PreviousVelocity.Y) / Delta
        if ValidNumber(VerticalChange) then
            State.verticalAcceleration = State.verticalAcceleration
                and State.verticalAcceleration + (VerticalChange - State.verticalAcceleration) * 0.25
                or VerticalChange
        end
        State.airTime = (State.airTime or 0) + Delta
        if State.airTime > 0.6 and State.verticalAcceleration and ValidNumber(PlayerGravity) and PlayerGravity > 0 then
            if State.verticalAcceleration > -PlayerGravity * 0.4 then
                local FloorY: number? = TraceFloor(Position, nil, Root)
                State.flying = FloorY and Position.Y - FloorY > 12 or false
            else
                State.flying = false
            end
        end
    else
        State.airTime = nil
        State.verticalAcceleration = nil
        State.flying = nil
    end

    local TakeoffBase: number = State.position.Y
    local MissedLanding: boolean?
    if Airborne and State.airborne and PreviousVelocity.Y <= 0 and CurrentVelocity.Y > 8 and not Knockback then
        local FloorY: number? = TraceFloor(Position, nil, Root)
        local Height: number = Humanoid and Humanoid.HipHeight + Root.Size.Y * 0.5 or 3
        if FloorY and Position.Y - FloorY <= Height + 3 then
            MissedLanding = true
            TakeoffBase = FloorY + Height
        end
    end
    if Airborne and (not State.airborne or MissedLanding) and CurrentVelocity.Y > 5 and not Knockback then
        local Takeoff: number = CurrentVelocity.Y
        local Reference: number = State.jumpVelocity or Takeoff
        if Takeoff < Reference * 1.5 and Takeoff > Reference * 0.5 then
            State.jumpVelocity = State.jumpVelocity and (State.jumpVelocity + (Takeoff - State.jumpVelocity) * 0.35) or Takeoff
            if State.jumpStart then
                local Period: number = Time - State.jumpStart
                local Rise: number? = State.jumpBase and TakeoffBase - State.jumpBase
                if Period > 0.15 and Period < 1.5 then
                    if State.jumpPeriod then
                        local Drift: number = math.abs(Period - State.jumpPeriod) / State.jumpPeriod
                        State.jumpDrift = State.jumpDrift and (State.jumpDrift + (Drift - State.jumpDrift) * 0.35) or Drift
                    end
                    State.jumpPeriod = State.jumpPeriod and (State.jumpPeriod + (Period - State.jumpPeriod) * 0.35) or Period
                    State.jumpSeen = math.min((State.jumpSeen or 0) + 1, 6)
                else
                    State.jumpSeen, State.jumpPeriod = nil, nil
                end
                if Period > 0.15 and Period < 1.5 and Rise and Rise > 1 and Rise < 8 then
                    State.climbStep = State.climbStep and (State.climbStep + (Rise - State.climbStep) * 0.35) or Rise
                    State.climbSeen = math.min((State.climbSeen or 0) + 1, 6)
                else
                    State.climbStep, State.climbSeen = nil, nil
                end
            end
            State.jumpStart = Time
            State.jumpBase = TakeoffBase
        elseif not State.jumpVelocity then
            State.jumpVelocity = Takeoff
            State.jumpStart = Time
            State.jumpBase = TakeoffBase
        end
    end
    State.airborne = Airborne
    if State.jumpPeriod and Time - (State.jumpStart or 0) > State.jumpPeriod + math.max(0.1, State.jumpPeriod * (State.jumpDrift or 0) * 2) then
        State.jumpPeriod, State.jumpSeen, State.climbStep, State.climbSeen = nil, nil, nil, nil
    end

    local StrafeHorizontal: Vector3 = CurrentVelocity * HorizontalMask
    if StrafeHorizontal.Magnitude > 4 and not Knockback then
        State.strafeSlow = nil
        State.strafeSpeed = State.strafeSpeed and (State.strafeSpeed + (StrafeHorizontal.Magnitude - State.strafeSpeed) * 0.2) or StrafeHorizontal.Magnitude
        local Unit: Vector3 = StrafeHorizontal.Unit
        local Previous: Vector3? = State.strafeDirection
        if Previous and math.abs(Unit:Dot(Previous)) < 0.65 then
            State.strafeHalf, State.strafeReversal, State.strafeSeen = nil, nil, nil
            State.strafeDirection = Unit
        elseif Previous and Unit:Dot(Previous) < -0.5 then
            local LastReversal: number? = State.strafeReversal
            if LastReversal then
                local Half: number = Time - LastReversal
                if Half > 0.08 and Half < 1.2 then
                    State.strafeHalf = State.strafeHalf and (State.strafeHalf + (Half - State.strafeHalf) * 0.35) or Half
                    State.strafeSeen = math.min((State.strafeSeen or 0) + 1, 6)
                end
            end
            State.strafeDirection = Unit
            State.strafeReversal = Time
        elseif not Previous or Unit:Dot(Previous) > 0.5 then
            State.strafeDirection = Unit
        end
    elseif StrafeHorizontal.Magnitude < 1 then
        State.strafeSlow = State.strafeSlow or Time
        if Time - State.strafeSlow > 0.2 then
            State.strafeDirection, State.strafeHalf, State.strafeSeen, State.strafeSpeed = nil, nil, nil, nil
        end
    end
    if State.strafeReversal and Time - State.strafeReversal > (State.strafeHalf and State.strafeHalf * 1.5 or 2.5) then
        State.strafeHalf, State.strafeReversal, State.strafeSeen, State.strafeSpeed = nil, nil, nil, nil
    end

    local PreviousTurn: Vector3? = State.turnUnit
    if StrafeHorizontal.Magnitude > 5 and not Knockback then
        local Unit: Vector3 = StrafeHorizontal.Unit
        if PreviousTurn and Delta > Epsilon then
            local Cross: number = PreviousTurn.X * Unit.Z - PreviousTurn.Z * Unit.X
            local Angle: number = math.atan2(Cross, math.clamp(PreviousTurn:Dot(Unit), -1, 1))
            if math.abs(Angle) < 1.4 then
                local Rate: number = Angle / Delta
                local Settled: number? = State.turnRate
                if Settled and Settled * Rate > 0 and math.abs(Rate) > 0.25 then
                    State.turnSeen = math.min((State.turnSeen or 0) + 1, 12)
                elseif math.abs(Rate) < 0.25 then
                    State.turnSeen = math.max((State.turnSeen or 0) - 1, 0)
                else
                    State.turnSeen = 0
                end
                State.turnRate = Settled and Settled + (Rate - Settled) * 0.3 or Rate
            else
                State.turnRate, State.turnSeen = nil, 0
            end
        end
        State.turnUnit = Unit
    else
        State.turnRate, State.turnSeen, State.turnUnit = nil, 0, nil
    end
    if State.strafeReversal and Time - State.strafeReversal < Delta * 1.5 then
        State.turnRate, State.turnSeen = nil, 0
    end

    if StrafeHorizontal.Magnitude > 4 then
        if Displacement.Magnitude > Epsilon then
            State.updateTime = Time
        end
    else
        State.updateTime = nil
    end

    local Pending = State.pending
    if Pending then
        while Pending[1] and Pending[1].arrival <= Time do
            local Entry = table.remove(Pending, 1)
            local Observed: Vector3 = State.position:Lerp(Position, math.clamp((Entry.arrival - State.time) / Delta, 0, 1))
            local Miss: number = ((Observed - Entry.position) * HorizontalMask).Magnitude / Entry.horizon
            if Entry.candidates then
                State.scores = State.scores or {}
                local Scores = State.scores[Entry.bucket] or {count = 0}
                for i: number, v: Vector3 in Entry.candidates do
                    local Difference: Vector3 = (Observed - v) * HorizontalMask
                    local Loss: number = math.min(Difference:Dot(Difference) / 9, 4)
                    Scores[i] = Scores[i] and Scores[i] + (Loss - Scores[i]) * 0.2 or Loss
                end
                Scores.count += 1
                State.scores[Entry.bucket] = Scores
            end
            if State.missRate then
                Miss = math.min(Miss, State.missRate * 1.5)
            end
            State.missRate = State.missRate and (State.missRate + (Miss - State.missRate) * 0.3) or Miss
        end
    end

    local Acceleration: Vector3 = Vector3.zero
    if not Knockback and HorizontalVelocity.Magnitude > 1 then
        local Change: Vector3 = (CurrentVelocity - PreviousVelocity) * HorizontalMask / Delta
        local Parallel: number = Change:Dot(HorizontalVelocity.Unit)
        local Perpendicular: number = (Change - HorizontalVelocity.Unit * Parallel).Magnitude
        if Parallel < -8 and Perpendicular < math.abs(Parallel) * 0.6 then
            Acceleration = HorizontalVelocity.Unit * math.max(Parallel, -400)
        end
    end

    if not Knockback then
        State.stableVelocity = CurrentVelocity
        State.knockbackImpulse = nil
    end
    State.assembly = Velocity
    State.acceleration = Acceleration
    State.damageTime = DamageTime
    State.position = Position
    State.time = Time
    State.velocity = CurrentVelocity
    UpdatePattern(State, Position, Time, Knockback)
    UpdateInputs(State, Humanoid, Time, CurrentVelocity * HorizontalMask, Knockback)
    return {
        acceleration = Acceleration,
        changed = Changed or KnockbackStarted,
        decay = State.knockbackDecay,
        flying = State.flying,
        impulse = Knockback and KnockbackImpulse,
        knockback = Knockback,
        knockbackBase = Knockback and State.knockbackBase,
        expectedImpulse = State.expectedImpulse,
        expectedLift = State.expectedLift,
        expectedTime = State.expectedTime,
        missRate = State.missRate,
        position = Position,
        state = State,
        stale = State.updateTime and math.clamp(Time - State.updateTime, 0, 0.2) or nil,
        strafeElapsed = State.strafeReversal and Time - State.strafeReversal or nil,
        strafeHalf = State.strafeHalf,
        strafeSeen = State.strafeSeen,
        strafeSpeed = State.strafeSpeed,
        strafeDirection = State.strafeDirection,
        turnRate = State.turnRate,
        turnSeen = State.turnSeen,
        velocity = CurrentVelocity
    }
end

local GradeSpeed, GradeGravity, GradeInterval = 240, 35, 0.1

function Prediction.Observe(Root, Position, Velocity, Airborne, PlayerGravity, Origin, PlayerHeight, PlayerJump)
    if typeof(Root) ~= "Instance" then
        return
    end

    local Motion = GetTargetMotion(Root, Position, Velocity, Airborne, PlayerGravity)
    local State = Motion.state
    if not State or not ValidVector(Origin) then
        return
    end

    local Now: number = workspace:GetServerTimeNow()
    if Now - (State.gradeTime or -math.huge) < GradeInterval then
        return
    end

    Prediction.SolveTrajectory(Origin, GradeSpeed, GradeGravity, Position, Velocity, PlayerGravity, PlayerHeight, PlayerJump, nil, Airborne, Position, Root, nil, true)
end

local PatternInterval: number = 1 / 30
local PatternVelocities: {Vector3} = {}

UpdatePattern = function(State, Position: Vector3, Time: number, Knockback)
    if Knockback then
        State.pattern = nil
        return
    end

    local Pattern = State.pattern
    if not Pattern or Time - Pattern.observed > 0.25 then
        State.pattern = {samples = {Position * HorizontalMask}, time = Time, observed = Time, position = Position}
        return
    end

    local Samples: {Vector3} = Pattern.samples
    local Elapsed: number = Time - Pattern.observed
    while Time - Pattern.time >= PatternInterval do
        Pattern.time += PatternInterval
        local Alpha: number = math.clamp((Pattern.time - Pattern.observed) / math.max(Elapsed, Epsilon), 0, 1)
        table.insert(Samples, Pattern.position:Lerp(Position, Alpha) * HorizontalMask)
        if #Samples > 128 then
            table.remove(Samples, 1)
        end
    end
    Pattern.observed, Pattern.position = Time, Position
    if Time - (Pattern.checked or 0) < 0.1 then
        return
    end
    Pattern.checked = Time

    local Count: number = #Samples
    for i: number = 3, Count do
        PatternVelocities[i] = (Samples[i] - Samples[i - 2]) / (PatternInterval * 2)
    end

    local Best, BestError, BestVariance
    for Period: number = 9, math.min(66, math.floor((Count - 3) / 2)) do
        local Span: number = math.min(Period, 30)
        local Error, Energy, Average = 0, 0, Vector3.zero
        for i: number = Count - Span + 1, Count do
            local Current: Vector3 = PatternVelocities[i]
            local Previous: Vector3 = PatternVelocities[i - Period]
            local Difference: Vector3 = Current - Previous
            Error += Difference:Dot(Difference)
            Energy += Current:Dot(Current)
            Average += Current
        end
        Average /= Span
        local Variance: number = Energy / Span - Average:Dot(Average)
        Error /= Span
        if Variance > 16 and Error < Variance * 0.12 and (not BestError or Error < BestError * 0.85) then
            Best, BestError, BestVariance = Period, Error, Variance
        end
    end

    if Best then
        local Current: Vector3 = (Samples[Count] - Samples[Count - 3]) / (PatternInterval * 3)
        local Previous: Vector3 = (Samples[Count - Best] - Samples[Count - Best - 3]) / (PatternInterval * 3)
        local Difference: Vector3 = Current - Previous
        if Difference:Dot(Difference) < math.max(9, BestVariance * 0.2) then
            Pattern.seen = Pattern.period and math.abs(Pattern.period - Best) <= 2 and (Pattern.seen or 0) + 1 or 1
            Pattern.period = Best
            Pattern.error = BestError / BestVariance
            return
        end
    end
    Pattern.period, Pattern.seen = nil, nil
end

local function PatternDisplacement(Pattern, Elapsed: number)
    local Samples: {Vector3} = Pattern.samples
    local Count, Period = #Samples, Pattern.period
    local Phase: number = Elapsed / PatternInterval
    local Cycles: number = math.floor(Phase / Period)
    Phase -= Cycles * Period
    local Index: number = math.floor(Phase)
    local Position: Vector3 = Samples[Count - Period + Index]:Lerp(Samples[Count - Period + Index + 1], Phase - Index)
    local Drift: Vector3 = Samples[Count] - Samples[Count - Period]
    return Position - Samples[Count - Period] + Drift * Cycles
end

local InputDelay: number = 0.18
local InputDelaySeen: number = 0
local InputHistory: number = 1
local InputFresh: number = 0.25

UpdateInputs = function(State, Humanoid: Humanoid?, Time: number, Velocity: Vector3, Knockback)
    local Move = Humanoid and Humanoid.MoveDirection
    if not ValidVector(Move) then
        State.inputs = nil
        return
    end

    Move = Move * HorizontalMask
    local Inputs = State.inputs
    if not Inputs then
        Inputs = {}
        State.inputs = Inputs
    end

    local Last = Inputs[#Inputs]
    if not Last or (Last.move - Move).Magnitude > 1e-3 then
        table.insert(Inputs, {move = Move, time = Time})
    end
    while #Inputs > 2 and Inputs[2].time < Time - InputHistory do
        table.remove(Inputs, 1)
    end
    State.inputTime = Time

    local Speed: number = Velocity.Magnitude
    if not Knockback and Speed > 8 and Speed < 60 and Move.Magnitude > 0.5 then
        State.cruise = State.cruise and State.cruise + (Speed - State.cruise) * 0.1 or Speed
    end

    local Change = State.inputChange
    if Change then
        if Knockback or Time - Change.time > 0.5 then
            State.inputChange = nil
        elseif Speed > 4 and Velocity.Unit:Dot(Change.direction) > 0.8 then
            local Delay: number = Time - Change.time
            if Delay > 0.03 and Delay < 0.45 then
                InputDelay += (Delay - InputDelay) * 0.1
                InputDelaySeen += 1
            end
            State.inputChange = nil
        end
    end

    if Last and Last.move ~= Move and Last.move.Magnitude > 0.5 and Move.Magnitude > 0.5 and Last.move.Unit:Dot(Move.Unit) < 0.3 then
        if Speed < 4 or Velocity.Unit:Dot(Move.Unit) < 0.3 then
            State.inputChange = {direction = Move.Unit, time = Time}
        end
    end
end

local function GetInputPath(State, Now: number)
    local Inputs = State and State.inputs
    if not Inputs or #Inputs == 0 or Now - (State.inputTime or -math.huge) > InputFresh then
        return nil
    end

    local Speed: number = math.clamp(State.cruise or 20, 8, 60)
    local Start: number = Now - InputDelay
    local First: number = 1
    for i: number = #Inputs, 1, -1 do
        if Inputs[i].time <= Start then
            First = i
            break
        end
    end

    local Path = {{0, Inputs[First].move * Speed}}
    for i: number = First + 1, #Inputs do
        table.insert(Path, {Inputs[i].time - Start, Inputs[i].move * Speed})
    end
    return Path
end

local function InputDisplacement(Path, Elapsed: number)
    local Offset: Vector3 = Vector3.zero
    for i: number, v in Path do
        local From: number = v[1]
        if Elapsed <= From then
            break
        end
        local Following = Path[i + 1]
        local To: number = Following and math.min(Following[1], Elapsed) or Elapsed
        Offset += v[2] * (To - From)
    end
    return Offset
end

function Prediction.getInputDelay()
    return InputDelay, InputDelaySeen
end

local SolveMotionTime = function(Origin: Vector3, Speed: number, ProjectileAcceleration: Vector3, PositionAtTime: (number) -> Vector3, Minimum: number?)
    local function Evaluate(Time: number)
        local Offset: Vector3 = PositionAtTime(Time) - Origin - ProjectileAcceleration * (0.5 * Time * Time)
        return Offset:Dot(Offset) - Speed * Speed * Time * Time
    end

    local Low: number = Minimum or 0
    local LowValue: number = Evaluate(Low)
    if not ValidNumber(LowValue) then
        return
    end
    local Distance: number = (PositionAtTime(Low) - Origin).Magnitude
    local Start: number = Low
    local Maximum: number = math.min(math.max(Distance / Speed * 4 + 1, Low + 2), 12)
    for Step: number = 1, 72 do
        local Alpha: number = Step / 72
        local High: number = Start + (Maximum - Start) * math.pow(Alpha, 1.35)
        local HighValue: number = Evaluate(High)
        if not ValidNumber(HighValue) then
            return
        end
        if math.abs(HighValue) < math.max(1e-7, Speed * Speed * High * High * 1e-7) then
            return High
        end
        if (HighValue > 0) ~= (LowValue > 0) then
            for _ = 1, 60 do
                local Middle: number = (Low + High) * 0.5
                if (Evaluate(Middle) > 0) == (LowValue > 0) then
                    Low = Middle
                else
                    High = Middle
                end
            end
            return High
        end
        Low = High
        LowValue = HighValue
    end
end

local SolveInterceptTime = function(Displacement: Vector3, Velocity: Vector3, Acceleration: Vector3, Speed: number, Minimum: number?)
    Minimum = Minimum or 0
    local HalfAcceleration: Vector3 = Acceleration * 0.5
    if HalfAcceleration:Dot(HalfAcceleration) < Epsilon then
        local A: number = Velocity:Dot(Velocity) - Speed * Speed
        local B: number = 2 * Velocity:Dot(Displacement)
        local C: number = Displacement:Dot(Displacement)
        if math.abs(A) < Epsilon then
            local Time: number? = math.abs(B) > Epsilon and -C / B or nil
            return Time and Time > math.max(Epsilon, Minimum) and Time or nil
        end

        local Discriminant: number = B * B - 4 * A * C
        local Tolerance: number = Epsilon * (B * B + math.abs(4 * A * C) + 1)
        if Discriminant < -Tolerance then
            return
        end

        local Root: number = math.sqrt(math.max(Discriminant, 0))
        local Q: number = -0.5 * (B + (B >= 0 and Root or -Root))
        local First: number? = Q / A
        local Second: number? = math.abs(Q) > Epsilon and C / Q or nil
        First = First and First > math.max(Epsilon, Minimum) and First or nil
        Second = Second and Second > math.max(Epsilon, Minimum) and Second or nil
        if First and Second then
            return math.min(First, Second)
        end
        return First or Second
    end

    local C4: number = HalfAcceleration:Dot(HalfAcceleration)
    local C3: number = 2 * HalfAcceleration:Dot(Velocity)
    local C2: number = 2 * HalfAcceleration:Dot(Displacement) + Velocity:Dot(Velocity) - Speed * Speed
    local C1: number = 2 * Velocity:Dot(Displacement)
    local C0: number = Displacement:Dot(Displacement)
    local Root0, Root1, Root2 = SolveCubic(4 * C4, 3 * C3, 2 * C2, C1)
    local Critical: {number} = {}
    if ValidNumber(Root0) and Root0 > Minimum then
        table.insert(Critical, Root0)
    end
    if ValidNumber(Root1) and Root1 > Minimum then
        table.insert(Critical, Root1)
    end
    if ValidNumber(Root2) and Root2 > Minimum then
        table.insert(Critical, Root2)
    end
    table.sort(Critical)

    local function Evaluate(Time: number)
        return ((((C4 * Time + C3) * Time + C2) * Time + C1) * Time + C0)
    end

    local function Tolerance(Time: number)
        return math.max(1e-7, Speed * Speed * Time * Time * 1e-7)
    end

    local function Bisect(Low: number, High: number, LowValue: number)
        for _ = 1, 60 do
            local Middle: number = (Low + High) * 0.5
            local Value: number = Evaluate(Middle)
            if (Value > 0) == (LowValue > 0) then
                Low = Middle
                LowValue = Value
            else
                High = Middle
            end
        end
        return High
    end

    local Previous: number = Minimum
    local PreviousValue: number = Evaluate(Previous)
    for _, Time: number in Critical do
        local Value: number = Evaluate(Time)
        if PreviousValue * Value < 0 then
            return Bisect(Previous, Time, PreviousValue)
        end
        if math.abs(Value) <= Tolerance(Time) then
            return Time
        end
        Previous = Time
        PreviousValue = Value
    end

    if PreviousValue < 0 then
        local High: number = math.max(Previous * 2, Previous + 1)
        local HighValue: number = Evaluate(High)
        while HighValue < 0 do
            High *= 2
            HighValue = Evaluate(High)
        end
        return Bisect(Previous, High, PreviousValue)
    end
    return
end

local StrafeDisplacement = function(Elapsed: number, Remaining: number, Half: number)
    local Phase: number = Half - Remaining
    local Future: number = (Phase + Elapsed) % (Half * 2)
    return (Future <= Half and Future or Half * 2 - Future) - Phase
end

local SolveLandingTime = function(StartY: number, FloorY: number, VerticalVelocity: number, PlayerGravity: number)
    local Height: number = StartY - FloorY
    if Height <= Epsilon and VerticalVelocity <= 0 then
        return nil, true
    end

    local Discriminant: number = VerticalVelocity * VerticalVelocity + 2 * PlayerGravity * Height
    if Discriminant < 0 then
        return nil
    end

    local Landing: number = (VerticalVelocity + math.sqrt(Discriminant)) / PlayerGravity
    return ValidNumber(Landing) and Landing > Epsilon and Landing or nil
end

local function SolveStaticLaunch(Origin: Vector3, Target: Vector3, Speed: number, Acceleration: Vector3)
    local Delta: Vector3 = Target - Origin
    if Speed <= Epsilon then
        return
    end

    local Pull: number = -Acceleration.Y
    if math.abs(Pull) <= Epsilon then
        local Distance: number = Delta.Magnitude
        if Distance <= Epsilon then
            return
        end
        local Time: number = Distance / Speed
        return Delta / Time, Time
    end

    local A: number = 0.25 * Pull * Pull
    local B: number = (Pull * Delta.Y) - (Speed * Speed)
    local C: number = Delta:Dot(Delta)
    local Discriminant: number = (B * B) - (4 * A * C)
    if Discriminant < 0 then
        return
    end

    local Root: number = math.sqrt(Discriminant)
    local First, Second = (-B - Root) / (2 * A), (-B + Root) / (2 * A)
    local Squared: number? = First > Epsilon and First or (Second > Epsilon and Second or nil)
    if not Squared then
        return
    end

    local Time: number = math.sqrt(Squared)
    if not ValidNumber(Time) or Time <= Epsilon then
        return
    end

    local Velocity: Vector3 = (Delta + Vector3.new(0, 0.5 * Pull * Time * Time, 0)) / Time
    if not ValidVector(Velocity) then
        return
    end

    return Velocity, Time
end

local CoverLift: number = 2
local AimLift: number = 0.5

Prediction.SolveTrajectory = function(Origin, ProjectileSpeed, Gravity, TargetPosition, TargetVelocity, PlayerGravity, PlayerHeight, PlayerJump, Params, TargetAirborne, TargetRootPosition, TargetRoot, MinimumTime, Strict)
    ResolveShots()
    TargetVelocity = TargetVelocity or Vector3.zero
    ProjectileSpeed = tonumber(ProjectileSpeed) or 0
    Gravity = tonumber(Gravity) or 0
    PlayerGravity = tonumber(PlayerGravity) or 0
    PlayerHeight = tonumber(PlayerHeight) or 0
    if typeof(TargetRootPosition) == "Instance" and TargetRootPosition:IsA("BasePart") then
        TargetRoot = TargetRootPosition
        TargetRootPosition = TargetRoot.Position
    end
    if not ValidVector(Origin)
        or not ValidVector(TargetPosition)
        or not ValidVector(TargetVelocity)
        or not ValidNumber(ProjectileSpeed)
        or ProjectileSpeed <= Epsilon
        or not ValidNumber(Gravity)
        or not ValidNumber(PlayerGravity)
        or not ValidNumber(PlayerHeight)
    then
        local State = TargetRoot and TargetMotion[TargetRoot]
        local LastSolution = State and State.lastSolution
        local CurrentPosition = typeof(TargetRoot) == "Instance" and TargetRoot:IsA("BasePart") and TargetRoot.Position
        if LastSolution
            and ValidVector(Origin)
            and ValidVector(CurrentPosition)
            and workspace:GetServerTimeNow() - LastSolution.time < 0.08
            and math.abs(LastSolution.projectileSpeed - ProjectileSpeed) < 0.01
            and math.abs(LastSolution.gravity - Gravity) < 0.01
            and (LastSolution.origin - Origin).Magnitude < 4
            and (LastSolution.targetPosition - CurrentPosition).Magnitude < 6
        then
            return Origin + LastSolution.velocity, LastSolution.impact, LastSolution.travelTime
        end
        if Strict then
            return nil
        end
        return TargetPosition, TargetPosition
    end
    if not ValidVector(TargetRootPosition) then
        TargetRootPosition = TargetPosition
    end
    if (TargetPosition - TargetRootPosition).Magnitude < 0.1 then
        TargetPosition += Vector3.new(0, AimLift, 0)
    end
    local TargetOffset: Vector3 = TargetPosition - TargetRootPosition
    if type(TargetAirborne) ~= "boolean" then
        TargetAirborne = nil
    end
    if TargetAirborne == nil then
        TargetAirborne = math.abs(TargetVelocity.Y) > 0.01
    end

    local Motion = GetTargetMotion(TargetRoot, TargetRootPosition, TargetVelocity, TargetAirborne, PlayerGravity)
    if Motion.invalid and Strict then
        return nil
    end
    TargetRootPosition = Motion.position
    TargetPosition = TargetRootPosition + TargetOffset
    TargetVelocity = Motion.velocity
    local SolutionTargetPosition: Vector3 = TargetRootPosition
    local ObservedPosition, ObservedVelocity = TargetPosition, TargetVelocity
    if ResidualSamples >= 8 then
        local Lead: Vector3 = TargetVelocity * HorizontalMask
        if Lead.Magnitude > 6 then
            TargetPosition -= Lead.Unit * math.clamp(ResidualSpread * 0.5, 0, 2)
        end
    end
    local LeadConfidence: number = 1
    local MissRate = Motion.missRate
    if MissRate and MissRate > Epsilon and not Motion.knockback then
        local Speed: number = (TargetVelocity * HorizontalMask).Magnitude
        if Speed > Epsilon then
            LeadConfidence = (Speed * Speed) / (Speed * Speed + MissRate * MissRate)
        end
    end
    local TargetAcceleration: Vector3 = Vector3.zero
    if PlayerGravity > 0 and (TargetAirborne or TargetVelocity.Y < -1) and not Motion.flying then
        TargetAcceleration = Vector3.new(0, -PlayerGravity, 0)
    end
    local HorizontalAcceleration: Vector3 = Motion.acceleration
    local HorizontalVelocity: Vector3 = TargetVelocity * HorizontalMask
    local StopTime: number?
    if HorizontalAcceleration.Magnitude > Epsilon and HorizontalVelocity.Magnitude > Epsilon then
        local Slowdown: number = HorizontalAcceleration:Dot(HorizontalVelocity.Unit)
        StopTime = math.abs(Slowdown) > Epsilon and -HorizontalVelocity.Magnitude / Slowdown or nil
        if not ValidNumber(StopTime) or StopTime <= Epsilon or StopTime > 0.35 then
            HorizontalAcceleration = Vector3.zero
            StopTime = nil
        end
    end

    local StrafeHalf, StrafeRemaining, StrafeVelocity
    if Motion.strafeHalf and (Motion.strafeSeen or 0) >= 2 then
        if HorizontalVelocity.Magnitude > 4 then
            StrafeHalf, StrafeVelocity = Motion.strafeHalf, HorizontalVelocity
        elseif Motion.strafeDirection and (Motion.strafeSpeed or 0) > 4 then
            StrafeHalf, StrafeVelocity = Motion.strafeHalf, Motion.strafeDirection * Motion.strafeSpeed
        end
        if StrafeHalf then
            StrafeRemaining = math.clamp(StrafeHalf - (Motion.strafeElapsed or 0), 0, StrafeHalf)
        end
    end

    local TurnRate: number?
    if not StrafeHalf
        and (Motion.turnSeen or 0) >= 4
        and ValidNumber(Motion.turnRate)
        and HorizontalVelocity.Magnitude > 5
        and HorizontalAcceleration.Magnitude <= Epsilon
    then
        TurnRate = math.clamp(Motion.turnRate, -5, 5)
        if math.abs(TurnRate) < 0.25 then
            TurnRate = nil
        end
    end

    local JumpVelocity, JumpPeriod, ClimbStep
    if not PlayerJump and Motion.state and (Motion.state.jumpSeen or 0) >= 2 and Motion.state.jumpPeriod and workspace:GetServerTimeNow() - (Motion.state.jumpStart or 0) < Motion.state.jumpPeriod * 1.5 then
        PlayerJump = Motion.state.jumpVelocity
    end
    if not PlayerJump and (TargetVelocity * HorizontalMask).Magnitude > 8 then
        PlayerJump = 42.6
    end
    if not PlayerJump and Motion.state and Motion.state.leaping then
        PlayerJump = Motion.state.jumpVelocity or 42.6
    end
    if ValidNumber(PlayerJump) and PlayerJump > 0 and PlayerGravity > 0 and not Motion.flying then
        JumpVelocity = PlayerJump
        local Observed = Motion.state and Motion.state.jumpVelocity
        if ValidNumber(Observed) and Observed > 0 then
            JumpVelocity = math.clamp(Observed, PlayerJump * 0.6, PlayerJump * 1.6)
        end
        local Period = Motion.state and Motion.state.jumpPeriod
        if ValidNumber(Period) and Period > 0 then
            JumpPeriod = Period
        end
        local Climb = Motion.state and Motion.state.climbStep
        if JumpPeriod
            and ValidNumber(Climb)
            and (Motion.state.climbSeen or 0) >= 2
            and Climb < JumpVelocity * JumpVelocity / (2 * PlayerGravity)
            and workspace:GetServerTimeNow() - (Motion.state.jumpStart or -math.huge) < JumpPeriod * 2
        then
            ClimbStep = Climb
        end
    end

    local GroundY, LandingTime, FloorLimit
    if PlayerHeight > 0 then
        local FloorY: number? = TraceFloor(TargetRootPosition, Params, TargetRoot)
        if FloorY then
            FloorLimit = FloorY + PlayerHeight + TargetOffset.Y
        end
        if FloorY and (TargetAcceleration.Y < 0 or JumpVelocity) and not Motion.flying then
            local Landing, Grounded = SolveLandingTime(TargetRootPosition.Y, FloorY + PlayerHeight, TargetVelocity.Y, PlayerGravity)
            local Horizontal: Vector3 = TargetVelocity * HorizontalMask
            local FloorPath = not Motion.knockback and not Motion.flying and GetInputPath(Motion.state, workspace:GetServerTimeNow())
            if Landing and Horizontal.Magnitude * Landing > 2 then
                local Settled: boolean?
                for Step: number = 1, 4 do
                    local SampleTime: number = Landing * (Step / 4)
                    local SampleFloor: number? = TraceFloor(TargetRootPosition + (FloorPath and InputDisplacement(FloorPath, SampleTime) or Horizontal * SampleTime), Params, TargetRoot)
                    if SampleFloor then
                        local Height: number = TargetRootPosition.Y + TargetVelocity.Y * SampleTime - PlayerGravity * (0.5 * SampleTime * SampleTime)
                        if Height <= SampleFloor + PlayerHeight then
                            local Solved: number? = SolveLandingTime(TargetRootPosition.Y, SampleFloor + PlayerHeight, TargetVelocity.Y, PlayerGravity)
                            if Solved then
                                FloorY = SampleFloor
                                Landing = Solved
                                Settled = true
                                break
                            end
                        end
                    end
                end

                if not Settled then
                    local Drifted: number? = TraceFloor(TargetRootPosition + (FloorPath and InputDisplacement(FloorPath, Landing) or Horizontal * Landing), Params, TargetRoot)
                    if Drifted and math.abs(Drifted - FloorY) > Epsilon then
                        FloorY = Drifted
                        Landing, Grounded = SolveLandingTime(TargetRootPosition.Y, FloorY + PlayerHeight, TargetVelocity.Y, PlayerGravity)
                    end
                end
            end

            if ClimbStep and TargetAirborne and Motion.state.jumpBase then
                local Raised: number = Motion.state.jumpBase + ClimbStep - PlayerHeight
                local Rising: number = math.max(TargetVelocity.Y, 0)
                if FloorY < Raised - ClimbStep * 0.5 and TargetRootPosition.Y + Rising * Rising / (2 * PlayerGravity) >= Raised + PlayerHeight then
                    FloorY = Raised
                    Landing, Grounded = SolveLandingTime(TargetRootPosition.Y, FloorY + PlayerHeight, TargetVelocity.Y, PlayerGravity)
                end
            end

            if Grounded then
                TargetRootPosition = Vector3.new(TargetRootPosition.X, FloorY + PlayerHeight, TargetRootPosition.Z)
                TargetPosition = TargetRootPosition + TargetOffset
                TargetVelocity = Vector3.new(TargetVelocity.X, 0, TargetVelocity.Z)
                TargetAcceleration = Vector3.zero
                if JumpVelocity then
                    GroundY = FloorY + PlayerHeight + TargetOffset.Y
                    LandingTime = 0
                end
            else
                GroundY = FloorY + PlayerHeight + TargetOffset.Y
                LandingTime = Landing
            end
        end
    end

    if GroundY and (JumpVelocity or TargetAirborne) and not Motion.flying then
        GroundY += CoverLift - TargetOffset.Y
        JumpVelocity = nil
    end

    local Latency: number = Prediction.getLatency() + (Motion.stale or 0)
    local ProjectileAcceleration: Vector3 = Vector3.new(0, -Gravity, 0)
    local PositionAtTime: ((number) -> Vector3)?
    local Time: number?
    local Pattern = Motion.state and Motion.state.pattern
    local InputPath = not Motion.knockback and not Motion.flying and GetInputPath(Motion.state, workspace:GetServerTimeNow())
    if Motion.knockback and Motion.impulse and Motion.knockbackBase then
        local BasePosition: Vector3 = TargetPosition
        local BaseVelocity: Vector3 = Motion.knockbackBase
        local Impulse: Vector3 = Motion.impulse
        local Decay: number = math.max(Motion.decay or 1.8, Epsilon)
        PositionAtTime = function(Value: number)
            local Total: number = Latency + Value
            local HorizontalOffset: Vector3 = BaseVelocity * Total + Impulse * ((1 - math.exp(-Decay * Total)) / Decay)
            local Vertical: number = LandingTime and Total >= LandingTime
                and GroundY
                or BasePosition.Y + TargetVelocity.Y * Total + TargetAcceleration.Y * (0.5 * Total * Total)
            return Vector3.new(BasePosition.X + HorizontalOffset.X, Vertical, BasePosition.Z + HorizontalOffset.Z)
        end
        Time = SolveMotionTime(Origin, ProjectileSpeed, ProjectileAcceleration, PositionAtTime, MinimumTime)
    elseif Motion.expectedImpulse and Motion.expectedTime then
        local BasePosition: Vector3 = TargetPosition
        local BaseVelocity: Vector3 = HorizontalVelocity
        local Impulse: Vector3 = Motion.expectedImpulse
        local Decay: number = math.max(Motion.decay or (TargetAirborne and 1.8 or 3.5), Epsilon)
        local ImpulseDelay: number = math.max(Motion.expectedTime - workspace:GetServerTimeNow(), 0) + Latency
        local Lift: number? = ValidNumber(Motion.expectedLift) and Motion.expectedLift > Epsilon and Motion.expectedLift or nil
        PositionAtTime = function(Value: number)
            local Total: number = Latency + Value
            local HorizontalOffset: Vector3 = BaseVelocity * Total
            if Total > ImpulseDelay then
                local Since: number = Total - ImpulseDelay
                HorizontalOffset += Impulse * ((1 - math.exp(-Decay * Since)) / Decay)
            end
            local Vertical: number = LandingTime and Total >= LandingTime
                and GroundY
                or BasePosition.Y + TargetVelocity.Y * Total + TargetAcceleration.Y * (0.5 * Total * Total)
            if Lift and Total > ImpulseDelay then
                local Since: number = Total - ImpulseDelay
                Vertical += math.max(Lift * Since - PlayerGravity * (0.5 * Since * Since), 0)
            end
            return Vector3.new(BasePosition.X + HorizontalOffset.X, Vertical, BasePosition.Z + HorizontalOffset.Z)
        end
        Time = SolveMotionTime(Origin, ProjectileSpeed, ProjectileAcceleration, PositionAtTime, MinimumTime)
    elseif InputPath then
        PositionAtTime = function(Value: number)
            local Total: number = Latency + Value
            local Offset: Vector3 = InputDisplacement(InputPath, Total)
            local Vertical: number
            if LandingTime and GroundY and Total >= LandingTime then
                Vertical = GroundY
            else
                Vertical = TargetPosition.Y + TargetVelocity.Y * Total + TargetAcceleration.Y * (0.5 * Total * Total)
                if GroundY then
                    Vertical = math.max(Vertical, GroundY - 1)
                end
            end
            return Vector3.new(TargetPosition.X + Offset.X, Vertical, TargetPosition.Z + Offset.Z)
        end
        LeadConfidence = 1
        Time = SolveMotionTime(Origin, ProjectileSpeed, ProjectileAcceleration, PositionAtTime, MinimumTime)
    elseif Pattern and Pattern.period and (Pattern.seen or 0) >= 2 then
        local Phase: number = math.max(workspace:GetServerTimeNow() - Pattern.time, 0)
        local Previous: Vector3 = PatternDisplacement(Pattern, Phase)
        PositionAtTime = function(Value: number)
            local Total: number = Latency + Value
            local Offset: Vector3 = PatternDisplacement(Pattern, Phase + Total) - Previous
            local Vertical: number
            if LandingTime and GroundY and Total >= LandingTime then
                Vertical = GroundY
            else
                Vertical = TargetPosition.Y + TargetVelocity.Y * Total + TargetAcceleration.Y * (0.5 * Total * Total)
            end
            return Vector3.new(TargetPosition.X + Offset.X, Vertical, TargetPosition.Z + Offset.Z)
        end
        LeadConfidence = 1
        Time = SolveMotionTime(Origin, ProjectileSpeed, ProjectileAcceleration, PositionAtTime, MinimumTime)
    elseif StrafeHalf then
        local BasePosition: Vector3 = TargetPosition
        local BaseVertical: number = TargetVelocity.Y
        local Horizontal: Vector3 = StrafeVelocity
        local Half, Remaining = StrafeHalf, StrafeRemaining
        PositionAtTime = function(Value: number)
            local Total: number = Latency + Value
            local Offset: Vector3 = Horizontal * StrafeDisplacement(Total, Remaining, Half)
            local Vertical: number
            if LandingTime and GroundY and Total >= LandingTime then
                Vertical = GroundY
            else
                Vertical = BasePosition.Y + BaseVertical * Total + TargetAcceleration.Y * (0.5 * Total * Total)
            end
            return Vector3.new(BasePosition.X + Offset.X, Vertical, BasePosition.Z + Offset.Z)
        end
        Time = SolveMotionTime(Origin, ProjectileSpeed, ProjectileAcceleration, PositionAtTime, MinimumTime)
    elseif TurnRate then
        local BasePosition: Vector3 = TargetPosition
        local BaseVertical: number = TargetVelocity.Y
        local SpeedAlong: number = HorizontalVelocity.Magnitude
        local Unit: Vector3 = HorizontalVelocity.Unit
        local Normal: Vector3 = Vector3.new(-Unit.Z, 0, Unit.X)
        local Radius: number = SpeedAlong / TurnRate
        local SweepLimit: number = math.min(2.6 / math.abs(TurnRate), 0.1 * (Motion.turnSeen or 4))
        PositionAtTime = function(Value: number)
            local Total: number = Latency + Value
            local Swept: number = math.min(Total, SweepLimit) * TurnRate
            local Offset: Vector3 = Unit * (Radius * math.sin(Swept)) + Normal * (Radius * (1 - math.cos(Swept)))
            if Total > SweepLimit then
                local Heading: Vector3 = Unit * math.cos(Swept) + Normal * math.sin(Swept)
                Offset += Heading * (SpeedAlong * (Total - SweepLimit))
            end
            local Vertical: number
            if LandingTime and GroundY and Total >= LandingTime then
                Vertical = GroundY
            else
                Vertical = BasePosition.Y + BaseVertical * Total + TargetAcceleration.Y * (0.5 * Total * Total)
            end
            return Vector3.new(BasePosition.X + Offset.X, Vertical, BasePosition.Z + Offset.Z)
        end
        Time = SolveMotionTime(Origin, ProjectileSpeed, ProjectileAcceleration, PositionAtTime, MinimumTime)
    else
        if Latency > Epsilon then
            local HorizontalTime: number = StopTime and math.min(Latency, StopTime) or Latency
            local HorizontalOffset: Vector3 = HorizontalVelocity * HorizontalTime + HorizontalAcceleration * (0.5 * HorizontalTime * HorizontalTime)
            TargetRootPosition += HorizontalOffset
            TargetPosition += HorizontalOffset
            if StopTime and Latency >= StopTime then
                TargetVelocity = Vector3.new(0, TargetVelocity.Y, 0)
                HorizontalVelocity = Vector3.zero
                HorizontalAcceleration = Vector3.zero
                StopTime = nil
            else
                HorizontalVelocity += HorizontalAcceleration * Latency
                TargetVelocity = Vector3.new(HorizontalVelocity.X, TargetVelocity.Y, HorizontalVelocity.Z)
                if StopTime then
                    StopTime -= Latency
                end
            end

            if LandingTime and Latency >= LandingTime then
                TargetPosition = Vector3.new(TargetPosition.X, GroundY, TargetPosition.Z)
                TargetVelocity = Vector3.new(TargetVelocity.X, 0, TargetVelocity.Z)
                TargetAcceleration = Vector3.zero
                LandingTime = nil
            else
                local VerticalOffset: Vector3 = Vector3.new(0, TargetVelocity.Y * Latency + TargetAcceleration.Y * (0.5 * Latency * Latency), 0)
                TargetRootPosition += VerticalOffset
                TargetPosition += VerticalOffset
                TargetVelocity += Vector3.new(0, TargetAcceleration.Y * Latency, 0)
                if LandingTime then
                    LandingTime -= Latency
                end
            end
        end

        local Displacement: Vector3 = TargetPosition - Origin
        if Displacement:Dot(Displacement) <= Epsilon then
            return TargetPosition, TargetPosition, 0
        end

        local RelativeAcceleration: Vector3 = TargetAcceleration - ProjectileAcceleration
        if StopTime then
            PositionAtTime = function(Value: number)
                local HorizontalTime: number = math.min(Value, StopTime)
                local HorizontalOffset: Vector3 = HorizontalVelocity * HorizontalTime + HorizontalAcceleration * (0.5 * HorizontalTime * HorizontalTime)
                local Vertical: number = LandingTime and Value >= LandingTime
                    and GroundY
                    or TargetPosition.Y + TargetVelocity.Y * Value + TargetAcceleration.Y * (0.5 * Value * Value)
                return Vector3.new(TargetPosition.X + HorizontalOffset.X, Vertical, TargetPosition.Z + HorizontalOffset.Z)
            end
            Time = SolveMotionTime(Origin, ProjectileSpeed, ProjectileAcceleration, PositionAtTime, MinimumTime)
        else
            Time = SolveInterceptTime(Displacement, TargetVelocity, RelativeAcceleration, ProjectileSpeed, MinimumTime)
        end
        if not PositionAtTime and LandingTime and (not Time or Time > LandingTime) then
            local LandedPosition: Vector3 = Vector3.new(TargetPosition.X, GroundY, TargetPosition.Z)
            local LandedVelocity: Vector3 = Vector3.new(TargetVelocity.X, 0, TargetVelocity.Z)
            Time = SolveInterceptTime(LandedPosition - Origin, LandedVelocity, -ProjectileAcceleration, ProjectileSpeed, math.max(LandingTime, MinimumTime or 0))
        end
    end

    if Time and ValidNumber(Time) and Time > Epsilon then
        local FutureTarget: Vector3
        if PositionAtTime then
            FutureTarget = PositionAtTime(Time)
        elseif LandingTime and Time > LandingTime then
            FutureTarget = Vector3.new(
                TargetPosition.X + TargetVelocity.X * Time,
                GroundY,
                TargetPosition.Z + TargetVelocity.Z * Time
            )
        else
            FutureTarget = TargetPosition + TargetVelocity * Time + TargetAcceleration * (0.5 * Time * Time)
        end
        local LaunchVelocity: Vector3 = (FutureTarget - Origin - ProjectileAcceleration * (0.5 * Time * Time)) / Time
        if FloorLimit and ValidVector(FutureTarget) and FutureTarget.Y < FloorLimit then
            FutureTarget = Vector3.new(FutureTarget.X, FloorLimit, FutureTarget.Z)
            local FloorVelocity, FloorTime = SolveStaticLaunch(Origin, FutureTarget, ProjectileSpeed, ProjectileAcceleration)
            if FloorVelocity and FloorTime then
                LaunchVelocity, Time = FloorVelocity, FloorTime
            end
        end

        local Confidence: number = LeadConfidence
        if Confidence < 1 and ValidVector(FutureTarget) then
            local Present: Vector3 = PositionAtTime and PositionAtTime(0) or TargetPosition
            if not ValidVector(Present) then
                Present = TargetPosition
            end
            local Damped: Vector3 = Vector3.new(
                Present.X + (FutureTarget.X - Present.X) * Confidence,
                FutureTarget.Y,
                Present.Z + (FutureTarget.Z - Present.Z) * Confidence
            )
            local DampedVelocity, DampedTime = SolveStaticLaunch(Origin, Damped, ProjectileSpeed, ProjectileAcceleration)
            if DampedVelocity and DampedTime then
                FutureTarget, LaunchVelocity, Time = Damped, DampedVelocity, DampedTime
            end
        end
        local ForecastTime: number = Time
        local Bucket: number = Time + Latency < 0.3 and 1 or Time + Latency < 0.7 and 2 or 3
        local Candidates: {Vector3} = {
            FutureTarget - TargetOffset,
            ObservedPosition + ObservedVelocity * (Latency + Time) - TargetOffset,
            ObservedPosition + ObservedVelocity * Latency - TargetOffset
        }
        local Scores = Motion.state and Motion.state.scores and Motion.state.scores[Bucket]
        if Scores and Scores.count >= 5 and Scores[1] > 1 and not StrafeHalf and not InputPath and not Motion.knockback and not Motion.expectedImpulse and not (Pattern and Pattern.period and (Pattern.seen or 0) >= 2) then
            local Selected, Loss = 1, Scores[1] * 0.8
            for i: number = 2, 3 do
                if Scores[i] < Loss then
                    Selected, Loss = i, Scores[i]
                end
            end
            if Selected ~= 1 then
                local Velocity: Vector3 = Selected == 2 and ObservedVelocity * HorizontalMask or Vector3.zero
                local Present: Vector3 = ObservedPosition + ObservedVelocity * Latency
                local function Alternative(Value: number)
                    local Vertical: number
                    if PositionAtTime then
                        Vertical = PositionAtTime(Value).Y
                    elseif LandingTime and Value >= LandingTime then
                        Vertical = GroundY
                    else
                        Vertical = TargetPosition.Y + TargetVelocity.Y * Value + TargetAcceleration.Y * (0.5 * Value * Value)
                    end
                    local Point: Vector3 = Present + Velocity * Value
                    return Vector3.new(Point.X, Vertical, Point.Z)
                end
                local Solved: number? = SolveMotionTime(Origin, ProjectileSpeed, ProjectileAcceleration, Alternative, MinimumTime)
                if Solved then
                    Time = Solved
                    FutureTarget = Alternative(Time)
                    LaunchVelocity = (FutureTarget - Origin - ProjectileAcceleration * (0.5 * Time * Time)) / Time
                end
            end
        end
        if ValidVector(FutureTarget)
            and ValidVector(LaunchVelocity)
            and math.abs(LaunchVelocity.Magnitude - ProjectileSpeed) < math.max(0.05, ProjectileSpeed * 0.002)
        then
            local State = Motion.state
            if State then
                local Now: number = workspace:GetServerTimeNow()
                State.lastSolution = {
                    gravity = Gravity,
                    impact = FutureTarget,
                    origin = Origin,
                    projectileSpeed = ProjectileSpeed,
                    targetPosition = SolutionTargetPosition,
                    time = Now,
                    travelTime = Time,
                    velocity = LaunchVelocity
                }
                if Now - (State.gradeTime or -math.huge) >= 0.1 then
                    State.gradeTime = Now
                    State.pending = State.pending or {}
                    if #State.pending >= 16 then
                        table.remove(State.pending, 1)
                    end
                    table.insert(State.pending, {
                        arrival = Now + ForecastTime + Latency,
                        horizon = ForecastTime + Latency,
                        position = Candidates[1],
                        candidates = Candidates,
                        bucket = Bucket
                    })
                end
            end
            return Origin + LaunchVelocity, FutureTarget, Time
        end
    end

    local LastSolution = Motion.state and Motion.state.lastSolution
    if LastSolution
        and not Motion.changed
        and not Motion.knockback
        and workspace:GetServerTimeNow() - LastSolution.time < 0.08
        and math.abs(LastSolution.projectileSpeed - ProjectileSpeed) < 0.01
        and math.abs(LastSolution.gravity - Gravity) < 0.01
        and (LastSolution.origin - Origin).Magnitude < 4
        and (LastSolution.targetPosition - SolutionTargetPosition).Magnitude < 6
    then
        return Origin + LastSolution.velocity, LastSolution.impact, LastSolution.travelTime
    end

    if Strict then
        return nil
    end
    return TargetPosition, TargetPosition
end

return Prediction