CREATE TABLE location (
    locationRecordID INTEGER PRIMARY KEY,
    recordID INTEGER,
    locationOrder INTEGER,
    latitude TEXT,
    longitude TEXT,
    altitude TEXT,
    speed TEXT,
    elapsedDistance REAL,
    timeAtInstance TEXT,
    FOREIGN KEY(recordID) REFERENCES recordsTTK(recordID)
);