/*								SVILUPPO SOSTENIBILE: ANALISI COMPARATIVA MONDIALE TRAMITE SQL


- SPECIFICHE DI PROGETTO
Immagina di lavorare per un’organizzazione no profit impegnata nella promozione dello sviluppo sostenibile globale.
Il tuo compito è analizzare i dati a disposizione per aiutare l’organizzazione a redigere un report comparativo tra Paesi su temi cruciali per lo sviluppo.
Per farlo realizza delle query che interroghino i dati presenti nei diversi dataset con lo scopo di trovare insight utili.
*/


/*
- DATASETS
Hai a disposizione diversi dataset per analizzare e confrontare i Paesi su temi chiave come economia, popolazione ed emissioni di CO₂.
Il dataset principale è il 'Global Country Information Dataset' che contiene dati del 2023 su indicatori economici, demografici e ambientali.
Puoi utlizzare anche le informazioni contenute in:
	- 'Global Data on Sustainable Energy': approfondisce come vari Paesi si sono mossi sul tema dell’energia sostenibile.
	- 'Global Missing Migrants Dataset': fornisce dati sui migranti dispersi a livello globale.
*/


/*												FASE PRELIMINARE
									Creazione tabelle ed importazione dati da datasets
*/									

--creazione tabelle da dataset 'Global Country Information Dataset', suddivise per macrotemi
CREATE TABLE IF NOT EXISTS general_info (
	country_id	INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Colonna ID come PK (identificatore unico)
    country VARCHAR(255),
    capital_major_city VARCHAR(255),
    land_area_km2 BIGINT,
    agricultural_land_percent DECIMAL(5, 2),
    forested_area_percent DECIMAL(5, 2),
    official_language VARCHAR(255),
    co2_emissions BIGINT,
    calling_code VARCHAR(10),
    latitude VARCHAR(16),
    longitude VARCHAR(16)
);
ALTER TABLE general_info ADD CONSTRAINT unique_gen_info_country UNIQUE (country);


CREATE TABLE healthcare (
    country VARCHAR(255),
    infant_mortality DECIMAL(5, 2),
    life_expectancy DECIMAL(5, 2),
    maternal_mortality_ratio DECIMAL(10, 2),
    out_of_pocket_health_expenditure DECIMAL(5, 2),
    physicians_per_thousand DECIMAL(5, 2)
);
ALTER TABLE healthcare ADD CONSTRAINT pk_healthcare PRIMARY KEY (country);

CREATE TABLE employment (
    country VARCHAR(255),
    minimum_wage DECIMAL(10, 2),
    population_labor_force_participation DECIMAL(5, 2),
    unemployment_rate DECIMAL(5, 2),
    gross_primary_education_enrollment DECIMAL(5, 2),
    gross_tertiary_education_enrollment DECIMAL(5, 2)
);
ALTER TABLE employment ADD CONSTRAINT pk_employment PRIMARY KEY (country);


CREATE TABLE economy (
    country VARCHAR(255),
    cpi DECIMAL(6, 2),
    cpi_change_percent DECIMAL(5, 2),
    currency_code VARCHAR(10),
    gasoline_price DECIMAL(5, 2),
    gdp BIGINT,
    tax_revenue_percent DECIMAL(5, 2),
    total_tax_rate DECIMAL(5, 2)
);
ALTER TABLE economy ADD CONSTRAINT pk_economy PRIMARY KEY (country);

CREATE TABLE demographics_2023 (
    country VARCHAR(255),
    population BIGINT,
    density INT,
    birth_rate DECIMAL(5, 2),
    fertility_rate DECIMAL(5, 2),
    urban_population BIGINT,
    armed_forces_size BIGINT
);
ALTER TABLE demographics ADD CONSTRAINT pk_demographics PRIMARY KEY (country);


