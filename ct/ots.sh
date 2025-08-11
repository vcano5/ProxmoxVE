#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/vcano5/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: bvdberg01
# License: MIT | https://github.com/vcano5/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Luzifer/ots

APP="OTS"
var_tags="${var_tags:-secrets-sharer}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-3}"
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
    if [[ ! -d /opt/ots ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    RELEASE=$(curl -fsSL https://api.github.com/repos/Luzifer/ots/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
    if [[ "${RELEASE}" != "$(cat ~/.ots 2>/dev/null)" ]] || [[ ! -f ~/.ots ]]; then
        msg_info "Stopping ${APP} Service"
        systemctl stop ots
        systemctl stop nginx
        msg_ok "Stopped ${APP} Service"

        fetch_and_deploy_gh_release "ots" "Luzifer/ots" "prebuild" "latest" "/opt/ots" "ots_linux_amd64.tgz"

        msg_info "Stopping ${APP} Service"
        systemctl start ots
        systemctl start nginx
        msg_ok "Stopped ${APP} Service"
        msg_ok "Updated Successfully"
    else
        msg_ok "No update required. ${APP} is already at ${RELEASE}"
    fi
    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}https://${IP}${CL}"
