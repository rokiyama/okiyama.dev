.PHONY: new
DATE=$(shell date '+%Y-%m-%d')
TITLE=title

serve:
	hugo server -D

new:
	hugo new posts/${DATE}-${TITLE}.md
