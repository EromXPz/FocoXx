package dev.productos.productos_app

import android.app.Activity
import android.os.Bundle
import android.graphics.Color
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class BlockActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(36, 36, 36, 36)
            setBackgroundColor(Color.rgb(18, 20, 36))
        }
        root.addView(TextView(this).apply {
            text = "Hora de voltar ao foco"
            textSize = 28f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
        })
        root.addView(TextView(this).apply {
            text = "Você escolheu limitar este aplicativo. Feche-o e retome o que é importante para você."
            textSize = 17f
            setTextColor(Color.LTGRAY)
            gravity = Gravity.CENTER
            setPadding(0, 20, 0, 28)
        })
        root.addView(Button(this).apply {
            text = "Voltar"
            setOnClickListener {
                val home = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(home)
                finish()
            }
        })
        setContentView(root)
    }
}