--creazione tabelle da dataset 'Global Data on Sustainable Energy'
CREATE TABLE energy_general_info_00_20 (
    energy_id INT NOT NULL GENERATED ALWAYS AS IDENTITY,
	country VARCHAR(100),
    year INT,
    access_to_electricity_percent DECIMAL (5,2),
    access_to_clean_fuels_percent DECIMAL (5,2),
    gdp_per_capita DECIMAL (8,2),
    gdp_growth DECIMAL (5,2),
    financial_flows_develpmt_usd BIGINT,
	PRIMARY KEY (country, year)
);

CREATE TABLE energy_sources_00_20 (
    ensou_id INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	country VARCHAR(100),
    year INT,
    electricity_from_fossil_fuels_twh DECIMAL(10, 2),
    electricity_from_nuclear_twh DECIMAL(10, 2),
    electricity_from_renewables_twh DECIMAL(10, 2),
    low_carbon_electricity_percent DECIMAL(10, 2),
    energy_consumption_per_capita_kwh DECIMAL(15, 5),
    energy_intensity_mj_per_gdp DECIMAL(5, 2),
    co2_emissions_kt DECIMAL(15, 4),
	CONSTRAINT unique_country_year UNIQUE (country, year)
);


CREATE TABLE energy_renewable_00_20 (
    enren_id INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	country VARCHAR(100),
    year INT,
    electricity_from_renewables DECIMAL(10, 2),
    renewable_electricity_generating_capacity_per_capita DECIMAL(10, 2),
    renewable_energy_share_in_total_final_energy_consumption DECIMAL(5, 2),
    renewables_percentage_equivalent_primary_energy DECIMAL(10, 8)
);


--creazione tabella da database 'Global Missing Migrants Dataset'
CREATE TABLE migration_incidents (
    incident_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    incident_year INT,               
    reported_month VARCHAR(20),      
    region_of_origin VARCHAR(300), 
	country_of_origin VARCHAR(300),
    region_of_incident VARCHAR(300), 
    migration_route VARCHAR(500),    
    number_of_dead INT,              
    minimum_estimated_missing INT,  
    total_dead_and_missing INT,      
    number_of_survivors INT,         
    number_of_females INT,           
    number_of_males INT,             
    number_of_children INT,          
    cause_of_death VARCHAR(500)      
);


--creazione foreign key che legano tabelle create da 'Global Country Information Dataset'
ALTER TABLE healthcare
ADD CONSTRAINT fk_healthcare FOREIGN KEY (country)
REFERENCES general_info(country);

ALTER TABLE demographics
ADD CONSTRAINT fk_demog FOREIGN KEY (country)
REFERENCES general_info(country);

ALTER TABLE economy
ADD CONSTRAINT fk_econ FOREIGN KEY (country)
REFERENCES general_info(country);

ALTER TABLE employment
ADD CONSTRAINT fk_employ FOREIGN KEY (country)
REFERENCES general_info(country);


--Rinomino tabelle per maggior chiarezza contenuto (specificati anni di riferimento per i records delle varie tabelle)
ALTER TABLE general_info RENAME TO general_info_2023;
ALTER TABLE demographics RENAME TO demographics_2023;
ALTER TABLE economy RENAME TO economy_2023;
ALTER TABLE employment RENAME TO employment_2023;
ALTER TABLE healthcare RENAME TO healthcare_2023;
ALTER TABLE migration_incidents RENAME TO migration_incidents_14_23;


--Standardizzazione dei valori null, blank o Unknown tabella migration_incidents_14_23 per una più accurata analisi
SELECT migration_incidents_14_23.cause_of_death FROM migration_incidents_14_23
WHERE cause_of_death LIKE '%unk%' OR cause_of_death IS NULL;

UPDATE migration_incidents_14_23
SET country_of_origin = NULL WHERE country_of_origin LIKE 'Unkn%';

UPDATE migration_incidents_14_23
SET cause_of_death = NULL WHERE cause_of_death LIKE '%unkn%';


/*												ANALISI
				Interrogazione dei dati per rispondere a domande utili ad individuare insight  
*/


-- Q1: Qual'è la Top10 dei Paesi che hanno emesso la maggior percentuale di C02 nel 2023 (rispetto a quella globale)?

