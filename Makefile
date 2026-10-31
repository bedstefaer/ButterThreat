.PHONY: all check lint test

all: check

check: lint test

lint:
	luacheck RPGThreat.lua tests

test:
	lua tests/run.lua
