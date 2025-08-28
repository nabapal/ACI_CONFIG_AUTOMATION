from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, TextAreaField
from wtforms.validators import DataRequired, Length

class TenantForm(FlaskForm):
    name = StringField('Tenant Name', validators=[DataRequired(), Length(max=128)])
    apic_url = StringField('APIC URL', validators=[DataRequired(), Length(max=256)])
    apic_username = StringField('APIC Username', validators=[DataRequired(), Length(max=128)])
    apic_password = PasswordField('APIC Password', validators=[DataRequired(), Length(max=256)])
    description = TextAreaField('Description', validators=[Length(max=256)])
    submit = SubmitField('Save')
