
-- One-time setup actions for LSST database stored functions 
-- and procedures - assumes the LSST Database Schema already exists.
-- $Author$
-- $Revision$
-- $Date$
--
-- See <http://lsstdev.ncsa.uiuc.edu/trac/wiki/Copyrights>
-- for copyright information.


DELIMITER //

-- ===========================   SDQA   =========================== --

-- Created: 24 October 2008, R. Laher (laher@ipac.caltech.edu)
--
-- Insert a new record into the SDQA_Threshold table. 
--
-- Modifications: 
--
-- 8 December 2008, R. Laher (laher@ipac.caltech.edu)
-- Removed code associated with versioning of SDQA_Threshold records,
-- since is to be handled by provenance.
--

-- Returns number of elements inserted.
-- Negative value indicates an error:
-- -1: metric not found
-- -2: insert failed
CREATE FUNCTION addSdqaThresholdRecord (
    metricName_      VARCHAR(30),
    upperThreshold_  DOUBLE,
    lowerThreshold_  DOUBLE
) RETURNS INT

BEGIN

    DECLARE sdqa_thresholdId_ SMALLINT;
    DECLARE sdqa_metricId_    SMALLINT;


    -- Get sdqa_metricId.
    SELECT sdqa_metricId INTO sdqa_metricId_
    FROM   sdqa_Metric
    WHERE  metricName = metricName_;

    IF sdqa_metricId_ IS NULL THEN
        RETURN -1;
    END IF;

    -- Insert SDQA_Threshold record.
    INSERT INTO sdqa_Threshold ( sdqa_metricId, 
                                 upperThreshold, 
                                 lowerThreshold, 
                                 createdDate )
    VALUES ( sdqa_metricId_, 
             upperThreshold_, 
             lowerThreshold_, 
             now() );

    SELECT LAST_INSERT_ID() INTO sdqa_thresholdId_;

    IF sdqa_thresholdId_ IS NULL THEN
        RETURN -2;
    END IF;

    RETURN sdqa_thresholdId_;
END
//

DELIMITER ;

-- ===========================   Time   =========================== --

-- Created by K.-T. Lim (ktl@slac.stanford.edu)

--
-- Table of leap seconds.
--

CREATE TABLE LeapSeconds (
    whenJd FLOAT NOT NULL,
    offset FLOAT NOT NULL,
    mjdRef FLOAT NOT NULL,
    drift FLOAT NOT NULL,
    whenMjdUtc FLOAT NULL,
    whenUtc BIGINT NULL,
    whenTai BIGINT NULL
);

INSERT INTO LeapSeconds (whenJd, offset, mjdRef, drift) VALUES
    (2437300.5, 1.4228180, 37300., 0.001296),
    (2437512.5, 1.3728180, 37300., 0.001296),
    (2437665.5, 1.8458580, 37665., 0.0011232),
    (2438334.5, 1.9458580, 37665., 0.0011232),
    (2438395.5, 3.2401300, 38761., 0.001296),
    (2438486.5, 3.3401300, 38761., 0.001296),
    (2438639.5, 3.4401300, 38761., 0.001296),
    (2438761.5, 3.5401300, 38761., 0.001296),
    (2438820.5, 3.6401300, 38761., 0.001296),
    (2438942.5, 3.7401300, 38761., 0.001296),
    (2439004.5, 3.8401300, 38761., 0.001296),
    (2439126.5, 4.3131700, 39126., 0.002592),
    (2439887.5, 4.2131700, 39126., 0.002592),
    (2441317.5, 10.0, 41317., 0.0),
    (2441499.5, 11.0, 41317., 0.0),
    (2441683.5, 12.0, 41317., 0.0),
    (2442048.5, 13.0, 41317., 0.0),
    (2442413.5, 14.0, 41317., 0.0),
    (2442778.5, 15.0, 41317., 0.0),
    (2443144.5, 16.0, 41317., 0.0),
    (2443509.5, 17.0, 41317., 0.0),
    (2443874.5, 18.0, 41317., 0.0),
    (2444239.5, 19.0, 41317., 0.0),
    (2444786.5, 20.0, 41317., 0.0),
    (2445151.5, 21.0, 41317., 0.0),
    (2445516.5, 22.0, 41317., 0.0),
    (2446247.5, 23.0, 41317., 0.0),
    (2447161.5, 24.0, 41317., 0.0),
    (2447892.5, 25.0, 41317., 0.0),
    (2448257.5, 26.0, 41317., 0.0),
    (2448804.5, 27.0, 41317., 0.0),
    (2449169.5, 28.0, 41317., 0.0),
    (2449534.5, 29.0, 41317., 0.0),
    (2450083.5, 30.0, 41317., 0.0),
    (2450630.5, 31.0, 41317., 0.0),
    (2451179.5, 32.0, 41317., 0.0),
    (2453736.5, 33.0, 41317., 0.0),
    (2454832.5, 34.0, 41317., 0.0);

