# Who TM Needs Balance — Stellaris Mod Agent Guide

## Project

纯脚本模组，Honkai Impact 3rd 主题的 cheat/OP mod。Stellaris v4.5.*。所有文件/标识符使用 `wtmnb_` 前缀。

## 结构

- `events/` — 11 个事件文件，11 个 namespace
- `common/inline_scripts/` — 内联脚本复用；`wtmnb/parts/` 为条件编译的开关零件
- `common/scripted_effects/`、`common/scripted_triggers/`、`common/scripted_actions/` — 公用逻辑
- `common/scripted_variables/` — `@` 常量宏
- `common/on_actions/` — `wtmnb_on_actions.txt`
- `localisation/simp_chinese/` — 主要语言，`localisation/english/` 为次要
- `tools/` — 发布/开发辅助脚本，不随 mod 上传
- 上传白名单：`upload.bat` 只复制 `common events gfx interface localisation` + `descriptor.mod`/`thumbnail.png`，新增顶层内容目录时要同步改那里的 `for %%d in (...)`

## 本地化文件编码（UTF-8 with BOM）

`localisation/simp_chinese/*.yml` **必须**是 UTF-8 with BOM（首 3 字节 `EF BB BF`），否则游戏读不到中文；`localisation/english/*.yml` 不要 BOM。

- 检查：`head -c3 <file> | od -An -tx1 | tr -d ' \n'` → `efbbbf`
- 补 BOM（幂等，可反复执行）：`[ "$(head -c3 F | od -An -tx1 | tr -d ' \n')" = efbbbf ] || sed -i '1s/^/\xEF\xBB\xBF/' F`
- 文件工具会吞掉 BOM（已实测）：`read` 返回的首行不含 BOM，`edit` 哪怕只改别的行也会把 BOM 写没，`write` 仅在 content 以 `\uFEFF` 开头时才写出 BOM；因此用这些工具改过中文 yml 后必须按上面补回
- `.gitattributes` 兜不住：`working-tree-encoding` 只认 iconv 支持的编码名，写 `UTF-8-BOM` 会让 `git add` 直接 `fatal: failed to encode`（已实测），故只能靠编辑侧保证
- 发布闸门：`upload.bat` 开头会先调 `tools/check_localisation_bom.ps1`，任一文件缺 BOM 就中止上传；该脚本**必须保持纯 ASCII**，因为 PowerShell 5.1 会把无 BOM 的 `.ps1` 按系统 ANSI 码页解析

## Namespaces

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

## Event ID 约定 (`wtmnb` namespace)

`wtmnb.<number>`，数字按功能分段：

| 范围 | 用途 |
|------|------|
| 1–99 | 核心事件 |
| 1xxx | 轨道轰炸 |
| 4xxx | 风暴 |

其他 namespace 通常使用 1xxx–4xxx 范围，具体参照 `common/on_actions/wtmnb_on_actions.txt` 中的调用。

## 加载顺序技巧

- `!!!!` 前缀文件（如 `!!!!_wtmnb_dc_triggers.txt`）强制最早加载
- `~` 前缀文件（如 `~wtmnb_fallback_vars.txt`）强制最晚加载

## DC（多彩银河）集成

`!!!!_wtmnb_dc_triggers.txt` 是 DC mod 未安装时的 placeholder，其中 `is_cg_empire`、`is_lust_empire` 等 trigger 均返回 `always = no` 防止报错。**不要编辑此文件**。

## 关键约定

- Scripted effect/trigger：`snake_case`，带 `wtmnb_` 前缀；用 `# scope:` / `# this:` 注释说明作用域
- 内联脚本传参使用 `[[]]` 大写变量名：`CLASS`、`PLANET`、`TRAIT`、`TYPE`、`MULT`、`BY`
- 注释主要是中文，含幽默/吐槽风格
- 不使用触发式 `limit`（Stellaris 自动应用），`random_*` effect 需要 `limit = {}`
- action scope 链复杂，参考 `wtmnb_safe_destroy_fleet` 中的 `on_*_destroyed_*` 模式

## 调试

- script_documentation logs（`effects.log`、`triggers.log`）在 `opencode.json` 中已配置引用
- 纯脚本模组，无构建/测试/lint 系统

## 代码审核优先级

1. `events/` → `common/scripted_triggers/` → `common/scripted_effects/` → `common/inline_scripts/events/wtmnb_colossus/`（21 个子脚本）
2. 验证 scope 和 effect/trigger 语法时对照 `script_documentation`

## Git

- remote: `Dave-12138` → `https://github.com/Dave-12138/Stellaris-mod-Who-TM-Needs-Balance.git`
- commit message：中文或 `feat:`/`fix:`/`refactor:` 前缀
- `descriptor.mod` 的 `version` 格式为 `年.月.当月第几个版本`（如 `26.10.1` = 2026 年 10 月第 1 版）；只改 descriptor 的提交不 bump 版本号
- `.gitignore` 忽略 `.vscode/`、`*.vdf`、`*.bat`（`wtmnb.vdf` 已被跟踪，仍会入库）
- `wtmnb.vdf` 的 `description` 是一个跨多行的引号字符串，正文里**不能出现半角 `"`**（会提前截断 KeyValues，steamcmd 报 `RecursiveLoadFromBuffer` / `key name too long`）；需要引号时用全角 “”
