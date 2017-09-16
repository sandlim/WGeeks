from cloudant import Cloudant
from flask import Flask, render_template, request, jsonify
import atexit
import cf_deployment_tracker
import os
import json
import requests
import gdal
import numpy as np
import pandas as pd


state_acronyms = {'Florida':'FL'}



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

    response = get_lastest_weather_report('FL','Flood')

    query_url = response.url
    summaries = response.json()['DisasterDeclarationsSummaries']
    status_code = response.status_code

    print(status_code)
    print(query_url)

    return render_template('data.html',query_url=query_url,status_code=status_code,summaries=summaries)


def get_lastest_weather_report(state=None,incidentType=None,incidentBeginDate=None,declaredCountyArea=None,top=None):
    url = 'https://www.fema.gov/api/open/v1/DisasterDeclarationsSummaries'

    #disasterType: major disaster (MD), fire management (FM) or emergency declaration (EM)
    select = 'disasterNumber,state,disasterType,incidentBeginDate,incidentEndDate,incidentType,placeCode,declaredCountyArea',

    params = {'$select':select,
              '$orderby':'incidentBeginDate desc',            
              }
    if top is not None:
        params['$top'] = top,

    filters = []
    if state is not None:
         filters.append("state eq '%s'" %state)

    if declaredCountyArea is not None:
         filters.append("declaredCountyArea eq '%s'" %state)

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
    with open('incidents.csv','w') as csv:
        csv.write(','.join(keys)+'\n')
        for i in range(len(data)):
            values = [str(data[i][key]) for key in keys]
            csv.write(','.join(values)+'\n')


def export_geotiff_to_npy():
    input_file = 'fl_risk_20170916104510_tiff/fl1010irmt.tif'
    output_file = 'out.raster'    
    ds = gdal.Open(input_file)
    band = ds.GetRasterBand(1)
    arr = band.ReadAsArray()
    [cols, rows] = arr.shape
    arr_min = arr.min()
    arr_max = arr.max()
    arr_mean = int(arr.mean())
    arr_out = np.where((arr < arr_mean), 10000, arr)
    driver = gdal.GetDriverByName("GTiff")
    outdata = driver.Create(output_file, rows, cols, 1, gdal.GDT_UInt16)
    outdata.SetGeoTransform(ds.GetGeoTransform())##sets same geotransform as input
    outdata.SetProjection(ds.GetProjection())##sets same projection as input
    outdata.GetRasterBand(1).WriteArray(arr_out)
    outdata.GetRasterBand(1).SetNoDataValue(10000)##if you want these values transparent
    outdata.FlushCache() ##saves to disk!!
    outdata = None
    band=None
    ds=None
    np.save('fl1010irmt.npy',arr_out)


def get_occurence_by_incident(data,incident):
    dictionary = {}
    for i in range(len(data)):
        current_incidentType = data[i][incident]
        if current_incidentType not in dictionary:
            dictionary[current_incidentType] = 1
        else:
            dictionary[current_incidentType] += 1
    return dictionary


def get_spatial_report(state='Florida',county='Charlotte'):

    input_claims = 'formatted_claims_county.txt'
    input_policies = 'formatted_policies_county.txt'
    data_claims = pd.read_csv(input_claims,sep='\t')
    data_policies = pd.read_csv(input_policies,sep='\t')
    data_claims_state = data_claims[data_claims['state'] == state.upper()]
    data_claims_state_county = data_claims_state[data_claims_state['county'] == county.upper() + ' COUNTY']
    data_policies_state = data_policies[data_policies['state'] == state.upper()]
    data_policies_state_county = data_policies_state[data_policies_state['county'] == county.upper() + ' COUNTY']

    print('\n\n===== Claims in %s, %s =======' %(state,county))
    print(data_claims_state_county.head())

    print('\n\n===== Policies in %s, %s =======' %(state,county))
    print(data_policies_state_county.head())



    start_date = '2000-01-01T04:00:00.000z'
    response = get_lastest_weather_report(state=state_acronyms[state],incidentBeginDate=start_date)
    data_disasters = response.json()['DisasterDeclarationsSummaries']
    data_disasters_county = [q for q in data_disasters if q['declaredCountyArea'] == '%s (County)' %county]
    number_disasters = len(data_disasters)
    number_disasters_county = len(data_disasters_county)
    disasters_by_type = get_occurence_by_incident(data_disasters,'incidentType')
    disasters_county_by_type = get_occurence_by_incident(data_disasters_county,'incidentType')

    print('\n\n===== No. of disasters in %s =======' %(state))
    print(number_disasters)
    print(disasters_by_type)


    print('\n\n===== No. of disasters in %s, %s =======' %(state,county))
    print(number_disasters_county)
    print(disasters_county_by_type)






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


get_spatial_report(state='Florida',county='Charlotte')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port, debug=True)
#    convert_geotiff_to_npy()


