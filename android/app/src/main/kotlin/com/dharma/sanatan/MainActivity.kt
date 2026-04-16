package com.dharma.sanatan

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val whatsappPackages = listOf(
        "com.whatsapp",
        "com.whatsapp.w4b"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "dharma_app/whatsapp_share"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "shareImageToWhatsApp" -> {
                    val imagePath = call.argument<String>("imagePath")
                    if (imagePath.isNullOrBlank()) {
                        result.error("invalid_path", "Image path is required", null)
                        return@setMethodCallHandler
                    }

                    result.success(shareImageToWhatsApp(imagePath))
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun shareImageToWhatsApp(imagePath: String): Boolean {
        val sourceFile = File(imagePath)
        if (!sourceFile.exists()) {
            return false
        }

        val imageFile = File(cacheDir, sourceFile.name).apply {
            if (absolutePath != sourceFile.absolutePath) {
                sourceFile.copyTo(this, overwrite = true)
            }
        }

        val authority = "${applicationContext.packageName}.fileprovider"
        val imageUri: Uri = FileProvider.getUriForFile(
            applicationContext,
            authority,
            imageFile
        )

        val packageManager = applicationContext.packageManager

        for (packageName in whatsappPackages) {
            val sendIntent = Intent(Intent.ACTION_SEND).apply {
                type = "image/png"
                `package` = packageName
                putExtra(Intent.EXTRA_STREAM, imageUri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                clipData = android.content.ClipData.newUri(
                    contentResolver,
                    "gana_match_result",
                    imageUri
                )
            }

            if (sendIntent.resolveActivity(packageManager) != null) {
                startActivity(sendIntent)
                return true
            }
        }

        return false
    }
}
