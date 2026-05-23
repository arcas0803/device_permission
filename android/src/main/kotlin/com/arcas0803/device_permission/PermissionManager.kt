package com.arcas0803.device_permission

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.app.Application
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.PluginRegistry

class PermissionManager(private val context: Context) :
    PluginRegistry.ActivityResultListener,
    PluginRegistry.RequestPermissionsResultListener {

    private var successCallback: ((Map<Int, Int>) -> Unit)? = null
    private var activity: Activity? = null
    private var pendingRequestCount: Int = 0
    private var requestResults: MutableMap<Int, Int>? = null

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        val activity = this.activity ?: return false

        if (requestResults == null) {
            pendingRequestCount = 0
            return false
        }

        val results = requestResults!!
        var status: Int
        var permission: Int

        when (requestCode) {
            PermissionConstants.PERMISSION_CODE_IGNORE_BATTERY_OPTIMIZATIONS -> {
                permission = PermissionConstants.PERMISSION_GROUP_IGNORE_BATTERY_OPTIMIZATIONS

                status = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val packageName = context.packageName
                    val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                    if (pm.isIgnoringBatteryOptimizations(packageName))
                        PermissionConstants.PERMISSION_STATUS_GRANTED
                    else
                        PermissionConstants.PERMISSION_STATUS_DENIED
                } else {
                    PermissionConstants.PERMISSION_STATUS_RESTRICTED
                }
            }

            PermissionConstants.PERMISSION_CODE_MANAGE_EXTERNAL_STORAGE -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    status = if (Environment.isExternalStorageManager())
                        PermissionConstants.PERMISSION_STATUS_GRANTED
                    else
                        PermissionConstants.PERMISSION_STATUS_DENIED
                } else {
                    return false
                }
                permission = PermissionConstants.PERMISSION_GROUP_MANAGE_EXTERNAL_STORAGE
            }

            PermissionConstants.PERMISSION_CODE_SYSTEM_ALERT_WINDOW -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    status = if (Settings.canDrawOverlays(activity))
                        PermissionConstants.PERMISSION_STATUS_GRANTED
                    else
                        PermissionConstants.PERMISSION_STATUS_DENIED
                    permission = PermissionConstants.PERMISSION_GROUP_SYSTEM_ALERT_WINDOW
                } else {
                    return false
                }
            }

            PermissionConstants.PERMISSION_CODE_REQUEST_INSTALL_PACKAGES -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    status = if (activity.packageManager.canRequestPackageInstalls())
                        PermissionConstants.PERMISSION_STATUS_GRANTED
                    else
                        PermissionConstants.PERMISSION_STATUS_DENIED
                    permission = PermissionConstants.PERMISSION_GROUP_REQUEST_INSTALL_PACKAGES
                } else {
                    return false
                }
            }

            PermissionConstants.PERMISSION_CODE_ACCESS_NOTIFICATION_POLICY -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val notificationManager =
                        activity.getSystemService(Application.NOTIFICATION_SERVICE) as NotificationManager
                    status = if (notificationManager.isNotificationPolicyAccessGranted)
                        PermissionConstants.PERMISSION_STATUS_GRANTED
                    else
                        PermissionConstants.PERMISSION_STATUS_DENIED
                    permission = PermissionConstants.PERMISSION_GROUP_ACCESS_NOTIFICATION_POLICY
                } else {
                    return false
                }
            }

            PermissionConstants.PERMISSION_CODE_SCHEDULE_EXACT_ALARM -> {
                permission = PermissionConstants.PERMISSION_GROUP_SCHEDULE_EXACT_ALARM
                val alarmManager = activity.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                status = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    if (alarmManager.canScheduleExactAlarms())
                        PermissionConstants.PERMISSION_STATUS_GRANTED
                    else
                        PermissionConstants.PERMISSION_STATUS_DENIED
                } else {
                    PermissionConstants.PERMISSION_STATUS_GRANTED
                }
            }

            else -> return false
        }

        results[permission] = status
        pendingRequestCount--

        if (successCallback != null && pendingRequestCount == 0) {
            successCallback!!.invoke(results)
        }
        return true
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != PermissionConstants.PERMISSION_CODE) {
            pendingRequestCount = 0
            return false
        }

        if (requestResults == null) return false

        if (permissions.isEmpty() && grantResults.isEmpty()) {
            pendingRequestCount = 0
            Log.w(
                PermissionConstants.LOG_TAG,
                "onRequestPermissionsResult is called without results. This is probably caused by interfering request codes. If you see this error, please file an issue in flutter-permission-handler: https://github.com/Baseflow/flutter-permission-handler/issues",
            )
            return false
        }

        val results = requestResults!!
        val permissionList = permissions.toList()
        val calendarWriteIndex = permissionList.indexOf(Manifest.permission.WRITE_CALENDAR)

        if (calendarWriteIndex >= 0) {
            val writeGrantResult = grantResults[calendarWriteIndex]
            val writeStatus = PermissionUtils.toPermissionStatus(
                activity,
                Manifest.permission.WRITE_CALENDAR,
                writeGrantResult,
            )
            results[PermissionConstants.PERMISSION_GROUP_CALENDAR_WRITE_ONLY] = writeStatus

            val calendarReadIndex = permissionList.indexOf(Manifest.permission.READ_CALENDAR)
            if (calendarReadIndex >= 0) {
                val readGrantResult = grantResults[calendarReadIndex]
                val readStatus = PermissionUtils.toPermissionStatus(
                    activity,
                    Manifest.permission.READ_CALENDAR,
                    readGrantResult,
                )
                val fullAccessStatus = PermissionUtils.strictestStatus(writeStatus, readStatus)
                results[PermissionConstants.PERMISSION_GROUP_CALENDAR_FULL_ACCESS] =
                    fullAccessStatus
                results[PermissionConstants.PERMISSION_GROUP_CALENDAR] = fullAccessStatus
            }
        }

        for (i in permissions.indices) {
            val permissionName = permissions[i]

            if (permissionName == Manifest.permission.WRITE_CALENDAR ||
                permissionName == Manifest.permission.READ_CALENDAR
            ) {
                continue
            }

            val permission = PermissionUtils.parseManifestName(permissionName)
            if (permission == PermissionConstants.PERMISSION_GROUP_UNKNOWN) continue

            val result = grantResults[i]

            when (permission) {
                PermissionConstants.PERMISSION_GROUP_PHONE -> {
                    val previousResult = results[PermissionConstants.PERMISSION_GROUP_PHONE]
                    val newResult = PermissionUtils.toPermissionStatus(
                        activity,
                        permissionName,
                        result,
                    )
                    val strictest = PermissionUtils.strictestStatus(previousResult, newResult)
                    results[PermissionConstants.PERMISSION_GROUP_PHONE] = strictest
                }

                PermissionConstants.PERMISSION_GROUP_MICROPHONE -> {
                    if (!results.containsKey(PermissionConstants.PERMISSION_GROUP_MICROPHONE)) {
                        results[PermissionConstants.PERMISSION_GROUP_MICROPHONE] =
                            PermissionUtils.toPermissionStatus(activity, permissionName, result)
                    }
                    if (!results.containsKey(PermissionConstants.PERMISSION_GROUP_SPEECH)) {
                        results[PermissionConstants.PERMISSION_GROUP_SPEECH] =
                            PermissionUtils.toPermissionStatus(activity, permissionName, result)
                    }
                }

                PermissionConstants.PERMISSION_GROUP_LOCATION_ALWAYS -> {
                    val permissionStatus =
                        PermissionUtils.toPermissionStatus(activity, permissionName, result)

                    if (!results.containsKey(PermissionConstants.PERMISSION_GROUP_LOCATION_ALWAYS)) {
                        results[PermissionConstants.PERMISSION_GROUP_LOCATION_ALWAYS] =
                            permissionStatus
                    }
                }

                PermissionConstants.PERMISSION_GROUP_LOCATION -> {
                    val permissionStatus =
                        PermissionUtils.toPermissionStatus(activity, permissionName, result)

                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                        if (!results.containsKey(PermissionConstants.PERMISSION_GROUP_LOCATION_ALWAYS)) {
                            results[PermissionConstants.PERMISSION_GROUP_LOCATION_ALWAYS] =
                                permissionStatus
                        }
                    }

                    if (!results.containsKey(PermissionConstants.PERMISSION_GROUP_LOCATION_WHEN_IN_USE)) {
                        results[PermissionConstants.PERMISSION_GROUP_LOCATION_WHEN_IN_USE] =
                            permissionStatus
                    }

                    results[permission] = permissionStatus
                }

                PermissionConstants.PERMISSION_GROUP_PHOTOS,
                PermissionConstants.PERMISSION_GROUP_VIDEOS -> {
                    results[permission] = determinePermissionStatus(permission)
                }

                else -> {
                    if (!results.containsKey(permission)) {
                        results[permission] = PermissionUtils.toPermissionStatus(
                            activity,
                            permissionName,
                            result,
                        )
                    }
                }
            }
        }

        pendingRequestCount -= grantResults.size

        if (successCallback != null && pendingRequestCount == 0) {
            successCallback!!.invoke(results)
        }
        return true
    }

    fun checkPermissionStatus(
        permission: Int,
        successCallback: (Int) -> Unit,
    ) {
        successCallback(determinePermissionStatus(permission))
    }

    fun requestPermissions(
        permissions: List<Int>,
        successCallback: (Map<Int, Int>) -> Unit,
        errorCallback: (String, String) -> Unit,
    ) {
        if (pendingRequestCount > 0) {
            errorCallback(
                "PermissionHandler.PermissionManager",
                "A request for permissions is already running, please wait for it to finish before doing another request (note that you can request multiple permissions at the same time).",
            )
            return
        }

        val activity = this.activity
        if (activity == null) {
            Log.d(PermissionConstants.LOG_TAG, "Unable to detect current Activity.")
            errorCallback(
                "PermissionHandler.PermissionManager",
                "Unable to detect current Android Activity.",
            )
            return
        }

        this.successCallback = successCallback
        this.requestResults = HashMap()
        this.pendingRequestCount = 0

        val permissionsToRequest = ArrayList<String>()
        for (permission in permissions) {
            val permissionStatus = determinePermissionStatus(permission)
            if (permissionStatus == PermissionConstants.PERMISSION_STATUS_GRANTED) {
                if (!requestResults!!.containsKey(permission)) {
                    requestResults!![permission] = PermissionConstants.PERMISSION_STATUS_GRANTED
                }
                continue
            }

            val names = PermissionUtils.getManifestNames(activity, permission)

            if (names == null || names.isEmpty()) {
                if (!requestResults!!.containsKey(permission)) {
                    if (permission == PermissionConstants.PERMISSION_GROUP_IGNORE_BATTERY_OPTIMIZATIONS &&
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.M
                    ) {
                        requestResults!![permission] =
                            PermissionConstants.PERMISSION_STATUS_RESTRICTED
                    } else if (permission == PermissionConstants.PERMISSION_GROUP_MANAGE_EXTERNAL_STORAGE &&
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.R
                    ) {
                        requestResults!![permission] =
                            PermissionConstants.PERMISSION_STATUS_RESTRICTED
                    } else {
                        requestResults!![permission] = PermissionConstants.PERMISSION_STATUS_DENIED
                    }
                }
                continue
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                permission == PermissionConstants.PERMISSION_GROUP_IGNORE_BATTERY_OPTIMIZATIONS
            ) {
                launchSpecialPermission(
                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                    PermissionConstants.PERMISSION_CODE_IGNORE_BATTERY_OPTIMIZATIONS,
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R &&
                permission == PermissionConstants.PERMISSION_GROUP_MANAGE_EXTERNAL_STORAGE
            ) {
                launchSpecialPermission(
                    Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
                    PermissionConstants.PERMISSION_CODE_MANAGE_EXTERNAL_STORAGE,
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                permission == PermissionConstants.PERMISSION_GROUP_SYSTEM_ALERT_WINDOW
            ) {
                launchSpecialPermission(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    PermissionConstants.PERMISSION_CODE_SYSTEM_ALERT_WINDOW,
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                permission == PermissionConstants.PERMISSION_GROUP_REQUEST_INSTALL_PACKAGES
            ) {
                launchSpecialPermission(
                    Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                    PermissionConstants.PERMISSION_CODE_REQUEST_INSTALL_PACKAGES,
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                permission == PermissionConstants.PERMISSION_GROUP_ACCESS_NOTIFICATION_POLICY
            ) {
                launchSpecialPermission(
                    Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS,
                    PermissionConstants.PERMISSION_CODE_ACCESS_NOTIFICATION_POLICY,
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                permission == PermissionConstants.PERMISSION_GROUP_SCHEDULE_EXACT_ALARM
            ) {
                launchSpecialPermission(
                    Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                    PermissionConstants.PERMISSION_CODE_SCHEDULE_EXACT_ALARM,
                )
            } else if (permission == PermissionConstants.PERMISSION_GROUP_CALENDAR_FULL_ACCESS ||
                permission == PermissionConstants.PERMISSION_GROUP_CALENDAR
            ) {
                val isValidManifest = isValidManifestForCalendarFullAccess()
                if (isValidManifest) {
                    permissionsToRequest.add(Manifest.permission.WRITE_CALENDAR)
                    permissionsToRequest.add(Manifest.permission.READ_CALENDAR)
                    pendingRequestCount += 2
                } else {
                    requestResults!![permission] = PermissionConstants.PERMISSION_STATUS_DENIED
                }
            } else {
                permissionsToRequest.addAll(names)
                pendingRequestCount += names.size
            }
        }

        if (permissionsToRequest.isNotEmpty()) {
            val requestPermissions = permissionsToRequest.toTypedArray()
            ActivityCompat.requestPermissions(
                activity,
                requestPermissions,
                PermissionConstants.PERMISSION_CODE,
            )
        }

        if (this.successCallback != null && pendingRequestCount == 0) {
            this.successCallback!!.invoke(requestResults!!)
        }
    }

    private fun determinePermissionStatus(permission: Int): Int {
        if (permission == PermissionConstants.PERMISSION_GROUP_NOTIFICATION) {
            return checkNotificationPermissionStatus()
        }

        if (permission == PermissionConstants.PERMISSION_GROUP_BLUETOOTH) {
            return checkBluetoothPermissionStatus()
        }

        if (permission == PermissionConstants.PERMISSION_GROUP_BLUETOOTH_CONNECT ||
            permission == PermissionConstants.PERMISSION_GROUP_BLUETOOTH_SCAN ||
            permission == PermissionConstants.PERMISSION_GROUP_BLUETOOTH_ADVERTISE
        ) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                return checkBluetoothPermissionStatus()
            }
        }

        if (permission == PermissionConstants.PERMISSION_GROUP_CALENDAR_FULL_ACCESS ||
            permission == PermissionConstants.PERMISSION_GROUP_CALENDAR
        ) {
            val isValidManifest = isValidManifestForCalendarFullAccess()
            if (!isValidManifest) return PermissionConstants.PERMISSION_STATUS_DENIED
        }

        val names = PermissionUtils.getManifestNames(context, permission)

        if (names == null) {
            Log.d(
                PermissionConstants.LOG_TAG,
                "No android specific permissions needed for: $permission",
            )
            return PermissionConstants.PERMISSION_STATUS_GRANTED
        }

        if (names.isEmpty()) {
            Log.d(
                PermissionConstants.LOG_TAG,
                "No permissions found in manifest for: $names $permission",
            )

            if (permission == PermissionConstants.PERMISSION_GROUP_IGNORE_BATTERY_OPTIMIZATIONS) {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                    return PermissionConstants.PERMISSION_STATUS_RESTRICTED
                }
            }

            if (permission == PermissionConstants.PERMISSION_GROUP_MANAGE_EXTERNAL_STORAGE) {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                    return PermissionConstants.PERMISSION_STATUS_RESTRICTED
                }
            }

            return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M)
                PermissionConstants.PERMISSION_STATUS_GRANTED
            else
                PermissionConstants.PERMISSION_STATUS_DENIED
        }

        val requiresExplicitPermission =
            context.applicationInfo.targetSdkVersion >= Build.VERSION_CODES.M

        if (requiresExplicitPermission) {
            val permissionStatuses = HashSet<Int>()

            for (name in names) {
                when {
                    permission == PermissionConstants.PERMISSION_GROUP_IGNORE_BATTERY_OPTIMIZATIONS -> {
                        val packageName = context.packageName
                        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                        if (pm.isIgnoringBatteryOptimizations(packageName)) {
                            permissionStatuses.add(PermissionConstants.PERMISSION_STATUS_GRANTED)
                        } else {
                            permissionStatuses.add(PermissionConstants.PERMISSION_STATUS_DENIED)
                        }
                    }

                    permission == PermissionConstants.PERMISSION_GROUP_MANAGE_EXTERNAL_STORAGE -> {
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                            permissionStatuses.add(PermissionConstants.PERMISSION_STATUS_RESTRICTED)
                        }
                        val status = if (Environment.isExternalStorageManager())
                            PermissionConstants.PERMISSION_STATUS_GRANTED
                        else
                            PermissionConstants.PERMISSION_STATUS_DENIED
                        permissionStatuses.add(status)
                    }

                    permission == PermissionConstants.PERMISSION_GROUP_SYSTEM_ALERT_WINDOW -> {
                        val status = if (Settings.canDrawOverlays(context))
                            PermissionConstants.PERMISSION_STATUS_GRANTED
                        else
                            PermissionConstants.PERMISSION_STATUS_DENIED
                        permissionStatuses.add(status)
                    }

                    permission == PermissionConstants.PERMISSION_GROUP_REQUEST_INSTALL_PACKAGES -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val status = if (context.packageManager.canRequestPackageInstalls())
                                PermissionConstants.PERMISSION_STATUS_GRANTED
                            else
                                PermissionConstants.PERMISSION_STATUS_DENIED
                            permissionStatuses.add(status)
                        }
                    }

                    permission == PermissionConstants.PERMISSION_GROUP_ACCESS_NOTIFICATION_POLICY -> {
                        val notificationManager =
                            context.getSystemService(Application.NOTIFICATION_SERVICE) as NotificationManager
                        val status = if (notificationManager.isNotificationPolicyAccessGranted)
                            PermissionConstants.PERMISSION_STATUS_GRANTED
                        else
                            PermissionConstants.PERMISSION_STATUS_DENIED
                        permissionStatuses.add(status)
                    }

                    permission == PermissionConstants.PERMISSION_GROUP_SCHEDULE_EXACT_ALARM -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val alarmManager =
                                context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                            val status = if (alarmManager.canScheduleExactAlarms())
                                PermissionConstants.PERMISSION_STATUS_GRANTED
                            else
                                PermissionConstants.PERMISSION_STATUS_DENIED
                            permissionStatuses.add(status)
                        } else {
                            permissionStatuses.add(PermissionConstants.PERMISSION_STATUS_GRANTED)
                        }
                    }

                    permission == PermissionConstants.PERMISSION_GROUP_PHOTOS ||
                        permission == PermissionConstants.PERMISSION_GROUP_VIDEOS -> {
                        val permissionStatus = ContextCompat.checkSelfPermission(context, name)
                        var permissionStatusLimited = permissionStatus
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                            permissionStatusLimited = ContextCompat.checkSelfPermission(
                                context,
                                Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED,
                            )
                        }
                        when {
                            permissionStatusLimited == PackageManager.PERMISSION_GRANTED &&
                                permissionStatus == PackageManager.PERMISSION_DENIED -> {
                                permissionStatuses.add(PermissionConstants.PERMISSION_STATUS_LIMITED)
                            }

                            permissionStatus == PackageManager.PERMISSION_GRANTED -> {
                                permissionStatuses.add(PermissionConstants.PERMISSION_STATUS_GRANTED)
                            }

                            else -> {
                                permissionStatuses.add(
                                    PermissionUtils.determineDeniedVariant(
                                        activity,
                                        name,
                                    ),
                                )
                            }
                        }
                    }

                    else -> {
                        val permissionStatus =
                            ContextCompat.checkSelfPermission(context, name)
                        if (permissionStatus != PackageManager.PERMISSION_GRANTED) {
                            permissionStatuses.add(
                                PermissionUtils.determineDeniedVariant(activity, name),
                            )
                        }
                    }
                }
            }

            if (permissionStatuses.isNotEmpty()) {
                return PermissionUtils.strictestStatus(permissionStatuses)
            }
        }

        return PermissionConstants.PERMISSION_STATUS_GRANTED
    }

    private fun launchSpecialPermission(permissionAction: String, requestCode: Int) {
        val activity = this.activity ?: return

        val intent = Intent(permissionAction)
        if (permissionAction != Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS) {
            val packageName = activity.packageName
            intent.data = Uri.parse("package:$packageName")
        }
        activity.startActivityForResult(intent, requestCode)
        pendingRequestCount++
    }

    fun shouldShowRequestPermissionRationale(
        permission: Int,
        successCallback: (Boolean) -> Unit,
        errorCallback: (String, String) -> Unit,
    ) {
        val activity = this.activity
        if (activity == null) {
            Log.d(PermissionConstants.LOG_TAG, "Unable to detect current Activity.")
            errorCallback(
                "PermissionHandler.PermissionManager",
                "Unable to detect current Android Activity.",
            )
            return
        }

        val names = PermissionUtils.getManifestNames(activity, permission)

        if (names == null) {
            Log.d(
                PermissionConstants.LOG_TAG,
                "No android specific permissions needed for: $permission",
            )
            successCallback(false)
            return
        }

        if (names.isEmpty()) {
            Log.d(
                PermissionConstants.LOG_TAG,
                "No permissions found in manifest for: $permission no need to show request rationale",
            )
            successCallback(false)
            return
        }

        successCallback(
            ActivityCompat.shouldShowRequestPermissionRationale(activity, names[0]),
        )
    }

    private fun checkNotificationPermissionStatus(): Int {
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            val manager = NotificationManagerCompat.from(context)
            val isGranted = manager.areNotificationsEnabled()
            if (isGranted) PermissionConstants.PERMISSION_STATUS_GRANTED
            else PermissionConstants.PERMISSION_STATUS_DENIED
        } else {
            val status = context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)
            if (status == PackageManager.PERMISSION_GRANTED)
                PermissionConstants.PERMISSION_STATUS_GRANTED
            else
                PermissionUtils.determineDeniedVariant(
                    activity,
                    Manifest.permission.POST_NOTIFICATIONS,
                )
        }
    }

    private fun checkBluetoothPermissionStatus(): Int {
        val names = PermissionUtils.getManifestNames(
            context,
            PermissionConstants.PERMISSION_GROUP_BLUETOOTH,
        )
        val missingInManifest = names == null || names.isEmpty()
        if (missingInManifest) {
            Log.d(PermissionConstants.LOG_TAG, "Bluetooth permission missing in manifest")
            return PermissionConstants.PERMISSION_STATUS_DENIED
        }
        return PermissionConstants.PERMISSION_STATUS_GRANTED
    }

    private fun isValidManifestForCalendarFullAccess(): Boolean {
        val names = PermissionUtils.getManifestNames(
            context,
            PermissionConstants.PERMISSION_GROUP_CALENDAR_FULL_ACCESS,
        )
        val writeInManifest = names != null && names.contains(Manifest.permission.WRITE_CALENDAR)
        val readInManifest = names != null && names.contains(Manifest.permission.READ_CALENDAR)
        val validManifest = writeInManifest && readInManifest
        if (!validManifest) {
            if (!writeInManifest)
                Log.d(
                    PermissionConstants.LOG_TAG,
                    Manifest.permission.WRITE_CALENDAR + " missing in manifest",
                )
            if (!readInManifest)
                Log.d(
                    PermissionConstants.LOG_TAG,
                    Manifest.permission.READ_CALENDAR + " missing in manifest",
                )
            return false
        }
        return true
    }
}
