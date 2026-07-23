package com.clinic.service;

import com.clinic.config.AppConfig;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeUnit;

/**
 * Service gọi Python để nhận diện u xơ tử cung từ ảnh siêu âm
 */
public class AiPredictionService {

    public String predict(String inputImagePath, String outputDir) throws Exception {
        File dir = new File(outputDir);
        if (!dir.exists() && !dir.mkdirs()) throw new IllegalStateException("Không tạo được thư mục kết quả AI.");
        String scriptPath = AppConfig.getAiPythonScript();
        if (scriptPath.isBlank() || !new File(scriptPath).isFile()) {
            throw new IllegalStateException("Chưa cấu hình đúng ai.python.script.");
        }

        ProcessBuilder processBuilder = new ProcessBuilder(
                AppConfig.getAiPythonCommand(),
                scriptPath,
                inputImagePath,
                outputDir
        );

        processBuilder.environment().put("PYTHONIOENCODING", "UTF-8");
        processBuilder.redirectErrorStream(true);

        Process process = processBuilder.start();

        boolean completed = process.waitFor(AppConfig.getAiProcessTimeout(), TimeUnit.MILLISECONDS);
        if (!completed) {
            process.destroyForcibly();
            throw new RuntimeException("AI prediction timed out.");
        }
        String output = new String(process.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        int exitCode = process.exitValue();

        if (exitCode != 0) {
            throw new RuntimeException("AI prediction failed: " + output);
        }

        return output;
    }
}
