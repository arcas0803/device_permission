#include "device_permission_plugin.h"

#include <windows.h>
#include <shellapi.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <map>
#include <vector>

namespace device_permission {

void DevicePermissionPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "com.arcas0803.device_permission/permissions",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<DevicePermissionPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

DevicePermissionPlugin::DevicePermissionPlugin() {}

DevicePermissionPlugin::~DevicePermissionPlugin() {}

static int checkPermissionStatus(int permission) {
  switch (permission) {
    case 0:  // calendar
    case 1:  // camera
    case 2:  // contacts
    case 3:  // location
    case 4:  // locationAlways
    case 5:  // locationWhenInUse
    case 6:  // mediaLibrary
    case 7:  // microphone
    case 9:  // photos
    case 11: // reminders
    case 12: // sensors
    case 14: // speech
    case 15: // storage
    case 17: // notification
    case 21: // bluetooth
    case 32: // videos
    case 33: // audio
    case 38: // assistant
      return 1; // granted - Windows doesn't have a unified permission system
    case 8:  // phone
    case 13: // sms
    case 16: // ignoreBatteryOptimizations
    case 18: // accessMediaLocation
    case 19: // activityRecognition
    case 20: // unknown
    case 22: // manageExternalStorage
    case 23: // systemAlertWindow
    case 24: // requestInstallPackages
    case 25: // appTrackingTransparency
    case 26: // criticalAlerts
    case 27: // accessNotificationPolicy
    case 28: // bluetoothScan
    case 29: // bluetoothAdvertise
    case 30: // bluetoothConnect
    case 31: // nearbyWifiDevices
    case 34: // scheduleExactAlarm
    case 35: // sensorsAlways
    case 36: // calendarWriteOnly
    case 37: // calendarFullAccess
    case 39: // backgroundRefresh
    default:
      return 1; // granted
  }
}

static int checkServiceStatus(int permission) {
  switch (permission) {
    case 3:  // location
    case 4:  // locationAlways
    case 5:  // locationWhenInUse
      return 1; // enabled
    case 8:  // phone
      return 2; // notApplicable
    case 21: // bluetooth
      return 1; // enabled
    default:
      return 2; // notApplicable
  }
}

void DevicePermissionPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string &method = method_call.method_name();

  if (method == "checkPermissionStatus") {
    int permission = std::get<int>(*method_call.arguments());
    int status = checkPermissionStatus(permission);
    result->Success(flutter::EncodableValue(status));
  } else if (method == "checkServiceStatus") {
    int permission = std::get<int>(*method_call.arguments());
    int status = checkServiceStatus(permission);
    result->Success(flutter::EncodableValue(status));
  } else if (method == "requestPermissions") {
    const auto *permissions = std::get_if<flutter::EncodableList>(method_call.arguments());
    flutter::EncodableMap resultMap;
    if (permissions) {
      for (const auto &perm : *permissions) {
        int permValue = std::get<int>(perm);
        int status = checkPermissionStatus(permValue);
        resultMap[flutter::EncodableValue(permValue)] = flutter::EncodableValue(status);
      }
    }
    result->Success(flutter::EncodableValue(resultMap));
  } else if (method == "shouldShowRequestPermissionRationale") {
    result->Success(flutter::EncodableValue(false));
  } else if (method == "openAppSettings") {
    ShellExecuteA(nullptr, "open", "ms-settings:", nullptr, nullptr, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}

}  // namespace device_permission
