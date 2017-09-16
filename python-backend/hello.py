from cloudant import Cloudant
from flask import Flask, render_template, request, jsonify
import atexit
import cf_deployment_tracker
import os
import json
import requests


# Emit Bluemix deployment event
cf_deployment_tracker.track()

app = Flask(__name__)

db_name = 'mydb'
client = None
db = None

if 'VCAP_SERVICES' in os.environ:
    vcap = json.loads(os.getenv('VCAP_SERVICES'))
    print('Found VCAP_SERVICES')
    if 'cloudantNoSQLDB' in vcap:
        creds = vcap['cloudantNoSQLDB'][0]['credentials']
        user = creds['username']
        password = creds['password']
        url = 'https://' + creds['host']
        client = Cloudant(user, password, url=url, connect=True)
        db = client.create_database(db_name, throw_on_exists=False)
elif os.path.isfile('vcap-local.json'):
    with open('vcap-local.json') as f:
        vcap = json.load(f)
        print('Found local VCAP_SERVICES')
        creds = vcap['services']['cloudantNoSQLDB'][0]['credentials']
        user = creds['username']
        password = creds['password']
        url = 'https://' + creds['host']
        client = Cloudant(user, password, url=url, connect=True)
        db = client.create_database(db_name, throw_on_exists=False)

# On Bluemix, get the port number from the environment variable PORT
# When running this app on the local machine, default the port to 8000
port = int(os.getenv('PORT', 8000))

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/request')
def request_data():

    """ OpenFEMA API Documentation
        https://www.fema.gov/openfema-api-documentation"""

    response = get_lastest_weather_report('FL','Hurricane')

    query_url = response.url
    summaries = response.json()['DisasterDeclarationsSummaries']
    status_code = response.status_code

    print(status_code)
    print(query_url)

    return render_template('data.html',query_url=query_url,status_code=status_code,summaries=summaries)


def get_lastest_weather_report(state=None,incidentType=None,incidentBeginDate=None,top=20):
    url = 'https://www.fema.gov/api/open/v1/DisasterDeclarationsSummaries'

    #disasterType: major disaster (MD), fire management (FM) or emergency declaration (EM)
    select = 'disasterNumber,state,disasterType,incidentBeginDate,incidentEndDate,incidentType,placeCode,declaredCountyArea',

    params = {'$select':select,
              '$top':top,
              '$orderby':'incidentBeginDate desc',            
              }

    filters = []
    if state is not None:
         filters.append("state eq '%s'" %state)

    if incidentType is not None:
        filters.append("incidentType eq '%s'" %incidentType)

    if incidentBeginDate is not None:
        #Date format: '1969-04-18T04:00:00.000z'
        filters.append("incidentBeginDate ge '%s'" %incidentBeginDate)

    if filters != []:
        params['$filter'] = ' and '.join(filters)

    response = requests.get(url,params=params)

    export_response_to_csv(response)

    return response

def export_response_to_csv(response):
    data = response.json()['DisasterDeclarationsSummaries']
    keys = [key for key in data[0]]
    print(keys)
    with open('incidents.csv','w') as csv:
        csv.write(','.join(keys)+'\n')
        for i in range(len(data)):
            values = [str(data[i][key]) for key in keys]
            csv.write(','.join(values)+'\n')







# /* Endpoint to greet and add a new visitor to database.
# * Send a POST request to localhost:8000/api/visitors with body
# * {
# *     "name": "Bob"
# * }
# */
@app.route('/api/visitors', methods=['GET'])
def get_visitor():
    if client:
        return jsonify(list(map(lambda doc: doc['name'], db)))
    else:
        print('No database')
        return jsonify([])

# /**
#  * Endpoint to get a JSON array of all the visitors in the database
#  * REST API example:
#  * <code>
#  * GET http://localhost:8000/api/visitors
#  * </code>
#  *
#  * Response:
#  * [ "Bob", "Jane" ]
#  * @return An array of all the visitor names
#  */
@app.route('/api/visitors', methods=['POST'])
def put_visitor():
    user = request.json['name']
    if client:
        data = {'name':user}
        db.create_document(data)
        return 'Hello %s! I added you to the database.' % user
    else:
        print('No database')
        return 'Hello %s!' % user

@atexit.register
def shutdown():
    if client:
        client.disconnect()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port, debug=True)
