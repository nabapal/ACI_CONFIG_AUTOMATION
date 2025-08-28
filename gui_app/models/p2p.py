from gui_app.app import db

class P2P(db.Model):
    __tablename__ = 'p2p'
    id = db.Column(db.Integer, primary_key=True)
    tenant_id = db.Column(db.Integer, db.ForeignKey('tenants.id'), nullable=False)
    hostname = db.Column(db.String(128), nullable=False)
    interface_port = db.Column(db.String(64), nullable=False)
    interface_speed = db.Column(db.String(32))
    vlan_id = db.Column(db.String(64))

    def __repr__(self):
        return f'<P2P HOSTNAME={self.hostname} PORT={self.interface_port} VLAN={self.vlan_id} Tenant={self.tenant_id}>'
