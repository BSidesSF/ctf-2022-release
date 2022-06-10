package org.bsidessf.login4shell.servlets;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class HomeHandler extends BaseServlet {

	private static final long serialVersionUID = 1L;

	public static final String TEMPLATE_NAME = "home.ftlh";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		sendHtmlTemplate(response, TEMPLATE_NAME, buildBaseRoot(request));
	}
}
