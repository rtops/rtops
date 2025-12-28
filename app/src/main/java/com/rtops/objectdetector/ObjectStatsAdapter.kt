package com.rtops.objectdetector

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class ObjectStatsAdapter : RecyclerView.Adapter<ObjectStatsAdapter.ViewHolder>() {

    private var stats = listOf<ObjectStats>()

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val objectLabel: TextView = view.findViewById(R.id.objectLabel)
        val objectCount: TextView = view.findViewById(R.id.objectCount)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_object_stat, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val stat = stats[position]
        holder.objectLabel.text = stat.label
        holder.objectCount.text = "x${stat.count}"
    }

    override fun getItemCount() = stats.size

    fun updateStats(newStats: List<ObjectStats>) {
        stats = newStats
        notifyDataSetChanged()
    }
}
