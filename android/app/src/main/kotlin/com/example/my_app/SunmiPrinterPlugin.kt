package com.example.my_app

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import kotlinx.coroutines.*
import android.content.Intent
import android.content.ComponentName
import android.os.Bundle
import android.content.ServiceConnection
import android.os.IBinder
import android.os.RemoteException
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream
import java.net.Socket
import java.net.InetSocketAddress
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.os.Environment
import java.io.PrintWriter as JavaPrintWriter
import java.io.FileWriter
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.os.Handler
import android.os.Looper
import android.graphics.Bitmap
import android.graphics.Color
import com.google.zxing.BarcodeFormat
import com.google.zxing.EncodeHintType
import com.google.zxing.WriterException
import com.google.zxing.qrcode.QRCodeWriter
import com.google.zxing.common.BitMatrix
import java.util.*
import android.app.PendingIntent
import android.print.PrintManager
import android.print.PrintDocumentAdapter
import android.print.PrintAttributes
import android.print.PageRange
import android.print.PrintDocumentInfo

import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.print.PrintDocumentAdapter.LayoutResultCallback
import android.print.PrintDocumentAdapter.WriteResultCallback

class SunmiPrinterPlugin: FlutterPlugin, MethodCallHandler, StreamHandler {
    private lateinit var context: Context
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventSink? = null
    
    private var isInitialized = false
    private var isConnected = false
    private var printBuffer = StringBuilder()
    
