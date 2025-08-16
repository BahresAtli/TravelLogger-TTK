CREATE TABLE IF NOT EXISTS mainTable (
    recordID INTEGER PRIMARY KEY,
    startTime TEXT,
    endTime TEXT,
    elapsedMilisecs INTEGER,
    distance REAL,
    startLatitude REAL,
    startLongitude REAL,
    startAltitude REAL,
    endLatitude REAL,
    endLongitude REAL,
    endAltitude REAL,
    label TEXT
);