WITH co2 (country, co2_emissions, tot_co2) AS		--CTE (Common Table Expression):esiste solo nella query ov'è creata
(
SELECT country, co2_emissions,
(SELECT SUM(co2_emissions)
FROM general_info_2023)
FROM general_info_2023
)
SELECT country, co2_emissions,
ROUND((co2_emissions/tot_co2)*100,2) AS world_co2_percent   --aliasing
FROM co2
WHERE (co2_emissions/tot_co2)*100 IS NOT NULL
ORDER BY (co2_emissions/tot_co2)*100 DESC
LIMIT 10;

-- A1: I Paesi produttori della maggior parte della C02 globale nel 2023 sono stati Cina, USA, India, Russia e Giappone), responsabili assieme 
--     di oltre il 60% delle emissioni globali.



-- Q2. C'è correlazione tra la CO2 emission e l'estensione della terra agricola nel Paese?

WITH land_emissions (country, agricultural_area_km2, co2_emissions) AS      
(
SELECT country,
	(land_area_km2*agricultural_land_percent),
	 co2_emissions
FROM general_info_2023
WHERE co2_emissions IS NOT NULL AND agricultural_land_percent IS NOT NULL
ORDER BY co2_emissions DESC
)
SELECT country,
ROW_NUMBER() OVER(ORDER BY co2_emissions DESC) rank_co2,   		 				--Ranking Window Function: ROW_NUMBER conta ogni riga univocamente (no valori doppi)
ROW_NUMBER() OVER(ORDER BY agricultural_area_km2 DESC) AS rank_agriculture,
	CASE																			-- Il Paese è nella top20 di rank_agriculture: True or False. 
    	WHEN ROW_NUMBER() OVER(ORDER BY agricultural_area_km2 DESC) < 15
   		THEN 'True'
    	ELSE 'False'
	END AS is_in_top_15_rank_agriculture
FROM land_emissions
ORDER BY ROW_NUMBER() OVER(ORDER BY co2_emissions DESC)
LIMIT 15;

-- A2: Tra i primi 15 Paesi produttori di C02 ben 10 sono nella top 15 della classifica globale per estensione di terra agricola.
--     Sembra esserci una correlazione tra C02 emessa e sviluppo del settore primario del Paese.



-- Q3: Valutazione dell'impatto dell'energia da combustibili fossili e dell'energia pulita (nucleare e da rinnovabili) sulle emissioni di C02,
--	   mediate negli ultimi 10 anni

WITH avg_energy_co2 AS
(
SELECT country, 
ROUND(AVG(electricity_from_fossil_fuels_twh),5) AS avg_electricity_from_fuels_twh,
ROUND(AVG(electricity_from_renewables_twh + electricity_from_nuclear_twh),5) AS avg_clean_electricity_twh,
ROUND(AVG(co2_emissions_kt),5) AS avg_c02_emiss_kt
FROM energy_sources_00_20
WHERE year BETWEEN 2010 AND 2020
GROUP BY country
HAVING AVG(co2_emissions_kt) IS NOT NULL
ORDER BY AVG(co2_emissions_kt) DESC
)
SELECT *,
	CASE WHEN avg_electricity_from_fuels_twh =0 THEN NULL   					--rapporto energia pulita/energia fossile
		 ELSE ROUND(avg_clean_electricity_twh/avg_electricity_from_fuels_twh,2)
		 END AS clean_fuel_energy_ratio,
ROW_NUMBER() OVER(ORDER BY avg_electricity_from_fuels_twh DESC) AS rank_fuel_electr,
ROW_NUMBER() OVER(ORDER BY avg_clean_electricity_twh DESC) AS rank_clean_electr,
ROW_NUMBER() OVER(ORDER BY avg_c02_emiss_kt DESC) AS rank_co2_emiss
FROM avg_energy_co2
WHERE avg_c02_emiss_kt IS NOT NULL AND avg_electricity_from_fuels_twh IS NOT NULL
ORDER BY rank_co2_emiss
LIMIT 15;

