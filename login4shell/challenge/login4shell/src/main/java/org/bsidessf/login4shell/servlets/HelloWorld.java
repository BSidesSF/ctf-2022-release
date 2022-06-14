package org.bsidessf.login4shell.servlets;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import freemarker.template.Template;
import freemarker.template.TemplateException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class HelloWorld extends BaseServlet {

	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Map<String, String> root = new HashMap<>();
		root.put("name", "world");
		sendHtmlTemplate(response, "helloworld.ftlh", root);
	}
}
