package org.bsidessf.login4shell.servlets;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.bsidessf.login4shell.TemplateConfiguration;
import org.bsidessf.login4shell.UserManager;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class BaseServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected Map<String, Object> buildBaseRoot(HttpServletRequest request) {
		Map<String, Object> rv = new HashMap<>();
		String whoami = UserManager.getUserForRequest(request);
		if (whoami != null) {
			rv.put("username", whoami);
			rv.put("loggedin", true);
		} else {
			rv.put("loggedin", false);
		}
		return rv;
	}

	protected Configuration getTemplateConfiguration() {
		try {
			return TemplateConfiguration.getConfig();
		} catch (Exception ex) {
			return null;
		}
	}
	
	protected void sendHtmlTemplate(HttpServletResponse response, String template, Object data) {
		sendHtmlTemplate(response, HttpServletResponse.SC_OK, template, data);
	}
	
	protected void sendHtmlTemplate(HttpServletResponse response, int code, String template, Object data) {
		response.setContentType("text/html");
		response.setStatus(code);
		try {
			Template temp = getTemplateConfiguration().getTemplate(template);
			temp.process(data, response.getWriter());
		} catch (TemplateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
