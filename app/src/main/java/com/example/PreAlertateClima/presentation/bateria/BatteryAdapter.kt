package com.example.PreAlertateClima.presentation.bateria

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.PreAlertateClima.R

data class BatteryModel(
    val percentageText: String,
    val timeEstimateText: String
)

class BatteryAdapter(
    private val batteryList: List<BatteryModel>
) : RecyclerView.Adapter<BatteryAdapter.BatteryViewHolder>() {

    class BatteryViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val tvBatteryPercentage: TextView = itemView.findViewById(R.id.tvBatteryPercentage)
        val tvBatteryTime: TextView = itemView.findViewById(R.id.tvBatteryTime)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BatteryViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_battery, parent, false)
        return BatteryViewHolder(view)
    }

    override fun onBindViewHolder(holder: BatteryViewHolder, position: Int) {
        val item = batteryList[position]
        holder.tvBatteryPercentage.text = item.percentageText
        holder.tvBatteryTime.text = item.timeEstimateText
    }

    override fun getItemCount(): Int = batteryList.size
}
