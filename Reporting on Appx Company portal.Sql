--Company Portal on One machine
SELECT *
FROM v_GS_WINDOWS8_APPLICATION AS app
JOIN v_R_System AS sys ON app.ResourceID = sys.ResourceID
WHERE sys.Name0 = '2HNW5J3'
  AND ApplicationName0 LIKE 'Microsoft.companyporta%'
ORDER BY ApplicationName0 ASC

--Company Portal on Device Collection installed
DECLARE @CollectionID nvarchar(8)
SET @CollectionID = 'CAS00A90'
SELECT *
FROM v_GS_WINDOWS8_APPLICATION AS app
JOIN v_R_System AS sys ON app.ResourceID = sys.ResourceID
JOIN v_FullCollectionMembership AS fcm ON sys.ResourceID = fcm.ResourceID
WHERE fcm.CollectionID = @CollectionID
  AND app.ApplicationName0 LIKE 'Microsoft.companyporta%'
--ORDER BY app.ApplicationName0 ASC
ORDER BY Timestamp ASC

--Company Portal on Device Collection NOT installed
DECLARE @CollectionID nvarchar(8)
SET @CollectionID = 'CAS00A90'

SELECT sys.*
FROM v_R_System AS sys
JOIN v_FullCollectionMembership AS fcm ON sys.ResourceID = fcm.ResourceID
WHERE fcm.CollectionID = @CollectionID
  AND NOT EXISTS (
    SELECT 1
    FROM v_GS_WINDOWS8_APPLICATION AS app
    WHERE app.ResourceID = sys.ResourceID
      AND app.ApplicationName0 LIKE 'Microsoft.companyporta%'
  )


