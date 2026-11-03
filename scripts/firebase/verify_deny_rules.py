#!/usr/bin/env python3
"""Smoke-test deny-all Firestore rules for anonymous and authenticated clients."""
import json
import os
import urllib.error
import urllib.request

auth_host = os.environ['FIREBASE_AUTH_EMULATOR_HOST']
auth_url = f'http://{auth_host}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo'
request = urllib.request.Request(auth_url, data=b'{"returnSecureToken":true}', headers={'Content-Type': 'application/json'})
with urllib.request.urlopen(request) as response:
    token = json.load(response)['idToken']
host = os.environ['FIRESTORE_EMULATOR_HOST']
url = f'http://{host}/v1/projects/demo-hareup/databases/(default)/documents/groups/other-group'
for actor, credential in [('anonymous', None), ('authenticated', token)]:
    for method, data in [('GET', None), ('PATCH', json.dumps({'fields': {'name': {'stringValue': 'private'}}}).encode())]:
        headers = {'Content-Type': 'application/json'}
        if credential:
            headers['Authorization'] = f'Bearer {credential}'
        request = urllib.request.Request(url, data=data, method=method, headers=headers)
        try:
            with urllib.request.urlopen(request) as response:
                raise SystemExit(f'{actor} {method} unexpectedly succeeded: {response.status}')
        except urllib.error.HTTPError as error:
            if error.code != 403:
                raise SystemExit(f'{actor} {method} expected 403, received {error.code}') from error
            print(f'{actor} {method}: denied (403)')
