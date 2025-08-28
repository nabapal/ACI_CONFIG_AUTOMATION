from gui_app.app import db

class Service(db.Model):
    __tablename__ = 'services'
    id = db.Column(db.Integer, primary_key=True)
    tenant_id = db.Column(db.Integer, db.ForeignKey('tenants.id'), nullable=False)
    vlan = db.Column(db.Integer, nullable=False)
    interface = db.Column(db.String(64), nullable=False)
    description = db.Column(db.String(256))
    vrf = db.Column(db.String(128))
    ipv4 = db.Column(db.String(64))
    ipv6 = db.Column(db.String(64))
    qos = db.Column(db.String(64))

    def __repr__(self):
        return f'<Service VLAN={self.vlan} Interface={self.interface} Tenant={self.tenant_id}>'
