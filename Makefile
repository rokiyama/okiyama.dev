.PHONY: new
DATE=$(shell date '+%Y-%m-%d')
FILENAME=untitled

serve:
	hugo server -D --bind 0.0.0.0

new:
	hugo new posts/${DATE}-${FILENAME}.md
