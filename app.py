from flask import Flask, render_template, request, flash, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime
import os
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Required for flash messages

# Configure PostgreSQL connection (ensure password is URL-encoded)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
    'DATABASE_URL', 'postgresql://sai:Sai%402024@16.16.128.22:5432/mydb1'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize the database
db = SQLAlchemy(app)

# Create a model for the form data
class FormData(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    traveller_name = db.Column(db.String(100), nullable=False)
    travel_date = db.Column(db.Date, nullable=False)
    age = db.Column(db.Integer, nullable=False)

# Create the tables in the database (ensure this runs only once)
with app.app_context():
    db.create_all()

@app.route('/health')
def health():
    """Health check route for liveness/readiness probes."""
    return 'OK', 200  # Respond with 200 status to indicate the app is healthy

@app.route('/')
def index():
    return render_template('form.html')

@app.route('/submit', methods=['POST'])
def submit():
    try:
        # Get form data
        traveller_name = request.form.get('travellerName')
        travel_date_str = request.form.get('travelDate')
        age_str = request.form.get('age')

        logging.debug(f"Form data received - Name:{traveller_name}, Date:{travel_date_str}, Age:{age_str}")

        # Input validation
        if not traveller_name or not travel_date_str or not age_str:
            flash("All fields are required!", "danger")
            return redirect(url_for('index'))

        # Convert string inputs to proper types
        travel_date = datetime.strptime(travel_date_str, '%Y-%m-%d').date()
        age = int(age_str)

        # Save form data to the database
        new_data = FormData(traveller_name=traveller_name, travel_date=travel_date, age=age)
        db.session.add(new_data)
        db.session.commit()

        flash("Form submitted successfully!", "success")
    except ValueError as ve:
        logging.error(f"Invalid input format - {ve}")
        flash(f"Invalid input format - {ve}", "danger")
    except SQLAlchemyError as e:
        logging.error(f"Database error - {e}")
        db.session.rollback()
        flash(f"Database error - {e}", "danger")
    except Exception as e:
        logging.error(f"Unexpected error - {e}")
        flash(f"Unexpected error - {e}", "danger")

    return redirect(url_for('index'))

@app.route('/submissions')
def submissions():
    # Fetch all submitted data
    data = FormData.query.all()
    return render_template('submissions.html', data=data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)  # Listen on all network interfaces
