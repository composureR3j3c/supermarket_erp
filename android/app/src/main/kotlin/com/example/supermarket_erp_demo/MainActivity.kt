package com.example.supermarket_erp_demo

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val cardReaderChannel = "supermarket_erp_demo/card_reader"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            cardReaderChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "readCard" -> {
                    // TODO: Integrate your POS vendor SDK here (PAX/Newland/Sunmi/Verifone/etc).
                    // Return fields expected by Flutter:
                    // maskedPan (required), cardBrand (optional), transactionRef (optional)
                    result.error(
                        "reader_not_integrated",
                        "Native POS card reader SDK is not integrated yet.",
                        null
                    )
                }
                else -> result.notImplemented()
            }
        }
    }
}
