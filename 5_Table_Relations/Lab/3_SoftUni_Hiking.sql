
SELECT
    r.start_point,
    r.end_point,
    R.leader_id,
    concat_ws(' ',c.first_name,c.last_name) AS leader_name

FROM routes AS r
join campers as c on r.leader_id = c.id
