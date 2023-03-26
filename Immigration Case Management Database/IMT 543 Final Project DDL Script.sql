CREATE TABLE IndustryType
(IndustryTypeID INT IDENTITY(1,1) PRIMARY KEY,
IndustryName VARCHAR(50) NOT NULL,
IndustryDescription VARCHAR(150) NOT NULL,
NAICSCode CHAR(6) NOT NULL)

CREATE TABLE Attorney
(AttorneyID INT IDENTITY(1,1) PRIMARY KEY,
AttorneyFName VARCHAR(30) NOT NULL,
AttorneyLName VARCHAR(30) NOT NULL,
BarNumber VARCHAR(15) NOT NULL)

CREATE TABLE CaseStatus
(StatusID INT IDENTITY(1,1) PRIMARY KEY,
StatusName VARCHAR(50) NOT NULL,
StatusDescription VARCHAR(150) NOT NULL)

CREATE TABLE CaseType
(CaseTypeID INT IDENTITY(1,1) PRIMARY KEY,
CaseTypeName VARCHAR(100) NOT NULL,
CaseTypeDescription VARCHAR(200) NOT NULL)

CREATE TABLE LegalSupport
(LegalSupportID INT IDENTITY(1,1) PRIMARY KEY,
SupportFName VARCHAR(30) NOT NULL,
SupportLName VARCHAR(30) NOT NULL,
Title VARCHAR(30) NOT NULL)

CREATE TABLE QuestionnaireResults
(QuestionnaireID INT IDENTITY(1,1) PRIMARY KEY,
ClientCity VARCHAR(30) NOT NULL,
ClientState VARCHAR(20) NOT NULL,
ClientAddressLineOne VARCHAR(30) NOT NULL,
ClientZipCode CHAR(5) NOT NULL,
SSN CHAR(9) NOT NULL,
JobTitle VARCHAR(20) NOT NULL,
Salary DECIMAL(8,2) NOT NULL)

CREATE TABLE RevisedQuestionnaireResults
(RevisedQuestionnaireID INT IDENTITY(1,1) PRIMARY KEY,
RevisedClientCity VARCHAR(30) NOT NULL,
RevisedClientState VARCHAR(20) NOT NULL,
RevisedClientAddressLineOne VARCHAR(30) NOT NULL,
RevisedClientZipCode CHAR(5) NOT NULL,
RevisedSSN CHAR(9) NOT NULL,
RevisedJobTitle VARCHAR(20) NOT NULL,
RevisedSalary DECIMAL(8,2) NOT NULL)

CREATE TABLE Corporation
(CorporationID INT IDENTITY(1,1) PRIMARY KEY,
CorporationName VARCHAR(30) NOT NULL,
CorporationDescription VARCHAR(100) NOT NULL,
CorpCity VARCHAR(30) NOT NULL,
CorpState VARCHAR(20) NOT NULL,
CorpAddressLineOne VARCHAR(30) NOT NULL,
CorpZipCode CHAR(5) NOT NULL,
FEIN CHAR(9) NOT NULL)

CREATE TABLE Clients
(ClientID INT IDENTITY(1,1) PRIMARY KEY,
ClientFName VARCHAR(30) NULL,
ClientLName VARCHAR(30) NULL,
ClientDOB DATE NOT NULL,
ClientEmail VARCHAR(40) NOT NULL)

CREATE TABLE Cases
(CaseID INT IDENTITY(1,1) PRIMARY KEY,
OpenedDate DATE NOT NULL,
ClosedDate DATE NULL,
FiledDate DATE NULL,
ApprovedDate DATE NULL,
ValidityStart DATE NULL,
ValidityEnd DATE NULL)

ALTER TABLE Corporation
ADD IndustryTypeID INT NOT NULL
FOREIGN KEY (IndustryTypeID) REFERENCES IndustryType(IndustryTypeID);

ALTER TABLE Clients
ADD CorporationID INT NOT NULL,
FOREIGN KEY (CorporationID) REFERENCES Corporation(CorporationID);

ALTER TABLE RevisedQuestionnaireResults
ADD QuestionnaireID INT NOT NULL
FOREIGN KEY (QuestionnaireID) REFERENCES QuestionnaireResults(QuestionnaireID);

ALTER TABLE Cases
ADD ClientID INT NOT NULL
FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
AttorneyID INT NOT NULL
FOREIGN KEY (AttorneyID) REFERENCES Attorney(AttorneyID),
LegalSupportID INT NOT NULL
FOREIGN KEY (LegalSupportID) REFERENCES LegalSupport(LegalSupportID),
StatusID INT NOT NULL
FOREIGN KEY (StatusID) REFERENCES CaseStatus(StatusID),
CaseTypeID INT NOT NULL
FOREIGN KEY (CaseTypeID) REFERENCES CaseType(CaseTypeID),
RevisedQuestionnaireID INT NOT NULL
FOREIGN KEY (RevisedQuestionnaireID) REFERENCES RevisedQuestionnaireResults(RevisedQuestionnaireID);

INSERT INTO CaseStatus (StatusName, StatusDescription)
VALUES ('Approved', 'Case has been approved'),
('Closed', 'Case is closed and no longer under processing'),
('In Process', 'Case is currently being prepared for filing'),
('Filed', 'Case is filed and pending adjudication'),
('On Hold', 'Case has not been filed and is not being worked on')

