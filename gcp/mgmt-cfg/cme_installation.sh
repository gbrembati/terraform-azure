#!/bin/bash

source /opt/CPshared/5.0/tmp/.CPprofile.sh  # source CPprofile

###################### bin variables ######################
AWK=/bin/awk
ECHO=/bin/echo
SLEEP=/bin/sleep
GREP=/bin/grep
RM=/bin/rm
MKDIR=/bin/mkdir
TOUCH=/bin/touch
CHMOD=/bin/chmod
TEE=/usr/bin/tee
DATE=/bin/date
JQ=${CPDIR}/bin/jq
CAT=/bin/cat
TIMEOUT=/bin/timeout
###########################################################

###################### file/folder variables ######################
PYTHON3=/etc/fw/Python/bin/python3.7
CPPROD_UTIL=${CPDIR}/bin/cpprod_util
AUTOUPDATER=/opt/AutoUpdater/latest/bin/autoupdatercli
CME_INSTALLATION_DATA_FILE="/tmp/cme_autoupdater_intallation_data"
CME_INSTALLATION_STATUS_SCRIPT="/tmp/cme_installation_status.py"
CME_AUTOUPDATER_VERSION_SCRIPT="/tmp/cme_autoupdater_verion.py"
CME_AUTOUPDATER_BUNDLE_COUNT_SCRIPT="/tmp/cme_autoupdater_bundle_count.py"
CME_LOGDIR="/var/log/CPcme/"
CME_INSTALLATION_LOGFILE="${CME_LOGDIR}/cme_installation.log"
####################################################################

###################### user-message variables #########################
AUTOUPDATER_NOT_INSTALLED_MESSAGE="AutoUpdater is not installed on the machine - please install the minimal JHF version as described in sk157492 and try again"
FAILED_TO_READ_CME_INFO_FROM_AUTOUPDATER_MESSAGE="Failed to read CME info from AutoUpdater and can't install CME. Please contact Check Point Support"
FAILED_TO_INSTALL_CME_BUNDLE_MESSAGE="Failed to install latest CME bundle. Please contact Check Point Support"
FAILED_TO_ENABLE_CME_DOWNLOAD_MESSAGE="Failed to enable online download for CME bundle in AutoUpdater. Please contact Check Point Support"
CME_CURRENTLY_INSTALLING_MESSAGE="CME is currently installing, please wait (this operation can take up to 5 minutes)..."
VERIFYING_PRECONDITIONS_MESSAGE="Verifying pre-conditions for CME installation via AutoUpdater..."
ANOTHER_CME_INSTALLATION_IN_PROGRESS="Another CME installation via AutoUpdater is already in progress, please wait for it to finish prior to running this installation"

CME_ALREADY_INSTALLED_MESSAGE='A version of CME is already installed via AutoUpdater
In order to enable CME downloads please run in expert mode: "autoupdatercli enable CME". After CME is enabled it will automatically upgrade itself with the latest available version
If you have no internet access please follow instructions for offline installation in sk157492'

INSTALLING_CME_VIA_ONLINE_UPDATE_MESSAGE="Installing CME via online update, please wait (this operation can take up to 5 minutes)..."

FAILED_TO_DOWNLOAD_CME_BUNDLE_MESSAGE='Failed to download latest CME bundle
If you have no internet access please follow instructions for offline installation in sk157492'

FAILED_TO_VERIFY_CME_INSTALLATION_MESSAGE="Failed to verify if CME installation completed successfully. Please try running the script again after a few minutes or contact Check Point Support"
SUCCESSFULLY_INSTALLED_CME_MESSAGE="Successfully installed CME. Please re-login to the shell in order to start using CME"
CME_DISABLED_WILL_INSTALL_MESSAGE="CME is installed via AutoUpdater but not enabled for automatic downloads, will install..."
DISABLE_HA_CME_MANUALLY='Could not disable automatic updates for CME on HA machine
Please disable CME updates manually by running the following command in expert mode: "autoupdatercli disable CME"'
##################################################################

