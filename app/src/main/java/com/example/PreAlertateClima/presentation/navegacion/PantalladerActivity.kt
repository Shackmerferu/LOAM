package com.example.PreAlertateClima.presentation.navegacion

import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Bundle
import android.speech.RecognizerIntent
import android.widget.Button
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.PreAlertateClima.R
import com.example.PreAlertateClima.presentation.alertapanico.PanicoAlertaActivity
import com.example.PreAlertateClima.presentation.asistencia.ChatAsistenciaActivity
import com.example.PreAlertateClima.presentation.base.DisasterActivity
import com.example.PreAlertateClima.presentation.bateria.BatteryAdapter
import com.example.PreAlertateClima.presentation.bateria.BatteryModel
import com.example.PreAlertateClima.presentation.comandovoz.VoiceActivity
import com.example.PreAlertateClima.presentation.guide.GuiaCatastrofesActivity
import com.example.PreAlertateClima.presentation.home.MainActivity
import com.example.PreAlertateClima.presentation.location.MapActivity
import com.example.PreAlertateClima.presentation.media.CameraActivity
import com.example.PreAlertateClima.utils.navegarHacia
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class PantalladerActivity : DisasterActivity() {

    private lateinit var rvBateria: RecyclerView

    private val speechLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        if (result.resultCode == RESULT_OK && result.data != null) {
            val matches = result.data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            val spokenText = matches?.firstOrNull()?.lowercase(Locale.getDefault()) ?: ""
            procesarComandoVozDirecto(spokenText)
        }
    }

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

        btnSalir.setOnClickListener { finishAffinity() }
        btnIzq.setOnClickListener { navegarHacia(MapActivity::class.java) }
        btnMedio.setOnClickListener { navegarHacia(MainActivity::class.java) }
        btnDer.setOnClickListener {
            Toast.makeText(this, "Ya te encuentras en esta sección", Toast.LENGTH_SHORT).show()
        }

        // Batería como RecyclerView en la parte superior (Height ~100dp, Width match_parent)
        rvBateria = findViewById(R.id.rvBateria)
        rvBateria.layoutManager = LinearLayoutManager(this)
        cargarRecyclerViewBateria()

        // Botones de Herramientas
        val btnCamara: Button = findViewById(R.id.btn_Camara)
        val btnGrabadora: Button = findViewById(R.id.btn_Grabadora)
        val btnChat: Button = findViewById(R.id.btn_Chat)
        val btnGuia: Button = findViewById(R.id.btn_Guia)
        val btnVoz: Button = findViewById(R.id.btn_Voz)
        val btnPanico: Button = findViewById(R.id.btn_Panico)

        btnCamara.setOnClickListener {
            navegarHacia(CameraActivity::class.java)
        }

        btnGrabadora.setOnClickListener {
            // Pantalla propia para Grabadora de Voz
            navegarHacia(VoiceActivity::class.java)
        }

        btnChat.setOnClickListener {
            navegarHacia(ChatAsistenciaActivity::class.java)
        }

        btnGuia.setOnClickListener {
            navegarHacia(GuiaCatastrofesActivity::class.java)
        }

        btnVoz.setOnClickListener {
            // Toast de aviso y activación directa del reconocimiento de voz de Google
            iniciarComandoVozDirecto()
        }

        btnPanico.setOnClickListener {
            navegarHacia(PanicoAlertaActivity::class.java)
        }
    }

    private fun cargarRecyclerViewBateria() {
        val batteryStatus: Intent? = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1

        val pct = if (level != -1 && scale != -1) (level * 100 / scale.toFloat()).toInt() else 50

        val minutosRestantes = pct * 5
        val horas = minutosRestantes / 60
        val mins = minutosRestantes % 60

        val horaApagadoMs = System.currentTimeMillis() + (minutosRestantes * 60 * 1000L)
        val horaApagadoStr = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(horaApagadoMs))

        val batteryItem = BatteryModel(
            percentageText = "🔋 Batería: $pct%",
            timeEstimateText = "Tiempo estimado restante: ${horas}h ${mins}m (Apagado aprox: $horaApagadoStr hs)"
        )

        rvBateria.adapter = BatteryAdapter(listOf(batteryItem))
    }

    private fun iniciarComandoVozDirecto() {
        Toast.makeText(this, "Reconocimiento de voz de Google activo, podés hablar...", Toast.LENGTH_LONG).show()

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "es-ES")
            putExtra(RecognizerIntent.EXTRA_PROMPT, "Di 'camara' para abrir la cámara o 'tomar foto' para sacar foto")
        }

        try {
            speechLauncher.launch(intent)
        } catch (e: Exception) {
            Toast.makeText(this, "El servicio de reconocimiento de voz de Google no está disponible", Toast.LENGTH_SHORT).show()
        }
    }

    private fun procesarComandoVozDirecto(comando: String) {
        when {
            comando.contains("camara") || comando.contains("cámara") || comando.contains("abrir camara") -> {
                Toast.makeText(this, "Abriendo cámara por voz...", Toast.LENGTH_SHORT).show()
                val intent = Intent(this, CameraActivity::class.java)
                startActivity(intent)
            }
            comando.contains("foto") || comando.contains("tomar foto") || comando.contains("sacar foto") -> {
                Toast.makeText(this, "Tomando foto por voz...", Toast.LENGTH_SHORT).show()
                val intent = Intent(this, CameraActivity::class.java).apply {
                    putExtra("AUTO_TAKE_PHOTO", true)
                }
                startActivity(intent)
            }
            else -> {
                Toast.makeText(this, "Comando no reconocido: \"$comando\". Di 'abrir camara' o 'tomar foto'", Toast.LENGTH_LONG).show()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        cargarRecyclerViewBateria()
    }
}
