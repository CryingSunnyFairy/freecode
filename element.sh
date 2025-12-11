#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Check if argument exist
if [[ -z $1 ]]
then
# Error message
  echo -e "Please provide an element as an argument."
else
  # Check argument validity
  ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number = $1 OR symbol = '$1' OR name = '$1'")

  # If the result is empty then the argument passed was NOT an atomic number OR an element's symbol or an element's name.  Print the appropriate message and end.
  if [[ -z $ELEMENT ]]
  then
    echo -e "I could not find that element in the database."
  else 
    #use sed to split lines for number, symbol and name

    NUMBER=$(echo $ELEMENT | sed -E 's/ \|.+//') 
    SYMBOL=$(echo $ELEMENT | sed -E 's/^[0-9]+ \| //' | sed -E 's/ \| [A-Za-z]+$//')
    NAME=$(echo $ELEMENT | sed -E 's/^.+\| //')

        
    # retreive property for elements
    PROPERTY=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = $NUMBER")

    # Split the line apart using sed.
    ATOMIC_MASS=$(echo $PROPERTY | sed -E 's/ \| [0-9.\-]+ \| [0-9.\-]+ \| [0-9]+$//')
    MELTING_POINT_C=$(echo $PROPERTY |  sed -E 's/^[0-9.]+ \| //' | sed -E 's/ \| [-0-9.]+ \| [0-9]+$//')
    BOILING_POINT_C=$(echo $PROPERTY | sed -E 's/^[0-9.]+ \| [0-9.\-]+ \| //' | sed -E 's/ \| [0-9]+$//')
    TYPE_ID=$(echo $PROPERTY | sed -E 's/^[0-9.]+ \| [0-9.\-]+ \| [0-9.\-]+ \| //')


    # Get type and trim
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID" | sed 's/^ //')
    # echo $TYPE

    # Finally report result
    echo -e "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_C celsius and a boiling point of $BOILING_POINT_C celsius."
  fi
fi
