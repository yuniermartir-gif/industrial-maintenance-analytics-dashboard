import os
import pandas as pd

# 1. Chemins locaux automatiques
current_dir = os.path.dirname(os.path.abspath(__file__))
input_path = os.path.join(current_dir, "../01_raw_data/01_nettoyage_donnees.csv")
output_path = os.path.join(current_dir, "../02_cleaned_data/machine_failures_clean.csv")

print("\n⏳ [SAS RUEDA ANALYTICS] - Début du contrôle qualité des données...")

# 2. Chargement du dataset industriel
df = pd.read_csv(input_path)

# 3. Traitement et Ingénierie des Données (Standard Industriel)
# Conversion Kelvin en Celsius
df['Air_temperature_C'] = df['Air temperature [K]'] - 273.15
df['Process_temperature_C'] = df['Process temperature [K]'] - 273.15
df['Temperature_Delta_C'] = df['Process_temperature_C'] - df['Air_temperature_C']

# Normalisation des noms de colonnes pour SQL et Power BI
df.rename(columns={
    'Rotational speed [rpm]': 'Rotational_speed_rpm',
    'Torque [Nm]': 'Torque_Nm',
    'Tool wear [min]': 'Tool_wear_min',
    'Machine failure': 'Machine_failure'
}, inplace=True)

# Contrôle des doublons
print("Nombre de doublons avant suppression :", df.duplicated().sum())

# Suppression des doublons si nécessaire
df = df.drop_duplicates()

print("Nombre de doublons après suppression :", df.duplicated().sum())

# 4. Sauvegarde locale sécurisée
df.to_csv(output_path, index=False)

print("✅ Contrôle qualité réussi ! Fichier généré : machine_failures_clean.csv")
print(f"📁 Chemin d'accès local : {output_path}\n")
# Diagnostic simple
print(df.shape)
print(df.isnull().sum())

