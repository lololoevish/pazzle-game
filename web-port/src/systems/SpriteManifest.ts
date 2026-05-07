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

		const graphics = scene.make.graphics({ x: 0, y: 0 }, false);
		graphics.fillStyle(PLACEHOLDER_COLORS[key], 1);
		graphics.fillRoundedRect(
			0,
			0,
			key === "caveEntrance" ? 72 : 40,
			key === "caveEntrance" ? 72 : 48,
			8,
		);
		graphics.lineStyle(3, 0x1f2937, 1);
		graphics.strokeRoundedRect(
			1,
			1,
			key === "caveEntrance" ? 70 : 38,
			key === "caveEntrance" ? 70 : 46,
			8,
		);
		graphics.generateTexture(
			key,
			key === "caveEntrance" ? 72 : 40,
			key === "caveEntrance" ? 72 : 48,
		);
		graphics.destroy();
	}
}