###################### script global variables ######################
HEADLINE_DELIMITER="============================================================"
CME_INITIAL_VERSION_DATAFILE_VAR="cme_initial_version"
MACHINE_VERSION_NAME=""
MACHINE_VERSION_NUM=0
AUTOUPDATER_COMMAND_TIMEOUT=20
AUTOUPDATER_COMMAND_OUTPUT=""
AUTOUPDATER_CME_MISSING=4
AUTOUPDATER_CME_INSTALLING=3
AUTOUPDATER_CME_IDLE=2
SUCCESS=1
FAILURE=0
MONITOR_TIMEOUT_FAILURE=2
MONITOR_INTERNAL_FAILURE=3
WAIT_INTERVAL=10  # sleep for 10 seconds when monitoring CME installation
INSTALLATION_TIMEOUT=300  # timeout after 300 seconds (=5 minutes) when monitoring CME installation
MINIMAL_ALLOWED_AUTOUPDATER_BUILD=990180162
AUTOUPDATER_COMMAND_NUM_OF_RETRIES=3
AUTOUPDATER_COMMAND_RETRY_INTERVAL=20
######################################################################

############################ functions #################################
function ALL_ECHO() {
    # echo both to stdout and into log file
    to_echo=${1}
    $ECHO -e "$to_echo" | $TEE -a $CME_INSTALLATION_LOGFILE
}

function LOG_ECHO() {
    # echo only into log file
    to_echo=${1}
    $ECHO -e "$to_echo" >> $CME_INSTALLATION_LOGFILE
}

# Run autoupdater command with retries
# Example of usage: "run_autoupdater_command enable CME", where "enable CME" is the input command
function run_autoupdater_command() {
    autoupdater_command=${1}
    retries_counter=0
    autoupdater_command_ret=1
    AUTOUPDATER_COMMAND_OUTPUT=""
    # Try autoupdater command maximum of 3 times, if it doesn't succeed after 3 times consider as failure
    until [ $retries_counter -ge $AUTOUPDATER_COMMAND_NUM_OF_RETRIES ]
    do
        timeout_result=$SUCCESS
        # run AutoUpdater command with timeout on versions above R80.10
        if [ $MACHINE_VERSION_NUM -gt 8010 ]; then
            LOG_ECHO "Running AutoUpdater command \"$autoupdater_command\" with timeout of $AUTOUPDATER_COMMAND_TIMEOUT seconds "
            AUTOUPDATER_COMMAND_OUTPUT=$($TIMEOUT $AUTOUPDATER_COMMAND_TIMEOUT $AUTOUPDATER $autoupdater_command) # get autoupdater command output
            if [ $? -ne 0 ]; then
                timeout_result=$FAILURE
                LOG_ECHO "Timed out while executing AutoUpdater command \"$autoupdater_command\""
            fi
        # run AutoUpdater command without timeout - timeout command doesn't exist on version R80.10
        else
            AUTOUPDATER_COMMAND_OUTPUT=$($AUTOUPDATER $autoupdater_command) # get autoupdater command output
        fi
        # If AutoUpdater command hasn't timed out and succeeded to execute (it can fail to execute even without timing out)
        if [ $? -eq 0 ] && [ $timeout_result -eq $SUCCESS ]; then
            return $SUCCESS
        fi
        ((retries_counter++))
        if [ $retries_counter -lt $AUTOUPDATER_COMMAND_NUM_OF_RETRIES ]; then
            LOG_ECHO "Failed to run AutoUpdater command \"${autoupdater_command}\" - retry $retries_counter out of $AUTOUPDATER_COMMAND_NUM_OF_RETRIES. Will retry in $AUTOUPDATER_COMMAND_RETRY_INTERVAL seconds..."
            $SLEEP $AUTOUPDATER_COMMAND_RETRY_INTERVAL
        fi
    done
    # Maxed out retries, return failure
    LOG_ECHO "Failed to run AutoUpdater command \"$autoupdater_command\" - reached maximum of $AUTOUPDATER_COMMAND_NUM_OF_RETRIES retries"
    return $FAILURE # return error
}

