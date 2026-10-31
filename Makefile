.PHONY: all check lint test package

all: check

check: lint test

lint:
	luacheck RPGThreat.lua tests

test:
	lua tests/run.lua

package:
	./package.sh
