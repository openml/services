SELECT 
  ttid as tt_id,
  name,
  description,
  creator,
  contributors,
  creationDate
FROM task_type as tt
WHERE
  :task_type_id_from <= tt.ttid
  AND tt.ttid < :task_type_id_to