# Get string of machine version
function init_cp_version() {

    cp_version=$($CPPROD_UTIL CPPROD_GetLastMinorVersion)
    cp_version=$($ECHO $cp_version) # remove spaces

    # Full version is returned on R80.10 and "<nil>" on R80.20 and above
    if [ "$cp_version" == "<nil>" -o "$cp_version" == "Failed to find the value" ]; then
        cp_version=""
    fi

    if [ ! -z $cp_version ]; then
        MACHINE_VERSION_NAME=$cp_version
        return
    fi

    # Get full version
    cp_version=$($CPPROD_UTIL CPPROD_GetVerText CPshared)
    cp_version=$($ECHO $cp_version) # remove spaces

    # Get minor version
    cp_sub_version=$($CPPROD_UTIL CPPROD_GetValue CPshared SubVersionText 4)
    cp_sub_version=$($ECHO $cp_sub_version) # remove spaces

    if [ "$cp_sub_version" == "<nil>" -o "$cp_sub_version" == "Failed to find the value" ]; then
        cp_sub_version=""
    fi

    if [ ! -z $cp_sub_version ]; then
        cp_version="${cp_version}${cp_sub_version}"
    fi

    MACHINE_VERSION_NAME=$cp_version
}

# Get numeric value of machine version (e.g. the string: R80.40 will be converted to the int: 8040)
function init_cp_version_numeric() {
    # init version name only if it hasn't been set before
    if [ -z "$MACHINE_VERSION_NAME" ]; then
        init_cp_version
    fi
    current_cp_version="${MACHINE_VERSION_NAME:1}" # remove "R" char from version name
    # read major and minor versions into variables
    IFS=. read major minor <<< "$current_cp_version"
    if [ -z "$minor" ]; then
        minor=0
    fi
    MACHINE_VERSION_NUM=$((${major}*100+$minor))
}

# Verify CME is not installed via CPUSE
function verify_no_cpuse_cme() {
    grep_line_count=$(cpinfo -y CPupdates 2>&1 | $GREP -c "BUNDLE_CME_WRAPPER")
    if [ $(($grep_line_count + 0)) -ne 0 ]; then
        $ECHO "An old bundle of CME is currently installed - you must uninstall it via CPUSE before installing this version"
        return $FAILURE
    fi
    return $SUCCESS
}

# Verify minimal build number of AutoUpdater is installed
function verify_autoupdater_build() {
    autoupdater_build=$(cpvinfo /opt/AutoUpdater/latest/bin/AutoUpdater 2>&1 | $GREP "Build Number" | $AWK -F= '{gsub(/^[ \t]+|[ \t]+$/, "", $2); {print $2}}')
    if [ -z "$autoupdater_build" ]; then
        $ECHO "AutoUpdater is not installed on the machine - install the minimal JHF version as described in sk157492"
        return $FAILURE
    fi

    autoupdater_build=$(($autoupdater_build + 0))  # convert to int
    if [ $autoupdater_build -lt $MINIMAL_ALLOWED_AUTOUPDATER_BUILD ]; then
        $ECHO "Version of AutoUpdater needs to be $MINIMAL_ALLOWED_AUTOUPDATER_BUILD or higher (current version is: $autoupdater_build) - please download the correct version from sk157492"
        return $FAILURE
    fi
    return $SUCCESS
}

# verify that the minimal jumbo hotfix package is installed on the machine according to the machine version
function verify_jumbo_hotfix() {
    jumbo_hf_bundle_name=""
    if [ $MACHINE_VERSION_NUM -lt 8040 ]; then
        if [ $MACHINE_VERSION_NUM -eq 8010 ]; then
            jumbo_hf_bundle_name="BUNDLE_R80_10_JUMBO_HF"
            min_jumbo_hf_take=249
        elif [ $MACHINE_VERSION_NUM -eq 8020 ]; then
            jumbo_hf_bundle_name="BUNDLE_R80_20_JUMBO_HF_MAIN_gogoKernel"
            min_jumbo_hf_take=117
        elif [ $MACHINE_VERSION_NUM -eq 8030 ]; then
            jumbo_hf_bundle_name="BUNDLE_R80_30_JUMBO_HF_MAIN_gogoKernel"
            min_jumbo_hf_take=71
        else
            $ECHO "CME via AutoUpdater is not supported on version $MACHINE_VERSION_NAME"
            return $FAILURE
        fi

        current_jumbo_take_installed=$(cpinfo -y CPupdates 2>&1 | $GREP $jumbo_hf_bundle_name | $AWK 'BEGIN { FS = "[ \t]+Take:[ \t]+" }; gsub(/^[ \t]+|[ \t]+$/, "", $2); { print $2 }')
        if [ -z "$current_jumbo_take_installed" ]; then
            $ECHO "No jumbo hotfix found on the machine. Version $MACHINE_VERSION_NAME requires a jumbo hotfix with a minimum take of $min_jumbo_hf_take"
            return $FAILURE
        elif [ $(($current_jumbo_take_installed + 0)) -lt $min_jumbo_hf_take ]; then
            $ECHO "Version $MACHINE_VERSION_NAME requires a jumbo hotfix of minimum take: $min_jumbo_hf_take. Take currently installed: $current_jumbo_take_installed"
            return $FAILURE
        fi
    fi
    return $SUCCESS
}

