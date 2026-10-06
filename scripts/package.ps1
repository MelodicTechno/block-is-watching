<#
.SYNOPSIS
    将本 Chrome 扩展打包为可上传的 zip 分发包。

.DESCRIPTION
    从项目根目录的 manifest.json 读取 name 与 version，将运行时白名单文件
    （manifest.json、content/、icons/、README.md）汇集到临时目录后压缩，
    输出到 dist/<name>-v<version>.zip。openspec/、.opencode/、scripts/、dist/
    等非运行时目录不会被包含。

.PARAMETER Help
    显示用法说明并退出。

.EXAMPLE
    pwsh scripts/package.ps1
    生成 dist/<name>-v<version>.zip。
#>
[CmdletBinding()]
param(
    [Alias('?')]
    [switch]$Help
)

$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

function Show-Usage {
    @'
用法: pwsh scripts/package.ps1

从 manifest.json 读取 name 与 version，将以下运行时文件打包为 zip：
  manifest.json, content/, icons/, README.md

产物: dist/<name>-v<version>.zip
排除: openspec/, .opencode/, scripts/, dist/ 等非运行时目录

选项:
  -Help, -?   显示本帮助
'@ | Write-Output
}

if ($Help) {
    Show-Usage
    exit 0
}

$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $root 'manifest.json'

if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    Write-Error "缺少 manifest.json: $manifestPath"
    exit 1
}

try {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
} catch {
    Write-Error "manifest.json 解析失败: $_"
    exit 1
}

$name = $manifest.name
$version = $manifest.version
if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($version)) {
    Write-Error "manifest.json 缺少 name 或 version 字段"
    exit 1
}

$requiredDirs = @('content', 'icons')
$missing = @()
foreach ($dir in $requiredDirs) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $dir) -PathType Container)) {
        $missing += $dir
    }
}
if ($missing.Count -gt 0) {
    Write-Error ("缺少必需目录: " + ($missing -join ', '))
    exit 1
}

$safeName = ($name -replace '\s+', '-') -replace '[^A-Za-z0-9\-_.]', ''
if ([string]::IsNullOrWhiteSpace($safeName)) {
    Write-Error "manifest.json 的 name 无法生成安全文件名: $name"
    exit 1
}

$distDir = Join-Path $root 'dist'
if (-not (Test-Path -LiteralPath $distDir -PathType Container)) {
    New-Item -ItemType Directory -Path $distDir | Out-Null
}
$zipPath = Join-Path $distDir "$safeName-v$version.zip"

$staging = Join-Path ([System.IO.Path]::GetTempPath()) ("bili-pkg-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $staging | Out-Null

try {
    Copy-Item -LiteralPath $manifestPath -Destination $staging
    Copy-Item -LiteralPath (Join-Path $root 'content') -Destination $staging -Recurse
    Copy-Item -LiteralPath (Join-Path $root 'icons') -Destination $staging -Recurse
    $readme = Join-Path $root 'README.md'
    if (Test-Path -LiteralPath $readme -PathType Leaf) {
        Copy-Item -LiteralPath $readme -Destination $staging
    }

    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }

    Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zipPath -Force

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $hasManifest = $false
        foreach ($entry in $archive.Entries) {
            if ($entry.FullName -eq 'manifest.json') { $hasManifest = $true }
        }
    } finally {
        $archive.Dispose()
    }
    if (-not $hasManifest) {
        Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue
        Write-Error "打包校验失败: 压缩包根目录缺少 manifest.json"
        exit 1
    }
} finally {
    if (Test-Path -LiteralPath $staging) {
        Remove-Item -LiteralPath $staging -Recurse -Force
    }
}

Write-Output "已生成: $zipPath"
exit 0
