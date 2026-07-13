package com.clinic.service;

import java.io.File;
import java.nio.charset.StandardCharsets;

/**
 * Service gọi Python để nhận diện u xơ tử cung từ ảnh siêu âm
 */
public class AiPredictionService {

    private static final String PYTHON_COMMAND = "py";

    private static final String PYTHON_SCRIPT =
            "C:\\Users\\admin\\Downloads\\AI_Ultrasound_Fibroid\\predict_for_web.py";

    public String predict(String inputImagePath, String outputDir) throws Exception {
        File dir = new File(outputDir);

        if (!dir.exists()) {
            dir.mkdirs();
        }

        ProcessBuilder processBuilder = new ProcessBuilder(
                PYTHON_COMMAND,
                PYTHON_SCRIPT,
                inputImagePath,
                outputDir
        );

        processBuilder.environment().put("PYTHONIOENCODING", "UTF-8");
        processBuilder.redirectErrorStream(true);

        Process process = processBuilder.start();

        String output = new String(
                process.getInputStream().readAllBytes(),
                StandardCharsets.UTF_8
        );

        int exitCode = process.waitFor();

        if (exitCode != 0) {
            throw new RuntimeException("AI prediction failed: " + output);
        }

        return output;
    }
}
