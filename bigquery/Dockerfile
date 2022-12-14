FROM python:3.8

WORKDIR /app

# Copy the requirements.txt file to the working directory
COPY requirements.txt /app

# Install the required packages from the requirements.txt file
RUN pip install -r requirements.txt

# Copy the rest of the source code to the working directory
COPY gbq_ingest.py /app/gbq_ingest.py

# Run the Python script when the container launches
CMD ["python", "gbq_ingest.py"]