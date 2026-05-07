import { LEVEL_COUNT } from "./constants";

export type LevelProgress = {
	completed: boolean;
	leverPulled: boolean;
};

export type GameProgress = {
	currentLevel: number;
	gold: number;
	inventory: string[];
	npcRewards: Record<string, boolean>;
	levels: LevelProgress[];
};

export function createDefaultProgress(): GameProgress {
	return {
		currentLevel: 1,
		gold: 0,
		inventory: [],
		npcRewards: {
			elder: false,
			mechanic: false,
			archivist: false,
		},
		levels: Array.from({ length: LEVEL_COUNT }, () => ({
			completed: false,
			leverPulled: false,
		})),
	};
}

export function normalizeProgress(value: unknown): GameProgress {
	const fallback = createDefaultProgress();

	if (!value || typeof value !== "object") {
		return fallback;
	}

	const raw = value as Partial<GameProgress>;
	const levels = Array.from({ length: LEVEL_COUNT }, (_, index) => {
		const rawLevel = Array.isArray(raw.levels) ? raw.levels[index] : undefined;
		return {
			completed: Boolean(rawLevel?.completed),
			leverPulled: Boolean(rawLevel?.leverPulled),
		};
	});

	const completedCount = levels.filter((level) => level.completed).length;
	const currentLevel = Math.min(
		LEVEL_COUNT,
		Math.max(1, Number(raw.currentLevel) || completedCount + 1),
	);

	return {
		currentLevel,
		gold: Math.max(0, Number(raw.gold) || 0),
		inventory: Array.isArray(raw.inventory)
			? raw.inventory.filter((item) => typeof item === "string")
			: [],
		npcRewards: {
			elder: Boolean(raw.npcRewards?.elder),
			mechanic: Boolean(raw.npcRewards?.mechanic),
			archivist: Boolean(raw.npcRewards?.archivist),
		},
		levels,
	};
}

export function completeLevel(
	progress: GameProgress,
	levelNumber: number,
): GameProgress {
	const next = normalizeProgress(progress);
	const index = levelNumber - 1;

	if (index >= 0 && index < LEVEL_COUNT) {
		next.levels[index] = {
			completed: true,
			leverPulled: true,
		};
		next.gold += 10;
		next.currentLevel = Math.min(
			LEVEL_COUNT,
			Math.max(next.currentLevel, levelNumber + 1),
		);
	}

	return next;
}

export function getCompletedLevelCount(progress: GameProgress): number {
	return progress.levels.filter((level) => level.completed).length;
}

export function isExpeditionComplete(progress: GameProgress): boolean {
	return getCompletedLevelCount(progress) >= LEVEL_COUNT;
}
