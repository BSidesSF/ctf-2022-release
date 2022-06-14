package org.bsidessf.login4shell.servlets;

import java.io.IOException;
import java.util.Map;
import java.util.regex.Pattern;

import org.bsidessf.login4shell.UserManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class LoginHandler extends BaseServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(LoginHandler.class);
	private static final Pattern allowedUsernames = Pattern.compile("\\A[a-z0-9]+\\z");
	
	public static final String TEMPLATE_NAME = "login.ftlh";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		sendHtmlTemplate(response, TEMPLATE_NAME, buildBaseRoot(request));
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		if (username == null || password == null || username.equals("") || password.equals("")) {
			sendError(request, response, "Username and password are required!");
			return;
		}
		if (!allowedUsernames.matcher(username).matches()) {
			sendError(request, response, "Username must be lowercase alphanumeric!");
			return;
		}
		if (UserManager.verifyUserPassword(username, password)) {
			UserManager.setCookieForUser(response, username);
			response.sendRedirect("/");
			logger.info("User {} logged in successfully.", UserManager.getBaseUsername(username));
			return;
		}
		sendError(request, response, "Invalid username or password");
	}
	
	private void sendError(HttpServletRequest request, HttpServletResponse response, String error) {
		Map<String, Object> error_map = buildBaseRoot(request);
		error_map.put("error", error);
		sendHtmlTemplate(response, TEMPLATE_NAME, error_map);
	}
}
