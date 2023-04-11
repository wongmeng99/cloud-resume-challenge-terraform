import boto3
import json

# create a DynamoDB object using the AWS SDK
dynamodb = boto3.resource('dynamodb')
# use the DynamoDB object to select our table
table = dynamodb.Table('http-crud-tutorial-items')



# define the handler function that the Lambda service will use as an entry point
def lambda_handler(event, context):

# write name and time to the DynamoDB table using the object we instantiated and save response in a variable
    response = table.put_item(
        Item={
            'id': event['name'],
            'email':event['email'],
            'message':event['message'] 
            })
# return a properly formatted JSON object
    return {
        'statusCode': 200,
        'body': json.dumps('I really appreciate your interest, ' + event['name'])
    }