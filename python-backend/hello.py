from cloudant import Cloudant
#from flask import Flask, render_template, request, jsonify, url_for
from flask import Flask, jsonify, url_for, render_template, redirect, request
import atexit
import cf_deployment_tracker
import os
import json
import requests
import pandas as pd
from states import state_acronyms, COUNTRY

# Emit Bluemix deployment event
cf_deployment_tracker.track()

template_dir = os.path.abspath('frontend')
app = Flask(__name__,template_folder=template_dir,static_folder='frontend',static_url_path='')

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



@app.route('/',methods=['GET','POST'])
def home():
    print("Welcome to front page")
    if request.method == 'POST':
        if request.form['existingCustomer'] == 'Yes':
            return redirect(url_for('login'))
        if request.form['existingCustomer'] == 'No':
            return redirect(url_for('register'))
    return render_template('index.html')

@app.route('/UserVerification/login',methods=['GET','POST'])
def login():
    print("Welcome to login page")
    if request.method == 'POST':
        if request.form['login_to_dashboard'] == 'Login':
            return redirect(url_for('dashboard'))
    return render_template('UserVerification/login.html')

@app.route('/UserVerification/register',methods=['GET','POST'])
def register():
    print("Welcome to register page")
    if request.method == 'POST':
        if request.form['Submit'] == 'Submit':
            return redirect(url_for('choose_business'))
    return render_template('UserVerification/register.html')

@app.route('/UserVerification/ChooseBusiness/choose_business',methods=['GET','POST'])
def choose_business():
    print("Welcome to choice of business page")
    industries = ['Tradesmen', 'Renewables', 'Manufacturer', 'IT', 'Farmer', 'Outdoor guide']
    if request.method == 'POST':
        if request.form['business']:
            return redirect(url_for('choose_region'))
    return render_template('UserVerification/ChooseBusiness/choose_business.html',industries=industries)

@app.route('/UserVerification/ChooseBusiness/choose_region/<country>/<state>/<county>',methods=['GET','POST'])
@app.route('/UserVerification/ChooseBusiness/choose_region/<country>/<state>',methods=['GET','POST'])
@app.route('/UserVerification/ChooseBusiness/choose_region',methods=['GET','POST'])
@app.route('/UserVerification/ChooseBusiness/choose_region/<country>',methods=['GET','POST'])
def choose_region(country=None,state=None,county=None):
    print("Welcome to choice of region page")


    print(country)

    countries = sorted([q for q in COUNTRY])
    states = []
    counties = []

    if country is None:
        country_chosen = False
    else:
        country_chosen = country#True
        if country == 'United States':
            states = sorted([q for q in state_acronyms])

    if state is None:
        state_chosen = False
    else:
        state_chosen = state#True
        if country == 'United States' and state == 'Florida':
            counties = ['Charlotte']       


    print(request.method)

    if request.method == 'POST':
        # print(request.form['country'])
        # print(request.form['state'])
        # print(request.form['county'])
        if country is None and request.form['country']:
            print(request.form['country'])
            print(url_for('choose_region',country=request.form['country']))
            render_template(url_for('choose_region',country=request.form['country']))

        # if state is None and request.form['state']:
        #     redirect(url_for('choose_region',country=request.form['country'],state=request.form['state']))

        # if request.form['county']:# and state is None and county is None:
        #     redirect(url_for('dashboard'))

    print(request.method)


        # if request.form['country']:
        #     country_chosen = True
        #     if request.form['country'] == 'United States':
        #         states = [q for q in state_acronyms]
    # if request.method == 'POST':
    #     if request.form['state']:
    #         country_chosen = True
    #         state_chosen = True
    # if request.method == 'POST':
    #     if request.form['region'] == 'Yes':
    #         return redirect(url_for('dashboard'))

    return render_template('UserVerification/ChooseBusiness/choose_region.html',countries=countries,
        states=states,counties=counties,country_chosen=country_chosen,state_chosen=state_chosen)

