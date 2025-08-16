CREATE TABLE temp_mainTable (
	recordID INTEGER,
	startTime TEXT,
	endTime TEXT,
	elapsedMilisecs INTEGER,
	startLatitude REAL,
	startLongitude REAL,
	endLatitude REAL,
	endLongitude REAL,
	label	TEXT,
	startAltitude	REAL,
	endAltitude REAL,
	distance REAL,
	PRIMARY KEY(recordID)
);

INSERT INTO temp_mainTable SELECT * FROM mainTable;

DROP TABLE mainTable;

ALTER TABLE temp_mainTable RENAME TO mainTable;