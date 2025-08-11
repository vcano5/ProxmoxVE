#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/vcano5/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: MickLesk (CanbiZ)
# License: MIT | https://github.com/vcano5/ProxmoxVE/raw/main/LICENSE
# Source: https://release-argus.io/

APP="Argus"
var_tags="${var_tags:-watcher}"
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
  if [[ ! -d /opt/argus ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  RELEASE=$(curl -fsSL https://api.github.com/repos/release-argus/Argus/releases/latest | jq -r .tag_name | sed 's/^v//')
  if [[ "${RELEASE}" != "$(cat ~/.Argus 2>/dev/null)" ]] || [[ ! -f ~/.Argus ]]; then
    msg_info "Stopping service"
    systemctl stop argus
    msg_ok "Service stopped"

    fetch_and_deploy_gh_release "Argus" "release-argus/Argus" "singlefile" "latest" "/opt/argus" "Argus*linux-amd64"

    msg_info "Starting service"
    systemctl start argus
    msg_ok "Service started"

    msg_ok "Updated ${APP} to ${RELEASE}"
  else
    msg_ok "${APP} is already up to date (${RELEASE})"
  fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"
