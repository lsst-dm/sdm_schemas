
-- One-time setup actions for LSST pipelines - assumes the LSST Database Schema already exists.
-- $Author$
-- $Revision$
-- $Date$
--
-- See <http://lsstdev.ncsa.uiuc.edu:8100/trac/wiki/Copyrights>
-- for copyright information.

-- ================================================= --
-- Populate lookup/mapping tables with fixed content --
-- ================================================= --

-- LSST filters
INSERT INTO prv_Filter VALUES (0,  0, 'u', NULL, 0.0, 0.0);
INSERT INTO prv_Filter VALUES (1,  0, 'g', NULL, 0.0, 0.0);
INSERT INTO prv_Filter VALUES (2,  0, 'r', NULL, 0.0, 0.0);
INSERT INTO prv_Filter VALUES (3,  0, 'i', NULL, 0.0, 0.0);
INSERT INTO prv_Filter VALUES (4,  0, 'z', NULL, 0.0, 0.0);
INSERT INTO prv_Filter VALUES (5,  0, 'y', NULL, 0.0, 0.0);
-- Additional filters used by MOPS
INSERT INTO prv_Filter VALUES (6,  0, 'w', NULL, 0.0, 0.0);
INSERT INTO prv_Filter VALUES (7,  0, 'V', NULL, 0.0, 0.0);
INSERT INTO prv_Filter VALUES (-99, 0, 'DD', NULL, 0.0, 0.0); -- dummy filter

INSERT INTO Filter(filterId, filtName, photClam, photBW) VALUES (0,  'u', 0.0, 0.0);
INSERT INTO Filter(filterId, filtName, photClam, photBW) VALUES (1,  'g', 0.0, 0.0);
INSERT INTO Filter(filterId, filtName, photClam, photBW) VALUES (2,  'r', 0.0, 0.0);
INSERT INTO Filter(filterId, filtName, photClam, photBW) VALUES (3,  'i', 0.0, 0.0);
INSERT INTO Filter(filterId, filtName, photClam, photBW) VALUES (4,  'z', 0.0, 0.0);
INSERT INTO Filter(filterId, filtName, photClam, photBW) VALUES (5,  'y', 0.0, 0.0);

INSERT INTO Filter(filterId, filtName, photClam, photBW) VALUES (6,  'w', 0.0, 0.0);
INSERT INTO Filter(filterId, filtName, photClam, photBW) VALUES (7,  'V', 0.0, 0.0);
INSERT INTO Filter(filterId, filtName, photClam, photBW) VALUES (-99, 'DD', 0.0, 0.0);



INSERT INTO mops_SSMDesc (prefix, description) VALUES ( 'S0', 'MOPS synthetic NEO');
INSERT INTO mops_SSMDesc (prefix, description) VALUES ( 'S1', 'MOPS synthetic main-belt object');
INSERT INTO mops_SSMDesc (prefix, description) VALUES ( 'St', 'MOPS synthetic Trojan');
INSERT INTO mops_SSMDesc (prefix, description) VALUES ( 'SC', 'MOPS synthetic Centaur');
INSERT INTO mops_SSMDesc (prefix, description) VALUES ( 'ST', 'MOPS synthetic trans-Neptunian object');
INSERT INTO mops_SSMDesc (prefix, description) VALUES ( 'SS', 'MOPS synthetic scattered disk object');
INSERT INTO mops_SSMDesc (prefix, description) VALUES ( 'Sc', 'MOPS synthetic comet');
INSERT INTO mops_SSMDesc (prefix, description) VALUES ( 'SM', 'MOPS synthetic control object');


-- ================================================================ --
-- Create tables in the form (ENGINE/indexes) expected by pipelines --
-- ================================================================ --

CREATE TABLE _tmpl_DIASource LIKE DIASource;

ALTER TABLE _tmpl_DIASource 
    DROP KEY ampExposureId,
    DROP KEY filterId,
    DROP KEY movingObjectId,
    DROP KEY objectId;

-- This should be a permanent table, but copy it from Object for now.
CREATE TABLE NonVarObject LIKE Object;

CREATE TABLE _tmpl_InMemoryObject LIKE Object;

ALTER TABLE _tmpl_InMemoryObject ENGINE=MEMORY;

CREATE TABLE _tmpl_InMemoryMatchPair LIKE _tmpl_MatchPair;
ALTER TABLE _tmpl_InMemoryMatchPair ENGINE=MEMORY;

CREATE TABLE _tmpl_InMemoryId LIKE _tmpl_Id;
ALTER TABLE _tmpl_InMemoryId ENGINE=MEMORY;

-- Create tables that accumulate data from per-visit tables
CREATE TABLE _mops_Prediction LIKE _tmpl_mops_Prediction;
ALTER TABLE _mops_Prediction
    ADD COLUMN visitId INTEGER NOT NULL, 
    ADD INDEX  idx_visitId (visitId);

CREATE TABLE _ap_DIASourceToObjectMatches LIKE _tmpl_MatchPair;
ALTER TABLE _ap_DIASourceToObjectMatches
    ADD COLUMN visitId INTEGER NOT NULL,
    ADD INDEX  idx_visitId (visitId);

CREATE TABLE _ap_PredToDIASourceMatches LIKE _tmpl_MatchPair;
ALTER TABLE _ap_PredToDIASourceMatches
    ADD COLUMN visitId INTEGER NOT NULL, 
    ADD INDEX  idx_visitId (visitId);

CREATE TABLE _ap_DIASourceToNewObject LIKE _tmpl_IdPair;
ALTER TABLE _ap_DIASourceToNewObject
    ADD COLUMN visitId INTEGER NOT NULL, 
    ADD INDEX  idx_visitId (visitId);
