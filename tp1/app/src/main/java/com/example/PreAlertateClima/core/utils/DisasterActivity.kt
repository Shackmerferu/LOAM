package com.example.PreAlertateClima.presentation.base

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.example.PreAlertateClima.presentation.desastre.DesastreAlertaActivity
import com.google.firebase.firestore.DocumentChange
import com.google.firebase.firestore.FirebaseFirestore

// Actividad base para escuchar catástrofes en tiempo real desde Firebase en toda la app
open class DisasterActivity : AppCompatActivity() {

    // Instancia de Firestore para consultas globales
    protected lateinit var db: FirebaseFirestore

    companion object {
        // Bandera global para saber si ya se disparó una alerta de desastre
        var isDisasterTriggeredGlobal = false
        // Bandera para evitar inicializar múltiples escuchadores de Firebase
        private var isListenerInitialized = false
        // Bandera para ignorar el primer snapshot inicial de Firestore
        private var isFirstSnapshotReceived = false

        // Función para iniciar el escuchador global de catástrofes en Firestore
        fun iniciarEscuchadorGlobal(context: Context) {
            if (isListenerInitialized) return
            isListenerInitialized = true

            try {
                val db = FirebaseFirestore.getInstance()
                db.collection("catastrofes")
                    .addSnapshotListener { snapshot, error ->
                        if (error != null) {
                            Log.e("DisasterActivity", "Error al escuchar catastrofes: ${error.message}")
                            return@addSnapshotListener
                        }

                        if (snapshot != null) {
                            // Ignorar el snapshot inicial que contiene datos pasados/viejos
                            if (!isFirstSnapshotReceived) {
                                isFirstSnapshotReceived = true
                                Log.d("DisasterActivity", "Escuchador de catástrofes activo (datos pasados ignorados).")
                                return@addSnapshotListener
                            }

                            // Reaccionar únicamente si la base de datos es actualizada o se agrega un registro en tiempo real
                            // Módulo lógico-condicional ante la actualización
                            if (!isDisasterTriggeredGlobal) {
                                for (change in snapshot.documentChanges) {
                                    if (change.type == DocumentChange.Type.ADDED || change.type == DocumentChange.Type.MODIFIED) {
                                        val doc = change.document
                                        val docActivo = doc.getBoolean("activo") ?: true
                                        if (docActivo) {
                                            isDisasterTriggeredGlobal = true
                                            Log.d("DisasterActivity", "¡Base de datos actualizada! Catástrofe en tiempo real: ${doc.id}")
                                            activarAlertaCatastrofeGlobal(context)
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        // Activar y pasar a pantalla de catástrofe, superponiéndose sobre las demás
        private fun activarAlertaCatastrofeGlobal(context: Context) {
            try {
                val intent = Intent(context, DesastreAlertaActivity::class.java)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                context.startActivity(intent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            db = FirebaseFirestore.getInstance()
            iniciarEscuchadorGlobal(applicationContext)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
