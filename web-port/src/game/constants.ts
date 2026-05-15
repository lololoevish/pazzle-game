export const GAME_WIDTH = 960;
export const GAME_HEIGHT = 540;
export const LEVEL_COUNT = 24;
export const SAVE_KEY = "adventure-puzzle-game-web-save-v1";

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
] as const;

export type SpriteKey = (typeof SPRITE_KEYS)[number];
