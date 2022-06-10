package org.bsidessf.login4shell.servlets;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

import org.bsidessf.login4shell.UserManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RegisterHandler extends BaseServlet {

	private static final long serialVersionUID = 1L;
	private static final Pattern allowedUsernames = Pattern.compile("\\A[a-z0-9]+\\z");
	
	public static final String TEMPLATE_NAME = "register.ftlh";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		sendHtmlTemplate(response, TEMPLATE_NAME, buildBaseRoot(request));
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String username = request.getParameter("username");
		if (username == null || username.equals("")) {
			sendError(request, response, "Username is required!");
			return;
		}
		if (!allowedUsernames.matcher(username).matches()) {
			sendError(request, response, "Username must be lowercase alphanumeric!");
			return;
		}
		String password = UserManager.getPasswordForUser(username);
		Map<String, Object> success_map = buildBaseRoot(request);
		success_map.put("password", password);
		success_map.put("success", "Successfully registered!");
		sendHtmlTemplate(response, TEMPLATE_NAME, success_map);
	}
	
	private void sendError(HttpServletRequest request, HttpServletResponse response, String error) {
		Map<String, Object> error_map = buildBaseRoot(request);
		error_map.put("error", error);
		sendHtmlTemplate(response, TEMPLATE_NAME, error_map);
	}
}