# Verify that all preconditions for installation hold and in case any of them don't print the ones that are missing and exit
# 1. CPUSE CME bundle must be removed prior to AutoUpdater CME installation
# 2. Minimal version of AutoUpdater is 990180162
# 3. Verify minimal JHF is installed based on version: R80.10 - Take 249, R80.20 - Take 117, R80.30 - Take 71
function verify_preconditions() {
    preconditions_passed=true
    preconditions_error_message=" \nThe following issues need to be fixed prior to installation:\n${HEADLINE_DELIMITER}\n\n"

    # Verify no CPUSE CME is installed
    cpuse_cme_err_message=$(verify_no_cpuse_cme)
    if [ $? -eq $FAILURE ]; then
        LOG_ECHO "$cpuse_cme_err_message"
        preconditions_error_message="$preconditions_error_message (*) $cpuse_cme_err_message\n"
        preconditions_passed=false
    fi

    # Verify minimal build number of AutoUpdater is installed
    autoupdater_build_err_message=$(verify_autoupdater_build)
    if [ $? -eq $FAILURE ]; then
        LOG_ECHO "$autoupdater_build_err_message"
        preconditions_error_message="$preconditions_error_message (*) $autoupdater_build_err_message\n"
        preconditions_passed=false
    fi

    # Verify jumbo hotfix for relevant version is installed
    jumbo_hotfix_err_message=$(verify_jumbo_hotfix)
    if [ $? -eq $FAILURE ]; then
        LOG_ECHO "$jumbo_hotfix_err_message"
        preconditions_error_message="$preconditions_error_message (*) $jumbo_hotfix_err_message\n"
        preconditions_passed=false
    fi

    # If some preconditions didn't hold
    if ! $preconditions_passed; then
        ALL_ECHO "${preconditions_error_message}\nPlease fix the above issues before running the installation again\n"
        exit 1
    fi
    ALL_ECHO "Pre-conditions verification for CME installation passed successfully"
}

# get number of CME bundles listed in AutoUpdater
function get_cme_bundles_count_in_autoupdater() {
    LOG_ECHO "Getting CME bundle count in AutoUpdater..."
    run_autoupdater_command "show json"
    # If failed to run autoupdater show json command
    if [ $? -eq $FAILURE ]; then
        LOG_ECHO "Failed to get products info from AutoUpdater"
        return $FAILURE
    fi

    cat << EOF > $CME_AUTOUPDATER_BUNDLE_COUNT_SCRIPT
import json
import sys
autoupdater_products_json=sys.argv[1]

try:
    products_info = json.loads(autoupdater_products_json)
except Exception:
    print(1)
    sys.exit(1)

if not products_info:
    print(0)
    sys.exit(0)

autoupdater_products = products_info.get("products")
if not autoupdater_products:
    print(0)
    sys.exit(0)

for product in autoupdater_products:
    product_name = product.get("product-name")
    if product_name and product_name == "CloudGuard_IaaS":
        product_components = product.get("product-components")
        if not product_components:
            print(0)
            sys.exit(0)
        for component in product_components:
            component_name = component.get("component-name")
            if component_name and component_name.lower() == "cme":
                packages = component.get("repository-packages")
                if not packages or not isinstance(packages, list):
                    print(0)
                    sys.exit(0)
                else:
                    print(len(packages))
                    sys.exit(0)
        print(0)
        sys.exit(0)

print(0)
sys.exit(0)
EOF
    cme_bundle_count_in_autoupdater=$($PYTHON3 $CME_AUTOUPDATER_BUNDLE_COUNT_SCRIPT "$AUTOUPDATER_COMMAND_OUTPUT" 2>>$CME_INSTALLATION_LOGFILE)
    if [ $? -ne 0 ]; then
        LOG_ECHO "Failed to execute Python script for CME bundle count in AutoUpdater"
        $RM -f $CME_AUTOUPDATER_BUNDLE_COUNT_SCRIPT
        return $FAILURE
    fi
    $RM -f $CME_AUTOUPDATER_BUNDLE_COUNT_SCRIPT
    $ECHO $cme_bundle_count_in_autoupdater
    LOG_ECHO "Got CME bundle count in AutoUpdater: $cme_bundle_count_in_autoupdater"
    return $SUCCESS
}

