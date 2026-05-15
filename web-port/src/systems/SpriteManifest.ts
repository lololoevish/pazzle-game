import type Phaser from "phaser";
import { SPRITE_KEYS, type SpriteKey } from "../game/constants";

export type SpriteManifest = Partial<Record<SpriteKey, string>>;

const PLACEHOLDER_COLORS: Record<SpriteKey, number> = {
	player: 0x79d7ff,
	npcElder: 0xffd37a,
	npcMechanic: 0x9cff8f,
	npcArchivist: 0xd8a3ff,
	lever: 0xff7f7f,
	caveEntrance: 0x8d7a5b,
	crystal: 0x7affea,
	townBackground: 0x1a2e1a,
	caveBackground: 0x1a1a2e,
	uiPanel: 0x2d3748,
	button: 0x4a5568,
};

export async function fetchSpriteManifest(): Promise<SpriteManifest> {
	try {
		const response = await fetch("/sprites/manifest.json", {
			cache: "no-cache",
		});
		if (!response.ok) {
			return {};
		}
		return (await response.json()) as SpriteManifest;
	} catch {
		return {};
	}
}

export function queueManifestSprites(
	scene: Phaser.Scene,
	manifest: SpriteManifest,
): void {
	for (const key of SPRITE_KEYS) {
		const fileName = manifest[key]?.trim();

		if (fileName) {
			scene.load.image(key, `/sprites/${fileName}`);
		}
	}
}

export function ensureSpriteTextures(scene: Phaser.Scene): void {
	for (const key of SPRITE_KEYS) {
		if (scene.textures.exists(key)) {
			continue;
		}

		let width = 40;
		let height = 48;

		if (key === "caveEntrance") {
			width = 72;
			height = 72;
		} else if (key === "townBackground" || key === "caveBackground") {
			width = 960;
			height = 540;
		} else if (key === "uiPanel") {
			width = 128;
			height = 128;
		} else if (key === "button") {
			width = 64;
			height = 32;
		}

		const graphics = scene.make.graphics({ x: 0, y: 0 }, false);
		graphics.fillStyle(PLACEHOLDER_COLORS[key], 1);

		if (key === "townBackground" || key === "caveBackground") {
			graphics.fillRect(0, 0, width, height);
			// Добавим немного текстуры для фона
			graphics.lineStyle(2, 0xffffff, 0.05);
			for (let i = 0; i < 10; i++) {
				graphics.lineBetween(
					Math.random() * width,
					0,
					Math.random() * width,
					height,
				);
			}
		} else {
			graphics.fillRoundedRect(0, 0, width, height, 8);
			graphics.lineStyle(3, 0x1f2937, 1);
			graphics.strokeRoundedRect(1, 1, width - 2, height - 2, 8);
		}

		graphics.generateTexture(key, width, height);
		graphics.destroy();
	}
}
