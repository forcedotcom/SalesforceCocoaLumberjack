#!/bin/bash

# Builds the CocoaLumberjack Debug and Release builds, creating a zip archive of each in the artifacts folder.

ROOT_PATH=`dirname $0`
ROOT_PATH=`( cd "${ROOT_PATH}" && pwd )`
ARTIFACTS_PATH="${ROOT_PATH}/artifacts"
PROJECT_NAME="CocoaLumberjack"
XCODE_PROJECT_PATH="${ROOT_PATH}/../${PROJECT_NAME}/${PROJECT_NAME}.xcodeproj"
LIB_NAME="lib${PROJECT_NAME}.a"

function buildWithConfig()
{
    local buildConfig=$1
    local tempOutputFolderPrefix=`basename ${BASH_SOURCE[0]}`
    local tempOutputFolderTemplate="/tmp/${tempOutputFolderPrefix}.XXXXXX"
    local tempOutputFolder=`mktemp -d ${tempOutputFolderTemplate}`
    local appFolder="${tempOutputFolder}/${PROJECT_NAME}"

    echo "--- Building ${buildConfig} configuration ---"

    echo "Creating working folder..."
    mkdir "${appFolder}"

    echo "Building..."
    xcodebuild -project "${XCODE_PROJECT_PATH}" -configuration ${buildConfig} -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${ARTIFACTS_PATH}/${buildConfig}/device" ONLY_ACTIVE_ARCH=NO
    xcodebuild -project "${XCODE_PROJECT_PATH}" -configuration ${buildConfig} -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${ARTIFACTS_PATH}/${buildConfig}/sim" ONLY_ACTIVE_ARCH=NO

    echo "Running lipo..."
    lipo -create -output "${appFolder}/${LIB_NAME}" "${ARTIFACTS_PATH}/${buildConfig}/device/${LIB_NAME}" "${ARTIFACTS_PATH}/${buildConfig}/sim/${LIB_NAME}"
    echo "Copying headers..."
    cp -R "${ARTIFACTS_PATH}/${buildConfig}/sim/Headers" "${appFolder}"
    echo "Archiving the library package..."
    ditto -k -c --keepParent --norsrc "${appFolder}" "${ARTIFACTS_PATH}/${PROJECT_NAME}-${buildConfig}.zip"

    echo "Removing working folder..."
    rm -rf "${tempOutputFolder}"

    echo "--- Finished building ${buildConfig} configuration ---"
}

buildWithConfig Debug
buildWithConfig Release
