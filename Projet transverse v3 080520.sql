-- Load Data
-- Client
drop table IF EXISTS client;
create table client (
	IDCLIENT_BRUT real primary key, 
	CIVILITE varchar(10),
	DATENAISSANCE timestamp,
	MAGASIN varchar(15),
	DATEDEBUTADHESION timestamp,
	DATEREADHESION timestamp,
	DATEFINADHESION timestamp,
	VIP integer,
	CODEINSEE varchar(10),
	PAYS varchar(10)
);

COPY client FROM 'C:\DATA_Projet_R\CLIENT.CSV' CSV HEADER delimiter '|' null '';

---TRANSFORMATION IDCLIENT_BRUT
ALTER TABLE client ADD IDCLIENT bigint;
UPDATE client SET IDCLIENT =  CAST(IDCLIENT_BRUT AS bigint);
ALTER TABLE client DROP IDCLIENT_BRUT;
ALTER TABLE client ADD PRIMARY KEY (IDCLIENT);

-- Entete_Ticket
drop table IF EXISTS entete_ticket;
create table entete_ticket 
(
	IDTICKET bigint primary key,
	TIC_DATE timestamp,
	MAG_CODE varchar(15),
	IDCLIENT_BRUT real,
	TIC_TOTALTTC_BRUT varchar(10) --money
);

COPY entete_ticket FROM 'C:\DATA_Projet_R\ENTETES_TICKET_V4.CSV' CSV HEADER delimiter '|' null '';

---TRANSFORMATION TIC_TOTALTTC_BRUT
ALTER TABLE entete_ticket ADD TIC_TOTALTTC float;
UPDATE entete_ticket SET TIC_TOTALTTC =  CAST(REPLACE(TIC_TOTALTTC_BRUT , ',', '.') AS float);
ALTER TABLE entete_ticket DROP TIC_TOTALTTC_BRUT;

---TRANSFORMATION IDCLIENT_BRUT
ALTER TABLE entete_ticket ADD IDCLIENT bigint;
UPDATE entete_ticket SET IDCLIENT =  CAST(IDCLIENT_BRUT AS bigint);
ALTER TABLE entete_ticket DROP IDCLIENT_BRUT;

-- Ligne_ticket

drop table IF EXISTS lignes_ticket;
create table lignes_ticket 
(
	IDTICKET bigint,
	NUMLIGNETICKET integer,
	IDARTICLE varchar(15), --ligne avec 'COUPON'
	QUANTITE_BRUT varchar(15),
	MONTANTREMISE_BRUT varchar(15),
	TOTAL_BRUT varchar(15),
	MARGESORTIE_BRUT varchar(15)
);

COPY lignes_ticket FROM 'C:\DATA_Projet_R\LIGNES_TICKET_V4.CSV' CSV HEADER delimiter '|' null '';

---TRANSFORMATION QUANTITE_BRUT
ALTER TABLE lignes_ticket ADD QUANTITE float;
UPDATE lignes_ticket SET QUANTITE =  CAST(REPLACE(QUANTITE_BRUT , ',', '.') AS float);
ALTER TABLE lignes_ticket DROP QUANTITE_BRUT;

---TRANSFORMATION MONTANTREMISE_BRUT
ALTER TABLE lignes_ticket ADD MONTANTREMISE float;
UPDATE lignes_ticket SET MONTANTREMISE =  CAST(REPLACE(MONTANTREMISE_BRUT , ',', '.') AS float);
ALTER TABLE lignes_ticket DROP MONTANTREMISE_BRUT;

---TRANSFORMATION TOTAL_BRUT
ALTER TABLE lignes_ticket ADD TOTAL float;
UPDATE lignes_ticket SET TOTAL =  CAST(REPLACE(TOTAL_BRUT , ',', '.') AS float);
ALTER TABLE lignes_ticket DROP TOTAL_BRUT;

---TRANSFORMATION MARGESORTIE_BRUT
ALTER TABLE lignes_ticket ADD MARGESORTIE float;
UPDATE lignes_ticket SET MARGESORTIE =  CAST(REPLACE(MARGESORTIE_BRUT , ',', '.') AS float);
ALTER TABLE lignes_ticket DROP MARGESORTIE_BRUT;

