import boto3
import json
from typing import Any, Dict

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('urls')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:  
    path_parameters = event.get("pathParameters") or {}
    short_id = path_parameters.get("short_id")
    
    if not short_id:
        return {
            "statusCode": 400, 
            "body": json.dumps({"error": "Missing short_id"})
        }

    response = table.get_item(
        Key={"short_url": short_id},
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