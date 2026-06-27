-- ======================================================
-- PHASE 4 : ANALYSE SQL
-- Projet : Dashboard industriel de suivi qualité
-- et maintenance prédictive
-- Auteur : Yunier Martir Prado
-- ======================================================


-- 1. Vérification visuelle des premières lignes
-- Objectif : contrôler la lisibilité des données,
-- les noms des colonnes et la cohérence générale.

SELECT *
FROM maintenance_data
LIMIT 10;


-- 2. Vérification du nombre total d'observations
-- Objectif : confirmer que les 10 000 lignes
-- ont été correctement importées dans SQLite.

SELECT COUNT(*) AS total_observations
FROM maintenance_data;


-- 3. Vérification de la structure de la table
-- Objectif : contrôler les noms, l'ordre
-- et les types de données des colonnes.

PRAGMA table_info(maintenance_data);


-- 4. Question 1.1 : Taux global de panne machine
-- Objectif : calculer le nombre total d'observations,
-- le nombre total de pannes et le taux global de panne.

SELECT 
    COUNT(*) AS total_observations,
    SUM(Machine_failure) AS total_pannes,
    ROUND(
        SUM(Machine_failure) * 100.0 / COUNT(*),
        2
    ) AS taux_global_panne_pct
FROM maintenance_data;


-- 5. Question 1.2 : Taux de panne par type de produit
-- Objectif : comparer les catégories L, M et H.

SELECT
    Type AS type_produit,
    COUNT(*) AS total_observations,
    SUM(Machine_failure) AS total_pannes,
    ROUND(
        SUM(Machine_failure) * 100.0 / COUNT(*),
        2
    ) AS taux_panne_pct
FROM maintenance_data
GROUP BY Type
ORDER BY taux_panne_pct DESC;
 

-- QUESTION 2.1 : IMPACT OPÉRATIONNEL ET FINANCIER GLOBAL
-- ======================================================
Objectif :
-- Évaluer l’impact global des pannes machines sur la production
-- en mesurant le volume de défaillances, la proportion
-- d’observations affectées et leur coût financier estimé.
-- Hypothèse analytique :
-- Le coût moyen estimé d'une panne machine est fixé à CHF 500.
-- Cette estimation est utilisée car le dataset ne contient
-- aucune donnée financière réelle.

SELECT
    COUNT(*) AS total_observations,
    SUM(Machine_failure) AS total_pannes,
    COUNT(*) - SUM(Machine_failure) AS observations_sans_panne,
    ROUND(
        SUM(Machine_failure) * 100.0 / COUNT(*),
        2
    ) AS taux_global_panne_pct,
    SUM(Machine_failure) * 500 AS cout_total_estime_chf
FROM maintenance_data;

-- Question 2.2 : Impact financier estimé par type de produit
-- Objectif : comparer le coût estimé des pannes
-- entre les catégories L, M et H.

SELECT
    Type AS type_produit,
    COUNT(*) AS total_observations,
    SUM(Machine_failure) AS total_pannes,
    ROUND(
        SUM(Machine_failure) * 100.0 / COUNT(*),
        2
    ) AS taux_panne_pct,
    SUM(Machine_failure) * 500 AS cout_estime_chf
FROM maintenance_data
GROUP BY Type
ORDER BY cout_estime_chf DESC;

-- ======================================================
-- QUESTION 3 : PARAMÈTRES TECHNIQUES ASSOCIÉS AUX PANNES
-- ======================================================

-- Objectif :
-- Comparer les valeurs moyennes des principaux paramètres techniques
-- entre les observations sans panne et les observations avec panne,
-- afin d’identifier les conditions de fonctionnement les plus associées
-- aux défaillances machines.

