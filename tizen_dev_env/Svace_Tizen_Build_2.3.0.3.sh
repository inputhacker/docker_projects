#!/bin/bash

#---------------------------------------------------------------
#----------- Please set following 8 variables. -----------------
#---------------------------------------------------------------

# 1) Svace binary directory. If not existing it, script will makes them.
  # e.g
    # _SVACE_BINARY_DIR=/home/selab/svace
_SVACE_BINARY_DIR=/workspace/infra/svace/binary


# 2) Build command. Please do not use 'sudo'. Sometimes, any error is came.
#    You can use architecture 'armv7l', 'aarch64' and 'i586'. 
  #e.g
    #_BUILD_CMD="gbs build -A armv7l"
    #_BUILD_CMD="gbs build -A armv7l -C --clean-repos -P tizen_3.0_mobile"
_BUILD_CMD="gbs -c /workspace/gbs_config/gbs.conf.unified build -B /workspace/GBS-T4.0-UNIFIED -A armv7l --include --keep-packs"
#_BUILD_CMD="gbs build -A armv7l --clean-repo -B ~/GBS-ROOT"


# 3) Directory where build takes place
  # e.g
    #_BUILD_PATH=~/Tizen_packages/Tizen_Build_Test
_BUILD_PATH=/workspace/gits/tizen.org

# 4) location where rpms were stored.
  #e.g
    #_PROD_LOCATION=~/GBS-ROOT/local/repos/tztv_3.0/armv7l/RPMS
    #_PROD_LOCATION=~/GBS-ROOT/local/repos/public_3.0_tv_arm/armv7l/RPMS
_PROD_LOCATION=/workspace/GBS-T4.0-UNIFIED/local/repos/tizen.unified/armv7l/RPMS


# 5) Module name to upload svace rusult into svace manager. If you don't have it, write application in 'SCATT' Community.
  #e.g
    #_SVACE_MODULE=Module_Test
    #_SVACE_MODULE=NNC_DataNetwork
_SVACE_MODULE=TWS_Input


# 6) In svace manager, user id is same with single id.
_SVACE_USER=sj76.park


# 7) Svace user password (default : '1111')
_SVACE_PASSWORD=1111


# 8) If you want upload custom path only, you need download the file and set variable below.
_SVACE_INCLUDING_PATH_TEMPLATE_FILE=${_BUILD_PATH}/filter.properties.xml.template

#====================================================================
# **** Warning: DO NOT CHANGE CONTENTS BELOW ****
#====================================================================

#--------------------------------------------------------------
# SVACE Options(Change after confirming with Svace incharge)
#--------------------------------------------------------------

# Svace analyzer and rpm version
_SVACE_RPM_VERSION="2.3.0_0426"
_SVACE_RPM_RELEASE="170526"
_SVACE_ANALYZER_VERSION="2.3.0-1225"

# Host (x86|x64) / Target(armv7l/i586/aarch64) architecture
_HOST_ARCHITECTURE=x64

_TARGET_ARCHITECTURE=armv7l
#_TARGET_ARCHITECTURE=i586
#_TARGET_ARCHITECTURE=aarch64

# Svace manager IP
_SVACE_MANAGER_HOST="suprem.sec.samsung.net:12000"
_DOWNLOAD_URL="http://suprem.sec.samsung.net/confluence/download/attachments/57754858"

# Svace rpm name (RPM & TBZ2)
_SVACE_RPM_NAME=svace-${_SVACE_RPM_VERSION}_${_SVACE_RPM_RELEASE}.${_TARGET_ARCHITECTURE}
_SVACE_BINARY_NAME=svace-${_SVACE_ANALYZER_VERSION}-analyzer-${_HOST_ARCHITECTURE}-linux
_SVACE_INCLUDING_PATH_TOOL_NAME="Svace-Only-Wanted-Path-1.0.0"

