#!/usr/bin/env bash
set -euo pipefail

mkdir -p data/raw data/processed

# 1) Descargar dataset (mac friendly)
curl -L \
  -o data/raw/auto-mpg.data \
  https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data

# 2) Limpiar y construir CSV correcto sin romper car_name
awk '
BEGIN {
  OFS=",";
  print "mpg,cylinders,displacement,horsepower,weight,acceleration,model_year,origin,car_name"
}
{
  if ($0 ~ /\?/) next;

  mpg=$1; cyl=$2; disp=$3; hp=$4; wt=$5; acc=$6; year=$7; org=$8;

  name="";
  for (i=9; i<=NF; i++) {
    name = name (i==9 ? "" : " ") $i
  }
  gsub(/"/, "", name);

  print mpg, cyl, disp, hp, wt, acc, year, org, name
}' data/raw/auto-mpg.data > data/processed/auto_mpg_clean.csv

echo "OK -> data/processed/auto_mpg_clean.csv"
