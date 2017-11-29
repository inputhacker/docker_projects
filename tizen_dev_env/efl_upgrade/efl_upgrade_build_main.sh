#!/bin/sh

cd /workspace/gits/efl_upgrade/main

if [ "S1" = "pull" ]; then
	./efl_upgrade_main_git_pull.sh
fi

gbs -c /workspace/gbs_config/gbs.conf.unified build -R /workspace/GBS-T5.0_EFL_UPGRADE/base -B /workspace/GBS-T5.0_EFL_UPGRADE/main -A armv7l --include-all --clean

cd -
