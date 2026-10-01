package com.solana.solanakit.mobilewallet.wallet

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.solana.digitalassetlinks.AndroidAppPackageVerifier
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.URI

class DigitalAssetLinksApiImpl(
    private val context: Context,
    binaryMessenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "DigitalAssetLinksApiImpl"
        private const val CHANNEL_NAME = "com.solana.solanakit.mobilewallet/digital_asset_links"
    }

    private val channel = MethodChannel(binaryMessenger, CHANNEL_NAME)

    fun register() {
        channel.setMethodCallHandler(this)
    }

    fun unregister() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "getCallingPackage" -> {
                result.success(activityProvider()?.callingPackage)
            }

            "verifyCallingPackage" -> {
                val clientIdentityUri = call.argument<String>("clientIdentityUri")
                if (clientIdentityUri == null) {
                    result.error("INVALID_ARGUMENT", "clientIdentityUri is required", null)
                    return
                }
                val callingPackage = activityProvider()?.callingPackage
                if (callingPackage == null) {
                    result.success(false)
                    return
                }
                verifyPackage(callingPackage, clientIdentityUri, result)
            }

            "verifyPackage" -> {
                val packageName = call.argument<String>("packageName")
                val clientIdentityUri = call.argument<String>("clientIdentityUri")
                if (packageName == null || clientIdentityUri == null) {
                    result.error(
                        "INVALID_ARGUMENT",
                        "packageName and clientIdentityUri are required",
                        null,
                    )
                    return
                }
                verifyPackage(packageName, clientIdentityUri, result)
            }

            "getCallingPackageUid" -> {
                val callingPackage = activityProvider()?.callingPackage
                if (callingPackage == null) {
                    result.error("NO_CALLING_PACKAGE", "No calling package available", null)
                    return
                }
                getUidForPackage(callingPackage, result)
            }

            "getUidForPackage" -> {
                val packageName = call.argument<String>("packageName")
                if (packageName == null) {
                    result.error("INVALID_ARGUMENT", "packageName is required", null)
                    return
                }
                getUidForPackage(packageName, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun verifyPackage(
        packageName: String,
        clientIdentityUri: String,
        result: MethodChannel.Result,
    ) {
        val packageManager = context.packageManager
        val verifier = AndroidAppPackageVerifier(packageManager)
        val verified =
            try {
                verifier.verify(packageName, URI.create(clientIdentityUri))
            } catch (e: AndroidAppPackageVerifier.CouldNotVerifyPackageException) {
                Log.w(
                    TAG,
                    "Package verification failed for package=$packageName, clientIdentityUri=$clientIdentityUri",
                    e,
                )
                false
            } catch (e: IllegalArgumentException) {
                Log.w(
                    TAG,
                    "Invalid clientIdentityUri=$clientIdentityUri",
                    e,
                )
                false
            }
        result.success(verified)
    }

    private fun getUidForPackage(
        packageName: String,
        result: MethodChannel.Result,
    ) {
        val packageManager = context.packageManager
        try {
            val uid =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    packageManager.getPackageUid(packageName, 0)
                } else {
                    packageManager.getApplicationInfo(packageName, 0).uid
                }
            result.success(uid)
        } catch (e: PackageManager.NameNotFoundException) {
            result.error("PACKAGE_NOT_FOUND", "Package not found: $packageName", null)
        }
    }
}
