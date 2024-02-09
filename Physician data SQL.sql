-- Vishwaben Joshi
-- Northeastern Assignments for Database design class

use PhysicianPractice

-- Question - Find the patients who have a billing charge over $1000 or a billing charge under $10. How many patients are there?
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

-- Question - Find the patients who have both a billing charge over $1000 and a billing charge under $10. How many patients are there?
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

-- Question - Find the patients who do have a billing charge over $1000 but who do not have a billing charge under $10.  How many patients are there?

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

-- Question - Write a query that lists every patient who has at least one A1c result that is higher than the average A1c results for each patient's PCP.  Use temp.PhysicianAverageA1c for this.  Don't list patients more than once


SELECT DISTINCT p.patientkey, p.FirstName, p.LastName
FROM phys.Patient p 
JOIN temp.AveragePhysicianA1CValue  apv on apv.PCPPhysicianKey = p.PCPPhysicianKey
JOIN phys.LaboratoryTests lt on lt.PatientKey = p.PatientKey
WHERE lt.Description like 'hemo%' and lt.Value > apv.AveragePhysicianA1CValue
GROUP BY p.patientkey, p.FirstName, p.LastName
ORDER BY p.PatientKey;
-- resulted 1330 patients 

-- Question - Write a query that lists the average A1c value for all patients assigned to each PCP.  That's one average for each PCP.

SELECT p.PCPPhysicianKey,
AVG(lt.Value) AS avgA1c
FROM phys.Patient p
JOIN phys.PhysicianAssignedToPractice pcp on pcp.PhysicianKey = p.PCPPhysicianKey
JOIN phys.LaboratoryTests lt on lt.PatientKey = p.PatientKey
WHERE lt.Description like 'hemo%'
GROUP BY p.PCPPhysicianKey
ORDER BY p.PCPPhysicianKey;
-- resulted 20 rows


-- Question - Take your answer to #4, and instead of using temp.PhysicianAverageA1c, use your query from #5 as a subquery.  Don't use any temp tables or views.  Don't list patients more than once. 

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

-- Question - Find the minimum and maximum Hemoglobin A1c result for each patient.  (Not just Carlsons.)
-- That's one minimum and one maximum for each patient.  Show the patient key, first name, last name, min A1c, and max A1c.
SELECT p.PatientKey, p.FirstName, p.LastName,
MIN(lt.VALUE), -- as Minimumhemo
MAX(lt.VALUE) -- as Maximumhemo
from phys.LaboratoryTests lt
JOIN phys.Patient p on lt.patientkey = p.PatientKey 
where lt.Description = 'Hemoglobin A1c' 
group by p.PatientKey, p.FirstName, p.LastName ;

-- resulting 2650 rows 

-- Question Find the average of all Hemoglobin A1c results for each condition.  We should get one average for each condition, and each condition should be listed once.

select pc.PCondition,
avg(lt.value) as AverageHemo
from phys.PatientCondition pc
join phys.LaboratoryTests lt on pc.PatientKey = lt.patientkey
where lt.Description = 'Hemoglobin A1c'
group by pc.PCondition;

-- resulting 6 rows

-- Question We are now going to clean up the query from question #2.  In query #2, you were listing minimum and maximum and PatientKey.  For #4, copy the query from #2 and modify the query to add a title in each result column that doesn't have a title (use aliases).  Select columns as needed so that you display PatientKey, LastName, and FirstName columns in the selected results along with the min,max,average, and count of A1c tests (the count for each patient).  Order the results alphabetically.  Only include patients with at least two A1c tests.

SELECT p.PatientKey, p.LastName, p.FirstName,
MIN(lt.VALUE) AS MinA1c,
MAX(lt.VALUE) AS MaxA1c,
avg(lt.value) as avgA1c,
count(*) as numberoftest
from phys.LaboratoryTests lt
JOIN phys.Patient p on lt.patientkey = p.PatientKey 
where lt.Description = 'Hemoglobin A1c' 
group by p.PatientKey, p.FirstName, p.LastName 
having count(*) >=2  -- in the qustion it is given atleast 2 tests.
-- having count(*) > 2  -- which is greater then 2 tests.
order by p.LastName , p.FirstName;