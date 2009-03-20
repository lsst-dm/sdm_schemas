
-- LSST Database Schema
-- $Author$
-- $Revision$
-- $Date$
--
-- See <http://lsstdev.ncsa.uiuc.edu:8100/trac/wiki/Copyrights>
-- for copyright information.


CREATE TABLE AAA_Version_3_0_22 (version CHAR);

CREATE TABLE Science_Amp_Exposure
(
	scienceAmpExposureId BIGINT NOT NULL,
	scienceCCDExposureId BIGINT NOT NULL,
	rawAmpExposureId BIGINT NULL,
	ampId INTEGER NULL,
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
	dateObs TIMESTAMP NULL DEFAULT 0,
	expTime FLOAT(0) NULL,
	ccdSize VARCHAR(50) NULL,
	photoFlam FLOAT(0) NULL,
	photoZP FLOAT(0) NULL,
	nCombine INTEGER NULL DEFAULT 1,
	taiMjd DOUBLE NULL,
	bixX INTEGER NULL,
	binY INTEGER NULL,
	readNoise DOUBLE NULL,
	saturationLimit BIGINT NULL,
	dataSection VARCHAR(24) NULL,
	gain DOUBLE NULL,
	PRIMARY KEY (scienceAmpExposureId),
	KEY (rawAmpExposureId),
	KEY (scienceCCDExposureId)
) ;


CREATE TABLE mops_TrackletsToDIASource
(
	trackletId BIGINT NOT NULL,
	diaSourceId BIGINT NOT NULL,
	PRIMARY KEY (trackletId, diaSourceId),
	INDEX idx_mopsTrackletsToDIASource_diaSourceId (diaSourceId ASC),
	KEY (trackletId)
) ;


CREATE TABLE mops_MovingObjectToTracklet
(
	movingObjectId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	INDEX idx_mopsMovingObjectToTracklets_movingObjectId (movingObjectId ASC),
	INDEX idx_mopsMovingObjectToTracklets_trackletId (trackletId ASC)
) ;


CREATE TABLE mops_Event_TrackletRemoval
(
	eventId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	PRIMARY KEY (eventId),
	INDEX idx_mopsEventTrackletRemoval_trackletId (trackletId ASC),
	KEY (eventId)
) ;


CREATE TABLE mops_Event_TrackletPrecovery
(
	eventId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	ephemerisDistance FLOAT(0) NOT NULL,
	ephemerisUncertainty FLOAT(0) NULL,
	PRIMARY KEY (eventId),
	INDEX idx_mopsEventTrackletPrecovery_trackletId (trackletId ASC),
	KEY (eventId)
) ;


CREATE TABLE mops_Event_TrackletAttribution
(
	eventId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	ephemerisDistance FLOAT(0) NOT NULL,
	ephemerisUncertainty FLOAT(0) NULL,
	PRIMARY KEY (eventId),
	INDEX idx_mopsEventTrackletAttribution_trackletId (trackletId ASC),
	KEY (eventId)
) ;


CREATE TABLE mops_Event_OrbitIdentification
(
	eventId BIGINT NOT NULL,
	childObjectId BIGINT NOT NULL,
	PRIMARY KEY (eventId),
	INDEX idx_mopsEventOrbitIdentification2MovingObject_childObjectId (childObjectId ASC),
	KEY (eventId)
) ;


