package com.example.PreAlertateClima.presentation.navegacion

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.PreAlertateClima.R

data class Emergencia(val nombre: String, val numero: String)

class EmergenciesAdapter(
    private val emergenciasList: List<Emergencia>,
    private val onNumberClick: (String) -> Unit
) : RecyclerView.Adapter<EmergenciesAdapter.EmergenciaViewHolder>() {

    class EmergenciaViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val tvNombre: TextView = itemView.findViewById(R.id.tvNombreInstitucion)
        val tvNumero: TextView = itemView.findViewById(R.id.tvNumero)
        val btnLlamar: ImageView = itemView.findViewById(R.id.btnLlamar)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): EmergenciaViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_emergency, parent, false)
        return EmergenciaViewHolder(view)
    }

    override fun onBindViewHolder(holder: EmergenciaViewHolder, position: Int) {
        val emergencia = emergenciasList[position]
        holder.tvNombre.text = emergencia.nombre
        holder.tvNumero.text = emergencia.numero

        val clickListener = View.OnClickListener {
            onNumberClick(emergencia.numero)
        }
        
        holder.itemView.setOnClickListener(clickListener)
        holder.tvNumero.setOnClickListener(clickListener)
        holder.btnLlamar.setOnClickListener(clickListener)
    }

    override fun getItemCount(): Int = emergenciasList.size
}