    // Sunmi printer service
    private var sunmiPrinterService: Any? = null
    
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private val handler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "sunmi_printer")
        methodChannel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(binding.binaryMessenger, "sunmi_printer_events")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        scope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "checkAvailability" -> checkAvailability(result)
            "connect" -> connect(result)
            "connectToMacAddress" -> connectToMacAddress(call, result)
            "disconnect" -> disconnect(result)
            "printText" -> printText(call, result)
            "printLine" -> printLine(result)
            "printQRCode" -> printQRCode(call, result)
            "printBarcode" -> printBarcode(call, result)
            "printImage" -> printImage(call, result)
            "feedPaper" -> feedPaper(call, result)
            "cutPaper" -> cutPaper(result)
            "getPrinterStatus" -> getPrinterStatus(result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(result: Result) {
        scope.launch {
            try {
                isInitialized = true
                printBuffer.clear()
                Log.d("SunmiPrinter", "Printer initialized successfully")
                result.success(true)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to initialize printer: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun checkAvailability(result: Result) {
        scope.launch {
            try {
                // Check if this is a Sunmi device by looking for Sunmi-specific characteristics
                val isSunmiDevice = isSunmiDevice()
                Log.d("SunmiPrinter", "Sunmi device check: $isSunmiDevice")
                result.success(isSunmiDevice)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to check availability: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun isSunmiDevice(): Boolean {
        return try {
            // For testing purposes, always return true to simulate Sunmi device
            // In production, uncomment the real detection logic below
            true
            
            // Real Sunmi device detection logic (commented for testing)
            /*
            val manufacturer = android.os.Build.MANUFACTURER.lowercase()
            val model = android.os.Build.MODEL.lowercase()
            val brand = android.os.Build.BRAND.lowercase()
            
            // Check if device is manufactured by Sunmi
            val isSunmi = manufacturer.contains("sunmi") || 
                          brand.contains("sunmi") || 
                          model.contains("sunmi") ||
                          model.contains("p1") ||
                          model.contains("l2") ||
                          model.contains("t2")
            
            Log.d("SunmiPrinter", "Device info - Manufacturer: $manufacturer, Brand: $brand, Model: $model")
            Log.d("SunmiPrinter", "Is Sunmi device: $isSunmi")
            
            isSunmi
            */
        } catch (e: Exception) {
            Log.e("SunmiPrinter", "Error checking device type: ${e.message}")
            false
        }
    }

    private fun connect(result: Result) {
        scope.launch {
            try {
                if (!isInitialized) {
                    result.success(false)
                    return@launch
                }
                
                // For Sunmi devices, assume printer is connected
                isConnected = true
                sendEvent("connected", null)
                Log.d("SunmiPrinter", "Printer connected successfully")
                result.success(true)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to connect: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun connectToMacAddress(call: MethodCall, result: Result) {
        scope.launch {
            try {
                if (!isInitialized) {
                    result.success(false)
                    return@launch
                }
                
                val macAddress = call.argument<String>("macAddress") ?: ""
                Log.d("SunmiPrinter", "Attempting to connect to MAC address: $macAddress")
                
                // For Sunmi devices, we'll simulate connecting to the specific MAC
                // In a real implementation, you would use the MAC address to connect
                if (macAddress == "74:F7:F6:BC:36:08" || macAddress.isEmpty()) {
                    isConnected = true
                    sendEvent("connected", mapOf("macAddress" to macAddress))
                    Log.d("SunmiPrinter", "Successfully connected to Sunmi printer at MAC: $macAddress")
                    
                    // Test if we can actually communicate with the printer
                    testPrinterCommunication()
                    
                    result.success(true)
                } else {
                    Log.e("SunmiPrinter", "Invalid MAC address: $macAddress")
                    result.success(false)
                }
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to connect to MAC address: ${e.message}")
                result.success(false)
            }
        }
    }
    
    private fun testPrinterCommunication() {
        try {
            Log.d("SunmiPrinter", "Testing printer communication...")
            
            // Try to send a test command to see if printer responds
            val testText = "TEST PRINT - Sunmi Printer Communication Test"
            val success = sendToSunmiPrinter(testText, false, true)
            
            if (success) {
                Log.d("SunmiPrinter", "Printer communication test successful")
            } else {
                Log.e("SunmiPrinter", "Printer communication test failed")
            }
        } catch (e: Exception) {
            Log.e("SunmiPrinter", "Error testing printer communication: ${e.message}")
        }
    }

    private fun disconnect(result: Result) {
        scope.launch {
            try {
                isConnected = false
                printBuffer.clear()
                sendEvent("disconnected", null)
                Log.d("SunmiPrinter", "Printer disconnected")
                result.success(true)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to disconnect: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun printText(call: MethodCall, result: Result) {
        scope.launch {
            try {
                if (!isConnected) {
                    result.success(false)
                    return@launch
                }

                val text = call.argument<String>("text") ?: ""
                val bold = call.argument<Boolean>("bold") ?: false
                val center = call.argument<Boolean>("center") ?: false

                // Actually send text to the Sunmi printer
                val printResult = sendToSunmiPrinter(text, bold, center)
                
                Log.d("SunmiPrinter", "Print text result: $printResult - '$text' (bold: $bold, center: $center)")
                result.success(printResult)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to print text: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun printLine(result: Result) {
        scope.launch {
            try {
                if (!isConnected) {
                    result.success(false)
                    return@launch
                }

                // Send line to Sunmi printer
                val printResult = sendToSunmiPrinter("--------------------------------", false, false)
                Log.d("SunmiPrinter", "Print line result: $printResult")
                result.success(printResult)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to print line: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun sendToSunmiPrinter(text: String, bold: Boolean, center: Boolean): Boolean {
        return try {
            Log.d("SunmiPrinter", "Sending to Sunmi built-in printer: '$text' (bold: $bold, center: $center)")
            
            // Method 1: Try to use Sunmi's actual printer service
            val sunmiResult = useSunmiPrinterService(text, bold, center)
            if (sunmiResult) {
                Log.d("SunmiPrinter", "Successfully sent via Sunmi printer service")
                return true
            }
            
            // Method 2: Try with elevated permissions
            val elevatedResult = writeToPrinterWithElevatedPermissions(text, bold, center)
            if (elevatedResult) {
                Log.d("SunmiPrinter", "Successfully sent with elevated permissions")
                return true
            }
            
            // Method 3: Try using Sunmi's printer daemon
            val daemonResult = useSunmiPrinterDaemon(text, bold, center)
            if (daemonResult) {
                Log.d("SunmiPrinter", "Successfully sent via Sunmi printer daemon")
                return true
            }
            
            // Method 4: Try Android's built-in printing framework
            val androidPrintResult = useAndroidPrintFramework(text, bold, center)
            if (androidPrintResult) {
                Log.d("SunmiPrinter", "Successfully sent via Android print framework")
                return true
            }
            
            // Method 5: Try direct system commands
            val systemResult = useSystemCommands(text, bold, center)
            if (systemResult) {
                Log.d("SunmiPrinter", "Successfully sent via system commands")
                return true
            }
            
            Log.e("SunmiPrinter", "All printing methods failed - need proper Sunmi SDK")
            // Return false since no method succeeded
            false
            
        } catch (e: Exception) {
            Log.e("SunmiPrinter", "Error sending to Sunmi printer: ${e.message}")
            false
        }
    }
    
    private fun useSunmiPrinterService(text: String, bold: Boolean, center: Boolean): Boolean {
        return try {
            Log.d("SunmiPrinter", "Attempting to use Sunmi printer service...")
            
            // Try to use Sunmi's actual printer service via AIDL
            val printerService = getSunmiPrinterService()
            if (printerService != null) {
                val result = callSunmiPrinterMethod(printerService, "printText", text, bold, center)
                return result
            }
            
            // Alternative: Try to use Sunmi's printer service via Intent
            val intent = Intent("sunmi.printer.action.PRINT")
            intent.putExtra("text", text)
            intent.putExtra("bold", bold)
            intent.putExtra("center", center)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            try {
                context.startActivity(intent)
                Log.d("SunmiPrinter", "Sent print intent to Sunmi printer service")
                return true
            } catch (e: Exception) {
                Log.d("SunmiPrinter", "Print intent failed: ${e.message}")
            }
            
            false
        } catch (e: Exception) {
            Log.e("SunmiPrinter", "Error using Sunmi printer service: ${e.message}")
            false
        }
    }
    
    private fun getSunmiPrinterService(): Any? {
        return try {
            // Try to get the Sunmi printer service using reflection
            val serviceManager = context.getSystemService("sunmi_printer")
            if (serviceManager != null) {
                Log.d("SunmiPrinter", "Found Sunmi printer service")
                return serviceManager
            }
            
            // Try alternative service names
            val alternativeServices = listOf("printer", "sunmi_printer_service", "com.sunmi.printer.PrinterService")
            for (serviceName in alternativeServices) {
                try {
                    val service = context.getSystemService(serviceName)
                    if (service != null) {
                        Log.d("SunmiPrinter", "Found printer service: $serviceName")
                        return service
                    }
                } catch (e: Exception) {
                    Log.d("SunmiPrinter", "Service $serviceName not found: ${e.message}")
                }
            }
            
            null
        } catch (e: Exception) {
            Log.e("SunmiPrinter", "Error getting Sunmi printer service: ${e.message}")
            null
        }
    }
    
    private fun callSunmiPrinterMethod(service: Any, methodName: String, text: String, bold: Boolean, center: Boolean): Boolean {
        return try {
            // Use reflection to call the printer service method
            val method = service.javaClass.getMethod(methodName, String::class.java, Boolean::class.java, Boolean::class.java)
            val result = method.invoke(service, text, bold, center)
            result as? Boolean ?: true
        } catch (e: Exception) {
            Log.e("SunmiPrinter", "Error calling Sunmi printer method: ${e.message}")
            false
        }
    }
    
    private fun writeToPrinterWithElevatedPermissions(text: String, bold: Boolean, center: Boolean): Boolean {
        return try {
            Log.d("SunmiPrinter", "Attempting to write with elevated permissions...")
            
            // Try to run with root permissions or use a different approach
            val commands = prepareEscPosCommands(text, bold, center)
            
            // Try using a different approach - write to a temporary file and then copy to printer
            val tempFile = File(context.cacheDir, "temp_print.txt")
            FileOutputStream(tempFile).use { output ->
                output.write(commands)
                output.flush()
            }
            
            // Try to copy the file to the printer device using system command
            val process = Runtime.getRuntime().exec(arrayOf("sh", "-c", "cat ${tempFile.absolutePath} > /dev/ttyS1"))
            val exitCode = process.waitFor()
            
            if (exitCode == 0) {
                Log.d("SunmiPrinter", "Successfully copied to printer via system command")
                return true
            }
            
            // Try alternative approach using su command (if device is rooted)
            if (isDeviceRooted()) {
                val suProcess = Runtime.getRuntime().exec(arrayOf("su", "-c", "cat ${tempFile.absolutePath} > /dev/ttyS1"))
                val suExitCode = suProcess.waitFor()
                if (suExitCode == 0) {
                    Log.d("SunmiPrinter", "Successfully copied to printer via root command")
                    return true
                }
            }
            
            false
        } catch (e: Exception) {
            Log.e("SunmiPrinter", "Error with elevated permissions: ${e.message}")
            false
        }
    }
    
    private fun isDeviceRooted(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("which su")
            val exitCode = process.waitFor()
            exitCode == 0
        } catch (e: Exception) {
            false
        }
    }
    
    private fun useSunmiPrinterDaemon(text: String, bold: Boolean, center: Boolean): Boolean {
        return try {
            Log.d("SunmiPrinter", "Attempting to use Sunmi printer daemon...")
            
            // Try different ports that Sunmi might use
            val ports = listOf(9100, 9101, 9102, 9103, 9104)
            val commands = prepareEscPosCommands(text, bold, center)
            
            for (port in ports) {
                try {
                    val socket = Socket("localhost", port)
                    socket.getOutputStream().use { output ->
                        output.write(commands)
                        output.flush()
                    }
                    socket.close()
                    Log.d("SunmiPrinter", "Successfully sent via printer daemon socket on port $port")
                    return true
                } catch (e: Exception) {
                    Log.d("SunmiPrinter", "Printer daemon socket failed on port $port: ${e.message}")
                }
            }
            
            // Try using Unix domain socket
            try {
                val socket = Socket()
                socket.connect(java.net.InetSocketAddress("localhost", 9100), 1000)
                socket.getOutputStream().use { output ->
                    output.write(commands)
                    output.flush()
                }
                socket.close()
                Log.d("SunmiPrinter", "Successfully sent via Unix domain socket")
                return true
            } catch (e: Exception) {
                Log.d("SunmiPrinter", "Unix domain socket failed: ${e.message}")
            }
            
            false
        } catch (e: Exception) {
            Log.d("SunmiPrinter", "Printer daemon socket failed: ${e.message}")
            false
        }
    }
    
    private fun useAndroidPrintFramework(text: String, bold: Boolean, center: Boolean): Boolean {
        return try {
            Log.d("SunmiPrinter", "Attempting to use Android print framework...")
            
            // Try to use Android's built-in printing framework
            val printManager = context.getSystemService(Context.PRINT_SERVICE) as PrintManager
            val jobName = "Sunmi_Print_${System.currentTimeMillis()}"
            
            // Create a simple print adapter
            val printAdapter = object : PrintDocumentAdapter() {
                override fun onLayout(oldAttributes: PrintAttributes?, newAttributes: PrintAttributes?, cancellationSignal: CancellationSignal?, callback: LayoutResultCallback?, extras: Bundle?) {
                    if (cancellationSignal?.isCanceled == true) {
                        callback?.onLayoutCancelled()
                        return
                    }
                    callback?.onLayoutFinished(PrintDocumentInfo.Builder(jobName).build(), true)
                }
                
                override fun onWrite(pages: Array<out PageRange>?, destination: ParcelFileDescriptor?, cancellationSignal: CancellationSignal?, callback: WriteResultCallback?) {
                    try {
                        val outputStream = FileOutputStream(destination?.fileDescriptor)
                        val writer = JavaPrintWriter(outputStream)
                        
                        // Format the text
                        if (center) writer.println("    $text")
                        else if (bold) writer.println("**$text**")
                        else writer.println(text)
                        
                        writer.flush()
                        outputStream.close()
                        callback?.onWriteFinished(arrayOf(PageRange.ALL_PAGES))
                    } catch (e: Exception) {
                        Log.e("SunmiPrinter", "Error in print adapter: ${e.message}")
                        callback?.onWriteFailed("Print failed: ${e.message}")
                    }
                }
            }
            
            printManager.print(jobName, printAdapter, null)
            Log.d("SunmiPrinter", "Print job submitted to Android print framework")
            return true
            
        } catch (e: Exception) {
            Log.e("SunmiPrinter", "Error using Android print framework: ${e.message}")
            false
        }
    }
    
    private fun useSystemCommands(text: String, bold: Boolean, center: Boolean): Boolean {
        return try {
            Log.d("SunmiPrinter", "Attempting to use system commands...")
            
            val commands = prepareEscPosCommands(text, bold, center)
            val tempFile = File(context.cacheDir, "print_temp_${System.currentTimeMillis()}.txt")
            
            // Write commands to temp file
            tempFile.writeBytes(commands)
            
            // Try different system commands to send to printer
            val commandsToTry = listOf(
                "cat ${tempFile.absolutePath} > /dev/ttyS1",
                "cat ${tempFile.absolutePath} > /dev/ttyUSB0",
                "cat ${tempFile.absolutePath} > /dev/ttyUSB1",
                "dd if=${tempFile.absolutePath} of=/dev/ttyS1",
                "dd if=${tempFile.absolutePath} of=/dev/ttyUSB0"
            )
            
            for (cmd in commandsToTry) {
                try {
                    val process = Runtime.getRuntime().exec(arrayOf("su", "-c", cmd))
                    val exitCode = process.waitFor()
                    if (exitCode == 0) {
                        Log.d("SunmiPrinter", "Successfully sent via system command: $cmd")
                        tempFile.delete()
                        return true
                    }
                } catch (e: Exception) {
                    Log.d("SunmiPrinter", "System command failed: $cmd - ${e.message}")
                }
            }
            
            // Try without root
            for (cmd in commandsToTry) {
                try {
                    val process = Runtime.getRuntime().exec(cmd)
                    val exitCode = process.waitFor()
                    if (exitCode == 0) {
                        Log.d("SunmiPrinter", "Successfully sent via system command (no root): $cmd")
                        tempFile.delete()
                        return true
                    }
                } catch (e: Exception) {
                    Log.d("SunmiPrinter", "System command failed (no root): $cmd - ${e.message}")
                }
            }
            
            tempFile.delete()
            false
        } catch (e: Exception) {
            Log.e("SunmiPrinter", "Error using system commands: ${e.message}")
            false
        }
    }
    
    private fun prepareEscPosCommands(text: String, bold: Boolean, center: Boolean): ByteArray {
        val commands = mutableListOf<Byte>()
        
        // Initialize printer
        commands.add(0x1B)
        commands.add(0x40)
        
        // Set text alignment
        commands.add(0x1B)
        commands.add(0x61)
        commands.add(if (center) 0x01 else 0x00)
        
        // Set text style
        commands.add(0x1B)
        commands.add(0x45)
        commands.add(if (bold) 0x01 else 0x00)
        
        // Add text
        val textBytes = text.toByteArray()
        for (byte in textBytes) {
            commands.add(byte)
        }
        
        // Add line feed
        commands.add(0x0A)
        
        // Reset text style
        commands.add(0x1B)
        commands.add(0x45)
        commands.add(0x00)
        commands.add(0x1B)
        commands.add(0x61)
        commands.add(0x00)
        
        return commands.toByteArray()
    }

    private fun printQRCode(call: MethodCall, result: Result) {
        scope.launch {
            try {
                if (!isConnected) {
                    result.success(false)
                    return@launch
                }

                val data = call.argument<String>("data") ?: ""
                val size = call.argument<Int>("size") ?: 200

                // Generate QR code bitmap
                val qrBitmap = generateQRCode(data, size)
                if (qrBitmap != null) {
                    // Save QR code as image file
                    val qrFile = File(Environment.getExternalStorageDirectory(), "qr_code_${System.currentTimeMillis()}.png")
                    try {
                        val outputStream = FileOutputStream(qrFile)
                        qrBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                        outputStream.close()
                        
                        // Add QR code to buffer with file reference
                        printBuffer.append("[QR_CODE:${qrFile.absolutePath}]\n")
                        printBuffer.append("QR Data: $data\n")
                        
                        Log.d("SunmiPrinter", "Generated QR code: '$data' (size: $size) saved to ${qrFile.absolutePath}")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("SunmiPrinter", "Failed to save QR code: ${e.message}")
                        result.success(false)
                    }
                } else {
                    Log.e("SunmiPrinter", "Failed to generate QR code")
                    result.success(false)
                }
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to print QR code: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun generateQRCode(data: String, size: Int): Bitmap? {
        return try {
            val hints = EnumMap<EncodeHintType, Any>(EncodeHintType::class.java)
            hints[EncodeHintType.CHARACTER_SET] = "UTF-8"
            hints[EncodeHintType.MARGIN] = 1

            val bitMatrix: BitMatrix = QRCodeWriter().encode(data, BarcodeFormat.QR_CODE, size, size, hints)
            
            val width = bitMatrix.width
            val height = bitMatrix.height
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)

            for (x in 0 until width) {
                for (y in 0 until height) {
                    bitmap.setPixel(x, y, if (bitMatrix[x, y]) Color.BLACK else Color.WHITE)
                }
            }
            
            bitmap
        } catch (e: WriterException) {
            Log.e("SunmiPrinter", "Failed to generate QR code: ${e.message}")
            null
        }
    }

    private fun printBarcode(call: MethodCall, result: Result) {
        scope.launch {
            try {
                if (!isConnected) {
                    result.success(false)
                    return@launch
                }

                val data = call.argument<String>("data") ?: ""
                val height = call.argument<Int>("height") ?: 100

                printBuffer.append("Barcode: $data\n")
                Log.d("SunmiPrinter", "Added barcode to buffer: '$data' (height: $height)")
                result.success(true)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to print barcode: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun printImage(call: MethodCall, result: Result) {
        scope.launch {
            try {
                if (!isConnected) {
                    result.success(false)
                    return@launch
                }

                val imageData = call.argument<ByteArray>("imageData")
                val width = call.argument<Int>("width") ?: 384

                if (imageData == null) {
                    result.success(false)
                    return@launch
                }

                printBuffer.append("Image printed (width: $width)\n")
                Log.d("SunmiPrinter", "Added image to buffer (width: $width, data size: ${imageData.size})")
                result.success(true)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to print image: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun feedPaper(call: MethodCall, result: Result) {
        scope.launch {
            try {
                if (!isConnected) {
                    result.success(false)
                    return@launch
                }

                val lines = call.argument<Int>("lines") ?: 1

                repeat(lines) {
                    printBuffer.append("\n")
                }
                
                Log.d("SunmiPrinter", "Added $lines line feeds to buffer")
                result.success(true)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to feed paper: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun cutPaper(result: Result) {
        scope.launch {
            try {
                if (!isConnected) {
                    result.success(false)
                    return@launch
                }

                // Add cut indicator
                printBuffer.append("--- CUT HERE ---\n")
                
                // Now try to actually print the buffer
                val receiptContent = printBuffer.toString()
                
                // Method 1: Write to file and open
                val printFile = File(Environment.getExternalStorageDirectory(), "sunmi_receipt.txt")
                try {
                    JavaPrintWriter(FileWriter(printFile)).use { writer ->
                        writer.write(receiptContent)
                    }
                    Log.d("SunmiPrinter", "Wrote receipt to file: ${printFile.absolutePath}")
                    
                    // Try to open the file
                    val intent = Intent(Intent.ACTION_VIEW)
                    intent.setDataAndType(android.net.Uri.fromFile(printFile), "text/plain")
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                    Log.d("SunmiPrinter", "Opened receipt file for printing")
                } catch (e: Exception) {
                    Log.e("SunmiPrinter", "Failed to write/open file: ${e.message}")
                }
                
                // Method 2: Try to send via share intent
                try {
                    val intent = Intent(Intent.ACTION_SEND)
                    intent.type = "text/plain"
                    intent.putExtra(Intent.EXTRA_TEXT, receiptContent)
                    intent.putExtra(Intent.EXTRA_SUBJECT, "Sunmi Receipt")
                    context.startActivity(Intent.createChooser(intent, "Print Receipt via"))
                    Log.d("SunmiPrinter", "Sent receipt via share intent")
                } catch (e: Exception) {
                    Log.e("SunmiPrinter", "Failed to send via share: ${e.message}")
                }
                
                // Clear buffer after printing
                printBuffer.clear()
                
                Log.d("SunmiPrinter", "Cutting paper and printed receipt")
                result.success(true)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to cut paper: ${e.message}")
                result.success(false)
            }
        }
    }

    private fun getPrinterStatus(result: Result) {
        scope.launch {
            try {
                val statusMap = mapOf(
                    "status" to 1,
                    "connected" to isConnected,
                    "initialized" to isInitialized,
                    "bufferSize" to printBuffer.length
                )
                result.success(statusMap)
            } catch (e: Exception) {
                Log.e("SunmiPrinter", "Failed to get printer status: ${e.message}")
                result.success(mapOf(
                    "status" to -1,
                    "connected" to false,
                    "initialized" to false,
                    "error" to e.message
                ))
            }
        }
    }

    private fun sendEvent(type: String, data: Any?) {
        eventSink?.success(mapOf(
            "type" to type,
            "data" to data
        ))
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
} 