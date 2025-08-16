CREATE TABLE temp_location (
	locationRecordID INTEGER,
	recordID INTEGER,
	locationOrder INTEGER,
	latitude REAL,
	longitude REAL,
	timeAtInstance TEXT,
	altitude REAL,
	speed REAL,
	elapsedDistance REAL,
	PRIMARY KEY(locationRecordID),
	FOREIGN KEY(recordID) REFERENCES mainTable(recordID)
);

INSERT INTO temp_location SELECT * FROM location;

DROP TABLE location;

ALTER TABLE temp_location RENAME TO location;
