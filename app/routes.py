from flask import Blueprint, jsonify
from .models import User
from .extensions import db

main = Blueprint("main", __name__)

@main.route("/")
def home():
    return "Flask SaaS Running 🚀"

@main.route("/users")
def users():
    users = User.query.all()
    return jsonify([{"id": u.id, "name": u.name} for u in users])