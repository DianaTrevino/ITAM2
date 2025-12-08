from fastapi import FastAPI
import pandas as pd
import joblib
from sqlalchemy import text

from api.schemas import CarFeatures, PredictionResponse
from api.db import init_table, insert_log, engine

app = FastAPI(title="Auto MPG Predictor")

model = joblib.load("model.pkl")
model_cols = joblib.load("model_columns.pkl")

pred_history = []

ORIGIN_MAP_NUM = {1: "USA", 2: "Europe", 3: "Japan"}
ORIGIN_MAP_STR = {
    "usa": "USA",
    "united states": "USA",
    "europe": "Europe",
    "japan": "Japan"
}

def normalize_origin(value):
    if isinstance(value, int):
        return ORIGIN_MAP_NUM.get(value, "USA")
    if isinstance(value, str):
        v = value.strip().lower()
        if v.isdigit():
            return ORIGIN_MAP_NUM.get(int(v), "USA")
        return ORIGIN_MAP_STR.get(v, value.strip().title())
    return "USA"

@app.on_event("startup")
def startup():
    init_table()

@app.post("/predict", response_model=PredictionResponse)
def predict(car: CarFeatures):
    payload = car.model_dump()
    origin_norm = normalize_origin(payload["origin"])
    payload["origin"] = origin_norm

    df = pd.DataFrame([payload])
    df_encoded = pd.get_dummies(df, columns=["origin"], drop_first=True)

    # Alinear columnas exactas del entrenamiento
    df_final = df_encoded.reindex(columns=model_cols, fill_value=0)

    pred = float(model.predict(df_final)[0])

    pred_history.append(pred)
    insert_log(payload, pred, origin_norm)

    return {"mpg_prediction": pred, "origin_normalized": origin_norm}

@app.get("/stats")
def stats():
    # Prefer DB si existe
    if engine is not None:
        q = """
        SELECT
          COUNT(*) as n,
          AVG(prediction) as avg_pred,
          MIN(prediction) as min_pred,
          MAX(prediction) as max_pred
        FROM logs
        """
        with engine.begin() as conn:
            row = conn.execute(text(q)).mappings().first()

        return {
            "count": int(row["n"] or 0),
            "avg": float(row["avg_pred"] or 0),
            "min": float(row["min_pred"] or 0),
            "max": float(row["max_pred"] or 0),
            "source": "mysql"
        }

    # Fallback en memoria
    if not pred_history:
        return {"count": 0, "avg": None, "min": None, "max": None, "source": "memory"}

    return {
        "count": len(pred_history),
        "avg": sum(pred_history)/len(pred_history),
        "min": min(pred_history),
        "max": max(pred_history),
        "source": "memory"
    }
