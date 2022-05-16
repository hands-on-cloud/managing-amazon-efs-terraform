import os

EFS_MOUNT_POINT = os.environ.get('EFS_MOUNT_POINT')

def lambda_handler(event, context):
    WRITE_FILENAME = os.path.join(EFS_MOUNT_POINT, 'lambda_created.txt')

    with open(WRITE_FILENAME, 'w') as f:
        lines = [
            'I am writing first line. This is still first line.\n',
            'Now, I am on second line.\n',
            'This is 3rd\n'
        ]

        f.writelines(lines)

    READ_FILENAME = os.path.join(EFS_MOUNT_POINT, 'demo.txt')
    content = None
    with open(READ_FILENAME, 'r') as f:
        content = f.readlines()

    return {
        'statusCode': 200,
        'content': ' '.join(content)
    }
