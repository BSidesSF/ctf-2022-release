package org.bsidessf.login4shell;

import freemarker.cache.ClassTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.TemplateExceptionHandler;

public class TemplateConfiguration {
	private static boolean isConfigured = false;
	private static final Configuration configSingleton = new Configuration(Configuration.VERSION_2_3_31);
	
	public static void setup() {
		configSingleton.setTemplateLoader(new ClassTemplateLoader(TemplateConfiguration.class, "templates"));
		configSingleton.setWrapUncheckedExceptions(true);
		configSingleton.setTemplateExceptionHandler(TemplateExceptionHandler.HTML_DEBUG_HANDLER);
		configSingleton.setLogTemplateExceptions(true);
		configSingleton.setDefaultEncoding("UTF-8");
		isConfigured = true;
	}
	
	public static Configuration getConfig() throws Exception {
		if (!isConfigured) {
			throw new Exception("Unconfigured template configuration!");
		}
		return configSingleton;
	}
}
