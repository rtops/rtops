package com.rtops.objectdetector

import android.content.Context
import android.graphics.RectF
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.objects.DetectedObject
import com.google.mlkit.vision.objects.ObjectDetection
import com.google.mlkit.vision.objects.ObjectDetector
import com.google.mlkit.vision.objects.defaults.ObjectDetectorOptions

class ObjectDetectorHelper(
    private val context: Context,
    private val objectDetectorListener: DetectorListener
) {

    private var objectDetector: ObjectDetector? = null

    interface DetectorListener {
        fun onError(error: String)
        fun onResults(
            results: List<DetectedObject>,
            imageHeight: Int,
            imageWidth: Int
        )
    }

    init {
        setupObjectDetector()
    }

    private fun setupObjectDetector() {
        val options = ObjectDetectorOptions.Builder()
            .setDetectorMode(ObjectDetectorOptions.STREAM_MODE)
            .enableMultipleObjects()
            .enableClassification()
            .build()

        objectDetector = ObjectDetection.getClient(options)
    }

    fun detect(imageProxy: ImageProxy) {
        val mediaImage = imageProxy.image
        if (mediaImage != null) {
            val image = InputImage.fromMediaImage(
                mediaImage,
                imageProxy.imageInfo.rotationDegrees
            )

            objectDetector?.process(image)
                ?.addOnSuccessListener { detectedObjects ->
                    objectDetectorListener.onResults(
                        detectedObjects,
                        image.height,
                        image.width
                    )
                    imageProxy.close()
                }
                ?.addOnFailureListener { e ->
                    objectDetectorListener.onError(e.message ?: "Unknown error")
                    imageProxy.close()
                }
        } else {
            imageProxy.close()
        }
    }

    fun clear() {
        objectDetector?.close()
        objectDetector = null
    }
}
