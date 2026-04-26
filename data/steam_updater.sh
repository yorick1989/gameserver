#!/bin/bash

: ${STEAMCMD_PATH:=${HOME}/steamcmd}
: ${STEAMCMD_LOGIN:=anonymous}
: ${STEAMCMD_OS:=linux}
: ${GS_APPID:=}
: ${GS_PATH:=}

# Install the SteamCMD binaries
function steamcmd_install() {

  if type -p wget > /dev/null 2>&1; then
    GET_BIN="$(type -p wget) -qO-"
  elif type -p curl > /dev/null 2>&1; then
    GET_BIN="$(type -p curl) -sqL"
  else
    return 1
  fi

  ${GET_BIN} "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
   | tar -C "${STEAMCMD_PATH}" -zxvf -

  if [ "$?" != "0" ]; then 
    return 1
  fi

  return 0

}

# Update gameserver
# $1 = branch name (default: public)
# $2 = branch password (default: [empty])
function gameserver_update() {

  # Set non-public (default) app branch
  if [ "$1" != "" ] && [ "$1" != "public" ]; then

    _app_branch_cmd="-beta '${branch}'"

    if [ "$2" != "" ]; then
      _app_branch_cmd+=" -betapassword '${betapassword}'"
    fi

  fi

  printf 'Install gameserver (appid: %s, branch: %s, path: %s)\n' "${GS_APPID}" "${_app_branch_cmd:-public}" "${GS_PATH}"

  ${STEAMCMD_PATH}/steamcmd.sh << EOF
@ShutdownOnFailedCommand 0
@NoPromptForPassword 1
login ${STEAMCMD_LOGIN}

@sSteamCmdForcePlatformType ${STEAMCMD_OS}
force_install_dir ${GS_PATH}
app_update ${GS_APPID} ${_app_branch_cmd} ${STEAMCMD_VALIDATE}
quit
EOF

}

function gameserver_check() {

  if [ ! -f "${STEAMCMD_PATH}/steamcmd.sh" ] && ! steamcmd_install; then
  
      ret=$?
      printf 'SteamCMD can not be installed.\n'

      exit ${ret}
  
  fi

  # Set the app branch name
  _app_branch="${1:-public}"

  # Set manifest variable
  _app_manifest="${GS_PATH}/steamapps/appmanifest_${GS_APPID}.acf"

  if [ ! -f "${GS_PATH}/steamapps/appmanifest_${GS_APPID}.acf" ]; then

    printf '%s\n' "Gameserver need to be updated."

    return 1

  fi

  # Compare downloaded bytes downloaded and staged
  _compare_downloaded=$(awk -F'"' '$2 ~ /^(BytesToDownload|BytesDownloaded|BytesToStage|BytesStaged)/{print $4}' "${_app_manifest}" | sort -n | uniq -c | wc -l)

  if [ "${_compare_downloaded}" != "2" ]; then

    printf '%s\n' "Gameserver need to be updated."

    return 1

  fi

  # Set the current build id
  _app_build_id=$(awk -F'"' '$2 == "buildid"{print $4}' "${_app_manifest}")

  # Set the app branches to a variable
  _app_branches_buildids=$(printf 'login %s\napp_info_update 1\napp_info_print %s\nquit' "${STEAMCMD_LOGIN}" "${GS_APPID}" | \
     ${STEAMCMD_PATH}/steamcmd.sh | \
     awk -F'"' '
      $2 == "branches" && $4 == ""{cbr=0}
      cbr != "" && /\s*\{\s*$/{cbr=cbr+1}
      cbr != "" && /\s*\}\s*$/{cbr=cbr-1}
      cbr == "1" && $2 != ""{printf $2 "/"}
      cbr == "2" && $2 == "buildid"{print $4}')

  _app_branch_latest_build_id=$(printf '%s' "${_app_branches_buildids}" | awk -v branch="${_app_branch}" -F'/' '$1 == branch{print $2}')

  if [ "${_app_build_id}" != "${_app_branch_latest_build_id}" ]; then

    printf '%s\n' "Gameserver need to be updated."

    return 1
    
  fi

  return 0

}
