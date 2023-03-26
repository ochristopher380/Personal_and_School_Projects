-- Create computed columns 

ALTER TABLE Cases ADD FirmProcessingTime AS (DATEDIFF(DAY,OpenedDate, FiledDate))

ALTER TABLE Cases ADD GovProcessingTime AS (DATEDIFF(DAY, FiledDate, ApprovedDate))

SELECT * FROM Cases

-- Create Stored Procedures 
GO
CREATE PROCEDURE CreateClient
@CorpName VARCHAR(30),
@ClientLname VARCHAR(30),
@ClientFName VARCHAR(30),
@ClientDOB DATE,
@ClientEmail VARCHAR(40)
AS
DECLARE @CorpID INT

SET @CorpID = (SELECT CorporationID
				FROM Corporation
				WHERE CorporationName = @CorpName)

IF @CorpID IS NULL
BEGIN
PRINT 'CorpID has returned NULL, check CorpName Spelling';
THROW 50001, 'CorpID has returned NULL, terminating', 1;
END

BEGIN TRAN T1
INSERT INTO Clients(CorporationID, ClientFName, ClientLName, ClientDOB, ClientEmail)
VALUES (@CorpID, @ClientFName, @ClientLname, @ClientDOB, @ClientEmail)
COMMIT TRAN T1
GO

GO 
CREATE PROCEDURE CreateCorp
@IndustryName VARCHAR(30),
@CorpName VARCHAR(30),
@CorpDesc VARCHAR(100),
@CorpCity VARCHAR(30),
@CorpState VARCHAR(20),
@CorpAddress VARCHAR(30),
@CorpZipCode CHAR(5),
@FEIN CHAR(9)
AS
DECLARE @IndustryTypeID INT

SET @IndustryTypeID = (SELECT IndustryTypeID
						FROM IndustryType
						WHERE IndustryName = @IndustryName)

IF @IndustryTypeID IS NULL
BEGIN
PRINT 'IndustryTypeID has returned NULL, check IndustryName Spelling';
THROW 50002, 'IndustryTypeID has returned NULL, terminating', 1;
END

BEGIN TRAN T2
INSERT INTO Corporation (IndustryTypeID, CorporationName, CorporationDescription, CorpCity, CorpState, CorpAddressLineOne, CorpZipCode, FEIN)
VALUES (@IndustryTypeID, @CorpName, @CorpDesc, @CorpCity, @CorpState, @CorpAddress, @CorpZipCode, @FEIN)
COMMIT TRAN T2
GO

-- Complex Querries 

SELECT TOP 5 A.CorporationID, A.CorporationName, COUNT(C.CaseID) AS OpenCaseCount
FROM Corporation AS A
JOIN Clients AS B ON (A.CorporationID = B.CorporationID)
JOIN Cases AS C ON (B.ClientID = C.ClientID)
JOIN CaseStatus AS D ON (C.StatusID= D.StatusID)
WHERE D.StatusName = 'In Process'
GROUP BY A.CorporationID, A.CorporationName
ORDER BY COUNT(C.CaseID) DESC

SELECT A.AttorneyID, A.AttorneyFName, A.AttorneyLName, COUNT(E.IndustryTypeID) AS CountOfIndustriesPracticedIn
FROM Attorney AS A
JOIN Cases AS B ON (A.AttorneyID = B.AttorneyID)
JOIN Clients AS C ON (B.ClientID = C.ClientID)
JOIN Corporation AS D ON (C.CorporationID = D.CorporationID)
JOIN IndustryType AS E ON (D.IndustryTypeID = E.IndustryTypeID)
GROUP BY A.AttorneyID, A.AttorneyFName, A.AttorneyLName

-- Business Rules/Triggers 
GO
CREATE TRIGGER InsertOpenDate
ON Cases
AFTER INSERT AS
INSERT INTO Cases(OpenedDate)
VALUES(GETDATE())
GO

GO 
CREATE TRIGGER CheckValidityDates
ON Cases
FOR INSERT
AS
DECLARE @StartDate DATE, @EndDate DATE
SET @StartDate = (SELECT ValidityStart FROM INSERTED)
SET @EndDate = (SELECT ValidityEnd FROM INSERTED)
IF DATEDIFF(YEAR,@StartDate,@EndDate) > 3
BEGIN
PRINT 'Max Validity Exceeded'
ROLLBACK TRANSACTION
END
GO

