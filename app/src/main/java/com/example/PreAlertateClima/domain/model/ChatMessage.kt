package com.example.PreAlertateClima.domain.model

import com.google.firebase.Timestamp

data class ChatMessage(
    var id: String = "",
    var remitente: String = "",
    var mensaje: String = "",
    var timestamp: Timestamp? = null
)