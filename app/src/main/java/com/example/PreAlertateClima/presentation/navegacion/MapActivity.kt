package com.example.PreAlertateClima.presentation.navegacion

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.location.Geocoder
import android.location.LocationManager
import android.os.Bundle
import android.webkit.WebView
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.PreAlertateClima.R
import com.example.PreAlertateClima.utils.navegarHacia
import com.google.android.gms.location.LocationServices
import com.google.firebase.firestore.FirebaseFirestore
import java.util.Locale

class MapActivity : AppCompatActivity() {

    private lateinit var tvDireccionGrande: TextView
    private lateinit var mapaWebView: WebView
    private lateinit var btnGuardarLocacion: Button

    // Coordenadas por defecto (fallback) para que OpenStreetMap no quede en blanco o trabado
    private var latitudActual: Double = -35.6683
    private var longitudActual: Double = -63.7704

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_map)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        tvDireccionGrande = findViewById(R.id.tvDireccionGrande)
        mapaWebView = findViewById(R.id.mapaWebView)
        btnGuardarLocacion = findViewById(R.id.btnGuardarLocacion)

        mapaWebView.settings.javaScriptEnabled = true

        verificarEstadoGPS()

        btnGuardarLocacion.setOnClickListener {
            guardarEnFirestore()
        }

        val btnSalir: Button = findViewById(R.id.btn_salir)
        val btnIzq: Button = findViewById(R.id.btn_izq)
        val btnMedio: Button = findViewById(R.id.btnmedio)
        val btnDer: Button = findViewById(R.id.btn_der)

        btnSalir.setOnClickListener {
            finishAffinity()
        }

        btnIzq.setOnClickListener {
            Toast.makeText(this, "Ya te encuentras en la pantalla del mapa", Toast.LENGTH_SHORT).show()
        }

        btnMedio.setOnClickListener {
            navegarHacia(MainActivity::class.java)
        }

        btnDer.setOnClickListener {
            navegarHacia(PantalladerActivity::class.java)
        }
    }

    private fun verificarEstadoGPS() {
        val locationManager = getSystemService(LOCATION_SERVICE) as LocationManager
        if (!locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
            Toast.makeText(this, "ERROR: El GPS está desconectado", Toast.LENGTH_LONG).show()
            tvDireccionGrande.text = "GPS Apagado"
            cargarMapaOSM(latitudActual, longitudActual) // Carga coordenadas por defecto para evitar bloqueo
        } else {
            obtenerCoordenadasReales()
        }
    }

    @SuppressLint("MissingPermission")
    private fun obtenerCoordenadasReales() {
        val fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                if (location != null) {
                    latitudActual = location.latitude
                    longitudActual = location.longitude

                    traducirCoordenadasADireccion(latitudActual, longitudActual)
                    cargarMapaOSM(latitudActual, longitudActual)
                } else {
                    // Si la ubicación es nula de forma temporal, usamos el fallback
                    cargarMapaOSM(latitudActual, longitudActual)
                }
            }
        } else {
            // Solicitar permisos en tiempo de ejecución si no fueron otorgados
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                100
            )
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 100 && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            obtenerCoordenadasReales()
        } else {
            Toast.makeText(this, "Permiso de ubicación denegado", Toast.LENGTH_SHORT).show()
            cargarMapaOSM(latitudActual, longitudActual)
        }
    }

    private fun cargarMapaOSM(lat: Double, lon: Double) {
        val urlOSM = "https://www.openstreetmap.org/#map=16/$lat/$lon"
        mapaWebView.loadUrl(urlOSM)
    }

    private fun traducirCoordenadasADireccion(lat: Double, lon: Double) {
        try {
            val geocoder = Geocoder(this, Locale.getDefault())
            val direcciones = geocoder.getFromLocation(lat, lon, 1)
            if (!direcciones.isNullOrEmpty()) {
                val direccionFisica = direcciones[0].getAddressLine(0)
                tvDireccionGrande.text = direccionFisica
            }
        } catch (e: Exception) {
            tvDireccionGrande.text = "Ubicación: $lat, $lon"
        }
    }

    private fun guardarEnFirestore() {
        val db = FirebaseFirestore.getInstance()
        val direccionTexto = tvDireccionGrande.text.toString()
        val datosUbicacion = mapOf(
            "latitud" to latitudActual,
            "longitud" to longitudActual,
            "referencia" to "Usuario reportando siniestro - Ubicación: $direccionTexto",
            "hora" to System.currentTimeMillis()
        )

        db.collection("LocacionesSiniestros")
            .add(datosUbicacion)
            .addOnSuccessListener {
                Toast.makeText(this, "Ubicación guardada en Firestore", Toast.LENGTH_SHORT).show()
            }
            .addOnFailureListener {
                Toast.makeText(this, "Error al guardar ubicación", Toast.LENGTH_SHORT).show()
            }
    }
}