SELECT
    Machine_failure AS statut_panne,
    COUNT(*) AS total_observations,
    ROUND(AVG(Air_temperature_C), 2) AS temperature_air_moyenne_c,
    ROUND(AVG(Process_temperature_C), 2) AS temperature_process_moyenne_c,
    ROUND(AVG(Temperature_Delta_C), 2) AS delta_temperature_moyen_c,
    ROUND(AVG(Rotational_speed_rpm), 2) AS vitesse_rotation_moyenne_rpm,
    ROUND(AVG(Torque_Nm), 2) AS couple_moyen_nm,
    ROUND(AVG(Tool_wear_min), 2) AS usure_outil_moyenne_min
FROM maintenance_data
GROUP BY Machine_failure
ORDER BY Machine_failure;

-- ======================================================
-- QUESTION 4.1 : RISQUE DE PANNE PAR NIVEAU D'USURE
--	À partir de quel niveau d’usure outil le risque de panne augmente-t-il 
-- et quand pourrait-on planifier une intervention préventive ? 
-- ======================================================

-- Objectif :
-- Regrouper les observations par plages d'usure de l'outil
-- afin d'identifier à partir de quel niveau le taux de panne
-- augmente de manière significative.
--usure de l’outil par rapport à l’ensemble des pannes

SELECT
    CASE
        WHEN Tool_wear_min < 60 THEN '0-59 min'
        WHEN Tool_wear_min < 120 THEN '60-119 min'
        WHEN Tool_wear_min < 180 THEN '120-179 min'
        WHEN Tool_wear_min < 220 THEN '180-219 min'
        ELSE '220 min et plus'
    END AS plage_usure,

    COUNT(*) AS total_observations,

    SUM(Machine_failure) AS total_pannes,

    ROUND(
        SUM(Machine_failure) * 100.0 / COUNT(*),
        2
    ) AS taux_panne_pct

FROM maintenance_data

GROUP BY plage_usure

ORDER BY
    CASE plage_usure
        WHEN '0-59 min' THEN 1
        WHEN '60-119 min' THEN 2
        WHEN '120-179 min' THEN 3
        WHEN '180-219 min' THEN 4
        WHEN '220 min et plus' THEN 5
    END;


    -- ======================================================
-- QUESTION 4.2 : PANNE TWF PAR NIVEAU D'USURE.
usure de l’outil par rapport aux pannes spécifiques liées à l’usure de l’outil.
-- ======================================================

-- Objectif :
-- Identifier les plages d'usure dans lesquelles les pannes
-- spécifiques de type TWF se concentrent.
--usure de l’outil par rapport aux pannes spécifiques TWF

SELECT
    CASE
        WHEN Tool_wear_min < 60 THEN '0-59 min'
        WHEN Tool_wear_min < 120 THEN '60-119 min'
        WHEN Tool_wear_min < 180 THEN '120-179 min'
        WHEN Tool_wear_min < 220 THEN '180-219 min'
        ELSE '220 min et plus'
    END AS plage_usure,

    COUNT(*) AS total_observations,

    SUM(TWF) AS total_pannes_twf,

    ROUND(
        SUM(TWF) * 100.0 / COUNT(*),
        2
    ) AS taux_twf_pct

FROM maintenance_data

GROUP BY plage_usure

ORDER BY
    CASE plage_usure
        WHEN '0-59 min' THEN 1
        WHEN '60-119 min' THEN 2
        WHEN '120-179 min' THEN 3
        WHEN '180-219 min' THEN 4
        WHEN '220 min et plus' THEN 5
    END;

    -- ======================================================
-- QUESTION 5.1 : DISTRIBUTION DES CAUSES DE DÉFAILLANCE
-- ======================================================

-- Objectif :
-- Compter le nombre de défaillances pour chaque cause spécifique
-- et les classer de la plus fréquente à la moins fréquente
-- afin d’identifier les priorités d’amélioration.

SELECT 'TWF' AS cause_defaillance, SUM(TWF) AS total_pannes
FROM maintenance_data

UNION ALL

SELECT 'HDF', SUM(HDF)
FROM maintenance_data

UNION ALL

