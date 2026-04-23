SELECT s.*, UNIX_TIMESTAMP(s.creation_date) as unix_ts_in_secs
FROM openml_expdb.study as s
WHERE UNIX_TIMESTAMP(s.creation_date) > :sql_last_value

