import os
import traceback

from flask import Flask
app = Flask(__name__)

EFS_MOUNT_POINT = os.environ.get('EFS_MOUNT_POINT')

def demo_file_content():
    print(f'EFS_MOUNT_POINT: {EFS_MOUNT_POINT}')
    content = None
    try:
        READ_FILENAME = os.path.join(EFS_MOUNT_POINT, 'demo.txt')
        with open(READ_FILENAME, 'r') as f:
            content = ''.join(f.readlines())
    except Exception as e:
        print(f'Exception: {traceback.format_exc()}')
        content = 'An error has been occurred. Check out logs.'
        pass
    return content

@app.route("/")
def hello():
    return demo_file_content()

if __name__ == "__main__":
    # Only for debugging while developing
    app.run(host='0.0.0.0', debug=True, port=80)
