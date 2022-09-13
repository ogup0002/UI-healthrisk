import requests

BASE = "http://127.0.0.1:5000/"

response = requests.put(BASE + "rating", {"web_id": 12001, "iid": 1002,"rating": 1})

print(response.json())

# input()

# response = requests.get(BASE + 'gett')
# print(response.json())

# response = requests.get(BASE + "preference/1")
# print(response.json())