INSERT INTO CaseType (CaseTypeName, CaseTypeDescription)
VALUES ('H-1B' , 'Initial H-1B Case'),
('L-1A', 'Initial L-1A Case'),
('L-1B', 'Initial L-1B Case'),
('E-3', 'Initial E-3'),
('H-1B1', 'Initial H-1B1')

INSERT INTO IndustryType(IndustryName, IndustryDescription, NAICSCode)
VALUES ('Libraries and Archives', 'Institutions where documents and records are stored', '519210'),
('Internet Service Provider', 'Provides internet to customers', '51711'),
('Cloud Services', 'Provides clound infrastructure and cloud as a platform', '518210'),
('Legal Services', 'Provides legal advice and prepares cases', '541110'),
('Architecture', 'Provides architectural and design services', '541310')

INSERT INTO LegalSupport (SupportFName, SupportLName, Title)
VALUES ('John', 'Smith', 'Legal Assistant'),
('Robert', 'Johnson', 'Paralegal'),
('Jane', 'Nixon', 'Senior Paralegal'),
('Elizabeth', 'Ashwood', 'Legal Assistant'),
('Amanda', 'Muellur', 'Paralegal')

INSERT INTO Attorney (AttorneyFName, AttorneyLName, BarNumber)
VALUES ('Sam', 'Johnson', 'P98653'),
('Robert', 'Bork', 'J653987'),
('Anna', 'Roberts', 'P65321'),
('Maria', 'Miles', 'Y3652987'),
('Albert', 'Coleman', 'Q35241')

INSERT INTO QuestionnaireResults (ClientCity, ClientState, ClientAddressLineOne, ClientZipCode, SSN, JobTitle, Salary)
VALUES ('Seattle', 'WA', '123 State Ave.', '98122', '123456789', 'Engineer', 89850.00),
('San Francisco', 'CA', '457 Broad St.', '97541', '456878923', 'Doctor', 180550.00),
('Detroit', 'MI', '6987 Woodward Ave.', '48122', '845369879', 'Automotive Engineer', 85000.00),
('Chicago', 'IL', '1889 Michigan Ave.', '98765', '357964850', 'Nurse', 90000.00),
('New York', 'NY', '14th St.', '12357', '369852147', 'Data Analyst', 75500.00)

INSERT INTO Corporation (CorporationName, CorporationDescription, CorpCity, CorpState, CorpAddressLineOne, CorpZipCode, FEIN, IndustryTypeID)
VALUES ('Tech Corp', 'Provides Cloud Technology Services', 'Chicago', 'IL', '5432 Michigan Ave.', '98765', '875698501', 3),
('City Archives', 'Archive devoted to cities', 'New York', 'NY', '654 Houston St.', '98562', '023489657', 1),
('Build Taller', 'An Architecture firm specializing in tall buildings', 'San Francisco', 'CA', '754 Fremont St.', '96548', '603248970', 5),
('FRI Corp', 'Provides Fast and Reliable Internet', 'Kansas City', 'MO', '587 Kansas Ave.', '98523', '478952306', 2),
('Lawyers R Us', 'General lawfirm and legal services', 'Toledo', 'OH', '632 Lowe Ct.', '96541', '905804732', 4);

INSERT INTO RevisedQuestionnaireResults (RevisedClientCity, RevisedClientState, RevisedClientAddressLineOne, RevisedClientZipCode, RevisedSSN, RevisedJobTitle, RevisedSalary, QuestionnaireID)
VALUES ('Seattle', 'WA', '1243 State Ave.', '98122', '123456789', 'Engineer', 89000.00, 1),
('San Francisco', 'CA', '457 Broad St.', '98541', '456878923', 'Doctor', 180550.00, 2),
('Detroit', 'MI', '6987 Woodward Ave.', '48122', '845369879', 'Mechanical Engineer', 85000.00, 3),
('Chicago', 'IL', '1889 Michigan St.', '98765', '357964850', 'Registered Nurse', 90000.00, 4),
('New York', 'NY', '17th St.', '12357', '369852147', 'Business Analyst', 75500.00, 5)

INSERT INTO Clients (ClientFName, ClientLName, ClientDOB, ClientEmail, CorporationID)
VALUES ('Albert', 'Denova', '05/08/1985', 'AlDenova@gmail.com', 1),
('Cheryl', 'Mastro', '06/09/1990', 'CMastro@yahoo.com', 3),
('Douglas', 'Erikson', '01/06/2000', 'DErikson@sbcglobal.net', 2),
('Amanda', 'Peloski', '12/05/1983', 'APeloski@gmail.com', 5),
('Carl', 'VanNostren', '10/22/1979', 'Carl2@VanNostren.com', 4)

INSERT INTO Cases (OpenedDate, ClosedDate, FiledDate, ApprovedDate, ValidityStart, ValidityEnd, ClientID, AttorneyID, LegalSupportID, StatusID, CaseTypeID, RevisedQuestionnaireID)
VALUES('10/20/2022', NULL, '10/30/2022', '01/03/2023', '01/01/2024', '01/01/2026', 1, 1, 1, 1, 1, 1),
('06/18/2022', '12/31/2022', NULL, NULL, NULL, NULL, 2, 2, 2, 2, 2, 2),
('02/09/2023', NULL, NULL, NULL, NULL, NULL, 3, 3, 3, 3, 3, 3),
('01/01/2023', NULL, '02/09/2023', NULL, NULL, NULL, 4, 4, 4, 4, 4, 4),
('01/09/2023', NULL, NULL, NULL, NULL, NULL, 5, 5, 5, 5, 5, 5)

