# Who TM Needs Balance — Stellaris Mod Agent Guide

## Project

- Honkai Impact 3rd 主题的 cheat/OP 模组；`descriptor.mod` 声明 Stellaris `v4.5.*`，工坊 id `2463706913`。
- **纯脚本模组**：没有构建、测试、lint、依赖安装，改完就是最终产物。
- 所有文件与标识符用 `wtmnb_` 前缀；注释以中文为主，带幽默/吐槽风格。
- 发布链路：`upload.bat`（宿主 Windows）→ 重建 `../wtmnb_dist` → steamcmd + `wtmnb.vdf`。

## Commands

- 没有 install/build/test/lint。语法与字段校验只有两条路：
  - **CWTools MCP**：语言服务跑在宿主，容器侧经 `ws_mcp_call` 调 `@<工作区根>/cwt`；`get_diagnostics` 期望 `errors: 0, warnings: 0`。`file` 参数**必须传宿主绝对路径**（`C:/Users/<用户>/Documents/Paradox Interactive/Stellaris/mod/<mod>/...`），传相对路径会报“无法读取文件”。环境准备与排障见 skill `stellaris-mod-env`。
  - 对照只读原版挂载点 `/ref/stellaris` 下同目录、同名字段的写法。
- 中文 yml 补 BOM：`node tools/fix_localisation_bom.mjs`（就地补齐，幂等）；加 `--check` 只检查、缺 BOM 时退出码 1。
- 发布：`upload.bat` —— 先补 BOM，再按白名单重建 `../wtmnb_dist`，最后上传。
- 调试用的 `script_documentation` 日志（`effects.log`、`triggers.log`）在仓库外 `../../logs/script_documentation`，可查合法的 effect/trigger 列表。

## Architecture

- `events/` — 11 个事件文件 = 11 个 namespace，见下表。
- `common/` — 数据定义，逐目录照原版 `/ref/stellaris/common/<同名目录>` 的写法：`buildings/`、`edicts/`、`decisions/`、`megastructures/`、`ship_*`、`technology/`、`traits/`、`scripted_effects|triggers|actions|values|loc/`、`on_actions/wtmnb_on_actions.txt` 等。
- `common/inline_scripts/` — 58 个内联脚本；其中 `events/wtmnb_colossus/` 是 21 个巨像选项，`wtmnb/parts/` 是条件编译零件（`switch.txt` 按 `$SW$` 转发到 `l_0`/`l_2`）。
- `common/scripted_variables/` — `@` 常量宏；`~wtmnb_fallback_vars.txt` 放别的 mod 没装时的兜底值。
- `localisation/simp_chinese/` 为主语言、`localisation/english/` 为次语言；`gfx/`、`interface/` 是图标与模型等资源。
- `tools/` — 开发/发布脚本，不随 mod 上传。
- 改动/审核优先级：`events/` → `common/scripted_triggers/` → `common/scripted_effects/` → `common/inline_scripts/events/wtmnb_colossus/`。

### Namespaces

| 文件 | namespace |
|------|-----------|
| `wtmnb_events.txt` | `wtmnb` |
| `wtmnb_colossus_events.txt` | `wtmnb_colossus` |
| `wtmnb_diplomacy_events.txt` | `wtmnb_diplomacy` |
| `wtmnb_dc_events.txt` | `wtmnb_dc` |
| `wtmnb_species_events.txt` | `wtmnb_species` |
| `wtmnb_battle_events.txt` | `wtmnb_battle` |
| `wtmnb_ship_skill_events.txt` | `wtmnb_ship_skill` |
| `wtmnb_ship_events.txt` | `wtmnb_ships` |
| `wtmnb_science_ship_events.txt` | `wtmnb_scienceship` |
| `wtmnb_boomer_events.txt` | `wtmnb_boomer` |
| `wtmnb_starbase_building_events.txt` | `wtmnb_starbase` |

### Event ID 约定（`wtmnb` namespace）

| 范围 | 用途 |
|------|------|
| 1–99 | 核心事件 |
| 1xxx | 轨道轰炸 |
| 4xxx | 风暴 |

其他 namespace 一般用 1xxx–4xxx，实际调用点见 `common/on_actions/wtmnb_on_actions.txt`。

