import mysql.connector
from mysql.connector import Error

def get_db():
    try:
        connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",
            database="fresh_first",
            port=3306
        )
        return connection

    except Error as error:
        print("Database connection error:", error)
        return None
