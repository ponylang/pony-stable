#!/bin/bash
cd "$CWD" || exit 100
exec "$STABLE_BIN" "$@"
