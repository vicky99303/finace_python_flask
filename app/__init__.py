from flask import Flask
from .extensions import db, init_redis
import os

def create_app():
    app = Flask(__name__)

    # Database config
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)
    app.redis = init_redis()

    from .routes import main
    app.register_blueprint(main)

    return app