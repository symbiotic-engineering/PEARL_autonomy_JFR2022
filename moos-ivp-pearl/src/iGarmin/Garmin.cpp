/*
 * Garmin.cpp
 * 
 * Created on: 6/30/2021
 * Auther: Ethan Rolland
 * 
 */

#include "MBUtils.h"
#include "NMEAdefs.h"
#include "Garmin.h"
#include "NMEA2000_CAN.h"
#include "N2kMessages.h"
//#include "N2kMessagesEnumToStr.h" //Necessary if Printing to a stream


using namespace std;

/*
 * Static NMEA string exists because overwritten Handler must be static so the handler can 
 * be reassigned as the handler called by the ParseMessages() function provided. ParseMessages
 * must be overwritten because the default ParseMessages simply publishes to a stream.
 */
vector<double> GARMIN::m_heading_vals = {};

GARMIN::GARMIN()
{
	//MOOS file parameters
	m_prefix           = "GAR";
	m_num_devices      = 0;
	m_device_names     = {};
	m_heading_offset   = 0.0;
	
	m_bValidCanBusConn = false;
}

bool GARMIN::OnNewMail(MOOSMSG_LIST &NewMail)
{
	AppCastingMOOSApp::OnNewMail(NewMail);
	MOOSMSG_LIST::iterator p;
	for (p=NewMail.begin(); p!=NewMail.end(); ++p) {
	  CMOOSMsg &rMsg = *p;
	  string key     = rMsg.GetKey();
	  string sVal    = rMsg.GetString();
	}
	return UpdateMOOSVariables(NewMail);
}

void GARMIN::RegisterForMOOSMessages()
{
	AppCastingMOOSApp::RegisterVariables();
}

bool GARMIN::OnStartUp()
{
	AppCastingMOOSApp::OnStartUp();
	STRING_LIST sParams;
	if (!m_MissionReader.GetConfiguration(GetAppName(), sParams))
		reportConfigWarning("No config block found for " + GetAppName());
	
	bool handled = true;
	STRING_LIST::iterator p;
	for (p = sParams.begin(); p != sParams.end(); p++) {
		string orig   = *p;
		string line   = *p;
		string param  = toupper(biteStringX(line, '='));
		string value  = line;

		if      (param == "PREFIX")         handled = SetParam_PREFIX(value);
		else if (param == "NUM_DEVICES")	handled = SetParam_NUM_DEVICES(value);
		else if (param == "DEVICE_NAMES")   handled = SetParam_DEVICE_NAMES(value);
		else if (param == "HEADING_OFFSET") handled = SetParam_HEADING_OFFSET(value);
		else
		  reportUnhandledConfigWarning(orig); }
	
	CheckDeviceInit();
	
	RegisterForMOOSMessages();
	MOOSPause(500);
	
	// Set up and start NMEA messages
	NMEA2000.EnableForward(false);
	NMEA2000.SetMsgHandler(HandleNMEA2000Msg);
	m_bValidCanBusConn = NMEA2000.Open();
	
	return true;
}

bool GARMIN::OnConnectToServer()
{
	RegisterForMOOSMessages();
	return true;
}

bool GARMIN::Iterate()
{
	AppCastingMOOSApp::Iterate();
	
	if (m_bValidCanBusConn && m_num_devices>0) {
		//Overwritten ParseMessages function will now call HandleNMEA2000Msg
		NMEA2000.ParseMessages();
	
		PublishHeadings(m_device_names,m_heading_vals);
	}
	
	AppCastingMOOSApp::PostReport();
	
	return true;
}

bool GARMIN::SetParam_PREFIX(string sVal)
{
	m_prefix = toupper(sVal);
	size_t strLen = m_prefix.length();
	if (strLen > 0 && m_prefix.at(strLen -1) != '_')
		m_prefix += "_";
	
	return true;
}

bool GARMIN::SetParam_NUM_DEVICES(string sVal)
{
	stringstream ssMsg;
	if (!isNumber(sVal))
		ssMsg << "Param NUM_DEVICES must be an integer. Defaulting to 0.";
	else
		m_num_devices = stoi(sVal);
	string msg = ssMsg.str();
	if (!msg.empty())
		reportConfigWarning(msg);
	
	return true;
}