-- A3: Tra i primi 15 Paesi produttori di C02 ben 10 sono nella top 15 della classifica per utilizzo di elettricità da combustibili fossili,
--     C`è una forte correlazione tra generazione di energia da combustili fossili ed emissione di C02.
--     Il rapporto energia pulita/energia fossile identifica i Paesi più o meno virtuosi nell'utilizzo di energia pulita.



-- Q4: Ranking paesi con maggiori emissioni C02: confronto tra l'effetto dell'agricoltura (2023) ed energia fossile e pulita (mediata 2010-2020)

--Vista 'agricolture' che contiene il rank dei Top30 Paesi per emissione C02 ed il relativo rank per estensione aree coltivabili (sviluppo agricolo)
CREATE VIEW agricolture AS(                                             
WITH land_emissions (country, agricultural_area_km2, co2_emissions) AS
(
SELECT country,
	(land_area_km2*agricultural_land_percent),
	 co2_emissions
FROM general_info_2023
WHERE co2_emissions IS NOT NULL AND agricultural_land_percent IS NOT NULL
ORDER BY co2_emissions DESC
)
SELECT country,
ROW_NUMBER() OVER(ORDER BY co2_emissions DESC) rank_co2,
ROW_NUMBER() OVER(ORDER BY agricultural_area_km2 DESC) AS rank_agriculture
FROM land_emissions
ORDER BY ROW_NUMBER() OVER(ORDER BY co2_emissions DESC)
LIMIT 30
);

--Vista 'energy' contenente il rank dei Top30 Paesi per produzione di energia fossile ed il relativo rank per produzione energia pulita ed emissioni C02 
CREATE VIEW energy AS(
WITH avg_energy_co2 AS
(
SELECT country, 
ROUND(AVG(electricity_from_fossil_fuels_twh),5) AS avg_electricity_from_fuels_twh,
ROUND(AVG(electricity_from_renewables_twh + electricity_from_nuclear_twh),5) AS avg_clean_electricity_twh,
ROUND(AVG(co2_emissions_kt),5) AS avg_c02_emiss_kt
FROM energy_sources_00_20
WHERE year BETWEEN 2010 AND 2020
GROUP BY country
HAVING AVG(co2_emissions_kt) IS NOT NULL
ORDER BY AVG(co2_emissions_kt) DESC
)
SELECT *,
ROW_NUMBER() OVER(ORDER BY avg_electricity_from_fuels_twh DESC) AS rank_fuel_electr,
ROW_NUMBER() OVER(ORDER BY avg_clean_electricity_twh DESC) AS rank_clean_electr,
ROW_NUMBER() OVER(ORDER BY avg_c02_emiss_kt DESC) AS rank_co2_emiss
FROM avg_energy_co2
WHERE avg_c02_emiss_kt IS NOT NULL AND avg_electricity_from_fuels_twh IS NOT NULL
ORDER BY rank_co2_emiss
LIMIT 30
);


--Utilizzo di un Left Join per unire i dati delle due Viste ed avere una visione estesa degli effetti dei vari fattori sulle emissioni di C02 nei vari Paesi 
SELECT a.country, a.rank_co2, a.rank_agriculture, e.rank_fuel_electr, rank_clean_electr FROM agricolture a
LEFT JOIN energy e
ON a.country = e.country
LIMIT 10;

-- A4: I top10 Paesi per emissioni di C02 sono nella top10 (eccetto il Canada) per produzione di energia fossile, e ben 5 su 10 nella top10 per estensione di terreno coltivato.
--     Combustibili fossili e agricoltura sono fattori evidentemente impattanti nella generazione di emissioni di C02.
--     Tali Paesi si mostrano anche virtuosi in termini di produzione di energia pulita (tutti entro la top15) anche se lo sforzo positivo non è ancora evidentemente sufficiente
--     ad equilibrare gli altri fattori negativi.



-- Q5: Ricerca correlazione tra il totale C02 prodotta dai vari Paesi (2000-2020) ed energia consumata per capita (2000-2020)

--Query utilizzando una CTE:
WITH consumption_emissions AS     
(
SELECT country, 
SUM(energy_consumption_per_capita_kwh) AS total_energy_cons_per_capita_kwh,
SUM(co2_emissions_kt) AS total_co2_emitted_kt  
FROM energy_sources_00_20
WHERE energy_consumption_per_capita_kwh IS NOT NULL AND co2_emissions_kt IS NOT NULL
GROUP BY country
ORDER BY SUM(co2_emissions_kt) DESC
)
SELECT *,
ROW_NUMBER() OVER(ORDER BY total_energy_cons_per_capita_kwh DESC) AS rank_energy_consumption_per_capita,
ROW_NUMBER() OVER(ORDER BY total_co2_emitted_kt DESC) AS rank_co2_emissions
FROM consumption_emissions
ORDER BY rank_co2_emissions;

--Posso ottenere lo stesso risultato implementando una Subquery (senza CTE): 
SELECT *,
       ROW_NUMBER() OVER(ORDER BY total_energy_cons_per_capita_kwh DESC) AS rank_energy_consumption_per_capita,
       ROW_NUMBER() OVER(ORDER BY total_co2_emitted_kt DESC) AS rank_co2_emissions
FROM (
       SELECT country,                         --Subquery:meno intuitiva a livello di lettura del codice di una CTE
              SUM(energy_consumption_per_capita_kwh) AS total_energy_cons_per_capita_kwh,
              SUM(co2_emissions_kt) AS total_co2_emitted_kt  
       FROM energy_sources_00_20
       WHERE energy_consumption_per_capita_kwh IS NOT NULL AND co2_emissions_kt IS NOT NULL
       GROUP BY country
       ORDER BY SUM(co2_emissions_kt) DESC
     ) AS consumption_emissions
ORDER BY rank_co2_emissions
LIMIT 15;

-- A5: Non si evidenzia una correlazione tra il consumo di energia pro capite e le emissioni pro capite nei vari Paesi



-- Q6: Stima dell'energia totale consumata per Paese nel 2020 (con popolazione presa dalla tabella demographics_2023 - quindi riferita a 3 anni dopo)

WITH energycons_per_capita_2020 AS     --prima CTE: dati sul consumo di energia pro capite (da tabella energy_sources_00_20)
(
SELECT country, energy_consumption_per_capita_kwh FROM energy_sources_00_20
WHERE year = 2020
)
, 
 access_electr_2020 AS     --seconda CTE: dati sull'accesso all'energia (da tabella energy_general_info_00_20) 
(
SELECT country, access_to_electricity_percent FROM energy_general_info_00_20
WHERE year = 2020
)
SELECT ec20.country, ec20.energy_consumption_per_capita_kwh, ae20.access_to_electricity_percent, dem.population, 
ROUND(ec20.energy_consumption_per_capita_kwh*(dem.population*(ae20.access_to_electricity_percent/100))/1000000000,5) AS total_energy_consumption_2020_twh
FROM energycons_per_capita_2020 ec20
JOIN access_electr_2020 ae20       --unione delle due CTE (inner join)
ON ec20.country=ae20.country
JOIN demographics_2023 dem         --ulteriore unione con la tabella demographics_2023 per avere i dati sulla popolazione (inner join)
ON ec20.country=dem.country
ORDER BY total_energy_consumption_2020_twh DESC
LIMIT 15;

-- A6: tramite questa analisi sono stati identificati i Paesi con maggior consumo di energia nel 2020 (valore stimato sulla base di una media pro capite)



-- Q7: Confronto tra la crescita media del GDP e la crescita media dei consumi di energia per capita dal 2000 al 2020

WITH cte_energy_growth AS
(
SELECT  
    country, 
    year, 
    energy_consumption_per_capita_kwh AS energy_cons_y,
	LAG(year) OVER(PARTITION BY country ORDER BY year) AS "year-1",
	LAG(energy_consumption_per_capita_kwh) OVER(PARTITION BY country ORDER BY year) AS "energy_cons_y-1",
    CASE
        WHEN LAG(energy_consumption_per_capita_kwh) OVER (PARTITION BY country ORDER BY year) IS NULL THEN NULL
        WHEN energy_consumption_per_capita_kwh = 0 THEN NULL
        ELSE (energy_consumption_per_capita_kwh - LAG(energy_consumption_per_capita_kwh) OVER (PARTITION BY country ORDER BY year)) / LAG(energy_consumption_per_capita_kwh) OVER (PARTITION BY country ORDER BY year)*100
    END AS energy_consumption_growth_per_capita
FROM energy_sources_00_20
WHERE country != 'Equatorial Guinea'   		--dato escluso dall'analisi comparativa in quanto con outlier (70% crescita di consumo energia pro capite)
)
SELECT cte.country, ROUND(AVG(cte.energy_consumption_growth_per_capita),2) AS "avg_energy_consumption_growth_per_capita(%)", ROUND(AVG(egi.gdp_growth),2) AS "avg_gdp_growth(%)"
FROM cte_energy_growth cte
JOIN energy_general_info_00_20  egi
ON cte.country=egi.country AND cte.year=egi.year
GROUP BY cte.country
HAVING AVG(cte.energy_consumption_growth_per_capita) IS NOT NULL
ORDER BY AVG(cte.energy_consumption_growth_per_capita)DESC
LIMIT 20;

-- A7: Non c'è una correlazione sistematica ma in generale per alti aumenti di crescita(%) del pil corrispondono alti valori di 
--     crescita(%) del consumo di energia pro capite (le due curve si seguono). 
--     Da tenere in considerazione che l`analisi è realtiva a dati mediati dal 2000 al 2020.



