package com.example.PreAlertateClima.domain.repository

import com.example.PreAlertateClima.domain.model.Emergencia
import kotlinx.coroutines.flow.Flow
interface EmergenciaRepository {
    fun getEmergencies(): Flow<List<Emergencia>>
}