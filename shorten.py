import boto3
import json
import string
import random
import time
from typing import Any, Dict
from boto3.dynamodb.conditions import Attr
from botocore.exceptions import ClientError

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

    MAX_RETRIES = 5
    for _ in range(MAX_RETRIES):
        short_url = get_short_url()
        
        try:
            table.put_item(
                Item={
                    "short_url": short_url,
                    "long_url": long_url,
                    "creation_time": int(time.time()),
                },
                ConditionExpression=Attr('short_url').not_exists()
            )
            
            return {
                "statusCode": 200,
                "headers": headers,
                "body": json.dumps({"short_url": short_url, "long_url": long_url})
            }
            
        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                continue
            else:
                raise 

    return {
        "statusCode": 500,
        "headers": headers,
        "body": json.dumps({"error": "Could not generate a unique short URL."})
    }

def get_short_url() -> str:
    URL_LENGTH = 6
    ALPHABET = string.ascii_letters + string.digits
    return ''.join(random.choices(ALPHABET, k=URL_LENGTH))