package com.example.PreAlertateClima.presentation.navegacion

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.PreAlertateClima.R
import com.example.PreAlertateClima.utils.navegarHacia
import android.hardware.camera2.CameraManager

class PantalladerActivity : AppCompatActivity() {

    private lateinit var cameraManager: CameraManager
    private var cameraId: String = ""
    private var isFlashOn = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.pantallader)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        val btnSalir: Button = findViewById(R.id.btn_salir)
        val btnIzq: Button = findViewById(R.id.btn_izq)
        val btnMedio: Button = findViewById(R.id.btnmedio)
        val btnDer: Button = findViewById(R.id.btn_der)

        btnSalir.setOnClickListener {
            finishAffinity()
        }

        btnIzq.setOnClickListener {
            navegarHacia(MapActivity::class.java)
        }

        btnMedio.setOnClickListener {
            navegarHacia(MainActivity::class.java)
        }

        btnDer.setOnClickListener {
            Toast.makeText(this, "Ya te encuentras en esta sección", Toast.LENGTH_SHORT).show()
        }

        // Inicializar CameraManager
        cameraManager = getSystemService(CAMERA_SERVICE) as CameraManager
        try {
            cameraId = cameraManager.cameraIdList[0]
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Llamamos a la función de configuración
        configurarLinterna()
    }

    private fun configurarLinterna() {
        val btnLinterna: Button = findViewById(R.id.btn_Linterna)

        btnLinterna.setOnClickListener {
            try {
                if (isFlashOn) {
                    cameraManager.setTorchMode(cameraId, false)
                    isFlashOn = false
                } else {
                    cameraManager.setTorchMode(cameraId, true)
                    isFlashOn = true
                }
            } catch (e: Exception) {
                Toast.makeText(this, "El dispositivo no soporta linterna", Toast.LENGTH_SHORT).show()
            }
        }
    }

    // Apagado obligatorio exigido por las consignas al salir de la app
    override fun onDestroy() {
        super.onDestroy()
        try {
            if (isFlashOn) {
                cameraManager.setTorchMode(cameraId, false)
                isFlashOn = false
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}