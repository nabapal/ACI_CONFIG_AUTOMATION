from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///aci_gui.db'
app.config['SECRET_KEY'] = 'your-secret-key'
db = SQLAlchemy(app)
migrate = Migrate(app, db)
from gui_app import routes

if __name__ == "__main__":
    app.run(debug=True)
