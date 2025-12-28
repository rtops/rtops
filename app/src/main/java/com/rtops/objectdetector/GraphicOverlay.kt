package com.rtops.objectdetector

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.util.AttributeSet
import android.view.View

class GraphicOverlay(context: Context, attrs: AttributeSet?) : View(context, attrs) {

    private val lock = Any()
    private val graphics = mutableListOf<Graphic>()

    private var imageWidth = 0
    private var imageHeight = 0
    private var scaleFactor = 1.0f
    private var postScaleWidthOffset = 0f
    private var postScaleHeightOffset = 0f

    abstract class Graphic(private val overlay: GraphicOverlay) {
        abstract fun draw(canvas: Canvas)

        fun calculateRect(height: Float, width: Float, boundingBoxT: RectF): RectF {
            val scaleX = overlay.width.toFloat() / width
            val scaleY = overlay.height.toFloat() / height
            val scale = scaleX.coerceAtLeast(scaleY)

            overlay.scaleFactor = scale

            val offsetX = (overlay.width.toFloat() - width * scale) / 2.0f
            val offsetY = (overlay.height.toFloat() - height * scale) / 2.0f

            val mappedBox = RectF().apply {
                left = boundingBoxT.left * scale + offsetX
                top = boundingBoxT.top * scale + offsetY
                right = boundingBoxT.right * scale + offsetX
                bottom = boundingBoxT.bottom * scale + offsetY
            }

            return mappedBox
        }
    }

    fun clear() {
        synchronized(lock) {
            graphics.clear()
        }
        postInvalidate()
    }

    fun add(graphic: Graphic) {
        synchronized(lock) {
            graphics.add(graphic)
        }
    }

    fun setImageSourceInfo(imageWidth: Int, imageHeight: Int) {
        this.imageWidth = imageWidth
        this.imageHeight = imageHeight
        postInvalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        synchronized(lock) {
            for (graphic in graphics) {
                graphic.draw(canvas)
            }
        }
    }
}

class ObjectGraphic(
    private val overlay: GraphicOverlay,
    private val labels: List<String>,
    private val boundingBox: RectF,
    private val imageHeight: Int,
    private val imageWidth: Int
) : GraphicOverlay.Graphic(overlay) {

    private val boxPaint = Paint().apply {
        color = Color.GREEN
        style = Paint.Style.STROKE
        strokeWidth = 5.0f
    }

    private val textPaint = Paint().apply {
        color = Color.GREEN
        textSize = 40.0f
        style = Paint.Style.FILL
    }

    private val backgroundPaint = Paint().apply {
        color = Color.BLACK
        alpha = 128
        style = Paint.Style.FILL
    }

    override fun draw(canvas: Canvas) {
        val rect = calculateRect(
            imageHeight.toFloat(),
            imageWidth.toFloat(),
            boundingBox
        )

        canvas.drawRect(rect, boxPaint)

        if (labels.isNotEmpty()) {
            val label = labels.first()
            val textWidth = textPaint.measureText(label)
            val textHeight = textPaint.textSize

            canvas.drawRect(
                rect.left,
                rect.top - textHeight - 10,
                rect.left + textWidth + 10,
                rect.top,
                backgroundPaint
            )

            canvas.drawText(
                label,
                rect.left + 5,
                rect.top - 5,
                textPaint
            )
        }
    }
}
