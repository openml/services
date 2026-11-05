  SELECT 
    tt.ttid, 
    (
      SELECT COUNT(*)
      FROM task
      WHERE task.ttid=tt.ttid
    ) as task_count
  FROM task_type as tt