SELECT 'PWF', SUM(PWF)
FROM maintenance_data

UNION ALL

SELECT 'OSF', SUM(OSF)
FROM maintenance_data

UNION ALL

SELECT 'RNF', SUM(RNF)
FROM maintenance_data

ORDER BY total_pannes DESC;

-- Question 5.2 : Répartition en pourcentage des causes
-- Objectif :
-- Calculer la part de chaque cause dans le total des défaillances spécifiques.

WITH causes AS (
    SELECT 'TWF' AS cause_defaillance, SUM(TWF) AS total_pannes
    FROM maintenance_data

    UNION ALL

    SELECT 'HDF', SUM(HDF)
    FROM maintenance_data

    UNION ALL

    SELECT 'PWF', SUM(PWF)
    FROM maintenance_data

    UNION ALL

    SELECT 'OSF', SUM(OSF)
    FROM maintenance_data

    UNION ALL

    SELECT 'RNF', SUM(RNF)
    FROM maintenance_data
)

SELECT
    cause_defaillance,
    total_pannes,
    ROUND(
        total_pannes * 100.0 / SUM(total_pannes) OVER (),
        2
    ) AS part_pct
FROM causes
ORDER BY total_pannes DESC;


--- ======================================================
-- QUESTION 6.1 : CLASSIFICATION DES NIVEAUX DE RISQUE
-- VERSION FINALE RÉVISÉE
-- ======================================================

-- Historique méthodologique :
-- La première version utilisait le seuil exploratoire
-- Process_temperature_C >= 40.
--
-- Après l’analyse complémentaire des défaillances HDF,
-- cette condition a été remplacée par :
-- Temperature_Delta_C < 9.5
-- AND Rotational_speed_rpm < 1400.
--
-- Cette nouvelle règle est mieux soutenue par les résultats du dataset.

SELECT
    CASE
        WHEN Machine_failure = 1 THEN 'Critique'

        WHEN Tool_wear_min >= 180
             OR Torque_Nm >= 50
             OR (
                 Temperature_Delta_C < 9.5
                 AND Rotational_speed_rpm < 1400
             )
        THEN 'Alerte'

        ELSE 'Normal'
    END AS niveau_risque,

    COUNT(*) AS total_observations,
    SUM(Machine_failure) AS total_pannes,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS part_observations_pct

FROM maintenance_data

GROUP BY niveau_risque

ORDER BY
    CASE niveau_risque
        WHEN 'Critique' THEN 1
        WHEN 'Alerte' THEN 2
        WHEN 'Normal' THEN 3
    END;

   -- ======================================================
-- QUESTION 6.2 : ORIGINE DES SIGNAUX D'ALERTE
-- VERSION FINALE RÉVISÉE APRÈS ANALYSE HDF
-- ======================================================

-- Objectif :
-- Identifier les paramètres techniques responsables
-- du classement des observations dans la catégorie Alerte.

-- Historique méthodologique :
-- La condition thermique initiale Process_temperature_C >= 40
-- a été remplacée par une règle combinée mieux soutenue
-- par l’analyse des défaillances HDF :
-- Temperature_Delta_C < 9.5
-- AND Rotational_speed_rpm < 1400.

SELECT
    SUM(
        CASE
            WHEN Machine_failure = 0
                 AND Tool_wear_min >= 180
            THEN 1 ELSE 0
        END
    ) AS alertes_usure,

    SUM(
        CASE
            WHEN Machine_failure = 0
                 AND Torque_Nm >= 50
            THEN 1 ELSE 0
        END
    ) AS alertes_couple,

    SUM(
        CASE
            WHEN Machine_failure = 0
                 AND Temperature_Delta_C < 9.5
                 AND Rotational_speed_rpm < 1400
            THEN 1 ELSE 0
        END
    ) AS alertes_hdf

FROM maintenance_data;


