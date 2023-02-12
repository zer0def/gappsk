#!/bin/bash

pushd app; find -type f -iname '*.tar.xz' -print0 | xargs -0 -n1 -- tar -xJf; popd
pushd overlay; find -type f -iname '*.tar.xz' -print0 | xargs -0 -n1 -- tar -xJf; popd
pushd priv-app; find -type f -iname '*.tar.xz' -print0 | xargs -0 -n1 -- tar -xJf; popd
pushd framework; find -type f -iname '*Framework.tar.xz' -print0 | xargs -0 -n1 -- tar -xJf; popd

mkdir -p etc/default-permissions etc/permissions etc/preferred-apps etc/security/fsverity etc/sysconfig

tar -xJf etc/Permissions.tar.xz -C etc/permissions
find framework -type f -iname '*Permissions.tar.xz' -print0 | xargs -0 -n1 -- tar -C etc/permissions -xJf

tar -xJf certificate/Certificate.tar.xz -C etc/security/fsverity
tar -xJf etc/Default.tar.xz -C etc/default-permissions
tar -xJf etc/Preferred.tar.xz -C etc/preferred-apps
tar -xJf etc/Sysconfig.tar.xz -C etc/sysconfig

find -type f -iname '*.tar.xz' -delete; rmdir certificate
find -type f -print0 | xargs -0 -- chmod -x
