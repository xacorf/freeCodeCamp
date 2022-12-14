#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #get services
  SERVICES_AVAILABLE=$($PSQL "SELECT * FROM services")

  #display services
  echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  #select service
  read SERVICE_ID_SELECTED

  #find service
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  #if not exists
  if [[ -z $SERVICE_SELECTED ]]
  then
    #return to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #ask for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    #find user
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    #if user doent exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      #ask for name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      #insert customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #ask for time
    echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    #input service
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?\n"
