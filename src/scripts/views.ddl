CREATE VIEW `ad-fantasy-football.playdraft_2018.v_combined`
AS
SELECT
  *,
  (CASE WHEN position = 'QB' AND position_rank = 1
    OR position = 'RB' AND position_rank <= 2
    OR position = 'WR' AND position_rank <= 3
    OR position = 'TE' AND position_rank = 1 THEN true
    ELSE false END) AS player_counts 
FROM
  (
    SELECT
      t_drafts.id AS id,
      t_drafts.draft_id AS draft_id,
      t_drafts.team_id AS team_id,
      t_drafts.round_number AS round_number,
      t_drafts.pick_number AS pick_number,
      t_drafts.player_id AS player_id,
      t_drafts.pick_time AS pick_time,
      t_leagues.participants AS participants,
      t_leagues.draft_tm AS draft_tm,
      t_leagues.entry_cost AS entry_cost,
      t_leagues.draft_timer AS draft_timer,
      t_leagues.complete_true_false AS complete_true_false,
      t_players.first_name AS first_name,
      t_players.last_name AS last_name,
      t_players.position AS position,
      t_players.team AS team,
      t_players.team_name AS team_name,
      t_results.year AS year,
      t_results.week AS week,
      t_results.fantasy_points AS fantasy_points,
      RANK() OVER (PARTITION BY t_drafts.draft_id, t_drafts.team_id, t_players.position, t_results.year, t_results.week
                   ORDER BY fantasy_points DESC) AS position_rank
    FROM
      (
        SELECT
          id,
          draft_id,
          team_id,
          round_number,
          pick_number,
          MAX(player_id) AS player_id,
          MAX(pick_time) AS pick_time
        FROM
          `ad-fantasy-football.playdraft_2018.drafts`
        GROUP BY 1, 2, 3, 4, 5
      ) t_drafts
        INNER JOIN
      (
        SELECT
          draft_id,
          participants,
          draft_tm,
          entry_cost,
          draft_timer,
          complete_true_false
        FROM
          `ad-fantasy-football.playdraft_2018.leagues`
        GROUP BY 1, 2, 3, 4, 5, 6
      ) t_leagues
        ON (t_drafts.draft_id = t_leagues.draft_id)
        INNER JOIN
      (
        SELECT
          player_id,
          MAX(first_name) AS first_name,
          MAX(last_name) AS last_name,
          MAX(position) AS position,
          MAX(team) AS team,
          MAX(team_name) AS team_name
        FROM
          `ad-fantasy-football.playdraft_2018.players`
        GROUP BY 1
      ) t_players
        ON (t_drafts.player_id = t_players.player_id)
        LEFT OUTER JOIN
      (
        SELECT
          player_id,
          year,
          week,
          MAX(fantasy_points) AS fantasy_points
        FROM
          `ad-fantasy-football.playdraft_2018.results`
        GROUP BY 1, 2, 3  
      ) t_results
        ON (t_drafts.player_id = t_results.player_id)
  )
;

CREATE VIEW `ad-fantasy-football.playdraft_2018.v_teams`
AS
SELECT
  t_players.draft_id AS draft_id,
  t_players.team_id AS team_id,
  t_players.participants AS participants, 
  t_players.draft_tm AS draft_tm, 
  t_players.entry_cost AS entry_cost, 
  t_players.draft_timer AS draft_timer, 
  t_players.complete_true_false AS complete_true_false,
  t_players.total_points AS total_points,
  t_ranks.rank AS league_rank
FROM
  (
    SELECT
      draft_id,
      team_id,
      MAX(participants) AS participants, 
      MAX(draft_tm) AS draft_tm, 
      MAX(entry_cost) AS entry_cost, 
      MAX(draft_timer) AS draft_timer, 
      MAX(complete_true_false) AS complete_true_false,
      SUM(fantasy_points) AS total_points
    FROM
      `ad-fantasy-football.playdraft_2018.v_combined`
    WHERE
      player_counts
    GROUP BY 1, 2
  ) t_players
    INNER JOIN
  (
    SELECT
      draft_id,
      team_id,
      rank
    FROM
      `ad-fantasy-football.playdraft_2018.ranks`
    GROUP BY 1, 2, 3
  ) t_ranks
    ON (t_players.draft_id = t_ranks.draft_id
      AND t_players.team_id = t_ranks.team_id
    )
;


CREATE VIEW `ad-fantasy-football.playdraft_2018.v_full`
AS
SELECT
  t_drafts.id AS id,
  t_drafts.draft_id AS draft_id,
  t_drafts.team_id AS team_id,
  t_drafts.round_number AS round_number,
  t_drafts.pick_number AS pick_number,
  t_drafts.player_id AS player_id,
  t_drafts.pick_time AS pick_time,
  t_drafts.participants AS participants,
  t_drafts.draft_tm AS draft_tm,
  t_drafts.entry_cost AS entry_cost,
  t_drafts.draft_timer AS draft_timer,
  t_drafts.complete_true_false AS complete_true_false,
  t_drafts.first_name AS first_name,
  t_drafts.last_name AS last_name,
  t_drafts.position AS position,
  t_drafts.team AS team,
  t_drafts.team_name AS team_name,
  t_drafts.year AS year,
  t_drafts.week AS week,
  t_drafts.fantasy_points AS fantasy_points,
  t_drafts.position_rank AS position_rank,
  t_drafts.player_counts AS player_counts,
  t_teams.total_points AS total_points,
  t_teams.league_rank AS league_rank
FROM
  `ad-fantasy-football.playdraft_2018.v_combined` AS t_drafts
    LEFT OUTER JOIN
  `ad-fantasy-football.playdraft_2018.v_teams` AS t_teams
    ON (t_drafts.draft_id = t_teams.draft_id
      AND t_drafts.team_id = t_teams.team_id
    )
;
