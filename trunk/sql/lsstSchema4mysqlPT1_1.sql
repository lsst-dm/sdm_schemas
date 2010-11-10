
-- LSST Database Schema
-- $Author$
-- $Revision$
-- $Date$
--
-- See <http://lsstdev.ncsa.uiuc.edu/trac/wiki/Copyrights>
-- for copyright information.


CREATE TABLE AAA_Version_3_1_88 (version CHAR);

SET FOREIGN_KEY_CHECKS=0;


CREATE TABLE prv_Activity
(
	activityId INTEGER NOT NULL,
	offset MEDIUMINT NOT NULL,
	name VARCHAR(64) NOT NULL,
	type VARCHAR(64) NOT NULL,
	platform VARCHAR(64) NOT NULL,
	PRIMARY KEY (activityId, offset)
) ;


CREATE TABLE prv_cnf_PolicyKey
(
	policyKeyId INTEGER NOT NULL,
	value TEXT NULL,
	validityBegin DATETIME NULL,
	validityEnd DATETIME NULL,
	PRIMARY KEY (policyKeyId)
) ;


CREATE TABLE prv_cnf_SoftwarePackage
(
	packageId INTEGER NOT NULL,
	version VARCHAR(255) NOT NULL,
	directory VARCHAR(255) NOT NULL,
	validityBegin DATETIME NULL,
	validityEnd DATETIME NULL,
	PRIMARY KEY (packageId)
) ;


CREATE TABLE prv_Filter
(
	filterId TINYINT NOT NULL,
	focalPlaneId TINYINT NOT NULL,
	name VARCHAR(80) NOT NULL,
	url VARCHAR(255) NULL,
	clam FLOAT(0) NOT NULL,
	bw FLOAT(0) NOT NULL,
	PRIMARY KEY (filterId),
	UNIQUE name(name),
	INDEX focalPlaneId (focalPlaneId ASC)
) TYPE=MyISAM;


CREATE TABLE prv_PolicyFile
(
	policyFileId INTEGER NOT NULL,
	pathName VARCHAR(255) NOT NULL,
	hashValue CHAR(32) NOT NULL,
	modifiedDate BIGINT NOT NULL,
	PRIMARY KEY (policyFileId)
) ;


CREATE TABLE prv_PolicyKey
(
	policyKeyId INTEGER NOT NULL,
	policyFileId INTEGER NOT NULL,
	keyName VARCHAR(255) NOT NULL,
	keyType VARCHAR(16) NOT NULL,
	PRIMARY KEY (policyKeyId),
	KEY (policyFileId)
) ;


CREATE TABLE prv_Run
(
	offset MEDIUMINT NOT NULL AUTO_INCREMENT,
	runId VARCHAR(255) NOT NULL,
	PRIMARY KEY (offset),
	UNIQUE UQ_prv_Run_runId(runId)
) ;


CREATE TABLE prv_SoftwarePackage
(
	packageId INTEGER NOT NULL,
	packageName VARCHAR(64) NOT NULL,
	PRIMARY KEY (packageId)
) ;


CREATE TABLE Durations
(
	id INTEGER NOT NULL AUTO_INCREMENT,
	RUNID VARCHAR(80) NULL,
	name VARCHAR(80) NULL,
    stagename VARCHAR(80) NULL,
	SLICEID INTEGER NULL DEFAULT -1,
	duration BIGINT NULL,
	HOSTID VARCHAR(80) NULL,
	LOOPNUM INTEGER NULL DEFAULT -1,
	STAGEID INTEGER NULL DEFAULT -1,
	PIPELINE VARCHAR(80) NULL,
	COMMENT VARCHAR(255) NULL,
	start VARCHAR(80) NULL,
	userduration BIGINT NULL,
	systemduration BIGINT NULL,
	PRIMARY KEY (id),
	INDEX dur_runid (RUNID ASC),
	INDEX idx_durations_pipeline (PIPELINE ASC),
	INDEX idx_durations_name (name ASC)
) ;


CREATE TABLE Logs
(
	id INTEGER NOT NULL AUTO_INCREMENT,
	HOSTID VARCHAR(80) NULL,
	RUNID VARCHAR(80) NULL,
	LOG VARCHAR(80) NULL,
	workerid VARCHAR(80) NULL,
    stagename VARCHAR(80) NULL,
	SLICEID INTEGER NULL,
	STAGEID INTEGER NULL,
	LOOPNUM INTEGER NULL,
	STATUS VARCHAR(80) NULL,
	LEVEL INTEGER NULL DEFAULT 9999,
	DATE VARCHAR(30) NULL,
	TIMESTAMP BIGINT NULL,
	node INTEGER NULL,
	custom VARCHAR(4096) NULL,
	timereceived TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	visitid INTEGER NULL,
	COMMENT TEXT NULL,
	PIPELINE VARCHAR(80) NULL,
	TYPE VARCHAR(5) NULL,
	EVENTTIME BIGINT NULL,
	PUBTIME BIGINT NULL,
	usertime BIGINT NULL,
	systemtime BIGINT NULL,
	PRIMARY KEY (id),
	INDEX a (RUNID ASC)
) ;



SET FOREIGN_KEY_CHECKS=1;


ALTER TABLE prv_cnf_PolicyKey ADD CONSTRAINT FK_prv_cnf_PolicyKey_prv_PolicyKey 
	FOREIGN KEY (policyKeyId) REFERENCES prv_PolicyKey (policyKeyId);

ALTER TABLE prv_cnf_SoftwarePackage ADD CONSTRAINT FK_prv_cnf_SoftwarePackage_prv_SoftwarePackage 
	FOREIGN KEY (packageId) REFERENCES prv_SoftwarePackage (packageId);

ALTER TABLE prv_PolicyKey ADD CONSTRAINT FK_prv_PolicyKey_prv_PolicyFile 
	FOREIGN KEY (policyFileId) REFERENCES prv_PolicyFile (policyFileId);
