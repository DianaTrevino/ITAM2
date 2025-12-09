# Examen Final Diana T- Auto MPG (Predicción de Eficiencia de Combustible)

E2E pipeline de ciencia de datos usando el dataset **Auto MPG** de UCI:
- Descarga y limpieza con Bash
- EDA univariado/bivariado en R + gráficos
- Guardado en Feather
- Entrenamiento + evaluación de Random Forest en Python
- API REST con FastAPI (/predict, /stats)
- Logging de predicciones en **MySQL**
- Contenerización con Docker
- Orquestación local con Docker Compose
- (Opcional) despliegue en AWS

---

## Estructura del proyecto

examen/168962/
├── bash/01_download_clean.sh
├── data/
│ ├── raw/auto-mpg.data
│ └── processed/
│ ├── auto_mpg_clean.csv
│ ├── univariate_stats.csv
│ ├── cor_matrix.csv
│ ├── cor_with_mpg.csv
│ ├── origin_counts.csv
│ ├── origin_vs_mpg.csv
│ ├── boxplot_mpg_origin.png
│ ├── scatter_weight_mpg.png
│ └── auto_mpg.feather
├── r/
│ ├── 02_eda_univariate_bivariate.R
│ └── 03_save_feather.R
├── python/
│ ├── 04_train_model.py
│ └── 05_evaluate_model.py
├── api/
│ ├── main.py
│ ├── db.py
│ ├── schemas.py
│ └── requirements.txt
├── model.pkl
├── model_columns.pkl
├── test_split.pkl
├── Dockerfile
├── docker-compose.yml
└── README.md



---

## 1) Descarga y limpieza (Bash)

Ejecutar:

```bash
bash bash/01_download_clean.sh
R EDA:

Rscript r/02_eda_univariate_bivariate.R

Guardar Feather:
Rscript r/03_save_feather.R

Entrenar Modelo:
python3 python/04_train_model.py

Evaluar Modelo:
python3 python/05_evaluate_model.py


API:
pip3 install -r api/requirements.txt
uvicorn api.main:app --reload --port 8000

Docker:
docker build -t auto-mpg-api .
docker run --rm -p 80:80 auto-mpg-api


Docker compose:
docker compose up --build

Shinny App:

R -e "shiny::runApp('shiny')"

AWS:esta sección queda como documentación completa para ejecución posterior.

10.1 RDS MySQL
Crear instancia en AWS RDS:
Engine: MySQL 8
DB instance identifier: autompg-rds
Master username: admin (ejemplo)
Password: <tu_password>
Initial database name: autompg
Public access: Yes (solo pruebas)
Security Group:
Permitir 3306 desde tu IP o desde el SG de EC2

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
DB_HOST=<endpoint-rds>
DB_PORT=3306
DB_USER=<usuario>
DB_PASS=<password>
DB_NAME=autompg

DB_HOST=<endpoint-rds>
DB_PORT=3306
DB_USER=<usuario>
DB_PASS=<password>
DB_NAME=autompg

10.2 EC2 — Despliegue API con Docker
Crear instancia EC2 Ubuntu.
Security Group:
Inbound:
80 (HTTP) desde 0.0.0.0/0
22 (SSH) solo tu IP
Conectarse: ssh -i <tu-key.pem> ubuntu@<EC2_PUBLIC_IP>
Instalar docker: sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker ubuntu
newgrp docker
Clonar repo: git clone <repo>
cd examen/168962

construir imagen: docker build -t auto-mpg-api .

Correr Api apuntando RDS: docker run -d --name auto_mpg_api \
  -p 80:80 \
  -e DB_HOST=<endpoint-rds> \
  -e DB_PORT=3306 \
  -e DB_USER=<usuario> \
  -e DB_PASS=<password> \
  -e DB_NAME=autompg \
  auto-mpg-api

Probar: 
curl http://<EC2_PUBLIC_IP>/stats

Endpoints: 

{
  "cylinders": 4,
  "displacement": 140,
  "horsepower": 90,
  "weight": 2400,
  "acceleration": 19.5,
  "model_year": 76,
  "origin": "Japan"
}

Stats:
curl http://localhost/stats


Notas de reproducibilidad: bash bash/01_download_clean.sh
Rscript r/02_eda_univariate_bivariate.R
Rscript r/03_save_feather.R
python3 python/04_train_model.py
python3 python/05_evaluate_model.py
docker compose up -d --build

14) Evidencia mínima sugerida
data/processed/auto_mpg_clean.csv
data/processed/univariate_stats.csv
data/processed/cor_with_mpg.csv
data/processed/origin_vs_mpg.csv
data/processed/*.png
data/processed/auto_mpg.feather
model.pkl, model_columns.pkl, test_split.pkl
API funcional con /predict y /stats
Dockerfile y docker-compose.yml
Este README.md

