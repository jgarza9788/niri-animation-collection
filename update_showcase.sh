
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

for file in "${files[@]}"; do
	base=$(basename "$file")
	name="${base%.*}"

	header=$(sed -n '1,50p' "$file")

	title=$(printf "%s" "$header" | awk 'BEGIN{IGNORECASE=1} /title:/{sub(/^[^:]*:[ \t]*/,"",$0); print; exit}')
	description=$(printf "%s" "$header" | awk 'BEGIN{IGNORECASE=1} /description:/{sub(/^[^:]*:[ \t]*/,"",$0); print; exit}')
	giffield=$(printf "%s" "$header" | awk 'BEGIN{IGNORECASE=1} /gif:/{sub(/^[^:]*:[ \t]*/,"",$0); print; exit}')

	[ -z "$title" ] && title="$name"

	echo "## $title" >> "$OUT_FILE"
	if [ -n "$description" ]; then
		echo "" >> "$OUT_FILE"
		echo "$description" >> "$OUT_FILE"
	fi

	# resolve gif path: prefer explicit header, then docs/gifs/<name>.*, then demos/<name>.gif
	gifpath=""
	if [ -n "$giffield" ]; then
		if [ -f "$giffield" ]; then
			gifpath="$giffield"
		elif [ -f "docs/gifs/$giffield" ]; then
			gifpath="docs/gifs/$giffield"
		fi
	fi

	if [ -z "$gifpath" ]; then
		if [ -f "docs/gifs/${name}.gif" ]; then
			gifpath="docs/gifs/${name}.gif"
		elif [ -f "docs/gifs/${name}.png" ]; then
			gifpath="docs/gifs/${name}.png"
		elif [ -f "demos/${name}.gif" ]; then
			gifpath="demos/${name}.gif"
		fi
	fi

	echo "" >> "$OUT_FILE"
	if [ -n "$gifpath" ]; then
		echo "![${title}](${gifpath})" >> "$OUT_FILE"
	else
		echo "_No demo image found for ${title}_" >> "$OUT_FILE"
	fi

	echo "" >> "$OUT_FILE"
done

echo "Wrote $OUT_FILE"
