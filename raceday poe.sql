USE master;
GO

IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE RaceDayDB;
END
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO


/* =========================================================
   2. CREATE USERS TABLE
   ========================================================= */

CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) PRIMARY KEY,

    FullName VARCHAR(100) NOT NULL,

    Email VARCHAR(150) NOT NULL UNIQUE,

    PasswordHash VARCHAR(255) NOT NULL,

    Role VARCHAR(20) NOT NULL
        CHECK (Role IN ('Organiser', 'Participant')),

    DateCreated DATETIME NOT NULL
        DEFAULT GETDATE()
);
GO


/* =========================================================
   3. CREATE ROUTES TABLE
   ========================================================= */

CREATE TABLE Routes
(
    RouteID INT IDENTITY(1,1) PRIMARY KEY,

    RouteName VARCHAR(150) NOT NULL,

    Description VARCHAR(500),

    DistanceKM DECIMAL(6,2) NOT NULL
        CHECK (DistanceKM > 0),

    StartPoint VARCHAR(150) NOT NULL,

    FinishPoint VARCHAR(150) NOT NULL
);
GO


/* =========================================================
   4. CREATE EVENTS TABLE
   ========================================================= */

CREATE TABLE Events
(
    EventID INT IDENTITY(1,1) PRIMARY KEY,

    OrganizerID INT NOT NULL,

    RouteID INT NOT NULL,

    EventName VARCHAR(150) NOT NULL,

    EventDate DATE NOT NULL,

    StartTime TIME NOT NULL,

    Venue VARCHAR(150) NOT NULL,

    WeatherLocation VARCHAR(150),

    CONSTRAINT FK_Events_Users
        FOREIGN KEY (OrganizerID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Events_Routes
        FOREIGN KEY (RouteID)
        REFERENCES Routes(RouteID)
);
GO


/* =========================================================
   5. CREATE EVENT CATEGORIES TABLE
   ========================================================= */

CREATE TABLE EventCategories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,

    EventID INT NOT NULL,

    CategoryName VARCHAR(100) NOT NULL,

    DistanceKM DECIMAL(6,2) NOT NULL
        CHECK (DistanceKM > 0),

    EntryFee DECIMAL(10,2) NOT NULL
        CHECK (EntryFee >= 0),

    MaxParticipants INT NOT NULL
        CHECK (MaxParticipants > 0),

    CONSTRAINT FK_EventCategories_Events
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID)
);
GO


/* =========================================================
   6. CREATE ENTRIES TABLE
   ========================================================= */

