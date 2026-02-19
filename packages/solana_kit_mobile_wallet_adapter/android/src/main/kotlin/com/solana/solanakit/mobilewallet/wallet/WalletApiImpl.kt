package com.solana.solanakit.mobilewallet.wallet

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

/**
 * Implements the wallet-side MethodChannel API for MWA.
 *
 * This class bridges between the Flutter Dart layer and the Android walletlib.
 * It receives requests from the native walletlib and forwards them to Dart
 * via MethodChannel invocations.
 *
 * Note: The actual `com.solanamobile:mobile-wallet-adapter-walletlib` dependency
 * is optional. When not present, this class provides a stub implementation that
 * wallet apps can extend with their own native WebSocket server.
 */
class WalletApiImpl(
    private val context: Context,
    binaryMessenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(
        binaryMessenger,
        "com.solana.solanakit.mobilewallet/wallet"
    )

    /** Pending request completers, keyed by requestId. */
    private val pendingRequests = ConcurrentHashMap<String, (String) -> Unit>()

    /** Active session IDs. */
    private val activeSessions = ConcurrentHashMap<String, Boolean>()

    fun register() {
        channel.setMethodCallHandler(this)
    }

    fun unregister() {
        channel.setMethodCallHandler(null)
        pendingRequests.clear()
        activeSessions.clear()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "createScenario" -> {
                val walletName = call.argument<String>("walletName")
                val configJson = call.argument<String>("configJson")
                if (walletName == null || configJson == null) {
                    result.error("INVALID_ARGUMENT", "walletName and configJson are required", null)
                    return
                }
                val sessionId = UUID.randomUUID().toString()
                activeSessions[sessionId] = true
                result.success(sessionId)
            }
            "startScenario" -> {
                val sessionId = call.argument<String>("sessionId")
                if (sessionId == null || !activeSessions.containsKey(sessionId)) {
                    result.error("INVALID_SESSION", "Invalid session ID", null)
                    return
                }
                // In a full implementation, this would start the native
                // LocalWebSocketServerScenario. For now, signal ready.
                channel.invokeMethod("onScenarioReady", mapOf("sessionId" to sessionId))
                result.success(null)
            }
            "closeScenario" -> {
                val sessionId = call.argument<String>("sessionId")
                if (sessionId != null) {
                    activeSessions.remove(sessionId)
                    channel.invokeMethod("onScenarioComplete", mapOf("sessionId" to sessionId))
                    channel.invokeMethod("onScenarioTeardownComplete", mapOf("sessionId" to sessionId))
                }
                result.success(null)
            }
            "resolveRequest" -> {
                val requestId = call.argument<String>("requestId")
                val resultJson = call.argument<String>("resultJson")
                if (requestId == null || resultJson == null) {
                    result.error("INVALID_ARGUMENT", "requestId and resultJson are required", null)
                    return
                }
                val completer = pendingRequests.remove(requestId)
                completer?.invoke(resultJson)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Called by the native walletlib when a dApp request arrives.
     * Forwards the request to the Dart layer via MethodChannel.
     *
     * @param methodName The callback method name (e.g. "onAuthorizeRequest")
     * @param requestId A unique ID for this request
     * @param sessionId The session this request belongs to
     * @param paramsJson JSON-encoded request parameters
     * @param onResult Callback invoked when the Dart layer resolves the request
     */
    fun forwardRequestToDart(
        methodName: String,
        requestId: String,
        sessionId: String,
        paramsJson: String,
        onResult: (String) -> Unit
    ) {
        pendingRequests[requestId] = onResult
        channel.invokeMethod(methodName, mapOf(
            "requestId" to requestId,
            "sessionId" to sessionId,
            "paramsJson" to paramsJson
        ))
    }

    /**
     * Sends a lifecycle event to the Dart layer.
     */
    fun sendLifecycleEvent(methodName: String, sessionId: String, error: String? = null) {
        val args = mutableMapOf<String, Any?>("sessionId" to sessionId)
        if (error != null) {
            args["error"] = error
        }
        channel.invokeMethod(methodName, args)
    }
}
