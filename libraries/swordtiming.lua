local swordTiming: table = {
	["SafeSpacing"] = 0.296,
	["HighSpacing"] = 0.2925,
	["HitFloor"] = 0.285,
	["GapFloor"] = 0.2915,
	["ArrivalFloor"] = 0.2747,
	["CooldownCorrection"] = (0.017999999225139618 / 10) + 0.013412
};

local weaponSpacing: {[number]: number} = {[0.21] = 0.229, [0.25] = 0.249, [0.35] = 0.345, [0.4] = 0.341, [0.6] = 0.63};

swordTiming.Calculate = function(speed: number, fury: number, high: boolean, budget: number, hits: number?): (number, number, number, number, boolean)
	local stock: boolean = speed == 0.3;
	local normal: number = high and swordTiming.HighSpacing or swordTiming.SafeSpacing;
	local spacing: number = stock and normal or weaponSpacing[speed] or speed + 0.03;
	if hits and hits ~= 35 then
		spacing = math.max(spacing, 10 / math.max(hits - 1, 1));
	end;
	spacing = math.max(spacing * fury, budget);
	local scale: number = spacing / (stock and normal or swordTiming.SafeSpacing);
	local gap: number = (scale < 1 and swordTiming.GapFloor or swordTiming.HitFloor) * scale;
	if stock and high then
		gap = math.max(gap, swordTiming.GapFloor * fury, budget);
	end;
	return spacing, scale, gap, math.max(speed * fury - swordTiming.CooldownCorrection, 0), stock;
end;

return swordTiming;