# Svace Setting
_SVACE_BIN=${_SVACE_BINARY_DIR}/${_SVACE_BINARY_NAME}/bin/svace
_SVACE_INCLUDING_PATH_TOOL_BIN=${_SVACE_BINARY_DIR}/${_SVACE_INCLUDING_PATH_TOOL_NAME}/bin/filter.sh
_SVACE_CHECKER_FILE_NAME="warn-settings.118"
_SVACE_CHECKER_FILE_PATH=${_SVACE_BINARY_DIR}/${_SVACE_CHECKER_FILE_NAME}.txt
_SVACE_RPM_DIR=${_SVACE_BINARY_DIR}/${_SVACE_RPM_NAME}
_SVACE_BUILD_CMD="${_BUILD_CMD} -R ${_SVACE_RPM_DIR} --extra-packs svace --clean-repos"

_DATE=`date +%F_%H%M`
_LOG_dir=$_SVACE_BINARY_DIR/logs/$_DATE/

#------------------------------------------------------------
#------------------------------------------------------------

check_error() {
	result_status=$?
	if [ $result_status != 0 ]
	then
		echo ""
		echo ---------------------------------------------------------------------
		echo "Fail. Check [$_STEP] step. Exit code is $result_status"
		echo ---------------------------------------------------------------------
		exit $result_status
	else
		echo ""
		echo ---------------------------------------------------------------------
		echo "Success [$_STEP] step."
		echo ---------------------------------------------------------------------
	fi
}

get_login_cookie() {
    URL_LOGIN=http://suprem.sec.samsung.net/confluence/dologin.action

    rm $_SVACE_BINARY_DIR/.cookies.txt

    wget --save-cookies $_SVACE_BINARY_DIR/.cookies.txt \
         --keep-session-cookies \
         --post-data 'os_username=svace.tizen&os_password=swc@seteam1' \
         $URL_LOGIN
    rm dologin.action*
}

check_md5_and_download() {
	_TARGET=$1
	_EXT=$2
	_DIRECTORY=$3
    
	if ! [ -d $_DIRECTORY ]
	then
		mkdir -p $_DIRECTORY
	fi

 	cd $_DIRECTORY
	
	rm $_TARGET.md5
	wget --no-cache --load-cookies $_SVACE_BINARY_DIR/.cookies.txt ${_DOWNLOAD_URL}/$_TARGET.md5
	md5sum -c $_TARGET.md5
	if [ $? != 0 ]
	then
		rm $_TARGET.md5 $_TARGET.$2
		wget --no-cache --load-cookies $_SVACE_BINARY_DIR/.cookies.txt ${_DOWNLOAD_URL}/$_TARGET.$2
		wget --no-cache --load-cookies $_SVACE_BINARY_DIR/.cookies.txt ${_DOWNLOAD_URL}/$_TARGET.md5
		
		md5sum -c $_TARGET.md5
		check_error
	fi
	cd ..
}

install_svace_from_web() {
	_STEP=INSTALL_SVACE
    
    get_login_cookie    

	check_md5_and_download $_SVACE_RPM_NAME rpm $_SVACE_RPM_DIR
	check_md5_and_download $_SVACE_BINARY_NAME zip $_SVACE_BINARY_DIR
	check_md5_and_download ${_SVACE_CHECKER_FILE_NAME} txt $_SVACE_BINARY_DIR
    
    if [ -f $_SVACE_INCLUDING_PATH_TEMPLATE_FILE ]
        then
        check_md5_and_download $_SVACE_INCLUDING_PATH_TOOL_NAME zip $_SVACE_BINARY_DIR
    fi

	if ! [ -d $_SVACE_BINARY_DIR/${_SVACE_BINARY_NAME} ]
	then
		unzip ${_SVACE_BINARY_DIR}/${_SVACE_BINARY_NAME}.zip -d $_SVACE_BINARY_DIR

	fi

    rm $_SVACE_BINARY_DIR/.cookies.txt
}

add_VD_checkers() {
	SVACE_USER_DIR=$_SVACE_BINARY_DIR/$_SVACE_BINARY_NAME/specifications/user
    rm -rf ${SVACE_USER_DIR}
	mkdir -p ${SVACE_USER_DIR}/arm

    get_login_cookie

	check_md5_and_download "Tizen.c" zip ${SVACE_USER_DIR}/arm
	unzip ${SVACE_USER_DIR}/arm/Tizen.c.zip -d ${SVACE_USER_DIR}/arm

	rm ${SVACE_USER_DIR}/arm/Tizen.c.zip
    rm $_SVACE_BINARY_DIR/.cookies.txt
}


