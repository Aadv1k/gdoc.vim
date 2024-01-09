from __future__ import print_function

import os.path
import os
import pickle
import sys

from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

from fmt_msg import GdocErr

class google_api():
    def __init__(self, credentials_file_path, token_directory: str = './'):
        self.SCOPES = [
            'https://www.googleapis.com/auth/documents',
            'https://www.googleapis.com/auth/drive'
        ]
        self.drive_service = None
        self.docs_service = None
        self.creds = None
        self.token_directory = os.path.normpath(token_directory)

        if not credentials_file_path:
            print('Please provide a credentials file.', credentials_file_path)
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
                        #gdoc_err('Please provide a valid credentials file')
                        raise GdocErr('Please provide a valid credentials file')
                else:
                    #gdoc_err('Please provide a valid credentials file')
                    raise GdocErr('Please provide a valid credentials file')

            path_exists = os.path.exists(
                os.path.join(
                    self.token_directory,
                    'token.pickle'))

            if path_exists:
                with open(os.path.join(self.token_directory, 'token.pickle'), 'wb') as token:
                    pickle.dump(self.creds, token)
            else:
                file_path = os.path.join(self.token_directory, 'token.pickle')
                os.makedirs(os.path.dirname(file_path), exist_ok=True)

                with open(file_path, 'wb') as token:
                    pickle.dump(self.creds, token)

        if self.creds is None:
            raise GdocErr('Service credentials unavailable!')

        self.drive_service = build('drive', 'v3', credentials=self.creds)
        self.docs_service = build('docs', 'v1', credentials=self.creds)

    def delete_doc(self, file_id):
        try:
            dq = self.drive_service.files().delete(fileId=file_id).execute()
            return (0, dq)
        except Exception as e:
            return (-1, e)

    def create_doc(self, blob):
        doc = self.docs_service.documents().create(body=blob).execute()
        return {
            'id': doc.get('documentId', None),
            'title': doc.get('title', None)
        }

    def list_doc(self, params: str):
        page_token = None
        res = []

        while True:
            response = self.drive_service.files().list(
                q=params,
                fields='nextPageToken, files(id, name)',
                pageToken=page_token).execute()
            for file in response.get('files', []):
                res.append(file)
            page_token = response.get('nextPageToken', None)
            if page_token is None:
                break
        return res

    def read_doc(self, doc_id):
        document = self.docs_service.documents().get(documentId=doc_id).execute()
        return document

    def extract_text_from_gdoc_data(self, data):
        text_content = ""

        if 'body' in json_data and 'content' in json_data['body']:
            for item in json_data['body']['content']:
                if 'paragraph' in item and 'elements' in item['paragraph']:
                    for element in item['paragraph']['elements']:
                        if 'textRun' in element and 'content' in element['textRun']:
                            text_content += element['textRun']['content']
        return text_content




    def edit_doc(self, doc_id, blob):
        result = self.docs_service.documents().batchUpdate(
            documentId=doc_id, body={'requests': blob}).execute()
        return result
