.PHONY: new
DATE=$(shell date '+%Y-%m-%d')
FILENAME=untitled

serve:
	hugo server -D

new:
	hugo new posts/${DATE}-${FILENAME}.md
