from app.services.hello import say_hello

res = say_hello("World")
print(res)
assert res["message"] == "Hello, World!"
print("verify_hello: OK")
