#include "include/device_permission/device_permission_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <map>
#include <vector>

#include "device_permission_plugin_private.h"

#define DEVICE_PERMISSION_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), device_permission_plugin_get_type(), \
                              DevicePermissionPlugin))

struct _DevicePermissionPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(DevicePermissionPlugin, device_permission_plugin, g_object_get_type())

static int check_permission_status(int permission) {
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
    case 36: // calendarWriteOnly
    case 37: // calendarFullAccess
    case 38: // assistant
      return 1; // granted - Linux desktop doesn't have unified permission system
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
    case 39: // backgroundRefresh
    default:
      return 2; // restricted for mobile-only or unsupported permissions
  }
}

static int check_service_status(int permission) {
  switch (permission) {
    case 3:  // location
    case 4:  // locationAlways
    case 5:  // locationWhenInUse
      return 1; // enabled (geoclue typically available)
    case 8:  // phone
      return 2; // notApplicable
    case 21: // bluetooth
      return 1; // enabled
    default:
      return 2; // notApplicable
  }
}

static void device_permission_plugin_handle_method_call(
    DevicePermissionPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "checkPermissionStatus") == 0) {
    int permission = (int)fl_value_get_int(fl_value_get_list_value(args, 0));
    int status = check_permission_status(permission);
    g_autoptr(FlValue) result = fl_value_new_int(status);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));

  } else if (strcmp(method, "checkServiceStatus") == 0) {
    int permission = (int)fl_value_get_int(fl_value_get_list_value(args, 0));
    int status = check_service_status(permission);
    g_autoptr(FlValue) result = fl_value_new_int(status);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));

  } else if (strcmp(method, "requestPermissions") == 0) {
    g_autoptr(FlValue) result_map = fl_value_new_map();
    size_t len = fl_value_get_length(args);
    for (size_t i = 0; i < len; i++) {
      int perm = (int)fl_value_get_int(fl_value_get_list_value(args, i));
      int status = check_permission_status(perm);
      g_autoptr(FlValue) key = fl_value_new_int(perm);
      g_autoptr(FlValue) val = fl_value_new_int(status);
      fl_value_set(result_map, key, val);
    }
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result_map));

  } else if (strcmp(method, "shouldShowRequestPermissionRationale") == 0) {
    g_autoptr(FlValue) result = fl_value_new_bool(FALSE);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));

  } else if (strcmp(method, "openAppSettings") == 0) {
    const gchar* command = "gnome-control-center privacy";
    g_spawn_command_line_async(command, nullptr);
    g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));

  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void device_permission_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(device_permission_plugin_parent_class)->dispose(object);
}

static void device_permission_plugin_class_init(DevicePermissionPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = device_permission_plugin_dispose;
}

static void device_permission_plugin_init(DevicePermissionPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  DevicePermissionPlugin* plugin = DEVICE_PERMISSION_PLUGIN(user_data);
  device_permission_plugin_handle_method_call(plugin, method_call);
}

void device_permission_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  DevicePermissionPlugin* plugin = DEVICE_PERMISSION_PLUGIN(
      g_object_new(device_permission_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "com.arcas0803.device_permission/permissions",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
