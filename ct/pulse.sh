#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/vcano5/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: rcourtman
# License: MIT | https://github.com/vcano5/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/rcourtman/Pulse

APP="Pulse"
var_tags="${var_tags:-monitoring,proxmox}"
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
  if [[ ! -d /opt/pulse ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if [[ ! -f ~/.pulse ]]; then
    msg_error "Old Installation Found! Please recreate the container due big changes in the software."
    exit 1
  fi

  RELEASE=$(curl -fsSL https://api.github.com/repos/rcourtman/Pulse/releases/latest | jq -r '.tag_name' | sed 's/^v//')
  if [[ "${RELEASE}" != "$(cat ~/.pulse 2>/dev/null)" ]] || [[ ! -f ~/.pulse ]]; then
    msg_info "Stopping ${APP}"
    systemctl stop pulse
    msg_ok "Stopped ${APP}"

    fetch_and_deploy_gh_release "pulse" "rcourtman/Pulse" "prebuild" "latest" "/opt/pulse" "*-linux-amd64.tar.gz"
    chown -R pulse:pulse /etc/pulse /opt/pulse
    sed -i 's|pulse/pulse|pulse/bin/pulse|' /etc/systemd/system/pulse.service
    systemctl daemon-reload
    if [[ -f /opt/pulse/pulse ]]; then
      rm -rf /opt/pulse/{pulse,frontend-modern}
    fi

    msg_info "Starting ${APP}"
    systemctl start pulse
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:7655${CL}"
