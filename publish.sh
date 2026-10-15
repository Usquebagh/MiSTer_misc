#!/usr/bin/env bash
# Publish a core build to this database: copies the .rbf into _Arcade/cores as
# <Name>_<YYYYMMDD>.rbf (replacing older builds of the same core), copies any
# MRAs into _Arcade/_misc, then commits and pushes. update_all picks it up once
# the GitHub Action has rebuilt the database (about a minute).
#
# Usage:
#   ./publish.sh <core project dir>      newest .rbf in releases/ or output_files/,
#                                        plus releases/*.mra
#   ./publish.sh <file.rbf> [file.mra ...]
#
# Options:
#   -n NAME    core name, must match the MRAs' <rbf> tag (default: file name
#              without "Arcade-" and the date, e.g. Arcade-FireTrap_20261004.rbf -> FireTrap)
#   -m MSG     commit message
#   -d         dry run: show what would change, touch nothing
#
# Runs from Git Bash or WSL.

set -euo pipefail

name="" msg="" dry=0
while getopts "n:m:d" opt; do
    case $opt in
        n) name=$OPTARG ;;
        m) msg=$OPTARG ;;
        d) dry=1 ;;
        *) sed -n '2,19p' "$0"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
[ $# -ge 1 ] || { sed -n '2,19p' "$0"; exit 1; }

repo=$(cd "$(dirname "$0")" && pwd)
mras=()

if [ -d "$1" ]; then
    src=$1
    rbf=$(ls -t "$src"/releases/*.rbf "$src"/output_files/*.rbf 2>/dev/null | head -1 || true)
    [ -n "$rbf" ] || { echo "No .rbf in $src/releases or $src/output_files" >&2; exit 1; }
    for f in "$src"/releases/*.mra; do [ -e "$f" ] && mras+=("$f"); done
else
    rbf=$1; shift
    mras=("$@")
fi

[ -f "$rbf" ] || { echo "Not found: $rbf" >&2; exit 1; }
for f in "${mras[@]+"${mras[@]}"}"; do [ -f "$f" ] || { echo "Not found: $f" >&2; exit 1; }; done

if [ -z "$name" ]; then
    name=$(basename "$rbf" .rbf)
    name=${name#Arcade-}
    name=$(echo "$name" | sed -E 's/_[0-9]{8}.*$//')
fi
target="${name}_$(date +%Y%m%d).rbf"

# Older builds of this core already in the repo (with or without the Arcade- prefix)
old=()
while IFS= read -r f; do
    [ "$f" = "$target" ] || old+=("$f")
done < <(ls "$repo/_Arcade/cores" | grep -E "^(Arcade-)?${name}(_[0-9]{8}[^/]*)?\.rbf$" || true)

echo "Core:   $rbf"
echo "  ->    _Arcade/cores/$target"
for f in "${old[@]+"${old[@]}"}"; do echo "  drop  _Arcade/cores/$f"; done
for f in "${mras[@]+"${mras[@]}"}"; do echo "MRA:    $(basename "$f")"; done

# Warn when an MRA points at a different core name
for f in "${mras[@]+"${mras[@]}"}"; do
    tag=$(tr -d '\r' < "$f" | grep -oiE '<rbf>[^<]*' | head -1 | cut -c6-)
    t=${tag#Arcade-}
    if [ -n "$tag" ] && [ "${t,,}" != "${name,,}" ]; then
        echo "WARNING: $(basename "$f") has <rbf>$tag</rbf>, core is $name (use -n?)" >&2
    fi
done

[ $dry -eq 1 ] && { echo "(dry run, nothing changed)"; exit 0; }

cd "$repo"
git pull --rebase --quiet

for f in "${old[@]+"${old[@]}"}"; do git rm --quiet "_Arcade/cores/$f"; done
cp "$rbf" "_Arcade/cores/$target"
for f in "${mras[@]+"${mras[@]}"}"; do cp "$f" "_Arcade/_misc/"; done
git add _Arcade

if git diff --cached --quiet; then
    echo "Nothing changed, nothing to push."
    exit 0
fi

git commit --quiet -m "${msg:-$name: build $(date +%Y-%m-%d)}"
git push --quiet
echo "Pushed. Run update_all on the MiSTer in a minute or two."