# get version of currently installed CME in AutoUpdater - print 0 if none
function get_cme_autoupdater_version() {
    LOG_ECHO "Getting CME version in AutoUpdater..."
    run_autoupdater_command "show json"
    # If failed to run autoupdater show json command
    if [ $? -eq $FAILURE ]; then
        LOG_ECHO "Failed to get products info from AutoUpdater"
        return $FAILURE
    fi

    cat << EOF > $CME_AUTOUPDATER_VERSION_SCRIPT
import json
import sys
autoupdater_products_json=sys.argv[1]

try:
    products_info = json.loads(autoupdater_products_json)
except Exception:
    print(1)
    sys.exit(1)

autoupdater_products = products_info.get("products")
if not autoupdater_products:
    print(0)
    sys.exit(0)

for product in autoupdater_products:
    product_name = product.get("product-name")
    if product_name and product_name == "CloudGuard_IaaS":
        product_components = product.get("product-components")
        if not product_components:
            print(0)
            sys.exit(0)
        for component in product_components:
            component_name = component.get("component-name")
            if component_name and component_name.lower() == "cme":
                packages = component.get("repository-packages")
                if not packages or not isinstance(packages, list):
                    print(0)
                    sys.exit(0)
                max_ver = 0
                for package in packages:
                    package_installed = package.get("package-installed")
                    package_version = package.get("package-version")
                    if package_installed and str(package_installed).lower() == "true" and \
                        package_version and int(package_version) > max_ver:
                        max_ver = int(package_version)
                print(max_ver)
                sys.exit(0)
        print(0)
        sys.exit(0)

print(0)
sys.exit(0)
EOF
    cme_curr_verion=$($PYTHON3 $CME_AUTOUPDATER_VERSION_SCRIPT "$AUTOUPDATER_COMMAND_OUTPUT" 2>>$CME_INSTALLATION_LOGFILE)
    if [ $? -ne 0 ]; then
        LOG_ECHO "Failed to execute Python script for CME version in AutoUpdater"
        $RM -f $CME_AUTOUPDATER_VERSION_SCRIPT
        return $FAILURE
    fi
    $RM -f $CME_AUTOUPDATER_VERSION_SCRIPT
    $ECHO $cme_curr_verion
    LOG_ECHO "Got CME version: $cme_curr_verion"
    return $SUCCESS
}

