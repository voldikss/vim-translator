import sqlite3


class DataStore:
    def __init__(self) -> None:
        self.connection = self.create_connection()

    def create_connection(self):
        return sqlite3.connect("translator.db")

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute("create table translations")
        self.connection.commit()
        cursor.close()

    def _execute(self, statement):
        cursor = self.connection.cursor()
        cursor.execute(statement)
        self.connection.commit()
        cursor.close()
        # self.connection.close()

    def get(self):
        cursor = self.connection.cursor()
        cursor.execute("select * from translations where id=?", ("1",))
        return cursor.fetchall()
