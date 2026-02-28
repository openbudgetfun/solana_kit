package com.solana.solanakit.mobilewallet.wallet

import android.app.Activity
import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Base64
import com.solana.mobilewalletadapter.common.ProtocolContract
import com.solana.mobilewalletadapter.common.signin.SignInWithSolana
import com.solana.mobilewalletadapter.walletlib.association.AssociationUri
import com.solana.mobilewalletadapter.walletlib.association.LocalAssociationUri
import com.solana.mobilewalletadapter.walletlib.authorization.AuthIssuerConfig
import com.solana.mobilewalletadapter.walletlib.protocol.MobileWalletAdapterConfig
import com.solana.mobilewalletadapter.walletlib.scenario.AuthorizeRequest
import com.solana.mobilewalletadapter.walletlib.scenario.AuthorizedAccount
import com.solana.mobilewalletadapter.walletlib.scenario.DeauthorizedEvent
import com.solana.mobilewalletadapter.walletlib.scenario.LocalScenario
import com.solana.mobilewalletadapter.walletlib.scenario.ReauthorizeRequest
import com.solana.mobilewalletadapter.walletlib.scenario.Scenario
import com.solana.mobilewalletadapter.walletlib.scenario.ScenarioRequest
import com.solana.mobilewalletadapter.walletlib.scenario.SignAndSendTransactionsRequest
import com.solana.mobilewalletadapter.walletlib.scenario.SignInResult
import com.solana.mobilewalletadapter.walletlib.scenario.SignMessagesRequest
import com.solana.mobilewalletadapter.walletlib.scenario.SignPayloadsRequest
import com.solana.mobilewalletadapter.walletlib.scenario.SignTransactionsRequest
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.nio.charset.StandardCharsets
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

/**
 * Wallet-side Android bridge backed by `mobile-wallet-adapter-walletlib`.
 *
 * This exposes wallet scenario lifecycle and request handling to Dart over
 * MethodChannel and maps Dart JSON payloads to concrete walletlib request
 * completions.
 */