### 加载顺序技巧

- `!!!!` 前缀（如 `!!!!_wtmnb_dc_triggers.txt`）= 强制最早加载。
- `~` 前缀（如 `~wtmnb_fallback_vars.txt`）= 强制最晚加载。

### DC（多彩银河）集成

`!!!!_wtmnb_dc_triggers.txt` 是 DC mod 未安装时的 placeholder：`is_cg_empire`、`is_lust_empire` 等 trigger 一律 `always = no`，用来防止报错。**不要编辑这个文件**。

## Conventions

- scripted effect / trigger：`snake_case` + `wtmnb_` 前缀；作用域绕的地方用 `# scope:fleet` / `# scope: planet` 注释标注。
- 内联脚本传参：脚本体内写 `$NAME$`，调用处写大写 `NAME = value`（如 `script = buildings/wtmnb_little_safe` + `MULT = ...`）。
- effect 里的条件块是 `[[TRIGGER] … ]` / `[[!TRIGGER] … ]` —— 这是条件执行语法，**不是**内联脚本传参。
- 不使用触发式 `limit`（Stellaris 会自动应用）；`random_*` effect 需要显式 `limit = {}`。
- action scope 链很绕，照 `wtmnb_safe_destroy_fleet` 里的 `on_*_destroyed_*` 模式写。

### 本地化文件编码（UTF-8 with BOM）

`localisation/simp_chinese/*.yml` **必须**是 UTF-8 with BOM（首 3 字节 `EF BB BF`），否则游戏读不到中文；`localisation/english/*.yml` 不要 BOM。

- 检查：`head -c3 <file> | od -An -tx1 | tr -d ' \n'` → `efbbbf`
- 补 BOM：`node tools/fix_localisation_bom.mjs`（幂等；`--check` 只检查不改，缺 BOM 返回 1）
- 文件工具会吞掉 BOM（已实测）：`read` 返回的首行不含 BOM，`edit` 哪怕只改别的行也会把 BOM 写没，`write` 仅在 content 以 `\uFEFF` 开头时才写出 BOM；因此用这些工具改过中文 yml 后必须补回
- `.gitattributes` 兜不住：`working-tree-encoding` 只认 iconv 编码名，写 `UTF-8-BOM` 会让 `git add` 直接 `fatal: failed to encode`（已实测）

### Git

- remote：`Dave-12138` → `https://github.com/Dave-12138/Stellaris-mod-Who-TM-Needs-Balance.git`，分支 `master`。
- commit message：中文，`feat:` / `fix:` / `refactor:` 等 Angular 前缀。
- 只改 `descriptor.mod` 的提交不 bump `version`；`version` 格式为 `年.月.当月第几个版本`（`26.10.1` = 2026 年 10 月第 1 版）。
- `.gitignore` 只忽略 `.vscode/`、`.cwtools-ai/`、`.dsh/*/`（`.dsh/` 顶层的文件仍可跟踪）；`upload.bat`、`wtmnb.vdf` 都是已跟踪文件。

## Pitfalls

- **改名/改键名不会报错，只会静默失效**：star flag、本地化键名改了就查不到（如 `has_star_flag` 恒为 false）。
- `wtmnb.vdf` 的 `description` 是多行引号字符串，正文里**不能出现半角 `"`**（会提前截断 KeyValues，steamcmd 报 `RecursiveLoadFromBuffer` / `key name too long`）；需要引号时用全角 “”。
- 上传白名单在 `upload.bat` 的 `for %%d in (common events gfx interface localisation)`：**新增顶层内容目录必须同步改这一行**，否则不会进上传包。
- `!!!!_wtmnb_dc_triggers.txt` 是 DC 占位符，改了会破坏 DC 兼容，**保持原样**。
- 上传前会自动补 BOM，所以上传后 `git status` 里出现中文 yml 改动属正常，记得提交。
- git 的 `CRLF will be replaced by LF` 警告是 `core.autocrlf=input` 的正常现象，忽略即可。

## Maintenance

- 本文件是活的：发现新的命令、约定、坑就在对应段落就地更新，删掉过时内容；只写验证过的事实，保持简短。
- 不要另建 `CLAUDE.md` 或其它替代文件。
