import joblib
import pandas as pd
import pyarrow.feather as feather
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor

# 1) Cargar Feather
data = feather.read_feather("data/processed/auto_mpg.feather")

# 2) Asegurar que no usamos texto libre en el modelo base
if "car_name" in data.columns:
    data = data.drop(columns=["car_name"])

# 3) One-Hot Encoding de origin
data_encoded = pd.get_dummies(data, columns=["origin"], drop_first=True)

# 4) Features / target
X = data_encoded.drop("mpg", axis=1)
y = data_encoded["mpg"]

# 5) Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# 6) Modelo
model = RandomForestRegressor(
    n_estimators=300,
    random_state=42,
    n_jobs=-1
)

model.fit(X_train, y_train)

# 7) Guardar modelo y columnas
joblib.dump(model, "model.pkl")
joblib.dump(X.columns.tolist(), "model_columns.pkl")

# Guardar test para evaluación separada
joblib.dump((X_test, y_test), "test_split.pkl")

print("OK -> model.pkl, model_columns.pkl, test_split.pkl")
