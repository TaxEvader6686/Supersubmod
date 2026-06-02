return {
	Ship_Crew_Requirement = 7500,
	Fighters = {
		["LIGHT_FIGHTERBOMBER_DOUBLE"] = {
			DEFAULT = {Initial = 2, Reserve = 4}
		},
		["ELITE_FIGHTERBOMBER_DOUBLE"] = {
			DEFAULT = {Initial = 1, Reserve = 3}
		},
		["ELITE_INTERCEPTOR_DOUBLE"] = {
			DEFAULT = {Initial = 2, Reserve = 4}
		},
		["BOMBER_DOUBLE"] = {
			DEFAULT = {Initial = 2, Reserve = 4}
		}
	},
	Native = "IMPERIAL",
	Scripts = {"fighter-spawn", "persistent-damage-tactical"},
	Flags = {HANGAR = true}
}