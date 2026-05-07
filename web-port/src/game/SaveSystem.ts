import { SAVE_KEY } from "./constants";
import {
	createDefaultProgress,
	type GameProgress,
	normalizeProgress,
} from "./GameState";

export function loadProgress(): GameProgress {
	const raw = window.localStorage.getItem(SAVE_KEY);

	if (!raw) {
		return createDefaultProgress();
	}

	try {
		return normalizeProgress(JSON.parse(raw));
	} catch {
		return createDefaultProgress();
	}
}

export function saveProgress(progress: GameProgress): void {
	window.localStorage.setItem(
		SAVE_KEY,
		JSON.stringify(normalizeProgress(progress)),
	);
}

export function resetProgress(): GameProgress {
	const progress = createDefaultProgress();
	saveProgress(progress);
	return progress;
}

export function hasSave(): boolean {
	return window.localStorage.getItem(SAVE_KEY) !== null;
}
