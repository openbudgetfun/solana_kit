package com.solana.solanakit.mobilewallet

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.annotation.NonNull
import com.solana.solanakit.mobilewallet.wallet.WalletApiImpl
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SolanaKitMobileWalletAdapterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var clientChannel: MethodChannel
    private var walletApi: WalletApiImpl? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // Client-side channel (dApp -> wallet).
        clientChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "com.solana.solanakit.mobilewallet/client"
        )
        clientChannel.setMethodCallHandler(this)

        // Wallet-side channel (wallet scenario management).
        walletApi = WalletApiImpl(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger
        )
        walletApi?.register()
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "launchIntent" -> {
                val uri = call.argument<String>("uri")
                if (uri == null) {
                    result.error("INVALID_ARGUMENT", "URI is required", null)
                    return
                }
                try {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uri))
                    activity?.startActivity(intent)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("LAUNCH_FAILED", e.message, null)
                }
            }
            "isWalletEndpointAvailable" -> {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("solana-wallet:/"))
                val available = activity?.packageManager?.resolveActivity(
                    intent,
                    PackageManager.MATCH_DEFAULT_ONLY
                ) != null
                result.success(available)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        clientChannel.setMethodCallHandler(null)
        walletApi?.unregister()
        walletApi = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