-- Q8: Correlazione tra il numero di forze armate ed il GDP/popolazione del Paese

SELECT *,
	ROW_NUMBER() OVER(ORDER BY gdp DESC) AS gdp_rank,
	ROW_NUMBER() OVER(ORDER BY population DESC) AS population_rank,
	ROW_NUMBER() OVER(ORDER BY armed_forces_size DESC) AS armed_forces_rank
FROM
(SELECT d.country, e.gdp, d.population, d.armed_forces_size 
FROM demographics_2023 d
JOIN economy_2023 e
ON d.country = e.country) AS economy_demographics_data
WHERE gdp IS NOT NULL AND population IS NOT NULL AND armed_forces_size IS NOT NULL
ORDER BY armed_forces_rank
LIMIT 11;

-- A8: In generale i Paesi con maggior numero di forze armate hanno una forte economia ed una estesa popolazione
--     (o uno dei due fattori), ad eccezzione della North Korea, Egitto ed Iran. Solo 5 Paesi superano il milioni di forze militari.



-- Q9: Valutazione sostituzione generazionale nei paesi sviluppati (senza immigrazione)

--creo una vista contentente i dati demografici relativi alla sostituzione generazionale nei Paesi sviluppati (GDP pro capite>15k$)
CREATE VIEW demographic_view AS
SELECT d.country, d.fertility_rate, e.gdp/population AS gdp_pro_capite,
	CASE	
		WHEN fertility_rate > 2.1 THEN 'Sostituzione generazionale garantita'  --con tasso di fertilità >2.1 è garantita la sostituzione generazionale
		ELSE 'Popolazione in invecchiamento'								   --quando inferiore non è garantita
	END AS demografia_paesi_sviluppati