@app.route('/UserVerification/Dashboard/dashboard')
@app.route('/UserVerification/Dashboard/dashboard/<country>/<state>/<county>')
def dashboard(country=None,state=None,county=None):
    print(country,state,county)

    if country is None:
        country = 'USA'
    if state is None:
        state = 'Florida'
    if county is None:
        county = 'Charlotte'


    report = spatial_report(state=state,county=county)  

    # Weather reports  
    weather_scores = {'frost':0,
                      'hail':0,
                      'drought':0,
                      'flood':0,
                      'storm':0}

    if 'Freezing' in report.disasters_county_by_type:
        weather_scores['frost'] += report.disasters_county_by_type['Freezing']
    if 'Snow' in report.disasters_county_by_type:
        weather_scores['frost'] += report.disasters_county_by_type['Snow']

    if 'Fire' in report.disasters_county_by_type:
        weather_scores['drought'] += report.disasters_county_by_type['Fire']

    if 'Hurricane' in report.disasters_county_by_type:
        weather_scores['storm'] += report.disasters_county_by_type['Hurricane']
    if 'Severe Storm(s)' in report.disasters_county_by_type:
        weather_scores['storm'] += report.disasters_county_by_type['Severe Storm(s)']
    if 'Coastal Storm' in report.disasters_county_by_type:
        weather_scores['storm'] += report.disasters_county_by_type['Coastal Storm']
    
    if 'Flood' in report.disasters_county_by_type:
        weather_scores['flood'] += report.disasters_county_by_type['Flood']

    print(weather_scores)
    for i in weather_scores:
        weather_scores[i] = int(100*weather_scores[i]/report.number_disasters_county)


    #Insurance reports
    claims_dict = report.data_claims_state_county.to_dict()
    for i in claims_dict:
        claims_dict[i] =  claims_dict[i][next(iter(claims_dict[i]))]

    policies_dict = report.data_policies_state_county.to_dict()
    for i in policies_dict:
        policies_dict[i] = policies_dict[i][next(iter(policies_dict[i]))]
    print(claims_dict)
    print(policies_dict)

    return render_template('UserVerification/Dashboard/dashboard.html',weather_scores=weather_scores,claims_dict=claims_dict,policies_dict=policies_dict)



@app.route('/request')
def request_data():

    """ OpenFEMA API Documentation
        https://www.fema.gov/openfema-api-documentation"""

    response = get_lastest_weather_report('FL','Flood')

    query_url = response.url
    status_code = response.status_code
    if status_code == '200':
        summaries = response.json()['DisasterDeclarationsSummaries']
    else:
        summaries = ['Access denied: %s' %status_code]
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

    if response.status_code == '200':
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
    import gdal
    import numpy as np

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


class spatial_report:

    def __init__(self,state='Florida',county='Charlotte'):

        input_claims = 'formatted_claims_county.txt'
        input_policies = 'formatted_policies_county.txt'

        self.data_claims = pd.read_csv(input_claims,sep='\t')
        self.data_policies = pd.read_csv(input_policies,sep='\t')

        self.data_claims_state = self.data_claims[self.data_claims['state'] == state.upper()]
        self.data_claims_state_county = self.data_claims_state[self.data_claims_state['county'] == county.upper() + ' COUNTY']
        self.data_policies_state = self.data_policies[self.data_policies['state'] == state.upper()]
        self.data_policies_state_county = self.data_policies_state[self.data_policies_state['county'] == county.upper() + ' COUNTY']

        print('\n\n===== Claims in %s, %s =======' %(state,county))
        print(self.data_claims_state_county.head())

        print('\n\n===== Policies in %s, %s =======' %(state,county))
        print(self.data_policies_state_county.head())


        start_date = '2000-01-01T04:00:00.000z'
        response = get_lastest_weather_report(state=state_acronyms[state],incidentBeginDate=start_date)

        if response.status_code == '200':
            self.data_disasters = response.json()['DisasterDeclarationsSummaries']

            self.data_disasters_county = [q for q in self.data_disasters if q['declaredCountyArea'] == '%s (County)' %county]
            self.number_disasters = len(self.data_disasters)
            self.number_disasters_county = len(self.data_disasters_county)
            self.disasters_by_type = get_occurence_by_incident(self.data_disasters,'incidentType')
            self.disasters_county_by_type = get_occurence_by_incident(self.data_disasters_county,'incidentType')

            print('\n\n===== No. of disasters in %s =======' %(state))
            print(self.number_disasters)
            print(self.disasters_by_type)


            print('\n\n===== No. of disasters in %s, %s =======' %(state,county))
            print(self.number_disasters_county)
            print(self.disasters_county_by_type)
        else:
            self.disasters_county_by_type = []
            self.disasters_by_type = []

            self.number_disasters = 1
            self.number_disasters_county = 1







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



#Test cases before going live:
get_lastest_weather_report('FL','Flood')
spatial_report(state='Florida',county='Charlotte')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port, debug=True)


#    convert_geotiff_to_npy()


