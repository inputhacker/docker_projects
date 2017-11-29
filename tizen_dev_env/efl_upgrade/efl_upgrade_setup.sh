#!bin/sh

#mkdir -p base/automake
#cp -af efl_upgrade_build_base.sh base
#cd base/automake
#wget ...
#tar -zxvf automake_1.15.tar.gz
#cd -

mkdir main
cp -af efl_upgrade_build_main.sh efl_upgrade_main_git_pull.sh main
cd main
chmod +x *.sh
mkdir deviced e-mod-tizen-devicemgr e-mod-tizen-keyrouter efl enlightenment wayland-extension
git clone ssh://${TIZEN_SSH_USER_ID}@review.tizen.org:29418/platform/core/system/deviced -b tizen
git clone ssh://${TIZEN_SSH_USER_ID}@review.tizen.org:29418/platform/upstream/efl -b sandbox/upgrade/efl120
git clone ssh://${TIZEN_SSH_USER_ID}@review.tizen.org:29418/platform/upstream/enlightenment -b sandbox/upgrade/efl120
git clone ssh://${TIZEN_SSH_USER_ID}@review.tizen.org:29418/platform/core/uifw/wayland-extension -b sandbox/upgrade/efl120
git clone ssh://${TIZEN_SSH_USER_ID}@review.tizen.org:29418/platform/core/uifw/e-mod-tizen-devicemgr -b sandbox/upgrade/efl120
#git clone ssh://sj76park@review.tizen.org:29418/platform/core/uifw/e-mod-tizen-keyrouter -b sandbox/upgrade/efl120
#git clone ssh://sj76park@review.tizen.org:29418/platform/core/uifw/e-mod-tizen-gesture -b sandbox/upgrade/efl120
#git clone ssh://sj76park@review.tizen.org:29418/platform/core/uifw/e-mod-tizen-screen-reader -b sandbox/upgrade/efl120
cd -




