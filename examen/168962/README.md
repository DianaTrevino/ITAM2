# Examen Final Diana T — Auto MPG (Predicción de Eficiencia de Combustible)

Pipeline end-to-end con el dataset **Auto MPG (UCI)**:

- Descarga y limpieza con Bash
- EDA univariado/bivariado en R + gráficas
- Guardado en Feather
- Entrenamiento y evaluación de Random Forest en Python
- API REST con FastAPI (`/predict`, `/stats`)
- Logging de predicciones en MySQL (AWS RDS)
- Contenerización con Docker
- Orquestación local con Docker Compose
- Shiny App en R

---

## Estructura del proyecto

examen/168962/

├─ bash/
├─ data/
│ ├─ raw/
│ └─ processed/
├─ r/
├─ python/
├─ api/
├─ shiny/
├─ model/
├─ Dockerfile
├─ docker-compose.yml
└─ README.md

---

## Reproducibilidad rápida

Ejecutar en este orden:

```bash
# 1) Descargar y limpiar
bash bash/01_download_clean.sh

# 2) EDA en R
Rscript r/02_eda_univariate_bivariate.R

# 3) Guardar Feather
Rscript r/03_save_feather.R

# 4) Entrenar modelo
python3 python/04_train_model.py

# 5) Evaluar modelo
python3 python/05_evaluate_model.py
```

### Datos generados (evidencia mínima)
- data/processed/auto_mpg_clean.csv
- data/processed/univariate_stats.csv
- data/processed/cor_with_mpg.csv
- data/processed/origin_vs_mpg.csv
- data/processed/*.png
- data/processed/auto_mpg.feather
- model/model.pkl
- model/model_columns.pkl
- model/test_split.pkl (si aplica)

### API (FastAPI)

Instalación:
```bash
pip3 install -r api/requirements.txt
```

Ejecución local:
```bash
uvicorn api.main:app --reload --port 8000
```

**Endpoint /predict**  
Ejemplo de request:
```json
{
  "cylinders": 4,
  "displacement": 140,
  "horsepower": 90,
  "weight": 2400,
  "acceleration": 19.5,
  "model_year": 76,
  "origin": "Japan"
}
```

`origin` acepta:
- Texto: "USA", "Europe", "Japan"
- Número como string o int: 1, 2, 3

**Endpoint /stats**
```bash
curl http://localhost:8000/stats
```

### Docker

Build:
```bash
docker build -t auto-mpg-api .
```

Run:
```bash
docker run --rm -p 80:80 auto-mpg-api
```

### Docker Compose
```bash
docker compose up --build
```

### Shiny App

Ejecución local:
```bash
R -e "shiny::runApp('shiny')"
```

Sugerido para servidor:
```bash
R -e "shiny::runApp('shiny', host='0.0.0.0', port=3838)"
```

## AWS (documentación de despliegue)

### 1) RDS MySQL

Crear instancia:
- Engine: MySQL 8
- DB instance identifier: autompg-rds
- Master username: admin (ejemplo)
- Password: <tu_password>
- Initial database name: autompg
- Public access: Yes (solo pruebas)
- Security Group: permitir 3306 desde tu IP o desde el SG de EC2

Crear tabla:
```sql
CREATE TABLE IF NOT EXISTS predictions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cylinders INT,
  displacement FLOAT,
  horsepower FLOAT,
  weight FLOAT,
  acceleration FLOAT,
  model_year INT,
  origin VARCHAR(20),
  prediction FLOAT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Variables de entorno usadas por la API:
```bash
export DB_HOST="<endpoint-rds>"
export DB_PORT="3306"
export DB_USER="<usuario>"
export DB_PASS="<password>"
export DB_NAME="autompg"
```

### 2) EC2 — Despliegue API con Docker

Crear instancia EC2 Ubuntu.

Security Group:
- 80 (HTTP) desde 0.0.0.0/0
- 22 (SSH) solo tu IP

Conectarse:
```bash
ssh -i <tu-key.pem> ubuntu@<EC2_PUBLIC_IP>
```

Instalar Docker:
```bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker ubuntu
newgrp docker
```

Clonar repo y entrar:
```bash
git clone <repo>
cd examen/168962
```

Construir imagen:
```bash
docker build -t auto-mpg-api .
```

Correr API apuntando a RDS:
```bash
docker run -d --name auto_mpg_api \
  -p 80:80 \
  -e DB_HOST="<endpoint-rds>" \
  -e DB_PORT="3306" \
  -e DB_USER="<usuario>" \
  -e DB_PASS="<password>" \
  -e DB_NAME="autompg" \
  auto-mpg-api
```

Probar:
```bash
curl http://<EC2_PUBLIC_IP>/stats
```

### 3) EC2 — Despliegue Shiny

Abrir puerto 3838 en el Security Group.

Ejecutar:
```bash
R -e "shiny::runApp('shiny', host='0.0.0.0', port=3838)"
```

### Notas

- `origin` se trata como variable categórica con etiquetas: 1 = USA, 2 = Europe, 3 = Japan.
- El modelo usa One-Hot Encoding y la API re-alinea columnas con `model_columns.pkl`.

