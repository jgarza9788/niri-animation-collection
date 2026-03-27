#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="."
OUT_FILE="$OUT_DIR/showcase.md"

mkdir -p "$OUT_DIR"

cat > "$OUT_FILE" <<'MD'
# Showcase

This page lists available animations and their header blocks and demo images.

MD

mapfile -t files < <(find animations -type f -name '*.kdl' | sort)

if [ ${#files[@]} -eq 0 ]; then
	echo "No animations found in animations/" >> "$OUT_FILE"
	echo "Wrote $OUT_FILE"
	exit 0
fi

for file in "${files[@]}"; do
	base=$(basename "$file")
	name="${base%.*}"

	# Extract full /* ... */ header block
	header=$(awk '
		BEGIN { in_header=0 }
		/^[[:space:]]*\/\*/ { in_header=1 }
		in_header { print }
		/\*\// && in_header { exit }
	' "$file")

	# Try to extract a title from the header (fallback to filename)
	title=$(printf "%s\n" "$header" | awk 'BEGIN{IGNORECASE=1} /title:/{sub(/^[^:]*:[ \t]*/,"",$0); print; exit}')
	[ -z "$title" ] && title="$name"

	# Extract demo image path if present
	gifpath=$(printf "%s\n" "$header" | awk 'BEGIN{IGNORECASE=1} /Demo:/{sub(/^[^:]*:[ \t]*/,"",$0); print; exit}')

	echo "## $title" >> "$OUT_FILE"
	echo "" >> "$OUT_FILE"

	if [ -n "$header" ]; then
		echo '```c' >> "$OUT_FILE"
		printf "%s\n" "$header" >> "$OUT_FILE"
		echo '```' >> "$OUT_FILE"
		echo "" >> "$OUT_FILE"
	else
		echo "_No header comment found for ${title}_" >> "$OUT_FILE"
		echo "" >> "$OUT_FILE"
	fi

	
	if [ -n "$gifpath" ] && [ -f "$gifpath" ]; then
		echo "<img src=\"$gifpath\" alt=\"demo_gif\" height=\"300\">" >> "$OUT_FILE"
		echo "" >> "$OUT_FILE"
	else
		echo "_No demo image found for ${title}_" >> "$OUT_FILE"
		echo "" >> "$OUT_FILE"
	fi

	echo "" >> "$OUT_FILE"
	echo "---" >> "$OUT_FILE"
	echo "---" >> "$OUT_FILE"
	echo "---" >> "$OUT_FILE"
	echo "" >> "$OUT_FILE"
done

echo "Wrote $OUT_FILE"
