package com.example.PreAlertateClima

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.webkit.WebView
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.pantalla_inicio)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }
        val btn_salir : Button = findViewById(R.id.btn_salir)
        btn_salir.setOnClickListener {
            finishAffinity() //cierra todas las activitos y la aplicación
        }

        val btnDerecha = findViewById<Button>(R.id.derecha)
        btnDerecha.setOnClickListener {
            val intento = Intent(this, PantalladerActivity::class.java)
            startActivity(intento)
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
    }
}