package com.example.PreAlertateClima.ui.main

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.map

// ViewModel para gestionar las páginas y secciones de la interfaz
class PageViewModel : ViewModel() {

    // Variable mutable para almacenar el índice de la sección actual
    private val _index = MutableLiveData<Int>()
    
    // LiveData pública con el texto formateado según la sección
    val text: LiveData<String> = _index.map {
        "Hello world from section: $it"
    }

    // Función para actualizar el índice de la sección
    fun setIndex(index: Int) {
        _index.value = index
    }
}
