from pydantic import BaseModel
from typing import Union

class CarFeatures(BaseModel):
    cylinders: int
    displacement: float
    horsepower: float
    weight: float
    acceleration: float
    model_year: int
    origin: Union[str, int]  # "USA"/"Europe"/"Japan" o 1/2/3

class PredictionResponse(BaseModel):
    mpg_prediction: float
    origin_normalized: str