bool GARMIN::SetParam_DEVICE_NAMES(string sVal)
{
	if (!sVal.empty()) {
		string names = toupper(sVal);
		m_device_names = parseString(names, ',');
	}		
	return true;
}

bool GARMIN::SetParam_HEADING_OFFSET(std::string sVal)
{
  stringstream ssMsg;
  if (!isNumber(sVal))
    ssMsg << "Param HEADING_OFFSET must be a number in range (-180.0 180.0). Defaulting to 0.0.";
  else 
    m_heading_offset = strtod(sVal.c_str(), 0);
  if (m_heading_offset <= -180.0 || m_heading_offset >= 180.0) {
    ssMsg << "Param HEADING_OFFSET cannot be " << m_heading_offset << ". Must be in range (-180.0, 180.0). Defaulting to 0.0.";
    m_heading_offset = 0.0; }
  string msg = ssMsg.str();
  if (!msg.empty())
    reportConfigWarning(msg);
  
  return true;
}

void GARMIN::CheckDeviceInit()
{
	stringstream ssMsg;
	if (m_device_names.size() != m_num_devices) {
		ssMsg << "Number of device names specified does not equal NUM_DEVICES. Setting NUM_DEVICES to 0.";
		m_num_devices = 0;
	}
	else {
		for (size_t i = 0; i != m_device_names.size(); i++) {
			m_heading_vals.push_back(BAD_DOUBLE);
		}
	}
	string msg = ssMsg.str();
	if (!msg.empty())
		reportConfigWarning(msg);
	
}

void GARMIN::PublishHeadings(vector<string> deviceNames, vector<double> headingVals)
{
	for (size_t i = 0; i != headingVals.size(); i++) {
		double dHeading = headingVals[i];
		string name = deviceNames[i];
		if (dHeading != BAD_DOUBLE)
			m_Comms.Notify(m_prefix + name + "_HEADING", dHeading + m_heading_offset);
		else
			reportRunWarning("Did not receive heading info from: " + name);
	}
}

bool GARMIN::buildReport()
{
	m_msgs << endl << "SETUP" << endl;
	m_msgs << "----------------------------------------" << endl;
	m_msgs << "   Publish PREFIX:          " << m_prefix << endl;
	m_msgs << "   Number of NMEA Devices:  " << m_num_devices << endl;
	for (size_t i = 0; i != m_device_names.size(); i++) {
		m_msgs << "   NMEA Device " << i+1 << ":           " << m_device_names[i] << endl;
	}
	m_msgs << "   HEADING_OFFSET:          " << doubleToString(m_heading_offset, 1) << endl;
	
	m_msgs << endl << "DEVICE STATUS" << endl;
	m_msgs << "----------------------------------------" << endl;
	if (m_bValidCanBusConn) {
		m_msgs << "   Communicating properly with NMEA2000 network." << endl;
		m_msgs << endl;
		if (m_num_devices > 0) {
			for (size_t i = 0; i != m_device_names.size(); i++) {
				m_msgs << "   " << m_device_names[i] << " Heading [deg]: " << doubleToString(m_heading_vals[i] + m_heading_offset, 2) << endl;
			}
		}
		else
			m_msgs << "   No connected devices to read from." << endl;
	}
	else
		m_msgs << "   No communications with NMEA2000 network." << endl;
	
	return true;
}

/*
 * HandleNMEA2000Msg:
 * DESCRIPTION: Overwritten handler function to parse input string and record heading
 * records to a static variable which can be written to the MOOSDB. Similar to Data Display
 * Examples given on GitHub here: https://github.com/ttlappalainen/NMEA2000
 */
void GARMIN::HandleNMEA2000Msg(const tN2kMsg &N2kMsg)
{
	for (size_t i = 0; i != m_heading_vals.size(); i++) {
		unsigned char SID;
		tN2kHeadingReference HeadingReference;
		double Heading = 0;
		double Deviation = 0;
		double Variation = 0;
		int idx = 0;
		//Provided Parsing function, Individual parsing functions given by N2kMessage file
		if(N2kMsg.Source == i && ParseN2kHeading(N2kMsg, SID, Heading, Deviation, Variation, HeadingReference)){
			m_heading_vals[i] = Heading*180/M_PI;
		}
	}
}





