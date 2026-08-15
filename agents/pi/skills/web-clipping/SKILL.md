---
name: web-clipping
description: Extract a webpage or pasted source into an Obsidian clipping note under /Users/tony/Documents/Ob2026/00-Inbox/_clippings using the vault clipping template. Use when the user asks to save a webpage, extract article body, create a web clipping, archive AI/chat/book/transcript content, or put clipped content into the Obsidian Inbox clipping folder from any working directory.
---

# Web Clipping

Use this skill to extract and clean source content for a clipping in the Obsidian vault at:

```text
/Users/tony/Documents/Ob2026
```

This skill owns source extraction and cleanup. It does not define frontmatter, reproduce the clipping template, or assemble the final note. The vault's `create-vault-note` skill owns template resolution, file creation, and structural verification.

## Workflow

1. Get the source URL or pasted content.
2. Determine the source title, original URL, source kind, and complete substantive content.
3. For a webpage, extract the main article or post. Preserve:
   - title and headings;
   - paragraphs, lists, blockquotes, code blocks, and tables;
   - meaningful links and images;
   - author-written updates and footnotes that belong to the source.
4. Remove page chrome and unrelated material:
   - navigation, sidebars, cookie notices, and advertisements;
   - share and subscription prompts;
   - comments outside the authored source;
   - related-post previews, recommendations, and page footers.
5. Normalize the Markdown:
   - resolve relative links and image URLs against the source page URL;
   - keep standard Markdown footnotes when extraction provides them;
   - otherwise turn same-page fragment links into full source URLs with fragments;
   - preserve code and quoted text without rewriting them.
6. Do not invent, summarize, translate, or reconstruct missing original text unless the user explicitly asks. If complete source extraction fails after available fetch and browser methods, report the failure; never save a search summary as `原文`.
7. Prepare this clipping input in the current context; do not create a temporary interchange file:
   - note type: `clipping`;
   - title;
   - original URL, or empty when none exists;
   - source kind: webpage, AI conversation, transcript, or book excerpt;
   - cleaned Markdown body;
   - answers for `我的三句话` only when the user explicitly requested them.
8. Before writing any note, read and follow:

   ```text
   /Users/tony/Documents/Ob2026/.agents/skills/create-vault-note/SKILL.md
   ```

9. Let `create-vault-note` read the current clipping template, choose `medium`, create the final file under `00-Inbox/_clippings/`, and verify its structure.
10. Report the final file path.

## Boundaries

- Direct source extraction and Markdown cleanup do not count as AI-generated substantive content.
- AI summaries, translations, reconstructions, and rewritten source text do count as AI-generated substantive content.
- Preserve all clipping-template prompts. When the user did not ask to fill `我的三句话`, leave their answer positions empty; never remove the prompt lines.
- Store downloaded attachments flat in `/Users/tony/Documents/Ob2026/_attachments/` and reference them by filename. Do not download remote images unless the user asks.
