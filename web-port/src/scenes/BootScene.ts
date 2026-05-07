import Phaser from "phaser";
import {
	ensureSpriteTextures,
	fetchSpriteManifest,
	queueManifestSprites,
} from "../systems/SpriteManifest";

export class BootScene extends Phaser.Scene {
	public constructor() {
		super("BootScene");
	}

	public async preload(): Promise<void> {
		const manifest = await fetchSpriteManifest();
		queueManifestSprites(this, manifest);

		this.load.on("complete", () => {
			ensureSpriteTextures(this);
			this.scene.start("MenuScene");
		});

		this.load.start();
	}
}