---- ======================================================
-- QUESTION 6.3 : NOMBRE DE SIGNAUX D'ALERTE SIMULTANÉS
-- VERSION FINALE RÉVISÉE APRÈS ANALYSE HDF
-- ======================================================

-- Objectif :
-- Identifier les observations sans panne présentant
-- un, deux ou trois signaux techniques simultanés.

-- Historique méthodologique :
-- La règle thermique initiale Process_temperature_C >= 40
-- a été remplacée par une condition HDF combinée :
-- Temperature_Delta_C < 9.5
-- AND Rotational_speed_rpm < 1400.

SELECT
    nombre_signaux,
    COUNT(*) AS total_observations
FROM (
    SELECT
        (
            CASE
                WHEN Tool_wear_min >= 180
                THEN 1 ELSE 0
            END
            +
            CASE
                WHEN Torque_Nm >= 50
                THEN 1 ELSE 0
            END
            +
            CASE
                WHEN Temperature_Delta_C < 9.5
                     AND Rotational_speed_rpm < 1400
                THEN 1 ELSE 0
            END
        ) AS nombre_signaux
    FROM maintenance_data
    WHERE Machine_failure = 0
)
WHERE nombre_signaux >= 1
GROUP BY nombre_signaux
ORDER BY nombre_signaux;


-- ======================================================
-- ANALYSE COMPLÉMENTAIRE QUESTION 1: CONDITIONS ASSOCIÉES AUX PANNES HDF
-- Approche prédictive de premier niveau fondée sur l’identification de profils
-- de risque.
-- ======================================================
--  cette requête sert à :
--valider ou corriger la règle thermique ;
--éviter l’utilisation d’un seuil arbitraire ;
--identifier des tendances ou des relations supplémentaires ;
--améliorer la rigueur méthodologique du tableau de bord ;
--mieux justifier la classification en niveaux Normal, Alerte et Critique.

-- Objectif :
-- Comparer l'écart thermique et la vitesse de rotation
-- entre les observations sans HDF et avec HDF,
-- afin d'améliorer la règle d'alerte thermique.

SELECT
    HDF AS statut_hdf,
    COUNT(*) AS total_observations,
    ROUND(AVG(Temperature_Delta_C), 2) AS delta_temperature_moyen_c,
    ROUND(AVG(Rotational_speed_rpm), 2) AS vitesse_rotation_moyenne_rpm,
    ROUND(AVG(Process_temperature_C), 2) AS temperature_process_moyenne_c
FROM maintenance_data
GROUP BY HDF
ORDER BY HDF;


-- ======================================================
-- ANALYSE COMPLÉMENTAIRE HDF PAR PLAGES  QUESTION 2
-- ======================================================

-- Objectif :
-- Étudier la fréquence des défaillances HDF selon des plages
-- de delta thermique et de vitesse de rotation afin d’identifier
-- des conditions techniques pouvant servir de seuils d’alerte.

SELECT
    CASE
        WHEN Temperature_Delta_C < 8.5 THEN 'Delta < 8.5 °C'
        WHEN Temperature_Delta_C < 9.5 THEN 'Delta 8.5–9.49 °C'
        WHEN Temperature_Delta_C < 10.5 THEN 'Delta 9.5–10.49 °C'
        ELSE 'Delta >= 10.5 °C'
    END AS plage_delta_temperature,

    CASE
        WHEN Rotational_speed_rpm < 1400 THEN 'Vitesse < 1400 rpm'
        WHEN Rotational_speed_rpm < 1600 THEN 'Vitesse 1400–1599 rpm'
        ELSE 'Vitesse >= 1600 rpm'
    END AS plage_vitesse,

    COUNT(*) AS total_observations,
    SUM(HDF) AS total_hdf,

    ROUND(
        SUM(HDF) * 100.0 / COUNT(*),
        2
    ) AS taux_hdf_pct

FROM maintenance_data

GROUP BY
    plage_delta_temperature,
    plage_vitesse

ORDER BY
    taux_hdf_pct DESC;



