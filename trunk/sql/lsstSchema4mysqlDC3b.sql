
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


CREATE TABLE _MovingObjectToType
(
	movingObjectId BIGINT NOT NULL,
	typeId SMALLINT NOT NULL,
	probability TINYINT NULL DEFAULT 100,
	KEY (typeId),
	KEY (movingObjectId)
) ;


CREATE TABLE _ObjectToType
(
	objectId BIGINT NOT NULL,
	typeId SMALLINT NOT NULL,
	probability TINYINT NULL DEFAULT 100,
	KEY (typeId),
	KEY (objectId)
) ;


CREATE TABLE _qservChunkMap
(
	raMin DOUBLE NOT NULL,
	raMax DOUBLE NOT NULL,
	declMin DOUBLE NOT NULL,
	declMax DOUBLE NOT NULL,
	chunkId INTEGER NOT NULL,
	objCount INTEGER NOT NULL
) ;


CREATE TABLE _qservObjectIdMap
(
	objectId BIGINT NOT NULL,
	chunkId INTEGER NOT NULL,
	subChunkId INTEGER NOT NULL
) ;


CREATE TABLE _qservSubChunkMap
(
	raMin DOUBLE NOT NULL,
	raMax DOUBLE NOT NULL,
	declMin DOUBLE NOT NULL,
	declMax DOUBLE NOT NULL,
	chunkId INTEGER NOT NULL,
	subChunkId INTEGER NOT NULL,
	objCount INTEGER NOT NULL
) ;


CREATE TABLE _tmpl_Id
(
	id BIGINT NOT NULL
) ;


CREATE TABLE _tmpl_IdPair
(
	first BIGINT NOT NULL,
	second BIGINT NOT NULL
) ;


CREATE TABLE _tmpl_MatchPair
(
	first BIGINT NOT NULL,
	second BIGINT NOT NULL,
	distance DOUBLE NOT NULL
) ;


