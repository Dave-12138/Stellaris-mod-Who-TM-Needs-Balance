// 自动为 localisation/simp_chinese/*.yml 补齐 UTF-8 BOM（幂等）
//
// 用法：
//   node tools/fix_localisation_bom.mjs          缺 BOM 就地补上，返回 0
//   node tools/fix_localisation_bom.mjs --check  只检查不修改，缺 BOM 返回 1
//
// 说明：
//   Stellaris 读不出没有 BOM 的中文本地化，本脚本由 upload.bat 在上传前调用，
//   也可在改完 yml 后手工跑一次。输出保持 ASCII，不依赖宿主控制台的代码页。

import { readdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const BOM = Buffer.from([0xef, 0xbb, 0xbf])
const checkOnly = process.argv.slice(2).includes('--check')
const root = dirname(dirname(fileURLToPath(import.meta.url)))
const rel = 'localisation/simp_chinese'
const dir = join(root, rel)

let names
try {
  names = readdirSync(dir)
    .filter((n) => n.toLowerCase().endsWith('.yml'))
    .sort()
} catch (err) {
  console.error(`[FAIL] cannot read ${rel}/: ${err.message}`)
  process.exit(2)
}

const missing = []
let ok = 0

for (const name of names) {
  let buf
  try {
    buf = readFileSync(join(dir, name))
  } catch (err) {
    console.error(`[FAIL] ${rel}/${name}: ${err.message}`)
    process.exit(1)
  }
  if (buf.subarray(0, 3).equals(BOM)) ok++
  else missing.push({ name, buf })
}

if (missing.length > 0 && checkOnly) {
  console.log(`[FAIL] missing UTF-8 BOM: ${missing.length}`)
  for (const { name } of missing) console.log(`       ${rel}/${name}`)
  process.exit(1)
}

for (const { name, buf } of missing) {
  try {
    writeFileSync(join(dir, name), Buffer.concat([BOM, buf]))
  } catch (err) {
    console.error(`[FAIL] ${rel}/${name}: ${err.message}`)
    process.exit(1)
  }
  console.log(`[FIX ] added UTF-8 BOM: ${rel}/${name}`)
}

if (missing.length > 0) console.log(`[ OK ] ${ok} ok, ${missing.length} repaired - remember to commit`)
else console.log(`[ OK ] all ${ok} file(s) under ${rel}/ have a UTF-8 BOM`)
