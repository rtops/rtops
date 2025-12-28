package com.rtops.objectdetector

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.mlkit.vision.objects.DetectedObject
import android.widget.Button
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : AppCompatActivity(), ObjectDetectorHelper.DetectorListener {

    private lateinit var previewView: PreviewView
    private lateinit var graphicOverlay: GraphicOverlay
    private lateinit var statsRecyclerView: RecyclerView
    private lateinit var clearButton: Button
    private lateinit var statsAdapter: ObjectStatsAdapter

    private var preview: Preview? = null
    private var imageAnalyzer: ImageAnalysis? = null
    private var camera: Camera? = null
    private var cameraProvider: ProcessCameraProvider? = null

    private lateinit var objectDetectorHelper: ObjectDetectorHelper
    private val objectTracker = ObjectTracker()
    private lateinit var cameraExecutor: ExecutorService

    companion object {
        private const val TAG = "ObjectDetector"
        private const val REQUEST_CODE_PERMISSIONS = 10
        private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        previewView = findViewById(R.id.previewView)
        graphicOverlay = findViewById(R.id.graphicOverlay)
        statsRecyclerView = findViewById(R.id.statsRecyclerView)
        clearButton = findViewById(R.id.clearButton)

        setupRecyclerView()
        setupButtons()

        cameraExecutor = Executors.newSingleThreadExecutor()
        objectDetectorHelper = ObjectDetectorHelper(this, this)

        if (allPermissionsGranted()) {
            startCamera()
        } else {
            ActivityCompat.requestPermissions(
                this,
                REQUIRED_PERMISSIONS,
                REQUEST_CODE_PERMISSIONS
            )
        }
    }

    private fun setupRecyclerView() {
        statsAdapter = ObjectStatsAdapter()
        statsRecyclerView.apply {
            layoutManager = LinearLayoutManager(this@MainActivity)
            adapter = statsAdapter
        }
    }

    private fun setupButtons() {
        clearButton.setOnClickListener {
            objectTracker.clear()
            updateStats()
            Toast.makeText(this, "Statistik rensad", Toast.LENGTH_SHORT).show()
        }
    }

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)

        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()
            bindCameraUseCases()
        }, ContextCompat.getMainExecutor(this))
    }

    private fun bindCameraUseCases() {
        val cameraProvider = cameraProvider
            ?: throw IllegalStateException("Camera initialization failed.")

        val cameraSelector = CameraSelector.Builder()
            .requireLensFacing(CameraSelector.LENS_FACING_BACK)
            .build()

        preview = Preview.Builder()
            .setTargetAspectRatio(AspectRatio.RATIO_4_3)
            .setTargetRotation(previewView.display.rotation)
            .build()

        imageAnalyzer = ImageAnalysis.Builder()
            .setTargetAspectRatio(AspectRatio.RATIO_4_3)
            .setTargetRotation(previewView.display.rotation)
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
            .build()
            .also {
                it.setAnalyzer(cameraExecutor) { imageProxy ->
                    objectDetectorHelper.detect(imageProxy)
                }
            }

        cameraProvider.unbindAll()

        try {
            camera = cameraProvider.bindToLifecycle(
                this,
                cameraSelector,
                preview,
                imageAnalyzer
            )

            preview?.setSurfaceProvider(previewView.surfaceProvider)
        } catch (exc: Exception) {
            Log.e(TAG, "Use case binding failed", exc)
        }
    }

    override fun onError(error: String) {
        runOnUiThread {
            Log.e(TAG, "Object detection error: $error")
        }
    }

    override fun onResults(
        results: List<DetectedObject>,
        imageHeight: Int,
        imageWidth: Int
    ) {
        runOnUiThread {
            graphicOverlay.clear()
            graphicOverlay.setImageSourceInfo(imageWidth, imageHeight)

            results.forEach { detectedObject ->
                val labels = detectedObject.labels.map { label ->
                    val confidence = (label.confidence * 100).toInt()
                    "${label.text} ($confidence%)"
                }

                // Track objects
                if (detectedObject.labels.isNotEmpty()) {
                    val primaryLabel = detectedObject.labels.first()
                    objectTracker.trackObject(primaryLabel.text, primaryLabel.confidence)
                }

                // Draw detection box
                val graphic = ObjectGraphic(
                    graphicOverlay,
                    labels,
                    detectedObject.boundingBox,
                    imageHeight,
                    imageWidth
                )
                graphicOverlay.add(graphic)
            }

            graphicOverlay.invalidate()
            updateStats()
        }
    }

    private fun updateStats() {
        val stats = objectTracker.getObjectStats()
        statsAdapter.updateStats(stats)
    }

    private fun allPermissionsGranted() = REQUIRED_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(baseContext, it) == PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_PERMISSIONS) {
            if (allPermissionsGranted()) {
                startCamera()
            } else {
                Toast.makeText(
                    this,
                    getString(R.string.camera_permission_required),
                    Toast.LENGTH_SHORT
                ).show()
                finish()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
        objectDetectorHelper.clear()
    }
}
