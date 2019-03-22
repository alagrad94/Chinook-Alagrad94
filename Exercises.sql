--Non-USA Customers
SELECT CustomerId, CONCAT(FirstName, ' ', LastName) AS FullName, Country
FROM Customer
WHERE Country NOT LIKE 'USA'

--Brazil Customers
SELECT CustomerId, CONCAT(FirstName, ' ', LastName) AS FullName, Country
FROM Customer
WHERE Country LIKE 'Brazil'

--Brazil Customers Invoices
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS FullName, i.InvoiceId, i.InvoiceDate, i.BillingCountry
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE Country LIKE 'Brazil'

--Sales Agent
SELECT CONCAT(FirstName, ' ', LastName) AS FullName
FROM Employee
WHERE Title LIKE 'Sales Support Agent'

--Unique Invoice Countries
SELECT DISTINCT BillingCountry
FROM Invoice

--Sales Agent Invoices
SELECT c.SupportRepId, CONCAT(e.FirstName, ' ', e.LastName) AS SalesAgentName, i.InvoiceId
FROM Employee e
LEFT JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE Title LIKE 'Sales Support Agent'
ORDER BY SalesAgentName, i.InvoiceId

--Invoice Totals
SELECT i.InvoiceId, i.BillingCountry, i.Total, CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, CONCAT(e.FirstName, ' ', e.LastName) AS SalesAgentName
FROM Invoice i
LEFT JOIN Customer c ON c.CustomerId = i.CustomerId
LEFT JOIN Employee e ON e.EmployeeId = c.SupportRepId

--Totals Invoices (Year)
SELECT COUNT(CASE WHEN InvoiceDate BETWEEN '2011-01-01' AND '2011-12-31' THEN 1 ELSE NULL END) AS Count2011, 
	COUNT(CASE WHEN InvoiceDate BETWEEN '2009-01-01' AND '2009-12-31' THEN 1 ELSE NULL END) AS Count2009
FROM Invoice

--Total Sales (Year)
SELECT SUM(CASE WHEN Total > 0 AND InvoiceDate BETWEEN '2011-01-01' AND '2011-12-31' THEN Total ELSE 0 END) AS Sales2011, 
	SUM(CASE WHEN Total > 0 AND InvoiceDate BETWEEN '2009-01-01' AND '2009-12-31' THEN Total ELSE 0 END) AS Sales2009
FROM Invoice

--Invoice 37 Line Item Count
SELECT COUNT(*)
FROM InvoiceLine
WHERE InvoiceId = 37

--Line Items Per Invoice
SELECT InvoiceId, COUNT(*) AS CountLineItems
FROM InvoiceLine
GROUP BY InvoiceId

--Line Item Track
SELECT i.InvoiceId, i.InvoiceLineId, t.Name
FROM InvoiceLine i
LEFT JOIN Track t ON i.TrackId = t.TrackId
ORDER BY i.InvoiceId

--Line Item Track Artist
SELECT i.InvoiceId, i.InvoiceLineId, t.Name AS TrackName, b.Name AS ArtistName
FROM InvoiceLine i
LEFT JOIN Track t ON i.TrackId = t.TrackId
LEFT JOIN Album a ON t.AlbumId = a.AlbumId
LEFT JOIN Artist b on a.ArtistId = b.ArtistId
ORDER BY i.InvoiceId

--Country Invoices
SELECT i.BillingCountry, COUNT(*) AS InvoiceCount
FROM Invoice i
GROUP BY i.BillingCountry

--Playlist Track Count
SELECT p.PlaylistId, COUNT(t.TrackId) AS TrackCount
FROM Playlist p
LEFT JOIN PlaylistTrack t ON p.PlaylistId = t.PlaylistId
GROUP BY p.PlaylistId

--Tracks No ID
SELECT t.Name AS TrackName, a.Title AS AlbumTitle, m.Name AS MediaType, g.Name AS Genre
FROM Track t
LEFT JOIN Album a ON t.AlbumId = a.AlbumId
LEFT JOIN MediaType m ON t.MediaTypeId = m.MediaTypeId
LEFT JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name, m.Name, a.Title, t.Name

--Invoices Line Items Count 
SELECT InvoiceId, COUNT(*) AS CountLineItems
FROM InvoiceLine
GROUP BY InvoiceId