FROM demographics_2023 d
JOIN economy_2023 e
ON e.country = d.country
WHERE gdp/population > 15000    --paesi sviluppati hanno gdp pro_capite >15k
;

--Richiamo la vista ed estraggo il conteggio dei Paesi sviluppati con sostituzione generazionale garantita e quelli in invecchiamento
SELECT demografia_paesi_sviluppati, COUNT(*)
FROM demographic_view 
GROUP BY demografia_paesi_sviluppati;

-- A9: Si nota come tra i 56 Paesi sviluppati (GDP pro capite >15k$) vi sia un problema di sostituzione generazionale in quanto 
--     in ben 49 di essi la sostituzione non è garantita e la popolazione è in invecchiamento


-- Q10: Confronto tra Paesi sviluppati e Paesi in via di sviluppo sull'invecchiamento della popolazione.

CREATE VIEW nations_fertility_overview AS
(
	WITH fertility_gdp (country,fertility_rate,population,gdp,gdp_pro_capite, demographic_situation, nation_status) AS   --CTE
	(
	SELECT d.country, d.fertility_rate, d.population, e.gdp, e.gdp/population AS gdp_pro_capite,
	CASE	
		WHEN fertility_rate > 2.1 THEN 'Sostituzione generazionale garantita'
		ELSE 'popolazione in invecchiamento'
	END,
	CASE 
		WHEN gdp/population >15000 THEN 'Paese sviluppato'
		ELSE 'Paese in via di sviluppo'
	END 
	FROM demographics_2023 d
	JOIN economy_2023 e
	ON e.country = d.country
	)
SELECT nation_status, demographic_situation, COUNT(demographic_situation) AS nation_count
FROM fertility_gdp
GROUP BY demographic_situation, nation_status
ORDER BY nation_status, demographic_situation
);

