package com.arcas0803.device_permission

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log

class AppSettingsManager {
    fun openAppSettings(
        context: Context?,
        successCallback: (Boolean) -> Unit,
        errorCallback: (String, String) -> Unit,
    ) {
        if (context == null) {
            Log.d(PermissionConstants.LOG_TAG, "Context cannot be null.")
            errorCallback("PermissionHandler.AppSettingsManager", "Android context cannot be null.")
            return
        }

        try {
            val settingsIntent = Intent().apply {
                action = android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                addCategory(Intent.CATEGORY_DEFAULT)
                data = Uri.parse("package:" + context.packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
            }

            context.startActivity(settingsIntent)
            successCallback(true)
        } catch (ex: Exception) {
            successCallback(false)
        }
    }
}
