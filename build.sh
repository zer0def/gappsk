#!/bin/sh

# Check existance of required tools and notify user of missing tools
#for i in java zip; do
#  command -v "${i}" >/dev/null 2>&1 || { echo "! ${i} is required but it's not installed. Aborting..." >&2; exit 1; }
#done

# Runtime Variables
ARCH="${1}"
API="${2}"

# Create build directory
RELEASE="GAppsk-${ARCH}-api${API}"

cd assets; git checkout "${API}"; cd "${OLDPWD}"
mkdir -p build/system
cp -rf "assets/${ARCH}/"* etc framework overlay build/system/
[ "${API}" -lt 26 ] || rm -rf build/system/priv-app/GoogleLoginService
[ "${API}" -ge 28 ] || rm -rf build/system/priv-app/GoogleRestore
[ "${API}" -lt 29 ] || rm -rf build/system/priv-app/GoogleBackupTransport
[ "${API}" -eq 29 ] || rm -f build/system/etc/default-permissions/gapps-permission.xml
[ "${API}" -ge 30 ] || rm -f build/overlay/PlayStoreOverlay.apk
cp -rf META-INF post-fs-data.sh service.sh build/

cat <<EOF >"build/module.prop"
id=GAppsk
name=GAppsk
version=v1.0
versionCode=10
author=zer0def
description=GAppsk
platform=${ARCH}
sdk=${API}
EOF

# Create ZIP
cd build; zip -qr9 "../${RELEASE}.zip" *; cd "${OLDPWD}"
if [ "${ZIPSIGN:-0}" -ne 0 ]; then
  java -jar zipsigner.jar "${RELEASE}.zip" "${RELEASE}_signed.zip" 2>/dev/null
  rm -f "${RELEASE}.zip"
fi