svace_build() {
	_STEP=BUILD
	echo ""
	echo ---------------------------------------------------------------------
	echo ====== Step2-2 : Svace Build - generate intermediate result =========
	echo ---------------------------------------------------------------------
	
	cd $_BUILD_PATH
	echo "SVACE_BUILD_CMD : $_SVACE_BUILD_CMD"
	$_SVACE_BUILD_CMD
}


svace_merge_analyze() {
	cd $_PROD_LOCATION
	_STEP=MERGE

	RPMS_NUM=`find $_PROD_LOCATION -name "*-svace*.rpm" | wc -l`

	rm -rf merge-dir
	if [ $RPMS_NUM -eq 0 ]; then
		echo "there is no svace rpm."
		exit
	elif [ $RPMS_NUM -eq 1 ]; then
		echo "there is only one svace rpm."

		for f in *-svace*.rpm; do
			echo ""
			echo "=========================================================="
			echo " extract svace rpm and tar file "
			echo "=========================================================="
			echo "rpm extraction -> $f"
			rpm2cpio $f | cpio -id

			packageName=`echo $f | sed 's/\-svace.*\.rpm//'`
			echo "tar extraction -> $f"
			
			cat $packageName/svace-output.tar.gz* | tar zxvf - -C $packageName > /dev/null
			mv $packageName/home/abuild/svace-output merge-dir
		done

		_STEP=ANALYZE
		echo ""
		echo "=========================================================="
		echo " svace analyze"
		echo "=========================================================="
		
		echo "$_SVACE_BIN analyze --unlimited-memory --svace-dir merge-dir --warnings $_SVACE_CHECKER_FILE_PATH"
		$_SVACE_BIN analyze --unlimited-memory --svace-dir merge-dir --warnings $_SVACE_CHECKER_FILE_PATH
		check_error
	else
		echo "there are over two svace rpms."
		CUR_DIR=`pwd`
			
		rm -rf tmp
		rm extraction_fail_list
			
		mkdir merge-dir
		mkdir tmp

		_STEP=MERGE
		$_SVACE_BIN init --bare merge-dir

		if [ -f $CUR_DIR/tmp/merge-list ]; then
			rm $CUR_DIR/tmp/merge-list
		fi
	
		echo ""
		echo "=========================================================="
		echo " extract svace rpm and tar file"
		echo "=========================================================="

		for f in *-svace*.rpm; do
			echo "extract svace rpm and tar file -> $f"
			rpm2cpio $f | cpio -id
			packageName=`echo $f | sed 's/\-svace.*\.rpm//'`
			cat $packageName/svace-output.tar.gz* | tar zxvf - -C $packageName > /dev/null
		done

		_STEP=EXPORT_BUILD
		echo ""
		echo "=========================================================="
		echo " Svace export-build"
		echo "=========================================================="
		
		for f in *-svace*.rpm; do
			echo "export-build -> $f"
			packageName=`echo $f | sed 's/\-svace.*\.rpm//'`
			
			cd $packageName
			if [ -f home/abuild/svace-output/bitcode/build-object ]; then
				rm -rf $CUR_DIR/tmp/$packageName
				line=$(head -n 1 home/abuild/svace-output/bitcode/build-object)
				echo "$_SVACE_BIN export-build --svace-dir home/abuild/svace-output --path $CUR_DIR/tmp/$packageName"
				$_SVACE_BIN export-build --svace-dir home/abuild/svace-output --path $CUR_DIR/tmp/$packageName
				if [ $? -ne 0 ]; then
				    echo 'Warning : can not export results' | tee -a $CUR_DIR/extraction_fail_list
				else
				    echo $line >> $CUR_DIR/tmp/merge-list
				fi
			else
				echo "build-object is not exist"
			fi
			cd ..
		done
		
		_STEP=HISTORY_IMPORT_DATA
		echo ""
		echo "=========================================================="
		echo " svace history import-data "
		echo "=========================================================="
		
		for f in *-svace*.rpm; do
			echo "history import-data -> $f"
			packageName=`echo $f | sed 's/\-svace.*\.rpm//'`
			
			if [ -f $packageName/home/abuild/svace-output/bitcode/build-object ];
			then
				echo "$_SVACE_BIN history import-data --svace-dir merge-dir --type build --merge-metrics true --path $CUR_DIR/tmp/$packageName"
				$_SVACE_BIN history import-data --svace-dir merge-dir --type build --merge-metrics true --path $CUR_DIR/tmp/$packageName
			else
				echo "build-object is not exist"
			fi
		done
		
		_STEP=MERGE_BUILD
		echo ""
		echo "=========================================================="
		echo " svace merge-build "
		echo "=========================================================="
		
		BUILD_OBJECTS=""
		while read -r Line
		do
			BUILD_OBJECTS="$BUILD_OBJECTS $Line"
		done < $CUR_DIR/tmp/merge-list
		
		echo "svace merge-build --svace-dir merge-dir $BUILD_OBJECTS"
		echo "$_SVACE_BIN merge-build --svace-dir merge-dir $BUILD_OBJECTS"
		$_SVACE_BIN merge-build --svace-dir merge-dir $BUILD_OBJECTS 2>&1 | tee $CUR_DIR/tmp/merge-result
		RESULTING=`cat $CUR_DIR/tmp/merge-result | grep 'Resulting build object' | sed 's/.*]//'`
		
		echo "resulting build object: " $RESULTING

		echo ""
		echo "=========================================================="
		echo " db indexing for svace manager"
		echo "=========================================================="
		
		sqlite3 $CUR_DIR/merge-dir/bitcode/dxr/svace-dxr*.db "CREATE INDEX FILE_ID_IDX ON TOKEN_DATA(LOC_FILE);"
		sqlite3 $CUR_DIR/merge-dir/bitcode/dxr/svace-dxr*.db "CREATE INDEX TOKEN_GROUP_IDX  ON TOKEN_DATA(TOKEN_GROUP)"

		_STEP=ANALYZE
		echo ""
		echo "=========================================================="
		echo " svace analyze "
		echo "=========================================================="
		echo "$_SVACE_BIN analyze --unlimited-memory --svace-dir merge-dir --build $RESULTING --warnings $_SVACE_CHECKER_FILE_PATH"
		$_SVACE_BIN analyze --unlimited-memory --svace-dir merge-dir --build $RESULTING --warnings $_SVACE_CHECKER_FILE_PATH
		check_error
	fi
}