-- REF_MAGASIN

drop table IF EXISTS ref_magasin;
create table ref_magasin 
(
	CODESOCIETE varchar(15) primary key,
	VILLE varchar(50),
	LIBELLEDEPARTEMENT integer,
	LIBELLEREGIONCOMMERCIALE varchar(15)
);

COPY ref_magasin FROM 'C:\DATA_Projet_R\REF_MAGASIN.CSV' CSV HEADER delimiter '|' null '';

-- REF_ARTICLE
drop table IF EXISTS ref_article;
create table ref_article 
(
	CODEARTICLE varchar(15) primary key,
	CODEUNIVERS varchar(15),
	CODEFAMILLE varchar(15),
	CODESOUSFAMILLE varchar(15)
);

COPY ref_article FROM 'C:\DATA_Projet_R\REF_ARTICLE.CSV' CSV HEADER delimiter '|' null '';

-- 1. Etude global
select vip, new_n2, new_n1, adherent, churner
from (select vip as factor, count(*) as vip from client 
	  group by vip) as temp0
join (select vip as factor, count(*) as new_n2 from client
	  where extract(year from datedebutadhesion) = 2016
	  group by vip) as temp1
using(factor)
join (select vip as factor, count(*) as new_n1 from client
	  where extract(year from datedebutadhesion) = 2017
	  group by vip) as temp2
using(factor)
join (select vip as factor, count(*) as adherent from client
	  where extract(year from datefinadhesion) >= 2018
	  group by vip) as temp3
using(factor)
join(select vip as factor, count(*) as churner from client 
	 where extract(year from datefinadhesion) < 2018 
	 group by vip) as temp4
using(factor)
where factor = 1;

-- b. Comportement du CA GLOBAL par client N-2 vs N-1
select temp_data.idclient_brut, case when annee = 2016 then sum_ca else NULL end as ca_2016, 
								case when annee = 2017 then sum_ca else NULL end as ca_2017
from(
	select idclient_brut, extract(year from datedebutadhesion) as annee, sum(tic_totalttc) as sum_ca
	from lignes_ticket inner join entete_ticket on lignes_ticket.idticket = entete_ticket.idticket
	inner join client on entete_ticket.idclient = client.idclient_brut
	where extract(year from datedebutadhesion) = 2016 or extract(year from datedebutadhesion) = 2017
	group by idclient_brut, extract(year from datedebutadhesion)) as temp_data
group by 1, 2, 3
order by 1;

-- Répartition par âge x sexe: 
-- Constituer un graphique montrant la répartition par âge x sexe sur l'ensemble des clients.
-- Ajouter la colonne gender
alter table client add gender character(10);
update client set gender = (case when lower(civilite) = 'monsieur' then 'male'
							when lower(civilite) = 'madame' then 'female'
							when civilite = 'Mr' then 'male'
							when civilite = 'Mme' then 'female' end);
-- Ajouter la colonne age
alter table client add age real;
update client set age = 2020 - extract(year from datenaissance);

-- Ajouter la colonne qui concatenate age et gender
alter table client add age_sex character(20);
update client set age_sex = concat(gender, age);

-- Je ne tiens pas en compte des valeurs inférieures à 18 et supérieures à 100
select gender, age, round(num/(select sum(num) from (select gender, age, count(age_sex) as num
											   from client 
											   where age is not null and (age >= 18 and age <= 100)
											   group by gender, age) as temp2)*100, 2) as pct
from (select gender, age, count(age_sex) as num
	  from client 
	  where age is not null and (age >= 18 and age <= 100)
	  group by gender, age) as temp1
group by gender, age, num;

