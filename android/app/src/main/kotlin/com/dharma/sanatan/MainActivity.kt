package com.dharma.sanatan

import android.content.ContentValues
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFlutterPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val whatsappPackages = listOf(
        "com.whatsapp",
        "com.whatsapp.w4b"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        if (!flutterEngine.plugins.has(InAppWebViewFlutterPlugin::class.java)) {
            flutterEngine.plugins.add(InAppWebViewFlutterPlugin())
        }

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "dharma_app/spiritual_media_download"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidSdkInt" -> result.success(Build.VERSION.SDK_INT)
                "saveImageToDownloads" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType") ?: "image/jpeg"

                    if (bytes == null || fileName.isNullOrBlank()) {
                        result.error("invalid_args", "bytes and fileName are required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val savedPath = saveImageToDownloads(bytes, fileName, mimeType)
                        result.success(savedPath)
                    } catch (exception: Exception) {
                        result.error(
                            "save_failed",
                            exception.message ?: "Failed to save file",
                            null
                        )
                    }
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

    private fun saveImageToDownloads(
        bytes: ByteArray,
        fileName: String,
        mimeType: String
    ): String {
        val safeFileName = fileName.trim().ifEmpty { "spiritual_media_${System.currentTimeMillis()}" }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, safeFileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    "${Environment.DIRECTORY_DOWNLOADS}/GlobalSanathanCommunity"
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            val itemUri = contentResolver.insert(collection, values)
                ?: throw IllegalStateException("Unable to create download entry")

            contentResolver.openOutputStream(itemUri)?.use { outputStream ->
                outputStream.write(bytes)
                outputStream.flush()
            } ?: throw IllegalStateException("Unable to open download output stream")

            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            contentResolver.update(itemUri, values, null, null)
            safeFileName
        } else {
            val downloadsDirectory = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS
            )
            val targetDirectory = File(downloadsDirectory, "GlobalSanathanCommunity").apply {
                if (!exists()) {
                    mkdirs()
                }
            }
            val targetFile = File(targetDirectory, safeFileName)
            FileOutputStream(targetFile).use { outputStream ->
                outputStream.write(bytes)
                outputStream.flush()
            }
            MediaScannerConnection.scanFile(
                applicationContext,
                arrayOf(targetFile.absolutePath),
                arrayOf(mimeType),
                null
            )
            targetFile.absolutePath
        }
    }
}
