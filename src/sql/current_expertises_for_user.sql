SELECT
  i_scale.ranking AS interest,
  e_scale.ranking AS experience,
  ARRAY_AGG(exp.name ORDER BY exp.name) AS expertises
FROM expertise_current cur
INNER JOIN interest_scale i_scale ON (i_scale.id = cur.interest_scale_id)
INNER JOIN experience_scale e_scale ON (e_scale.id = cur.experience_scale_id)
INNER JOIN slack_user usr ON (usr.id = cur.slack_user_id)
INNER JOIN expertise exp ON (exp.id = cur.expertise_id)
WHERE usr.slack_id = ${userId}
GROUP BY interest, experience
ORDER BY interest, experience
