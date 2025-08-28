from gui_app.app import db

class Tenant(db.Model):
    __tablename__ = 'tenants'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128), nullable=False, unique=True)
    apic_url = db.Column(db.String(256), nullable=False)
    apic_username = db.Column(db.String(128), nullable=False)
    apic_password = db.Column(db.String(256), nullable=False)  # Store encrypted in production
    description = db.Column(db.String(256))
    # Relationships
    services = db.relationship('Service', backref='tenant', lazy=True)
    p2ps = db.relationship('P2P', backref='tenant', lazy=True)
    deployments = db.relationship('DeploymentHistory', backref='tenant', lazy=True)

    def __repr__(self):
        return f'<Tenant {self.name}>'
