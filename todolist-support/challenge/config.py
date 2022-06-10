import os

class Config:
    REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    SSO_URL = os.getenv("SSO_URL", "http://localhost:3123/api/sso")
    SSO_KEY_URL = os.getenv("SSO_KEY_URL", "http://localhost:3123/pubkey.pem")