svace_exclude_without_wanted_path() {
    _STEP=EXCLUDE_PATH
    if [ -f $_SVACE_INCLUDING_PATH_TEMPLATE_FILE ];
    then
    	echo ""
    	echo "=========================================================="
    	echo " Exclude all alarms without path list in template file."
    	echo "=========================================================="

	    if ! [ -d $_SVACE_BINARY_DIR/${_SVACE_INCLUDING_PATH_TOOL_NAME} ];
	    then
	    	unzip ${_SVACE_BINARY_DIR}/${_SVACE_INCLUDING_PATH_TOOL_NAME}.zip -d $_SVACE_BINARY_DIR
	    fi
        echo "$_SVACE_INCLUDING_PATH_TOOL_BIN -d $_PROD_LOCATION/merge-dir -p $_SVACE_INCLUDING_PATH_TEMPLATE_FILE"
        $_SVACE_INCLUDING_PATH_TOOL_BIN -d "$_PROD_LOCATION/merge-dir" -p "$_SVACE_INCLUDING_PATH_TEMPLATE_FILE"
        check_error
    else
        echo "Exclude template file is not exist. If you want, Please download template and set it.(option)"
    fi
}

extract_build_time_from_build_info() {
	if [ -f $BUILD_INFO ]
	then
		while read line
		do
			if [ "`expr substr "$line" 1 17`" = "Build start time:" ]
			then
				BUILD_START_TIME=`expr substr "$line" 18 10000`
				BUILD_START_TIME=`date +%s --date="$BUILD_START_TIME"`
			fi
			if [ "`expr substr "$line" 1 18`" = "Build finish time:" ]
			then
				BUILD_FINISH_TIME=`expr substr "$line" 19 10000`
				BUILD_FINISH_TIME=`date +%s --date="$BUILD_FINISH_TIME"`
			fi
		done < $BUILD_INFO
		BUILD_TIME_PKG=$((BUILD_FINISH_TIME - BUILD_START_TIME))
    else
        echo "There is no build-info.txt file"
	fi
}

