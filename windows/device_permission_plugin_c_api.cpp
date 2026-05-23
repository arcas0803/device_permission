#include "include/device_permission/device_permission_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "device_permission_plugin.h"

void DevicePermissionPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  device_permission::DevicePermissionPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
