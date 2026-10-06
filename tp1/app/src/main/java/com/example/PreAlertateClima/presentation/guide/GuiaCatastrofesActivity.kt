package com.example.PreAlertateClima.presentation.guide

import android.net.Uri
import android.os.Bundle
import android.widget.Button
import android.widget.MediaController
import android.widget.VideoView
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.PreAlertateClima.R
import com.example.PreAlertateClima.presentation.home.MainActivity
import com.example.PreAlertateClima.presentation.location.MapActivity
import com.example.PreAlertateClima.presentation.navegacion.PantalladerActivity
import com.example.PreAlertateClima.utils.navegarHacia

// Actividad para mostrar guías y videos instructivos sobre catástrofes
class GuiaCatastrofesActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_guia_catastrofes)

        // Configuración edge-to-edge de la vista
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        // Configurar VideoViews para los videos de res/raw/ (Huracán, Terremoto y Tsunami)
        val vvHuracan: VideoView = findViewById(R.id.vvVideoHuracan)
        val vvTerremoto: VideoView = findViewById(R.id.vvVideoTerremoto)
        val vvTsunami: VideoView = findViewById(R.id.vvVideoTsunami)

        configurarVideoLocal(vvHuracan, R.raw.huracan_video)
        configurarVideoLocal(vvTerremoto, R.raw.terremoto_video)
        configurarVideoLocal(vvTsunami, R.raw.tsunami_video)

        // Botones de navegación inferior
        val btnSalir: Button = findViewById(R.id.btn_salir)
        val btnIzq: Button = findViewById(R.id.btn_izq)
        val btnMedio: Button = findViewById(R.id.btn_medio)
        val btnDer: Button = findViewById(R.id.btn_der)

        btnSalir.setOnClickListener { finishAffinity() }
        btnIzq.setOnClickListener { navegarHacia(MapActivity::class.java) }
        btnMedio.setOnClickListener { navegarHacia(MainActivity::class.java) }
        btnDer.setOnClickListener { navegarHacia(PantalladerActivity::class.java) }
    }

    // Función para configurar y cargar un video local desde los recursos raw
    private fun configurarVideoLocal(videoView: VideoView, rawResId: Int) {
        try {
            val uri = Uri.parse("android.resource://$packageName/$rawResId")
            videoView.setVideoURI(uri)
            val mediaController = MediaController(this)
            mediaController.setAnchorView(videoView)
            videoView.setMediaController(mediaController)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
