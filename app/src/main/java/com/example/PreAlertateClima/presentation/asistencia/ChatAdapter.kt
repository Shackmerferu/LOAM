package com.example.PreAlertateClima.presentation.asistencia

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.PreAlertateClima.R
import com.example.PreAlertateClima.domain.model.ChatMessage
import java.text.SimpleDateFormat
import java.util.Locale

// Adaptador para mostrar los mensajes de chat en el RecyclerView
class ChatAdapter(
    private val messages: MutableList<ChatMessage> = mutableListOf()
) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    
    // Tipos de vista para distinguir entre mensajes del usuario y del representante
    companion object {
        private const val VIEW_TYPE_USER = 1
        private const val VIEW_TYPE_REP = 2
    }

    // Función para actualizar la lista de mensajes en tiempo real
    fun setMessages(newMessages: List<ChatMessage>) {
        messages.clear()
        messages.addAll(newMessages)
        notifyDataSetChanged()
    }

    // Determinar el tipo de vista según el remitente del mensaje
    override fun getItemViewType(position: Int): Int {
        val msg = messages[position]
        return if (msg.remitente.equals("Usuario", ignoreCase = true) || msg.remitente.isBlank()) {
            VIEW_TYPE_USER
        } else {
            VIEW_TYPE_REP
        }
    }

    // Crear el ViewHolder correspondiente (usuario o representante)
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        return if (viewType == VIEW_TYPE_USER) {
            val view = inflater.inflate(R.layout.item_chat_user, parent, false)
            UserViewHolder(view)
        } else {
            val view = inflater.inflate(R.layout.item_chat_representative, parent, false)
            RepViewHolder(view)
        }
    }

    // Vincular los datos del mensaje con las vistas del ViewHolder
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val message = messages[position]
        val formattedTime = message.timestamp?.toDate()?.let {
            SimpleDateFormat("HH:mm", Locale.getDefault()).format(it)
        } ?: ""

        if (holder is UserViewHolder) {
            holder.tvMessage.text = message.mensaje
            holder.tvTime.text = formattedTime
        } else if (holder is RepViewHolder) {
            holder.tvSender.text = if (message.remitente.isNotBlank()) message.remitente else "Representante"
            holder.tvMessage.text = message.mensaje
            holder.tvTime.text = formattedTime
        }
    }

    // Retornar la cantidad total de mensajes
    override fun getItemCount(): Int = messages.size

    // ViewHolder para mensajes enviados por el usuario
    class UserViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val tvMessage: TextView = itemView.findViewById(R.id.tvMessageUser)
        val tvTime: TextView = itemView.findViewById(R.id.tvTimeUser)
    }

    // ViewHolder para mensajes enviados por el representante
    class RepViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val tvSender: TextView = itemView.findViewById(R.id.tvSenderName)
        val tvMessage: TextView = itemView.findViewById(R.id.tvMessageRep)
        val tvTime: TextView = itemView.findViewById(R.id.tvTimeRep)
    }
}
