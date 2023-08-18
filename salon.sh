#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?\n"

  #display services #) <service>
  SERVICE_INFO="$($PSQL "SELECT service_id, name FROM services;")"
  echo "$SERVICE_INFO" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  #get service name from id
  SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")"
  #if service not found
  if [[ -z $SERVICE_NAME ]]
  then
    #send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    #get customer id from phone number
    CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")"
    #if name empty
    if [[ -z $CUSTOMER_ID ]]
    then
      #ask for name and insert customer
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT="$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")"
      #get new customer id
      CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")"
    fi
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME
    #insert appointment
    INSERT_APPOINTMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")"
    #output message
    #I have put you down for a <service> at <time>, <name>.
    echo "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//') at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}



MAIN_MENU