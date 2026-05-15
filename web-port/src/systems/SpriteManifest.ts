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
		} else if (key === "crystal") {
			width = 32;
			height = 32;
		}

		const graphics = scene.make.graphics({ x: 0, y: 0 }, false);
		const color = PLACEHOLDER_COLORS[key];

		if (key === "townBackground" || key === "caveBackground") {
			// Улучшенный фон с градиентом и шумом
			graphics.fillGradientStyle(color, color, 0x000000, 0x000000, 1);
			graphics.fillRect(0, 0, width, height);

			// Текстура (камни или трава)
			graphics.lineStyle(1, 0xffffff, 0.03);
			for (let i = 0; i < 400; i++) {
				const x = Math.random() * width;
				const y = Math.random() * height;
				if (key === "caveBackground") {
					graphics.strokeCircle(x, y, Math.random() * 3);
				} else {
					graphics.lineBetween(x, y, x + 2, y + 4);
				}
			}
		} else if (key === "player") {
			// Герой с глазами и "рюкзаком"
			graphics.fillStyle(color, 1);
			graphics.fillRoundedRect(4, 4, 32, 40, 8);
			graphics.lineStyle(2, 0xffffff, 0.5);
			graphics.strokeRoundedRect(4, 4, 32, 40, 8);

			// Глаза
			graphics.fillStyle(0xffffff, 1);
			graphics.fillRect(10, 14, 6, 6);
			graphics.fillRect(24, 14, 6, 6);
			graphics.fillStyle(0x000000, 1);
			graphics.fillRect(12, 16, 2, 2);
			graphics.fillRect(26, 16, 2, 2);
		} else if (key.startsWith("npc")) {
			// NPC с отличительными чертами
			graphics.fillStyle(color, 1);
			graphics.fillRoundedRect(4, 4, 32, 40, 10);
			graphics.lineStyle(2, 0x000000, 0.3);
			graphics.strokeRoundedRect(4, 4, 32, 40, 10);

			// Глаза (закрыты или прищурены)
			graphics.lineStyle(2, 0x000000, 0.6);
			graphics.lineBetween(10, 18, 16, 18);
			graphics.lineBetween(24, 18, 30, 18);

			if (key === "npcElder") {
				// Борода
				graphics.fillStyle(0xffffff, 0.9);
				graphics.fillTriangle(10, 24, 30, 24, 20, 44);
			} else if (key === "npcMechanic") {
				// Пояс с инструментами
				graphics.fillStyle(0x4b5563, 1);
				graphics.fillRect(4, 28, 32, 6);
			} else if (key === "npcArchivist") {
				// Монокль или книга
				graphics.lineStyle(1, 0xffd700, 1);
				graphics.strokeCircle(27, 18, 5);
				graphics.lineBetween(27, 13, 27, 5);
			}
		} else if (key === "crystal") {
			// Кристалл (ромб с блеском)
			graphics.fillStyle(color, 1);
			graphics.beginPath();
			graphics.moveTo(16, 2);
			graphics.lineTo(30, 16);
			graphics.lineTo(16, 30);
			graphics.lineTo(2, 16);
			graphics.closePath();
			graphics.fill();
			graphics.lineStyle(2, 0xffffff, 0.8);
			graphics.strokePath();
			// Блеск
			graphics.fillStyle(0xffffff, 0.5);
			graphics.fillTriangle(16, 6, 26, 16, 16, 16);
		} else if (key === "lever") {
			// Рычаг с основанием
			graphics.fillStyle(0x374151, 1);
			graphics.fillRect(8, 36, 24, 10);
			graphics.lineStyle(4, 0x9ca3af, 1);
			graphics.lineBetween(20, 36, 20, 12);
			graphics.fillStyle(0xef4444, 1);
			graphics.fillCircle(20, 10, 8);
		} else if (key === "caveEntrance") {
			// Арка входа
			graphics.fillStyle(0x111827, 1);
			graphics.fillEllipse(36, 40, 60, 64);
			graphics.lineStyle(6, color, 1);
			graphics.strokeEllipse(36, 40, 60, 64);
			// Камни вокруг
			graphics.fillStyle(color, 0.7);
			for (let i = 0; i < 8; i++) {
				const ang = (i / 8) * Math.PI * 2;
				graphics.fillCircle(
					36 + Math.cos(ang) * 32,
					40 + Math.sin(ang) * 32,
					8,
				);
			}
		} else if (key === "uiPanel") {
			// Панель с рамкой
			graphics.fillStyle(color, 1);
			graphics.fillRoundedRect(0, 0, width, height, 12);
			graphics.lineStyle(4, 0x4a5568, 1);
			graphics.strokeRoundedRect(2, 2, width - 4, height - 4, 12);
			graphics.lineStyle(2, 0x718096, 1);
			graphics.strokeRoundedRect(6, 6, width - 12, height - 12, 8);
		} else if (key === "button") {
			// Кнопка с градиентом
			graphics.fillGradientStyle(color, color, 0x2d3748, 0x2d3748, 1);
			graphics.fillRoundedRect(0, 0, width, height, 6);
			graphics.lineStyle(2, 0xffffff, 0.4);
			graphics.strokeRoundedRect(1, 1, width - 2, height - 2, 6);
		} else {
			graphics.fillStyle(PLACEHOLDER_COLORS[key], 1);
			graphics.fillRoundedRect(0, 0, width, height, 8);
			graphics.lineStyle(3, 0x1f2937, 1);
			graphics.strokeRoundedRect(1, 1, width - 2, height - 2, 8);
		}

		graphics.generateTexture(key, width, height);
		graphics.destroy();
	}
}
