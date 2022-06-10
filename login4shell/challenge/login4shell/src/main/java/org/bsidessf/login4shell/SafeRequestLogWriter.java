package org.bsidessf.login4shell;

import java.io.IOException;

import org.eclipse.jetty.server.Slf4jRequestLogWriter;

public class SafeRequestLogWriter extends Slf4jRequestLogWriter {
	@Override
	public void write(String requestEntry) throws IOException {
		// Avoid jndi injection in this log writer
		requestEntry = requestEntry.replaceAll("jndi", "j-n-d-i").replaceAll("\\$", "*").replaceAll("ldap", "l-d-a-p");
		super.write(requestEntry);
	}
}
