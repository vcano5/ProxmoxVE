#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/vcano5/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Lucas Zampieri (zampierilucas) | MickLesk (CanbiZ)
# License: MIT | https://github.com/vcano5/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Cleanuparr/Cleanuparr

APP="Cleanuparr"
var_tags="${var_tags:-arr}"
var_cpu="${var_cpu:-2}"
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
    if [[ ! -f /opt/cleanuparr/Cleanuparr ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    RELEASE=$(curl -fsSL https://api.github.com/repos/Cleanuparr/Cleanuparr/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    if [[ "${RELEASE}" != "$(cat ~/.Cleanuparr 2>/dev/null)" ]] || [[ ! -f ~/.Cleanuparr ]]; then
        msg_info "Stopping ${APP}"
        systemctl stop cleanuparr
        msg_ok "Stopped ${APP}"

        fetch_and_deploy_gh_release "Cleanuparr" "Cleanuparr/Cleanuparr" "prebuild" "latest" "/opt/cleanuparr" "*linux-amd64.zip"

        msg_info "Starting ${APP}"
        systemctl start cleanuparr
        msg_ok "Started ${APP}"
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:11011${CL}"
