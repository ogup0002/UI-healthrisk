from flask import Flask, Response
from flask_restful import Api, Resource, reqparse
import pymysql
import pandas as pd
# from flask import Flask, request, make_response
app = Flask(__name__)
api = Api(app)


conn = pymysql.connect(
        user="sittofit",
        password="0AxPzbedoJFNTfPj67Pr",
        host="db.sittofit.tk",
        port=3306,
        database="sittofit",
        cursorclass = pymysql.cursors.DictCursor)
cursorObject = conn.cursor() 



# incoming_args = reqparse.RequestParser()
# incoming_args.add_argument("web_id", type=int, help = "Browser ID, only integer value accepted.")
# incoming_args.add_argument("preference", type=str, help = "User Preferences as a list.")
# incoming_args.add_argument("rating", type=int, help = 'User rating can only be number 1 or 2.')

preferences = {}
ratings = pd.DataFrame()
# def abort_ ()

# class Preference(Resource):
#     def get(self):
#         return preferences[web_id]
@app.route("/", methods = ['PUT'])
def put():
    incoming_args = reqparse.RequestParser()
    incoming_args.add_argument("web_id", type=int, help = "Browser ID, only integer value accepted.")
    incoming_args.add_argument("preference", type=str, help = "User Preferences as a list.")
    args = incoming_args.parse_args()
    preferences = args
    print(preferences)
    
    # cursorObject.execute('''select * from user_pref''')
    df = pd.DataFrame([preferences])
    d1 = '''INSERT INTO user_pref (web_id,pref) values (%s, %s)'''
    d2 = '''UPDATE user_pref set web_id = %s, pref = %s where web_id = %s'''

    val1 = (df["web_id"][0], df["preference"][0])
    val2 = (df['web_id'][0], df["preference"][0], df["web_id"][0])

    user_data = pd.read_sql('''select * from user_pref''', conn)
    if df['web_id'][0] in user_data['web_id'].values:
        ## UPDATE
        cursorObject.execute(d2, val2)
        conn.commit()
    else:
        cursorObject.execute(d1, val1)
        conn.commit()   
    return {'view': 'Success'}

@app.route("/rating", methods = ['PUT'])
def rating_():
    incoming_args = reqparse.RequestParser()
    incoming_args.add_argument("web_id", type=int, help = "Browser ID, only integer value accepted.")
    incoming_args.add_argument("iid", type=int, help = "Item ID, only 4 digit integer value accepted.")
    incoming_args.add_argument("rating", type=int, help = 'User rating can only be number 1 or 2.')
    args = incoming_args.parse_args()
    ratings = args
    print(ratings)

    df = pd.DataFrame([ratings])
    print(df)
    d1 = '''INSERT INTO user_rating (web_id, iid, rating) values (%s, %s, %s)'''
    d2 = '''UPDATE user_rating set web_id = %s, iid = %s, rating = %s where (web_id = %s and iid = %s)'''

    val1 = (df["web_id"][0], df["iid"][0], df['rating'][0])
    val2 = (df['web_id'][0], df["iid"][0], df["rating"][0], df['web_id'][0], df["iid"][0])

    user_rating = pd.read_sql('''select * from user_rating''', conn)
    comp1 = [df['web_id'][0], df['iid'][0]]
    comp2 = [user_rating['web_id'].values, user_rating['iid'].values]
    if comp1 == comp2:
        ## UPDATE
        cursorObject.execute(d2, val2)
        conn.commit()
    else:
        cursorObject.execute(d1, val1)
        conn.commit()
    return {'view': 'You have arrived here'} 

#@app.route("/cards", methods = ['GET'])
#def rating_():



if __name__ == "__main__":
    app.run(debug=True)


# return Response(df.to_json(orient="records"), mimetype='application/json')
