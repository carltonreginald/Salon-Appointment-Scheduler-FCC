#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help\n" 


MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # prints service list
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # gets input
  read SERVICE_ID_SELECTED

  # finds and returns selection from service table
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # if not valid input returns to main menu
  if [[ -z $SERVICE_ID_SELECTED  ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # promt user for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  fi
        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          
          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 

          # prompts user for service time
          echo -e "\nWhat time would you like your $SERVICE_NAME , $CUSTOMER_NAME?"
          # $(echo $SERVICE_ID_SELECTED | sed -r 's/[0-9]*//g' ) 
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

          if [[ $SERVICE_TIME ]]
          then
              # insert data into appointments table
              INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
            if [[ $SERVICE_TIME ]]
            then
                # output appointment details
                echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
            fi
          fi
        fi
 
}

MAIN_MENU
