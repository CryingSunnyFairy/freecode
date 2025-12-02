#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"



echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Create main menu

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?"

  LIST_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$LIST_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    ID=$(echo $SERVICE_ID | sed 's/ //g')
    NAME=$(echo $SERVICE | sed 's/ //g')
    echo "$ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
  [1-4]) CUSTOMER_DETAILS ;;
  *) MAIN_MENU "Please enter a valid option." ;;
  esac

}

# get customer details
CUSTOMER_DETAILS() {
  # get phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

   # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]; then
    # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    SERVICE_NAMES=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME=$(echo $SERVICE_NAMES| sed 's/ //g')

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_TO_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")    

    if [[ $INSERT_TO_APPOINTMENTS == "INSERT 0 1" ]]
    then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi

}


MAIN_MENU

