package com.example.PreAlertateClima.domain.model

import com.google.firebase.Timestamp

// Modelo de datos para los mensajes del chat de asistencia
data class ChatMessage(
    var id: String = "",
    var remitente: String = "",
    var mensaje: String = "",
    var timestamp: Timestamp? = null
)