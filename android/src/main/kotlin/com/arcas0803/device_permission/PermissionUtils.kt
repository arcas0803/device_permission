package com.arcas0803.device_permission

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.util.Log
import androidx.core.app.ActivityCompat

object PermissionUtils {
    private const val SHARED_PREFERENCES_PERMISSION_WAS_DENIED_BEFORE_KEY =
        "sp_permission_handler_permission_was_denied_before"

    fun parseManifestName(permission: String): Int {
        return when (permission) {
            Manifest.permission.WRITE_CALENDAR,
            Manifest.permission.READ_CALENDAR -> PermissionConstants.PERMISSION_GROUP_CALENDAR

            Manifest.permission.CAMERA -> PermissionConstants.PERMISSION_GROUP_CAMERA
            Manifest.permission.READ_CONTACTS,
            Manifest.permission.WRITE_CONTACTS,
            Manifest.permission.GET_ACCOUNTS -> PermissionConstants.PERMISSION_GROUP_CONTACTS

            Manifest.permission.ACCESS_BACKGROUND_LOCATION -> PermissionConstants.PERMISSION_GROUP_LOCATION_ALWAYS
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_FINE_LOCATION -> PermissionConstants.PERMISSION_GROUP_LOCATION

            Manifest.permission.RECORD_AUDIO -> PermissionConstants.PERMISSION_GROUP_MICROPHONE
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.READ_PHONE_NUMBERS,
            Manifest.permission.CALL_PHONE,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.WRITE_CALL_LOG,
            Manifest.permission.ADD_VOICEMAIL,
            Manifest.permission.USE_SIP -> PermissionConstants.PERMISSION_GROUP_PHONE

            Manifest.permission.BODY_SENSORS -> PermissionConstants.PERMISSION_GROUP_SENSORS
            Manifest.permission.BODY_SENSORS_BACKGROUND -> PermissionConstants.PERMISSION_GROUP_SENSORS_ALWAYS
            Manifest.permission.SEND_SMS,
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS,
            Manifest.permission.RECEIVE_WAP_PUSH,
            Manifest.permission.RECEIVE_MMS -> PermissionConstants.PERMISSION_GROUP_SMS

            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE -> PermissionConstants.PERMISSION_GROUP_STORAGE

            Manifest.permission.ACCESS_MEDIA_LOCATION -> PermissionConstants.PERMISSION_GROUP_ACCESS_MEDIA_LOCATION
            Manifest.permission.ACTIVITY_RECOGNITION -> PermissionConstants.PERMISSION_GROUP_ACTIVITY_RECOGNITION
            Manifest.permission.MANAGE_EXTERNAL_STORAGE -> PermissionConstants.PERMISSION_GROUP_MANAGE_EXTERNAL_STORAGE
            Manifest.permission.SYSTEM_ALERT_WINDOW -> PermissionConstants.PERMISSION_GROUP_SYSTEM_ALERT_WINDOW
            Manifest.permission.REQUEST_INSTALL_PACKAGES -> PermissionConstants.PERMISSION_GROUP_REQUEST_INSTALL_PACKAGES
            Manifest.permission.ACCESS_NOTIFICATION_POLICY -> PermissionConstants.PERMISSION_GROUP_ACCESS_NOTIFICATION_POLICY
            Manifest.permission.BLUETOOTH_SCAN -> PermissionConstants.PERMISSION_GROUP_BLUETOOTH_SCAN
            Manifest.permission.BLUETOOTH_ADVERTISE -> PermissionConstants.PERMISSION_GROUP_BLUETOOTH_ADVERTISE
            Manifest.permission.BLUETOOTH_CONNECT -> PermissionConstants.PERMISSION_GROUP_BLUETOOTH_CONNECT
            Manifest.permission.POST_NOTIFICATIONS -> PermissionConstants.PERMISSION_GROUP_NOTIFICATION
            Manifest.permission.NEARBY_WIFI_DEVICES -> PermissionConstants.PERMISSION_GROUP_NEARBY_WIFI_DEVICES
            Manifest.permission.READ_MEDIA_IMAGES -> PermissionConstants.PERMISSION_GROUP_PHOTOS
            Manifest.permission.READ_MEDIA_VIDEO -> PermissionConstants.PERMISSION_GROUP_VIDEOS
            Manifest.permission.READ_MEDIA_AUDIO -> PermissionConstants.PERMISSION_GROUP_AUDIO
            Manifest.permission.SCHEDULE_EXACT_ALARM -> PermissionConstants.PERMISSION_GROUP_SCHEDULE_EXACT_ALARM
            else -> PermissionConstants.PERMISSION_GROUP_UNKNOWN
        }
    }