SELECT *, ROUND(nation_count/SUM(nation_count) OVER(PARTITION BY nation_status),2) AS "nation_percentage"
FROM nations_fertility_overview
;

-- A10: Si nota un trend inverso tra Paesi sviluppati e Paesi in via di sviluppo, con i secondi in cui la sostituzione generazionale è garantita 
--      in quasi il 70% dei casi, al contrario dei Paesi sviluppati in cui è garantita in meno del 15% dei casi.



-- Q11: Come varia l'istruzione media ed il salario medio nei vari Paesi dividendoli per categoria di reddito?

--Creo vista che categorizza lo sviluppo economico dei paesi e viene poi usata per valutazioni sull'istruzione, sanità, lavoro
CREATE VIEW economic_status (country,economy) AS
(
SELECT ec.country,
	CASE 							--categorizzazione Paesi sulla base del reddito pro capite
		WHEN gdp/population > 30000 THEN 'Paese ad alto reddito'                
		WHEN gdp/population >10000 AND gdp/population < 30000 THEN 'Paese a medio reddito'
		ELSE 'Paese a basso reddito'
	END  
FROM economy_2023 ec
JOIN demographics_2023 d
ON ec.country = d.country
);

--query che utilizza la Vista 'economic_status' per rispondere al quesito
SELECT economy,
	   ROUND(AVG(gross_tertiary_education_enrollment)) AS "avg_tertiary_education_enrollment %", 
	   ROUND(AVG(minimum_wage),2) AS "avg_minimum wage $/h"
FROM economic_status es
JOIN employment_2023 em
ON es.country = em.country
GROUP BY economy
ORDER BY economy;

-- A11: Nei paesi a più alto reddito si riscontrano maggiori livelli di istruzione e salari orari più alti



-- Q12: correlazione tra economia e situazione sanitaria del Paese 
SELECT es.economy,
	ROUND(AVG(life_expectancy),2) AS avg_life_expectancy,
	ROUND(AVG(out_of_pocket_health_expenditure),2) AS avg_out_of_pocket_health_expenditure,
 	ROUND(AVG(physicians_per_thousand),2) AS avg_phisician_per_thousand
FROM economic_status es   										--uso la vista creata precedentemente 
JOIN healthcare_2023 h
ON es.country = h.country
WHERE physicians_per_thousand IS NOT NULL
GROUP BY economy
ORDER BY economy;

-- A12: Nei paesi più sviluppati economicamente la vita media è più alta in quanto le spese sanitarie
--      sono maggiormente coperte dal servizio sanitario (pubblico/privato) e sono presenti più medici tra la popolazione



-- Q13: Considerazioni varie sul dataset 'Global Missing Migrants Dataset'


