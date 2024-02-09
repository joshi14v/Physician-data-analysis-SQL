-- Vishwaben Joshi
-- Week5 Assignment

use PhysicianPractice

-- Question 1 Find the patients who have a billing charge over $1000 or a billing charge under $10. How many patients are there?
SELECT p.* 
FROM phys.Patient p
JOIN phys.Billing b on p.PatientKey = b.PatientKey
WHERE b.BillingCharge > 1000 
UNION 
SELECT p.*
FROM phys.Patient p
JOIN phys.Billing b on p.PatientKey = b.PatientKey
WHERE b.BillingCharge < 10 ;
-- Resulted 16,044 patients 
-- 7330 patients (using distinct) who have billing charge >1000 and 12,373 patients (using distinct)who have billing charge <10

-- Question 2 - Find the patients who have both a billing charge over $1000 and a billing charge under $10. How many patients are there?
SELECT p.* 
FROM phys.Patient p  
JOIN phys.Billing b on p.PatientKey = b.PatientKey
WHERE b.BillingCharge > 1000 
INTERSECT
SELECT p.* 
FROM phys.Patient p
JOIN phys.Billing b on p.PatientKey = b.PatientKey
WHERE b.BillingCharge < 10 ;
-- Resulted 3659 patients

-- Question 3 - Find the patients who do have a billing charge over $1000 but who do not have a billing charge under $10.  How many patients are there?

SELECT p.*
FROM phys.Patient p
JOIN phys.Billing b on p.PatientKey = b.PatientKey
WHERE b.BillingCharge > 1000
EXCEPT
SELECT p.*
FROM phys.Patient p
JOIN phys.Billing b on p.PatientKey = b.PatientKey
WHERE b.BillingCharge < 10 ;
-- resulted 3671 patients

-- Question 4 - Write a query that lists every patient who has at least one A1c result that is higher than the average A1c results for each patient's PCP.  Use temp.PhysicianAverageA1c for this.  Don't list patients more than once


SELECT DISTINCT p.patientkey, p.FirstName, p.LastName
FROM phys.Patient p 
JOIN temp.AveragePhysicianA1CValue  apv on apv.PCPPhysicianKey = p.PCPPhysicianKey
JOIN phys.LaboratoryTests lt on lt.PatientKey = p.PatientKey
WHERE lt.Description like 'hemo%' and lt.Value > apv.AveragePhysicianA1CValue
GROUP BY p.patientkey, p.FirstName, p.LastName
ORDER BY p.PatientKey;
-- resulted 1330 patients 

-- Question 5 - Write a query that lists the average A1c value for all patients assigned to each PCP.  That's one average for each PCP.

SELECT p.PCPPhysicianKey,
AVG(lt.Value) AS avgA1c
FROM phys.Patient p
JOIN phys.PhysicianAssignedToPractice pcp on pcp.PhysicianKey = p.PCPPhysicianKey
JOIN phys.LaboratoryTests lt on lt.PatientKey = p.PatientKey
WHERE lt.Description like 'hemo%'
GROUP BY p.PCPPhysicianKey
ORDER BY p.PCPPhysicianKey;
-- resulted 20 rows


-- Question 6 - Take your answer to #4, and instead of using temp.PhysicianAverageA1c, use your query from #5 as a subquery.  Don't use any temp tables or views.  Don't list patients more than once. 


SELECT DISTINCT p.patientkey, p.FirstName, p.LastName
FROM phys.Patient p 
JOIN (SELECT pt.PCPPhysicianKey,
AVG(lt.Value) AS avgA1c
FROM phys.Patient pt
JOIN phys.PhysicianAssignedToPractice pcp on pcp.PhysicianKey = pt.PCPPhysicianKey
JOIN phys.LaboratoryTests lt on lt.PatientKey = pt.PatientKey
WHERE lt.Description like 'hemo%'
GROUP BY pt.PCPPhysicianKey)  apv on apv.PCPPhysicianKey = p.PCPPhysicianKey
JOIN phys.LaboratoryTests lt on lt.PatientKey = p.PatientKey
WHERE lt.Description like 'hemo%' and lt.Value > apv.avgA1c
GROUP BY p.patientkey, p.FirstName, p.LastName
ORDER BY p.PatientKey;
-- resulted 1330 rows