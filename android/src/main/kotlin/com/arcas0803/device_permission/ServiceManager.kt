package com.arcas0803.device_permission

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.telephony.TelephonyManager
import android.text.TextUtils
import android.util.Log

class ServiceManager {
    fun checkServiceStatus(
        permission: Int,
        context: Context?,
        successCallback: (Int) -> Unit,
        errorCallback: (String, String) -> Unit,
    ) {
        if (context == null) {
            Log.d(PermissionConstants.LOG_TAG, "Context cannot be null.")
            errorCallback("PermissionHandler.ServiceManager", "Android context cannot be null.")
            return
        }

        if (permission == PermissionConstants.PERMISSION_GROUP_LOCATION ||
            permission == PermissionConstants.PERMISSION_GROUP_LOCATION_ALWAYS ||
            permission == PermissionConstants.PERMISSION_GROUP_LOCATION_WHEN_IN_USE
        ) {
            val serviceStatus = if (isLocationServiceEnabled(context))
                PermissionConstants.SERVICE_STATUS_ENABLED
            else
                PermissionConstants.SERVICE_STATUS_DISABLED

            successCallback(serviceStatus)
            return
        }

        if (permission == PermissionConstants.PERMISSION_GROUP_BLUETOOTH) {
            val serviceStatus = if (isBluetoothServiceEnabled(context))
                PermissionConstants.SERVICE_STATUS_ENABLED
            else
                PermissionConstants.SERVICE_STATUS_DISABLED

            successCallback(serviceStatus)
            return
        }

        if (permission == PermissionConstants.PERMISSION_GROUP_PHONE) {
            val pm = context.packageManager
            if (!pm.hasSystemFeature(PackageManager.FEATURE_TELEPHONY)) {
                successCallback(PermissionConstants.SERVICE_STATUS_NOT_APPLICABLE)
                return
            }

            val telephonyManager =
                context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager

            if (telephonyManager == null ||
                telephonyManager.phoneType == TelephonyManager.PHONE_TYPE_NONE
            ) {
                successCallback(PermissionConstants.SERVICE_STATUS_NOT_APPLICABLE)
                return
            }

            val callAppsList = getCallAppsList(pm)

            if (callAppsList.isEmpty()) {
                successCallback(PermissionConstants.SERVICE_STATUS_NOT_APPLICABLE)
                return
            }

            if (telephonyManager.simState != TelephonyManager.SIM_STATE_READY) {
                successCallback(PermissionConstants.SERVICE_STATUS_DISABLED)
                return
            }

            successCallback(PermissionConstants.SERVICE_STATUS_ENABLED)
            return
        }

        if (permission == PermissionConstants.PERMISSION_GROUP_IGNORE_BATTERY_OPTIMIZATIONS) {
            val serviceStatus = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PermissionConstants.SERVICE_STATUS_ENABLED
            else
                PermissionConstants.SERVICE_STATUS_NOT_APPLICABLE
            successCallback(serviceStatus)
            return
        }

        successCallback(PermissionConstants.SERVICE_STATUS_NOT_APPLICABLE)
    }

    @Suppress("DEPRECATION")
    private fun isLocationServiceEnabled(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val locationManager =
                context.getSystemService(Context.LOCATION_SERVICE) as LocationManager?
            locationManager?.isLocationEnabled ?: false
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            isLocationServiceEnabledKitKat(context)
        } else {
            isLocationServiceEnablePreKitKat(context)
        }
    }

    @Suppress("DEPRECATION")
    private fun isLocationServiceEnabledKitKat(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) return false

        val locationMode: Int = try {
            Settings.Secure.getInt(
                context.contentResolver,
                Settings.Secure.LOCATION_MODE,
            )
        } catch (e: Settings.SettingNotFoundException) {
            e.printStackTrace()
            return false
        }

        return locationMode != Settings.Secure.LOCATION_MODE_OFF
    }

    @Suppress("DEPRECATION")
    private fun isLocationServiceEnablePreKitKat(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) return false

        val locationProviders = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.LOCATION_PROVIDERS_ALLOWED,
        )
        return !TextUtils.isEmpty(locationProviders)
    }

    @Suppress("DEPRECATION")
    private fun isBluetoothServiceEnabled(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2) {
            BluetoothAdapter.getDefaultAdapter().isEnabled
        } else {
            val manager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
            val adapter = manager.adapter
            adapter.isEnabled
        }
    }

    @Suppress("DEPRECATION")
    private fun getCallAppsList(pm: PackageManager): List<android.content.pm.ResolveInfo> {
        val callIntent = Intent(Intent.ACTION_CALL)
        callIntent.data = Uri.parse("tel:123123")

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(
                callIntent,
                PackageManager.ResolveInfoFlags.of(0),
            )
        } else {
            pm.queryIntentActivities(callIntent, 0)
        }
    }
}