UPDATE LeapSeconds
    SET whenMjdUtc = whenJd - 2400000.5,
        whenUtc = CAST((whenMjdUtc - 40587.0) * 86.4e12 AS SIGNED),
        whenTai = whenUtc +
            CAST(1.0e9 * (offset + (whenMjdUtc - mjdRef) * drift) AS SIGNED);


DELIMITER //

--
-- Function to convert UTC nanoseconds to TAI nanoseconds.
--

CREATE FUNCTION utcToTai (
    nsecs_ BIGINT
) RETURNS BIGINT
BEGIN
    DECLARE nsecsPerDay_ DOUBLE;
    DECLARE epochInMjd_ DOUBLE;
    DECLARE offset_ FLOAT;
    DECLARE mjdRef_ FLOAT;
    DECLARE drift_ FLOAT;
    DECLARE mjd_ DOUBLE;
    DECLARE leapSecs_ DOUBLE;

    SET nsecsPerDay_ = 86.4e12;
    SET epochInMjd_ = 40587.0;
    SELECT offset, mjdRef, drift INTO offset_, mjdRef_, drift_
        FROM LeapSeconds
        WHERE whenUtc = (
            SELECT MAX(whenUtc) FROM LeapSeconds WHERE whenUtc <= nsecs_
        );
    SET mjd_ = nsecs_ / nsecsPerDay_ + epochInMjd_;
    SET leapSecs_ = offset_ + (mjd_ - mjdRef_) * drift_;
    
    RETURN nsecs_ + CAST(leapSecs_ * 1.0e9 + 0.5 AS SIGNED INTEGER);

END
//


--
-- Function to convert TAI nanoseconds to UTC nanoseconds.
--

CREATE FUNCTION taiToUtc (
    nsecs_ BIGINT
) RETURNS BIGINT
BEGIN

    DECLARE nsecsPerDay_ DOUBLE;
    DECLARE epochInMjd_ DOUBLE;
    DECLARE offset_ FLOAT;
    DECLARE mjdRef_ FLOAT;
    DECLARE drift_ FLOAT;
    DECLARE taiSecs_ DOUBLE;
    DECLARE leapSecs_ DOUBLE;

    SET nsecsPerDay_ = 86.4e12;
    SET epochInMjd_ = 40587.0;
    SELECT offset, mjdRef, drift INTO offset_, mjdRef_, drift_
        FROM LeapSeconds
        WHERE whenTai = (
            SELECT MAX(whenTai) FROM LeapSeconds WHERE whenTai <= nsecs_
        );
    SET taiSecs_ = nsecs_ / 1.0e9;
    SET leapSecs_ = taiSecs_ -
        (taiSecs_ - offset_ - drift_ * (epochInMjd_ - mjdRef_)) /
        (1.0 + drift_ * 1.0e9 / nsecsPerDay_);
    RETURN nsecs_ - CAST(leapSecs_ * 1.0e9 + 0.5 AS SIGNED);

END
//


--
-- Function to convert TAI nanoseconds to Modified Julian Days (UTC).
--

CREATE FUNCTION taiToMjdUtc (
    nsecs_ BIGINT
) RETURNS DOUBLE
BEGIN
    RETURN taiToUTC(nsecs_) / 86.4e12 + 40587.0;
END
//


--
-- Function to convert TAI nanoseconds to Modified Julian Days (TAI).
--

CREATE FUNCTION taiToMjdTai (
    nsecs_ BIGINT
) RETURNS DOUBLE
BEGIN
    RETURN nsecs_ / 86.4e12 + 40587.0;
END
//


--
-- Function to convert Modified Julian Days (TAI) to TAI nanoseconds.
--

CREATE FUNCTION mjdTaiToTai (
    mjdTai_ FLOAT
) RETURNS BIGINT
BEGIN
    RETURN (mjdTai_ - 40587.0) * 86.4e12;
END
//


--
-- Function to convert Modified Julian Days (UTC) to TAI nanoseconds.
--

CREATE FUNCTION mjdUtcToTai (
    mjdUtc_ FLOAT
) RETURNS BIGINT
BEGIN
    RETURN utcToTai((mjdUtc_ - 40587.0) * 86.4e12);
END
//

DELIMITER ;