# get the installation status of CME in AutoUpdater - Not existing, idle or in progress
function get_cme_installation_status() {
    LOG_ECHO "Getting CME installation status in AutoUpdater..."
    # If failed to run autoupdater show json command
    run_autoupdater_command "show json"
    if [ $? -eq $FAILURE ]; then
        LOG_ECHO "Failed to get products info from AutoUpdater"
        return $FAILURE
    fi

    cat << EOF > $CME_INSTALLATION_STATUS_SCRIPT
import json
import sys
autoupdater_products_json=sys.argv[1]

try:
    products_info = json.loads(autoupdater_products_json)
except Exception:
    print(1)
    sys.exit(1)

autoupdater_products = products_info.get("products")
if not autoupdater_products:
    print($AUTOUPDATER_CME_MISSING)
    sys.exit(1)

for product in autoupdater_products:
    product_name = product.get("product-name")
    if product_name and product_name == "CloudGuard_IaaS":
        product_components = product.get("product-components")
        if not product_components:
            print($AUTOUPDATER_CME_MISSING)
            sys.exit(1)
        for component in product_components:
            component_name = component.get("component-name")
            if component_name and component_name.lower() == "cme":
                component_install_revert_action = component.get("install-revert-action")
                if "installing" in component_install_revert_action.lower():
                    print($AUTOUPDATER_CME_INSTALLING)
                    sys.exit(0)
                else:
                   print($AUTOUPDATER_CME_IDLE)
                   sys.exit(0)
        print($AUTOUPDATER_CME_MISSING)
        sys.exit(1)

print($AUTOUPDATER_CME_MISSING)  # CME is missing from AutoUpdater
sys.exit(1)
EOF
    cme_status=$($PYTHON3 $CME_INSTALLATION_STATUS_SCRIPT "$AUTOUPDATER_COMMAND_OUTPUT" 2>>$CME_INSTALLATION_LOGFILE)
    if [ $? -ne 0 ]; then
        LOG_ECHO "Failed to execute Python script for CME version in AutoUpdater"
        $RM -f $CME_INSTALLATION_STATUS_SCRIPT
        return $FAILURE
    fi
    $RM -f $CME_INSTALLATION_STATUS_SCRIPT
    $ECHO $cme_status
    LOG_ECHO "Got CME installation status in AutoUpdater: $cme_status"
    return $SUCCESS
}

# Monitor online CME installation via AutoUpdater
function monitor_cme_autoupdater_installation() {
    elapsed_time=0
    cme_initial_version=$($AWK -F= '/'$CME_INITIAL_VERSION_DATAFILE_VAR'/ {print $2; exit;}' $CME_INSTALLATION_DATA_FILE)
    cme_initial_version=$(($cme_initial_version + 0)) # convert to int
    LOG_ECHO "Starting installation monitor, total timeout: $INSTALLATION_TIMEOUT seconds"
    until [ $elapsed_time -gt $INSTALLATION_TIMEOUT ]
    do
        $SLEEP $WAIT_INTERVAL
        elapsed_time=$(($elapsed_time + $WAIT_INTERVAL))
        LOG_ECHO "Elapsed time: $elapsed_time seconds"
        $ECHO -n "....."
        cme_ver=$(get_cme_autoupdater_version)
        if [ $? -eq $FAILURE ]; then
            LOG_ECHO "Failed to read CME info from AutoUpdater, exiting installation"
            $ECHO ""
            return $MONITOR_INTERNAL_FAILURE
        fi
        cme_ver=$(($cme_ver + 0)) # convert to int
        # If CME final version is greater than the initial one then update succeeded
        if [ $cme_ver -gt $cme_initial_version ]; then
            $ECHO ""
            return $SUCCESS
        fi
    done
    $ECHO ""
    return $MONITOR_TIMEOUT_FAILURE
}

