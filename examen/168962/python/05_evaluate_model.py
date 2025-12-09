import joblib
from sklearn.metrics import mean_squared_error, r2_score

model = joblib.load("model.pkl")
X_test, y_test = joblib.load("test_split.pkl")

preds = model.predict(X_test)

mse = mean_squared_error(y_test, preds)
r2 = r2_score(y_test, preds)

print(f"MSE: {mse:.4f}")
print(f"R2 : {r2:.4f}")
