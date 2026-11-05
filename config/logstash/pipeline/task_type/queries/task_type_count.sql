  SELECT 
    tt.ttid as tt_id, 
    (
      SELECT COUNT(*)
      FROM task
      WHERE task.ttid=tt.ttid
    ) as task_count
  FROM task_type as tt