function install_cme() {
    # Get status of CME installation in AutoUpdater
    cme_installation_status=$(get_cme_installation_status)
    if [ $? -eq $FAILURE ]; then
        ALL_ECHO "$FAILED_TO_READ_CME_INFO_FROM_AUTOUPDATER_MESSAGE"
        return $FAILURE
    fi

    cme_installation_status=$(($cme_installation_status + 0)) # convert to int
    # If cme is not currently being installed by AutoUpdater
    if [ $cme_installation_status -eq $AUTOUPDATER_CME_IDLE ]; then

        # Empty installation data file from possible previous entries
        $ECHO -n "" >$CME_INSTALLATION_DATA_FILE

        # Get the currently installed CME version
        curr_cme_ver=$(get_cme_autoupdater_version)
        if [ $? -eq $FAILURE ]; then
            ALL_ECHO "$FAILED_TO_READ_CME_INFO_FROM_AUTOUPDATER_MESSAGE"
            return $FAILURE
        fi

        # If there's a CME bundle that is currently installed
        if [ $(($curr_cme_ver + 0)) -gt 0 ]; then
            LOG_ECHO "Getting CME download scheduler state in AutoUpdater..."
            run_autoupdater_command "show json"
            if [ $? -eq $FAILURE ]; then
                ALL_ECHO "$FAILED_TO_READ_CME_INFO_FROM_AUTOUPDATER_MESSAGE"
                return $FAILURE
            fi
            cme_scheduler_active=$($ECHO "$AUTOUPDATER_COMMAND_OUTPUT" | $JQ '.products[] | select(."product-name"=="CloudGuard_IaaS")' 2>/dev/null | $JQ '."product-components"[] | select(."component-name"=="CME")."download-scheduler-active"' 2>/dev/null)
            cme_scheduler_active=$($ECHO $cme_scheduler_active) # remove spaces from variable
            # If CME is enabled then don't install
            if [[ $cme_scheduler_active =~ true ]]; then
                ALL_ECHO "$CME_ALREADY_INSTALLED_MESSAGE"
                return $FAILURE
            else
                ALL_ECHO "$CME_DISABLED_WILL_INSTALL_MESSAGE"
                # Record the current latest version of CME installed in Darwin
                $ECHO "$CME_INITIAL_VERSION_DATAFILE_VAR=$curr_cme_ver" >>$CME_INSTALLATION_DATA_FILE
            fi
        else
            $ECHO "$CME_INITIAL_VERSION_DATAFILE_VAR=0" >>$CME_INSTALLATION_DATA_FILE
        fi

        # Record the current number of CME bundles listed inside AutoUpdater for later indication of successful/unsuccessful download
        cme_initial_bundle_count=$(get_cme_bundles_count_in_autoupdater)
        if [ $? -eq $FAILURE ]; then
            ALL_ECHO "$FAILED_TO_READ_CME_INFO_FROM_AUTOUPDATER_MESSAGE"
            return $FAILURE
        fi
        $ECHO "cme_initial_bundle_count=$cme_initial_bundle_count" >>$CME_INSTALLATION_DATA_FILE

        LOG_ECHO "Content of CME installation data file:"
        LOG_ECHO "----------------------------------------"
        $CAT $CME_INSTALLATION_DATA_FILE >> $CME_INSTALLATION_LOGFILE
        LOG_ECHO "----------------------------------------"

        # Enable online updates for CME in AutoUpdater - will begin download of latest CME bundle from Download Center
        LOG_ECHO "Enabling automatic updates for CME in AutoUpdater..."
        run_autoupdater_command "enable CME" >>$CME_INSTALLATION_LOGFILE 2>&1
        if [ $? -eq $FAILURE ]; then
            LOG_ECHO "Failed to enable CME in AutoUpdater"
            ALL_ECHO "$FAILED_TO_ENABLE_CME_DOWNLOAD_MESSAGE"
            return $FAILURE
        fi

        # Stop AutoUpdater after enabling CME
        LOG_ECHO "Stopping AutoUpdater..."
        run_autoupdater_command "stop" >>$CME_INSTALLATION_LOGFILE 2>&1
        if [ $? -eq $FAILURE ]; then
            LOG_ECHO "Failed to stop AutoUpdater"
            ALL_ECHO "$FAILED_TO_ENABLE_CME_DOWNLOAD_MESSAGE"
            return $FAILURE
        fi

        ALL_ECHO "$INSTALLING_CME_VIA_ONLINE_UPDATE_MESSAGE"
    # CME installation is in progress in AutoUpdater
    elif [ $cme_installation_status -eq $AUTOUPDATER_CME_INSTALLING ]; then
        # If installation of CME in AutoUpdater was initiated not by this script then installation data file will be missing
        if [ ! -f $CME_INSTALLATION_DATA_FILE ]; then
            ALL_ECHO "$ANOTHER_CME_INSTALLATION_IN_PROGRESS"
            return $FAILURE
        fi
        # CME installation already initiated, skip to monitor
        ALL_ECHO "$CME_CURRENTLY_INSTALLING_MESSAGE"
    fi

    # Start monitoring installation of CME in AutoUpdater
    monitor_cme_autoupdater_installation
    monitor_result=$?
    # Installation succeeded
    if [ $monitor_result -eq $SUCCESS ]; then
        ALL_ECHO "$SUCCESSFULLY_INSTALLED_CME_MESSAGE"
        return $SUCCESS
    # Installation failed
    elif [ $monitor_result -eq $MONITOR_TIMEOUT_FAILURE ]; then
        cme_initial_bundle_count=$($AWK -F= '/cme_initial_bundle_count/ {print $2; exit;}' $CME_INSTALLATION_DATA_FILE)
        cme_initial_bundle_count=$(($cme_initial_bundle_count + 0)) # convert to int
        cme_final_bundle_count=$(get_cme_bundles_count_in_autoupdater)
        if [ $? -eq $FAILURE ]; then
            ALL_ECHO "$FAILED_TO_READ_CME_INFO_FROM_AUTOUPDATER_MESSAGE"
            return $FAILURE
        fi
        # If a new bundle was downloaded (but failed to install)
        if [ $cme_initial_bundle_count -lt $cme_final_bundle_count ]; then
            ALL_ECHO "$FAILED_TO_INSTALL_CME_BUNDLE_MESSAGE"
        # No bundle was downloaded and the initial bundle count is equal to the final bundle count
        else
            if [ $cme_final_bundle_count -eq 0 ]; then
                ALL_ECHO "$FAILED_TO_DOWNLOAD_CME_BUNDLE_MESSAGE"
            else
                ALL_ECHO "$FAILED_TO_INSTALL_CME_BUNDLE_MESSAGE"
            fi
        fi

    else
        LOG_ECHO "Monitor failed with internal error"
        ALL_ECHO "$FAILED_TO_VERIFY_CME_INSTALLATION_MESSAGE"
    fi
    return $FAILURE
}

