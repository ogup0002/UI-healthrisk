import requests

# BASE = "http://127.0.0.1:5000/"
BASE = "https://sittofit-backend-ogup0002.vercel.app/trial"
 
# response = requests.put(BASE + "rating", {"web_id": 12001, "iid": 1002,"rating": 1})

# print(response.json())

# input()

# response = requests.get(BASE + 'cards')
# print(response.json())

# response = requests.get(BASE + "preference/1")
# print(response.json())

response = requests.get(BASE)
print(response.json())

# import requests 
# import json

# BASE = "http://1be2-121-200-5-152.ngrok.io" 

# response = requests.put(BASE, {'link' : 'C:\\Users\\pragya\\Downloads\\Iteration 2\\test\\new_holland_honeyeater_test_1.wav'})
# print(response.json())