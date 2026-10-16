# check_localisation_bom.ps1
# Verify that every localisation/simp_chinese/*.yml starts with a UTF-8 BOM
# (EF BB BF). Stellaris cannot read Chinese localisation without it.
#
# Usage:  powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_localisation_bom.ps1
# Exit:   0 = ok, 1 = missing BOM, 2 = directory not found
#
# KEEP THIS FILE PURE ASCII. Windows PowerShell 5.1 reads a .ps1 without a BOM
# using the system ANSI codepage, which would garble non-ASCII output.

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$dir  = Join-Path $root 'localisation\simp_chinese'

if (-not (Test-Path -LiteralPath $dir)) {
    Write-Host "[FAIL] not found: $dir"
    exit 2
}

$bad = @()
foreach ($file in @(Get-ChildItem -LiteralPath $dir -Filter '*.yml' -File)) {
    $head   = New-Object byte[] 3
    $stream = [System.IO.File]::OpenRead($file.FullName)
    try     { $n = $stream.Read($head, 0, 3) }
    finally { $stream.Dispose() }

    if ($n -lt 3 -or $head[0] -ne 0xEF -or $head[1] -ne 0xBB -or $head[2] -ne 0xBF) {
        $bad += $file.Name
    }
}

if ($bad.Count -gt 0) {
    Write-Host "[FAIL] missing UTF-8 BOM (EF BB BF):"
    foreach ($name in $bad) { Write-Host "       localisation/simp_chinese/$name" }
    Write-Host "       see AGENTS.md, section about localisation encoding"
    exit 1
}

Write-Host "[ OK ] localisation/simp_chinese/*.yml are UTF-8 with BOM"
exit 0
