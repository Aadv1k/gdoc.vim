from __future__ import print_function

import os.path
import os
import pickle
import sys

from apiclient import errors
from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build



class make_query():
    def __init__(self, credentials_file_path: str = None, token_directory: str = './'):
        self.SCOPES = [
            'https://www.googleapis.com/auth/documents',
            'https://www.googleapis.com/auth/drive'
        ]
        self.drive_service = None
        self.docs_service = None
        self.creds = None
        self.token_directory = os.path.normpath(token_directory)

        if not credentials_file_path:
            print('Please provide a credentials file.')
            sys.exit()
        self.credential_file = os.path.normpath(credentials_file_path)

        if os.path.exists(os.path.join(self.token_directory, 'token.pickle')):
            with open(os.path.join(self.token_directory, 'token.pickle'), 'rb') as token:
                self.creds = pickle.load(token)
        if not self.creds or not self.creds.valid:
            if self.creds and self.creds.expired and self.creds.refresh_token:
                self.creds.refresh(Request())
            else:

                if os.path.exists(self.credential_file):
                    try:
                        flow = InstalledAppFlow.from_client_secrets_file(
                            self.credential_file, self.SCOPES)

                        self.creds = flow.run_local_server(port=0)
                    except Exception as _:
                        print('Please provide a credentials file')
                        sys.exit()
                else:
                    print('Please provide a valid crednetials file')
                    sys.exit()

            path_exists = os.path.exists(os.path.join(self.token_directory, 'token.pickle'))
            
            if path_exists:
                with open(os.path.join(self.token_directory, 'token.pickle'), 'wb') as token:
                    pickle.dump(self.creds, token)
            else:
                file_path = os.path.join(self.token_directory, 'token.pickle')
                os.makedirs(os.path.dirname(file_path), exist_ok=True)

                with open(file_path, 'wb') as token:
                    pickle.dump(self.creds, token)



        if self.creds is None:
            print('ERROR : Service credentials unavailable!')
            sys.exit()

        self.drive_service = build('drive', 'v3', credentials=self.creds)
        self.docs_service = build('docs', 'v1', credentials=self.creds)

    def create_doc(self, blob):
        doc = self.docs_service.documents().create(body=blob).execute()
        return {
                'id': doc.get('documentId', None), 
                'title': doc.get('title', None)
            }

    def list_doc(self, get_all=False):
        result = []
        if not get_all:
            file = self.drive_service.files().list().execute()
            filtered_data = filter(
                lambda x: x['mimeType'] == 'application/vnd.google-apps.document',
                file['files'])
            for item in filtered_data:
                result.append(item)
            return result

        else:
            page_token = None
            data = []
            while True:
                try:
                    param = {}
                    if page_token:
                        param['pageToken'] = page_token
                    files = self.drive_service.files().list(**param).execute()
                    data.extend(files['files'])

                    page_token = files.get('nextPageToken')
                    if not page_token:
                        break
                except errors.HttpError as error:
                    print('An error occurred: ', error)
                    break

        filtered_data = filter(
            lambda x: x['mimeType'] == 'application/vnd.google-apps.document',
            file['files'])
        for item in filtered_data:
            result.append(item)
        return result

    def read_doc(self, doc_id):
        document = self.docs_service.documents().get(documentId=doc_id).execute()
        return document

    def edit_doc(self, doc_id, blob):
        result = self.docs_service.documents().batchUpdate(documentId=doc_id, body={'requests': blob}).execute()
        return result
