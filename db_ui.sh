#!/bin/bash

run_query() {
  local query="$1"
  sqlplus64 "zshibly/02047333@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=oracle.scs.ryerson.ca)(Port=1521))(CONNECT_DATA=(SID=orcl)))" <<EOF > tempfile
  SET PAGESIZE 1000
  SET LINESIZE 200
  $query
  exit;
EOF
  sed -n '/^SQL>/,/^Disconnected/p' tempfile | head -n -2  
  rm tempfile
}

# Main menu
while true; do
  clear
  echo "Galactica Database Main Menu"
  echo "----------------------------"
  echo "1. Execute SQL Query"
  echo "2. Create Table"
  echo "3. Insert Data"
  echo "4. Drop Table"
  echo "5. Exit"

  read -p "Enter option: " option

  case $option in
    1)
      clear
      read -p "Enter SQL query: " sql_query
      echo -e "\n"
      run_query "$sql_query"
      read -n 1 -s -r -p "Press any key to continue..."
      ;;
    2)
      clear
      read -p "Enter table name: " table_name
      echo
      read -p "Add first column name: " first_column_name

      query_str='CREATE TABLE "ZSHIBLY".'"$table_name"" (""$first_column_name"

      while true; do
        while true; do
          echo -e "\nWhat is the data type?\nEnter the number corresponding to the data type.\n1. NUMBER\n2. VARCHAR2\n3. DATE\n4. CLOB\n"
          read -n 1 -p "Enter your selection: " data_type_option
          case $data_type_option in
            1)
              query_str+=" NUMBER"
              break
              ;;
            2)
              query_str+=" VARCHAR2"
              break
              ;;
            3)
              query_str+=" DATE"
              break
              ;;
            4)
              query_str+=" CLOB"
              break
              ;;
            *)
              echo "Invalid option. Please try again."
              read -n 1 -s -r -p "Press any key to continue..."
              ;;
          esac
        done

        while true; do
          echo -e "\n"
          read -n 1 -p "Is it a primary key? y/n: " primary_key_option
          case $primary_key_option in
            y)
              query_str+=" PRIMARY KEY"
              break
              ;;
            n)
              break
              ;;
            *)
              echo "Invalid option. Please try again."
              read -n 1 -s -r -p "Press any key to continue..."
              ;;
          esac
        done
        
        while true; do
          echo -e "\n"
          read -n 1 -p "Can it be a NULL? y/n: " null_option
          case $null_option in
            y)
              break
              ;;
            n)
              query_str+=" NOT NULL"
              break
              ;;
            *)
              echo "Invalid option. Please try again."
              read -n 1 -s -r -p "Press any key to continue..."
              ;;
          esac
        done
        echo -e "\n"
        read -n 1 -p "Do you want to add more columns? y/n: " more_columns_option
        echo -e "\n"
        case $more_columns_option in
          y)
            clear
            read -p "Name of new column: " column_name
            query_str+=", $column_name"
            ;;
          n)
            query_str+=");"
            break
            ;;
          *)
            echo "Invalid option. Please try again."
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        esac
      done
      echo -e "\n"
      run_query "$query_str"
      read -n 1 -s -r -p "Press any key to continue..."
      ;;
    3)
      clear
      read -p "Enter table name: " table_name
      echo -e "\n"
      echo -e "$table_name"" table has the following columns:\n"
      run_query 'DESCRIBE "ZSHIBLY".'"$table_name"
      echo -e "\n"
      query_str="INSERT INTO "'"ZSHIBLY".'"$table_name"" ("
      read -p "Enter column names separated by commas: " column_names
      echo -e "\n"
      query_str+="$column_names"") VALUES ("
      read -p "Enter values separated by commas (values need to be in the same order in which the columns were listed): " values
      query_str+="$values"");"
      echo -e "\n"
      run_query "$query_str"
      read -n 1 -s -r -p "Press any key to continue..."
      ;;
    4)
      clear
      read -p "Enter table name to be dropped: " table_name
      sql_query="DROP TABLE "'"ZSHIBLY".'"$table_name"";"
      echo -e "\n"
      run_query "$sql_query"
      read -n 1 -s -r -p "Press any key to continue..."
      ;;
    5)
      clear
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo "Invalid option. Please try again."
      read -n 1 -s -r -p "Press any key to continue..."
      ;;
    
  esac
done
