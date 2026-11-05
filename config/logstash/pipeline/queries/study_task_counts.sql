SELECT study_id, COUNT(DISTINCT(task_id)), unix_ts_in_secs
from task_study as ts
JOIN (
SELECT ts_inner.study_id, UNIX_TIMESTAMP(max(ts_inner.date)) as unix_ts_in_secs
FROM task_study as ts_inner
GROUP BY ts_inner.study_id
) as b ON b.study_id = ts.study_id AND b.unix_ts_in_secs > :sql_last_value
group by study_id

