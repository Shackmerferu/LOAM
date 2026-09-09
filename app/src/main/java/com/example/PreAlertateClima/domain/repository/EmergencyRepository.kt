package com.example.PreAlertateClima.domain.repository

import com.example.PreAlertateClima.domain.model.Emergency
import kotlinx.coroutines.flow.Flow
interface EmergencyRepository {
    fun getEmergencies(): Flow<List<Emergency>>
}