-- Q13.1: Aree del mondo raggruppate per numero di morti per migrazione dal 2014 al 2023
SELECT SUM(number_of_dead) AS total_n_dead, region_of_incident
FROM migration_incidents_14_23
GROUP BY region_of_incident
ORDER BY SUM(number_of_dead) DESC;

-- A13.1: Il mar Mediterraneo è l'area attorno a cui si consuma il maggior numero di vittime causate dall'immigrazione
--        seguito dal Nord Africa e Nord America.



-- Q13.2: Numero delle vittime e scomparsi per immigrazione per anno, divise per categorie
SELECT incident_year, 
	   SUM(number_of_dead) AS death_toll_from_immigration,
	   SUM(number_of_males) AS number_of_males,
	   SUM(number_of_females) AS number_of_females,
	   SUM(number_of_children) AS number_of_children
FROM migration_incidents_14_23
GROUP BY incident_year
ORDER BY incident_year
;

-- A13.2: L'andamento delle vittime è piuttosto costante e con una media attorno ai 3000 all'anno. 
--        Si può notare il decremento durante il periodo di restrizioni da Covid-19 (anno 2020)



-- Q13.3: Trend delle vittime per migrazione suddivise per mese ed anno nel periodo analizzato (2014-2023) 

--aggiungo colonna alla tabella che contenga il mese dell'incidente in formato numero
ALTER TABLE migration_incidents_14_23
ADD COLUMN month_number INT;

UPDATE migration_incidents_14_23
SET month_number = 
CASE LOWER(reported_month)
    WHEN 'january' THEN 1
    WHEN 'february' THEN 2
    WHEN 'march' THEN 3
    WHEN 'april' THEN 4
    WHEN 'may' THEN 5
    WHEN 'june' THEN 6
    WHEN 'july' THEN 7
    WHEN 'august' THEN 8
    WHEN 'september' THEN 9
    WHEN 'october' THEN 10
    WHEN 'november' THEN 11
    WHEN 'december' THEN 12
    ELSE NULL
END;

--Query per valutare le vittime divise per mese ed anno
SELECT  month_number AS incident_month, incident_year, 
		SUM (number_of_dead) AS monthly_deaths
FROM migration_incidents_14_23
GROUP BY incident_year, month_number
ORDER BY incident_year, month_number;



-- Q13.4: Rolling total del numero vittime ripartito per anno dal 2014 al 2023
WITH monthly_totals AS (
    SELECT 
        incident_year, 
        month_number, 
        SUM(number_of_dead) AS monthly_deaths
    FROM migration_incidents_14_23
    GROUP BY incident_year, month_number
)
SELECT 
    incident_year, 
    month_number AS incident_month,
	monthly_deaths,
    SUM(monthly_deaths) OVER (      --Running total ripartito per anno e ordianto per mese crescente
        PARTITION BY incident_year 
        ORDER BY month_number
    ) AS rolling_total_deaths
FROM monthly_totals
ORDER BY incident_year, month_number;



-- Q13.5: Valutazione dei mesi in cui si verificano piu vittime per migrazione negli anni analizzati
WITH monthly_totals AS 
(
    SELECT 
        incident_year, 
        month_number, 
        SUM(number_of_dead) AS monthly_deaths
    FROM migration_incidents_14_23
    GROUP BY incident_year, month_number
),
year_month_rank AS
(SELECT *,
	RANK () OVER(PARTITION BY incident_year ORDER BY monthly_deaths DESC) AS rank_monthly_deaths
FROM monthly_totals 
ORDER BY incident_year,month_number)
SELECT incident_year, month_number, monthly_deaths, 
	   COUNT(month_number) OVER(PARTITION BY month_number)  --quante volte quel mese risulta quello con più vittime negli anni analizzati
FROM year_month_rank
WHERE rank_monthly_deaths = 1
ORDER BY incident_year
; 

-- A13.5: Si nota come generalmente i mesi in cui si verificano maggiori vittime vanno da aprile a settembre.