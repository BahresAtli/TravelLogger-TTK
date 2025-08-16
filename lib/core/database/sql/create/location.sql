CREATE TABLE IF NOT EXISTS location (
    locationRecordID INTEGER PRIMARY KEY,
    recordID INTEGER,
    locationOrder INTEGER,
    latitude REAL,
    longitude REAL,
    altitude REAL,
    speed REAL,
    elapsedDistance REAL,
    timeAtInstance TEXT,
    FOREIGN KEY(recordID) REFERENCES mainTable(recordID)
);