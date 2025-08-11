#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/vcano5/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/vcano5/ProxmoxVE/raw/main/LICENSE
# Source: https://ombi.io/

APP="Ombi"
var_tags="${var_tags:-media}"
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
  if [[ ! -d /opt/ombi ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  RELEASE=$(curl -fsSL https://api.github.com/repos/Ombi-app/Ombi/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ "${RELEASE}" != "$(cat ~/.ombi)" ]] || [[ ! -f ~/.ombi ]]; then
    msg_info "Stopping ${APP} service"
    systemctl stop ombi
    msg_ok "Stopped ${APP} service"

    msg_info "Creating backup"
    [[ -f /opt/ombi/Ombi.db ]] && mv /opt/ombi/Ombi.db /opt
    [[ -f /opt/ombi/OmbiExternal.db ]] && mv /opt/ombi/OmbiExternal.db /opt
    [[ -f /opt/ombi/OmbiSettings.db ]] && mv /opt/ombi/OmbiSettings.db /opt
    msg_ok "Backup created"

    rm -rf /opt/ombi
    fetch_and_deploy_gh_release "ombi" "Ombi-app/Ombi" "prebuild" "latest" "/opt/ombi" "linux-x64.tar.gz"
    [[ -f /opt/Ombi.db ]] && mv /opt/Ombi.db /opt/ombi
    [[ -f /opt/OmbiExternal.db ]] && mv /opt/OmbiExternal.db /opt/ombi
    [[ -f /opt/OmbiSettings.db ]] && mv /opt/OmbiSettings.db /opt/ombi

    msg_info "Starting ${APP} service"
    systemctl start ombi
    msg_ok "Started ${APP} service"

    msg_ok "Updated Successfully"
  else
    msg_ok "No update required.  ${APP} ia already at ${RELEASE}."
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:5000${CL}"
