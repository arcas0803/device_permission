//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <device_permission/device_permission_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) device_permission_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DevicePermissionPlugin");
  device_permission_plugin_register_with_registrar(device_permission_registrar);
}
