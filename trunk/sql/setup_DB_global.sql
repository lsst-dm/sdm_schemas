


-- global table for keeping run-related info
CREATE TABLE IF NOT EXISTS RunInfo (
    runInfoId INT NOT NULL AUTO_INCREMENT,   -- primary key
    dcVersion VARCHAR(16) NOT NULL,          -- DC version, eg DC3a, DC3b, DC4, ...
    runName VARCHAR(64) NOT NULL,            -- unique name of the run
    dbName VARCHAR(64) NOT NULL,             -- database name
    startDate DATETIME NOT NULL,             -- time when run was started
    endDate DATETIME,                        -- time when run ended
    initiator VARCHAR(64) NOT NULL,          -- user name of the run initiator
    nExtensions SMALLINT NOT NULL DEFAULT 0, -- number of times extension was requested
    expDate DATETIME NOT NULL,               -- date at which run expires (can be deleted)
    firstNotifDate DATETIME DEFAULT NULL,    -- date when 1st notification was sent
    finalNotifDate DATETIME DEFAULT NULL,    -- date when final notification was sent
    delDate DATETIME DEFAULT NULL,           -- deletion time or NULL
    PRIMARY KEY (runInfoId),
    UNIQUE(runName, initiator),
    INDEX (expDate)
) ENGINE=InnoDB; 



-- create stored functions / procedures
DELIMITER //

-- return value:
--  - "0000-01-01": run not found
--  - "0000-02-02": run already deleted
--  - a valid date: new expiration date

CREATE FUNCTION extendRun (
    in_runName VARCHAR(64),
    in_dcVersion VARCHAR(16),
    in_runInitiator VARCHAR(64) ) RETURNS DATETIME
BEGIN
   DECLARE n INT;
   DECLARE r DATETIME;

   -- report error if run not found
   SELECT COUNT(*) INTO n
   FROM   RunInfo
   WHERE  runName = in_runName
   AND    dcVersion = in_dcVersion
   AND    initiator = in_runInitiator;
   IF n <> 1 THEN RETURN "0000-01-01"; END IF;

   -- report error if run already deleted
   SELECT COUNT(*) INTO n
   FROM   RunInfo
   WHERE  runName = in_runName
   AND    dcVersion = in_dcVersion
   AND    initiator = in_runInitiator
   AND    delDate IS NOT NULL;
   IF n = 1 THEN RETURN "0000-02-02"; END IF;

   -- do the update
   UPDATE RunInfo
   SET    expDate = DATE_ADD(NOW(), INTERVAL 2 WEEK),
          nExtensions = nExtensions + 1,
          firstNotifDate = NULL,
          finalNotifDate = NULL
   WHERE  runName = in_runName
   AND    dcVersion = in_dcVersion
   AND    initiator = in_runInitiator
   AND    delDate IS NULL;

   SELECT DATE_ADD(NOW(), INTERVAL 2 WEEK) INTO r;
   RETURN r;
END;
//

-- marks a run as 'finished'
-- return value:
--  0 - success
-- -1 - not found
-- -2 - already closed
CREATE FUNCTION setRunFinished (
   in_runDbName VARCHAR(64) ) RETURNS INT
BEGIN
   DECLARE n INT;
   DECLARE d DATETIME;

   SELECT COUNT(*) INTO n
   FROM   RunInfo
   WHERE  dbName = in_runDbName;
   IF n <> 1 THEN RETURN -1; END IF;

   SELECT endDate INTO d
   FROM   RunInfo
   WHERE  dbName = in_runDbName;
   IF (d IS NOT NULL) THEN RETURN -2; END IF;

   UPDATE RunInfo
   SET endDate = NOW()
   WHERE dbName = in_runDbName;

   RETURN 0;
END
//

CREATE FUNCTION setRunDeleted (
   in_runDbName VARCHAR(64) ) RETURNS INT
BEGIN
   DECLARE n INT;

   SELECT COUNT(*) INTO n
   FROM   RunInfo
   WHERE  dbName = in_runDbName;
   IF n <> 1 THEN RETURN -1; END IF;

   UPDATE RunInfo 
   SET delDate = NOW()
   WHERE dbName = in_runDbName;

   RETURN 0;
END
//


DELIMITER ;


-- See http://bugs.mysql.com/bug.php?id=47843
-- for more details
UPDATE mysql.db SET Execute_priv = 'Y' WHERE Db = 'test' OR Db = 'test\_%';
FLUSH PRIVILEGES;