CREATE TABLE Ccd_Detector
(
	ccdDetectorId INTEGER NOT NULL DEFAULT 1,
	biasSec VARCHAR(20) NOT NULL DEFAULT '[0:0,0:0]',
	trimSec VARCHAR(20) NOT NULL DEFAULT '[0:0,0:0]',
	gain FLOAT(0) NULL,
	rdNoise FLOAT(0) NULL,
	saturate FLOAT(0) NULL,
	PRIMARY KEY (ccdDetectorId)
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


CREATE TABLE Filter
(
	filterId TINYINT NOT NULL,
	filterName CHAR(255) NOT NULL,
	photClam FLOAT(0) NOT NULL,
	photBW FLOAT(0) NOT NULL,
	PRIMARY KEY (filterId)
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


CREATE TABLE ObjectType
(
	typeId SMALLINT NOT NULL,
	description VARCHAR(255) NULL,
	PRIMARY KEY (typeId)
) ;


CREATE TABLE sdqa_ImageStatus
(
	sdqa_imageStatusId SMALLINT NOT NULL AUTO_INCREMENT,
	statusName VARCHAR(30) NOT NULL,
	definition VARCHAR(255) NOT NULL,
	PRIMARY KEY (sdqa_imageStatusId)
) ;


CREATE TABLE sdqa_Metric
(
	sdqa_metricId SMALLINT NOT NULL AUTO_INCREMENT,
	metricName VARCHAR(30) NOT NULL,
	physicalUnits VARCHAR(30) NOT NULL,
	dataType CHAR(1) NOT NULL,
	definition VARCHAR(255) NOT NULL,
	PRIMARY KEY (sdqa_metricId),
	UNIQUE UQ_sdqaMetric_metricName(metricName)
) ;


CREATE TABLE sdqa_Rating_ForScienceAmpExposure
(
	sdqa_ratingId BIGINT NOT NULL AUTO_INCREMENT,
	sdqa_metricId SMALLINT NOT NULL,
	sdqa_thresholdId SMALLINT NOT NULL,
	ampExposureId BIGINT NOT NULL,
	metricValue DOUBLE NOT NULL,
	metricSigma DOUBLE NOT NULL,
	PRIMARY KEY (sdqa_ratingId),
	UNIQUE UQ_sdqaRating_ForScienceAmpExposure_metricId_ampExposureId(sdqa_metricId, ampExposureId),
	KEY (sdqa_metricId),
	KEY (sdqa_thresholdId),
	KEY (ampExposureId)
) ;


CREATE TABLE sdqa_Rating_ForScienceCcdExposure
(
	sdqa_ratingId BIGINT NOT NULL AUTO_INCREMENT,
	sdqa_metricId SMALLINT NOT NULL,
	sdqa_thresholdId SMALLINT NOT NULL,
	ccdExposureId BIGINT NOT NULL,
	metricValue DOUBLE NOT NULL,
	metricSigma DOUBLE NOT NULL,
	PRIMARY KEY (sdqa_ratingId),
	UNIQUE UQ_sdqa_Rating_ForScienceCCDExposure_metricId_ccdExposureId(sdqa_metricId, ccdExposureId),
	KEY (sdqa_metricId),
	KEY (sdqa_thresholdId),
	KEY (ccdExposureId)
) ;


CREATE TABLE sdqa_Threshold
(
	sdqa_thresholdId SMALLINT NOT NULL AUTO_INCREMENT,
	sdqa_metricId SMALLINT NOT NULL,
	upperThreshold DOUBLE NULL,
	lowerThreshold DOUBLE NULL,
	createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (sdqa_thresholdId),
	UNIQUE UQ_sdqa_Threshold_sdqa_metricId(sdqa_metricId),
	KEY (sdqa_metricId)
) ;


CREATE TABLE _mops_Config
(
	configId BIGINT NOT NULL AUTO_INCREMENT,
	configText TEXT NULL,
	PRIMARY KEY (configId)
) ;


CREATE TABLE _mops_EonQueue
(
	movingObjectId BIGINT NOT NULL,
	eventId BIGINT NOT NULL,
	insertTime TIMESTAMP NOT NULL,
	status CHAR(1) NULL DEFAULT 'I',
	PRIMARY KEY (movingObjectId),
	INDEX idx__mopsEonQueue_eventId (eventId ASC)
) ;


CREATE TABLE _mops_MoidQueue
(
	movingObjectId BIGINT NOT NULL,
	movingObjectVersion INT NOT NULL,
	eventId BIGINT NOT NULL,
	insertTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (movingObjectId, movingObjectVersion),
	KEY (movingObjectId),
	INDEX idx_mopsMoidQueue_eventId (eventId ASC)
) ;


CREATE TABLE _tmpl_mops_Ephemeris
(
	movingObjectId BIGINT NOT NULL,
	movingObjectVersion INTEGER NOT NULL,
	ra DOUBLE NOT NULL,
	decl DOUBLE NOT NULL,
	mjd DOUBLE NOT NULL,
	smia DOUBLE NULL,
	smaa DOUBLE NULL,
	pa DOUBLE NULL,
	mag DOUBLE NULL,
	INDEX idx_mopsEphemeris_movingObjectId (movingObjectId ASC)
) TYPE=MyISAM;


CREATE TABLE _tmpl_mops_Prediction
(
	movingObjectId BIGINT NOT NULL,
	movingObjectVersion INTEGER NOT NULL,
	ra DOUBLE NOT NULL,
	decl DOUBLE NOT NULL,
	mjd DOUBLE NOT NULL,
	smia DOUBLE NOT NULL,
	smaa DOUBLE NOT NULL,
	pa DOUBLE NOT NULL,
	mag DOUBLE NOT NULL,
	magErr FLOAT(0) NOT NULL
) TYPE=MyISAM;


CREATE TABLE mops_Event
(
	eventId BIGINT NOT NULL AUTO_INCREMENT,
	procHistoryId INT NOT NULL,
	eventType CHAR(1) NOT NULL,
	eventTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	movingObjectId BIGINT NULL,
	movingObjectVersion INT NULL,
	orbitCode CHAR(1) NULL,
	d3 FLOAT(0) NULL,
	d4 FLOAT(0) NULL,
	ccdExposureId BIGINT NULL,
	classification CHAR(1) NULL,
	ssmId BIGINT NULL,
	PRIMARY KEY (eventId),
	KEY (movingObjectId),
	INDEX idx_mopsEvent_ccdExposureId (ccdExposureId ASC),
	INDEX idx_mopsEvent_movingObjectId (movingObjectId ASC, movingObjectVersion ASC),
	INDEX idx_mopsEvent_procHistoryId (procHistoryId ASC),
	INDEX idx_mopsEvent_ssmId (ssmId ASC)
) ;


CREATE TABLE mops_Event_OrbitDerivation
(
	eventId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	PRIMARY KEY (eventId, trackletId),
	INDEX idx_mopsEventDerivation_trackletId (trackletId ASC),
	KEY (eventId)
) ;


CREATE TABLE mops_Event_OrbitIdentification
(
	eventId BIGINT NOT NULL,
	childObjectId BIGINT NOT NULL,
	PRIMARY KEY (eventId),
	INDEX idx_mopsEventOrbitIdentification2MovingObject_childObjectId (childObjectId ASC)
) ;


CREATE TABLE mops_Event_TrackletAttribution
(
	eventId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	ephemerisDistance FLOAT(0) NOT NULL,
	ephemerisUncertainty FLOAT(0) NULL,
	PRIMARY KEY (eventId),
	INDEX idx_mopsEventTrackletAttribution_trackletId (trackletId ASC)
) ;


CREATE TABLE mops_Event_TrackletPrecovery
(
	eventId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	ephemerisDistance FLOAT(0) NOT NULL,
	ephemerisUncertainty FLOAT(0) NULL,
	PRIMARY KEY (eventId),
	INDEX idx_mopsEventTrackletPrecovery_trackletId (trackletId ASC)
) ;


CREATE TABLE mops_Event_TrackletRemoval
(
	eventId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	PRIMARY KEY (eventId),
	INDEX idx_mopsEventTrackletRemoval_trackletId (trackletId ASC)
) ;


CREATE TABLE mops_MovingObjectToTracklet
(
	movingObjectId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	INDEX idx_mopsMovingObjectToTracklets_movingObjectId (movingObjectId ASC),
	INDEX idx_mopsMovingObjectToTracklets_trackletId (trackletId ASC)
) ;


CREATE TABLE mops_SSM
(
	ssmId BIGINT NOT NULL AUTO_INCREMENT,
	ssmDescId SMALLINT NULL,
	q DOUBLE NOT NULL,
	e DOUBLE NOT NULL,
	i DOUBLE NOT NULL,
	node DOUBLE NOT NULL,
	argPeri DOUBLE NOT NULL,
	timePeri DOUBLE NOT NULL,
	epoch DOUBLE NOT NULL,
	h_v DOUBLE NOT NULL,
	h_ss DOUBLE NULL,
	g DOUBLE NULL,
	albedo DOUBLE NULL,
	ssmObjectName VARCHAR(32) NOT NULL,
	PRIMARY KEY (ssmId),
	UNIQUE UQ_mopsSSM_ssmObjectName(ssmObjectName),
	INDEX idx_mopsSSM_ssmDescId (ssmDescId ASC),
	INDEX idx_mopsSSM_epoch (epoch ASC)
) ;


CREATE TABLE mops_SSMDesc
(
	ssmDescId SMALLINT NOT NULL AUTO_INCREMENT,
	prefix CHAR(4) NULL,
	description VARCHAR(100) NULL,
	PRIMARY KEY (ssmDescId)
) ;


CREATE TABLE mops_Tracklet
(
	trackletId BIGINT NOT NULL AUTO_INCREMENT,
	ccdExposureId BIGINT NOT NULL,
	procHistoryId INT NOT NULL,
	ssmId BIGINT NULL,
	velRa DOUBLE NULL,
	velRaErr DOUBLE NULL,
	velDecl DOUBLE NULL,
	velDeclErr DOUBLE NULL,
	velTot DOUBLE NULL,
	accRa DOUBLE NULL,
	accRaErr DOUBLE NULL,
	accDecl DOUBLE NULL,
	accDeclErr DOUBLE NULL,
	extEpoch DOUBLE NULL,
	extRa DOUBLE NULL,
	extRaErr DOUBLE NULL,
	extDecl DOUBLE NULL,
	extDeclErr DOUBLE NULL,
	extMag DOUBLE NULL,
	extMagErr DOUBLE NULL,
	probability DOUBLE NULL,
	status CHAR(1) NULL,
	classification CHAR(1) NULL,
	PRIMARY KEY (trackletId),
	INDEX idx_mopsTracklets_ccdExposureId (ccdExposureId ASC),
	INDEX idx_mopsTracklets_ssmId (ssmId ASC),
	INDEX idx_mopsTracklets_classification (classification ASC),
	INDEX idx_mopsTracklets_extEpoch (extEpoch ASC)
) ;


CREATE TABLE mops_TrackletToDiaSource
(
	trackletId BIGINT NOT NULL,
	diaSourceId BIGINT NOT NULL,
	PRIMARY KEY (trackletId, diaSourceId),
	INDEX idx_mopsTrackletsToDIASource_diaSourceId (diaSourceId ASC),
	KEY (trackletId)
) ;


CREATE TABLE mops_TrackToTracklet
(
	trackId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	PRIMARY KEY (trackId, trackletId),
	INDEX IDX_mopsTrackToTracklet_trackletId (trackletId ASC)
) ;


CREATE TABLE _Raw_Ccd_ExposureToVisit
(
	visitId INTEGER NOT NULL,
	ccdExposureId BIGINT NOT NULL,
	KEY (ccdExposureId),
	KEY (visitId)
) ;


CREATE TABLE FpaMetadata
(
	ccdExposureId BIGINT NOT NULL,
	exposureType TINYINT NOT NULL,
	metadataKey VARCHAR(255) NOT NULL,
	metadataValue VARCHAR(255) NULL,
	PRIMARY KEY (ccdExposureId)
) ;


CREATE TABLE RaftMetadata
(
	raftId BIGINT NOT NULL,
	metadataKey VARCHAR(255) NOT NULL,
	metadataValue VARCHAR(255) NULL,
	PRIMARY KEY (raftId)
) ;


CREATE TABLE Raw_Amp_Exposure
(
	rawAmpExposureId BIGINT NOT NULL,
	rawCcdExposureId BIGINT NOT NULL,
	ampId INTEGER NOT NULL,
	PRIMARY KEY (rawAmpExposureId),
	KEY (rawCcdExposureId)
) ;


CREATE TABLE Raw_Amp_Exposure_Metadata
(
	rawAmpExposureId BIGINT NOT NULL,
	exposureType TINYINT NOT NULL,
	metadataKey VARCHAR(255) NOT NULL,
	metadataValue VARCHAR(255) NULL,
	PRIMARY KEY (rawAmpExposureId)
) ;


CREATE TABLE Raw_Ccd_Exposure
(
	rawCcdExposureId BIGINT NOT NULL,
	ra DOUBLE NOT NULL,
	decl DOUBLE NOT NULL,
	filterId INTEGER NOT NULL,
	equinox FLOAT(0) NOT NULL,
	radecSys VARCHAR(20) NULL,
	dateObs TIMESTAMP NOT NULL DEFAULT 0,
	url VARCHAR(255) NOT NULL,
	ctype1 VARCHAR(20) NOT NULL,
	ctype2 VARCHAR(20) NOT NULL,
	mjdObs DOUBLE NULL,
	airmass FLOAT(0) NULL,
	crpix1 FLOAT(0) NOT NULL,
	crpix2 FLOAT(0) NOT NULL,
	crval1 DOUBLE NOT NULL,
	crval2 DOUBLE NOT NULL,
	cd11 DOUBLE NOT NULL,
	cd21 DOUBLE NOT NULL,
	darkTime FLOAT(0) NULL,
	cd12 DOUBLE NOT NULL,
	zd FLOAT(0) NULL,
	cd22 DOUBLE NOT NULL,
	taiObs TIMESTAMP NOT NULL DEFAULT 0,
	expTime FLOAT(0) NOT NULL,
	PRIMARY KEY (rawCcdExposureId)
) ;


CREATE TABLE Raw_Ccd_Exposure_Metadata
(
	rawCcdExposureId BIGINT NOT NULL,
	exposureType TINYINT NOT NULL,
	metadataKey VARCHAR(255) NOT NULL,
	metadataValue VARCHAR(255) NULL,
	PRIMARY KEY (rawCcdExposureId)
) ;


CREATE TABLE Science_Amp_Exposure
(
	scienceAmpExposureId BIGINT NOT NULL,
	scienceCcdExposureId BIGINT NOT NULL,
	rawAmpExposureId BIGINT NULL,
	ampId INTEGER NULL,
	PRIMARY KEY (scienceAmpExposureId),
	KEY (scienceCcdExposureId),
	KEY (rawAmpExposureId)
) ;


CREATE TABLE Science_Amp_Exposure_Metadata
(
	scienceAmpExposureId BIGINT NOT NULL,
	exposureType TINYINT NOT NULL,
	metadataKey VARCHAR(255) NOT NULL,
	metadataValue VARCHAR(255) NULL,
	PRIMARY KEY (scienceAmpExposureId)
) ;


CREATE TABLE Science_Ccd_Exposure
(
	scienceCcdExposureId BIGINT NOT NULL,
	rawCcdExposureId BIGINT NULL,
	snapId TINYINT NOT NULL,
	filterId INTEGER NULL,
	equinox FLOAT(0) NULL,
	url VARCHAR(255) NULL,
	ctype1 VARCHAR(20) NULL,
	ctype2 VARCHAR(20) NULL,
	crpix1 FLOAT(0) NULL,
	crpix2 FLOAT(0) NULL,
	crval1 DOUBLE NULL,
	crval2 DOUBLE NULL,
	cd1_1 DOUBLE NULL,
	cd2_1 DOUBLE NULL,
	cd1_2 DOUBLE NULL,
	cd2_2 DOUBLE NULL,
	taiMjd DOUBLE NULL,
	ccdSize VARCHAR(50) NULL,
	dateObs TIMESTAMP NULL DEFAULT 0,
	expTime FLOAT(0) NULL,
	photoFlam FLOAT(0) NULL,
	photoZP FLOAT(0) NULL,
	nCombine INTEGER NULL DEFAULT 1,
	binX INTEGER NULL,
	binY INTEGER NULL,
	readNoise DOUBLE NULL,
	saturationLimit BIGINT NULL,
	dataSection VARCHAR(24) NULL,
	gain DOUBLE NULL,
	PRIMARY KEY (scienceCcdExposureId),
	KEY (rawCcdExposureId)
) ;


CREATE TABLE Science_Ccd_Exposure_Metadata
(
	scienceCcdExposureId BIGINT NOT NULL,
	exposureType TINYINT NOT NULL,
	metadataKey VARCHAR(255) NOT NULL,
	metadataValue VARCHAR(255) NULL,
	PRIMARY KEY (scienceCcdExposureId)
) ;


CREATE TABLE Visit
(
	visitId INTEGER NOT NULL
) ;


CREATE TABLE CalibSource
(
	calibSourceId BIGINT NOT NULL,
	ccdExposureId BIGINT NULL,
	filterId TINYINT NULL,
	astroRefCatId BIGINT NULL,
	photoRefCatId BIGINT NULL,
	ra DOUBLE NOT NULL,
	raSigma FLOAT(0) NOT NULL,
	decl DOUBLE NOT NULL,
	declSigma FLOAT(0) NOT NULL,
	xAstrom DOUBLE NOT NULL,
	xAstromSigma FLOAT(0) NOT NULL,
	yAstrom DOUBLE NOT NULL,
	yAstromSigma FLOAT(0) NOT NULL,
	xyAstromCov FLOAT(0) NOT NULL,
	psfFlux DOUBLE NOT NULL,
	psfFluxSigma FLOAT(0) NOT NULL,
	apFlux DOUBLE NOT NULL,
	apFluxSigma FLOAT(0) NULL,
	momentIxx FLOAT(0) NULL,
	momentIxxSigma FLOAT(0) NULL,
	momentIyy FLOAT(0) NULL,
	momentIyySigma FLOAT(0) NULL,
	momentIxy FLOAT(0) NULL,
	momentIxySigma FLOAT(0) NULL,
	flag BIGINT NULL,
	_chunkId INTEGER NULL,
	_subChunkId INTEGER NULL,
	PRIMARY KEY (calibSourceId),
	KEY (ccdExposureId),
	KEY (filterId),
	KEY (xAstromSigma)
) TYPE=MyISAM;


CREATE TABLE DiaSource
(
	diaSourceId BIGINT NOT NULL,
	ccdExposureId BIGINT NULL,
	filterId TINYINT NOT NULL,
	objectId BIGINT NULL,
	movingObjectId BIGINT NULL,
	ra DOUBLE NOT NULL,
	raSigma FLOAT(0) NOT NULL,
	decl DOUBLE NOT NULL,
	declSigma FLOAT(0) NOT NULL,
	xAstrom FLOAT(0) NOT NULL,
	xAstromSigma FLOAT(0) NOT NULL,
	yAstrom FLOAT(0) NOT NULL,
	yAstromSigma FLOAT(0) NOT NULL,
	xyAstromCov FLOAT(0) NOT NULL,
	xOther FLOAT(0) NOT NULL,
	xOtherSigma FLOAT(0) NOT NULL,
	yOther FLOAT(0) NOT NULL,
	yOtherSigma FLOAT(0) NOT NULL,
	xyOtherCov FLOAT(0) NOT NULL,
	astromRefrRa FLOAT(0) NULL,
	astromRefrRaSigma FLOAT(0) NULL,
	astromRefrDecl FLOAT(0) NULL,
	astromRefrDeclSigma FLOAT(0) NULL,
	sky FLOAT(0) NOT NULL,
	skySigma FLOAT(0) NOT NULL,
	psfLnL FLOAT(0) NULL,
	lnL_SG FLOAT(0) NULL,
	flux_PS FLOAT(0) NOT NULL,
	flux_PS_Sigma FLOAT(0) NOT NULL,
	flux_SG FLOAT(0) NOT NULL,
	flux_SG_Sigma FLOAT(0) NOT NULL,
	flux_CSG FLOAT(0) NOT NULL,
	flux_CSG_Sigma FLOAT(0) NOT NULL,
	extendedness FLOAT(0) NULL,
	galExtinction FLOAT(0) NULL,
	apCorrection FLOAT(0) NOT NULL,
	grayExtinction FLOAT(0) NOT NULL,
	nonGrayExtinction FLOAT(0) NOT NULL,
	midPoint FLOAT(0) NOT NULL,
	momentIx FLOAT(0) NULL,
	momentIxSigma FLOAT(0) NULL,
	momentIy FLOAT(0) NULL,
	momentIySigma FLOAT(0) NULL,
	momentIxx FLOAT(0) NULL,
	momentIxxSigma FLOAT(0) NULL,
	momentIyy FLOAT(0) NULL,
	momentIyySigma FLOAT(0) NULL,
	momentIxy FLOAT(0) NULL,
	momentIxySigma FLOAT(0) NULL,
	flags BIGINT NOT NULL,
	_chunkId INTEGER NULL,
	_subChunkId INTEGER NULL,
	PRIMARY KEY (diaSourceId),
	KEY (ccdExposureId),
	KEY (filterId),
	KEY (movingObjectId),
	KEY (objectId)
) TYPE=MyISAM;


CREATE TABLE ForcedSource
(
	objectId BIGINT NOT NULL,
	ccdExposureId BIGINT NOT NULL,
	sky FLOAT(0) NOT NULL,
	skySigma FLOAT(0) NOT NULL,
	flux_PS FLOAT(0) NULL,
	flux_PS_Sigma FLOAT(0) NULL,
	flux_SG FLOAT(0) NULL,
	flux_SG_Sigma FLOAT(0) NULL,
	flux_CSG FLOAT(0) NULL,
	flux_CSG_Sigma FLOAT(0) NULL,
	psfLnL FLOAT(0) NULL,
	modelLSLnL FLOAT(0) NULL,
	modelSGLnL FLOAT(0) NULL,
	flags BIGINT NOT NULL,
	_chunkId INTEGER NULL,
	_subChunkId INTEGER NULL,
	PRIMARY KEY (objectId, ccdExposureId)
) ;


CREATE TABLE MovingObject
(
	movingObjectId BIGINT NOT NULL,
	movingObjectVersion INT NOT NULL DEFAULT '1',
	procHistoryId INTEGER NOT NULL,
	taxonomicTypeId SMALLINT NULL,
	ssmObjectName VARCHAR(32) NULL,
	q DOUBLE NOT NULL,
	e DOUBLE NOT NULL,
	i DOUBLE NOT NULL,
	node DOUBLE NOT NULL,
	meanAnom DOUBLE NOT NULL,
	argPeri DOUBLE NOT NULL,
	distPeri DOUBLE NOT NULL,
	timePeri DOUBLE NOT NULL,
	epoch DOUBLE NOT NULL,
	h_v DOUBLE NOT NULL,
	g DOUBLE NULL DEFAULT 0.15,
	rotationPeriod DOUBLE NULL,
	rotationEpoch DOUBLE NULL,
	albedo DOUBLE NULL,
	poleLat DOUBLE NULL,
	poleLon DOUBLE NULL,
	d3 DOUBLE NULL,
	d4 DOUBLE NULL,
	orbFitResidual DOUBLE NOT NULL,
	orbFitChi2 DOUBLE NULL,
	classification CHAR(1) NULL,
	ssmId BIGINT NULL,
	mopsStatus CHAR(1) NULL,
	stablePass CHAR(1) NULL,
	timeCreated TIMESTAMP NULL,
	uMag DOUBLE NULL,
	uMagErr FLOAT(0) NULL,
	uAmplitude FLOAT(0) NULL,
	uPeriod FLOAT(0) NULL,
	gMag DOUBLE NULL,
	gMagErr FLOAT(0) NULL,
	gAmplitude FLOAT(0) NULL,
	gPeriod FLOAT(0) NULL,
	rMag DOUBLE NULL,
	rMagErr FLOAT(0) NULL,
	rAmplitude FLOAT(0) NULL,
	rPeriod FLOAT(0) NULL,
	iMag DOUBLE NULL,
	iMagErr FLOAT(0) NULL,
	iAmplitude FLOAT(0) NULL,
	iPeriod FLOAT(0) NULL,
	zMag DOUBLE NULL,
	zMagErr FLOAT(0) NULL,
	zAmplitude FLOAT(0) NULL,
	zPeriod FLOAT(0) NULL,
	yMag DOUBLE NULL,
	yMagErr FLOAT(0) NULL,
	yAmplitude FLOAT(0) NULL,
	yPeriod FLOAT(0) NULL,
	flag INTEGER NULL,
	src01 DOUBLE NULL,
	src02 DOUBLE NULL,
	src03 DOUBLE NULL,
	src04 DOUBLE NULL,
	src05 DOUBLE NULL,
	src06 DOUBLE NULL,
	src07 DOUBLE NULL,
	src08 DOUBLE NULL,
	src09 DOUBLE NULL,
	src10 DOUBLE NULL,
	src11 DOUBLE NULL,
	src12 DOUBLE NULL,
	src13 DOUBLE NULL,
	src14 DOUBLE NULL,
	src15 DOUBLE NULL,
	src16 DOUBLE NULL,
	src17 DOUBLE NULL,
	src18 DOUBLE NULL,
	src19 DOUBLE NULL,
	src20 DOUBLE NULL,
	src21 DOUBLE NULL,
	convCode VARCHAR(8) NULL,
	o_minus_c DOUBLE NULL,
	moid1 DOUBLE NULL,
	moidLong1 DOUBLE NULL,
	moid2 DOUBLE NULL,
	moidLong2 DOUBLE NULL,
	arcLengthDays DOUBLE NULL,
	PRIMARY KEY (movingObjectId, movingObjectVersion),
	KEY (procHistoryId),
	INDEX idx_MovingObject_taxonomicTypeId (taxonomicTypeId ASC),
	INDEX idx_MovingObject_ssmId (ssmId ASC),
	INDEX idx_MovingObject_ssmObjectName (ssmObjectName ASC),
	INDEX idx_MovingObject_status (mopsStatus ASC)
) ;


CREATE TABLE Object
(
	objectId BIGINT NOT NULL,
	iauId CHAR(34) NULL,
	ra_PS DOUBLE NOT NULL,
	ra_PS_Sigma FLOAT(0) NOT NULL,
	decl_PS DOUBLE NOT NULL,
	decl_PS_Sigma FLOAT(0) NOT NULL,
	radecl_PS_Cov FLOAT(0) NULL,
	ra_SG DOUBLE NULL,
	ra_SG_Sigma FLOAT(0) NULL,
	decl_SG DOUBLE NULL,
	decl_SG_Sigma FLOAT(0) NULL,
	radecl_SG_Cov FLOAT(0) NULL,
	raRange FLOAT(0) NULL,
	declRange FLOAT(0) NULL,
	muRa_PS DOUBLE NULL,
	muRa_PS_Sigma FLOAT(0) NULL,
	muDecl_PS DOUBLE NULL,
	muDecl_PS_Sigma FLOAT(0) NULL,
	muRaDecl_PS_Cov FLOAT(0) NULL,
	parallax_PS DOUBLE NULL,
	parallax_PS_Sigma FLOAT(0) NULL,
	canonicalFilterId TINYINT NULL,
	extendedness FLOAT(0) NULL,
	varProb FLOAT(0) NULL,
	earliestObsTime DOUBLE NULL,
	latestObsTime DOUBLE NULL,
	flags INTEGER NULL,
	uNumObs INTEGER NULL,
	uExtendedness FLOAT(0) NULL,
	uVarProb FLOAT(0) NULL,
	uRaOffset_PS FLOAT(0) NULL,
	uRaOffset_PS_Sigma FLOAT(0) NULL,
	uDeclOffset_PS FLOAT(0) NULL,
	uDeclOffset_PS_Sigma FLOAT(0) NULL,
	uRaDeclOffset_PS_Cov FLOAT(0) NULL,
	uRaOffset_SG FLOAT(0) NULL,
	uRaOffset_SG_Sigma FLOAT(0) NULL,
	uDeclOffset_SG FLOAT(0) NULL,
	uDeclOffset_SG_Sigma FLOAT(0) NULL,
	uRaDeclOffset_SG_Cov FLOAT(0) NULL,
	uLnL_PS FLOAT(0) NULL,
	uLnL_SG FLOAT(0) NULL,
	uFlux_PS FLOAT(0) NULL,
	uFlux_PS_Sigma FLOAT(0) NULL,
	uFlux_SG FLOAT(0) NULL,
	uFlux_SG_Sigma FLOAT(0) NULL,
	uFlux_CSG FLOAT(0) NULL,
	uFlux_CSG_Sigma FLOAT(0) NULL,
	uTimescale FLOAT(0) NULL,
	uEarliestObsTime DOUBLE NULL,
	uLatestObsTime DOUBLE NULL,
	uSersicN_SG FLOAT(0) NULL,
	uSersicN_SG_Sigma FLOAT(0) NULL,
	uE1_SG FLOAT(0) NULL,
	uE1_SG_Sigma FLOAT(0) NULL,
	uE2_SG FLOAT(0) NULL,
	uE2_SG_Sigma FLOAT(0) NULL,
	uRadius_SG FLOAT(0) NULL,
	uRadius_SG_Sigma FLOAT(0) NULL,
	uFlags INTEGER NULL,
	gNumObs INTEGER NULL,
	gExtendedness FLOAT(0) NULL,
	gVarProb FLOAT(0) NULL,
	gRaOffset_PS FLOAT(0) NULL,
	gRaOffset_PS_Sigma FLOAT(0) NULL,
	gDeclOffset_PS FLOAT(0) NULL,
	gDeclOffset_PS_Sigma FLOAT(0) NULL,
	gRaDeclOffset_PS_Cov FLOAT(0) NULL,
	gRaOffset_SG FLOAT(0) NULL,
	gRaOffset_SG_Sigma FLOAT(0) NULL,
	gDeclOffset_SG FLOAT(0) NULL,
	gDeclOffset_SG_Sigma FLOAT(0) NULL,
	gRaDeclOffset_SG_Cov FLOAT(0) NULL,
	gLnL_PS FLOAT(0) NULL,
	gLnL_SG FLOAT(0) NULL,
	gFlux_PS FLOAT(0) NULL,
	gFlux_PS_Sigma FLOAT(0) NULL,
	gFlux_SG FLOAT(0) NULL,
	gFlux_SG_Sigma FLOAT(0) NULL,
	gFlux_CSG FLOAT(0) NULL,
	gFlux_CSG_Sigma FLOAT(0) NULL,
	gTimescale FLOAT(0) NULL,
	gEarliestObsTime DOUBLE NULL,
	gLatestObsTime DOUBLE NULL,
	gSersicN_SG FLOAT(0) NULL,
	gSersicN_SG_Sigma FLOAT(0) NULL,
	gE1_SG FLOAT(0) NULL,
	gE1_SG_Sigma FLOAT(0) NULL,
	gE2_SG FLOAT(0) NULL,
	gE2_SG_Sigma FLOAT(0) NULL,
	gRadius_SG FLOAT(0) NULL,
	gRadius_SG_Sigma FLOAT(0) NULL,
	gFlags INTEGER NULL,
	rNumObs INTEGER NULL,
	rExtendedness FLOAT(0) NULL,
	rVarProb FLOAT(0) NULL,
	rRaOffset_PS FLOAT(0) NULL,
	rRaOffset_PS_Sigma FLOAT(0) NULL,
	rDeclOffset_PS FLOAT(0) NULL,
	rDeclOffset_PS_Sigma FLOAT(0) NULL,
	rRaDeclOffset_PS_Cov FLOAT(0) NULL,
	rRaOffset_SG FLOAT(0) NULL,
	rRaOffset_SG_Sigma FLOAT(0) NULL,
	rDeclOffset_SG FLOAT(0) NULL,
	rDeclOffset_SG_Sigma FLOAT(0) NULL,
	rRaDeclOffset_SG_Cov FLOAT(0) NULL,
	rLnL_PS FLOAT(0) NULL,
	rLnL_SG FLOAT(0) NULL,
	rFlux_PS FLOAT(0) NULL,
	rFlux_PS_Sigma FLOAT(0) NULL,
	rFlux_SG FLOAT(0) NULL,
	rFlux_SG_Sigma FLOAT(0) NULL,
	rFlux_CSG FLOAT(0) NULL,
	rFlux_CSG_Sigma FLOAT(0) NULL,
	rTimescale FLOAT(0) NULL,
	rEarliestObsTime DOUBLE NULL,
	rLatestObsTime DOUBLE NULL,
	rSersicN_SG FLOAT(0) NULL,
	rSersicN_SG_Sigma FLOAT(0) NULL,
	rE1_SG FLOAT(0) NULL,
	rE1_SG_Sigma FLOAT(0) NULL,
	rE2_SG FLOAT(0) NULL,
	rE2_SG_Sigma FLOAT(0) NULL,
	rRadius_SG FLOAT(0) NULL,
	rRadius_SG_Sigma FLOAT(0) NULL,
	rFlags INTEGER NULL,
	iNumObs INTEGER NULL,
	iExtendedness FLOAT(0) NULL,
	iVarProb FLOAT(0) NULL,
	iRaOffset_PS FLOAT(0) NULL,
	iRaOffset_PS_Sigma FLOAT(0) NULL,
	iDeclOffset_PS FLOAT(0) NULL,
	iDeclOffset_PS_Sigma FLOAT(0) NULL,
	iRaDeclOffset_PS_Cov FLOAT(0) NULL,
	iRaOffset_SG FLOAT(0) NULL,
	iRaOffset_SG_Sigma FLOAT(0) NULL,
	iDeclOffset_SG FLOAT(0) NULL,
	iDeclOffset_SG_Sigma FLOAT(0) NULL,
	iRaDeclOffset_SG_Cov FLOAT(0) NULL,
	iLnL_PS FLOAT(0) NULL,
	iLnL_SG FLOAT(0) NULL,
	iFlux_PS FLOAT(0) NULL,
	iFlux_PS_Sigma FLOAT(0) NULL,
	iFlux_SG FLOAT(0) NULL,
	iFlux_SG_Sigma FLOAT(0) NULL,
	iFlux_CSG FLOAT(0) NULL,
	iFlux_CSG_Sigma FLOAT(0) NULL,
	iTimescale FLOAT(0) NULL,
	iEarliestObsTime DOUBLE NULL,
	iLatestObsTime DOUBLE NULL,
	iSersicN_SG FLOAT(0) NULL,
	iSersicN_SG_Sigma FLOAT(0) NULL,
	iE1_SG FLOAT(0) NULL,
	iE1_SG_Sigma FLOAT(0) NULL,
	iE2_SG FLOAT(0) NULL,
	iE2_SG_Sigma FLOAT(0) NULL,
	iRadius_SG FLOAT(0) NULL,
	iRadius_SG_Sigma FLOAT(0) NULL,
	iFlags INTEGER NULL,
	zNumObs INTEGER NULL,
	zExtendedness FLOAT(0) NULL,
	zVarProb FLOAT(0) NULL,
	zRaOffset_PS FLOAT(0) NULL,
	zRaOffset_PS_Sigma FLOAT(0) NULL,
	zDeclOffset_PS FLOAT(0) NULL,
	zDeclOffset_PS_Sigma FLOAT(0) NULL,
	zRaDeclOffset_PS_Cov FLOAT(0) NULL,
	zRaOffset_SG FLOAT(0) NULL,
	zRaOffset_SG_Sigma FLOAT(0) NULL,
	zDeclOffset_SG FLOAT(0) NULL,
	zDeclOffset_SG_Sigma FLOAT(0) NULL,
	zRaDeclOffset_SG_Cov FLOAT(0) NULL,
	zLnL_PS FLOAT(0) NULL,
	zLnL_SG FLOAT(0) NULL,
	zFlux_PS FLOAT(0) NULL,
	zFlux_PS_Sigma FLOAT(0) NULL,
	zFlux_SG FLOAT(0) NULL,
	zFlux_SG_Sigma FLOAT(0) NULL,
	zFlux_CSG FLOAT(0) NULL,
	zFlux_CSG_Sigma FLOAT(0) NULL,
	zTimescale FLOAT(0) NULL,
	zEarliestObsTime DOUBLE NULL,
	zLatestObsTime DOUBLE NULL,
	zSersicN_SG FLOAT(0) NULL,
	zSersicN_SG_Sigma FLOAT(0) NULL,
	zE1_SG FLOAT(0) NULL,
	zE1_SG_Sigma FLOAT(0) NULL,
	zE2_SG FLOAT(0) NULL,
	zE2_SG_Sigma FLOAT(0) NULL,
	zRadius_SG FLOAT(0) NULL,
	zRadius_SG_Sigma FLOAT(0) NULL,
	zFlags INTEGER NULL,
	yNumObs INTEGER NULL,
	yExtendedness FLOAT(0) NULL,
	yVarProb FLOAT(0) NULL,
	yRaOffset_PS FLOAT(0) NULL,
	yRaOffset_PS_Sigma FLOAT(0) NULL,
	yDeclOffset_PS FLOAT(0) NULL,
	yDeclOffset_PS_Sigma FLOAT(0) NULL,
	yRaDeclOffset_PS_Cov FLOAT(0) NULL,
	yRaOffset_SG FLOAT(0) NULL,
	yRaOffset_SG_Sigma FLOAT(0) NULL,
	yDeclOffset_SG FLOAT(0) NULL,
	yDeclOffset_SG_Sigma FLOAT(0) NULL,
	yRaDeclOffset_SG_Cov FLOAT(0) NULL,
	yLnL_PS FLOAT(0) NULL,
	yLnL_SG FLOAT(0) NULL,
	yFlux_PS FLOAT(0) NULL,
	yFlux_PS_Sigma FLOAT(0) NULL,
	yFlux_SG FLOAT(0) NULL,
	yFlux_SG_Sigma FLOAT(0) NULL,
	yFlux_CSG FLOAT(0) NULL,
	yFlux_CSG_Sigma FLOAT(0) NULL,
	yTimescale FLOAT(0) NULL,
	yEarliestObsTime DOUBLE NULL,
	yLatestObsTime DOUBLE NULL,
	ySersicN_SG FLOAT(0) NULL,
	ySersicN_SG_Sigma FLOAT(0) NULL,
	yE1_SG FLOAT(0) NULL,
	yE1_SG_Sigma FLOAT(0) NULL,
	yE2_SG FLOAT(0) NULL,
	yE2_SG_Sigma FLOAT(0) NULL,
	yRadius_SG FLOAT(0) NULL,
	yRadius_SG_Sigma FLOAT(0) NULL,
	yFlags INTEGER NULL,
	_chunkId INTEGER NULL,
	_subChunkId INTEGER NULL,
	PRIMARY KEY (objectId)
) TYPE=MyISAM;


CREATE TABLE ObjectExtras
(
	objectId BIGINT NOT NULL,
	uFlux_ra_PS_Cov FLOAT(0) NULL,
	uFlux_decl_PS_Cov FLOAT(0) NULL,
	uRa_decl_PS_Cov FLOAT(0) NULL,
	uFlux_ra_SG_Cov FLOAT(0) NULL,
	uFlux_decl_SG_Cov FLOAT(0) NULL,
	uFlux_SersicN_SG_Cov FLOAT(0) NULL,
	uFlux_e1_SG_Cov FLOAT(0) NULL,
	uFlux_e2_SG_Cov FLOAT(0) NULL,
	uFlux_radius_SG_Cov FLOAT(0) NULL,
	uRa_decl_SG_Cov FLOAT(0) NULL,
	uRa_SersicN_SG_Cov FLOAT(0) NULL,
	uRa_e1_SG_Cov FLOAT(0) NULL,
	uRa_e2_SG_Cov FLOAT(0) NULL,
	uRa_radius_SG_Cov FLOAT(0) NULL,
	uDecl_SersicN_SG_Cov FLOAT(0) NULL,
	uDecl_e1_SG_Cov FLOAT(0) NULL,
	uDecl_e2_SG_Cov FLOAT(0) NULL,
	uDecl_radius_SG_Cov FLOAT(0) NULL,
	uSersicN_e1_SG_Cov FLOAT(0) NULL,
	uSersicN_e2_SG_Cov FLOAT(0) NULL,
	uSersicN_radius_SG_Cov FLOAT(0) NULL,
	uE1_e2_SG_Cov FLOAT(0) NULL,
	uE1_radius_SG_Cov FLOAT(0) NULL,
	uE2_radius_SG_Cov FLOAT(0) NULL,
	gFlux_ra_PS_Cov FLOAT(0) NULL,
	gFlux_decl_PS_Cov FLOAT(0) NULL,
	gRa_decl_PS_Cov FLOAT(0) NULL,
	gFlux_ra_SG_Cov FLOAT(0) NULL,
	gFlux_decl_SG_Cov FLOAT(0) NULL,
	gFlux_SersicN_SG_Cov FLOAT(0) NULL,
	gFlux_e1_SG_Cov FLOAT(0) NULL,
	gFlux_e2_SG_Cov FLOAT(0) NULL,
	gFlux_radius_SG_Cov FLOAT(0) NULL,
	gRa_decl_SG_Cov FLOAT(0) NULL,
	gRa_SersicN_SG_Cov FLOAT(0) NULL,
	gRa_e1_SG_Cov FLOAT(0) NULL,
	gRa_e2_SG_Cov FLOAT(0) NULL,
	gRa_radius_SG_Cov FLOAT(0) NULL,
	gDecl_SersicN_SG_Cov FLOAT(0) NULL,
	gDecl_e1_SG_Cov FLOAT(0) NULL,
	gDecl_e2_SG_Cov FLOAT(0) NULL,
	gDecl_radius_SG_Cov FLOAT(0) NULL,
	gSersicN_e1_SG_Cov FLOAT(0) NULL,
	gSersicN_e2_SG_Cov FLOAT(0) NULL,
	gSersicN_radius_SG_Cov FLOAT(0) NULL,
	gE1_e2_SG_Cov FLOAT(0) NULL,
	gE1_radius_SG_Cov FLOAT(0) NULL,
	gE2_radius_SG_Cov FLOAT(0) NULL,
	rFlux_ra_PS_Cov FLOAT(0) NULL,
	rFlux_decl_PS_Cov FLOAT(0) NULL,
	rRa_decl_PS_Cov FLOAT(0) NULL,
	rFlux_ra_SG_Cov FLOAT(0) NULL,
	rFlux_decl_SG_Cov FLOAT(0) NULL,
	rFlux_SersicN_SG_Cov FLOAT(0) NULL,
	rFlux_e1_SG_Cov FLOAT(0) NULL,
	rFlux_e2_SG_Cov FLOAT(0) NULL,
	rFlux_radius_SG_Cov FLOAT(0) NULL,
	rRa_decl_SG_Cov FLOAT(0) NULL,
	rRa_SersicN_SG_Cov FLOAT(0) NULL,
	rRa_e1_SG_Cov FLOAT(0) NULL,
	rRa_e2_SG_Cov FLOAT(0) NULL,
	rRa_radius_SG_Cov FLOAT(0) NULL,
	rDecl_SersicN_SG_Cov FLOAT(0) NULL,
	rDecl_e1_SG_Cov FLOAT(0) NULL,
	rDecl_e2_SG_Cov FLOAT(0) NULL,
	rDecl_radius_SG_Cov FLOAT(0) NULL,
	rSersicN_e1_SG_Cov FLOAT(0) NULL,
	rSersicN_e2_SG_Cov FLOAT(0) NULL,
	rSersicN_radius_SG_Cov FLOAT(0) NULL,
	rE1_e2_SG_Cov FLOAT(0) NULL,
	rE1_radius_SG_Cov FLOAT(0) NULL,
	rE2_radius_SG_Cov FLOAT(0) NULL,
	iFlux_ra_PS_Cov FLOAT(0) NULL,
	iFlux_decl_PS_Cov FLOAT(0) NULL,
	iRa_decl_PS_Cov FLOAT(0) NULL,
	iFlux_ra_SG_Cov FLOAT(0) NULL,
	iFlux_decl_SG_Cov FLOAT(0) NULL,
	iFlux_SersicN_SG_Cov FLOAT(0) NULL,
	iFlux_e1_SG_Cov FLOAT(0) NULL,
	iFlux_e2_SG_Cov FLOAT(0) NULL,
	iFlux_radius_SG_Cov FLOAT(0) NULL,
	iRa_decl_SG_Cov FLOAT(0) NULL,
	iRa_SersicN_SG_Cov FLOAT(0) NULL,
	iRa_e1_SG_Cov FLOAT(0) NULL,
	iRa_e2_SG_Cov FLOAT(0) NULL,
	iRa_radius_SG_Cov FLOAT(0) NULL,
	iDecl_SersicN_SG_Cov FLOAT(0) NULL,
	iDecl_e1_SG_Cov FLOAT(0) NULL,
	iDecl_e2_SG_Cov FLOAT(0) NULL,
	iDecl_radius_SG_Cov FLOAT(0) NULL,
	iSersicN_e1_SG_Cov FLOAT(0) NULL,
	iSersicN_e2_SG_Cov FLOAT(0) NULL,
	iSersicN_radius_SG_Cov FLOAT(0) NULL,
	iE1_e2_SG_Cov FLOAT(0) NULL,
	iE1_radius_SG_Cov FLOAT(0) NULL,
	iE2_radius_SG_Cov FLOAT(0) NULL,
	zFlux_ra_PS_Cov FLOAT(0) NULL,
	zFlux_decl_PS_Cov FLOAT(0) NULL,
	zRa_decl_PS_Cov FLOAT(0) NULL,
	zFlux_ra_SG_Cov FLOAT(0) NULL,
	zFlux_decl_SG_Cov FLOAT(0) NULL,
	zFlux_SersicN_SG_Cov FLOAT(0) NULL,
	zFlux_e1_SG_Cov FLOAT(0) NULL,
	zFlux_e2_SG_Cov FLOAT(0) NULL,
	zFlux_radius_SG_Cov FLOAT(0) NULL,
	zRa_decl_SG_Cov FLOAT(0) NULL,
	zRa_SersicN_SG_Cov FLOAT(0) NULL,
	zRa_e1_SG_Cov FLOAT(0) NULL,
	zRa_e2_SG_Cov FLOAT(0) NULL,
	zRa_radius_SG_Cov FLOAT(0) NULL,
	zDecl_SersicN_SG_Cov FLOAT(0) NULL,
	zDecl_e1_SG_Cov FLOAT(0) NULL,
	zDecl_e2_SG_Cov FLOAT(0) NULL,
	zDecl_radius_SG_Cov FLOAT(0) NULL,
	zSersicN_e1_SG_Cov FLOAT(0) NULL,
	zSersicN_e2_SG_Cov FLOAT(0) NULL,
	zSersicN_radius_SG_Cov FLOAT(0) NULL,
	zE1_e2_SG_Cov FLOAT(0) NULL,
	zE1_radius_SG_Cov FLOAT(0) NULL,
	zE2_radius_SG_Cov FLOAT(0) NULL,
	yFlux_ra_PS_Cov FLOAT(0) NULL,
	yFlux_decl_PS_Cov FLOAT(0) NULL,
	yRa_decl_PS_Cov FLOAT(0) NULL,
	yFlux_ra_SG_Cov FLOAT(0) NULL,
	yFlux_decl_SG_Cov FLOAT(0) NULL,
	yFlux_SersicN_SG_Cov FLOAT(0) NULL,
	yFlux_e1_SG_Cov FLOAT(0) NULL,
	yFlux_e2_SG_Cov FLOAT(0) NULL,
	yFlux_radius_SG_Cov FLOAT(0) NULL,
	yRa_decl_SG_Cov FLOAT(0) NULL,
	yRa_SersicN_SG_Cov FLOAT(0) NULL,
	yRa_e1_SG_Cov FLOAT(0) NULL,
	yRa_e2_SG_Cov FLOAT(0) NULL,
	yRa_radius_SG_Cov FLOAT(0) NULL,
	yDecl_SersicN_SG_Cov FLOAT(0) NULL,
	yDecl_e1_SG_Cov FLOAT(0) NULL,
	yDecl_e2_SG_Cov FLOAT(0) NULL,
	yDecl_radius_SG_Cov FLOAT(0) NULL,
	ySersicN_e1_SG_Cov FLOAT(0) NULL,
	ySersicN_e2_SG_Cov FLOAT(0) NULL,
	ySersicN_radius_SG_Cov FLOAT(0) NULL,
	yE1_e2_SG_Cov FLOAT(0) NULL,
	yE1_radius_SG_Cov FLOAT(0) NULL,
	yE2_radius_SG_Cov FLOAT(0) NULL,
	_chunkId INTEGER NULL,
	_subChunkId INTEGER NULL,
	PRIMARY KEY (objectId)
) ;


CREATE TABLE Source_pt1
(
	sourceId BIGINT NOT NULL,
	ampExposureId BIGINT NULL,
	filterId TINYINT NOT NULL,
	objectId BIGINT NULL,
	movingObjectId BIGINT NULL,
	procHistoryId INTEGER NOT NULL,
	ra DOUBLE NOT NULL,
	raErrForDetection FLOAT(0) NULL,
	raErrForWcs FLOAT(0) NOT NULL,
	decl DOUBLE NOT NULL,
	declErrForDetection FLOAT(0) NULL,
	declErrForWcs FLOAT(0) NOT NULL,
	xFlux DOUBLE NULL,
	xFluxErr FLOAT(0) NULL,
	yFlux DOUBLE NULL,
	yFluxErr FLOAT(0) NULL,
	raFlux DOUBLE NULL,
	raFluxErr FLOAT(0) NULL,
	declFlux DOUBLE NULL,
	declFluxErr FLOAT(0) NULL,
	xPeak DOUBLE NULL,
	yPeak DOUBLE NULL,
	raPeak DOUBLE NULL,
	declPeak DOUBLE NULL,
	xAstrom DOUBLE NULL,
	xAstromErr FLOAT(0) NULL,
	yAstrom DOUBLE NULL,
	yAstromErr FLOAT(0) NULL,
	raAstrom DOUBLE NULL,
	raAstromErr FLOAT(0) NULL,
	declAstrom DOUBLE NULL,
	declAstromErr FLOAT(0) NULL,
	raObject DOUBLE NULL,
	declObject DOUBLE NULL,
	taiMidPoint DOUBLE NOT NULL,
	taiRange FLOAT(0) NULL,
	psfFlux DOUBLE NOT NULL,
	psfFluxErr FLOAT(0) NOT NULL,
	apFlux DOUBLE NOT NULL,
	apFluxErr FLOAT(0) NOT NULL,
	modelFlux DOUBLE NOT NULL,
	modelFluxErr FLOAT(0) NOT NULL,
	petroFlux DOUBLE NULL,
	petroFluxErr FLOAT(0) NULL,
	instFlux DOUBLE NOT NULL,
	instFluxErr FLOAT(0) NOT NULL,
	nonGrayCorrFlux DOUBLE NULL,
	nonGrayCorrFluxErr FLOAT(0) NULL,
	atmCorrFlux DOUBLE NULL,
	atmCorrFluxErr FLOAT(0) NULL,
	apDia FLOAT(0) NULL,
	Ixx FLOAT(0) NULL,
	IxxErr FLOAT(0) NULL,
	Iyy FLOAT(0) NULL,
	IyyErr FLOAT(0) NULL,
	Ixy FLOAT(0) NULL,
	IxyErr FLOAT(0) NULL,
	snr FLOAT(0) NOT NULL,
	chi2 FLOAT(0) NOT NULL,
	sky FLOAT(0) NULL,
	skyErr FLOAT(0) NULL,
	extendedness FLOAT(0) NULL,
	flux_PS FLOAT(0) NULL,
	flux_PS_Sigma FLOAT(0) NULL,
	flux_SG FLOAT(0) NULL,
	flux_SG_Sigma FLOAT(0) NULL,
	sersicN_SG FLOAT(0) NULL,
	sersicN_SG_Sigma FLOAT(0) NULL,
	e1_SG FLOAT(0) NULL,
	e1_SG_Sigma FLOAT(0) NULL,
	e2_SG FLOAT(0) NULL,
	e2_SG_Sigma FLOAT(0) NULL,
	radius_SG FLOAT(0) NULL,
	radius_SG_Sigma FLOAT(0) NULL,
	flux_flux_SG_Cov FLOAT(0) NULL,
	flux_e1_SG_Cov FLOAT(0) NULL,
	flux_e2_SG_Cov FLOAT(0) NULL,
	flux_radius_SG_Cov FLOAT(0) NULL,
	flux_sersicN_SG_Cov FLOAT(0) NULL,
	e1_e1_SG_Cov FLOAT(0) NULL,
	e1_e2_SG_Cov FLOAT(0) NULL,
	e1_radius_SG_Cov FLOAT(0) NULL,
	e1_sersicN_SG_Cov FLOAT(0) NULL,
	e2_e2_SG_Cov FLOAT(0) NULL,
	e2_radius_SG_Cov FLOAT(0) NULL,
	e2_sersicN_SG_Cov FLOAT(0) NULL,
	radius_radius_SG_Cov FLOAT(0) NULL,
	radius_sersicN_SG_Cov FLOAT(0) NULL,
	sersicN_sersicN_SG_Cov FLOAT(0) NULL,
	flagForAssociation SMALLINT NULL,
	flagForDetection INTEGER NULL,
	flagForWcs SMALLINT NULL,
	PRIMARY KEY (sourceId),
	INDEX ampExposureId (ampExposureId ASC),
	INDEX filterId (filterId ASC),
	INDEX movingObjectId (movingObjectId ASC),
	INDEX objectId (objectId ASC),
	INDEX procHistoryId (procHistoryId ASC)
) TYPE=MyISAM;


CREATE TABLE Source_pt2
(
	sourceId BIGINT NOT NULL,
	ccdExposureId BIGINT NULL,
	filterId TINYINT NOT NULL,
	objectId BIGINT NULL,
	movingObjectId BIGINT NULL,
	ra DOUBLE NOT NULL,
	raSigma FLOAT(0) NOT NULL,
	decl DOUBLE NOT NULL,
	declSigma FLOAT(0) NOT NULL,
	xAstrom FLOAT(0) NOT NULL,
	xAstromSigma FLOAT(0) NOT NULL,
	yAstrom FLOAT(0) NOT NULL,
	yAstromSigma FLOAT(0) NOT NULL,
	xyAstromCov FLOAT(0) NOT NULL,
	xOther FLOAT(0) NOT NULL,
	xOtherSigma FLOAT(0) NOT NULL,
	yOther FLOAT(0) NOT NULL,
	yOtherSigma FLOAT(0) NOT NULL,
	xyOtherCov FLOAT(0) NOT NULL,
	astromRefrRa FLOAT(0) NULL,
	astromRefrRaSigma FLOAT(0) NULL,
	astromRefrDecl FLOAT(0) NULL,
	astromRefrDeclSigma FLOAT(0) NULL,
	sky FLOAT(0) NOT NULL,
	skySigma FLOAT(0) NOT NULL,
	psfLnL FLOAT(0) NULL,
	lnL_SG FLOAT(0) NULL,
	flux_PS FLOAT(0) NULL,
	flux_PS_Sigma FLOAT(0) NULL,
	flux_SG FLOAT(0) NULL,
	flux_SG_Sigma FLOAT(0) NULL,
	flux_CSG FLOAT(0) NULL,
	flux_CSG_Sigma FLOAT(0) NULL,
	extendedness FLOAT(0) NULL,
	galExtinction FLOAT(0) NULL,
	sersicN_SG FLOAT(0) NULL,
	sersicN_SG_Sigma FLOAT(0) NULL,
	e1_SG FLOAT(0) NULL,
	e1_SG_Sigma FLOAT(0) NULL,
	e2_SG FLOAT(0) NULL,
	e2_SG_Sigma FLOAT(0) NULL,
	radius_SG FLOAT(0) NULL,
	radius_SG_Sigma FLOAT(0) NULL,
	midPoint FLOAT(0) NOT NULL,
	apCorrection FLOAT(0) NOT NULL,
	grayExtinction FLOAT(0) NOT NULL,
	nonGrayExtinction FLOAT(0) NOT NULL,
	momentIx FLOAT(0) NULL,
	momentIxSigma FLOAT(0) NULL,
	momentIy FLOAT(0) NULL,
	momentIySigma FLOAT(0) NULL,
	momentIxx FLOAT(0) NULL,
	momentIxxSigma FLOAT(0) NULL,
	momentIyy FLOAT(0) NULL,
	momentIyySigma FLOAT(0) NULL,
	momentIxy FLOAT(0) NULL,
	momentIxySigma FLOAT(0) NULL,
	flags BIGINT NOT NULL,
	_chunkId INTEGER NULL,
	_subChunkId INTEGER NULL,
	PRIMARY KEY (sourceId),
	KEY (objectId),
	KEY (ccdExposureId),
	KEY (filterId),
	KEY (movingObjectId),
	KEY (objectId)
) TYPE=MyISAM;



SET FOREIGN_KEY_CHECKS=1;


ALTER TABLE prv_cnf_PolicyKey ADD CONSTRAINT FK_prv_cnf_PolicyKey_prv_PolicyKey 
	FOREIGN KEY (policyKeyId) REFERENCES prv_PolicyKey (policyKeyId);

ALTER TABLE prv_cnf_SoftwarePackage ADD CONSTRAINT FK_prv_cnf_SoftwarePackage_prv_SoftwarePackage 
	FOREIGN KEY (packageId) REFERENCES prv_SoftwarePackage (packageId);

ALTER TABLE prv_PolicyKey ADD CONSTRAINT FK_prv_PolicyKey_prv_PolicyFile 
	FOREIGN KEY (policyFileId) REFERENCES prv_PolicyFile (policyFileId);

ALTER TABLE _mops_EonQueue ADD CONSTRAINT FK__mopsEonQueue_MovingObject 
	FOREIGN KEY (movingObjectId) REFERENCES MovingObject (movingObjectId);

ALTER TABLE _mops_MoidQueue ADD CONSTRAINT FK__mops_MoidQueue_MovingObject 
	FOREIGN KEY (movingObjectId) REFERENCES MovingObject (movingObjectId);

ALTER TABLE mops_SSM ADD CONSTRAINT FK_mopsSSM_mopsSSMDesc 
	FOREIGN KEY (ssmDescId) REFERENCES mops_SSMDesc (ssmDescId);

ALTER TABLE mops_Tracklet ADD CONSTRAINT FK_mopsTracklets_mopsSSM 
	FOREIGN KEY (ssmId) REFERENCES mops_SSM (ssmId);

ALTER TABLE Source_pt2 ADD CONSTRAINT FK_Source_Object 
	FOREIGN KEY (objectId) REFERENCES Object (objectId);
