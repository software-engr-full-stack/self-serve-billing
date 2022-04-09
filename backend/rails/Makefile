# TODO:
#   1. Refactor JWT encode and decode
#   2. Turn this Makefile into tests

sign-up:
	curl --header "Content-Type: application/json" \
			 --request POST \
			 --data '{"user": {"email": "test@example.org", "name": "test", "password": "abcdefgh"}}' \
			 http://localhost:3000/api/v1/sign_up

login:
	curl --header "Content-Type: application/json" \
			 --request POST \
			 --data '{"user": {"email": "test@example.org", "password": "abcdefgh"}}' \
			 http://localhost:3000/api/v1/login

current-user:
	curl --header "Content-Type: application/json" \
			 --header "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.3At8q1MKrwLYWK010DlgAUhmTXJVg-5W9IN3x-2K4Jc" \
			 http://localhost:3000/api/v1/current_user