    fun getManifestNames(context: Context?, permission: Int): List<String>? {
        if (context == null) return null
        val permissionNames = ArrayList<String>()

        when (permission) {
            PermissionConstants.PERMISSION_GROUP_CALENDAR_WRITE_ONLY -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.WRITE_CALENDAR))
                    permissionNames.add(Manifest.permission.WRITE_CALENDAR)
            }

            PermissionConstants.PERMISSION_GROUP_CALENDAR_FULL_ACCESS,
            PermissionConstants.PERMISSION_GROUP_CALENDAR -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.WRITE_CALENDAR))
                    permissionNames.add(Manifest.permission.WRITE_CALENDAR)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_CALENDAR))
                    permissionNames.add(Manifest.permission.READ_CALENDAR)
            }

            PermissionConstants.PERMISSION_GROUP_CAMERA -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.CAMERA))
                    permissionNames.add(Manifest.permission.CAMERA)
            }

            PermissionConstants.PERMISSION_GROUP_CONTACTS -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_CONTACTS))
                    permissionNames.add(Manifest.permission.READ_CONTACTS)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.WRITE_CONTACTS))
                    permissionNames.add(Manifest.permission.WRITE_CONTACTS)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.GET_ACCOUNTS))
                    permissionNames.add(Manifest.permission.GET_ACCOUNTS)
            }

            PermissionConstants.PERMISSION_GROUP_LOCATION_ALWAYS,
            PermissionConstants.PERMISSION_GROUP_LOCATION_WHEN_IN_USE,
            PermissionConstants.PERMISSION_GROUP_LOCATION -> {
                if (permission == PermissionConstants.PERMISSION_GROUP_LOCATION_ALWAYS &&
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
                ) {
                    if (hasPermissionInManifest(
                            context,
                            permissionNames,
                            Manifest.permission.ACCESS_BACKGROUND_LOCATION,
                        )
                    )
                        permissionNames.add(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
                    return permissionNames
                }

                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.ACCESS_COARSE_LOCATION))
                    permissionNames.add(Manifest.permission.ACCESS_COARSE_LOCATION)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.ACCESS_FINE_LOCATION))
                    permissionNames.add(Manifest.permission.ACCESS_FINE_LOCATION)
            }

            PermissionConstants.PERMISSION_GROUP_SPEECH,
            PermissionConstants.PERMISSION_GROUP_MICROPHONE -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.RECORD_AUDIO))
                    permissionNames.add(Manifest.permission.RECORD_AUDIO)
            }

            PermissionConstants.PERMISSION_GROUP_PHONE -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_PHONE_STATE))
                    permissionNames.add(Manifest.permission.READ_PHONE_STATE)
                if (Build.VERSION.SDK_INT > Build.VERSION_CODES.Q &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_PHONE_NUMBERS)
                )
                    permissionNames.add(Manifest.permission.READ_PHONE_NUMBERS)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.CALL_PHONE))
                    permissionNames.add(Manifest.permission.CALL_PHONE)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_CALL_LOG))
                    permissionNames.add(Manifest.permission.READ_CALL_LOG)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.WRITE_CALL_LOG))
                    permissionNames.add(Manifest.permission.WRITE_CALL_LOG)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.ADD_VOICEMAIL))
                    permissionNames.add(Manifest.permission.ADD_VOICEMAIL)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.USE_SIP))
                    permissionNames.add(Manifest.permission.USE_SIP)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.ANSWER_PHONE_CALLS)
                )
                    permissionNames.add(Manifest.permission.ANSWER_PHONE_CALLS)
            }

            PermissionConstants.PERMISSION_GROUP_SENSORS -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
                    if (hasPermissionInManifest(context, permissionNames, Manifest.permission.BODY_SENSORS))
                        permissionNames.add(Manifest.permission.BODY_SENSORS)
                }
            }

            PermissionConstants.PERMISSION_GROUP_SENSORS_ALWAYS -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    if (hasPermissionInManifest(context, permissionNames, Manifest.permission.BODY_SENSORS_BACKGROUND))
                        permissionNames.add(Manifest.permission.BODY_SENSORS_BACKGROUND)
                }
            }

            PermissionConstants.PERMISSION_GROUP_SMS -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.SEND_SMS))
                    permissionNames.add(Manifest.permission.SEND_SMS)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.RECEIVE_SMS))
                    permissionNames.add(Manifest.permission.RECEIVE_SMS)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_SMS))
                    permissionNames.add(Manifest.permission.READ_SMS)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.RECEIVE_WAP_PUSH))
                    permissionNames.add(Manifest.permission.RECEIVE_WAP_PUSH)
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.RECEIVE_MMS))
                    permissionNames.add(Manifest.permission.RECEIVE_MMS)
            }

            PermissionConstants.PERMISSION_GROUP_STORAGE -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_EXTERNAL_STORAGE))
                    permissionNames.add(Manifest.permission.READ_EXTERNAL_STORAGE)
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
                    (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q && Environment.isExternalStorageLegacy())
                ) {
                    if (hasPermissionInManifest(
                            context,
                            permissionNames,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        )
                    )
                        permissionNames.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                }
            }

            PermissionConstants.PERMISSION_GROUP_IGNORE_BATTERY_OPTIMIZATIONS -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                    hasPermissionInManifest(
                        context,
                        permissionNames,
                        Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                    )
                )
                    permissionNames.add(Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            }

            PermissionConstants.PERMISSION_GROUP_ACCESS_MEDIA_LOCATION -> {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.ACCESS_MEDIA_LOCATION))
                    permissionNames.add(Manifest.permission.ACCESS_MEDIA_LOCATION)
            }

            PermissionConstants.PERMISSION_GROUP_ACTIVITY_RECOGNITION -> {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.ACTIVITY_RECOGNITION))
                    permissionNames.add(Manifest.permission.ACTIVITY_RECOGNITION)
            }

            PermissionConstants.PERMISSION_GROUP_BLUETOOTH -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.BLUETOOTH))
                    permissionNames.add(Manifest.permission.BLUETOOTH)
            }

            PermissionConstants.PERMISSION_GROUP_MANAGE_EXTERNAL_STORAGE -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.MANAGE_EXTERNAL_STORAGE)
                )
                    permissionNames.add(Manifest.permission.MANAGE_EXTERNAL_STORAGE)
            }

            PermissionConstants.PERMISSION_GROUP_SYSTEM_ALERT_WINDOW -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.SYSTEM_ALERT_WINDOW))
                    permissionNames.add(Manifest.permission.SYSTEM_ALERT_WINDOW)
            }

            PermissionConstants.PERMISSION_GROUP_REQUEST_INSTALL_PACKAGES -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.REQUEST_INSTALL_PACKAGES)
                )
                    permissionNames.add(Manifest.permission.REQUEST_INSTALL_PACKAGES)
            }

            PermissionConstants.PERMISSION_GROUP_ACCESS_NOTIFICATION_POLICY -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.ACCESS_NOTIFICATION_POLICY)
                )
                    permissionNames.add(Manifest.permission.ACCESS_NOTIFICATION_POLICY)
            }

            PermissionConstants.PERMISSION_GROUP_BLUETOOTH_SCAN -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val result =
                        determineBluetoothPermission(context, Manifest.permission.BLUETOOTH_SCAN)
                    if (result != null) permissionNames.add(result)
                }
            }

            PermissionConstants.PERMISSION_GROUP_BLUETOOTH_ADVERTISE -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val result =
                        determineBluetoothPermission(context, Manifest.permission.BLUETOOTH_ADVERTISE)
                    if (result != null) permissionNames.add(result)
                }
            }

            PermissionConstants.PERMISSION_GROUP_BLUETOOTH_CONNECT -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val result =
                        determineBluetoothPermission(context, Manifest.permission.BLUETOOTH_CONNECT)
                    if (result != null) permissionNames.add(result)
                }
            }

            PermissionConstants.PERMISSION_GROUP_NOTIFICATION -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.POST_NOTIFICATIONS)
                )
                    permissionNames.add(Manifest.permission.POST_NOTIFICATIONS)
            }

            PermissionConstants.PERMISSION_GROUP_NEARBY_WIFI_DEVICES -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.NEARBY_WIFI_DEVICES)
                )
                    permissionNames.add(Manifest.permission.NEARBY_WIFI_DEVICES)
            }

            PermissionConstants.PERMISSION_GROUP_PHOTOS -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_MEDIA_IMAGES)
                )
                    permissionNames.add(Manifest.permission.READ_MEDIA_IMAGES)
            }

            PermissionConstants.PERMISSION_GROUP_VIDEOS -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_MEDIA_VIDEO)
                )
                    permissionNames.add(Manifest.permission.READ_MEDIA_VIDEO)
            }

            PermissionConstants.PERMISSION_GROUP_AUDIO -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    hasPermissionInManifest(context, permissionNames, Manifest.permission.READ_MEDIA_AUDIO)
                )
                    permissionNames.add(Manifest.permission.READ_MEDIA_AUDIO)
            }

            PermissionConstants.PERMISSION_GROUP_SCHEDULE_EXACT_ALARM -> {
                if (hasPermissionInManifest(context, permissionNames, Manifest.permission.SCHEDULE_EXACT_ALARM))
                    permissionNames.add(Manifest.permission.SCHEDULE_EXACT_ALARM)
            }

            PermissionConstants.PERMISSION_GROUP_MEDIA_LIBRARY,
            PermissionConstants.PERMISSION_GROUP_REMINDERS,
            PermissionConstants.PERMISSION_GROUP_UNKNOWN -> return null
        }

        return permissionNames
    }

    @Suppress("DEPRECATION")
    private fun hasPermissionInManifest(
        context: Context,
        confirmedPermissions: ArrayList<String>,
        permission: String,
    ): Boolean {
        try {
            for (r in confirmedPermissions) {
                if (r == permission) return true
            }

            if (context == null) {
                Log.d(
                    PermissionConstants.LOG_TAG,
                    "Unable to detect current Activity or App Context.",
                )
                return false
            }

            val info = getPackageInfo(context)
                ?: run {
                    Log.d(
                        PermissionConstants.LOG_TAG,
                        "Unable to get Package info, will not be able to determine permissions to request.",
                    )
                    return false
                }

            val requestedPermissions = info.requestedPermissions?.toList() ?: return false
            val confirmed = ArrayList(requestedPermissions)
            for (r in confirmed) {
                if (r == permission) return true
            }
        } catch (ex: Exception) {
            Log.d(PermissionConstants.LOG_TAG, "Unable to check manifest for permission: ", ex)
        }
        return false
    }

    @Suppress("DEPRECATION")
    fun toPermissionStatus(
        activity: Activity?,
        permissionName: String,
        grantResult: Int,
    ): Int {
        if (grantResult == PackageManager.PERMISSION_DENIED) {
            return determineDeniedVariant(activity, permissionName)
        }

        return PermissionConstants.PERMISSION_STATUS_GRANTED
    }

    fun strictestStatus(statuses: Collection<Int>): Int {
        return when {
            statuses.contains(PermissionConstants.PERMISSION_STATUS_NEVER_ASK_AGAIN) ->
                PermissionConstants.PERMISSION_STATUS_NEVER_ASK_AGAIN

            statuses.contains(PermissionConstants.PERMISSION_STATUS_RESTRICTED) ->
                PermissionConstants.PERMISSION_STATUS_RESTRICTED

            statuses.contains(PermissionConstants.PERMISSION_STATUS_DENIED) ->
                PermissionConstants.PERMISSION_STATUS_DENIED

            statuses.contains(PermissionConstants.PERMISSION_STATUS_LIMITED) ->
                PermissionConstants.PERMISSION_STATUS_LIMITED

            else -> PermissionConstants.PERMISSION_STATUS_GRANTED
        }
    }

    fun strictestStatus(statusA: Int?, statusB: Int?): Int {
        val statuses = HashSet<Int>()
        statusA?.let { statuses.add(it) }
        statusB?.let { statuses.add(it) }
        return strictestStatus(statuses)
    }

    fun determineDeniedVariant(
        activity: Activity?,
        permissionName: String,
    ): Int {
        if (activity == null) return PermissionConstants.PERMISSION_STATUS_DENIED
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return PermissionConstants.PERMISSION_STATUS_DENIED

        val wasDeniedBefore = wasPermissionDeniedBefore(activity, permissionName)
        val shouldShowRational = !isNeverAskAgainSelected(activity, permissionName)

        val isDenied = if (wasDeniedBefore) !shouldShowRational else shouldShowRational

        if (!wasDeniedBefore && isDenied) {
            setPermissionDenied(activity, permissionName)
        }

        if (wasDeniedBefore && isDenied) {
            return PermissionConstants.PERMISSION_STATUS_NEVER_ASK_AGAIN
        }

        return PermissionConstants.PERMISSION_STATUS_DENIED
    }

    fun isNeverAskAgainSelected(activity: Activity, name: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return false
        val shouldShowRequestPermissionRationale =
            ActivityCompat.shouldShowRequestPermissionRationale(activity, name)
        return !shouldShowRequestPermissionRationale
    }

    private fun determineBluetoothPermission(
        context: Context,
        permission: String,
    ): String? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            hasPermissionInManifest(context, ArrayList(), permission)
        ) {
            permission
        } else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            if (hasPermissionInManifest(context, ArrayList(), Manifest.permission.ACCESS_FINE_LOCATION))
                Manifest.permission.ACCESS_FINE_LOCATION
            else if (hasPermissionInManifest(context, ArrayList(), Manifest.permission.ACCESS_COARSE_LOCATION))
                Manifest.permission.ACCESS_COARSE_LOCATION
            else null
        } else if (hasPermissionInManifest(context, ArrayList(), Manifest.permission.ACCESS_FINE_LOCATION)) {
            Manifest.permission.ACCESS_FINE_LOCATION
        } else {
            null
        }
    }

    @Suppress("DEPRECATION")
    private fun getPackageInfo(context: Context): PackageInfo? {
        val pm = context.packageManager

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getPackageInfo(
                context.packageName,
                PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()),
            )
        } else {
            pm.getPackageInfo(context.packageName, PackageManager.GET_PERMISSIONS)
        }
    }

    private fun wasPermissionDeniedBefore(
        context: Context,
        permissionName: String,
    ): Boolean {
        val sharedPreferences =
            context.getSharedPreferences(permissionName, Context.MODE_PRIVATE)
        return sharedPreferences.getBoolean(
            SHARED_PREFERENCES_PERMISSION_WAS_DENIED_BEFORE_KEY,
            false,
        )
    }

    private fun setPermissionDenied(context: Context, permissionName: String) {
        val sharedPreferences =
            context.getSharedPreferences(permissionName, Context.MODE_PRIVATE)
        sharedPreferences.edit()
            .putBoolean(SHARED_PREFERENCES_PERMISSION_WAS_DENIED_BEFORE_KEY, true)
            .apply()
    }
}
