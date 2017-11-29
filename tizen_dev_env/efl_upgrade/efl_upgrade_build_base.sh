#!/bin/sh

cd /workspace/gits/efl_upgrade/base
gbs -c /workspace/gbs_config/gbs.conf.unified build -B /workspace/GBS-T5.0_EFL_UPGRADE/base -A armv7l --include-all --clean
cd -
