FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY api/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY api/ /app/api/
COPY model.pkl model_columns.pkl /app/

# (Opcional pero recomendado para que la API siempre tenga acceso local al feather)
COPY data/processed/auto_mpg.feather /app/data/processed/auto_mpg.feather

ENV PYTHONPATH=/app

EXPOSE 80

CMD ["python", "-m", "uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "80"]
