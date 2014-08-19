#!/bin/sh
set -e

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/avatar/avatar-placeholder.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/avatar/avatar-placeholder@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-blue.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-blue@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-gray.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-gray@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-green.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-green@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-selected.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-selected@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-typing.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic/bubble-classic-typing@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic-square/bubble-classic-square-blue.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic-square/bubble-classic-square-blue@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic-square/bubble-classic-square-gray.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic-square/bubble-classic-square-gray@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic-square/bubble-classic-square-selected.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic-square/bubble-classic-square-selected@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-min-tailless.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-min-tailless@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-min.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-min@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-stroked-tailless.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-stroked-tailless@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-stroked.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-stroked@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-tailless.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble-tailless@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat/bubble@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-classic/input-bar-background.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-classic/input-bar-background@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-classic/input-field-cover.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-classic/input-field-cover@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-classic/send-button-pressed.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-classic/send-button-pressed@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-classic/send-button.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-classic/send-button@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-flat/button-photo.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-flat/button-photo@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-flat/input-bar-flat.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-flat/input-bar-flat@2x.png"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Sounds/message-received.aiff"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Sounds/message-sent.aiff"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/avatar"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-classic-square"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/bubble-flat"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-classic"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Images/input-bar-flat"
install_resource "JSMessagesViewController/JSMessagesViewController/Resources/Sounds"

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ `xcrun --find actool` ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in 
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;  
  esac 
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
