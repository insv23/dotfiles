import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MODEL_THINKING_LEVELS = {
	"openai-codex/gpt-5.5": "medium",
	"deepseek/deepseek-v4-pro": "high",
} as const;

type ThinkingLevel = (typeof MODEL_THINKING_LEVELS)[keyof typeof MODEL_THINKING_LEVELS];

function getModelKey(model: { provider: string; id: string }): string {
	return `${model.provider}/${model.id}`;
}

export default function (pi: ExtensionAPI) {
	function syncThinkingLevel(model: { provider: string; id: string } | undefined): void {
		if (!model) return;

		const level = MODEL_THINKING_LEVELS[getModelKey(model) as keyof typeof MODEL_THINKING_LEVELS] as
			| ThinkingLevel
			| undefined;
		if (!level) return;
		if (pi.getThinkingLevel() === level) return;

		pi.setThinkingLevel(level);
	}

	pi.on("session_start", async (_event, ctx) => {
		syncThinkingLevel(ctx.model);
	});

	pi.on("model_select", async (event) => {
		syncThinkingLevel(event.model);
	});
}
