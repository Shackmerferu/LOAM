package com.example.PreAlertateClima.presentation.media

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Bundle
import android.os.Environment
import android.util.Log
import android.widget.Button
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.video.FileOutputOptions
import androidx.camera.video.Quality
import androidx.camera.video.QualitySelector
import androidx.camera.video.Recorder
import androidx.camera.video.Recording
import androidx.camera.video.VideoCapture
import androidx.camera.video.VideoRecordEvent
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.PreAlertateClima.R
import com.example.PreAlertateClima.presentation.base.DisasterActivity
import com.example.PreAlertateClima.presentation.home.MainActivity
import com.example.PreAlertateClima.presentation.location.MapActivity
import com.example.PreAlertateClima.presentation.navegacion.PantalladerActivity
import com.example.PreAlertateClima.utils.navegarHacia
import java.io.File
import java.text.SimpleDateFormat
import java.util.Locale

class CameraActivity : DisasterActivity() {

    private lateinit var viewFinder: PreviewView
    private lateinit var btnSwitchCamera: Button
    private lateinit var btnTakePhoto: Button
    private lateinit var btnToggleRecord: Button

    private var imageCapture: ImageCapture? = null
    private var videoCapture: VideoCapture<Recorder>? = null
    private var activeRecording: Recording? = null