--Sales Agent Total Sales 
SELECT e.FirstName, e.LastName, SUM(i.Total) AS TotalSales
FROM Employee e
LEFT JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE Title LIKE 'Sales Support Agent'
GROUP BY e.LastName, e.FirstName

--Top 2009 Agent
SELECT TOP(1) s.FirstName, s.LastName, s.Sales2009 AS MaxSales
FROM 
	(SELECT e.EmployeeId as EmployeeId, e.FirstName AS FirstName, e.LastName AS LastName, SUM(CASE WHEN i.Total > 0 AND i.InvoiceDate BETWEEN '2009-01-01' AND '2009-12-31' THEN i.Total ELSE 0 END) AS Sales2009
	FROM Employee e
	LEFT JOIN Customer c ON c.SupportRepId = e.EmployeeId
	LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
	WHERE Title LIKE 'Sales Support Agent'
	GROUP BY e.EmployeeId, e.LastName, e.FirstName) s
GROUP BY s.FirstName, s.LastName, s.Sales2009
ORDER BY MaxSales DESC

--Top Agent
SELECT TOP(1) s.FirstName, s.LastName, MAX(s.TotalSales) AS TotalSales
FROM 
	(SELECT e.FirstName AS FirstName, e.LastName AS LastName, SUM(i.Total) AS TotalSales
	FROM Employee e
	LEFT JOIN Customer c ON c.SupportRepId = e.EmployeeId
	LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
	WHERE Title LIKE 'Sales Support Agent'
	GROUP BY e.LastName, e.FirstName) s
GROUP BY s.FirstName, s.LastName
ORDER BY TotalSales DESC

--Sales Agent Customer Count
SELECT e.FirstName, e.LastName, COUNT(CASE WHEN c.SupportRepId = e.EmployeeId THEN 1 ELSE NULL END) As CustCount
FROM Employee e
LEFT JOIN Customer c ON e.EmployeeId = c.SupportRepId
WHERE e.Title LIKE 'Sales Support Agent'
GROUP BY e.FirstName, e.LastName

--Sales Per Country
SELECT i.BillingCountry, SUM(i.Total) AS TotalSales
FROM Invoice i
GROUP BY i.BillingCountry
ORDER BY i.BillingCountry DESC

--Top Country
SELECT TOP(1) i.BillingCountry, SUM(i.Total) AS TotalSales
FROM Invoice i
GROUP BY i.BillingCountry
ORDER BY i.BillingCountry DESC

--Top 2013 Track
SELECT TOP(1) t.Name, COUNT(CASE WHEN t.TrackId = l.TrackId AND i.InvoiceDate BETWEEN '2013-01-01' AND '2013-12-31' THEN 1 ELSE 0 END ) AS OrderCount
FROM Track t
LEFT JOIN InvoiceLine l ON t.TrackId = l.TrackId
LEFT JOIN Invoice i ON l.InvoiceId = i.InvoiceId
GROUP BY t.Name
ORDER BY OrderCount DESC

--Top 5 Tracks
SELECT TOP(5) t.Name, COUNT(CASE WHEN l.TrackId = t.TrackId THEN 1 ELSE 0 END ) AS OrderCount
FROM Track t
LEFT JOIN InvoiceLine l ON t.TrackId = l.TrackId
GROUP BY l.TrackId, t.Name
ORDER BY OrderCount DESC

--Top 3 Artists
SELECT TOP(3) b.Name, COUNT(CASE WHEN l.TrackId = t.TrackId THEN 1 ELSE 0 END ) AS OrderCount
FROM Track t
LEFT JOIN InvoiceLine l ON t.TrackId = l.TrackId
LEFT JOIN Album a ON t.AlbumId = a.AlbumId
LEFT JOIN Artist b on a.ArtistId = b.ArtistId
GROUP BY l.TrackId, b.Name
ORDER BY OrderCount DESC

--Top Media Type
SELECT TOP(1) m.Name, COUNT(CASE WHEN l.TrackId = t.TrackId THEN 1 ELSE 0 END ) AS OrderCount
FROM Track t
LEFT JOIN InvoiceLine l ON t.TrackId = l.TrackId
LEFT JOIN MediaType m ON t.MediaTypeId = m.MediaTypeId
GROUP BY l.TrackId, m.Name
ORDER BY OrderCount DESC