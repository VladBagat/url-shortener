import boto3
import json
import os
import string
import random
import time
from botocore.exceptions import ClientError
from typing import Any, Dict

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ["TABLE_NAME"]
SHORT_CODE_KEY = os.environ["SHORT_CODE_KEY"]
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    headers = {
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

    ttl = int(time.time()) + get_days_in_seconds(1)
    short_url = None
    max_retries = 5

    for _ in range(max_retries):
        candidate_short_url = get_short_url()

        try:
            table.put_item(
                Item={
                    SHORT_CODE_KEY: candidate_short_url,
                    "long_url": long_url,
                    "expires_at": ttl,
                },
                ConditionExpression=f"attribute_not_exists({SHORT_CODE_KEY})",
            )
            short_url = candidate_short_url
            break
        except ClientError as exc:
            if exc.response["Error"]["Code"] != "ConditionalCheckFailedException":
                raise

    if short_url is None:
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"error": "Could not generate a unique short URL"})
        }

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
