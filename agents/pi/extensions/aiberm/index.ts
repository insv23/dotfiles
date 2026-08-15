import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerProvider("aiberm", {
    name: "Aiberm",
    baseUrl: "https://aiberm.com/v1",
    apiKey: "$PI_AIBERM_API_KEY",
    api: "openai-completions",
    models: [
      {
        id: "google/gemini-2.5-flash",
        name: "Gemini 2.5 Flash",
        reasoning: false,
        input: ["text", "image"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 1000000,
        maxTokens: 65536,
      },
      {
        id: "google/gemini-3.1-pro",
        name: "Gemini 3.1 Pro",
        reasoning: false,
        input: ["text", "image"],
        cost: { input: 0.46, output: 2.76, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 1048576,
        maxTokens: 65536,
      },
      {
        id: "claude-sonnet-4-6-thinking",
        name: "Claude Sonnet 4.6 Thinking",
        reasoning: true,
        thinkingLevelMap: {
          minimal: null,
          low: "low",
          medium: "medium",
          high: "high",
          xhigh: null,
        },
        input: ["text", "image"],
        cost: { input: 0.57, output: 2.85, cacheRead: 0.057, cacheWrite: 0.57 },
        contextWindow: 1000000,
        maxTokens: 64000,
      },
      {
        id: "openai/gpt-5.5",
        name: "GPT 5.5",
        reasoning: true,
        thinkingLevelMap: {
          minimal: null,
          low: "low",
          medium: "medium",
          high: "high",
          xhigh: null,
        },
        input: ["text", "image"],
        cost: { input: 0.69, output: 5.52, cacheRead: 0.069, cacheWrite: 0.69 },
        contextWindow: 1000000,
        maxTokens: 64000,
      },
    ],
  });
}
