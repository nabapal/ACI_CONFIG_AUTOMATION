from gui_app.app import db

class DeploymentHistory(db.Model):
    __tablename__ = 'deployment_history'
    id = db.Column(db.Integer, primary_key=True)
    tenant_id = db.Column(db.Integer, db.ForeignKey('tenants.id'), nullable=False)
    task_type = db.Column(db.String(64), nullable=False)
    status = db.Column(db.String(32))
    timestamp = db.Column(db.DateTime)
    log = db.Column(db.Text)

    def __repr__(self):
        return f'<DeploymentHistory {self.task_type} Tenant={self.tenant_id} Status={self.status}>'