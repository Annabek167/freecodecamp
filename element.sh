#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# function to run file
MAIN_PROGRAM() {
  # check if no input at the $1 position character
  if [[ -z $1 ]]
  then
    # print the closing sentence
    echo "Please provide an element as an argument."
  else
    # call the function of printing element's info at the $1 position character
    PRINT_ELEMENT $1
  fi
}

# the function of printing element's info 
PRINT_ELEMENT() {
  # read the $1 position character as INPUT
  INPUT=$1
  # check if INPUT is a number or string
  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    # read the database to find atomic_number of the element that have symbol or name that match with INPUT, format it, and store it as ATOMIC_NUMBER
    ATOMIC_NUMBER=$(echo $($PSQL "SELECT atomic_number FROM elements WHERE symbol='$INPUT' OR name='$INPUT';") | sed 's/ //g')
  else
    # read the database to find atomic_number of the element that have atomic_number that match with INPUT, format it, and store it as ATOMIC_NUMBER
    ATOMIC_NUMBER=$(echo $($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$INPUT;") | sed 's/ //g')
  fi
  
  # check if ATOMIC_NUMBER doesn't exist
  if [[ -z $ATOMIC_NUMBER ]]
  then
    # print the closing sentence
    echo "I could not find that element in the database."
  else
    # read from database the info of the element that have atomic_number matching with ATOMIC_NUMBER stored above, format them, and store them as these variables:
    TYPE_ID=$(echo $($PSQL "SELECT type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    NAME=$(echo $($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    SYMBOL=$(echo $($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    ATOMIC_MASS=$(echo $($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    MELTING_POINT_CELSIUS=$(echo $($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    BOILING_POINT_CELSIUS=$(echo $($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    TYPE=$(echo $($PSQL "SELECT type FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    # print the element's info
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
}

# call function MAIN
  MAIN_PROGRAM $1