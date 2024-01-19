package com.frydoapps.timetoparty

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugin.common.MethodChannel
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.QueryPurchasesParams
import android.os.Bundle
import com.android.billingclient.api.BillingResult

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.frydoapps.timetoparty/billing"
    private lateinit var billingClient: BillingClient

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupBillingClient()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Rejestracja GoogleMobileAds
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "listTile", ListTileNativeAdFactory(context))

        // Konfiguracja MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getPurchases") {
                getPurchases(result)  // Przekazanie result do funkcji getPurchases
            } else {
                result.notImplemented()
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        // Usunięcie rejestracji GoogleMobileAds
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
    }

    private fun setupBillingClient() {
        billingClient = BillingClient.newBuilder(context)
            .setListener { billingResult, purchases ->
                // Obsługa wyniku zakupu, jeśli jest to konieczne
            }
            .enablePendingPurchases() // Wymagane, jeśli Twoja aplikacja obsługuje zakupy
            .build()

        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    // Połączenie z usługą billingową zostało nawiązane
                }
            }

            override fun onBillingServiceDisconnected() {
                // Obsługa odłączenia od usługi billingowej
            }
        })
    }

    private fun getPurchases(result: MethodChannel.Result) {
        billingClient.queryPurchasesAsync(QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.INAPP).build()) { billingResult, purchasesList ->
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchasesList != null) {
                var purchasesResult = ""
                for (purchase in purchasesList) {
                    purchasesResult += "${purchase.skus}\n"
                }
                result.success(purchasesResult)  // Przekazanie wyniku z powrotem do Fluttera
            } else {
                result.error("ERROR", "Błąd zapytania o zakupy: ${billingResult.debugMessage}", null)
            }
        }
    }
}
