import boto3
import json
import os
import string
import random
import time
from typing import Any, Dict

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ["TABLE_NAME"]
SHORT_CODE_KEY = os.environ["SHORT_CODE_KEY"]
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json"
    }

    method = event.get("httpMethod") or event.get("requestContext", {}).get("http", {}).get("method")
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
    
    ttl = int(time.time()) + get_days_in_seconds(1)

    table.put_item(
        Item={
        SHORT_CODE_KEY: short_url,
        "long_url": long_url,
        "expires_at": ttl,
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

def get_days_in_seconds(days: int) -> int:
    return days * 24 * 60 * 60
