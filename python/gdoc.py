from google_api import google_api
from itertools import chain


class doc_query(google_api):
    def __init__(self, credentials_file_path,
                 token_directory='./', gdoc_file='./.gdoc'):
        super().__init__(credentials_file_path, token_directory)
        self.gdoc_file = gdoc_file

    def write_id_to_file(self, idx, file_name):
        f = open(self.gdoc_file, 'a')
        f.write(f"{file_name} -> {idx}\n")
        f.close()

    def parse_doc(self, document: dict):
        content_str = []

        for elems in document['body']['content']:
            para = elems.get('paragraph', False)
            doc_length = 0

            doc_length += elems['endIndex']

            if para:
                cur_str = [item['textRun']['content']
                           for item in para['elements']]
                content_str.append(cur_str)

        return ("".join(list(chain(*content_str))), doc_length)

    def sync_doc(self, new_doc: str, old_doc_id: str):
        _, doc_length = self.parse_doc(self.read_doc(old_doc_id))

        blob = [
            {
                'deleteContentRange': {
                    'range': {
                        'startIndex': 1,
                        'endIndex': doc_length - 1,
                    }
                }
            },

            {
                'insertText': {
                    'location': {'index': 1},
                    'text': new_doc
                }
            }
        ]

        result = self.edit_doc(old_doc_id, blob)
        if not result:
            return -1

        return result

    def open_doc_from_file(self, fname: str = '', idx: str = ''):
        with open(self.gdoc_file) as file:
            ids = [line.split(
                '->') for line in file.read().split('\n') if all(line.split('->'))]

        for id in ids:
            doc_name, doc_id = id[0].strip(), id[1].strip()
            if doc_name == fname or doc_id == idx:
                return (self.parse_doc(self.read_doc(doc_id)), doc_id, doc_name)
            else:
                continue
        return -1

# list_doc() -> [] -> {} -> name, id, kind, mimeType
# 'create_doc', 'edit_doc', 'list_doc', 'read_doc'
