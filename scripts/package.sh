#!/usr/bin/env bash
set -euo pipefail

print_usage() {
  cat <<'EOF'
用法: bash scripts/package.sh

从 manifest.json 读取 name 与 version，将以下运行时文件打包为 zip：
  manifest.json, content/, icons/, README.md

产物: dist/<name>-v<version>.zip
排除: openspec/, .opencode/, scripts/, dist/ 等非运行时目录

选项:
  -h, --help   显示本帮助
EOF
}

case "${1:-}" in
  -h|--help|-?) print_usage; exit 0 ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/.." && pwd)"
manifest="$root/manifest.json"

if [ ! -f "$manifest" ]; then
  echo "缺少 manifest.json: $manifest" >&2
  exit 1
fi

json_value() {
  grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$manifest" \
    | head -n 1 \
    | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/'
}

name="$(json_value name)"
version="$(json_value version)"

if [ -z "$name" ] || [ -z "$version" ]; then
  echo "manifest.json 缺少 name 或 version 字段" >&2
  exit 1
fi

missing=""
for dir in content icons; do
  if [ ! -d "$root/$dir" ]; then
    missing="$missing $dir"
  fi
done
if [ -n "$missing" ]; then
  echo "缺少必需目录:$missing" >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "未找到 zip 命令，请先安装（如 apt-get install zip / brew install zip）" >&2
  exit 1
fi

safe_name="$(printf '%s' "$name" | tr -s '[:space:]' '-' | sed -E 's/[^A-Za-z0-9._-]//g')"
if [ -z "$safe_name" ]; then
  echo "manifest.json 的 name 无法生成安全文件名: $name" >&2
  exit 1
fi

dist="$root/dist"
mkdir -p "$dist"
zip_path="$dist/${safe_name}-v${version}.zip"

staging="$(mktemp -d)"
cleanup() { rm -rf "$staging"; }
trap cleanup EXIT

cp -p "$manifest" "$staging/"
cp -Rp "$root/content" "$staging/"
cp -Rp "$root/icons" "$staging/"

items=(manifest.json content icons)
if [ -f "$root/README.md" ]; then
  cp -p "$root/README.md" "$staging/"
  items+=(README.md)
fi

rm -f "$zip_path"
( cd "$staging" && zip -r -q -D "$zip_path" "${items[@]}" )

if command -v unzip >/dev/null 2>&1; then
  if ! unzip -l "$zip_path" | grep -qE '(^|[[:space:]])manifest\.json$'; then
    rm -f "$zip_path"
    echo "打包校验失败: 压缩包根目录缺少 manifest.json" >&2
    exit 1
  fi
fi

echo "已生成: $zip_path"
