package org.bsidessf.login4shell;

import org.eclipse.jetty.server.CustomRequestLog;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.HttpConfiguration;
import org.eclipse.jetty.server.HttpConnectionFactory;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.ServerConnector;
import org.eclipse.jetty.server.Slf4jRequestLogWriter;
import org.eclipse.jetty.server.handler.ContextHandler;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.server.handler.ResourceHandler;
import org.eclipse.jetty.servlet.ServletHandler;
import org.eclipse.jetty.util.resource.Resource;
import org.bsidessf.login4shell.servlets.FlagHandler;
import org.bsidessf.login4shell.servlets.HelloWorld;
import org.bsidessf.login4shell.servlets.HomeHandler;
import org.bsidessf.login4shell.servlets.LoginHandler;
import org.bsidessf.login4shell.servlets.LogoutHandler;
import org.bsidessf.login4shell.servlets.RegisterHandler;

public class ServerMain {

  private final static int PORT = 8123;

	public static void main(String[] args) throws Exception {
		Server serverInstance = new Server(PORT);

		HttpConfiguration config = new HttpConfiguration();
		config.setRelativeRedirectAllowed(true);
		config.addCustomizer(new org.eclipse.jetty.server.ForwardedRequestCustomizer());
		HttpConnectionFactory connectionFactory = new HttpConnectionFactory(config);
    ServerConnector connector = new ServerConnector(serverInstance, connectionFactory);
    connector.setPort(PORT);
    serverInstance.setConnectors(new ServerConnector[]{connector});
		
		ServletHandler shandler = new ServletHandler();
		shandler.setEnsureDefaultServlet(false);
		shandler.addServletWithMapping(HelloWorld.class, "/hello");
		shandler.addServletWithMapping(HomeHandler.class, "/");
		shandler.addServletWithMapping(LoginHandler.class, "/login");
		shandler.addServletWithMapping(RegisterHandler.class, "/register");
		shandler.addServletWithMapping(LogoutHandler.class, "/logout");
		shandler.addServletWithMapping(FlagHandler.class, "/flag");
		
		ResourceHandler rh = new ResourceHandler();
		rh.setDirAllowed(true);
		rh.setBaseResource(Resource.newClassPathResource("org/bsidessf/login4shell/static"));
		ContextHandler ctxhandler = new ContextHandler("/static");
		ctxhandler.setHandler(rh);
		
		HandlerList handlers = new HandlerList();
		handlers.setHandlers(new Handler[] {ctxhandler, shandler});
		serverInstance.setHandler(handlers);
		TemplateConfiguration.setup();
		
		// Logging config?
		Slf4jRequestLogWriter logWriter = new SafeRequestLogWriter();
		logWriter.setLoggerName("requestlog");
		CustomRequestLog logger = new CustomRequestLog(logWriter, "%{client}a %t %m %U %s %R");
		serverInstance.setRequestLog(logger);
		
		serverInstance.start();
		serverInstance.join();
	}

}
