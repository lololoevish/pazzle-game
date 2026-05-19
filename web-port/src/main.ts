import Phaser from "phaser";
import { GAME_HEIGHT, GAME_WIDTH } from "./game/constants";
import { BootScene } from "./scenes/BootScene";
import { CaveScene } from "./scenes/CaveScene";
import { MenuScene } from "./scenes/MenuScene";
import { SpriteHelpScene } from "./scenes/SpriteHelpScene";
import { TownScene } from "./scenes/TownScene";
import { VictoryScene } from "./scenes/VictoryScene";

import "./style.css";

const config: Phaser.Types.Core.GameConfig = {
	type: Phaser.AUTO,
	parent: "game",
	width: GAME_WIDTH,
	height: GAME_HEIGHT,
	backgroundColor: "#0f172a",
	pixelArt: true,
	physics: {
		default: "arcade",
		arcade: {
			debug: false,
		},
	},
	scale: {
		mode: Phaser.Scale.RESIZE,
		autoCenter: Phaser.Scale.CENTER_BOTH,
		width: "100%",
		height: "100%",
	},
	scene: [
		BootScene,
		MenuScene,
		SpriteHelpScene,
		TownScene,
		CaveScene,
		VictoryScene,
	],
};

new Phaser.Game(config);