CREATE TABLE mops_Event_OrbitDerivation
(
	eventId BIGINT NOT NULL,
	trackletId BIGINT NOT NULL,
	PRIMARY KEY (eventId, trackletId),
	INDEX idx_mopsEventDerivation_trackletId (trackletId ASC),
	KEY (eventId)
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


CREATE TABLE _mops_EonQueue
(
	movingObjectId BIGINT NOT NULL,
	eventId BIGINT NOT NULL,
	insertTime TIMESTAMP NOT NULL,
	status CHAR(1) NULL DEFAULT 'I',
	PRIMARY KEY (movingObjectId),
	KEY (movingObjectId),
	INDEX idx__mopsEonQueue_eventId (eventId ASC)
) ;


CREATE TABLE Raw_Amp_Exposure
(
	rawAmpExposureId BIGINT NOT NULL,
	rawCCDExposureId BIGINT NOT NULL,
	ampId INTEGER NOT NULL,
	radecSys VARCHAR(20) NULL,
	url VARCHAR(255) NOT NULL,
	ctype1 VARCHAR(20) NOT NULL,
	ctype2 VARCHAR(20) NOT NULL,
	crpix1 FLOAT(0) NOT NULL,
	crpix2 FLOAT(0) NOT NULL,
	crval1 DOUBLE NOT NULL,
	crval2 DOUBLE NOT NULL,
	cd11 DOUBLE NOT NULL,
	cd21 DOUBLE NOT NULL,
	cd12 DOUBLE NOT NULL,
	cd22 DOUBLE NOT NULL,
	taiObs TIMESTAMP NOT NULL DEFAULT 0,
	darkTime FLOAT(0) NULL,
	zd FLOAT(0) NULL,
	PRIMARY KEY (rawAmpExposureId),
	KEY (rawCCDExposureId)
) ;


CREATE TABLE _Raw_FPA_ExposureToVisit
(
	visitId INTEGER NOT NULL,
	exposureId BIGINT NOT NULL,
	KEY (exposureId),
	KEY (exposureId),
	KEY (visitId)
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


CREATE TABLE sdqa_Rating_ForScienceFPAExposure
(
	sdqa_ratingId BIGINT NOT NULL AUTO_INCREMENT,
	sdqa_metricId SMALLINT NOT NULL,
	sdqa_thresholdId SMALLINT NOT NULL,
	exposureId INTEGER NOT NULL,
	metricValue DOUBLE NOT NULL,
	metricErr DOUBLE NOT NULL,
	PRIMARY KEY (sdqa_ratingId),
	UNIQUE UQ_sdqa_Rating_ForScienceFPAExposure_metricId_exposureId(sdqa_metricId, exposureId),
	KEY (exposureId),
	KEY (sdqa_metricId),
	KEY (sdqa_thresholdId)
) ;


CREATE TABLE sdqa_Rating_ForScienceCCDExposure
(
	sdqa_ratingId BIGINT NOT NULL AUTO_INCREMENT,
	sdqa_metricId SMALLINT NOT NULL,
	sdqa_thresholdId SMALLINT NOT NULL,
	ccdExposureId BIGINT NOT NULL,
	metricValue DOUBLE NOT NULL,
	metricErr DOUBLE NOT NULL,
	PRIMARY KEY (sdqa_ratingId),
	UNIQUE UQ_sdqa_Rating_ForScienceCCDExposure_metricId_ccdExposureId(sdqa_metricId, ccdExposureId),
	KEY (sdqa_metricId),
	KEY (sdqa_thresholdId),
	KEY (ccdExposureId)
) ;


CREATE TABLE prv_cnf_PolicyKey
(
	policyKeyId INTEGER NOT NULL,
	value TEXT NULL,
	validityBegin DATETIME NULL,
	validityEnd DATETIME NULL,
	PRIMARY KEY (policyKeyId),
	KEY (policyKeyId)
) ;


CREATE TABLE DIASource
(
	diaSourceId BIGINT NOT NULL,
	ampExposureId BIGINT NOT NULL,
	diaSourceToId BIGINT NULL,
	filterId TINYINT NOT NULL,
	objectId BIGINT NULL,
	movingObjectId BIGINT NULL,
	xAstrom DOUBLE NOT NULL,
	xAstromErr FLOAT(0) NULL,
	yAstrom DOUBLE NOT NULL,
	yAstromErr FLOAT(0) NULL,
	ra DOUBLE NOT NULL,
	raErrForDetection FLOAT(0) NULL,
	raErrForWcs FLOAT(0) NULL,
	decl DOUBLE NOT NULL,
	declErrForDetection FLOAT(0) NULL,
	declErrForWcs FLOAT(0) NULL,
	taiMidPoint DOUBLE NOT NULL,
	taiRange DOUBLE NOT NULL,
	Ixx FLOAT(0) NULL,
	IxxErr FLOAT(0) NULL,
	Iyy FLOAT(0) NULL,
	IyyErr FLOAT(0) NULL,
	Ixy FLOAT(0) NULL,
	IxyErr FLOAT(0) NULL,
	psfFlux DOUBLE NOT NULL,
	psfFluxErr FLOAT(0) NULL,
	apFlux DOUBLE NOT NULL,
	apFluxErr FLOAT(0) NULL,
	modelFlux DOUBLE NOT NULL,
	modelFluxErr FLOAT(0) NULL,
	instFlux DOUBLE NOT NULL,
	instFluxErr FLOAT(0) NULL,
	apDia FLOAT(0) NULL,
	flagForClassification BIGINT NULL,
	flagForDetection BIGINT NULL,
	snr FLOAT(0) NOT NULL,
	chi2 FLOAT(0) NOT NULL,
	PRIMARY KEY (diaSourceId),
	UNIQUE UQ_DIASource_diaSourceToId(diaSourceToId),
	KEY (movingObjectId),
	KEY (ampExposureId),
	KEY (filterId),
	KEY (movingObjectId),
	KEY (objectId)
) TYPE=MyISAM;


CREATE TABLE Visit
(
	visitId INTEGER NOT NULL,
	exposureId BIGINT NOT NULL,
	KEY (exposureId)
) ;


CREATE TABLE Science_CCD_Exposure
(
	scienceCCDExposureId BIGINT NOT NULL,
	scienceFPAExposureId BIGINT NOT NULL,
	rawCCDExposureId BIGINT NULL,
	PRIMARY KEY (scienceCCDExposureId),
	KEY (rawCCDExposureId),
	KEY (scienceFPAExposureId)
) ;


CREATE TABLE Raw_CCD_Exposure
(
	rawCCDExposureId BIGINT NOT NULL,
	rawFPAExposureId BIGINT NOT NULL,
	PRIMARY KEY (rawCCDExposureId),
	KEY (rawFPAExposureId)
) ;


CREATE TABLE _Science_FPA_ExposureToTemplateImage
(
	scienceFPAExposureId BIGINT NOT NULL,
	templateImageId INTEGER NOT NULL,
	KEY (scienceFPAExposureId),
	KEY (templateImageId),
	KEY (scienceFPAExposureId)
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


CREATE TABLE sdqa_Rating_ForScienceAmpExposure
(
	sdqa_ratingId BIGINT NOT NULL AUTO_INCREMENT,
	sdqa_metricId SMALLINT NOT NULL,
	sdqa_thresholdId SMALLINT NOT NULL,
	ampExposureId BIGINT NOT NULL,
	metricValue DOUBLE NOT NULL,
	metricErr DOUBLE NOT NULL,
	PRIMARY KEY (sdqa_ratingId),
	UNIQUE UQ_sdqa_Rating_ForScienceAmpExposure_metricId_ampExposureId(sdqa_metricId, ampExposureId),
	KEY (sdqa_metricId),
	KEY (sdqa_thresholdId),
	KEY (ampExposureId)
) ;


CREATE TABLE _ObjectToType
(
	objectId BIGINT NOT NULL,
	typeId SMALLINT NOT NULL,
	probability TINYINT NULL DEFAULT 100,
	KEY (typeId),
	KEY (objectId)
) ;


CREATE TABLE _MovingObjectToType
(
	movingObjectId BIGINT NOT NULL,
	typeId SMALLINT NOT NULL,
	probability TINYINT NULL DEFAULT 100,
	KEY (typeId),
	KEY (movingObjectId)
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


CREATE TABLE prv_cnf_SoftwarePackage
(
	packageId INTEGER NOT NULL,
	version VARCHAR(255) NOT NULL,
	directory VARCHAR(255) NOT NULL,
	validityBegin DATETIME NULL,
	validityEnd DATETIME NULL,
	PRIMARY KEY (packageId),
	KEY (packageId)
) ;


CREATE TABLE WCSSource
(
	wcsSourceId BIGINT NOT NULL,
	ampExposureId BIGINT NULL,
	filterId TINYINT NULL,
	wcsObjectId BIGINT NULL,
	wcsObjectRa DOUBLE NULL,
	wcsObjectRaErr FLOAT(0) NULL,
	wcsObjectDecl DOUBLE NULL,
	wcsObjectDeclErr FLOAT(0) NULL,
	ra DOUBLE NULL,
	raErr FLOAT(0) NULL,
	decl DOUBLE NULL,
	declErr FLOAT(0) NULL,
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
	psfFlux DOUBLE NULL,
	psfFluxErr FLOAT(0) NULL,
	apFlux DOUBLE NULL,
	apFluxErr FLOAT(0) NULL,
	modelFlux DOUBLE NULL,
	modelFluxErr FLOAT(0) NULL,
	petroFlux DOUBLE NULL,
	petroFluxErr FLOAT(0) NULL,
	instFlux DOUBLE NULL,
	instFluxErr FLOAT(0) NULL,
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
	snr FLOAT(0) NULL,
	chi2 FLOAT(0) NULL,
	sky FLOAT(0) NULL,
	skyErr FLOAT(0) NULL,
	flag BIGINT NULL,
	PRIMARY KEY (wcsSourceId),
	KEY (ampExposureId),
	KEY (filterId),
	KEY (raErr),
	KEY (wcsObjectId)
) TYPE=MyISAM;


CREATE TABLE Object
(
	objectId BIGINT NOT NULL,
	ra DOUBLE NOT NULL,
	decl DOUBLE NOT NULL,
	earliestObsT DATETIME NULL,
	latestObsT DATETIME NULL,
	uMag DOUBLE NULL,
	uMagErr DOUBLE NULL,
	uPetroMag FLOAT(0) NULL,
	uPetroMagErr FLOAT(0) NULL,
	uIxx FLOAT(0) NULL,
	uIyy FLOAT(0) NULL,
	uIxy FLOAT(0) NULL,
	uNumObs INTEGER NULL,
	uFlags INTEGER NULL,
	gMag DOUBLE NULL,
	gMagErr DOUBLE NULL,
	gPetroMag FLOAT(0) NULL,
	gPetroMagErr FLOAT(0) NULL,
	gIxx FLOAT(0) NULL,
	gIyy FLOAT(0) NULL,
	gIxy FLOAT(0) NULL,
	gNumObs INTEGER NULL,
	gFlags INTEGER NULL,
	rMag DOUBLE NULL,
	rMagErr DOUBLE NULL,
	rPetroMag FLOAT(0) NULL,
	rPetroMagErr FLOAT(0) NULL,
	rIxx FLOAT(0) NULL,
	rIyy FLOAT(0) NULL,
	rIxy FLOAT(0) NULL,
	rNumObs INTEGER NULL,
	rFlags INTEGER NULL,
	iMag DOUBLE NULL,
	iMagErr DOUBLE NULL,
	iPetroMag FLOAT(0) NULL,
	iPetroMagErr FLOAT(0) NULL,
	iIxx FLOAT(0) NULL,
	iIyy FLOAT(0) NULL,
	iIxy FLOAT(0) NULL,
	iNumObs INTEGER NULL,
	iFlags INTEGER NULL,
	zMag DOUBLE NULL,
	zMagErr DOUBLE NULL,
	zPetroMag FLOAT(0) NULL,
	zPetroMagErr FLOAT(0) NULL,
	zIxx FLOAT(0) NULL,
	zIyy FLOAT(0) NULL,
	zIxy FLOAT(0) NULL,
	zNumObs INTEGER NULL,
	zFlags INTEGER NULL,
	yMag DOUBLE NULL,
	yMagErr DOUBLE NULL,
	yPetroMag FLOAT(0) NULL,
	yPetroMagErr FLOAT(0) NULL,
	yIxx FLOAT(0) NULL,
	yIyy FLOAT(0) NULL,
	yIxy FLOAT(0) NULL,
	yNumObs INTEGER NULL,
	yFlags INTEGER NULL,
	PRIMARY KEY (objectId)
) TYPE=MyISAM;


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


CREATE TABLE _tmpl_WCSSource
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
	flagForAssociation SMALLINT NULL,
	flagForDetection SMALLINT NULL,
	flagForWcs SMALLINT NULL,
	PRIMARY KEY (sourceId),
	KEY (ampExposureId),
	KEY (filterId),
	KEY (movingObjectId),
	KEY (objectId),
	KEY (procHistoryId)
) TYPE=MyISAM;


CREATE TABLE Science_FPA_Exposure
(
	scienceFPAExposureId BIGINT NOT NULL,
	PRIMARY KEY (scienceFPAExposureId)
) ;


CREATE TABLE Raw_FPA_Exposure
(
	rawFPAExposureId BIGINT NOT NULL,
	ra DOUBLE NOT NULL,
	decl DOUBLE NOT NULL,
	filterId INTEGER NOT NULL,
	equinox FLOAT(0) NOT NULL,
	dateObs TIMESTAMP NOT NULL DEFAULT 0,
	mjdObs DOUBLE NULL,
	expTime FLOAT(0) NOT NULL,
	airmass FLOAT(0) NULL,
	PRIMARY KEY (rawFPAExposureId)
) ;


CREATE TABLE mops_SSMDesc
(
	ssmDescId SMALLINT NOT NULL AUTO_INCREMENT,
	prefix CHAR(4) NULL,
	description VARCHAR(100) NULL,
	PRIMARY KEY (ssmDescId)
) ;


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


CREATE TABLE _mops_Config
(
	configId BIGINT NOT NULL AUTO_INCREMENT,
	configText TEXT NULL,
	PRIMARY KEY (configId)
) ;


CREATE TABLE sdqa_Metric
(
	sdqa_metricId SMALLINT NOT NULL AUTO_INCREMENT,
	metricName VARCHAR(30) NOT NULL,
	physicalUnits VARCHAR(30) NOT NULL,
	dataType CHAR(1) NOT NULL,
	definition VARCHAR(255) NOT NULL,
	PRIMARY KEY (sdqa_metricId),
	UNIQUE UQ_sdqa_Metric_metricName(metricName)
) ;


CREATE TABLE sdqa_ImageStatus
(
	sdqa_imageStatusId SMALLINT NOT NULL AUTO_INCREMENT,
	statusName VARCHAR(30) NOT NULL,
	definition VARCHAR(255) NOT NULL,
	PRIMARY KEY (sdqa_imageStatusId)
) ;


CREATE TABLE ObjectType
(
	typeId SMALLINT NOT NULL,
	description VARCHAR(255) NULL,
	PRIMARY KEY (typeId)
) ;


CREATE TABLE Filter
(
	filterId INTEGER NOT NULL,
	filtURL VARCHAR(255) NULL,
	filtName VARCHAR(255) NOT NULL,
	photClam FLOAT(0) NOT NULL,
	photBW FLOAT(0) NOT NULL,
	PRIMARY KEY (filterId)
) ;


CREATE TABLE CCD_Detector
(
	ccdDetectorId INTEGER NOT NULL DEFAULT 1,
	biasSec VARCHAR(20) NOT NULL DEFAULT '[0:0,0:0]',
	trimSec VARCHAR(20) NOT NULL DEFAULT '[0:0,0:0]',
	gain FLOAT(0) NULL,
	rdNoise FLOAT(0) NULL,
	saturate FLOAT(0) NULL,
	PRIMARY KEY (ccdDetectorId)
) ;


CREATE TABLE _tmpl_MatchPair
(
	first BIGINT NOT NULL,
	second BIGINT NOT NULL,
	distance DOUBLE NOT NULL
) ;


CREATE TABLE _tmpl_IdPair
(
	first BIGINT NOT NULL,
	second BIGINT NOT NULL
) ;


CREATE TABLE _tmpl_Id
(
	id BIGINT NOT NULL
) ;


CREATE TABLE prv_SoftwarePackage
(
	packageId INTEGER NOT NULL,
	packageName VARCHAR(64) NOT NULL,
	PRIMARY KEY (packageId)
) ;


CREATE TABLE prv_Run
(
	offset INTEGER NOT NULL AUTO_INCREMENT,
	runId VARCHAR(255) NOT NULL,
	PRIMARY KEY (offset),
	UNIQUE UQ_prv_Run_runId(runId)
) ;


CREATE TABLE prv_PolicyFile
(
	policyFileId INTEGER NOT NULL,
	pathName VARCHAR(255) NOT NULL,
	hashValue CHAR(32) NOT NULL,
	modifiedDate BIGINT NOT NULL,
	PRIMARY KEY (policyFileId)
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





ALTER TABLE Science_Amp_Exposure ADD CONSTRAINT FK_Science_Amp_Exposure_Raw_Amp_Exposure 
	FOREIGN KEY (rawAmpExposureId) REFERENCES Raw_Amp_Exposure (rawAmpExposureId);

ALTER TABLE Science_Amp_Exposure ADD CONSTRAINT FK_Science_Amp_Exposure_Science_CCD_Exposure 
	FOREIGN KEY (scienceCCDExposureId) REFERENCES Science_CCD_Exposure (scienceCCDExposureId);

ALTER TABLE _mops_MoidQueue ADD CONSTRAINT FK__mops_MoidQueue_MovingObject 
	FOREIGN KEY (movingObjectId) REFERENCES MovingObject (movingObjectId);

ALTER TABLE _mops_EonQueue ADD CONSTRAINT FK__mopsEonQueue_MovingObject 
	FOREIGN KEY (movingObjectId) REFERENCES MovingObject (movingObjectId);

ALTER TABLE Raw_Amp_Exposure ADD CONSTRAINT FK_Raw_Amp_Exposure_Raw_CCD_Exposure 
	FOREIGN KEY (rawCCDExposureId) REFERENCES Raw_CCD_Exposure (rawCCDExposureId);

ALTER TABLE mops_Tracklet ADD CONSTRAINT FK_mops_Tracklet_Science_CCD_Exposure 
	FOREIGN KEY (ccdExposureId) REFERENCES Science_CCD_Exposure (scienceCCDExposureId);

ALTER TABLE mops_Tracklet ADD CONSTRAINT FK_mopsTracklets_mopsSSM 
	FOREIGN KEY (ssmId) REFERENCES mops_SSM (ssmId);

ALTER TABLE mops_Event ADD CONSTRAINT FK_mops_Event_Science_CCD_Exposure 
	FOREIGN KEY (ccdExposureId) REFERENCES Science_CCD_Exposure (scienceCCDExposureId);

ALTER TABLE prv_cnf_PolicyKey ADD CONSTRAINT FK_prv_cnf_PolicyKey_prv_PolicyKey 
	FOREIGN KEY (policyKeyId) REFERENCES prv_PolicyKey (policyKeyId);

ALTER TABLE DIASource ADD CONSTRAINT FK_DIASource_MovingObject 
	FOREIGN KEY (movingObjectId) REFERENCES MovingObject (movingObjectId);

ALTER TABLE Visit ADD CONSTRAINT FK_Visit_Raw_FPA_Exposure 
	FOREIGN KEY (exposureId) REFERENCES Raw_FPA_Exposure (rawFPAExposureId);

ALTER TABLE Science_CCD_Exposure ADD CONSTRAINT FK_Science_CCD_Exposure_Raw_CCD_Exposure 
	FOREIGN KEY (rawCCDExposureId) REFERENCES Raw_CCD_Exposure (rawCCDExposureId);

ALTER TABLE Science_CCD_Exposure ADD CONSTRAINT FK_Science_CCD_Exposure_Science_FPA_Exposure 
	FOREIGN KEY (scienceFPAExposureId) REFERENCES Science_FPA_Exposure (scienceFPAExposureId);

ALTER TABLE Raw_CCD_Exposure ADD CONSTRAINT FK_Raw_CCD_Exposure_Raw_FPA_Exposure 
	FOREIGN KEY (rawFPAExposureId) REFERENCES Raw_FPA_Exposure (rawFPAExposureId);

ALTER TABLE mops_SSM ADD CONSTRAINT FK_mopsSSM_mopsSSMDesc 
	FOREIGN KEY (ssmDescId) REFERENCES mops_SSMDesc (ssmDescId);

ALTER TABLE sdqa_Threshold ADD CONSTRAINT FK_sdqa_Threshold_sdqa_Metric 
	FOREIGN KEY (sdqa_metricId) REFERENCES sdqa_Metric (sdqa_metricId);

ALTER TABLE prv_PolicyKey ADD CONSTRAINT FK_prv_PolicyKey_prv_PolicyFile 
	FOREIGN KEY (policyFileId) REFERENCES prv_PolicyFile (policyFileId);

ALTER TABLE prv_cnf_SoftwarePackage ADD CONSTRAINT FK_prv_cnf_SoftwarePackage_prv_SoftwarePackage 
	FOREIGN KEY (packageId) REFERENCES prv_SoftwarePackage (packageId);
