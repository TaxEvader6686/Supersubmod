return {
	Fighters = {
		["HEAVY_FIGHTER"] = {
			DEFAULT = {Initial = 1, Reserve = 4}
		},
		["ELITE_FIGHTERBOMBER"] = {
			DEFAULT = {Initial = 1, Reserve = 4}
		},
		["ELITE_TIE_RAPTOR_SQUADRON"] = {
			DEFAULT = {Initial = 2, Reserve = 6}
		},
		["BOMBER2_DOUBLE"] = {
			DEFAULT = {Initial = 1, Reserve = 4}
		}
	},
	Native = "IMPERIAL",
	Scripts = {"fighter-spawn", "persistent-damage-tactical"},
	Flags = {HANGAR = true, DAMAGEINHERIT = "EXECUTOR_STAR_DREADNOUGHT"}
}