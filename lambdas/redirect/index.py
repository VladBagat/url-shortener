import boto3
import json
import os
from typing import Any, Dict

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ["TABLE_NAME"]
SHORT_CODE_KEY = os.environ["SHORT_CODE_KEY"]
PATH_PARAMETER_NAME = os.environ.get("PATH_PARAMETER_NAME", "short_code")
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:  
    path_parameters = event.get("pathParameters") or {}
    short_id = path_parameters.get(PATH_PARAMETER_NAME)
    
    if not short_id:
        return {
            "statusCode": 400, 
            "body": json.dumps({"error": "Missing short_id"})
        }

    response = table.get_item(
        Key={SHORT_CODE_KEY: short_id},
        ProjectionExpression="long_url"
    )

    item = response.get("Item")

    if item and "long_url" in item:
        return {
            "statusCode": 302,
            "headers": {
                "Location": item["long_url"],
                "Cache-Control": "no-cache, no-store, must-revalidate"
            }
        }
    else:
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "URL not found"})
        }