calculate_build_time() {

	cd $_PROD_LOCATION

    RPMS_NUM=`ls *-svace*.rpm | wc -l`

    BUILD_TIME_TOTAL=0

    if [ $RPMS_NUM -eq 0 ]; then
        echo "There is no rpm."
        exit

    elif [ $RPMS_NUM -eq 1 ]; then
        echo "There is a rpm."
		
		#only one rpm; already copied at merge-dir
		BUILD_INFO="./merge-dir/bitcode/build-info.txt"
        extract_build_time_from_build_info
        BUILD_TIME_TOTAL=${BUILD_TIME_PKG}
	else

		for f in *-svace*.rpm; do
			ProjectName=`echo $f | sed 's/\-svace.*\.rpm//'`
			cd $ProjectName
			BUILD_INFO=home/abuild/svace-output/bitcode/build-info.txt
            extract_build_time_from_build_info
            BUILD_TIME_TOTAL=$(( BUILD_TIME_TOTAL + BUILD_TIME_PKG ))
			cd ..
		done

	fi

	echo "BUILD TIME : ${BUILD_TIME_TOTAL} second(s)"

	# write to merge-dir
	BUILD_INFO_MERGED="./merge-dir/bitcode/build-info.txt"

	BUILD_TIME_TOTAL_SECOND=$((BUILD_TIME_TOTAL%60))
	BUILD_TIME_TOTAL=$((BUILD_TIME_TOTAL/60))
	BUILD_TIME_TOTAL_MINUTE=$((BUILD_TIME_TOTAL%60))
	BUILD_TIME_TOTAL_HOUR=$((BUILD_TIME_TOTAL/60))
	
	BUILD_TIME_TOTAL_STR=""

	if [ $BUILD_TIME_TOTAL_HOUR -ne 0 ]
	then
		BUILD_TIME_TOTAL_STR="$BUILD_TIME_TOTAL_HOUR""h"
	fi
	if [ $BUILD_TIME_TOTAL_MINUTE -ne 0 ]
	then
		BUILD_TIME_TOTAL_STR="$BUILD_TIME_TOTAL_STR""$BUILD_TIME_TOTAL_MINUTE""m"
	fi
	if [ $BUILD_TIME_TOTAL_SECOND -ne 0 ]
	then
		BUILD_TIME_TOTAL_STR="$BUILD_TIME_TOTAL_STR""$BUILD_TIME_TOTAL_SECOND""s"
	fi

	echo "Total build time: $BUILD_TIME_TOTAL_STR""." >> $BUILD_INFO_MERGED

}


svace_upload() {
	_STEP=UPLOAD
	if ! [ -f $_PROD_LOCATION/merge-dir/analyze-res/*.svres ]; then
		echo "There is no svres file that is result of svace analyzer. Please check whether svace build and analyze phase were successed or not."
		exit
	fi
	echo ""
	echo "=========================================================="
	echo " svace upload to svace manager "
	echo "=========================================================="

	_SVACE_UPLOAD_CMD="$_SVACE_BIN upload --host $_SVACE_MANAGER_HOST --module $_SVACE_MODULE --user $_SVACE_USER --pass $_SVACE_PASSWORD --svace-dir $_PROD_LOCATION/merge-dir"
	
	echo $_SVACE_UPLOAD_CMD
	$_SVACE_UPLOAD_CMD
	check_error
}

mkdir -p $_LOG_dir

install_svace_from_web 2>&1 >> ${_LOG_dir}/install_svace_from_web.log
add_VD_checkers 2>&1 |tee ${_LOG_dir}/add_VD_checkers.log
svace_build 2>&1 |tee ${_LOG_dir}/svace_build.log
svace_merge_analyze 2>&1 |tee ${_LOG_dir}/svace_merge_analyze.log
svace_exclude_without_wanted_path 2>&1 |tee ${_LOG_dir}/svace_exclude_path.log
calculate_build_time 2>&1 |tee ${_LOG_dir}/calculate_build_time.log
#svace_upload 2>&1 |tee ${_LOG_dir}/svace_upload.log

