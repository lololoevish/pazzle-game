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
	grassPatch: 0x22c55e,
	stonePebble: 0x94a3b8,
	torchGlow: 0xf97316,
	starSparkle: 0xfef3c7,
	townBanner: 0x7c3aed,
	moonLantern: 0xfef9c3,
	caveVine: 0x34d399,
	magicCircle: 0xa78bfa,
	softCloud: 0xe0f2fe,
	townPath: 0xb45309,
	glowMushroom: 0xfb7185,
	caveCrystalCluster: 0x67e8f9,
	stalactite: 0x64748b,
	runeStone: 0x818cf8,
	gearEmblem: 0xf59e0b,
	mirrorShard: 0x93c5fd,
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
		} else if (key === "grassPatch") {
			width = 48;
			height = 32;
		} else if (key === "stonePebble") {
			width = 32;
			height = 24;
		} else if (key === "torchGlow") {
			width = 64;
			height = 64;
		} else if (key === "starSparkle") {
			width = 24;
			height = 24;
		} else if (key === "townBanner") {
			width = 96;
			height = 72;
		} else if (key === "moonLantern") {
			width = 48;
			height = 72;
		} else if (key === "caveVine") {
			width = 44;
			height = 96;
		} else if (key === "magicCircle") {
			width = 96;
			height = 96;
		} else if (key === "softCloud") {
			width = 140;
			height = 64;
		} else if (key === "townPath") {
			width = 128;
			height = 64;
		} else if (key === "glowMushroom") {
			width = 48;
			height = 48;
		} else if (key === "caveCrystalCluster") {
			width = 72;
			height = 56;
		} else if (key === "stalactite") {
			width = 40;
			height = 80;
		} else if (key === "runeStone") {
			width = 56;
			height = 56;
		} else if (key === "gearEmblem") {
			width = 64;
			height = 64;
		} else if (key === "mirrorShard") {
			width = 56;
			height = 72;
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
			// Красивая градиентная тень под ногами
			graphics.fillStyle(0x000000, 0.4);
			graphics.fillEllipse(20, 44, 16, 5);
			graphics.fillStyle(0x000000, 0.25);
			graphics.fillEllipse(20, 44, 20, 7);

			// Струящийся плащ за спиной
			graphics.fillStyle(0x7c3aed, 0.95);
			graphics.fillRoundedRect(2, 8, 36, 32, 6);
			graphics.fillStyle(0x6d28d9, 1);
			graphics.fillRect(6, 12, 28, 28);

			// Тело с плавным градиентом
			graphics.fillGradientStyle(color, color, 0x0284c7, 0x0c4a6e, 1);
			graphics.fillRoundedRect(5, 3, 30, 38, 8);
			graphics.lineStyle(1.5, 0xe0f2fe, 0.65);
			graphics.strokeRoundedRect(5, 3, 30, 38, 8);

			// Выразительные глаза с бликами и зрачками
			graphics.fillStyle(0xffffff, 1);
			graphics.fillCircle(13, 14, 4);
			graphics.fillCircle(27, 14, 4);
			graphics.fillStyle(0x0369a1, 1);
			graphics.fillCircle(13, 14, 2);
			graphics.fillCircle(27, 14, 2);
			graphics.fillStyle(0xffffff, 1);
			graphics.fillCircle(14, 13, 1.2);
			graphics.fillCircle(28, 13, 1.2);

			// Светящийся амулет на груди
			graphics.fillStyle(0xfde68a, 1);
			graphics.fillTriangle(20, 22, 17, 26, 23, 26);
			graphics.fillStyle(0xf59e0b, 1);
			graphics.fillTriangle(20, 30, 17, 26, 23, 26);
		} else if (key.startsWith("npc")) {
			// Тень под ногами
			graphics.fillStyle(0x000000, 0.4);
			graphics.fillEllipse(20, 44, 16, 5);

			if (key === "npcElder") {
				// Староста в мудрой изумрудной мантии
				graphics.fillGradientStyle(0x047857, 0x047857, 0x064e3b, 0x022c22, 1);
				graphics.fillRoundedRect(4, 2, 32, 40, 10);
				graphics.lineStyle(2, 0x10b981, 0.45);
				graphics.strokeRoundedRect(4, 2, 32, 40, 10);

				// Глаза (прищуренные, мудрые)
				graphics.lineStyle(2.5, 0x1e293b, 0.8);
				graphics.lineBetween(10, 15, 15, 14);
				graphics.lineBetween(25, 14, 30, 15);

				// Пышная прорисованная борода с локонами
				graphics.fillStyle(0xf1f5f9, 0.95);
				graphics.fillTriangle(8, 20, 32, 20, 20, 43);
				graphics.fillStyle(0xe2e8f0, 0.85);
				graphics.fillTriangle(14, 20, 26, 20, 20, 38);

				// Посох с сияющей сферой
				graphics.fillStyle(0x78350f, 1);
				graphics.fillRect(32, 6, 4, 38); // Ручка посоха
				graphics.fillStyle(0xfbbf24, 1);
				graphics.fillRect(31, 2, 6, 4); // Золотое навершие
				graphics.fillStyle(0x60a5fa, 0.9);
				graphics.fillCircle(34, 0, 5); // Сияющая сфера
				graphics.fillStyle(0xffffff, 0.85);
				graphics.fillCircle(33, -1, 2); // Блик на сфере
			} else if (key === "npcMechanic") {
				// Механик в оранжевой куртке и прочном жилете
				graphics.fillGradientStyle(0xd97706, 0xd97706, 0x7c2d12, 0x451a03, 1);
				graphics.fillRoundedRect(4, 2, 32, 40, 8);
				graphics.lineStyle(1.5, 0xf59e0b, 0.5);
				graphics.strokeRoundedRect(4, 2, 32, 40, 8);

				// Защитный нагрудник
				graphics.fillStyle(0x4b5563, 1);
				graphics.fillRoundedRect(8, 22, 24, 18, 4);

				// Глаза и защитные очки на лбу
				graphics.fillStyle(0xffffff, 1);
				graphics.fillCircle(13, 15, 3.5);
				graphics.fillCircle(27, 15, 3.5);
				graphics.fillStyle(0x000000, 1);
				graphics.fillCircle(13, 15, 1.5);
				graphics.fillCircle(27, 15, 1.5);

				// Большие очки на лбу
				graphics.fillStyle(0x1e293b, 0.95);
				graphics.fillRect(6, 6, 28, 4);
				graphics.fillStyle(0xfacc15, 0.88);
				graphics.fillCircle(11, 8, 4);
				graphics.fillCircle(29, 8, 4);

				// Серебряный гаечный ключ за плечом
				graphics.fillStyle(0x9ca3af, 1);
				graphics.fillRect(32, 10, 3, 26);
				graphics.fillStyle(0x6b7280, 1);
				graphics.fillCircle(33.5, 9, 4);
				graphics.fillStyle(0x000000, 1);
				graphics.fillCircle(33.5, 9, 1.5); // Отверстие ключа
			} else if (key === "npcArchivist") {
				// Архивариус в мистической темной мантии со звездами
				graphics.fillGradientStyle(0x312e81, 0x312e81, 0x1e1b4b, 0x090514, 1);
				graphics.fillRoundedRect(4, 2, 32, 40, 9);
				graphics.lineStyle(2, 0xa78bfa, 0.55);
				graphics.strokeRoundedRect(4, 2, 32, 40, 9);

				// Золотая вышивка
				graphics.lineStyle(1.5, 0xfbbf24, 0.7);
				graphics.lineBetween(8, 22, 32, 22);
				graphics.lineBetween(8, 32, 32, 32);

				// Глаза и золотой монокль
				graphics.fillStyle(0xffffff, 1);
				graphics.fillCircle(13, 15, 3.5);
				graphics.fillCircle(27, 15, 3.5);
				graphics.fillStyle(0x000000, 1);
				graphics.fillCircle(13, 15, 1.5);
				graphics.fillCircle(27, 15, 1.5);

				// Монокль
				graphics.lineStyle(1.5, 0xf59e0b, 1);
				graphics.strokeCircle(13, 15, 5);
				graphics.lineBetween(8, 15, 4, 24); // Цепочка монокля

				// Левитирующая открытая книга
				graphics.fillStyle(0x4c1d95, 0.9);
				graphics.fillRoundedRect(31, 24, 11, 14, 2); // Обложка
				graphics.fillStyle(0xfef08a, 0.95);
				graphics.fillRect(32, 25, 9, 12); // Страницы
				graphics.lineStyle(1, 0x000000, 0.35);
				graphics.lineBetween(36, 25, 36, 37); // Разворот книги
			}
		} else if (key === "crystal") {
			// Красивая тень
			graphics.fillStyle(0x000000, 0.25);
			graphics.fillEllipse(16, 28, 13, 4.5);

			// Многогранный 3D кристалл
			// 1. Левая грань (темная)
			graphics.fillStyle(0x0891b2, 0.95);
			graphics.beginPath();
			graphics.moveTo(16, 1);
			graphics.lineTo(4, 16);
			graphics.lineTo(16, 31);
			graphics.closePath();
			graphics.fill();

			// 2. Правая грань (светлая)
			graphics.fillStyle(0x22d3ee, 0.95);
			graphics.beginPath();
			graphics.moveTo(16, 1);
			graphics.lineTo(28, 16);
			graphics.lineTo(16, 31);
			graphics.closePath();
			graphics.fill();

			// 3. Центральное светящееся ядро
			graphics.fillStyle(0xecfeff, 0.7);
			graphics.beginPath();
			graphics.moveTo(16, 4);
			graphics.lineTo(10, 16);
			graphics.lineTo(16, 28);
			graphics.lineTo(22, 16);
			graphics.closePath();
			graphics.fill();

			// 4. Ослепительные белые грани и блик
			graphics.lineStyle(1.5, 0xffffff, 0.85);
			graphics.beginPath();
			graphics.moveTo(16, 1);
			graphics.lineTo(4, 16);
			graphics.lineTo(16, 31);
			graphics.lineTo(28, 16);
			graphics.closePath();
			graphics.strokePath();

			graphics.lineStyle(1.2, 0xffffff, 0.6);
			graphics.lineBetween(16, 1, 16, 31);
			graphics.lineBetween(4, 16, 28, 16);

			// 5. Искры вокруг
			graphics.fillStyle(0xffffff, 0.8);
			graphics.fillRect(4, 4, 2, 2);
			graphics.fillRect(26, 6, 2, 2);
			graphics.fillRect(5, 25, 2, 2);
			graphics.fillRect(25, 24, 2, 2);
		} else if (key === "lever") {
			// Тень
			graphics.fillStyle(0x000000, 0.35);
			graphics.fillEllipse(20, 44, 19, 6.5);

			// Каменный резной постамент
			graphics.fillGradientStyle(0x374151, 0x374151, 0x1f2937, 0x111827, 1);
			graphics.fillRoundedRect(3, 33, 34, 13, 5);
			graphics.lineStyle(1.5, 0x4b5563, 0.8);
			graphics.strokeRoundedRect(3, 33, 34, 13, 5);

			// Рунический символ на постаменте
			graphics.lineStyle(1, 0xef4444, 0.85);
			graphics.strokeCircle(20, 39, 3.5);

			// Металлическая ось
			graphics.fillStyle(0x9ca3af, 1);
			graphics.fillCircle(20, 33, 6);

			// Прочный рычаг
			graphics.lineStyle(4.5, 0x4b5563, 1);
			graphics.lineBetween(20, 33, 20, 11);
			graphics.lineStyle(2, 0xd1d5db, 0.8);
			graphics.lineBetween(20, 32, 20, 12);

			// Светящийся набалдашник с красивой аурой
			graphics.fillStyle(0xef4444, 0.22);
			graphics.fillCircle(20, 9, 13); // Аура свечения
			graphics.fillStyle(0xef4444, 1);
			graphics.fillCircle(20, 9, 7.5); // Сам шар
			graphics.fillStyle(0xffffff, 0.8);
			graphics.fillCircle(17.5, 6.5, 2.5); // Четкий блик
		} else if (key === "caveEntrance") {
			// Величественная каменная арка
			graphics.fillStyle(0x0f172a, 1); // Темный зев пещеры
			graphics.fillEllipse(36, 40, 58, 62);

			// Мистический портал с градиентом
			graphics.fillGradientStyle(0x1e1b4b, 0x1e1b4b, 0x311042, 0x05010a, 0.65);
			graphics.fillEllipse(36, 40, 50, 54);

			// Левая и правая каменные колонны
			graphics.fillGradientStyle(0x4b5563, 0x374151, 0x1f2937, 0x111827, 1);
			graphics.fillRoundedRect(2, 10, 14, 62, 4);
			graphics.fillRoundedRect(56, 10, 14, 62, 4);

			// Каменное оголовье арки
			graphics.fillRoundedRect(2, 4, 68, 12, 4);

			// Рельефные швы на камнях
			graphics.lineStyle(1.5, 0x111827, 0.8);
			for (let i = 1; i < 4; i++) {
				graphics.lineBetween(2, 10 + i * 16, 16, 10 + i * 16);
				graphics.lineBetween(56, 10 + i * 16, 70, 10 + i * 16);
			}

			// Светящиеся неоновые руны на колоннах
			graphics.fillStyle(color, 0.85);
			// Левые руны
			graphics.fillCircle(9, 20, 2.5);
			graphics.fillTriangle(9, 36, 6, 41, 12, 41);
			graphics.fillRect(7, 54, 4, 4);
			// Правые руны
			graphics.fillCircle(63, 20, 2.5);
			graphics.fillTriangle(63, 36, 60, 41, 66, 41);
			graphics.fillRect(61, 54, 4, 4);

			// Золотая окантовка портала
			graphics.lineStyle(2, 0xfdba74, 0.8);
			graphics.strokeEllipse(36, 40, 50, 54);
		} else if (key === "uiPanel") {
			// Богатая фэнтезийная панель с золотыми заклепками по углам
			graphics.fillStyle(0x1e293b, 1); // Внутренний фон кожи
			graphics.fillRoundedRect(0, 0, width, height, 12);

			// Текстура кожи/холста
			graphics.fillStyle(0x0f172a, 0.2);
			for (let i = 0; i < 15; i++) {
				graphics.fillRect(Math.random() * width, Math.random() * height, 4, 4);
			}

			// Прочная темная рамка
			graphics.lineStyle(4.5, 0x0f172a, 1);
			graphics.strokeRoundedRect(2, 2, width - 4, height - 4, 12);

			// Внутренняя изящная золотая каемка
			graphics.lineStyle(2, 0xd97706, 0.8);
			graphics.strokeRoundedRect(6, 6, width - 12, height - 12, 8);

			// Золотые заклепки по 4 углам
			graphics.fillStyle(0xfbbf24, 1);
			graphics.fillCircle(10, 10, 3);
			graphics.fillCircle(width - 10, 10, 3);
			graphics.fillCircle(10, height - 10, 3);
			graphics.fillCircle(width - 10, height - 10, 3);
		} else if (key === "button") {
			// Великолепная объемная кнопка
			graphics.fillGradientStyle(color, color, 0x1e293b, 0x0f172a, 1);
			graphics.fillRoundedRect(0, 0, width, height, 6);

			// Объемная каемка (блик сверху, тень снизу)
			graphics.lineStyle(2, 0xffffff, 0.35);
			graphics.strokeRoundedRect(1, 1, width - 2, height - 2, 6);
			graphics.lineStyle(1.5, 0x000000, 0.5);
			graphics.lineBetween(1, height - 2, width - 2, height - 2);
		} else if (key === "tileFloor") {
			// Текстурный плиточный пол (изысканный паркет)
			graphics.fillStyle(color, 1);
			graphics.fillRect(0, 0, width, height);

			graphics.lineStyle(1, 0x000000, 0.25);
			graphics.strokeRect(0, 0, width, height);

			graphics.lineStyle(1, 0xffffff, 0.08);
			graphics.lineBetween(1, 1, width - 2, 1);
			graphics.lineBetween(1, 1, 1, height - 2);
		} else if (key === "caveWall") {
			// Объемный и брутальный каменный блок для пещерных перегородок
			graphics.fillGradientStyle(color, color, 0x0f172a, 0x020617, 1);
			graphics.fillRoundedRect(0, 0, width, height, 6);

			// Грубая фактура камня
			graphics.lineStyle(2.5, 0x334155, 0.95);
			graphics.strokeRoundedRect(1.5, 1.5, width - 3, height - 3, 6);

			// Трещины на камне
			graphics.lineStyle(1.5, 0x020617, 0.6);
			graphics.lineBetween(8, 16, 42, 12);
			graphics.lineBetween(42, 12, 54, 32);
			graphics.lineBetween(14, 46, 48, 50);

			// Светящиеся мелкие частички кристаллов в стене
			graphics.fillStyle(0x67e8f9, 0.85);
			graphics.fillRect(14, 26, 2, 2);
			graphics.fillRect(48, 18, 2, 2);
			graphics.fillRect(28, 42, 2, 2);
		} else if (key === "runeGlow") {
			// Энергетическая светящаяся руна
			graphics.fillStyle(color, 0.16);
			graphics.fillCircle(24, 24, 23);
			graphics.fillStyle(color, 0.26);
			graphics.fillCircle(24, 24, 15);

			// Внутренний сияющий контур
			graphics.lineStyle(2.2, color, 0.9);
			graphics.strokeCircle(24, 24, 11);
			graphics.lineStyle(1.5, 0xffffff, 0.7);
			graphics.strokeCircle(24, 24, 7);

			// Перекрестные рунические лучи
			graphics.lineStyle(1.8, color, 0.8);
			graphics.lineBetween(24, 4, 24, 44);
			graphics.lineBetween(4, 24, 44, 24);
		} else if (key === "mist") {
			// Живой и атмосферный туман
			graphics.fillStyle(color, 0.08);
			graphics.fillEllipse(34, 30, 78, 24);
			graphics.fillStyle(color, 0.06);
			graphics.fillEllipse(78, 34, 90, 28);
			graphics.fillStyle(0xffffff, 0.05);
			graphics.fillEllipse(58, 22, 70, 18);
		} else if (key === "grassPatch") {
			// Декоративная живая трава
			graphics.fillStyle(0x000000, 0.2);
			graphics.fillEllipse(24, 28, 36, 8);
			for (let i = 0; i < 9; i++) {
				const x = 7 + i * 4;
				const bladeHeight = 11 + (i % 3) * 6;
				graphics.lineStyle(2.5, color, 0.95);
				graphics.lineBetween(
					x,
					27,
					x + Phaser.Math.Between(-3, 3),
					27 - bladeHeight,
				);
				graphics.lineStyle(1.5, 0xdcfce7, 0.7);
				graphics.lineBetween(x + 1, 27, x + 2, 18);
			}
			// Маленький цветок
			graphics.fillStyle(0xfef08a, 0.95);
			graphics.fillCircle(34, 14, 2.5);
			graphics.fillStyle(0xef4444, 0.9);
			graphics.fillCircle(32, 12, 1.5);
			graphics.fillCircle(36, 12, 1.5);
			graphics.fillCircle(34, 16, 1.5);
		} else if (key === "stonePebble") {
			// Маленький камень/галька для глубины пола.
			graphics.fillStyle(0x000000, 0.18);
			graphics.fillEllipse(16, 20, 22, 6);
			graphics.fillGradientStyle(color, 0xe2e8f0, 0x475569, 0x334155, 1);
			graphics.fillEllipse(16, 12, 24, 16);
			graphics.lineStyle(1, 0x0f172a, 0.4);
			graphics.strokeEllipse(16, 12, 24, 16);
			graphics.lineStyle(1, 0xffffff, 0.25);
			graphics.lineBetween(9, 8, 19, 6);
		} else if (key === "torchGlow") {
			// Теплое пятно света/факел без физики.
			graphics.fillStyle(color, 0.1);
			graphics.fillCircle(32, 32, 30);
			graphics.fillStyle(color, 0.18);
			graphics.fillCircle(32, 32, 18);
			graphics.fillStyle(0xfef3c7, 0.9);
			graphics.fillTriangle(32, 12, 43, 39, 21, 39);
			graphics.fillStyle(0xef4444, 0.85);
			graphics.fillTriangle(32, 20, 39, 40, 25, 40);
		} else if (key === "starSparkle") {
			// Маленькая искра/пыльца.
			graphics.lineStyle(2, color, 0.9);
			graphics.lineBetween(12, 1, 12, 23);
			graphics.lineBetween(1, 12, 23, 12);
			graphics.lineStyle(1, 0xffffff, 0.7);
			graphics.lineBetween(5, 5, 19, 19);
			graphics.lineBetween(19, 5, 5, 19);
			graphics.fillStyle(color, 0.6);
			graphics.fillCircle(12, 12, 3);
		} else if (key === "townBanner") {
			// Тканевый баннер для оживления хаба.
			graphics.fillStyle(0x000000, 0.2);
			graphics.fillEllipse(48, 68, 70, 8);
			graphics.fillGradientStyle(0x8b5cf6, 0x6d28d9, 0x4c1d95, 0x312e81, 1);
			graphics.fillRoundedRect(8, 6, 80, 52, 8);
			graphics.fillTriangle(8, 48, 8, 70, 28, 56);
			graphics.fillTriangle(88, 48, 88, 70, 68, 56);
			graphics.lineStyle(3, 0xfef3c7, 0.85);
			graphics.lineBetween(14, 16, 82, 16);
			graphics.lineStyle(2, 0xfbbf24, 0.9);
			graphics.strokeCircle(48, 34, 12);
			graphics.lineBetween(48, 20, 48, 48);
			graphics.lineBetween(34, 34, 62, 34);
			graphics.fillStyle(0xffffff, 0.18);
			graphics.fillRoundedRect(14, 10, 28, 42, 6);
		} else if (key === "moonLantern") {
			// Тёплый подвесной фонарь со свечением.
			graphics.fillStyle(0xfef3c7, 0.12);
			graphics.fillCircle(24, 42, 28);
			graphics.lineStyle(2, 0x78350f, 0.8);
			graphics.lineBetween(24, 0, 24, 14);
			graphics.fillStyle(0x92400e, 1);
			graphics.fillRoundedRect(13, 15, 22, 34, 6);
			graphics.fillGradientStyle(0xfef9c3, 0xfacc15, 0xfb923c, 0xf97316, 1);
			graphics.fillEllipse(24, 32, 26, 30);
			graphics.lineStyle(2, 0x451a03, 0.6);
			graphics.strokeEllipse(24, 32, 26, 30);
			graphics.fillStyle(0xffffff, 0.35);
			graphics.fillEllipse(18, 25, 7, 10);
		} else if (key === "caveVine") {
			// Светящаяся лиана/корень для пещер.
			graphics.lineStyle(4, 0x14532d, 0.9);
			graphics.beginPath();
			graphics.moveTo(22, 0);
			graphics.lineTo(18, 18);
			graphics.lineTo(26, 38);
			graphics.lineTo(16, 62);
			graphics.lineTo(24, 96);
			graphics.strokePath();
			for (const leaf of [
				{ x: 14, y: 24 },
				{ x: 30, y: 42 },
				{ x: 12, y: 64 },
				{ x: 31, y: 78 },
			]) {
				graphics.fillStyle(color, 0.78);
				graphics.fillEllipse(leaf.x, leaf.y, 16, 8);
				graphics.fillStyle(0xecfccb, 0.5);
				graphics.fillCircle(leaf.x, leaf.y, 2);
			}
		} else if (key === "magicCircle") {
			// Волшебный рунический круг с пентаграммой и лучами
			graphics.fillStyle(color, 0.1);
			graphics.fillCircle(48, 48, 46);

			// Внешнее руническое кольцо
			graphics.lineStyle(2.5, color, 0.85);
			graphics.strokeCircle(48, 48, 42);
			graphics.lineStyle(1.2, color, 0.45);
			graphics.strokeCircle(48, 48, 38);

			// Звезда вписанная
			graphics.lineStyle(1.8, color, 0.75);
			graphics.beginPath();
			for (let i = 0; i <= 5; i++) {
				const angle = (i * 4 * Math.PI) / 5 - Math.PI / 2;
				const x = 48 + Math.cos(angle) * 32;
				const y = 48 + Math.sin(angle) * 32;
				if (i === 0) graphics.moveTo(x, y);
				else graphics.lineTo(x, y);
			}
			graphics.closePath();
			graphics.strokePath();

			// Внутреннее светящееся кольцо
			graphics.lineStyle(2, 0xffffff, 0.65);
			graphics.strokeCircle(48, 48, 20);

			// 8 рунических лучей с точками
			for (let i = 0; i < 8; i++) {
				const angle = (i * Math.PI) / 4;
				graphics.lineStyle(1, color, 0.35);
				graphics.lineBetween(
					48 + Math.cos(angle) * 12,
					48 + Math.sin(angle) * 12,
					48 + Math.cos(angle) * 36,
					48 + Math.sin(angle) * 36,
				);
				graphics.fillStyle(0xffffff, 0.85);
				graphics.fillCircle(
					48 + Math.cos(angle) * 20,
					48 + Math.sin(angle) * 20,
					1.5,
				);
			}

			// Центральное ядро
			graphics.fillStyle(0xffffff, 0.95);
			graphics.fillCircle(48, 48, 3.5);
		} else if (key === "softCloud") {
			// Роскошное пушистое облако с мягким закатным переливом
			graphics.fillStyle(color, 0.08);
			graphics.fillEllipse(70, 42, 120, 26);

			// Левая кучка
			graphics.fillStyle(0xfda4af, 0.22); // Розоватый
			graphics.fillEllipse(42, 34, 52, 24);
			// Центр
			graphics.fillStyle(color, 0.36); // Голубоватый
			graphics.fillEllipse(72, 26, 68, 32);
			// Правая кучка
			graphics.fillStyle(0xc084fc, 0.25); // Лавандовый
			graphics.fillEllipse(104, 36, 56, 26);

			// Мягкий золотистый блик от заката сверху
			graphics.fillStyle(0xfef08a, 0.16);
			graphics.fillEllipse(64, 20, 40, 14);
		} else if (key === "townPath") {
			// Неровная дорожная плитка для хаба.
			graphics.fillGradientStyle(0x92400e, 0x78350f, color, 0x451a03, 1);
			graphics.fillRoundedRect(0, 10, width, 44, 12);
			graphics.lineStyle(2, 0xfbbf24, 0.18);
			graphics.lineBetween(8, 24, 120, 18);
			graphics.lineBetween(10, 42, 118, 48);
			graphics.lineStyle(1, 0x000000, 0.25);
			for (let i = 0; i < 7; i++) {
				const x = 12 + i * 18;
				graphics.strokeRoundedRect(x, 18 + (i % 2) * 8, 16, 18, 4);
			}
		} else if (key === "glowMushroom") {
			// Светящийся гриб для пещерной биолюминесценции.
			graphics.fillStyle(color, 0.12);
			graphics.fillCircle(24, 24, 24);
			graphics.fillStyle(0xe5e7eb, 0.9);
			graphics.fillRoundedRect(19, 22, 10, 22, 5);
			graphics.fillGradientStyle(color, 0xfda4af, 0xbe123c, 0x881337, 1);
			graphics.fillEllipse(24, 20, 38, 24);
			graphics.fillStyle(0xffffff, 0.75);
			graphics.fillCircle(14, 17, 3);
			graphics.fillCircle(24, 12, 2);
			graphics.fillCircle(34, 19, 3);
		} else if (key === "caveCrystalCluster") {
			// Кластер кристаллов для стен и платформ.
			graphics.fillStyle(0x000000, 0.2);
			graphics.fillEllipse(36, 50, 54, 8);
			for (const shard of [
				{ x: 18, y: 38, h: 30, w: 12 },
				{ x: 34, y: 30, h: 42, w: 16 },
				{ x: 52, y: 40, h: 28, w: 12 },
			]) {
				graphics.fillStyle(color, 0.86);
				graphics.beginPath();
				graphics.moveTo(shard.x, shard.y - shard.h / 2);
				graphics.lineTo(shard.x + shard.w / 2, shard.y);
				graphics.lineTo(shard.x, shard.y + shard.h / 2);
				graphics.lineTo(shard.x - shard.w / 2, shard.y);
				graphics.closePath();
				graphics.fill();
				graphics.lineStyle(1, 0xffffff, 0.45);
				graphics.lineBetween(
					shard.x,
					shard.y - shard.h / 2,
					shard.x,
					shard.y + shard.h / 2,
				);
			}
		} else if (key === "stalactite") {
			graphics.fillStyle(0x000000, 0.18);
			graphics.fillEllipse(20, 8, 34, 10);
			graphics.fillGradientStyle(0x94a3b8, color, 0x334155, 0x0f172a, 1);
			graphics.fillTriangle(4, 4, 36, 4, 20, 78);
			graphics.lineStyle(1, 0xffffff, 0.18);
			graphics.lineBetween(20, 6, 17, 66);
			graphics.lineBetween(28, 10, 22, 54);
		} else if (key === "runeStone") {
			graphics.fillStyle(0x000000, 0.22);
			graphics.fillEllipse(28, 46, 42, 8);
			graphics.fillGradientStyle(0x475569, 0x334155, 0x1e293b, 0x0f172a, 1);
			graphics.fillRoundedRect(8, 8, 40, 38, 8);
			graphics.lineStyle(2, color, 0.9);
			graphics.lineBetween(28, 15, 20, 31);
			graphics.lineBetween(28, 15, 36, 31);
			graphics.lineBetween(20, 31, 36, 31);
			graphics.fillStyle(color, 0.22);
			graphics.fillCircle(28, 28, 18);
		} else if (key === "gearEmblem") {
			graphics.fillStyle(0x000000, 0.18);
			graphics.fillCircle(32, 34, 28);
			graphics.lineStyle(6, color, 0.9);
			graphics.strokeCircle(32, 32, 20);
			for (let i = 0; i < 8; i++) {
				const angle = (i / 8) * Math.PI * 2;
				graphics.lineBetween(
					32 + Math.cos(angle) * 18,
					32 + Math.sin(angle) * 18,
					32 + Math.cos(angle) * 28,
					32 + Math.sin(angle) * 28,
				);
			}
			graphics.fillStyle(0x111827, 1);
			graphics.fillCircle(32, 32, 8);
		} else if (key === "mirrorShard") {
			graphics.fillStyle(0x000000, 0.18);
			graphics.fillEllipse(28, 62, 38, 8);
			graphics.fillGradientStyle(0xe0f2fe, color, 0x60a5fa, 0x1e3a8a, 1);
			graphics.beginPath();
			graphics.moveTo(28, 2);
			graphics.lineTo(50, 24);
			graphics.lineTo(38, 66);
			graphics.lineTo(8, 54);
			graphics.lineTo(14, 18);
			graphics.closePath();
			graphics.fill();
			graphics.lineStyle(2, 0xffffff, 0.45);
			graphics.lineBetween(18, 20, 42, 26);
			graphics.lineBetween(20, 48, 36, 56);
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
