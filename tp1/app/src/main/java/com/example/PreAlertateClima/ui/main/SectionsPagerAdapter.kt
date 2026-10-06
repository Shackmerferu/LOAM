package com.example.PreAlertateClima.ui.main

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.example.PreAlertateClima.R

private val TAB_TITLES = arrayOf(
        R.string.tab_text_1,
        R.string.tab_text_2
)

/**
 * A [FragmentStateAdapter] that returns a fragment corresponding to
 * one of the sections/tabs/pages.
 */
// Adaptador para gestionar las pestañas de navegación por secciones
class SectionsPagerAdapter(private val context: Context, fa: FragmentActivity)
    : FragmentStateAdapter(fa) {

    // Crear y retornar el fragmento correspondiente a la posición de la pestaña
    override fun createFragment(position: Int): Fragment {
        return PlaceholderFragment.newInstance(position + 1)
    }

    // Retornar el número total de pestañas (páginas)
    override fun getItemCount(): Int {
        return 2
    }

    // Obtener el título correspondiente a cada pestaña
    fun getPageTitle(position: Int): CharSequence? {
        return context.resources.getString(TAB_TITLES[position])
    }
}
