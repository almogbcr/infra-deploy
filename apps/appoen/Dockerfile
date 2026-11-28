FROM python:3.14-slim

WORKDIR /opt/infradeploy/flask

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . . 

EXPOSE 5050

CMD ["gunicorn","--bind","0.0.0.0:5050","app:app"]
