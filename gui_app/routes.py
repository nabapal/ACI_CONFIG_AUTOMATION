
from gui_app.app import app, db
from flask import render_template, redirect, url_for, flash, request
from gui_app.models.tenant import Tenant
from gui_app.forms.tenant_form import TenantForm

@app.route('/')
def dashboard():
    return render_template('dashboard.html')

@app.route('/tenants')
def tenants():
    tenants = Tenant.query.all()
    return render_template('tenants.html', tenants=tenants)

@app.route('/tenants/add', methods=['GET', 'POST'])
def add_tenant():
    form = TenantForm()
    if form.validate_on_submit():
        tenant = Tenant(
            name=form.name.data,
            apic_url=form.apic_url.data,
            apic_username=form.apic_username.data,
            apic_password=form.apic_password.data,
            description=form.description.data
        )
        db.session.add(tenant)
        db.session.commit()
        flash('Tenant added successfully!', 'success')
        return redirect(url_for('tenants'))
    return render_template('tenant_form.html', form=form, action='Add')


@app.route('/tenants/edit/<int:tenant_id>', methods=['GET', 'POST'])
def edit_tenant(tenant_id):
    tenant = Tenant.query.get_or_404(tenant_id)
    form = TenantForm(obj=tenant)
    if form.validate_on_submit():
        tenant.name = form.name.data
        tenant.apic_url = form.apic_url.data
        tenant.apic_username = form.apic_username.data
        tenant.apic_password = form.apic_password.data
        tenant.description = form.description.data
        db.session.commit()
        flash('Tenant updated successfully!', 'success')
        return redirect(url_for('tenants'))
    return render_template('tenant_form.html', form=form, action='Edit')

@app.route('/tenants/delete/<int:tenant_id>', methods=['POST'])
def delete_tenant(tenant_id):
    tenant = Tenant.query.get_or_404(tenant_id)
    db.session.delete(tenant)
    db.session.commit()
    flash('Tenant deleted successfully!', 'success')
    return redirect(url_for('tenants'))
