.PHONY: all check lint test luals

all: check

check: lint test

lint:
	luacheck RPGThreat.lua tests

test:
	lua tests/run.lua

# WoW API check; needs lua-language-server and jq on PATH and the Ketho/vscode-wow-api
# Annotations folder at .wow-api/Annotations (see the wow-api-check job in ci.yml)
luals:
	lua-language-server --check . --checklevel Information --logpath .wow-api/log --check_out_path .wow-api/check.json
	jq -e 'length == 0' .wow-api/check.json > /dev/null || (jq -r 'to_entries[] | .key as $$f | .value[] | "\($$f):\(.range.start.line + 1): [\(.code)] \(.message)"' .wow-api/check.json; exit 1)