-- 2. Etude par magasin
-- a. Résultat par magasin (+1 ligne Total)
select * from
(select *,
		case 
		when pct_nb_actif > 0 AND dif_ttc > 0 then 'positive'
		when pct_nb_actif < 0 AND dif_ttc < 0 then 'negative'
		else 'moyen' end as indice_evol
 from
 (select codesociete, 
		Nb_client, 
		Nb_client_actif_2016, Nb_client_actif_2017, pct_nb_actif,
		total_ttc_2016, total_ttc_2017, dif_ttc
  from
  (select codesociete, 
		Nb_client, 
		Nb_client_actif_2016, 
		Nb_client_actif_2017, 
		pct_nb_actif
   from (select ref_magasin.codesociete, count(client.idclient_brut) as Nb_client
		 from ref_magasin inner join client on ref_magasin.codesociete = client.magasin
		 and ref_magasin.codesociete is not null
		 group by ref_magasin.codesociete) as mydata_temp3
   join
   (select codesociete, 
		Nb_client_actif_2016, Nb_client_actif_2017,
		round((Nb_client_actif_2017 - Nb_client_actif_2016) * 1.0 / Nb_client_actif_2016, 3) as pct_nb_actif
	from 
	(select ref_magasin.codesociete, count(idclient_brut) as Nb_client_actif_2016
			 from client inner join entete_ticket on client.idclient_brut = entete_ticket.idclient
			 inner join ref_magasin on ref_magasin.codesociete = client.magasin
			 where extract (year from entete_ticket.tic_date) = 2016 and ref_magasin.codesociete is not null
	 group by ref_magasin.codesociete) as mydata_temp8
	join
	(select ref_magasin.codesociete, count(idclient_brut) as Nb_client_actif_2017
			 from client inner join entete_ticket on client.idclient_brut = entete_ticket.idclient
			 inner join ref_magasin on ref_magasin.codesociete = client.magasin
			 where extract (year from entete_ticket.tic_date) = 2017 and ref_magasin.codesociete is not null
	 group by ref_magasin.codesociete) as mydata_temp2
	using (codesociete)) as mydata_temp4
   using (codesociete)) as mydata_temp5
  join
  (select codesociete,
		total_ttc_2016, total_ttc_2017,
		(total_ttc_2017 - total_ttc_2016) as dif_ttc
   from
   (select ref_magasin.codesociete, sum(tic_totalttc) as total_ttc_2016
	from ref_magasin inner join entete_ticket on ref_magasin.codesociete = entete_ticket.mag_code
	where extract (year from entete_ticket.tic_date) = 2016 and ref_magasin.codesociete is not null
	group by ref_magasin.codesociete) mydata_temp1
   join
   (select ref_magasin.codesociete, sum(tic_totalttc) as total_ttc_2017
	from ref_magasin inner join entete_ticket on ref_magasin.codesociete = entete_ticket.mag_code
	where extract (year from entete_ticket.tic_date) = 2017 and ref_magasin.codesociete is not null
	group by ref_magasin.codesociete) mydata_temp2
   using (codesociete)) as mydata_temp
  using (codesociete)) as mydata_temp6) as mydata_temp7
  order by case 
  when indice_evol = 'positive' then 1
  when indice_evol = 'moyen' then 2
  when indice_evol = 'negative' then 3
  end;

-- b. Distance
-- Load Data: insee
drop table if exists insee;
create table insee (
	codeinsee varchar(10) primary key, 
	codepostal varchar(200),
	commune varchar(50),
	departement varchar(50),
	region varchar(50),
	statut varchar(50),
	alitude_moyenne decimal,
	superficie decimal,
	population decimal,
	geo_point_2d varchar(200),
	geo_shape varchar(2000000),
	id_geofla varchar(10),
	code_commune varchar(10),
	code_canton varchar(10),
	code_arrondissement varchar(10),
	code_departement varchar(10),
	code_region varchar(10)
);

COPY insee FROM 'C:\DATA_Projet_R\INSEE.CSV' CSV HEADER delimiter ';' null '';

-- Table that combine client, magasin and their long and lat
-- La fonction customisée pour calculer la distance étant donné les valeurs longtitude et latitude
create or replace function calculate_distance(lat_client float, 
											  long_client float, 
											  lat_mag float, 
											  long_mag float)
returns float as $distance$ declare distance float = 0; 
begin
	distance = sin(pi() * lat_client / 180) 
				* sin(pi() * lat_mag / 180) 
				+ cos(pi() * lat_client / 180) 
				* cos(pi() * lat_mag / 180) 
				* cos(pi() * (long_client - long_mag) / 180);
	if distance > 1 then distance = 1; end if;
	distance = (acos(distance) * 180 / pi()) * 60 * 1.1515 * 1.609344;
