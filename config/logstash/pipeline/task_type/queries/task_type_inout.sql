SELECT 
  ttid as tt_id,
  name,
  `type`,
  io,
  requirement,
  description
FROM task_type_inout
WHERE ttid <= :task_type_id_from
AND ttid < :task_type_id_to
