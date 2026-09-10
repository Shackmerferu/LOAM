package com.example.PreAlertateClima.presentation.home

import android.content.Intent
import android.content.res.ColorStateList
import android.graphics.Color
import android.hardware.camera2.CameraManager
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import android.widget.Button
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.PreAlertateClima.R
import com.example.PreAlertateClima.presentation.base.DisasterActivity
import com.example.PreAlertateClima.presentation.location.MapActivity
import com.example.PreAlertateClima.presentation.navegacion.Emergencia
import com.example.PreAlertateClima.presentation.navegacion.EmergenciesAdapter
import com.example.PreAlertateClima.presentation.navegacion.PantalladerActivity
import com.example.PreAlertateClima.utils.navegarHacia
import com.google.firebase.firestore.FirebaseFirestore

// Actividad principal de inicio que muestra clima, linterna y números de emergencia
class MainActivity : DisasterActivity() {

    private lateinit var rvEmergencias: RecyclerView
    private val listaEmergencias = mutableListOf<Emergencia>()
    private lateinit var adapter: EmergenciesAdapter

    private lateinit var cameraManager: CameraManager
    private var cameraId: String = ""
    private var isFlashOn = false
    private lateinit var btnLinternaHeader: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.pantalla_inicio)

        // Ajuste edge-to-edge
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        // Botones de navegación inferior
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
            Toast.makeText(this, "Ya te encuentras en la pantalla principal", Toast.LENGTH_SHORT).show()
        }

        btnDer.setOnClickListener {
            navegarHacia(PantalladerActivity::class.java)
        }

        // Configuración de Linterna en Header (Rojo apagado / Verde encendido)
        cameraManager = getSystemService(CAMERA_SERVICE) as CameraManager
        try {
            cameraId = cameraManager.cameraIdList[0]
        } catch (e: Exception) {
            e.printStackTrace()
        }

        btnLinternaHeader = findViewById(R.id.btn_linterna_header)
        btnLinternaHeader.setOnClickListener {
            toggleLinternaHeader()
        }

        // Configuración del WebView para mostrar el widget meteorológico
        val webView = findViewById<WebView>(R.id.weatherWebView)
        webView.settings.javaScriptEnabled = true

        val htmlContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    body { margin: 0; padding: 0; background-color: #fdf6e3; }
                    .commonninja_component { width: 100% !important; }
                    div.weather-widget {
                        border-color: transparent !important;
                        border-width: 0px !important;
                    }
                </style>
            </head>
            <body>
                <script src="https://cdn.commoninja.com/sdk/latest/commonninja.js" defer></script>
<div class="commonninja_component pid-796d41ad-c8ef-4c40-a2c4-a0387a1403d7"></div>
            </body>
            </html>
        """.trimIndent()

        webView.loadDataWithBaseURL("https://commonninja.com", htmlContent, "text/html", "UTF-8", null)

        rvEmergencias = findViewById(R.id.rvEmergencias)
        rvEmergencias.layoutManager = LinearLayoutManager(this)

        adapter = EmergenciesAdapter(listaEmergencias) { numeroParaLlamar ->
            llamarEmergencia(numeroParaLlamar)
        }
        rvEmergencias.adapter = adapter

        // Inicializamos Cloud Firestore para los números de emergencia
        db = FirebaseFirestore.getInstance()
        cargarNumerosEmergenciaFirestore()
    }

    // Función para alternar el estado de la linterna desde el encabezado
    private fun toggleLinternaHeader() {
        try {
            if (isFlashOn) {
                apagarLinternaHeader()
            } else {
                cameraManager.setTorchMode(cameraId, true)
                isFlashOn = true
                btnLinternaHeader.backgroundTintList = ColorStateList.valueOf(Color.parseColor("#27AE60")) // Verde
            }
        } catch (e: Exception) {
            Toast.makeText(this, "No se pudo activar la linterna", Toast.LENGTH_SHORT).show()
        }
    }

    // Función para apagar la linterna del encabezado y cambiar color de botón a rojo
    private fun apagarLinternaHeader() {
        try {
            if (isFlashOn) {
                cameraManager.setTorchMode(cameraId, false)
                isFlashOn = false
                btnLinternaHeader.backgroundTintList = ColorStateList.valueOf(Color.parseColor("#C0392B")) // Rojo
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    // Función para cargar los números de emergencia desde Firebase Firestore o valores por defecto
    private fun cargarNumerosEmergenciaFirestore() {
        val defaultEmergencias = listOf(
            Emergencia("Policía de Emergencias", "101"),
            Emergencia("Bomberos Voluntarios", "100"),
            Emergencia("Ambulancia (SAME)", "107"),
            Emergencia("Defensa Civil", "103")
        )

        listaEmergencias.clear()
        listaEmergencias.addAll(defaultEmergencias)
        adapter.notifyDataSetChanged()

        db.collection("Emergencias")
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    Log.e("FirestoreDebug", "Error al escuchar: ${error.message}")
                    return@addSnapshotListener
                }

                if (snapshot != null && !snapshot.isEmpty) {
                    Log.d("FirestoreDebug", "Documentos encontrados: ${snapshot.documents.size}")
                    listaEmergencias.clear()
                    for (document in snapshot.documents) {
                        val nombre = document.getString("nombre")
                            ?: document.getString("name")
                            ?: document.id

                        val numero = document.getString("numero")
                            ?: document.getString("number")
                            ?: document.getString("phone")
                            ?: ""

                        if (nombre.isNotBlank() && numero.isNotBlank()) {
                            listaEmergencias.add(Emergencia(nombre, numero))
                        }
                    }
                    adapter.notifyDataSetChanged()
                } else if (snapshot != null && snapshot.isEmpty) {
                    for (emergencia in defaultEmergencias) {
                        db.collection("Emergencias").add(
                            mapOf("nombre" to emergencia.nombre, "numero" to emergencia.numero)
                        )
                    }
                }
            }
    }

    // Función para realizar llamada telefónica de emergencia
    private fun llamarEmergencia(numero: String) {
        val intentLlamada = Intent(Intent.ACTION_DIAL)
        intentLlamada.data = Uri.parse("tel:$numero")
        startActivity(intentLlamada)
    }

    override fun onPause() {
        super.onPause()
        apagarLinternaHeader()
    }

    override fun onStop() {
        super.onStop()
        apagarLinternaHeader()
    }

    override fun onDestroy() {
        super.onDestroy()
        apagarLinternaHeader()
    }
}
