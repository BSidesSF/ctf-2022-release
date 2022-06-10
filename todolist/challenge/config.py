import os

class Config:
    REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    SUPPORT_URL = os.getenv("SUPPORT_URL", "http://localhost:3124/")
