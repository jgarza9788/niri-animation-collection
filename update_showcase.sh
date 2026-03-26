
#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="."
OUT_FILE="$OUT_DIR/showcase.md"

mkdir -p "$OUT_DIR"

cat > "$OUT_FILE" <<'MD'
# Showcase

This page lists available animations and their demo images (GIF/PNG).

MD

mapfile -t files < <(find animations -type f -name '*.kdl' | sort)

if [ ${#files[@]} -eq 0 ]; then
	echo "No animations found in animations/" >> "$OUT_FILE"
	echo "Wrote $OUT_FILE"
	exit 0
fi


# for file in "${files[@]}"; do
# 	echo "$file"
# done

for file in "${files[@]}"; do
	base=$(basename "$file")
	name="${base%.*}"

	header=$(sed -n '1,50p' "$file")

	title=$(printf "%s" "$header" | awk 'BEGIN{IGNORECASE=1} /title:/{sub(/^[^:]*:[ \t]*/,"",$0); print; exit}')
	authors=$(printf "%s" "$header" | awk 'BEGIN{IGNORECASE=1} /authors:/{sub(/^[^:]*:[ \t]*/,"",$0); print; exit}')
	desc=$(printf "%s" "$header" | awk 'BEGIN{IGNORECASE=1} /Desc:/{sub(/^[^:]*:[ \t]*/,"",$0); print; exit}')
	gifpath=$(printf "%s" "$header" | awk 'BEGIN{IGNORECASE=1} /Demo:/{sub(/^[^:]*:[ \t]*/,"",$0); print; exit}')

	echo -e "$title\n$authors\\n$desc\\n$gifpath"

	[ -z "$title" ] && title="$name"

	echo "## $title  " >> "$OUT_FILE"
	echo "* Authors: $authors  " >> "$OUT_FILE"
	if [ -n "$desc" ]; then
		echo "* Desc: $desc  " >> "$OUT_FILE"
	fi

	if [ -n "$gifpath" ]; then
		echo "![${title}](${gifpath})  " >> "$OUT_FILE"
	else
		echo "_No demo image found for ${title}_" >> "$OUT_FILE"
	fi

	echo "" >> "$OUT_FILE"
	echo "---" >> "$OUT_FILE"
	echo "" >> "$OUT_FILE"
done

echo "Wrote $OUT_FILE"
