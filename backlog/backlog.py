from  pg8000 import Connection
from dotenv import load_dotenv
import os 

load_dotenv()
print(f"Username is: {os.environ['USER']}")
print(f"Password is: {os.environ['PASSWORD']}")

def purchase_order():
    db_user = os.environ.get("USER")
    print(db_user)
    db_database = os.environ.get("DATABASE")
    con = Connection(db_user,database=db_database)
    rows = con.run(f'SELECT * from fact_purchase_order')
    
