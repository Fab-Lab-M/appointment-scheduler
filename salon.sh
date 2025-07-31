#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi  
  
  #get available services

  AVAILABLE_SERVICES=$($PSQL "
    SELECT
      service_id,
      name
    FROM services
    ORDER BY service_id
  ")
  echo "$AVAILABLE_SERVICES" | while IFS=" | " read SERVICE_ID NAME
  do
      echo "$SERVICE_ID)" "$NAME"
  done
  
  read SERVICE_ID_SELECTED

  SERVICE_AVAILABILITY=$($PSQL "
    SELECT
      service_id
    FROM services
    WHERE service_id = $SERVICE_ID_SELECTED 
  ")

  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  #Ask number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "
    SELECT name
    FROM customers
    WHERE phone = '$CUSTOMER_PHONE'
  ")

  # Remove leading/trailing whitespace from CUSTOMER_NAME
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)

  if [[ -z $CUSTOMER_NAME ]] 
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER=$($PSQL "
      INSERT INTO customers(name, phone)
      VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')
    ")
    echo INSERT_CUSTOMER
  fi
    
  echo -e "\nWhat time would you like your cut,$CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "
    SELECT customer_id
    FROM customers
    WHERE phone = '$CUSTOMER_PHONE'
  ")
  
  # Remove leading/trailing whitespace from CUSTOMER_ID
  CUSTOMER_ID=$(echo $CUSTOMER_ID | xargs)

  INSERT_APPOINTMENT=$($PSQL "
    INSERT INTO appointments(customer_id, service_id, time)
    VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')
  ")
  
  SERVICE_NAME=$($PSQL "
    SELECT name
    FROM services
    WHERE service_id = '$SERVICE_ID_SELECTED'
  ")


  # Remove leading/trailing whitespace from SERVICE_NAME
  SERVICE_NAME=$(echo $SERVICE_NAME | xargs)

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  exit

}

MAIN_MENU