    private var cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA
    private var isRecording = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_camera)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        viewFinder = findViewById(R.id.viewFinder)
        btnSwitchCamera = findViewById(R.id.btnSwitchCamera)
        btnTakePhoto = findViewById(R.id.image_capture_button)
        btnToggleRecord = findViewById(R.id.btnToggleRecord)

        val btnSalir: Button = findViewById(R.id.btn_salir)
        val btnIzq: Button = findViewById(R.id.btn_izq)
        val btnMedio: Button = findViewById(R.id.btnmedio)
        val btnDer: Button = findViewById(R.id.btn_der)

        btnSalir.setOnClickListener { finishAffinity() }
        btnIzq.setOnClickListener { navegarHacia(MapActivity::class.java) }
        btnMedio.setOnClickListener { navegarHacia(MainActivity::class.java) }
        btnDer.setOnClickListener { navegarHacia(PantalladerActivity::class.java) }

        if (allPermissionsGranted()) {
            startCamera()
        } else {
            ActivityCompat.requestPermissions(this, REQUIRED_PERMISSIONS, REQUEST_CODE_PERMISSIONS)
        }

        btnSwitchCamera.setOnClickListener {
            cameraSelector = if (cameraSelector == CameraSelector.DEFAULT_FRONT_CAMERA) {
                CameraSelector.DEFAULT_BACK_CAMERA
            } else {
                CameraSelector.DEFAULT_FRONT_CAMERA
            }
            startCamera()
        }

        btnTakePhoto.setOnClickListener {
            takePhoto()
        }

        btnToggleRecord.setOnClickListener {
            toggleVideoRecord()
        }
    }

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)

        cameraProviderFuture.addListener({
            val cameraProvider: ProcessCameraProvider = cameraProviderFuture.get()

            val preview = Preview.Builder()
                .build()
                .also {
                    it.setSurfaceProvider(viewFinder.surfaceProvider)
                }

            imageCapture = ImageCapture.Builder().build()

            val recorder = Recorder.Builder()
                .setQualitySelector(QualitySelector.from(Quality.HIGHEST))
                .build()
            videoCapture = VideoCapture.withOutput(recorder)

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    this,
                    cameraSelector,
                    preview,
                    imageCapture,
                    videoCapture
                )

                if (intent.getBooleanExtra("AUTO_TAKE_PHOTO", false)) {
                    viewFinder.postDelayed({
                        takePhotoAndReturn()
                    }, 1000)
                }
            } catch (exc: Exception) {
                Log.e("CameraActivity", "Binding failed", exc)
            }

        }, ContextCompat.getMainExecutor(this))
    }

    private fun getOutputFile(dirType: String, prefix: String, extension: String): File {
        val publicDir = Environment.getExternalStoragePublicDirectory(dirType)
        val appDir = File(publicDir, "PreAlertate")
        if (!appDir.exists()) {
            appDir.mkdirs()
        }

        val name = SimpleDateFormat(FILENAME_FORMAT, Locale.US).format(System.currentTimeMillis())
        val file = File(appDir, "${prefix}_$name.$extension")

        return if (appDir.exists() && appDir.canWrite()) file else File(getExternalFilesDir(dirType) ?: filesDir, "${prefix}_$name.$extension")
    }

    private fun scanMediaFile(file: File, mimeType: String) {
        MediaScannerConnection.scanFile(
            applicationContext,
            arrayOf(file.absolutePath),
            arrayOf(mimeType)
        ) { path, uri ->
            Log.d("CameraActivity", "Scanned $path -> $uri")
        }
    }

    private fun takePhoto() {
        val imageCapture = imageCapture ?: return

        val photoFile = getOutputFile(Environment.DIRECTORY_PICTURES, "IMG", "jpg")
        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()

        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onError(exc: ImageCaptureException) {
                    Log.e("CameraActivity", "Photo capture failed: ${exc.message}", exc)
                    Toast.makeText(baseContext, "Error al tomar foto", Toast.LENGTH_SHORT).show()
                }

                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    scanMediaFile(photoFile, "image/jpeg")
                    val msg = "Foto guardada en galeria/archivos: ${photoFile.name}"
                    Toast.makeText(baseContext, msg, Toast.LENGTH_SHORT).show()
                }
            }
        )
    }

    private fun takePhotoAndReturn() {
        val imageCapture = imageCapture ?: return

        val photoFile = getOutputFile(Environment.DIRECTORY_PICTURES, "IMG", "jpg")
        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()

        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onError(exc: ImageCaptureException) {
                    Log.e("CameraActivity", "Photo capture failed: ${exc.message}", exc)
                    Toast.makeText(baseContext, "Error al tomar foto por voz", Toast.LENGTH_SHORT).show()
                    finish()
                }

                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    scanMediaFile(photoFile, "image/jpeg")
                    Toast.makeText(baseContext, "¡Foto tomada y guardada!", Toast.LENGTH_SHORT).show()
                    val intent = Intent(this@CameraActivity, PantalladerActivity::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    startActivity(intent)
                    finish()
                }
            }
        )
    }

    private fun toggleVideoRecord() {
        val videoCapture = this.videoCapture ?: return

        if (activeRecording != null) {
            activeRecording?.stop()
            activeRecording = null
            btnToggleRecord.text = "Grabar"
            isRecording = false
            Toast.makeText(this, "Grabación de video detenida", Toast.LENGTH_SHORT).show()
            return
        }

        val videoFile = getOutputFile(Environment.DIRECTORY_MOVIES, "VID", "mp4")
        val fileOutputOptions = FileOutputOptions.Builder(videoFile).build()

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), REQUEST_CODE_PERMISSIONS)
            return
        }

        activeRecording = videoCapture.output
            .prepareRecording(this, fileOutputOptions)
            .withAudioEnabled()
            .start(ContextCompat.getMainExecutor(this)) { recordEvent ->
                when (recordEvent) {
                    is VideoRecordEvent.Start -> {
                        isRecording = true
                        btnToggleRecord.text = "Detener"
                        Toast.makeText(this, "Grabando video...", Toast.LENGTH_SHORT).show()
                    }
                    is VideoRecordEvent.Finalize -> {
                        if (!recordEvent.hasError()) {
                            scanMediaFile(videoFile, "video/mp4")
                            Toast.makeText(this, "Video guardado en archivos: ${videoFile.name}", Toast.LENGTH_SHORT).show()
                        } else {
                            activeRecording?.close()
                            activeRecording = null
                            Log.e("CameraActivity", "Video capture error: ${recordEvent.error}")
                        }
                        btnToggleRecord.text = "Grabar"
                        isRecording = false
                    }
                }
            }
    }

    private fun allPermissionsGranted() = REQUIRED_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(baseContext, it) == PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_PERMISSIONS) {
            if (allPermissionsGranted()) {
                startCamera()
            } else {
                Toast.makeText(this, "Permisos de cámara / audio denegados", Toast.LENGTH_SHORT).show()
            }
        }
    }

    companion object {
        private const val FILENAME_FORMAT = "yyyy-MM-dd-HH-mm-ss-SSS"
        private const val REQUEST_CODE_PERMISSIONS = 10
        private val REQUIRED_PERMISSIONS = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO
        )
    }
}
