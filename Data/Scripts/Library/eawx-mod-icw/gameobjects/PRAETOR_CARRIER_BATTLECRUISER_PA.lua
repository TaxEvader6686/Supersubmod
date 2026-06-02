return {
	Ship_Crew_Requirement = 2300,
	Fighters = {
		["HEAVY_FIGHTER"] = {
			DEFAULT = {Initial = 3, Reserve = 12}
		},
		["ELITE_INTERCEPTOR"] = {
			DEFAULT = {Initial = 3, Reserve = 12}
		},
		["BOMBER_DOUBLE"] = {
			DEFAULT = {Initial = 2, Reserve = 9}
		},
		["HEAVY_BOMBER_DOUBLE"] = {
			DEFAULT = {Initial = 1, Reserve = 3}
		}
	},
	Native = "IMPERIAL",
	Scripts = {"multilayer", "fighter-spawn", "single-unit-retreat"}
}