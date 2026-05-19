import Phaser from "phaser";
import { SPRITE_KEYS } from "../game/constants";
import {
	ensureSpriteTextures,
	type SpriteManifest,
} from "../systems/SpriteManifest";

export class BootScene extends Phaser.Scene {
	public constructor() {
		super("BootScene");
	}

	public preload(): void {
		this.load.json("spriteManifest", "/sprites/manifest.json");
	}

	public create(): void {
		const manifest =
			(this.cache.json.get("spriteManifest") as SpriteManifest) || {};
		let hasImages = false;

		for (const key of SPRITE_KEYS) {
			const fileName = manifest[key]?.trim();
			if (fileName) {
				this.load.image(key, `/sprites/${fileName}`);
				hasImages = true;
			}
		}

		if (hasImages) {
			this.load.once("complete", () => {
				ensureSpriteTextures(this);
				this.scene.start("MenuScene");
			});
			this.load.start();
		} else {
			ensureSpriteTextures(this);
			this.scene.start("MenuScene");
		}
	}
}
