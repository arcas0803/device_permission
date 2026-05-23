#ifndef FLUTTER_PLUGIN_DEVICE_PERMISSION_PLUGIN_H_
#define FLUTTER_PLUGIN_DEVICE_PERMISSION_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace device_permission {

class DevicePermissionPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DevicePermissionPlugin();

  virtual ~DevicePermissionPlugin();

  DevicePermissionPlugin(const DevicePermissionPlugin&) = delete;
  DevicePermissionPlugin& operator=(const DevicePermissionPlugin&) = delete;

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace device_permission

#endif  // FLUTTER_PLUGIN_DEVICE_PERMISSION_PLUGIN_H_
