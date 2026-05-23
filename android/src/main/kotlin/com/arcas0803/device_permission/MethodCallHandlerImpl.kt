package com.arcas0803.device_permission

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MethodCallHandlerImpl(
    private val applicationContext: Context,
    private val appSettingsManager: AppSettingsManager,
    private val permissionManager: PermissionManager,
    private val serviceManager: ServiceManager,
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkServiceStatus" -> {
                val permission = (call.arguments as Int)
                serviceManager.checkServiceStatus(
                    permission,
                    applicationContext,
                    result::success,
                    { errorCode, errorDescription ->
                        result.error(errorCode, errorDescription, null)
                    },
                )
            }

            "checkPermissionStatus" -> {
                val permission = (call.arguments as Int)
                permissionManager.checkPermissionStatus(permission, result::success)
            }

            "requestPermissions" -> {
                @Suppress("UNCHECKED_CAST")
                val permissions = call.arguments as List<Int>
                permissionManager.requestPermissions(
                    permissions,
                    result::success,
                    { errorCode, errorDescription ->
                        result.error(errorCode, errorDescription, null)
                    },
                )
            }

            "shouldShowRequestPermissionRationale" -> {
                val permission = (call.arguments as Int)
                permissionManager.shouldShowRequestPermissionRationale(
                    permission,
                    result::success,
                    { errorCode, errorDescription ->
                        result.error(errorCode, errorDescription, null)
                    },
                )
            }

            "openAppSettings" -> {
                appSettingsManager.openAppSettings(
                    applicationContext,
                    result::success,
                    { errorCode, errorDescription ->
                        result.error(errorCode, errorDescription, null)
                    },
                )
            }

            else -> result.notImplemented()
        }
    }
}
