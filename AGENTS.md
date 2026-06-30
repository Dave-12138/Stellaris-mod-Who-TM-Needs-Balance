# Who TM Needs Balance — Stellaris Mod Agent Guide

## Project

纯脚本模组，Honkai Impact 3rd 主题的 cheat/OP mod。Stellaris v4.4.*。所有文件/标识符使用 `wtmnb_` 前缀。

## 结构

- `events/` — 10 个事件文件，7 个 namespace（`wtmnb`、`wtmnb_colossus`、`wtmnb_diplomacy`、`wtmnb_dc`、`wtmnb_species`、`wtmnb_battle`、`wtmnb_fort_skill`）
- `common/inline_scripts/` — 大量内联脚本复用；`wtmnb/parts/` 为条件编译（`code_if`/`load_if`）的开关零件
- `common/scripted_effects/`、`common/scripted_triggers/`、`common/scripted_actions/` — 公用逻辑
- `common/scripted_variables/` — `@` 常量宏
- `localisation/simp_chinese/` — 主要语言，`localisation/english/` 为次要
- `gfx/`、`interface/` — 图标、模型、弹道定义

## Event ID 约定

`<namespace>.<number>`，数字按功能分段：

| 范围     | 用途             |
| -------- | ---------------- |
| 1–99     | 核心事件         |
| 1xxx     | 轨道轰炸         |
| 2xxx     | 崩坏裂变弹       |
| 3xxx     | 跃迁/弹射        |
| 4xxx     | 风暴             |
| 5xxx     | 空间站建筑       |
| 6xxx     | 超距射击         |
| 7xxx     | 科研船           |
| 8xxx     | 战斗光环         |

colossus/fortress 用 `wtmnb_colossus.1xxx–4xxx`，外交用 `wtmnb_diplomacy.1–1xxx`。

## 加载顺序技巧

- `!!!!` 前缀文件（如 `!!!!_wtmnb_dc_triggers.txt`）强制最早加载
- `~` 前缀文件（如 `~wtmnb_fallback_vars.txt`）强制最晚加载

## DC（多彩银河）集成

DC 内容依赖多彩银河 mod。`!!!!_wtmnb_dc_triggers.txt` 是 DC mod 未安装时的 placeholder，其中 `is_cg_empire`、`is_lust_empire` 等 trigger 均返回 `always = no` 防止报错。不要编辑此文件。

## 关键约定

- Scripted effect/trigger：`snake_case`，带 `wtmnb_` 前缀；用 `# scope:` / `# this:` 注释说明作用域
- 内联脚本传参使用`[[]]`大写变量名：`CLASS`、`PLANET`、`TRAIT`、`TYPE`、`MULT`、`BY`
- 注释主要是中文，含幽默/吐槽风格
- 不使用触发式 `limit`（Stellaris 自动应用），`random_*` effect 需要 `limit = {}`
- action scope 链复杂，参考 `wtmnb_safe_destroy_fleet` 中的 `on_*_destroyed_*` 模式

## 调试

- script_documentation logs（`effects.log`、`triggers.log`）在 opencode.json 中已配置引用
- 纯脚本模组，无构建/测试/lint 系统

## 代码审核优先级

1. `events/` → `common/scripted_triggers/` → `common/scripted_effects/` → `common/inline_scripts/events/wtmnb_colossus/`（20 个子脚本）
2. 验证 scope 和 effect/trigger 语法时对照 `script_documentation`

## Git

- remote: `Dave-12138` → `https://github.com/Dave-12138/Stellaris-mod-Who-TM-Needs-Balance.git`
- commit message：中文或 `feat:`/`fix:`/`refactor:` 前缀
- `.gitignore` 忽略 `.vscode/`、`*.vdf`、`*.bat`
