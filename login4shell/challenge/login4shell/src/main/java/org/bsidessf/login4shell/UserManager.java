package org.bsidessf.login4shell;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.slf4j.LoggerFactory;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

import org.slf4j.Logger;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class UserManager {
	
	public static final String COOKIE_NAME = "logincookie";
	public static final String MAC_NAME = "HmacSHA256";
	private static final String SKEY = "WelcomeToBSidesSF2022";
	private static final Logger logger = LoggerFactory.getLogger(UserManager.class);
	private static final Gson gson = new Gson();
	private static final int MAC_LENGTH = 9;
	
	public static class UserInstance {
		public String username;
		public String password;
		
		public UserInstance() {}
		
		public UserInstance(String u, String p) {
			username = u;
			password = p;
		}
	}
	
	public static String getUserForRequest(HttpServletRequest request) {
		Cookie[] cookies = request.getCookies();
		if (cookies == null) {
			// no cookies
			return null;
		}
		for (Cookie c: cookies) {
			if (c.getName().equals(COOKIE_NAME)) {
				// Try to decode and do stuff
				if (c.getValue().equals("")) {
					return null;
				}
				Base64.Decoder dec = Base64.getUrlDecoder();
				byte[] val;
				try {
					val = dec.decode(c.getValue());
				} catch (IllegalArgumentException ex) {
					logger.error("Error decoding base64: ", ex);
					return null;
				}
				String valstr = new String(val, StandardCharsets.UTF_8);
				try {
					UserInstance u = gson.fromJson(valstr, UserInstance.class);
					if (verifyUserPassword(u)) {
						return u.username;
					}
					return null;
				} catch (JsonSyntaxException ex) {
					logger.error("Error decoding JSON: ", ex);
					return null;
				}
			}
		}
		return null;
	}
	
	public static void setCookieForUser(HttpServletResponse response, String username) {
		String password = getPasswordForUser(username);
		UserInstance inst = new UserInstance(username, password);
		String rawval = gson.toJson(inst);
		String val = Base64.getUrlEncoder().encodeToString(rawval.getBytes());
		Cookie c = new Cookie(COOKIE_NAME, val);
		response.addCookie(c);
	}
	
	public static boolean verifyUserPassword(UserInstance inst) {
		return verifyUserPassword(inst.username, inst.password);
	}
	
	public static boolean verifyUserPassword(String username, String password) {
		String expected = getPasswordForUser(username);
		return password.equals(expected);
	}
	
	public static String getPasswordForUser(String username) {
		try {
			return macValue(getBaseUsername(username));
		} catch (NoSuchAlgorithmException|InvalidKeyException ex) {
			logger.error("Failed getting mac value: ", ex);
			return "not-a-valid-password!!";
		}
	}
	
	public static String getBaseUsername(String username) {
		int plusIdx = username.indexOf("+");
		if (plusIdx > 0) {
			username = username.substring(0, plusIdx);
		}
		return username;
	}
	
	private static String macValue(String input) throws NoSuchAlgorithmException, InvalidKeyException {
		Mac hasher = Mac.getInstance(MAC_NAME);
		SecretKeySpec spec = new SecretKeySpec(SKEY.getBytes(), MAC_NAME);
		hasher.init(spec);
		byte[] inputBytes = input.getBytes(StandardCharsets.UTF_8);
		hasher.update(inputBytes);
		byte[] resultBytes = hasher.doFinal();
		resultBytes = Arrays.copyOf(resultBytes, MAC_LENGTH);
		Base64.Encoder encoder = Base64.getUrlEncoder();
		return encoder.encodeToString(resultBytes);
	}
}
