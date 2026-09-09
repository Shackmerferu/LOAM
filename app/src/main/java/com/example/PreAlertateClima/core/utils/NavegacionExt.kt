package com.example.PreAlertateClima.utils

import android.app.Activity
import android.content.Intent

fun Activity.navegarHacia(claseDestino: Class<*>) {
    val intento = Intent(this, claseDestino)
    startActivity(intento)
    finish()
}