class WalletApiImpl(
    private val context: Context,
    binaryMessenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : MethodChannel.MethodCallHandler {
    private enum class PendingRequestType {
        AUTHORIZE,
        REAUTHORIZE,
        DEAUTHORIZE,
        SIGN_TRANSACTIONS,
        SIGN_MESSAGES,
        SIGN_AND_SEND_TRANSACTIONS,
    }

    private data class ScenarioState(
        val sessionId: String,
        val associationUri: Uri,
        val scenario: Scenario,
    )

    private data class PendingRequest(
        val sessionId: String,
        val type: PendingRequestType,
        val request: ScenarioRequest,
    )

    companion object {
        private const val CHANNEL_NAME = "com.solana.solanakit.mobilewallet/wallet"
        private const val ERROR_INVALID_ARGUMENT = "INVALID_ARGUMENT"
        private const val ERROR_INVALID_SESSION = "INVALID_SESSION"
        private const val ERROR_INVALID_REQUEST = "INVALID_REQUEST"
        private const val ERROR_SESSION_ALREADY_CREATED = "ERROR_SESSION_ALREADY_CREATED"
        private const val ERROR_INTENT_DATA_NOT_FOUND = "ERROR_INTENT_DATA_NOT_FOUND"
        private const val ERROR_UNSUPPORTED_ASSOCIATION_URI = "ERROR_UNSUPPORTED_ASSOCIATION_URI"
        private const val ERROR_UNSUPPORTED_ASSOCIATION_TYPE = "ERROR_UNSUPPORTED_ASSOCIATION_TYPE"
    }

    private val channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
    private val mainHandler = Handler(Looper.getMainLooper())

    private val scenarios = ConcurrentHashMap<String, ScenarioState>()
    private val sessionByAssociationUri = ConcurrentHashMap<String, String>()
    private val pendingRequests = ConcurrentHashMap<String, PendingRequest>()

    fun register() {
        channel.setMethodCallHandler(this)
    }

    fun unregister() {
        channel.setMethodCallHandler(null)
        pendingRequests.clear()
        sessionByAssociationUri.clear()
        scenarios.values.forEach { state ->
            state.scenario.close()
        }
        scenarios.clear()
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "createScenario" -> createScenario(call, result)
            "startScenario" -> startScenario(call, result)
            "closeScenario" -> closeScenario(call, result)
            "resolveRequest" -> resolveRequest(call, result)
            "cancelRequest" -> cancelRequest(call, result)
            else -> result.notImplemented()
        }
    }

    private fun createScenario(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val walletName = call.argument<String>("walletName")
        val configJson = call.argument<String>("configJson")
        if (walletName == null || configJson == null) {
            result.error(
                ERROR_INVALID_ARGUMENT,
                "walletName and configJson are required",
                null,
            )
            return
        }

        val currentActivity = activityProvider()
        val intent = currentActivity?.intent
        val data = intent?.data
        if (data == null) {
            result.error(
                ERROR_INTENT_DATA_NOT_FOUND,
                "Unable to get launch association URI from current activity intent",
                null,
            )
            return
        }

        val associationUriString = data.toString()
        if (sessionByAssociationUri.containsKey(associationUriString)) {
            result.error(
                ERROR_SESSION_ALREADY_CREATED,
                "Session already created for uri: $associationUriString",
                null,
            )
            return
        }

        val associationUri = AssociationUri.parse(data)
        if (associationUri == null) {
            result.error(
                ERROR_UNSUPPORTED_ASSOCIATION_URI,
                "Unsupported association URI: $associationUriString",
                null,
            )
            return
        }
        if (associationUri !is LocalAssociationUri) {
            result.error(
                ERROR_UNSUPPORTED_ASSOCIATION_TYPE,
                "Only local association URIs are currently supported",
                null,
            )
            return
        }

        val sessionId = UUID.randomUUID().toString()
        val config = parseWalletConfig(configJson)
        val callbacks = WalletScenarioCallbacks(sessionId)
        val scenario =
            associationUri.createScenario(
                context,
                config,
                AuthIssuerConfig(walletName),
                callbacks,
            )

        scenarios[sessionId] = ScenarioState(sessionId, data, scenario)
        sessionByAssociationUri[associationUriString] = sessionId
        result.success(sessionId)
    }

    private fun startScenario(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val sessionId = call.argument<String>("sessionId")
        if (sessionId == null) {
            result.error(ERROR_INVALID_ARGUMENT, "sessionId is required", null)
            return
        }
        val state = scenarios[sessionId]
        if (state == null) {
            result.error(ERROR_INVALID_SESSION, "Invalid session ID: $sessionId", null)
            return
        }

        try {
            @Suppress("DEPRECATION")
            state.scenario.start()
            result.success(null)
        } catch (e: Exception) {
            sendLifecycleEvent("onScenarioError", sessionId, e.message ?: "Failed to start scenario")
            result.error("START_FAILED", e.message, null)
        }
    }

    private fun closeScenario(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val sessionId = call.argument<String>("sessionId")
        if (sessionId == null) {
            result.error(ERROR_INVALID_ARGUMENT, "sessionId is required", null)
            return
        }
        val state = scenarios.remove(sessionId)
        if (state == null) {
            result.success(null)
            return
        }

        sessionByAssociationUri.remove(state.associationUri.toString())
        pendingRequests.entries.removeIf { (_, pending) ->
            if (pending.sessionId == sessionId) {
                pending.request.cancel()
                true
            } else {
                false
            }
        }

        state.scenario.close()
        result.success(null)
    }

    private fun cancelRequest(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val sessionId = call.argument<String>("sessionId")
        val requestId = call.argument<String>("requestId")
        if (sessionId == null || requestId == null) {
            result.error(ERROR_INVALID_ARGUMENT, "sessionId and requestId are required", null)
            return
        }
        val pending = pendingRequests.remove(requestId)
        if (pending == null || pending.sessionId != sessionId) {
            result.success(null)
            return
        }

        pending.request.cancel()
        result.success(null)
    }

    private fun resolveRequest(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val sessionId = call.argument<String>("sessionId")
        val requestId = call.argument<String>("requestId")
        val resultJson = call.argument<String>("resultJson")
        if (sessionId == null || requestId == null || resultJson == null) {
            result.error(
                ERROR_INVALID_ARGUMENT,
                "sessionId, requestId, and resultJson are required",
                null,
            )
            return
        }
        if (!scenarios.containsKey(sessionId)) {
            result.error(ERROR_INVALID_SESSION, "Invalid session ID: $sessionId", null)
            return
        }
        val pending = pendingRequests.remove(requestId)
        if (pending == null || pending.sessionId != sessionId) {
            result.error(ERROR_INVALID_REQUEST, "Invalid request ID: $requestId", null)
            return
        }

        try {
            val response = JSONObject(resultJson)
            if (response.has("error")) {
                resolveFailure(pending, response.optJSONObject("error"))
            } else {
                resolveSuccess(pending, response)
            }
            result.success(null)
        } catch (e: Exception) {
            pending.request.completeWithInternalError(e)
            sendLifecycleEvent(
                "onScenarioError",
                sessionId,
                "Failed to resolve request: ${e.message}",
            )
            result.error("RESOLVE_FAILED", e.message, null)
        }
    }

    private fun resolveFailure(
        pending: PendingRequest,
        errorObject: JSONObject?,
    ) {
        val code = errorObject?.optInt("code", -32603) ?: -32603
        val data = errorObject?.opt("data")

        when (pending.type) {
            PendingRequestType.AUTHORIZE -> {
                val request = pending.request as AuthorizeRequest
                when (code) {
                    ProtocolContract.ERROR_AUTHORIZATION_FAILED -> request.completeWithDecline()
                    else -> request.completeWithInternalError(Exception("Authorize request failed: $code"))
                }
            }

            PendingRequestType.REAUTHORIZE -> {
                val request = pending.request as ReauthorizeRequest
                when (code) {
                    ProtocolContract.ERROR_AUTHORIZATION_FAILED -> request.completeWithDecline()
                    else -> request.completeWithInternalError(Exception("Reauthorize request failed: $code"))
                }
            }

            PendingRequestType.DEAUTHORIZE -> {
                pending.request.completeWithInternalError(Exception("Deauthorize event failed: $code"))
            }

            PendingRequestType.SIGN_TRANSACTIONS,
            PendingRequestType.SIGN_MESSAGES,
            -> {
                val request = pending.request as SignPayloadsRequest
                when (code) {
                    ProtocolContract.ERROR_NOT_SIGNED -> {
                        request.completeWithDecline()
                    }

                    ProtocolContract.ERROR_TOO_MANY_PAYLOADS -> {
                        request.completeWithTooManyPayloads()
                    }

                    ProtocolContract.ERROR_AUTHORIZATION_FAILED -> {
                        request.completeWithAuthorizationNotValid()
                    }

                    ProtocolContract.ERROR_INVALID_PAYLOADS -> {
                        val valid = parseValidFlags(data)
                        if (valid != null) {
                            request.completeWithInvalidPayloads(valid)
                        } else {
                            request.completeWithInternalError(Exception("Missing valid flags for invalid payloads"))
                        }
                    }

                    else -> {
                        request.completeWithInternalError(Exception("Sign payloads request failed: $code"))
                    }
                }
            }

            PendingRequestType.SIGN_AND_SEND_TRANSACTIONS -> {
                val request = pending.request as SignAndSendTransactionsRequest
                when (code) {
                    ProtocolContract.ERROR_NOT_SIGNED -> {
                        request.completeWithDecline()
                    }

                    ProtocolContract.ERROR_TOO_MANY_PAYLOADS -> {
                        request.completeWithTooManyPayloads()
                    }

                    ProtocolContract.ERROR_AUTHORIZATION_FAILED -> {
                        request.completeWithAuthorizationNotValid()
                    }

                    ProtocolContract.ERROR_INVALID_PAYLOADS -> {
                        val valid = parseValidFlags(data)
                        if (valid != null) {
                            request.completeWithInvalidSignatures(valid)
                        } else {
                            request.completeWithInternalError(Exception("Missing valid flags for invalid signatures"))
                        }
                    }

                    ProtocolContract.ERROR_NOT_SUBMITTED -> {
                        val signatures = parseOpaqueByteArrayList(data, "signatures")
                        if (signatures != null) {
                            request.completeWithNotSubmitted(signatures)
                        } else {
                            request.completeWithInternalError(Exception("Missing signatures for not-submitted response"))
                        }
                    }

                    else -> {
                        request.completeWithInternalError(
                            Exception("Sign-and-send request failed: $code"),
                        )
                    }
                }
            }
        }
    }

    private fun resolveSuccess(
        pending: PendingRequest,
        response: JSONObject,
    ) {
        when (pending.type) {
            PendingRequestType.AUTHORIZE -> {
                val request = pending.request as AuthorizeRequest
                val accountsJson =
                    response.optJSONArray("accounts")
                        ?: throw IllegalArgumentException("Authorize response missing accounts")
                if (accountsJson.length() == 0) {
                    throw IllegalArgumentException("Authorize response has no accounts")
                }
                val accounts = parseAuthorizedAccounts(accountsJson)
                val walletUriBase = response.optStringOrNull("wallet_uri_base")?.let(Uri::parse)
                val scope = response.optStringOrNull("auth_token")?.let(::decodeOpaqueToken)
                val signInResult = response.optJSONObject("sign_in_result")?.let(::parseSignInResult)
                request.completeWithAuthorize(accounts.first(), walletUriBase, scope, signInResult)
            }

            PendingRequestType.REAUTHORIZE -> {
                val request = pending.request as ReauthorizeRequest
                request.completeWithReauthorize()
            }

            PendingRequestType.DEAUTHORIZE -> {
                val request = pending.request as DeauthorizedEvent
                request.complete()
            }

            PendingRequestType.SIGN_TRANSACTIONS,
            PendingRequestType.SIGN_MESSAGES,
            -> {
                val request = pending.request as SignPayloadsRequest
                val signedPayloads =
                    parseOpaqueByteArrayList(response, "signed_payloads")
                        ?: throw IllegalArgumentException("Missing signed_payloads")
                request.completeWithSignedPayloads(signedPayloads)
            }

            PendingRequestType.SIGN_AND_SEND_TRANSACTIONS -> {
                val request = pending.request as SignAndSendTransactionsRequest
                val signatures =
                    parseOpaqueByteArrayList(response, "signatures")
                        ?: throw IllegalArgumentException("Missing signatures")
                request.completeWithSignatures(signatures)
            }
        }
    }

    private inner class WalletScenarioCallbacks(
        private val sessionId: String,
    ) : LocalScenario.Callbacks {
        override fun onScenarioReady() {
            sendLifecycleEvent("onScenarioReady", sessionId)
        }

        override fun onScenarioServingClients() {
            sendLifecycleEvent("onScenarioServingClients", sessionId)
        }

        override fun onScenarioServingComplete() {
            sendLifecycleEvent("onScenarioServingComplete", sessionId)
        }

        override fun onScenarioComplete() {
            sendLifecycleEvent("onScenarioComplete", sessionId)
        }

        override fun onScenarioError() {
            sendLifecycleEvent("onScenarioError", sessionId, "Scenario error")
        }

        override fun onScenarioTeardownComplete() {
            sendLifecycleEvent("onScenarioTeardownComplete", sessionId)
            scenarios.remove(sessionId)?.let { state ->
                sessionByAssociationUri.remove(state.associationUri.toString())
            }
            pendingRequests.entries.removeIf { (_, pending) ->
                if (pending.sessionId == sessionId) {
                    pending.request.cancel()
                    true
                } else {
                    false
                }
            }
        }

        override fun onLowPowerAndNoConnection() {
            sendLifecycleEvent(
                "onScenarioError",
                sessionId,
                "Low power mode with no active connection",
            )
        }

        override fun onAuthorizeRequest(request: AuthorizeRequest) {
            forwardRequestToDart(
                methodName = "onAuthorizeRequest",
                sessionId = sessionId,
                type = PendingRequestType.AUTHORIZE,
                request = request,
                params = createAuthorizeParams(request),
            )
        }

        override fun onReauthorizeRequest(request: ReauthorizeRequest) {
            forwardRequestToDart(
                methodName = "onReauthorizeRequest",
                sessionId = sessionId,
                type = PendingRequestType.REAUTHORIZE,
                request = request,
                params =
                    createVerifiableIdentityParams(
                        identityName = request.identityName,
                        identityUri = request.identityUri,
                        iconRelativeUri = request.iconRelativeUri,
                        chain = request.chain,
                        authorizationScope = request.authorizationScope,
                    ),
            )
        }

        override fun onSignTransactionsRequest(request: SignTransactionsRequest) {
            val params =
                createSignPayloadParams(
                    identityName = request.identityName,
                    identityUri = request.identityUri,
                    iconRelativeUri = request.iconRelativeUri,
                    chain = request.chain,
                    authorizationScope = request.authorizationScope,
                    payloads = request.payloads,
                )
            forwardRequestToDart(
                methodName = "onSignTransactionsRequest",
                sessionId = sessionId,
                type = PendingRequestType.SIGN_TRANSACTIONS,
                request = request,
                params = params,
            )
        }

        override fun onSignMessagesRequest(request: SignMessagesRequest) {
            val params =
                createSignPayloadParams(
                    identityName = request.identityName,
                    identityUri = request.identityUri,
                    iconRelativeUri = request.iconRelativeUri,
                    chain = request.chain,
                    authorizationScope = request.authorizationScope,
                    payloads = request.payloads,
                )
            val addresses = JSONArray().put(encodeOpaqueBytes(request.authorizedPublicKey))
            params.put("addresses", addresses)
            forwardRequestToDart(
                methodName = "onSignMessagesRequest",
                sessionId = sessionId,
                type = PendingRequestType.SIGN_MESSAGES,
                request = request,
                params = params,
            )
        }

        override fun onSignAndSendTransactionsRequest(request: SignAndSendTransactionsRequest) {
            val params =
                createSignPayloadParams(
                    identityName = request.identityName,
                    identityUri = request.identityUri,
                    iconRelativeUri = request.iconRelativeUri,
                    chain = request.chain,
                    authorizationScope = request.authorizationScope,
                    payloads = request.payloads,
                )
            val options = JSONObject()
            request.minContextSlot?.let { options.put("min_context_slot", it) }
            request.commitment?.let { options.put("commitment", it) }
            request.skipPreflight?.let { options.put("skip_preflight", it) }
            request.maxRetries?.let { options.put("max_retries", it) }
            request.waitForCommitmentToSendNextTransaction?.let {
                options.put("wait_for_commitment_to_send_next_transaction", it)
            }
            if (options.length() > 0) {
                params.put("options", options)
            }
            forwardRequestToDart(
                methodName = "onSignAndSendTransactionsRequest",
                sessionId = sessionId,
                type = PendingRequestType.SIGN_AND_SEND_TRANSACTIONS,
                request = request,
                params = params,
            )
        }

        override fun onDeauthorizedEvent(event: DeauthorizedEvent) {
            forwardRequestToDart(
                methodName = "onDeauthorizedEvent",
                sessionId = sessionId,
                type = PendingRequestType.DEAUTHORIZE,
                request = event,
                params =
                    createVerifiableIdentityParams(
                        identityName = event.identityName,
                        identityUri = event.identityUri,
                        iconRelativeUri = event.iconRelativeUri,
                        chain = event.chain,
                        authorizationScope = event.authorizationScope,
                    ),
            )
        }
    }

    private fun forwardRequestToDart(
        methodName: String,
        sessionId: String,
        type: PendingRequestType,
        request: ScenarioRequest,
        params: JSONObject,
    ) {
        val requestId = UUID.randomUUID().toString()
        pendingRequests[requestId] = PendingRequest(sessionId, type, request)
        val args =
            mapOf(
                "requestId" to requestId,
                "sessionId" to sessionId,
                "paramsJson" to params.toString(),
            )
        invokeMethodOnMain(methodName, args)
    }

    private fun sendLifecycleEvent(
        methodName: String,
        sessionId: String,
        error: String? = null,
    ) {
        val args = mutableMapOf<String, Any?>("sessionId" to sessionId)
        if (error != null) {
            args["error"] = error
        }
        invokeMethodOnMain(methodName, args)
    }

    private fun invokeMethodOnMain(
        methodName: String,
        args: Map<String, Any?>,
    ) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            channel.invokeMethod(methodName, args)
        } else {
            mainHandler.post {
                channel.invokeMethod(methodName, args)
            }
        }
    }

    private fun parseWalletConfig(configJson: String): MobileWalletAdapterConfig {
        val config = JSONObject(configJson)

        val maxTransactions =
            config.optIntAny(
                "maxTransactionsPerSigningRequest",
                "max_transactions_per_request",
                0,
            )
        val maxMessages =
            config.optIntAny(
                "maxMessagesPerSigningRequest",
                "max_messages_per_request",
                0,
            )
        val noConnectionWarningTimeoutMs =
            config.optLongAny(
                "noConnectionWarningTimeoutMs",
                "no_connection_warning_timeout_ms",
                0L,
            )

        val versionsArray =
            config.optJSONArrayAny(
                "supportedTransactionVersions",
                "supported_transaction_versions",
            )
        val supportedTransactionVersions = mutableListOf<Any>()
        if (versionsArray == null || versionsArray.length() == 0) {
            supportedTransactionVersions.add(MobileWalletAdapterConfig.LEGACY_TRANSACTION_VERSION)
        } else {
            for (i in 0 until versionsArray.length()) {
                val version = versionsArray.get(i)
                when (version) {
                    is Number -> {
                        supportedTransactionVersions.add(version.toInt())
                    }

                    is String -> {
                        val asInt = version.toIntOrNull()
                        supportedTransactionVersions.add(asInt ?: version)
                    }
                }
            }
            if (supportedTransactionVersions.isEmpty()) {
                supportedTransactionVersions.add(MobileWalletAdapterConfig.LEGACY_TRANSACTION_VERSION)
            }
        }

        val featuresArray = config.optJSONArrayAny("optionalFeatures", "features")
        val optionalFeatures = mutableListOf<String>()
        if (featuresArray != null) {
            for (i in 0 until featuresArray.length()) {
                optionalFeatures.add(featuresArray.getString(i))
            }
        }
        if (optionalFeatures.isEmpty()) {
            optionalFeatures.add(ProtocolContract.FEATURE_ID_SIGN_TRANSACTIONS)
        }

        return MobileWalletAdapterConfig(
            maxTransactions,
            maxMessages,
            supportedTransactionVersions.toTypedArray(),
            noConnectionWarningTimeoutMs,
            optionalFeatures.toTypedArray(),
        )
    }

    private fun createAuthorizeParams(request: AuthorizeRequest): JSONObject {
        val params = JSONObject()
        request.chain?.let { params.put("chain", it) }

        val identity = JSONObject()
        request.identityName?.let { identity.put("name", it) }
        request.identityUri?.toString()?.let { identity.put("uri", it) }
        request.iconRelativeUri?.toString()?.let { identity.put("icon", it) }
        if (identity.length() > 0) {
            params.put("identity", identity)
        }

        request.features?.let {
            params.put("features", JSONArray(it.toList()))
        }
        request.addresses?.let {
            params.put("addresses", JSONArray(it.toList()))
        }
        request.signInPayload?.let {
            params.put("sign_in_payload", it.toJson())
        }

        return params
    }

    private fun createVerifiableIdentityParams(
        identityName: String?,
        identityUri: Uri?,
        iconRelativeUri: Uri?,
        chain: String,
        authorizationScope: ByteArray,
    ): JSONObject {
        val params = JSONObject()
        params.put("chain", chain)
        params.put("auth_token", encodeOpaqueBytes(authorizationScope))

        identityName?.let { params.put("identity_name", it) }
        identityUri?.toString()?.let { params.put("identity_uri", it) }
        iconRelativeUri?.toString()?.let { params.put("icon_relative_uri", it) }

        return params
    }

    private fun createSignPayloadParams(
        identityName: String?,
        identityUri: Uri?,
        iconRelativeUri: Uri?,
        chain: String,
        authorizationScope: ByteArray,
        payloads: Array<ByteArray>,
    ): JSONObject {
        val params =
            createVerifiableIdentityParams(
                identityName = identityName,
                identityUri = identityUri,
                iconRelativeUri = iconRelativeUri,
                chain = chain,
                authorizationScope = authorizationScope,
            )
        params.put("payloads", encodeByteArrayList(payloads))
        return params
    }

    private fun parseAuthorizedAccounts(accounts: JSONArray): Array<AuthorizedAccount> =
        Array(accounts.length()) { index ->
            val accountJson = accounts.getJSONObject(index)
            val publicKey =
                decodeOpaqueToken(
                    accountJson.getString("address"),
                )

            val displayAddress = accountJson.optStringOrNull("display_address")
            val displayAddressFormat = accountJson.optStringOrNull("display_address_format")
            val label = accountJson.optStringOrNull("label")
            val icon = accountJson.optStringOrNull("icon")?.let(Uri::parse)
            val chains = accountJson.optStringArray("chains")
            val features = accountJson.optStringArray("features")

            AuthorizedAccount(
                publicKey,
                displayAddress,
                displayAddressFormat,
                label,
                icon,
                chains,
                features,
            )
        }

    private fun parseSignInResult(json: JSONObject): SignInResult =
        SignInResult(
            decodeOpaqueToken(json.getString("address")),
            decodeOpaqueToken(json.getString("signed_message")),
            decodeOpaqueToken(json.getString("signature")),
            json.optStringOrNull("signature_type"),
        )

    private fun parseValidFlags(data: Any?): BooleanArray? {
        val obj = data as? JSONObject ?: return null
        val validArray = obj.optJSONArray("valid") ?: return null
        return BooleanArray(validArray.length()) { idx ->
            validArray.optBoolean(idx, false)
        }
    }

    private fun parseOpaqueByteArrayList(
        container: Any?,
        key: String,
    ): Array<ByteArray>? {
        val jsonObject = container as? JSONObject ?: return null
        val array = jsonObject.optJSONArray(key) ?: return null
        return Array(array.length()) { idx ->
            decodeOpaqueToken(array.optString(idx, ""))
        }
    }

    private fun encodeByteArrayList(payloads: Array<ByteArray>): JSONArray {
        val result = JSONArray()
        payloads.forEach { payload ->
            result.put(encodeOpaqueBytes(payload))
        }
        return result
    }

    private fun encodeOpaqueBytes(bytes: ByteArray): String = Base64.encodeToString(bytes, Base64.NO_WRAP)

    private fun decodeOpaqueToken(value: String): ByteArray =
        try {
            Base64.decode(value, Base64.NO_WRAP)
        } catch (_: IllegalArgumentException) {
            value.toByteArray(StandardCharsets.UTF_8)
        }

    private fun JSONObject.optStringOrNull(key: String): String? {
        if (!has(key) || isNull(key)) {
            return null
        }
        val value = optString(key, "")
        return if (value.isEmpty()) null else value
    }

    private fun JSONObject.optStringArray(key: String): Array<String>? {
        val jsonArray = optJSONArray(key) ?: return null
        return Array(jsonArray.length()) { idx ->
            jsonArray.getString(idx)
        }
    }

    private fun JSONObject.optIntAny(
        primaryKey: String,
        fallbackKey: String,
        defaultValue: Int,
    ): Int =
        when {
            has(primaryKey) -> optInt(primaryKey, defaultValue)
            has(fallbackKey) -> optInt(fallbackKey, defaultValue)
            else -> defaultValue
        }

    private fun JSONObject.optLongAny(
        primaryKey: String,
        fallbackKey: String,
        defaultValue: Long,
    ): Long =
        when {
            has(primaryKey) -> optLong(primaryKey, defaultValue)
            has(fallbackKey) -> optLong(fallbackKey, defaultValue)
            else -> defaultValue
        }

    private fun JSONObject.optJSONArrayAny(
        primaryKey: String,
        fallbackKey: String,
    ): JSONArray? = optJSONArray(primaryKey) ?: optJSONArray(fallbackKey)
}
