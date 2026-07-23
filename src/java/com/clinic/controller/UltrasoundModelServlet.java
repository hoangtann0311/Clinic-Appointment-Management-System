package com.clinic.controller;

import com.clinic.config.AppConfig;
import com.clinic.dao.AiAnalysisResultDAO;
import com.clinic.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;

/**
 * Hồ sơ chỉ đọc của mô hình AI đang được tích hợp trong luồng siêu âm.
 */
@WebServlet("/sonographer/ai-model")
public class UltrasoundModelServlet extends HttpServlet {

    private final AiAnalysisResultDAO aiAnalysisResultDAO = new AiAnalysisResultDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() != 6) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("errorTitle", "Truy Cập Bị Từ Chối");
            request.setAttribute("errorDetail",
                    "Chỉ Bác sĩ siêu âm được xem hồ sơ mô hình AI.");
            request.getRequestDispatcher("/views/errors/403.jsp").forward(request, response);
            return;
        }

        String scriptPath = AppConfig.getAiPythonScript();
        File scriptFile = scriptPath == null || scriptPath.isBlank()
                ? null : new File(scriptPath);

        request.setAttribute("modelName",
                AppConfig.get("ai.model.name", "CAMS Fibroid Hybrid"));
        request.setAttribute("modelVersion",
                AppConfig.get("ai.model.version", "CAMS-FIBROID-HYBRID-v1.0"));
        request.setAttribute("trainingRunId",
                AppConfig.get("ai.model.trainingRunId", "UNET-APPROVED-37"));
        request.setAttribute("trainingDate",
                AppConfig.get("ai.model.trainingDate", "Hồ sơ huấn luyện hiện hành"));
        request.setAttribute("inferenceScript",
                scriptFile == null ? "predict_for_web.py" : scriptFile.getName());
        request.setAttribute("runtimeReady",
                scriptFile != null && scriptFile.isFile());
        request.setAttribute("processTimeoutSeconds",
                Math.max(1L, AppConfig.getAiProcessTimeout() / 1000L));
        request.setAttribute("usageStats",
                aiAnalysisResultDAO.getModelUsageStats());

        request.getRequestDispatcher("/views/sonographer/ai-model.jsp")
                .forward(request, response);
    }
}
