export const GAME_WIDTH = 800;
export const GAME_HEIGHT = 600;
export const LEVEL_COUNT = 24;
export const SAVE_KEY = "adventure-puzzle-game-web-save-v1";

export const PLAYER_CONFIG = {
	topdownSpeed: 220,
	topdownDiagonalSpeed: 180,
	topdownAcceleration: 10,
	topdownDeceleration: 14,
	platformerMoveSpeed: 260,
	platformerGroundAcceleration: 2200,
	platformerGroundDeceleration: 2600,
	platformerAirAcceleration: 1600,
	platformerAirDeceleration: 1400,
	jumpSpeed: 560,
	jumpCutSpeed: 220,
	gravityRiseHold: 1350,
	gravityRiseRelease: 2500,
	gravityFall: 2850,
	maxFallSpeed: 900,
	coyoteTime: 0.5,
	jumpBufferTime: 0.15,
	interactionDistance: 96,
} as const;

export const PUZZLE_TYPES = [
	"maze",
	"word_search",
	"rhythm",
	"pairs",
	"platformer",
	"final",
	"riddle",
	"sound_trap",
	"jumping_path",
	"memory_advanced",
	"cave_song",
	"epic_finale",
] as const;

export type PuzzleType = (typeof PUZZLE_TYPES)[number];

export const SPRITE_KEYS = [
	"player",
	"npcElder",
	"npcMechanic",
	"npcArchivist",
	"lever",
	"caveEntrance",
	"crystal",
	"townBackground",
	"caveBackground",
	"uiPanel",
	"button",
	"tileFloor",
	"caveWall",
	"runeGlow",
	"mist",
	"grassPatch",
	"stonePebble",
	"torchGlow",
	"starSparkle",
	"townBanner",
	"moonLantern",
	"caveVine",
	"magicCircle",
	"softCloud",
	"townPath",
	"glowMushroom",
	"caveCrystalCluster",
	"stalactite",
	"runeStone",
	"gearEmblem",
	"mirrorShard",
] as const;

export type SpriteKey = (typeof SPRITE_KEYS)[number];
