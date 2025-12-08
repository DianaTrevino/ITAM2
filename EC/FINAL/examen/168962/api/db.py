import os
from sqlalchemy import create_engine, text

DB_HOST = os.getenv("DB_HOST", "")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_USER = os.getenv("DB_USER", "")
DB_PASS = os.getenv("DB_PASS", "")
DB_NAME = os.getenv("DB_NAME", "")

engine = None
if all([DB_HOST, DB_USER, DB_PASS, DB_NAME]):
    url = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    engine = create_engine(url, pool_pre_ping=True)

def init_table():
    if engine is None:
        return
    ddl = """
    CREATE TABLE IF NOT EXISTS logs (
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
    """
    with engine.begin() as conn:
        conn.execute(text(ddl))

def insert_log(payload: dict, prediction: float, origin_norm: str):
    if engine is None:
        return
    sql = """
    INSERT INTO logs
    (cylinders, displacement, horsepower, weight, acceleration, model_year, origin, prediction)
    VALUES
    (:cylinders, :displacement, :horsepower, :weight, :acceleration, :model_year, :origin, :prediction)
    """
    params = {
        "cylinders": payload["cylinders"],
        "displacement": payload["displacement"],
        "horsepower": payload["horsepower"],
        "weight": payload["weight"],
        "acceleration": payload["acceleration"],
        "model_year": payload["model_year"],
        "origin": origin_norm,
        "prediction": prediction
    }
    with engine.begin() as conn:
        conn.execute(text(sql), params)
