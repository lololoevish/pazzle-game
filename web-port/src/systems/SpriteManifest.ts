import Phaser from "phaser";
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
	tileFloor: 0x1f2937,
	caveWall: 0x111827,
	runeGlow: 0x67e8f9,
	mist: 0xcbd5e1,
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
		} else if (key === "tileFloor") {
			width = 32;
			height = 32;
		} else if (key === "caveWall") {
			width = 64;
			height = 64;
		} else if (key === "runeGlow") {
			width = 48;
			height = 48;
		} else if (key === "mist") {
			width = 128;
			height = 64;
		}

		const graphics = scene.make.graphics({ x: 0, y: 0 }, false);
		const color = PLACEHOLDER_COLORS[key];

		if (key === "townBackground" || key === "caveBackground") {
			// Улучшенный фон с градиентом и шумом
			graphics.fillGradientStyle(color, color, 0x000000, 0x000000, 1);
			graphics.fillRect(0, 0, width, height);

			// Текстура
			if (key === "caveBackground") {
				// Камни и трещины
				graphics.lineStyle(2, 0x000000, 0.2);
				for (let i = 0; i < 50; i++) {
					const x = Math.random() * width;
					const y = Math.random() * height;
					const size = 10 + Math.random() * 40;
					graphics.beginPath();
					graphics.moveTo(x, y);
					graphics.lineTo(x + size, y + size / 2);
					graphics.strokePath();
				}
				graphics.lineStyle(1, 0xffffff, 0.05);
				for (let i = 0; i < 200; i++) {
					graphics.strokeCircle(
						Math.random() * width,
						Math.random() * height,
						Math.random() * 3,
					);
				}
			} else {
				// Трава и дорожки
				graphics.fillStyle(0x064e3b, 0.2);
				for (let i = 0; i < 100; i++) {
					graphics.fillEllipse(
						Math.random() * width,
						Math.random() * height,
						4,
						2,
					);
				}
				graphics.lineStyle(1, 0xffffff, 0.03);
				for (let i = 0; i < 400; i++) {
					const x = Math.random() * width;
					const y = Math.random() * height;
					graphics.lineBetween(x, y, x, y - 3);
				}
			}
		} else if (key === "player") {
			// Тень под ногами
			graphics.fillStyle(0x000000, 0.3);
			graphics.fillEllipse(20, 44, 15, 6);

			// Герой с глазами и "рюкзаком"
			graphics.fillStyle(color, 1);
			graphics.fillRoundedRect(4, 2, 32, 40, 8);
			graphics.lineStyle(2, 0xffffff, 0.5);
			graphics.strokeRoundedRect(4, 2, 32, 40, 8);

			// Глаза
			graphics.fillStyle(0xffffff, 1);
			graphics.fillRect(10, 12, 6, 6);
			graphics.fillRect(24, 12, 6, 6);
			graphics.fillStyle(0x000000, 1);
			graphics.fillRect(12, 14, 2, 2);
			graphics.fillRect(26, 14, 2, 2);
		} else if (key.startsWith("npc")) {
			// Тень
			graphics.fillStyle(0x000000, 0.3);
			graphics.fillEllipse(20, 44, 15, 6);

			// NPC с отличительными чертами
			graphics.fillStyle(color, 1);
			graphics.fillRoundedRect(4, 2, 32, 40, 10);
			graphics.lineStyle(2, 0x000000, 0.3);
			graphics.strokeRoundedRect(4, 2, 32, 40, 10);

			// Глаза
			graphics.lineStyle(2, 0x000000, 0.6);
			graphics.lineBetween(10, 16, 16, 16);
			graphics.lineBetween(24, 16, 30, 16);

			if (key === "npcElder") {
				// Борода
				graphics.fillStyle(0xffffff, 0.9);
				graphics.fillTriangle(10, 22, 30, 22, 20, 42);
			} else if (key === "npcMechanic") {
				// Пояс с инструментами
				graphics.fillStyle(0x4b5563, 1);
				graphics.fillRect(4, 26, 32, 6);
				graphics.fillStyle(0x9ca3af, 1);
				graphics.fillRect(10, 26, 4, 8); // Инструмент 1
				graphics.fillRect(26, 26, 4, 8); // Инструмент 2
			} else if (key === "npcArchivist") {
				// Монокль и книга
				graphics.lineStyle(1, 0xffd700, 1);
				graphics.strokeCircle(27, 16, 5);
				graphics.lineBetween(27, 11, 27, 3);
				graphics.fillStyle(0xffffff, 0.8);
				graphics.fillRect(8, 28, 12, 10); // Книжка
			}
		} else if (key === "crystal") {
			// Тень
			graphics.fillStyle(0x000000, 0.2);
			graphics.fillEllipse(16, 28, 12, 4);

			// Кристалл (многогранный ромб)
			graphics.fillStyle(color, 1);
			graphics.beginPath();
			graphics.moveTo(16, 0);
			graphics.lineTo(32, 16);
			graphics.lineTo(16, 32);
			graphics.lineTo(0, 16);
			graphics.closePath();
			graphics.fill();

			// Грани
			graphics.lineStyle(1, 0xffffff, 0.6);
			graphics.lineBetween(16, 0, 16, 32);
			graphics.lineBetween(0, 16, 32, 16);
			graphics.lineStyle(2, 0xffffff, 0.9);
			graphics.strokePath();

			// Блеск
			graphics.fillStyle(0xffffff, 0.6);
			graphics.fillTriangle(16, 4, 28, 16, 16, 16);
			graphics.fillTriangle(16, 28, 4, 16, 16, 16);
		} else if (key === "lever") {
			// Тень
			graphics.fillStyle(0x000000, 0.3);
			graphics.fillEllipse(20, 44, 18, 6);

			// Рычаг с основанием
			graphics.fillStyle(0x374151, 1);
			graphics.fillRoundedRect(4, 34, 32, 12, 4);
			graphics.lineStyle(4, 0x9ca3af, 1);
			graphics.lineBetween(20, 36, 20, 12);

			// Набалдашник с бликом
			graphics.fillStyle(0xef4444, 1);
			graphics.fillCircle(20, 10, 8);
			graphics.fillStyle(0xffffff, 0.4);
			graphics.fillCircle(17, 7, 3);
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
		} else if (key === "tileFloor") {
			// Плитка пола
			graphics.fillStyle(color, 1);
			graphics.fillRect(0, 0, width, height);
			graphics.lineStyle(1, 0x000000, 0.3);
			graphics.strokeRect(0, 0, width, height);
			graphics.lineStyle(1, 0xffffff, 0.1);
			graphics.strokeRect(1, 1, width - 2, height - 2);
		} else if (key === "caveWall") {
			// Неровный каменный блок для стен и платформ.
			graphics.fillGradientStyle(color, color, 0x020617, 0x020617, 1);
			graphics.fillRoundedRect(0, 0, width, height, 6);
			graphics.lineStyle(2, 0x475569, 0.7);
			graphics.strokeRoundedRect(1, 1, width - 2, height - 2, 6);
			graphics.lineStyle(1, 0x000000, 0.35);
			graphics.lineBetween(8, 18, 56, 14);
			graphics.lineBetween(12, 42, 48, 50);
			graphics.lineBetween(30, 6, 22, 34);
			graphics.lineStyle(1, 0xffffff, 0.1);
			for (let i = 0; i < 12; i++) {
				graphics.strokeCircle(
					Phaser.Math.Between(6, width - 6),
					Phaser.Math.Between(6, height - 6),
					Phaser.Math.Between(1, 3),
				);
			}
		} else if (key === "runeGlow") {
			// Магическая руна с мягким свечением.
			graphics.fillStyle(color, 0.14);
			graphics.fillCircle(24, 24, 22);
			graphics.fillStyle(color, 0.22);
			graphics.fillCircle(24, 24, 14);
			graphics.lineStyle(3, color, 0.95);
			graphics.strokeCircle(24, 24, 10);
			graphics.lineBetween(24, 10, 24, 38);
			graphics.lineBetween(12, 24, 36, 24);
			graphics.lineStyle(2, 0xffffff, 0.7);
			graphics.strokeCircle(24, 24, 4);
		} else if (key === "mist") {
			// Полупрозрачный слой тумана для глубины.
			graphics.fillStyle(color, 0.08);
			graphics.fillEllipse(34, 30, 78, 24);
			graphics.fillStyle(color, 0.06);
			graphics.fillEllipse(78, 34, 90, 28);
			graphics.fillStyle(0xffffff, 0.07);
			graphics.fillEllipse(58, 22, 70, 18);
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