CREATE TABLE Entries
(
    EntryID INT IDENTITY(1,1) PRIMARY KEY,

    ParticipantID INT NOT NULL,

    CategoryID INT NOT NULL,

    EntryDate DATETIME NOT NULL
        DEFAULT GETDATE(),

    EntryStatus VARCHAR(30) NOT NULL
        DEFAULT 'Confirmed'
        CHECK (EntryStatus IN
        ('Pending', 'Confirmed', 'Cancelled')),

    RaceNumber VARCHAR(20),

    CONSTRAINT FK_Entries_Users
        FOREIGN KEY (ParticipantID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Entries_EventCategories
        FOREIGN KEY (CategoryID)
        REFERENCES EventCategories(CategoryID),

    CONSTRAINT UQ_Entries_RaceNumber
        UNIQUE (RaceNumber)
);
GO


/* =========================================================
   7. CREATE RESULTS TABLE
   ========================================================= */

CREATE TABLE Results
(
    ResultID INT IDENTITY(1,1) PRIMARY KEY,

    EntryID INT NOT NULL UNIQUE,

    FinishTime TIME NOT NULL,

    Position INT NOT NULL
        CHECK (Position > 0),

    AveragePace DECIMAL(6,2)
        CHECK (AveragePace > 0),

    ResultDate DATE NOT NULL
        DEFAULT CAST(GETDATE() AS DATE),

    CONSTRAINT FK_Results_Entries
        FOREIGN KEY (EntryID)
        REFERENCES Entries(EntryID)
);
GO


INSERT INTO Users
    (FullName, Email, PasswordHash, Role)
VALUES
    ('John Smith',
     'john@raceday.co.za',
     'HASHED_PASSWORD_001',
     'Organiser'),

    ('Sarah Williams',
     'sarah@raceday.co.za',
     'HASHED_PASSWORD_002',
     'Organiser'),

    ('Michael Adams',
     'michael@email.com',
     'HASHED_PASSWORD_003',
     'Participant'),

    ('Emma Brown',
     'emma@email.com',
     'HASHED_PASSWORD_004',
     'Participant');
GO


/* =========================================================
   9. INSERT ROUTES
   ========================================================= */

INSERT INTO Routes
    (RouteName, Description, DistanceKM, StartPoint, FinishPoint)
VALUES
    ('Cape Town 10K Route',
     'Scenic city route suitable for a 10 kilometre race.',
     10.00,
     'Green Point',
     'Green Point'),

    ('Cape Town Half Marathon Route',
     'Half marathon route through the Cape Town area.',
     21.10,
     'Sea Point',
     'Cape Town Stadium'),

    ('Cape Town Marathon Route',
     'Full marathon route around Cape Town.',
     42.20,
     'Woodstock',
     'Green Point');
GO


/* =========================================================
   10. INSERT EVENTS
   Minimum required: 3 Events
   ========================================================= */

INSERT INTO Events
    (OrganizerID, RouteID, EventName, EventDate, StartTime,
     Venue, WeatherLocation)
VALUES
    (1,
     1,
     'Cape Town 10K Challenge',
     '2026-10-10',
     '07:00:00',
     'Green Point',
     'Cape Town'),

    (1,
     2,
     'Cape Town Half Marathon',
     '2026-11-15',
     '06:30:00',
     'Sea Point',
     'Cape Town'),

    (2,
     3,
     'Cape Town Full Marathon',
     '2026-12-06',
     '06:00:00',
     'Woodstock',
     'Cape Town');
GO

INSERT INTO EventCategories
    (EventID, CategoryName, DistanceKM, EntryFee, MaxParticipants)
VALUES
    /* Event 1 */
    (1, '10K Open', 10.00, 150.00, 500),
    (1, '10K Junior', 10.00, 100.00, 200),

    /* Event 2 */
    (2, 'Half Marathon Open', 21.10, 250.00, 1000),
    (2, 'Half Marathon Junior', 21.10, 180.00, 300),

    /* Event 3 */
    (3, 'Marathon Open', 42.20, 400.00, 1500),
    (3, 'Marathon Veteran', 42.20, 350.00, 500);
GO


/* =========================================================
   12. INSERT PARTICIPANT ENTRIES
   ========================================================= */

INSERT INTO Entries
    (ParticipantID, CategoryID, EntryDate, EntryStatus, RaceNumber)
VALUES
    (3, 1, '2026-08-20 10:15:00', 'Confirmed', 'CT10K001'),

    (3, 3, '2026-08-21 11:30:00', 'Confirmed', 'CTHM001'),

    (4, 1, '2026-08-22 09:45:00', 'Confirmed', 'CT10K002'),

    (4, 5, '2026-08-23 14:20:00', 'Confirmed', 'CTMAR001');
GO


/* =========================================================
   13. INSERT RESULTS
   ========================================================= */

INSERT INTO Results
    (EntryID, FinishTime, Position, AveragePace, ResultDate)
VALUES
    (1, '00:52:30', 24, 5.25, '2026-10-10'),

    (3, '01:02:15', 56, 6.23, '2026-10-10');
GO


SELECT * FROM Users;

SELECT * FROM Routes;

SELECT * FROM Events;

SELECT * FROM EventCategories;

SELECT * FROM Entries;

SELECT * FROM Results;
GO


/* =========================================================
   15. DISPLAY COMPLETE RACEDAY INFORMATION
   ========================================================= */

SELECT
    e.EventName,
    e.EventDate,
    e.StartTime,
    r.RouteName,
    ec.CategoryName,
    ec.DistanceKM,
    ec.EntryFee
FROM Events e
INNER JOIN Routes r
    ON e.RouteID = r.RouteID
INNER JOIN EventCategories ec
    ON e.EventID = ec.EventID
ORDER BY e.EventDate;
GO


/* =========================================================
   16. DISPLAY PARTICIPANT ENTRIES
   ========================================================= */

SELECT
    u.FullName AS Participant,
    e.EventName,
    ec.CategoryName,
    en.RaceNumber,
    en.EntryStatus
FROM Entries en
INNER JOIN Users u
    ON en.ParticipantID = u.UserID
INNER JOIN EventCategories ec
    ON en.CategoryID = ec.CategoryID
INNER JOIN Events e
    ON ec.EventID = e.EventID
ORDER BY e.EventDate;
GO


/* =========================================================
   17. DISPLAY RESULTS
   ========================================================= */

SELECT
    u.FullName AS Participant,
    e.EventName,
    ec.CategoryName,
    en.RaceNumber,
    res.FinishTime,
    res.Position,
    res.AveragePace
FROM Results res
INNER JOIN Entries en
    ON res.EntryID = en.EntryID
INNER JOIN Users u
    ON en.ParticipantID = u.UserID
INNER JOIN EventCategories ec
    ON en.CategoryID = ec.CategoryID
INNER JOIN Events e
    ON ec.EventID = e.EventID
ORDER BY res.Position;
GO
