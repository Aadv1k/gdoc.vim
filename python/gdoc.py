from google_api import google_api
import json


query = google_api('/home/aadv1k/.vim/credentials.json', '/home/aadv1k/.vim/')


# list_doc() -> [] -> {} -> name, id, kind, mimeType

print(json.dumps(query.read_doc(query.list_doc()[0]['id'])))

