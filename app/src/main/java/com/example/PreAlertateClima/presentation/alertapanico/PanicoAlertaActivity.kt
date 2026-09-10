package com.example.PreAlertateClima.presentation.alertapanico

import android.content.Intent
import android.graphics.Color
import android.hardware.camera2.CameraManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.View
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import com.example.PreAlertateClima.R
import com.example.PreAlertateClima.presentation.base.DisasterActivity
import com.example.PreAlertateClima.presentation.navegacion.PantalladerActivity

class PanicoAlertaActivity : AppCompatActivity() {

    private lateinit var panicoLayout: View
    private lateinit var btnDetenerPanico: Button

    private lateinit var cameraManager: CameraManager
    private var cameraId: String = ""
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null

    private val handler = Handler(Looper.getMainLooper())
    private var isRedState = true
    private var isRunning = true
    //Luz intermitente , linterna y sonido que se actualiza cada 1 seg,
    private val flashingRunnable = object : Runnable {
        override fun run() {
            if (!isRunning) return

            try {
                if (isRedState) {
                    panicoLayout.setBackgroundColor(Color.parseColor("#FF0000"))
                    encenderLinterna(true)
                    vibrar()
                } else {
                    panicoLayout.setBackgroundColor(Color.parseColor("#FFFFFF"))
                    encenderLinterna(false)
                }
                isRedState = !isRedState
            } catch (e: Exception) {
                e.printStackTrace()
            }

            handler.postDelayed(this, 1000)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_panico_alerta)

        panicoLayout = findViewById(R.id.panicoLayout)
        btnDetenerPanico = findViewById(R.id.btnDetenerPanico)

        btnDetenerPanico.setOnClickListener {
            detenerTodoYSalir()
        }

        cameraManager = getSystemService(CAMERA_SERVICE) as CameraManager
        try {
            cameraId = cameraManager.cameraIdList[0]
        } catch (e: Exception) {
            e.printStackTrace()
        }
        //encender la vibracion del celular
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as Vibrator
        }

        // Reproducir sonido de alarma desde res/raw/alarma_alerta
        try {
            mediaPlayer = MediaPlayer.create(this, R.raw.alarma_alerta)
            mediaPlayer?.isLooping = true
            mediaPlayer?.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        handler.post(flashingRunnable)
    }
    //Funcion para encender la linterna del celular
    private fun encenderLinterna(on: Boolean) {
        try {
            if (cameraId.isNotEmpty()) {
                cameraManager.setTorchMode(cameraId, on)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    //Funcion para encender la vibracion del celular
    private fun vibrar() {
        try {
            if (vibrator?.hasVibrator() == true) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator?.vibrate(VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator?.vibrate(500)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    //desactivando la alerta se debe apagar todo funcionamiento iniciado (linterna,sonido,vibración)
    private fun desactivarAlerta() {
        isRunning = false
        handler.removeCallbacks(flashingRunnable)

        try { encenderLinterna(false) } catch (e: Exception) { e.printStackTrace() }
        try {
            if (mediaPlayer?.isPlaying == true) {
                mediaPlayer?.stop()
            }
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
        try { vibrator?.cancel() } catch (e: Exception) { e.printStackTrace() }

        DisasterActivity.isDisasterTriggeredGlobal = false
    }
    //Funcion para detener todo y volver a la pestaña anterior
    private fun detenerTodoYSalir() {
        desactivarAlerta()

        val intent = Intent(this, PantalladerActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        startActivity(intent)
        finish()
    }

    override fun onPause() {
        super.onPause()
        desactivarAlerta()
    }

    override fun onStop() {
        super.onStop()
        desactivarAlerta()
    }

    override fun onDestroy() {
        super.onDestroy()
        desactivarAlerta()
    }
}