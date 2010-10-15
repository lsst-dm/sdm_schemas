

-- Used to initialize global provenance database.
-- Notice that the main schema used in the per-run 
-- databases will be used. This script contains extras.

CREATE TABLE prv_RunDbNameToRunCode (
    runCode MEDIUMINT NOT NULL AUTO_INCREMENT,
    runDbName VARCHAR(255) NOT NULL,
    PRIMARY KEY(runCode),
    UNIQUE(runDbName)
) ENGINE=InnoDB; 
