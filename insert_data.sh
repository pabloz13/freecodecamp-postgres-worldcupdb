#! /bin/bash

if [[ $1 == "test" ]]
then
 PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
 PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")

# insert all teams to the teams table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
 if [[ $WINNER != "winner" ]]
 then
  # check if the team is in the table
  TEAM=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
  # if not found
    if [[ -z $TEAM ]]
    then
      # insert the team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    fi
  fi  

  # move onto the opponent column
  if [[ $OPPONENT != "opponent" ]]
  then
    # check if the team is in the table
    TEAM=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found
    if [[ -z $TEAM ]]
    then
      # insert the team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
    fi
  fi

  TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  if [[ $TEAM_ID_WINNER || $TEAM_ID_OPPONENT ]]
  then
    if [[ $YEAR != "year" ]]
    then
      INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR
      fi
    fi
  fi

done
