#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/vcano5/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/vcano5/ProxmoxVE/raw/main/LICENSE
# Source: https://www.nocodb.com/

APP="NocoDB"
var_tags="${var_tags:-noCode}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage
    check_container_resources
    if [[ ! -f /etc/systemd/system/nocodb.service ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    RELEASE=$(curl -fsSL https://api.github.com/repos/nocodb/nocodb/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
    if [[ ! -f ~/.nocodb ]] || [[ "${RELEASE}" != "$(cat ~/.nocodb)" ]]; then
    msg_info "Stopping Service"
    systemctl stop nocodb
    msg_ok "Stopped Service"

    fetch_and_deploy_gh_release "nocodb" "nocodb/nocodb" "singlefile" "latest" "/opt/nocodb/" "Noco-linux-x64"

    msg_info "Starting Service"
    systemctl start nocodb
    msg_ok "Started Service"

    msg_ok "Updated Successfully"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080/dashboard${CL}"
