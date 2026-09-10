package com.example.PreAlertateClima.presentation.comandovoz

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
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
import java.util.Date
import java.util.Locale

// Actividad para grabar notas de voz y audios de emergencia
class VoiceActivity : DisasterActivity() {

    private lateinit var tvAudioStatus: TextView
    private lateinit var btnRecordAudio: Button

    private var mediaRecorder: MediaRecorder? = null
    private var isRecording = false
    private var audioFile: File? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_voice)

        // Configuración de insets de pantalla edge-to-edge
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        tvAudioStatus = findViewById(R.id.tvAudioStatus)
        btnRecordAudio = findViewById(R.id.btnRecordAudio)

        // Botones de navegación inferior
        val btnSalir: Button = findViewById(R.id.btn_salir)
        val btnIzq: Button = findViewById(R.id.btn_izq)
        val btnMedio: Button = findViewById(R.id.btnmedio)
        val btnDer: Button = findViewById(R.id.btn_der)

        btnSalir.setOnClickListener { finishAffinity() }
        btnIzq.setOnClickListener { navegarHacia(MapActivity::class.java) }
        btnMedio.setOnClickListener { navegarHacia(MainActivity::class.java) }
        btnDer.setOnClickListener { navegarHacia(PantalladerActivity::class.java) }

        // Solicitar permisos en tiempo de ejecución para micrófono y almacenamiento según versión
        val permissions = mutableListOf(Manifest.permission.RECORD_AUDIO)
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
            permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
        }

        if (!permissions.all { ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED }) {
            ActivityCompat.requestPermissions(this, permissions.toTypedArray(), REQUEST_AUDIO_PERMISSION)
        }

        // Botón para iniciar o detener la grabación de audio
        btnRecordAudio.setOnClickListener {
            if (isRecording) {
                stopRecording()
            } else {
                startRecording()
            }
        }
    }

    // Función para iniciar la grabación de audio desde el micrófono
    private fun startRecording() {
        val permissions = mutableListOf(Manifest.permission.RECORD_AUDIO)
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
            permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
        }

        if (!permissions.all { ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED }) {
            ActivityCompat.requestPermissions(this, permissions.toTypedArray(), REQUEST_AUDIO_PERMISSION)
            return
        }

        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val musicDir = getExternalFilesDir(Environment.DIRECTORY_MUSIC) ?: filesDir
        audioFile = File(musicDir, "AUDIO_$timeStamp.m4a")

        try {
            mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(this)
            } else {
                @Suppress("DEPRECATION")
                (MediaRecorder())
            }.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setOutputFile(audioFile?.absolutePath)
                prepare()
                start()
            }

            isRecording = true
            tvAudioStatus.text = "🔴 Grabando audio de micrófono..."
            btnRecordAudio.text = "Detener Grabación"
            Toast.makeText(this, "Grabando audio...", Toast.LENGTH_SHORT).show()

        } catch (e: Exception) {
            Log.e("VoiceActivity", "Error al iniciar grabación: ${e.message}", e)
            Toast.makeText(this, "Error al iniciar grabación: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }

    // Función para detener la grabación y guardar el archivo de audio
    private fun stopRecording() {
        try {
            try {
                mediaRecorder?.stop()
            } catch (e: Exception) {
                Log.e("VoiceActivity", "Stop rápido: ${e.message}")
            }
            mediaRecorder?.release()
            mediaRecorder = null
            isRecording = false

            val file = audioFile
            if (file != null && file.exists() && file.length() > 0) {
                guardarEnMediaStorePublica(file)
                tvAudioStatus.text = "✅ Audio guardado en carpeta Music: ${file.name}"
                Toast.makeText(this, "Audio guardado exitosamente en Music", Toast.LENGTH_LONG).show()
            } else {
                tvAudioStatus.text = "⚠️ La grabación fue demasiado corta."
                Toast.makeText(this, "Mantené la grabación al menos 1 segundo", Toast.LENGTH_SHORT).show()
            }

            btnRecordAudio.text = "Iniciar Grabación"

        } catch (e: Exception) {
            Log.e("VoiceActivity", "Error al detener grabación: ${e.message}", e)
            Toast.makeText(this, "Error al detener grabación", Toast.LENGTH_SHORT).show()
        }
    }

    // Función para guardar la grabación de audio en el almacenamiento público MediaStore
    private fun guardarEnMediaStorePublica(file: File) {
        try {
            val values = ContentValues().apply {
                put(MediaStore.Audio.Media.DISPLAY_NAME, file.name)
                put(MediaStore.Audio.Media.MIME_TYPE, "audio/m4a")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Audio.Media.RELATIVE_PATH, "${Environment.DIRECTORY_MUSIC}/PreAlertate")
                    put(MediaStore.Audio.Media.IS_PENDING, 1)
                }
            }

            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values)

            if (uri != null) {
                resolver.openOutputStream(uri)?.use { outputStream ->
                    file.inputStream().use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    values.clear()
                    values.put(MediaStore.Audio.Media.IS_PENDING, 0)
                    resolver.update(uri, values, null, null)
                }
                Log.d("VoiceActivity", "Copiado a MediaStore: $uri")
            }
        } catch (e: Exception) {
            Log.e("VoiceActivity", "Error al guardar en MediaStore: ${e.message}")
        }

        MediaScannerConnection.scanFile(
            applicationContext,
            arrayOf(file.absolutePath),
            arrayOf("audio/m4a", "audio/mp4")
        ) { path, uri ->
            Log.d("VoiceActivity", "Scanned audio $path -> $uri")
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_AUDIO_PERMISSION) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startRecording()
            } else {
                Toast.makeText(this, "Permiso de micrófono denegado", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onStop() {
        super.onStop()
        if (isRecording) {
            stopRecording()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            mediaRecorder?.release()
            mediaRecorder = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    companion object {
        private const val REQUEST_AUDIO_PERMISSION = 200
    }
}
