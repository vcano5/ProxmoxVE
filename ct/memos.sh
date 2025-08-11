#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/vcano5/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://github.com/vcano5/ProxmoxVE/raw/main/LICENSE
# Source: https://www.usememos.com/

APP="Memos"
var_tags="${var_tags:-notes}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
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
  if [[ ! -d /opt/memos ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  
  RELEASE=$(curl -fsSL https://api.github.com/repos/usememos/memos/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ "${RELEASE}" != "$(cat ~/.memos 2>/dev/null)" ]] || [[ ! -f ~/.memos ]]; then
    msg_info "Stopping service"
    systemctl stop memos
    msg_ok "Service stopped"

    fetch_and_deploy_gh_release "memos" "usememos/memos" "prebuild" "latest" "/opt/memos" "memos*linux_amd64.tar.gz"

    msg_info "Starting service"
    systemctl start memos
    msg_ok "Service started"

    msg_ok "Updated successfully"
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:9030${CL}"
