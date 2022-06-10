package org.bsidessf.login4shell.servlets;

import java.io.IOException;
import java.util.Map;

import org.bsidessf.login4shell.UserManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class FlagHandler extends BaseServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(FlagHandler.class);

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String username = UserManager.getUserForRequest(request);
		if (username == null) {
			response.sendRedirect("/login");
			return;
		}
		logger.info("Attempt by {} to get the flag!", username);
		Map<String, Object> root = buildBaseRoot(request);
		sendHtmlTemplate(response, "flag.ftlh", root);
	}
}
