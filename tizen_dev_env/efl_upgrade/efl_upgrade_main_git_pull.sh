#!/bin/sh

find . -type d -maxdepth 1 -exec /bin/sh -c "cd {} && git checkout sandbox/upgrade/efl120 && git pull && cd -" \;
