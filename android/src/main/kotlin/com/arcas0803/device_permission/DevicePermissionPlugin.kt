package com.arcas0803.device_permission

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class DevicePermissionPlugin : FlutterPlugin, ActivityAware {

    private var permissionManager: PermissionManager? = null
    private var methodChannel: MethodChannel? = null
    private var pluginBinding: ActivityPluginBinding? = null
    private var methodCallHandler: MethodCallHandlerImpl? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        permissionManager = PermissionManager(binding.applicationContext)

        startListening(
            binding.applicationContext,
            binding.binaryMessenger,
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopListening()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        startListeningToActivity(binding.activity)

        pluginBinding = binding
        registerListeners()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        stopListeningToActivity()
        deregisterListeners()
        pluginBinding = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    private fun startListening(applicationContext: Context, messenger: BinaryMessenger) {
        methodChannel = MethodChannel(
            messenger,
            "com.arcas0803.device_permission/permissions",
        )

        methodCallHandler = MethodCallHandlerImpl(
            applicationContext,
            AppSettingsManager(),
            permissionManager!!,
            ServiceManager(),
        )

        methodChannel!!.setMethodCallHandler(methodCallHandler)
    }

    private fun stopListening() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        methodCallHandler = null
    }

    private fun startListeningToActivity(activity: Activity) {
        permissionManager?.setActivity(activity)
    }

    private fun stopListeningToActivity() {
        permissionManager?.setActivity(null)
    }

    private fun registerListeners() {
        pluginBinding?.let { binding ->
            binding.addActivityResultListener(permissionManager!!)
            binding.addRequestPermissionsResultListener(permissionManager!!)
        }
    }

    private fun deregisterListeners() {
        pluginBinding?.let { binding ->
            binding.removeActivityResultListener(permissionManager!!)
            binding.removeRequestPermissionsResultListener(permissionManager!!)
        }
    }
}
