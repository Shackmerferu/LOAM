package com.example.PreAlertateClima.presentation.asistencia

import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.PreAlertateClima.R
import com.example.PreAlertateClima.domain.model.ChatMessage
import com.example.PreAlertateClima.presentation.home.MainActivity
import com.example.PreAlertateClima.presentation.location.MapActivity
import com.example.PreAlertateClima.presentation.navegacion.PantalladerActivity
import com.example.PreAlertateClima.utils.navegarHacia
import com.google.firebase.Timestamp
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query

class ChatAsistenciaActivity : AppCompatActivity() {

    private lateinit var rvChat: RecyclerView
    private lateinit var etMensaje: EditText
    private lateinit var btnEnviar: Button
    private lateinit var chatAdapter: ChatAdapter
    private lateinit var db: FirebaseFirestore

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_chat_asistencia)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        db = FirebaseFirestore.getInstance()

        // Vistas
        rvChat = findViewById(R.id.rvChat)
        etMensaje = findViewById(R.id.etMensaje)
        btnEnviar = findViewById(R.id.btnEnviar)

        // Adapter y LayoutManager
        val layoutManager = LinearLayoutManager(this)
        layoutManager.stackFromEnd = true
        rvChat.layoutManager = layoutManager
        chatAdapter = ChatAdapter()
        rvChat.adapter = chatAdapter

        // Escuchar mensajes en tiempo real desde Firestore
        escucharMensajes()

        // Botón Enviar
        btnEnviar.setOnClickListener {
            enviarMensaje()
        }

        // Navegación
        val btnSalir: Button = findViewById(R.id.btn_salir)
        val btnIzq: Button = findViewById(R.id.btn_izq)
        val btnMedio: Button = findViewById(R.id.btn_medio)
        val btnDer: Button = findViewById(R.id.btn_der)

        btnSalir.setOnClickListener { finishAffinity() }
        btnIzq.setOnClickListener { navegarHacia(MapActivity::class.java) }
        btnMedio.setOnClickListener { navegarHacia(MainActivity::class.java) }
        btnDer.setOnClickListener { navegarHacia(PantalladerActivity::class.java) }
    }

    private fun escucharMensajes() {
        try {
            db.collection("chat_asistencia")
                .orderBy("timestamp", Query.Direction.ASCENDING)
                .addSnapshotListener { snapshot, error ->
                    if (error != null) {
                        Log.e("ChatAsistencia", "Error al escuchar mensajes: ${error.message}")
                        return@addSnapshotListener
                    }

                    if (snapshot != null) {
                        val listaMensajes = mutableListOf<ChatMessage>()
                        for (doc in snapshot.documents) {
                            val msg = doc.toObject(ChatMessage::class.java)
                            if (msg != null) {
                                msg.id = doc.id
                                listaMensajes.add(msg)
                            }
                        }
                        chatAdapter.setMessages(listaMensajes)
                        if (listaMensajes.isNotEmpty()) {
                            rvChat.smoothScrollToPosition(listaMensajes.size - 1)
                        }
                    }
                }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun enviarMensaje() {
        val texto = etMensaje.text.toString().trim()
        if (texto.isEmpty()) {
            Toast.makeText(this, "Escribe un mensaje antes de enviar", Toast.LENGTH_SHORT).show()
            return
        }

        val datosMensaje = hashMapOf(
            "remitente" to "Usuario",
            "mensaje" to texto,
            "timestamp" to Timestamp.now()
        )

        db.collection("chat_asistencia")
            .add(datosMensaje)
            .addOnSuccessListener {
                etMensaje.text.clear()
            }
            .addOnFailureListener { e ->
                Log.e("ChatAsistencia", "Error al enviar mensaje: ${e.message}")
            }
    }
}
