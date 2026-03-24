from flask_sqlalchemy import SQLAlchemy
import redis
import os

db = SQLAlchemy()

def init_redis():
    return redis.from_url(os.getenv("REDIS_URL"))