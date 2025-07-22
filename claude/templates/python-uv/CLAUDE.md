### 🔄 Project Awareness & Context
- Always read @.claude/OVERVIEW.md at the start of a new conversation to understand the project's architecture, goals, style, and constraints.
- Check @.claude/ROADMAP.md before starting a new task. If the task isn’t listed, add it with a brief description and today's date.
- Use consistent naming conventions, file structure, and architecture patterns as described in `@.claude/ROADMAP.md`.

### 🧱 Code Structure & Modularity
- **Never create a file longer than 500 lines of code.** If a file approaches this limit, refactor by splitting it into modules or helper files.
- **Organize code into clearly separated modules**, grouped by feature or responsibility.
- **Use clear, consistent imports** (prefer relative imports within packages).
- **Use python_dotenv and load_env()** for environment variables.

### 📎 Style & Conventions
- **Use Python** as the primary language.
- **Follow PEP8**
- Write **docstrings for every function** using the Google style:
  ```python
  def example():
      """
      Brief summary.

      Args:
          param1 (type): Description.

      Returns:
          type: Description.
      """
  ```
- When you generate the Python code, you must adhere to the following **strict type annotation** rules:
  1. Strict Typing: All function and method definitions must include type hints for every argument and for the return value (e.g., `⁠def my_function(name: str, count: int) -> bool:` ).
  2. No ⁠`Any` Type: The use of `⁠typing.Any` is forbidden. You must always specify the exact type. If a variable can hold multiple types, use `⁠typing.Union` (e.g., ⁠`Union[str, int]` ). If a value can be `⁠None`, use `⁠typing.Optional` (e.g., `⁠Optional[str]` ).	
  3. Specific Collections: Use specific types from the ⁠typing module for collections. For example:
     - Use `⁠List[str]` instead of ⁠`list`.
     - Use `⁠Dict[str, int]` instead of `⁠dict`.
     - Use `⁠Tuple[str, bool, int]` instead of `⁠tuple`.
     - Variable Annotation: Annotate all variables, especially when their type is not immediately obvious from the assignment.

### 🧪 Testing & Reliability
- **Always create Pytest unit tests for new features** (functions, classes, routes, etc).
- **After updating any logic**, check whether existing unit tests need to be updated. If so, do it.
- **Tests should live in a `/tests` folder** mirroring the main app structure.
  - Include at least:
    - 1 test for expected use
    - 1 edge case
    - 1 failure case

### ✅ Task Completion
- **Mark completed tasks in `TASK.md`** immediately after finishing them.
- Add new TODOs discovered during development to `@.claude/ROADMAP.md` under a “Discovered During Work” section.

### 📚 Documentation & Explainability
- **Update `README.md`** when new features are added, dependencies change, or setup steps are modified.
- **Comment non-obvious code** and ensure everything is understandable to a mid-level developer.
- When writing complex logic, **add an inline `# Reason:` comment** explaining the why, not just the what.

### 🧠 AI Behavior Rules
- **Never assume missing context. Ask questions if uncertain.**
- **Never hallucinate libraries or functions** – only use known, verified Python packages.
- **Always confirm file paths and module names** exist before referencing them in code or tests.
- **Never delete or overwrite existing code** unless explicitly instructed to or if part of a task from `TASK.md`.

### 🔄 Code Reuse & Extension Principles
- **ALWAYS analyze existing code before creating new files.** Look for similar functionality that can be extended.
- **Prioritize extending existing services and components** over creating new ones.
- **When suggesting new files, provide exhaustive justification** explaining why existing files cannot be extended.
- **Reference specific existing files** when proposing changes - avoid generic recommendations.
- **Consolidate duplicate code** - if you find similar functions/classes, refactor to reuse them.
- **Follow existing architecture patterns** - maintain consistency with current codebase structure.