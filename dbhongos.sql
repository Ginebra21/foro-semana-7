CREATE DATABASE IF NOT EXISTS fungi_toxins CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE fungi_toxins;

-- Tabla de hongos
CREATE TABLE IF NOT EXISTS fungi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  scientific_name VARCHAR(120) NOT NULL,
  common_name VARCHAR(120) NULL,
  genus VARCHAR(80) NULL,
  family VARCHAR(80) NULL,
  syndrome ENUM('hepatotóxico','nefrótóxico','neurotóxico','colinérgico','gastrointestinal','hematológico','desconocido') NOT NULL DEFAULT 'desconocido',
  region VARCHAR(160) NULL,
  edibility ENUM('venenoso','potencialmente peligroso') NOT NULL DEFAULT 'venenoso',
  notes TEXT NULL,
  INDEX (scientific_name),
  INDEX (syndrome)
) ENGINE=InnoDB;

-- Tabla de toxinas
CREATE TABLE IF NOT EXISTS toxins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  class VARCHAR(120) NULL, -- p.ej., ciclopeptídica, alcaloide, sesquiterpeno
  mechanism TEXT NULL
) ENGINE=InnoDB;

-- Relación
CREATE TABLE IF NOT EXISTS fungi_toxins (
  fungus_id INT NOT NULL,
  toxin_id INT NOT NULL,
  PRIMARY KEY (fungus_id, toxin_id),
  CONSTRAINT fk_ft_fungus FOREIGN KEY (fungus_id) REFERENCES fungi(id) ON DELETE CASCADE,
  CONSTRAINT fk_ft_toxin FOREIGN KEY (toxin_id) REFERENCES toxins(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Datos de ejemplo: toxinas
INSERT INTO toxins (name, class, mechanism) VALUES
('α-amanitina','ciclopeptídica (amatoxina)','Inhibe ARN polimerasa II → fallo hepático'),
('β-amanitina','ciclopeptídica (amatoxina)','Similar a α-amanitina'),
('falotoxinas','ciclopeptídica (falotoxina)','Se unen a F-actina; menor absorción oral'),
('orellanina','di-N-óxido de bifenil','Daño tubular renal → nefrotoxicidad diferida'),
('muscarina','alcaloide','Agonista muscarínico → síndrome colinérgico'),
('muscimol','isoxazol','Agonista GABA_A → efectos neurotóxicos'),
('ácido iboténico','isoxazol','Agonista glutamatérgico; se descarboxila a muscimol'),
('gyromitrina','hidrazona','Se metaboliza a monometilhidrazina (MMH) → neuro/Hepatotóxico'),
('illudina S','sesquiterpeno','Alquilante; daño GI'),
('psilocibina','triptafano derivado','Psicoactiva; no se considera tóxica letal típica'),
('psilocina','fenetilamina indólica','Metabolito activo de psilocibina'),
('irritantes GI','mezcla proteica','Causa gastroenteritis aguda');

-- hongos
INSERT INTO fungi (scientific_name, common_name, genus, family, syndrome, region, edibility, notes) VALUES
('Amanita phalloides','oronja verde / death cap','Amanita','Amanitaceae','hepatotóxico','Europa, América, Oceanía','venenoso','Latencia larga (6–24h), riesgo de fallo hepático'),
('Amanita virosa','angel destructor / destroying angel','Amanita','Amanitaceae','hepatotóxico','Europa, América del Norte','venenoso','Síndrome fallo hepático fulminante'),
('Galerina marginata','galerina de borde','Galerina','Strophariaceae','hepatotóxico','Hemisferio norte','venenoso','Pequeño, en madera; confusión con comestibles'),
('Cortinarius orellanus','cortinario de montaña','Cortinarius','Cortinariaceae','nefrótóxico','Europa','venenoso','Periodo de latencia 2–17 días'),
('Gyromitra esculenta','falsa colmenilla','Gyromitra','Helvellaceae','neurotóxico','Europa, NA','potencialmente peligroso','Tóxica cruda o mal preparada (gyromitrina)'),
('Clitocybe dealbata','clitocybe blanco','Clitocybe','Tricholomataceae','colinérgico','Europa','venenoso','Alta muscarina'),
('Inocybe spp.','inocybe','Inocybe','Inocybaceae','colinérgico','Global','venenoso','Numerosas especies con muscarina'),
('Amanita muscaria','matamoscas','Amanita','Amanitaceae','neurotóxico','Hemisferio norte','potencialmente peligroso','Muscimol y ácido iboténico'),
('Amanita pantherina','amanita pantera','Amanita','Amanitaceae','neurotóxico','Europa, Asia, NA','potencialmente peligroso','Similar a A. muscaria'),
('Omphalotus olearius','seta de olivo / jack-o\'-lantern','Omphalotus','Marasmiaceae','gastrointestinal','Mediterráneo, NA','venenoso','Bioluminiscente; confusión con Cantharellus'),
('Chlorophyllum molybdites','parasol verde','Chlorophyllum','Agaricaceae','gastrointestinal','Subtropical/tropical','venenoso','Causa gastroenteritis severa'),
('Lepiota brunneoincarnata','lepiota mortal','Lepiota','Agaricaceae','hepatotóxico','Europa, reportes en Asia','venenoso','Amatoxinas potentes');

-- Asociación hongo-toxina
INSERT INTO fungi_toxins (fungus_id, toxin_id)
SELECT f.id, t.id FROM fungi f JOIN toxins t ON 1=0; -- no-op para claridad

-- Amanita phalloides → amatoxinas y falotoxinas
INSERT INTO fungi_toxins (fungus_id, toxin_id)
SELECT f.id, t.id FROM fungi f, toxins t
WHERE f.scientific_name='Amanita phalloides' AND t.name IN ('α-amanitina','β-amanitina','falotoxinas');

-- Amanita virosa, Galerina marginata, Lepiota brunneoincarnata → amatoxinas
INSERT INTO fungi_toxins (fungus_id, toxin_id)
SELECT f.id, t.id FROM fungi f, toxins t
WHERE f.scientific_name IN ('Amanita virosa','Galerina marginata','Lepiota brunneoincarnata')
  AND t.name IN ('α-amanitina','β-amanitina');

-- Cortinarius orellanus → orellanina
INSERT INTO fungi_toxins (fungus_id, toxin_id)
SELECT f.id, t.id FROM fungi f, toxins t
WHERE f.scientific_name='Cortinarius orellanus' AND t.name='orellanina';

-- Clitocybe & Inocybe → muscarina
INSERT INTO fungi_toxins (fungus_id, toxin_id)
SELECT f.id, t.id FROM fungi f, toxins t
WHERE f.scientific_name IN ('Clitocybe dealbata','Inocybe spp.') AND t.name='muscarina';

-- A. muscaria / A. pantherina → muscimol + ácido iboténico
INSERT INTO fungi_toxins (fungus_id, toxin_id)
SELECT f.id, t.id FROM fungi f, toxins t
WHERE f.scientific_name IN ('Amanita muscaria','Amanita pantherina')
  AND t.name IN ('muscimol','ácido iboténico');

-- Gyromitra esculenta → gyromitrina
INSERT INTO fungi_toxins (fungus_id, toxin_id)
SELECT f.id, t.id FROM fungi f, toxins t
WHERE f.scientific_name='Gyromitra esculenta' AND t.name='gyromitrina';

-- Omphalotus olearius → illudina S
INSERT INTO fungi_toxins (fungus_id, toxin_id)
SELECT f.id, t.id FROM fungi f, toxins t
WHERE f.scientific_name='Omphalotus olearius' AND t.name='illudina S';

-- Chlorophyllum molybdites → irritantes GI
INSERT INTO fungi_toxins (fungus_id, toxin_id)
SELECT f.id, t.id FROM fungi f, toxins t
WHERE f.scientific_name='Chlorophyllum molybdites' AND t.name='irritantes GI';
