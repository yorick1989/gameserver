#!/bin/bash

: ${SCRIPT_PATH:=$(cd "$(dirname "$0")" && pwd)}
: ${STEAMCMD_OS:=windows}
: ${GS_APPID:=2271150}
: ${GS_PATH:=${SCRIPT_PATH}/loya}
: ${GS_WORLD:=Default}

source "${SCRIPT_PATH}/steam_updater.sh"

function gameserver_config() {

  # Set the gameserver configuration values
  until [[ $# -eq 0 ]]; do
    case $1 in
      --name)
        _name="$2"
        shift # past argument
        shift # past value
        ;;
      --ip)
        _ip="$2"
        shift # past argument
        shift # past value
        ;;
      --port)
        _port="$2"
        shift # past argument
        shift # past value
        ;;
      --description)
        _description="$2"
        shift # past argument
        shift # past value
        ;;
      --difficulty)
        _difficulty="$2"
        shift # past argument
        shift # past value
        ;;
      --worldsize)
        _worldsize="$2"
        shift # past argument
        shift # past value
        ;;
      --visibility)
        _visibility="$2"
        shift # past argument
        shift # past value
        ;;
      -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
      *)
        shift # past argument
        ;;
    esac
  done

  if [ ! -f "${GS_PATH}/Server/Worlds/${GS_WORLD}/world.json" ]; then

    if [ ! -d "${GS_PATH}/Server/Worlds/${GS_WORLD}/" ]; then
      mkdir "${GS_PATH}/Server/Worlds/${GS_WORLD}/"
    fi

    cat << EOF > "${GS_PATH}/Server/Worlds/${GS_WORLD}/world.json"
{"Name":"${name:-${GS_WORLD:=Default}}","IP":"${_ip:=0.0.0.0}","Port":${_port:=15010},"Description":"${_description:=${_name:-${GS_WORLD:=Default}} world.}","Seed":5484662,"Difficuly":${_difficulty:=1},"WorldSize":${_worldsize:=1000.0},"Visibility":${_visibility:=2}}
EOF

    return 0
    
  fi

  if [ -n "${_name}" ]; then
    sed -i "s;\(\"Name\":\"\)[^\"]*\(\"\);\1${_name}\2;g" "${GS_PATH}/Server/Worlds/${GS_WORLD}/world.json"
  fi

  if [ -n "${_ip}" ]; then
    sed -i "s;\(\"IP\":\"\)[^\"]*\(\"\);\1${_ip}\2;g" "${GS_PATH}/Server/Worlds/${GS_WORLD}/world.json"
  fi

  if [ -n "${_port}" ]; then
    sed -i "s;\(\"Port\":\"\)[^\"]*\(\"\);\1${_port}\2;g" "${GS_PATH}/Server/Worlds/${GS_WORLD}/world.json"
  fi

  if [ -n "${_description}" ]; then
    sed -i "s;\(\"Description\":\"\)[^\"]*\(\"\);\1${_description}\2;g" "${GS_PATH}/Server/Worlds/${GS_WORLD}/world.json"
  fi

  if [ -n "${_difficulty}" ]; then
    sed -i "s;\(\"Difficulty\":\"\)[^\"]*\(\"\);\1${_difficulty}\2;g" "${GS_PATH}/Server/Worlds/${GS_WORLD}/world.json"
  fi

  if [ -n "${_worldsize}" ]; then
    sed -i "s;\(\"WorldSize\":\"\)[^\"]*\(\"\);\1${_worldsize}\2;g" "${GS_PATH}/Server/Worlds/${GS_WORLD}/world.json"
  fi

  if [ -n "${_visibility}" ]; then
    sed -i "s;\(\"Visibility\":\"\)[^\"]*\(\"\);\1${_visibility}\2;g" "${GS_PATH}/Server/Worlds/${GS_WORLD}/world.json"
  fi

  return 0

}

function gameserver_start() {

  : ${WINEPREFIX:=${HOME}/.wineprefix}
  export WINEPREFIX
  export WINEARCH=win64

  # Set the gameserver configuration values
  until [[ $# -eq 0 ]]; do
    case $1 in
      --ip)
        _ip="$2"
        shift # past argument
        shift # past value
        ;;
      -*|--*)
        shift # past argument
        shift # past value
        ;;
      *)
        shift # past argument
        ;;
    esac
  done

  if [ ! -d "${WINEPREFIX}" ]; then
    winecfg
  fi

  cd ${GS_PATH}/Server

  wine "${GS_PATH}"/Server/MirrorServer.exe ${_ip:=0.0.0.0}

}

if ! gameserver_check; then

  gameserver_update

fi

gameserver_config $*

gameserver_start $*
