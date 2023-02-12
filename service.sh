#!/system/bin/sh
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done

install_as_user_app(){
  pm list packages | grep -q "^package:${1}$" || return
  loc=$(pm list packages -f "${1}" | sed 's|package:\(.*\)=[^=]*|\1|g')
  echo "${loc}" | grep -q '^/data/' || pm install -r "${loc}"
}

get_app_uid(){ dumpsys package "${1}" | awk -F= '/userId/{print $2; exit}'; }
gms_uid="$(get_app_uid com.google.android.gms)"

if [ "$(getprop ro.build.version.sdk)" -ge 29 ]; then
  for i in com.google.android.gms com.android.vending; do
    install_as_user_app "${i}"  # once installed, it'll crash *once*, then reasonably work
    if settings list global | grep -q "^uids_allowed_on_restricted_networks="; then
      uid="$(get_app_uid "${i}")"; [ -n "${uid}" ] || continue
      settings get global uids_allowed_on_restricted_networks | grep -qE "(^|;)${uid}($|;)" || settings put global uids_allowed_on_restricted_networks "$(settings get global uids_allowed_on_restricted_networks);${uid}"
    fi
  done
fi

# allow GMS to doze off
if [ ${GMS_DOZE:-0} -ne 0 ]; then
  for i in \
    auth.managed.admin.DeviceAdminReceiver \
    mdm.receivers.MdmDeviceAdminReceiver \
    chimera.GmsIntentOperationService \
  ; do
    for j in $(pm list users | grep 'UserInfo{' | sed 's/[[:space:]]*UserInfo{\([0-9]*\):.*/\1/g'); do
      pm disable --user "${j}" "com.google.android.gms/${i}"
    done
  done
  dumpsys deviceidle whitelist -com.google.android.gms
fi