-- 1 mile = 1.609344 kilometers
-- https://stackoverflow.com/questions/389211/geospatial-coordinates-and-distance-in-kilometers
	return distance;
end;
$distance$ language plpgsql;

-- Extract long lat for client and magasin and calculate distance using the customized function
copy(
select *,
		case 
		when dist_km <= 5 then '[0;5]'
		when dist_km > 5 and dist_km <= 10 then '(5;10]'
		when dist_km > 10 and dist_km <= 20 then '(10;20]'
		when dist_km > 20 and dist_km <= 50 then '(20;50]'
		else '>50' end as dist_km_interval
from
(select idclient_brut, lat_client, long_client, 
		magasin, lat_mag , long_mag,
		calculate_distance(cast(lat_client as float), cast(long_client as float), cast(lat_mag as float), cast(long_mag as float)) as dist_km
from
(select client.idclient_brut, client.magasin, mydata_temp1.long_client, mydata_temp1.lat_client from client 
 join
 -- Long Lat Client
(select idclient_brut, 
    case when position(',' in geo_point_2d) > 0 
         then substring(geo_point_2d, 1, position(',' in geo_point_2d) -1) 
         else geo_point_2d end as long_client,
    case when position(',' in geo_point_2d) > 0 
         then substring(geo_point_2d, position(',' in geo_point_2d) +1, length(geo_point_2d))  
         else null end as lat_client
from insee inner join client on insee.codeinsee = client.codeinsee) as mydata_temp1
using (idclient_brut)) as mydata_temp3
join
(select codesociete as magasin, long_mag, lat_mag
from ref_magasin
join
-- Long Lat Magasin
(select ville, 
    case when position(',' in geo_point_2d) > 0 
         then substring(geo_point_2d, 1, position(',' in geo_point_2d) -1) 
         else geo_point_2d end long_mag, 
    case when position(',' in geo_point_2d) > 0 
         then substring(geo_point_2d, position(',' in geo_point_2d) +1, length(geo_point_2d))  
         else null end as lat_mag
from insee inner join ref_magasin on insee.commune = ref_magasin.ville) as mydata_temp2
using(ville)) as mydata_temp4
using(magasin)) as mydata_temp5
group by 8, 1, 2, 3, 4, 5, 6, 7) to 'C:\DATA_Projet_R\2bfix.CSV' CSV HEADER delimiter '|' null '';

-- 3. Etude par univers
-- a. ETUDE PAR UNIVERS: Constituer un histogramme N-2 / N-1 évolution du CA par univers
select codeunivers, ca_2016, ca_2017, (ca_2017 - ca_2016) as diff_ca
from
(select codeunivers, sum(total) as ca_2016
 from lignes_ticket inner join entete_ticket on lignes_ticket.idticket = entete_ticket.idticket
 inner join ref_article on lignes_ticket.idarticle = ref_article.codearticle
 where extract(year from tic_date) = 2016
 group by codeunivers) as mydata_temp1
join
(select codeunivers, sum(total) as ca_2017
 from lignes_ticket inner join entete_ticket on lignes_ticket.idticket = entete_ticket.idticket
 inner join ref_article on lignes_ticket.idarticle = ref_article.codearticle
 where extract(year from tic_date) = 2017
 group by codeunivers) as mydata_temp2
using(codeunivers);

-- b. TOP PAR UNIVERS: Afficher le top 5 des familles les plus rentable par univers (en fonction de la marge obtenu) (tableau ou graphique -> au choix)
select *
from
(select codeunivers, codesousfamille, rentab, 
       row_number() over (partition by codeunivers order by rentab desc) as temp_rank 
 from 
 (select codeunivers, codesousfamille, sum(margesortie) as rentab
  from ref_article inner join lignes_ticket on ref_article.codearticle = lignes_ticket.idarticle
  group by codesousfamille, codeunivers) as mydata_temp1) as mydata_temp2
  where temp_rank <= 5;