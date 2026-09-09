package com.example.PreAlertateClima.presentation.navegacion

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Button
import android.webkit.WebView
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.PreAlertateClima.R
import com.google.firebase.firestore.FirebaseFirestore
import com.example.PreAlertateClima.utils.navegarHacia

class MainActivity : AppCompatActivity() {

    private lateinit var rvEmergencias: RecyclerView
    private lateinit var db: FirebaseFirestore
    private val listaEmergencias = mutableListOf<Emergencia>()
    private lateinit var adapter: EmergenciesAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.pantalla_inicio)

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
            Toast.makeText(this, "Ya te encuentras en la pantalla principal", Toast.LENGTH_SHORT).show()
        }

        btnDer.setOnClickListener {
            navegarHacia(PantalladerActivity::class.java)
        }

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
                <div class="commonninja_component pid-8ddd9bbb-2658-4e7a-a036-e6049fe0dbee"></div>
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

        // Inicializamos Cloud Firestore
        db = FirebaseFirestore.getInstance()
        cargarNumerosEmergenciaFirestore()
    }

    private fun cargarNumerosEmergenciaFirestore() {
        db.collection("Emergencias")
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    android.util.Log.e("FirestoreDebug", "Error al escuchar: ${error.message}")
                    return@addSnapshotListener
                }

                if (snapshot != null) {
                    android.util.Log.d("FirestoreDebug", "Documentos encontrados: ${snapshot.documents.size}")
                    listaEmergencias.clear()
                    for (document in snapshot.documents) {
                        android.util.Log.d("FirestoreDebug", "ID Doc: ${document.id} | Data: ${document.data}")

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
                }
            }
    }

    private fun llamarEmergencia(numero: String) {
        val intentLlamada = Intent(Intent.ACTION_DIAL)
        intentLlamada.data = Uri.parse("tel:$numero")
        startActivity(intentLlamada)
    }
}