// input: Pi before_agent_start event and ~/.pi/agent/skills/caveman/SKILL.md
// output: System prompt augmented with Caveman full-mode instructions
// pos: Global Pi extension that auto-enables Caveman full for every agent turn
// If this file changes, update this header comment and parent folder docs if present.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { join } from "node:path";

function stripFrontmatter(markdown: string): string {
  return markdown.replace(/^---\n[\s\S]*?\n---\n?/, "").trim();
}

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", (event, ctx) => {
    const home = process.env.HOME;
    if (!home) {
      ctx.ui.notify("auto-caveman: HOME is not set", "warn");
      return { systemPrompt: event.systemPrompt };
    }

    const skillPath = join(home, ".pi/agent/skills/caveman/SKILL.md");

    try {
      const skillBody = stripFrontmatter(readFileSync(skillPath, "utf8"));
      const cavemanPrompt = [
        `<skill name="caveman" location="${skillPath}">`,
        `References are relative to ${join(home, ".pi/agent/skills/caveman")}.`,
        "",
        skillBody,
        "</skill>",
        "",
        "full",
      ].join("\n");

      return {
        systemPrompt: `${event.systemPrompt}\n\n${cavemanPrompt}`,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      ctx.ui.notify(`auto-caveman: failed to load caveman skill: ${message}`, "warn");
      return { systemPrompt: event.systemPrompt };
    }
  });
}
