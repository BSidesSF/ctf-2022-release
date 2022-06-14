#include <stdio.h>
#include <stdlib.h>

#include "httpd.h"
#include "http_request.h"
#include "http_log.h"
#include "mod_auth.h"
#include "apr_md5.h"
#include "apr_base64.h"

#define USERNAME_HEADER "X-CTF-User"
#define HEADER "X-CTF-Authorization"
#define TOKEN_PREFIX "Token "
#define SECRET "GuardingTheGatesFromEvilCTFPlayers"
#define HASH_LENGTH (128 / 8)

/* Define prototypes of our functions in this module */
static void register_hooks(apr_pool_t *pool);

/* Define our module as an entity and assign a function for registering hooks  */

module AP_MODULE_DECLARE_DATA   ctfauth_module =
{
    STANDARD20_MODULE_STUFF,
    NULL,            // Per-directory configuration handler
    NULL,            // Merge handler for per-directory configurations
    NULL,            // Per-server configuration handler
    NULL,            // Merge handler for per-server configurations
    NULL,            // Any directives we may have for httpd
    register_hooks   // Our hook registering function
};

static authz_status custom_auth_provider(request_rec *r, const char* require_args, const void *parsed_require_args) {
  char *username = (char*)apr_table_get(r->headers_in, USERNAME_HEADER);
  if(!username) {
    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "CTF: No username detected");
    return AUTHZ_DENIED;
  }
  if(strcmp(username, "ctf")) {
    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "CTF: Incorrect username");
    return AUTHZ_DENIED;
  }

  char* header = (char*)apr_table_get( r->headers_in, HEADER);

  if(!header) {
    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "CTF: Missing authorization header");
    return AUTHZ_DENIED;
  }

  if(strncmp(header, TOKEN_PREFIX, strlen(TOKEN_PREFIX))) {
    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "CTF: Incorrect header format for authorization header");
    return AUTHZ_DENIED;
  }

  char *encoded_token = header + strlen(TOKEN_PREFIX);

  // Need to do the weird "length dance" because "decode_len" doesn't mean "decode_len",
  // it means "maximum length for the base64 length"
  int max_length = apr_base64_decode_len(encoded_token);
  unsigned char *decoded_token = malloc(max_length);
  int actual_length = apr_base64_decode(decoded_token, encoded_token);

  if(actual_length != HASH_LENGTH) {
    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "CTF: Incorrect decoded length for authorization header (expected: %d bytes)", HASH_LENGTH);
    return AUTHZ_DENIED;
  }

  // Calculate MD5(secret + username + secret)
  apr_md5_ctx_t md5;
  apr_md5_init(&md5);
  apr_md5_update(&md5, SECRET, strlen(SECRET));
  apr_md5_update(&md5, username, strlen(username));
  apr_md5_update(&md5, SECRET, strlen(SECRET));

  char buffer[HASH_LENGTH];
  apr_md5_final(buffer, &md5);

  if(memcmp(buffer, decoded_token, HASH_LENGTH)) {
    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "CTF: Token doesn't match!");
    free(decoded_token);
    return AUTHZ_DENIED;
  }

  ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "CTF: Looks good!");
  free(decoded_token);

  return AUTHZ_GRANTED;
}

static const authz_provider authz_ctfauth_provider = {
  &custom_auth_provider,
  NULL
};

/* register_hooks: Adds a hook to the httpd process */
static void register_hooks(apr_pool_t *pool)
{

    /* Hook the request handler */
  ap_register_auth_provider(pool, AUTHZ_PROVIDER_GROUP, "ctfauth", AUTHZ_PROVIDER_VERSION, &authz_ctfauth_provider, AP_AUTH_INTERNAL_PER_CONF);

}
