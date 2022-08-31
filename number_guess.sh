#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "\n\n~~~Welcome to the Guessing Game~~~\n\n"

GUESSING_GAME() {
  
  RANDOM_NUMBER=$((1 + $RANDOM % 1000))
  
  echo -e "\nEnter your username:"
  read USERNAME_INPUT

  USERNAME_RESPONSE=$($PSQL "SELECT username FROM users WHERE username='$USERNAME_INPUT'")
  if [[ -z $USERNAME_RESPONSE ]]
  then
    $PSQL "INSERT INTO users(username) VALUES('$USERNAME_INPUT')" > SILENT
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT'")
    $PSQL "INSERT INTO games(user_id, games_played, best_game) VALUES ($USER_ID, 0, 0)" > SILENT
    echo -e "\nWelcome, $USERNAME_INPUT! It looks like this is your first time here."
  else
    GET_USERS_INFO=$($PSQL "SELECT * FROM users FULL JOIN games USING(user_id) WHERE username='$USERNAME_INPUT'")
    echo "$GET_USERS_INFO" | while read USERID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME
    do
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
  fi

  echo -e "\nGuess the secret number between 1 and 1000:"
  NUMBER_OF_GUESS=0

  GUESS_FUNCTION() {
    
    read GUESS
    
    if [[ $GUESS =~ ^[0-9]+$ ]]
    then
      ((NUMBER_OF_GUESS = NUMBER_OF_GUESS + 1))
      if [[ $GUESS -eq $RANDOM_NUMBER ]]
      then
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT'")
        $PSQL "UPDATE games SET games_played = games_played + 1 WHERE user_id=$USER_ID" > SILENT
        echo -e "\nYou guessed it in $NUMBER_OF_GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!"
        BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE user_id=$USER_ID")
        if [[ $BEST_GAME -eq 0 ]]
        then
          $PSQL "UPDATE games SET best_game = $NUMBER_OF_GUESS where user_id=$USER_ID" > SILENT
        else
          if [[ $BEST_GAME -gt $NUMBER_OF_GUESS ]]
          then
            $PSQL "UPDATE games SET best_game = $NUMBER_OF_GUESS where user_id=$USER_ID" > SILENT
          fi
        fi
      else
        if [[ $GUESS -lt $RANDOM_NUMBER ]]
        then
          echo -e "\nIt's higher than that, guess again:"
          GUESS_FUNCTION
        else
          if [[ $GUESS -gt $RANDOM_NUMBER ]]
          then
            echo -e "\nIt's lower than that, guess again:"
            GUESS_FUNCTION
          fi
        fi
      fi
    else
      echo -e "\nThat is not an integer, guess again:"
      GUESS_FUNCTION
    fi
  }
 
 GUESS_FUNCTION

}

GUESSING_GAME