################################### end of funtions ####################################

################################### Main of program starts here ###################################
# Create CME log dir
$MKDIR -p $CME_LOGDIR
LOG_ECHO "\n${HEADLINE_DELIMITER} $($DATE '+%d/%m/%Y  %H:%M:%S ') ${HEADLINE_DELIMITER}\n"

init_cp_version_numeric

# If AutoUpdater is not installed
if [ ! -d /opt/AutoUpdater ]; then
    ALL_ECHO "$AUTOUPDATER_NOT_INSTALLED_MESSAGE"
    exit 1
fi

ALL_ECHO "$VERIFYING_PRECONDITIONS_MESSAGE"
verify_preconditions

# Set debug mode in AutoUpdater to DEBUG for the execution of the script
LOG_ECHO "Setting AutoUpdater debug mode to: DEBUG"
run_autoupdater_command "debug DEBUG"
install_cme
installation_result=$?
# Set debug mode in AutoUpdater back to NORMAL
LOG_ECHO "Setting AutoUpdater debug mode to: NORMAL"
run_autoupdater_command "debug NORMAL"
$RM -f $CME_INSTALLATION_DATA_FILE >>$CME_INSTALLATION_LOGFILE 2>&1
if [ $installation_result -eq $SUCCESS ]; then
    exit 0
fi

# In case of failed installation, disable CME updates for HA machines
LOG_ECHO "Checking if machine is part of HA environment..."
ha_peers=$(psql_client cpm postgres -c "select count(objid) from cpnetworkobject_data where dlesession=0 and not deleted and servertype=0" 2>/dev/null | $GREP -E -o "^[ \t]*([0-9]|([1-9][0-9])*)$" | $GREP -E -o "[0-9]|([1-9][0-9]*)")
# SQL server probably doesn't exist (maybe because machine is prior to First Time Wizard)
if [ -z "$ha_peers" ]; then
    LOG_ECHO "Failed to connect to SQL server of the machine - unable to resolve current HA configuration"
elif [ $ha_peers -gt 1 ]; then
    LOG_ECHO "HA machine detected - CME autoupdates will be turned off in AutoUpdater"
    run_autoupdater_command "disable CME"
    # if AutoUpdater failed to turn off automatic updates inform to turn off manually
    if [ $? -eq $FAILURE ]; then
        ALL_ECHO "$DISABLE_HA_CME_MANUALLY"
    else
        LOG_ECHO "Successfully disabled automatic updates for CME in AutoUpdater"
    fi
fi

exit 1
################################### Main of program ends here ###################################