package com.example.PreAlertateClima.domain.repository

import com.example.PreAlertateClima.domain.model.Emergency
import kotlinx.coroutines.flow.Flow

// Repositorio para la obtención de datos de emergencias
interface EmergencyRepository {
    // Función que retorna un Flow con la lista de emergencias
    fun getEmergencies(): Flow<List<Emergency>>
}
