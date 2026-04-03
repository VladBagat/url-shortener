import boto3
import json
import string
import random
import time
from typing import Any, Dict

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('urls')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json"
    }

    method = event.get('httpMethod')
    if method != 'POST':
        return {
            "statusCode": 405,
            "headers": headers,
            "body": json.dumps({"error": "Method Not Allowed"})
        }
   
    try:
        body = json.loads(event.get("body", "{}"))
        long_url = body["url"]
    except (KeyError, TypeError, json.JSONDecodeError):
        return {
            "statusCode": 400,
            "headers": headers,
            "body": json.dumps({"error": "Invalid request body. Expected {'url': '...'}"})
        }

    short_url = get_short_url()

    table.put_item(
        Item={
            "short_url": short_url,
            "long_url": long_url,
            "creation_time": int(time.time()),
        }
    )

    return {
        "statusCode": 200,
        "headers": headers,
        "body": json.dumps({"short_url": short_url, "long_url": long_url})
    }

def get_short_url() -> str:
    URL_LENGTH = 8
    ALPHABET = string.ascii_letters + string.digits
    return ''.join(random.choices(ALPHABET, k=URL_LENGTH))
