package com.example.PreAlertateClima.ui.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment

// Fragmento temporal o de comodín para secciones y pestañas
class PlaceholderFragment : Fragment() {
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return null
    }

    companion object {
        // Función fábrica para crear una nueva instancia del fragmento con el número de sección
        fun newInstance(sectionNumber: Int): PlaceholderFragment {
            return PlaceholderFragment().apply {
                arguments = Bundle().apply {
                    putInt("section_number", sectionNumber)
                }
            }
        }
    }
}
