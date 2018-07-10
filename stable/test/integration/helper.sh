#!/bin/bash
# workaround -- see https://github.com/ponylang/ponyc/issues/2821
cd "$CWD" || exit 100
exec "$STABLE_BIN" "$@"
